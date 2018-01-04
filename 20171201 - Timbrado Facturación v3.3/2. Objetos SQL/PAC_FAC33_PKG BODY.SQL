CREATE OR REPLACE PACKAGE BODY APPS.PAC_FAC33_PKG IS

    PROCEDURE TIMBRADO
        (
            P_ERRBUF        OUT NOCOPY VARCHAR2,
            P_RETCODE       OUT NOCOPY VARCHAR2,
            P_RFCEMI        VARCHAR2,
            P_RFCREC        VARCHAR2,
            P_SERFOL        VARCHAR2,
            P_NUMFOL        VARCHAR2
         )
    IS
        var_request_id          NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        var_file_name           VARCHAR2(200) := '';
        var_waiting             VARCHAR2(10) := 'TRUE';
        
        var_host                VARCHAR2(50) := '192.1.1.119';
        var_user                VARCHAR2(50) := 'cfd';
        var_pass                VARCHAR2(50) := 'Facturacion01';
        
        var_port_post           VARCHAR2(10) := '21';
        var_port_transfer       VARCHAR2(10) := '2100';
        var_port_error          VARCHAR2(10) := '2200';
        
        POST_FILE_EXCEPTION         EXCEPTION;
        REMOVE_FILE_EXCEPTION       EXCEPTION;
        LISTING_ERRORS_EXCEPTION    EXCEPTION;
        CFDI_ERROR_EXCEPTION        EXCEPTION;
    BEGIN
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'REQUEST_ID : ' || var_request_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'TIMBRADO(P_RFCEMI => ' || P_RFCEMI ||
                                               ' ,P_RFCREC => ' || P_RFCREC ||
                                               ' ,P_SERFOL => ' || P_SERFOL ||
                                               ' ,P_NUMFOL => ' || P_NUMFOL || ')');
                                               
        var_file_name := var_file_name;
        var_file_name := var_file_name || P_RFCEMI || '_';
        var_file_name := var_file_name || P_RFCREC || '_';
        var_file_name := var_file_name || P_SERFOL || '_';
        var_file_name := var_file_name || P_NUMFOL;                                              
        
        
        DECLARE
            var_connection    UTL_TCP.CONNECTION;
        BEGIN      
                
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
                        
            FTP.PUT
            (
                P_CONN      => var_connection,
                P_FROM_DIR  => 'CALVARIO',
                P_FROM_FILE => var_file_name || '.txt',
                P_TO_FILE   => '/' || var_file_name || '.txt'
            );
                      
            FTP.LOGOUT
            (
                P_CONN => var_connection
            );
            
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Archivo ' || var_file_name || '.txt transferido!');
          
        EXCEPTION 
            WHEN OTHERS THEN
                RAISE POST_FILE_EXCEPTION; 
        END;
        
        
        BEGIN
        
--            UTL_FILE.FREMOVE
--                (
--                    LOCATION => 'CALVARIO',
--                    FILENAME => var_file_name || '.txt'
--                );
            
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Archivo ' || var_file_name || '.txt procesado!');
            
        EXCEPTION
            WHEN OTHERS THEN
                fnd_file.put_line(fnd_file.log, sqlerrm);
                
                RAISE REMOVE_FILE_EXCEPTION;
        END;
        
        
        LOOP
        
            DECLARE
                var_connection      UTL_TCP.CONNECTION;
                var_list_error      FTP.T_STRING_TABLE;
            BEGIN
            
                var_connection := FTP.LOGIN
                                    (
                                        P_HOST => var_host,
                                        P_PORT => var_port_error,
                                        P_USER => var_user,
                                        P_PASS => var_pass
                                    );
                            
                FTP.NLST
                    (
                        P_CONN   => var_connection,
                        P_DIR    => '/',
                        P_LIST   => var_list_error
                    );
                    
                FTP.LOGOUT
                    (
                        P_CONN  => var_connection
                    );
                  
                IF var_list_error.COUNT > 0 THEN
                
                    FOR I IN var_list_error.FIRST .. var_list_error.LAST LOOP
                
                        IF var_list_error(I) LIKE '%' || var_file_name || '%' THEN
                            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Archivo ' || var_file_name || ' con error.');
                            
                            
                            
                            
                            
                            RAISE CFDI_ERROR_EXCEPTION;
                        END IF;
                
                    END LOOP;
                
                END IF;
            EXCEPTION
                WHEN CFDI_ERROR_EXCEPTION THEN
                    RAISE CFDI_ERROR_EXCEPTION;
                WHEN OTHERS THEN
                    RAISE LISTING_ERRORS_EXCEPTION;    
            END;
            
            EXIT WHEN var_waiting = 'FALSE';
        
        END LOOP;                                                 
        
    EXCEPTION
        WHEN POST_FILE_EXCEPTION THEN
            P_ERRBUF   := 'POST_FILE_EXCEPTION : El archivo ' || var_file_name || ' no se encuentra o no fue generado.';
            P_RETCODE  := 1;
        WHEN REMOVE_FILE_EXCEPTION THEN
            P_ERRBUF   := 'REMOVE_FILE_EXCEPTION : El archivo ' || var_file_name || ' no se encuentra o no fue generado.';
            P_RETCODE  := 1;
        WHEN LISTING_ERRORS_EXCEPTION THEN
            P_ERRBUF   := 'LISTING_ERRORS_EXCEPTION : Error al recuperar la lista de errores.';
            P_RETCODE  := 1;
        WHEN CFDI_ERROR_EXCEPTION THEN
            P_ERRBUF   := 'CFDI_ERROR_EXCEPTION : El archivo ' || var_file_name || ' marcó error al momento del timbrado.';
            P_RETCODE  := 2;
    END TIMBRADO; 

END PAC_FAC33_PKG;