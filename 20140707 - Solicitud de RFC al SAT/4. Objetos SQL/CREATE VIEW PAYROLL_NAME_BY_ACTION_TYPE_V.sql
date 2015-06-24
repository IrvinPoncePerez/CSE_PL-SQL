DROP VIEW APPS.PAYROLL_NAME_BY_ACTION_TYPE_V;

/* Formatted on 2014/07/07 17:51 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW apps.payroll_name_by_action_type_v (payroll_id,
                                                                 payroll_name
                                                                )
AS
   SELECT DISTINCT payroll.payroll_id, payroll.payroll_name
              FROM pay_all_payrolls_f payroll JOIN pay_payroll_actions actions
                   ON payroll.payroll_id = actions.payroll_id
             WHERE 1 = 1
               AND (actions.action_type = 'Q' OR actions.action_type = 'R')
          GROUP BY payroll.payroll_id, payroll.payroll_name;
