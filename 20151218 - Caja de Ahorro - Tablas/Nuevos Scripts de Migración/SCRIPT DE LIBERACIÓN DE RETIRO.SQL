/**************************************************/
/*                  ALTER SESION                  */
/**************************************************/
ALTER SESSION SET CURRENT_SCHEMA=APPS; 





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