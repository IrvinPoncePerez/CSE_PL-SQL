/**************************************************/
/*                  ALTER SESION                  */
/**************************************************/
ALTER SESSION SET CURRENT_SCHEMA=APPS; 
            

SELECT *
  FROM ATET_XLA_HEADERS AXH,
       ATET_XLA_LINES   AXL
 WHERE JOURNAL_NAME LIKE '%JUAREZ ROSALES%'
   AND AXH.HEADER_ID = AXL.HEADER_ID;

/******************************************************/



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
                   PRR.ELEMENT_ENTRY_ID     AS  "ELEMENT_ENTRY_ID",
                   1,
                   'IMPORTED',
                     SYSDATE,
                     -1,
                     SYSDATE,
                     -1
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
               AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
               AND PPA.ACTION_TYPE IN ('Q', 'R', 'B')
               AND PTP.PERIOD_NAME LIKE '%' || :P_YEAR || '%'
               AND PTP.PERIOD_NAME = NVL(:P_PERIOD_NAME, PTP.PERIOD_NAME)
               AND EXTRACT(MONTH FROM PPA.DATE_EARNED) >= :P_MONTH
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
               AND PAF.PERSON_ID = :P_PERSON_ID
--               AND PAF.ASSIGNMENT_ID = :P_ASSIGNMENT_ID
             ORDER BY PAF.PERSON_ID,
                      PETF.ELEMENT_NAME,
                      PIVF.NAME,
                      PRR.RUN_RESULT_ID;




/******************************************************/
            
            
BEGIN
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
                   PRR.ELEMENT_ENTRY_ID     AS  "ELEMENT_ENTRY_ID",
                   1,
                   'IMPORTED',
                     SYSDATE,
                     -1,
                     SYSDATE,
                     -1
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
               AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
               AND PPA.ACTION_TYPE IN ('Q', 'R', 'B')
               AND PTP.PERIOD_NAME LIKE '%' || :P_YEAR || '%'
               AND PTP.PERIOD_NAME = NVL(:P_PERIOD_NAME, PTP.PERIOD_NAME)
               AND EXTRACT(MONTH FROM PPA.DATE_EARNED) >= :P_MONTH
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
               AND PAF.PERSON_ID = :P_PERSON_ID
               AND PAF.ASSIGNMENT_ID = :P_ASSIGNMENT_ID
             ORDER BY PAF.PERSON_ID,
                      PETF.ELEMENT_NAME,
                      PIVF.NAME,
                      PRR.RUN_RESULT_ID;
                      
COMMIT;

END;



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
                       AND ASPR.ELEMENT_NAME = ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME')
                       AND ASPR.ENTRY_NAME = 'Pay Value'
                       AND ASPR.EXPORT_REQUEST_ID = :P_EXPORT_REQUEST_ID
--                       AND ASPR.IMPORT_REQUEST_ID = var_import_request_id
                       AND ASPR.PERSON_ID = :P_PERSON_ID
                       AND ASPR.ASSIGNMENT_ID = :P_ASSIGNMENT_ID;
                       
    var_result                  VARCHAR2(50) := 'N';
                       
BEGIN


    FOR detail_saving IN DETAIL_LIST_SAVINGS LOOP
                        
                        ATET_SAVINGS_BANK_PKG.CREATE_ACCOUNT(detail_saving.PERSON_ID,
                                       'SAVINGS_ELEMENT_NAME',
                                       'SAV_CODE_COMB');                             
                            
                                                
                        var_result := ATET_SAVINGS_BANK_PKG.INSERT_SAVING_TRANSACTION(P_PAYROLL_RESULT_ID => detail_saving.PAYROLL_RESULT_ID,
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
                               ASPR.LAST_UPDATED_BY = -1
                         WHERE ASPR.PAYROLL_RESULT_ID = detail_saving.PAYROLL_RESULT_ID;
                                                                    
                        IF var_result = 'N' THEN
                            EXIT;
                        END IF;                          
                                
                    END LOOP;

END;

   
   
COMMIT;