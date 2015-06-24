        SELECT company company_p,
               classification_name class_name_p,
               element_name elem_name_p,
               SUM(CASE WHEN (v_period_name = 1) 
                        THEN TO_NUMBER(result_value) ELSE 0
                   END
               ) enero_p,
               SUM(CASE WHEN (v_period_name = 2) 
                        THEN TO_NUMBER(result_value) ELSE 0
                   END
               ) febrero_p,
               SUM(CASE WHEN (v_period_name = 3) 
                        THEN TO_NUMBER(result_value) ELSE 0
                   END
               ) marzo_p,
               SUM(CASE WHEN (v_period_name = 4) 
                        THEN TO_NUMBER(result_value) ELSE 0
                   END
               ) abril_p,
               SUM(CASE WHEN (v_period_name = 5) 
                        THEN TO_NUMBER(result_value) ELSE 0
                   END
               ) mayo_p,
               SUM(CASE WHEN (v_period_name = 6) 
                        THEN TO_NUMBER(result_value) ELSE 0
                   END
               ) junio_p,
               SUM(CASE WHEN (v_period_name = 7) 
                        THEN TO_NUMBER(result_value) ELSE 0
                   END
               ) julio_p,
               SUM(CASE WHEN (v_period_name = 8) 
                        THEN TO_NUMBER(result_value) ELSE 0
                   END
               ) agosto_p,
               SUM(CASE WHEN (v_period_name = 9) 
                        THEN TO_NUMBER(result_value) ELSE 0
                   END
               ) septiembre_p,
               SUM(CASE WHEN (v_period_name = 10) 
                        THEN TO_NUMBER(result_value) ELSE 0
                   END
               ) octubre_p,
               SUM(CASE WHEN (v_period_name = 11) 
                        THEN TO_NUMBER(result_value) ELSE 0
                   END
               ) noviembre_p,
               SUM(CASE WHEN (v_period_name = 12) 
                        THEN TO_NUMBER(result_value) ELSE 0
                   END
               ) diciembre_p,
               SUM(CASE WHEN (v_period_name = -1) 
                        THEN TO_NUMBER(result_value) ELSE 0
                   END
               ) errores_p,
               SUM (result_value) total_p
          FROM (SELECT (SELECT cmp.meaning company
                          FROM fnd_lookup_values cmp
                         WHERE cmp.lookup_type = 'NOMINAS POR EMPLEADOR LEGAL'
                           AND cmp.lookup_code = :p_company_id
                           AND cmp.LANGUAGE = USERENV('LANG')
                       ) company,
                       cla.classification_name,
                       ety.element_name,
                       pac_hr_pay_pkg.find_period_month(ptp.period_name) v_period_name,
                       rrv.result_value
                  FROM pay_element_types_f ety,
                       pay_element_classifications cla,
                       pay_run_result_values rrv,
                       pay_input_values_f inv,
                       pay_run_results rrs,
                       pay_assignment_actions assact,
                       pay_payroll_actions ppact,
                       pay_payrolls_f ppayrolls,
                       per_all_assignments_f paaf, 
                       per_all_people_f papf,
                       per_time_periods ptp
                 WHERE 1 = 1
                       AND paaf.person_id = papf.person_id
                       AND paaf.assignment_id = assact.assignment_id
                       AND ppact.effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date
                       AND ppact.effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
                       AND ptp.time_period_id = ppact.time_period_id
                       AND ptp.payroll_id = ppayrolls.payroll_id
                       AND ppayrolls.payroll_id = NVL(:p_payroll_id, ppayrolls.payroll_id)
                       AND ptp.period_name = NVL(:p_period_name, ptp.period_name)
--                       AND ptp.period_name LIKE '%'||NVL(:p_year, ptp.period_name)||'%'
                       AND REGEXP_LIKE(ptp.period_name,:p_year)
--                       AND NOT EXISTS (SELECT 1
--                                         FROM hr_all_organization_units ced
--                                        WHERE NAME LIKE DECODE(:p_cedis,'Y','TRAE TODO','N','%CEDI%')
--                                          AND ced.organization_id = paaf.organization_id)
                       AND NOT EXISTS (SELECT 1
                                         FROM pay_payrolls_f ppf
                                        WHERE REGEXP_LIKE(payroll_name,'CEDI|PTO|PUNTO')
                                          AND ppf.payroll_id = ppayrolls.payroll_id
                                          AND 1 = DECODE(:p_cedis,'Y',0,'N',1,1))
--                       AND ppayrolls.payroll_id NOT IN (63,79,82) 
                       AND (   (:p_payroll_id IS NULL AND ppayrolls.payroll_id NOT IN (63,79,82))
                            OR (:p_payroll_id IS NOT NULL)
                           )
                       AND paaf.organization_id = NVL(:p_organization_id, paaf.organization_id)
                       AND papf.employee_number = NVL(:p_employee_num,papf.employee_number)
                       AND ppayrolls.payroll_id = ppact.payroll_id
                       AND ppact.payroll_action_id = assact.payroll_action_id
                       AND (ppact.action_type = 'Q' OR ppact.action_type = 'R')
                       AND assact.assignment_action_id = rrs.assignment_action_id
                       AND inv.element_type_id = ety.element_type_id
                       AND rrs.element_type_id = ety.element_type_id
                       AND cla.classification_id = ety.classification_id
                       AND rrs.run_result_id = rrv.run_result_id
                       AND rrv.input_value_id = inv.input_value_id
                       AND inv.NAME = 'Pay Value'
                       AND (   cla.classification_name IN ('Earnings','Supplemental Earnings','Imputed Earnings', 'Amends')
                            OR ety.element_name IN (SELECT meaning
                                                      FROM fnd_lookup_values_vl
                                                     WHERE lookup_type = 'XX_PERCEPCIONES_INFORMATIVAS'
                                                   )
                           )
                       AND ety.element_type_id NOT IN (163, 164, 299, 300)
                       AND SYSDATE BETWEEN ety.EFFECTIVE_START_DATE AND ety.EFFECTIVE_END_DATE
                       AND SYSDATE BETWEEN INV.EFFECTIVE_START_DATE AND INV.EFFECTIVE_END_DATE
            )           
            GROUP BY company,
                     classification_name,
                     element_name
            ORDER BY 1,3;