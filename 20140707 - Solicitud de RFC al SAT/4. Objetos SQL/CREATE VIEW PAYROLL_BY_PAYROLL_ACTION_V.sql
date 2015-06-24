DROP VIEW APPS.PAYROLL_BY_PAYROLL_ACTION_V;

/* Formatted on 2014/07/22 18:28 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW apps.payroll_by_payroll_action_v (consolidation_set_id,
                                                               consolidation_set_name,
                                                               payroll_id,
                                                               period_type,
                                                               payroll_name,
                                                               action_type
                                                              )
AS
   SELECT DISTINCT pcs.consolidation_set_id consolidation_set_id,
                   pcs.consolidation_set_name consolidation_set_name,
                   ppf.payroll_id payroll_id, ppf.period_type period_type,
                   ppf.payroll_name payroll_name, ppa.action_type action_type
              FROM pay_consolidation_sets pcs,
                   pay_payrolls_f ppf,
                   pay_payroll_actions ppa
             WHERE ppa.payroll_id = ppf.payroll_id
               AND ppa.consolidation_set_id = pcs.consolidation_set_id
               AND (ppa.action_type = 'Q' OR ppa.action_type = 'R');
