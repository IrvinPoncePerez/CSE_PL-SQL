CREATE OR REPLACE PACKAGE PAC_UPDATE_DIRECT_DEPOSIT_PKG IS

    PROCEDURE UPDATE_PAYMENT_METHOD(
                    P_ERRBUF    OUT NOCOPY  VARCHAR2,
                    P_RETCODE   OUT NOCOPY  VARCHAR2,
                    P_PAYMENT_METHOD_ID IN  NUMBER);
    
    PROCEDURE UPDATE_PAYMENT_METHOD_BY_ID(
                    P_EMPLOYEE_NUMBER       VARCHAR2,
                    P_ACCOUNT_NUMBER        VARCHAR2,
                    P_CARD_NUMBER           VARCHAR2,
                    P_PAYMENT_METHOD_ID     NUMBER);
                    
    PROCEDURE PRINT_PAYMENT_METHOD_BY_ID(
                    P_EMPLOYEE_NUMBER       VARCHAR2,
                    P_PAYMENT_METHOD_ID     NUMBER);
    

END PAC_UPDATE_DIRECT_DEPOSIT_PKG;