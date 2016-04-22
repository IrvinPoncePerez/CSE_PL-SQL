/*************************************************************/
/*              INSERT ENTRY VALUE FOLIO                     */
/*************************************************************/
BEGIN
INSERT INTO ATET_SB_PAYROLL_RESULTS(
    PERSON_ID,
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
      IMPORT_REQUEST_ID,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY
)
SELECT PERSON_ID,
      ASSIGNMENT_ID,
      ASSIGNMENT_ACTION_ID,
      PAYROLL_ACTION_ID,
      EARNED_DATE,
      TIME_PERIOD_ID,
      PERIOD_NAME,
      PAYROLL_STATUS,
      ELEMENT_NAME,
      'Folio',
      'Numero',
      '1',
      RUN_RESULT_ID,
      ELEMENT_ENTRY_ID,
      EXPORT_REQUEST_ID,
      IMPORT_REQUEST_ID,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY
  FROM ATET_SB_PAYROLL_RESULTS
 WHERE 1 = 1
   AND PERIOD_NAME = '6 2016 Semana' 
   AND ELEMENT_NAME = 'D072_PRESTAMO CAJA DE AHORRO'
   AND ENTRY_NAME = 'Amount';
   
END;

SELECT PERSON_ID,
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
      IMPORT_REQUEST_ID,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY
  FROM ATET_SB_PAYROLL_RESULTS
 WHERE 1 = 1
   AND PERIOD_NAME = '6 2016 Semana' 
   AND ELEMENT_NAME = 'D072_PRESTAMO CAJA DE AHORRO'
   AND ENTRY_NAME = 'Folio'
   AND ENTRY_VALUE = 1;
   

/*************************************************************/
/*                      UPDATE LOAN_NUMBER                   */                      
/*************************************************************/
    SELECT DISTINCT
           ASM.EMPLOYEE_FULL_NAME,
           ASM.PERSON_ID,
           ASL.LOAN_NUMBER
      FROM ATET_SB_PAYROLL_RESULTS    ASPR,
           ATET_SB_MEMBERS            ASM,
           ATET_SB_LOANS              ASL,
           ATET_SB_PAYMENTS_SCHEDULE  ASPS     
     WHERE ASPR.ENTRY_NAME = 'Folio'
       AND ASPR.PERSON_ID = ASM.PERSON_ID
       AND ASM.MEMBER_ID = ASL.MEMBER_ID
       AND ASL.LOAN_ID = ASPS.LOAN_ID
       AND ASPS.PERIOD_NAME = '6 2016 Semana'
       AND ASPR.ENTRY_VALUE = 1
       AND ASL.LOAN_STATUS_FLAG = 'ACTIVE'
     ORDER BY PERSON_ID,
              LOAN_NUMBER;

DECLARE

    var_period_name VARCHAR2(100) := '6 2016 Semana';

    CURSOR PAYMENTS_SCHEDULE_DETAILS IS
    SELECT DISTINCT
           ASM.EMPLOYEE_FULL_NAME,
           ASM.PERSON_ID,
           ASL.LOAN_NUMBER
      FROM ATET_SB_PAYROLL_RESULTS    ASPR,
           ATET_SB_MEMBERS            ASM,
           ATET_SB_LOANS              ASL,
           ATET_SB_PAYMENTS_SCHEDULE  ASPS     
     WHERE ASPR.ENTRY_NAME = 'Folio'
       AND ASPR.PERSON_ID = ASM.PERSON_ID
       AND ASM.MEMBER_ID = ASL.MEMBER_ID
       AND ASL.LOAN_ID = ASPS.LOAN_ID
       AND ASPS.PERIOD_NAME = var_period_name
       AND ASPR.ENTRY_VALUE = 1
       AND ASL.LOAN_STATUS_FLAG = 'ACTIVE'
     ORDER BY PERSON_ID,
              LOAN_NUMBER;
BEGIN

    FOR DETAIL IN PAYMENTS_SCHEDULE_DETAILS LOOP

        UPDATE ATET_SB_PAYROLL_RESULTS  ASPR
           SET ENTRY_VALUE = DETAIL.LOAN_NUMBER
         WHERE 1 = 1
           AND ENTRY_NAME = 'Folio'
           AND PERIOD_NAME = var_period_name
           AND ENTRY_VALUE = 1
           AND PERSON_ID = DETAIL.PERSON_ID;
       
    END LOOP;
    
END;

/*************************************************************/
/*              DELETE AND CREATE PAYMENT_SCHEDULE           */
/*************************************************************/
SELECT ASPR.PERSON_ID,
           ASM.EMPLOYEE_FULL_NAME,
           ASM.MEMBER_ID,
           ASL.LOAN_ID,
           ASPR.EARNED_DATE,
           ASL.TRANSACTION_DATE
      FROM ATET_SB_PAYROLL_RESULTS  ASPR,
           ATET_SB_MEMBERS          ASM,
           ATET_SB_LOANS            ASL
     WHERE 1 = 1
       AND ENTRY_NAME = 'Folio'
       AND PERIOD_NAME = '6 2016 Semana'
       AND ENTRY_VALUE = 1
       AND ASPR.PERSON_ID = ASM.PERSON_ID
       AND ASL.MEMBER_ID = ASM.MEMBER_ID
       AND ASL.LOAN_STATUS_FLAG = 'ACTIVE';


DECLARE
    
    VAR_LAST_PAYMENT_DATE   DATE;
    
    VAR_PERIOD_NAME         VARCHAR2(100) := '4 2016 Semana';
 
    CURSOR PAYMENTS_SCHEDULE_DETAILS IS
    SELECT ASPR.PERSON_ID,
           ASM.MEMBER_ID,
           ASL.LOAN_ID
      FROM ATET_SB_PAYROLL_RESULTS  ASPR,
           ATET_SB_MEMBERS          ASM,
           ATET_SB_LOANS            ASL
     WHERE 1 = 1
       AND ENTRY_NAME = 'Folio'
       AND PERIOD_NAME = VAR_PERIOD_NAME
       AND ENTRY_VALUE = 1
       AND ASPR.PERSON_ID = ASM.PERSON_ID
       AND ASL.MEMBER_ID = ASM.MEMBER_ID
       AND ASL.LOAN_STATUS_FLAG = 'ACTIVE';

BEGIN

    FOR DETAIL IN PAYMENTS_SCHEDULE_DETAILS LOOP
    
        DBMS_OUTPUT.PUT_LINE('LOAN_ID = ' || DETAIL.LOAN_ID);
    
        DELETE FROM ATET_SB_PAYMENTS_SCHEDULE ASPS
         WHERE 1 = 1
           AND ASPS.LOAN_ID = DETAIL.LOAN_ID;
           
        ATET_SB_BACK_OFFICE_PKG.
            CREATE_PAYMENTS_SCHEDULE(
                DETAIL.LOAN_ID,
                VAR_LAST_PAYMENT_DATE);
    
    END LOOP; 

END;


--/**************************************************************/
--/*          INSERTAR APORTACIONES VOLUNTARIAS                 */
--/**************************************************************/
--DECLARE
--    CURSOR VOLUNTARY_CONTRIBUTION_DETAILS IS
--        SELECT ACT.P_MEMBER_ID,
--               ACT.P_SAVING_AMOUNT,
--               ACT.P_DEPOSIT_DATE
--          FROM ATET_CONTRIBUTION_TEMP ACT;
--      
--    var_import_request_id       NUMBER;
--    var_waiting                 BOOLEAN;
--    var_phase                   VARCHAR2 (80 BYTE);
--    var_status                  VARCHAR2 (80 BYTE);
--    var_dev_phase               VARCHAR2 (80 BYTE);
--    var_dev_status              VARCHAR2 (80 BYTE);
--    var_message                 VARCHAR2 (4000 BYTE);
--              
--BEGIN

--    fnd_global.apps_initialize (user_id        => 3397,
--                                resp_id        => 53698,
--                                resp_appl_id   => 101);
--                       
--    mo_global.set_policy_context ('S', 1329);

--    
--    FOR DETAIL IN VOLUNTARY_CONTRIBUTION_DETAILS LOOP
--        
--        
--        var_import_request_id :=
--            FND_REQUEST.SUBMIT_REQUEST (
--               APPLICATION => 'PER',
--               PROGRAM => 'ATET_VOLUNTARY_CONTRIBUTION',
--               DESCRIPTION => '',
--               START_TIME => '',
--               SUB_REQUEST => FALSE,
--               ARGUMENT1 => TO_CHAR(DETAIL.P_MEMBER_ID),
--               ARGUMENT2 => TO_CHAR(DETAIL.P_SAVING_AMOUNT),
--               ARGUMENT3 => TO_CHAR(DETAIL.P_DEPOSIT_DATE)
--                                       );
--            
--        STANDARD.COMMIT;
--                     
--        var_waiting :=
--            FND_CONCURRENT.WAIT_FOR_REQUEST (
--                REQUEST_ID => var_import_request_id,
--                INTERVAL => 1,
--                MAX_WAIT => 0,
--                PHASE => var_phase,
--                STATUS => var_status,
--                DEV_PHASE => var_dev_phase,
--                DEV_STATUS => var_dev_status,
--                MESSAGE => var_message
--                                        );
--    
--            
--        UPDATE ATET_CONTRIBUTION_TEMP ACT
--           SET ACT.P_RETCODE = var_import_request_id
--         WHERE 1 = 1
--           AND ACT.P_MEMBER_ID = DETAIL.P_MEMBER_ID
--           AND ACT.P_SAVING_AMOUNT = DETAIL.P_SAVING_AMOUNT
--           AND ACT.P_DEPOSIT_DATE = DETAIL.P_DEPOSIT_DATE;
--    
--    END LOOP;

--    COMMIT;

--END;

SELECT *
FROM FND_USER
WHERE USER_NAME = 'IPONCE';

--COMMIT;

SELECT DISTINCT ELEMENT_NAME
  FROM ATET_SB_SAVINGS_TRANSACTIONS;
  
  
/**************************************************************/
/*                  RETIRO DE AHORRO                          */
/**************************************************************/
DECLARE
    CURSOR RETIREMENTS_DETAILS IS
        SELECT ACT.P_MEMBER_ID,
               ACT.P_AMOUNT_SAVED,
               ACT.P_PERCENTAGE_RETIREMENT,
               ACT.P_SAVING_RETIREMENT,
               ACT.P_IS_MEMBER_END
          FROM ATET_RETIREMENTS_TEMP ACT;
      
    var_import_request_id       NUMBER;
    var_waiting                 BOOLEAN;
    var_phase                   VARCHAR2 (80 BYTE);
    var_status                  VARCHAR2 (80 BYTE);
    var_dev_phase               VARCHAR2 (80 BYTE);
    var_dev_status              VARCHAR2 (80 BYTE);
    var_message                 VARCHAR2 (4000 BYTE);
              
BEGIN

    fnd_global.apps_initialize (user_id        => 3397,
                                resp_id        => 53698,
                                resp_appl_id   => 101);
                       
    mo_global.set_policy_context ('S', 1329);

    
    FOR DETAIL IN RETIREMENTS_DETAILS LOOP
        
        
        var_import_request_id :=
            FND_REQUEST.SUBMIT_REQUEST (
               APPLICATION => 'PER',
               PROGRAM => 'ATET_SAVING_RETIREMENT',
               DESCRIPTION => '',
               START_TIME => '',
               SUB_REQUEST => FALSE,
               ARGUMENT1 => TO_CHAR(DETAIL.P_MEMBER_ID),
               ARGUMENT2 => TO_CHAR(DETAIL.P_AMOUNT_SAVED),
               ARGUMENT3 => TO_CHAR(DETAIL.P_PERCENTAGE_RETIREMENT),
               ARGUMENT4 => TO_CHAR(DETAIL.P_SAVING_RETIREMENT),
               ARGUMENT5 => TO_CHAR('RETIRO PARCIAL DE CAJA DE AHORRO'),
               ARGUMENT6 => TO_CHAR(DETAIL.P_IS_MEMBER_END)
                                       );
            
        STANDARD.COMMIT;
                     
        var_waiting :=
            FND_CONCURRENT.WAIT_FOR_REQUEST (
                REQUEST_ID => var_import_request_id,
                INTERVAL => 1,
                MAX_WAIT => 0,
                PHASE => var_phase,
                STATUS => var_status,
                DEV_PHASE => var_dev_phase,
                DEV_STATUS => var_dev_status,
                MESSAGE => var_message
                                        );
    
            
        UPDATE ATET_RETIREMENTS_TEMP ACT
           SET ACT.REQUEST_ID = var_import_request_id
         WHERE 1 = 1
           AND ACT.P_MEMBER_ID = DETAIL.P_MEMBER_ID
           AND ACT.P_SAVING_RETIREMENT = DETAIL.P_SAVING_RETIREMENT
           AND ACT.P_IS_MEMBER_END = DETAIL.P_IS_MEMBER_END;
    
    END LOOP;

    COMMIT;

END;


/**************************************************************/
/*            LIBERACION DE RETIRO DE AHORRO                  */
/**************************************************************/
SELECT *
          FROM ATET_SB_TRANSACTIONS_HOLDS ASTH
         WHERE 1 = 1
           AND ASTH.RELEASED_FLAG = 'P'
           AND ASTH.HOLD_RELEASE_ID IS NULL;

DECLARE
    CURSOR RELEASE_DETAILS IS
        SELECT ASTH.TRANSACTION_HOLD_ID
          FROM ATET_SB_TRANSACTIONS_HOLDS ASTH
         WHERE 1 = 1
           AND ASTH.RELEASED_FLAG = 'P'
           AND ASTH.HOLD_RELEASE_ID IS NULL;   
      
    var_import_request_id       NUMBER;
    var_waiting                 BOOLEAN;
    var_phase                   VARCHAR2 (80 BYTE);
    var_status                  VARCHAR2 (80 BYTE);
    var_dev_phase               VARCHAR2 (80 BYTE);
    var_dev_status              VARCHAR2 (80 BYTE);
    var_message                 VARCHAR2 (4000 BYTE);
              
BEGIN

    fnd_global.apps_initialize (user_id        => 3397,
                                resp_id        => 53698,
                                resp_appl_id   => 101);
                       
    mo_global.set_policy_context ('S', 1329);

    
    FOR DETAIL IN RELEASE_DETAILS LOOP
        
        
        var_import_request_id :=
            FND_REQUEST.SUBMIT_REQUEST (
               APPLICATION => 'PER',
               PROGRAM => 'ATET_RELEASE_SAVING_RETIREMENT',
               DESCRIPTION => '',
               START_TIME => '',
               SUB_REQUEST => FALSE,
               ARGUMENT1 => TO_CHAR(DETAIL.TRANSACTION_HOLD_ID),
               ARGUMENT2 => TO_CHAR('LIBERADO'),
               ARGUMENT3 => TO_CHAR('Y')
                                       );
            
        STANDARD.COMMIT;
                     
        var_waiting :=
            FND_CONCURRENT.WAIT_FOR_REQUEST (
                REQUEST_ID => var_import_request_id,
                INTERVAL => 1,
                MAX_WAIT => 0,
                PHASE => var_phase,
                STATUS => var_status,
                DEV_PHASE => var_dev_phase,
                DEV_STATUS => var_dev_status,
                MESSAGE => var_message
                                        );
    
    END LOOP;


END;

