/**************************************************/
/*                  ALTER SESION                  */
/**************************************************/
ALTER SESSION SET CURRENT_SCHEMA=APPS;


DECLARE
    
    CURSOR PARTIAL_REFINANCE_DETAIL    IS
        SELECT ATR.P_PREVIOUS_LOAN_ID,
               ATR.P_ACTUAL_LOAN_ID,
               ATR.P_CONDONATE_INTEREST,
               ATR.P_PREPAYMENT_AMOUNT
          FROM ATET_TMP_REFINANCE  ATR
         WHERE 1 = 1
           AND ATR.P_REQUEST_ID IS NULL
           AND P_ACTUAL_LOAN_ID IS NOT NULL
         ORDER BY P_PREVIOUS_LOAN_ID;
      
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
               PROGRAM => 'ATET_MANUAL_REFINANCING',
               DESCRIPTION => '',
               START_TIME => '',
               SUB_REQUEST => FALSE,
               ARGUMENT1 => TO_CHAR(DETAIL.P_PREVIOUS_LOAN_ID),
               ARGUMENT2 => TO_CHAR(DETAIL.P_ACTUAL_LOAN_ID),
               ARGUMENT3 => TO_CHAR(DETAIL.P_CONDONATE_INTEREST),
               ARGUMENT4 => TO_CHAR(DETAIL.P_PREPAYMENT_AMOUNT)
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
    
            
        UPDATE ATET_TMP_REFINANCE ACT
           SET ACT.P_REQUEST_ID = var_import_request_id
         WHERE 1 = 1
           AND ACT.P_PREVIOUS_LOAN_ID = DETAIL.P_PREVIOUS_LOAN_ID
           AND ACT.P_ACTUAL_LOAN_ID = DETAIL.P_ACTUAL_LOAN_ID
           AND ACT.P_CONDONATE_INTEREST = DETAIL.P_CONDONATE_INTEREST
           AND ACT.P_PREPAYMENT_AMOUNT = DETAIL.P_PREPAYMENT_AMOUNT;
    
    END LOOP;

    COMMIT;

END;

