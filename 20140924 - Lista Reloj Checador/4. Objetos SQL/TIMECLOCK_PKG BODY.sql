CREATE OR REPLACE PACKAGE BODY APPS.TIMECLOCK_PKG IS


    PROCEDURE TIMECLOCK_ADD_DAYS_PRC(
                P_START_DATE VARCHAR2, 
                P_END_DATE VARCHAR2) 
    IS
        var_start_date  DATE := TRUNC(TO_DATE(P_START_DATE,'RRRR/MM/DD HH24:MI:SS'));
        var_end_date    DATE := TRUNC(TO_DATE(P_END_DATE,'RRRR/MM/DD HH24:MI:SS'));
        var_days        NUMBER;    
        var_date        DATE;
        var_day_week    VARCHAR2(25);
        var_day         VARCHAR2(20);
        
    BEGIN
    
        EXECUTE IMMEDIATE 'TRUNCATE TABLE TIMECLOCK_DATES_TB';
        COMMIT;

        var_days := var_end_date - var_start_date;    
        
        FOR i IN 0..var_days LOOP
        
        
            IF i = 0 THEN
                var_date := var_start_date;
            ELSIF i = var_days THEN
                var_date := var_end_date;
            ELSE
                var_date := var_start_date + i; 
            END IF;
        
            
            var_day_week := TRIM(TO_CHAR(var_date, 'DAY'));
            IF    var_day_week IN ('SUNDAY','DOMINGO') THEN var_day := 'DOMINGO';
            ELSIF var_day_week IN ('MONDAY', 'LUNES') THEN var_day := 'LUNES';
            ELSIF var_day_week IN ('TUESDAY', 'MARTES') THEN var_day := 'MARTES';
            ELSIF var_day_week IN ('WEDNESDAY', 'MIÉRCOLES') THEN var_day := 'MIERCOLES';
            ELSIF var_day_week IN ('THURSDAY', 'JUEVES') THEN var_day := 'JUEVES';
            ELSIF var_day_week IN ('FRIDAY', 'VIERNES') THEN var_day := 'VIERNES';
            ELSIF var_day_week IN ('SATURDAY', 'SÁBADO') THEN var_day := 'SABADO';
            END IF; 
            
            
            INSERT INTO TIMECLOCK_DATES_TB(IDENTIFY, TIMECLOCK_DATE, TIMECLOCK_DAY) VALUES ('Y', var_date, var_day);
            
            
        END LOOP;

    END;
    
    
    FUNCTION  TIMECLOCK_HAS_DELAY(
                P_CHECK_DAY     TIMESTAMP)
    RETURN VARCHAR2
    IS
        var_hour    number;
        var_minute  number;
        var_result  VARCHAR2(2) := '';
    BEGIN
    
        IF P_CHECK_DAY  IS NOT NULL  THEN
           
           var_hour := EXTRACT(HOUR FROM P_CHECK_DAY);   
           var_minute := EXTRACT(MINUTE FROM P_CHECK_DAY);
           
           IF (var_hour = 8 OR var_hour = 15) THEN
               
               IF (var_minute >= 6 AND var_minute  <= 10) THEN
                   var_result := 'RE';
               ELSIF (var_minute >= 11) THEN
                   var_result := 'FA'; 
               END IF;
               
           END IF; 
                
        END IF;

        RETURN var_result;
    
    END;


    FUNCTION  TIMECLOCK_FORMAT_HOUR(
                P_CHECK_DAY     TIMESTAMP)
    RETURN VARCHAR2
    IS 
    BEGIN
        IF P_CHECK_DAY IS NOT NULL THEN
            RETURN TO_CHAR(P_CHECK_DAY, 'HH12:MI:SS AM');
        ELSE 
            RETURN '';
        END IF;
    END;  
    
    
    FUNCTION  TIMECLOCK_ABSENCE_DESC(
                P_PERSON_ID         NUMBER,
                P_CHECK_DATE        DATE)
    RETURN VARCHAR2
    IS
        var_result      VARCHAR2(100) := '';
        
    BEGIN
        
        SELECT NVL(PAAV.C_TYPE_DESC, '') || ' ' || 
               (CASE WHEN PAAV.ABSENCE_DAYS / (PAAV.DATE_END - (PAAV.DATE_START -1)) < 1 THEN
                        '1/' || (1 / (PAAV.ABSENCE_DAYS / (PAAV.DATE_END - (PAAV.DATE_START -1))))
                     ELSE
                        TO_CHAR(PAAV.ABSENCE_DAYS / (PAAV.DATE_END - (PAAV.DATE_START -1)))
                END) || ' DÍA' 
          INTO var_result
          FROM PER_ABSENCE_ATTENDANCES_V    PAAV
         WHERE PAAV.PERSON_ID = P_PERSON_ID
           AND P_CHECK_DATE BETWEEN PAAV.DATE_START AND PAAV.DATE_END
           AND ROWNUM = 1;
    
        RETURN UPPER(var_result);
        
    END; 
    
    FUNCTION  GET_BONUS(
                P_PERSON_ID         NUMBER,
                P_START_DATE        DATE,
                P_END_DATE          DATE)
    RETURN VARCHAR2
    IS
        var_result      NUMBER;
    BEGIN
    
   
        SELECT SUM(PRRV.RESULT_VALUE)
          INTO var_result
          FROM PAY_PAYROLL_ACTIONS          PPA,
               PAY_PAYROLLS_F               PPF,
               PER_TIME_PERIODS             PTP,
               PER_ALL_ASSIGNMENTS_F        PAAF,
               PAY_ASSIGNMENT_ACTIONS       PAA,
               PAY_RUN_RESULTS              PRR,
               PAY_ELEMENT_TYPES_F          PETF,
               PAY_RUN_RESULT_VALUES        PRRV,
               PAY_INPUT_VALUES_F           PIVF,
               PAY_ELEMENT_CLASSIFICATIONS  PEC
         WHERE 1 = 1 
           AND PPF.PAYROLL_ID = PPA.PAYROLL_ID
           AND PTP.PAYROLL_ID = PPF.PAYROLL_ID
           AND PTP.START_DATE = P_START_DATE
           AND PTP.END_DATE = P_END_DATE
           AND PPA.EFFECTIVE_DATE BETWEEN PTP.START_DATE AND PTP.END_DATE
           AND PTP.TIME_PERIOD_ID = PPA.TIME_PERIOD_ID   
           AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
           AND PAAF.PERSON_ID = P_PERSON_ID
           AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID 
           AND PAA.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID 
           AND PPF.PAYROLL_NAME NOT IN ('02_SEM - GRBE', '02_QUIN - EVENTUAL')
           AND PPA.EFFECTIVE_DATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
           AND PPA.EFFECTIVE_DATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
           AND PAC_CFDI_FUNCTIONS_PKG.GET_PAYMENT_METHOD(PAA.ASSIGNMENT_ID) LIKE '%%'
           AND PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
           AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
           AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
           AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
           AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
           AND PETF.ELEMENT_NAME  IN ('P039_DESPENSA')
           AND PIVF.UOM = 'M'
           AND PIVF.NAME = 'Pay Value'
           AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE;
    
        RETURN 'BONO : ' || TO_CHAR(var_result) || ' ';
        
--        RETURN '';
    END GET_BONUS;
    
END TIMECLOCK_PKG;
/
