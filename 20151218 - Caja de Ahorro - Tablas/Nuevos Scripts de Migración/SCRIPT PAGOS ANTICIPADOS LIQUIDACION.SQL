DECLARE
    
    CURSOR PARTIAL_PREPAYMENT_DETAIL    IS
        SELECT ATP.P_PREPAID_MEMBER_ID,
               ATP.P_PREPAID_LOAN_ID,
               ATP.P_PREPAID_BONUS_PERCENTAGE,
               ATP.P_PREPAID_BONUS_AMOUNT
          FROM ATET_TMP_PREPAYMENT  ATP
         WHERE 1 = 1
           AND ATP.P_REQUEST_ID IS NULL
           AND ATP.P_PREPAID_MEMBER_ID IS NOT NULL
           AND ATP.P_PREPAID_LOAN_ID IS NOT NULL
           AND ATP.P_PREPAID_BONUS_PERCENTAGE IS NOT NULL
           AND ATP.P_PREPAID_BONUS_AMOUNT IS NOT NULL;
      
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

    
    FOR DETAIL IN PARTIAL_PREPAYMENT_DETAIL LOOP
        
        
        var_import_request_id :=
            FND_REQUEST.SUBMIT_REQUEST (
               APPLICATION => 'PER',
               PROGRAM => 'ATET_PROCESS_PREPAYMENT',
               DESCRIPTION => '',
               START_TIME => '',
               SUB_REQUEST => FALSE,
               ARGUMENT1 => TO_CHAR(DETAIL.P_PREPAID_MEMBER_ID),
               ARGUMENT2 => TO_CHAR(DETAIL.P_PREPAID_LOAN_ID),
               ARGUMENT3 => TO_CHAR(DETAIL.P_PREPAID_BONUS_PERCENTAGE),
               ARGUMENT4 => TO_CHAR(DETAIL.P_PREPAID_BONUS_AMOUNT)
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
    
            
        UPDATE ATET_TMP_PREPAYMENT ACT
           SET ACT.P_REQUEST_ID = var_import_request_id
         WHERE 1 = 1
           AND ACT.P_PREPAID_MEMBER_ID = DETAIL.P_PREPAID_MEMBER_ID
           AND ACT.P_PREPAID_LOAN_ID = DETAIL.P_PREPAID_LOAN_ID
           AND ACT.P_PREPAID_BONUS_PERCENTAGE = DETAIL.P_PREPAID_BONUS_PERCENTAGE
           AND ACT.P_PREPAID_BONUS_AMOUNT = DETAIL.P_PREPAID_BONUS_AMOUNT;
    
    END LOOP;

    COMMIT;

END;

