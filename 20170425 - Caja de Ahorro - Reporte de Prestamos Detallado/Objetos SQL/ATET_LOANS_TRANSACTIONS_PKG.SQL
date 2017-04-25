CREATE OR REPLACE PACKAGE APPS.ATET_LOANS_TRANSACTIONS_PKG IS

    PROCEDURE CREATE_REPORT
        (
            CP_START_DATE          VARCHAR2,
            CP_END_DATE            VARCHAR2,
            P_MEMBER_ID           VARCHAR2,
            P_PAYROLL_ID          VARCHAR2,
            P_PERIOD_TYPE         VARCHAR2,
            P_TRANSACTION_CODE    VARCHAR2,
            P_REQUEST_ID          VARCHAR2
        );
        
    PROCEDURE DROP_REPORT
        (
            P_REQUEST_ID                    VARCHAR2
        );

END ATET_LOANS_TRANSACTIONS_PKG;