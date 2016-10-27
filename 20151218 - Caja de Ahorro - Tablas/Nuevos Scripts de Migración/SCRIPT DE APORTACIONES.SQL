/**************************************************/
/*                  ALTER SESION                  */
/**************************************************/
ALTER SESSION SET CURRENT_SCHEMA=APPS;



        SELECT ATC.P_MEMBER_ID,
               ATC.P_SAVING_AMOUNT,
               ATC.P_DEPOSIT_DATE
              FROM ATET_TMP_CONTRIBUTION    ATC
         WHERE 1 = 1
           AND ATC.P_REQUEST_ID IS NULL;


DECLARE
    
    CURSOR PARTIAL_REFINANCE_DETAIL    IS
        SELECT ATC.P_MEMBER_ID,
               ATC.P_SAVING_AMOUNT,
               ATC.P_DEPOSIT_DATE
              FROM ATET_TMP_CONTRIBUTION    ATC
         WHERE 1 = 1
--           AND ROWNUM = 1
           AND ATC.P_REQUEST_ID IS NULL;
      
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

    
    FOR DETAIL IN PARTIAL_REFINANCE_DETAIL LOOP
        
        
        var_import_request_id :=
            FND_REQUEST.SUBMIT_REQUEST (
               APPLICATION => 'PER',
               PROGRAM => 'ATET_VOLUNTARY_CONTRIBUTION',
               DESCRIPTION => '',
               START_TIME => '',
               SUB_REQUEST => FALSE,
               ARGUMENT1 => TO_CHAR(DETAIL.P_MEMBER_ID),
               ARGUMENT2 => TO_CHAR(DETAIL.P_SAVING_AMOUNT),
               ARGUMENT3 => TO_CHAR(DETAIL.P_DEPOSIT_DATE)
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
    
            
        UPDATE ATET_TMP_CONTRIBUTION ATC
           SET ATC.P_REQUEST_ID = var_import_request_id
         WHERE 1 = 1
           AND ATC.P_MEMBER_ID = DETAIL.P_MEMBER_ID
           AND ATC.P_SAVING_AMOUNT = DETAIL.P_SAVING_AMOUNT
           AND ATC.P_DEPOSIT_DATE = DETAIL.P_DEPOSIT_DATE;
           
           
    
    END LOOP;

    COMMIT;

END;

