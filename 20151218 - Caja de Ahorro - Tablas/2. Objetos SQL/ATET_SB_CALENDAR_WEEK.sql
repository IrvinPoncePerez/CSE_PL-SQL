CREATE OR REPLACE VIEW ATET_SB_CALENDAR_WEEK
AS
SELECT DD.PERIOD_NUM,
       DD.PERIOD_NAME,
       DD.START_DATE,
       DD.END_DATE,
       DD.EXPORTED_FLAG,
       DD.IMPORTED_FLAG,
       DD.PROCESSED_FLAG,
       DD.ACCOUNTED_FLAG
  FROM (SELECT DISTINCT
               D.PERIOD_NUM                         AS  "PERIOD_NUM",
               D.PERIOD_NAME                        AS  "PERIOD_NAME",
               D.START_DATE                         AS  "START_DATE",
               D.END_DATE                           AS  "END_DATE",
               DECODE(ASPS.STATUS_FLAG,
                      'SKIP', 'E',
                      'EXPORTED', 'E',
                      'PARTIAL', 'E',
                      'REFINANCED', 'E',
                      'PAYED', 'E',
                      SUBSTR(ASPS.STATUS_FLAG,1,1)) AS  "EXPORTED_FLAG",
               SUBSTR(ASPR.ATTRIBUTE6,1,1)          AS  "IMPORTED_FLAG",
               SUBSTR(ASST.TRANSACTION_CODE,1,1)    AS  "PROCESSED_FLAG",
               SUBSTR(ASST.ACCOUNTED_FLAG,1,1)      AS  "ACCOUNTED_FLAG"
          FROM (SELECT DISTINCT
                       PTP.PERIOD_NUM,
                       PTP.PERIOD_NAME,
                       PTP.START_DATE,
                       PTP.END_DATE,
                       PTP.TIME_PERIOD_ID
                  FROM PER_TIME_PERIODS             PTP,
                       ATET_SAVINGS_BANK            ASB
                 WHERE 1 = 1
                   AND ASB.SAVING_BANK_ID = ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                   AND EXTRACT(YEAR FROM PTP.END_DATE) = ASB.YEAR
                   AND PTP.PERIOD_TYPE IN ('Semana', 'Week')
                   AND PTP.END_DATE BETWEEN ASB.OPENING_DATE AND ASB.TERMINATION_DATE) D
          LEFT JOIN ATET_SB_PAYMENTS_SCHEDULE       ASPS
            ON D.PERIOD_NAME = ASPS.PERIOD_NAME 
           AND ASPS.TIME_PERIOD_ID = D.TIME_PERIOD_ID 
          LEFT JOIN ATET_SB_PAYROLL_RESULTS         ASPR  
            ON D.PERIOD_NAME = ASPR.PERIOD_NAME 
           AND ASPR.TIME_PERIOD_ID = D.TIME_PERIOD_ID
          LEFT JOIN ATET_SB_SAVINGS_TRANSACTIONS    ASST
            ON D.PERIOD_NAME = ASST.PERIOD_NAME
           AND ASST.TIME_PERIOD_ID = D.TIME_PERIOD_ID
         ORDER BY TO_NUMBER(D.PERIOD_NUM)) DD
 WHERE 1 = 1
   AND (   DD.EXPORTED_FLAG IS NOT NULL
        OR DD.IMPORTED_FLAG IS NOT NULL
        OR DD.PROCESSED_FLAG IS NOT NULL
        OR DD.ACCOUNTED_FLAG IS NOT NULL)
 ORDER BY TO_NUMBER(DD.PERIOD_NUM) 
 
 
