CREATE OR REPLACE PACKAGE APPS.PAC_FAC33_PKG IS

    PROCEDURE TIMBRADO
        (
            P_ERRBUF        OUT NOCOPY VARCHAR2,
            P_RETCODE       OUT NOCOPY VARCHAR2,
            P_RFCEMI        VARCHAR2,
            P_RFCREC        VARCHAR2,
            P_SERFOL        VARCHAR2,
            P_NUMFOL        VARCHAR2
         );    

END PAC_FAC33_PKG;