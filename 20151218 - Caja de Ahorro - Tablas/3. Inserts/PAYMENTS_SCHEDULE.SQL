SELECT PAYROLL_ID,
                TIME_PERIOD_ID,
                END_DATE,
                PERIOD_NAME,
                PERIOD_NUM,
                PERIOD_SEQUENCE
           FROM (  SELECT PAYROLL_ID,
                          TIME_PERIOD_ID,
                          END_DATE,
                          PERIOD_NAME,
                          PERIOD_NUM,
                          ROW_NUMBER ()
                             OVER (PARTITION BY PAYROLL_ID ORDER BY END_DATE)
                             PERIOD_SEQUENCE
                     FROM PER_TIME_PERIODS
                    WHERE PAYROLL_ID = LN_PAYROLL_ID
                          AND (END_DATE > TO_DATE (LD_DATE_EARNED)
                               AND END_DATE > TO_DATE (LN_TRANSACTION_DATE))
                 ORDER BY END_DATE)
          WHERE PERIOD_SEQUENCE <= LN_TERM_PERIODS;