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
    
   
        
        RETURN '';
    END GET_BONUS;
    
END TIMECLOCK_PKG;
/
