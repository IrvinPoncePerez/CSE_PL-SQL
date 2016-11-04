/**************************************************/
/*                  ALTER SESION                  */
/**************************************************/
ALTER SESSION SET CURRENT_SCHEMA=APPS; 

UPDATE ATET_TMP_RETIREMENTS
   SET REQUEST_ID = NULL;
COMMIT;

/**************************************************************/
/*                  RETIRO DE AHORRO                          */
/**************************************************************/
DECLARE
    CURSOR RETIREMENTS_DETAILS IS
        SELECT ACT.P_MEMBER_ID,
               ACT.P_PERCENTAGE_RETIREMENT,
               ACT.P_SAVING_RETIREMENT,
               ACT.P_IS_MEMBER_END
          FROM ATET_TMP_RETIREMENTS ACT
         WHERE 1 = 1
--           AND ROWNUM = 1
           AND ACT.REQUEST_ID IS NULL;
      
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
               ARGUMENT2 => TO_CHAR(DETAIL.P_PERCENTAGE_RETIREMENT),
               ARGUMENT3 => TO_CHAR(DETAIL.P_SAVING_RETIREMENT),
               ARGUMENT4 => TO_CHAR('RETIRO PARCIAL DE CAJA DE AHORRO'),
               ARGUMENT5 => TO_CHAR(DETAIL.P_IS_MEMBER_END)
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
    
            
        UPDATE ATET_TMP_RETIREMENTS ACT
           SET ACT.REQUEST_ID = var_import_request_id
         WHERE 1 = 1
           AND ACT.P_MEMBER_ID = DETAIL.P_MEMBER_ID
           AND ACT.P_SAVING_RETIREMENT = DETAIL.P_SAVING_RETIREMENT
           AND ACT.P_IS_MEMBER_END = DETAIL.P_IS_MEMBER_END;
    
    END LOOP;

    COMMIT;

END;