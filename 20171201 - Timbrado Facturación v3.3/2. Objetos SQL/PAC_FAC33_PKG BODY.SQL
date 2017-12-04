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
        var_request_id      NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    BEGIN
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'REQUEST_ID : ' || var_request_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'TIMBRADO(P_RFCEMI => ' || P_RFCEMI ||
                                               ' ,P_RFCREC => ' || P_RFCREC ||
                                               ' ,P_SERFOL => ' || P_SERFOL ||
                                               ' ,P_NUMFOL => ' || P_NUMFOL || ')');
                                               
                                                       
        
        
    END TIMBRADO; 

END PAC_FAC33_PKG;