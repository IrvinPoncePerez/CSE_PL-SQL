/**************************************************/
/*                  ALTER SESION                  */
/**************************************************/
ALTER SESSION SET CURRENT_SCHEMA=APPS; 



        SELECT TIME_PERIOD_ID 
          FROM ATET_SB_PAYMENTS_SCHEDULE
         WHERE 1 = 1 
           AND LOAN_ID = :P_PARTIAL_LOAN_ID
           AND STATUS_FLAG IN ('PENDING', 'SKIP')
           AND ROWNUM = 1;


/*************************************************************/
/*      Actualizacion de TIME_PERIOD_ID EN  
            ATET_TMP_PREPAYMENT                             **/                                         
/*************************************************************/
DECLARE
    
    CURSOR PARTIAL_PREPAYMENT_DETAIL    IS
        SELECT ATP.P_PARTIAL_MEMBER_ID,
               ATP.P_PARTIAL_LOAN_ID,
               ATP.P_PARTIAL_PAYMENT_AMOUNT
          FROM ATET_TMP_PREPAYMENT  ATP
         WHERE 1 = 1
           AND ATP.P_REQUEST_ID IS NULL
           AND ATP.P_PARTIAL_MEMBER_ID IS NOT NULL
           AND ATP.P_PARTIAL_LOAN_ID IS NOT NULL
           AND ATP.P_PARTIAL_PAYMENT_AMOUNT IS NOT NULL
           AND ATP.P_PARTIAL_TIME_PERIOD_ID IS NULL;
 
              
    VAR_TIME_PERIOD_ID  NUMBER;           
           
BEGIN

   

    
    FOR DETAIL IN PARTIAL_PREPAYMENT_DETAIL LOOP
        
        
    
        BEGIN
            SELECT TIME_PERIOD_ID 
              INTO VAR_TIME_PERIOD_ID
              FROM ATET_SB_PAYMENTS_SCHEDULE
             WHERE 1 = 1 
               AND LOAN_ID = DETAIL.P_PARTIAL_LOAN_ID
               AND STATUS_FLAG IN ('PENDING')
               AND ROWNUM = 1;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            BEGIN
                SELECT TIME_PERIOD_ID 
                  INTO VAR_TIME_PERIOD_ID
                  FROM ATET_SB_PAYMENTS_SCHEDULE
                 WHERE 1 = 1 
                   AND LOAN_ID = DETAIL.P_PARTIAL_LOAN_ID
                   AND STATUS_FLAG IN ('SKIP')
                   AND ROWNUM = 1;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE(DETAIL.P_PARTIAL_LOAN_ID);        
            END;
        END;
        
        UPDATE ATET_TMP_PREPAYMENT ATP
           SET ATP.P_PARTIAL_TIME_PERIOD_ID = VAR_TIME_PERIOD_ID
         WHERE 1 = 1
           AND ATP.P_PARTIAL_MEMBER_ID = DETAIL.P_PARTIAL_MEMBER_ID
           AND ATP.P_PARTIAL_LOAN_ID = DETAIL.P_PARTIAL_LOAN_ID
           AND ATP.P_PARTIAL_PAYMENT_AMOUNT = DETAIL.P_PARTIAL_PAYMENT_AMOUNT;

    
    END LOOP;

END;



/***************************************************************/
/**     SCRIPT DE PAGOS ANTICIPADOS (PARCIALES)                */
/***************************************************************/



DECLARE
    
    CURSOR PARTIAL_PREPAYMENT_DETAIL    IS
        SELECT ATP.P_PARTIAL_MEMBER_ID,
               ATP.P_PARTIAL_LOAN_ID,
               ATP.P_PARTIAL_PAYMENT_AMOUNT,
               ATP.P_PARTIAL_TIME_PERIOD_ID
          FROM ATET_TMP_PREPAYMENT  ATP
         WHERE 1 = 1
           AND ATP.P_REQUEST_ID IS NULL
           AND ATP.P_PARTIAL_MEMBER_ID IS NOT NULL
           AND ATP.P_PARTIAL_LOAN_ID IS NOT NULL
           AND ATP.P_PARTIAL_PAYMENT_AMOUNT IS NOT NULL;
      
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
               PROGRAM => 'ATET_PARCIAL_PREPAYMENT',
               DESCRIPTION => '',
               START_TIME => '',
               SUB_REQUEST => FALSE,
               ARGUMENT1 => TO_CHAR(DETAIL.P_PARTIAL_MEMBER_ID),
               ARGUMENT2 => TO_CHAR(DETAIL.P_PARTIAL_LOAN_ID),
               ARGUMENT3 => TO_CHAR(DETAIL.P_PARTIAL_PAYMENT_AMOUNT),
               ARGUMENT4 => TO_CHAR(DETAIL.P_PARTIAL_TIME_PERIOD_ID),
               ARGUMENT5 => TO_CHAR('N')
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
           AND ACT.P_PARTIAL_MEMBER_ID = DETAIL.P_PARTIAL_MEMBER_ID
           AND ACT.P_PARTIAL_LOAN_ID = DETAIL.P_PARTIAL_LOAN_ID
           AND ACT.P_PARTIAL_PAYMENT_AMOUNT = DETAIL.P_PARTIAL_PAYMENT_AMOUNT
           AND ACT.P_PARTIAL_TIME_PERIOD_ID = DETAIL.P_PARTIAL_TIME_PERIOD_ID;
    
    END LOOP;

    COMMIT;

END;