CREATE OR REPLACE PACKAGE APPS.PAC_INVOICE_PKG IS

    PROCEDURE SIGNED
        (
            P_ERRBUF            OUT NOCOPY VARCHAR2,
            P_RETCODE           OUT NOCOPY VARCHAR2,
            P_RFCEMI            VARCHAR2,
            P_RFCREC            VARCHAR2,
            P_SERFOL            VARCHAR2,
            P_NUMFOL            VARCHAR2,
            P_CUSTOMER_TRX_ID   NUMBER
         );   
         
    PROCEDURE SYNC
        (
            P_ERRBUF            OUT NOCOPY VARCHAR2,
            P_RETCODE           OUT NOCOPY VARCHAR2,
            P_EMIANIO           VARCHAR2,
            P_EMIMES            VARCHAR2
        ); 

END PAC_INVOICE_PKG;