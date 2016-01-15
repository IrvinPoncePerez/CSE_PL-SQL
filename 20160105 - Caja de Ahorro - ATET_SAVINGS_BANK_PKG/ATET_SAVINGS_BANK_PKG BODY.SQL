CREATE OR REPLACE PACKAGE BODY ATET_SAVINGS_BANK_PKG IS


    FUNCTION    GET_SAVING_BANK_ID
      RETURN    NUMBER
    IS
        var_saving_bank_id      NUMBER;
    BEGIN
        
        SELECT SB.SAVING_BANK_ID
          INTO var_saving_bank_id
          FROM ATET_SAVINGS_BANK SB
         WHERE 1 = 1 
           AND SB.SAVING_BANK_STATUS = 'OPEN';
           
           
        RETURN var_saving_bank_id;
    
    END GET_SAVING_BANK_ID;
    
    
    FUNCTION    GET_SAVING_BANK_YEAR
      RETURN    NUMBER
    IS
        var_saving_bank_year    NUMBER;
    BEGIN
    
        SELECT ASB.YEAR
          INTO var_saving_bank_year
          FROM ATET_SAVINGS_BANK    ASB
         WHERE 1 = 1
           AND ASB.SAVING_BANK_ID = GET_SAVING_BANK_ID;
           
        RETURN var_saving_bank_year;
    
    END GET_SAVING_BANK_YEAR;
    
    
    FUNCTION    GET_AVAILABLE_PERIODS(P_MEMBER_ID   NUMBER)
      RETURN    NUMBER
    IS
        var_count_periods   NUMBER;
    BEGIN
        SELECT COUNT(D.PERIOD_NAME)
        --       D.PERIOD_NAME,
        --       D.TIME_PERIOD_ID,
        --       D.ASSIGNMENT_ID,
        --       D.PAYROLL_ID,
        --       D.END_DATE,
        --       PPA.TIME_PERIOD_ID,
        --       PAA.RUN_TYPE_ID
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

           
        RETURN var_count_periods; 
    END GET_AVAILABLE_PERIODS;
    
    
    FUNCTION    GET_PERIOD_TYPE(P_PERSON_ID             NUMBER)
      RETURN    VARCHAR2
    IS
        var_period_type     VARCHAR2(100);
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
    
    END GET_PERIOD_TYPE;
    
      
    FUNCTION    GET_REGISTRATION_DATE
      RETURN    DATE
    IS
        var_registration_date   DATE;
    BEGIN
        
        SELECT SB.REGISTRATION_DATE
          INTO var_registration_date
          FROM ATET_SAVINGS_BANK    SB
         WHERE 1 = 1
           AND SB.SAVING_BANK_ID = GET_SAVING_BANK_ID;
           
        RETURN var_registration_date;
    
    END GET_REGISTRATION_DATE;
    
    
    FUNCTION    GET_PARAMETER_VALUE(P_SAVING_BANK_ID          NUMBER,
                                    P_PARAMETER_CODE          VARCHAR2)
      RETURN    VARCHAR2
    IS
        var_parameter_value     VARCHAR2(100);
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
    
    EXCEPTION WHEN NO_DATA_FOUND THEN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, '***************************************************************************************');
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'No se ha definido el valor del parámetro ' || P_PARAMETER_CODE);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '***************************************************************************************');
    
    END GET_PARAMETER_VALUE;
    
    
    FUNCTION    IF_MEMBER_EXIST(P_EMPLOYEE_NUMBER      NUMBER)
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
        
    END IF_MEMBER_EXIST;
    
    
    FUNCTION GET_MAX_ASSIGNMENT_ACTION_ID(P_ASSIGNMENT_ID        NUMBER,
                                            P_PAYROLL_ID           NUMBER)
        RETURN NUMBER                                                        
    IS
              
        var_assignment_action_id    NUMBER;
              
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
--           AND EXTRACT(YEAR FROM PPA.DATE_EARNED) = P_YEAR
           AND PPA.CONSOLIDATION_SET_ID = PCS.CONSOLIDATION_SET_ID
           AND PCS.CONSOLIDATION_SET_NAME IN ('NORMAL')
         ORDER BY PPA.DATE_EARNED DESC,
                  PAA.ASSIGNMENT_ACTION_ID DESC;
                       
        RETURN var_assignment_action_id;   
              
    END GET_MAX_ASSIGNMENT_ACTION_ID;
    
    
    FUNCTION GET_SUBTBR(P_ASSIGNMENT_ACTION_ID      NUMBER)
        RETURN NUMBER
    IS 
        var_result_value    NUMBER;
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
        RETURN 0;
    END GET_SUBTBR;


    FUNCTION GET_ISRRET(P_ASSIGNMENT_ACTION_ID      NUMBER)
    RETURN NUMBER
    IS 
        var_result_value    NUMBER;
    BEGIN
        
         SELECT ROUND(PRRV.RESULT_VALUE, 2)
           INTO var_result_value
           FROM PAY_RUN_RESULTS          PRR,
                PAY_ELEMENT_TYPES_F      PETF,
                PAY_RUN_RESULT_VALUES    PRRV,
                PAY_INPUT_VALUES_F       PIVF
          WHERE PRR.ASSIGNMENT_ACTION_ID = P_ASSIGNMENT_ACTION_ID
            AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
            AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
            AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
            AND PETF.ELEMENT_NAME = 'D055_ISPT'
            AND PIVF.NAME = 'Pay Value';
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END GET_ISRRET;
    
    
    FUNCTION GET_MONDET(P_ASSIGNMENT_ACTION_ID      NUMBER)
    RETURN NUMBER
    IS 
        var_result_value    NUMBER;
    BEGIN
        
        SELECT SUM(PRRV.RESULT_VALUE)
          INTO var_result_value
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
           AND (PEC.CLASSIFICATION_NAME IN ('Voluntary Deductions', 
                                            'Involuntary Deductions') 
                   OR PETF.ELEMENT_NAME IN (SELECT MEANING
                                              FROM FND_LOOKUP_VALUES 
                                             WHERE LOOKUP_TYPE = 'XX_DEDUCCIONES_INFORMATIVAS'
                                               AND LANGUAGE = USERENV('LANG')))
           AND PETF.ELEMENT_NAME <> 'D055_ISPT'
           AND PIVF.UOM = 'M'
           AND PIVF.NAME = 'Pay Value';
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END GET_MONDET;
    
    
    FUNCTION    GET_PERSON_TERMINATION_DATE(P_PERSON_ID     NUMBER)
      RETURN    VARCHAR2
    IS
        var_actual_termination_date VARCHAR2(50) := 'NOTHING';
    BEGIN
    
        SELECT PPOS.ACTUAL_TERMINATION_DATE
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
        RETURN var_actual_termination_date; 
    END GET_PERSON_TERMINATION_DATE;
    
      
    FUNCTION    GET_MEMBER_TERMINATION_DATE(P_PERSON_ID     NUMBER)
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
           
        RETURN var_member_termination_date;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN var_member_termination_date;
    END GET_MEMBER_TERMINATION_DATE;
    
    
    PROCEDURE   EXPORT_PAYROLL_RESULTS(P_ERRBUF         OUT NOCOPY  VARCHAR2,
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
                   PRRV.RESULT_VALUE        AS  "ENTRY_VALUE"
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
               AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
               AND PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
               AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
               AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
               AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
               AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
               AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
               AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
               AND PETF.ELEMENT_NAME IN (ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME'),
                                         ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME'))
               /************************************************/
               /************************************************/
--               AND PAF.PERSON_ID IN (SELECT ASM.PERSON_ID FROM ATET_SB_MEMBERS ASM)
               /************************************************/
               /************************************************/ 
             ORDER BY PAF.PERSON_ID,
                      PETF.ELEMENT_NAME,
                      PIVF.NAME;
   
        TYPE   DETAILS IS TABLE OF DETAIL_LIST%ROWTYPE INDEX BY PLS_INTEGER;
     
        detail DETAILS;
        
        var_request_id      NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        var_log             VARCHAR2(1000);
        var_user_id         NUMBER := FND_GLOBAL.USER_ID;
        var_validate        NUMBER;
    
    BEGIN
        
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
                                                         var_request_id,
                                                         'EXPORTED',
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
        
    
    END EXPORT_PAYROLL_RESULTS;
    
    
    PROCEDURE   IMPORT_PAYROLL_RESULTS(P_ERRBUF            OUT NOCOPY  VARCHAR2,
                                       P_RETCODE           OUT NOCOPY  VARCHAR2,
                                       P_EXPORT_REQUEST_ID NUMBER)
    IS
        var_import_request_id       NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        var_log                     VARCHAR2(1000);
        var_user_id                 NUMBER := FND_GLOBAL.USER_ID;
        var_validate                NUMBER;
        var_have_account            NUMBER;
        var_result                  VARCHAR2(50);
        
        var_sum_saving_amount       NUMBER;
        var_sum_saving_pay_value    NUMBER;
    BEGIN
    
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
                       AND ASPR.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME')
                       AND ASPR.ENTRY_NAME = 'Pay Value'
                       AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                       AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;     
            
                    
            BEGIN
            
                                 
                FOR detail_saving IN DETAIL_LIST_SAVINGS LOOP
                    
                    CREATE_ACCOUNT(detail_saving.PERSON_ID,
                                   'SAVINGS_ELEMENT_NAME',
                                   'SAV_CODE_COMB');                             
                        
                    var_result := 'N';
                    
                    var_result := INSERT_SAVING_TRANSACTION(detail_saving.PAYROLL_RESULT_ID,
                                                            detail_saving.PERSON_ID,
                                                            detail_saving.EARNED_DATE,
                                                            detail_saving.TIME_PERIOD_ID,
                                                            detail_saving.PERIOD_NAME,
                                                            detail_saving.ELEMENT_NAME,
                                                            detail_saving.ENTRY_NAME,
                                                            detail_saving.ENTRY_UNITS,
                                                            detail_saving.ENTRY_VALUE,
                                                            0,
                                                            detail_saving.ENTRY_VALUE);
                                                                
                    IF var_result = 'N' THEN
                        EXIT;
                    END IF;                          
                            
                END LOOP;
                
                IF    var_result = 'Y' THEN
                    COMMIT;
                    
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
                    
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '********************************************************');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   '||GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME'));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   MOVIMIENTOS PROGRAMADOS   : ' || TO_CHAR(var_sum_saving_amount));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   MOVIMIENTOS REALES        : ' || TO_CHAR(var_sum_saving_pay_value));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '********************************************************');
                    
                ELSIF var_result = 'N' THEN
                    
                    ROLLBACK;
                
                    UPDATE ATET_SB_PAYROLL_RESULTS  ASPR
                       SET IMPORT_REQUEST_ID = NULL,
                           ATTRIBUTE6 = NULL
                     WHERE ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                       AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                       
                    COMMIT; 
                    
                    P_ERRBUF := 'EL PROCESO DE IMPORTACIÓN ENCONTRO UN INCONVENIENTE AL MOMENTO DE PROCESAR LOS MOVIMIENTOS DE CAJA DE AHORRO.';
                    P_RETCODE := 1;                      
                       
                END IF;
            
            END;
            
        ELSE
        
            P_ERRBUF := 'EL PROCESO DE IMPORTACIÓN YA FUE EJECUTADO ANTERIORMENTE.';
            P_RETCODE := 1;
        
        END IF;
    
    END IMPORT_PAYROLL_RESULTS;
    
    
    
    
    PROCEDURE   CREATE_ACCOUNT(P_PERSON_ID              NUMBER,
                               P_PARAM_ELEMENT_NAME     VARCHAR2,
                               P_PARAM_CODE_COMBINATION VARCHAR2)
    IS
        var_have_account    NUMBER;
        var_user_id         NUMBER := FND_GLOBAL.USER_ID;
    BEGIN
                   

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
                COMMIT;
                
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
                    COMMIT;
                    
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
                    COMMIT;
                    
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'CREATE ACCOUNT ' || GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME) || '.');
                END IF;
            END IF;                          
        END IF;
 
    END;
    
    
    FUNCTION GET_LOOKUP_MEANING (P_LOOKUP_TYPE    VARCHAR2,
                                P_LOOKUP_CODE    VARCHAR2)
      RETURN VARCHAR2
   --
   AS
      V_MEANING   HR_LOOKUPS.MEANING%TYPE;
   --
   BEGIN
      --


      --
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

      --

      --
      RETURN V_MEANING;
   --
   END GET_LOOKUP_MEANING;
   
   
    PROCEDURE   ROLLBACK_EXPORT_PAYRESULT(P_ERRBUF            OUT NOCOPY  VARCHAR2,
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
        
    
    END ROLLBACK_EXPORT_PAYRESULT;
    
    
    PROCEDURE   CHANGE_AMOUNT_TO_SAVE(P_ERRBUF            OUT NOCOPY  VARCHAR2,
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
    
        IF SYSDATE > TO_DATE(GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'REG_CHANGED_DATE'), 'RRRR/MM/DD') THEN
            P_ERRBUF := 'No se puede cambiar el monto de ahorro cuando la fecha de inscripción ha finalizado.';
            P_RETCODE := 1;
        ELSE
        
            -- ATTRIBUTE2       Periodos pendientes
            -- ATTRIBUTE3       Monto real de ahorro.
            
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
    
    END RESTART_SEQUENCE;  
    
    
    FUNCTION    GET_MEMBER_ID(P_PERSON_ID   NUMBER)
      RETURN    NUMBER
    IS
        var_member_id   NUMBER;
    BEGIN
        SELECT ASM.MEMBER_ID
          INTO var_member_id
          FROM ATET_SB_MEMBERS ASM
         WHERE ASM.PERSON_ID = P_PERSON_ID
           AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
           
        RETURN var_member_id;           
    END GET_MEMBER_ID;
    
    
    FUNCTION    GET_MEMBER_IS_SAVER(P_MEMBER_ID     NUMBER)
      RETURN    VARCHAR2
    IS
        var_result  VARCHAR2(50);
    BEGIN
    
        SELECT ASM.IS_SAVER
          INTO var_result
          FROM ATET_SB_MEMBERS  ASM
         WHERE 1 = 1
           AND ASM.MEMBER_ID = P_MEMBER_ID;
    
        RETURN var_result;
    END;
      
      
    FUNCTION    GET_CODE_COMBINATION_ID(ELEMENT_NAME    VARCHAR2)
      RETURN    NUMBER
    IS
    BEGIN
        RETURN 1;
    END GET_CODE_COMBINATION_ID;
    
    
    FUNCTION    INSERT_SAVING_TRANSACTION(P_PAYROLL_RESULT_ID   NUMBER,
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
             
                                                  
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'MOVIMIENTO PROCESADO: '    || P_PAYROLL_RESULT_ID  || ','
                                                                    || P_PERSON_ID          || ','
                                                                    || P_EARNED_DATE        || ','
                                                                    || P_PERIOD_NAME        || ','
                                                                    || P_ELEMENT_NAME       || ','
                                                                    || P_ENTRY_NAME         || ','
                                                                    || P_ENTRY_UNITS        || ','
                                                                    || P_ENTRY_VALUE        || ','
                                                                    || P_DEBIT_AMOUNT       || ','
                                                                    || P_CREDIT_AMOUNT      || '.');                           
    
        RETURN 'Y';
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'NO SE PROCESO EL MOVIMIENTO: ' || P_PAYROLL_RESULT_ID  || ','
                                                                        || P_PERSON_ID          || ','
                                                                        || P_EARNED_DATE        || ','
                                                                        || P_PERIOD_NAME        || ','
                                                                        || P_ELEMENT_NAME       || ','
                                                                        || P_ENTRY_NAME         || ','
                                                                        || P_ENTRY_UNITS        || ','
                                                                        || P_ENTRY_VALUE        || ','
                                                                        || P_DEBIT_AMOUNT       || ','
                                                                        || P_CREDIT_AMOUNT      || '.' || SQLERRM);
        ROLLBACK;
        RETURN 'N';
    END INSERT_SAVING_TRANSACTION;
    
    
    FUNCTION    GET_SAVING_MEMBER_ACCOUNT_ID(P_MEMBER_ID            NUMBER,
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
         
        RETURN var_member_account_id;
    END GET_SAVING_MEMBER_ACCOUNT_ID;
    
    
    FUNCTION    GET_LOAN_MEMBER_ACCOUNT_ID(P_MEMBER_ID          NUMBER,
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
               SET ASMA.LOAN_ID = P_LOAN_ID
             WHERE 1 = 1
               AND ASMA.MEMBER_ID = P_MEMBER_ID
               AND ASMA.ACCOUNT_DESCRIPTION = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME')
               AND ASMA.LOAN_ID IS NULL; 
               
               DBMS_OUTPUT.PUT_LINE( 'UPDATE ACCOUNT');
               
            COMMIT;
            
            SELECT ASMA.MEMBER_ACCOUNT_ID
              INTO var_member_account_id
              FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
             WHERE 1 = 1
               AND ASMA.MEMBER_ID = P_MEMBER_ID
               AND ASMA.LOAN_ID = P_LOAN_ID
               AND ASMA.ACCOUNT_DESCRIPTION = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME');  
        
            DBMS_OUTPUT.PUT_LINE( 'SELECT ACCOUNT');
        
        END;
        
    
        RETURN var_member_account_id;
    END GET_LOAN_MEMBER_ACCOUNT_ID;


    PROCEDURE   SET_LOAN_BALANCE(P_LOAN_ID            NUMBER,
                                 P_LOAN_AMOUNT        NUMBER,
                                 P_PERSON_ID          NUMBER)
    IS
        var_member_id           NUMBER := GET_MEMBER_ID(P_PERSON_ID);
        var_member_account_id   NUMBER;
        var_user_id             NUMBER := FND_GLOBAL.USER_ID;
        var_loan_number         NUMBER;
        var_loan_id             NUMBER;
    BEGIN
    
        SELECT ASL.LOAN_ID,
               ASL.LOAN_NUMBER
          INTO var_loan_id,
               var_loan_number
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
        
        COMMIT;

        NULL;
    
    END SET_LOAN_BALANCE;
    
    
    PROCEDURE   INSERT_EXTEMPORANEOUS_SAVING(P_ERRBUF               OUT NOCOPY  VARCHAR2,
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
         var_isrret                     NUMBER;
         var_subtbr                     NUMBER;
         var_mondet                     NUMBER;
         var_validate                   VARCHAR2(1) := 'N';
         var_min_sav_amt_sm             NUMBER;
         var_min_sav_amt_wk             NUMBER;
         var_saving_bank_id             NUMBER := ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID;
    BEGIN
        
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
                var_subtbr := ATET_SAVINGS_BANK_PKG.GET_SUBTBR(var_max_assignment_action_id);
                var_isrret := ATET_SAVINGS_BANK_PKG.GET_ISRRET(var_max_assignment_action_id);
                var_mondet := ATET_SAVINGS_BANK_PKG.GET_MONDET(var_max_assignment_action_id);
                            
            
                var_max_per_sav := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_PER_SAV');
                var_max_sav_amt_sm := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_SAV_AMT_SM');
                var_max_sav_amt_wk := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_SAV_AMT_WK');
                var_min_sav_amt_sm := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MIN_SAV_AMT_SM');
                var_min_sav_amt_wk := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MIN_SAV_AMT_WK');
                var_posibility_saving := (var_subtbr - (var_isrret + var_mondet)) * (var_max_per_sav / 100);
            
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
    
    END INSERT_EXTEMPORANEOUS_SAVING;
    
    
    FUNCTION    GET_POSIBILITY_SAVING(P_PERSON_ID           NUMBER)
      RETURN    NUMBER
    IS
         var_period_type                VARCHAR2(100);
         var_assignment_id               NUMBER;
         var_payroll_id                 NUMBER;
         var_max_assignment_action_id   NUMBER;
         var_max_per_sav                NUMBER;
         var_posibility_saving          NUMBER;
         var_isrret                     NUMBER;
         var_subtbr                     NUMBER;
         var_mondet                     NUMBER;
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
        var_isrret := ATET_SAVINGS_BANK_PKG.GET_ISRRET(var_max_assignment_action_id);
        var_mondet := ATET_SAVINGS_BANK_PKG.GET_MONDET(var_max_assignment_action_id);
        var_max_per_sav := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_PER_SAV');
        var_posibility_saving := (var_subtbr - (var_isrret + var_mondet)) * (var_max_per_sav / 100);
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
    
        RETURN var_posibility_saving;
    END GET_POSIBILITY_SAVING;
        
                                 

END ATET_SAVINGS_BANK_PKG;