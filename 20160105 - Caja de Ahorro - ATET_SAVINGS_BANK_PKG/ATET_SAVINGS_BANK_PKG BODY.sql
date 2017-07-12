CREATE OR REPLACE PACKAGE BODY APPS.ATET_SAVINGS_BANK_PKG IS

    FUNCTION    GET_SAVING_BANK_ID
      RETURN    ATET_SAVINGS_BANK.SAVING_BANK_ID%TYPE
    IS
        var_saving_bank_id      ATET_SAVINGS_BANK.SAVING_BANK_ID%TYPE;
    BEGIN
        
        SELECT SB.SAVING_BANK_ID
          INTO var_saving_bank_id
          FROM ATET_SAVINGS_BANK SB
         WHERE 1 = 1 
           AND SB.SAVING_BANK_STATUS = 'OPEN';

        RETURN var_saving_bank_id;
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_SAVING_BANK_ID ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_SAVING_BANK_ID;
    
    
    FUNCTION    GET_SAVING_BANK_YEAR
      RETURN    ATET_SAVINGS_BANK.YEAR%TYPE
    IS
        var_saving_bank_year    ATET_SAVINGS_BANK.YEAR%TYPE;
    BEGIN
    
        SELECT ASB.YEAR
          INTO var_saving_bank_year
          FROM ATET_SAVINGS_BANK    ASB
         WHERE 1 = 1
           AND ASB.SAVING_BANK_ID = GET_SAVING_BANK_ID; 
           
        RETURN var_saving_bank_year;
        
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_SAVING_BANK_YEAR ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_SAVING_BANK_YEAR;
    
    
    FUNCTION    GET_AVAILABLE_PERIODS(
                    P_MEMBER_ID   ATET_SB_MEMBERS.MEMBER_ID%TYPE)
      RETURN    NUMBER
    IS
        var_count_periods   NUMBER;
        var_extemp_loans    VARCHAR2(50);
    BEGIN
    
        var_extemp_loans := NVL(GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'EXTEMP_LOANS'), 'N');
    
        IF var_extemp_loans = 'N' THEN 
            SELECT COUNT(D.PERIOD_NAME)
              INTO var_count_periods
              FROM (SELECT PTP.PERIOD_NAME,
                           PTP.TIME_PERIOD_ID,
                           PAF.ASSIGNMENT_ID,
                           PAF.PAYROLL_ID,
                           PTP.START_DATE,
                           PTP.END_DATE,
                           PAF.EFFECTIVE_START_DATE,
                           PAF.EFFECTIVE_END_DATE
                      FROM ATET_SB_MEMBERS          ASM,
                           ATET_SAVINGS_BANK        ASB,
                           PER_ASSIGNMENTS_F        PAF,
                           PER_TIME_PERIODS         PTP
                     WHERE 1 = 1
                       AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
                       AND ASM.PERSON_ID = PAF.PERSON_ID
                       AND ASM.SAVING_BANK_ID = ASB.SAVING_BANK_ID
                       AND ASM.MEMBER_ID = P_MEMBER_ID
                       AND PTP.PAYROLL_ID = PAF.PAYROLL_ID    
                       AND EXTRACT(YEAR FROM PTP.END_DATE) = ASB.YEAR
                       AND PTP.END_DATE BETWEEN SYSDATE AND ASB.TERMINATION_DATE) D
               LEFT JOIN PAY_PAYROLL_ACTIONS          PPA
                 ON PPA.PAYROLL_ID = D.PAYROLL_ID
                AND PPA.TIME_PERIOD_ID = D.TIME_PERIOD_ID
                AND PPA.EFFECTIVE_DATE BETWEEN D.START_DATE AND D.END_DATE
                AND PPA.EFFECTIVE_DATE BETWEEN D.EFFECTIVE_START_DATE AND D.EFFECTIVE_END_DATE
               LEFT JOIN PAY_ASSIGNMENT_ACTIONS       PAA
                 ON PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
                AND PAA.ASSIGNMENT_ID = D.ASSIGNMENT_ID
                AND PAA.RUN_TYPE_ID IS NOT NULL 
              WHERE 1 = 1 
                AND PPA.TIME_PERIOD_ID IS NULL
              ORDER BY D.TIME_PERIOD_ID;
        ELSE 
            SELECT COUNT(D.PERIOD_NAME)
              INTO var_count_periods
              FROM (SELECT PTP.PERIOD_NAME,
                           PTP.TIME_PERIOD_ID,
                           PAF.ASSIGNMENT_ID,
                           PAF.PAYROLL_ID,
                           PTP.START_DATE,
                           PTP.END_DATE,
                           PAF.EFFECTIVE_START_DATE,
                           PAF.EFFECTIVE_END_DATE
                      FROM ATET_SB_MEMBERS          ASM,
                           ATET_SAVINGS_BANK        ASB,
                           PER_ASSIGNMENTS_F        PAF,
                           PER_TIME_PERIODS         PTP
                     WHERE 1 = 1
                       AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
                       AND ASM.PERSON_ID = PAF.PERSON_ID
                       AND ASM.SAVING_BANK_ID = ASB.SAVING_BANK_ID
                       AND ASM.MEMBER_ID = P_MEMBER_ID
                       AND PTP.PAYROLL_ID = PAF.PAYROLL_ID    
                       AND EXTRACT(YEAR FROM PTP.END_DATE) = ASB.YEAR
                       ) D
               LEFT JOIN PAY_PAYROLL_ACTIONS          PPA
                 ON PPA.PAYROLL_ID = D.PAYROLL_ID
                AND PPA.TIME_PERIOD_ID = D.TIME_PERIOD_ID
                AND PPA.EFFECTIVE_DATE BETWEEN D.START_DATE AND D.END_DATE
                AND PPA.EFFECTIVE_DATE BETWEEN D.EFFECTIVE_START_DATE AND D.EFFECTIVE_END_DATE
               LEFT JOIN PAY_ASSIGNMENT_ACTIONS       PAA
                 ON PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
                AND PAA.ASSIGNMENT_ID = D.ASSIGNMENT_ID
                AND PAA.RUN_TYPE_ID IS NOT NULL 
              WHERE 1 = 1 
                AND PPA.TIME_PERIOD_ID IS NULL
              ORDER BY D.TIME_PERIOD_ID;
        END IF;
           
        RETURN var_count_periods; 
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_AVAILABLE_PERIODS ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_AVAILABLE_PERIODS;
    
    
    FUNCTION    GET_PERIOD_TYPE(
                    P_PERSON_ID             ATET_SB_MEMBERS.PERSON_ID%TYPE)
      RETURN    PAY_PAYROLLS_F.PERIOD_TYPE%TYPE
    IS
        var_period_type    PAY_PAYROLLS_F.PERIOD_TYPE%TYPE;
    BEGIN
        
        SELECT PPF.PERIOD_TYPE
          INTO var_period_type
          FROM PER_ASSIGNMENTS_F    PAF,
               PAY_PAYROLLS_F       PPF
         WHERE 1 = 1
           AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
           AND PAF.PERSON_ID = P_PERSON_ID
           AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE;
                   
        RETURN var_period_type;    
    
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_PERIOD_TYPE ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_PERIOD_TYPE;
    
      
    FUNCTION    GET_REGISTRATION_DATE
      RETURN    ATET_SAVINGS_BANK.REGISTRATION_DATE%TYPE
    IS
        var_registration_date   ATET_SAVINGS_BANK.REGISTRATION_DATE%TYPE;
    BEGIN
        
        SELECT SB.REGISTRATION_DATE
          INTO var_registration_date
          FROM ATET_SAVINGS_BANK    SB
         WHERE 1 = 1
           AND SB.SAVING_BANK_ID = GET_SAVING_BANK_ID;
           
        RETURN var_registration_date;
    
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_REGISTRATION_DATE ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_REGISTRATION_DATE;
    
    
    FUNCTION    GET_PARAMETER_VALUE(
                    P_SAVING_BANK_ID          ATET_SAVINGS_BANK.SAVING_BANK_ID%TYPE,
                    P_PARAMETER_CODE          ATET_SB_PARAMETERS.PARAMETER_CODE%TYPE)
      RETURN    ATET_SB_PARAMETERS.PARAMETER_VALUE%TYPE
    IS
        var_parameter_value     ATET_SB_PARAMETERS.PARAMETER_VALUE%TYPE;
    BEGIN
    
        SELECT ASP.PARAMETER_VALUE
          INTO var_parameter_value
          FROM ATET_SB_PARAMETERS   ASP
         WHERE 1 = 1    
           AND ASP.SAVING_BANK_ID = P_SAVING_BANK_ID
           AND ASP.PARAMETER_CODE = P_PARAMETER_CODE 
           AND (   ASP.EFFECTIVE_END_DATE IS NULL
                OR SYSDATE BETWEEN ASP.EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE);
                
        RETURN var_parameter_value;
    
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_PARAMETER_VALUE ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_PARAMETER_VALUE;
    
    
    FUNCTION    IF_MEMBER_EXIST(
                    P_EMPLOYEE_NUMBER      ATET_SB_MEMBERS.EMPLOYEE_NUMBER%TYPE
                )
      RETURN    NUMBER
    IS
        var_result  NUMBER;
    BEGIN
        
        SELECT COUNT(ASM.PERSON_ID)
          INTO var_result
          FROM ATET_SB_MEMBERS ASM
         WHERE 1 = 1
           AND ASM.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
           AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
    
        RETURN var_result;
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en IF_MEMBER_EXIST ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END IF_MEMBER_EXIST;
    
    
    FUNCTION GET_MAX_ASSIGNMENT_ACTION_ID(
                P_ASSIGNMENT_ID        PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ID%TYPE,
                P_PAYROLL_ID           PAY_PAYROLL_ACTIONS.PAYROLL_ID%TYPE)
        RETURN PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ACTION_ID%TYPE                                         
    IS
              
        var_assignment_action_id    PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ACTION_ID%TYPE;
              
    BEGIN
              
        SELECT MAX(PAA.ASSIGNMENT_ACTION_ID)
          INTO var_assignment_action_id
          FROM PAY_ASSIGNMENT_ACTIONS       PAA,
               PAY_PAYROLL_ACTIONS          PPA,
               PER_TIME_PERIODS             PTP,
               PAY_RUN_TYPES_F              PRT,
               PAY_CONSOLIDATION_SETS       PCS
         WHERE 1 = 1
           AND PAA.ASSIGNMENT_ID = P_ASSIGNMENT_ID
           AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
           AND PPA.PAYROLL_ID = P_PAYROLL_ID
           AND PPA.ACTION_TYPE IN ('Q', 'R')
           AND PPA.TIME_PERIOD_ID = PTP.TIME_PERIOD_ID
           AND PAA.RUN_TYPE_ID = PRT.RUN_TYPE_ID
           AND PRT.RUN_TYPE_NAME IN ('Standard') 
           AND PPA.CONSOLIDATION_SET_ID = PCS.CONSOLIDATION_SET_ID
           AND PCS.CONSOLIDATION_SET_NAME IN ('NORMAL')
         ORDER BY PPA.DATE_EARNED DESC,
                  PAA.ASSIGNMENT_ACTION_ID DESC; 
                       
        RETURN var_assignment_action_id;   
    
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_MAX_ASSIGNMENT_ACTION_ID ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_MAX_ASSIGNMENT_ACTION_ID;
    
    
    FUNCTION GET_SUBTBR(
                P_ASSIGNMENT_ACTION_ID      PAY_RUN_RESULTS.ASSIGNMENT_ACTION_ID%TYPE)
      RETURN PAY_RUN_RESULT_VALUES.RESULT_VALUE%TYPE
    IS 
        var_result_value    PAY_RUN_RESULT_VALUES.RESULT_VALUE%TYPE;
    BEGIN
        
         SELECT SUM(RESULT)
           INTO var_result_value
           FROM(SELECT SUM(PRRV.RESULT_VALUE) AS RESULT
                  FROM PAY_RUN_RESULTS              PRR,
                       PAY_ELEMENT_TYPES_F          PETF,
                       PAY_RUN_RESULT_VALUES        PRRV,
                       PAY_INPUT_VALUES_F           PIVF,
                       PAY_ELEMENT_CLASSIFICATIONS  PEC
                 WHERE PRR.ASSIGNMENT_ACTION_ID = P_ASSIGNMENT_ACTION_ID
                   AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
                   AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
                   AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
                   AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
                   AND (PEC.CLASSIFICATION_NAME IN ('Earnings', 
                                                    'Supplemental Earnings', 
                                                    'Amends', 
                                                    'Imputed Earnings') 
                          OR PETF.ELEMENT_NAME  IN (SELECT MEANING
                                                      FROM FND_LOOKUP_VALUES 
                                                     WHERE LOOKUP_TYPE = 'XX_PERCEPCIONES_INFORMATIVAS'
                                                       AND LANGUAGE = USERENV('LANG')))
                   AND PIVF.UOM = 'M'
                   AND (PIVF.NAME = 'ISR Subject' OR PIVF.NAME = 'ISR Exempt')
                UNION
                SELECT SUM(PRRV.RESULT_VALUE) AS RESULT                    
                  FROM PAY_RUN_RESULTS              PRR,
                       PAY_ELEMENT_TYPES_F          PETF,
                       PAY_RUN_RESULT_VALUES        PRRV,
                       PAY_INPUT_VALUES_F           PIVF,
                       PAY_ELEMENT_CLASSIFICATIONS  PEC
                 WHERE PRR.ASSIGNMENT_ACTION_ID = P_ASSIGNMENT_ACTION_ID
                   AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
                   AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
                   AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
                   AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
                   AND PETF.ELEMENT_NAME  IN ('FINAN_TRABAJO_RET',
                                              'P080_FONDO AHORRO TR ACUM',
                                              'P017_PRIMA DE ANTIGUEDAD',
                                              'P032_SUBSIDIO_PARA_EMPLEO')
                   AND PIVF.UOM = 'M'
                   AND PIVF.NAME = 'Pay Value');
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_SUBTBR(P_ASSIGNMENT_ACTION_ID => ' || P_ASSIGNMENT_ACTION_ID ||
                                                  ') RETURN 0');
    
        RETURN 0;
    END GET_SUBTBR;
    
       
    FUNCTION    GET_PERSON_TERMINATION_DATE(
                    P_PERSON_ID     PER_ASSIGNMENTS_F.PERSON_ID%TYPE)
      RETURN    VARCHAR2
    IS
        var_actual_termination_date VARCHAR(100) := 'NOTHING';
    BEGIN
    
        SELECT DISTINCT
               PPOS.ACTUAL_TERMINATION_DATE
          INTO var_actual_termination_date
          FROM PER_PEOPLE_F             PPF,
               PER_ASSIGNMENTS_F        PAF,
               PER_PERIODS_OF_SERVICE   PPOS
         WHERE 1 = 1
           AND PPF.PERSON_ID = PAF.PERSON_ID
           AND PPF.PERSON_ID = PPOS.PERSON_ID
           AND PAF.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID
           AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
           AND PPF.PERSON_ID = P_PERSON_ID;
           
        RETURN var_actual_termination_date;   
        
    EXCEPTION WHEN NO_DATA_FOUND THEN    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_PERSON_TERMINATION_DATE(P_PERSON_ID => ' || P_PERSON_ID ||
                                                                   ') RETURN ' || var_actual_termination_date);
        DBMS_OUTPUT.PUT_LINE('NO_DATA_FOUND');
        RETURN 'NOTHING'; 
    END GET_PERSON_TERMINATION_DATE;
    
      
    FUNCTION    GET_MEMBER_TERMINATION_DATE(
                    P_PERSON_ID     NUMBER)
      RETURN    VARCHAR2
    IS
        var_member_termination_date VARCHAR2(50) := 'NOTHING';
    BEGIN
    
        SELECT SBM.MEMBER_END_DATE
          INTO var_member_termination_date
          FROM ATET_SB_MEMBERS SBM
         WHERE 1 = 1
           AND SBM.PERSON_ID = P_PERSON_ID
           AND SBM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
           
--        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_MEMBER_TERMINATION_DATE(P_PERSON_ID => ' || P_PERSON_ID || 
--                                                                    ') RETURN ' || var_member_termination_date); 
           
        RETURN var_member_termination_date;
    EXCEPTION WHEN NO_DATA_FOUND THEN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_MEMBER_TERMINATION_DATE(P_PERSON_ID => ' || P_PERSON_ID || 
                                                                    ') RETURN ' || var_member_termination_date);
    
        RETURN var_member_termination_date;
    END GET_MEMBER_TERMINATION_DATE;
    
    
    PROCEDURE   EXPORT_PAYROLL_RESULTS(
                    P_ERRBUF         OUT NOCOPY  VARCHAR2,
                    P_RETCODE        OUT NOCOPY  VARCHAR2,
                    P_PERIOD_TYPE    VARCHAR2,
                    P_YEAR           NUMBER,
                    P_MONTH          NUMBER,
                    P_PERIOD_NAME    VARCHAR2)
    IS
    
        CURSOR  DETAIL_LIST IS
            SELECT DISTINCT 
                   PAF.PERSON_ID            AS  "PERSON_ID",
                   PAF.ASSIGNMENT_ID        AS  "ASSIGNMENT_ID",
                   PAA.ASSIGNMENT_ACTION_ID AS  "ASSIGNMENT_ACTION_ID",
                   PPA.PAYROLL_ACTION_ID    AS  "PAYROLL_ACTION_ID",
                   PPA.DATE_EARNED          AS  "EARNED_DATE",
                   PTP.TIME_PERIOD_ID       AS  "TIME_PERIOD_ID",
                   PTP.PERIOD_NAME          AS  "PERIOD_NAME",
                   ATET_SAVINGS_BANK_PKG.GET_LOOKUP_MEANING('ACTION_STATUS', 
                                                            PPA.ACTION_STATUS)        AS  "PAYROLL_STATUS",
                   PETF.ELEMENT_NAME        AS  "ELEMENT_NAME",
                   PIVF.NAME                AS  "ENTRY_NAME",
                   ATET_SAVINGS_BANK_PKG.GET_LOOKUP_MEANING('UNITS', 
                                                            PIVF.UOM)                 AS  "ENTRY_UNITS",
                   PRRV.RESULT_VALUE        AS  "ENTRY_VALUE",
                   PRR.RUN_RESULT_ID        AS  "RUN_RESULT_ID",
                   PRR.ELEMENT_ENTRY_ID     AS  "ELEMENT_ENTRY_ID"
              FROM PAY_PAYROLL_ACTIONS          PPA,
                   PER_TIME_PERIODS             PTP,
                   PAY_ASSIGNMENT_ACTIONS       PAA,
                   PAY_PAYROLLS_F               PPF,
                   PER_ASSIGNMENTS_F            PAF,
                   PAY_RUN_RESULTS              PRR,
                   PAY_ELEMENT_TYPES_F          PETF,
                   PAY_RUN_RESULT_VALUES        PRRV,
                   PAY_INPUT_VALUES_F           PIVF,
                   PAY_ELEMENT_CLASSIFICATIONS  PEC
             WHERE 1 = 1
               AND PTP.TIME_PERIOD_ID = PPA.TIME_PERIOD_ID
               AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
               AND PPA.PAYROLL_ID = PPF.PAYROLL_ID     
               AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(P_PERIOD_TYPE, PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
               AND PPA.ACTION_TYPE IN ('Q', 'R', 'B')
               AND PTP.PERIOD_NAME LIKE '%' || P_YEAR || '%'
               AND PTP.PERIOD_NAME = NVL(P_PERIOD_NAME, PTP.PERIOD_NAME)
               AND EXTRACT(MONTH FROM PPA.DATE_EARNED) >= P_MONTH
               AND PAF.ASSIGNMENT_ID = PAA.ASSIGNMENT_ID
               AND PPA.DATE_EARNED BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
               AND PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
               AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
               AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
               AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
               AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
               AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
               AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
               AND PETF.ELEMENT_NAME IN (ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME'),
                                         ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME')) 
             ORDER BY PAF.PERSON_ID,
                      PETF.ELEMENT_NAME,
                      PIVF.NAME,
                      PRR.RUN_RESULT_ID;
   
        TYPE   DETAILS IS TABLE OF DETAIL_LIST%ROWTYPE INDEX BY PLS_INTEGER;
     
        detail DETAILS;
        
        var_request_id              NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        var_log                     VARCHAR2(1000);
        var_user_id                 NUMBER := FND_GLOBAL.USER_ID;
        var_validate                NUMBER;
        
        var_import_request_id       NUMBER;
        var_waiting                 BOOLEAN;
        var_phase                   VARCHAR2 (80 BYTE);
        var_status                  VARCHAR2 (80 BYTE);
        var_dev_phase               VARCHAR2 (80 BYTE);
        var_dev_status              VARCHAR2 (80 BYTE);
        var_message                 VARCHAR2 (4000 BYTE);
    
    BEGIN
    
--        FND_FILE.PUT_LINE(FND_FILE.LOG, 'EXPORT_PAYROLL_RESULTS(P_PERIOD_TYPE => ' || P_PERIOD_TYPE ||
--                                                              ',P_YEAR => ' || P_YEAR ||
--                                                              ',P_MONTH => ' || P_MONTH ||
--                                                              ',P_PERIOD_NAME => ' || P_PERIOD_NAME ||
--                                                              ')');
        
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '***********     PARAMETERS     ***********');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_PERIOD_TYPE : ' || P_PERIOD_TYPE);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_YEAR : ' || P_YEAR);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_MONTH : ' || P_MONTH);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_PERIOD_NAME : ' || P_PERIOD_NAME);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '******************************************'); 
        
        SELECT COUNT(ASPR.PERIOD_NAME) 
          INTO var_validate
          FROM ATET_SB_PAYROLL_RESULTS ASPR 
         WHERE 1 = 1
           AND ASPR.PERIOD_NAME = P_PERIOD_NAME;
        
        IF var_validate = 0 THEN
        
            OPEN DETAIL_LIST;
            
            LOOP
            
                FETCH DETAIL_LIST BULK COLLECT INTO detail LIMIT 500;
                
                EXIT WHEN detail.COUNT = 0;
                
                FOR rowIndex IN 1 .. detail.COUNT
                LOOP
                
                    INSERT INTO ATET_SB_PAYROLL_RESULTS(PERSON_ID,
                                                        ASSIGNMENT_ID,
                                                        ASSIGNMENT_ACTION_ID,
                                                        PAYROLL_ACTION_ID,
                                                        EARNED_DATE,
                                                        TIME_PERIOD_ID,
                                                        PERIOD_NAME,
                                                        PAYROLL_STATUS,
                                                        ELEMENT_NAME,
                                                        ENTRY_NAME,
                                                        ENTRY_UNITS,
                                                        ENTRY_VALUE,
                                                        RUN_RESULT_ID,
                                                        ELEMENT_ENTRY_ID,
                                                        EXPORT_REQUEST_ID,
                                                        ATTRIBUTE6,
                                                        CREATION_DATE,
                                                        CREATED_BY,
                                                        LAST_UPDATE_DATE,
                                                        LAST_UPDATED_BY)
                                                 VALUES (detail(rowIndex).PERSON_ID,
                                                         detail(rowIndex).ASSIGNMENT_ID,
                                                         detail(rowIndex).ASSIGNMENT_ACTION_ID,
                                                         detail(rowIndex).PAYROLL_ACTION_ID,
                                                         detail(rowIndex).EARNED_DATE,
                                                         detail(rowIndex).TIME_PERIOD_ID,
                                                         detail(rowIndex).PERIOD_NAME,
                                                         detail(rowIndex).PAYROLL_STATUS,
                                                         detail(rowIndex).ELEMENT_NAME,
                                                         detail(rowIndex).ENTRY_NAME,
                                                         detail(rowIndex).ENTRY_UNITS,
                                                         detail(rowIndex).ENTRY_VALUE,
                                                         detail(rowIndex).RUN_RESULT_ID,
                                                         detail(rowIndex).ELEMENT_ENTRY_ID,
                                                         var_request_id,
                                                         'IMPORTED',
                                                         SYSDATE,
                                                         var_user_id,
                                                         SYSDATE,
                                                         var_user_id);
                                 
                    COMMIT;
                    
                
                    var_log := RPAD(detail(rowIndex).PERSON_ID, 10, ' ')              ||
                               RPAD(detail(rowIndex).ASSIGNMENT_ID, 10, ' ')          ||
                               RPAD(detail(rowIndex).ASSIGNMENT_ACTION_ID, 10, ' ')   ||
                               RPAD(detail(rowIndex).PAYROLL_ACTION_ID, 10, ' ')      ||
                               RPAD(detail(rowIndex).EARNED_DATE, 15, ' ')            ||
                               RPAD(detail(rowIndex).TIME_PERIOD_ID, 15, ' ')         ||
                               RPAD(detail(rowIndex).PERIOD_NAME, 20, ' ')            ||
                               RPAD(detail(rowIndex).PAYROLL_STATUS, 10, ' ')         ||
                               RPAD(detail(rowIndex).ELEMENT_NAME, 30, ' ')           ||
                               RPAD(detail(rowIndex).ENTRY_NAME, 15, ' ')             ||
                               RPAD(detail(rowIndex).ENTRY_UNITS, 10, ' ')            ||
                               RPAD(detail(rowIndex).ENTRY_VALUE, 10, ' ');
                    
                    FND_FILE.PUT_LINE(FND_FILE.LOG ,var_log);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT ,var_log);       
                        
                END LOOP;
                
            END LOOP;
            
            CLOSE DETAIL_LIST;

            
        ELSE
        
            P_ERRBUF := 'EL PROCESO DE EXPORTACIÓN PARA EL PERIODO ' || P_PERIOD_NAME || ' YA FUE EJECUTADO ANTERIORMENTE.';
            P_RETCODE := 1;
        
        END IF;
        
    
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en EXPORT_PAYROLL_RESULTS ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END EXPORT_PAYROLL_RESULTS;
    
    
    PROCEDURE   IMPORT_PAYROLL_RESULTS(
                    P_ERRBUF            OUT NOCOPY  VARCHAR2,
                    P_RETCODE           OUT NOCOPY  VARCHAR2,
                    P_EXPORT_REQUEST_ID NUMBER)
    IS
        var_import_request_id       NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        var_log                     VARCHAR2(1000);
        var_user_id                 NUMBER := FND_GLOBAL.USER_ID;
        var_validate                NUMBER;
        var_have_account            NUMBER;
        var_result                  VARCHAR2(50) := 'N';
        
        var_period_name             VARCHAR2(200);
        
        var_sum_saving_amount       NUMBER;
        var_sum_saving_pay_value    NUMBER;
        var_sum_saving_import       NUMBER;
        
        var_sum_loan_amount         NUMBER;
        var_sum_loan_pay_value      NUMBER;
        var_sum_loan_import         NUMBER;
        
        var_pp_payment_date         DATE;
        var_pp_period_name          VARCHAR2(200);
        var_skip_count              NUMBER;
        
    BEGIN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'IMPORT_PAYROLL_RESULTS(P_EXPORT_REQUEST_ID => ' || P_EXPORT_REQUEST_ID || ')');
    
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '***********     PARAMETERS     ***********');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_EXPORT_REQUEST_ID : ' || P_EXPORT_REQUEST_ID);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '******************************************');
        
    
        SELECT COUNT(ASPR.EXPORT_REQUEST_ID)
          INTO var_validate
          FROM ATET_SB_PAYROLL_RESULTS ASPR
         WHERE 1 = 1
           AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
           AND ASPR.IMPORT_REQUEST_ID IS NOT NULL;
           
           
        IF var_validate = 0 THEN
        
            UPDATE ATET_SB_PAYROLL_RESULTS
               SET IMPORT_REQUEST_ID = var_import_request_id,
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = var_user_id
             WHERE EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID;
             
            COMMIT;
            
            DECLARE
                CURSOR DETAIL_LIST_SAVINGS IS
                    SELECT ASPR.PAYROLL_RESULT_ID,
                           ASPR.PERSON_ID,
                           ASPR.ASSIGNMENT_ID,
                           ASPR.ASSIGNMENT_ACTION_ID,
                           ASPR.PAYROLL_ACTION_ID,
                           ASPR.EARNED_DATE,
                           ASPR.TIME_PERIOD_ID,
                           ASPR.PERIOD_NAME,
                           ASPR.PAYROLL_STATUS,
                           ASPR.ELEMENT_NAME,
                           ASPR.ENTRY_NAME,
                           ASPR.ENTRY_UNITS,
                           ASPR.ENTRY_VALUE
                      FROM ATET_SB_PAYROLL_RESULTS  ASPR
                     WHERE 1 = 1
                       AND ASPR.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME')
                       AND ASPR.ENTRY_NAME = 'Pay Value'
                       AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                       AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;           
                
                CURSOR DETAIL_LIST_LOANS IS
                    SELECT ASPR.EXPORT_REQUEST_ID,
                           ASPR.PAYROLL_RESULT_ID,
                           ASPR.PERSON_ID,
                           ASPR.ASSIGNMENT_ID,
                           ASPR.ASSIGNMENT_ACTION_ID,
                           ASPR.PAYROLL_ACTION_ID,
                           ASPR.EARNED_DATE,
                           ASPR.TIME_PERIOD_ID,
                           ASPR.PERIOD_NAME,
                           ASPR.PAYROLL_STATUS,
                           ASPR.ELEMENT_NAME,
                           ASPR.ENTRY_NAME,
                           ASPR.ENTRY_UNITS,
                           ASPR.ENTRY_VALUE,
                           ASPR.RUN_RESULT_ID,
                           ASPR.ELEMENT_ENTRY_ID
                      FROM ATET_SB_PAYROLL_RESULTS  ASPR
                     WHERE 1 = 1
                       AND ASPR.ELEMENT_NAME = ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME')
                       AND ASPR.ENTRY_NAME = 'Pay Value'
                       AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                       AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;   
                       
                CURSOR SKIP_PAYMENTS_LIST (PP_PAYMENT_DATE      DATE, 
                                           PP_PERIOD_NAME       VARCHAR2) IS
                    SELECT ASM.PERSON_ID                    AS  PERSON_ID,
                           ASPS.PAYMENT_DATE                AS  EARNED_DATE,
                           ASPS.TIME_PERIOD_ID              AS  TIME_PERIOD_ID,
                           PP_PERIOD_NAME                   AS  PERIOD_NAME,
                           0                                AS  ENTRY_VALUE,
                           -1                               AS  PAYROLL_RESULT_ID,
                           'D072_PRESTAMO CAJA DE AHORRO'   AS  ELEMENT_NAME,
                           'Pay Value'                      AS  ENTRY_NAME,
                           'Dinero'                         AS  ENTRY_UNITS,
                           ASPS.PAYMENT_SCHEDULE_ID         AS  PAYMENT_SCHEDULE_ID
                      FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS,
                           ATET_SB_LOANS                ASL,
                           ATET_SB_MEMBERS              ASM 
                     WHERE 1 = 1
                       AND ASPS.LOAN_ID = ASL.LOAN_ID
                       AND ASL.MEMBER_ID = ASM.MEMBER_ID
                       AND ASPS.PERIOD_NAME = PP_PERIOD_NAME
                       AND ASPS.PAYMENT_DATE = PP_PAYMENT_DATE
                       AND ASPS.STATUS_FLAG IN ('PENDING', 'EXPORTED');
                      
            
                    
            BEGIN
            
                IF var_result = 'N' THEN    
                
                    OPEN DETAIL_LIST_SAVINGS;
                    IF DETAIL_LIST_SAVINGS%ROWCOUNT = 0 THEN
                        var_result := 'Y';
                    END IF;
                    CLOSE DETAIL_LIST_SAVINGS;
                                 
                    FOR detail_saving IN DETAIL_LIST_SAVINGS LOOP
                        
                        CREATE_ACCOUNT(detail_saving.PERSON_ID,
                                       'SAVINGS_ELEMENT_NAME',
                                       'SAV_CODE_COMB');                             
                            
                        var_result := 'N';
                        
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'PROCESANDO: ' || detail_saving.PAYROLL_RESULT_ID  || ','
                                                                       || detail_saving.PERSON_ID          || ','
                                                                       || detail_saving.EARNED_DATE        || ','
                                                                       || detail_saving.PERIOD_NAME        || ','
                                                                       || detail_saving.ELEMENT_NAME       || ','
                                                                       || detail_saving.ENTRY_NAME         || ','
                                                                       || detail_saving.ENTRY_UNITS        || ','
                                                                       || detail_saving.ENTRY_VALUE);
                        
                        var_result := INSERT_SAVING_TRANSACTION(P_PAYROLL_RESULT_ID => detail_saving.PAYROLL_RESULT_ID,
                                                                P_PERSON_ID => detail_saving.PERSON_ID,
                                                                P_EARNED_DATE => detail_saving.EARNED_DATE,
                                                                P_TIME_PERIOD_ID => detail_saving.TIME_PERIOD_ID,
                                                                P_PERIOD_NAME => detail_saving.PERIOD_NAME,
                                                                P_ELEMENT_NAME => detail_saving.ELEMENT_NAME,
                                                                P_ENTRY_NAME => detail_saving.ENTRY_NAME,
                                                                P_ENTRY_UNITS => detail_saving.ENTRY_UNITS,
                                                                P_ENTRY_VALUE => detail_saving.ENTRY_VALUE,
                                                                P_DEBIT_AMOUNT => 0,
                                                                P_CREDIT_AMOUNT => detail_saving.ENTRY_VALUE);
                        
                        UPDATE ATET_SB_PAYROLL_RESULTS ASPR
                           SET ASPR.ATTRIBUTE7 = 'PROCESSED',
                               ASPR.LAST_UPDATE_DATE = SYSDATE,
                               ASPR.LAST_UPDATED_BY = var_user_id
                         WHERE ASPR.PAYROLL_RESULT_ID = detail_saving.PAYROLL_RESULT_ID;
                                                                    
                        IF var_result = 'N' THEN
                            EXIT;
                        END IF;                          
                                
                    END LOOP;
                    
                    IF    var_result = 'Y' THEN
                    
                        BEGIN
                            SELECT DISTINCT ASPR.PERIOD_NAME
                              INTO var_period_name
                              FROM ATET_SB_PAYROLL_RESULTS  ASPR
                             WHERE 1 = 1
                               AND ASPR.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME')
                               AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                               AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                               
                            SELECT SUM(ASPEE.ENTRY_VALUE1)
                              INTO var_sum_saving_import
                              FROM ATET_SB_PAY_ELEMENT_ENTRIES  ASPEE
                             WHERE 1 = 1
                               AND ASPEE.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME')
                               AND ASPEE.PERIOD_NAME = var_period_name;
                            
                            SELECT SUM(ASPR.ENTRY_VALUE)
                              INTO var_sum_saving_amount
                              FROM ATET_SB_PAYROLL_RESULTS  ASPR
                             WHERE 1 = 1
                               AND ASPR.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME')
                               AND ASPR.ENTRY_NAME = 'Amount'
                               AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                               AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                               
                            SELECT SUM(ASPR.ENTRY_VALUE)
                              INTO var_sum_saving_pay_value
                              FROM ATET_SB_PAYROLL_RESULTS  ASPR
                             WHERE 1 = 1
                               AND ASPR.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME')
                               AND ASPR.ENTRY_NAME = 'Pay Value'
                               AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                               AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'SIN DECUENTOS ' ||GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME'));    
                        END;
                        
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '********************************************************');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   '||GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME'));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   DESCUENTOS EXPORTADOS    : ' || TO_CHAR(var_sum_saving_import));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   DESCUENTOS PROGRAMADOS   : ' || TO_CHAR(var_sum_saving_amount));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   DESCUENTOS REALES        : ' || TO_CHAR(var_sum_saving_pay_value));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '********************************************************');
                        
                    ELSIF var_result = 'N' THEN
                        
                        ROLLBACK;
                    
                        UPDATE ATET_SB_PAYROLL_RESULTS  ASPR
                           SET ASPR.IMPORT_REQUEST_ID = NULL,
                               ASPR.ATTRIBUTE6 = NULL,
                               ASPR.LAST_UPDATE_DATE = SYSDATE,
                               ASPR.LAST_UPDATED_BY = var_user_id
                         WHERE ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                           AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                           
                        COMMIT; 
                        
                        P_ERRBUF := 'EL PROCESO DE IMPORTACIÓN ENCONTRO UN INCONVENIENTE AL MOMENTO DE PROCESAR LOS MOVIMIENTOS DE CAJA DE AHORRO.';
                        P_RETCODE := 1;                      
                           
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'EL PROCESO DE IMPORTACIÓN ENCONTRO UN INCONVENIENTE AL MOMENTO DE PROCESAR LOS MOVIMIENTOS DE CAJA DE AHORRO.');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'**************************************SE REVIRTIERON TODOS LOS PROCESOS**************************************');
                        
                    END IF;
                    
                END IF;
                
                IF var_result = 'Y' THEN
                
                    FOR detail_loan IN DETAIL_LIST_LOANS LOOP
                                                         
                        var_result := 'N';
                        
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'PROCESANDO: ' || detail_loan.PAYROLL_RESULT_ID  || ','
                                                                       || detail_loan.PERSON_ID          || ','
                                                                       || detail_loan.EARNED_DATE        || ','
                                                                       || detail_loan.PERIOD_NAME        || ','
                                                                       || detail_loan.ELEMENT_NAME       || ','
                                                                       || detail_loan.ENTRY_NAME         || ','
                                                                       || detail_loan.ENTRY_UNITS        || ','
                                                                       || detail_loan.ENTRY_VALUE);
                        
                        var_result := INSERT_LOAN_TRANSACTION(P_EXPORT_REQUEST_ID => detail_loan.EXPORT_REQUEST_ID,
                                                              P_PAYROLL_RESULT_ID => detail_loan.PAYROLL_RESULT_ID,
                                                              P_PERSON_ID => detail_loan.PERSON_ID,
                                                              P_RUN_RESULT_ID => detail_loan.RUN_RESULT_ID,
                                                              P_EARNED_DATE => detail_loan.EARNED_DATE,
                                                              P_TIME_PERIOD_ID => detail_loan.TIME_PERIOD_ID,
                                                              P_PERIOD_NAME => detail_loan.PERIOD_NAME,
                                                              P_ELEMENT_NAME => detail_loan.ELEMENT_NAME,
                                                              P_ENTRY_NAME => detail_loan.ENTRY_NAME,
                                                              P_ENTRY_UNITS => detail_loan.ENTRY_UNITS,
                                                              P_ENTRY_VALUE => detail_loan.ENTRY_VALUE,
                                                              P_DEBIT_AMOUNT => 0,
                                                              P_CREDIT_AMOUNT => detail_loan.ENTRY_VALUE,
                                                              P_PAYMENT_SCHEDULE_ID => 0);
                                                              
                                                              
                        UPDATE ATET_SB_PAYROLL_RESULTS ASPR
                           SET ASPR.ATTRIBUTE7 = 'PROCESSED',
                               ASPR.LAST_UPDATE_DATE = SYSDATE,
                               ASPR.LAST_UPDATED_BY = var_user_id
                         WHERE ASPR.PAYROLL_RESULT_ID = detail_loan.PAYROLL_RESULT_ID;
                                                                                                                                  
                        IF var_result = 'N' THEN
                            EXIT;
                        END IF;                          
                                
                    END LOOP;
                    
                    IF    var_result = 'Y' THEN
                    
                        BEGIN
                            SELECT DISTINCT ASPR.PERIOD_NAME
                              INTO var_period_name
                              FROM ATET_SB_PAYROLL_RESULTS  ASPR
                             WHERE 1 = 1
                               AND ASPR.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME')
                               AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                               AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                               
                            SELECT SUM(ASPEE.ENTRY_VALUE1)
                              INTO var_sum_loan_import
                              FROM ATET_SB_PAY_ELEMENT_ENTRIES  ASPEE
                             WHERE 1 = 1
                               AND ASPEE.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME')
                               AND ASPEE.PERIOD_NAME = var_period_name;
                            
                            SELECT SUM(ASPR.ENTRY_VALUE)
                              INTO var_sum_loan_amount
                              FROM ATET_SB_PAYROLL_RESULTS  ASPR
                             WHERE 1 = 1
                               AND ASPR.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME')
                               AND ASPR.ENTRY_NAME = 'Amount'
                               AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                               AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                               
                            SELECT SUM(ASPR.ENTRY_VALUE)
                              INTO var_sum_loan_pay_value
                              FROM ATET_SB_PAYROLL_RESULTS  ASPR
                             WHERE 1 = 1
                               AND ASPR.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME')
                               AND ASPR.ENTRY_NAME = 'Pay Value'
                               AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                               AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'SIN DECUENTOS ' ||GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME'));
                        END;
                        
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '********************************************************');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   '||GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME'));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   DESCUENTOS EXPORTADOS    : ' || TO_CHAR(var_sum_loan_import));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   DESCUENTOS PROGRAMADOS   : ' || TO_CHAR(var_sum_loan_amount));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   DESCUENTOS REALES        : ' || TO_CHAR(var_sum_loan_pay_value));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '********************************************************');
                        
                    ELSIF var_result = 'N' THEN
                        
                        ROLLBACK;
                    
                        UPDATE ATET_SB_PAYROLL_RESULTS  ASPR
                           SET ASPR.IMPORT_REQUEST_ID = NULL,
                               ASPR.ATTRIBUTE6 = NULL,
                               ASPR.LAST_UPDATE_DATE = SYSDATE,
                               ASPR.LAST_UPDATED_BY = var_user_id
                         WHERE ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                           AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                           
                        COMMIT; 
                        
                        P_ERRBUF := 'EL PROCESO DE IMPORTACIÓN ENCONTRO UN INCONVENIENTE AL MOMENTO DE PROCESAR LOS MOVIMIENTOS DE PRESTAMO DE CAJA DE AHORRO.';
                        P_RETCODE := 1;                      
                        
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'EL PROCESO DE IMPORTACIÓN ENCONTRO UN INCONVENIENTE AL MOMENTO DE PROCESAR LOS MOVIMIENTOS DE PRESTAMO DE CAJA DE AHORRO.');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'********************************************SE REVIRTIERON TODOS LOS PROCESOS********************************************');
                           
                    END IF;
                
                END IF;
                
                IF var_result = 'Y' THEN
                
                    BEGIN                        
                        
                        SELECT DISTINCT 
                               ASPR.PERIOD_NAME,
                               ASPR.EARNED_DATE
                          INTO var_pp_period_name,
                               var_pp_payment_date
                          FROM ATET_SB_PAYROLL_RESULTS  ASPR
                         WHERE 1 = 1
                           AND ASPR.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME')
                           AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                           AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                           
                    EXCEPTION WHEN NO_DATA_FOUND THEN
                        NULL;
                    END;
                       
                    var_skip_count := 0;
                
                    FOR detail_skip IN SKIP_PAYMENTS_LIST(var_pp_payment_date, var_pp_period_name) LOOP
                        
                        var_result := 'N';
                        var_skip_count := var_skip_count + 1;
                        
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'PROCESANDO: ' || detail_skip.PAYROLL_RESULT_ID  || ','
                                                                       || detail_skip.PERSON_ID          || ','
                                                                       || detail_skip.EARNED_DATE        || ','
                                                                       || detail_skip.PERIOD_NAME        || ','
                                                                       || detail_skip.ELEMENT_NAME       || ','
                                                                       || detail_skip.ENTRY_NAME         || ','
                                                                       || detail_skip.ENTRY_UNITS        || ','
                                                                       || detail_skip.ENTRY_VALUE);    
                    
                        var_result := INSERT_LOAN_TRANSACTION(P_EXPORT_REQUEST_ID => P_EXPORT_REQUEST_ID,
                                                              P_PAYROLL_RESULT_ID => detail_skip.PAYROLL_RESULT_ID,
                                                              P_PERSON_ID => detail_skip.PERSON_ID,
                                                              P_RUN_RESULT_ID => -1,
                                                              P_EARNED_DATE => detail_skip.EARNED_DATE,
                                                              P_TIME_PERIOD_ID => detail_skip.TIME_PERIOD_ID,
                                                              P_PERIOD_NAME => detail_skip.PERIOD_NAME,
                                                              P_ELEMENT_NAME => detail_skip.ELEMENT_NAME,
                                                              P_ENTRY_NAME => detail_skip.ENTRY_NAME,
                                                              P_ENTRY_UNITS => detail_skip.ENTRY_UNITS,
                                                              P_ENTRY_VALUE => detail_skip.ENTRY_VALUE,
                                                              P_DEBIT_AMOUNT => 0,
                                                              P_CREDIT_AMOUNT => detail_skip.ENTRY_VALUE,
                                                              P_PAYMENT_SCHEDULE_ID => detail_skip.PAYMENT_SCHEDULE_ID);
                                                              
                        IF var_result = 'N' THEN
                            EXIT;
                        END IF;
                    
                    END LOOP; 
                    
                    
                    IF    var_result = 'Y' THEN
                        
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '********************************************************');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   '||GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME'));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   DESCUENTOS SALTADOS    : ' || TO_CHAR(var_skip_count));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '********************************************************');
                        
                    ELSIF var_result = 'N' THEN
                        
                        ROLLBACK;
                    
                        UPDATE ATET_SB_PAYROLL_RESULTS  ASPR
                           SET ASPR.IMPORT_REQUEST_ID = NULL,
                               ASPR.ATTRIBUTE6 = NULL,
                               ASPR.LAST_UPDATE_DATE = SYSDATE,
                               ASPR.LAST_UPDATED_BY = var_user_id
                         WHERE ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                           AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                           
                        COMMIT; 
                        
                        P_ERRBUF := 'EL PROCESO DE IMPORTACIÓN ENCONTRO UN INCONVENIENTE AL MOMENTO DE PROCESAR LOS MOVIMIENTOS DE PRESTAMO DE CAJA DE AHORRO.';
                        P_RETCODE := 1;                      
                        
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'EL PROCESO DE IMPORTACIÓN ENCONTRO UN INCONVENIENTE AL MOMENTO DE PROCESAR LOS MOVIMIENTOS DE PRESTAMO DE CAJA DE AHORRO.');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'********************************************SE REVIRTIERON TODOS LOS PROCESOS********************************************');
                           
                    END IF;
                    
                
                END IF;
            
            END;
            
            IF var_result = 'Y' THEN
                COMMIT;
            ELSIF var_result = 'N' THEN
                ROLLBACK;
            END IF;
            
        ELSE
        
            P_ERRBUF := 'EL PROCESO DE IMPORTACIÓN YA FUE EJECUTADO ANTERIORMENTE.';
            P_RETCODE := 1;
        
        END IF;  

    EXCEPTION WHEN OTHERS THEN
        
        ROLLBACK;
                    
        UPDATE ATET_SB_PAYROLL_RESULTS  ASPR
           SET ASPR.IMPORT_REQUEST_ID = NULL,
               ASPR.ATTRIBUTE6 = NULL,
               ASPR.LAST_UPDATE_DATE = SYSDATE,
               ASPR.LAST_UPDATED_BY = var_user_id
         WHERE ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
           AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                           
        COMMIT;     
    
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'XXXXXXXXXXXXX   ROLLBACK EJECUTADO   XXXXXXXXXXXXX');
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en IMPORT_PAYROLL_RESULTS ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END IMPORT_PAYROLL_RESULTS;
    
    
    
    PROCEDURE   CREATE_ACCOUNT(
                    P_PERSON_ID              NUMBER,
                    P_PARAM_ELEMENT_NAME     VARCHAR2,
                    P_PARAM_CODE_COMBINATION VARCHAR2)
    IS
        var_have_account    NUMBER;
        var_user_id         NUMBER := FND_GLOBAL.USER_ID;
    BEGIN
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'CREATE_ACCOUNT(P_PERSON_ID => ' || P_PERSON_ID ||
                                                      ',P_PARAM_ELEMENT_NAME => ' || P_PARAM_ELEMENT_NAME ||
                                                      ',P_PARAM_CODE_COMBINATION => ' || P_PARAM_CODE_COMBINATION || ')');
                   

        IF P_PARAM_ELEMENT_NAME = 'SAVINGS_ELEMENT_NAME' THEN
            
            SELECT COUNT(ASMA.MEMBER_ACCOUNT_ID)
              INTO var_have_account
              FROM ATET_SB_MEMBERS          ASM,
                   ATET_SB_MEMBERS_ACCOUNTS ASMA                               
             WHERE 1 = 1
               AND ASM.PERSON_ID = P_PERSON_ID
               AND ASM.MEMBER_ID = ASMA.MEMBER_ID   
               AND ASMA.ACCOUNT_DESCRIPTION = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME)
               AND ASMA.ACCOUNT_NUMBER = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_CODE_COMBINATION)
               AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;

            IF var_have_account = 0 THEN                                
                INSERT INTO ATET_SB_MEMBERS_ACCOUNTS(MEMBER_ID,
                                                     CODE_COMBINATION_ID,
                                                     ACCOUNT_NUMBER,
                                                     ACCOUNT_DESCRIPTION,
                                                     DEBIT_BALANCE,
                                                     CREDIT_BALANCE,
                                                     FINAL_BALANCE,
                                                     CREATION_DATE,
                                                     CREATED_BY,
                                                     LAST_UPDATE_DATE,
                                                     LAST_UPDATED_BY)
                                             VALUES (GET_MEMBER_ID(P_PERSON_ID),
                                                     GET_CODE_COMBINATION_ID(GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAV_CODE_COMB')),
                                                     GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAV_CODE_COMB'),
                                                     GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME),
                                                     0,
                                                     0,
                                                     0,
                                                     SYSDATE,
                                                     var_user_id,
                                                     SYSDATE,
                                                     var_user_id);
                
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'CREATE ACCOUNT ' || GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME) || '.');
                
            END IF;                                                                                                                                              
                                                                                             
        ELSIF P_PARAM_ELEMENT_NAME = 'LOAN_ELEMENT_NAME' THEN
            IF GET_MEMBER_IS_SAVER(GET_MEMBER_ID(P_PERSON_ID)) = 'Y' THEN
            
                SELECT COUNT(ASMA.MEMBER_ACCOUNT_ID)
                  INTO var_have_account
                  FROM ATET_SB_MEMBERS          ASM,
                       ATET_SB_MEMBERS_ACCOUNTS ASMA                               
                 WHERE 1 = 1
                   AND ASM.PERSON_ID = P_PERSON_ID
                   AND ASM.MEMBER_ID = ASMA.MEMBER_ID   
                   AND ASMA.ACCOUNT_DESCRIPTION = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME)
                   AND ASMA.ACCOUNT_NUMBER = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_SAV_CODE_COMB')
                   AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID
                   AND ASMA.LOAN_ID IS NULL;
                   
                IF var_have_account = 0 THEN             
                    INSERT INTO ATET_SB_MEMBERS_ACCOUNTS(MEMBER_ID,
                                                         CODE_COMBINATION_ID,
                                                         ACCOUNT_NUMBER,
                                                         ACCOUNT_DESCRIPTION,
                                                         DEBIT_BALANCE,
                                                         CREDIT_BALANCE,
                                                         FINAL_BALANCE,
                                                         CREATION_DATE,
                                                         CREATED_BY,
                                                         LAST_UPDATE_DATE,
                                                         LAST_UPDATED_BY)
                                                 VALUES (GET_MEMBER_ID(P_PERSON_ID),
                                                         GET_CODE_COMBINATION_ID(GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_SAV_CODE_COMB')),
                                                         GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_SAV_CODE_COMB'),
                                                         GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME),
                                                         0,
                                                         0,
                                                         0,
                                                         SYSDATE,
                                                         var_user_id,
                                                         SYSDATE,
                                                         var_user_id);
                    
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'CREATE ACCOUNT ' || GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME) || '.');
                END IF;
            ELSE
                SELECT COUNT(ASMA.MEMBER_ACCOUNT_ID)
                  INTO var_have_account
                  FROM ATET_SB_MEMBERS          ASM,
                       ATET_SB_MEMBERS_ACCOUNTS ASMA                               
                 WHERE 1 = 1
                   AND ASM.PERSON_ID = P_PERSON_ID
                   AND ASM.MEMBER_ID = ASMA.MEMBER_ID   
                   AND ASMA.ACCOUNT_DESCRIPTION = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME)
                   AND ASMA.ACCOUNT_NUMBER = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_NO_SAV_CODE_COMB')
                   AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID
                   AND ASMA.LOAN_ID IS NULL;
                   
                IF var_have_account = 0 THEN 
                    INSERT INTO ATET_SB_MEMBERS_ACCOUNTS(MEMBER_ID,
                                                         CODE_COMBINATION_ID,
                                                         ACCOUNT_NUMBER,
                                                         ACCOUNT_DESCRIPTION,
                                                         DEBIT_BALANCE,
                                                         CREDIT_BALANCE,
                                                         FINAL_BALANCE,
                                                         CREATION_DATE,
                                                         CREATED_BY,
                                                         LAST_UPDATE_DATE,
                                                         LAST_UPDATED_BY)
                                                 VALUES (GET_MEMBER_ID(P_PERSON_ID),
                                                         GET_CODE_COMBINATION_ID(GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_NO_SAV_CODE_COMB')),
                                                         GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_NO_SAV_CODE_COMB'),
                                                         GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME),
                                                         0,
                                                         0,
                                                         0,
                                                         SYSDATE,
                                                         var_user_id,
                                                         SYSDATE,
                                                         var_user_id);
                    
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'CREATE ACCOUNT ' || GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME) || '.');
                END IF;
            END IF;   
        
        ELSIF P_PARAM_ELEMENT_NAME = 'INTEREST_ELEMENT_NAME' THEN    
                     
            SELECT COUNT(ASMA.MEMBER_ACCOUNT_ID)
              INTO var_have_account
              FROM ATET_SB_MEMBERS          ASM,
                   ATET_SB_MEMBERS_ACCOUNTS ASMA                               
             WHERE 1 = 1
               AND ASM.PERSON_ID = P_PERSON_ID
               AND ASM.MEMBER_ID = ASMA.MEMBER_ID   
               AND ASMA.ACCOUNT_DESCRIPTION = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME)
               AND ASMA.ACCOUNT_NUMBER = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_CODE_COMBINATION)
               AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
               
            IF var_have_account = 0 THEN                                
                INSERT INTO ATET_SB_MEMBERS_ACCOUNTS(MEMBER_ID,
                                                     CODE_COMBINATION_ID,
                                                     ACCOUNT_NUMBER,
                                                     ACCOUNT_DESCRIPTION,
                                                     DEBIT_BALANCE,
                                                     CREDIT_BALANCE,
                                                     FINAL_BALANCE,
                                                     CREATION_DATE,
                                                     CREATED_BY,
                                                     LAST_UPDATE_DATE,
                                                     LAST_UPDATED_BY)
                                             VALUES (GET_MEMBER_ID(P_PERSON_ID),
                                                     GET_CODE_COMBINATION_ID(GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'INTEREST_CODE_COMB')),
                                                     GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'INTEREST_CODE_COMB'),
                                                     GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME),
                                                     0,
                                                     0,
                                                     0,
                                                     SYSDATE,
                                                     var_user_id,
                                                     SYSDATE,
                                                     var_user_id);
                
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'CREATE ACCOUNT ' || GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME) || '.');
                
            END IF; 
                      
        END IF;
 
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en CREATE_ACCOUNT ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END CREATE_ACCOUNT;
    
    
    FUNCTION    GET_LOOKUP_MEANING(
                    P_LOOKUP_TYPE    VARCHAR2,
                    P_LOOKUP_CODE    VARCHAR2)
      RETURN    VARCHAR2
   
   AS
      V_MEANING   HR_LOOKUPS.MEANING%TYPE;
   
   BEGIN
   
      BEGIN
         SELECT HRL.MEANING
           INTO V_MEANING
           FROM HR_LOOKUPS HRL
          WHERE HRL.LOOKUP_TYPE = P_LOOKUP_TYPE
                AND HRL.LOOKUP_CODE = P_LOOKUP_CODE;
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE_APPLICATION_ERROR (
               -20001,
                  'An error was encountered - in get_lookup_meaning '
               || SQLCODE
               || ' -ERROR- '
               || SQLERRM);
      END;

      

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_LOOKUP_MEANING(P_LOOKUP_TYPE => ' || P_LOOKUP_TYPE ||
                                                        ',P_LOOKUP_CODE => ' || P_LOOKUP_CODE || ') RETURN ' || V_MEANING);

      
      RETURN V_MEANING;
   
   END GET_LOOKUP_MEANING;
   
   
    PROCEDURE   ROLLBACK_EXPORT_PAYRESULT(
                    P_ERRBUF            OUT NOCOPY  VARCHAR2,
                    P_RETCODE           OUT NOCOPY  VARCHAR2,
                    P_EXPORT_REQUEST_ID NUMBER)
    IS
    
        CURSOR DETAIL_LIST  IS
            SELECT ASPR.PAYROLL_RESULT_ID,
                   ASPR.PERSON_ID,
                   ASPR.ASSIGNMENT_ID,
                   ASPR.ASSIGNMENT_ACTION_ID,
                   ASPR.PAYROLL_ACTION_ID,
                   ASPR.EARNED_DATE,
                   ASPR.PERIOD_NAME,
                   ASPR.PAYROLL_STATUS,
                   ASPR.ELEMENT_NAME,
                   ASPR.ENTRY_NAME,
                   ASPR.ENTRY_UNITS,
                   ASPR.ENTRY_VALUE,
                   ASPR.EXPORT_REQUEST_ID
              FROM ATET_SB_PAYROLL_RESULTS ASPR
             WHERE ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID;
             
        TYPE   DETAILS IS TABLE OF DETAIL_LIST%ROWTYPE INDEX BY PLS_INTEGER;
     
        detail DETAILS;
        
        var_log             VARCHAR2(1000);
        var_validate        NUMBER;
        
    BEGIN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'ROLLBACK_EXPORT_PAYRESULT(P_EXPORT_REQUEST_ID => ' ||P_EXPORT_REQUEST_ID || ')');
        
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '***********     PARAMETERS     ***********');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_EXPORT_REQUEST_ID : ' || P_EXPORT_REQUEST_ID);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '******************************************');
        
        OPEN DETAIL_LIST;
            
        LOOP
            
            FETCH DETAIL_LIST BULK COLLECT INTO detail LIMIT 500;
                
            EXIT WHEN detail.COUNT = 0;
                
            FOR rowIndex IN 1 .. detail.COUNT
            LOOP
                
                var_log := '';
                
                SELECT COUNT(ASPR.PAYROLL_RESULT_ID)
                  INTO var_validate
                  FROM ATET_SB_PAYROLL_RESULTS ASPR
                 WHERE 1 = 1
                   AND ASPR.PAYROLL_RESULT_ID = detail(rowIndex).PAYROLL_RESULT_ID
                   AND ASPR.IMPORT_REQUEST_ID IS NULL; 
                
                IF var_validate = 1 THEN
                    DELETE FROM ATET_SB_PAYROLL_RESULTS
                     WHERE PAYROLL_RESULT_ID = detail(rowIndex).PAYROLL_RESULT_ID;
                     
                    COMMIT;
                    
                    var_log := RPAD('COMPLETE : ', 10, ' ');
                ELSE
                    P_ERRBUF := 'No se puede revertir el movimiento.';
                    P_RETCODE := 1;
                    var_log := RPAD('WARNING : ', 10, ' ');
                END IF;    
                
                var_log := var_log || RPAD(detail(rowIndex).PERSON_ID, 10, ' ')              ||
                                      RPAD(detail(rowIndex).ASSIGNMENT_ID, 10, ' ')          ||
                                      RPAD(detail(rowIndex).ASSIGNMENT_ACTION_ID, 10, ' ')   ||
                                      RPAD(detail(rowIndex).PAYROLL_ACTION_ID, 10, ' ')      ||
                                      RPAD(detail(rowIndex).EARNED_DATE, 15, ' ')            ||
                                      RPAD(detail(rowIndex).PERIOD_NAME, 20, ' ')            ||
                                      RPAD(detail(rowIndex).PAYROLL_STATUS, 10, ' ')         ||
                                      RPAD(detail(rowIndex).ELEMENT_NAME, 30, ' ')           ||
                                      RPAD(detail(rowIndex).ENTRY_NAME, 15, ' ')             ||
                                      RPAD(detail(rowIndex).ENTRY_UNITS, 10, ' ')            ||
                                      RPAD(detail(rowIndex).ENTRY_VALUE, 10, ' ')            ||
                                      RPAD(detail(rowIndex).EXPORT_REQUEST_ID, 10, ' ');
                    
                FND_FILE.PUT_LINE(FND_FILE.LOG ,var_log);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT ,var_log);       
                        
            END LOOP;
                
        END LOOP;
            
        CLOSE DETAIL_LIST;
        
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en ROLLBACK_EXPORT_PAYRESULT ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END ROLLBACK_EXPORT_PAYRESULT;
    
    
    PROCEDURE   CHANGE_AMOUNT_TO_SAVE(
                    P_ERRBUF            OUT NOCOPY  VARCHAR2,
                    P_RETCODE           OUT NOCOPY  VARCHAR2,
                    P_EMPLOYEE_NUMBER   NUMBER,
                    P_AMOUNT_TO_SAVE    NUMBER)
    IS
        var_amount_to_save      NUMBER;
        var_next_discount       NUMBER;
        var_employee_number     NUMBER;
        var_employee_name       VARCHAR2(500);
        
        var_attribute2          VARCHAR2(15);
        var_attribute3          VARCHAR2(15);
        var_is_saver            VARCHAR2(5);
    BEGIN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'CHANGE_AMOUNT_TO_SAVE(P_EMPLOYEE_NUMBER => ' || P_EMPLOYEE_NUMBER || 
                                                             ',P_AMOUNT_TO_SAVE => ' || P_AMOUNT_TO_SAVE || 
                                                             ')');
    
        IF SYSDATE > TO_DATE(GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'REG_CHANGED_DATE'), 'RRRR/MM/DD') THEN
            P_ERRBUF := 'No se puede cambiar el monto de ahorro cuando la fecha de inscripción ha finalizado.';
            P_RETCODE := 1;
        ELSE
        
            
            
            SELECT NVL(TO_CHAR(ASM.ATTRIBUTE2), 'NOTHING'),
                   NVL(TO_CHAR(ASM.ATTRIBUTE3), 'NOTHING'),
                   ASM.IS_SAVER
              INTO var_attribute2,
                   var_attribute3,
                   var_is_saver
              FROM ATET_SB_MEMBERS ASM 
             WHERE ASM.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER 
               AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
               
            IF var_is_saver = 'Y' THEN
                
                IF var_attribute2 = 'NOTHING' AND var_attribute3 = 'NOTHING' THEN
                
                    UPDATE ATET_SB_MEMBERS
                       SET AMOUNT_TO_SAVE = P_AMOUNT_TO_SAVE,
                           ATTRIBUTE7 = 'CHANGED',
                           LAST_UPDATE_DATE = SYSDATE,
                           LAST_UPDATED_BY = FND_GLOBAL.USER_ID
                     WHERE EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
                       AND SAVING_BANK_ID = GET_SAVING_BANK_ID;


                    COMMIT;
                        
                    SELECT ASM.EMPLOYEE_NUMBER,
                           ASM.EMPLOYEE_FULL_NAME,
                           ASM.AMOUNT_TO_SAVE
                      INTO var_employee_number,
                           var_employee_name,
                           var_amount_to_save
                      FROM ATET_SB_MEMBERS ASM
                     WHERE ASM.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
                       AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
                           
                           
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '***********     CAMBIO DE AHORRO     ***********');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Número de empleado :          ' || var_employee_number);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Nombre de empleado :          ' || var_employee_name);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Monto de ahorro actualizado : ' || var_amount_to_save);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '************************************************');
                        
                ELSE
                    
                    UPDATE ATET_SB_MEMBERS
                       SET ATTRIBUTE3 = P_AMOUNT_TO_SAVE,
                           AMOUNT_TO_SAVE = P_AMOUNT_TO_SAVE * (1 + ATTRIBUTE2),
                           ATTRIBUTE7 = 'CHANGED',
                           LAST_UPDATE_DATE = SYSDATE,
                           LAST_UPDATED_BY = FND_GLOBAL.USER_ID
                     WHERE EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
                       AND SAVING_BANK_ID = GET_SAVING_BANK_ID;


                    COMMIT;
                        
                    SELECT ASM.EMPLOYEE_NUMBER,
                           ASM.EMPLOYEE_FULL_NAME,
                           ASM.ATTRIBUTE3,
                           ASM.AMOUNT_TO_SAVE
                      INTO var_employee_number,
                           var_employee_name,
                           var_amount_to_save,
                           var_next_discount
                      FROM ATET_SB_MEMBERS ASM
                     WHERE ASM.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
                       AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
                           
                           
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '***********     CAMBIO DE AHORRO     ***********');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Número de empleado :          ' || var_employee_number);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Nombre de empleado :          ' || var_employee_name);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Monto de ahorro actualizado : ' || var_amount_to_save);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Próximo descuento : '           || var_next_discount);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '************************************************');
                    
                END IF;
                
            END IF;
               
        END IF;
    
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en CHANGE_AMOUNT_TO_SAVE ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END CHANGE_AMOUNT_TO_SAVE;
    
    
    PROCEDURE   RESTART_SEQUENCE
    IS
    BEGIN
        
        EXECUTE IMMEDIATE 'DROP SEQUENCE ATET_SB_LOAN_NUMBER_SEQ';

        EXECUTE IMMEDIATE
             'CREATE SEQUENCE ATET_SB_LOAN_NUMBER_SEQ '
          || 'START WITH 1 '
          || 'INCREMENT BY 1 '
          || 'NOCACHE '
          || 'NOCYCLE';
                  
                  
        EXECUTE IMMEDIATE 'DROP SEQUENCE ATET_SB_CHECK_NUMBER_SEQ';

        EXECUTE IMMEDIATE
             'CREATE SEQUENCE ATET_SB_CHECK_NUMBER_SEQ '
          || 'START WITH 1 '
          || 'INCREMENT BY 1 '
          || 'NOCACHE '
          || 'NOCYCLE';
          
          
        EXECUTE IMMEDIATE 'DROP SEQUENCE ATET_SB_ENDORSEMENT_NUMBER_SEQ';

        EXECUTE IMMEDIATE
             'CREATE SEQUENCE ATET_SB_ENDORSEMENT_NUMBER_SEQ '
          || 'START WITH 1 '
          || 'INCREMENT BY 1 '
          || 'NOCACHE '
          || 'NOCYCLE';      
          
        EXECUTE IMMEDIATE 'DROP SEQUENCE ATET_SB_SAVING_RETIREMENT_SEQ';
          
        EXECUTE IMMEDIATE
             'CREATE SEQUENCE ATET_SB_SAVING_RETIREMENT_SEQ '
          || 'START WITH 1 '
          || 'INCREMENT BY 1 '
          || 'NOCACHE '
          || 'NOCYCLE';    
        
        EXECUTE IMMEDIATE 'DROP SEQUENCE ATET_SB_PREPAID_SEQ';  
          
        EXECUTE IMMEDIATE
             'CREATE SEQUENCE ATET_SB_PREPAID_SEQ '
          || 'START WITH 1 '
          || 'INCREMENT BY 1 '
          || 'NOCACHE '
          || 'NOCYCLE';
          
        EXECUTE IMMEDIATE 'DROP SEQUENCE ATET_SB_RECEIPT_NUMBER_SEQ';  
          
        EXECUTE IMMEDIATE
             'CREATE SEQUENCE ATET_SB_RECEIPT_NUMBER_SEQ '
          || 'START WITH 1 '
          || 'INCREMENT BY 1 '
          || 'NOCACHE '
          || 'NOCYCLE';  
          
        EXECUTE IMMEDIATE 'DROP SEQUENCE ATET_SB_PREPAID_SEQ';  
          
        EXECUTE IMMEDIATE
             'CREATE SEQUENCE ATET_SB_PREPAID_SEQ '
          || 'START WITH 1 '
          || 'INCREMENT BY 1 '
          || 'NOCACHE '
          || 'NOCYCLE'; 
          
        COMMIT;  
                  
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en RESTART_SEQUENCE ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END RESTART_SEQUENCE;  
    
    
    PROCEDURE   CREATE_SEQUENCE
    IS
    BEGIN
        
        EXECUTE IMMEDIATE
             'CREATE SEQUENCE ATET_SB_LOAN_NUMBER_SEQ '
          || 'START WITH 1 '
          || 'INCREMENT BY 1 '
          || 'NOCACHE '
          || 'NOCYCLE';
                  
                  
        EXECUTE IMMEDIATE
             'CREATE SEQUENCE ATET_SB_CHECK_NUMBER_SEQ '
          || 'START WITH 1 '
          || 'INCREMENT BY 1 '
          || 'NOCACHE '
          || 'NOCYCLE';
          
          
        EXECUTE IMMEDIATE
             'CREATE SEQUENCE ATET_SB_ENDORSEMENT_NUMBER_SEQ '
          || 'START WITH 1 '
          || 'INCREMENT BY 1 '
          || 'NOCACHE '
          || 'NOCYCLE';    
          
        EXECUTE IMMEDIATE
             'CREATE SEQUENCE ATET_SB_SAVING_RETIREMENT_SEQ '
          || 'START WITH 1 '
          || 'INCREMENT BY 1 '
          || 'NOCACHE '
          || 'NOCYCLE';   
          
        EXECUTE IMMEDIATE
             'CREATE SEQUENCE ATET_SB_PREPAID_SEQ '
          || 'START WITH 1 '
          || 'INCREMENT BY 1 '
          || 'NOCACHE '
          || 'NOCYCLE';
          
        COMMIT;   
                  
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en CREATE_SEQUENCE ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END CREATE_SEQUENCE;  
    
    
    FUNCTION    GET_MEMBER_ID(
                    P_PERSON_ID   NUMBER)
      RETURN    NUMBER
    IS
        var_member_id   NUMBER;
    BEGIN
        SELECT ASM.MEMBER_ID
          INTO var_member_id
          FROM ATET_SB_MEMBERS ASM
         WHERE ASM.PERSON_ID = P_PERSON_ID
           AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_MEMBER_ID(P_PERSON_ID => ' || P_PERSON_ID || ') RETURN ' || var_member_id);
           
        RETURN var_member_id;   
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_MEMBER_ID ' || SQLCODE || ' -ERROR- ' || SQLERRM);        
    END GET_MEMBER_ID;
    
    
    FUNCTION    GET_PERSON_ID(
                    P_MEMBER_ID   NUMBER)
      RETURN    NUMBER
    IS
        var_person_id   NUMBER;
    BEGIN
         SELECT ASM.PERSON_ID
          INTO var_person_id
          FROM ATET_SB_MEMBERS ASM
         WHERE ASM.MEMBER_ID = P_MEMBER_ID
           AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_PERSON_ID(P_MEMBER_ID => ' || P_MEMBER_ID || ') RETURN ' || var_person_id);
           
        RETURN var_person_id;   
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_PERSON_ID ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_PERSON_ID;
    
    
    FUNCTION    GET_MEMBER_IS_SAVER(
                    P_MEMBER_ID     NUMBER)
      RETURN    VARCHAR2
    IS
        var_result  VARCHAR2(50);
    BEGIN
    
        SELECT ASM.IS_SAVER
          INTO var_result
          FROM ATET_SB_MEMBERS  ASM
         WHERE 1 = 1
           AND ASM.MEMBER_ID = P_MEMBER_ID;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_MEMBER_IS_SAVER(P_MEMBER_ID => ' || P_MEMBER_ID || ') RETURN ' || var_result);
    
        RETURN var_result;

    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_MEMBER_IS_SAVER ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_MEMBER_IS_SAVER;
      
   
    FUNCTION    GET_CODE_COMBINATION_ID(
                    P_CODE_COMBINATION   VARCHAR2)
      RETURN    NUMBER
    IS
        var_result  NUMBER;
    BEGIN
    
        
         SELECT ASAM.ACCOUNT_MAPPING_ID
          INTO var_result
          FROM ATET_SB_ACCOUNT_MAPPING  ASAM
         WHERE 1 = 1
           AND (ASAM.SEGMENT1 ||
                ASAM.SEGMENT2 ||
                ASAM.SEGMENT3 ||
                ASAM.SEGMENT4 ||
                ASAM.SEGMENT5 ||
                ASAM.SEGMENT6) = REPLACE(P_CODE_COMBINATION, '-', '');
        
    

                
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_CODE_COMBINATION_ID(P_CODE_COMBINATION => ' || P_CODE_COMBINATION || 
                                                               ') RETURN ' || var_result); 
                
        RETURN var_result;

        
        
    EXCEPTION WHEN OTHERS THEN
        
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_CODE_COMBINATION_ID ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_CODE_COMBINATION_ID;
    
    
    FUNCTION    GET_CODE_COMBINATION(
                    P_CODE_COMBINATION_ID       NUMBER
                ) RETURN    VARCHAR2
    IS
        var_result  VARCHAR2(100);
    BEGIN
    
        SELECT ASAM.CONCATENED_SEGMENT_1
          INTO var_result
          FROM ATET_SB_ACCOUNT_MAPPING  ASAM
         WHERE 1 = 1
           AND ASAM.ACCOUNT_MAPPING_ID = P_CODE_COMBINATION_ID;
    
        RETURN var_result;
        
    END GET_CODE_COMBINATION;
    
    
    FUNCTION    INSERT_SAVING_TRANSACTION(
                    P_PAYROLL_RESULT_ID   NUMBER,
                    P_PERSON_ID           NUMBER,
                    P_EARNED_DATE         DATE,
                    P_TIME_PERIOD_ID      NUMBER,
                    P_PERIOD_NAME         VARCHAR2,
                    P_ELEMENT_NAME        VARCHAR2,
                    P_ENTRY_NAME          VARCHAR2,
                    P_ENTRY_UNITS         VARCHAR2,
                    P_ENTRY_VALUE         NUMBER,
                    P_DEBIT_AMOUNT        NUMBER,
                    P_CREDIT_AMOUNT       NUMBER)
    RETURN VARCHAR2
    IS
        var_import_request_id       NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        var_log                     VARCHAR2(1000);
        var_user_id                 NUMBER := FND_GLOBAL.USER_ID;
        
        var_member_id               NUMBER;
        var_member_account_id       NUMBER;
        var_attribute2              VARCHAR2(50);
        var_attribute3              VARCHAR2(50);
    BEGIN
    
        var_member_id := GET_MEMBER_ID(P_PERSON_ID);
        var_member_account_id := GET_SAVING_MEMBER_ACCOUNT_ID(GET_MEMBER_ID(P_PERSON_ID),
                                                              GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAV_CODE_COMB'),
                                                              GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME'));
    
        INSERT INTO ATET_SB_SAVINGS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                  MEMBER_ID,
                                                  PAYROLL_RESULT_ID,
                                                  PERSON_ID,
                                                  EARNED_DATE,
                                                  TIME_PERIOD_ID,
                                                  PERIOD_NAME,
                                                  ELEMENT_NAME,
                                                  ENTRY_NAME,
                                                  ENTRY_UNITS,
                                                  ENTRY_VALUE,
                                                  TRANSACTION_CODE,
                                                  DEBIT_AMOUNT,
                                                  CREDIT_AMOUNT,
                                                  REQUEST_ID,
                                                  ACCOUNTED_FLAG,
                                                  CREATION_DATE,
                                                  CREATED_BY,
                                                  LAST_UPDATE_DATE,
                                                  LAST_UPDATED_BY)
                                          VALUES (var_member_account_id,
                                                  var_member_id,
                                                  P_PAYROLL_RESULT_ID,
                                                  P_PERSON_ID,
                                                  P_EARNED_DATE,
                                                  P_TIME_PERIOD_ID,
                                                  P_PERIOD_NAME,
                                                  P_ELEMENT_NAME,
                                                  P_ENTRY_NAME,
                                                  P_ENTRY_UNITS,
                                                  P_ENTRY_VALUE,
                                                  'PROCESSED',
                                                  P_DEBIT_AMOUNT,
                                                  P_CREDIT_AMOUNT,
                                                  var_import_request_id,
                                                  'UNACCOUNTED',
                                                  SYSDATE,
                                                  var_user_id,
                                                  SYSDATE,
                                                  var_user_id);
                                                  
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET DEBIT_BALANCE = DEBIT_BALANCE + P_DEBIT_AMOUNT,
               CREDIT_BALANCE = CREDIT_BALANCE + P_CREDIT_AMOUNT,
               LAST_TRANSACTION_DATE = SYSDATE               
         WHERE MEMBER_ID = var_member_id
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET FINAL_BALANCE = CREDIT_BALANCE - DEBIT_BALANCE,
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = var_user_id             
         WHERE MEMBER_ID = var_member_id
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
        
        
        SELECT NVL(TO_CHAR(ASM.ATTRIBUTE2), 'NOTHING'),
               NVL(TO_CHAR(ASM.ATTRIBUTE3), 'NOTHING')
          INTO var_attribute2,
               var_attribute3
          FROM ATET_SB_MEMBERS ASM 
         WHERE ASM.MEMBER_ID = var_member_id 
           AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
        
        
        IF var_attribute2 <> 'NOTHING' AND var_attribute3 <> 'NOTHING' THEN
            
           UPDATE ATET_SB_MEMBERS
              SET AMOUNT_TO_SAVE = TO_NUMBER(var_attribute3),
                  ATTRIBUTE2 = NULL,
                  ATTRIBUTE3 = NULL,
                  LAST_UPDATE_DATE = SYSDATE,
                  LAST_UPDATED_BY = var_user_id
            WHERE MEMBER_ID = var_member_id;
        
        END IF;
             
                                                  
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'MOVIMIENTO PROCESADO: *AHORRO*'    || P_PAYROLL_RESULT_ID  || ','
                                                                               || P_PERSON_ID          || ','
                                                                               || P_EARNED_DATE        || ','
                                                                               || P_PERIOD_NAME        || ','
                                                                               || P_ELEMENT_NAME       || ','
                                                                               || P_ENTRY_NAME         || ','
                                                                               || P_ENTRY_UNITS        || ','
                                                                               || P_ENTRY_VALUE        || ','
                                                                               || P_DEBIT_AMOUNT       || ','
                                                                               || P_CREDIT_AMOUNT      || '.');    
                                                                               
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT_SAVING_TRANSACTION(P_PAYROLL_RESULT_ID => ' || P_PAYROLL_RESULT_ID ||
                                                                 ',P_PERSON_ID => ' || P_PERSON_ID ||
                                                                 ',P_EARNED_DATE => ' || P_EARNED_DATE || 
                                                                 ',P_TIME_PERIOD_ID => ' || P_TIME_PERIOD_ID ||
                                                                 ',P_PERIOD_NAME => ' || P_PERIOD_NAME ||
                                                                 ',P_ELEMENT_NAME => ' || P_ELEMENT_NAME ||
                                                                 ',P_ENTRY_NAME => ' || P_ENTRY_NAME ||
                                                                 ',P_ENTRY_UNITS => ' || P_ENTRY_UNITS ||
                                                                 ',P_ENTRY_VALUE => ' || P_ENTRY_VALUE ||
                                                                 ',P_DEBIT_AMOUNT => ' || P_DEBIT_AMOUNT ||
                                                                 ',P_CREDIT_AMOUNT => ' || P_CREDIT_AMOUNT || ') RETURN Y');                       
    
        RETURN 'Y';
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'NO SE PROCESO EL MOVIMIENTO: *AHORRO*' || P_PAYROLL_RESULT_ID  || ','
                                                                                || P_PERSON_ID          || ','
                                                                                || P_EARNED_DATE        || ','
                                                                                || P_PERIOD_NAME        || ','
                                                                                || P_ELEMENT_NAME       || ','
                                                                                || P_ENTRY_NAME         || ','
                                                                                || P_ENTRY_UNITS        || ','
                                                                                || P_ENTRY_VALUE        || ','
                                                                                || P_DEBIT_AMOUNT       || ','
                                                                                || P_CREDIT_AMOUNT      || '.' || SQLERRM);
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT_SAVING_TRANSACTION(P_PAYROLL_RESULT_ID => ' || P_PAYROLL_RESULT_ID ||
                                                                 ',P_PERSON_ID => ' || P_PERSON_ID ||
                                                                 ',P_EARNED_DATE => ' || P_EARNED_DATE || 
                                                                 ',P_TIME_PERIOD_ID => ' || P_TIME_PERIOD_ID ||
                                                                 ',P_PERIOD_NAME => ' || P_PERIOD_NAME ||
                                                                 ',P_ELEMENT_NAME => ' || P_ELEMENT_NAME ||
                                                                 ',P_ENTRY_NAME => ' || P_ENTRY_NAME ||
                                                                 ',P_ENTRY_UNITS => ' || P_ENTRY_UNITS ||
                                                                 ',P_ENTRY_VALUE => ' || P_ENTRY_VALUE ||
                                                                 ',P_DEBIT_AMOUNT => ' || P_DEBIT_AMOUNT ||
                                                                 ',P_CREDIT_AMOUNT => ' || P_CREDIT_AMOUNT || ') RETURN N');
        
        ROLLBACK;
        RETURN 'N';
    END INSERT_SAVING_TRANSACTION;
    
    
    FUNCTION   INSERT_LOAN_TRANSACTION(
                    P_EXPORT_REQUEST_ID   NUMBER,
                    P_PAYROLL_RESULT_ID   NUMBER,
                    P_PERSON_ID           NUMBER,
                    P_RUN_RESULT_ID       NUMBER,
                    P_EARNED_DATE         DATE,
                    P_TIME_PERIOD_ID      NUMBER,
                    P_PERIOD_NAME         VARCHAR2,
                    P_ELEMENT_NAME        VARCHAR2,
                    P_ENTRY_NAME          VARCHAR2,
                    P_ENTRY_UNITS         VARCHAR2,
                    P_ENTRY_VALUE         NUMBER,
                    P_DEBIT_AMOUNT        NUMBER,
                    P_CREDIT_AMOUNT       NUMBER,
                    P_PAYMENT_SCHEDULE_ID NUMBER)
      RETURN    VARCHAR2
    IS
        var_import_request_id       NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        var_user_id                 NUMBER := FND_GLOBAL.USER_ID;
        var_validate                NUMBER;
        var_validate_partial        NUMBER;

        var_member_id               NUMBER;
        var_member_account_id       NUMBER;
        
        var_loan_id                 NUMBER;
        var_loan_number             NUMBER;
        
        var_entry_value             NUMBER;
        var_payment_schedule_id     NUMBER;
        var_time_period_id          NUMBER;
        var_period_name             VARCHAR2(200);
        var_payment_number          NUMBER;
        var_payment_amount          NUMBER;
        var_payment_capital         NUMBER;
        var_payment_interest        NUMBER;
        var_payment_interest_late   NUMBER;
        
        var_expected_payment_amount NUMBER;
        var_late_interest_rate      NUMBER;
        
        var_nd_payment_capital          NUMBER := 0;
        var_nd_payment_interest         NUMBER := 0;
        var_nd_payment_interest_late    NUMBER := 0;
        
        var_wd_payment_capital          NUMBER := 0;
        var_wd_payment_interest         NUMBER := 0;
        var_wd_payment_interest_late    NUMBER := 0;
        
        var_p_payment_capital           NUMBER := 0;
        var_p_payment_interest          NUMBER := 0;
        var_p_payment_interest_late     NUMBER := 0;
        
        CURSOR PAYMENT_DETAILS  IS
            SELECT ASPS.PAYMENT_SCHEDULE_ID,
                   ASPS.PAYMENT_NUMBER,
                   ASPS.TIME_PERIOD_ID,
                   ASPS.PERIOD_NAME,
                   ASPS.PAYMENT_AMOUNT,
                   ASPS.PAYMENT_CAPITAL,
                   ASPS.PAYMENT_INTEREST,
                   ASPS.PAYMENT_INTEREST_LATE,
                   NVL(ASPS.OWED_AMOUNT, ASPS.PAYMENT_AMOUNT)               AS EXPECTED_PAYMENT_AMOUNT
              FROM ATET_SB_PAYMENTS_SCHEDULE ASPS
             WHERE 1 = 1
               AND ASPS.LOAN_ID = var_loan_id
               AND ASPS.TIME_PERIOD_ID = P_TIME_PERIOD_ID
               AND ASPS.STATUS_FLAG NOT IN ('PAYED', 'REFINANCED')
             ORDER BY TO_NUMBER(ASPS.TIME_PERIOD_ID);
             
        CURSOR PAYMENT_PARTIAL_DETAILS IS
            SELECT ASPS.PAYMENT_SCHEDULE_ID,
                   ASPS.PAYMENT_NUMBER,
                   ASPS.TIME_PERIOD_ID,
                   ASPS.PERIOD_NAME,
                   ASPS.PAYMENT_AMOUNT,
                   NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL)             AS PAYMENT_CAPITAL,
                   NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST)           AS PAYMENT_INTEREST,
                   NVL(ASPS.OWED_INTEREST_LATE, ASPS.PAYMENT_INTEREST_LATE) AS PAYMENT_INTEREST_LATE,
                   NVL(ASPS.OWED_AMOUNT, ASPS.PAYMENT_AMOUNT)               AS EXPECTED_PAYMENT_AMOUNT
              FROM ATET_SB_PAYMENTS_SCHEDULE ASPS
             WHERE 1 = 1
               AND ASPS.LOAN_ID = var_loan_id
               AND ASPS.TIME_PERIOD_ID < P_TIME_PERIOD_ID
               AND ASPS.STATUS_FLAG IN ('SKIP', 'PARTIAL')
             ORDER BY TO_NUMBER(ASPS.TIME_PERIOD_ID) ASC;
             
        CURSOR PAYMENT_PREPAID_DETAILS IS
            SELECT ASPS.PAYMENT_SCHEDULE_ID,
                   ASPS.PAYMENT_NUMBER,
                   ASPS.TIME_PERIOD_ID,
                   ASPS.PERIOD_NAME,
                   ASPS.PAYMENT_AMOUNT,
                   NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL)             AS PAYMENT_CAPITAL,
                   NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST)           AS PAYMENT_INTEREST,
                   NVL(ASPS.OWED_INTEREST_LATE, ASPS.PAYMENT_INTEREST_LATE) AS  PAYMENT_INTEREST_LATE,
                   NVL(ASPS.OWED_AMOUNT, ASPS.PAYMENT_AMOUNT)               AS EXPECTED_PAYMENT_AMOUNT
              FROM ATET_SB_PAYMENTS_SCHEDULE ASPS
             WHERE 1 = 1
               AND ASPS.LOAN_ID = var_loan_id
               AND ASPS.TIME_PERIOD_ID > P_TIME_PERIOD_ID
               AND ASPS.STATUS_FLAG NOT IN ('PAYED', 'REFINANCED')
             ORDER BY TO_NUMBER(ASPS.TIME_PERIOD_ID) DESC;
        
    BEGIN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT_LOAN_TRANSACTION(' ||
                    ',P_EXPORT_REQUEST_ID => ' || P_EXPORT_REQUEST_ID || 
                    ',P_PAYROLL_RESULT_ID => ' || P_PAYROLL_RESULT_ID ||
                    ',P_PERSON_ID => ' || P_PERSON_ID ||
                    ',P_RUN_RESULT_ID => ' || P_RUN_RESULT_ID ||
                    ',P_EARNED_DATE => ' || P_EARNED_DATE ||
                    ',P_TIME_PERIOD_ID => ' || P_TIME_PERIOD_ID ||
                    ',P_PERIOD_NAME => ' || P_PERIOD_NAME ||
                    ',P_ELEMENT_NAME => ' || P_ELEMENT_NAME ||
                    ',P_ENTRY_NAME => ' || P_ENTRY_NAME ||
                    ',P_ENTRY_UNITS => ' || P_ENTRY_UNITS ||
                    ',P_ENTRY_VALUE => ' || P_ENTRY_VALUE ||
                    ',P_DEBIT_AMOUNT => ' || P_DEBIT_AMOUNT ||
                    ',P_CREDIT_AMOUNT => ' || P_CREDIT_AMOUNT ||
                    ',P_PAYMENT_SCHEDULE_ID => ' || P_PAYMENT_SCHEDULE_ID || ')');
        
        var_entry_value := P_ENTRY_VALUE;
        var_member_id := GET_MEMBER_ID(P_PERSON_ID);
        var_loan_id := GET_RESULT_FROM_PAYROLL_RESULT(P_PERSON_ID, P_EXPORT_REQUEST_ID, P_RUN_RESULT_ID, 'Futuro 4');
        var_loan_number := GET_RESULT_FROM_PAYROLL_RESULT(P_PERSON_ID, P_EXPORT_REQUEST_ID, P_RUN_RESULT_ID, 'Folio');
        
        IF P_PAYMENT_SCHEDULE_ID <> 0 THEN
            SELECT ASPS.LOAN_ID
              INTO var_loan_id
              FROM ATET_SB_PAYMENTS_SCHEDULE ASPS
             WHERE 1 = 1
               AND ASPS.PAYMENT_SCHEDULE_ID = P_PAYMENT_SCHEDULE_ID;
        END IF;
        
        IF var_loan_id = 0 AND var_loan_number <> 0 THEN
            var_loan_id := GET_LOAN_ID(
                                P_MEMBER_ID => var_member_id, 
                                P_LOAN_NUMBER => var_loan_number);
        ELSIF var_loan_id = 0 AND var_loan_number = 0 THEN
            var_loan_id := GET_LOAN_ID(
                                P_PERSON_ID => P_PERSON_ID,
                                P_PAYMENT_AMOUNT => GET_RESULT_FROM_PAYROLL_RESULT(P_PERSON_ID, P_EXPORT_REQUEST_ID, P_RUN_RESULT_ID, 'Amount'));
        END IF;
        
        var_member_account_id := GET_LOAN_MEMBER_ACCOUNT_ID(var_member_id, var_loan_id);
    
        
        FOR payment IN PAYMENT_DETAILS LOOP
        
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'PAYMENT_DETAILS');
        
            var_payment_schedule_id := payment.PAYMENT_SCHEDULE_ID;
            var_payment_number := payment.PAYMENT_NUMBER;
            var_time_period_id := payment.TIME_PERIOD_ID;
            var_period_name := payment.PERIOD_NAME;
            var_payment_amount := payment.PAYMENT_AMOUNT;
            var_expected_payment_amount := payment.EXPECTED_PAYMENT_AMOUNT;
            var_payment_capital := payment.PAYMENT_CAPITAL;
            var_payment_interest := payment.PAYMENT_INTEREST;
            var_payment_interest_late := payment.PAYMENT_INTEREST_LATE;
            
            
            IF (var_entry_value - var_payment_interest_late) >= 0 THEN
                var_payment_interest_late := var_payment_interest_late;
            ELSE
                var_payment_interest_late := var_entry_value;
            END IF;
            
            var_entry_value := var_entry_value - var_payment_interest_late;
            
            IF (var_entry_value - var_payment_interest) >= 0 THEN
                var_payment_interest := var_payment_interest;
            ELSE
                var_payment_interest := var_entry_value;
            END IF; 
            
            var_entry_value := var_entry_value - var_payment_interest;
            
            IF (var_entry_value - var_payment_capital) >= 0 THEN
                var_payment_capital := var_payment_capital;
            ELSE
                var_payment_capital := var_entry_value;
            END IF;
            
            var_entry_value := var_entry_value - var_payment_capital;
            
            var_payment_amount := var_payment_interest_late +
                                  var_payment_interest +
                                  var_payment_capital;
            
            INSERT_LOAN_TRANSACTION(
                P_PAYMENT_NUMBER            => var_payment_number,
                P_DEBIT_AMOUNT              => 0,
                P_CREDIT_AMOUNT             => var_payment_amount,
                P_PAYMENT_AMOUNT            => var_payment_amount,
                P_PAYMENT_CAPITAL           => var_payment_capital,
                P_PAYMENT_INTEREST          => var_payment_interest,
                P_PAYMENT_INTEREST_LATE     => var_payment_interest_late,
                P_ELEMENT_NAME              => P_ELEMENT_NAME,
                P_ENTRY_NAME                => P_ENTRY_NAME,
                P_ENTRY_UNITS               => P_ENTRY_UNITS,
                P_MEMBER_ACCOUNT_ID         => var_member_account_id,
                P_MEMBER_ID                 => var_member_id,
                P_PAYROLL_RESULT_ID         => P_PAYROLL_RESULT_ID,
                P_LOAN_ID                   => var_loan_id,
                P_PERSON_ID                 => P_PERSON_ID,
                P_RUN_RESULT_ID             => P_RUN_RESULT_ID,
                P_EARNED_DATE               => P_EARNED_DATE,
                P_TIME_PERIOD_ID            => P_TIME_PERIOD_ID,
                P_PERIOD_NAME               => P_PERIOD_NAME,
                P_ENTRY_VALUE               => var_entry_value,
                P_EXPECTED_PAYMENT_AMOUNT   => var_expected_payment_amount,
                P_PAYMENT_SCHEDULE_ID       => var_payment_schedule_id,
                P_DESCRIPTION               => '');

            
        END LOOP;
        
        IF var_entry_value > 0 THEN 
        
            FOR partial IN PAYMENT_PARTIAL_DETAILS LOOP
            
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'PAYMENT_PARTIAL_DETAILS');
            
                var_payment_schedule_id := partial.PAYMENT_SCHEDULE_ID;
                var_payment_number := partial.PAYMENT_NUMBER;
                var_time_period_id := partial.TIME_PERIOD_ID;
                var_period_name := partial.PERIOD_NAME;
                var_payment_amount := partial.PAYMENT_AMOUNT;
                var_expected_payment_amount := partial.EXPECTED_PAYMENT_AMOUNT;
                var_payment_capital := partial.PAYMENT_CAPITAL;
                var_payment_interest := partial.PAYMENT_INTEREST;
                var_payment_interest_late := partial.PAYMENT_INTEREST_LATE;
                
                IF (var_entry_value - var_payment_interest_late) >= 0 THEN
                    var_payment_interest_late := var_payment_interest_late;
                ELSE
                    var_payment_interest_late := var_entry_value;
                END IF;
                
                var_entry_value := var_entry_value - var_payment_interest_late;
                
                IF (var_entry_value - var_payment_interest) >= 0 THEN
                    var_payment_interest := var_payment_interest;
                ELSE
                    var_payment_interest := var_entry_value;
                END IF; 
                
                var_entry_value := var_entry_value - var_payment_interest;
                
                IF (var_entry_value - var_payment_capital) >= 0 THEN
                    var_payment_capital := var_payment_capital;
                ELSE
                    var_payment_capital := var_entry_value;
                END IF;
                
                var_entry_value := var_entry_value - var_payment_capital;
                
                var_payment_amount := var_payment_interest_late +
                                      var_payment_interest +
                                      var_payment_capital;

                INSERT_LOAN_TRANSACTION(
                    P_PAYMENT_NUMBER            => var_payment_number,
                    P_DEBIT_AMOUNT              => 0,
                    P_CREDIT_AMOUNT             => var_payment_amount,
                    P_PAYMENT_AMOUNT            => var_payment_amount,
                    P_PAYMENT_CAPITAL           => var_payment_capital,
                    P_PAYMENT_INTEREST          => var_payment_interest,
                    P_PAYMENT_INTEREST_LATE     => var_payment_interest_late,
                    P_ELEMENT_NAME              => P_ELEMENT_NAME,
                    P_ENTRY_NAME                => P_ENTRY_NAME,
                    P_ENTRY_UNITS               => P_ENTRY_UNITS,
                    P_MEMBER_ACCOUNT_ID         => var_member_account_id,
                    P_MEMBER_ID                 => var_member_id,
                    P_PAYROLL_RESULT_ID         => P_PAYROLL_RESULT_ID,
                    P_LOAN_ID                   => var_loan_id,
                    P_PERSON_ID                 => P_PERSON_ID,
                    P_RUN_RESULT_ID             => P_RUN_RESULT_ID,
                    P_EARNED_DATE               => P_EARNED_DATE,
                    P_TIME_PERIOD_ID            => P_TIME_PERIOD_ID,
                    P_PERIOD_NAME               => P_PERIOD_NAME,
                    P_ENTRY_VALUE               => var_entry_value,
                    P_EXPECTED_PAYMENT_AMOUNT   => var_expected_payment_amount,
                    P_PAYMENT_SCHEDULE_ID       => var_payment_schedule_id,
                    P_DESCRIPTION               => 'PAGO VENCIDO: TIME_PERIOD_ID=' || TO_CHAR(P_TIME_PERIOD_ID) || ',PERIOD_NAME=' || TO_CHAR(P_PERIOD_NAME));
                    
                SELECT COUNT(ASPS.PAYMENT_SCHEDULE_ID)
                  INTO var_validate_partial
                  FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
                 WHERE 1 = 1
                   AND ASPS.PAYMENT_SCHEDULE_ID = var_payment_schedule_id
                   AND ASPS.STATUS_FLAG = 'PARTIAL';
                   
                UPDATE ATET_SB_PAYMENTS_SCHEDULE ASPS
                   SET ASPS.ATTRIBUTE6 = 'PAGO VENCIDO: TIME_PERIOD_ID=' || TO_CHAR(P_TIME_PERIOD_ID) || ',PERIOD_NAME=' || TO_CHAR(P_PERIOD_NAME) 
                 WHERE 1 = 1
                   AND ASPS.PAYMENT_SCHEDULE_ID = var_payment_schedule_id;
                   
                IF var_validate_partial > 0 THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG ,'REFINANCE_PAYMENT_SCHEDULE');
                
                    REFINANCE_PAYMENT_SCHEDULE(var_payment_schedule_id, P_EARNED_DATE);
                END IF;

                IF var_entry_value = 0 THEN
                    EXIT;
                END IF;
                                      
            END LOOP;
            
        END IF;
        
        IF var_entry_value > 0 THEN 
        
            FOR prepaid IN PAYMENT_PREPAID_DETAILS LOOP
            
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'PAYMENT_PREPAID_DETAILS');
            
                var_payment_schedule_id := prepaid.PAYMENT_SCHEDULE_ID;
                var_payment_number := prepaid.PAYMENT_NUMBER;
                var_time_period_id := prepaid.TIME_PERIOD_ID;
                var_period_name := prepaid.PERIOD_NAME;
                var_payment_amount := prepaid.PAYMENT_AMOUNT;
                var_expected_payment_amount := prepaid.EXPECTED_PAYMENT_AMOUNT;
                var_payment_capital := prepaid.PAYMENT_CAPITAL;
                var_payment_interest := prepaid.PAYMENT_INTEREST;
                var_payment_interest_late := prepaid.PAYMENT_INTEREST_LATE;
                
                IF (var_entry_value - var_payment_interest_late) >= 0 THEN
                    var_payment_interest_late := var_payment_interest_late;
                ELSE
                    var_payment_interest_late := var_entry_value;
                END IF;
                
                var_entry_value := var_entry_value - var_payment_interest_late;
                
                IF (var_entry_value - var_payment_interest) >= 0 THEN
                    var_payment_interest := var_payment_interest;
                ELSE
                    var_payment_interest := var_entry_value;
                END IF; 
                
                var_entry_value := var_entry_value - var_payment_interest;
                
                IF (var_entry_value - var_payment_capital) >= 0 THEN
                    var_payment_capital := var_payment_capital;
                ELSE
                    var_payment_capital := var_entry_value;
                END IF;
                
                var_entry_value := var_entry_value - var_payment_capital;
                
                var_payment_amount := var_payment_interest_late +
                                      var_payment_interest +
                                      var_payment_capital;

                INSERT_LOAN_TRANSACTION(
                    P_PAYMENT_NUMBER            => var_payment_number,
                    P_DEBIT_AMOUNT              => 0,
                    P_CREDIT_AMOUNT             => var_payment_amount,
                    P_PAYMENT_AMOUNT            => var_payment_amount,
                    P_PAYMENT_CAPITAL           => var_payment_capital,
                    P_PAYMENT_INTEREST          => var_payment_interest,
                    P_PAYMENT_INTEREST_LATE     => var_payment_interest_late,
                    P_ELEMENT_NAME              => P_ELEMENT_NAME,
                    P_ENTRY_NAME                => P_ENTRY_NAME,
                    P_ENTRY_UNITS               => P_ENTRY_UNITS,
                    P_MEMBER_ACCOUNT_ID         => var_member_account_id,
                    P_MEMBER_ID                 => var_member_id,
                    P_PAYROLL_RESULT_ID         => P_PAYROLL_RESULT_ID,
                    P_LOAN_ID                   => var_loan_id,
                    P_PERSON_ID                 => P_PERSON_ID,
                    P_RUN_RESULT_ID             => P_RUN_RESULT_ID,
                    P_EARNED_DATE               => P_EARNED_DATE,
                    P_TIME_PERIOD_ID            => P_TIME_PERIOD_ID,
                    P_PERIOD_NAME               => P_PERIOD_NAME,
                    P_ENTRY_VALUE               => var_entry_value,
                    P_EXPECTED_PAYMENT_AMOUNT   => var_expected_payment_amount,
                    P_PAYMENT_SCHEDULE_ID       => var_payment_schedule_id,
                    P_DESCRIPTION               => 'PAGO ANTICIPADO: TIME_PERIOD_ID=' || TO_CHAR(P_TIME_PERIOD_ID) || ',PERIOD_NAME=' || TO_CHAR(P_PERIOD_NAME));
                    
                SELECT COUNT(ASPS.PAYMENT_SCHEDULE_ID)
                  INTO var_validate_partial
                  FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
                 WHERE 1 = 1
                   AND ASPS.PAYMENT_SCHEDULE_ID = var_payment_schedule_id
                   AND ASPS.STATUS_FLAG = 'PARTIAL';
                   
                UPDATE ATET_SB_PAYMENTS_SCHEDULE ASPS
                   SET ASPS.ATTRIBUTE6 = 'PAGO ANTICIPADO: TIME_PERIOD_ID=' || TO_CHAR(P_TIME_PERIOD_ID) || ',PERIOD_NAME=' || TO_CHAR(P_PERIOD_NAME)
                 WHERE 1 = 1
                   AND ASPS.PAYMENT_SCHEDULE_ID = var_payment_schedule_id;
                   
                IF var_validate_partial > 0 THEN
                
                    FND_FILE.PUT_LINE(FND_FILE.LOG ,'REFINANCE_PAYMENT_SCHEDULE');
                    
                    REFINANCE_PAYMENT_SCHEDULE(var_payment_schedule_id, P_EARNED_DATE);
                END IF;

                IF var_entry_value = 0 THEN
                    EXIT;
                END IF;
                                      
            END LOOP;
            
        END IF;
        
        
        SELECT COUNT(ASPS.PAYMENT_NUMBER)
          INTO var_validate
          FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
         WHERE 1 = 1
           AND ASPS.LOAN_ID = var_loan_id
           AND ASPS.STATUS_FLAG NOT IN ('PAYED', 'REFINANCED');
           
    
        IF var_validate = 0 THEN
        
            UPDATE ATET_SB_LOANS ASL
               SET ASL.LOAN_STATUS_FLAG = 'PAYED',
                   ASL.LAST_UPDATE_DATE = SYSDATE,
                   ASL.LAST_UPDATED_BY = var_user_id
             WHERE ASL.LOAN_ID = var_loan_id;

             
           
            MERGE INTO ATET_SB_MEMBERS      ASM
                 USING (SELECT DISTINCT ASE.LOAN_ID,
                                        ASE.MEMBER_ENDORSEMENT_ID
                          FROM ATET_SB_ENDORSEMENTS ASE
                         WHERE 1 = 1) ASE
                    ON (    ASE.LOAN_ID = var_loan_id
                        AND ASE.MEMBER_ENDORSEMENT_ID = ASM.MEMBER_ID)
            WHEN MATCHED THEN 
            UPDATE SET ASM.IS_ENDORSEMENT = 'N',
                       ASM.LAST_UPDATE_DATE = SYSDATE,
                       ASM.LAST_UPDATED_BY = var_user_id;      


            SELECT COUNT(ASL.LOAN_ID)
              INTO var_validate
              FROM ATET_SB_LOANS ASL
             WHERE 1 = 1
               AND ASL.MEMBER_ID = var_member_id
               AND ASL.LOAN_STATUS_FLAG = 'ACTIVE';

            IF var_validate = 0 THEN 
                MERGE INTO ATET_SB_MEMBERS      ASM
                     USING (SELECT DISTINCT ASE.LOAN_ID,
                                            ASE.MEMBER_BORROWER_ID
                              FROM ATET_SB_ENDORSEMENTS ASE
                             WHERE 1 = 1) ASE
                        ON (    ASE.LOAN_ID = var_loan_id
                            AND ASE.MEMBER_BORROWER_ID = ASM.MEMBER_ID)
                WHEN MATCHED THEN 
                UPDATE SET ASM.IS_BORROWER = 'N',
                           ASM.LAST_UPDATE_DATE = SYSDATE,
                           ASM.LAST_UPDATED_BY = var_user_id;
            END IF;
        
        END IF;     
        
        
        SELECT COUNT(ASPS.PAYMENT_SCHEDULE_ID)
          INTO var_validate
          FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
         WHERE 1 = 1
           AND ASPS.LOAN_ID = var_loan_id
           AND ASPS.STATUS_FLAG IN ('PENDING', 'EXPORTED');
            
                    
        IF var_validate = 0 THEN
                
            SELECT COUNT(ASPS.PAYMENT_SCHEDULE_ID)
              INTO var_validate
              FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
             WHERE 1 = 1
               AND ASPS.LOAN_ID = var_loan_id
               AND ASPS.STATUS_FLAG IN ('SKIP', 'PARTIAL');
                           
            IF var_validate > 0 THEN
                    
                var_late_interest_rate := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LATE_INT');
                            
                SELECT NVL(SUM(NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL)), 0)       AS  PAYMENT_CAPITAL,
                       NVL(SUM(NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST)), 0)      AS  PAYMENT_INTEREST,
                       NVL(SUM(NVL(ASPS.OWED_INTEREST_LATE, ASPS.PAYMENT_INTEREST_LATE)), 0) AS  PAYMENT_INTEREST_LATE
                  INTO var_nd_payment_capital,
                       var_nd_payment_interest,
                       var_nd_payment_interest_late
                  FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
                 WHERE 1 = 1
                   AND ASPS.LOAN_ID = var_loan_id
                   AND ASPS.STATUS_FLAG IN ('SKIP', 'PARTIAL')
                   AND ASPS.ATTRIBUTE6 IS NULL;
                               
                SELECT NVL(SUM(NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL)), 0)        AS  PAYMENT_CAPITAL,
                       NVL(SUM(NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST)), 0)       AS  PAYMENT_INTEREST,
                       NVL(SUM(NVL(ASPS.OWED_INTEREST_LATE, ASPS.PAYMENT_INTEREST_LATE)), 0)  AS  PAYMENT_INTEREST_LATE
                  INTO var_wd_payment_capital,
                       var_wd_payment_interest,
                       var_wd_payment_interest_late
                  FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
                 WHERE 1 = 1
                   AND ASPS.LOAN_ID = var_loan_id
                   AND ASPS.STATUS_FLAG IN ('SKIP', 'PARTIAL')
                   AND ASPS.ATTRIBUTE6 = 'DISABILITIES';
                               
                var_wd_payment_capital := var_wd_payment_capital;
                var_wd_payment_interest := var_wd_payment_interest;
                var_wd_payment_interest_late := var_wd_payment_interest_late;
                            
                var_nd_payment_capital := var_nd_payment_capital;
                var_nd_payment_interest := var_nd_payment_interest;
                var_nd_payment_interest_late := TRUNC((var_nd_payment_interest_late + ((var_nd_payment_capital + var_nd_payment_interest) * (var_late_interest_rate / 100))), 2);
                            
                var_p_payment_capital := var_wd_payment_capital + var_nd_payment_capital;
                var_p_payment_interest := var_wd_payment_interest + var_nd_payment_interest;
                var_p_payment_interest_late := TRUNC((var_wd_payment_interest_late + var_nd_payment_interest_late), 2);
                            
                EXTEND_PAYMENTS_SCHEDULE(P_LOAN_ID                  => var_loan_id,
                                         P_PERSON_ID                => P_PERSON_ID,
                                         P_MEMBER_ID                => var_member_id,
                                         P_TIME_PERIOD_ID           => P_TIME_PERIOD_ID,
                                         P_ACTUAL_DATE_EARNED       => P_EARNED_DATE,
                                         P_PAYMENT_CAPITAL          => var_p_payment_capital,
                                         P_PAYMENT_INTEREST         => var_p_payment_interest,
                                         P_PAYMENT_INTEREST_LATE    => var_p_payment_interest_late);
                                                     
            END IF;
                    
        END IF;  
    
    
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'MOVIMIENTO PROCESADO: *PRESTAMO*' || P_PAYROLL_RESULT_ID  || ','
                                                                              || P_PERSON_ID          || ','
                                                                              || P_RUN_RESULT_ID      || ','
                                                                              || P_EARNED_DATE        || ','
                                                                              || P_PERIOD_NAME        || ','
                                                                              || P_ELEMENT_NAME       || ','
                                                                              || P_ENTRY_NAME         || ','
                                                                              || P_ENTRY_UNITS        || ','
                                                                              || P_ENTRY_VALUE        || ','
                                                                              || P_DEBIT_AMOUNT       || ','
                                                                              || P_CREDIT_AMOUNT      || '.'); 
                                                                              
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT_LOAN_TRANSACTION(P_EXPORT_REQUEST_ID => ' || P_EXPORT_REQUEST_ID ||
                                                               ',P_PAYROLL_RESULT_ID => ' || P_PAYROLL_RESULT_ID ||
                                                               ',P_PERSON_ID => ' || P_PERSON_ID ||
                                                               ',P_RUN_RESULT_ID => ' || P_RUN_RESULT_ID ||
                                                               ',P_EARNED_DATE => ' || P_EARNED_DATE ||
                                                               ',P_TIME_PERIOD_ID => ' || P_TIME_PERIOD_ID ||
                                                               ',P_PERIOD_NAME => ' || P_PERIOD_NAME ||
                                                               ',P_ELEMENT_NAME => ' || P_ELEMENT_NAME ||
                                                               ',P_ENTRY_NAME => ' || P_ENTRY_NAME ||
                                                               ',P_ENTRY_UNITS => ' || P_ENTRY_UNITS ||
                                                               ',P_ENTRY_VALUE => ' || P_ENTRY_VALUE ||
                                                               ',P_DEBIT_AMOUNT => ' || P_DEBIT_AMOUNT ||
                                                               ',P_CREDIT_AMOUNT => ' || P_CREDIT_AMOUNT || ') RETURN Y');                          
    
        RETURN 'Y';
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'NO SE PROCESO EL MOVIMIENTO: *PRESTAMO*' || P_PAYROLL_RESULT_ID  || ','
                                                                                  || P_PERSON_ID          || ','
                                                                                  || P_RUN_RESULT_ID      || ','
                                                                                  || P_EARNED_DATE        || ','
                                                                                  || P_PERIOD_NAME        || ','
                                                                                  || P_ELEMENT_NAME       || ','
                                                                                  || P_ENTRY_NAME         || ','
                                                                                  || P_ENTRY_UNITS        || ','
                                                                                  || P_ENTRY_VALUE        || ','
                                                                                  || P_DEBIT_AMOUNT       || ','
                                                                                  || P_CREDIT_AMOUNT      || '.' || SQLERRM);
                                                                                  
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT_LOAN_TRANSACTION(P_EXPORT_REQUEST_ID => ' || P_EXPORT_REQUEST_ID ||
                                                               ',P_PAYROLL_RESULT_ID => ' || P_PAYROLL_RESULT_ID ||
                                                               ',P_PERSON_ID => ' || P_PERSON_ID ||
                                                               ',P_RUN_RESULT_ID => ' || P_RUN_RESULT_ID ||
                                                               ',P_EARNED_DATE => ' || P_EARNED_DATE ||
                                                               ',P_TIME_PERIOD_ID => ' || P_TIME_PERIOD_ID ||
                                                               ',P_PERIOD_NAME => ' || P_PERIOD_NAME ||
                                                               ',P_ELEMENT_NAME => ' || P_ELEMENT_NAME ||
                                                               ',P_ENTRY_NAME => ' || P_ENTRY_NAME ||
                                                               ',P_ENTRY_UNITS => ' || P_ENTRY_UNITS ||
                                                               ',P_ENTRY_VALUE => ' || P_ENTRY_VALUE ||
                                                               ',P_DEBIT_AMOUNT => ' || P_DEBIT_AMOUNT ||
                                                               ',P_CREDIT_AMOUNT => ' || P_CREDIT_AMOUNT || ') RETURN N');
                                                               
        ROLLBACK;
        RETURN 'N';
    
    END INSERT_LOAN_TRANSACTION;
    
    
    PROCEDURE   INSERT_LOAN_TRANSACTION(
                    P_PAYMENT_NUMBER            NUMBER,
                    P_DEBIT_AMOUNT              NUMBER,
                    P_CREDIT_AMOUNT             NUMBER,
                    P_PAYMENT_AMOUNT            NUMBER,
                    P_PAYMENT_CAPITAL           NUMBER,
                    P_PAYMENT_INTEREST          NUMBER,
                    P_PAYMENT_INTEREST_LATE     NUMBER,
                    P_ELEMENT_NAME              VARCHAR2,
                    P_ENTRY_NAME                VARCHAR2,
                    P_ENTRY_UNITS               VARCHAR2,
                    P_MEMBER_ACCOUNT_ID         NUMBER,
                    P_MEMBER_ID                 NUMBER,
                    P_PAYROLL_RESULT_ID         NUMBER,
                    P_LOAN_ID                   NUMBER,
                    P_PERSON_ID                 NUMBER,
                    P_RUN_RESULT_ID             NUMBER,
                    P_EARNED_DATE               DATE,
                    P_TIME_PERIOD_ID            NUMBER,
                    P_PERIOD_NAME               VARCHAR2,
                    P_ENTRY_VALUE               NUMBER,
                    P_EXPECTED_PAYMENT_AMOUNT   NUMBER,
                    P_PAYMENT_SCHEDULE_ID       NUMBER,
                    P_DESCRIPTION               VARCHAR2)
    IS
    
        var_validate                    NUMBER;
        var_user_id                     NUMBER := FND_GLOBAL.USER_ID;
        var_import_request_id           NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        var_late_interest_rate          NUMBER;
        
        var_nd_payment_capital          NUMBER;
        var_nd_payment_interest         NUMBER;
        var_nd_payment_interest_late    NUMBER;
        
        var_wd_payment_capital          NUMBER;
        var_wd_payment_interest         NUMBER;
        var_wd_payment_interest_late    NUMBER;
        
        var_p_payment_capital           NUMBER;
        var_p_payment_interest          NUMBER;
        var_p_payment_interest_late     NUMBER;
    
    BEGIN
    
        FND_FILE.PUT_LINE( FND_FILE.LOG, 'INSERT_LOAN_TRANSACTION(P_PAYMENT_NUMBER => '     || P_PAYMENT_NUMBER ||
                                                                ',P_DEBIT_AMOUNT => '       || P_DEBIT_AMOUNT ||
                                                                ',P_CREDIT_AMOUNT => '      || P_CREDIT_AMOUNT ||
                                                                ',P_PAYMENT_AMOUNT => '     || P_PAYMENT_AMOUNT ||
                                                                ',P_PAYMENT_CAPITAL => '    || P_PAYMENT_AMOUNT ||
                                                                ',P_PAYMENT_INTEREST => '   || P_PAYMENT_AMOUNT ||
                                                                ',P_PAYMENT_INTEREST_LATE => ' || P_PAYMENT_INTEREST_LATE ||
                                                                ',P_ELEMENT_NAME => '       || P_ELEMENT_NAME ||
                                                                ',P_ENTRY_NAME => '         || P_ENTRY_NAME ||
                                                                ',P_ENTRY_UNITS => '        || P_ENTRY_UNITS ||
                                                                ',P_MEMBER_ACCOUNT_ID => '  || P_MEMBER_ACCOUNT_ID ||
                                                                ',P_MEMBER_ID => '          || P_MEMBER_ID ||
                                                                ',P_PAYROLL_RESULT_ID => '  || P_PAYROLL_RESULT_ID ||
                                                                ',P_LOAN_ID => '            || P_LOAN_ID || 
                                                                ',P_PERSON_ID => '          || P_PERSON_ID ||
                                                                ',P_RUN_RESULT_ID => '      || P_RUN_RESULT_ID ||
                                                                ',P_EARNED_DATE => '        || P_EARNED_DATE ||
                                                                ',P_TIME_PERIOD_ID => '     || P_TIME_PERIOD_ID ||
                                                                ',P_PERIOD_NAME => '        || P_PERIOD_NAME ||
                                                                ',P_ENTRY_VALUE => '        || P_ENTRY_VALUE ||
                                                                ',P_EXPECTED_PAYMENT_AMOUNT => ' || P_EXPECTED_PAYMENT_AMOUNT ||
                                                                ',P_PAYMENT_SCHEDULE_ID => ' || P_PAYMENT_SCHEDULE_ID || 
                                                                ')');
    
        INSERT INTO ATET_SB_LOANS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                MEMBER_ID,
                                                PAYROLL_RESULT_ID,
                                                LOAN_ID,
                                                PERSON_ID,
                                                RUN_RESULT_ID,
                                                EARNED_DATE,
                                                TIME_PERIOD_ID,
                                                PERIOD_NAME,
                                                ELEMENT_NAME,
                                                ENTRY_NAME,
                                                ENTRY_UNITS,
                                                ENTRY_VALUE,
                                                TRANSACTION_CODE,
                                                DEBIT_AMOUNT,
                                                CREDIT_AMOUNT,
                                                PAYMENT_AMOUNT,
                                                PAYMENT_CAPITAL,
                                                PAYMENT_INTEREST,
                                                PAYMENT_INTEREST_LATE,
                                                REQUEST_ID,
                                                ACCOUNTED_FLAG,
                                                ATTRIBUTE6,
                                                CREATION_DATE,
                                                CREATED_BY,
                                                LAST_UPDATE_DATE,
                                                LAST_UPDATED_BY)
                                         VALUES (P_MEMBER_ACCOUNT_ID,
                                                 P_MEMBER_ID,
                                                 P_PAYROLL_RESULT_ID,
                                                 P_LOAN_ID,
                                                 P_PERSON_ID,
                                                 P_RUN_RESULT_ID,
                                                 P_EARNED_DATE,
                                                 P_TIME_PERIOD_ID,
                                                 P_PERIOD_NAME,
                                                 P_ELEMENT_NAME,
                                                 P_ENTRY_NAME,
                                                 P_ENTRY_UNITS,
                                                 P_PAYMENT_AMOUNT,
                                                 'PROCESSED',
                                                 P_DEBIT_AMOUNT,
                                                 P_CREDIT_AMOUNT,
                                                 P_PAYMENT_AMOUNT,
                                                 P_PAYMENT_CAPITAL,
                                                 P_PAYMENT_INTEREST,
                                                 P_PAYMENT_INTEREST_LATE,
                                                 var_import_request_id,
                                                 'UNACCOUNTED',
                                                 P_DESCRIPTION,
                                                 SYSDATE,
                                                 var_user_id,
                                                 SYSDATE,
                                                 var_user_id);
                
                                                   
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET DEBIT_BALANCE = DEBIT_BALANCE + P_DEBIT_AMOUNT,
               CREDIT_BALANCE = CREDIT_BALANCE + (P_PAYMENT_CAPITAL + P_PAYMENT_INTEREST),
               LAST_TRANSACTION_DATE = SYSDATE               
         WHERE MEMBER_ID = P_MEMBER_ID
           AND MEMBER_ACCOUNT_ID = P_MEMBER_ACCOUNT_ID;
                       
                       
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET FINAL_BALANCE = DEBIT_BALANCE - CREDIT_BALANCE,
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = var_user_id             
         WHERE MEMBER_ID = P_MEMBER_ID
           AND MEMBER_ACCOUNT_ID = P_MEMBER_ACCOUNT_ID;
                       
                       
        UPDATE ATET_SB_LOANS ASL
           SET ASL.LOAN_BALANCE = ASL.LOAN_BALANCE - (P_PAYMENT_CAPITAL + P_PAYMENT_INTEREST),
               ASL.LAST_PAYMENT_DATE = P_EARNED_DATE,
               ASL.LAST_UPDATE_DATE = SYSDATE,
               ASL.LAST_UPDATED_BY = var_user_id
         WHERE 1 = 1
           AND ASL.LOAN_ID = P_LOAN_ID;
               
                       
        IF P_PAYMENT_AMOUNT > 0 AND P_PAYMENT_AMOUNT >= P_EXPECTED_PAYMENT_AMOUNT  THEN
                    
            UPDATE ATET_SB_PAYMENTS_SCHEDULE ASPS
               SET ASPS.STATUS_FLAG         = 'PAYED',
                   ASPS.PAYED_AMOUNT        = NVL(ASPS.PAYED_AMOUNT, 0) + P_PAYMENT_AMOUNT,
                   ASPS.PAYED_CAPITAL       = NVL(ASPS.PAYED_CAPITAL, 0) + P_PAYMENT_CAPITAL,
                   ASPS.PAYED_INTEREST      = NVL(ASPS.PAYED_INTEREST, 0) + P_PAYMENT_INTEREST,
                   ASPS.PAYED_INTEREST_LATE = NVL(ASPS.PAYED_INTEREST_LATE, 0) + P_PAYMENT_INTEREST_LATE,
                   ASPS.OWED_AMOUNT         = (NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL) - P_PAYMENT_CAPITAL) +
                                              (NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST) - P_PAYMENT_INTEREST) +
                                              (NVL(ASPS.OWED_INTEREST_LATE, ASPS.PAYMENT_INTEREST_LATE) - P_PAYMENT_INTEREST_LATE),
                   ASPS.OWED_CAPITAL        = NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL) - P_PAYMENT_CAPITAL,
                   ASPS.OWED_INTEREST       = NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST) - P_PAYMENT_INTEREST,
                   ASPS.OWED_INTEREST_LATE  = NVL(ASPS.OWED_INTEREST_LATE, ASPS.PAYMENT_INTEREST_LATE) - P_PAYMENT_INTEREST_LATE,
                   ASPS.LAST_UPDATE_DATE    = SYSDATE,
                   ASPS.LAST_UPDATED_BY     = var_user_id
             WHERE ASPS.PAYMENT_SCHEDULE_ID = P_PAYMENT_SCHEDULE_ID
               AND ASPS.LOAN_ID = P_LOAN_ID;
                    
        ELSIF P_PAYMENT_AMOUNT > 0 AND P_PAYMENT_AMOUNT < P_EXPECTED_PAYMENT_AMOUNT THEN
                    
            UPDATE ATET_SB_PAYMENTS_SCHEDULE ASPS
               SET ASPS.STATUS_FLAG         = 'PARTIAL',
                   ASPS.PAYED_AMOUNT        = NVL(ASPS.PAYED_AMOUNT, 0) + P_PAYMENT_AMOUNT,
                   ASPS.PAYED_CAPITAL       = NVL(ASPS.PAYED_CAPITAL, 0) + P_PAYMENT_CAPITAL,
                   ASPS.PAYED_INTEREST      = NVL(ASPS.PAYED_INTEREST, 0) + P_PAYMENT_INTEREST,
                   ASPS.PAYED_INTEREST_LATE = NVL(ASPS.PAYED_INTEREST_LATE, 0) + P_PAYMENT_INTEREST_LATE,
                   ASPS.OWED_AMOUNT         = (NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL) - P_PAYMENT_CAPITAL) +
                                              (NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST) - P_PAYMENT_INTEREST) +
                                              (NVL(ASPS.OWED_INTEREST_LATE, ASPS.PAYMENT_INTEREST_LATE) - P_PAYMENT_INTEREST_LATE),
                   ASPS.OWED_CAPITAL        = NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL) - P_PAYMENT_CAPITAL,
                   ASPS.OWED_INTEREST       = NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST) - P_PAYMENT_INTEREST,
                   ASPS.OWED_INTEREST_LATE  = NVL(ASPS.OWED_INTEREST_LATE, ASPS.PAYMENT_INTEREST_LATE) - P_PAYMENT_INTEREST_LATE,
                   ASPS.ATTRIBUTE6          = HAS_DISABILITIES(P_PERSON_ID, ASPS.TIME_PERIOD_ID),
                   ASPS.LAST_UPDATE_DATE    = SYSDATE,
                   ASPS.LAST_UPDATED_BY     = var_user_id
             WHERE ASPS.PAYMENT_SCHEDULE_ID = P_PAYMENT_SCHEDULE_ID
               AND ASPS.LOAN_ID = P_LOAN_ID;
                    
        ELSIF P_PAYMENT_AMOUNT = 0 THEN
                    
            UPDATE ATET_SB_PAYMENTS_SCHEDULE ASPS
               SET ASPS.STATUS_FLAG         = 'SKIP',
                   ASPS.PAYED_AMOUNT        = NVL(ASPS.PAYED_AMOUNT, 0) + P_PAYMENT_AMOUNT,
                   ASPS.PAYED_CAPITAL       = NVL(ASPS.PAYED_CAPITAL, 0) + P_PAYMENT_CAPITAL,
                   ASPS.PAYED_INTEREST      = NVL(ASPS.PAYED_INTEREST, 0) + P_PAYMENT_INTEREST,
                   ASPS.PAYED_INTEREST_LATE = NVL(ASPS.PAYED_INTEREST_LATE, 0) + P_PAYMENT_INTEREST_LATE,
                   ASPS.OWED_AMOUNT         = (ASPS.PAYMENT_CAPITAL + ASPS.PAYMENT_INTEREST + ASPS.PAYMENT_INTEREST_LATE),  
                   ASPS.OWED_CAPITAL        = ASPS.PAYMENT_CAPITAL,
                   ASPS.OWED_INTEREST       = ASPS.PAYMENT_INTEREST,
                   ASPS.OWED_INTEREST_LATE  = ASPS.PAYMENT_INTEREST_LATE,
                   ASPS.ATTRIBUTE6          = HAS_DISABILITIES(P_PERSON_ID, ASPS.TIME_PERIOD_ID),
                   ASPS.LAST_UPDATE_DATE    = SYSDATE,
                   ASPS.LAST_UPDATED_BY     = var_user_id
             WHERE ASPS.PAYMENT_SCHEDULE_ID = P_PAYMENT_SCHEDULE_ID
               AND ASPS.LOAN_ID = P_LOAN_ID;                   
                    
        END IF;
        
        
    END INSERT_LOAN_TRANSACTION;
    

    FUNCTION    GET_SAVING_MEMBER_ACCOUNT_ID(
                    P_MEMBER_ID            NUMBER,
                    P_ACCOUNT_NUMBER       VARCHAR2,
                    P_ACCOUNT_DESCRIPTION  VARCHAR2)
      RETURN    NUMBER
    IS
        var_member_account_id   NUMBER;
    BEGIN
    
        SELECT ASMA.MEMBER_ACCOUNT_ID
          INTO var_member_account_id
          FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
         WHERE 1 = 1
           AND ASMA.MEMBER_ID = P_MEMBER_ID
           AND ASMA.ACCOUNT_NUMBER = P_ACCOUNT_NUMBER
           AND ASMA.ACCOUNT_DESCRIPTION = P_ACCOUNT_DESCRIPTION;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_SAVING_MEMBER_ACCOUNT_ID(P_MEMBER_ID => ' || P_MEMBER_ID || 
                                                                    ',P_ACCOUNT_NUMBER => ' || P_ACCOUNT_NUMBER || 
                                                                    ',P_ACCOUNT_DESCRIPTION => ' || P_ACCOUNT_DESCRIPTION || 
                                                                    ') RETURN ' || var_member_account_id);
         
        RETURN var_member_account_id;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_SAVING_MEMBER_ACCOUNT_ID ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_SAVING_MEMBER_ACCOUNT_ID;
    
    
    FUNCTION    GET_LOAN_MEMBER_ACCOUNT_ID(
                    P_MEMBER_ID          NUMBER,
                    P_LOAN_ID            NUMBER)
      RETURN    NUMBER
    IS
        var_member_account_id   NUMBER;

    BEGIN
           
        BEGIN
        
            SELECT ASMA.MEMBER_ACCOUNT_ID
              INTO var_member_account_id
              FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
             WHERE 1 = 1
               AND ASMA.MEMBER_ID = P_MEMBER_ID
               AND ASMA.LOAN_ID = P_LOAN_ID
               AND ASMA.ACCOUNT_DESCRIPTION = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME');        
               
               DBMS_OUTPUT.PUT_LINE( 'SELECT ACCOUNT');
        
        EXCEPTION WHEN NO_DATA_FOUND THEN
           
            UPDATE ATET_SB_MEMBERS_ACCOUNTS ASMA
               SET ASMA.LOAN_ID = P_LOAN_ID,
                   ASMA.LAST_UPDATE_DATE = SYSDATE,
                   ASMA.LAST_UPDATED_BY = FND_GLOBAL.USER_ID
             WHERE 1 = 1
               AND ASMA.MEMBER_ID = P_MEMBER_ID
               AND ASMA.ACCOUNT_DESCRIPTION = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME')
               AND ASMA.LOAN_ID IS NULL; 
               
               DBMS_OUTPUT.PUT_LINE( 'UPDATE ACCOUNT');
               

            
            SELECT ASMA.MEMBER_ACCOUNT_ID
              INTO var_member_account_id
              FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
             WHERE 1 = 1
               AND ASMA.MEMBER_ID = P_MEMBER_ID
               AND ASMA.LOAN_ID = P_LOAN_ID
               AND ASMA.ACCOUNT_DESCRIPTION = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME');  
        
            DBMS_OUTPUT.PUT_LINE( 'SELECT ACCOUNT');
        
        END;
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_LOAN_MEMBER_ACCOUNT_ID(P_MEMBER_ID => ' || P_MEMBER_ID || 
                                                                  ',P_LOAN_ID => ' || P_LOAN_ID || 
                                                                  ') RETURN ' || var_member_account_id);
    
        RETURN var_member_account_id;
    END GET_LOAN_MEMBER_ACCOUNT_ID;


    PROCEDURE   SET_LOAN_BALANCE(
                    P_LOAN_ID            NUMBER,
                    P_LOAN_AMOUNT        NUMBER,
                    P_PERSON_ID          NUMBER)
    IS
        var_member_id           NUMBER := GET_MEMBER_ID(P_PERSON_ID);
        var_member_account_id   NUMBER;
        var_user_id             NUMBER := FND_GLOBAL.USER_ID;
        var_loan_number         NUMBER;
        var_loan_id             NUMBER;
        var_transaction_date    DATE;
    BEGIN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'SET_LOAN_BALANCE(P_LOAN_ID => ' || P_LOAN_ID ||
                                                        ',P_LOAN_AMOUNT => ' || P_LOAN_AMOUNT ||
                                                        ',P_PERSON_ID => ' || P_PERSON_ID ||
                                                        ')');
    
        SELECT ASL.LOAN_ID,
               ASL.LOAN_NUMBER,
               ASL.TRANSACTION_DATE
          INTO var_loan_id,
               var_loan_number,
               var_transaction_date
          FROM ATET_SB_LOANS    ASL
         WHERE 1 = 1
           AND ASL.MEMBER_ID = GET_MEMBER_ID(P_PERSON_ID)
           AND ASL.LOAN_ID = P_LOAN_ID;
           
           
            DBMS_OUTPUT.PUT_LINE( 'SELECT LOAN_ID, LOAN_NUMBER');     
           
        var_member_account_id := GET_LOAN_MEMBER_ACCOUNT_ID(GET_MEMBER_ID(P_PERSON_ID), P_LOAN_ID);
                                                          
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET DEBIT_BALANCE = DEBIT_BALANCE + P_LOAN_AMOUNT,
               CREDIT_BALANCE = CREDIT_BALANCE + 0,
               LAST_TRANSACTION_DATE = SYSDATE               
         WHERE MEMBER_ID = var_member_id
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET FINAL_BALANCE = DEBIT_BALANCE - CREDIT_BALANCE,
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = var_user_id             
         WHERE MEMBER_ID = var_member_id
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
           
        INSERT INTO ATET_SB_LOANS_TRANSACTIONS(MEMBER_ACCOUNT_ID,
                                               MEMBER_ID,
                                               PAYROLL_RESULT_ID,
                                               LOAN_ID,
                                               PERSON_ID,
                                               EARNED_DATE,
                                               PERIOD_NAME,
                                               ELEMENT_NAME,
                                               TRANSACTION_CODE,
                                               DEBIT_AMOUNT,
                                               CREDIT_AMOUNT,
                                               ACCOUNTED_FlAG,
                                               CREATION_DATE,
                                               CREATED_BY,
                                               LAST_UPDATE_DATE,
                                               LAST_UPDATED_BY)
                                       VALUES (var_member_account_id,
                                               var_member_id,
                                               -1,
                                               P_LOAN_ID,
                                               P_PERSON_ID,
                                               var_transaction_date,
                                               'APERTURA',
                                               'APERTURA DE PRESTAMO',
                                               'OPENING',
                                               P_LOAN_AMOUNT,
                                               0,
                                               'ACCOUNTED',
                                               SYSDATE,
                                               var_user_id,
                                               SYSDATE,
                                               var_user_id);
        

    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en SET_LOAN_BALANCE ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END SET_LOAN_BALANCE;
    
    
    PROCEDURE   INSERT_EXTEMPORANEOUS_SAVING(
                    P_ERRBUF               OUT NOCOPY  VARCHAR2,
                    P_RETCODE              OUT NOCOPY  VARCHAR2,
                    P_PERSON_ID            NUMBER,
                    P_SAVING_AMOUNT        NUMBER,
                    P_PENDING_PAYMENT      NUMBER)
    IS
    
         var_person_id                  NUMBER;
         var_employee_number            NUMBER;
         var_employee_full_name         VARCHAR2(300);
         var_person_type                VARCHAR2(300);
         var_seniority_years            NUMBER;
         var_rfc                        VARCHAR2(300);
         var_curp                       VARCHAR2(300);
         var_sex                        VARCHAR2(300);
         var_email_address              VARCHAR2(300);
         var_effective_hire_date        DATE;
         var_member_start_date          DATE;
         var_is_saver                   VARCHAR2(10);
         var_is_borrower                VARCHAR2(10);
         var_is_endorsement             VARCHAR2(10);
         var_assignment_id              NUMBER;
         var_payroll_id                 NUMBER;
         var_period_type                VARCHAR2(300);
         var_max_assignment_action_id   NUMBER;
         var_max_per_sav                NUMBER;
         var_max_sav_amt_sm             NUMBER;
         var_max_sav_amt_wk             NUMBER;
         var_posibility_saving          NUMBER;
         var_real_posibility_saving     NUMBER;
         var_validate                   VARCHAR2(1) := 'N';
         var_min_sav_amt_sm             NUMBER;
         var_min_sav_amt_wk             NUMBER;
         var_saving_bank_id             NUMBER := ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID;
    BEGIN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT_EXTEMPORANEOUS_SAVING(P_PERSON_ID => ' || P_PERSON_ID ||
                                                                    ',P_SAVING_AMOUNT => ' || P_SAVING_AMOUNT ||
                                                                    ',P_PENDING_PAYMENT => ' || P_PENDING_PAYMENT ||
                                                                    ')');
        
        IF TO_DATE(GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'REG_EXTEMPORANEOUS_DATE'), 'RRRR/MM/DD') > SYSDATE THEN
            
            SELECT PPF.PERSON_ID                                                  AS  "PERSON_ID",
                 PPF.EMPLOYEE_NUMBER                                              AS  "EMPLOYEE_NUMBER",
                 PPF.FULL_NAME                                                    AS  "EMPLOYEE_NAME",
                 UPPER(PPTT.USER_PERSON_TYPE)                                     AS  "PERSON_TYPE",
                 TRUNC(HR_MX_UTILITY.GET_SENIORITY_SOCIAL_SECURITY(PPF.PERSON_ID, 
                                                                   SYSDATE))      AS  "SENIORITY_YEARS",
                 PPF.PER_INFORMATION2                                             AS  "RFC",
                 PPF.NATIONAL_IDENTIFIER                                          AS  "CURP",
                 UPPER(PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('SEX', 
                                                         PPF.SEX))                AS  "SEX",
                 PPF.EMAIL_ADDRESS                                                AS  "EMAIL_ADDRESS",
                 PAC_RESULT_VALUES_PKG.GET_EFFECTIVE_START_DATE(PPF.PERSON_ID)    AS  "FFECTIVE_START_DATE",
                 SYSDATE,
                 'Y'                                                              AS  "IS_SAVER",
                 'N'                                                              AS  "IS_BORROWER",
                 'N'                                                              AS  "IS_ENDORSEMENT",
                 PAF.ASSIGNMENT_ID,
                 PAF.PAYROLL_ID
            INTO var_person_id,
                 var_employee_number,
                 var_employee_full_name,
                 var_person_type,
                 var_seniority_years,
                 var_rfc,
                 var_curp,
                 var_sex,
                 var_email_address,
                 var_effective_hire_date,
                 var_member_start_date,
                 var_is_saver,
                 var_is_borrower,
                 var_is_endorsement,
                 var_assignment_id,
                 var_payroll_id
            FROM PER_PEOPLE_F             PPF,
                 PER_PERSON_TYPES_TL      PPTT,
                 PER_ASSIGNMENTS_F        PAF,
                 PER_PERIODS_OF_SERVICE   PPOS
            WHERE 1 = 1
             AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
             AND PPF.PERSON_TYPE_ID = PPTT.PERSON_TYPE_ID
             AND LANGUAGE = USERENV('LANG')
             AND PPTT.USER_PERSON_TYPE IN ('Employee', 'Empleado')
             AND PPF.PERSON_ID = PAF.PERSON_ID
             AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
             AND PPOS.PERSON_ID = PPF.PERSON_ID
             AND PPOS.PERIOD_OF_SERVICE_ID = PAF.PERIOD_OF_SERVICE_ID
             AND PPF.PERSON_ID = P_PERSON_ID
            ORDER BY TO_NUMBER(PPF.EMPLOYEE_NUMBER);
            
            IF ATET_SAVINGS_BANK_PKG.IF_MEMBER_EXIST(var_employee_number) = 0 THEN
            
                var_period_type := ATET_SAVINGS_BANK_PKG.GET_PERIOD_TYPE(var_person_id);
                var_max_assignment_action_id := ATET_SAVINGS_BANK_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(var_assignment_id, var_payroll_id);
                          
            
                var_max_per_sav := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_PER_SAV');
                var_max_sav_amt_sm := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_SAV_AMT_SM');
                var_max_sav_amt_wk := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_SAV_AMT_WK');
                var_min_sav_amt_sm := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MIN_SAV_AMT_SM');
                var_min_sav_amt_wk := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MIN_SAV_AMT_WK');

                IF    var_period_type IN ('Week', 'Semana') THEN
                    var_posibility_saving := var_max_sav_amt_wk;
                ELSIF var_period_type IN ('Semi-Month', 'Quincena') THEN
                    var_posibility_saving := var_max_sav_amt_sm;
                END IF;

            
                IF    var_period_type IN ('Week', 'Semana') THEN
                
                  IF var_posibility_saving > var_max_sav_amt_wk THEN
                    var_real_posibility_saving := TRUNC(var_max_sav_amt_wk);
                  ELSE
                    var_real_posibility_saving := TRUNC(var_posibility_saving);
                  END IF;
                
                ELSIF var_period_type IN ('Semi-Month', 'Quincena') THEN
                
                  IF var_posibility_saving > var_max_sav_amt_sm THEN
                    var_real_posibility_saving := TRUNC(var_max_sav_amt_sm);
                  ELSE
                    var_real_posibility_saving := TRUNC(var_posibility_saving);
                  END IF;
                
                END IF;
                
                
                IF    var_period_type IN ('Semana', 'Week') THEN
                
                  IF    P_SAVING_AMOUNT < var_min_sav_amt_wk THEN
                    var_validate := 'N';
                  ELSIF P_SAVING_AMOUNT > var_real_posibility_saving THEN
                    var_validate := 'N';
                  ELSE
                    var_validate := 'Y';
                  END IF;
                
                ELSIF var_period_type IN ('Quincena', 'Semi-Month') THEN
                
                  IF    P_SAVING_AMOUNT < var_min_sav_amt_sm THEN
                    var_validate := 'N';
                  ELSIF P_SAVING_AMOUNT > var_real_posibility_saving THEN
                    var_validate := 'N';
                  ELSE
                    var_validate := 'Y';
                  END IF; 
                
                END IF;
                
                
                IF var_validate = 'Y' THEN
                    
                    INSERT INTO ATET_SB_MEMBERS (SAVING_BANK_ID,
                                                 PERSON_ID,
                                                 EMPLOYEE_NUMBER,
                                                 EMPLOYEE_FULL_NAME,
                                                 PERSON_TYPE,
                                                 SENIORITY_YEARS,
                                                 RFC,
                                                 CURP,
                                                 SEX,
                                                 EMAIL_ADDRESS,
                                                 AMOUNT_TO_SAVE,
                                                 ATTRIBUTE2,
                                                 ATTRIBUTE3,
                                                 EFFECTIVE_HIRE_DATE,
                                                 MEMBER_START_DATE,
                                                 IS_SAVER,
                                                 IS_BORROWER,
                                                 IS_ENDORSEMENT,
                                                 ATTRIBUTE6,                                                 
                                                 CREATION_DATE,
                                                 CREATED_BY,
                                                 LAST_UPDATE_DATE,
                                                 LAST_UPDATED_BY)
                                         VALUES (var_saving_bank_id,
                                                 var_person_id,
                                                 var_employee_number,
                                                 var_employee_full_name,
                                                 var_person_type,
                                                 var_seniority_years,
                                                 var_rfc,
                                                 var_curp,
                                                 var_sex,
                                                 var_email_address,
                                                 P_SAVING_AMOUNT * (1 + P_PENDING_PAYMENT),
                                                 P_PENDING_PAYMENT,
                                                 P_SAVING_AMOUNT,
                                                 var_effective_hire_date,
                                                 TO_DATE(var_member_start_date, 'DD/MM/RRRR'),
                                                 var_is_saver,
                                                 var_is_borrower,
                                                 var_is_endorsement,
                                                 var_period_type,
                                                 SYSDATE,
                                                 FND_GLOBAL.USER_ID,
                                                 SYSDATE,
                                                 FND_GLOBAL.USER_ID); 
                                                 
                    COMMIT;
                    
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '****************AHORRO INGRESADO****************');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Número de empleado : ' || var_employee_number);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Nombre de empleado : ' || var_employee_full_name);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Tipo de persona : ' || var_person_type);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Antigüedad : ' || var_seniority_years);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'RFC : ' || var_rfc);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'CURP :' || var_curp);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Sexo : ' || var_sex);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'e-mail : ' || var_email_address);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Monto de ahorro :' || P_SAVING_AMOUNT);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Periodos pendientes :' || P_PENDING_PAYMENT);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Siguiente descuento :' || TO_CHAR(P_SAVING_AMOUNT * (1 + P_PENDING_PAYMENT)));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Fecha de Inscripción :' || TO_CHAR(var_member_start_date));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '***********************************************');
                
                ELSE
                    P_ERRBUF := 'La cantidad de ahorro ingresada excede la posibilidad de ahorro del empleado.';
                    P_RETCODE := 1;
                END IF;
            
            ELSE
                P_ERRBUF := 'El empleado ingresado ya es miembro de la caja de ahorro.';
                P_RETCODE := 1;
            END IF;
        
        ELSE
            P_ERRBUF := 'La fecha de registro ha vencido para este proceso.';
            P_RETCODE := 1;
        END IF;
    
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en INSERT_EXTEMPORANEOUS_SAVING ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END INSERT_EXTEMPORANEOUS_SAVING;
    
    
    FUNCTION    GET_POSIBILITY_SAVING(
                    P_PERSON_ID           NUMBER)
      RETURN    NUMBER
    IS
         var_period_type                VARCHAR2(100);
         var_assignment_id               NUMBER;
         var_payroll_id                 NUMBER;
         var_max_assignment_action_id   NUMBER;
         var_max_per_sav                NUMBER;
         var_posibility_saving          NUMBER;
         var_subtbr                     NUMBER;
         var_saving_bank_id             NUMBER := ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID;
         var_max_sav_amt_sm             NUMBER;
         var_max_sav_amt_wk             NUMBER;
    BEGIN
    
        SELECT PAF.ASSIGNMENT_ID,
               PAF.PAYROLL_ID
          INTO var_assignment_id,
               var_payroll_id
          FROM PER_ASSIGNMENTS_F    PAF
         WHERE 1 = 1
           AND PAF.PERSON_ID = P_PERSON_ID
           AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE;
          
    
        var_period_type := ATET_SAVINGS_BANK_PKG.GET_PERIOD_TYPE(P_PERSON_ID);   
        var_max_assignment_action_id := ATET_SAVINGS_BANK_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(var_assignment_id, var_payroll_id);
        var_subtbr := ATET_SAVINGS_BANK_PKG.GET_SUBTBR(var_max_assignment_action_id);
        var_max_per_sav := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_PER_SAV');
        var_posibility_saving := (var_subtbr) * (var_max_per_sav / 100);
        var_max_sav_amt_sm := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_SAV_AMT_SM');
        var_max_sav_amt_wk := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_SAV_AMT_WK');
        
        IF    var_period_type IN ('Week', 'Semana') THEN
          IF var_posibility_saving > var_max_sav_amt_wk THEN
            var_posibility_saving := TRUNC(var_max_sav_amt_wk);
          ELSE
            var_posibility_saving := TRUNC(var_posibility_saving);
          END IF;
        ELSIF var_period_type IN ('Semi-Month', 'Quincena') THEN
          IF var_posibility_saving > var_max_sav_amt_sm THEN
            var_posibility_saving := TRUNC(var_max_sav_amt_sm);
          ELSE
            var_posibility_saving := TRUNC(var_posibility_saving);
          END IF;
        END IF;
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_POSIBILITY_SAVING(P_PERSON_ID => ' || P_PERSON_ID || 
                                                              ') RETURN ' || var_posibility_saving); 
    
        RETURN var_posibility_saving;
        
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_POSIBILITY_SAVING ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_POSIBILITY_SAVING;
        
    
    FUNCTION    GET_RESULT_FROM_PAYROLL_RESULT(
                    P_PERSON_ID                 NUMBER,
                    P_EXPORT_REQUEST_ID         NUMBER,
                    P_RUN_RESULT_ID             NUMBER,
                    P_ENTRY_NAME                VARCHAR2)
      RETURN    NUMBER
    IS
        var_result      NUMBER;
    BEGIN 
    
        SELECT ASPR.ENTRY_VALUE
          INTO var_result
          FROM ATET_SB_PAYROLL_RESULTS  ASPR
         WHERE 1 = 1
           AND ASPR.PERSON_ID = P_PERSON_ID
           AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
           AND ASPR.RUN_RESULT_ID = P_RUN_RESULT_ID
           AND ASPR.ENTRY_NAME = P_ENTRY_NAME;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_RESULT_FROM_PAYROLL_RESULT(P_PERSON_ID => ' || P_PERSON_ID || 
                                                                      ',P_EXPORT_REQUEST_ID => ' || P_EXPORT_REQUEST_ID || 
                                                                      ',P_RUN_RESULT_ID => ' || P_RUN_RESULT_ID || 
                                                                      ',P_ENTRY_NAME => ' || P_ENTRY_NAME || 
                                                                      ') RETURN ' || var_result);
    
        RETURN var_result;
       
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END GET_RESULT_FROM_PAYROLL_RESULT;
    
    
    FUNCTION    GET_LOAN_ID(
                    P_MEMBER_ID     NUMBER,
                    P_LOAN_NUMBER   NUMBER)
      RETURN    NUMBER
    IS
        var_result  NUMBER;
    BEGIN
    
        SELECT ASL.LOAN_ID
          INTO var_result
          FROM ATET_SB_LOANS    ASL,
               ATET_SB_MEMBERS  ASM
         WHERE 1 = 1
           AND ASL.LOAN_NUMBER = P_LOAN_NUMBER
           AND ASL.MEMBER_ID = ASM.MEMBER_ID
           AND ASM.MEMBER_ID = P_MEMBER_ID
           AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_LOAN_ID(P_MEMBER_ID => ' || P_MEMBER_ID || 
                                                   ',P_LOAN_NUMBER => ' || P_LOAN_NUMBER || 
                                                   ') RETURN ' || var_result);
    
        RETURN var_result;
        
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_LOAN_ID(P_MEMBER_ID => '||P_MEMBER_ID||' , P_LOAN_NUMBER => '||P_LOAN_NUMBER||') ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_LOAN_ID;
    
    
    FUNCTION    GET_LOAN_ID(
                    P_PERSON_ID         NUMBER,
                    P_PAYMENT_AMOUNT    NUMBER)
      RETURN    NUMBER
    IS
        var_result  NUMBER;
    BEGIN
    
        BEGIN
            
            SELECT ASL.LOAN_ID
              INTO var_result
              FROM ATET_SB_MEMBERS              ASM,
                   ATET_SB_LOANS                ASL,
                   ATET_SB_PAYMENTS_SCHEDULE    ASPS
             WHERE ASM.PERSON_ID = P_PERSON_ID
               AND ASM.SAVING_BANK_ID = ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
               AND ASM.MEMBER_ID = ASL.MEMBER_ID
               AND ASL.LOAN_STATUS_FLAG = 'ACTIVE'
               AND ASL.LOAN_ID = ASPS.LOAN_ID
               AND ASPS.PAYMENT_NUMBER = 1;
        
        EXCEPTION WHEN TOO_MANY_ROWS THEN
    
            SELECT ASL.LOAN_ID
              INTO var_result
              FROM ATET_SB_MEMBERS              ASM,
                   ATET_SB_LOANS                ASL,
                   ATET_SB_PAYMENTS_SCHEDULE    ASPS
             WHERE ASM.PERSON_ID = P_PERSON_ID
               AND ASM.SAVING_BANK_ID = ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
               AND ASM.MEMBER_ID = ASL.MEMBER_ID
               AND ASL.LOAN_STATUS_FLAG = 'ACTIVE'
               AND ASL.LOAN_ID = ASPS.LOAN_ID
               AND ASPS.PAYMENT_NUMBER = 1
               AND TRUNC(ASPS.PAYMENT_AMOUNT, 0) = TRUNC(P_PAYMENT_AMOUNT,0);
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_LOAN_ID(P_PERSON_ID => '||P_PERSON_ID||', P_PAYMENT_AMOUNT => '||P_PAYMENT_AMOUNT||') ' || SQLCODE || ' -ERROR- ' || SQLERRM);   
        END;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_LOAN_ID(P_PERSON_ID => ' || P_PERSON_ID || 
                                                   ',P_PAYMENT_AMOUNT => ' || P_PAYMENT_AMOUNT || 
                                                   ') RETURN ' || var_result); 
    
        RETURN var_result;
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_LOAN_ID(P_PERSON_ID => '||P_PERSON_ID||', P_PAYMENT_AMOUNT => '||P_PAYMENT_AMOUNT||') ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_LOAN_ID;
      
    
    
    PROCEDURE   SEND_TO_XLA(
                    P_ERRBUF         OUT NOCOPY  VARCHAR2,
                    P_RETCODE        OUT NOCOPY  VARCHAR2,
                    P_PERIOD_TYPE    VARCHAR2,
                    P_YEAR           NUMBER,
                    P_MONTH          NUMBER,
                    P_PERIOD_NAME    VARCHAR2,
                    P_ELEMENT_NAME   VARCHAR2)
    IS
    
        CURSOR DETAILS_COMPANIES IS
            SELECT DISTINCT SUBSTR(PPF.PAYROLL_NAME, 0, 2) AS COMPANY_CODE
              FROM PAY_PAYROLLS_F   PPF
             WHERE 1 = 1
               AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE;
    
        CURSOR DETAILS_SAVINGS(PP_PERIOD_NAME   VARCHAR2, 
                               PP_ELEMENT_NAME  VARCHAR2, 
                               PP_COMPANY_CODE  VARCHAR2) IS
            SELECT ASST.SAVING_TRANSACTION_ID,
                   ASMA.CODE_COMBINATION_ID,
                   ASMA.ACCOUNT_NUMBER,
                   ASST.MEMBER_ID,
                   ASM.EMPLOYEE_FULL_NAME,
                   ASST.PERSON_ID,
                   ASST.ENTRY_VALUE,
                   ASST.DEBIT_AMOUNT,
                   ASST.CREDIT_AMOUNT
              FROM ATET_SB_SAVINGS_TRANSACTIONS ASST,
                   ATET_SB_MEMBERS              ASM,
                   ATET_SB_MEMBERS_ACCOUNTS     ASMA,
                   PER_ASSIGNMENTS_F            PAF,
                   PAY_PAYROLLS_F               PPF 
             WHERE ASST.PERIOD_NAME = PP_PERIOD_NAME
               AND ASST.ELEMENT_NAME = PP_ELEMENT_NAME 
               AND ASST.ACCOUNTED_FLAG = 'UNACCOUNTED'
               AND ASST.MEMBER_ID = ASM.MEMBER_ID
               AND ASM.MEMBER_ID = ASMA.MEMBER_ID
               AND ASST.MEMBER_ACCOUNT_ID = ASMA.MEMBER_ACCOUNT_ID
               AND ASST.PERSON_ID = PAF.PERSON_ID
               AND ASST.EARNED_DATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
               AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
               AND ASST.EARNED_DATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
               AND SUBSTR(PPF.PAYROLL_NAME, 0, 2) = PP_COMPANY_CODE;
               
        CURSOR DETAILS_LOANS (PP_PERIOD_NAME   VARCHAR2, 
                              PP_ELEMENT_NAME  VARCHAR2, 
                              PP_COMPANY_CODE  VARCHAR2) IS
            SELECT ASLT.LOAN_TRANSACTION_ID,
                   ASMA.CODE_COMBINATION_ID,
                   ASMA.ACCOUNT_NUMBER,
                   ASLT.MEMBER_ID,
                   ASM.EMPLOYEE_FULL_NAME,
                   ASLT.PERSON_ID,
                   ASLT.PAYMENT_AMOUNT,
                   ASL.LOAN_NUMBER
              FROM ATET_SB_LOANS_TRANSACTIONS   ASLT,
                   ATET_SB_MEMBERS              ASM,
                   ATET_SB_MEMBERS_ACCOUNTS     ASMA,
                   ATET_SB_LOANS                ASL,
                   PER_ASSIGNMENTS_F            PAF,
                   PAY_PAYROLLS_F               PPF 
             WHERE ASLT.PERIOD_NAME = PP_PERIOD_NAME
               AND ASLT.ELEMENT_NAME = PP_ELEMENT_NAME 
               AND ASLT.ACCOUNTED_FLAG = 'UNACCOUNTED'
               AND ASLT.MEMBER_ID = ASM.MEMBER_ID
               AND ASM.MEMBER_ID = ASMA.MEMBER_ID
               AND ASLT.MEMBER_ACCOUNT_ID = ASMA.MEMBER_ACCOUNT_ID
               AND ASLT.MEMBER_ID = ASL.MEMBER_ID
               AND ASLT.LOAN_ID = ASL.LOAN_ID
               AND ASLT.PERSON_ID = PAF.PERSON_ID
               AND ASLT.EARNED_DATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
               AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
               AND ASLT.EARNED_DATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
               AND SUBSTR(PPF.PAYROLL_NAME, 0, 2) = PP_COMPANY_CODE;
               
        CURSOR DETAILS_INTERESTS (PP_PERIOD_NAME   VARCHAR2, 
                                  PP_ELEMENT_NAME  VARCHAR2, 
                                  PP_COMPANY_CODE  VARCHAR2) IS
            SELECT ASLT.LOAN_TRANSACTION_ID,
                   ASMA.CODE_COMBINATION_ID,
                   ASMA.ACCOUNT_NUMBER,
                   ASLT.MEMBER_ID,
                   ASM.EMPLOYEE_FULL_NAME,
                   ASLT.PERSON_ID,
                   ASLT.PAYMENT_INTEREST,
                   ASL.LOAN_NUMBER
              FROM ATET_SB_LOANS_TRANSACTIONS   ASLT,
                   ATET_SB_MEMBERS              ASM,
                   ATET_SB_MEMBERS_ACCOUNTS     ASMA,
                   ATET_SB_LOANS                ASL,
                   PER_ASSIGNMENTS_F            PAF,
                   PAY_PAYROLLS_F               PPF 
             WHERE ASLT.PERIOD_NAME = PP_PERIOD_NAME
               AND ASLT.ELEMENT_NAME = PP_ELEMENT_NAME
               AND ASLT.MEMBER_ID = ASM.MEMBER_ID
               AND ASM.MEMBER_ID = ASMA.MEMBER_ID
               AND ASLT.MEMBER_ACCOUNT_ID = ASMA.MEMBER_ACCOUNT_ID
               AND ASLT.MEMBER_ID = ASL.MEMBER_ID
               AND ASLT.LOAN_ID = ASL.LOAN_ID
               AND ASLT.PERSON_ID = PAF.PERSON_ID
               AND ASLT.EARNED_DATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
               AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
               AND ASLT.EARNED_DATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
               AND SUBSTR(PPF.PAYROLL_NAME, 0, 2) = PP_COMPANY_CODE;
               
        CURSOR DETAILS_INTERESTS_LATE (PP_PERIOD_NAME   VARCHAR2, 
                                       PP_ELEMENT_NAME  VARCHAR2, 
                                       PP_COMPANY_CODE  VARCHAR2) IS
            SELECT ASLT.LOAN_TRANSACTION_ID,
                   ASMA.CODE_COMBINATION_ID,
                   ASMA.ACCOUNT_NUMBER,
                   ASLT.MEMBER_ID,
                   ASM.EMPLOYEE_FULL_NAME,
                   ASLT.PERSON_ID,
                   ASLT.PAYMENT_INTEREST_LATE,
                   ASL.LOAN_NUMBER
              FROM ATET_SB_LOANS_TRANSACTIONS   ASLT,
                   ATET_SB_MEMBERS              ASM,
                   ATET_SB_MEMBERS_ACCOUNTS     ASMA,
                   ATET_SB_LOANS                ASL,
                   PER_ASSIGNMENTS_F            PAF,
                   PAY_PAYROLLS_F               PPF 
             WHERE ASLT.PERIOD_NAME = PP_PERIOD_NAME
               AND ASLT.ELEMENT_NAME = PP_ELEMENT_NAME
               AND ASLT.MEMBER_ID = ASM.MEMBER_ID
               AND ASM.MEMBER_ID = ASMA.MEMBER_ID
               AND ASLT.MEMBER_ACCOUNT_ID = ASMA.MEMBER_ACCOUNT_ID
               AND ASLT.MEMBER_ID = ASL.MEMBER_ID
               AND ASLT.LOAN_ID = ASL.LOAN_ID
               AND ASLT.PERSON_ID = PAF.PERSON_ID
               AND ASLT.EARNED_DATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
               AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
               AND ASLT.EARNED_DATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
               AND ASLT.PAYMENT_INTEREST_LATE <> 0
               AND SUBSTR(PPF.PAYROLL_NAME, 0, 2) = PP_COMPANY_CODE;
               
        var_saving_debit_amount         NUMBER;
        var_saving_credit_amount        NUMBER;
        
        var_loan_debit_amount           NUMBER;
        var_loan_credit_amount          NUMBER;
        
        var_deb_cs_code_comb            VARCHAR2(500);
        var_deb_pac_code_comb           VARCHAR2(500);
        var_not_rec_sav_code_comb       VARCHAR2(500);
        var_not_rec_no_sav_code_comb    VARCHAR2(500);
        var_une_int_code_comb           VARCHAR2(500);
        var_int_rec_code_comb           VARCHAR2(500);
        
        var_deb_cs_account_id           NUMBER;
        var_deb_pac_account_id          NUMBER;
        var_not_rec_sav_account_id      NUMBER;
        var_not_rec_no_sav_account_id   NUMBER;
        var_une_int_account_id          NUMBER;
        var_int_rec_account_id          NUMBER;
        
        var_header_id                   NUMBER;
        var_index                       NUMBER := 0;
        var_description                 VARCHAR2(500);
        
        var_user_id                     NUMBER := FND_GLOBAL.USER_ID;
        
    BEGIN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'SEND_TO_XLA(P_PERIOD_TYPE => ' || P_PERIOD_TYPE ||
                                                   ',P_YEAR => ' || P_YEAR ||
                                                   ',P_MONTH => ' || P_MONTH ||
                                                   ',P_PERIOD_NAME => ' || P_PERIOD_NAME ||
                                                   ',P_ELEMENT_NAME => ' || P_ELEMENT_NAME ||
                                                   ')');
    
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '***********     PARAMETERS     ***********');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_PERIOD_TYPE : ' || P_PERIOD_TYPE);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_YEAR : ' || P_YEAR);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_MONTH : ' || P_MONTH);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_PERIOD_NAME : ' || P_PERIOD_NAME);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_ELEMENT_NAME : ' || P_ELEMENT_NAME);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '******************************************');
        
        IF    P_ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME') THEN
            
            var_deb_cs_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'DEB_CS_CODE_COMB');
            var_deb_pac_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'DEB_PAC_CODE_COMB');
            var_deb_cs_account_id := GET_CODE_COMBINATION_ID(var_deb_cs_code_comb);
            var_deb_pac_account_id := GET_CODE_COMBINATION_ID(var_deb_pac_code_comb);
            
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_deb_cs_code_comb);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_deb_pac_code_comb);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_deb_cs_account_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_deb_pac_account_id);
            
            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (P_ENTITY_CODE        => 'PAYROLL',
                                                       P_EVENT_TYPE_CODE    => 'PAYROLL_SAVINGS',
                                                       P_BATCH_NAME         => 'APORTACIONES DE AHORRO',
                                                       P_JOURNAL_NAME       => UPPER(P_PERIOD_NAME || '-' || P_ELEMENT_NAME),
                                                       P_HEADER_ID          => var_header_id);

            FND_FILE.PUT_LINE(FND_FILE.LOG, 'HEADER_ID : ' || var_header_id);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('CUENTA', 35, ' ') || 
                                               RPAD('DESCRIPCION', 50, ' ') || 
                                               LPAD('CARGO', 30, ' ') || 
                                               LPAD('ABONO', 30, ' '));             
            
            FOR detail_company IN DETAILS_COMPANIES LOOP
            
                var_saving_debit_amount := 0;
                var_saving_credit_amount := 0;
                var_description := '';
                
                FOR detail_saving IN DETAILS_SAVINGS(P_PERIOD_NAME, 
                                                     P_ELEMENT_NAME, 
                                                     detail_company.COMPANY_CODE) LOOP
                    var_saving_debit_amount := var_saving_debit_amount + detail_saving.ENTRY_VALUE;
                END LOOP;
                
                /*****************************************************/
                /*          CARGO   :   DEUDORES DIVERSOS            */
                /*****************************************************/
                IF detail_company.COMPANY_CODE = '02' AND var_saving_debit_amount > 0 THEN
                
                    var_index := var_index + 1;
                
                    var_description := UPPER('Aportaciones de ahorro (El Calvario Servicios)');
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_deb_cs_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_SAVINGS',
                                                             P_ACCOUNTED_DR            => var_saving_debit_amount,
                                                             P_ACCOUNTED_CR            => var_saving_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => -1,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_deb_cs_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_saving_debit_amount, 30, ' ') || 
                                                       LPAD(var_saving_credit_amount, 30, ' '));
                    
                ELSIF detail_company.COMPANY_CODE = '11' AND var_saving_debit_amount > 0 THEN
                
                    var_index := var_index + 1;
                
                    var_description := UPPER('Aportaciones de ahorro (Productos Avicolas El Calvario)');
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_deb_pac_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_SAVINGS',
                                                             P_ACCOUNTED_DR            => var_saving_debit_amount,
                                                             P_ACCOUNTED_CR            => var_saving_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => -1,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_deb_pac_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_saving_debit_amount, 30, ' ') || 
                                                       LPAD(var_saving_credit_amount, 30, ' '));                                         
                                                                                 
                END IF;
                
                /*****************************************************/
                /*          ABONO   :   APORTACIONES POR PAGAR       */
                /*****************************************************/
                FOR detail_saving IN DETAILS_SAVINGS(P_PERIOD_NAME, 
                                                     P_ELEMENT_NAME, 
                                                     detail_company.COMPANY_CODE) LOOP
                    var_saving_debit_amount := 0;                                                     
                    var_saving_credit_amount := 0;
                    var_index := var_index + 1;
                    var_description := '';
                                                     
                    var_saving_credit_amount := detail_saving.CREDIT_AMOUNT;
                    var_description := detail_saving.EMPLOYEE_FULL_NAME || '|' || var_saving_credit_amount;
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => detail_saving.CODE_COMBINATION_ID,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_SAVINGS',
                                                             P_ACCOUNTED_DR            => var_saving_debit_amount,
                                                             P_ACCOUNTED_CR            => var_saving_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => detail_saving.SAVING_TRANSACTION_ID,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(detail_saving.ACCOUNT_NUMBER, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_saving_debit_amount, 30, ' ') || 
                                                       LPAD(var_saving_credit_amount, 30, ' '));
                    
                    UPDATE ATET_SB_SAVINGS_TRANSACTIONS ASST
                       SET ASST.ACCOUNTED_FLAG = 'ACCOUNTED',
                           ASST.LAST_UPDATE_DATE = SYSDATE,
                           ASST.LAST_UPDATED_BY = var_user_id
                     WHERE 1 = 1 
                       AND ASST.SAVING_TRANSACTION_ID = detail_saving.SAVING_TRANSACTION_ID;
                    
                END LOOP;
            
            END LOOP;
            
        ELSIF P_ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME') THEN
            
            var_deb_cs_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'DEB_CS_CODE_COMB');
            var_deb_pac_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'DEB_PAC_CODE_COMB');
            var_not_rec_sav_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'NOT_REC_SAV_CODE_COMB');
            var_not_rec_no_sav_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'NOT_REC_NO_SAV_CODE_COMB');
            var_une_int_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'UNE_INT_CODE_COMB');
            var_int_rec_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'INT_REC_CODE_COMB');
            
            var_deb_cs_account_id := GET_CODE_COMBINATION_ID(var_deb_cs_code_comb);
            var_deb_pac_account_id := GET_CODE_COMBINATION_ID(var_deb_pac_code_comb);
            var_not_rec_sav_account_id := GET_CODE_COMBINATION_ID(var_not_rec_sav_code_comb);
            var_not_rec_no_sav_account_id := GET_CODE_COMBINATION_ID(var_not_rec_no_sav_code_comb);
            var_une_int_account_id := GET_CODE_COMBINATION_ID(var_une_int_code_comb);
            var_int_rec_account_id := GET_CODE_COMBINATION_ID(var_int_rec_code_comb);  
            
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_deb_cs_code_comb);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_deb_pac_code_comb);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_not_rec_sav_code_comb);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_not_rec_no_sav_code_comb);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_une_int_code_comb);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_int_rec_code_comb);
            
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_deb_cs_account_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_deb_pac_account_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_not_rec_sav_account_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_not_rec_no_sav_account_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_une_int_account_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_int_rec_account_id);
            
            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (P_ENTITY_CODE        => 'PAYROLL',
                                                       P_EVENT_TYPE_CODE    => 'PAYROLL_LOANS',
                                                       P_BATCH_NAME         => 'PAGO DE PRESTAMOS',
                                                       P_JOURNAL_NAME       => UPPER(P_PERIOD_NAME || '-' || P_ELEMENT_NAME),
                                                       P_HEADER_ID          => var_header_id);

            FND_FILE.PUT_LINE(FND_FILE.LOG, 'HEADER_ID : ' || var_header_id);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('CUENTA', 35, ' ') || 
                                               RPAD('DESCRIPCION', 50, ' ') || 
                                               LPAD('CARGO', 30, ' ') || 
                                               LPAD('ABONO', 30, ' '));
            
            FOR detail_company IN DETAILS_COMPANIES LOOP
            
                var_loan_debit_amount := 0;
                var_loan_credit_amount := 0;
                var_description := '';
                
                FOR detail_loan IN DETAILS_LOANS(P_PERIOD_NAME, 
                                                 P_ELEMENT_NAME, 
                                                 detail_company.COMPANY_CODE) LOOP
                    var_loan_debit_amount := var_loan_debit_amount + detail_loan.PAYMENT_AMOUNT;
                END LOOP;
                
                /*****************************************************/
                /*          CARGO   :   DEUDORES DIVERSOS            */
                /*****************************************************/
                IF detail_company.COMPANY_CODE = '02' AND var_loan_debit_amount > 0 THEN
                
                    var_index := var_index + 1;
                
                    var_description := UPPER('Pago de prestamo de caja ahorro (El Calvario Servicios)');
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_deb_cs_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_LOANS',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => -1,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_deb_cs_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));
                    
                ELSIF detail_company.COMPANY_CODE = '11' AND var_loan_debit_amount > 0 THEN
                
                    var_index := var_index + 1;
                
                    var_description := UPPER('Pago de prestamo de caja ahorro (Productos Avicolas El Calvario)');
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_deb_pac_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_LOANS',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => -1,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_deb_pac_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));                                         
                                                                                 
                END IF;
                
                /*****************************************************/
                /*          ABONO   :   DOCUMENTOS POR COBRAR        */
                /*****************************************************/
                FOR detail_loan IN DETAILS_LOANS(P_PERIOD_NAME, 
                                                 P_ELEMENT_NAME, 
                                                 detail_company.COMPANY_CODE) LOOP
                    var_loan_debit_amount := 0;
                    var_loan_credit_amount := 0;
                    var_index := var_index + 1;
                    var_description := '';
                                                     
                    var_loan_credit_amount := detail_loan.PAYMENT_AMOUNT;
                    var_description := detail_loan.EMPLOYEE_FULL_NAME || '|' || detail_loan.LOAN_NUMBER || '|' || var_loan_credit_amount;
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => detail_loan.CODE_COMBINATION_ID,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_LOANS',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => detail_loan.LOAN_TRANSACTION_ID,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(detail_loan.ACCOUNT_NUMBER, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));
                    
                    UPDATE ATET_SB_LOANS_TRANSACTIONS ASLT
                       SET ASLT.ACCOUNTED_FLAG = 'ACCOUNTED',
                           ASLT.LAST_UPDATE_DATE = SYSDATE,
                           ASLT.LAST_UPDATED_BY = var_user_id
                     WHERE 1 = 1 
                       AND ASLT.LOAN_TRANSACTION_ID = detail_loan.LOAN_TRANSACTION_ID;
                                                                     
                END LOOP;       
                
                /*****************************************************/
                /*          CARGO   :   INTERESES POR DEVENGAR       */
                /*****************************************************/
                FOR detail_interest IN DETAILS_INTERESTS(P_PERIOD_NAME, 
                                                         P_ELEMENT_NAME, 
                                                         detail_company.COMPANY_CODE) LOOP
                    
                    var_loan_debit_amount := 0;
                    var_loan_credit_amount := 0;
                    var_index := var_index + 1;
                    var_description := '';
                                                     
                    var_loan_debit_amount := detail_interest.PAYMENT_INTEREST;
                    var_description := detail_interest.EMPLOYEE_FULL_NAME || '|' || detail_interest.LOAN_NUMBER || '|' || var_loan_debit_amount;
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_une_int_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => detail_interest.LOAN_TRANSACTION_ID,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_une_int_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));
                    
                    
                    UPDATE ATET_SB_LOANS_TRANSACTIONS ASLT
                       SET ASLT.ACCOUNTED_FLAG = 'ACCOUNTED',
                           ASLT.LAST_UPDATE_DATE = SYSDATE,
                           ASLT.LAST_UPDATED_BY = var_user_id
                     WHERE 1 = 1 
                       AND ASLT.LOAN_TRANSACTION_ID = detail_interest.LOAN_TRANSACTION_ID;
                                                                     
                END LOOP;  
                
                var_loan_debit_amount := 0;
                var_loan_credit_amount := 0;
                var_description := '';
                
                FOR detail_interest IN DETAILS_INTERESTS(P_PERIOD_NAME, 
                                                         P_ELEMENT_NAME, 
                                                         detail_company.COMPANY_CODE) LOOP
                    var_loan_credit_amount := var_loan_credit_amount + detail_interest.PAYMENT_INTEREST;
                END LOOP;      
                
                /*****************************************************/
                /*          ABONO   :   INTERESES COBRADOS           */
                /*****************************************************/
                IF detail_company.COMPANY_CODE = '02' AND var_loan_credit_amount > 0 THEN
                
                    var_index := var_index + 1;
                
                    var_description := UPPER('Intereses Cobrados (El Calvario Servicios)');
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_int_rec_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => -1,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_int_rec_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));
                    
                ELSIF detail_company.COMPANY_CODE = '11' AND var_loan_credit_amount > 0 THEN
                
                    var_index := var_index + 1;
                
                    var_description := UPPER('Intereses Cobrados (Productos Avicolas El Calvario)');
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_int_rec_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => -1,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_int_rec_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));                                         
                                                                                 
                END IF;
                
                var_loan_debit_amount := 0;
                var_loan_credit_amount := 0;
                var_description := '';
                
                FOR detail_interest_late IN DETAILS_INTERESTS_LATE(P_PERIOD_NAME, 
                                                                   P_ELEMENT_NAME, 
                                                                   detail_company.COMPANY_CODE) LOOP
                    var_loan_debit_amount := var_loan_debit_amount + detail_interest_late.PAYMENT_INTEREST_LATE;
                END LOOP;
                
                /*****************************************************/
                /*          CARGO   :   DEUDORES DIVERSOS            */
                /*****************************************************/
                IF detail_company.COMPANY_CODE = '02' AND var_loan_debit_amount > 0 THEN
                
                    var_index := var_index + 1;
                
                    var_description := UPPER('Intereses Moratorios Cobrados (El Calvario Servicios)');
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_deb_cs_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST_LATE',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => -1,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_deb_cs_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));
                    
                ELSIF detail_company.COMPANY_CODE = '11' AND var_loan_debit_amount > 0 THEN
                
                    var_index := var_index + 1;
                
                    var_description := UPPER('Intereses Moratorios Cobrados (Productos Avicolas El Calvario)');
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_deb_pac_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST_LATE',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => -1,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_deb_pac_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));                                         
                                                                                 
                END IF;
                
                /*****************************************************/
                /*          CARGO   :   INTERESES POR DEVENGAR       */
                /*****************************************************/
                FOR detail_interest_late IN DETAILS_INTERESTS_LATE(P_PERIOD_NAME, 
                                                                   P_ELEMENT_NAME, 
                                                                   detail_company.COMPANY_CODE) LOOP
                    var_loan_debit_amount := 0;
                    var_loan_credit_amount := 0;
                    var_index := var_index + 1;
                    var_description := '';
                                                     
                    var_loan_credit_amount := detail_interest_late.PAYMENT_INTEREST_LATE;
                    var_description := detail_interest_late.EMPLOYEE_FULL_NAME || '|' || detail_interest_late.LOAN_NUMBER || '|' || var_loan_credit_amount;
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_int_rec_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST_LATE',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => detail_interest_late.LOAN_TRANSACTION_ID,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_int_rec_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));
                    
                    
                    UPDATE ATET_SB_LOANS_TRANSACTIONS ASLT
                       SET ASLT.ACCOUNTED_FLAG = 'ACCOUNTED',
                           ASLT.LAST_UPDATE_DATE = SYSDATE,
                           ASLT.LAST_UPDATED_BY = var_user_id
                     WHERE 1 = 1 
                       AND ASLT.LOAN_TRANSACTION_ID = detail_interest_late.LOAN_TRANSACTION_ID;
                                                                     
                END LOOP;  
            
            END LOOP;                        
        
        END IF;
        
        
        COMMIT;
        ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL;
        
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en SEND_TO_XLA ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END SEND_TO_XLA;
    
    
    FUNCTION    HAS_DISABILITIES(
                    P_PERSON_ID        NUMBER,
                    P_TIME_PERIOD_ID   NUMBER)
      RETURN    VARCHAR2
    IS
        var_result  VARCHAR2(100);
        var_count   NUMBER;
    BEGIN
    
                SELECT DISTINCT
                       COUNT(PDF.DISABILITY_ID)
                  INTO var_count
                  FROM  PAY_ALL_PAYROLLS_F          PAP,
                        PER_PERSON_TYPE_USAGES_F    PPTU,
                        PER_PERIODS_OF_SERVICE      PPOS,
                        PER_ALL_ASSIGNMENTS_F       PAA,   
                        PER_PEOPLE_F                PPF,      
                        PER_ALL_PEOPLE_F            PAPF,
                        PER_DISABILITIES_F          PDF,
                        PER_TIME_PERIODS            PTP  
                 WHERE 1 = 1
                   AND PPF.PERSON_ID = PPTU.PERSON_ID
                   AND PPF.PERSON_ID = PPOS.PERSON_ID
                   AND PAA.PAYROLL_ID = PAP.PAYROLL_ID
                   AND PAA.PERSON_ID = PPF.PERSON_ID
                   AND PAPF.PERSON_ID = PPF.PERSON_ID
                   AND (PPF.EFFECTIVE_START_DATE = PAPF.EFFECTIVE_START_DATE
                    AND PPF.EFFECTIVE_START_DATE = PPTU.EFFECTIVE_START_DATE
                    AND PPF.EFFECTIVE_START_DATE = PPOS.DATE_START) 
                   AND PAA.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID
                   AND PPF.REGISTERED_DISABLED_FLAG IS NULL
                   AND PDF.PERSON_ID = PPF.PERSON_ID
                   AND PDF.PERSON_ID = P_PERSON_ID
                   AND PAP.PAYROLL_ID = PTP.PAYROLL_ID
                   AND PTP.TIME_PERIOD_ID = P_TIME_PERIOD_ID
                   AND (   PTP.START_DATE BETWEEN PDF.REGISTRATION_DATE AND PDF.REGISTRATION_EXP_DATE
                        OR PTP.END_DATE BETWEEN PDF.REGISTRATION_DATE AND PDF.REGISTRATION_EXP_DATE)    
                   AND (PDF.CATEGORY = 'RT'
                     OR PDF.CATEGORY = 'GRAL'
                     OR PDF.CATEGORY = 'MAT')
                 GROUP BY PPF.PERSON_ID,
                           PAPF.EMPLOYEE_NUMBER,       
                           PAPF.FULL_NAME,
                           PDF.DISABILITY_ID,
                           PDF.REGISTRATION_DATE, 
                           PDF.REGISTRATION_EXP_DATE;
                           
        IF var_count > 0 THEN
            var_result := 'DISABILITIES';
        ELSE
            var_result := '';
        END IF;
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'HAS_DISABILITIES(P_PERSON_ID => ' || P_PERSON_ID || 
                                                        ',P_TIME_PERIOD_ID => ' || P_TIME_PERIOD_ID || 
                                                        ') RETURN ' || var_result);
    
        RETURN var_result;
    END HAS_DISABILITIES;
    
    
    PROCEDURE   EXTEND_PAYMENTS_SCHEDULE(
                    P_LOAN_ID                  NUMBER,
                    P_PERSON_ID                NUMBER,
                    P_MEMBER_ID                NUMBER,
                    P_TIME_PERIOD_ID           NUMBER,
                    P_ACTUAL_DATE_EARNED       DATE,
                    P_PAYMENT_CAPITAL          NUMBER,
                    P_PAYMENT_INTEREST         NUMBER,
                    P_PAYMENT_INTEREST_LATE    NUMBER)
    IS
    
        CURSOR  DETAILS(PP_TIME_PERIOD_ID       NUMBER,
                        PP_ACTUAL_DATE_EARNED   DATE,
                        PP_TERM_PERIODS         NUMBER
                        ) IS
            SELECT PAYROLL_ID,
                   TIME_PERIOD_ID,
                   END_DATE,
                   PERIOD_NAME,
                   PERIOD_NUM,
                   PERIOD_SEQUENCE
              FROM (SELECT PTP.PAYROLL_ID,
                           PTP.TIME_PERIOD_ID,
                           PTP.END_DATE,
                           PTP.PERIOD_NAME,
                           PTP.PERIOD_NUM,
                           ROW_NUMBER () OVER (PARTITION BY PTP.PAYROLL_ID ORDER BY PTP.END_DATE)
                           PERIOD_SEQUENCE
                      FROM PER_TIME_PERIODS  PTP,   
                           PER_TIME_PERIODS  PTP_PPF
                     WHERE PTP.PAYROLL_ID = PTP_PPF.PAYROLL_ID
                       AND PTP_PPF.TIME_PERIOD_ID = PP_TIME_PERIOD_ID
                       AND (    PTP.END_DATE > TO_DATE(PP_ACTUAL_DATE_EARNED)
                            AND PTP.END_DATE > TO_DATE (PP_ACTUAL_DATE_EARNED))
                     ORDER BY PTP.END_DATE)
             WHERE 1 = 1
               AND PERIOD_SEQUENCE <= PP_TERM_PERIODS
             ORDER BY PERIOD_SEQUENCE;
             
        var_term_periods                    NUMBER;
        var_assignment_id                   NUMBER;
        var_member_period_type              VARCHAR2(100);
        
        var_sum_payment_capital             NUMBER;
        var_sum_payment_interest            NUMBER;
        var_sum_payment_interest_late       NUMBER;
        
        var_opening_balance                 NUMBER;
        var_payment_amount                  NUMBER;
        var_payment_capital                 NUMBER;
        var_payment_interest                NUMBER;
        var_payment_interest_late           NUMBER;
        var_final_balance                   NUMBER;
        var_accrual_payment_amount          NUMBER;
        var_user_id                         NUMBER := FND_GLOBAL.USER_ID;
    
    BEGIN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'EXTEND_PAYMENTS_SCHEDULE(P_LOAN_ID => ' || P_LOAN_ID ||
                                                                ',P_PERSON_ID => ' || P_PERSON_ID ||
                                                                ',P_MEMBER_ID => ' || P_MEMBER_ID ||
                                                                ',P_TIME_PERIOD_ID => ' || P_TIME_PERIOD_ID ||
                                                                ',P_ACTUAL_DATE_EARNED => ' || P_ACTUAL_DATE_EARNED ||
                                                                ',P_PAYMENT_CAPITAL => ' || P_PAYMENT_CAPITAL ||
                                                                ',P_PAYMENT_INTEREST => ' || P_PAYMENT_INTEREST ||
                                                                ',P_PAYMENT_INTEREST_LATE => ' || P_PAYMENT_INTEREST_LATE || 
                                                                ')');
                                                                
        SELECT PAF.ASSIGNMENT_ID,
               PPF.PERIOD_TYPE
          INTO var_assignment_id,
               var_member_period_type
          FROM PER_ASSIGNMENTS_F    PAF,
               PAY_PAYROLLS_F       PPF
         WHERE 1 = 1
           AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
           AND PAF.PERSON_ID = P_PERSON_ID
           AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE;
           
           
        IF    var_member_period_type IN ('Week', 'Semana') THEN
            var_term_periods := 4;
            var_payment_capital := TRUNC((P_PAYMENT_CAPITAL / 4), 2);
            var_payment_interest := TRUNC((P_PAYMENT_INTEREST / 4), 2);
            var_payment_interest_late := TRUNC((P_PAYMENT_INTEREST_LATE / 4), 2);
        ELSIF var_member_period_type IN ('Semi-Month', 'Quincena') THEN
            var_term_periods := 2;
            var_payment_capital := TRUNC((P_PAYMENT_CAPITAL / 2), 2);
            var_payment_interest := TRUNC((P_PAYMENT_INTEREST / 2), 2);
            var_payment_interest_late := TRUNC((P_PAYMENT_INTEREST_LATE / 2), 2);
        END IF;
        
        var_sum_payment_capital := 0;
        var_sum_payment_interest := 0;
        var_sum_payment_interest_late := 0;
        var_payment_amount := 0;
        var_accrual_payment_amount := 0;
        var_final_balance := 0;
        var_opening_balance := 0;
        
        FOR detail IN DETAILS(P_TIME_PERIOD_ID, P_ACTUAL_DATE_EARNED, var_term_periods) LOOP
            
            IF detail.PERIOD_SEQUENCE = var_term_periods THEN
                var_payment_capital := P_PAYMENT_CAPITAL - var_sum_payment_capital; 
                var_payment_interest := P_PAYMENT_INTEREST - var_sum_payment_interest;
                var_payment_interest_late := P_PAYMENT_INTEREST_LATE - var_sum_payment_interest_late; 
            END IF;
            
            var_sum_payment_capital := var_sum_payment_capital + var_payment_capital;
            var_sum_payment_interest := var_sum_payment_interest + var_payment_interest;
            var_sum_payment_interest_late := var_sum_payment_interest_late + var_payment_interest_late;
            var_payment_amount := var_payment_capital + var_payment_interest + var_payment_interest_late;
            var_accrual_payment_amount := var_accrual_payment_amount + var_payment_amount;    
            var_final_balance := (P_PAYMENT_CAPITAL + P_PAYMENT_INTEREST + P_PAYMENT_INTEREST_LATE) - var_accrual_payment_amount;
            var_opening_balance := var_final_balance + var_payment_amount;
            
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT ATET_SB_PAYMENTS_SCHEDULE(LOAN_ID => ' || P_LOAN_ID ||
                                                                           ', PAYMENT_NUMBER => ' || detail.PERIOD_SEQUENCE || 
                                                                           ', PERIOD_NUMBER => ' || detail.PERIOD_NUM ||
                                                                           ', TIME_PERIOD_ID => ' || detail.TIME_PERIOD_ID ||
                                                                           ', PERIOD_NAME => ' || detail.PERIOD_NAME || 
                                                                           ', PAYMENT_DATE => ' || detail.END_DATE ||
                                                                           ', PAYROLL_ID => ' || detail.PAYROLL_ID ||
                                                                           ', ASSIGNMENT_ID => ' || var_assignment_id ||
                                                                           ', OPENING_BALANCE => ' || var_opening_balance ||
                                                                           ', PAYMENT_AMOUNT => ' || var_payment_amount ||
                                                                           ', PAYMENT_CAPITAL => ' || var_payment_capital || 
                                                                           ', PAYMENT_INTEREST => ' || var_payment_interest ||
                                                                           ', PAYMENT_INTEREST_LATE => ' || var_payment_interest_late ||
                                                                           ', FINAL_BALANCE => ' || var_final_balance ||
                                                                           ', ACCRUAL_PAYMENT_AMOUNT => ' || var_accrual_payment_amount ||
                                                                           ')');
            
            INSERT 
              INTO ATET_SB_PAYMENTS_SCHEDULE(LOAN_ID,
                                             PAYMENT_NUMBER,
                                             PERIOD_NUMBER,
                                             TIME_PERIOD_ID,
                                             PERIOD_NAME,
                                             PAYMENT_DATE,
                                             PAYROLL_ID,
                                             ASSIGNMENT_ID,
                                             OPENING_BALANCE,
                                             PAYMENT_AMOUNT,
                                             PAYMENT_CAPITAL,
                                             PAYMENT_INTEREST,
                                             PAYMENT_INTEREST_LATE,
                                             FINAL_BALANCE,
                                             ACCRUAL_PAYMENT_AMOUNT,
                                             STATUS_FLAG,
                                             CREATION_DATE,
                                             CREATED_BY,
                                             LAST_UPDATE_DATE,
                                             LAST_UPDATED_BY)
                                     VALUES (P_LOAN_ID,
                                             detail.PERIOD_SEQUENCE,
                                             detail.PERIOD_NUM,
                                             detail.TIME_PERIOD_ID,
                                             detail.PERIOD_NAME,
                                             detail.END_DATE,
                                             detail.PAYROLL_ID,
                                             var_assignment_id,
                                             var_opening_balance,
                                             var_payment_amount,
                                             var_payment_capital,
                                             var_payment_interest,
                                             var_payment_interest_late,
                                             var_final_balance,
                                             var_accrual_payment_amount,
                                             'PENDING',
                                             SYSDATE,
                                             var_user_id,
                                             SYSDATE,
                                             var_user_id);
                                                                             
            
            IF detail.PERIOD_SEQUENCE = var_term_periods THEN
                EXIT;
            END IF;
        
        END LOOP;
        
        UPDATE ATET_SB_PAYMENTS_SCHEDULE    ASPS
           SET ASPS.STATUS_FLAG = 'REFINANCED',
               ASPS.LAST_UPDATE_DATE = SYSDATE,
               ASPS.LAST_UPDATED_BY = var_user_id
         WHERE 1 = 1
           AND ASPS.LOAN_ID = P_LOAN_ID
           AND ASPS.STATUS_FLAG IN ('SKIP', 'PARTIAL');
        
         MERGE 
          INTO ATET_SB_PAYMENTS_SCHEDULE    ASPS
         USING (SELECT DISTINCT ASL.LOAN_ID
                  FROM ATET_SB_MEMBERS              ASM,
                       ATET_SB_LOANS                ASL,
                       PER_ALL_PEOPLE_F             PAPF,
                       PER_PERSON_TYPES             PPT,
                       ATET_SB_PAYMENTS_SCHEDULE    ASPS
                 WHERE 1 = 1
                   AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID
                   AND ASM.MEMBER_ID = ASL.MEMBER_ID
                   AND PAPF.PERSON_ID = ASM.PERSON_ID
                   AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE
                                   AND PAPF.EFFECTIVE_END_DATE
                   AND PPT.PERSON_TYPE_ID = PAPF.PERSON_TYPE_ID
                   AND PPT.USER_PERSON_TYPE IN ('Ex-empleado', 'Ex-employee')
                   AND ASL.LOAN_STATUS_FLAG IN ('ACTIVE')
                   AND ASL.LOAN_ID = ASPS.LOAN_ID
                   AND ASPS.STATUS_FLAG IN ('SKIP', 'PARTIAL', 'PENDING')
                   AND (   ASPS.PAYMENT_INTEREST_LATE > 0
                        OR ASPS.PAYED_INTEREST_LATE > 0
                        OR ASPS.OWED_INTEREST_LATE > 0) 
                   AND ASM.PERSON_ID = P_PERSON_ID
                   AND ASL.LOAN_ID = P_LOAN_ID ) D 
            ON (    ASPS.LOAN_ID = D.LOAN_ID
                AND ASPS.STATUS_FLAG IN ('SKIP', 'PARTIAL', 'PENDING')
                AND (   ASPS.PAYMENT_INTEREST_LATE > 0
                     OR ASPS.PAYED_INTEREST_LATE > 0
                     OR ASPS.OWED_INTEREST_LATE > 0))
          WHEN MATCHED THEN
        UPDATE 
           SET ASPS.PAYMENT_INTEREST_LATE = 0;
         
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en EXTEND_PAYMENTS_SCHEDULE ' || SQLCODE || ' -ERROR- ' || SQLERRM);    
    END EXTEND_PAYMENTS_SCHEDULE;
    
    
    PROCEDURE   SETTLEMENT_LOAN(
                    P_LOAN_ID           NUMBER)
    IS
        var_loan_id             NUMBER;
        var_member_id           NUMBER;
        var_member_account_id   NUMBER;
        var_person_id           NUMBER;
        var_loan_balance        NUMBER;
        var_user_id             NUMBER := FND_GLOBAL.USER_ID;
        var_validate            NUMBER;
    BEGIN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'SETTLEMENT_LOAN(P_LOAN_ID => ' || P_LOAN_ID || ')');
        
        SELECT ASL.LOAN_ID,
               ASL.MEMBER_ID,
               ASM.PERSON_ID,
               ASL.LOAN_BALANCE
          INTO var_loan_id,
               var_member_id,
               var_person_id,
               var_loan_balance
          FROM ATET_SB_LOANS    ASL,
               ATET_SB_MEMBERS  ASM
         WHERE 1 = 1
           AND ASL.LOAN_ID = P_LOAN_ID
           AND ASL.MEMBER_ID = ASM.MEMBER_ID;
        
        var_member_account_id := GET_LOAN_MEMBER_ACCOUNT_ID(var_member_id, var_loan_id);
                                                            
                                                            
        UPDATE ATET_SB_PAYMENTS_SCHEDULE    ASPS
           SET ASPS.STATUS_FLAG = 'PAYED',
               ASPS.ATTRIBUTE6 = 'REFINANCED',
               ASPS.LAST_UPDATE_DATE = SYSDATE,
               ASPS.LAST_UPDATED_BY = var_user_id
         WHERE 1 = 1
           AND ASPS.LOAN_ID = var_loan_id
           AND ASPS.STATUS_FLAG IN ('PARTIAL', 'SKIP', 'PENDING', 'EXPORTED');
           
        
    
        INSERT INTO ATET_SB_LOANS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                MEMBER_ID,
                                                PAYROLL_RESULT_ID,
                                                LOAN_ID,
                                                PERSON_ID,
                                                EARNED_DATE,
                                                PERIOD_NAME,
                                                ELEMENT_NAME,
                                                TRANSACTION_CODE,
                                                DEBIT_AMOUNT,
                                                CREDIT_AMOUNT,
                                                ACCOUNTED_FLAG,
                                                CREATION_DATE,
                                                CREATED_BY,
                                                LAST_UPDATE_DATE,
                                                LAST_UPDATED_BY)
                                         VALUES (var_member_account_id,
                                                 var_member_id,
                                                 -1,
                                                 var_loan_id,
                                                 var_person_id,
                                                 TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                                                 'LIQUIDACION',
                                                 'LIQUIDACION DE PRESTAMO',
                                                 'SETTLEMENT_LOAN',
                                                 0,
                                                 var_loan_balance,
                                                 'ACCOUNTED',
                                                 SYSDATE,
                                                 var_user_id,
                                                 SYSDATE,
                                                 var_user_id);
                                                  
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET DEBIT_BALANCE = DEBIT_BALANCE + 0,
               CREDIT_BALANCE = CREDIT_BALANCE + var_loan_balance,
               LAST_TRANSACTION_DATE = SYSDATE               
         WHERE MEMBER_ID = var_member_id
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET FINAL_BALANCE = DEBIT_BALANCE - CREDIT_BALANCE,
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = var_user_id             
         WHERE MEMBER_ID = var_member_id
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
        UPDATE ATET_SB_LOANS ASL
           SET ASL.LOAN_BALANCE = ASL.LOAN_BALANCE - var_loan_balance,
               ASL.LAST_PAYMENT_DATE = TO_DATE(SYSDATE, 'DD/MM/RRRR'),
               ASL.LOAN_STATUS_FLAG = 'PAYED',
               ASL.LAST_UPDATE_DATE = SYSDATE,
               ASL.LAST_UPDATED_BY = var_user_id
         WHERE 1 = 1
           AND ASL.LOAN_ID = var_loan_id;

                               
                   
        BEGIN             
            MERGE INTO ATET_SB_MEMBERS      ASM
                 USING ATET_SB_ENDORSEMENTS ASE
                    ON (    ASE.LOAN_ID = var_loan_id
                        AND ASE.MEMBER_ENDORSEMENT_ID = ASM.MEMBER_ID)
            WHEN MATCHED THEN 
            UPDATE SET ASM.IS_ENDORSEMENT = 'N',
                       ASM.LAST_UPDATE_DATE = SYSDATE,
                       ASM.LAST_UPDATED_BY = var_user_id;
        EXCEPTION 
             WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'MERGE AVALES: ' || SQLERRM);
                RAISE;
        END;     
               
    END SETTLEMENT_LOAN;
    
    
    PROCEDURE   CANCELLED_LOAN(
                    P_LOAN_ID                   NUMBER)
    IS
        var_loan_id             NUMBER;
        var_member_id           NUMBER;
        var_member_account_id   NUMBER;
        var_person_id           NUMBER;
        var_loan_balance        NUMBER;
        var_user_id             NUMBER := FND_GLOBAL.USER_ID;
        var_validate            NUMBER;
    BEGIN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'CANCEL_LOAN(P_LOAN_ID => ' || P_LOAN_ID || ')');
        
        SELECT ASL.LOAN_ID,
               ASL.MEMBER_ID,
               ASM.PERSON_ID,
               ASL.LOAN_BALANCE
          INTO var_loan_id,
               var_member_id,
               var_person_id,
               var_loan_balance
          FROM ATET_SB_LOANS    ASL,
               ATET_SB_MEMBERS  ASM
         WHERE 1 = 1
           AND ASL.LOAN_ID = P_LOAN_ID
           AND ASL.MEMBER_ID = ASM.MEMBER_ID;
        
        var_member_account_id := GET_LOAN_MEMBER_ACCOUNT_ID(var_member_id, var_loan_id);
                                                            
                                                            
        UPDATE ATET_SB_PAYMENTS_SCHEDULE    ASPS
           SET ASPS.STATUS_FLAG = 'CANCELLED',
               ASPS.LAST_UPDATE_DATE = SYSDATE,
               ASPS.LAST_UPDATED_BY = var_user_id
         WHERE 1 = 1
           AND ASPS.LOAN_ID = var_loan_id;
           
        
    
        INSERT INTO ATET_SB_LOANS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                MEMBER_ID,
                                                PAYROLL_RESULT_ID,
                                                LOAN_ID,
                                                PERSON_ID,
                                                EARNED_DATE,
                                                PERIOD_NAME,
                                                ELEMENT_NAME,
                                                TRANSACTION_CODE,
                                                DEBIT_AMOUNT,
                                                CREDIT_AMOUNT,
                                                CREATION_DATE,
                                                CREATED_BY,
                                                LAST_UPDATE_DATE,
                                                LAST_UPDATED_BY)
                                         VALUES (var_member_account_id,
                                                 var_member_id,
                                                 -1,
                                                 var_loan_id,
                                                 var_person_id,
                                                 TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                                                 'CANCELACION',
                                                 'CANCELACION DE PRESTAMO',
                                                 'CANCELLED_LOAN',
                                                 0,
                                                 var_loan_balance,
                                                 SYSDATE,
                                                 var_user_id,
                                                 SYSDATE,
                                                 var_user_id);
                                                  
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET DEBIT_BALANCE = DEBIT_BALANCE + 0,
               CREDIT_BALANCE = CREDIT_BALANCE + var_loan_balance,
               LAST_TRANSACTION_DATE = SYSDATE               
         WHERE MEMBER_ID = var_member_id
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET FINAL_BALANCE = DEBIT_BALANCE - CREDIT_BALANCE,
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = var_user_id             
         WHERE MEMBER_ID = var_member_id
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
        UPDATE ATET_SB_LOANS ASL
           SET ASL.LOAN_BALANCE = ASL.LOAN_BALANCE - var_loan_balance,
               ASL.LAST_PAYMENT_DATE = TO_DATE(SYSDATE, 'DD/MM/RRRR'),
               ASL.LOAN_STATUS_FLAG = 'CANCELLED',
               ASL.LAST_UPDATE_DATE = SYSDATE,
               ASL.LAST_UPDATED_BY = var_user_id
         WHERE 1 = 1
           AND ASL.LOAN_ID = var_loan_id;

             
        MERGE INTO ATET_SB_MEMBERS      ASM
             USING ATET_SB_ENDORSEMENTS ASE
                ON (    ASE.LOAN_ID = var_loan_id
                    AND ASE.MEMBER_ENDORSEMENT_ID = ASM.MEMBER_ID)
        WHEN MATCHED THEN 
        UPDATE SET ASM.IS_ENDORSEMENT = 'N',
                   ASM.LAST_UPDATE_DATE = SYSDATE,
                   ASM.LAST_UPDATED_BY = var_user_id;      
               
    END CANCELLED_LOAN;
    
    
    PROCEDURE   SETTLEMENT_LOAN(
                    P_LOAN_ID               NUMBER,
                    P_MEMBER_ID             NUMBER,
                    P_PREPAID_SEQ           NUMBER,
                    P_LOAN_TRANSACTION_ID   OUT NOCOPY NUMBER)
    IS
        var_member_account_id           NUMBER;
        var_person_id                   NUMBER;
        var_loan_balance                NUMBER;
        
        var_asps_payment_capital        NUMBER;
        var_asps_payment_interest       NUMBER;
        var_asps_payment_interest_late  NUMBER;
        
        var_user_id                     NUMBER := FND_GLOBAL.USER_ID;
        var_validate                    NUMBER;
    BEGIN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'SETTLEMENT_LOAN(P_LOAN_ID => ' || P_LOAN_ID || 
                                                        'P_MEMBER_ID => ' || P_MEMBER_ID ||
                                                        'P_PREPAID_SEQ => ' || P_PREPAID_SEQ ||
                                                        'P_LOAN_TRANSACTION_ID => ' || P_LOAN_TRANSACTION_ID || ')');
        
        SELECT ASM.PERSON_ID,
               SUM(NVL(ASPS.OWED_AMOUNT, ASPS.PAYMENT_AMOUNT)),
               SUM(NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL)),
               SUM(NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST)),
               SUM(NVL(ASPS.OWED_INTEREST_LATE, ASPS.PAYMENT_INTEREST_LATE))
          INTO var_person_id,
               var_loan_balance,
               var_asps_payment_capital,
               var_asps_payment_interest,
               var_asps_payment_interest_late
          FROM ATET_SB_LOANS                ASL,
               ATET_SB_MEMBERS              ASM,
               ATET_SB_PAYMENTS_SCHEDULE    ASPS
         WHERE 1 = 1
           AND ASL.LOAN_ID = P_LOAN_ID
           AND ASL.MEMBER_ID = ASM.MEMBER_ID
           AND ASPS.LOAN_ID = ASL.LOAN_ID
           AND ASPS.STATUS_FLAG IN ('PENDING', 'SKIP', 'PARTIAL') 
         GROUP 
            BY ASM.PERSON_ID;
        
        var_member_account_id := GET_LOAN_MEMBER_ACCOUNT_ID(P_MEMBER_ID, P_LOAN_ID);
                                                            
                                                            
        UPDATE ATET_SB_PAYMENTS_SCHEDULE    ASPS
           SET ASPS.STATUS_FLAG = 'PAYED',
               ASPS.ATTRIBUTE6 = 'PREPAID',
               ASPS.LAST_UPDATE_DATE = SYSDATE,
               ASPS.LAST_UPDATED_BY = var_user_id
         WHERE 1 = 1
           AND ASPS.LOAN_ID = P_LOAN_ID
           AND ASPS.STATUS_FLAG IN ('PARTIAL', 'SKIP', 'PENDING', 'EXPORTED');
           
        
    
        INSERT INTO ATET_SB_LOANS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                MEMBER_ID,
                                                PAYROLL_RESULT_ID,
                                                LOAN_ID,
                                                PERSON_ID,
                                                EARNED_DATE,
                                                PERIOD_NAME,
                                                ELEMENT_NAME,
                                                TRANSACTION_CODE,
                                                DEBIT_AMOUNT,
                                                CREDIT_AMOUNT,
                                                PAYMENT_AMOUNT,
                                                PAYMENT_CAPITAL,
                                                PAYMENT_INTEREST,
                                                PAYMENT_INTEREST_LATE,                                                
                                                ATTRIBUTE1,
                                                ACCOUNTED_FLAG,
                                                CREATION_DATE,
                                                CREATED_BY,
                                                LAST_UPDATE_DATE,
                                                LAST_UPDATED_BY)
                                         VALUES (var_member_account_id,
                                                 P_MEMBER_ID,
                                                 -1,
                                                 P_LOAN_ID,
                                                 var_person_id,
                                                 TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                                                 'LIQUIDACION',
                                                 'LIQUIDACION DE PRESTAMO',
                                                 'SETTLEMENT_LOAN',
                                                 0,
                                                 var_loan_balance,
                                                 var_loan_balance,
                                                 var_asps_payment_capital,
                                                 var_asps_payment_interest,
                                                 var_asps_payment_interest_late,
                                                 P_PREPAID_SEQ,
                                                 'ACCOUNTED',
                                                 SYSDATE,
                                                 var_user_id,
                                                 SYSDATE,
                                                 var_user_id);
        
        BEGIN
            SELECT ASLT.LOAN_TRANSACTION_ID
              INTO P_LOAN_TRANSACTION_ID
              FROM ATET_SB_LOANS_TRANSACTIONS ASLT 
             WHERE 1 = 1
               AND MEMBER_ACCOUNT_ID = var_member_account_id
               AND MEMBER_ID = P_MEMBER_ID
               AND PAYROLL_RESULT_ID = -1
               AND LOAN_ID = P_LOAN_ID
               AND PERSON_ID = var_person_id
               AND PERIOD_NAME = 'LIQUIDACION'
               AND ELEMENT_NAME = 'LIQUIDACION DE PRESTAMO'
               AND TRANSACTION_CODE = 'SETTLEMENT_LOAN'
               AND DEBIT_AMOUNT = 0
               AND CREDIT_AMOUNT = var_loan_balance
               AND ATTRIBUTE1 = P_PREPAID_SEQ;
        EXCEPTION
            WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'SELECT ATET_SB_LOANS_TRANSACTIONS : ' || SQLERRM);
                RAISE;
        END;
                                                  
                                                 
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET DEBIT_BALANCE = DEBIT_BALANCE + 0,
               CREDIT_BALANCE = CREDIT_BALANCE + (var_loan_balance - var_asps_payment_interest_late),
               LAST_TRANSACTION_DATE = SYSDATE               
         WHERE MEMBER_ID = P_MEMBER_ID
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
           
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET FINAL_BALANCE = DEBIT_BALANCE - CREDIT_BALANCE,
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = var_user_id             
         WHERE MEMBER_ID = P_MEMBER_ID
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
           
        UPDATE ATET_SB_LOANS ASL
           SET ASL.LOAN_BALANCE = ASL.LOAN_BALANCE - (var_loan_balance - var_asps_payment_interest_late),
               ASL.LAST_PAYMENT_DATE = TO_DATE(SYSDATE, 'DD/MM/RRRR'),
               ASL.LOAN_STATUS_FLAG = 'PAYED',
               ASL.LAST_UPDATE_DATE = SYSDATE,
               ASL.LAST_UPDATED_BY = var_user_id    
         WHERE 1 = 1
           AND ASL.LOAN_ID = P_LOAN_ID;

        BEGIN             
            MERGE INTO ATET_SB_MEMBERS      ASM
                 USING ATET_SB_ENDORSEMENTS ASE
                    ON (    ASE.LOAN_ID = P_LOAN_ID
                        AND ASE.MEMBER_ENDORSEMENT_ID = ASM.MEMBER_ID)
            WHEN MATCHED THEN 
            UPDATE SET ASM.IS_ENDORSEMENT = 'N',
                       ASM.LAST_UPDATE_DATE = SYSDATE,
                       ASM.LAST_UPDATED_BY = var_user_id;
        EXCEPTION 
             WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'MERGE AVALES: ' || SQLERRM);
                RAISE;
        END;     
            
                     
        SELECT COUNT(ASL.LOAN_ID)
          INTO var_validate
          FROM ATET_SB_LOANS ASL
         WHERE 1 = 1
           AND ASL.MEMBER_ID = P_MEMBER_ID
           AND ASL.LOAN_STATUS_FLAG = 'ACTIVE';


        IF var_validate = 0 THEN 
            BEGIN
                MERGE INTO ATET_SB_MEMBERS      ASM
                     USING ATET_SB_LOANS        ASL
                        ON (    ASL.LOAN_ID = P_LOAN_ID
                            AND ASL.MEMBER_ID = ASM.MEMBER_ID)
                WHEN MATCHED THEN 
                UPDATE SET ASM.IS_BORROWER = 'N',
                           ASM.LAST_UPDATE_DATE = SYSDATE,
                           ASM.LAST_UPDATED_BY = var_user_id;
            EXCEPTION 
             WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'MERGE BORROWER: ' || SQLERRM);
                RAISE;
            END;
        END IF;
         
    EXCEPTION
        WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
            RAISE;
    END SETTLEMENT_LOAN;
    
    
    PROCEDURE   SAVING_RETIREMENT(
                    P_ERRBUF                  OUT NOCOPY  VARCHAR2,
                    P_RETCODE                 OUT NOCOPY  VARCHAR2,
                    P_MEMBER_ID               NUMBER,
                    P_PERCENTAGE_RETIREMENT   NUMBER,
                    P_SAVING_RETIREMENT       NUMBER,
                    P_DESCRIPTION             VARCHAR2,
                    P_IS_MEMBER_END           VARCHAR2)
    IS
        var_validate                NUMBER;    
        var_loan_balance            NUMBER;
        var_percentage_retirement   NUMBER;
        
        var_user_id                 NUMBER := FND_GLOBAL.USER_ID;
        var_hold_comment            VARCHAR2(500);
        
        P_AMOUNT_SAVED              NUMBER;
    BEGIN                           
          
        SELECT COUNT(ASL.LOAN_ID),
               SUM(ASL.LOAN_BALANCE)
          INTO var_validate,
               var_loan_balance
          FROM ATET_SB_MEMBERS      ASM,
               ATET_SB_LOANS        ASL
         WHERE 1 = 1
           AND ASL.MEMBER_ID = ASM.MEMBER_ID
           AND ASM.MEMBER_ID = P_MEMBER_ID
           AND ASL.LOAN_STATUS_FLAG = 'ACTIVE';
           
           
           
        SELECT FINAL_BALANCE
          INTO P_AMOUNT_SAVED
          FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
         WHERE 1 = 1
           AND ASMA.MEMBER_ID = P_MEMBER_ID
           AND ASMA.LOAN_ID IS NULL
           AND ASMA.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO';
           
           
                             
        FND_FILE.PUT_LINE( FND_FILE.LOG, 'QUERY : ' || var_validate);           
           
        IF var_validate > 0 THEN
        
            var_percentage_retirement := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'PER_RET_LOAN_BALANCE');    
        
            IF P_PERCENTAGE_RETIREMENT IS NOT NULL THEN
                IF P_PERCENTAGE_RETIREMENT > var_percentage_retirement THEN
                    var_hold_comment := 'EL PORCENTAJE DE RETIRO INGRESADO DEBE DE SER MENOR O IGUAL AL ESTABLECIDO EN EL PARAMETRO DE PORCENTAJE DE RETIRO CON SALDO DE CRÉDITOS. SALDO RESTANTE :' || TO_CHAR(var_loan_balance, '$999,999.00');
                    P_ERRBUF := var_hold_comment;
                    P_RETCODE := 1; 
                ELSE
                    var_hold_comment := 'EL RETIRO DEBE SER LIBERADO PORQUE EL EMPLEADO TIENE PRESTAMOS ACTIVOS.';
                    P_ERRBUF := var_hold_comment;
                    P_RETCODE := 1;    
                END IF;
            ELSIF P_SAVING_RETIREMENT IS NOT NULL THEN
                IF (P_SAVING_RETIREMENT * 100) / P_AMOUNT_SAVED > var_percentage_retirement THEN
                    var_hold_comment := 'LA CANTIDAD DE RETIRO INGRESADA DEBE DE SER MENOR O IGUAL AL PORCENTAJE ESTABLECIDO EN EL PARAMETRO DE PORCENTAJE DE RETIRO CON SALDO DE CRÉDITOS. SALDO RESTANTE :' || TO_CHAR(var_loan_balance, '$999,999.00');
                    P_ERRBUF := var_hold_comment;
                    P_RETCODE := 1;
                ELSE
                    var_hold_comment := 'EL RETIRO DEBE SER LIBERADO PORQUE EL EMPLEADO TIENE PRESTAMOS ACTIVOS.';
                    P_ERRBUF := var_hold_comment;
                    P_RETCODE := 1;  
                END IF; 
            END IF;         
            
            INSERT 
              INTO ATET_SB_TRANSACTIONS_HOLDS (HOLD_REASON_CODE,
                                               HOLD_COMMENT,
                                               SOURCE_ID,
                                               SOURCE_TABLE,
                                               ATTRIBUTE6,
                                               ATTRIBUTE7,
                                               ATTRIBUTE8,
                                               ATTRIBUTE9,
                                               ATTRIBUTE10,
                                               ATTRIBUTE11,
                                               RELEASED_FLAG,
                                               CREATION_DATE,
                                               CREATED_BY,
                                               LAST_UPDATE_DATE,
                                               LAST_UPDATED_BY)
                                       VALUES ('SAVING_RETIREMENT',
                                               var_hold_comment,
                                               P_MEMBER_ID,
                                               'ATET_SB_MEMBERS',
                                               'P_MEMBER_ID=>' || P_MEMBER_ID,
                                               'P_AMOUNT_SAVED=>' || P_AMOUNT_SAVED,
                                               'P_PERCENTAGE_RETIREMENT=>' || P_PERCENTAGE_RETIREMENT,
                                               'P_SAVING_RETIREMENT=>' || P_SAVING_RETIREMENT,
                                               'P_IS_MEMBER_END=>' || P_IS_MEMBER_END,
                                               'P_DESCRIPTION=>' || P_DESCRIPTION,
                                               'P',
                                               SYSDATE,
                                               var_user_id,
                                               SYSDATE,
                                               var_user_id);
                                               
            FND_FILE.PUT_LINE( FND_FILE.LOG, 'INSERT : ATET_SB_TRANSACTIONS_HOLDS');           
                                                                      
            COMMIT;                                   
            RETURN;                  
        
        ELSE
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'EXCEUTE : PROCESS_SAVING_RETIREMENT');
            
            PROCESS_SAVING_RETIREMENT(P_MEMBER_ID             => P_MEMBER_ID,
                                      P_PERCENTAGE_RETIREMENT => P_PERCENTAGE_RETIREMENT,
                                      P_SAVING_RETIREMENT     => P_SAVING_RETIREMENT,
                                      P_DESCRIPTION           => P_DESCRIPTION,
                                      P_IS_MEMBER_END         => P_IS_MEMBER_END);
            
        END IF;
           
                
            
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en SAVING_RETIREMENT ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END SAVING_RETIREMENT;
    
    
    PROCEDURE   RELEASE_SAVING_RETIREMENT(
                    P_ERRBUF                    OUT NOCOPY VARCHAR2,
                    P_RETCODE                   OUT NOCOPY VARCHAR2,
                    P_TRANSACTION_HOLD_ID                NUMBER,
                    P_REASON_DESCRIPTION                 VARCHAR2,
                    P_RELEASE_FLAG                       VARCHAR2)
    IS
        var_user_id                 NUMBER := FND_GLOBAL.USER_ID;
        var_hold_release_id         NUMBER;
        
        var_member_id               VARCHAR2(100);
        var_percentage_retirement   VARCHAR2(100);
        var_saving_retirement       VARCHAR2(100);
        var_description             VARCHAR2(100);
        var_is_member_end           VARCHAR2(100);
        
    BEGIN
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'RELEASE_SAVING_RETIREMENT(P_TRANSACTION_HOLD_ID => ' || P_TRANSACTION_HOLD_ID ||
                                                                 ',P_REASON_DESCRIPTION => ' || P_REASON_DESCRIPTION ||
                                                                 ',P_RELEASE_FLAG => ' || P_RELEASE_FLAG || ')');
                                                                 
        IF P_RELEASE_FLAG = 'Y' THEN
        
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'CONDITION : Y');
            
            INSERT 
              INTO ATET_SB_HOLD_RELEASES (CREATION_DATE,
                                          CREATED_BY,
                                          LAST_UPDATE_DATE,
                                          LAST_UPDATED_BY,
                                          HOLD_SOURCE_ID,
                                          RELEASE_REASON_CODE,
                                          RELEASE_COMMENT)
                                  VALUES (SYSDATE,
                                          var_user_id,
                                          SYSDATE,
                                          var_user_id,
                                          P_TRANSACTION_HOLD_ID,
                                          'ATET_SB_TRANSACTIONS_HOLDS',
                                          P_REASON_DESCRIPTION);
                                          
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT : ATET_SB_HOLD_RELEASES');
                                          
                                          
            SELECT ASHR.HOLD_RELEASE_ID
              INTO var_hold_release_id
              FROM ATET_SB_HOLD_RELEASES ASHR
             WHERE 1 = 1
               AND ASHR.HOLD_SOURCE_ID = P_TRANSACTION_HOLD_ID
               AND ASHR.RELEASE_REASON_CODE = 'ATET_SB_TRANSACTIONS_HOLDS'
               AND ASHR.RELEASE_COMMENT = P_REASON_DESCRIPTION;
            
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'QUERY : var_hold_release_id');   
               
            UPDATE ATET_SB_TRANSACTIONS_HOLDS
               SET HOLD_RELEASE_ID = var_hold_release_id,
                   RELEASED_FLAG = 'Y',
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = var_user_id
             WHERE 1 = 1
               AND TRANSACTION_HOLD_ID = P_TRANSACTION_HOLD_ID;
                   
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'UPDATE : ATET_SB_TRANSACTIONS_HOLDS');
               
            SELECT REPLACE(ASTH.ATTRIBUTE6, 'P_MEMBER_ID=>', ''),
                   REPLACE(ASTH.ATTRIBUTE8, 'P_PERCENTAGE_RETIREMENT=>', ''),
                   REPLACE(ASTH.ATTRIBUTE9, 'P_SAVING_RETIREMENT=>', ''),
                   REPLACE(ASTH.ATTRIBUTE10, 'P_IS_MEMBER_END=>', ''),
                   REPLACE(ASTH.ATTRIBUTE11, 'P_DESCRIPTION=>', '')
              INTO var_member_id,
                   var_percentage_retirement,
                   var_saving_retirement,
                   var_is_member_end,
                   var_description
              FROM ATET_SB_TRANSACTIONS_HOLDS ASTH
             WHERE 1 = 1
               AND TRANSACTION_HOLD_ID = P_TRANSACTION_HOLD_ID;
               
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'QUERY : ATET_SB_TRANSACTIONS_HOLDS');                
               
            PROCESS_SAVING_RETIREMENT(
                          P_MEMBER_ID => var_member_id,
                          P_PERCENTAGE_RETIREMENT => var_percentage_retirement, 
                          P_SAVING_RETIREMENT => var_saving_retirement,
                          P_DESCRIPTION => var_description,
                          P_IS_MEMBER_END => var_is_member_end);
                   
                       
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'EXECUTE: PROCESS_SAVING_RETIREMENT');                            
            
        ELSIF P_RELEASE_FLAG = 'N' THEN
        
            UPDATE ATET_SB_TRANSACTIONS_HOLDS
               SET RELEASED_FLAG = 'N',
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = var_user_id
             WHERE 1 = 1
               AND TRANSACTION_HOLD_ID = P_TRANSACTION_HOLD_ID;     
               
        END IF;
        
        COMMIT;                                                                  
    
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'EXCEPTION : OTHERS' || SQLERRM);
        ROLLBACK;
    END RELEASE_SAVING_RETIREMENT;
    
    
    PROCEDURE   PROCESS_SAVING_RETIREMENT(
                    P_MEMBER_ID               NUMBER,
                    P_PERCENTAGE_RETIREMENT   NUMBER,
                    P_SAVING_RETIREMENT       NUMBER,
                    P_DESCRIPTION             VARCHAR2,
                    P_IS_MEMBER_END           VARCHAR2)
    IS
        SAVING_RETIREMENT_EXCEPTION EXCEPTION;
        
        var_amount_saved            NUMBER;
        var_saving_retirement       NUMBER;
        var_person_id               NUMBER;
        var_member_account_id       NUMBER;
        var_seniority               NUMBER;

        var_employee_number         VARCHAR2(50);
        var_employee_full_name      VARCHAR2(500);
        
        var_request_id              NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        var_user_id                 NUMBER := FND_GLOBAL.USER_ID;
        
        var_debit_amount            NUMBER;
        var_credit_amount           NUMBER;
        
        var_debit_balance           NUMBER;
        var_credit_balance          NUMBER;
        var_final_balance           NUMBER;
        
        var_saving_retirement_seq   NUMBER;
        var_saving_transaction_id   NUMBER;
        
        var_bank_code_comb          VARCHAR2(100);
        var_sav_code_comb           VARCHAR2(100);
        var_bank_account_id         NUMBER;
        var_sav_account_id          NUMBER;
        
        var_header_id               NUMBER;
        
        var_check_id                NUMBER;
        
        CURSOR SAVINGS_DETAILS IS
            SELECT ASST.EARNED_DATE,
                   ASST.PERIOD_NAME,
                   ASST.ELEMENT_NAME,
                   ASST.DEBIT_AMOUNT,
                   ASST.CREDIT_AMOUNT
              FROM ATET_SB_SAVINGS_TRANSACTIONS ASST
             WHERE 1 = 1
               AND ASST.MEMBER_ID = P_MEMBER_ID
             ORDER BY ASST.SAVING_TRANSACTION_ID;
    BEGIN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'PROCESS_SAVING_RETIREMENT(P_MEMBER_ID => ' || P_MEMBER_ID ||
                                                                 ',P_PERCENTAGE_RETIREMENT => ' || P_PERCENTAGE_RETIREMENT ||
                                                                 ',P_SAVING_RETIREMENT => ' || P_SAVING_RETIREMENT ||
                                                                 ',P_DESCRIPTION => ' || P_DESCRIPTION ||
                                                                 ',P_IS_MEMBER_END => ' || P_IS_MEMBER_END || ')');
    
        var_member_account_id := GET_SAVING_MEMBER_ACCOUNT_ID(P_MEMBER_ID,
                                                              GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAV_CODE_COMB'),
                                                              GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME'));                                                          
        
        SELECT ASMA.FINAL_BALANCE,
               ASM.EMPLOYEE_NUMBER,
               ASM.EMPLOYEE_FULL_NAME,
               ASM.PERSON_ID,
               ASM.SENIORITY_YEARS
          INTO var_amount_saved,
               var_employee_number,
               var_employee_full_name,
               var_person_id,
               var_seniority
          FROM ATET_SB_MEMBERS          ASM,
               ATET_SB_MEMBERS_ACCOUNTS ASMA
         WHERE ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID
           AND ASM.MEMBER_ID = P_MEMBER_ID
           AND ASM.MEMBER_ID = ASMA.MEMBER_ID
           AND ASMA.LOAN_ID IS NULL
           AND ASMA.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO';
        
        IF P_PERCENTAGE_RETIREMENT IS NOT NULL OR P_SAVING_RETIREMENT IS NOT NULL THEN
        
            IF P_PERCENTAGE_RETIREMENT IS NOT NULL AND P_SAVING_RETIREMENT IS NULL THEN
                    
                var_saving_retirement := TRUNC((var_amount_saved * (P_PERCENTAGE_RETIREMENT / 100)), 2);
                    
            ELSIF P_SAVING_RETIREMENT IS NOT NULL AND P_PERCENTAGE_RETIREMENT IS NULL THEN
                    
                var_saving_retirement := P_SAVING_RETIREMENT;
                      
            ELSE
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'SOLO SE PUEDE SELECCIONAR UN PARAMETRO A LA VEZ, PORCENTAJE DE RETIRO/MONTO DE RETIRO.');
                RAISE SAVING_RETIREMENT_EXCEPTION;
            END IF;
                
                
                
            SELECT ATET_SB_SAVING_RETIREMENT_SEQ.NEXTVAL
              INTO var_saving_retirement_seq 
              FROM DUAL;                         
                    
            var_debit_amount := var_saving_retirement;
            var_credit_amount := 0;
        
            INSERT INTO ATET_SB_SAVINGS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                      MEMBER_ID,
                                                      PAYROLL_RESULT_ID,
                                                      PERSON_ID,
                                                      EARNED_DATE,
                                                      PERIOD_NAME,
                                                      ELEMENT_NAME,
                                                      ENTRY_VALUE,
                                                      TRANSACTION_CODE,
                                                      DEBIT_AMOUNT,
                                                      CREDIT_AMOUNT,
                                                      ATTRIBUTE1,
                                                      ATTRIBUTE6,
                                                      ACCOUNTED_FLAG,
                                                      CREATION_DATE,
                                                      CREATED_BY,
                                                      LAST_UPDATE_DATE,
                                                      LAST_UPDATED_BY)
                                              VALUES (var_member_account_id,
                                                      P_MEMBER_ID,
                                                      -1,
                                                      var_person_id,
                                                      TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                                                      'RETIRO',
                                                      'RETIRO DE AHORRO',
                                                      var_saving_retirement,
                                                      'RETIREMENT',
                                                      var_debit_amount,
                                                      var_credit_amount,
                                                      var_saving_retirement_seq,
                                                      P_DESCRIPTION,
                                                      'ACCOUNTED',
                                                      SYSDATE,
                                                      var_user_id,
                                                      SYSDATE,
                                                      var_user_id);

                                                      
            UPDATE ATET_SB_MEMBERS_ACCOUNTS
               SET DEBIT_BALANCE = DEBIT_BALANCE + var_debit_amount,
                   CREDIT_BALANCE = CREDIT_BALANCE + var_credit_amount,
                   LAST_TRANSACTION_DATE = SYSDATE               
             WHERE MEMBER_ID = P_MEMBER_ID
               AND MEMBER_ACCOUNT_ID = var_member_account_id;

              
            UPDATE ATET_SB_MEMBERS_ACCOUNTS
               SET FINAL_BALANCE = CREDIT_BALANCE - DEBIT_BALANCE,
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = var_user_id             
             WHERE MEMBER_ID = P_MEMBER_ID
               AND MEMBER_ACCOUNT_ID = var_member_account_id;

                
            IF P_IS_MEMBER_END = 'Y' AND var_amount_saved = var_saving_retirement THEN
                    
                UPDATE ATET_SB_MEMBERS  ASM
                   SET ASM.IS_SAVER = 'N',
                       ASM.MEMBER_END_DATE = TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                       ASM.AMOUNT_TO_SAVE = NULL,
                       ASM.LAST_UPDATE_DATE = SYSDATE,
                       ASM.LAST_UPDATED_BY = var_user_id
                 WHERE 1 = 1
                   AND ASM.MEMBER_ID = P_MEMBER_ID;
                       
                           
            END IF;
                    
                    
            /**********************************************************/
            /*******      CONSULTA DE SAVING_TRANSACTION_ID        ****/
            /**********************************************************/
                    
            SELECT ASST.SAVING_TRANSACTION_ID
              INTO var_saving_transaction_id
              FROM ATET_SB_SAVINGS_TRANSACTIONS ASST
             WHERE 1 = 1
               AND ASST.MEMBER_ACCOUNT_ID = var_member_account_id
               AND ASST.MEMBER_ID = P_MEMBER_ID
               AND ASST.PERSON_ID = var_person_id
               AND ASST.PERIOD_NAME = 'RETIRO'
               AND ASST.ELEMENT_NAME = 'RETIRO DE AHORRO'
               AND ASST.ENTRY_VALUE = var_saving_retirement
               AND ASST.TRANSACTION_CODE = 'RETIREMENT'
               AND ASST.DEBIT_AMOUNT = var_debit_amount
               AND ASST.CREDIT_AMOUNT = var_credit_amount
               AND ASST.ATTRIBUTE1 = var_saving_retirement_seq;
                                        
            /**********************************************************/
            /*******             IMPRESIÓN DE RECIBO               ****/
            /**********************************************************/
                       
            PRINT_SAVING_TRANSACTION(P_SAVING_TRANSACTION_ID => var_saving_transaction_id);                    
                    
            /**********************************************************/
            /*******             CREACIÓN DE CHEQUE                ****/
            /**********************************************************/
                    
            CREATE_SAVING_RETIREMENT_CHECK(P_SAVING_TRANSACTION_ID => var_saving_transaction_id,
                                           P_DESCRIPTION => P_DESCRIPTION, 
                                           P_CHECK_ID => var_check_id);
                    
            /**********************************************************/
            /*******             IMPRESIÓN DE CHEQUE               ****/
            /**********************************************************/
                    
            PRINT_SAVING_RETIREMENT_CHECK(P_CHECK_ID => var_check_id);
                    
            /**********************************************************/
            /*******             CREACIÓN DE POLIZA                ****/
            /**********************************************************/
            var_bank_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'BANK_CODE_COMB');
            var_sav_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAV_CODE_COMB');
            var_bank_account_id := GET_CODE_COMBINATION_ID(var_bank_code_comb);
            var_sav_account_id := GET_CODE_COMBINATION_ID(var_sav_code_comb);
                    
            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (P_ENTITY_CODE        => 'SAVINGS',
                                                       P_EVENT_TYPE_CODE    => 'SAVING_RETIREMENT',
                                                       P_BATCH_NAME         => 'RETIRO DE AHORRO',
                                                       P_JOURNAL_NAME       => 'RETIRO DE CAJA DE AHORRO : ' || var_employee_number || '-' || var_employee_full_name,
                                                       P_HEADER_ID          => var_header_id);
                                                               
            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                     P_ROW_NUMBER              => 1,
                                                     P_CODE_COMBINATION_ID     => var_sav_account_id,
                                                     P_ACCOUNTING_CLASS_CODE   => 'SAVING_RETIREMENT',
                                                     P_ACCOUNTED_DR            => var_debit_amount,
                                                     P_ACCOUNTED_CR            => var_credit_amount,
                                                     P_DESCRIPTION             => 'RETIRO DE CAJA DE AHORRO : ' || var_employee_number || '-' || var_employee_full_name,
                                                     P_SOURCE_ID               => var_saving_transaction_id,
                                                     P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
                                                             
            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                     P_ROW_NUMBER              => 2,
                                                     P_CODE_COMBINATION_ID     => var_bank_account_id,
                                                     P_ACCOUNTING_CLASS_CODE   => 'SAVING_RETIREMENT',
                                                     P_ACCOUNTED_DR            => var_credit_amount,
                                                     P_ACCOUNTED_CR            => var_debit_amount,
                                                     P_DESCRIPTION             => 'RETIRO DE CAJA DE AHORRO : ' || var_employee_number || '-' || var_employee_full_name,
                                                     P_SOURCE_ID               => var_check_id,
                                                     P_SOURCE_LINK_TABLE       => 'ATET_SB_CHECKS_ALL');                                                      
                                
            /**********************************************************/
            /*******                   OUTPUT                      ****/
            /**********************************************************/
                    
            SELECT ASMA.DEBIT_BALANCE,
                   ASMA.CREDIT_BALANCE,
                   ASMA.FINAL_BALANCE
              INTO var_debit_balance,
                   var_credit_balance,
                   var_final_balance
              FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
             WHERE 1 = 1
               AND ASMA.MEMBER_ID = P_MEMBER_ID
               AND ASMA.MEMBER_ACCOUNT_ID = var_member_account_id;
                    
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*', 95, '*'));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('FECHA', 15, ' ') ||
                                               RPAD('PERIODO', 20, ' ') ||
                                               RPAD('DESCRIPCION',20, ' ') ||
                                               LPAD('CARGO',20, ' ') ||
                                               LPAD('ABONO',20, ' '));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*', 95, '*'));
                    
            FOR detail IN SAVINGS_DETAILS LOOP
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(detail.EARNED_DATE, 15, ' ') ||
                                                   RPAD(detail.PERIOD_NAME, 20, ' ') ||
                                                   RPAD(detail.ELEMENT_NAME,20, ' ') ||
                                                   LPAD(detail.DEBIT_AMOUNT,20, ' ') ||
                                                   LPAD(detail.CREDIT_AMOUNT,20, ' '));
            END LOOP;
                    
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*', 95, '*'));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('RESUMEN : ', 55, ' ') ||
                                               LPAD(var_debit_balance,20, ' ') ||
                                               LPAD(var_credit_balance,20, ' '));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*', 95, '*'));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('SALDO : ', 55, ' ') ||
                                               LPAD(var_final_balance,40, ' '));
                
        
        ELSE
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'EL PROCESO DE RETIRO DE AHORRO PARA EL EMPLEADO (' || var_employee_number || ')-' || var_employee_full_name ||' ENCONTRO DIFERENCIAS ENTRE EL PORCENTAJE DE RETIRO PERMITIDO Y EL INGRESADO COMO PARAMETRO.');
            RAISE SAVING_RETIREMENT_EXCEPTION;
        END IF;
        
        COMMIT;
        ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL;
        
    EXCEPTION WHEN SAVING_RETIREMENT_EXCEPTION THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR : SAVING_RETIREMENT_EXCEPTION');
                ROLLBACK;
              WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR : OTHERS');
                ROLLBACK;
    END PROCESS_SAVING_RETIREMENT;
    
    
    PROCEDURE   PRINT_SAVING_TRANSACTION(
                    P_SAVING_TRANSACTION_ID    NUMBER)
    IS
        add_layout_boolean   BOOLEAN;
        v_request_id         NUMBER;
        waiting              BOOLEAN;
        phase                VARCHAR2 (80 BYTE);
        status               VARCHAR2 (80 BYTE);
        dev_phase            VARCHAR2 (80 BYTE);
        dev_status           VARCHAR2 (80 BYTE);
        V_message            VARCHAR2 (4000 BYTE);
    BEGIN
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'PRINT_SAVING_TRANSACTION(P_SAVING_TRANSACTION_ID => ' || P_SAVING_TRANSACTION_ID || ')');    
    
        add_layout_boolean :=
            fnd_request.add_layout (
               template_appl_name   => 'PER',
               template_code        => 'ATET_SB_PRINT_WITHDRAW',
               template_language    => 'Spanish', 
               template_territory   => 'Mexico', 
               output_format        => 'PDF' 
                                            );



         v_request_id :=
            fnd_request.submit_request ('PER', 
                                        'ATET_SB_PRINT_WITHDRAW', 
                                        '',
                                        '',
                                        FALSE,
                                        TO_CHAR (P_SAVING_TRANSACTION_ID),  
                                        CHR (0) 
                                               );
         
         STANDARD.COMMIT;
         
         waiting := fnd_concurrent.wait_for_request (v_request_id,
                                             1,
                                             0,
                                             phase,
                                             status,
                                             dev_phase,
                                             dev_status,
                                             V_message);
    EXCEPTION WHEN OTHERS THEN
        RAISE;
    END PRINT_SAVING_TRANSACTION;
    
    
    PROCEDURE   CREATE_SAVING_RETIREMENT_CHECK(
                    P_SAVING_TRANSACTION_ID     NUMBER,
                    P_DESCRIPTION               VARCHAR2,
                    P_CHECK_ID                  OUT NOCOPY NUMBER)
    IS
        LN_BANK_ACCOUNT_ID           NUMBER;
        LC_BANK_ACCOUNT_NAME         VARCHAR2 (150);
        LC_BANK_ACCOUNT_NUM          VARCHAR2 (150);
        LC_BANK_NAME                 VARCHAR2 (150);
        LC_CURRENCY_CODE             VARCHAR2 (150);
        
        LN_SAVING_TRANSACTION_AMOUNT NUMBER;
        LN_MEMBER_ID                 NUMBER;
        LC_EMPLOYEE_FULL_NAME        VARCHAR2 (300);
        
        LD_TRANSACTION_DATE          DATE;
        LN_CHECK_NUMBER              NUMBER;
        LN_CHECK_ID                  NUMBER;

        INPUT_STRING                 VARCHAR2 (200);
        OUTPUT_STRING                VARCHAR2 (200);
        ENCRYPTED_RAW                RAW (2000); 
        DECRYPTED_RAW                RAW (2000); 
        NUM_KEY_BYTES                NUMBER := 256 / 8; 
        KEY_BYTES_RAW                RAW (32);  
        ENCRYPTION_TYPE              PLS_INTEGER 
         :=                                     
           DBMS_CRYPTO.ENCRYPT_AES256
            + DBMS_CRYPTO.CHAIN_CBC
            + DBMS_CRYPTO.PAD_PKCS5;
    BEGIN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'CREATE_SAVING_RETIREMENT_CHECK(P_SAVING_TRANSACTION_ID => ' || P_SAVING_TRANSACTION_ID ||
                                                                      ',P_CHECK_ID => ' || P_CHECK_ID || ')');
        
        BEGIN
         SELECT BANK_ACCOUNT_ID,
                BANK_ACCOUNT_NAME,
                BANK_ACCOUNT_NUM,
                BANK_NAME,
                CURRENCY_CODE
           INTO LN_BANK_ACCOUNT_ID,
                LC_BANK_ACCOUNT_NAME,
                LC_BANK_ACCOUNT_NUM,
                LC_BANK_NAME,
                LC_CURRENCY_CODE
           FROM ATET_SB_BANK_ACCOUNTS;
        EXCEPTION
         WHEN OTHERS
         THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'ERROR AL BUSCAR LA CUENTA BANCARIA');
            RAISE;
        END;
      
        BEGIN
            SELECT ASM.EMPLOYEE_FULL_NAME,
                   ASM.MEMBER_ID,
                   ASST.ENTRY_VALUE,
                   ASST.EARNED_DATE
              INTO LC_EMPLOYEE_FULL_NAME,
                   LN_MEMBER_ID,
                   LN_SAVING_TRANSACTION_AMOUNT,
                   LD_TRANSACTION_DATE
              FROM ATET_SB_MEMBERS              ASM,
                   ATET_SB_SAVINGS_TRANSACTIONS ASST
             WHERE ASM.MEMBER_ID = ASST.MEMBER_ID
               AND ASST.SAVING_TRANSACTION_ID = P_SAVING_TRANSACTION_ID;
        EXCEPTION
        WHEN OTHERS
        THEN
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'ERROR AL BUSCAR EL MIEMBRO');
           RAISE;
        END;
        
        
        SELECT ATET_SB_CHECKS_ALL_SEQ.NEXTVAL 
          INTO LN_CHECK_ID 
          FROM DUAL;

        SELECT ATET_SB_CHECK_NUMBER_SEQ.NEXTVAL
          INTO LN_CHECK_NUMBER
          FROM DUAL;

        BEGIN
            INPUT_STRING :=
                  TO_CHAR (LN_SAVING_TRANSACTION_AMOUNT)
               || ','
               || LN_CHECK_ID
               || ','
               || LN_CHECK_NUMBER
               || ','
               || LN_MEMBER_ID
               || ','
               || FND_GLOBAL.USER_ID
               || ','
               || TO_CHAR (CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF');

            DBMS_OUTPUT.PUT_LINE ('Original string: ' || input_string);
            key_bytes_raw := DBMS_CRYPTO.RANDOMBYTES (num_key_bytes);
            encrypted_raw :=
               DBMS_CRYPTO.ENCRYPT (
                  src   => UTL_I18N.STRING_TO_RAW (input_string, 'AL32UTF8'),
                  typ   => encryption_type,
                  key   => key_bytes_raw);
            

            decrypted_raw :=
               DBMS_CRYPTO.DECRYPT (src   => encrypted_raw,
                                    typ   => encryption_type,
                                    key   => key_bytes_raw);
            output_string := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
            DBMS_OUTPUT.PUT_LINE ('Cadena a encriptar: ' || input_string);
            DBMS_OUTPUT.PUT_LINE ('Cadena encriptada: ' || encrypted_raw);
            DBMS_OUTPUT.PUT_LINE ('LLave: ' || key_bytes_raw);
            DBMS_OUTPUT.PUT_LINE ('Decrypted string: ' || output_string);
        EXCEPTION
        WHEN OTHERS
        THEN
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'ERROR AL GENERAR FIRMA DIGITAL');
        END;

        BEGIN
            INSERT 
              INTO ATET_SB_CHECKS_ALL (CHECK_ID,
                                       AMOUNT,
                                       BANK_ACCOUNT_ID,
                                       BANK_ACCOUNT_NAME,
                                       CHECK_DATE,
                                       CHECK_NUMBER,
                                       CURRENCY_CODE,
                                       PAYMENT_TYPE_FLAG,
                                       STATUS_LOOKUP_CODE,
                                       MEMBER_ID,
                                       MEMBER_NAME,
                                       BANK_ACCOUNT_NUM,
                                       DIGITAL_SIGNATURE,
                                       DECRYPT_KEY,
                                       PAYMENT_DESCRIPTION,
                                       LAST_UPDATED_BY,
                                       LAST_UPDATE_DATE,
                                       CREATED_BY,
                                       CREATION_DATE)
                             VALUES (LN_CHECK_ID,
                                     LN_SAVING_TRANSACTION_AMOUNT,
                                     LN_BANK_ACCOUNT_ID,
                                     LC_BANK_ACCOUNT_NAME,
                                     LD_TRANSACTION_DATE,
                                     LN_CHECK_NUMBER,
                                     LC_CURRENCY_CODE,
                                     'CHECK_SAVING_RETIREMENT',
                                     'CREATED',
                                     LN_MEMBER_ID,
                                     LC_EMPLOYEE_FULL_NAME,
                                     LC_BANK_ACCOUNT_NUM,
                                     ENCRYPTED_RAW,
                                     KEY_BYTES_RAW,
                                     P_DESCRIPTION,
                                     FND_GLOBAL.USER_ID,
                                     SYSDATE,
                                     FND_GLOBAL.USER_ID,
                                     SYSDATE);

                    P_CHECK_ID := LN_CHECK_ID;

        EXCEPTION
        WHEN OTHERS
        THEN
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error : INSERT INTO ATET_SB_CHECKS_ALL :' || SQLERRM);
           RAISE;
        END;
    
    EXCEPTION WHEN OTHERS THEN
        RAISE;
    END CREATE_SAVING_RETIREMENT_CHECK;
    
    
    PROCEDURE   PRINT_SAVING_RETIREMENT_CHECK(
                    P_CHECK_ID    NUMBER)
    IS
      add_layout_boolean   BOOLEAN;
      v_request_id         NUMBER;
      waiting              BOOLEAN;
      phase                VARCHAR2 (80 BYTE);
      status               VARCHAR2 (80 BYTE);
      dev_phase            VARCHAR2 (80 BYTE);
      dev_status           VARCHAR2 (80 BYTE);
      V_message            VARCHAR2 (4000 BYTE);
   BEGIN
   
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'PRINT_SAVING_RETIREMENT_CHECK(P_CHECK_ID => ' || P_CHECK_ID || ')'); 
   
      BEGIN


         v_request_id :=
            fnd_request.submit_request ('PER',                 
                                        'ATET_SB_PRINT_CHECK', 
                                        '',                    
                                        '',                    
                                        FALSE,                 
                                        TO_CHAR (P_CHECK_ID),  
                                        CHR (0) 
                                               );
         STANDARD.COMMIT;
         waiting :=
            fnd_concurrent.wait_for_request (v_request_id,
                                             1,
                                             0,
                                             phase,
                                             status,
                                             dev_phase,
                                             dev_status,
                                             V_message);
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE;
      END;
    END PRINT_SAVING_RETIREMENT_CHECK;
    
    
    PROCEDURE   PROCESS_PREPAYMENT(
                    P_ERRBUF           OUT NOCOPY   VARCHAR2,
                    P_RETCODE          OUT NOCOPY   VARCHAR2,
                    P_MEMBER_ID                     NUMBER,
                    P_LOAN_ID                       NUMBER,
                    P_BONUS_PERCENTAGE              NUMBER,
                    P_BONUS_AMOUNT                  NUMBER,
                    P_IS_SAVING_RETIREMENT          VARCHAR2,
                    P_IS_SAVER                      VARCHAR2)
    IS
        QRY_LOAN_BALANCE                EXCEPTION;
        QRY_ASPS_PAYMENT_BALANCE        EXCEPTION;
        QRY_ASLT_PAYMENT_BALANCE        EXCEPTION;
        HAS_EXPORTED_PAYMENTS_SCHEDULE  EXCEPTION;
        FATAL_EXCEPTION                 EXCEPTION;
        PRINT_PREPAID_EXCEPTION         EXCEPTION;
        SETTLEMENT_LOAN_EXCEPTION       EXCEPTION; 
        CREATION_GL_EXCEPTION           EXCEPTION;
        MEMBER_ACCOUNT_EXCEPTION        EXCEPTION;
        MEMBER_EXCEPTION                EXCEPTION;
        SAVING_BALANCE_EXCEPTION        EXCEPTION;
        INSERT_SAVING_EXCEPTION         EXCEPTION;
        SELECT_SAVING_EXCEPTION         EXCEPTION;
        UPDATE_SAVING_EXCEPTION         EXCEPTION;
        PRE_PROCESSING_EXCEPTION        EXCEPTION;
        INSERT_RECEIPTS_EXCEPTION       EXCEPTION;
        
        var_employee_number             VARCHAR2(100);
        var_employee_full_name          VARCHAR2(1000);
        var_loan_number                 NUMBER;
        
        var_loan_balance                NUMBER;
        var_loan_amount                 NUMBER;
        var_loan_interest_amount        NUMBER;
        
        var_asps_loan_balance           NUMBER;
        var_asps_payment_capital        NUMBER;
        var_asps_payment_interest       NUMBER;
        var_asps_payment_interest_late  NUMBER;
        
        var_aslt_loan_balance           NUMBER;
        var_aslt_payment_capital        NUMBER;
        var_aslt_payment_interest       NUMBER;
        
        var_user_id                     NUMBER := FND_GLOBAL.USER_ID;
        var_request_id                  NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        
        var_validate                    NUMBER;
        
        var_bank_code_comb              VARCHAR2(100);
        var_une_int_code_comb           VARCHAR2(100);
        var_int_rec_code_comb           VARCHAR2(100);
        
        var_member_account_id           NUMBER;
        
        var_bank_account_id             NUMBER;
        var_not_rec_account_id          NUMBER;
        var_une_int_account_id          NUMBER;
        var_int_rec_account_id          NUMBER;
        
        var_header_id                   NUMBER;
        
        var_description                 VARCHAR2(200);
        
        var_loan_transaction_id         NUMBER;
        
        var_bonus_interest              NUMBER;
        
        CURSOR SAVINGS_DETAILS IS
            SELECT ASST.EARNED_DATE,
                   ASST.PERIOD_NAME,
                   ASST.ELEMENT_NAME,
                   ASST.DEBIT_AMOUNT,
                   ASST.CREDIT_AMOUNT
              FROM ATET_SB_SAVINGS_TRANSACTIONS ASST
             WHERE 1 = 1
               AND ASST.MEMBER_ID = P_MEMBER_ID
             ORDER BY ASST.SAVING_TRANSACTION_ID;
        
        CURSOR LOAN_TRANSACTION_DETAILS IS
            SELECT ASLT.EARNED_DATE,
                   ASLT.PERIOD_NAME,
                   ASLT.DEBIT_AMOUNT,
                   ASLT.CREDIT_AMOUNT
              FROM ATET_SB_LOANS_TRANSACTIONS   ASLT
             WHERE LOAN_ID = P_LOAN_ID
             ORDER BY LOAN_TRANSACTION_ID;
        
        CURSOR ACCOUNTED_DETAILS IS
            SELECT AXL2.LINE_NUMBER,
                   AXL2.CODE_COMBINATION_ID,
                   AXL2.DESCRIPTION,
                   AXL2.ACCOUNTED_DR,
                   AXL2.ACCOUNTED_CR
              FROM ATET_XLA_LINES           AXL2
             WHERE 1 = 1
               AND AXL2.HEADER_ID = var_header_id
             ORDER BY AXL2.LINE_NUMBER;
             
        var_debit_amount                NUMBER := 0;
        var_credit_amount               NUMBER := 0;
        
        var_saving_balance              NUMBER := 0;
        var_member_saving_account_id    NUMBER := 0;
        var_saving_retirement           NUMBER := 0;
        var_saving_retirement_seq       NUMBER := 0;
        var_sav_code_comb               VARCHAR2(100);
        var_sav_account_id              NUMBER := 0;
        var_saving_transaction_id       NUMBER := 0;
        var_condoned_interest_id        NUMBER;
        var_amount_saved                NUMBER;
        
        var_loan_receipt_seq            NUMBER := 0;
        var_receipts_all_seq            NUMBER;
        
        var_banks_account_id            NUMBER;
        var_banks_account_name          VARCHAR2(100);
        var_banks_account_num           VARCHAR2(100);
        var_banks_currency_code         VARCHAR2(13);
        
        var_deposit_date                DATE := TO_DATE(SYSDATE, 'DD/MM/RRRR');
        
        var_code_company                VARCHAR2(50);
            
        var_deb_cs_code_comb            VARCHAR2(100);
        var_deb_pac_code_comb           VARCHAR2(100);
                
        var_deb_cs_account_id           NUMBER;
        var_deb_pac_account_id          NUMBER;
            
        BEGIN
        
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'PROCESS_PREPAYMENT(P_MEMBER_ID => ' || P_MEMBER_ID || 
                                                              ',P_LOAN_ID => '|| P_LOAN_ID ||
                                                              ')'); 
                
            BEGIN                                              
                SELECT ASL.LOAN_BALANCE,
                       ASL.LOAN_AMOUNT,
                       ASL.LOAN_INTEREST_AMOUNT,
                       ASL.LOAN_NUMBER,
                       ASM.EMPLOYEE_NUMBER,
                       ASM.EMPLOYEE_FULL_NAME
                  INTO var_loan_balance,
                       var_loan_amount,
                       var_loan_interest_amount,
                       var_loan_number,
                       var_employee_number,
                       var_employee_full_name
                  FROM ATET_SB_LOANS    ASL,
                       ATET_SB_MEMBERS  ASM
                 WHERE 1 = 1
                   AND ASL.LOAN_ID = P_LOAN_ID
                   AND ASL.MEMBER_ID = P_MEMBER_ID
                   AND ASL.MEMBER_ID = ASM.MEMBER_ID;
                   
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'QUERY : var_loan_balance');
            EXCEPTION WHEN OTHERS THEN
                RAISE QRY_LOAN_BALANCE;    
            END;
            
            
            BEGIN
                SELECT SUM(NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL)),
                       SUM(NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST)),
                       SUM(NVL(ASPS.OWED_INTEREST_LATE, ASPS.PAYMENT_INTEREST_LATE))
                  INTO var_asps_payment_capital,
                       var_asps_payment_interest,
                       var_asps_payment_interest_late
                  FROM ATET_SB_PAYMENTS_SCHEDULE ASPS
                 WHERE 1 = 1
                   AND ASPS.LOAN_ID = P_LOAN_ID
                   AND ASPS.STATUS_FLAG IN ('PENDING',
                                            'SKIP',
                                            'PARTIAL');
                   
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'QUERY : var_asps_payment_capital, var_asps_payment_interest');
            EXCEPTION WHEN OTHERS THEN 
                RAISE QRY_ASPS_PAYMENT_BALANCE;             
            END;
            
            
            BEGIN
                SELECT var_loan_amount - NVL(SUM(ASLT.PAYMENT_CAPITAL), 0),
                       var_loan_interest_amount - NVL(SUM(ASLT.PAYMENT_INTEREST), 0)
                  INTO var_aslt_payment_capital,
                       var_aslt_payment_interest
                  FROM ATET_SB_LOANS_TRANSACTIONS ASLT
                 WHERE 1 = 1
                   AND ASLT.LOAN_ID = P_LOAN_ID
                   AND ASLT.TRANSACTION_CODE NOT IN ('OPENING', 'SETTLEMENT_LOAN');
                   
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'QUERY : var_aslt_payment_capital, var_aslt_payment_interest'); 
            EXCEPTION WHEN OTHERS THEN
                RAISE QRY_ASLT_PAYMENT_BALANCE;          
            END;
            
            
            SELECT COUNT(ASPS.PAYMENT_SCHEDULE_ID)
              INTO var_validate
              FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
             WHERE 1 = 1
               AND ASPS.LOAN_ID = P_LOAN_ID
               AND ASPS.STATUS_FLAG = 'EXPORTED';
        
            
            IF var_validate = 0 THEN
                
                var_loan_balance := var_loan_balance + var_asps_payment_interest_late;
                var_asps_loan_balance := var_asps_payment_capital + var_asps_payment_interest + var_asps_payment_interest_late;
                var_aslt_loan_balance := var_aslt_payment_capital + var_aslt_payment_interest + var_asps_payment_interest_late;
                
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_loan_balance : ' || var_loan_balance ||
                                               ',var_asps_loan_balance : ' || var_asps_loan_balance ||
                                               ',var_aslt_loan_balance : ' || var_aslt_loan_balance);  
                
                IF var_loan_balance = var_asps_loan_balance AND var_loan_balance = var_aslt_loan_balance THEN
                
                    IF  P_BONUS_PERCENTAGE <> 0 AND P_BONUS_AMOUNT = 0 THEN
                        var_bonus_interest := (var_asps_payment_interest * P_BONUS_PERCENTAGE) / 100;
                    ELSIF P_BONUS_PERCENTAGE = 0 AND P_BONUS_AMOUNT <> 0 THEN
                        var_bonus_interest := P_BONUS_AMOUNT;
                    ELSE
                        var_bonus_interest := 0;
                    END IF;
                    
                
                    /*********************************************/
                    /***               RETIRO DE AHORRO        ***/
                    /*********************************************/
                    
                    IF  P_IS_SAVING_RETIREMENT = 'Y' THEN
                    
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'CASE : IS_SAVING_RETIREMENT');
                        
                        SELECT COUNT(ASM.MEMBER_ID)
                          INTO var_validate
                          FROM ATET_SB_MEMBERS  ASM 
                         WHERE 1 = 1
                           AND ASM.MEMBER_ID = P_MEMBER_ID
                           AND ASM.IS_SAVER = 'Y';
                           
                        IF var_validate > 0 THEN 
                            
                            SELECT ASMA.FINAL_BALANCE
                              INTO var_saving_balance
                              FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
                             WHERE 1 = 1
                               AND ASMA.MEMBER_ID = P_MEMBER_ID
                               AND ASMA.LOAN_ID IS NULL
                               AND ASMA.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO';
                               
                            var_debit_amount := 0;
                            var_credit_amount := 0;
                               
                            IF var_saving_balance >= var_loan_balance THEN
                            
                                FND_FILE.PUT_LINE(FND_FILE.LOG, 'CASE : var_saving_balance >= var_loan_balance.');
                                
                                var_member_saving_account_id := GET_SAVING_MEMBER_ACCOUNT_ID(P_MEMBER_ID,
                                                                                             GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAV_CODE_COMB'),
                                                                                             GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME')); 
                                                                                             
                                FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET : var_member_saving_account_id.');
                                                                                                
                                var_saving_retirement := var_loan_balance - var_bonus_interest;
                                
                                FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET : var_saving_retirement=' || var_saving_retirement || 
                                                                     ' var_loan_balance=' || var_loan_balance ||
                                                                     ' var_bonus_interest=' || var_bonus_interest);
                    
                                SELECT ATET_SB_SAVING_RETIREMENT_SEQ.NEXTVAL
                                  INTO var_saving_retirement_seq 
                                  FROM DUAL;                         
                                    
                                var_debit_amount := var_saving_retirement;
                                var_credit_amount := 0;
                                
                                BEGIN
                                
                                    INSERT INTO ATET_SB_SAVINGS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                                              MEMBER_ID,
                                                                              PAYROLL_RESULT_ID,
                                                                              PERSON_ID,
                                                                              EARNED_DATE,
                                                                              PERIOD_NAME,
                                                                              ELEMENT_NAME,
                                                                              ENTRY_VALUE,
                                                                              TRANSACTION_CODE,
                                                                              DEBIT_AMOUNT,
                                                                              CREDIT_AMOUNT,
                                                                              ATTRIBUTE1,
                                                                              ATTRIBUTE6,
                                                                              ACCOUNTED_FLAG,
                                                                              CREATION_DATE,
                                                                              CREATED_BY,
                                                                              LAST_UPDATE_DATE,
                                                                              LAST_UPDATED_BY)
                                                                      VALUES (var_member_saving_account_id,
                                                                              P_MEMBER_ID,
                                                                              -1,
                                                                              GET_PERSON_ID(P_MEMBER_ID),
                                                                              TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                                                                              'RETIRO',
                                                                              'RETIRO DE AHORRO',
                                                                              var_saving_retirement,
                                                                              'RETIREMENT',
                                                                              var_debit_amount,
                                                                              var_credit_amount,
                                                                              var_saving_retirement_seq,
                                                                              'RETIRO POR PAGO ANTICIPADO',
                                                                              'ACCOUNTED',
                                                                              SYSDATE,
                                                                              var_user_id,
                                                                              SYSDATE,
                                                                              var_user_id);
                                                                              
                                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT : ATET_SB_SAVINGS_TRANSACTIONS.');
                                
                                EXCEPTION WHEN OTHERS THEN
                                    RAISE INSERT_SAVING_EXCEPTION;                                                                          
                                END;
                                     
                                BEGIN         
                                
                                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'AND ASST.MEMBER_ACCOUNT_ID = ' ||var_member_saving_account_id ||
                                                                   'AND ASST.MEMBER_ID = ' ||P_MEMBER_ID ||
                                                                   'AND ASST.PERSON_ID = ' ||GET_PERSON_ID(P_MEMBER_ID)||
                                                                   'AND ASST.ENTRY_VALUE = ' || var_saving_retirement||
                                                                   'AND ASST.DEBIT_AMOUNT = ' || var_debit_amount ||
                                                                   'AND ASST.CREDIT_AMOUNT = '||var_credit_amount||
                                                                   'AND ASST.ATTRIBUTE1 = '||var_saving_retirement_seq);  
                                                          
                                    SELECT ASST.SAVING_TRANSACTION_ID
                                      INTO var_saving_transaction_id
                                      FROM ATET_SB_SAVINGS_TRANSACTIONS ASST
                                     WHERE 1 = 1
                                       AND ASST.MEMBER_ACCOUNT_ID = var_member_saving_account_id
                                       AND ASST.MEMBER_ID = P_MEMBER_ID
                                       AND ASST.PERSON_ID = GET_PERSON_ID(P_MEMBER_ID)
                                       AND ASST.PERIOD_NAME = 'RETIRO'
                                       AND ASST.ELEMENT_NAME = 'RETIRO DE AHORRO'
                                       AND ASST.ENTRY_VALUE = var_saving_retirement
                                       AND ASST.TRANSACTION_CODE = 'RETIREMENT'
                                       AND ASST.DEBIT_AMOUNT = var_debit_amount
                                       AND ASST.CREDIT_AMOUNT = var_credit_amount
                                       AND ASST.ATTRIBUTE1 = var_saving_retirement_seq;
                                EXCEPTION WHEN OTHERS THEN
                                    RAISE SELECT_SAVING_EXCEPTION;
                                END;
                                
                                BEGIN
                                                                          
                                    UPDATE ATET_SB_MEMBERS_ACCOUNTS
                                       SET DEBIT_BALANCE = DEBIT_BALANCE + var_debit_amount,
                                           CREDIT_BALANCE = CREDIT_BALANCE + var_credit_amount,
                                           LAST_TRANSACTION_DATE = SYSDATE               
                                     WHERE MEMBER_ID = P_MEMBER_ID
                                       AND MEMBER_ACCOUNT_ID = var_member_saving_account_id;

                                  
                                    UPDATE ATET_SB_MEMBERS_ACCOUNTS
                                       SET FINAL_BALANCE = CREDIT_BALANCE - DEBIT_BALANCE,
                                           LAST_UPDATE_DATE = SYSDATE,
                                           LAST_UPDATED_BY = var_user_id             
                                     WHERE MEMBER_ID = P_MEMBER_ID
                                       AND MEMBER_ACCOUNT_ID = var_member_saving_account_id;
                                
                                EXCEPTION WHEN OTHERS THEN
                                    RAISE UPDATE_SAVING_EXCEPTION;
                                END;
                                
                            
                            ELSE
                                RAISE SAVING_BALANCE_EXCEPTION;
                            END IF;
                        
                        ELSE
                            RAISE MEMBER_EXCEPTION;
                        END IF;
                        
                        PRINT_SAVING_TRANSACTION(P_SAVING_TRANSACTION_ID => var_saving_transaction_id);
                    
                    END IF;
                    
                    
                    
                    /*********************************************/
                    /***            IMPRESIÓN DE RECIBO        ***/
                    /*********************************************/
                     BEGIN           
                                 
                        IF P_IS_SAVING_RETIREMENT = 'N' THEN                                  
                            SELECT ATET_SB_RECEIPT_NUMBER_SEQ.NEXTVAL
                              INTO var_loan_receipt_seq 
                              FROM DUAL;                         
                                 
                                 
                            SELECT ATET_SB_RECEIPTS_ALL_SEQ.NEXTVAL
                              INTO var_receipts_all_seq
                              FROM DUAL;
                        ELSIF P_IS_SAVING_RETIREMENT = 'Y' THEN
                            SELECT ATET_SB_PREPAID_SEQ.NEXTVAL
                              INTO var_loan_receipt_seq 
                              FROM DUAL;
                        END IF;                 
                            
                              
                        SELECT ASM.EMPLOYEE_NUMBER,
                               ASM.EMPLOYEE_FULL_NAME
                          INTO var_employee_number,
                               var_employee_full_name
                          FROM ATET_SB_MEMBERS  ASM
                         WHERE ASM.MEMBER_ID = P_MEMBER_ID;    
                             
                                      
                         SELECT BANK_ACCOUNT_ID,
                                BANK_ACCOUNT_NAME,
                                BANK_ACCOUNT_NUM,
                                CURRENCY_CODE
                           INTO var_banks_account_id,
                                var_banks_account_name,
                                var_banks_account_num,
                                var_banks_currency_code
                           FROM ATET_SB_BANK_ACCOUNTS
                          WHERE 1 = 1
                            AND ROWNUM = 1;
                                
                    EXCEPTION WHEN OTHERS THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
                        RAISE PRE_PROCESSING_EXCEPTION;
                    END;   
                    
                    
                    IF P_IS_SAVING_RETIREMENT = 'N' THEN    
                        /**********************************************************/
                        /*******          INSERT ATET_SB_RECEIPTS_ALL          ****/
                        /**********************************************************/
                        
                        BEGIN
                        
                            INSERT 
                              INTO ATET_SB_RECEIPTS_ALL (RECEIPT_ID,
                                                         RECEIPT_NUMBER,
                                                         RECEIPT_DATE,
                                                         STATUS_LOOKUP_CODE,
                                                         RECEIPT_TYPE_FLAG,
                                                         MEMBER_ID,
                                                         MEMBER_NAME,
                                                         CURRENCY_CODE,
                                                         AMOUNT,
                                                         COMMENTS,
                                                         BANK_ACCOUNT_ID,
                                                         BANK_ACCOUNT_NUM,
                                                         BANK_ACCOUNT_NAME,
                                                         DEPOSIT_DATE,
                                                         ATTRIBUTE1,
                                                         REQUEST_ID,
                                                         REFERENCE_TYPE,
                                                         REFERENCE_ID,
                                                         LAST_UPDATED_BY,
                                                         LAST_UPDATE_DATE,
                                                         CREATED_BY,
                                                         CREATION_DATE)
                                                 VALUES (var_receipts_all_seq,
                                                         var_loan_receipt_seq,
                                                         TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                                                         'CREATED',
                                                         'LOANS',
                                                         P_MEMBER_ID,
                                                         var_employee_full_name,
                                                         var_banks_currency_code,
                                                         var_loan_balance,
                                                         var_employee_number || '|' || var_employee_full_name || '|' || var_loan_balance || '|' || var_deposit_date,
                                                         var_banks_account_id,
                                                         var_banks_account_num,
                                                         var_banks_account_name,
                                                         var_deposit_date,
                                                         var_header_id,
                                                         var_request_id,
                                                         'ATET_SB_LOANS_TRANSACTIONS',
                                                         var_loan_transaction_id,
                                                         var_user_id,
                                                         SYSDATE,
                                                         var_user_id,
                                                         SYSDATE);
                                                         
                        EXCEPTION WHEN OTHERS THEN
                            FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
                            RAISE INSERT_RECEIPTS_EXCEPTION;
                        END;                                                                                                                                                         
                        
                    END IF;
                              
                    /*********************************************/
                    /***         LIQUIDACIÓN DEL PRESTAMO      ***/
                    /*********************************************/
                    BEGIN
                        SETTLEMENT_LOAN(
                            P_LOAN_ID => P_LOAN_ID,
                            P_MEMBER_ID => P_MEMBER_ID,
                            P_PREPAID_SEQ => var_loan_receipt_seq,
                            P_LOAN_TRANSACTION_ID => var_loan_transaction_id
                                       );
                                       
                        IF P_IS_SAVING_RETIREMENT = 'Y' THEN
                            UPDATE ATET_SB_LOANS_TRANSACTIONS
                               SET ATTRIBUTE7 = 'CON RETIRO DE AHORRO'
                             WHERE 1 = 1
                               AND LOAN_TRANSACTION_ID = var_loan_transaction_id;
                        END IF;                                                       
                        
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'EXECUTE : SETTLEMENT_LOAN');
                    EXCEPTION WHEN OTHERS THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'EXECUTE : SETTLEMENT_LOAN' || SQLERRM);
                        RAISE SETTLEMENT_LOAN_EXCEPTION;
                    END;
                    
                    /**********************************************************/
                    /*******             IMPRESIÓN DE RECIBO               ****/
                    /**********************************************************/
                    BEGIN
                                                  
                        PRINT_PREPAID(
                            P_LOAN_ID => P_LOAN_ID, 
                            P_FOLIO => var_loan_receipt_seq,
                            P_BONUS => var_bonus_interest,
                            P_LOAN_TRANSACTION_ID=> var_loan_transaction_id
                                     );
                            
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'PRINT : PREPAID');
                    EXCEPTION WHEN OTHERS THEN
                        RAISE PRINT_PREPAID_EXCEPTION;
                    END;
                    
                    /*********************************************/
                    /***          CREACION DE POLIZA           ***/
                    /*********************************************/
                    BEGIN
                    
                        BEGIN
                        
                            var_member_account_id := GET_LOAN_MEMBER_ACCOUNT_ID(P_MEMBER_ID, P_LOAN_ID);
                            
                            FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET LOAN_MEMBER_ACCOUNT_ID');
                                                
                            SELECT ASMA.CODE_COMBINATION_ID
                              INTO var_not_rec_account_id
                              FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
                             WHERE 1 = 1
                               AND ASMA.MEMBER_ACCOUNT_ID = var_member_account_id
                               AND ASMA.MEMBER_ID = P_MEMBER_ID
                               AND ASMA.LOAN_ID = P_LOAN_ID;
                               
                            FND_FILE.PUT_LINE(FND_FILE.LOG, 'QUERY : ATET_SB_MEMBERS_ACCOUNTS');
                               
                        EXCEPTION WHEN OTHERS THEN
                            RAISE MEMBER_ACCOUNT_EXCEPTION;    
                        END;
                        
                        var_bank_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'BANK_CODE_COMB');
                        var_une_int_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'UNE_INT_CODE_COMB');
                        var_int_rec_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'INT_REC_CODE_COMB');
                        var_sav_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAV_CODE_COMB');
                        
                        var_bank_account_id := GET_CODE_COMBINATION_ID(var_bank_code_comb);
                        var_une_int_account_id := GET_CODE_COMBINATION_ID(var_une_int_code_comb);
                        var_int_rec_account_id := GET_CODE_COMBINATION_ID(var_int_rec_code_comb);
                        var_sav_account_id := GET_CODE_COMBINATION_ID(var_sav_code_comb);
                        
                        var_deb_cs_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'DEB_CS_CODE_COMB');
                        var_deb_pac_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'DEB_PAC_CODE_COMB');
                        
                        var_deb_cs_account_id := GET_CODE_COMBINATION_ID(var_deb_cs_code_comb);
                        var_deb_pac_account_id := GET_CODE_COMBINATION_ID(var_deb_pac_code_comb);
                        
                        var_description := 'PAGO ANTICIPADO : ' || var_employee_number      || 
                                                            '|' || var_employee_full_name   ||
                                                            '|' || var_loan_number          ||
                                                            '|' || TRIM(TO_CHAR(var_loan_balance,'$999,999.99'));
                        
                        
                        ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (
                            P_ENTITY_CODE        => 'LOANS',
                            P_EVENT_TYPE_CODE    => 'LOAN_PREPAID',
                            P_BATCH_NAME         => 'PAGO ANTICIPADO',
                            P_JOURNAL_NAME       => var_description,
                            P_HEADER_ID          => var_header_id );
                            
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'CREATE : XLA_HEADER');
                        
                        /*********************************************/
                        /***        GUARDAR BONIFICACIÓN          ****/
                        /*********************************************/
                        
                        IF var_bonus_interest > 0 THEN
                            
                          
                            SELECT ATET_SB_CONDONED_INTEREST_SEQ.NEXTVAL
                              INTO var_condoned_interest_id
                              FROM DUAL;
                          


                            INSERT
                              INTO ATET_SB_CONDONED_INTEREST (
                                   SUBSIDIZED_INTEREST_ID,
                                   SUBSIDIZED_INTEREST_NUMBER,
                                   LOAN_ID,
                                   LOAN_NUMBER,
                                   CONDONED_INTEREST_AMOUNT,
                                   XLA_HEADER_ID,
                                   XLA_LINE_NUMBER,
                                   ACCOUNTING_CLASS_CODE,
                                   CODE_COMBINATION_ID,
                                   DESCRIPTION,
                                   CREATION_DATE,
                                   CREATED_BY,
                                   LAST_UPDATE_DATE,
                                   LAST_UPDATED_BY)
                            VALUES (var_condoned_interest_id,
                                    var_condoned_interest_id,
                                    P_LOAN_ID,
                                    var_loan_number,
                                    var_bonus_interest,
                                    var_header_id,
                                    5,
                                    'PREPAID_SUBSIDIZED',
                                    var_int_rec_account_id,
                                    'INTERESES BONIFICADOS',
                                    SYSDATE,
                                    FND_GLOBAL.USER_ID,
                                    SYSDATE,
                                    FND_GLOBAL.USER_ID);
                         
                            ATET_SB_BACK_OFFICE_PKG.PRINT_INTEREST_SUBSIDY(P_LOAN_ID);
                        
                        END IF;
                        
                        /****************************************************/
                        /***            RETIRO DE AHORRO                  ***/
                        /****************************************************/
                        IF  P_IS_SAVING_RETIREMENT = 'Y' THEN
                            /********** CARGO : AHORRO                  *********/
                            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                                P_HEADER_ID               => var_header_id,
                                P_ROW_NUMBER              => 1,
                                P_CODE_COMBINATION_ID     => var_sav_account_id,
                                P_ACCOUNTING_CLASS_CODE   => 'SAVING_RETIREMENT',
                                P_ACCOUNTED_DR            => var_saving_retirement,
                                P_ACCOUNTED_CR            => 0,
                                P_DESCRIPTION             => 'RETIRO DE CAJA DE AHORRO : ' || var_employee_number || '-' || var_employee_full_name,
                                P_SOURCE_ID               => var_saving_transaction_id,
                                P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
                        ELSE
                            /*********  CARGO : BANCOS                  *********/
                            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                                P_HEADER_ID => var_header_id,
                                P_ROW_NUMBER => 1,
                                P_CODE_COMBINATION_ID => var_bank_account_id,
                                P_ACCOUNTING_CLASS_CODE => 'LOAN_PREPAID',
                                P_ACCOUNTED_DR => var_asps_loan_balance,
                                P_ACCOUNTED_CR => 0,
                                P_DESCRIPTION => var_description,
                                P_SOURCE_ID => NULL,
                                P_SOURCE_LINK_TABLE => NULL);
                                
                            FND_FILE.PUT_LINE(FND_FILE.LOG, 'CREATE : XLA_LINES 1');
                        END IF;    
                        /*********  ABONO : DOCUMENTOS POR COBRAR   *********/
                        ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                            P_HEADER_ID => var_header_id,
                            P_ROW_NUMBER => 2,
                            P_CODE_COMBINATION_ID => var_not_rec_account_id,
                            P_ACCOUNTING_CLASS_CODE => 'LOAN_PREPAID',
                            P_ACCOUNTED_DR => 0,
                            P_ACCOUNTED_CR => var_loan_balance,
                            P_DESCRIPTION => var_description,
                            P_SOURCE_ID => var_loan_transaction_id,
                            P_SOURCE_LINK_TABLE => 'ATET_SB_LOANS_TRANSACTIONS');
                            
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'CREATE : XLA_LINES 2');
                        
                        /*********  CARGO : INTERESES POR DEVENGAR  *********/
                        ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                            P_HEADER_ID => var_header_id,
                            P_ROW_NUMBER => 3,
                            P_CODE_COMBINATION_ID => var_une_int_account_id,
                            P_ACCOUNTING_CLASS_CODE => 'LOAN_PREPAID',
                            P_ACCOUNTED_DR => var_asps_payment_interest,
                            P_ACCOUNTED_CR => 0,
                            P_DESCRIPTION => var_description,
                            P_SOURCE_ID => var_loan_transaction_id,
                            P_SOURCE_LINK_TABLE => 'ATET_SB_LOANS_TRANSACTIONS');
                            
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'CREATE : XLA_LINES 3');
                            
                        /*********  ABONO : INTERESES COBRADOS      *********/    
                        IF P_BONUS_PERCENTAGE = 0 AND P_BONUS_AMOUNT = 0 THEN
                        
                            FND_FILE.PUT_LINE(FND_FILE.LOG, 'CASE : BONUS_PERCENTAGE = 0 AND BONUS_AMOUNT = 0');
                        
                            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                                P_HEADER_ID => var_header_id,
                                P_ROW_NUMBER => 4,
                                P_CODE_COMBINATION_ID => var_int_rec_account_id,
                                P_ACCOUNTING_CLASS_CODE => 'LOAN_PREPAID',
                                P_ACCOUNTED_DR => 0,
                                P_ACCOUNTED_CR => var_asps_payment_interest,
                                P_DESCRIPTION => var_description,
                                P_SOURCE_ID => var_loan_transaction_id,
                                P_SOURCE_LINK_TABLE => 'ATET_SB_LOANS_TRANSACTIONS');  
                                
                            FND_FILE.PUT_LINE(FND_FILE.LOG, 'CREATE : XLA_LINES 3');
                            
                        ELSE
     
                            
                            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                                P_HEADER_ID => var_header_id,
                                P_ROW_NUMBER => 4,
                                P_CODE_COMBINATION_ID => var_int_rec_account_id,
                                P_ACCOUNTING_CLASS_CODE => 'LOAN_PREPAID',
                                P_ACCOUNTED_DR => 0,
                                P_ACCOUNTED_CR => var_asps_payment_interest - var_bonus_interest,
                                P_DESCRIPTION => var_description,
                                P_SOURCE_ID => var_loan_transaction_id,
                                P_SOURCE_LINK_TABLE => 'ATET_SB_LOANS_TRANSACTIONS');
                                
                            IF  P_IS_SAVING_RETIREMENT = 'N' THEN
                                ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                                    P_HEADER_ID => var_header_id,
                                    P_ROW_NUMBER => 5,
                                    P_CODE_COMBINATION_ID => var_int_rec_account_id,
                                    P_ACCOUNTING_CLASS_CODE => 'LOAN_PREPAID',
                                    P_ACCOUNTED_DR => 0,
                                    P_ACCOUNTED_CR => var_bonus_interest,
                                    P_DESCRIPTION => 'BONIFICACIÓN DE INTERESES : ' || var_employee_number      || 
                                                                                '|' || var_employee_full_name   ||
                                                                                '|' || var_loan_number          ||
                                                                                '|' || TRIM(TO_CHAR(var_loan_balance,'$999,999.99')),
                                    P_SOURCE_ID => var_loan_transaction_id,
                                    P_SOURCE_LINK_TABLE => 'ATET_SB_LOANS_TRANSACTIONS');                                                    
                            END IF;
                            
                        END IF; 
                    
                    BEGIN
            
                        SELECT DISTINCT SUBSTR(PPF.PAYROLL_NAME, 0, 2) AS COMPANY_CODE
                          INTO var_code_company
                          FROM PAY_PAYROLLS_F       PPF,
                               PER_ASSIGNMENTS_F    PAF,
                               ATET_SB_MEMBERS      ASM            
                         WHERE 1 = 1
                           AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
                           AND PAF.PERSON_ID = ASM.PERSON_ID
                           AND ASM.MEMBER_ID = P_MEMBER_ID
                           AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
                           AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE;
                    
                    EXCEPTION WHEN OTHERS THEN
                        NULL;
                    END;
                    
                    IF var_asps_payment_interest_late > 0  THEN
                        
                        IF var_code_company = '02' THEN
                        
                            /*********  CARGO : INTERESES MORATORIOS POR DEVENGAR  *********/
                            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                                P_HEADER_ID               => var_header_id,
                                P_ROW_NUMBER              => 6,
                                P_CODE_COMBINATION_ID     => var_deb_cs_account_id,
                                P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST_LATE',
                                P_ACCOUNTED_DR            => var_asps_payment_interest_late,
                                P_ACCOUNTED_CR            => 0,
                                P_DESCRIPTION             => 'INTERESES MORATORIOS: ' || var_employee_number      || 
                                                                                  '|' || var_employee_full_name   ||
                                                                                  '|' || var_loan_number          ||
                                                                                  '|' || TRIM(TO_CHAR(var_asps_payment_interest_late,'$999,999.99')),
                                P_SOURCE_ID               => var_loan_transaction_id,
                                P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                        ELSIF var_code_company = '11' THEN
                            
                            /*********  CARGO : INTERESES MORATORIOS POR DEVENGAR  *********/
                            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                                P_HEADER_ID               => var_header_id,
                                P_ROW_NUMBER              => 6,
                                P_CODE_COMBINATION_ID     => var_deb_pac_account_id,
                                P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST_LATE',
                                P_ACCOUNTED_DR            => var_asps_payment_interest_late,
                                P_ACCOUNTED_CR            => 0,
                                P_DESCRIPTION             => 'INTERESES MORATORIOS: ' || var_employee_number      || 
                                                                                  '|' || var_employee_full_name   ||
                                                                                  '|' || var_loan_number          ||
                                                                                  '|' || TRIM(TO_CHAR(var_asps_payment_interest_late,'$999,999.99')),
                                P_SOURCE_ID               => var_loan_transaction_id,
                                P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                
                        END IF;
                                                                                         
                        /*********  ABONO : INTERESES MORATORIOS COBRADOS      *********/
                        ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                            P_HEADER_ID               => var_header_id,
                            P_ROW_NUMBER              => 6,
                            P_CODE_COMBINATION_ID     => var_int_rec_account_id,
                            P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST_LATE',
                            P_ACCOUNTED_DR            => 0,
                            P_ACCOUNTED_CR            => var_asps_payment_interest_late,
                            P_DESCRIPTION             => 'INTERESES MORATORIOS: ' || var_employee_number      || 
                                                                                  '|' || var_employee_full_name   ||
                                                                                  '|' || var_loan_number          ||
                                                                                  '|' || TRIM(TO_CHAR(var_asps_payment_interest_late,'$999,999.99')),
                            P_SOURCE_ID               => var_loan_transaction_id,
                            P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                        
                    END IF;      
                                            
                
                EXCEPTION WHEN OTHERS THEN
                    RAISE CREATION_GL_EXCEPTION;
                END;
                /************************************************************/
                /***        OUTPUT MOVIMIENTOS DE AHORRO                  ***/
                /************************************************************/
                IF P_IS_SAVING_RETIREMENT = 'Y' THEN
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS DEL AHORRO');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    
                    var_debit_amount := 0;
                    var_credit_amount := 0;
                    
                    FOR DETAIL IN SAVINGS_DETAILS LOOP
                    
                        var_debit_amount := var_debit_amount + DETAIL.DEBIT_AMOUNT;
                        var_credit_amount := var_credit_amount + DETAIL.CREDIT_AMOUNT;
                        
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(DETAIL.EARNED_DATE, 40, ' ')
                                                         ||RPAD(DETAIL.PERIOD_NAME, 40, ' ')
                                                         ||LPAD(DETAIL.DEBIT_AMOUNT,40, ' ')
                                                         ||LPAD(DETAIL.CREDIT_AMOUNT,40, ' '));
                    
                    END LOOP;
                    
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('RESUMEN:', 80, ' ')
                                    ||LPAD(var_debit_amount, 40, ' ')
                                    ||LPAD(var_credit_amount, 40, ' '));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('SALDO:', 80, ' ')
                                    ||LPAD(' ', 40, ' ')
                                    ||LPAD((var_credit_amount - var_debit_amount), 40, ' '));
                END IF;
                /************************************************************/
                /*          OUTPUT MOVIMIENTOS DE PRESTAMO                  */
                /************************************************************/
                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS DEL PRESTAMO');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                
                var_debit_amount := 0;
                var_credit_amount := 0;
                
                FOR DETAIL IN LOAN_TRANSACTION_DETAILS LOOP
                
                    var_debit_amount := var_debit_amount + DETAIL.DEBIT_AMOUNT;
                    var_credit_amount := var_credit_amount + DETAIL.CREDIT_AMOUNT;
                    
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(DETAIL.EARNED_DATE, 40, ' ')
                                                     ||RPAD(DETAIL.PERIOD_NAME, 40, ' ')
                                                     ||LPAD(DETAIL.DEBIT_AMOUNT,40, ' ')
                                                     ||LPAD(DETAIL.CREDIT_AMOUNT,40, ' '));
                
                END LOOP;
                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('RESUMEN:', 80, ' ')
                                ||LPAD(var_debit_amount, 40, ' ')
                                ||LPAD(var_credit_amount, 40, ' '));
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('SALDO:', 80, ' ')
                                ||LPAD(' ', 40, ' ')
                                ||LPAD((var_debit_amount - var_credit_amount), 40, ' '));
                                
                /************************************************************/
                /*          OUTPUT MOVIMIENTOS CONTABLES                    */
                /************************************************************/
                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS CONTABLES');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                
                var_debit_amount := 0;
                var_credit_amount := 0;
                
                FOR DETAIL IN ACCOUNTED_DETAILS LOOP
                
                    var_debit_amount := var_debit_amount + DETAIL.ACCOUNTED_DR;
                    var_credit_amount := var_credit_amount + DETAIL.ACCOUNTED_CR;
                    
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(GET_CODE_COMBINATION(DETAIL.CODE_COMBINATION_ID) , 40, ' ')
                                                     ||RPAD(DETAIL.DESCRIPTION, 40, ' ')
                                                     ||LPAD(DETAIL.ACCOUNTED_DR,40, ' ')
                                                     ||LPAD(DETAIL.ACCOUNTED_CR,40, ' '));
                
                END LOOP;
                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('TOTAL:', 80, ' ')
                                ||LPAD(var_debit_amount, 40, ' ')
                                ||LPAD(var_credit_amount, 40, ' '));
                
                
            ELSE   
                RAISE FATAL_EXCEPTION;
            END IF;
        
        ELSE
            RAISE HAS_EXPORTED_PAYMENTS_SCHEDULE;
        END IF;
        
        
        IF P_IS_SAVER = 'Y' THEN
        
            BEGIN
                SELECT ASMA.FINAL_BALANCE
                  INTO var_amount_saved
                  FROM ATET_SB_MEMBERS          ASM,
                       ATET_SB_MEMBERS_ACCOUNTS ASMA
                 WHERE ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID
                   AND ASM.MEMBER_ID = P_MEMBER_ID
                   AND ASM.MEMBER_ID = ASMA.MEMBER_ID
                   AND ASMA.LOAN_ID IS NULL
                   AND ASMA.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO';
            EXCEPTION WHEN OTHERS THEN
                NULL;
            END;            
        
            IF P_IS_SAVER = 'Y' AND var_amount_saved = 0 THEN 
                UPDATE ATET_SB_MEMBERS  ASM
                   SET ASM.IS_SAVER = 'N',
                       ASM.MEMBER_END_DATE = TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                       ASM.AMOUNT_TO_SAVE = NULL,
                       ASM.LAST_UPDATE_DATE = SYSDATE,
                       ASM.LAST_UPDATED_BY = var_user_id
                 WHERE 1 = 1
                   AND ASM.MEMBER_ID = P_MEMBER_ID;
            END IF;
        END IF;
        
        
        COMMIT;
        ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL;
        
    EXCEPTION
        WHEN QRY_LOAN_BALANCE THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: AL CONSULTAR EL SALDO DEL PRÉSTAMO.');
            P_RETCODE := 2;
        WHEN QRY_ASPS_PAYMENT_BALANCE THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: AL CONSULTAR EL CAPITAL E INTERES POR PAGAR DEL PRÉSTAMO.');
            P_RETCODE := 2;
        WHEN QRY_ASLT_PAYMENT_BALANCE THEN    
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: AL CONSULTAR EL CAPITAL E INTERES POR PAGAR DEL PRÉSTAMO.');
            P_RETCODE := 2;
        WHEN HAS_EXPORTED_PAYMENTS_SCHEDULE THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'EL PRESTAMO A LIQUIDAR TIENE ELEMENTOS DE NOMINA EXPORTADOS.');
            P_RETCODE := 1;
        WHEN FATAL_EXCEPTION THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: INCONSISTENCIA EN LOS DATOS.');
            P_RETCODE := 2;
        WHEN PRINT_PREPAID_EXCEPTION THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: AL IMPRIMIR REPORTE DE PAGO ANTICIPADO.');
            P_RETCODE := 2;
        WHEN SETTLEMENT_LOAN_EXCEPTION THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: AL LIQUIDAR EL PRESTAMO.' || SQLERRM);
            P_RETCODE := 2;
        WHEN CREATION_GL_EXCEPTION THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: AL CREAR LA CONTABILIDAD.');
            P_RETCODE := 2;
        WHEN MEMBER_ACCOUNT_EXCEPTION THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: AL CONSULTAR LA CUENTA DE DOCUMENTOS POR COBRAR DEL PRESTAMO.');
            P_RETCODE := 2;
        WHEN MEMBER_EXCEPTION THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: EL MIEMBRO NO ES AHORRADOR.');
            P_RETCODE := 2;
        WHEN SAVING_BALANCE_EXCEPTION THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: EL MIEMBRO NO CUENTA CON EL SUFICIENTE SALDO DE AHORRO PARA CONTINUAR CON EL PROCESO.');
            P_RETCODE := 2;
        WHEN INSERT_SAVING_EXCEPTION THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: INSERT_SAVING_EXCEPTION.');
            P_RETCODE := 2;
        WHEN SELECT_SAVING_EXCEPTION THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: SELECT_SAVING_EXCEPTION.');
            P_RETCODE := 2;
        WHEN UPDATE_SAVING_EXCEPTION THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: UPDATE_SAVING_EXCEPTION.');
            P_RETCODE := 2;
        WHEN OTHERS THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: OTHERS_EXCEPTION.');
            P_RETCODE := 2;
    END PROCESS_PREPAYMENT;
    
    
    PROCEDURE   PROCESS_PARCIAL_PREPAYMENT(
                    P_ERRBUF         OUT NOCOPY VARCHAR2,
                    P_RETCODE        OUT NOCOPY VARCHAR2,
                    P_MEMBER_ID                 NUMBER,
                    P_LOAN_ID                   NUMBER,
                    P_PAYMENT_AMOUNT            NUMBER,
                    P_TIME_PERIOD_ID            NUMBER,
                    P_IS_SAVING_RETIREMENT      VARCHAR2)
    IS
        var_result                  VARCHAR2(10);
        var_person_id               NUMBER;
        var_payment_date            DATE;
        var_time_period_id          NUMBER;
        var_period_name             VARCHAR2(100);
        var_payment_schedule_id     NUMBER;
        
        var_member_account_id       NUMBER;
        
        var_not_rec_account_id      NUMBER;
        var_bank_account_id         NUMBER;
        var_une_int_account_id      NUMBER;
        var_int_rec_account_id      NUMBER;
        
        var_bank_code_comb          VARCHAR2(100);
        var_une_int_code_comb       VARCHAR2(100);
        var_int_rec_code_comb       VARCHAR2(100);
                    
        var_description             VARCHAR2(1000);
        
        var_employee_number         VARCHAR2(100); 
        var_employee_full_name      VARCHAR2(100);
        var_loan_number             VARCHAR2(100);
        
        var_header_id               NUMBER;
        
        var_asps_payment_amount     NUMBER;
        var_asps_payment_interest   NUMBER;
        var_asps_payment_int_late   NUMBER;
        
        var_deb_cs_code_comb        VARCHAR2(100);
        var_deb_pac_code_comb       VARCHAR2(100);
                
        var_deb_cs_account_id       NUMBER;
        var_deb_pac_account_id      NUMBER;
        
        var_code_company            VARCHAR2(50);
        
        
        MEMBERS_EX              EXCEPTION;
        PAYMENTS_SCHEDULE_EX    EXCEPTION;
        PRINT_PREPAID_EX        EXCEPTION;
        MEMBER_ACCOUNT_EX       EXCEPTION;
        CREATION_GL_EX          EXCEPTION;
        COMPANY_EX              EXCEPTION;
        MEMBER_EXCEPTION                EXCEPTION;
        SAVING_BALANCE_EXCEPTION        EXCEPTION;
        INSERT_SAVING_EXCEPTION         EXCEPTION;
        SELECT_SAVING_EXCEPTION         EXCEPTION;
        UPDATE_SAVING_EXCEPTION         EXCEPTION;
        PRE_PROCESSING_EXCEPTION        EXCEPTION;
        INSERT_RECEIPTS_EXCEPTION       EXCEPTION;
        
        CURSOR SAVINGS_DETAILS IS
            SELECT ASST.EARNED_DATE,
                   ASST.PERIOD_NAME,
                   ASST.ELEMENT_NAME,
                   ASST.DEBIT_AMOUNT,
                   ASST.CREDIT_AMOUNT
              FROM ATET_SB_SAVINGS_TRANSACTIONS ASST
             WHERE 1 = 1
               AND ASST.MEMBER_ID = P_MEMBER_ID
             ORDER BY ASST.SAVING_TRANSACTION_ID;
        
        CURSOR LOAN_TRANSACTION_DETAILS IS
            SELECT ASLT.EARNED_DATE,
                   ASLT.PERIOD_NAME,
                   ASLT.DEBIT_AMOUNT,
                   ASLT.CREDIT_AMOUNT
              FROM ATET_SB_LOANS_TRANSACTIONS   ASLT
             WHERE LOAN_ID = P_LOAN_ID
             ORDER BY LOAN_TRANSACTION_ID;
        
        CURSOR ACCOUNTED_DETAILS IS
            SELECT AXL2.LINE_NUMBER,
                   AXL2.CODE_COMBINATION_ID,
                   AXL2.DESCRIPTION,
                   AXL2.ACCOUNTED_DR,
                   AXL2.ACCOUNTED_CR
              FROM ATET_XLA_LINES           AXL2
             WHERE 1 = 1
               AND AXL2.HEADER_ID = var_header_id
             ORDER BY AXL2.LINE_NUMBER;
             
        var_debit_amount                NUMBER;
        var_credit_amount               NUMBER;
        
        var_saving_balance              NUMBER := 0;
        var_member_saving_account_id    NUMBER := 0;
        var_saving_retirement           NUMBER := 0;
        var_saving_retirement_seq       NUMBER := 0;
        var_sav_code_comb               VARCHAR2(100);
        var_sav_account_id              NUMBER := 0;
        var_saving_transaction_id       NUMBER := 0;
        var_validate                    NUMBER;
        var_user_id                     NUMBER := FND_GLOBAL.USER_ID;
        var_request_id                  NUMBER := FND_GLOBAL.CONC_REQUEST_ID; 
        var_loan_transaction_id         NUMBER;
        
        var_loan_receipt_seq            NUMBER := 0;
        var_receipts_all_seq            NUMBER;
        
        var_banks_account_id            NUMBER;
        var_banks_account_name          VARCHAR2(100);
        var_banks_account_num           VARCHAR2(100);
        var_banks_currency_code         VARCHAR2(13);
        
        var_deposit_date                DATE := TO_DATE(SYSDATE, 'DD/MM/RRRR');
        
    BEGIN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'PROCESS_PARCIAL_PREPAYMENT(P_MEMBER_ID => ' || P_MEMBER_ID ||
                                                                  ',P_LOAN_ID => ' || P_LOAN_ID ||
                                                                  ',P_PAYMENT_AMOUNT => ' || P_PAYMENT_AMOUNT ||
                                                                  ',P_TIME_PERIOD_ID => ' || P_TIME_PERIOD_ID ||
                                                                  ')');
    
        BEGIN
            SELECT ASM.PERSON_ID,
                   ASM.EMPLOYEE_NUMBER,
                   ASM.EMPLOYEE_FULL_NAME
              INTO var_person_id,
                   var_employee_number,
                   var_employee_full_name
              FROM ATET_SB_MEMBERS  ASM
             WHERE 1 = 1
               AND ASM.MEMBER_ID = P_MEMBER_ID;
        EXCEPTION WHEN OTHERS THEN
            RAISE MEMBERS_EX;
        END;
        
        
        BEGIN
            
            SELECT DISTINCT SUBSTR(PPF.PAYROLL_NAME, 0, 2) AS COMPANY_CODE
              INTO var_code_company
              FROM PAY_PAYROLLS_F       PPF,
                   PER_ASSIGNMENTS_F    PAF,
                   ATET_SB_MEMBERS      ASM            
             WHERE 1 = 1
               AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
               AND PAF.PERSON_ID = ASM.PERSON_ID
               AND ASM.MEMBER_ID = P_MEMBER_ID
               AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
               AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE;
        
        EXCEPTION WHEN OTHERS THEN
            RAISE COMPANY_EX;
        END;
        
        
        BEGIN   
            SELECT ASPS.TIME_PERIOD_ID,
                   ASPS.PERIOD_NAME,
                   ASPS.PAYMENT_DATE,
                   ASPS.PAYMENT_SCHEDULE_ID,
                   ASL.LOAN_NUMBER
              INTO var_time_period_id,
                   var_period_name,
                   var_payment_date,
                   var_payment_schedule_id,
                   var_loan_number
              FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS,
                   ATET_SB_LOANS                ASL
             WHERE 1 = 1
               AND ASPS.LOAN_ID = ASL.LOAN_ID
               AND ASPS.LOAN_ID = P_LOAN_ID
               AND ASPS.TIME_PERIOD_ID = P_TIME_PERIOD_ID
               AND ASPS.STATUS_FLAG NOT IN ('PAYED', 'REFINANCED');
        EXCEPTION WHEN OTHERS THEN
            RAISE PAYMENTS_SCHEDULE_EX;
        END;
        
        /*********************************************/
        /***               RETIRO DE AHORRO        ***/
        /*********************************************/
                
        IF  P_IS_SAVING_RETIREMENT = 'Y' THEN
                
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'CASE : IS_SAVING_RETIREMENT');
                    
            SELECT COUNT(ASM.MEMBER_ID)
              INTO var_validate
              FROM ATET_SB_MEMBERS  ASM 
             WHERE 1 = 1
               AND ASM.MEMBER_ID = P_MEMBER_ID
               AND ASM.IS_SAVER = 'Y';
                       
            IF var_validate > 0 THEN 
                        
                SELECT ASMA.FINAL_BALANCE
                  INTO var_saving_balance
                  FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
                 WHERE 1 = 1
                   AND ASMA.MEMBER_ID = P_MEMBER_ID
                   AND ASMA.LOAN_ID IS NULL
                   AND ASMA.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO';
                           
                var_debit_amount := 0;
                var_credit_amount := 0;
                           
                IF var_saving_balance >= P_PAYMENT_AMOUNT THEN
                        
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'CASE : var_saving_balance >= var_loan_balance.');
                            
                    var_member_saving_account_id := GET_SAVING_MEMBER_ACCOUNT_ID(P_MEMBER_ID,
                                                                                 GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAV_CODE_COMB'),
                                                                                 GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME')); 
                                                                                         
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET : var_member_saving_account_id.');
                                                                                            
                    var_saving_retirement := P_PAYMENT_AMOUNT;
                            
                
                    SELECT ATET_SB_SAVING_RETIREMENT_SEQ.NEXTVAL
                      INTO var_saving_retirement_seq 
                      FROM DUAL;                         
                                
                    var_debit_amount := var_saving_retirement;
                    var_credit_amount := 0;
                            
                    BEGIN
                            
                        INSERT INTO ATET_SB_SAVINGS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                                  MEMBER_ID,
                                                                  PAYROLL_RESULT_ID,
                                                                  PERSON_ID,
                                                                  EARNED_DATE,
                                                                  PERIOD_NAME,
                                                                  ELEMENT_NAME,
                                                                  ENTRY_VALUE,
                                                                  TRANSACTION_CODE,
                                                                  DEBIT_AMOUNT,
                                                                  CREDIT_AMOUNT,
                                                                  ATTRIBUTE1,
                                                                  ATTRIBUTE6,
                                                                  ACCOUNTED_FLAG,
                                                                  CREATION_DATE,
                                                                  CREATED_BY,
                                                                  LAST_UPDATE_DATE,
                                                                  LAST_UPDATED_BY)
                                                          VALUES (var_member_saving_account_id,
                                                                  P_MEMBER_ID,
                                                                  -1,
                                                                  GET_PERSON_ID(P_MEMBER_ID),
                                                                  TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                                                                  'RETIRO',
                                                                  'RETIRO DE AHORRO',
                                                                  var_saving_retirement,
                                                                  'RETIREMENT',
                                                                  var_debit_amount,
                                                                  var_credit_amount,
                                                                  var_saving_retirement_seq,
                                                                  'RETIRO POR PAGO ANTICIPADO',
                                                                  'ACCOUNTED',
                                                                  SYSDATE,
                                                                  var_user_id,
                                                                  SYSDATE,
                                                                  var_user_id);
                                                                          
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT : ATET_SB_SAVINGS_TRANSACTIONS.');
                            
                    EXCEPTION WHEN OTHERS THEN
                        RAISE INSERT_SAVING_EXCEPTION;                                                                          
                    END;
                                 
                    BEGIN         
                            
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'AND ASST.MEMBER_ACCOUNT_ID = ' ||var_member_saving_account_id ||
                                                       'AND ASST.MEMBER_ID = ' ||P_MEMBER_ID ||
                                                       'AND ASST.PERSON_ID = ' ||GET_PERSON_ID(P_MEMBER_ID)||
                                                       'AND ASST.ENTRY_VALUE = ' || var_saving_retirement||
                                                       'AND ASST.DEBIT_AMOUNT = ' || var_debit_amount ||
                                                       'AND ASST.CREDIT_AMOUNT = '||var_credit_amount||
                                                       'AND ASST.ATTRIBUTE1 = '||var_saving_retirement_seq);  
                                                      
                        SELECT ASST.SAVING_TRANSACTION_ID
                          INTO var_saving_transaction_id
                          FROM ATET_SB_SAVINGS_TRANSACTIONS ASST
                         WHERE 1 = 1
                           AND ASST.MEMBER_ACCOUNT_ID = var_member_saving_account_id
                           AND ASST.MEMBER_ID = P_MEMBER_ID
                           AND ASST.PERSON_ID = GET_PERSON_ID(P_MEMBER_ID)
                           AND ASST.PERIOD_NAME = 'RETIRO'
                           AND ASST.ELEMENT_NAME = 'RETIRO DE AHORRO'
                           AND ASST.ENTRY_VALUE = var_saving_retirement
                           AND ASST.TRANSACTION_CODE = 'RETIREMENT'
                           AND ASST.DEBIT_AMOUNT = var_debit_amount
                           AND ASST.CREDIT_AMOUNT = var_credit_amount
                           AND ASST.ATTRIBUTE1 = var_saving_retirement_seq;
                    EXCEPTION WHEN OTHERS THEN
                        RAISE SELECT_SAVING_EXCEPTION;
                    END;
                            
                    BEGIN
                                                                      
                        UPDATE ATET_SB_MEMBERS_ACCOUNTS
                           SET DEBIT_BALANCE = DEBIT_BALANCE + var_debit_amount,
                               CREDIT_BALANCE = CREDIT_BALANCE + var_credit_amount,
                               LAST_TRANSACTION_DATE = SYSDATE               
                         WHERE MEMBER_ID = P_MEMBER_ID
                           AND MEMBER_ACCOUNT_ID = var_member_saving_account_id;

                              
                        UPDATE ATET_SB_MEMBERS_ACCOUNTS
                           SET FINAL_BALANCE = CREDIT_BALANCE - DEBIT_BALANCE,
                               LAST_UPDATE_DATE = SYSDATE,
                               LAST_UPDATED_BY = var_user_id             
                         WHERE MEMBER_ID = P_MEMBER_ID
                           AND MEMBER_ACCOUNT_ID = var_member_saving_account_id;
                            
                    EXCEPTION WHEN OTHERS THEN
                        RAISE UPDATE_SAVING_EXCEPTION;
                    END;
                    
                         
                        
                ELSE
                    RAISE SAVING_BALANCE_EXCEPTION;
                END IF;
                    
            ELSE
                RAISE MEMBER_EXCEPTION;
            END IF;
            
                
        END IF;
   
        
        var_result := INSERT_LOAN_TRANSACTION(P_EXPORT_REQUEST_ID => -1,
                                              P_PAYROLL_RESULT_ID => -1,
                                              P_PERSON_ID => var_person_id,
                                              P_RUN_RESULT_ID => -1,
                                              P_EARNED_DATE => var_payment_date,
                                              P_TIME_PERIOD_ID => var_time_period_id,
                                              P_PERIOD_NAME => var_period_name,
                                              P_ELEMENT_NAME => 'PAGO ANTICIPADO',
                                              P_ENTRY_NAME => 'Pay Value',
                                              P_ENTRY_UNITS => 'Dinero',
                                              P_ENTRY_VALUE => P_PAYMENT_AMOUNT,
                                              P_DEBIT_AMOUNT => 0,
                                              P_CREDIT_AMOUNT => P_PAYMENT_AMOUNT,
                                              P_PAYMENT_SCHEDULE_ID => var_payment_schedule_id);
                                              
        
           
        INSERT INTO
            ATET_SB_LOANS_TRANSACTIONS(
                MEMBER_ACCOUNT_ID,
                MEMBER_ID,
                PAYROLL_RESULT_ID,
                LOAN_ID,
                PERSON_ID,
                RUN_RESULT_ID,
                EARNED_DATE,
                TIME_PERIOD_ID,
                PERIOD_NAME,
                ELEMENT_NAME,
                ENTRY_NAME,
                ENTRY_UNITS,
                ENTRY_VALUE,
                TRANSACTION_CODE,
                DEBIT_AMOUNT,
                CREDIT_AMOUNT,
                PAYMENT_AMOUNT,
                PAYMENT_CAPITAL,
                PAYMENT_INTEREST,
                PAYMENT_INTEREST_LATE,
                REQUEST_ID,
                ACCOUNTED_FLAG,
                ATTRIBUTE6,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY)
        SELECT  MEMBER_ACCOUNT_ID,
                MEMBER_ID,
                PAYROLL_RESULT_ID,
                LOAN_ID,
                PERSON_ID,
                RUN_RESULT_ID,
                EARNED_DATE,
                TIME_PERIOD_ID,
                ELEMENT_NAME,
                ELEMENT_NAME,
                ENTRY_NAME,
                ENTRY_UNITS,
                P_PAYMENT_AMOUNT,
                TRANSACTION_CODE,
                DEBIT_AMOUNT,
                P_PAYMENT_AMOUNT,
                P_PAYMENT_AMOUNT,
                SUM(PAYMENT_CAPITAL),
                SUM(PAYMENT_INTEREST),
                SUM(PAYMENT_INTEREST_LATE),
                REQUEST_ID,
                'ACCOUNTED',
                'PAGO ANTICIPADO: TIME_PERIOD_ID='||TIME_PERIOD_ID||',PERIOD_NAME='|| PERIOD_NAME,
                SYSDATE,
                CREATED_BY,
                SYSDATE,
                LAST_UPDATED_BY
          FROM ATET_SB_LOANS_TRANSACTIONS   ASLT 
         WHERE 1 = 1 
           AND ASLT.MEMBER_ID = P_MEMBER_ID
           AND ASLT.PERSON_ID = var_person_id
           AND ASLT.TIME_PERIOD_ID = var_time_period_id
           AND ASLT.PERIOD_NAME = var_period_name
           AND ASLT.ELEMENT_NAME = 'PAGO ANTICIPADO'
           AND ASLT.LOAN_ID = P_LOAN_ID
         GROUP BY MEMBER_ACCOUNT_ID,
                  MEMBER_ID,
                  PAYROLL_RESULT_ID,
                  LOAN_ID,
                  PERSON_ID,
                  RUN_RESULT_ID,
                  EARNED_DATE,
                  TIME_PERIOD_ID,
                  PERIOD_NAME,
                  ELEMENT_NAME,
                  ENTRY_NAME,
                  ENTRY_UNITS,
                  TRANSACTION_CODE,
                  DEBIT_AMOUNT,
                  REQUEST_ID,
                  CREATED_BY,
                  LAST_UPDATED_BY;
           
        
        DELETE FROM ATET_SB_LOANS_TRANSACTIONS ASLT
         WHERE 1 = 1 
           AND ASLT.MEMBER_ID = P_MEMBER_ID
           AND ASLT.PERSON_ID = var_person_id
           AND ASLT.TIME_PERIOD_ID = var_time_period_id
           AND ASLT.PERIOD_NAME = var_period_name
           AND ASLT.LOAN_ID = P_LOAN_ID
           AND ASLT.ELEMENT_NAME = 'PAGO ANTICIPADO';
           
                                             
        IF var_result = 'Y' THEN
        

            /*********************************************/
            /***            IMPRESIÓN DE RECIBO        ***/
            /*********************************************/
            BEGIN
                
                SELECT ASLT.LOAN_TRANSACTION_ID
                  INTO var_loan_transaction_id
                  FROM ATET_SB_LOANS_TRANSACTIONS   ASLT
                 WHERE 1 = 1
                   AND ASLT.MEMBER_ID = P_MEMBER_ID
                   AND ASLT.PERSON_ID = var_person_id
                   AND ASLT.TIME_PERIOD_ID = var_time_period_id
                   AND ASLT.LOAN_ID = P_LOAN_ID;
                
                IF P_IS_SAVING_RETIREMENT = 'N' THEN
                
                    SELECT ATET_SB_RECEIPT_NUMBER_SEQ.NEXTVAL
                      INTO var_loan_receipt_seq 
                      FROM DUAL;                         
                             
                             
                    SELECT ATET_SB_RECEIPTS_ALL_SEQ.NEXTVAL
                      INTO var_receipts_all_seq
                      FROM DUAL;   
                      
                     UPDATE ATET_SB_LOANS_TRANSACTIONS   ASLT
                       SET ASLT.ATTRIBUTE1 = var_loan_receipt_seq 
                     WHERE 1 = 1
                       AND ASLT.LOAN_ID = P_LOAN_ID
                       AND ASLT.LOAN_TRANSACTION_ID = var_loan_transaction_id;
                       
                ELSIF P_IS_SAVING_RETIREMENT = 'Y'THEN
                
                    SELECT ATET_SB_PREPAID_SEQ.NEXTVAL
                      INTO var_loan_receipt_seq
                      FROM DUAL;
                      
                     UPDATE ATET_SB_LOANS_TRANSACTIONS   ASLT
                       SET ASLT.ATTRIBUTE1 = var_loan_receipt_seq,
                           ASLT.ATTRIBUTE7 = 'CON RETIRO DE AHORRO'
                     WHERE 1 = 1
                       AND ASLT.LOAN_ID = P_LOAN_ID
                       AND ASLT.LOAN_TRANSACTION_ID = var_loan_transaction_id;
                       
                END IF;
                      
                        
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'PRINT : PREPAID');
            EXCEPTION WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
                RAISE PRINT_PREPAID_EX;
            END; 
            
            
            /*********************************************/
            /***          CREACION DE POLIZA           ***/
            /*********************************************/
            BEGIN
                
                BEGIN
                    
                    var_member_account_id := GET_LOAN_MEMBER_ACCOUNT_ID(P_MEMBER_ID, P_LOAN_ID);
                                            
                    SELECT ASMA.CODE_COMBINATION_ID
                      INTO var_not_rec_account_id
                      FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
                     WHERE 1 = 1
                       AND ASMA.MEMBER_ACCOUNT_ID = var_member_account_id
                       AND ASMA.MEMBER_ID = P_MEMBER_ID
                       AND ASMA.LOAN_ID = P_LOAN_ID;
                           
                EXCEPTION WHEN OTHERS THEN
                    RAISE MEMBER_ACCOUNT_EX;    
                END;
                    
                
                var_bank_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'BANK_CODE_COMB');
                var_une_int_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'UNE_INT_CODE_COMB');
                var_int_rec_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'INT_REC_CODE_COMB');
                var_sav_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAV_CODE_COMB');
                    
                var_bank_account_id := GET_CODE_COMBINATION_ID(var_bank_code_comb);
                var_une_int_account_id := GET_CODE_COMBINATION_ID(var_une_int_code_comb);
                var_int_rec_account_id := GET_CODE_COMBINATION_ID(var_int_rec_code_comb);
                var_sav_account_id := GET_CODE_COMBINATION_ID(var_sav_code_comb);
                
                var_deb_cs_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'DEB_CS_CODE_COMB');
                var_deb_pac_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'DEB_PAC_CODE_COMB');
                
                var_deb_cs_account_id := GET_CODE_COMBINATION_ID(var_deb_cs_code_comb);
                var_deb_pac_account_id := GET_CODE_COMBINATION_ID(var_deb_pac_code_comb);
                    
                var_description := 'PAGO ANTICIPADO : ' || var_employee_number      || 
                                                    '|' || var_employee_full_name   ||
                                                    '|' || var_loan_number          ||
                                                    '|' || TRIM(TO_CHAR(P_PAYMENT_AMOUNT,'$999,999.99'));
                                                    

                SELECT SUM(NVL(ASLT.PAYMENT_AMOUNT, 0)),
                       SUM(NVL(ASLT.PAYMENT_INTEREST, 0)),
                       SUM(NVL(ASLT.PAYMENT_INTEREST_LATE, 0))
                  INTO var_asps_payment_amount,
                       var_asps_payment_interest,
                       var_asps_payment_int_late
                  FROM ATET_SB_LOANS_TRANSACTIONS ASLT
                 WHERE 1 = 1 
                   AND ASLT.MEMBER_ID = P_MEMBER_ID
                   AND ASLT.PERSON_ID = var_person_id
                   AND ASLT.TIME_PERIOD_ID = var_time_period_id
                   AND ASLT.PERIOD_NAME = 'PAGO ANTICIPADO'
                   AND ASLT.ELEMENT_NAME = 'PAGO ANTICIPADO';
                    
                    
                ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (
                    P_ENTITY_CODE        => 'LOANS',
                    P_EVENT_TYPE_CODE    => 'LOAN_PREPAID',
                    P_BATCH_NAME         => 'PAGO ANTICIPADO',
                    P_JOURNAL_NAME       => var_description,
                    P_HEADER_ID          => var_header_id );
                    
                /****************************************************/
                /***            RETIRO DE AHORRO                  ***/
                /****************************************************/
                IF  P_IS_SAVING_RETIREMENT = 'Y' THEN
                    /********** CARGO : AHORRO                  *********/
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                        P_HEADER_ID               => var_header_id,
                        P_ROW_NUMBER              => 1,
                        P_CODE_COMBINATION_ID     => var_sav_account_id,
                        P_ACCOUNTING_CLASS_CODE   => 'SAVING_RETIREMENT',
                        P_ACCOUNTED_DR            => var_saving_retirement,
                        P_ACCOUNTED_CR            => 0,
                        P_DESCRIPTION             => 'RETIRO DE CAJA DE AHORRO : ' || var_employee_number || '-' || var_employee_full_name,
                        P_SOURCE_ID               => var_saving_transaction_id,
                        P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
                ELSE
                    /*********  CARGO : BANCOS                  *********/
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                        P_HEADER_ID => var_header_id,
                        P_ROW_NUMBER => 1,
                        P_CODE_COMBINATION_ID => var_bank_account_id,
                        P_ACCOUNTING_CLASS_CODE => 'LOAN_PREPAID',
                        P_ACCOUNTED_DR => var_asps_payment_amount,
                        P_ACCOUNTED_CR => 0,
                        P_DESCRIPTION => var_description,
                        P_SOURCE_ID => NULL,
                        P_SOURCE_LINK_TABLE => NULL);
                            
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'CREATE : XLA_LINES 1');
                END IF;   
                        
                /*********  ABONO : DOCUMENTOS POR COBRAR   *********/
                ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                    P_HEADER_ID => var_header_id,
                    P_ROW_NUMBER => 2,
                    P_CODE_COMBINATION_ID => var_not_rec_account_id,
                    P_ACCOUNTING_CLASS_CODE => 'LOAN_PREPAID',
                    P_ACCOUNTED_DR => 0,
                    P_ACCOUNTED_CR => var_asps_payment_amount,
                    P_DESCRIPTION => var_description,
                    P_SOURCE_ID => var_loan_transaction_id,
                    P_SOURCE_LINK_TABLE => 'ATET_SB_LOANS_TRANSACTIONS');
                    
                /*********  CARGO : INTERESES POR DEVENGAR  *********/
                ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                    P_HEADER_ID => var_header_id,
                    P_ROW_NUMBER => 3,
                    P_CODE_COMBINATION_ID => var_une_int_account_id,
                    P_ACCOUNTING_CLASS_CODE => 'LOAN_PREPAID',
                    P_ACCOUNTED_DR => var_asps_payment_interest,
                    P_ACCOUNTED_CR => 0,
                    P_DESCRIPTION => var_description,
                    P_SOURCE_ID => P_LOAN_ID,
                    P_SOURCE_LINK_TABLE => 'ATET_SB_LOANS');
                        
                /*********  ABONO : INTERESES COBRADOS      *********/    
                    
                ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                    P_HEADER_ID => var_header_id,
                    P_ROW_NUMBER => 4,
                    P_CODE_COMBINATION_ID => var_int_rec_account_id,
                    P_ACCOUNTING_CLASS_CODE => 'LOAN_PREPAID',
                    P_ACCOUNTED_DR => 0,
                    P_ACCOUNTED_CR => var_asps_payment_interest,
                    P_DESCRIPTION => var_description,
                    P_SOURCE_ID => P_LOAN_ID,
                    P_SOURCE_LINK_TABLE => 'ATET_SB_LOANS');  
                    
                IF var_asps_payment_int_late > 0 THEN
                
                    IF var_code_company = '02' THEN
                    
                        /*********  CARGO : INTERESES MORATORIOS POR DEVENGAR  *********/
                        ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                            P_HEADER_ID               => var_header_id,
                            P_ROW_NUMBER              => 5,
                            P_CODE_COMBINATION_ID     => var_deb_cs_account_id,
                            P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST_LATE',
                            P_ACCOUNTED_DR            => var_asps_payment_int_late,
                            P_ACCOUNTED_CR            => 0,
                            P_DESCRIPTION             => var_description,
                            P_SOURCE_ID               => P_LOAN_ID,
                            P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');
                    ELSIF var_code_company = '11' THEN
                        
                        /*********  CARGO : INTERESES MORATORIOS POR DEVENGAR  *********/
                        ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                            P_HEADER_ID               => var_header_id,
                            P_ROW_NUMBER              => 5,
                            P_CODE_COMBINATION_ID     => var_deb_pac_account_id,
                            P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST_LATE',
                            P_ACCOUNTED_DR            => var_asps_payment_int_late,
                            P_ACCOUNTED_CR            => 0,
                            P_DESCRIPTION             => var_description,
                            P_SOURCE_ID               => P_LOAN_ID,
                            P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');
                            
                    END IF;
                                                                                     
                    /*********  ABONO : INTERESES MORATORIOS COBRADOS      *********/
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                        P_HEADER_ID               => var_header_id,
                        P_ROW_NUMBER              => 6,
                        P_CODE_COMBINATION_ID     => var_int_rec_account_id,
                        P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST_LATE',
                        P_ACCOUNTED_DR            => 0,
                        P_ACCOUNTED_CR            => var_asps_payment_int_late,
                        P_DESCRIPTION             => var_description,
                        P_SOURCE_ID               => P_LOAN_ID,
                        P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');
                                                                   
                END IF;                        
                
            EXCEPTION WHEN OTHERS THEN
                RAISE CREATION_GL_EX;
            END;
        
        END IF;
                                              
        IF var_result = 'Y' THEN
            COMMIT;
            
            IF P_IS_SAVING_RETIREMENT = 'N' THEN
                /*********************************************/
                /***            IMPRESIÓN DE RECIBO        ***/
                /*********************************************/
                 BEGIN                         
                        
                          
                    SELECT ASM.EMPLOYEE_NUMBER,
                           ASM.EMPLOYEE_FULL_NAME
                      INTO var_employee_number,
                           var_employee_full_name
                      FROM ATET_SB_MEMBERS  ASM
                     WHERE ASM.MEMBER_ID = P_MEMBER_ID;    
                         
                                  
                     SELECT BANK_ACCOUNT_ID,
                            BANK_ACCOUNT_NAME,
                            BANK_ACCOUNT_NUM,
                            CURRENCY_CODE
                       INTO var_banks_account_id,
                            var_banks_account_name,
                            var_banks_account_num,
                            var_banks_currency_code
                       FROM ATET_SB_BANK_ACCOUNTS
                      WHERE 1 = 1
                        AND ROWNUM = 1;
                            
                EXCEPTION WHEN OTHERS THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
                    RAISE PRE_PROCESSING_EXCEPTION;
                END;   
                    
                /**********************************************************/
                /*******          INSERT ATET_SB_RECEIPTS_ALL          ****/
                /**********************************************************/
                    
                BEGIN
                    
                    INSERT 
                      INTO ATET_SB_RECEIPTS_ALL (RECEIPT_ID,
                                                 RECEIPT_NUMBER,
                                                 RECEIPT_DATE,
                                                 STATUS_LOOKUP_CODE,
                                                 RECEIPT_TYPE_FLAG,
                                                 MEMBER_ID,
                                                 MEMBER_NAME,
                                                 CURRENCY_CODE,
                                                 AMOUNT,
                                                 COMMENTS,
                                                 BANK_ACCOUNT_ID,
                                                 BANK_ACCOUNT_NUM,
                                                 BANK_ACCOUNT_NAME,
                                                 DEPOSIT_DATE,
                                                 ATTRIBUTE1,
                                                 REQUEST_ID,
                                                 REFERENCE_TYPE,
                                                 REFERENCE_ID,
                                                 LAST_UPDATED_BY,
                                                 LAST_UPDATE_DATE,
                                                 CREATED_BY,
                                                 CREATION_DATE)
                                         VALUES (var_receipts_all_seq,
                                                 var_loan_receipt_seq,
                                                 TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                                                 'CREATED',
                                                 'LOANS',
                                                 P_MEMBER_ID,
                                                 var_employee_full_name,
                                                 var_banks_currency_code,
                                                 P_PAYMENT_AMOUNT,
                                                 var_employee_number || '|' || var_employee_full_name || '|' || P_PAYMENT_AMOUNT || '|' || var_deposit_date,
                                                 var_banks_account_id,
                                                 var_banks_account_num,
                                                 var_banks_account_name,
                                                 var_deposit_date,
                                                 var_header_id,
                                                 var_request_id,
                                                 'ATET_SB_LOANS_TRANSACTIONS',
                                                 var_loan_transaction_id,
                                                 var_user_id,
                                                 SYSDATE,
                                                 var_user_id,
                                                 SYSDATE);
                                                     
                EXCEPTION WHEN OTHERS THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
                    RAISE INSERT_RECEIPTS_EXCEPTION;
                END;                 
                
                
            ELSIF P_IS_SAVING_RETIREMENT = 'Y' THEN
                    PRINT_SAVING_TRANSACTION(
                        P_SAVING_TRANSACTION_ID => var_saving_transaction_id);  
            END IF;
            
            PRINT_PREPAID(
                P_LOAN_ID => P_LOAN_ID, 
                P_FOLIO => var_loan_receipt_seq,
                P_BONUS => 0,
                P_LOAN_TRANSACTION_ID=> var_loan_transaction_id
                         );
            
            ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'COMMIT EJECUTADO.');
                
            
            
                /************************************************************/
                /***        OUTPUT MOVIMIENTOS DE AHORRO                  ***/
                /************************************************************/
                IF P_IS_SAVING_RETIREMENT = 'Y' THEN
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS DEL AHORRO');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    
                    var_debit_amount := 0;
                    var_credit_amount := 0;
                    
                    FOR DETAIL IN SAVINGS_DETAILS LOOP
                    
                        var_debit_amount := var_debit_amount + DETAIL.DEBIT_AMOUNT;
                        var_credit_amount := var_credit_amount + DETAIL.CREDIT_AMOUNT;
                        
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(DETAIL.EARNED_DATE, 40, ' ')
                                                         ||RPAD(DETAIL.PERIOD_NAME, 40, ' ')
                                                         ||LPAD(DETAIL.DEBIT_AMOUNT,40, ' ')
                                                         ||LPAD(DETAIL.CREDIT_AMOUNT,40, ' '));
                    
                    END LOOP;
                    
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('RESUMEN:', 80, ' ')
                                    ||LPAD(var_debit_amount, 40, ' ')
                                    ||LPAD(var_credit_amount, 40, ' '));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('SALDO:', 80, ' ')
                                    ||LPAD(' ', 40, ' ')
                                    ||LPAD((var_credit_amount - var_debit_amount), 40, ' '));
                END IF;
                
                /************************************************************/
                /*          OUTPUT MOVIMIENTOS DE PRESTAMO                  */
                /************************************************************/
                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS DEL PRESTAMO');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                
                var_debit_amount := 0;
                var_credit_amount := 0;
                
                FOR DETAIL IN LOAN_TRANSACTION_DETAILS LOOP
                
                    var_debit_amount := var_debit_amount + DETAIL.DEBIT_AMOUNT;
                    var_credit_amount := var_credit_amount + DETAIL.CREDIT_AMOUNT;
                    
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(DETAIL.EARNED_DATE, 40, ' ')
                                                     ||RPAD(DETAIL.PERIOD_NAME, 40, ' ')
                                                     ||LPAD(DETAIL.DEBIT_AMOUNT,40, ' ')
                                                     ||LPAD(DETAIL.CREDIT_AMOUNT,40, ' '));
                
                END LOOP;
                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('RESUMEN:', 80, ' ')
                                ||LPAD(var_debit_amount, 40, ' ')
                                ||LPAD(var_credit_amount, 40, ' '));
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('SALDO:', 80, ' ')
                                ||LPAD(' ', 40, ' ')
                                ||LPAD((var_debit_amount - var_credit_amount), 40, ' '));
                                
                /************************************************************/
                /*          OUTPUT MOVIMIENTOS CONTABLES                    */
                /************************************************************/
                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS CONTABLES');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                
                var_debit_amount := 0;
                var_credit_amount := 0;
                
                FOR DETAIL IN ACCOUNTED_DETAILS LOOP
                
                    var_debit_amount := var_debit_amount + DETAIL.ACCOUNTED_DR;
                    var_credit_amount := var_credit_amount + DETAIL.ACCOUNTED_CR;
                    
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(GET_CODE_COMBINATION(DETAIL.CODE_COMBINATION_ID) , 40, ' ')
                                                     ||RPAD(DETAIL.DESCRIPTION, 40, ' ')
                                                     ||LPAD(DETAIL.ACCOUNTED_DR,40, ' ')
                                                     ||LPAD(DETAIL.ACCOUNTED_CR,40, ' '));
                
                END LOOP;
                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('TOTAL:', 80, ' ')
                                ||LPAD(var_debit_amount, 40, ' ')
                                ||LPAD(var_credit_amount, 40, ' '));
            
            
            
            
        ELSIF var_result = 'N' THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ROLLBACK EJECUTADO.');
        END IF;    
        
     EXCEPTION
        WHEN MEMBERS_EX THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'MEMBERS_EX : ERROR AL CONSULTAR LOS DATOS DEL MIEMBRO.');
            P_RETCODE := 2;
        WHEN PAYMENTS_SCHEDULE_EX THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'PAYMENTS_SCHEDULE_EX : ERROR AL CONSULTAR LOS DATOS DEL PAGO ANTICIPADO.');
            P_RETCODE := 2;
        WHEN PRINT_PREPAID_EX THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'PRINT_PREPAID_EX : ERROR AL IMPRIMIR EL RECIBO.');
            P_RETCODE := 2;
        WHEN MEMBER_ACCOUNT_EX THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'MEMBER_ACCOUNT_EX : ERROR AL CONSULTAR EL MEMBER ACCOUNT.');
            P_RETCODE := 2;
        WHEN CREATION_GL_EX THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'CREATION_GL_EX : ERROR AL CREAR LA POLIZA.');
            P_RETCODE := 2;
        WHEN MEMBER_EXCEPTION THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: EL MIEMBRO NO ES AHORRADOR.');
            P_RETCODE := 2;
        WHEN SAVING_BALANCE_EXCEPTION THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: EL MIEMBRO NO CUENTA CON EL SUFICIENTE SALDO DE AHORRO PARA CONTINUAR CON EL PROCESO.');
            P_RETCODE := 2;
        WHEN INSERT_SAVING_EXCEPTION THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: INSERT_SAVING_EXCEPTION.');
            P_RETCODE := 2;
        WHEN SELECT_SAVING_EXCEPTION THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: SELECT_SAVING_EXCEPTION.');
            P_RETCODE := 2;
        WHEN UPDATE_SAVING_EXCEPTION THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: UPDATE_SAVING_EXCEPTION.');
            P_RETCODE := 2;
        WHEN OTHERS THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: OTHERS_EXCEPTION.');
            P_RETCODE := 2;
    END PROCESS_PARCIAL_PREPAYMENT;
    
    
    PROCEDURE   PRINT_PREPAID(
                    P_LOAN_ID               NUMBER,
                    P_FOLIO                 NUMBER,
                    P_BONUS                 NUMBER,
                    P_LOAN_TRANSACTION_ID   NUMBER)
    IS
        add_layout_boolean   BOOLEAN;
        v_request_id         NUMBER;
        waiting              BOOLEAN;
        phase                VARCHAR2 (80 BYTE);
        status               VARCHAR2 (80 BYTE);
        dev_phase            VARCHAR2 (80 BYTE);
        dev_status           VARCHAR2 (80 BYTE);
        V_message            VARCHAR2 (4000 BYTE);
    BEGIN
   
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'PRINT_PREPAID(P_LOAN_ID => ' || P_LOAN_ID || 
                                                     ',P_FOLIO  => ' || P_FOLIO  || 
                                                     ',P_BONUS => ' || P_BONUS ||
                                                     ',P_LOAN_TRANSACTION_ID => ' || P_LOAN_TRANSACTION_ID ||
                                                     ')'); 

        add_layout_boolean :=
            fnd_request.add_layout (
               template_appl_name   => 'PER',
               template_code        => 'ATET_SB_PRINT_PARTIAL_PREPAID',
               template_language    => 'Spanish', 
               template_territory   => 'Mexico', 
               output_format        => 'PDF' 
                                   );



        v_request_id :=
            fnd_request.submit_request (
               application => 'PER',
               program => 'ATET_SB_PRINT_PARTIAL_PREPAID',
               description => '',
               start_time => '',
               sub_request => FALSE,
               argument1 => TO_CHAR(P_LOAN_TRANSACTION_ID),
               argument2 => TO_CHAR(P_FOLIO)
                                       );
        
        STANDARD.COMMIT;
                 
        waiting :=
            fnd_concurrent.wait_for_request (
                request_id => v_request_id,
                interval => 1,
                max_wait => 0,
                phase => phase,
                status => status,
                dev_phase => dev_phase,
                dev_status => dev_status,
                message => V_message
                                        );
    EXCEPTION WHEN OTHERS THEN
        RAISE;  
    END PRINT_PREPAID;
    
    
    PROCEDURE   VOLUNTARY_CONTRIBUTION(
                    P_ERRBUF         OUT NOCOPY  VARCHAR2,
                    P_RETCODE        OUT NOCOPY  VARCHAR2,
                    P_MEMBER_ID      NUMBER,
                    P_SAVING_AMOUNT  NUMBER,
                    P_DEPOSIT_DATE   VARCHAR2)
    IS    
       
        var_user_id                     NUMBER := FND_GLOBAL.USER_ID;
        var_request_id                  NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        
        var_voluntary_contribution_seq  NUMBER;
        var_receipts_all_seq            NUMBER;
        
        var_member_account_id           NUMBER;
        var_debit_amount                NUMBER := 0;
        var_credit_amount               NUMBER := P_SAVING_AMOUNT;
        var_voluntary_contribution      NUMBER := P_SAVING_AMOUNT;
        var_deposit_date                DATE := TRUNC(TO_DATE(P_DEPOSIT_DATE,'RRRR/MM/DD HH24:MI:SS'));
        var_person_id                   NUMBER := GET_PERSON_ID(P_MEMBER_ID);
        var_employee_number             VARCHAR2(100);
        var_employee_full_name          VARCHAR2(500);
        
        var_saving_transaction_id       NUMBER;
        
        var_bank_code_comb              VARCHAR2(100);
        var_sav_code_comb               VARCHAR2(100);
        var_bank_account_id             NUMBER;
        var_sav_account_id              NUMBER;
        var_header_id                   NUMBER;
        
        var_debit_balance               NUMBER;
        var_credit_balance              NUMBER;
        var_final_balance               NUMBER;
        
        var_banks_account_id            NUMBER;
        var_banks_account_name          VARCHAR2(100);
        var_banks_account_num           VARCHAR2(100);
        var_banks_currency_code          VARCHAR2(13);
        
        CURSOR SAVINGS_DETAILS IS
            SELECT ASST.EARNED_DATE,
                   ASST.PERIOD_NAME,
                   ASST.ELEMENT_NAME,
                   ASST.DEBIT_AMOUNT,
                   ASST.CREDIT_AMOUNT
              FROM ATET_SB_SAVINGS_TRANSACTIONS ASST
             WHERE 1 = 1
               AND ASST.MEMBER_ID = P_MEMBER_ID
             ORDER BY ASST.SAVING_TRANSACTION_ID;
             
        PRE_PROCESSING_EXCEPTION     EXCEPTION;
        SAVING_TRANSACTION_EXCEPTION EXCEPTION;
        QUERY_TRANSACTION_EXCEPTION  EXCEPTION;
        CREATE_JOURNAL_EXCEPTION     EXCEPTION;
        INSERT_RECEIPTS_EXCEPTION    EXCEPTION;
        CREATE_OUTPUT_EXCEPTION      EXCEPTION;
        PRINT_RECEIPT_EXCEPTION      EXCEPTION;
    
    BEGIN
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'VOLUNTARY_CONTRIBUTION(P_MEMBER_ID => ' || P_MEMBER_ID ||
                                                              ',P_SAVING_AMOUNT => ' || P_SAVING_AMOUNT ||
                                                              ')');   
                                                              
        CREATE_ACCOUNT(GET_PERSON_ID(P_MEMBER_ID),
                       'SAVINGS_ELEMENT_NAME',
                       'SAV_CODE_COMB'); 
                            
        var_member_account_id := GET_SAVING_MEMBER_ACCOUNT_ID(P_MEMBER_ID,
                                                              GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAV_CODE_COMB'),
                                                              GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME'));   

        BEGIN           
                                                           
            SELECT ATET_SB_RECEIPT_NUMBER_SEQ.NEXTVAL
              INTO var_voluntary_contribution_seq 
              FROM DUAL;                         
             
             
            SELECT ATET_SB_RECEIPTS_ALL_SEQ.NEXTVAL
              INTO var_receipts_all_seq
              FROM DUAL;                 
            
              
            SELECT ASM.EMPLOYEE_NUMBER,
                   ASM.EMPLOYEE_FULL_NAME
              INTO var_employee_number,
                   var_employee_full_name
              FROM ATET_SB_MEMBERS  ASM
             WHERE ASM.MEMBER_ID = P_MEMBER_ID;    
             
                      
             SELECT BANK_ACCOUNT_ID,
                    BANK_ACCOUNT_NAME,
                    BANK_ACCOUNT_NUM,
                    CURRENCY_CODE
               INTO var_banks_account_id,
                    var_banks_account_name,
                    var_banks_account_num,
                    var_banks_currency_code
               FROM ATET_SB_BANK_ACCOUNTS
              WHERE 1 = 1
                AND ROWNUM = 1;
                
        EXCEPTION WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
            RAISE PRE_PROCESSING_EXCEPTION;
        END;       

        
        /**********************************************************/
        /*******      INSERT ATET_SB_SAVINGS_TRANSACTIONS      ****/
        /**********************************************************/
       
        BEGIN
        
            INSERT INTO ATET_SB_SAVINGS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                      MEMBER_ID,
                                                      PAYROLL_RESULT_ID,
                                                      PERSON_ID,
                                                      EARNED_DATE,
                                                      PERIOD_NAME,
                                                      ELEMENT_NAME,
                                                      ENTRY_VALUE,
                                                      TRANSACTION_CODE,
                                                      DEBIT_AMOUNT,
                                                      CREDIT_AMOUNT,
                                                      ATTRIBUTE1,
                                                      ACCOUNTED_FLAG,
                                                      CREATION_DATE,
                                                      CREATED_BY,
                                                      LAST_UPDATE_DATE,
                                                      LAST_UPDATED_BY)
                                              VALUES (var_member_account_id,
                                                      P_MEMBER_ID,
                                                      -1,
                                                      var_person_id,
                                                      TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                                                      'APORTACION',
                                                      'APORTACION VOLUNTARIA',
                                                      var_voluntary_contribution,
                                                      'CONTRIBUTION',
                                                      var_debit_amount,
                                                      var_credit_amount,
                                                      var_voluntary_contribution_seq,
                                                      'ACCOUNTED',
                                                      SYSDATE,
                                                      var_user_id,
                                                      SYSDATE,
                                                      var_user_id);

                                                          
            UPDATE ATET_SB_MEMBERS_ACCOUNTS
               SET DEBIT_BALANCE = DEBIT_BALANCE + var_debit_amount,
                   CREDIT_BALANCE = CREDIT_BALANCE + var_credit_amount,
                   LAST_TRANSACTION_DATE = SYSDATE               
             WHERE MEMBER_ID = P_MEMBER_ID
               AND MEMBER_ACCOUNT_ID = var_member_account_id;

                  
            UPDATE ATET_SB_MEMBERS_ACCOUNTS
               SET FINAL_BALANCE = CREDIT_BALANCE - DEBIT_BALANCE,
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = var_user_id             
             WHERE MEMBER_ID = P_MEMBER_ID
               AND MEMBER_ACCOUNT_ID = var_member_account_id;
               
        EXCEPTION WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
            RAISE SAVING_TRANSACTION_EXCEPTION;
        END;
        
        /**********************************************************/
        /*******      CONSULTA DE SAVING_TRANSACTION_ID        ****/
        /**********************************************************/
                    
        BEGIN        
        
            SELECT ASST.SAVING_TRANSACTION_ID
              INTO var_saving_transaction_id
              FROM ATET_SB_SAVINGS_TRANSACTIONS ASST
             WHERE 1 = 1
               AND ASST.MEMBER_ACCOUNT_ID = var_member_account_id
               AND ASST.MEMBER_ID = P_MEMBER_ID
               AND ASST.PERSON_ID = var_person_id
               AND ASST.PERIOD_NAME = 'APORTACION'
               AND ASST.ELEMENT_NAME = 'APORTACION VOLUNTARIA'
               AND ASST.ENTRY_VALUE = var_voluntary_contribution
               AND ASST.TRANSACTION_CODE = 'CONTRIBUTION'
               AND ASST.DEBIT_AMOUNT = var_debit_amount
               AND ASST.CREDIT_AMOUNT = var_credit_amount
               AND ASST.ATTRIBUTE1 = var_voluntary_contribution_seq;
               
        EXCEPTION WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
            RAISE QUERY_TRANSACTION_EXCEPTION;
        END;

        /**********************************************************/
        /*******             CREACIÓN DE POLIZA                ****/
        /**********************************************************/
        
        BEGIN
        
            var_bank_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'BANK_CODE_COMB');
            var_sav_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAV_CODE_COMB');
            var_bank_account_id := GET_CODE_COMBINATION_ID(var_bank_code_comb);
            var_sav_account_id := GET_CODE_COMBINATION_ID(var_sav_code_comb);
                 
            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (P_ENTITY_CODE        => 'SAVINGS',
                                                       P_EVENT_TYPE_CODE    => 'VOLUNTARY_CONTRIBUTION',
                                                       P_BATCH_NAME         => 'APORTACION VOLUNTARIA',
                                                       P_JOURNAL_NAME       => 'APORTACION VOLUNTARIA : ' || var_employee_number || '-' || var_employee_full_name,
                                                       P_HEADER_ID          => var_header_id);

            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,    
                                                     P_ROW_NUMBER              => 1,
                                                     P_CODE_COMBINATION_ID     => var_bank_account_id,
                                                     P_ACCOUNTING_CLASS_CODE   => 'VOLUNTARY_CONTRIBUTION',
                                                     P_ACCOUNTED_DR            => var_credit_amount,
                                                     P_ACCOUNTED_CR            => var_debit_amount,
                                                     P_DESCRIPTION             => var_employee_number || '|' 
                                                                               || var_employee_full_name || '|' 
                                                                               || var_voluntary_contribution || '|'
                                                                               || var_deposit_date,
                                                     P_SOURCE_ID               => var_saving_transaction_id,
                                                     P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');  
                                                                   
            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                     P_ROW_NUMBER              => 2,
                                                     P_CODE_COMBINATION_ID     => var_sav_account_id,
                                                     P_ACCOUNTING_CLASS_CODE   => 'VOLUNTARY_CONTRIBUTION',
                                                     P_ACCOUNTED_DR            => var_debit_amount,
                                                     P_ACCOUNTED_CR            => var_credit_amount,
                                                     P_DESCRIPTION             => var_employee_number || '|' 
                                                                               || var_employee_full_name || '|' 
                                                                               || var_voluntary_contribution || '|'
                                                                               || var_deposit_date,
                                                     P_SOURCE_ID               => var_saving_transaction_id,
                                                     P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
        
        EXCEPTION WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
            RAISE CREATE_JOURNAL_EXCEPTION;
        END;
                                                             
        /**********************************************************/
        /*******          INSERT ATET_SB_RECEIPTS_ALL          ****/
        /**********************************************************/
        
        BEGIN
        
            INSERT 
              INTO ATET_SB_RECEIPTS_ALL (RECEIPT_ID,
                                         RECEIPT_NUMBER,
                                         RECEIPT_DATE,
                                         STATUS_LOOKUP_CODE,
                                         RECEIPT_TYPE_FLAG,
                                         MEMBER_ID,
                                         MEMBER_NAME,
                                         CURRENCY_CODE,
                                         AMOUNT,
                                         COMMENTS,
                                         BANK_ACCOUNT_ID,
                                         BANK_ACCOUNT_NUM,
                                         BANK_ACCOUNT_NAME,
                                         DEPOSIT_DATE,
                                         ATTRIBUTE1,
                                         REQUEST_ID,
                                         REFERENCE_TYPE,
                                         REFERENCE_ID,
                                         LAST_UPDATED_BY,
                                         LAST_UPDATE_DATE,
                                         CREATED_BY,
                                         CREATION_DATE)
                                 VALUES (var_receipts_all_seq,
                                         var_voluntary_contribution_seq,
                                         TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                                         'CREATED',
                                         'SAVINGS',
                                         P_MEMBER_ID,
                                         var_employee_full_name,
                                         var_banks_currency_code,
                                         var_voluntary_contribution,
                                         var_employee_number || '|' || var_employee_full_name || '|' || var_voluntary_contribution || '|' || var_deposit_date,
                                         var_banks_account_id,
                                         var_banks_account_num,
                                         var_banks_account_name,
                                         var_deposit_date,
                                         var_header_id,
                                         var_request_id,
                                         'ATET_SB_SAVINGS_TRANSACTIONS',
                                         var_saving_transaction_id,
                                         var_user_id,
                                         SYSDATE,
                                         var_user_id,
                                         SYSDATE);
                                         
        EXCEPTION WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
            RAISE INSERT_RECEIPTS_EXCEPTION;
        END;                                                                                                                                                         

        /**********************************************************/
        /*******             IMPRESIÓN DE RECIBO               ****/
        /**********************************************************/

        BEGIN
            PRINT_VOLUNTARY_CONTRIBUTION(P_SAVING_TRANSACTION_ID => var_saving_transaction_id);
        EXCEPTION WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
            RAISE PRINT_RECEIPT_EXCEPTION;
        END;                                                       
                                
        /**********************************************************/
        /*******                   OUTPUT                      ****/
        /**********************************************************/
        
        BEGIN    
                        
            SELECT ASMA.DEBIT_BALANCE,
                   ASMA.CREDIT_BALANCE,
                   ASMA.FINAL_BALANCE
              INTO var_debit_balance,
                   var_credit_balance,
                   var_final_balance
              FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
             WHERE 1 = 1
               AND ASMA.MEMBER_ID = P_MEMBER_ID
               AND ASMA.MEMBER_ACCOUNT_ID = var_member_account_id;
                        
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*', 95, '*'));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('FECHA', 15, ' ') ||
                                               RPAD('PERIODO', 20, ' ') ||
                                               RPAD('DESCRIPCION',20, ' ') ||
                                               LPAD('CARGO',20, ' ') ||
                                               LPAD('ABONO',20, ' '));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*', 95, '*'));
                        
            FOR detail IN SAVINGS_DETAILS LOOP
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(detail.EARNED_DATE, 15, ' ') ||
                                                   RPAD(detail.PERIOD_NAME, 20, ' ') ||
                                                   RPAD(detail.ELEMENT_NAME,20, ' ') ||
                                                   LPAD(detail.DEBIT_AMOUNT,20, ' ') ||
                                                   LPAD(detail.CREDIT_AMOUNT,20, ' '));
            END LOOP;
                        
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*', 95, '*'));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('RESUMEN : ', 55, ' ') ||
                                               LPAD(var_debit_balance,20, ' ') ||
                                               LPAD(var_credit_balance,20, ' '));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*', 95, '*'));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('SALDO : ', 55, ' ') ||
                                               LPAD(var_final_balance,40, ' '));
                                               
        EXCEPTION WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
            RAISE CREATE_OUTPUT_EXCEPTION;
        END;
                    
        /**********************************************************/
        /*******                   COMMIT                      ****/
        /**********************************************************/    
        
        COMMIT;
        ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL;                                  
                                                                      
    EXCEPTION
        WHEN PRE_PROCESSING_EXCEPTION THEN
            ROLLBACK;
            P_RETCODE := 1;
            P_ERRBUF := 'ERROR EN EL BLOQUE PRE_PROCESSING.' || SQLERRM;
        WHEN SAVING_TRANSACTION_EXCEPTION THEN
            ROLLBACK;
            P_RETCODE := 1;
            P_ERRBUF := 'ERROR EN EL BLOQUE SAVING_TRANSACTION.' || SQLERRM;
        WHEN QUERY_TRANSACTION_EXCEPTION THEN
            ROLLBACK;
            P_RETCODE := 1;
            P_ERRBUF := 'ERROR EN EL BLOQUE QUERY_TRANSACTION.' || SQLERRM;
        WHEN CREATE_JOURNAL_EXCEPTION THEN
            ROLLBACK;
            P_RETCODE := 1;
            P_ERRBUF := 'ERROR EN EL BLOQUE CREATE_JOURNAL.' || SQLERRM;
        WHEN INSERT_RECEIPTS_EXCEPTION THEN
            ROLLBACK;
            P_RETCODE := 1;
            P_ERRBUF := 'ERROR EN EL BLOQUE INSERT_RECEIPTS.' || SQLERRM;
        WHEN CREATE_OUTPUT_EXCEPTION THEN
            ROLLBACK;
            P_RETCODE := 1;
            P_ERRBUF := 'ERROR EN EL BLOQUE CREATE_OUTPUT.' || SQLERRM;
        WHEN PRINT_RECEIPT_EXCEPTION THEN
            ROLLBACK;
            P_RETCODE := 1;
            P_ERRBUF := 'ERROR EN EL BLOQUE PRINT_RECEIPT.' || SQLERRM;
    END VOLUNTARY_CONTRIBUTION;
    
    
    PROCEDURE   PRINT_VOLUNTARY_CONTRIBUTION(
                    P_SAVING_TRANSACTION_ID     NUMBER)
    IS
        add_layout_boolean   BOOLEAN;
        v_request_id         NUMBER;
        waiting              BOOLEAN;
        phase                VARCHAR2 (80 BYTE);
        status               VARCHAR2 (80 BYTE);
        dev_phase            VARCHAR2 (80 BYTE);
        dev_status           VARCHAR2 (80 BYTE);
        V_message            VARCHAR2 (4000 BYTE);
    BEGIN
   
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'PRINT_VOLUNTARY_CONTRIBUTION(P_SAVING_TRANSACTION_ID => ' || P_SAVING_TRANSACTION_ID || ')'); 

        add_layout_boolean :=
            fnd_request.add_layout (
               template_appl_name   => 'PER',
               template_code        => 'ATET_PRINT_CONTRIBUTION',
               template_language    => 'Spanish', 
               template_territory   => 'Mexico', 
               output_format        => 'PDF' 
                                   );



        v_request_id :=
            fnd_request.submit_request (
               application => 'PER',
               program => 'ATET_PRINT_CONTRIBUTION',
               description => '',
               start_time => '',
               sub_request => FALSE,
               argument1 => TO_CHAR(P_SAVING_TRANSACTION_ID)
                                       );
        
        STANDARD.COMMIT;
                 
        waiting :=
            fnd_concurrent.wait_for_request (
                request_id => v_request_id,
                interval => 1,
                max_wait => 0,
                phase => phase,
                status => status,
                dev_phase => dev_phase,
                dev_status => dev_status,
                message => V_message
                                        );
    EXCEPTION WHEN OTHERS THEN
        RAISE;  
    END PRINT_VOLUNTARY_CONTRIBUTION;
    
    
    PROCEDURE   REFINANCE_PAYMENT_SCHEDULE(
                    P_PAYMENT_SCHEDULE_ID       NUMBER,
                    P_PAYMENT_DATE              DATE)
    IS
        var_user_id     NUMBER := FND_GLOBAL.USER_ID;
    BEGIN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'REFINANCE_PAYMENT_SCHEDULE(P_PAYMENT_SCHEDULE_ID => ' || P_PAYMENT_SCHEDULE_ID || ')');
        
        INSERT 
          INTO ATET_SB_PAYMENTS_SCHEDULE(LOAN_ID,
                                         PAYMENT_NUMBER,
                                         PERIOD_NUMBER,
                                         TIME_PERIOD_ID,
                                         PERIOD_NAME,
                                         PAYMENT_DATE,
                                         PAYROLL_ID,
                                         ASSIGNMENT_ID,
                                         OPENING_BALANCE,
                                         PAYMENT_AMOUNT,
                                         PAYMENT_CAPITAL,
                                         PAYMENT_INTEREST,
                                         PAYMENT_INTEREST_LATE,
                                         PAYED_AMOUNT,
                                         PAYED_CAPITAL,
                                         PAYED_INTEREST,
                                         PAYED_INTEREST_LATE,
                                         OWED_AMOUNT,
                                         OWED_CAPITAL,
                                         OWED_INTEREST,
                                         OWED_INTEREST_LATE,
                                         FINAL_BALANCE,
                                         ACCRUAL_PAYMENT_AMOUNT,
                                         STATUS_FLAG,
                                         ATTRIBUTE5,
                                         CREATION_DATE,
                                         CREATED_BY,
                                         LAST_UPDATE_DATE,
                                         LAST_UPDATED_BY)
                                  SELECT LOAN_ID,
                                         PAYMENT_NUMBER,
                                         PERIOD_NUMBER,
                                         TIME_PERIOD_ID,
                                         PERIOD_NAME,
                                         PAYMENT_DATE,
                                         PAYROLL_ID,
                                         ASSIGNMENT_ID,
                                         OPENING_BALANCE,
                                         (OWED_CAPITAL + OWED_INTEREST + OWED_INTEREST_LATE),
                                         OWED_CAPITAL,
                                         OWED_INTEREST,
                                         OWED_INTEREST_LATE,
                                         (CASE WHEN PAYMENT_DATE > P_PAYMENT_DATE THEN NULL
                                               ELSE 0
                                           END),
                                         (CASE WHEN PAYMENT_DATE > P_PAYMENT_DATE THEN NULL
                                               ELSE 0
                                           END),
                                         (CASE WHEN PAYMENT_DATE > P_PAYMENT_DATE THEN NULL
                                               ELSE 0
                                           END),
                                         (CASE WHEN PAYMENT_DATE > P_PAYMENT_DATE THEN NULL
                                               ELSE 0
                                           END),
                                         (CASE WHEN PAYMENT_DATE > P_PAYMENT_DATE THEN NULL
                                               ELSE (OWED_CAPITAL + OWED_INTEREST + OWED_INTEREST_LATE)
                                           END),
                                         (CASE WHEN PAYMENT_DATE > P_PAYMENT_DATE THEN NULL
                                               ELSE OWED_CAPITAL
                                           END),
                                         (CASE WHEN PAYMENT_DATE > P_PAYMENT_DATE THEN NULL
                                               ELSE OWED_INTEREST
                                           END),
                                         (CASE WHEN PAYMENT_DATE > P_PAYMENT_DATE THEN NULL
                                               ELSE OWED_INTEREST_LATE
                                           END),
                                         OPENING_BALANCE - (OWED_CAPITAL + OWED_INTEREST + OWED_INTEREST_LATE),
                                         ACCRUAL_PAYMENT_AMOUNT,
                                         (CASE
                                            WHEN PAYMENT_DATE > P_PAYMENT_DATE THEN
                                                'PENDING'
                                            ELSE
                                                'PARTIAL'
                                           END),
                                         P_PAYMENT_SCHEDULE_ID,
                                         SYSDATE,
                                         var_user_id,
                                         SYSDATE,
                                         var_user_id
                                    FROM ATET_SB_PAYMENTS_SCHEDULE ASPS
                                   WHERE 1 = 1
                                     AND ASPS.PAYMENT_SCHEDULE_ID = P_PAYMENT_SCHEDULE_ID;
                                     
        UPDATE ATET_SB_PAYMENTS_SCHEDULE    ASPS
           SET ASPS.STATUS_FLAG = 'PAYED',
               ASPS.LAST_UPDATE_DATE = SYSDATE,
               ASPS.LAST_UPDATED_BY = var_user_id
         WHERE 1 = 1 
           AND ASPS.PAYMENT_SCHEDULE_ID = P_PAYMENT_SCHEDULE_ID;
           
                   
                                         
        
    END REFINANCE_PAYMENT_SCHEDULE;
    
    
    PROCEDURE   MANUAL_REFINANCING(
                    P_ERRBUF        OUT NOCOPY VARCHAR2,
                    P_RETCODE       OUT NOCOPY VARCHAR2,
                    P_PREVIOUS_LOAN_ID         NUMBER,
                    P_ACTUAL_LOAN_ID           NUMBER,
                    P_CONDONATE_INTEREST       NUMBER,
                    P_PREPAYMENT_AMOUNT        NUMBER)
    IS
        var_previous_loan_id            NUMBER := P_PREVIOUS_LOAN_ID;
        var_actual_loan_id              NUMBER := P_ACTUAL_LOAN_ID;
        
        var_condonate_interest          NUMBER := P_CONDONATE_INTEREST;
        var_prepayment_amount           NUMBER := P_PREPAYMENT_AMOUNT;
        
        LN_HAS_PREVIOUS_REFINANCED      NUMBER;
        P_MEMBER_ID                     NUMBER;

        var_check_id                    NUMBER;
        var_check_number                NUMBER;
        var_loan_total_amount           NUMBER;
        var_actual_loan_check           NUMBER;
        var_loan_interest               NUMBER;
        var_previous_loan_balance       NUMBER;
        var_transfer_interest_amount    NUMBER;
        var_condonate_interest_amount   NUMBER;
        
        var_debit_amount                NUMBER;
        var_credit_amount               NUMBER;
        
        CURSOR LOAN_TRANSACTION_DETAILS IS
            SELECT ASLT.EARNED_DATE,
                   ASLT.PERIOD_NAME,
                   ASLT.DEBIT_AMOUNT,
                   ASLT.CREDIT_AMOUNT
              FROM ATET_SB_LOANS_TRANSACTIONS   ASLT
             WHERE LOAN_ID = P_PREVIOUS_LOAN_ID
             ORDER BY LOAN_TRANSACTION_ID;
        
        CURSOR ACCOUNTED_DETAILS IS
            SELECT AXL2.LINE_NUMBER,
                   AXL2.CODE_COMBINATION_ID,
                   AXL2.DESCRIPTION,
                   AXL2.ACCOUNTED_DR,
                   AXL2.ACCOUNTED_CR
              FROM ATET_LOAN_PAYMENTS_ALL   ALPA,
                   ATET_XLA_LINES           AXL1,
                   ATET_XLA_LINES           AXL2
             WHERE 1 = 1
               AND ALPA.CHECK_ID = AXL1.SOURCE_ID
               AND AXL1.SOURCE_LINK_TABLE = 'ATET_SB_CHECKS_ALL'
               AND AXL1.HEADER_ID = AXL2.HEADER_ID
               AND ALPA.LOAN_ID = P_ACTUAL_LOAN_ID
             ORDER BY AXL2.LINE_NUMBER;     
        
    BEGIN
        
    
            SELECT ASL.LOAN_TOTAL_AMOUNT,
                   ASL.ATTRIBUTE5,
                   ASL.LOAN_INTEREST_AMOUNT,
                   ASL.ATTRIBUTE3
              INTO var_loan_total_amount,
                   var_actual_loan_check,
                   var_loan_interest,
                   var_check_number
              FROM ATET_SB_LOANS    ASL
             WHERE 1 = 1
               AND ASL.LOAN_ID = var_actual_loan_id;
               
                   
            SELECT ASL.LOAN_BALANCE,
                   var_condonate_interest
              INTO var_previous_loan_balance,
                   var_condonate_interest_amount
              FROM ATET_SB_LOANS    ASL
             WHERE 1 = 1 
               AND ASL.LOAN_ID = var_previous_loan_id;  
               
               
            SELECT SUM(NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST)) - var_condonate_interest_amount 
              INTO var_transfer_interest_amount
              FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
             WHERE 1 = 1
               AND ASPS.LOAN_ID = var_previous_loan_id
               AND ASPS.STATUS_FLAG IN ('PENDING', 'SKIP', 'EXPORTED', 'PARTIAL');

            
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('MONTO NUEVO PRESTAMO',45, ' ')
                                  ||LPAD(var_loan_total_amount,20, ' ')
                                  ||LPAD(0,20, ' '));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('MONTO DEL CHEQUE',45, ' ')
                                  ||LPAD(0,20, ' ')
                                  ||LPAD(var_actual_loan_check,20, ' '));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('INTERESES NUEVO PRESTAMO',45, ' ')
                                  ||LPAD(0,20, ' ')
                                  ||LPAD(var_loan_interest,20, ' '));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('SALDO PRESTAMO ANTERIOR',45, ' ')
                                  ||LPAD(0,20, ' ')
                                  ||LPAD(var_previous_loan_balance,20, ' '));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('INTERESES POR DEVENGAR',45, ' ')
                                  ||LPAD(var_transfer_interest_amount + var_condonate_interest_amount,20, ' ')
                                  ||LPAD(0,20, ' '));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('INTERESES COBRADOS',45, ' ')
                                  ||LPAD(0,20, ' ')
                                  ||LPAD(var_transfer_interest_amount,20, ' '));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('TOTAL',45, ' ')
                                  ||LPAD(var_loan_total_amount +
                                         var_transfer_interest_amount + 
                                         var_condonate_interest_amount,20, ' ')
                                  ||LPAD(var_actual_loan_check +
                                         var_loan_interest +
                                         var_previous_loan_balance +
                                         var_transfer_interest_amount ,20, ' '));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('PAGO ANTICIPADO', 45, ' ')
                                  ||LPAD(var_prepayment_amount + var_condonate_interest, 20, ' ')); 
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('CHEQUE NO:', 45, ' ')
                                  ||LPAD(var_check_number, 20, ' '));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            
            
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_loan_total_amount:' || var_loan_total_amount);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_transfer_interest_amount:' || var_transfer_interest_amount);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_condonate_interest_amount:' || var_condonate_interest_amount);
            FND_FILE.PUT_LINE(FND_FILE.LOG, (var_loan_total_amount +var_transfer_interest_amount + var_condonate_interest_amount ));
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_actual_loan_check:' || var_actual_loan_check);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_loan_interest:' || var_loan_interest);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_previous_loan_balance:' || var_previous_loan_balance);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_transfer_interest_amount:' || var_transfer_interest_amount);
            FND_FILE.PUT_LINE(FND_FILE.LOG, (var_actual_loan_check + var_loan_interest + var_previous_loan_balance +var_transfer_interest_amount));
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_previous_loan_balance:' || var_previous_loan_balance);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_previous_loan_balance);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_prepayment_amount:' || var_prepayment_amount);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_condonate_interest:' || var_condonate_interest);
            FND_FILE.PUT_LINE(FND_FILE.LOG, (var_prepayment_amount + var_condonate_interest));
            
            
            
            IF (var_loan_total_amount +
                var_transfer_interest_amount + 
                var_condonate_interest_amount ) = (var_actual_loan_check +
                                                   var_loan_interest +
                                                   var_previous_loan_balance +
                                                   var_transfer_interest_amount) AND var_previous_loan_balance = (var_prepayment_amount + 
                                                                                                                  var_condonate_interest) THEN
                
                                                                                                                                                  
                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    REFINANCIAMIENTO    PROCESADO.  ');
                                
                
                LN_HAS_PREVIOUS_REFINANCED := 0;
                
                 SELECT DISTINCT 
                        MEMBER_ID
                   INTO P_MEMBER_ID
                   FROM ATET_SB_LOANS
                  WHERE 1 = 1
                    AND (   LOAN_ID = var_actual_loan_id
                         OR LOAN_ID = var_previous_loan_id);
                
                 SELECT COUNT (1)
                  INTO LN_HAS_PREVIOUS_REFINANCED
                  FROM ATET_SB_LOANS
                 WHERE ATTRIBUTE2 IS NOT NULL AND MEMBER_ID = P_MEMBER_ID;
                
                /************************************************************/
                /*       CREACION CHEQUE DE REFINANCIAMIENTO                */
                /************************************************************/
                
                ATET_SB_BACK_OFFICE_PKG.CREATE_REFINANCE_LOAN_CHECK(
                        P_ACTUAL_LOAN_ID            => var_actual_loan_id,
                        P_PREVIOUS_LOAN_ID          => var_previous_loan_id,
                        P_PREVIOUS_LOAN_BALANCE_DUE => var_previous_loan_balance,
                        P_TRANSFER_INTEREST_AMOUNT  => var_transfer_interest_amount,
                        P_CONDONATE_INTEREST_AMOUNT => var_condonate_interest_amount,
                        P_ACTUAL_LOAN_CHECK_AMOUNT  => var_actual_loan_check,
                        P_HAS_PREVIOUS_REFINANCED   => LN_HAS_PREVIOUS_REFINANCED,
                        P_CHECK_NUMBER              => var_check_number,
                        P_CHECK_ID                  => var_check_id
                        );
                
                /************************************************************/
                /*                 ACTUALIZACION DEL PRESTAMO               */
                /************************************************************/           
                        
                                        
                UPDATE ATET_SB_LOANS
                   SET ATTRIBUTE2 = var_actual_loan_id
                 WHERE LOAN_ID = var_previous_loan_id;
                 
                 
                /************************************************************/
                /*                 LIQUIDACION DEL PRESTAMO                 */
                /************************************************************/
                                 
                ATET_SAVINGS_BANK_PKG.SETTLEMENT_LOAN(var_previous_loan_id);
                
                
                /************************************************************/
                /*          OUTPUT MOVIMIENTOS DE PRESTAMO                  */
                /************************************************************/
                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS DEL PRESTAMO');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                
                var_debit_amount := 0;
                var_credit_amount := 0;
                
                FOR DETAIL IN LOAN_TRANSACTION_DETAILS LOOP
                
                    var_debit_amount := var_debit_amount + DETAIL.DEBIT_AMOUNT;
                    var_credit_amount := var_credit_amount + DETAIL.CREDIT_AMOUNT;
                    
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(DETAIL.EARNED_DATE, 40, ' ')
                                                     ||RPAD(DETAIL.PERIOD_NAME, 40, ' ')
                                                     ||LPAD(DETAIL.DEBIT_AMOUNT,40, ' ')
                                                     ||LPAD(DETAIL.CREDIT_AMOUNT,40, ' '));
                
                END LOOP;
                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('TOTAL:', 80, ' ')
                                ||LPAD(var_debit_amount, 40, ' ')
                                ||LPAD(var_credit_amount, 40, ' '));
                                
                /************************************************************/
                /*          OUTPUT MOVIMIENTOS CONTABLES                    */
                /************************************************************/
                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS CONTABLES');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                
                var_debit_amount := 0;
                var_credit_amount := 0;
                
                FOR DETAIL IN ACCOUNTED_DETAILS LOOP
                
                    var_debit_amount := var_debit_amount + DETAIL.ACCOUNTED_DR;
                    var_credit_amount := var_credit_amount + DETAIL.ACCOUNTED_CR;
                    
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(GET_CODE_COMBINATION(DETAIL.CODE_COMBINATION_ID) , 40, ' ')
                                                     ||RPAD(DETAIL.DESCRIPTION, 40, ' ')
                                                     ||LPAD(DETAIL.ACCOUNTED_DR,40, ' ')
                                                     ||LPAD(DETAIL.ACCOUNTED_CR,40, ' '));
                
                END LOOP;
                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('TOTAL:', 80, ' ')
                                ||LPAD(var_debit_amount, 40, ' ')
                                ||LPAD(var_credit_amount, 40, ' '));
                
            ELSE
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '      ERROR  :  ERROR AL INTENTAR PROCESAR EL REFINANCIAMIENTO, NO SE REALIZO NINGUN PROCESO.');
                P_ERRBUF := '      ERROR  :  ERROR AL INTENTAR PROCESAR EL REFINANCIAMIENTO, NO SE REALIZO NINGUN PROCESO.';
                P_RETCODE := 1;
            END IF;               

        COMMIT;
    
    EXCEPTION 
        WHEN OTHERS THEN
            P_RETCODE := 2;
            P_ERRBUF := SQLERRM;
            ROLLBACK;    
    END MANUAL_REFINANCING;
    
    
    PROCEDURE   CALCULATING_INTEREST_EARNED(
                    P_ERRBUF        OUT NOCOPY VARCHAR2,
                    P_RETCODE       OUT NOCOPY VARCHAR2,
                    P_INTEREST_PERCENTAGE      NUMBER)
    IS
    
        CURSOR  SAVERS_WITH_SAVINGS_DETAILS IS
                SELECT ASM.MEMBER_ID,
                       ASM.PERSON_ID,
                       ASM.EMPLOYEE_NUMBER,
                       ASM.EMPLOYEE_FULL_NAME,
                       ASMA.MEMBER_ACCOUNT_ID,
                       ASMA.FINAL_BALANCE
                  FROM ATET_SB_MEMBERS              ASM,
                       ATET_SB_MEMBERS_ACCOUNTS     ASMA
                 WHERE 1 = 1
                   AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID
                   AND ASM.MEMBER_ID = ASMA.MEMBER_ID
                   AND ASMA.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO'
                   AND ASMA.FINAL_BALANCE > 0;
                   
        CURSOR  INTEREST_EARNED_DETAILS IS
                SELECT ASM.EMPLOYEE_NUMBER,
                       ASM.EMPLOYEE_FULL_NAME,
                       ASST.CREDIT_AMOUNT,
                       ASST.SAVING_TRANSACTION_ID
                  FROM ATET_SB_MEMBERS              ASM,
                       ATET_SB_MEMBERS_ACCOUNTS     ASMA,
                       ATET_SB_SAVINGS_TRANSACTIONS ASST
                 WHERE 1 = 1
                   AND ASM.MEMBER_ID = ASMA.MEMBER_ID
                   AND ASM.MEMBER_ID = ASST.MEMBER_ID
                   AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID
                   AND ASMA.ACCOUNT_DESCRIPTION = 'INTERES GANADO'
                   AND ASMA.MEMBER_ACCOUNT_ID = ASST.MEMBER_ACCOUNT_ID
                   AND ASST.ELEMENT_NAME = 'INTERES GANADO';
        
        var_sum_saving_balance      NUMBER := 0;
        var_sum_interest_earned     NUMBER := 0;
        var_interest_earned         NUMBER := 0;
        var_interest_percentage     NUMBER := (P_INTEREST_PERCENTAGE / 100);
        
        var_user_id                 NUMBER := FND_GLOBAL.USER_ID;
        var_saving_bank_id          NUMBER := GET_SAVING_BANK_ID;
        var_int_final_balance       NUMBER;
        var_int_member_account_id   NUMBER;
        var_request_id              NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        var_debit_amount            NUMBER;
        var_credit_amount           NUMBER;
        var_validate                NUMBER;
        
        var_bank_code_comb          VARCHAR2(100);
        var_int_ear_code_comb       VARCHAR2(100);
        var_bank_account_id         NUMBER;
        var_int_ear_account_id      NUMBER;
        
        var_header_id               NUMBER;
        
        CURSOR ACCOUNTED_DETAILS IS
            SELECT AXL2.LINE_NUMBER,
                   AXL2.CODE_COMBINATION_ID,
                   AXL2.DESCRIPTION,
                   AXL2.ACCOUNTED_DR,
                   AXL2.ACCOUNTED_CR
              FROM ATET_XLA_LINES           AXL2
             WHERE 1 = 1
               AND AXL2.HEADER_ID = var_header_id
             ORDER BY AXL2.LINE_NUMBER;
        
    BEGIN
    
        SELECT COUNT(ASMA.MEMBER_ACCOUNT_ID)
          INTO var_validate
          FROM ATET_SB_MEMBERS_ACCOUNTS ASMA,
               ATET_SB_MEMBERS          ASM
         WHERE 1 = 1
           AND ASMA.MEMBER_ID = ASM.MEMBER_ID
           AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID
           AND ASMA.LOAN_ID IS NULL
           AND ASMA.ACCOUNT_DESCRIPTION = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'INTEREST_ELEMENT_NAME');
           
           
        IF var_validate = 0  THEN 
    
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('NUMERO DE EMPLEADO', 20, ' ') ||
                                               RPAD('NOMBRE DE EMPLEADO', 50, ' ') ||
                                               RPAD('AHORRO ACUMULADO', 30, ' ') ||
                                               RPAD('INTERES GANADO', 30, ' ')); 
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*', 130, '*'));
            
            
            UPDATE ATET_SAVINGS_BANK    ASB
               SET ASB.INTEREST_RATE_SHARING = P_INTEREST_PERCENTAGE,
                   ASB.LAST_UPDATE_DATE = SYSDATE,
                   ASB.LAST_UPDATED_BY = var_user_id
             WHERE 1 = 1
               AND ASB.SAVING_BANK_ID = var_saving_bank_id;
               
            
            FOR DETAIL IN SAVERS_WITH_SAVINGS_DETAILS LOOP
            
                var_interest_earned := ROUND(DETAIL.FINAL_BALANCE * var_interest_percentage, 0);
                var_sum_saving_balance := var_sum_saving_balance + DETAIL.FINAL_BALANCE;
                var_sum_interest_earned := var_sum_interest_earned + var_interest_earned; 
                var_int_member_account_id := NULL;
                var_int_final_balance := NULL;
                var_debit_amount := 0;
                var_credit_amount := 0;
                
                CREATE_ACCOUNT(DETAIL.PERSON_ID,
                               'INTEREST_ELEMENT_NAME',
                               'INTEREST_CODE_COMB');
                               
                var_int_member_account_id := GET_INTEREST_MEMBER_ACCOUNT_ID(DETAIL.MEMBER_ID);
                
                SELECT ASMA.FINAL_BALANCE
                  INTO var_int_final_balance
                  FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
                 WHERE 1 = 1
                   AND ASMA.MEMBER_ACCOUNT_ID = var_int_member_account_id; 
                   
                
                IF var_int_final_balance > 0 THEN
                
                    var_debit_amount := var_int_final_balance;
                    var_credit_amount := 0;
                
                    INSERT INTO ATET_SB_SAVINGS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                              MEMBER_ID,
                                                              PERSON_ID,
                                                              PAYROLL_RESULT_ID,
                                                              EARNED_DATE,
                                                              PERIOD_NAME,
                                                              ELEMENT_NAME,
                                                              TRANSACTION_CODE,
                                                              DEBIT_AMOUNT,
                                                              CREDIT_AMOUNT,
                                                              REQUEST_ID,
                                                              CREATION_DATE,
                                                              CREATED_BY,
                                                              LAST_UPDATE_DATE,
                                                              LAST_UPDATED_BY)
                                                      VALUES (var_int_member_account_id,
                                                              DETAIL.MEMBER_ID,
                                                              DETAIL.PERSON_ID,
                                                              -1,
                                                              TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                                                              'CANCELACION INTERES GANADO',
                                                              GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'INTEREST_ELEMENT_NAME'),
                                                              'PROCESSED',
                                                              var_debit_amount,
                                                              var_credit_amount,
                                                              var_request_id,
                                                              SYSDATE,
                                                              var_user_id,
                                                              SYSDATE,
                                                              var_user_id);
                                                      
                    UPDATE ATET_SB_MEMBERS_ACCOUNTS
                       SET DEBIT_BALANCE = DEBIT_BALANCE + var_debit_amount,
                           CREDIT_BALANCE = CREDIT_BALANCE + var_credit_amount,
                           LAST_TRANSACTION_DATE = SYSDATE               
                     WHERE MEMBER_ID = DETAIL.MEMBER_ID
                       AND MEMBER_ACCOUNT_ID = var_int_member_account_id;
                       
                    UPDATE ATET_SB_MEMBERS_ACCOUNTS
                       SET FINAL_BALANCE = CREDIT_BALANCE - DEBIT_BALANCE,
                           LAST_UPDATE_DATE = SYSDATE,
                           LAST_UPDATED_BY = var_user_id             
                     WHERE MEMBER_ID = DETAIL.MEMBER_ID
                       AND MEMBER_ACCOUNT_ID = var_int_member_account_id;
                    
                END IF;
                
                
                
                var_debit_amount := 0;
                var_credit_amount := var_interest_earned;
                
                INSERT INTO ATET_SB_SAVINGS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                          MEMBER_ID,
                                                          PERSON_ID,
                                                          PAYROLL_RESULT_ID,
                                                          EARNED_DATE,
                                                          PERIOD_NAME,
                                                          ELEMENT_NAME,
                                                          TRANSACTION_CODE,
                                                          DEBIT_AMOUNT,
                                                          CREDIT_AMOUNT,
                                                          REQUEST_ID,
                                                          CREATION_DATE,
                                                          CREATED_BY,
                                                          LAST_UPDATE_DATE,
                                                          LAST_UPDATED_BY)
                                                  VALUES (var_int_member_account_id,
                                                          DETAIL.MEMBER_ID,
                                                          DETAIL.PERSON_ID,
                                                          -1,
                                                          TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                                                          'INTERES GANADO',
                                                          GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'INTEREST_ELEMENT_NAME'),
                                                          'PROCESSED',
                                                          var_debit_amount,
                                                          var_credit_amount,
                                                          var_request_id,
                                                          SYSDATE,
                                                          var_user_id,
                                                          SYSDATE,
                                                          var_user_id);
                                                      
                UPDATE ATET_SB_MEMBERS_ACCOUNTS
                   SET DEBIT_BALANCE = DEBIT_BALANCE + var_debit_amount,
                       CREDIT_BALANCE = CREDIT_BALANCE + var_credit_amount,
                       LAST_TRANSACTION_DATE = SYSDATE               
                 WHERE MEMBER_ID = DETAIL.MEMBER_ID
                   AND MEMBER_ACCOUNT_ID = var_int_member_account_id;
                       
                UPDATE ATET_SB_MEMBERS_ACCOUNTS
                   SET FINAL_BALANCE = CREDIT_BALANCE - DEBIT_BALANCE,
                       LAST_UPDATE_DATE = SYSDATE,
                       LAST_UPDATED_BY = var_user_id             
                 WHERE MEMBER_ID = DETAIL.MEMBER_ID
                   AND MEMBER_ACCOUNT_ID = var_int_member_account_id;
               
                               
            
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(DETAIL.EMPLOYEE_NUMBER, 20, ' ') ||
                                                   RPAD(REPLACE(REPLACE(DETAIL.EMPLOYEE_FULL_NAME, CHR(10), ''), CHR(13), ''), 50, ' ') ||
                                                   LPAD(TRIM(TO_CHAR(DETAIL.FINAL_BALANCE, '999G999G999D99')), 30, ' ') ||
                                                   LPAD(TRIM(TO_CHAR(var_interest_earned, '999G999G999D99')), 30, ' '));
                                                   
            END LOOP;
            
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*', 130, '*'));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('TOTAL:', 70, ' ') ||
                                               LPAD(TRIM(TO_CHAR(var_sum_saving_balance, '999G999G999D99')), 30, ' ') ||
                                               LPAD(TRIM(TO_CHAR(var_sum_interest_earned, '999G999G999D99')), 30, ' ')); 
                                               
            /*******************************************************/
            /****           POLIZA DE INTERES GANADO            ****/
            /*******************************************************/
            
            var_bank_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'BANK_CODE_COMB');
            var_int_ear_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'INTEREST_CODE_COMB');
            var_bank_account_id := GET_CODE_COMBINATION_ID(var_bank_code_comb);
            var_int_ear_account_id := GET_CODE_COMBINATION_ID(var_int_ear_code_comb);
            
            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (P_ENTITY_CODE        => 'EARNED',
                                                       P_EVENT_TYPE_CODE    => 'INTEREST_EARNED',
                                                       P_BATCH_NAME         => 'INTERES GANADO',
                                                       P_JOURNAL_NAME       => 'CALCULO DE INTERES GANADO ' || GET_SAVING_BANK_YEAR,
                                                       P_HEADER_ID          => var_header_id);
                                                       
                                                             
            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                     P_ROW_NUMBER              => 1,
                                                     P_CODE_COMBINATION_ID     => var_bank_account_id,
                                                     P_ACCOUNTING_CLASS_CODE   => 'INTEREST_EARNED',
                                                     P_ACCOUNTED_DR            => var_sum_interest_earned,
                                                     P_ACCOUNTED_CR            => 0,
                                                     P_DESCRIPTION             => 'CALCULO DE INTERES GANADO ' || GET_SAVING_BANK_YEAR,
                                                     P_SOURCE_ID               => -1,
                                                     P_SOURCE_LINK_TABLE       => NULL);
                                                     
            FOR detail IN INTEREST_EARNED_DETAILS LOOP                                                     
                                                               
                ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                         P_ROW_NUMBER              => 2,
                                                         P_CODE_COMBINATION_ID     => var_int_ear_account_id,
                                                         P_ACCOUNTING_CLASS_CODE   => 'INTEREST_EARNED',
                                                         P_ACCOUNTED_DR            => 0,
                                                         P_ACCOUNTED_CR            => detail.CREDIT_AMOUNT,
                                                         P_DESCRIPTION             => 'INTERES GANADO ' || detail.EMPLOYEE_NUMBER || ' - ' || detail.EMPLOYEE_FULL_NAME,
                                                         P_SOURCE_ID               => detail.SAVING_TRANSACTION_ID,
                                                         P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
            
            END LOOP;
                                                     
            /*************************************************/
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS CONTABLES');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                
            var_debit_amount := 0;
            var_credit_amount := 0;
                
            FOR DETAIL IN ACCOUNTED_DETAILS LOOP
                
                var_debit_amount := var_debit_amount + DETAIL.ACCOUNTED_DR;
                var_credit_amount := var_credit_amount + DETAIL.ACCOUNTED_CR;
                    
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(GET_CODE_COMBINATION(DETAIL.CODE_COMBINATION_ID) , 40, ' ')
                                                 ||RPAD(DETAIL.DESCRIPTION, 40, ' ')
                                                 ||LPAD(DETAIL.ACCOUNTED_DR,40, ' ')
                                                 ||LPAD(DETAIL.ACCOUNTED_CR,40, ' '));
                
            END LOOP;
                
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('TOTAL:', 80, ' ')
                            ||LPAD(var_debit_amount, 40, ' ')
                            ||LPAD(var_credit_amount, 40, ' '));

            ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL;                                  
            COMMIT;
        ELSE
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'YA SE PROCESO ANTERIORMENTE EL PAGO DE DEVOLUCIÓN DE AHORRO.');
            P_RETCODE := 1;
            ROLLBACK;
        END IF;
    
    EXCEPTION 
        WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
            P_RETCODE := 2;
            ROLLBACK;
    END CALCULATING_INTEREST_EARNED;
    
    
    FUNCTION    GET_INTEREST_MEMBER_ACCOUNT_ID(
                    P_MEMBER_ID                 NUMBER
                ) RETURN    NUMBER
    IS
        var_member_account_id  NUMBER;
    BEGIN
    
        SELECT ASMA.MEMBER_ACCOUNT_ID
          INTO var_member_account_id
          FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
         WHERE 1 = 1
           AND ASMA.MEMBER_ID = P_MEMBER_ID
           AND ASMA.LOAN_ID IS NULL
           AND ASMA.ACCOUNT_DESCRIPTION = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'INTEREST_ELEMENT_NAME');
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_INTEREST_MEMBER_ACCOUNT_ID(P_MEMBER_ID => ' || P_MEMBER_ID || ') RETURN ' || var_member_account_id);
    
        RETURN var_member_account_id;
    END GET_INTEREST_MEMBER_ACCOUNT_ID;
    
    
    PROCEDURE   SETTLEMENT_LOAN_WITH_SAVING(
                    P_ERRBUF        OUT NOCOPY VARCHAR2,
                    P_RETCODE       OUT NOCOPY VARCHAR2,
                    P_YEAR          NUMBER)
    IS
    
        var_code_company            VARCHAR2(50);
        var_time_period_id          NUMBER;
        var_period_name             VARCHAR2(100);
        var_payment_date            DATE;
        var_payment_schedule_id     NUMBER;
        var_user_id                 NUMBER := FND_GLOBAL.USER_ID;
        
        var_loan_balance            NUMBER;
        var_saving_retirement       NUMBER;
        var_interest_retirement     NUMBER;
        var_loan_transac_balance    NUMBER;
        
        var_interest_transaction_id NUMBER;
        var_saving_transaction_id   NUMBER;
        
        var_debit_amount            NUMBER;
        var_credit_amount           NUMBER;
        var_header_id               NUMBER;
        
        var_interest_balance        NUMBER;
        var_saving_balance          NUMBER;
        
        COMPANY_EX                  EXCEPTION;
        PAYMENTS_SCHEDULE_EX        EXCEPTION;
        INSERT_SAVING_EXCEPTION     EXCEPTION;
        SELECT_SAVING_EXCEPTION     EXCEPTION;
        UPDATE_SAVING_EXCEPTION     EXCEPTION;
        NO_SAVING_BALANCE_EX        EXCEPTION;
        INT_SAVING_RETIREMENT_EX    EXCEPTION;
        INT_LOAN_TRANSACTION_EX     EXCEPTION;
        INT_CREATE_JOURNAL_EX       EXCEPTION;
        INSERT_LOAN_EX              EXCEPTION;
        GROUP_INSERT_LOAN_EX        EXCEPTION;
    
        CURSOR SAVINGS_DETAILS (PP_MEMBER_ID  NUMBER, PP_MEMBER_ACCOUNT_ID NUMBER)IS
            SELECT ASST.EARNED_DATE,
                   ASST.PERIOD_NAME,
                   ASST.ELEMENT_NAME,
                   ASST.DEBIT_AMOUNT,
                   ASST.CREDIT_AMOUNT
              FROM ATET_SB_SAVINGS_TRANSACTIONS ASST
             WHERE 1 = 1
               AND ASST.MEMBER_ID = PP_MEMBER_ID
               AND ASST.MEMBER_ACCOUNT_ID = PP_MEMBER_ACCOUNT_ID
             ORDER BY ASST.SAVING_TRANSACTION_ID;
             
        CURSOR LOAN_TRANSACTION_DETAILS (PP_LOAN_ID NUMBER) IS
            SELECT ASLT.EARNED_DATE,
                   ASLT.PERIOD_NAME,
                   ASLT.DEBIT_AMOUNT,
                   ASLT.CREDIT_AMOUNT
              FROM ATET_SB_LOANS_TRANSACTIONS   ASLT
             WHERE LOAN_ID = PP_LOAN_ID
             ORDER BY LOAN_TRANSACTION_ID;
             
        CURSOR ACCOUNTED_DETAILS (PP_HEADER_ID NUMBER) IS
            SELECT AXL2.LINE_NUMBER,
                   AXL2.CODE_COMBINATION_ID,
                   AXL2.DESCRIPTION,
                   AXL2.ACCOUNTED_DR,
                   AXL2.ACCOUNTED_CR
              FROM ATET_XLA_LINES           AXL2
             WHERE 1 = 1
               AND AXL2.HEADER_ID = PP_HEADER_ID
             ORDER BY AXL2.LINE_NUMBER;
    
        CURSOR  LOANS_DETAILS   IS
            SELECT ASM.MEMBER_ID,
                   ASM.PERSON_ID,
                   ASM.EMPLOYEE_NUMBER,
                   ASM.EMPLOYEE_FULL_NAME,
                   ASMA1.MEMBER_ACCOUNT_ID      AS SAVING_MEMBER_ACCOUNT_ID,
                   ASMA1.FINAL_BALANCE          AS SAVING_FINAL_BALANCE,
                   ASMA1.CODE_COMBINATION_ID    AS SAVING_CODE_COMBINATION_ID,
                   ASMA2.MEMBER_ACCOUNT_ID      AS INTEREST_MEMBER_ACCOUNT_ID,
                   ASMA2.FINAL_BALANCE          AS INTEREST_FINAL_BALANCE,
                   ASMA2.CODE_COMBINATION_ID    AS INTEREST_CODE_COMBINATION_ID,
                   ASL.LOAN_ID,
                   ASMA3.CODE_COMBINATION_ID    AS LOAN_CODE_COMBINATION_ID,
                   ASL.LOAN_NUMBER,
                   ASL.LOAN_BALANCE
              FROM ATET_SB_MEMBERS          ASM,
                   ATET_SB_MEMBERS_ACCOUNTS ASMA1,
                   ATET_SB_MEMBERS_ACCOUNTS ASMA2,
                   ATET_SB_MEMBERS_ACCOUNTS ASMA3,
                   ATET_SB_LOANS            ASL,
                   ATET_SAVINGS_BANK        ASB
             WHERE 1 = 1
               AND ASL.MEMBER_ID = ASM.MEMBER_ID
               AND ASM.MEMBER_ID = ASMA1.MEMBER_ID
               AND ASMA1.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO'
               AND ASMA1.FINAL_BALANCE > 0
               AND ASM.MEMBER_ID = ASMA2.MEMBER_ID
               AND ASMA2.ACCOUNT_DESCRIPTION = 'INTERES GANADO'
               AND ASMA2.FINAL_BALANCE > 0
               AND ASM.MEMBER_ID = ASMA3.MEMBER_ID
               AND ASMA3.ACCOUNT_DESCRIPTION = 'D072_PRESTAMO CAJA DE AHORRO'
               AND ASMA3.LOAN_ID = ASL.LOAN_ID
               AND ASL.LOAN_STATUS_FLAG = 'ACTIVE'
               AND ASL.LOAN_BALANCE > 0
               AND ASM.SAVING_BANK_ID = ASB.SAVING_BANK_ID
               AND ASB.YEAR = P_YEAR;
               
        PROCEDURE INTERNAL_SAVING_RETIREMENT(
            PP_ACCOUNT_DESCRIPTION          VARCHAR2,
            PP_MEMBER_ID                    NUMBER,
            PP_PAYMENT_AMOUNT               NUMBER,
            PP_MEMBER_ACCOUNT_ID            NUMBER,
            PP_BALANCE                  OUT NUMBER,
            PP_SAVING_RETIREMENT        OUT NUMBER,
            PP_SAVING_TRANSACTION_ID    OUT NUMBER)
        IS
            var_saving_balance          NUMBER;
            var_debit_amount            NUMBER;
            var_credit_amount           NUMBER;
            var_saving_retirement       NUMBER;
            var_saving_retirement_seq   NUMBER;
            var_saving_transaction_id   NUMBER;
        BEGIN
            
            SELECT ASMA.FINAL_BALANCE
              INTO var_saving_balance
              FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
             WHERE 1 = 1
               AND ASMA.MEMBER_ID = PP_MEMBER_ID
               AND ASMA.LOAN_ID IS NULL
               AND ASMA.ACCOUNT_DESCRIPTION = PP_ACCOUNT_DESCRIPTION;
               
            var_debit_amount := 0;
            var_credit_amount := 0;
            
            IF var_saving_balance = 0 THEN
                var_saving_retirement := 0;
                PP_BALANCE := PP_PAYMENT_AMOUNT - var_saving_retirement;
                PP_SAVING_RETIREMENT := var_saving_retirement;
                PP_SAVING_TRANSACTION_ID := -1;
                
                RETURN;
            ELSIF var_saving_balance >= PP_PAYMENT_AMOUNT THEN
                var_saving_retirement := PP_PAYMENT_AMOUNT;
                PP_BALANCE := PP_PAYMENT_AMOUNT - var_saving_retirement;
                PP_SAVING_RETIREMENT := var_saving_retirement;
            ELSE     
                var_saving_retirement := var_saving_balance;
                PP_BALANCE := PP_PAYMENT_AMOUNT - var_saving_retirement;
                PP_SAVING_RETIREMENT := var_saving_retirement;
            END IF;
            
            SELECT ATET_SB_SAVING_RETIREMENT_SEQ.NEXTVAL
              INTO var_saving_retirement_seq 
              FROM DUAL;
              
            var_debit_amount := var_saving_retirement;
            var_credit_amount := 0;
            
            BEGIN
                            
                INSERT INTO ATET_SB_SAVINGS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                          MEMBER_ID,
                                                          PAYROLL_RESULT_ID,
                                                          PERSON_ID,
                                                          EARNED_DATE,
                                                          PERIOD_NAME,
                                                          ELEMENT_NAME,
                                                          ENTRY_VALUE,
                                                          TRANSACTION_CODE,
                                                          DEBIT_AMOUNT,
                                                          CREDIT_AMOUNT,
                                                          ATTRIBUTE1,
                                                          ATTRIBUTE6,
                                                          ATTRIBUTE7,
                                                          ACCOUNTED_FLAG,
                                                          CREATION_DATE,
                                                          CREATED_BY,
                                                          LAST_UPDATE_DATE,
                                                          LAST_UPDATED_BY)
                                                  VALUES (PP_MEMBER_ACCOUNT_ID,
                                                          PP_MEMBER_ID,
                                                          -1,
                                                          GET_PERSON_ID(PP_MEMBER_ID),
                                                          TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                                                          'RETIRO',
                                                          'RETIRO POR PAGO ANTICIPADO',
                                                          var_saving_retirement,
                                                          'RETIREMENT',
                                                          var_debit_amount,
                                                          var_credit_amount,
                                                          var_saving_retirement_seq,
                                                          'RETIRO POR PAGO ANTICIPADO',
                                                          'REPARTO DE AHORRO',
                                                          'ACCOUNTED',
                                                          SYSDATE,
                                                          var_user_id,
                                                          SYSDATE,
                                                          var_user_id);                                                                          
                            
            EXCEPTION WHEN OTHERS THEN
                RAISE INSERT_SAVING_EXCEPTION;                                                                          
            END;
            
            BEGIN                                     
                                                      
                SELECT ASST.SAVING_TRANSACTION_ID,
                       ASST.SAVING_TRANSACTION_ID
                  INTO var_saving_transaction_id,
                       PP_SAVING_TRANSACTION_ID
                  FROM ATET_SB_SAVINGS_TRANSACTIONS ASST
                 WHERE 1 = 1
                   AND ASST.MEMBER_ACCOUNT_ID = PP_MEMBER_ACCOUNT_ID
                   AND ASST.MEMBER_ID = PP_MEMBER_ID
                   AND ASST.PERSON_ID = GET_PERSON_ID(PP_MEMBER_ID)
                   AND ASST.PERIOD_NAME = 'RETIRO'
                   AND ASST.ELEMENT_NAME = 'RETIRO POR PAGO ANTICIPADO'
                   AND ASST.ENTRY_VALUE = var_saving_retirement
                   AND ASST.TRANSACTION_CODE = 'RETIREMENT'
                   AND ASST.DEBIT_AMOUNT = var_debit_amount
                   AND ASST.CREDIT_AMOUNT = var_credit_amount
                   AND ASST.ATTRIBUTE1 = var_saving_retirement_seq;
                   
            EXCEPTION WHEN OTHERS THEN
                RAISE SELECT_SAVING_EXCEPTION;
            END;
            
            BEGIN
                                                                      
                UPDATE ATET_SB_MEMBERS_ACCOUNTS
                   SET DEBIT_BALANCE = DEBIT_BALANCE + var_debit_amount,
                       CREDIT_BALANCE = CREDIT_BALANCE + var_credit_amount,
                       LAST_TRANSACTION_DATE = SYSDATE               
                 WHERE MEMBER_ID = PP_MEMBER_ID
                   AND MEMBER_ACCOUNT_ID = PP_MEMBER_ACCOUNT_ID;

                              
                UPDATE ATET_SB_MEMBERS_ACCOUNTS
                   SET FINAL_BALANCE = CREDIT_BALANCE - DEBIT_BALANCE,
                       LAST_UPDATE_DATE = SYSDATE,
                       LAST_UPDATED_BY = var_user_id             
                 WHERE MEMBER_ID = PP_MEMBER_ID
                   AND MEMBER_ACCOUNT_ID = PP_MEMBER_ACCOUNT_ID;
                            
            EXCEPTION WHEN OTHERS THEN
                RAISE UPDATE_SAVING_EXCEPTION;
            END;
        
        EXCEPTION
            WHEN OTHERS THEN
                RAISE INT_SAVING_RETIREMENT_EX;
        END; 
     
        PROCEDURE INTERNAL_LOAN_TRANSACTION(
            PP_MEMBER_ID            NUMBER,
            PP_PERSON_ID            NUMBER,
            PP_PAYMENT_DATE         DATE,
            PP_TIME_PERIOD_ID       NUMBER,
            PP_PERIOD_NAME          VARCHAR2,
            PP_PAYMENT_AMOUNT       NUMBER,
            PP_PAYMENT_SCHEDULE_ID  NUMBER,
            PP_LOAN_ID              NUMBER)
        IS
            var_result                  VARCHAR2(10);
        BEGIN
        
            BEGIN
                var_result := INSERT_LOAN_TRANSACTION(P_EXPORT_REQUEST_ID => -1,
                                                      P_PAYROLL_RESULT_ID => -1,
                                                      P_PERSON_ID => PP_PERSON_ID,
                                                      P_RUN_RESULT_ID => -1,
                                                      P_EARNED_DATE => PP_PAYMENT_DATE,
                                                      P_TIME_PERIOD_ID => PP_TIME_PERIOD_ID,
                                                      P_PERIOD_NAME => PP_PERIOD_NAME,
                                                      P_ELEMENT_NAME => 'PAGO ANTICIPADO',
                                                      P_ENTRY_NAME => 'Pay Value',
                                                      P_ENTRY_UNITS => 'Dinero',
                                                      P_ENTRY_VALUE => PP_PAYMENT_AMOUNT,
                                                      P_DEBIT_AMOUNT => 0,
                                                      P_CREDIT_AMOUNT => PP_PAYMENT_AMOUNT,
                                                      P_PAYMENT_SCHEDULE_ID => PP_PAYMENT_SCHEDULE_ID);
            EXCEPTION WHEN OTHERS THEN
                RAISE INSERT_LOAN_EX;
            END;
           
        
            BEGIN
                INSERT INTO
                    ATET_SB_LOANS_TRANSACTIONS(
                        MEMBER_ACCOUNT_ID,
                        MEMBER_ID,
                        PAYROLL_RESULT_ID,
                        LOAN_ID,
                        PERSON_ID,
                        RUN_RESULT_ID,
                        EARNED_DATE,
                        TIME_PERIOD_ID,
                        PERIOD_NAME,
                        ELEMENT_NAME,
                        ENTRY_NAME,
                        ENTRY_UNITS,
                        ENTRY_VALUE,
                        TRANSACTION_CODE,
                        DEBIT_AMOUNT,
                        CREDIT_AMOUNT,
                        PAYMENT_AMOUNT,
                        PAYMENT_CAPITAL,
                        PAYMENT_INTEREST,
                        PAYMENT_INTEREST_LATE,
                        REQUEST_ID,
                        ACCOUNTED_FLAG,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY)
                SELECT  MEMBER_ACCOUNT_ID,
                        MEMBER_ID,
                        PAYROLL_RESULT_ID,
                        LOAN_ID,
                        PERSON_ID,
                        RUN_RESULT_ID,
                        EARNED_DATE,
                        TIME_PERIOD_ID,
                        ELEMENT_NAME,
                        ELEMENT_NAME,
                        ENTRY_NAME,
                        ENTRY_UNITS,
                        PP_PAYMENT_AMOUNT,
                        TRANSACTION_CODE,
                        DEBIT_AMOUNT,
                        PP_PAYMENT_AMOUNT,
                        PP_PAYMENT_AMOUNT,
                        SUM(PAYMENT_CAPITAL),
                        SUM(PAYMENT_INTEREST),
                        SUM(PAYMENT_INTEREST_LATE),
                        REQUEST_ID,
                        'ACCOUNTED',
                        'PAGO ANTICIPADO: TIME_PERIOD_ID='||PP_TIME_PERIOD_ID||',PERIOD_NAME='|| PP_PERIOD_NAME,
                        'REPARTO DE AHORRO',
                        SYSDATE,
                        CREATED_BY,
                        SYSDATE,
                        LAST_UPDATED_BY
                  FROM ATET_SB_LOANS_TRANSACTIONS   ASLT 
                 WHERE 1 = 1 
                   AND ASLT.MEMBER_ID = PP_MEMBER_ID
                   AND ASLT.PERSON_ID = PP_PERSON_ID
                   AND ASLT.TIME_PERIOD_ID = PP_TIME_PERIOD_ID
                   AND ASLT.PERIOD_NAME = PP_PERIOD_NAME
                   AND ASLT.ELEMENT_NAME = 'PAGO ANTICIPADO'
                   AND ASLT.LOAN_ID = PP_LOAN_ID
                 GROUP BY MEMBER_ACCOUNT_ID,
                          MEMBER_ID,
                          PAYROLL_RESULT_ID,
                          LOAN_ID,
                          PERSON_ID,
                          RUN_RESULT_ID,
                          EARNED_DATE,
                          TIME_PERIOD_ID,
                          PERIOD_NAME,
                          ELEMENT_NAME,
                          ENTRY_NAME,
                          ENTRY_UNITS,
                          TRANSACTION_CODE,
                          DEBIT_AMOUNT,
                          REQUEST_ID,
                          CREATED_BY,
                          LAST_UPDATED_BY;
            EXCEPTION WHEN OTHERS THEN
                RAISE GROUP_INSERT_LOAN_EX;
            END;
            
            DELETE FROM ATET_SB_LOANS_TRANSACTIONS ASLT
             WHERE 1 = 1 
               AND ASLT.MEMBER_ID = PP_MEMBER_ID
               AND ASLT.PERSON_ID = PP_PERSON_ID
               AND ASLT.TIME_PERIOD_ID = PP_TIME_PERIOD_ID
               AND ASLT.PERIOD_NAME = PP_PERIOD_NAME
               AND ASLT.LOAN_ID = PP_LOAN_ID
               AND ASLT.ELEMENT_NAME = 'PAGO ANTICIPADO';                                   
        
        EXCEPTION WHEN OTHERS THEN
            RAISE INT_LOAN_TRANSACTION_EX;
        END;
        
        PROCEDURE INTERNAL_CREATE_JOURNAL(
                PP_PERSON_ID                NUMBER,
                PP_MEMBER_ID                NUMBER,
                PP_EMPLOYEE_NUMBER          VARCHAR2,
                PP_EMPLOYEE_FULL_NAME       VARCHAR2,
                PP_LOAN_ID                  NUMBER,
                PP_LOAN_NUMBER              NUMBER,
                PP_PAYMENT_AMOUNT           NUMBER,
                PP_INTEREST_RETIREMENT      NUMBER,
                PP_INTEREST_TRANSACTION_ID  NUMBER,
                PP_SAVING_RETIREMENT        NUMBER,
                PP_SAVING_TRANSACTION_ID    NUMBER,
                PP_TIME_PERIOD_ID           NUMBER,
                PP_NOT_REC_ACCOUNT_ID       NUMBER,
                PP_SAV_ACCOUNT_ID           NUMBER,
                PP_INT_EAR_ACCOUNT_ID       NUMBER,
                PP_HEADER_ID            OUT NUMBER                
            )
        IS
            var_une_int_code_comb       VARCHAR2(100);
            var_int_rec_code_comb       VARCHAR2(100);
            
            var_une_int_account_id      NUMBER;
            var_int_rec_account_id      NUMBER;
            
            var_deb_cs_code_comb        VARCHAR2(100);
            var_deb_pac_code_comb       VARCHAR2(100);
                    
            var_deb_cs_account_id       NUMBER;
            var_deb_pac_account_id      NUMBER;
            
            var_description             VARCHAR2(1000);
            
            var_asps_payment_amount     NUMBER;
            var_asps_payment_interest   NUMBER;
            var_asps_payment_int_late   NUMBER;
        BEGIN
            
                var_une_int_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'UNE_INT_CODE_COMB');
                var_int_rec_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'INT_REC_CODE_COMB');
                    
                var_une_int_account_id := GET_CODE_COMBINATION_ID(var_une_int_code_comb);
                var_int_rec_account_id := GET_CODE_COMBINATION_ID(var_int_rec_code_comb);
                
                var_deb_cs_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'DEB_CS_CODE_COMB');
                var_deb_pac_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'DEB_PAC_CODE_COMB');
                
                var_deb_cs_account_id := GET_CODE_COMBINATION_ID(var_deb_cs_code_comb);
                var_deb_pac_account_id := GET_CODE_COMBINATION_ID(var_deb_pac_code_comb);
                    
                var_description := 'PAGO ANTICIPADO CON REPARTO DE AHORRO: ' || PP_EMPLOYEE_NUMBER      || 
                                                    '|' || PP_EMPLOYEE_FULL_NAME   ||
                                                    '|' || PP_LOAN_NUMBER          ||
                                                    '|' || TRIM(TO_CHAR(PP_PAYMENT_AMOUNT,'$999,999.99'));
                                                    
                SELECT SUM(NVL(ASLT.PAYMENT_AMOUNT, 0)),
                       SUM(NVL(ASLT.PAYMENT_INTEREST, 0)),
                       SUM(NVL(ASLT.PAYMENT_INTEREST_LATE, 0))
                  INTO var_asps_payment_amount,
                       var_asps_payment_interest,
                       var_asps_payment_int_late
                  FROM ATET_SB_LOANS_TRANSACTIONS ASLT
                 WHERE 1 = 1 
                   AND ASLT.MEMBER_ID = PP_MEMBER_ID
                   AND ASLT.PERSON_ID = PP_PERSON_ID
                   AND ASLT.TIME_PERIOD_ID = PP_TIME_PERIOD_ID
                   AND ASLT.PERIOD_NAME = 'PAGO ANTICIPADO'
                   AND ASLT.ELEMENT_NAME = 'PAGO ANTICIPADO'
                   AND ASLT.ATTRIBUTE7 = 'REPARTO DE AHORRO';
                   
                ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (
                    P_ENTITY_CODE        => 'LOANS',
                    P_EVENT_TYPE_CODE    => 'LOAN_PREPAID',
                    P_BATCH_NAME         => 'PAGO ANTICIPADO',
                    P_JOURNAL_NAME       => var_description,
                    P_HEADER_ID          => PP_HEADER_ID );
                    
                /*********************************************/
                /* CARGO    -   RETIRO DE INTERES GANADO     */
                /*********************************************/
                IF PP_INTEREST_RETIREMENT > 0 THEN 
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                            P_HEADER_ID               => PP_HEADER_ID,
                            P_ROW_NUMBER              => 1,
                            P_CODE_COMBINATION_ID     => PP_INT_EAR_ACCOUNT_ID,
                            P_ACCOUNTING_CLASS_CODE   => 'INTEREST_RETIREMENT',
                            P_ACCOUNTED_DR            => PP_INTEREST_RETIREMENT,
                            P_ACCOUNTED_CR            => 0,
                            P_DESCRIPTION             => 'RETIRO DE INTERES GANADO : ' || PP_EMPLOYEE_NUMBER || '-' || PP_EMPLOYEE_FULL_NAME,
                            P_SOURCE_ID               => PP_INTEREST_TRANSACTION_ID,
                            P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
                END IF;
                
                /*********************************************/
                /* CARGO    -   RETIRO DE AHORRO ACUMULADO   */
                /*********************************************/
                
                IF PP_SAVING_RETIREMENT > 0 THEN
                     ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                            P_HEADER_ID               => PP_HEADER_ID,
                            P_ROW_NUMBER              => 2,
                            P_CODE_COMBINATION_ID     => PP_SAV_ACCOUNT_ID,
                            P_ACCOUNTING_CLASS_CODE   => 'SAVING_RETIREMENT',
                            P_ACCOUNTED_DR            => PP_SAVING_RETIREMENT,
                            P_ACCOUNTED_CR            => 0,
                            P_DESCRIPTION             => 'RETIRO DE AHORRO ACUMULADO : ' || PP_EMPLOYEE_NUMBER || '-' || PP_EMPLOYEE_FULL_NAME,
                            P_SOURCE_ID               => PP_SAVING_TRANSACTION_ID,
                            P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
                END IF;
                
                /*********************************************/
                /* ABONO   -   DOCUMENTOS POR COBRAR         */
                /*********************************************/
                
                ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                    P_HEADER_ID => PP_HEADER_ID,
                    P_ROW_NUMBER => 3,
                    P_CODE_COMBINATION_ID => PP_NOT_REC_ACCOUNT_ID,
                    P_ACCOUNTING_CLASS_CODE => 'LOAN_PREPAID',
                    P_ACCOUNTED_DR => 0,
                    P_ACCOUNTED_CR => PP_PAYMENT_AMOUNT,
                    P_DESCRIPTION => var_description,
                    P_SOURCE_ID => PP_LOAN_ID,
                    P_SOURCE_LINK_TABLE => 'ATET_SB_LOANS');
                    
                /*********************************************/
                /* CARGO   -   INTERES POR DEVENGAR          */
                /*********************************************/
                IF var_asps_payment_interest > 0 THEN
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                        P_HEADER_ID => PP_HEADER_ID,
                        P_ROW_NUMBER => 4,
                        P_CODE_COMBINATION_ID => var_une_int_account_id,
                        P_ACCOUNTING_CLASS_CODE => 'LOAN_PREPAID',
                        P_ACCOUNTED_DR => var_asps_payment_interest,
                        P_ACCOUNTED_CR => 0,
                        P_DESCRIPTION => var_description,
                        P_SOURCE_ID => PP_LOAN_ID,
                        P_SOURCE_LINK_TABLE => 'ATET_SB_LOANS');
                        
                    /*********************************************/
                    /* ABONO   -   INTERES COBRADO               */
                    /*********************************************/
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                        P_HEADER_ID => PP_HEADER_ID,
                        P_ROW_NUMBER => 5,
                        P_CODE_COMBINATION_ID => var_int_rec_account_id,
                        P_ACCOUNTING_CLASS_CODE => 'LOAN_PREPAID',
                        P_ACCOUNTED_DR => 0,
                        P_ACCOUNTED_CR => var_asps_payment_interest,
                        P_DESCRIPTION => var_description,
                        P_SOURCE_ID => PP_LOAN_ID,
                        P_SOURCE_LINK_TABLE => 'ATET_SB_LOANS');
                END IF;  
                    
                IF var_asps_payment_int_late > 0 THEN
                    IF var_code_company = '02' THEN
                        /*********************************************/
                        /* CARGO - INTERESES MORATORIOS POR DEVENGAR */
                        /*********************************************/
                        ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                            P_HEADER_ID               => PP_HEADER_ID,
                            P_ROW_NUMBER              => 6,
                            P_CODE_COMBINATION_ID     => var_deb_cs_account_id,
                            P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST_LATE',
                            P_ACCOUNTED_DR            => var_asps_payment_int_late,
                            P_ACCOUNTED_CR            => 0,
                            P_DESCRIPTION             => var_description,
                            P_SOURCE_ID               => PP_LOAN_ID,
                            P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');
                    ELSIF var_code_company = '11' THEN
                        /*********************************************/
                        /* CARGO : INTERESES MORATORIOS POR DEVENGAR */
                        /*********************************************/
                        ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                            P_HEADER_ID               => PP_HEADER_ID,
                            P_ROW_NUMBER              => 6,
                            P_CODE_COMBINATION_ID     => var_deb_pac_account_id,
                            P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST_LATE',
                            P_ACCOUNTED_DR            => var_asps_payment_int_late,
                            P_ACCOUNTED_CR            => 0,
                            P_DESCRIPTION             => var_description,
                            P_SOURCE_ID               => PP_LOAN_ID,
                            P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');
                            
                    END IF;
                    
                    /*********************************************/
                    /* ABONO : INTERESES MORATORIOS COBRADOS     */
                    /*********************************************/
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(
                        P_HEADER_ID               => PP_HEADER_ID,
                        P_ROW_NUMBER              => 7,
                        P_CODE_COMBINATION_ID     => var_int_rec_account_id,
                        P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST_LATE',
                        P_ACCOUNTED_DR            => 0,
                        P_ACCOUNTED_CR            => var_asps_payment_int_late,
                        P_DESCRIPTION             => var_description,
                        P_SOURCE_ID               => PP_LOAN_ID,
                        P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');
                    
                END IF;

        EXCEPTION WHEN OTHERS THEN
            RAISE INT_CREATE_JOURNAL_EX;                 
        END;
    
    BEGIN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'SETTLEMENT_LOAN_WITH_SAVING');
        
        FOR detail IN LOANS_DETAILS LOOP
        
            var_code_company            := NULL;
            var_time_period_id          := NULL;
            var_period_name             := NULL;
            var_payment_date            := NULL;
            var_payment_schedule_id     := NULL;
            var_loan_balance            := NULL;
            var_saving_retirement       := NULL;
            var_interest_retirement     := NULL;
            var_loan_transac_balance    := NULL;
            var_interest_transaction_id := NULL;
            var_saving_transaction_id   := NULL;
            var_debit_amount            := NULL;
            var_credit_amount           := NULL;
            var_header_id               := NULL;
            var_interest_balance        := NULL;
            var_saving_balance          := NULL;
        
            SELECT ASMA.FINAL_BALANCE
              INTO var_interest_balance
              FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
             WHERE 1 = 1
               AND ASMA.MEMBER_ACCOUNT_ID = detail.INTEREST_MEMBER_ACCOUNT_ID
               AND ASMA.MEMBER_ID = detail.MEMBER_ID;
               
            SELECT ASMA.FINAL_BALANCE
              INTO var_saving_balance
              FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
             WHERE 1 = 1
               AND ASMA.MEMBER_ACCOUNT_ID = detail.SAVING_MEMBER_ACCOUNT_ID
               AND ASMA.MEMBER_ID = detail.MEMBER_ID;
               
            IF var_interest_balance > 0 OR var_saving_balance > 0 THEN               
            
                BEGIN
                
                    SELECT DISTINCT SUBSTR(PPF.PAYROLL_NAME, 0, 2) AS COMPANY_CODE
                      INTO var_code_company
                      FROM PAY_PAYROLLS_F       PPF,
                           PER_ASSIGNMENTS_F    PAF,
                           ATET_SB_MEMBERS      ASM            
                     WHERE 1 = 1
                       AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
                       AND PAF.PERSON_ID = ASM.PERSON_ID
                       AND ASM.MEMBER_ID = detail.MEMBER_ID
                       AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
                       AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE;
                
                EXCEPTION WHEN OTHERS THEN
                    RAISE COMPANY_EX;
                END;
                
                BEGIN   
                    SELECT ASPS.TIME_PERIOD_ID,
                           ASPS.PERIOD_NAME,
                           ASPS.PAYMENT_DATE,
                           ASPS.PAYMENT_SCHEDULE_ID
                      INTO var_time_period_id,
                           var_period_name,
                           var_payment_date,
                           var_payment_schedule_id
                      FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
                     WHERE 1 = 1
                       AND ASPS.LOAN_ID = detail.LOAN_ID
                       AND ASPS.STATUS_FLAG IN ('PENDING', 'EXPORTED', 'SKIP', 'PARTIAL')
                       AND ROWNUM = 1;
                EXCEPTION WHEN OTHERS THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR : LOAN_ID = ' || detail.LOAN_ID);
                    RAISE PAYMENTS_SCHEDULE_EX;
                END;
                               
                var_loan_balance := detail.loan_balance;
                var_interest_retirement := 0;
                var_saving_retirement := 0;
                var_loan_transac_balance := 0;
                
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_loan_balance * ' || var_loan_balance);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_interest_retirement * ' || var_interest_retirement);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_saving_retirement * ' || var_saving_retirement);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_loan_transac_balance * ' || var_loan_transac_balance);
                
                /********************************************************/
                /*          RETIRO DE AHORRO - INTERES GANADO           */ 
                /********************************************************/
                   
                IF var_interest_balance > 0 THEN                
                    INTERNAL_SAVING_RETIREMENT
                        (
                            PP_ACCOUNT_DESCRIPTION  => 'INTERES GANADO',
                            PP_MEMBER_ID            => detail.MEMBER_ID,
                            PP_PAYMENT_AMOUNT       => var_loan_balance,
                            PP_MEMBER_ACCOUNT_ID    => detail.INTEREST_MEMBER_ACCOUNT_ID,
                            PP_BALANCE              => var_loan_balance,
                            PP_SAVING_RETIREMENT    => var_interest_retirement,
                            PP_SAVING_TRANSACTION_ID=> var_interest_transaction_id
                        );
                
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_loan_balance * ' || var_loan_balance);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_interest_retirement * ' || var_interest_retirement);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_saving_retirement * ' || var_saving_retirement);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_loan_transac_balance * ' || var_loan_transac_balance);
                    
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS DE INTERES GANADO    ' || detail.EMPLOYEE_NUMBER || ' - ' || detail.EMPLOYEE_FULL_NAME);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    
                            
                    var_debit_amount := 0;
                    var_credit_amount := 0;
                            
                    FOR saving_detail IN SAVINGS_DETAILS (detail.MEMBER_ID, detail.INTEREST_MEMBER_ACCOUNT_ID) LOOP
                            
                        var_debit_amount := var_debit_amount + saving_detail.DEBIT_AMOUNT;
                        var_credit_amount := var_credit_amount + saving_detail.CREDIT_AMOUNT;
                                
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(saving_detail.EARNED_DATE, 40, ' ')
                                                         ||RPAD(saving_detail.PERIOD_NAME, 40, ' ')
                                                         ||LPAD(saving_detail.DEBIT_AMOUNT,40, ' ')
                                                         ||LPAD(saving_detail.CREDIT_AMOUNT,40, ' '));
                            
                    END LOOP;
                            
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('RESUMEN:', 80, ' ')
                                    ||LPAD(var_debit_amount, 40, ' ')
                                    ||LPAD(var_credit_amount, 40, ' '));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('SALDO:', 80, ' ')
                                    ||LPAD(' ', 40, ' ')
                                    ||LPAD((var_credit_amount - var_debit_amount), 40, ' '));
                        
                
                END IF;
                
                var_loan_transac_balance := var_loan_transac_balance + var_interest_retirement;
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_loan_transac_balance * ' || var_loan_transac_balance);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_interest_retirement * ' || var_interest_retirement);  
                
                /********************************************************/
                /*          RETIRO DE AHORRO - AHORRO ACUMULADO         */
                /********************************************************/
                
                IF var_loan_balance > 0 AND var_saving_balance > 0 THEN
                    INTERNAL_SAVING_RETIREMENT
                        (
                            PP_ACCOUNT_DESCRIPTION  => 'D071_CAJA DE AHORRO',
                            PP_MEMBER_ID            => detail.MEMBER_ID,
                            PP_PAYMENT_AMOUNT       => var_loan_balance,
                            PP_MEMBER_ACCOUNT_ID    => detail.SAVING_MEMBER_ACCOUNT_ID,
                            PP_BALANCE              => var_loan_balance,
                            PP_SAVING_RETIREMENT    => var_saving_retirement,
                            PP_SAVING_TRANSACTION_ID=> var_saving_transaction_id
                        );
                        
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_loan_balance * ' || var_loan_balance);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_interest_retirement * ' || var_interest_retirement);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_saving_retirement * ' || var_saving_retirement);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_loan_transac_balance * ' || var_loan_transac_balance);
                        
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS DE AHORRO    ' || detail.EMPLOYEE_NUMBER || ' - ' || detail.EMPLOYEE_FULL_NAME);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    
                            
                    var_debit_amount := 0;
                    var_credit_amount := 0;
                            
                    FOR saving_detail IN SAVINGS_DETAILS (detail.MEMBER_ID, detail.SAVING_MEMBER_ACCOUNT_ID) LOOP
                            
                        var_debit_amount := var_debit_amount + saving_detail.DEBIT_AMOUNT;
                        var_credit_amount := var_credit_amount + saving_detail.CREDIT_AMOUNT;
                                
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(saving_detail.EARNED_DATE, 40, ' ')
                                                         ||RPAD(saving_detail.PERIOD_NAME, 40, ' ')
                                                         ||LPAD(saving_detail.DEBIT_AMOUNT,40, ' ')
                                                         ||LPAD(saving_detail.CREDIT_AMOUNT,40, ' '));
                            
                    END LOOP;
                            
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('RESUMEN:', 80, ' ')
                                    ||LPAD(var_debit_amount, 40, ' ')
                                    ||LPAD(var_credit_amount, 40, ' '));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('SALDO:', 80, ' ')
                                    ||LPAD(' ', 40, ' ')
                                    ||LPAD((var_credit_amount - var_debit_amount), 40, ' '));
                END IF; 
                
                var_loan_transac_balance := var_loan_transac_balance + var_saving_retirement;
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_loan_transac_balance * ' || var_loan_transac_balance);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_saving_retirement * ' || var_saving_retirement);
                
                /********************************************************/
                /*      PAGO ANTICIPADO - CON REPARTO DE AHORRO         */
                /********************************************************/
                
                IF var_loan_transac_balance > 0 THEN
                
                    INTERNAL_LOAN_TRANSACTION
                        (
                            PP_MEMBER_ID            => detail.MEMBER_ID,
                            PP_PERSON_ID            => detail.PERSON_ID,
                            PP_PAYMENT_DATE         => var_payment_date,
                            PP_TIME_PERIOD_ID       => var_time_period_id,
                            PP_PERIOD_NAME          => var_period_name,
                            PP_PAYMENT_AMOUNT       => var_loan_transac_balance, 
                            PP_PAYMENT_SCHEDULE_ID  => var_payment_schedule_id,
                            PP_LOAN_ID              => detail.LOAN_ID
                        );
                        
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_loan_transac_balance * ' || var_loan_transac_balance);
                        
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS DEL PRESTAMO    ' || detail.EMPLOYEE_NUMBER || ' - ' || detail.EMPLOYEE_FULL_NAME);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                        
                    var_debit_amount := 0;
                    var_credit_amount := 0;
                        
                    FOR detail_loan IN LOAN_TRANSACTION_DETAILS  (detail.LOAN_ID) LOOP
                        
                        var_debit_amount := var_debit_amount + detail_loan.DEBIT_AMOUNT;
                        var_credit_amount := var_credit_amount + detail_loan.CREDIT_AMOUNT;
                            
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(detail_loan.EARNED_DATE, 40, ' ')
                                                         ||RPAD(detail_loan.PERIOD_NAME, 40, ' ')
                                                         ||LPAD(detail_loan.DEBIT_AMOUNT,40, ' ')
                                                         ||LPAD(detail_loan.CREDIT_AMOUNT,40, ' '));
                        
                    END LOOP;
                        
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('RESUMEN:', 80, ' ')
                                    ||LPAD(var_debit_amount, 40, ' ')
                                    ||LPAD(var_credit_amount, 40, ' '));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('SALDO:', 80, ' ')
                                    ||LPAD(' ', 40, ' ')
                                    ||LPAD((var_debit_amount - var_credit_amount), 40, ' ')); 
                    
                    
                    /********************************************************/
                    /*                  CREACIÓN DE POLIZA                  */
                    /********************************************************/
                    INTERNAL_CREATE_JOURNAL
                        (
                            PP_PERSON_ID                => detail.PERSON_ID,
                            PP_MEMBER_ID                => detail.MEMBER_ID,
                            PP_EMPLOYEE_NUMBER          => detail.EMPLOYEE_NUMBER,
                            PP_EMPLOYEE_FULL_NAME       => detail.EMPLOYEE_FULL_NAME,
                            PP_LOAN_ID                  => detail.LOAN_ID,
                            PP_LOAN_NUMBER              => detail.LOAN_NUMBER,
                            PP_PAYMENT_AMOUNT           => var_loan_transac_balance,
                            PP_INTEREST_RETIREMENT      => var_interest_retirement,
                            PP_INTEREST_TRANSACTION_ID  => var_interest_transaction_id,
                            PP_SAVING_RETIREMENT        => var_saving_retirement,
                            PP_SAVING_TRANSACTION_ID    => var_saving_transaction_id,
                            PP_TIME_PERIOD_ID           => var_time_period_id,
                            PP_NOT_REC_ACCOUNT_ID       => detail.LOAN_CODE_COMBINATION_ID,
                            PP_SAV_ACCOUNT_ID           => detail.SAVING_CODE_COMBINATION_ID,
                            PP_INT_EAR_ACCOUNT_ID       => detail.INTEREST_CODE_COMBINATION_ID,
                            PP_HEADER_ID                => var_header_id
                        );
                        
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_loan_balance * ' || var_loan_balance);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_interest_retirement * ' || var_interest_retirement);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_saving_retirement * ' || var_saving_retirement);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_loan_transac_balance * ' || var_loan_transac_balance);                                            
                        
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS CONTABLES    ' || detail.EMPLOYEE_NUMBER || ' - ' || detail.EMPLOYEE_FULL_NAME);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                        
                    var_debit_amount := 0;
                    var_credit_amount := 0;
                        
                    FOR detail_accounted IN ACCOUNTED_DETAILS(var_header_id) LOOP
                        
                        var_debit_amount := var_debit_amount + detail_accounted.ACCOUNTED_DR;
                        var_credit_amount := var_credit_amount + detail_accounted.ACCOUNTED_CR;
                            
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(GET_CODE_COMBINATION(detail_accounted.CODE_COMBINATION_ID) , 40, ' ')
                                                         ||RPAD(detail_accounted.DESCRIPTION, 40, ' ')
                                                         ||LPAD(detail_accounted.ACCOUNTED_DR,40, ' ')
                                                         ||LPAD(detail_accounted.ACCOUNTED_CR,40, ' '));
                        
                    END LOOP;
                        
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('TOTAL:', 80, ' ')
                                    ||LPAD(var_debit_amount, 40, ' ')
                                    ||LPAD(var_credit_amount, 40, ' '));
                    
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('+', 160, '+'));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                
                END IF;
            
            END IF;
            

        
        END LOOP;
        
        COMMIT;
        ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL;
        
    EXCEPTION
        WHEN INSERT_LOAN_EX THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: INSERT_LOAN_EX.');
            P_RETCODE := 2;
        WHEN GROUP_INSERT_LOAN_EX THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: GROUP_INSERT_LOAN_EX.');
            P_RETCODE := 2;
        WHEN INT_SAVING_RETIREMENT_EX THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: INT_SAVING_RETIREMENT_EX.');
            P_RETCODE := 2;
        WHEN INT_LOAN_TRANSACTION_EX THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: INT_LOAN_TRANSACTION_EX.');
            P_RETCODE := 2;
        WHEN INT_CREATE_JOURNAL_EX THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: INT_CREATE_JOURNAL_EX.');
            P_RETCODE := 2;
        WHEN COMPANY_EX THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: COMPANY_EX.');
            P_RETCODE := 2;
        WHEN PAYMENTS_SCHEDULE_EX THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: PAYMENTS_SCHEDULE_EX.');
            P_RETCODE := 2;    
        WHEN INSERT_SAVING_EXCEPTION THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: INSERT_SAVING_EXCEPTION.');
            P_RETCODE := 2;
        WHEN SELECT_SAVING_EXCEPTION THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: SELECT_SAVING_EXCEPTION.');
            P_RETCODE := 2;
        WHEN UPDATE_SAVING_EXCEPTION THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: UPDATE_SAVING_EXCEPTION.');
            P_RETCODE := 2;
        WHEN NO_SAVING_BALANCE_EX THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: NO_SAVING_BALANCE_EX.');
            P_RETCODE := 2;
        WHEN OTHERS THEN
            ROLLBACK;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: OTHERS_EXCEPTION.');
            P_RETCODE := 2;
    END SETTLEMENT_LOAN_WITH_SAVING;    
    
    
    
    
    PROCEDURE   CURRENCY_DISTRIBUTION(
                    P_ERRBUF        OUT NOCOPY VARCHAR2,
                    P_RETCODE       OUT NOCOPY VARCHAR2,
                    P_YEAR                      NUMBER,
                    P_MEMBER_NAME               VARCHAR2)
    IS
        var_validate                    NUMBER;
        var_user_id                     NUMBER := FND_GLOBAL.USER_ID;
        var_saving_transaction_id       NUMBER;
        var_bank_code_comb              VARCHAR2(100);
        var_bank_account_id             NUMBER;
        var_header_id                   NUMBER;
        var_accounted_cr                NUMBER;
        var_check_id                    NUMBER;
        var_debit_amount                NUMBER;
        var_credit_amount               NUMBER;
        var_row_index                   NUMBER;
        
        INT_ROUND_RETIREMENT_EX         EXCEPTION;
        INT_CURRENCY_DISTRIBUTION_EX    EXCEPTION;
        INSERT_SAVING_EX                EXCEPTION; 
        NO_SAVING_BALANCE_EX            EXCEPTION;
        SELECT_SAVING_EX                EXCEPTION;
        UPDATE_SAVING_EX                EXCEPTION;
        INT_SAVING_RETIREMENT_EX        EXCEPTION;
        
        ADD_LAYOUT_BOOLEAN   BOOLEAN;
        V_REQUEST_ID         NUMBER;
        WAITING              BOOLEAN;
        PHASE                VARCHAR2 (80 BYTE);
        STATUS               VARCHAR2 (80 BYTE);
        DEV_PHASE            VARCHAR2 (80 BYTE);
        DEV_STATUS           VARCHAR2 (80 BYTE);
        V_MESSAGE            VARCHAR2 (4000 BYTE);
        
        CURSOR RETIREMENT_TRANSACTIONS IS
                SELECT ACD.SAVING_RETIREMENT_ROUND,
                       ACD.SAVING_TRANSACTION_ID,
                       ASM.MEMBER_ID,
                       ASM.EMPLOYEE_NUMBER,
                       ASM.EMPLOYEE_FULL_NAME,
                       ASMA.ACCOUNT_DESCRIPTION,
                       ASMA.CODE_COMBINATION_ID
                  FROM ATET_CURRENCY_DISTRIBUTION_TB    ACD,
                       ATET_SB_MEMBERS                  ASM,
                       ATET_SB_MEMBERS_ACCOUNTS         ASMA
                 WHERE 1 = 1
                   AND ACD.ACCOUNT_DESCRIPTION IN ('INTERES GANADO', 'D071_CAJA DE AHORRO')
                   AND ACD.SAVING_BANK_ID = GET_SAVING_BANK_ID
                   AND ASM.MEMBER_ID = ACD.MEMBER_ID
                   AND ASM.MEMBER_ID = ASMA.MEMBER_ID
                   AND ASMA.ACCOUNT_DESCRIPTION = ACD.ACCOUNT_DESCRIPTION
                 ORDER BY ASM.EMPLOYEE_NUMBER,
                          ASMA.ACCOUNT_DESCRIPTION;
                                   
    
        CURSOR SAVINGS_RETIREMENT_DETAILS IS
                SELECT ASM.MEMBER_ID,
                       ASM.PERSON_ID,
                       ASM.EMPLOYEE_NUMBER,
                       ASM.EMPLOYEE_FULL_NAME,
                       (ASMA1.FINAL_BALANCE + ASMA2.FINAL_BALANCE) AS   FINAL_BALANCE,
                       ASMA1.FINAL_BALANCE                         AS   SAVING_FINAL_BALANCE,
                       ASMA1.MEMBER_ACCOUNT_ID                     AS   SAVING_ACCOUNT_ID,
                       ASMA1.ACCOUNT_DESCRIPTION                   AS   SAVING_ACCOUNT_DESCRIPTION,
                       ASMA2.FINAL_BALANCE                         AS   INTEREST_FINAL_BALANCE,
                       ASMA2.MEMBER_ACCOUNT_ID                     AS   INTEREST_ACCOUNT_ID,
                       ASMA2.ACCOUNT_DESCRIPTION                   AS   INTEREST_ACCOUNT_DESCRIPTION
                  FROM ATET_SB_MEMBERS                  ASM,
                       ATET_SB_MEMBERS_ACCOUNTS         ASMA1,
                       ATET_SB_MEMBERS_ACCOUNTS         ASMA2,
                       PER_ASSIGNMENTS_F                PAF,
                       PAY_PERSONAL_PAYMENT_METHODS_F   PPM,
                       PAY_ORG_PAYMENT_METHODS_F        OPM
                 WHERE 1 = 1
                   AND ASM.MEMBER_ID = ASMA1.MEMBER_ID
                   AND ASM.MEMBER_ID = ASMA2.MEMBER_ID
                   AND ASMA1.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO'
                   AND ASMA2.ACCOUNT_DESCRIPTION = 'INTERES GANADO'
                   AND (ASMA1.FINAL_BALANCE + ASMA2.FINAL_BALANCE) > 0
                   AND ASM.PERSON_ID = PAF.PERSON_ID
                   AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
                   AND PAF.ASSIGNMENT_ID = PPM.ASSIGNMENT_ID
                   AND SYSDATE BETWEEN PPM.EFFECTIVE_START_DATE AND PPM.EFFECTIVE_END_DATE
                   AND OPM.ORG_PAYMENT_METHOD_ID = PPM.ORG_PAYMENT_METHOD_ID
                   AND SYSDATE BETWEEN OPM.EFFECTIVE_START_DATE AND OPM.EFFECTIVE_END_DATE
                   AND OPM.ORG_PAYMENT_METHOD_NAME LIKE '%EFECTIVO%';
                   
        CURSOR ACCOUNTED_DETAILS (PP_HEADER_ID NUMBER) IS
            SELECT AXL2.LINE_NUMBER,
                   AXL2.CODE_COMBINATION_ID,
                   AXL2.DESCRIPTION,
                   AXL2.ACCOUNTED_DR,
                   AXL2.ACCOUNTED_CR
              FROM ATET_XLA_LINES           AXL2
             WHERE 1 = 1
               AND AXL2.HEADER_ID = PP_HEADER_ID
             ORDER BY AXL2.LINE_NUMBER;
                   
        FUNCTION INTERNAL_ROUND_RETIREMENT(
            P_SALARY    NUMBER) RETURN NUMBER
        IS
            var_salary          NUMBER(12, 2);
            var_centavos        VARCHAR2(10);
        BEGIN

            --Para el caso en dÃ³nde los netos a pagar existan decimales, se considerarÃ¡ lo siguiente:
            IF ( INSTR(P_SALARY, '.') > 0 ) THEN

                var_centavos    := SUBSTR(P_SALARY, INSTR(P_SALARY, '.'), LENGTH(P_SALARY));
                var_salary      := TO_NUMBER(REPLACE(P_SALARY, var_centavos));
            
                IF (TO_NUMBER(var_centavos, '9.99') >= .01 AND TO_NUMBER(var_centavos, '9.99') <= .49) THEN
                
                    var_salary := var_salary;
                

                ELSIF (TO_NUMBER(var_centavos, '9.99') >= .50 AND TO_NUMBER(var_centavos, '9.99') <= .99) THEN
                
                    var_salary := var_salary + 0.50;
                
                
--                ELSIF (TO_NUMBER(var_centavos, '9.99') >= .75 AND TO_NUMBER(var_centavos, '9.99') <= .99) THEN
--                
--                    var_salary := var_salary + 1;
--                
                END IF;

            ELSE
             
               var_salary := P_SALARY;
            
            END IF;
            
            IF var_salary IS NULL THEN
                var_salary := 0;
            END IF;
            
            RETURN var_salary;
            
        EXCEPTION WHEN OTHERS THEN
            RAISE INT_ROUND_RETIREMENT_EX;            
        END;           
                    
        PROCEDURE INTERNAL_CURRENCY_DISTRIBUTION(
           P_MEMBER_ID              IN  NUMBER,      
           P_SAVING_RETIREMENT      IN  NUMBER,
           P_ACCOUNT_DESCRIPTION    IN  VARCHAR2,
           P_SAVING_TRANSACTION_ID  IN  NUMBER)   
        AS
               var_500      NUMBER;
               var_200      NUMBER;
               var_100      NUMBER;
               var_50       NUMBER;
               var_20       NUMBER;
               var_10       NUMBER;
               var_5        NUMBER;
               var_2        NUMBER;
               var_1        NUMBER;
               var_50c      NUMBER;
               var_rest     NUMBER := INTERNAL_ROUND_RETIREMENT(P_SAVING_RETIREMENT);
               var_round    NUMBER := INTERNAL_ROUND_RETIREMENT(P_SAVING_RETIREMENT);
        BEGIN
            
            --Quinientos pesos.
            IF (TRUNC(var_rest / 500) > 0) THEN
               var_500 := TRUNC(var_rest / 500);
               var_rest := var_rest - (var_500 * 500);
            ELSE
               var_500 := 0;
            END IF;

            --Doscientos pesos.
            IF (TRUNC(var_rest / 200) > 0) THEN
                var_200 := TRUNC(var_rest / 200);
                var_rest := var_rest - (var_200 * 200);
            ELSE
                var_200 := 0;
            END IF;
            
            --Cien pesos.
            IF (TRUNC(var_rest / 100) > 0) THEN
                var_100 := TRUNC(var_rest / 100);
                var_rest := var_rest - (var_100 * 100);
            ELSE
                var_100 := 0;
            END IF;
            
            --Cincuenta pesos.
            IF (TRUNC(var_rest / 50) > 0) THEN
                var_50 := TRUNC(var_rest / 50);
                var_rest := var_rest - (var_50 * 50);
            ELSE
                var_50 := 0;
            END IF;
            
            --Veinte pesos.
            IF (TRUNC(var_rest / 20) > 0) THEN
                var_20 := TRUNC(var_rest / 20);
                var_rest := var_rest - (var_20 * 20);
            ELSE
                var_20 := 0;
            END IF;
            
            --Diez pesos.
            IF (TRUNC(var_rest / 10) > 0) THEN
                var_10 := TRUNC(var_rest / 10);
                var_rest := var_rest -(var_10 * 10);
            ELSE
                var_10 := 0;
            END IF;
            
            --Cinco pesos.
            IF (TRUNC(var_rest / 5) > 0) THEN
                var_5 := TRUNC(var_rest / 5);
                var_rest := var_rest - (var_5 * 5);
            ELSE
                var_5 := 0;
            END IF;
            
            --Dos pesos.
            IF (TRUNC(var_rest / 2) > 0) THEN
                var_2 := TRUNC(var_rest / 2);
                var_rest := var_rest - (var_2 * 2);
            ELSE
                var_2 := 0;
            END IF;
            
            --Un peso.
            IF (TRUNC(var_rest) > 0) THEN
                var_1 := TRUNC(var_rest);
                var_rest := var_rest - (var_1);
            ELSE
                var_1 := 0;
            END IF;
            
            --Cincuenta centavos.
            IF (TRUNC(var_rest / .50) > 0) THEN
                var_50c := TRUNC(var_rest / .50);
                var_rest := var_rest - (var_50c * .50);
            ELSE
                var_50c := 0;
            END IF;
            
            INSERT INTO ATET_CURRENCY_DISTRIBUTION_TB(MEMBER_ID,
                                                      SAVING_TRANSACTION_ID,
                                                      ACCOUNT_DESCRIPTION,
                                                      SAVING_RETIREMENT,
                                                      SAVING_RETIREMENT_ROUND,
                                                      CURRENCY_500,
                                                      CURRENCY_200,
                                                      CURRENCY_100,
                                                      CURRENCY_50,
                                                      CURRENCY_20,
                                                      CURRENCY_10,
                                                      CURRENCY_5,
                                                      CURRENCY_2,
                                                      CURRENCY_1,
                                                      CURRENCY_50c,
                                                      SAVING_BANK_ID)
                                             VALUES (P_MEMBER_ID,
                                                     P_SAVING_TRANSACTION_ID,
                                                     P_ACCOUNT_DESCRIPTION,
                                                     P_SAVING_RETIREMENT,
                                                     var_round,
                                                     var_500,
                                                     var_200,
                                                     var_100,
                                                     var_50,
                                                     var_20,
                                                     var_10,
                                                     var_5,
                                                     var_2,
                                                     var_1,
                                                     var_50c,
                                                     GET_SAVING_BANK_ID);
        EXCEPTION WHEN OTHERS THEN
            RAISE INT_CURRENCY_DISTRIBUTION_EX;
        END;
        
        PROCEDURE INTERNAL_SAVING_RETIREMENT(
            PP_ACCOUNT_DESCRIPTION          VARCHAR2,
            PP_MEMBER_ID                    NUMBER,
            PP_MEMBER_ACCOUNT_ID            NUMBER,
            PP_SAVING_RETIREMENT            NUMBER,
            PP_SAVING_RETIREMENT_ROUND      NUMBER,
            PP_SAVING_TRANSACTION_ID    OUT NUMBER)
        IS
            var_saving_balance          NUMBER;
            var_debit_amount            NUMBER;
            var_credit_amount           NUMBER;
            var_saving_retirement_seq   NUMBER;
        BEGIN
            
            SELECT ASMA.FINAL_BALANCE
              INTO var_saving_balance
              FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
             WHERE 1 = 1
               AND ASMA.MEMBER_ID = PP_MEMBER_ID
               AND ASMA.LOAN_ID IS NULL
               AND ASMA.ACCOUNT_DESCRIPTION = PP_ACCOUNT_DESCRIPTION;
               
            var_debit_amount := 0;
            var_credit_amount := 0;
            
            IF var_saving_balance = 0 THEN
                RAISE NO_SAVING_BALANCE_EX;
            END IF;
            
            SELECT ATET_SB_SAVING_RETIREMENT_SEQ.NEXTVAL
              INTO var_saving_retirement_seq 
              FROM DUAL;
              
            var_debit_amount := PP_SAVING_RETIREMENT;
            var_credit_amount := 0;
            
            BEGIN
                            
                INSERT INTO ATET_SB_SAVINGS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                          MEMBER_ID,
                                                          PAYROLL_RESULT_ID,
                                                          PERSON_ID,
                                                          EARNED_DATE,
                                                          PERIOD_NAME,
                                                          ELEMENT_NAME,
                                                          ENTRY_VALUE,
                                                          TRANSACTION_CODE,
                                                          DEBIT_AMOUNT,
                                                          CREDIT_AMOUNT,
                                                          ATTRIBUTE1,
                                                          ATTRIBUTE2,
                                                          ATTRIBUTE6,
                                                          ATTRIBUTE7,
                                                          ACCOUNTED_FLAG,
                                                          CREATION_DATE,
                                                          CREATED_BY,
                                                          LAST_UPDATE_DATE,
                                                          LAST_UPDATED_BY)
                                                  VALUES (PP_MEMBER_ACCOUNT_ID,
                                                          PP_MEMBER_ID,
                                                          -1,
                                                          GET_PERSON_ID(PP_MEMBER_ID),
                                                          TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                                                          'RETIRO',
                                                          'RETIRO POR REPARTO DE AHORRO',
                                                          PP_SAVING_RETIREMENT,
                                                          'RETIREMENT',
                                                          var_debit_amount,
                                                          var_credit_amount,
                                                          var_saving_retirement_seq,
                                                          PP_SAVING_RETIREMENT_ROUND,
                                                          'RETIRO POR REPARTO DE AHORRO',
                                                          'REPARTO DE AHORRO',
                                                          'ACCOUNTED',
                                                          SYSDATE,
                                                          var_user_id,
                                                          SYSDATE,
                                                          var_user_id);                                                                          
                            
            EXCEPTION WHEN OTHERS THEN
                RAISE INSERT_SAVING_EX;                                                                          
            END;
            
            BEGIN                                     
                                                      
                SELECT ASST.SAVING_TRANSACTION_ID
                  INTO PP_SAVING_TRANSACTION_ID
                  FROM ATET_SB_SAVINGS_TRANSACTIONS ASST
                 WHERE 1 = 1
                   AND ASST.MEMBER_ACCOUNT_ID = PP_MEMBER_ACCOUNT_ID
                   AND ASST.MEMBER_ID = PP_MEMBER_ID
                   AND ASST.PERSON_ID = GET_PERSON_ID(PP_MEMBER_ID)
                   AND ASST.PERIOD_NAME = 'RETIRO'
                   AND ASST.ELEMENT_NAME = 'RETIRO POR REPARTO DE AHORRO'
                   AND ASST.TRANSACTION_CODE = 'RETIREMENT'
                   AND ASST.ATTRIBUTE7 = 'REPARTO DE AHORRO';
                   
            EXCEPTION WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE(SQLERRM);
                RAISE SELECT_SAVING_EX;
            END;
            
            BEGIN
                                                                      
                UPDATE ATET_SB_MEMBERS_ACCOUNTS
                   SET DEBIT_BALANCE = DEBIT_BALANCE + var_debit_amount,
                       CREDIT_BALANCE = CREDIT_BALANCE + var_credit_amount,
                       LAST_TRANSACTION_DATE = SYSDATE               
                 WHERE MEMBER_ID = PP_MEMBER_ID
                   AND MEMBER_ACCOUNT_ID = PP_MEMBER_ACCOUNT_ID;

                              
                UPDATE ATET_SB_MEMBERS_ACCOUNTS
                   SET FINAL_BALANCE = CREDIT_BALANCE - DEBIT_BALANCE,
                       LAST_UPDATE_DATE = SYSDATE,
                       LAST_UPDATED_BY = var_user_id             
                 WHERE MEMBER_ID = PP_MEMBER_ID
                   AND MEMBER_ACCOUNT_ID = PP_MEMBER_ACCOUNT_ID;
                            
            EXCEPTION WHEN OTHERS THEN
                RAISE UPDATE_SAVING_EX;
            END;
        
        EXCEPTION WHEN OTHERS THEN
            RAISE INT_SAVING_RETIREMENT_EX;
        END;                
        
        PROCEDURE INTERNAL_CREATE_CHECK(
            P_RETIREMENT               NUMBER,
            P_MEMBER_NAME              VARCHAR2,               
            P_CHECK_ID      OUT NOCOPY NUMBER)
        IS
            LN_BANK_ACCOUNT_ID           NUMBER;
            LC_BANK_ACCOUNT_NAME         VARCHAR2 (150);
            LC_BANK_ACCOUNT_NUM          VARCHAR2 (150);
            LC_BANK_NAME                 VARCHAR2 (150);
            LC_CURRENCY_CODE             VARCHAR2 (150);
            
            LD_TRANSACTION_DATE          DATE;
            LN_CHECK_NUMBER              NUMBER;
            LN_CHECK_ID                  NUMBER;

            INPUT_STRING                 VARCHAR2 (200);
            OUTPUT_STRING                VARCHAR2 (200);
            ENCRYPTED_RAW                RAW (2000); 
            DECRYPTED_RAW                RAW (2000); 
            NUM_KEY_BYTES                NUMBER := 256 / 8; 
            KEY_BYTES_RAW                RAW (32);  
            ENCRYPTION_TYPE              PLS_INTEGER 
             :=                                     
               DBMS_CRYPTO.ENCRYPT_AES256
                + DBMS_CRYPTO.CHAIN_CBC
                + DBMS_CRYPTO.PAD_PKCS5;
        BEGIN
            BEGIN
                 SELECT BANK_ACCOUNT_ID,
                        BANK_ACCOUNT_NAME,
                        BANK_ACCOUNT_NUM,
                        BANK_NAME,
                        CURRENCY_CODE
                   INTO LN_BANK_ACCOUNT_ID,
                        LC_BANK_ACCOUNT_NAME,
                        LC_BANK_ACCOUNT_NUM,
                        LC_BANK_NAME,
                        LC_CURRENCY_CODE
                   FROM ATET_SB_BANK_ACCOUNTS;
            EXCEPTION
             WHEN OTHERS
             THEN
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'ERROR AL BUSCAR LA CUENTA BANCARIA');
                RAISE;
            END;
            
                       
            SELECT ATET_SB_CHECKS_ALL_SEQ.NEXTVAL 
              INTO LN_CHECK_ID 
              FROM DUAL;

            SELECT ATET_SB_CHECK_NUMBER_SEQ.NEXTVAL
              INTO LN_CHECK_NUMBER
              FROM DUAL;

            BEGIN
                INPUT_STRING :=
                      TO_CHAR (P_RETIREMENT)
                   || ','
                   || LN_CHECK_ID
                   || ','
                   || LN_CHECK_NUMBER
                   || ','
                   || P_MEMBER_NAME
                   || ','
                   || var_user_id
                   || ','
                   || TO_CHAR (CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF');

                DBMS_OUTPUT.PUT_LINE ('Original string: ' || input_string);
                key_bytes_raw := DBMS_CRYPTO.RANDOMBYTES (num_key_bytes);
                encrypted_raw :=
                   DBMS_CRYPTO.ENCRYPT (
                      src   => UTL_I18N.STRING_TO_RAW (input_string, 'AL32UTF8'),
                      typ   => encryption_type,
                      key   => key_bytes_raw);
                

                decrypted_raw :=
                   DBMS_CRYPTO.DECRYPT (src   => encrypted_raw,
                                        typ   => encryption_type,
                                        key   => key_bytes_raw);
                output_string := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
                DBMS_OUTPUT.PUT_LINE ('Cadena a encriptar: ' || input_string);
                DBMS_OUTPUT.PUT_LINE ('Cadena encriptada: ' || encrypted_raw);
                DBMS_OUTPUT.PUT_LINE ('LLave: ' || key_bytes_raw);
                DBMS_OUTPUT.PUT_LINE ('Decrypted string: ' || output_string);
            EXCEPTION
            WHEN OTHERS
            THEN
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'ERROR AL GENERAR FIRMA DIGITAL');
            END;              
            
            BEGIN
                INSERT 
                  INTO ATET_SB_CHECKS_ALL (CHECK_ID,
                                           AMOUNT,
                                           BANK_ACCOUNT_ID,
                                           BANK_ACCOUNT_NAME,
                                           CHECK_DATE,
                                           CHECK_NUMBER,
                                           MEMBER_ID,
                                           MEMBER_NAME,
                                           CURRENCY_CODE,
                                           PAYMENT_TYPE_FLAG,
                                           STATUS_LOOKUP_CODE,
                                           BANK_ACCOUNT_NUM,
                                           DIGITAL_SIGNATURE,
                                           DECRYPT_KEY,
                                           PAYMENT_DESCRIPTION,
                                           LAST_UPDATED_BY,
                                           LAST_UPDATE_DATE,
                                           CREATED_BY,
                                           CREATION_DATE)
                                 VALUES (LN_CHECK_ID,
                                         P_RETIREMENT,
                                         LN_BANK_ACCOUNT_ID,
                                         LC_BANK_ACCOUNT_NAME,
                                         SYSDATE,
                                         LN_CHECK_NUMBER,
                                         -1,
                                         P_MEMBER_NAME,
                                         LC_CURRENCY_CODE,
                                         'CHECK_SAVING_RETIREMENT',
                                         'CREATED',
                                         LC_BANK_ACCOUNT_NUM,
                                         ENCRYPTED_RAW,
                                         KEY_BYTES_RAW,
                                         'REPARTO DE AHORRO',
                                         var_user_id,
                                         SYSDATE,
                                         var_user_id,
                                         SYSDATE);

                        P_CHECK_ID := LN_CHECK_ID;

            EXCEPTION
            WHEN OTHERS
            THEN
                DBMS_OUTPUT.PUT_LINE('Error : INSERT INTO ATET_SB_CHECKS_ALL :' || SQLERRM);
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error : INSERT INTO ATET_SB_CHECKS_ALL :' || SQLERRM);
               RAISE;
            END;
    
        EXCEPTION WHEN OTHERS THEN
            RAISE;
        END;
        
    BEGIN
    
        SELECT COUNT(ACD.MEMBER_ID)
          INTO var_validate
          FROM ATET_CURRENCY_DISTRIBUTION_TB ACD
         WHERE 1 = 1
           AND ACD.SAVING_BANK_ID = GET_SAVING_BANK_ID;
        
        IF var_validate = 0 THEN
        
            FOR detail IN SAVINGS_RETIREMENT_DETAILS LOOP      
            
                var_saving_transaction_id := NULL;         
                     
                IF detail.INTEREST_FINAL_BALANCE > 0 THEN
                
                    INTERNAL_SAVING_RETIREMENT
                        (
                            PP_ACCOUNT_DESCRIPTION      => detail.INTEREST_ACCOUNT_DESCRIPTION,
                            PP_MEMBER_ID                => detail.MEMBER_ID,
                            PP_MEMBER_ACCOUNT_ID        => detail.INTEREST_ACCOUNT_ID,
                            PP_SAVING_RETIREMENT        => detail.INTEREST_FINAL_BALANCE,
                            PP_SAVING_RETIREMENT_ROUND  => INTERNAL_ROUND_RETIREMENT(detail.INTEREST_FINAL_BALANCE),
                            PP_SAVING_TRANSACTION_ID    => var_saving_transaction_id
                        );
                
                    INTERNAL_CURRENCY_DISTRIBUTION
                        (
                            P_MEMBER_ID             => detail.MEMBER_ID,      
                            P_SAVING_RETIREMENT     => detail.INTEREST_FINAL_BALANCE,
                            P_ACCOUNT_DESCRIPTION   => detail.INTEREST_ACCOUNT_DESCRIPTION,
                            P_SAVING_TRANSACTION_ID => var_saving_transaction_id
                        );
                    
                END IF;
                
                IF detail.SAVING_FINAL_BALANCE > 0 THEN
                    
                    INTERNAL_SAVING_RETIREMENT
                        (
                            PP_ACCOUNT_DESCRIPTION      => detail.SAVING_ACCOUNT_DESCRIPTION,
                            PP_MEMBER_ID                => detail.MEMBER_ID,
                            PP_MEMBER_ACCOUNT_ID        => detail.SAVING_ACCOUNT_ID,
                            PP_SAVING_RETIREMENT        => detail.SAVING_FINAL_BALANCE,
                            PP_SAVING_RETIREMENT_ROUND  => INTERNAL_ROUND_RETIREMENT(detail.SAVING_FINAL_BALANCE),
                            PP_SAVING_TRANSACTION_ID    => var_saving_transaction_id
                        );
                    
                    INTERNAL_CURRENCY_DISTRIBUTION
                        (
                            P_MEMBER_ID             => detail.MEMBER_ID,      
                            P_SAVING_RETIREMENT     => detail.SAVING_FINAL_BALANCE,
                            P_ACCOUNT_DESCRIPTION   => detail.SAVING_ACCOUNT_DESCRIPTION,
                            P_SAVING_TRANSACTION_ID => var_saving_transaction_id
                        );
                    
                END IF;
            
            END LOOP;
            
            var_bank_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'BANK_CODE_COMB');
            var_bank_account_id := GET_CODE_COMBINATION_ID(var_bank_code_comb);
            var_accounted_cr := 0;
            var_row_index := 0;
        
            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (P_ENTITY_CODE        => 'SAVINGS',
                                                       P_EVENT_TYPE_CODE    => 'SAVING_RETIREMENT',
                                                       P_BATCH_NAME         => 'RETIRO DE AHORRO',
                                                       P_JOURNAL_NAME       => 'REPARTO DE AHORRO EN EFECTIVO ' || GET_SAVING_BANK_YEAR,
                                                       P_HEADER_ID          => var_header_id);
            
            FOR detail IN RETIREMENT_TRANSACTIONS LOOP

                var_row_index := var_row_index + 1;    
            
                IF detail.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO' THEN                                                   
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_row_index,
                                                             P_CODE_COMBINATION_ID     => detail.CODE_COMBINATION_ID,
                                                             P_ACCOUNTING_CLASS_CODE   => 'SAVING_RETIREMENT',
                                                             P_ACCOUNTED_DR            => detail.SAVING_RETIREMENT_ROUND,
                                                             P_ACCOUNTED_CR            => 0,
                                                             P_DESCRIPTION             => 'RETIRO DE AHORRO ACUMULADO : ' || detail.EMPLOYEE_NUMBER || '-' || detail.EMPLOYEE_FULL_NAME,
                                                             P_SOURCE_ID               => detail.SAVING_TRANSACTION_ID,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
                END IF;                                                   
                       
                IF detail.ACCOUNT_DESCRIPTION = 'INTERES GANADO' THEN                                                                                           
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_row_index,
                                                             P_CODE_COMBINATION_ID     => detail.CODE_COMBINATION_ID,
                                                             P_ACCOUNTING_CLASS_CODE   => 'SAVING_RETIREMENT',
                                                             P_ACCOUNTED_DR            => detail.SAVING_RETIREMENT_ROUND,
                                                             P_ACCOUNTED_CR            => 0,
                                                             P_DESCRIPTION             => 'RETIRO DE INTERES GANADO : ' || detail.EMPLOYEE_NUMBER || '-' || detail.EMPLOYEE_FULL_NAME,
                                                             P_SOURCE_ID               => detail.SAVING_TRANSACTION_ID,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
                END IF;

                var_accounted_cr := var_accounted_cr + detail.SAVING_RETIREMENT_ROUND;       
                
                UPDATE ATET_SB_MEMBERS  ASM
                   SET ASM.MEMBER_END_DATE = TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                       ASM.LAST_UPDATE_DATE = SYSDATE,
                       ASM.LAST_UPDATED_BY = var_user_id
                 WHERE 1 = 1
                   AND ASM.MEMBER_ID = detail.MEMBER_ID;                                                       
        
            END LOOP;
            
            INTERNAL_CREATE_CHECK
                (
                    P_RETIREMENT    =>  var_accounted_cr,
                    P_MEMBER_NAME   =>  P_MEMBER_NAME,
                    P_CHECK_ID      =>  var_check_id
                );
            
            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                     P_ROW_NUMBER              => var_row_index + 1,
                                                     P_CODE_COMBINATION_ID     => var_bank_account_id,
                                                     P_ACCOUNTING_CLASS_CODE   => 'SAVING_RETIREMENT',
                                                     P_ACCOUNTED_DR            => 0,
                                                     P_ACCOUNTED_CR            => var_accounted_cr,
                                                     P_DESCRIPTION             => 'REPARTO DE AHORRO EN EFECTIVO ' || GET_SAVING_BANK_YEAR,
                                                     P_SOURCE_ID               => var_check_id,
                                                     P_SOURCE_LINK_TABLE       => 'ATET_SB_CHECKS_ALL');
                                                     
            /**********************************************************/
            /*******                    COMMIT                     ****/
            /**********************************************************/
            COMMIT;
                                                     
            /**********************************************************/
            /*******             IMPRESIÓN DE CHEQUE               ****/
            /**********************************************************/
            FND_GLOBAL.APPS_INITIALIZE 
                (
                    USER_ID        => var_user_id,
                    RESP_ID        => 53698,
                    RESP_APPL_ID   => 101);
            MO_GLOBAL.SET_POLICY_CONTEXT 
                (
                    P_ACCESS_MODE  => 'S',
                    P_ORG_ID       => 1329);
            
            PRINT_SAVING_RETIREMENT_CHECK
                (
                    P_CHECK_ID => var_check_id
                ); 
                
            /**********************************************************/
            /*******             TRANSFER TO GL                    ****/
            /**********************************************************/    
            ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL; 
        
            /**********************************************************/
            /*******                    OUTPUT                     ****/
            /**********************************************************/
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS CONTABLES    ' );
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                            
            var_debit_amount := 0;
            var_credit_amount := 0;
                            
            FOR detail_accounted IN ACCOUNTED_DETAILS(var_header_id) LOOP
                            
                var_debit_amount := var_debit_amount + detail_accounted.ACCOUNTED_DR;
                var_credit_amount := var_credit_amount + detail_accounted.ACCOUNTED_CR;
                                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(GET_CODE_COMBINATION(detail_accounted.CODE_COMBINATION_ID) , 40, ' ')
                                                 ||RPAD(detail_accounted.DESCRIPTION, 40, ' ')
                                                 ||LPAD(detail_accounted.ACCOUNTED_DR,40, ' ')
                                                 ||LPAD(detail_accounted.ACCOUNTED_CR,40, ' '));
                            
            END LOOP;
                            
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('TOTAL:', 80, ' ')
                            ||LPAD(var_debit_amount, 40, ' ')
                            ||LPAD(var_credit_amount, 40, ' ')); 
        
        END IF;
        
        
        FND_GLOBAL.APPS_INITIALIZE 
            (
                USER_ID        => var_user_id,
                RESP_ID        => 53698,
                RESP_APPL_ID   => 101);
        MO_GLOBAL.SET_POLICY_CONTEXT 
            (
                P_ACCESS_MODE  => 'S',
                P_ORG_ID       => 1329);
        
        
        ADD_LAYOUT_BOOLEAN :=
            FND_REQUEST.ADD_LAYOUT 
                (
                   TEMPLATE_APPL_NAME   => 'PER',
                   TEMPLATE_CODE        => 'ATET_CURRENCY_DISTRIBUTION',
                   TEMPLATE_LANGUAGE    => 'Spanish', 
                   TEMPLATE_TERRITORY   => 'Mexico', 
                   OUTPUT_FORMAT        => 'EXCEL' 
                );



         V_REQUEST_ID :=
            FND_REQUEST.SUBMIT_REQUEST 
                (
                    APPLICATION         =>  'PER', 
                    PROGRAM             =>  'ATET_CURRENCY_DISTRIBUTION', 
                    DESCRIPTION         =>  '',
                    START_TIME          =>  '',
                    SUB_REQUEST         =>  FALSE,
                    ARGUMENT1           =>  TO_CHAR (P_YEAR)
                );
         
         STANDARD.COMMIT;
         
         WAITING := 
            FND_CONCURRENT.WAIT_FOR_REQUEST 
                (
                    REQUEST_ID          =>  V_REQUEST_ID,
                    INTERVAL            =>  1,
                    MAX_WAIT            =>  0,
                    PHASE               =>  PHASE,
                    STATUS              =>  STATUS,
                    DEV_PHASE           =>  DEV_PHASE,
                    DEV_STATUS          =>  DEV_STATUS,
                    MESSAGE             =>  V_MESSAGE
                );   
        
    EXCEPTION
        WHEN INT_ROUND_RETIREMENT_EX THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'INT_ROUND_RETIREMENT_EX');
        WHEN INT_CURRENCY_DISTRIBUTION_EX THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'INT_CURRENCY_DISTRIBUTION_EX');
        WHEN INSERT_SAVING_EX THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT_SAVING_EX'); 
        WHEN NO_SAVING_BALANCE_EX THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'NO_SAVING_BALANCE_EX');
        WHEN SELECT_SAVING_EX THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'SELECT_SAVING_EX');
        WHEN UPDATE_SAVING_EX THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'UPDATE_SAVING_EX');
        WHEN INT_SAVING_RETIREMENT_EX THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'INT_SAVING_RETIREMENT_EX');
    END CURRENCY_DISTRIBUTION;
                    
    
    PROCEDURE   SAVING_DISTRIBUTION_WITH_CHECK(
                    P_ERRBUF        OUT NOCOPY VARCHAR2,
                    P_RETCODE       OUT NOCOPY VARCHAR2,
                    P_MEMBER_ID     NUMBER)
    IS
        var_saving_member_account_id    NUMBER;
        var_interest_member_account_id  NUMBER;
        
        var_saving_retirement           NUMBER;
        var_sav_code_combination_id     NUMBER;
        var_interest_retirement         NUMBER;
        var_int_code_combination_id     NUMBER;
        
        var_bank_code_comb              VARCHAR2(100);
        var_bank_account_id             NUMBER;
        
        var_saving_transaction_id       NUMBER;
        var_interest_transaction_id     NUMBER;
        
        var_user_id                     NUMBER := FND_GLOBAL.USER_ID;
        var_check_id                    NUMBER;
        var_header_id                   NUMBER;
        
        var_employee_number             VARCHAR2(50);
        var_employee_full_name          VARCHAR2(500);
        
        var_debit_amount                NUMBER;
        var_credit_amount               NUMBER;
        
        INSERT_SAVING_EX                EXCEPTION;
        SELECT_SAVING_EX                EXCEPTION;
        UPDATE_SAVING_EX                EXCEPTION;
        INT_SAVING_RETIREMENT_EX        EXCEPTION;
        QRY_SAVING_BALANCE_EX           EXCEPTION;
        QRY_INTEREST_BALANCE_EX         EXCEPTION;
        
        CURSOR SAVINGS_DETAILS (PP_MEMBER_ID  NUMBER, PP_MEMBER_ACCOUNT_ID NUMBER)IS
            SELECT ASST.EARNED_DATE,
                   ASST.PERIOD_NAME,
                   ASST.ELEMENT_NAME,
                   ASST.DEBIT_AMOUNT,
                   ASST.CREDIT_AMOUNT
              FROM ATET_SB_SAVINGS_TRANSACTIONS ASST
             WHERE 1 = 1
               AND ASST.MEMBER_ID = PP_MEMBER_ID
               AND ASST.MEMBER_ACCOUNT_ID = PP_MEMBER_ACCOUNT_ID
             ORDER BY ASST.SAVING_TRANSACTION_ID;
             
        CURSOR ACCOUNTED_DETAILS (PP_HEADER_ID NUMBER) IS
            SELECT AXL2.LINE_NUMBER,
                   AXL2.CODE_COMBINATION_ID,
                   AXL2.DESCRIPTION,
                   AXL2.ACCOUNTED_DR,
                   AXL2.ACCOUNTED_CR
              FROM ATET_XLA_LINES           AXL2
             WHERE 1 = 1
               AND AXL2.HEADER_ID = PP_HEADER_ID
             ORDER BY AXL2.LINE_NUMBER;
        
        PROCEDURE INTERNAL_SAVING_RETIREMENT(
            PP_ACCOUNT_DESCRIPTION          VARCHAR2,
            PP_MEMBER_ID                    NUMBER,
            PP_MEMBER_ACCOUNT_ID            NUMBER,
            PP_SAVING_RETIREMENT            NUMBER,
            PP_SAVING_TRANSACTION_ID    OUT NUMBER)
        IS
            var_saving_balance          NUMBER;
            var_debit_amount            NUMBER;
            var_credit_amount           NUMBER;
            var_saving_retirement_seq   NUMBER;
        BEGIN
            
            var_debit_amount := 0;
            var_credit_amount := 0;
                        
            SELECT ATET_SB_SAVING_RETIREMENT_SEQ.NEXTVAL
              INTO var_saving_retirement_seq 
              FROM DUAL;
              
            var_debit_amount := PP_SAVING_RETIREMENT;
            var_credit_amount := 0;
            
            BEGIN
                            
                INSERT INTO ATET_SB_SAVINGS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                          MEMBER_ID,
                                                          PAYROLL_RESULT_ID,
                                                          PERSON_ID,
                                                          EARNED_DATE,
                                                          PERIOD_NAME,
                                                          ELEMENT_NAME,
                                                          ENTRY_VALUE,
                                                          TRANSACTION_CODE,
                                                          DEBIT_AMOUNT,
                                                          CREDIT_AMOUNT,
                                                          ATTRIBUTE1,
                                                          ATTRIBUTE6,
                                                          ATTRIBUTE7,
                                                          ACCOUNTED_FLAG,
                                                          CREATION_DATE,
                                                          CREATED_BY,
                                                          LAST_UPDATE_DATE,
                                                          LAST_UPDATED_BY)
                                                  VALUES (PP_MEMBER_ACCOUNT_ID,
                                                          PP_MEMBER_ID,
                                                          -1,
                                                          GET_PERSON_ID(PP_MEMBER_ID),
                                                          TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                                                          'RETIRO',
                                                          'RETIRO POR REPARTO DE AHORRO',
                                                          PP_SAVING_RETIREMENT,
                                                          'RETIREMENT',
                                                          var_debit_amount,
                                                          var_credit_amount,
                                                          var_saving_retirement_seq,
                                                          'RETIRO POR REPARTO DE AHORRO',
                                                          'REPARTO DE AHORRO',
                                                          'ACCOUNTED',
                                                          SYSDATE,
                                                          var_user_id,
                                                          SYSDATE,
                                                          var_user_id);                                                                          
                            
            EXCEPTION WHEN OTHERS THEN
                RAISE INSERT_SAVING_EX;                                                                          
            END;
            
            BEGIN                                     
                                                      
                SELECT ASST.SAVING_TRANSACTION_ID
                  INTO PP_SAVING_TRANSACTION_ID
                  FROM ATET_SB_SAVINGS_TRANSACTIONS ASST
                 WHERE 1 = 1
                   AND ASST.MEMBER_ACCOUNT_ID = PP_MEMBER_ACCOUNT_ID
                   AND ASST.MEMBER_ID = PP_MEMBER_ID
                   AND ASST.PERSON_ID = GET_PERSON_ID(PP_MEMBER_ID)
                   AND ASST.PERIOD_NAME = 'RETIRO'
                   AND ASST.ELEMENT_NAME = 'RETIRO POR REPARTO DE AHORRO'
                   AND ASST.TRANSACTION_CODE = 'RETIREMENT'
                   AND ASST.ATTRIBUTE7 = 'REPARTO DE AHORRO';
                   
            EXCEPTION WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE(SQLERRM);
                RAISE SELECT_SAVING_EX;
            END;
            
            BEGIN
                                                                      
                UPDATE ATET_SB_MEMBERS_ACCOUNTS
                   SET DEBIT_BALANCE = DEBIT_BALANCE + var_debit_amount,
                       CREDIT_BALANCE = CREDIT_BALANCE + var_credit_amount,
                       LAST_TRANSACTION_DATE = SYSDATE               
                 WHERE MEMBER_ID = PP_MEMBER_ID
                   AND MEMBER_ACCOUNT_ID = PP_MEMBER_ACCOUNT_ID;

                              
                UPDATE ATET_SB_MEMBERS_ACCOUNTS
                   SET FINAL_BALANCE = CREDIT_BALANCE - DEBIT_BALANCE,
                       LAST_UPDATE_DATE = SYSDATE,
                       LAST_UPDATED_BY = var_user_id             
                 WHERE MEMBER_ID = PP_MEMBER_ID
                   AND MEMBER_ACCOUNT_ID = PP_MEMBER_ACCOUNT_ID;
                            
            EXCEPTION WHEN OTHERS THEN
                RAISE UPDATE_SAVING_EX;
            END;
        
        EXCEPTION WHEN OTHERS THEN
            RAISE INT_SAVING_RETIREMENT_EX;
        END;
        
        PROCEDURE INTERNAL_CREATE_CHECK(
            P_MEMBER_ID                NUMBER,
            P_RETIREMENT               NUMBER,
            P_CHECK_ID      OUT NOCOPY NUMBER)
        IS
            LN_BANK_ACCOUNT_ID           NUMBER;
            LC_BANK_ACCOUNT_NAME         VARCHAR2 (150);
            LC_BANK_ACCOUNT_NUM          VARCHAR2 (150);
            LC_BANK_NAME                 VARCHAR2 (150);
            LC_CURRENCY_CODE             VARCHAR2 (150);
            
            LN_SAVING_TRANSACTION_AMOUNT NUMBER;
            LN_MEMBER_ID                 NUMBER;
            LC_EMPLOYEE_FULL_NAME        VARCHAR2 (300);
            
            LD_TRANSACTION_DATE          DATE;
            LN_CHECK_NUMBER              NUMBER;
            LN_CHECK_ID                  NUMBER;

            INPUT_STRING                 VARCHAR2 (200);
            OUTPUT_STRING                VARCHAR2 (200);
            ENCRYPTED_RAW                RAW (2000); 
            DECRYPTED_RAW                RAW (2000); 
            NUM_KEY_BYTES                NUMBER := 256 / 8; 
            KEY_BYTES_RAW                RAW (32);  
            ENCRYPTION_TYPE              PLS_INTEGER 
             :=                                     
               DBMS_CRYPTO.ENCRYPT_AES256
                + DBMS_CRYPTO.CHAIN_CBC
                + DBMS_CRYPTO.PAD_PKCS5;
        BEGIN
            BEGIN
                 SELECT BANK_ACCOUNT_ID,
                        BANK_ACCOUNT_NAME,
                        BANK_ACCOUNT_NUM,
                        BANK_NAME,
                        CURRENCY_CODE
                   INTO LN_BANK_ACCOUNT_ID,
                        LC_BANK_ACCOUNT_NAME,
                        LC_BANK_ACCOUNT_NUM,
                        LC_BANK_NAME,
                        LC_CURRENCY_CODE
                   FROM ATET_SB_BANK_ACCOUNTS;
            EXCEPTION
             WHEN OTHERS
             THEN
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'ERROR AL BUSCAR LA CUENTA BANCARIA');
                RAISE;
            END;
            
            BEGIN
                SELECT ASM.EMPLOYEE_FULL_NAME,
                       ASM.MEMBER_ID,
                       P_RETIREMENT,
                       SYSDATE
                  INTO LC_EMPLOYEE_FULL_NAME,
                       LN_MEMBER_ID,
                       LN_SAVING_TRANSACTION_AMOUNT,
                       LD_TRANSACTION_DATE
                  FROM ATET_SB_MEMBERS              ASM
                 WHERE ASM.MEMBER_ID = P_MEMBER_ID;
            EXCEPTION
            WHEN OTHERS
            THEN
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'ERROR AL BUSCAR EL MIEMBRO');
               RAISE;
            END;
            
            SELECT ATET_SB_CHECKS_ALL_SEQ.NEXTVAL 
              INTO LN_CHECK_ID 
              FROM DUAL;

            SELECT ATET_SB_CHECK_NUMBER_SEQ.NEXTVAL
              INTO LN_CHECK_NUMBER
              FROM DUAL;

            BEGIN
                INPUT_STRING :=
                      TO_CHAR (LN_SAVING_TRANSACTION_AMOUNT)
                   || ','
                   || LN_CHECK_ID
                   || ','
                   || LN_CHECK_NUMBER
                   || ','
                   || LN_MEMBER_ID
                   || ','
                   || FND_GLOBAL.USER_ID
                   || ','
                   || TO_CHAR (CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF');

                DBMS_OUTPUT.PUT_LINE ('Original string: ' || input_string);
                key_bytes_raw := DBMS_CRYPTO.RANDOMBYTES (num_key_bytes);
                encrypted_raw :=
                   DBMS_CRYPTO.ENCRYPT (
                      src   => UTL_I18N.STRING_TO_RAW (input_string, 'AL32UTF8'),
                      typ   => encryption_type,
                      key   => key_bytes_raw);
                

                decrypted_raw :=
                   DBMS_CRYPTO.DECRYPT (src   => encrypted_raw,
                                        typ   => encryption_type,
                                        key   => key_bytes_raw);
                output_string := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
                DBMS_OUTPUT.PUT_LINE ('Cadena a encriptar: ' || input_string);
                DBMS_OUTPUT.PUT_LINE ('Cadena encriptada: ' || encrypted_raw);
                DBMS_OUTPUT.PUT_LINE ('LLave: ' || key_bytes_raw);
                DBMS_OUTPUT.PUT_LINE ('Decrypted string: ' || output_string);
            EXCEPTION
            WHEN OTHERS
            THEN
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'ERROR AL GENERAR FIRMA DIGITAL');
            END;              
            
            BEGIN
                INSERT 
                  INTO ATET_SB_CHECKS_ALL (CHECK_ID,
                                           AMOUNT,
                                           BANK_ACCOUNT_ID,
                                           BANK_ACCOUNT_NAME,
                                           CHECK_DATE,
                                           CHECK_NUMBER,
                                           CURRENCY_CODE,
                                           PAYMENT_TYPE_FLAG,
                                           STATUS_LOOKUP_CODE,
                                           MEMBER_ID,
                                           MEMBER_NAME,
                                           BANK_ACCOUNT_NUM,
                                           DIGITAL_SIGNATURE,
                                           DECRYPT_KEY,
                                           PAYMENT_DESCRIPTION,
                                           LAST_UPDATED_BY,
                                           LAST_UPDATE_DATE,
                                           CREATED_BY,
                                           CREATION_DATE)
                                 VALUES (LN_CHECK_ID,
                                         LN_SAVING_TRANSACTION_AMOUNT,
                                         LN_BANK_ACCOUNT_ID,
                                         LC_BANK_ACCOUNT_NAME,
                                         LD_TRANSACTION_DATE,
                                         LN_CHECK_NUMBER,
                                         LC_CURRENCY_CODE,
                                         'CHECK_SAVING_RETIREMENT',
                                         'CREATED',
                                         LN_MEMBER_ID,
                                         LC_EMPLOYEE_FULL_NAME,
                                         LC_BANK_ACCOUNT_NUM,
                                         ENCRYPTED_RAW,
                                         KEY_BYTES_RAW,
                                         'REPARTO DE AHORRO',
                                         FND_GLOBAL.USER_ID,
                                         SYSDATE,
                                         FND_GLOBAL.USER_ID,
                                         SYSDATE);

                        P_CHECK_ID := LN_CHECK_ID;

            EXCEPTION
            WHEN OTHERS
            THEN
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error : INSERT INTO ATET_SB_CHECKS_ALL :' || SQLERRM);
               RAISE;
            END;
    
        EXCEPTION WHEN OTHERS THEN
            RAISE;
        END;                
        
    BEGIN
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'SAVING_DISTRIBUTION_WITH_CHECK(P_MEMBER_ID => ' || P_MEMBER_ID || ')');
        
        var_saving_member_account_id := GET_SAVING_MEMBER_ACCOUNT_ID(P_MEMBER_ID, GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAV_CODE_COMB'), GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME'));                                                                 
        var_interest_member_account_id := GET_INTEREST_MEMBER_ACCOUNT_ID(P_MEMBER_ID);
        var_saving_retirement := 0;
        var_interest_retirement := 0;
        
        BEGIN
            SELECT ASMA.FINAL_BALANCE,
                   ASMA.CODE_COMBINATION_ID
              INTO var_saving_retirement,
                   var_sav_code_combination_id
              FROM ATET_SB_MEMBERS_ACCOUNTS     ASMA
             WHERE 1 = 1
               AND ASMA.MEMBER_ID = P_MEMBER_ID
               AND ASMA.MEMBER_ACCOUNT_ID = var_saving_member_account_id
               AND ASMA.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO';
        EXCEPTION WHEN OTHERS THEN
            RAISE QRY_SAVING_BALANCE_EX;       
        END;
        
        BEGIN
            SELECT ASMA.FINAL_BALANCE,
                   ASMA.CODE_COMBINATION_ID
              INTO var_interest_retirement,
                   var_int_code_combination_id
              FROM ATET_SB_MEMBERS_ACCOUNTS     ASMA
             WHERE 1 = 1
               AND ASMA.MEMBER_ID = P_MEMBER_ID
               AND ASMA.MEMBER_ACCOUNT_ID = var_interest_member_account_id
               AND ASMA.ACCOUNT_DESCRIPTION = 'INTERES GANADO';
        EXCEPTION WHEN OTHERS THEN
            RAISE QRY_INTEREST_BALANCE_EX;
        END;
        
        IF var_saving_retirement <> 0 THEN
            INTERNAL_SAVING_RETIREMENT
                (
                    PP_ACCOUNT_DESCRIPTION  => 'D071_CAJA DE AHORRO',
                    PP_MEMBER_ID            => P_MEMBER_ID,
                    PP_MEMBER_ACCOUNT_ID    => var_saving_member_account_id,
                    PP_SAVING_RETIREMENT    => var_saving_retirement,
                    PP_SAVING_TRANSACTION_ID=> var_saving_transaction_id
                );
        END IF;
               
        IF var_interest_retirement <> 0 THEN 
            INTERNAL_SAVING_RETIREMENT
                (
                    PP_ACCOUNT_DESCRIPTION  => 'INTERES GANADO',
                    PP_MEMBER_ID            => P_MEMBER_ID,
                    PP_MEMBER_ACCOUNT_ID    => var_interest_member_account_id,
                    PP_SAVING_RETIREMENT    => var_interest_retirement,
                    PP_SAVING_TRANSACTION_ID=> var_interest_transaction_id
                );
        END IF;          
        
        UPDATE ATET_SB_MEMBERS  ASM
           SET ASM.MEMBER_END_DATE = TO_DATE(SYSDATE, 'DD/MM/RRRR'),
               ASM.LAST_UPDATE_DATE = SYSDATE,
               ASM.LAST_UPDATED_BY = var_user_id
         WHERE 1 = 1
           AND ASM.MEMBER_ID = P_MEMBER_ID;     
           
        
        SELECT ASM.EMPLOYEE_NUMBER,
               ASM.EMPLOYEE_FULL_NAME
          INTO var_employee_number,
               var_employee_full_name
          FROM ATET_SB_MEMBERS      ASM
         WHERE 1 = 1
           AND ASM.MEMBER_ID = P_MEMBER_ID;
           
           
        /**********************************************************/
        /*******             CREACIÓN DE CHEQUE                ****/
        /**********************************************************/
        INTERNAL_CREATE_CHECK
            (
                P_MEMBER_ID     => P_MEMBER_ID,
                P_RETIREMENT    => var_saving_retirement + var_interest_retirement,
                P_CHECK_ID      => var_check_id
            );   
            
        /**********************************************************/
        /*******             IMPRESIÓN DE CHEQUE               ****/
        /**********************************************************/
        PRINT_SAVING_RETIREMENT_CHECK(P_CHECK_ID => var_check_id);  
        
        /**********************************************************/
        /*******             CREACIÓN DE POLIZA                ****/
        /**********************************************************/
        var_bank_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'BANK_CODE_COMB');
        var_bank_account_id := GET_CODE_COMBINATION_ID(var_bank_code_comb);

                    
        ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (P_ENTITY_CODE        => 'SAVINGS',
                                                   P_EVENT_TYPE_CODE    => 'SAVING_RETIREMENT',
                                                   P_BATCH_NAME         => 'RETIRO DE AHORRO',
                                                   P_JOURNAL_NAME       => 'RETIRO POR REPARTO DE AHORRO : ' || var_employee_number || '-' || var_employee_full_name,
                                                   P_HEADER_ID          => var_header_id);

        IF var_interest_retirement <> 0 THEN                                                   
            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                     P_ROW_NUMBER              => 1,
                                                     P_CODE_COMBINATION_ID     => var_int_code_combination_id,
                                                     P_ACCOUNTING_CLASS_CODE   => 'SAVING_RETIREMENT',
                                                     P_ACCOUNTED_DR            => var_interest_retirement,
                                                     P_ACCOUNTED_CR            => 0,
                                                     P_DESCRIPTION             => 'RETIRO DE INTERES GANADO : ' || var_employee_number || '-' || var_employee_full_name,
                                                     P_SOURCE_ID               => var_interest_transaction_id,
                                                     P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
        END IF;                                                   
               
        IF var_saving_retirement <> 0 THEN                                                                                           
            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                     P_ROW_NUMBER              => 2,
                                                     P_CODE_COMBINATION_ID     => var_sav_code_combination_id,
                                                     P_ACCOUNTING_CLASS_CODE   => 'SAVING_RETIREMENT',
                                                     P_ACCOUNTED_DR            => var_saving_retirement,
                                                     P_ACCOUNTED_CR            => 0,
                                                     P_DESCRIPTION             => 'RETIRO DE AHORRO ACUMULADO : ' || var_employee_number || '-' || var_employee_full_name,
                                                     P_SOURCE_ID               => var_saving_transaction_id,
                                                     P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
        END IF;
                                                             
        ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                 P_ROW_NUMBER              => 2,
                                                 P_CODE_COMBINATION_ID     => var_bank_account_id,
                                                 P_ACCOUNTING_CLASS_CODE   => 'SAVING_RETIREMENT',
                                                 P_ACCOUNTED_DR            => 0,
                                                 P_ACCOUNTED_CR            => var_interest_retirement + var_saving_retirement,
                                                 P_DESCRIPTION             => 'RETIRO POR REPARTO DE AHORRO : ' || var_employee_number || '-' || var_employee_full_name,
                                                 P_SOURCE_ID               => var_check_id,
                                                 P_SOURCE_LINK_TABLE       => 'ATET_SB_CHECKS_ALL');                                                      
        
        /**********************************************************/
        /*******                   OUTPUT                      ****/
        /**********************************************************/   
        IF var_interest_retirement <> 0 THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS DE INTERES GANADO    ' || var_employee_number || ' - ' || var_employee_full_name);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            
            var_debit_amount := 0;
            var_credit_amount := 0;
                            
            FOR saving_detail IN SAVINGS_DETAILS (P_MEMBER_ID, var_interest_member_account_id) LOOP
                            
                var_debit_amount := var_debit_amount + saving_detail.DEBIT_AMOUNT;
                var_credit_amount := var_credit_amount + saving_detail.CREDIT_AMOUNT;
                                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(saving_detail.EARNED_DATE, 40, ' ')
                                                 ||RPAD(saving_detail.PERIOD_NAME, 40, ' ')
                                                 ||LPAD(saving_detail.DEBIT_AMOUNT,40, ' ')
                                                 ||LPAD(saving_detail.CREDIT_AMOUNT,40, ' '));
                            
            END LOOP;
            
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('RESUMEN:', 80, ' ')
                            ||LPAD(var_debit_amount, 40, ' ')
                            ||LPAD(var_credit_amount, 40, ' '));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('SALDO:', 80, ' ')
                            ||LPAD(' ', 40, ' ')
                            ||LPAD((var_credit_amount - var_debit_amount), 40, ' '));
        END IF;
        
        IF var_saving_retirement <> 0 THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS DE AHORRO    ' || var_employee_number || ' - ' || var_employee_full_name);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    
                            
            var_debit_amount := 0;
            var_credit_amount := 0;
                            
            FOR saving_detail IN SAVINGS_DETAILS (P_MEMBER_ID, var_saving_member_account_id) LOOP
                            
                var_debit_amount := var_debit_amount + saving_detail.DEBIT_AMOUNT;
                var_credit_amount := var_credit_amount + saving_detail.CREDIT_AMOUNT;
                                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(saving_detail.EARNED_DATE, 40, ' ')
                                                 ||RPAD(saving_detail.PERIOD_NAME, 40, ' ')
                                                 ||LPAD(saving_detail.DEBIT_AMOUNT,40, ' ')
                                                 ||LPAD(saving_detail.CREDIT_AMOUNT,40, ' '));
                            
            END LOOP;
                            
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('RESUMEN:', 80, ' ')
                            ||LPAD(var_debit_amount, 40, ' ')
                            ||LPAD(var_credit_amount, 40, ' '));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('SALDO:', 80, ' ')
                            ||LPAD(' ', 40, ' ')
                            ||LPAD((var_credit_amount - var_debit_amount), 40, ' '));
        END IF;
        
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS CONTABLES    ' || var_employee_number || ' - ' || var_employee_full_name);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                        
        var_debit_amount := 0;
        var_credit_amount := 0;
                        
        FOR detail_accounted IN ACCOUNTED_DETAILS(var_header_id) LOOP
                        
            var_debit_amount := var_debit_amount + detail_accounted.ACCOUNTED_DR;
            var_credit_amount := var_credit_amount + detail_accounted.ACCOUNTED_CR;
                            
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(GET_CODE_COMBINATION(detail_accounted.CODE_COMBINATION_ID) , 40, ' ')
                                             ||RPAD(detail_accounted.DESCRIPTION, 40, ' ')
                                             ||LPAD(detail_accounted.ACCOUNTED_DR,40, ' ')
                                             ||LPAD(detail_accounted.ACCOUNTED_CR,40, ' '));
                        
        END LOOP;
                        
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('TOTAL:', 80, ' ')
                        ||LPAD(var_debit_amount, 40, ' ')
                        ||LPAD(var_credit_amount, 40, ' '));                                  
                         
    
    END SAVING_DISTRIBUTION_WITH_CHECK;

    PROCEDURE   RETIREMENT_DISPERSION(
                    P_ERRBUF        OUT NOCOPY VARCHAR2,
                    P_RETCODE       OUT NOCOPY VARCHAR2,
                    P_YEAR                      NUMBER,
                    P_MEMBER_NAME               VARCHAR2,
                    P_PAYMENT_METHOD_ID         NUMBER)
    IS
        var_validate                    NUMBER;
        var_user_id                     NUMBER := FND_GLOBAL.USER_ID;
        var_saving_transaction_id       NUMBER;
        var_bank_code_comb              VARCHAR2(100);
        var_bank_account_id             NUMBER;
        var_header_id                   NUMBER;
        var_accounted_cr                NUMBER;
        var_check_id                    NUMBER;
        var_debit_amount                NUMBER;
        var_credit_amount               NUMBER;
        var_row_index                   NUMBER;
        var_payment_method_name         VARCHAR2(200);
        
        INT_ROUND_RETIREMENT_EX         EXCEPTION;
        INT_CURRENCY_DISTRIBUTION_EX    EXCEPTION;
        INSERT_SAVING_EX                EXCEPTION; 
        NO_SAVING_BALANCE_EX            EXCEPTION;
        SELECT_SAVING_EX                EXCEPTION;
        UPDATE_SAVING_EX                EXCEPTION;
        INT_SAVING_RETIREMENT_EX        EXCEPTION;
        
        ADD_LAYOUT_BOOLEAN   BOOLEAN;
        V_REQUEST_ID         NUMBER;
        WAITING              BOOLEAN;
        PHASE                VARCHAR2 (80 BYTE);
        STATUS               VARCHAR2 (80 BYTE);
        DEV_PHASE            VARCHAR2 (80 BYTE);
        DEV_STATUS           VARCHAR2 (80 BYTE);
        V_MESSAGE            VARCHAR2 (4000 BYTE);
        
        CURSOR RETIREMENT_TRANSACTIONS IS
                SELECT ARD.SAVING_TRANSACTION_ID,
                       ASM.MEMBER_ID,
                       ASM.EMPLOYEE_NUMBER,
                       ASM.EMPLOYEE_FULL_NAME,
                       ASMA.ACCOUNT_DESCRIPTION,
                       ASMA.CODE_COMBINATION_ID,
                       ARD.SAVING_RETIREMENT
                  FROM ATET_RETIREMENT_DISPERSION_TB    ARD,
                       ATET_SB_MEMBERS                  ASM,
                       ATET_SB_MEMBERS_ACCOUNTS         ASMA
                 WHERE 1 = 1
                   AND ARD.ACCOUNT_DESCRIPTION IN ('INTERES GANADO', 'D071_CAJA DE AHORRO')
                   AND ARD.SAVING_BANK_ID = GET_SAVING_BANK_ID
                   AND ASM.MEMBER_ID = ARD.MEMBER_ID
                   AND ASM.MEMBER_ID = ASMA.MEMBER_ID
                   AND ASMA.ACCOUNT_DESCRIPTION = ARD.ACCOUNT_DESCRIPTION
                   AND ARD.PAYMENT_METHOD_ID = P_PAYMENT_METHOD_ID
                 ORDER BY ASM.EMPLOYEE_NUMBER,
                          ASMA.ACCOUNT_DESCRIPTION;
                                   
    
        CURSOR SAVINGS_RETIREMENT_DETAILS IS
                SELECT ASM.MEMBER_ID,
                       ASM.PERSON_ID,
                       ASM.EMPLOYEE_NUMBER,
                       ASM.EMPLOYEE_FULL_NAME,
                       (ASMA1.FINAL_BALANCE + ASMA2.FINAL_BALANCE) AS   FINAL_BALANCE,
                       ASMA1.FINAL_BALANCE                         AS   SAVING_FINAL_BALANCE,
                       ASMA1.MEMBER_ACCOUNT_ID                     AS   SAVING_ACCOUNT_ID,
                       ASMA1.ACCOUNT_DESCRIPTION                   AS   SAVING_ACCOUNT_DESCRIPTION,
                       ASMA2.FINAL_BALANCE                         AS   INTEREST_FINAL_BALANCE,
                       ASMA2.MEMBER_ACCOUNT_ID                     AS   INTEREST_ACCOUNT_ID,
                       ASMA2.ACCOUNT_DESCRIPTION                   AS   INTEREST_ACCOUNT_DESCRIPTION
                  FROM ATET_SB_MEMBERS                  ASM,
                       ATET_SB_MEMBERS_ACCOUNTS         ASMA1,
                       ATET_SB_MEMBERS_ACCOUNTS         ASMA2,
                       PER_ASSIGNMENTS_F                PAF,
                       PAY_PERSONAL_PAYMENT_METHODS_F   PPM,
                       PAY_ORG_PAYMENT_METHODS_F        OPM
                 WHERE 1 = 1
                   AND ASM.MEMBER_ID = ASMA1.MEMBER_ID
                   AND ASM.MEMBER_ID = ASMA2.MEMBER_ID
                   AND ASMA1.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO'
                   AND ASMA2.ACCOUNT_DESCRIPTION = 'INTERES GANADO'
                   AND (ASMA1.FINAL_BALANCE + ASMA2.FINAL_BALANCE) > 0
                   AND ASM.PERSON_ID = PAF.PERSON_ID
                   AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
                   AND PAF.ASSIGNMENT_ID = PPM.ASSIGNMENT_ID
                   AND SYSDATE BETWEEN PPM.EFFECTIVE_START_DATE AND PPM.EFFECTIVE_END_DATE
                   AND OPM.ORG_PAYMENT_METHOD_ID = PPM.ORG_PAYMENT_METHOD_ID
                   AND SYSDATE BETWEEN OPM.EFFECTIVE_START_DATE AND OPM.EFFECTIVE_END_DATE
                   AND OPM.ORG_PAYMENT_METHOD_ID = P_PAYMENT_METHOD_ID;
                   
        CURSOR ACCOUNTED_DETAILS (PP_HEADER_ID NUMBER) IS
            SELECT AXL2.LINE_NUMBER,
                   AXL2.CODE_COMBINATION_ID,
                   AXL2.DESCRIPTION,
                   AXL2.ACCOUNTED_DR,
                   AXL2.ACCOUNTED_CR
              FROM ATET_XLA_LINES           AXL2
             WHERE 1 = 1
               AND AXL2.HEADER_ID = PP_HEADER_ID
             ORDER BY AXL2.LINE_NUMBER;
                              
        PROCEDURE INTERNAL_SAVING_RETIREMENT(
            PP_ACCOUNT_DESCRIPTION          VARCHAR2,
            PP_MEMBER_ID                    NUMBER,
            PP_MEMBER_ACCOUNT_ID            NUMBER,
            PP_SAVING_RETIREMENT            NUMBER,
            PP_SAVING_TRANSACTION_ID    OUT NUMBER)
        IS
            var_saving_balance          NUMBER;
            var_debit_amount            NUMBER;
            var_credit_amount           NUMBER;
            var_saving_retirement_seq   NUMBER;
        BEGIN
            
            SELECT ASMA.FINAL_BALANCE
              INTO var_saving_balance
              FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
             WHERE 1 = 1
               AND ASMA.MEMBER_ID = PP_MEMBER_ID
               AND ASMA.LOAN_ID IS NULL
               AND ASMA.ACCOUNT_DESCRIPTION = PP_ACCOUNT_DESCRIPTION;
               
            var_debit_amount := 0;
            var_credit_amount := 0;
            
            IF var_saving_balance = 0 THEN
                RAISE NO_SAVING_BALANCE_EX;
            END IF;
            
            SELECT ATET_SB_SAVING_RETIREMENT_SEQ.NEXTVAL
              INTO var_saving_retirement_seq 
              FROM DUAL;
              
            var_debit_amount := PP_SAVING_RETIREMENT;
            var_credit_amount := 0;
            
            BEGIN
                            
                INSERT INTO ATET_SB_SAVINGS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                          MEMBER_ID,
                                                          PAYROLL_RESULT_ID,
                                                          PERSON_ID,
                                                          EARNED_DATE,
                                                          PERIOD_NAME,
                                                          ELEMENT_NAME,
                                                          ENTRY_VALUE,
                                                          TRANSACTION_CODE,
                                                          DEBIT_AMOUNT,
                                                          CREDIT_AMOUNT,
                                                          ATTRIBUTE1,
                                                          ATTRIBUTE6,
                                                          ATTRIBUTE7,
                                                          ACCOUNTED_FLAG,
                                                          CREATION_DATE,
                                                          CREATED_BY,
                                                          LAST_UPDATE_DATE,
                                                          LAST_UPDATED_BY)
                                                  VALUES (PP_MEMBER_ACCOUNT_ID,
                                                          PP_MEMBER_ID,
                                                          -1,
                                                          GET_PERSON_ID(PP_MEMBER_ID),
                                                          TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                                                          'RETIRO',
                                                          'RETIRO POR REPARTO DE AHORRO',
                                                          PP_SAVING_RETIREMENT,
                                                          'RETIREMENT',
                                                          var_debit_amount,
                                                          var_credit_amount,
                                                          var_saving_retirement_seq,
                                                          'RETIRO POR REPARTO DE AHORRO',
                                                          'REPARTO DE AHORRO',
                                                          'ACCOUNTED',
                                                          SYSDATE,
                                                          var_user_id,
                                                          SYSDATE,
                                                          var_user_id);                                                                          
                            
            EXCEPTION WHEN OTHERS THEN
                RAISE INSERT_SAVING_EX;                                                                          
            END;
            
            BEGIN                                     
                                                      
                SELECT ASST.SAVING_TRANSACTION_ID
                  INTO PP_SAVING_TRANSACTION_ID
                  FROM ATET_SB_SAVINGS_TRANSACTIONS ASST
                 WHERE 1 = 1
                   AND ASST.MEMBER_ACCOUNT_ID = PP_MEMBER_ACCOUNT_ID
                   AND ASST.MEMBER_ID = PP_MEMBER_ID
                   AND ASST.PERSON_ID = GET_PERSON_ID(PP_MEMBER_ID)
                   AND ASST.PERIOD_NAME = 'RETIRO'
                   AND ASST.ELEMENT_NAME = 'RETIRO POR REPARTO DE AHORRO'
                   AND ASST.TRANSACTION_CODE = 'RETIREMENT'
                   AND ASST.ATTRIBUTE7 = 'REPARTO DE AHORRO';
                   
            EXCEPTION WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE(SQLERRM);
                RAISE SELECT_SAVING_EX;
            END;
            
            BEGIN
                                                                      
                UPDATE ATET_SB_MEMBERS_ACCOUNTS
                   SET DEBIT_BALANCE = DEBIT_BALANCE + var_debit_amount,
                       CREDIT_BALANCE = CREDIT_BALANCE + var_credit_amount,
                       LAST_TRANSACTION_DATE = SYSDATE               
                 WHERE MEMBER_ID = PP_MEMBER_ID
                   AND MEMBER_ACCOUNT_ID = PP_MEMBER_ACCOUNT_ID;

                              
                UPDATE ATET_SB_MEMBERS_ACCOUNTS
                   SET FINAL_BALANCE = CREDIT_BALANCE - DEBIT_BALANCE,
                       LAST_UPDATE_DATE = SYSDATE,
                       LAST_UPDATED_BY = var_user_id             
                 WHERE MEMBER_ID = PP_MEMBER_ID
                   AND MEMBER_ACCOUNT_ID = PP_MEMBER_ACCOUNT_ID;
                            
            EXCEPTION WHEN OTHERS THEN
                RAISE UPDATE_SAVING_EX;
            END;
        
        EXCEPTION WHEN OTHERS THEN
            RAISE INT_SAVING_RETIREMENT_EX;
        END;                
        
        PROCEDURE INTERNAL_CREATE_CHECK(
            P_RETIREMENT               NUMBER,
            P_MEMBER_NAME              VARCHAR2,               
            P_CHECK_ID      OUT NOCOPY NUMBER)
        IS
            LN_BANK_ACCOUNT_ID           NUMBER;
            LC_BANK_ACCOUNT_NAME         VARCHAR2 (150);
            LC_BANK_ACCOUNT_NUM          VARCHAR2 (150);
            LC_BANK_NAME                 VARCHAR2 (150);
            LC_CURRENCY_CODE             VARCHAR2 (150);
            
            LD_TRANSACTION_DATE          DATE;
            LN_CHECK_NUMBER              NUMBER;
            LN_CHECK_ID                  NUMBER;

            INPUT_STRING                 VARCHAR2 (200);
            OUTPUT_STRING                VARCHAR2 (200);
            ENCRYPTED_RAW                RAW (2000); 
            DECRYPTED_RAW                RAW (2000); 
            NUM_KEY_BYTES                NUMBER := 256 / 8; 
            KEY_BYTES_RAW                RAW (32);  
            ENCRYPTION_TYPE              PLS_INTEGER 
             :=                                     
               DBMS_CRYPTO.ENCRYPT_AES256
                + DBMS_CRYPTO.CHAIN_CBC
                + DBMS_CRYPTO.PAD_PKCS5;
        BEGIN
            BEGIN
                 SELECT BANK_ACCOUNT_ID,
                        BANK_ACCOUNT_NAME,
                        BANK_ACCOUNT_NUM,
                        BANK_NAME,
                        CURRENCY_CODE
                   INTO LN_BANK_ACCOUNT_ID,
                        LC_BANK_ACCOUNT_NAME,
                        LC_BANK_ACCOUNT_NUM,
                        LC_BANK_NAME,
                        LC_CURRENCY_CODE
                   FROM ATET_SB_BANK_ACCOUNTS;
            EXCEPTION
             WHEN OTHERS
             THEN
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'ERROR AL BUSCAR LA CUENTA BANCARIA');
                RAISE;
            END;
            
                       
            SELECT ATET_SB_CHECKS_ALL_SEQ.NEXTVAL 
              INTO LN_CHECK_ID 
              FROM DUAL;

            SELECT ATET_SB_CHECK_NUMBER_SEQ.NEXTVAL
              INTO LN_CHECK_NUMBER
              FROM DUAL;

            BEGIN
                INPUT_STRING :=
                      TO_CHAR (P_RETIREMENT)
                   || ','
                   || LN_CHECK_ID
                   || ','
                   || LN_CHECK_NUMBER
                   || ','
                   || P_MEMBER_NAME
                   || ','
                   || var_user_id
                   || ','
                   || TO_CHAR (CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF');

                DBMS_OUTPUT.PUT_LINE ('Original string: ' || input_string);
                key_bytes_raw := DBMS_CRYPTO.RANDOMBYTES (num_key_bytes);
                encrypted_raw :=
                   DBMS_CRYPTO.ENCRYPT (
                      src   => UTL_I18N.STRING_TO_RAW (input_string, 'AL32UTF8'),
                      typ   => encryption_type,
                      key   => key_bytes_raw);
                

                decrypted_raw :=
                   DBMS_CRYPTO.DECRYPT (src   => encrypted_raw,
                                        typ   => encryption_type,
                                        key   => key_bytes_raw);
                output_string := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
                DBMS_OUTPUT.PUT_LINE ('Cadena a encriptar: ' || input_string);
                DBMS_OUTPUT.PUT_LINE ('Cadena encriptada: ' || encrypted_raw);
                DBMS_OUTPUT.PUT_LINE ('LLave: ' || key_bytes_raw);
                DBMS_OUTPUT.PUT_LINE ('Decrypted string: ' || output_string);
            EXCEPTION
            WHEN OTHERS
            THEN
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'ERROR AL GENERAR FIRMA DIGITAL');
            END;              
            
            BEGIN
                INSERT 
                  INTO ATET_SB_CHECKS_ALL (CHECK_ID,
                                           AMOUNT,
                                           BANK_ACCOUNT_ID,
                                           BANK_ACCOUNT_NAME,
                                           CHECK_DATE,
                                           CHECK_NUMBER,
                                           MEMBER_ID,
                                           MEMBER_NAME,
                                           CURRENCY_CODE,
                                           PAYMENT_TYPE_FLAG,
                                           STATUS_LOOKUP_CODE,
                                           BANK_ACCOUNT_NUM,
                                           DIGITAL_SIGNATURE,
                                           DECRYPT_KEY,
                                           PAYMENT_DESCRIPTION,
                                           LAST_UPDATED_BY,
                                           LAST_UPDATE_DATE,
                                           CREATED_BY,
                                           CREATION_DATE)
                                 VALUES (LN_CHECK_ID,
                                         P_RETIREMENT,
                                         LN_BANK_ACCOUNT_ID,
                                         LC_BANK_ACCOUNT_NAME,
                                         SYSDATE,
                                         LN_CHECK_NUMBER,
                                         -1,
                                         P_MEMBER_NAME,
                                         LC_CURRENCY_CODE,
                                         'CHECK_SAVING_RETIREMENT',
                                         'CREATED',
                                         LC_BANK_ACCOUNT_NUM,
                                         ENCRYPTED_RAW,
                                         KEY_BYTES_RAW,
                                         'REPARTO DE AHORRO',
                                         var_user_id,
                                         SYSDATE,
                                         var_user_id,
                                         SYSDATE);

                        P_CHECK_ID := LN_CHECK_ID;

            EXCEPTION
            WHEN OTHERS
            THEN
                DBMS_OUTPUT.PUT_LINE('Error : INSERT INTO ATET_SB_CHECKS_ALL :' || SQLERRM);
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error : INSERT INTO ATET_SB_CHECKS_ALL :' || SQLERRM);
               RAISE;
            END;
    
        EXCEPTION WHEN OTHERS THEN
            RAISE;
        END;
        
    
        PROCEDURE INTERNAL_RETIREMENT_DISPERSION(
            PP_MEMBER_ID                NUMBER,
            PP_SAVING_TRANSACTION_ID    NUMBER,
            PP_ACCOUNT_DESCRIPTION      VARCHAR2,
            PP_SAVING_RETIREMENT        NUMBER,
            PP_PAYMENT_METHOD_ID        NUMBER,
            PP_SAVING_BANK_ID           NUMBER)
        IS 
        BEGIN
            INSERT 
              INTO ATET_RETIREMENT_DISPERSION_TB(MEMBER_ID,
                                                 SAVING_TRANSACTION_ID,
                                                 ACCOUNT_DESCRIPTION,
                                                 SAVING_RETIREMENT,
                                                 PAYMENT_METHOD_ID,
                                                 SAVING_BANK_ID)
                                         VALUES (PP_MEMBER_ID,
                                                 PP_SAVING_TRANSACTION_ID,
                                                 PP_ACCOUNT_DESCRIPTION,
                                                 PP_SAVING_RETIREMENT,
                                                 PP_PAYMENT_METHOD_ID,
                                                 PP_SAVING_BANK_ID); 
        END;
    
    BEGIN
    
        SELECT SUBSTR(POPM.ORG_PAYMENT_METHOD_NAME, 4)
          INTO var_payment_method_name
          FROM PAY_ORG_PAYMENT_METHODS_F    POPM
         WHERE 1 = 1
           AND POPM.ORG_PAYMENT_METHOD_ID = P_PAYMENT_METHOD_ID;
    
        SELECT COUNT(ARD.MEMBER_ID)
          INTO var_validate
          FROM ATET_RETIREMENT_DISPERSION_TB ARD
         WHERE 1 = 1
           AND ARD.SAVING_BANK_ID = GET_SAVING_BANK_ID
           AND ARD.PAYMENT_METHOD_ID = P_PAYMENT_METHOD_ID;
        
        IF var_validate = 0 THEN
        
            FOR detail IN SAVINGS_RETIREMENT_DETAILS LOOP      
            
                var_saving_transaction_id := NULL;         
                     
                IF detail.INTEREST_FINAL_BALANCE > 0 THEN
                
                    INTERNAL_SAVING_RETIREMENT
                        (
                            PP_ACCOUNT_DESCRIPTION      => detail.INTEREST_ACCOUNT_DESCRIPTION,
                            PP_MEMBER_ID                => detail.MEMBER_ID,
                            PP_MEMBER_ACCOUNT_ID        => detail.INTEREST_ACCOUNT_ID,
                            PP_SAVING_RETIREMENT        => detail.INTEREST_FINAL_BALANCE,
                            PP_SAVING_TRANSACTION_ID    => var_saving_transaction_id
                        );
                
                    INTERNAL_RETIREMENT_DISPERSION
                        (
                            PP_MEMBER_ID                => detail.MEMBER_ID,
                            PP_SAVING_TRANSACTION_ID    => var_saving_transaction_id,
                            PP_ACCOUNT_DESCRIPTION      => detail.INTEREST_ACCOUNT_DESCRIPTION,
                            PP_SAVING_RETIREMENT        => detail.INTEREST_FINAL_BALANCE,
                            PP_PAYMENT_METHOD_ID        => P_PAYMENT_METHOD_ID,
                            PP_SAVING_BANK_ID           => GET_SAVING_BANK_ID
                        );
                    
                END IF;
                
                IF detail.SAVING_FINAL_BALANCE > 0 THEN
                    
                    INTERNAL_SAVING_RETIREMENT
                        (
                            PP_ACCOUNT_DESCRIPTION      => detail.SAVING_ACCOUNT_DESCRIPTION,
                            PP_MEMBER_ID                => detail.MEMBER_ID,
                            PP_MEMBER_ACCOUNT_ID        => detail.SAVING_ACCOUNT_ID,
                            PP_SAVING_RETIREMENT        => detail.SAVING_FINAL_BALANCE,
                            PP_SAVING_TRANSACTION_ID    => var_saving_transaction_id
                        );
                    
                    INTERNAL_RETIREMENT_DISPERSION
                        (
                            PP_MEMBER_ID                => detail.MEMBER_ID,
                            PP_SAVING_TRANSACTION_ID    => var_saving_transaction_id,
                            PP_ACCOUNT_DESCRIPTION      => detail.SAVING_ACCOUNT_DESCRIPTION,
                            PP_SAVING_RETIREMENT        => detail.SAVING_FINAL_BALANCE,
                            PP_PAYMENT_METHOD_ID        => P_PAYMENT_METHOD_ID,
                            PP_SAVING_BANK_ID           => GET_SAVING_BANK_ID
                        );
                    
                END IF;
            
            END LOOP;
            
            var_bank_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'BANK_CODE_COMB');
            var_bank_account_id := GET_CODE_COMBINATION_ID(var_bank_code_comb);
            var_accounted_cr := 0;
            var_row_index := 0;
        
            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (P_ENTITY_CODE        => 'SAVINGS',
                                                       P_EVENT_TYPE_CODE    => 'SAVING_RETIREMENT',
                                                       P_BATCH_NAME         => 'RETIRO DE AHORRO',
                                                       P_JOURNAL_NAME       => 'REPARTO DE AHORRO ' || var_payment_method_name || ' ' || GET_SAVING_BANK_YEAR,
                                                       P_HEADER_ID          => var_header_id);
            
            FOR detail IN RETIREMENT_TRANSACTIONS LOOP

                var_row_index := var_row_index + 1;    
            
                IF detail.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO' THEN                                                   
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_row_index,
                                                             P_CODE_COMBINATION_ID     => detail.CODE_COMBINATION_ID,
                                                             P_ACCOUNTING_CLASS_CODE   => 'SAVING_RETIREMENT',
                                                             P_ACCOUNTED_DR            => detail.SAVING_RETIREMENT,
                                                             P_ACCOUNTED_CR            => 0,
                                                             P_DESCRIPTION             => 'RETIRO DE AHORRO ACUMULADO : ' || detail.EMPLOYEE_NUMBER || '-' || detail.EMPLOYEE_FULL_NAME,
                                                             P_SOURCE_ID               => detail.SAVING_TRANSACTION_ID,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
                END IF;                                                   
                       
                IF detail.ACCOUNT_DESCRIPTION = 'INTERES GANADO' THEN                                                                                           
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_row_index,
                                                             P_CODE_COMBINATION_ID     => detail.CODE_COMBINATION_ID,
                                                             P_ACCOUNTING_CLASS_CODE   => 'SAVING_RETIREMENT',
                                                             P_ACCOUNTED_DR            => detail.SAVING_RETIREMENT,
                                                             P_ACCOUNTED_CR            => 0,
                                                             P_DESCRIPTION             => 'RETIRO DE INTERES GANADO : ' || detail.EMPLOYEE_NUMBER || '-' || detail.EMPLOYEE_FULL_NAME,
                                                             P_SOURCE_ID               => detail.SAVING_TRANSACTION_ID,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
                END IF;

                var_accounted_cr := var_accounted_cr + detail.SAVING_RETIREMENT;       
                
                UPDATE ATET_SB_MEMBERS  ASM
                   SET ASM.MEMBER_END_DATE = TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                       ASM.LAST_UPDATE_DATE = SYSDATE,
                       ASM.LAST_UPDATED_BY = var_user_id
                 WHERE 1 = 1
                   AND ASM.MEMBER_ID = detail.MEMBER_ID;                                                       
        
            END LOOP;
            
            INTERNAL_CREATE_CHECK
                (
                    P_RETIREMENT    =>  var_accounted_cr,
                    P_MEMBER_NAME   =>  P_MEMBER_NAME,
                    P_CHECK_ID      =>  var_check_id
                );
            
            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                     P_ROW_NUMBER              => var_row_index + 1,
                                                     P_CODE_COMBINATION_ID     => var_bank_account_id,
                                                     P_ACCOUNTING_CLASS_CODE   => 'SAVING_RETIREMENT',
                                                     P_ACCOUNTED_DR            => 0,
                                                     P_ACCOUNTED_CR            => var_accounted_cr,
                                                     P_DESCRIPTION             => 'REPARTO DE AHORRO ' || var_payment_method_name || ' ' || GET_SAVING_BANK_YEAR,
                                                     P_SOURCE_ID               => var_check_id,
                                                     P_SOURCE_LINK_TABLE       => 'ATET_SB_CHECKS_ALL');
                                                     
            /**********************************************************/
            /*******                    COMMIT                     ****/
            /**********************************************************/
            COMMIT;
                                                     
            /**********************************************************/
            /*******             IMPRESIÓN DE CHEQUE               ****/
            /**********************************************************/
            FND_GLOBAL.APPS_INITIALIZE 
                (
                    USER_ID        => var_user_id,
                    RESP_ID        => 53698,
                    RESP_APPL_ID   => 101);
            MO_GLOBAL.SET_POLICY_CONTEXT 
                (
                    P_ACCESS_MODE  => 'S',
                    P_ORG_ID       => 1329);
            
            PRINT_SAVING_RETIREMENT_CHECK
                (
                    P_CHECK_ID => var_check_id
                ); 
                
            /**********************************************************/
            /*******             TRANSFER TO GL                    ****/
            /**********************************************************/    
            ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL; 
        
            /**********************************************************/
            /*******                    OUTPUT                     ****/
            /**********************************************************/
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    MOVIMIENTOS CONTABLES    ' );
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                            
            var_debit_amount := 0;
            var_credit_amount := 0;
                            
            FOR detail_accounted IN ACCOUNTED_DETAILS(var_header_id) LOOP
                            
                var_debit_amount := var_debit_amount + detail_accounted.ACCOUNTED_DR;
                var_credit_amount := var_credit_amount + detail_accounted.ACCOUNTED_CR;
                                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(GET_CODE_COMBINATION(detail_accounted.CODE_COMBINATION_ID) , 40, ' ')
                                                 ||RPAD(detail_accounted.DESCRIPTION, 40, ' ')
                                                 ||LPAD(detail_accounted.ACCOUNTED_DR,40, ' ')
                                                 ||LPAD(detail_accounted.ACCOUNTED_CR,40, ' '));
                            
            END LOOP;
                            
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('*',160, '*'));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LPAD('TOTAL:', 80, ' ')
                            ||LPAD(var_debit_amount, 40, ' ')
                            ||LPAD(var_credit_amount, 40, ' ')); 
        
        END IF;
        
        
        FND_GLOBAL.APPS_INITIALIZE 
            (
                USER_ID        => var_user_id,
                RESP_ID        => 53698,
                RESP_APPL_ID   => 101);
        MO_GLOBAL.SET_POLICY_CONTEXT 
            (
                P_ACCESS_MODE  => 'S',
                P_ORG_ID       => 1329);
        
        
        ADD_LAYOUT_BOOLEAN :=
            FND_REQUEST.ADD_LAYOUT 
                (
                   TEMPLATE_APPL_NAME   => 'PER',
                   TEMPLATE_CODE        => 'ATET_RETIREMENT_DISPERSION',
                   TEMPLATE_LANGUAGE    => 'Spanish', 
                   TEMPLATE_TERRITORY   => 'Mexico', 
                   OUTPUT_FORMAT        => 'EXCEL' 
                );



         V_REQUEST_ID :=
            FND_REQUEST.SUBMIT_REQUEST 
                (
                    APPLICATION         =>  'PER', 
                    PROGRAM             =>  'ATET_RETIREMENT_DISPERSION', 
                    DESCRIPTION         =>  '',
                    START_TIME          =>  '',
                    SUB_REQUEST         =>  FALSE,
                    ARGUMENT1           =>  TO_CHAR (P_YEAR),
                    ARGUMENT2           =>  TO_CHAR (P_PAYMENT_METHOD_ID)
                );
         
         STANDARD.COMMIT;
         
         WAITING := 
            FND_CONCURRENT.WAIT_FOR_REQUEST 
                (
                    REQUEST_ID          =>  V_REQUEST_ID,
                    INTERVAL            =>  1,
                    MAX_WAIT            =>  0,
                    PHASE               =>  PHASE,
                    STATUS              =>  STATUS,
                    DEV_PHASE           =>  DEV_PHASE,
                    DEV_STATUS          =>  DEV_STATUS,
                    MESSAGE             =>  V_MESSAGE
                );   
        
    EXCEPTION
        WHEN INT_ROUND_RETIREMENT_EX THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'INT_ROUND_RETIREMENT_EX');
        WHEN INT_CURRENCY_DISTRIBUTION_EX THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'INT_CURRENCY_DISTRIBUTION_EX');
        WHEN INSERT_SAVING_EX THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT_SAVING_EX'); 
        WHEN NO_SAVING_BALANCE_EX THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'NO_SAVING_BALANCE_EX');
        WHEN SELECT_SAVING_EX THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'SELECT_SAVING_EX');
        WHEN UPDATE_SAVING_EX THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'UPDATE_SAVING_EX');
        WHEN INT_SAVING_RETIREMENT_EX THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'INT_SAVING_RETIREMENT_EX');
    END RETIREMENT_DISPERSION;   
    
    FUNCTION    GET_PERSON_TYPE(
                    P_MEMBER_ID                 NUMBER
                ) RETURN VARCHAR2
    IS
        var_person_type     VARCHAR2(500);
    BEGIN
    
        SELECT PPTT.USER_PERSON_TYPE
          INTO var_person_type
          FROM ATET_SB_MEMBERS      ASM,
               PER_PEOPLE_F         PPF,
               PER_PERSON_TYPES_TL  PPTT
         WHERE 1 = 1
           AND ASM.MEMBER_ID = P_MEMBER_ID
           AND ASM.PERSON_ID = PPF.PERSON_ID
           AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE 
                           AND PPF.EFFECTIVE_END_DATE
           AND PPF.PERSON_TYPE_ID = PPTT.PERSON_TYPE_ID
           AND PPTT.LANGUAGE = 'ESA'; 
        
        RETURN var_person_type;
    END GET_PERSON_TYPE;
    
    PROCEDURE   LOAN_REPAYMENT(
                    P_ERRBUF        OUT NOCOPY VARCHAR2,
                    P_RETCODE       OUT NOCOPY VARCHAR2,
                    P_LOAN_ID       NUMBER,
                    P_TERM_PERIODS  NUMBER)
    IS
        var_member_id                   NUMBER;
        var_employee_number             NUMBER;
        var_employee_full_name          VARCHAR2(1000);
        var_loan_number                 NUMBER;
        var_loan_amount                 NUMBER;
        var_loan_amount_validate        NUMBER;
        var_interest_amount             NUMBER;
        var_interest_amount_validate    NUMBER;
        var_loan_total_amount           NUMBER;
        
        var_assignment_id               NUMBER;
        var_member_period_type          VARCHAR2(50);
        var_payroll_id                  NUMBER;
        var_term_periods                NUMBER;
        
        var_member_account_id           NUMBER;
        var_credit_balance              NUMBER;
        var_debit_balance               NUMBER;
        var_final_balance               NUMBER;
        
        var_user_id                     NUMBER := FND_GLOBAL.USER_ID;
        
        var_prepaid_seq                 NUMBER;
        
        var_loan_transaction_id         NUMBER;
        
        var_header_id                   NUMBER;
        var_not_rec_sav_code_comb       VARCHAR2(500);
        var_not_rec_sav_account_id      NUMBER;
        var_une_int_code_comb           VARCHAR2(500);
        var_une_int_account_id          NUMBER;
        
        CURSOR DETAILS (P_PAYROLL_ID    NUMBER,
                        P_TERM_PERIODS  NUMBER)
            IS
        SELECT PAYROLL_ID,
               TIME_PERIOD_ID,
               END_DATE,
               PERIOD_NAME,
               PERIOD_NUM,
               PERIOD_SEQUENCE
          FROM (SELECT PAYROLL_ID,
                       TIME_PERIOD_ID,
                       END_DATE,
                       PERIOD_NAME,
                       PERIOD_NUM,
                       ROW_NUMBER ()
                       OVER (PARTITION 
                                    BY PAYROLL_ID 
                                 ORDER 
                                    BY END_DATE)
                       PERIOD_SEQUENCE
                  FROM PER_TIME_PERIODS
                 WHERE PAYROLL_ID = P_PAYROLL_ID
                   AND (    END_DATE-2 > (SYSDATE)
                        AND END_DATE-2 > (SYSDATE))
                 ORDER 
                    BY END_DATE)
          WHERE PERIOD_SEQUENCE <= P_TERM_PERIODS;
          
        CURSOR ENDORSEMENTS 
            IS
        SELECT ASE.ENDORSEMENT_ID
          FROM ATET_SB_ENDORSEMENTS     ASE
         WHERE 1 = 1
           AND ASE.LOAN_ID = P_LOAN_ID;
        
        LOAN_AMOUNT_EX                  EXCEPTION;
        INTEREST_AMOUNT_EX              EXCEPTION;
        PRINT_PREPAID_EX                EXCEPTION;
        CREATE_JOURNAL_EX               EXCEPTION;
        
    BEGIN
        SELECT ASM.MEMBER_ID,
               ASM.EMPLOYEE_NUMBER,
               ASM.EMPLOYEE_FULL_NAME,
               ASL.LOAN_NUMBER,
               (CASE
                    WHEN ASM.ATTRIBUTE6 = 'Week' THEN
                        (ASM.AMOUNT_TO_SAVE * 4) * 4
                    WHEN ASM.ATTRIBUTE6 = 'Semi-Month' THEN
                        (ASM.AMOUNT_TO_SAVE * 2) * 4
                END)                                PRESTAMO,
               ASL.LOAN_AMOUNT,
               (CASE
                    WHEN ASM.ATTRIBUTE6 = 'Week' THEN
                        ((ASM.AMOUNT_TO_SAVE * 4) * 4) * ((SELECT ASP.PARAMETER_VALUE/100
                                                              FROM ATET_SB_PARAMETERS ASP
                                                             WHERE 1 = 1
                                                               AND ASP.PARAMETER_CODE = 'INT_RATE_SAV'
                                                               AND ASP.SAVING_BANK_ID = GET_SAVING_BANK_ID) * 4)
                    WHEN ASM.ATTRIBUTE6 = 'Semi-Month' THEN
                        ((ASM.AMOUNT_TO_SAVE * 2) * 4) * ((SELECT ASP.PARAMETER_VALUE/100
                                                              FROM ATET_SB_PARAMETERS ASP
                                                             WHERE 1 = 1
                                                               AND ASP.PARAMETER_CODE = 'INT_RATE_SAV'
                                                               AND ASP.SAVING_BANK_ID = GET_SAVING_BANK_ID) * 4)
                END)                                INTERES,
               ASL.LOAN_INTEREST_AMOUNT,
               ASL.LOAN_TOTAL_AMOUNT
          INTO var_member_id,
               var_employee_number,
               var_employee_full_name,
               var_loan_number,
               var_loan_amount_validate,
               var_loan_amount,
               var_interest_amount_validate,
               var_interest_amount,
               var_loan_total_amount
          FROM ATET_SB_MEMBERS              ASM,
               ATET_SB_LOANS                ASL
         WHERE 1 = 1
           AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID
           AND ASM.IS_SAVER = 'Y'
           AND ASM.MEMBER_ID = ASL.MEMBER_ID
           AND ASL.LOAN_STATUS_FLAG = 'APPROVED'
           AND ASL.LOAN_ID = P_LOAN_ID;
    
        IF var_loan_amount = var_loan_amount_validate AND var_interest_amount = var_interest_amount_validate THEN
            
            CREATE_ACCOUNT(GET_PERSON_ID(var_member_id), 
                           'LOAN_ELEMENT_NAME', 
                           'LOAN_SAV_CODE_COMB');
                           
                           
                           
            SET_LOAN_BALANCE(P_LOAN_ID, 
                             var_loan_total_amount, 
                             GET_PERSON_ID(var_member_id));			
                           
            
              
            SELECT PAF.ASSIGNMENT_ID,
                   PPF.PERIOD_TYPE,
                   PPF.PAYROLL_ID
              INTO var_assignment_id,
                   var_member_period_type,
                   var_payroll_id
              FROM PER_ASSIGNMENTS_F    PAF,
                   PAY_PAYROLLS_F       PPF
             WHERE 1 = 1
               AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
               AND PAF.PERSON_ID = GET_PERSON_ID(var_member_id)
               AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
               AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE;
            
            
               
            IF    var_member_period_type IN ('Week', 'Semana') THEN
                var_term_periods := 4 * P_TERM_PERIODS;
            ELSIF var_member_period_type IN ('Semi-Month', 'Quincena') THEN
                var_term_periods := 2 * P_TERM_PERIODS;
            END IF;                                                                                
        
        
            INSERT 
              INTO ATET_LOAN_PAYMENTS_ALL
                 ( 
                   AMOUNT,
                   CHECK_ID,
                   LOAN_ID,
                   PAYMENT_NUM,
                   PAYMENT_TYPE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   CREATED_BY,
                   CREATION_DATE
                 )
            VALUES
                 (
                   var_loan_total_amount,
                   -1,
                   P_LOAN_ID,
                   1,
                   'LOAN_CHECK',
                   var_user_id,
                   SYSDATE,
                   var_user_id,
                   SYSDATE
                 );
        
        
            DECLARE
                var_index                   NUMBER := 1;
                var_opening_balance         NUMBER := var_interest_amount;
                var_payment_amount          NUMBER;
                var_payment_interest        NUMBER;
                var_final_balance           NUMBER;
                var_accrual_payment_amount  NUMBER;
            BEGIN
                FOR detail IN DETAILS(var_payroll_id, var_term_periods) LOOP
                    
                    IF    var_index = 1 THEN
                    
                        var_opening_balance := var_interest_amount;
                        var_payment_amount := TRUNC((var_interest_amount / var_term_periods), 2);
                        var_payment_interest := var_payment_amount;
                        var_final_balance := var_opening_balance - var_payment_amount;
                        var_accrual_payment_amount := var_payment_amount;
                        
                    ELSIF var_index = var_term_periods THEN
                        
                        var_opening_balance := var_final_balance;
                        var_payment_amount := var_final_balance;
                        var_payment_interest := var_payment_amount;
                        var_final_balance := var_opening_balance - var_payment_amount;
                        var_accrual_payment_amount := var_accrual_payment_amount + var_payment_amount; 
                    
                    ELSE
                        
                        var_opening_balance := var_final_balance;
                        var_payment_amount := TRUNC((var_interest_amount / var_term_periods), 2);
                        var_payment_interest := var_payment_amount;
                        var_final_balance := var_opening_balance - var_payment_amount;
                        var_accrual_payment_amount := var_accrual_payment_amount + var_payment_amount; 
                    
                    END IF;    
                    
                    INSERT
                      INTO ATET_SB_PAYMENTS_SCHEDULE 
                            (
                                LOAN_ID,
                                PAYMENT_NUMBER,
                                PERIOD_NUMBER,
                                TIME_PERIOD_ID,
                                PERIOD_NAME,
                                PAYMENT_DATE,
                                PAYROLL_ID,
                                ASSIGNMENT_ID,
                                OPENING_BALANCE,
                                PAYMENT_AMOUNT,
                                PAYMENT_CAPITAL,
                                PAYMENT_INTEREST,
                                PAYMENT_INTEREST_LATE,
                                FINAL_BALANCE,
                                ACCRUAL_PAYMENT_AMOUNT,
                                STATUS_FLAG,
                                CREATION_DATE,
                                CREATED_BY,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY
                            )
                      VALUES
                            (   
                                P_LOAN_ID,
                                detail.PERIOD_SEQUENCE,
                                detail.PERIOD_NUM,
                                detail.TIME_PERIOD_ID,
                                detail.PERIOD_NAME,
                                detail.END_DATE,
                                var_payroll_id,
                                var_assignment_id,
                                var_opening_balance,
                                var_payment_amount,
                                0,
                                var_payment_interest,
                                0,
                                var_final_balance,
                                var_accrual_payment_amount,
                                'PENDING',
                                SYSDATE,
                                var_user_id,
                                SYSDATE,
                                var_user_id
                            );
                
                    var_index := var_index +1;
                END LOOP;
            END;
               
               
            UPDATE ATET_SB_MEMBERS  ASM
               SET ASM.IS_BORROWER = 'Y'
             WHERE 1 = 1
               AND ASM.MEMBER_ID = var_member_id;
               
            
            FOR detail IN ENDORSEMENTS LOOP
            
                UPDATE ATET_SB_MEMBERS  ASM
                   SET ASM.IS_ENDORSEMENT = 'Y'
                 WHERE 1 = 1
                   AND ASM.MEMBER_ID = detail.ENDORSEMENT_ID; 
            
            END LOOP;
            
            
            SELECT ASMA.MEMBER_ACCOUNT_ID,
                   ASMA.CREDIT_BALANCE,
                   ASMA.DEBIT_BALANCE,
                   ASMA.FINAL_BALANCE
              INTO var_member_account_id,
                   var_credit_balance,
                   var_debit_balance,
                   var_final_balance
              FROM ATET_SB_MEMBERS_ACCOUNTS     ASMA
             WHERE 1 = 1
               AND ASMA.MEMBER_ID = var_member_id
               AND ASMA.LOAN_ID = P_LOAN_ID; 
            
            
            INSERT 
              INTO ATET_SB_LOANS_TRANSACTIONS
                (
                    MEMBER_ACCOUNT_ID,
                    MEMBER_ID,
                    PAYROLL_RESULT_ID,
                    LOAN_ID,
                    PERSON_ID,
                    EARNED_DATE,
                    PERIOD_NAME,
                    ELEMENT_NAME,
                    TRANSACTION_CODE,
                    DEBIT_AMOUNT,
                    CREDIT_AMOUNT,
                    PAYMENT_AMOUNT,
                    PAYMENT_CAPITAL,
                    PAYMENT_INTEREST,
                    PAYMENT_INTEREST_LATE,
                    ENTRY_VALUE,
                    ACCOUNTED_FLAG,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY
                )
                VALUES
                (
                    var_member_account_id,
                    var_member_id,
                    -1,
                    P_LOAN_ID,
                    GET_PERSON_ID(var_member_id),
                    TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                    'PAGO ANTICIPADO',
                    'PAGO ANTICIPADO',
                    'REPAYMENT_LOAN',
                    0,
                    var_loan_amount,
                    var_loan_amount,
                    var_loan_amount,
                    0,
                    0,
                    var_loan_amount,
                    'ACCOUNTED',
                    SYSDATE,
                    var_user_id,
                    SYSDATE,
                    var_user_id
                );
                
                
            SELECT ASLT.LOAN_TRANSACTION_ID
              INTO var_loan_transaction_id
              FROM ATET_SB_LOANS_TRANSACTIONS   ASLT
             WHERE 1 = 1
               AND MEMBER_ACCOUNT_ID = var_member_account_id
               AND MEMBER_ID = var_member_id
               AND LOAN_ID = P_LOAN_ID
               AND PERIOD_NAME = 'PAGO ANTICIPADO'
               AND TRANSACTION_CODE = 'REPAYMENT_LOAN';
                                   

            UPDATE ATET_SB_MEMBERS_ACCOUNTS
               SET DEBIT_BALANCE = DEBIT_BALANCE + 0,
                   CREDIT_BALANCE = CREDIT_BALANCE + var_loan_amount,
                   LAST_TRANSACTION_DATE = SYSDATE               
             WHERE MEMBER_ID = var_member_id
               AND MEMBER_ACCOUNT_ID = var_member_account_id
               AND LOAN_ID = P_LOAN_ID;
               
               
            UPDATE ATET_SB_MEMBERS_ACCOUNTS
               SET FINAL_BALANCE = DEBIT_BALANCE - CREDIT_BALANCE,
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = var_user_id             
             WHERE MEMBER_ID = var_member_id
               AND MEMBER_ACCOUNT_ID = var_member_account_id
               AND LOAN_ID = P_LOAN_ID; 
               
               
            UPDATE ATET_SB_LOANS ASL
               SET ASL.LOAN_BALANCE = ASL.LOAN_BALANCE - var_loan_amount,
                   ASL.LAST_PAYMENT_DATE = TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                   ASL.LOAN_STATUS_FLAG = 'ACTIVE',
                   ASL.LAST_UPDATE_DATE = SYSDATE,
                   ASL.LAST_UPDATED_BY = var_user_id
             WHERE 1 = 1
               AND ASL.LOAN_ID = P_LOAN_ID;
        
        
            BEGIN
                
                SELECT ATET_SB_PREPAID_SEQ.NEXTVAL
                  INTO var_prepaid_seq
                  FROM DUAL;
                      
                PRINT_PREPAID
                    (
                        P_LOAN_ID => P_LOAN_ID, 
                        P_FOLIO => var_prepaid_seq,
                        P_BONUS => 0,
                        P_LOAN_TRANSACTION_ID=> var_loan_transaction_id
                    );
                    
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'PRINT : PREPAID');
                
            EXCEPTION 
                WHEN OTHERS THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
                    RAISE PRINT_PREPAID_EX;
            END;          
            
            
            BEGIN
                
                ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER
                    (
                        P_ENTITY_CODE       => 'LOANS',
                        P_EVENT_TYPE_CODE   => 'REPAYMENT_LOAN',
                        P_BATCH_NAME        => 'DEVOLUCION DE PRESTAMO CON COBRO DE INTERESES',
                        P_JOURNAL_NAME      => 'PRESTAMO CAJA DE AHORRO A: ' || var_employee_number || '-' || var_employee_full_name,
                        P_HEADER_ID         => var_header_id
                    );
                    
                    
                var_not_rec_sav_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'NOT_REC_SAV_CODE_COMB');
                var_une_int_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'UNE_INT_CODE_COMB');
                
                var_not_rec_sav_account_id := GET_CODE_COMBINATION_ID(var_not_rec_sav_code_comb);
                var_une_int_account_id := GET_CODE_COMBINATION_ID(var_une_int_code_comb);
                
                    
                ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES 
                    (
                        P_HEADER_ID               => var_header_id,
                        P_ROW_NUMBER              => 1,
                        P_CODE_COMBINATION_ID     => var_not_rec_sav_account_id,
                        P_ACCOUNTING_CLASS_CODE   => 'LOAN_CREATION',
                        P_ACCOUNTED_DR            => var_loan_total_amount,
                        P_ACCOUNTED_CR            => 0,
                        P_DESCRIPTION             => 'PRESTAMO A: ' || var_employee_full_name ||  ' ' || var_loan_number,
                        P_SOURCE_ID               => P_LOAN_ID,
                        P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS'
                    );

               ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES 
                    (
                        P_HEADER_ID               => var_header_id,
                        P_ROW_NUMBER              => 2,
                        P_CODE_COMBINATION_ID     => var_not_rec_sav_account_id,
                        P_ACCOUNTING_CLASS_CODE   => 'REPAYMENT_LOAN',
                        P_ACCOUNTED_DR            => 0,
                        P_ACCOUNTED_CR            => var_loan_amount,
                        P_DESCRIPTION             => 'DEVOLUCION DE PRESTAMO: ' || var_employee_full_name ||  ' ' || var_loan_number,
                        P_SOURCE_ID               => var_loan_transaction_id,
                        P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS'
                    );


               ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES 
                    (
                        P_HEADER_ID               => var_header_id,
                        P_ROW_NUMBER              => 3,
                        P_CODE_COMBINATION_ID     => var_une_int_account_id,
                        P_ACCOUNTING_CLASS_CODE   => 'LOAN_INTEREST',
                        P_ACCOUNTED_DR            => 0,
                        P_ACCOUNTED_CR            => var_interest_amount,
                        P_DESCRIPTION             => 'INTERESES DEL PRESTAMO: ' || var_loan_number,
                        P_SOURCE_ID               => P_LOAN_ID,
                        P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS'
                    );
            
            EXCEPTION 
                WHEN OTHERS THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
                    RAISE CREATE_JOURNAL_EX;
            END; 
            
            COMMIT;
            ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL;    
        
        ELSIF var_loan_amount <> var_loan_amount_validate THEN
            RAISE LOAN_AMOUNT_EX;
        ELSIF var_interest_amount <> var_interest_amount_validate THEN
            RAISE INTEREST_AMOUNT_EX;
        END IF; 
           
    EXCEPTION 
        WHEN LOAN_AMOUNT_EX THEN
            P_RETCODE := 1;
            P_ERRBUF := 'El importe del préstamo no es equivalente a 4 meses de ahorro.';
            ROLLBACK;
        WHEN INTEREST_AMOUNT_EX THEN
            P_RETCODE := 1;
            P_ERRBUF := 'El importe de intereses no es el correspondiente de 4 meses de plazo.';
            ROLLBACK;
        WHEN PRINT_PREPAID_EX THEN
            P_RETCODE := 1;
            P_ERRBUF := 'Error al realizar la impresión del recibo de pago anticipado';
            ROLLBACK;
    END LOAN_REPAYMENT;
    
    PROCEDURE   SAVING_CHECK_REPLACEMENT(
                    P_ERRBUF        OUT NOCOPY VARCHAR2,
                    P_RETCODE       OUT NOCOPY VARCHAR2,
                    P_CHECK_ID      NUMBER)
    IS
        LN_BANK_ACCOUNT_ID         NUMBER;
        LC_BANK_ACCOUNT_NAME       VARCHAR2 (150);
        LC_BANK_ACCOUNT_NUM        VARCHAR2 (150);
        LC_BANK_NAME               VARCHAR2 (150);
        LC_CURRENCY_CODE           VARCHAR2 (150);
        
        LN_CHECK_NUMBER            NUMBER;
        LN_CHECK_ID                NUMBER;
        V_CHECK_ID                 NUMBER;
        V_CHECK_NUMBER             NUMBER;
        LN_CHECK_AMOUNT            NUMBER;
        
        LN_MEMBER_ID               NUMBER;
        LC_EMPLOYEE_FULL_NAME      VARCHAR2 (300);
        
        INPUT_STRING               VARCHAR2 (200);
        OUTPUT_STRING              VARCHAR2 (200);
        ENCRYPTED_RAW              RAW (2000);   -- stores encrypted binary text
        DECRYPTED_RAW              RAW (2000);   -- stores decrypted binary text
        NUM_KEY_BYTES              NUMBER := 256 / 8; -- key length 256 bits (32 bytes)
        KEY_BYTES_RAW              RAW (32);    -- stores 256-bit encryption key
        ENCRYPTION_TYPE            PLS_INTEGER
         :=                                           -- total encryption type
           DBMS_CRYPTO.ENCRYPT_AES256
            + DBMS_CRYPTO.CHAIN_CBC
            + DBMS_CRYPTO.PAD_PKCS5;
            
        P_ENTITY_CODE              VARCHAR2 (150);
        P_EVENT_TYPE_CODE          VARCHAR2 (150);
        P_BATCH_NAME               VARCHAR2 (150);
        P_JOURNAL_NAME             VARCHAR (150);
        P_HEADER_ID                NUMBER;
        LC_BANK_CODE_COMB          NUMBER;
        
        v_request_id NUMBER;
        waiting     BOOLEAN;
        phase      VARCHAR2(80 BYTE);
        status     VARCHAR2(80 BYTE);
        dev_phase  VARCHAR2(80 BYTE);
        dev_status VARCHAR2(80 BYTE);
        V_message    VARCHAR2(4000 BYTE);
    BEGIN
        BEGIN
             SELECT BANK_ACCOUNT_ID,
                    BANK_ACCOUNT_NAME,
                    BANK_ACCOUNT_NUM,
                    BANK_NAME,
                    CURRENCY_CODE
               INTO LN_BANK_ACCOUNT_ID,
                    LC_BANK_ACCOUNT_NAME,
                    LC_BANK_ACCOUNT_NUM,
                    LC_BANK_NAME,
                    LC_CURRENCY_CODE
               FROM ATET_SB_BANK_ACCOUNTS;
        EXCEPTION
         WHEN OTHERS
         THEN
            FND_FILE.PUT_LINE (FND_FILE.LOG,'Error al buscar la cuenta bancaria');
            DBMS_OUTPUT.PUT_LINE ('Error al buscar la cuenta bancaria');
            RAISE;
        END;
        
        BEGIN
            SELECT MEMBER_ID
              INTO LN_MEMBER_ID
              FROM ATET_SB_MEMBERS ASM
             WHERE MEMBER_ID = (SELECT MEMBER_ID
                                  FROM ATET_SB_CHECKS_ALL ASCA
                                 WHERE ASCA.CHECK_ID = P_CHECK_ID);
        EXCEPTION WHEN OTHERS THEN
           FND_FILE.PUT_LINE (FND_FILE.LOG,'Error al buscar al empleado.');
           DBMS_OUTPUT.PUT_LINE ('Error al buscar al empleado.');
           RAISE;
        END;
        
        BEGIN
            SELECT CHECK_ID, CHECK_NUMBER, AMOUNT
              INTO V_CHECK_ID, V_CHECK_NUMBER, LN_CHECK_AMOUNT
              FROM ATET_SB_CHECKS_ALL ASCA
             WHERE CHECK_ID = P_CHECK_ID
               AND STATUS_LOOKUP_CODE = 'CREATED';
        EXCEPTION WHEN OTHERS THEN
           FND_FILE.PUT_LINE (FND_FILE.LOG,'Error al buscar cheque.');
           DBMS_OUTPUT.PUT_LINE ('Error al buscar cheque.');
           RAISE;
        END;
        
        BEGIN
            SELECT EMPLOYEE_FULL_NAME
              INTO LC_EMPLOYEE_FULL_NAME
              FROM ATET_SB_MEMBERS
             WHERE MEMBER_ID = LN_MEMBER_ID;
        EXCEPTION
            WHEN OTHERS
            THEN
                FND_FILE.PUT_LINE (FND_FILE.LOG,'Error al buscar el miembro');
                DBMS_OUTPUT.PUT_LINE ('Error al buscar el miembro');
                RAISE;
        END;
        
        BEGIN
            SELECT ATET_SB_CHECKS_ALL_SEQ.NEXTVAL 
              INTO LN_CHECK_ID 
              FROM DUAL;

            SELECT ATET_SB_CHECK_NUMBER_SEQ.NEXTVAL
              INTO LN_CHECK_NUMBER
              FROM DUAL;

            INPUT_STRING :=   TO_CHAR (LN_CHECK_AMOUNT)  || ','
                            || LN_CHECK_ID              || ','
                            || LN_CHECK_NUMBER          || ','
                            || LN_MEMBER_ID             || ','
                            || FND_GLOBAL.USER_ID       || ','
                            || TO_CHAR (CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF');

            DBMS_OUTPUT.PUT_LINE ('Original string: ' || input_string);
            key_bytes_raw := DBMS_CRYPTO.RANDOMBYTES (num_key_bytes);
            encrypted_raw := DBMS_CRYPTO.ENCRYPT (src   => UTL_I18N.STRING_TO_RAW (input_string, 'AL32UTF8'), typ   => encryption_type, KEY   => key_bytes_raw);
            
            -- The encrypted value "encrypted_raw" can be used here
            decrypted_raw := DBMS_CRYPTO.DECRYPT (src   => encrypted_raw, typ   => encryption_type, KEY   => key_bytes_raw);
            output_string := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
            
            DBMS_OUTPUT.PUT_LINE ('Cadena a encriptar: ' || input_string);
            DBMS_OUTPUT.PUT_LINE ('Cadena encriptada: ' || encrypted_raw);
            DBMS_OUTPUT.PUT_LINE ('LLave: ' || key_bytes_raw);
            DBMS_OUTPUT.PUT_LINE ('Decrypted string: ' || output_string);

        EXCEPTION WHEN OTHERS THEN
           FND_FILE.PUT_LINE (FND_FILE.LOG,'Error al generar  firma digital.');
           DBMS_OUTPUT.PUT_LINE ('Error al generar  firma digital.');
        END;
        
        BEGIN
            INSERT INTO ATET_SB_CHECKS_ALL (CHECK_ID,
                                            AMOUNT,
                                            BANK_ACCOUNT_ID,
                                            BANK_ACCOUNT_NAME,
                                            CHECK_DATE,
                                            CHECK_NUMBER,
                                            CURRENCY_CODE,
                                            PAYMENT_TYPE_FLAG,
                                            STATUS_LOOKUP_CODE,
                                            MEMBER_ID,
                                            MEMBER_NAME,
                                            BANK_ACCOUNT_NUM,
                                            DIGITAL_SIGNATURE,
                                            DECRYPT_KEY,
                                            LAST_UPDATED_BY,
                                            LAST_UPDATE_DATE,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            PAYMENT_DESCRIPTION)
                 VALUES (LN_CHECK_ID,
                         LN_CHECK_AMOUNT,
                         LN_BANK_ACCOUNT_ID,
                         LC_BANK_ACCOUNT_NAME,
                         SYSDATE,
                         LN_CHECK_NUMBER,
                         LC_CURRENCY_CODE,
                         'CHECK_REPLACEMENT',
                         'CREATED',
                         LN_MEMBER_ID,
                         LC_EMPLOYEE_FULL_NAME,
                         LC_BANK_ACCOUNT_NUM,
                         ENCRYPTED_RAW,
                         KEY_BYTES_RAW,
                         FND_GLOBAL.USER_ID,
                         SYSDATE,
                         FND_GLOBAL.USER_ID,
                         SYSDATE,
                         'REEMPLAZO DE CHEQUE '||V_CHECK_NUMBER);

            --P_CHECK_ID := LN_CHECK_ID;
            
            COMMIT;
         
        EXCEPTION WHEN OTHERS THEN
           FND_FILE.PUT_LINE (FND_FILE.LOG,'Error: '||SQLERRM);
           DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
           RAISE;
        END;
        
        BEGIN
            UPDATE ATET_SB_CHECKS_ALL
               SET PAYMENT_TYPE_FLAG = 'REPLACED'
             WHERE 1 = 1
               AND CHECK_ID = P_CHECK_ID;
               
            COMMIT;               
        END;
        
        BEGIN
           P_ENTITY_CODE := 'CHECKS';
           P_EVENT_TYPE_CODE := 'CHECK_REPLACEMENT';
           P_BATCH_NAME := 'REEMPLAZO DE CHEQUE';
           P_JOURNAL_NAME := 'REEMPLAZO DEL CHEQUE: ' || V_CHECK_NUMBER;
           P_HEADER_ID := NULL;

           ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (P_ENTITY_CODE,
                                                      P_EVENT_TYPE_CODE,
                                                      P_BATCH_NAME,
                                                      P_JOURNAL_NAME,
                                                      P_HEADER_ID);

           FND_FILE.PUT_LINE (FND_FILE.LOG,'HEADER_ID: ' || P_HEADER_ID);
           DBMS_OUTPUT.PUT_LINE ('HEADER_ID: ' || P_HEADER_ID);

           SELECT ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID (
                     (SELECT ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                                'BANK_CODE_COMB',
                                (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                                   FROM DUAL))
                                CONCATENATED_SEGMENTS
                        FROM DUAL))
             INTO LC_BANK_CODE_COMB
             FROM DUAL CCID;

           ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
              P_HEADER_ID               => P_HEADER_ID,
              P_ROW_NUMBER              => 1,
              P_CODE_COMBINATION_ID     => LC_BANK_CODE_COMB,
              P_ACCOUNTING_CLASS_CODE   => P_EVENT_TYPE_CODE,
              P_ACCOUNTED_DR            => LN_CHECK_AMOUNT,
              P_ACCOUNTED_CR            => 0,
              P_DESCRIPTION             => 'REEMPLAZO DEL CHEQUE: ' || V_CHECK_NUMBER || ', DE RETIRO DE AHORRO DE: ' || LC_EMPLOYEE_FULL_NAME,
              P_SOURCE_ID               => V_CHECK_ID,
              P_SOURCE_LINK_TABLE       => 'ATET_SB_CHECKS_ALL');

           ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
              P_HEADER_ID               => P_HEADER_ID,
              P_ROW_NUMBER              => 2,
              P_CODE_COMBINATION_ID     => LC_BANK_CODE_COMB,
              P_ACCOUNTING_CLASS_CODE   => P_EVENT_TYPE_CODE,
              P_ACCOUNTED_DR            => 0,
              P_ACCOUNTED_CR            => LN_CHECK_AMOUNT,
              P_DESCRIPTION             => 'NUEVO NÚMERO DE CHEQUE: '|| LN_CHECK_NUMBER || ', DE RETIRO DE AHORRO DE: '|| LC_EMPLOYEE_FULL_NAME,
              P_SOURCE_ID               => LN_CHECK_ID,
              P_SOURCE_LINK_TABLE       => 'ATET_SB_CHECKS');

           COMMIT;
            
        EXCEPTION WHEN others THEN
            FND_FILE.PUT_LINE (FND_FILE.LOG,'Error: '||SQLERRM);
            DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
            RAISE;
        END;
         
        ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL;
        
        BEGIN
--                                                 );
              V_REQUEST_ID :=
                 FND_REQUEST.SUBMIT_REQUEST ('PER',                        -- APPLICATION
                                             'ATET_SB_PRINT_CHECK', -- PROGRAM SHORT NAME
                                             '',                           -- DESCRIPTION
                                             '',                            -- START TIME
                                             FALSE,                        -- SUB REQUEST
                                             TO_CHAR (LN_CHECK_ID),       -- ARGUMENT1
                                             CHR (0)       -- REPRESENTS END OF ARGUMENTS
                                                    );
               STANDARD.COMMIT;
               WAITING := FND_CONCURRENT.WAIT_FOR_REQUEST(V_REQUEST_ID,1,0,
                                                          PHASE,
                                                          STATUS,
                                                          DEV_PHASE,
                                                          DEV_STATUS,
                                                          V_MESSAGE
                                                         );               

               FND_FILE.PUT_LINE (FND_FILE.LOG,'CHEQUE - REQUEST_ID: '||V_REQUEST_ID );
          
        EXCEPTION WHEN OTHERS THEN
           FND_FILE.PUT_LINE (FND_FILE.LOG,'Error: '||SQLERRM);
           DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
           RAISE;
        END;
        
    EXCEPTION WHEN OTHERS THEN
            FND_FILE.PUT_LINE (FND_FILE.LOG,'Error inesperado: '||SQLERRM);
            DBMS_OUTPUT.PUT_LINE ('Error inesperado: ' || SQLERRM);         
    END SAVING_CHECK_REPLACEMENT;

END ATET_SAVINGS_BANK_PKG;
