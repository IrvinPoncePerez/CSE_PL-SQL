/* Formatted on 2016/10/11 15:57 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW apps.atet_sb_calendar_semi_month (period_num,
                                                               period_name,
                                                               start_date,
                                                               end_date,
                                                               exported_flag,
                                                               imported_flag,
                                                               processed_flag,
                                                               accounted_flag
                                                              )
AS
   SELECT   dd.period_num, dd.period_name, dd.start_date, dd.end_date,
            dd.exported_flag, dd.imported_flag, dd.processed_flag,
            dd.accounted_flag
       FROM (SELECT DISTINCT d.period_num AS "PERIOD_NUM",
                             d.period_name AS "PERIOD_NAME",
                             d.start_date AS "START_DATE",
                             d.end_date AS "END_DATE",
                             DECODE
                                (asps.status_flag,
                                 'SKIP', 'E',
                                 'EXPORTED', 'E',
                                 'PARTIAL', 'E',
                                 'REFINANCED', 'E',
                                 'PAYED', 'E',
                                 SUBSTR (asps.status_flag, 1, 1)
                                ) AS "EXPORTED_FLAG",
                             SUBSTR (aspr.attribute6, 1,
                                     1) AS "IMPORTED_FLAG",
                             SUBSTR
                                  (asst.transaction_code,
                                   1,
                                   1
                                  ) AS "PROCESSED_FLAG",
                             SUBSTR (asst.accounted_flag,
                                     1,
                                     1
                                    ) AS "ACCOUNTED_FLAG"
                        FROM (SELECT DISTINCT ptp.period_num, ptp.period_name,
                                              ptp.start_date, ptp.end_date,
                                              ptp.time_period_id
                                         FROM per_time_periods ptp,
                                              atet_savings_bank asb
                                        WHERE 1 = 1
                                          AND asb.saving_bank_id =
                                                 atet_savings_bank_pkg.get_saving_bank_id
                                          AND EXTRACT (YEAR FROM ptp.end_date) =
                                                                      asb.YEAR
                                          AND ptp.period_type IN
                                                   ('Quincena', 'Semi-Month')
                                          AND ptp.end_date
                                                 BETWEEN asb.opening_date
                                                     AND asb.termination_date) d
                             LEFT JOIN
                             atet_sb_payments_schedule asps
                             ON d.period_name = asps.period_name
                           AND asps.time_period_id = d.time_period_id
                             LEFT JOIN atet_sb_payroll_results aspr
                             ON d.period_name = aspr.period_name
                           AND aspr.time_period_id = d.time_period_id
                             LEFT JOIN atet_sb_savings_transactions asst
                             ON d.period_name = asst.period_name
                           AND asst.time_period_id = d.time_period_id
                    ORDER BY TO_NUMBER (d.period_num)) dd
      WHERE (   dd.exported_flag IS NOT NULL
             OR dd.imported_flag IS NOT NULL
             OR dd.processed_flag IS NOT NULL
             OR dd.accounted_flag IS NOT NULL
            )
   ORDER BY TO_NUMBER (dd.period_num);

