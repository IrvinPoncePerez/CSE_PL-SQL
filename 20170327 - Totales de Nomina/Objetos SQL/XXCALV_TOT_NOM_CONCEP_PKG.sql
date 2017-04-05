CREATE OR REPLACE PACKAGE APPS.XXCALV_TOT_NOM_CONCEP_PKG IS

    PROCEDURE CREATE_REPORT
        (
            P_CONSOLIDATION_SET_ID          VARCHAR2,
            P_EMPLOYER_NAME                 VARCHAR2,
            P_PAYROLL_END_MONTH_NUMBER      VARCHAR2,
            P_PAYROLL_END_PERIOD_NUMBER     VARCHAR2,
            P_PAYROLL_NAME                  VARCHAR2,
            P_PAYROLL_PERIOD_YEAR           VARCHAR2,
            P_PAYROLL_START_MONTH_NUMBER    VARCHAR2,
            P_PAYROLL_START_PERIOD_NUMBER   VARCHAR2,
            P_PAY_PERIOD_TYPE               VARCHAR2,
            P_REQUEST_ID                    VARCHAR2
        );
        
    PROCEDURE DROP_REPORT
        (
            P_REQUEST_ID                    VARCHAR2
        );

END XXCALV_TOT_NOM_CONCEP_PKG;