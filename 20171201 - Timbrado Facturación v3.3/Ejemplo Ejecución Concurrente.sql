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
                                                    PROGRAM     =>'PAC_FACTURACION_TIMBRADO',
                                                    DESCRIPTION => NULL,
                                                    START_TIME  => NULL,
                                                    SUB_REQUEST => FALSE,
                                                    ARGUMENT1 => 'PAC941215E50',
                                                    ARGUMENT2 => 'VITV721217I74',
                                                    ARGUMENT3 => 'FASA',
                                                    ARGUMENT4 => '32668',
                                                    ARGUMENT5 => 3446617--3441120
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
                                                    ARGUMENT1 => 2017
                                                  );

    DBMS_OUTPUT.PUT_LINE(V_REQUEST_ID);
    
    
    COMMIT;
              
END;


DECLARE
    V_REQUEST_ID NUMBER;
    WAITING                  BOOLEAN;
    ADD_LAYOUT_BOOLEAN       BOOLEAN;
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
    

    ADD_LAYOUT_BOOLEAN := FND_REQUEST.ADD_LAYOUT (
               TEMPLATE_APPL_NAME   => 'AR',
               TEMPLATE_CODE        => 'PAC_INVOICE_REPORT',
               TEMPLATE_LANGUAGE    => 'Spanish', 
               TEMPLATE_TERRITORY   => 'Mexico', 
               OUTPUT_FORMAT        => 'PDF' 
                                            );


    V_REQUEST_ID := APPS.FND_REQUEST.SUBMIT_REQUEST( APPLICATION =>'AR',
                                                    PROGRAM     =>'PAC_INVOICE_REPORT',
                                                    DESCRIPTION => NULL,
                                                    START_TIME  => NULL,
                                                    SUB_REQUEST => FALSE,
                                                    ARGUMENT1 => 'PAC941215E50',
                                                    ARGUMENT2 => 'RORM7404069F5',
                                                    ARGUMENT3 => 'FAVH',
                                                    ARGUMENT4 => '43075'
                                                  );

    DBMS_OUTPUT.PUT_LINE(V_REQUEST_ID);
    
    
    COMMIT;
              
END;