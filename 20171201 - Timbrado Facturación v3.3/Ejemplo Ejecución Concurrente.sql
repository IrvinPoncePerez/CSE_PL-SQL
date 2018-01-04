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
                                                    PROGRAM     =>'PAC_TIMBRADO_FACTURACION_33',
                                                    DESCRIPTION => NULL,
                                                    START_TIME  => NULL,
                                                    SUB_REQUEST => FALSE,
                                                    ARGUMENT1 => 'PAC941215E50',
                                                    ARGUMENT2 => 'XAXX010101000',
                                                    ARGUMENT3 => 'FATH',
                                                    ARGUMENT4 => '60355'
                                                  );

    DBMS_OUTPUT.PUT_LINE(V_REQUEST_ID);
    
    
    COMMIT;
              
END;

