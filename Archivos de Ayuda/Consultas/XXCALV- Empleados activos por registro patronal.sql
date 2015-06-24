SELECT   :p_employer_name empleador_legal,
         NVL (:p_pay_period_type, 'TODOS') periodo,
         NVL (:p_payroll_name, 'TODAS') nomina,
         PAC_HR_PAY_PKG.FIND_PERIOD_YEAR (paav.period_name) period_year,
         PAC_HR_PAY_PKG.find_period_month (paav.period_name) period_month,
         SUBSTR (ptptl.display_period_type, 1, 1) periodo_abrev,
         ppf.attribute1 acro_nomina,
         paav.assignment_number empleado,
         paav.full_name nombre,
         SUM (prrv.RESULT_VALUE) percepciones,
         PAC_HR_PAY_PKG.get_employer_registration (paav.ASSIGNMENT_ID)
         reg_patronal
    FROM PAY_PAYROLL_ACTIONS_V ppav,
         PAY_ASSIGNMENT_ACTIONS_V paav,
         PAY_RUN_RESULTS_V prrv,
         per_all_assignments_f paaf,
         PAY_PAYROLLS_F ppf,
         PER_TIME_PERIOD_TYPES_TL ptptl
   WHERE 1 = 1
         ---------------------
         AND PAC_HR_PAY_PKG.FIND_PERIOD_YEAR (paav.period_name) =
                :p_period_year
         AND PAC_HR_PAY_PKG.find_period_month (paav.period_name) =
                TO_NUMBER (:p_period_month)
--         AND paav.period_name = NVL (:p_payroll_period_name, paav.period_name)
         AND ppav.payroll_name = NVL (:p_payroll_name, ppav.payroll_name)
         AND PAC_HR_PAY_PKG.get_PERIOD_type (ppav.payroll_name) =
                NVL (:p_pay_period_type,
                     PAC_HR_PAY_PKG.get_PERIOD_type (ppav.payroll_name))
         AND PAC_HR_PAY_PKG.get_employer_name (ppav.payroll_name) =
                :p_employer_name
         AND pac_hr_pay_pkg.get_consolidation_set (ppf.consolidation_set_id) =
                NVL (
                   :p_consolidation_set,
                   pac_hr_pay_pkg.get_consolidation_set (
                      ppf.consolidation_set_id))
         ---------------------
         AND ppf.period_type = ptptl.period_type
         AND ptptl.language = USERENV ('LANG')
         AND PPF.PAYROLL_ID = ppav.payroll_id
         AND SYSDATE BETWEEN ppf.effective_start_date
                         AND ppf.effective_end_date
         AND paaf.assignment_id = paav.ASSIGNMENT_ID
         AND SYSDATE BETWEEN paaf.EFFECTIVE_START_DATE
                         AND paaf.effective_end_date
         AND ppav.period_name = paav.period_name
         AND paav.PAYROLL_ACTION_ID = ppav.PAYROLL_ACTION_ID
         AND ppav.status_code = 'C'
         AND (ppav.action_type = 'Q' OR ppav.action_type = 'R')
         AND paav.messages_exist = 'Y'
         AND prrv.ASSIGNMENT_ACTION_ID = paav.ASSIGNMENT_ACTION_ID
         AND prrv.UOM = 'M'
         AND prrv.RESULT_VALUE IS NOT NULL
         AND (prrv.classification_name IN ('Earnings', 'Supplemental Earnings')
              OR prrv.element_name IN
                    (SELECT MEANING
                       FROM FND_LOOKUP_VALUES_VL
                      WHERE lookup_type = 'XX_PERCEPCIONES_INFORMATIVAS'))
GROUP BY PAC_HR_PAY_PKG.FIND_PERIOD_YEAR (paav.period_name),
         PAC_HR_PAY_PKG.find_period_month (paav.period_name),
         ptptl.display_period_type,
         ppf.attribute1,
         paav.assignment_number,
         full_name,
         PAC_HR_PAY_PKG.get_employer_registration (paav.ASSIGNMENT_ID);