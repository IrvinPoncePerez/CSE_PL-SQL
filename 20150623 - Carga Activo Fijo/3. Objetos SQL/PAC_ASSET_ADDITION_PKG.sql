CREATE OR REPLACE PACKAGE PAC_ASSET_ADDITION_PKG
IS

    PROCEDURE ASSET_ADDITION(
                    P_ERRBUF    OUT NOCOPY  VARCHAR2,
                    P_RETCODE   OUT NOCOPY  VARCHAR2
              );
    
    PROCEDURE ADD_ASSET_ADDITION (
                    P_DESCRIPTION           VARCHAR2,
                    P_TAG_NUMBER            VARCHAR2,
                    P_SERIAL_NUMBER         VARCHAR2,
                    P_UNITS                 NUMBER,
                    P_CATEGORY              VARCHAR2,   
                    P_COST                  NUMBER,
                    P_VENDOR_NAME           VARCHAR2,
                    P_INVOICE_NUMBER        VARCHAR2,
                    P_BOOK_CODE             VARCHAR2,
                    P_DATE_IN_SERVICE       DATE,
                    P_DEPRECIATE_METHOD     VARCHAR2,
                    P_PRORATE_CODE          VARCHAR2,
                    P_CODE_COMBINATION      VARCHAR2,
                    P_LOCATION              VARCHAR2
              );

END PAC_ASSET_ADDITION_PKG;