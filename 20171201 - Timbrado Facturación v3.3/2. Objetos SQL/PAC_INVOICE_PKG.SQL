CREATE OR REPLACE PACKAGE APPS.PAC_INVOICE_PKG IS

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
         );   
         
    PROCEDURE SYNC
        (
            P_ERRBUF            OUT NOCOPY VARCHAR2,
            P_RETCODE           OUT NOCOPY VARCHAR2,
            P_EMIANIO           VARCHAR2,
            P_EMIMES            VARCHAR2
        ); 
        
    FUNCTION GET_DESCRIPTION_VALUE
        (
            P_FLEX_VALUE_SET_NAME   VARCHAR2,
            P_FLEX_VALUE            VARCHAR2
        )
    RETURN VARCHAR2;
    
    FUNCTION READ_XML
        (
            P_FILE_NAME         VARCHAR2
        )
        RETURN VARCHAR2;
        
    FUNCTION MERGE_PDF
        (
            P_FILES             PAC_PDF_FILES,
            P_OUTPUT_DIRECTORY  VARCHAR2,
            P_USERNAME          VARCHAR2,
            P_REQUEST_ID        VARCHAR2
        )
        RETURN VARCHAR2;        

END PAC_INVOICE_PKG;