CREATE OR REPLACE FORCE VIEW APPS.PERIODS_NAME_V (PERIOD_NAME,
                                                  YEAR,
                                                  MONTH,
                                                  PAYROLL_ID,
                                                  PERIOD_TYPE
                                                 )
AS
   SELECT PT.PERIOD_NAME                                    PERIOD_NAME, 
          EXTRACT (YEAR FROM PT.END_DATE)                   YEAR,
          EXTRACT (MONTH FROM PT.END_DATE)                  MONTH, 
          PT.PAYROLL_ID                                     PAYROLL_ID,
          PAC_HR_PAY_PKG.GET_PERIOD_TYPE (PAYROLL_NAME)     PERIOD_TYPE
     FROM PER_TIME_PERIODS  PT, 
          PAY_PAYROLLS_F    PP
    WHERE PT.PAYROLL_ID = PP.PAYROLL_ID;