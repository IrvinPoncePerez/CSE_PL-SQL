CREATE OR REPLACE PACKAGE BODY APPS.PAC_INVOICE_PKG IS

    SUBTYPE LOG_TYPE IS BINARY_INTEGER RANGE 0..1;
      P_LOG     CONSTANT LOG_TYPE := 0;
      P_DEBUG   CONSTANT LOG_TYPE := 1;
    

    FUNCTION GET_CFDI_UUID
    (
        P_RFCEMI            VARCHAR2,
        P_RFCREC            VARCHAR2,
        P_SERFOL            VARCHAR2,
        P_NUMFOL            VARCHAR2,
        P_EMIANIO           VARCHAR2,
        P_EMIMES            VARCHAR2,
        P_EMIDIA            VARCHAR2
    )
        RETURN VARCHAR2
    AS 
        LANGUAGE JAVA NAME 'CFDI.getUUID(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String';
        
        
    FUNCTION GET_CFDI_MESSAGES
    (
        P_RFCEMI    VARCHAR2,
        P_RFCREC    VARCHAR2,
        P_SERFOL    VARCHAR2,
        P_NUMFOL    VARCHAR2
    )
        RETURN VARCHAR2
    AS
        LANGUAGE JAVA NAME 'CFDI.getMessages(java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String';
        
    
    FUNCTION SYNC
        (
            P_EMIANIO           VARCHAR2,
            P_EMIMES            VARCHAR2
        )
        RETURN VARCHAR2
    AS
        LANGUAGE JAVA NAME 'CFDI.sync(java.lang.String, java.lang.String) return java.lang.String';   
        
        
    FUNCTION READ_XML
        (
            P_FILE_NAME         VARCHAR2
        )
        RETURN VARCHAR2
    AS
        LANGUAGE JAVA NAME 'CFDI.readXML(java.lang.String) return java.lang.String';
    
    FUNCTION MERGE_PDF
        (
            P_FILES             PAC_PDF_FILES,
            P_OUTPUT_DIRECTORY  VARCHAR2,
            P_USERNAME          VARCHAR2,
            P_REQUEST_ID        VARCHAR2
        )
        RETURN VARCHAR2
    AS  
        LANGUAGE JAVA NAME 'MERGE_PDF.mergePDF(oracle.sql.ARRAY, java.lang.String, java.lang.String, java.lang.String) return java.lang.String';
    
    PROCEDURE SYNC
        (
            P_ERRBUF            OUT NOCOPY VARCHAR2,
            P_RETCODE           OUT NOCOPY VARCHAR2,
            P_EMIANIO           VARCHAR2,
            P_EMIMES            VARCHAR2
        )
    IS
        var_message         VARCHAR2(2000);
        
        CURSOR INVOICES 
        IS
        SELECT PMR.RFCEMI,
               PMR.RFCREC,
               PMR.SERFOL,
               PMR.NUMFOL,
               PMR.EMIANIO,
               PMR.EMIMES,
               PMR.EMIDIA
          FROM PAC_MASTEREDI_REPORT_TB  PMR
         WHERE 1 = 1
           AND PMR.NOMREC IS NULL
           AND PMR.EMIANIO = P_EMIANIO
           AND PMR.EMIMES = P_EMIMES;
        
    BEGIN
        
        var_message := SYNC
                        (
                            P_EMIANIO => P_EMIANIO,
                            P_EMIMES  => P_EMIMES
                        );
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, '');
        FND_FILE.PUT_LINE(FND_FILE.LOG, var_message);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '');
        
        FOR INVOICE IN INVOICES LOOP
        
            BEGIN
                
                UPDATE PAC_MASTEREDI_REPORT_TB  PMR
                   SET PMR.EMITION_DATE = TO_DATE(PMR.EMIDIA||'/'||
                                                  PMR.EMIMES||'/'||
                                                  PMR.EMIANIO,'DD/MM/RRRR')
                 WHERE 1 = 1
                   AND PMR.RFCEMI = INVOICE.RFCEMI
                   AND PMR.RFCREC = INVOICE.RFCREC
                   AND PMR.SERFOL = INVOICE.SERFOL
                   AND PMR.NUMFOL = INVOICE.NUMFOL
                   AND PMR.EMIANIO = INVOICE.EMIANIO
                   AND PMR.EMIMES = INVOICE.EMIMES
                   AND PMR.EMIDIA = INVOICE.EMIDIA;
                   
                
                FND_FILE.PUT_LINE(FND_FILE.LOG, INVOICE.RFCEMI || ' ' ||
                                                INVOICE.RFCREC || ' ' ||
                                                INVOICE.SERFOL || ' ' ||
                                                INVOICE.NUMFOL);   
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG, INVOICE.RFCEMI || ' ' ||
                                                    INVOICE.RFCREC || ' ' ||
                                                    INVOICE.SERFOL || ' ' ||
                                                    INVOICE.NUMFOL || ' NO ENCONTRADO');
                WHEN TOO_MANY_ROWS THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG, '***************************************************');
                    FND_FILE.PUT_LINE(FND_FILE.LOG, '   ERROR AL CONSULTAR EL REGISTRO DE TRANSACCION.');
                    FND_FILE.PUT_LINE(FND_FILE.LOG, '***************************************************');
            END;                   
            
            COMMIT;
            
            DECLARE
                var_connection          UTL_TCP.CONNECTION;
                var_result              VARCHAR2(2000);
                var_host                VARCHAR2(50) := '192.1.1.119';
                var_user                VARCHAR2(50) := 'cfd';
                var_pass                VARCHAR2(50) := 'Facturacion01';
                var_port_transfer       VARCHAR2(10) := '2100';
                var_file_name           VARCHAR2(100):= INVOICE.RFCEMI || '_' ||
                                                        INVOICE.RFCREC || '_' ||
                                                        INVOICE.SERFOL || '_' ||
                                                        INVOICE.NUMFOL;
            BEGIN
                var_connection := FTP.LOGIN
                                    (
                                        P_HOST => var_host,
                                        P_PORT => var_port_transfer,
                                        P_USER => var_user,
                                        P_PASS => var_pass
                                    );
                                        
                FTP.BINARY
                    (
                        P_CONN => var_connection
                    );
                        
                FTP.GET
                    (
                        P_CONN      => var_connection,
                        P_FROM_FILE => '/'||INVOICE.RFCEMI||'/'||INVOICE.EMIANIO||'/'||TRIM(TO_CHAR(INVOICE.EMIMES, '09'))||'/'||var_file_name||'.XML',
                        P_TO_DIR    => 'CALVARIO',
                        P_TO_FILE   => '/'||var_file_name||'.XML');
                    
                FTP.LOGOUT
                    (
                        P_CONN  => var_connection
                    );
                    
                FND_FILE.PUT_LINE(FND_FILE.LOG, var_file_name);    
                var_result := READ_XML('/var/tmp/CARGAS/CALVARIO/'||var_file_name||'.XML');
                IF var_result LIKE '%-CHANGE-%' THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'EL NODO DE XML O LOS NOMBRES DE ATRIBUTOS HAN CAMBIADO   ' || var_result);
                    P_RETCODE  := 2;
                END IF;
                
                FND_FILE.PUT_LINE(FND_FILE.LOG, var_result);
                    
                UTL_FILE.FREMOVE
                (
                    LOCATION => 'CALVARIO',
                    FILENAME => var_file_name || '.XML'
                );
                        
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Archivo ' || var_file_name || '.XML descargado.');
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
        
        END LOOP;
        
        
    END SYNC;    
                

    PROCEDURE SIGNED
        (
            P_ERRBUF            OUT NOCOPY VARCHAR2,
            P_RETCODE           OUT NOCOPY VARCHAR2,
            P_RFCEMI            VARCHAR2,
            P_RFCREC            VARCHAR2,
            P_SERFOL            VARCHAR2,
            P_NUMFOL            VARCHAR2,
            P_CUSTOMER_TRX_ID   NUMBER,
            P_REPORT            VARCHAR2
         )
    IS
        var_request_id          NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        var_user_id             NUMBER := FND_GLOBAL.USER_ID;        
        var_layout_value        BOOLEAN;
        var_report_request_id   NUMBER;
        var_move_request_id     NUMBER;
        
        waiting                 BOOLEAN;
        phase                   VARCHAR2 (80 BYTE);
        status                  VARCHAR2 (80 BYTE);
        dev_phase               VARCHAR2 (80 BYTE);
        dev_status              VARCHAR2 (80 BYTE);
        message                 VARCHAR2 (4000 BYTE);
        
        var_file_name           VARCHAR2(2000) := '';
        var_out_file_name       VARCHAR2(2000);
        var_pdf_file_name       VARCHAR2(2000);
        var_source_dir          VARCHAR2(2000);
        var_waiting             NUMBER := 0;
        
        var_host                VARCHAR2(50) := '192.1.1.119';
        var_user                VARCHAR2(50) := 'cfd';
        var_pass                VARCHAR2(50) := 'Facturacion01';
        
        var_port_post           VARCHAR2(10) := '21';
        var_port_transfer       VARCHAR2(10) := '2100';
        var_port_error          VARCHAR2(10) := '2200';
        
        var_put_host            VARCHAR2(50) := '192.1.1.190';
        var_put_user            VARCHAR2(50) := 'nomina';
        var_put_pass            VARCHAR2(50) := 'oracle';
        
        var_result              VARCHAR2(10);
        var_validate            NUMBER;
        
        var_year                NUMBER := EXTRACT(YEAR FROM SYSDATE);
        var_month               NUMBER := EXTRACT(MONTH FROM SYSDATE);
        var_day                 NUMBER := EXTRACT(DAY FROM SYSDATE);
        
        var_uuid                VARCHAR2(1000);
        
        NOTES_REC               AR_NOTES%ROWTYPE;
        
        POST_FILE_EXCEPTION         EXCEPTION;
        REMOVE_FILE_EXCEPTION       EXCEPTION;
        LISTING_ERRORS_EXCEPTION    EXCEPTION;
        CFDI_ERROR_EXCEPTION        EXCEPTION;
        INSERT_NOTES_EXCEPTION      EXCEPTION;
        READ_XML_EXCEPTION          EXCEPTION;
        DOWNLOAD_XML_EXCEPTION      EXCEPTION;
        DOWNLOAD_PDF_EXCEPTION      EXCEPTION;
        FATAL_EXCEPTION             EXCEPTION;
        CFDI_DUPLICATE_EXCEPTION    EXCEPTION;
        
        CURSOR MESSAGES_CUR 
        IS
        SELECT EVE_DATE,
               EVE_TITLE,
               EVE_DESC
          FROM PAC_MASTEREDI_LOG_TB PML
         WHERE 1 = 1
           AND RFCEMI = P_RFCEMI
           AND RFCREC = P_RFCREC
           AND SERFOL = P_SERFOL
           AND NUMFOL = P_NUMFOL;  
           
        PROCEDURE PUT_LOG(P_LEVEL     LOG_TYPE,
                          P_MESSAGE   VARCHAR2)
        IS
        BEGIN
            IF P_LEVEL IN (P_LOG) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, P_MESSAGE);
            END IF;    
        END PUT_LOG;     
                 
    BEGIN
        
        PUT_LOG(P_LOG,'REQUEST_ID > var_request_id:' || var_request_id);
        PUT_LOG(P_LOG,'PROCESS > TIMBRADO(P_RFCEMI=>' || P_RFCEMI ||
                                       ', P_RFCREC=>' || P_RFCREC ||
                                       ', P_SERFOL=>' || P_SERFOL ||
                                       ', P_NUMFOL=>' || P_NUMFOL || ')');
                                               
        var_file_name := var_file_name;
        var_file_name := var_file_name || P_RFCEMI || '_';
        var_file_name := var_file_name || P_RFCREC || '_';
        var_file_name := var_file_name || P_SERFOL || '_';
        var_file_name := var_file_name || P_NUMFOL;                                              
        
        
        DECLARE
            var_connection    UTL_TCP.CONNECTION;
        BEGIN          
        
            PUT_LOG(P_DEBUG,'FTP CONNECTION > var_host:' || var_host || ' var_port_post:' || var_port_post);    
        
            var_connection := FTP.LOGIN
                                (   
                                    P_HOST => var_host,
                                    P_PORT => var_port_post,
                                    P_USER => var_user,
                                    P_PASS => var_pass
                                );                    
            FTP.BINARY
            (
                P_CONN => var_connection
            );
            
            PUT_LOG(P_LOG,'FTP PUT > FROM_FILE:' || var_file_name || '.txt TO_FILE:' || '/' || var_file_name || '.txt');
                        
            FTP.PUT
            (
                P_CONN      => var_connection,
                P_FROM_DIR  => 'CALVARIO',
                P_FROM_FILE => var_file_name || '.txt',
                P_TO_FILE   => '/' || var_file_name || '.txt'
            );
            
            PUT_LOG(P_DEBUG,'FTP LOGOUT');
                      
            FTP.LOGOUT
            (
                P_CONN => var_connection
            );
            
            PUT_LOG(P_LOG,'FILE > ' || var_file_name || '.txt transferido');
          
        EXCEPTION 
            WHEN OTHERS THEN
                PUT_LOG(P_LOG, 'EXCEPTION > POST_FILE_EXCEPTION');
                RAISE POST_FILE_EXCEPTION; 
        END;
        
        
        BEGIN
        
            PUT_LOG(P_DEBUG, 'FILE REMOVE > LOCATION:CALVARIO FILENAME:' || var_file_name || '.txt'); 
            
            UTL_FILE.FREMOVE
                (
                    LOCATION => 'CALVARIO',
                    FILENAME => var_file_name || '.txt'
                );
            
            PUT_LOG(P_LOG, 'FILE > ' || var_file_name || '.txt procesado');
            
        EXCEPTION
            WHEN OTHERS THEN
                PUT_LOG(P_LOG, 'EXCEPTION > REMOVE_FILE_EXCEPTION');
                RAISE REMOVE_FILE_EXCEPTION;
        END;
        
        
        LOOP
        
            DECLARE
                var_connection      UTL_TCP.CONNECTION;
                var_list_error      FTP.T_STRING_TABLE;
            BEGIN
                
                PUT_LOG(P_DEBUG, 'FTP CONNECTION > var_host:' || var_host || ' var_port_error:' || var_port_error);
            
                var_connection := FTP.LOGIN
                                    (
                                        P_HOST => var_host,
                                        P_PORT => var_port_error,
                                        P_USER => var_user,
                                        P_PASS => var_pass
                                    );
                         
                PUT_LOG(P_DEBUG, 'FTP NAMES LISTING');
                   
                FTP.NLST
                    (
                        P_CONN   => var_connection,
                        P_DIR    => '/',
                        P_LIST   => var_list_error
                    );
                    
                PUT_LOG(P_DEBUG, 'FTP LOGOUT');    
                    
                FTP.LOGOUT
                    (
                        P_CONN  => var_connection
                    );
                  
                IF var_list_error.COUNT > 0 THEN
                
                    FOR I IN var_list_error.FIRST .. var_list_error.LAST LOOP
                    
                        PUT_LOG(P_DEBUG, 'FILE > var_file_name:' || var_file_name);
                
                        IF var_list_error(I) LIKE '%' || var_file_name || '%' THEN
                        
                            PUT_LOG(P_LOG, 'FILE ERROR > ' || var_file_name || '.txt');
                        
                            BEGIN
                            
                                PUT_LOG(P_DEBUG, 'FTP CONNECTION > var_host:' || var_host || ' var_port_error:' || var_port_error);
                            
                                var_connection := FTP.LOGIN
                                                    (
                                                        P_HOST => var_host,
                                                        P_PORT => var_port_error,
                                                        P_USER => var_user,
                                                        P_PASS => var_pass
                                                    );
                                                    
                                PUT_LOG(P_LOG, 'FTP DELETE > FILE:' || var_list_error(I));                                                     
                                                    
                                FTP.DELETE
                                    (
                                        P_CONN => var_connection,
                                        P_FILE => var_list_error(I)
                                    );
                                    
                                PUT_LOG(P_DEBUG, 'FTP LOGOUT');                                                                      
                                    
                                FTP.LOGOUT
                                    (
                                        P_CONN  => var_connection
                                    );
                            END;
                            
                            PUT_LOG(P_LOG, 'PROCESS > GET_CFDI_MESSAGES(P_RFCEMI=>' || P_RFCEMI ||
                                                                       ', P_RFCREC=>' || P_RFCREC ||
                                                                       ', P_SERFOL=>' || P_SERFOL ||
                                                                       ', P_NUMFOL=>' || P_NUMFOL || ')');
                            
                            var_result := GET_CFDI_MESSAGES
                                            (
                                                P_RFCEMI    =>  P_RFCEMI,
                                                P_RFCREC    =>  P_RFCREC,
                                                P_SERFOL    =>  P_SERFOL,
                                                P_NUMFOL    =>  P_NUMFOL
                                            );
                            
                            IF var_result = 'OK' THEN
                                FOR MESSAGE IN MESSAGES_CUR LOOP
                                    PUT_LOG(P_LOG,MESSAGE.EVE_DATE ||'  '|| MESSAGE.EVE_TITLE ||'  '|| REPLACE(REPLACE(MESSAGE.EVE_DESC, CHR(10), ''), CHR(13), ''));
                                    P_ERRBUF   := MESSAGE.EVE_DATE ||'  '|| MESSAGE.EVE_TITLE ||'  '|| REPLACE(REPLACE(MESSAGE.EVE_DESC, CHR(10), ''), CHR(13), '');
                                END LOOP;
                            END IF;
                            
                        
                            SELECT COUNT(1)
                              INTO var_validate 
                              FROM PAC_MASTEREDI_LOG_TB
                             WHERE 1 = 1
                               AND RFCEMI = P_RFCEMI
                               AND RFCREC = P_RFCREC
                               AND SERFOL = P_SERFOL
                               AND NUMFOL = P_NUMFOL
                               AND EVE_TITLE = 'Error tecnico num:91';                
                            
                            
                            DELETE FROM PAC_MASTEREDI_LOG_TB PML
                             WHERE 1 = 1
                               AND RFCEMI = P_RFCEMI
                               AND RFCREC = P_RFCREC
                               AND SERFOL = P_SERFOL
                               AND NUMFOL = P_NUMFOL;
                               
                            COMMIT;
                            
                            IF var_validate > 0 THEN
                                PUT_LOG(P_DEBUG, 'ERROR > Error tecnico num:91');
                                EXIT;
                            END IF;                 
                            
                            PUT_LOG(P_LOG, 'EXCEPTION > CFDI_ERROR_EXCEPTION');
                            RAISE CFDI_ERROR_EXCEPTION;
                        END IF;
                
                    END LOOP;
                
                END IF;
            EXCEPTION
                WHEN CFDI_ERROR_EXCEPTION THEN
                    PUT_LOG(P_LOG, 'EXCEPTION > CFDI_ERROR_EXCEPTION');
                    RAISE CFDI_ERROR_EXCEPTION;
                WHEN OTHERS THEN
                    PUT_LOG(P_LOG, 'EXCEPTION > LISTING_ERRORS_EXCEPTION');
                    RAISE LISTING_ERRORS_EXCEPTION;    
            END;
            
            PUT_LOG(P_DEBUG, 'PROCESS > GET_CFDI_UUID (P_RFCEMI=>' || P_RFCEMI ||
                                                    ', P_RFCREC=>' || P_RFCREC ||
                                                    ', P_SERFOL=>' || P_SERFOL ||
                                                    ', P_NUMFOL=>' || P_NUMFOL ||
                                                    ', P_EMIANIO=>' || var_year ||
                                                    ', P_EMIMES=>' || var_month ||
                                                    ', P_EMIDIA=>' || var_day || ')'); 
            
            var_uuid := null;
            var_uuid := GET_CFDI_UUID 
                        (
                            P_RFCEMI            => P_RFCEMI,
                            P_RFCREC            => P_RFCREC,
                            P_SERFOL            => P_SERFOL,
                            P_NUMFOL            => P_NUMFOL,
                            P_EMIANIO           => var_year,
                            P_EMIMES            => var_month,
                            P_EMIDIA            => var_day
                        );
            
            PUT_LOG(P_DEBUG,  'JAVA RESPONSE > ' || var_uuid);                                    
               
            IF var_uuid LIKE '-OK-null%'THEN
                NULL;
            ELSIF var_uuid LIKE '-OK-%' THEN
                var_waiting := 1;  
            
                PUT_LOG(P_DEBUG,  'JAVA RESPONSE > ' || var_uuid);
                
                var_uuid := TRIM(REPLACE(var_uuid, '-OK-', ''));
                
                PUT_LOG(P_LOG, 'UUID > ' || var_uuid);
                
                BEGIN 
                    NOTES_REC.NOTE_TYPE               := 'MAINTAIN';
                    NOTES_REC.CUSTOMER_TRX_ID         := P_CUSTOMER_TRX_ID;
                    NOTES_REC.TEXT                    := var_uuid;
                    NOTES_REC.CUSTOMER_CALL_TOPIC_ID  := NULL;
                    NOTES_REC.CALL_ACTION_ID          := NULL;
                    NOTES_REC.CUSTOMER_CALL_ID        := NULL;
                    NOTES_REC.CREATION_DATE           := SYSDATE;
                                     
                    ARP_NOTES_PKG.INSERT_P
                        (
                           P_NOTES_REC => NOTES_REC
                        );
                        
                    PUT_LOG(P_LOG, 'AR_NOTE >  CUSTOMER_TRX_ID:' || P_CUSTOMER_TRX_ID || ' UUID:' || var_uuid);    

                    COMMIT;                        
                        
                    PUT_LOG(P_LOG, 'FILE > ' || var_file_name || '.XML UUID insertado');
                    
                EXCEPTION
                    WHEN OTHERS THEN
                        PUT_LOG(P_LOG, 'EXCEPTION > INSERT_NOTES_EXCEPTION');
                        RAISE INSERT_NOTES_EXCEPTION;
                END;
                
                DECLARE
                    var_connection  UTL_TCP.CONNECTION;
                    var_result      VARCHAR2(2000);
                BEGIN
                    
                    PUT_LOG(P_DEBUG, 'FTP CONNECTION > var_host:' || var_host || ' var_port_transfer:' || var_port_transfer);    
                
                    var_connection := FTP.LOGIN
                                        (
                                            P_HOST => var_host,
                                            P_PORT => var_port_transfer,
                                            P_USER => var_user,
                                            P_PASS => var_pass
                                        );
                                        
                    FTP.BINARY
                        (
                            P_CONN => var_connection
                        );

                    PUT_LOG(P_LOG, 'FTP GET > FROM_FILE:' ||'/'||P_RFCEMI||'/'||var_year||'/'||TRIM(TO_CHAR(var_month, '09'))||'/'||var_file_name||'.XML' ||' TO_FILE:' || '/'||var_file_name||'.XML');                        
                        
                    FTP.GET
                        (
                            P_CONN      => var_connection,
                            P_FROM_FILE => '/'||P_RFCEMI||'/'||var_year||'/'||TRIM(TO_CHAR(var_month, '09'))||'/'||var_file_name||'.XML',
                            P_TO_DIR    => 'CALVARIO',
                            P_TO_FILE   => '/'||var_file_name||'.XML');
                    
                    PUT_LOG(P_DEBUG, 'FTP LOGOUT');
                    
                    FTP.LOGOUT
                        (
                            P_CONN  => var_connection
                        );
                    
                    IF P_REPORT IN ('Y', 'YES') THEN   
                        
                        PUT_LOG(P_DEBUG, 'FTP CONNECTION > var_put_host:' || var_put_host || ' var_port:21');
                         
                        var_connection := FTP.LOGIN
                                            (   
                                                P_HOST => var_put_host,
                                                P_PORT => '21',
                                                P_USER => var_put_user,
                                                P_PASS => var_put_pass
                                            );
                                            
                        FTP.BINARY
                        (
                            P_CONN => var_connection
                        );
                        
                        PUT_LOG(P_LOG, 'FTP PUT > FROM_FILE:' || var_file_name || '.XML TO_FILE:' || '/var/tmp/CARGAS/CALVARIO/' || var_file_name || '.XML'); 
                                    
                        FTP.PUT
                        (
                            P_CONN      => var_connection,
                            P_FROM_DIR  => 'CALVARIO',
                            P_FROM_FILE => var_file_name || '.XML',
                            P_TO_FILE   => '/var/tmp/CARGAS/CALVARIO/' || var_file_name || '.XML'
                        );
                        
                        PUT_LOG(P_DEBUG, 'FTP LOGOUT');
                                  
                        FTP.LOGOUT
                        (
                            P_CONN => var_connection
                        );
                    END IF;        
                    
                    PUT_LOG(P_LOG, 'READ FILE > ' || var_file_name || '.XML');
                    
                    var_result := READ_XML('/var/tmp/CARGAS/CALVARIO/' || var_file_name || '.XML');
                    
                    PUT_LOG(P_LOG, 'JAVA RESPONSE > ' || var_result);
                    
                    IF var_result LIKE '%-CHANGE-%' THEN
                        PUT_LOG(P_LOG, 'READ XML ERROR > ' || var_result);
                        RAISE READ_XML_EXCEPTION;
                    END IF;
                    
                    PUT_LOG(P_DEBUG, 'FILE REMOVE > LOCATION:CALVARIO FILENAME:' || var_file_name || '.XML'); 
                    
                    UTL_FILE.FREMOVE
                    (
                        LOCATION => 'CALVARIO',
                        FILENAME => var_file_name || '.XML'
                    );
                        
                    PUT_LOG(P_LOG, 'FILE > ' || var_file_name || '.XML descargado');
                EXCEPTION
                    WHEN READ_XML_EXCEPTION THEN
                        PUT_LOG(P_LOG, 'EXCEPTION > READ_XML_EXCEPTION');
                        RAISE READ_XML_EXCEPTION;
                    WHEN OTHERS THEN
                        PUT_LOG(P_LOG, 'EXCEPTION > DOWNLOAD_XML_EXCEPTION');
                        RAISE DOWNLOAD_XML_EXCEPTION;
                END;
                
                DECLARE
                    var_connection  UTL_TCP.CONNECTION;
                BEGIN
                
                    PUT_LOG(P_DEBUG, 'FTP CONNECTION > var_host:' || var_host || ' var_port_transfer:' || var_port_transfer);
                
                    var_connection := FTP.LOGIN
                                        (
                                            P_HOST => var_host,
                                            P_PORT => var_port_transfer,
                                            P_USER => var_user,
                                            P_PASS => var_pass
                                        );
                                        
                    FTP.BINARY
                        (
                            P_CONN => var_connection
                        );
                        
                    PUT_LOG(P_LOG, 'FTP GET > FROM_FILE:' ||'/'||P_RFCEMI||'/'||var_year||'/'||TRIM(TO_CHAR(var_month, '09'))||'/'||var_file_name||'.PDF' ||' TO_FILE:' || '/'||var_file_name||'.PDF');                         
                        
                    FTP.GET
                        (
                            P_CONN      => var_connection,
                            P_FROM_FILE => '/'||P_RFCEMI||'/'||var_year||'/'||TRIM(TO_CHAR(var_month, '09'))||'/'||var_file_name||'.PDF',
                            P_TO_DIR    => 'CALVARIO',
                            P_TO_FILE   => '/'||var_file_name||'.PDF');
                    
                    PUT_LOG(P_DEBUG, 'FTP LOGOUT');
                    
                    FTP.LOGOUT
                        (
                            P_CONN  => var_connection
                        );
                    
                    IF P_REPORT IN ('Y', 'YES') THEN    
                    
                        PUT_LOG(P_DEBUG, 'FTP CONNECTION > var_put_host:' || var_put_host || ' var_port:21');    
                    
                        var_connection := FTP.LOGIN
                                            (   
                                                P_HOST => var_put_host,
                                                P_PORT => '21',
                                                P_USER => var_put_user,
                                                P_PASS => var_put_pass
                                            );
                                            
                        FTP.BINARY
                        (
                            P_CONN => var_connection
                        );
                              
                        PUT_LOG(P_LOG, 'FTP PUT > FROM_FILE:' || var_file_name || '.PDF TO_FILE:' || '/var/tmp/CARGAS/CALVARIO/' || var_file_name || '.PDF');
                              
                        FTP.PUT
                        (
                            P_CONN      => var_connection,
                            P_FROM_DIR  => 'CALVARIO',
                            P_FROM_FILE => var_file_name || '.PDF',
                            P_TO_FILE   => '/var/tmp/CARGAS/CALVARIO/' || var_file_name || '.PDF'
                        );
                                
                        PUT_LOG(P_DEBUG, 'FTP LOGOUT');
                          
                        FTP.LOGOUT
                        (
                            P_CONN => var_connection
                        );
                    END IF;           
                        
                    PUT_LOG(P_DEBUG, 'FILE REMOVE > LOCATION:CALVARIO FILENAME:' || var_file_name || '.PDF'); 
                    
                    UTL_FILE.FREMOVE
                    (
                        LOCATION => 'CALVARIO',
                        FILENAME => var_file_name || '.PDF'
                    );
                    
                    PUT_LOG(P_LOG, 'FILE > ' || var_file_name || '.PDF descargado');
                EXCEPTION
                    WHEN OTHERS THEN
                        PUT_LOG(P_LOG, 'EXCEPTION > DOWNLOAD_PDF_EXCEPTION');
                        RAISE DOWNLOAD_PDF_EXCEPTION;
                END;
                
                EXIT;
            
            ELSIF var_uuid LIKE '-DUPLICATE-%' THEN
                
                DECLARE
                    var_connection      UTL_TCP.CONNECTION;
                    var_list_error      FTP.T_STRING_TABLE;
                BEGIN
                    
                    PUT_LOG(P_DEBUG, 'FTP CONNECTION > var_host:' || var_host || ' var_port_error:' || var_port_error);
                
                    var_connection := FTP.LOGIN
                                        (
                                            P_HOST => var_host,
                                            P_PORT => var_port_error,
                                            P_USER => var_user,
                                            P_PASS => var_pass
                                        );
                             
                    PUT_LOG(P_DEBUG, 'FTP NAMES LISTING');
                       
                    FTP.NLST
                        (
                            P_CONN   => var_connection,
                            P_DIR    => '/',
                            P_LIST   => var_list_error
                        );
                        
                    PUT_LOG(P_DEBUG, 'FTP LOGOUT');    
                        
                    FTP.LOGOUT
                        (
                            P_CONN  => var_connection
                        );
                      
                    IF var_list_error.COUNT > 0 THEN
                    
                        FOR I IN var_list_error.FIRST .. var_list_error.LAST LOOP
                        
                            PUT_LOG(P_DEBUG, 'FILE > var_file_name:' || var_file_name);
                    
                            IF var_list_error(I) LIKE '%' || var_file_name || '%' THEN
                            
                                PUT_LOG(P_LOG, 'FILE ERROR > ' || var_file_name || '.txt');
                            
                                BEGIN
                                
                                    PUT_LOG(P_DEBUG, 'FTP CONNECTION > var_host:' || var_host || ' var_port_error:' || var_port_error);
                                
                                    var_connection := FTP.LOGIN
                                                        (
                                                            P_HOST => var_host,
                                                            P_PORT => var_port_error,
                                                            P_USER => var_user,
                                                            P_PASS => var_pass
                                                        );
                                                        
                                    PUT_LOG(P_LOG, 'FTP DELETE > FILE:' || var_list_error(I));                                                     
                                                        
                                    FTP.DELETE
                                        (
                                            P_CONN => var_connection,
                                            P_FILE => var_list_error(I)
                                        );
                                        
                                    PUT_LOG(P_DEBUG, 'FTP LOGOUT');                                                                      
                                        
                                    FTP.LOGOUT
                                        (
                                            P_CONN  => var_connection
                                        );
                                END;
                                
                                PUT_LOG(P_LOG, 'PROCESS > GET_CFDI_MESSAGES(P_RFCEMI=>' || P_RFCEMI ||
                                                                           ', P_RFCREC=>' || P_RFCREC ||
                                                                           ', P_SERFOL=>' || P_SERFOL ||
                                                                           ', P_NUMFOL=>' || P_NUMFOL || ')');
                                
                                var_result := GET_CFDI_MESSAGES
                                                (
                                                    P_RFCEMI    =>  P_RFCEMI,
                                                    P_RFCREC    =>  P_RFCREC,
                                                    P_SERFOL    =>  P_SERFOL,
                                                    P_NUMFOL    =>  P_NUMFOL
                                                );
                                
                                IF var_result = 'OK' THEN
                                    FOR MESSAGE IN MESSAGES_CUR LOOP
                                        PUT_LOG(P_LOG,MESSAGE.EVE_DATE ||'  '|| MESSAGE.EVE_TITLE ||'  '|| REPLACE(REPLACE(MESSAGE.EVE_DESC, CHR(10), ''), CHR(13), ''));
                                        P_ERRBUF   := MESSAGE.EVE_DATE ||'  '|| MESSAGE.EVE_TITLE ||'  '|| REPLACE(REPLACE(MESSAGE.EVE_DESC, CHR(10), ''), CHR(13), '');
                                    END LOOP;
                                END IF;
                                
                                DELETE FROM PAC_MASTEREDI_LOG_TB PML
                                 WHERE 1 = 1
                                   AND RFCEMI = P_RFCEMI
                                   AND RFCREC = P_RFCREC
                                   AND SERFOL = P_SERFOL
                                   AND NUMFOL = P_NUMFOL;
                                   
                                COMMIT;              
                                
                                PUT_LOG(P_LOG, 'EXCEPTION > CFDI_DUPLICATE_EXCEPTION');
                                RAISE CFDI_DUPLICATE_EXCEPTION;
                            END IF;
                    
                        END LOOP;
                    
                    END IF;
                EXCEPTION
                    WHEN CFDI_DUPLICATE_EXCEPTION THEN
                        PUT_LOG(P_LOG, 'EXCEPTION > CFDI_DUPLICATE_EXCEPTION');
                        RAISE CFDI_DUPLICATE_EXCEPTION;
                    WHEN OTHERS THEN
                        PUT_LOG(P_LOG, 'EXCEPTION > LISTING_ERRORS_EXCEPTION');
                        RAISE LISTING_ERRORS_EXCEPTION;    
                END;
                           
            ELSE
                PUT_LOG(P_DEBUG, 'ELSE RESPONSE > ' || var_uuid);       
            END IF;
        
        END LOOP;   
        
        IF P_REPORT IN ('Y', 'YES') THEN
            IF var_waiting = 1 THEN
            
                PUT_LOG(P_LOG, 'FND_REQUEST > ADD_LAYOUT > PAC_INVOICE_REPORT');
            
                var_layout_value := FND_REQUEST.ADD_LAYOUT 
                                    (
                                       TEMPLATE_APPL_NAME   => 'AR',
                                       TEMPLATE_CODE        => 'PAC_INVOICE_REPORT',
                                       TEMPLATE_LANGUAGE    => 'Spanish', 
                                       TEMPLATE_TERRITORY   => 'Mexico', 
                                       OUTPUT_FORMAT        => 'PDF' 
                                    );

                PUT_LOG(P_LOG, 'FND_REQUEST > SUBMIT_REQUEST > PAC_INVOICE_REPORT');
                PUT_LOG(P_LOG, 'PAC_INVOICE_REPORT > ARGUMENT1:'||P_SERFOL);
                PUT_LOG(P_LOG, 'PAC_INVOICE_REPORT > ARGUMENT2:'||P_NUMFOL);
                PUT_LOG(P_LOG, 'PAC_INVOICE_REPORT > ARGUMENT3:'||P_RFCREC);
                PUT_LOG(P_LOG, 'PAC_INVOICE_REPORT > ARGUMENT4:'||P_RFCEMI);

                var_report_request_id := FND_REQUEST.SUBMIT_REQUEST
                                         ( 
                                            APPLICATION =>'AR',
                                            PROGRAM     =>'PAC_INVOICE_REPORT',
                                            DESCRIPTION => NULL,
                                            START_TIME  => NULL,
                                            SUB_REQUEST => FALSE,
                                            ARGUMENT1   => P_SERFOL,
                                            ARGUMENT2   => P_NUMFOL,
                                            ARGUMENT3   => P_RFCREC,
                                            ARGUMENT4   => P_RFCEMI
                                         );
                                         
                STANDARD.COMMIT;
                
                PUT_LOG(P_LOG, 'FND_CONCURRENT > WAI_FOR_REQUEST > var_report_request_id:'|| var_report_request_id);
             
                waiting := FND_CONCURRENT.WAIT_FOR_REQUEST 
                           (
                                REQUEST_ID  => var_report_request_id,
                                INTERVAL    => 1,
                                MAX_WAIT    => 0,
                                PHASE       => phase,
                                STATUS      => status,
                                DEV_PHASE   => dev_phase,
                                DEV_STATUS  => dev_status,
                                MESSAGE     => message
                           );                                   
            
            END IF;
            
            IF var_waiting = 1 THEN
                SELECT FCR.OUTFILE_NAME,
                       FCO.FILE_NAME
                  INTO var_out_file_name,
                       var_pdf_file_name
                  FROM FND_CONCURRENT_REQUESTS  FCR,
                       FND_CONC_REQ_OUTPUTS     FCO
                 WHERE 1 = 1
                   AND FCR.REQUEST_ID = var_report_request_id
                   AND FCR.REQUEST_ID = FCO.CONCURRENT_REQUEST_ID
                   AND FCO.FILE_TYPE IN ('PDF', 'pdf');
                   
                PUT_LOG(P_LOG, 'QUERY > var_out_file_name:' || var_out_file_name);
                PUT_LOG(P_LOG, 'QUERY > var_pdf_file_name:' || var_pdf_file_name);                        
                   
                SELECT DD.DIRECTORY_PATH
                  INTO var_source_dir
                  FROM DBA_DIRECTORIES DD
                 WHERE 1 = 1
                   AND DD.DIRECTORY_NAME = 'CALVARIO';
                   
                PUT_LOG(P_LOG, 'QUERY > var_source_dir:' || var_source_dir);                   
                   
                FND_GLOBAL.APPS_INITIALIZE 
                (
                    USER_ID        => 3397,
                    RESP_ID        => 50627,
                    RESP_APPL_ID   => 222
                );
                           
                MO_GLOBAL.SET_POLICY_CONTEXT 
                (   
                    P_ACCESS_MODE => 'S', 
                    P_ORG_ID => 1329
                );                       
                
                PUT_LOG(P_LOG, 'FND_REQUEST > SUBMIT_REQUEST > PAC_INVOICE_MOVE');
                PUT_LOG(P_LOG, 'PAC_INVOICE_MOVE > ARGUMENT1:'||var_source_dir);
                PUT_LOG(P_LOG, 'PAC_INVOICE_MOVE > ARGUMENT2:'||var_file_name);
                PUT_LOG(P_LOG, 'PAC_INVOICE_MOVE > ARGUMENT3:'||var_out_file_name);
                PUT_LOG(P_LOG, 'PAC_INVOICE_MOVE > ARGUMENT4:'||var_pdf_file_name);
                PUT_LOG(P_LOG, 'PAC_INVOICE_MOVE > ARGUMENT5:'||'XML');
                PUT_LOG(P_LOG, 'PAC_INVOICE_MOVE > ARGUMENT6:'||'PDF');
                                           
                var_move_request_id := FND_REQUEST.SUBMIT_REQUEST
                                       ( 
                                            APPLICATION =>'AR',
                                            PROGRAM     =>'PAC_INVOICE_MOVE',
                                            DESCRIPTION => NULL,
                                            START_TIME  => NULL,
                                            SUB_REQUEST => FALSE,
                                            ARGUMENT1   => var_source_dir,
                                            ARGUMENT2   => var_file_name,
                                            ARGUMENT3   => var_out_file_name,
                                            ARGUMENT4   => var_pdf_file_name,
                                            ARGUMENT5   => 'XML',
                                            ARGUMENT6   => 'PDF'
                                        );                      
                                                                   
            END IF;
        END IF;      
                                                      
        
    EXCEPTION
        WHEN POST_FILE_EXCEPTION THEN
            P_ERRBUF   := 'POST_FILE_EXCEPTION : El archivo ' || var_file_name || ' no se encuentra o no fue generado.';
            P_RETCODE  := 1;
        WHEN REMOVE_FILE_EXCEPTION THEN
            P_ERRBUF   := 'REMOVE_FILE_EXCEPTION : El archivo ' || var_file_name || ' no se encuentra o no fue generado.';
            P_RETCODE  := 1;
        WHEN LISTING_ERRORS_EXCEPTION THEN
            P_ERRBUF   := 'LISTING_ERRORS_EXCEPTION : Error al recuperar la lista de errores del archivo ' || var_file_name || '.';
            P_RETCODE  := 1;
        WHEN CFDI_ERROR_EXCEPTION THEN
            P_RETCODE  := 2;
        WHEN INSERT_NOTES_EXCEPTION THEN
            P_ERRBUF   := 'INSERT_NOTES_EXCEPTION : Error al insertar el UUID como AR_NOTE para el archivo ' || var_file_name || '.';
            P_RETCODE  := 1;
        WHEN READ_XML_EXCEPTION THEN
            P_ERRBUF   := 'READ_XML_EXCEPTION : El Nodo de XML o los Nombres de Atributos han cambiado.';
            P_RETCODE  := 2;
        WHEN DOWNLOAD_XML_EXCEPTION THEN
            P_ERRBUF   := 'DOWNLOAD_XML_EXCEPTION : Error al descargar el archivo *.XML del archivo ' || var_file_name || '.';
            P_RETCODE  := 1;
        WHEN DOWNLOAD_PDF_EXCEPTION THEN
            P_ERRBUF   := 'DOWNLOAD_PDF_EXCEPTION : Error al descargar el archivo *.PDF del archivo ' || var_file_name || '.';
            P_RETCODE  := 1;
        WHEN CFDI_DUPLICATE_EXCEPTION THEN
            P_RETCODE  := 1;    
        WHEN FATAL_EXCEPTION THEN
            P_ERRBUF   := 'EXCEPTION : Excepción no manejada.';
            P_RETCODE  := 2;
    END SIGNED; 
    
    
    FUNCTION GET_DESCRIPTION_VALUE
        (
            P_FLEX_VALUE_SET_NAME   VARCHAR2,
            P_FLEX_VALUE            VARCHAR2
        )
    RETURN VARCHAR2
    IS
        var_result  VARCHAR2(100);
    BEGIN
    
        SELECT FFVVT.DESCRIPTION 
          INTO var_result
          FROM FND_FLEX_VALUE_SETS  FFVS,
               FND_FLEX_VALUES      FFVV,
               FND_FLEX_VALUES_TL   FFVVT
         WHERE 1 = 1
           AND FFVS.FLEX_VALUE_SET_NAME = P_FLEX_VALUE_SET_NAME
           AND FFVS.FLEX_VALUE_SET_ID = FFVV.FLEX_VALUE_SET_ID
           AND FFVV.FLEX_VALUE_ID = FFVVT.FLEX_VALUE_ID
           AND FFVVT.LANGUAGE = USERENV('LANG')
           AND FFVV.FLEX_VALUE = P_FLEX_VALUE;    
    
        RETURN var_result;
    END GET_DESCRIPTION_VALUE;
    

END PAC_INVOICE_PKG;