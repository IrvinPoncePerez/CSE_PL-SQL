CREATE OR REPLACE PACKAGE BODY ATET_SAVINGS_BANK_PKG IS

    /*****************      ARINCON     ****************/
    
    /*****************      SARIAS      ****************/
    
    /*****************      IPONCE      ****************/
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
--               AND PAF.PERSON_ID IN (SELECT ASM.PERSON_ID FROM ATET_SB_MEMBERS ASM)
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
                                                        PERIOD_NAME,
                                                        PAYROLL_STATUS,
                                                        ELEMENT_NAME,
                                                        ENTRY_NAME,
                                                        ENTRY_UNITS,
                                                        ENTRY_VALUE,
                                                        EXPORT_REQUEST_ID,
                                                        CREATION_DATE,
                                                        CREATED_BY,
                                                        LAST_UPDATE_DATE,
                                                        LAST_UPDATED_BY)
                                                 VALUES (detail(rowIndex).PERSON_ID,
                                                         detail(rowIndex).ASSIGNMENT_ID,
                                                         detail(rowIndex).ASSIGNMENT_ACTION_ID,
                                                         detail(rowIndex).PAYROLL_ACTION_ID,
                                                         detail(rowIndex).EARNED_DATE,
                                                         detail(rowIndex).PERIOD_NAME,
                                                         detail(rowIndex).PAYROLL_STATUS,
                                                         detail(rowIndex).ELEMENT_NAME,
                                                         detail(rowIndex).ENTRY_NAME,
                                                         detail(rowIndex).ENTRY_UNITS,
                                                         detail(rowIndex).ENTRY_VALUE,
                                                         var_request_id,
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
                        
                    var_result := '';
                    var_result := INSERT_SAVING_TRANSACTION(detail_saving.PAYROLL_RESULT_ID,
                                                            detail_saving.PERSON_ID,
                                                            detail_saving.EARNED_DATE,
                                                            detail_saving.PERIOD_NAME,
                                                            detail_saving.ELEMENT_NAME,
                                                            detail_saving.ENTRY_NAME,
                                                            detail_saving.ENTRY_UNITS,
                                                            detail_saving.ENTRY_VALUE,
                                                            0,
                                                            detail_saving.ENTRY_VALUE);
                    SAVEPOINT   INSERT_SAVING;
                                                                
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
                    ROLLBACK TO INSERT_SAVING;
                    
                    UPDATE ATET_SB_PAYROLL_RESULTS  ASPR
                       SET IMPORT_REQUEST_ID = NULL
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
        var_employee_number     NUMBER;
        var_employee_name       VARCHAR2(500);
    BEGIN
    
        IF SYSDATE > ATET_SAVINGS_BANK_PKG.GET_REGISTRATION_DATE THEN
            P_ERRBUF := 'No se puede cambiar el monto de ahorro cuando la fecha de inscripción ha finalizado.';
            P_RETCODE := 1;
        ELSE
            UPDATE ATET_SB_MEMBERS
               SET AMOUNT_TO_SAVE = P_AMOUNT_TO_SAVE,
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
    /*****************      LHERNANDEZ  ****************/

END ATET_SAVINGS_BANK_PKG;