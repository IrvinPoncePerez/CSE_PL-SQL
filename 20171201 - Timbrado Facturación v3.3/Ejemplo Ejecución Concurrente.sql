ALTER SESSION SET CURRENT_SCHEMA=APPS;


DECLARE
    V_REQUEST_ID NUMBER;
    WAITING                  BOOLEAN;
   PHASE                    VARCHAR2(80 BYTE);
   STATUS                   VARCHAR2(80 BYTE);
   DEV_PHASE                VARCHAR2(80 BYTE);
   DEV_STATUS               VARCHAR2(80 BYTE);
   MESSAGE                  VARCHAR2(4000 BYTE);
BEGIN


    fnd_global.apps_initialize (user_id        => 3397,
                                resp_id        => 50627,
                                resp_appl_id   => 222);
                       
    mo_global.set_policy_context ('S', 1329);
    

    V_REQUEST_ID := APPS.FND_REQUEST.SUBMIT_REQUEST( APPLICATION =>'AR',
                                                    PROGRAM     =>'PAC_INVOICE_SIGNED',
                                                    DESCRIPTION => NULL,
                                                    START_TIME  => NULL,
                                                    SUB_REQUEST => FALSE,
                                                    ARGUMENT1 => 'PAC941215E50',
                                                    ARGUMENT2 => 'NWM9709244W4',
                                                    ARGUMENT3 => 'CRTG',
                                                    ARGUMENT4 => '244',
                                                    ARGUMENT5 => 3488964
                                                  );

    DBMS_OUTPUT.PUT_LINE(V_REQUEST_ID);
    
    
    COMMIT;
              
END;



DECLARE
    V_REQUEST_ID NUMBER;
    WAITING                  BOOLEAN;
   PHASE                    VARCHAR2(80 BYTE);
   STATUS                   VARCHAR2(80 BYTE);
   DEV_PHASE                VARCHAR2(80 BYTE);
   DEV_STATUS               VARCHAR2(80 BYTE);
   MESSAGE                  VARCHAR2(4000 BYTE);
BEGIN


    fnd_global.apps_initialize (user_id        => 3397,
                                resp_id        => 50627,
                                resp_appl_id   => 222);
                       
    mo_global.set_policy_context ('S', 1329);
    

    V_REQUEST_ID := APPS.FND_REQUEST.SUBMIT_REQUEST( APPLICATION =>'AR',
                                                    PROGRAM     =>'PAC_INVOICE_SYNC',
                                                    DESCRIPTION => NULL,
                                                    START_TIME  => NULL,
                                                    SUB_REQUEST => FALSE,
                                                    ARGUMENT1 => 2018,
                                                    ARGUMENT2 => 2
                                                  );

    DBMS_OUTPUT.PUT_LINE(V_REQUEST_ID);
    
    
    COMMIT;
              
END;

