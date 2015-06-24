SELECT company company_d,
       classification_name class_name_d,
       element_name elem_name_d,
       sum(enero) enero_d,
       sum(febrero) febrero_d,
       sum(marzo) marzo_d,
       sum(abril) abril_d,
       sum(mayo) mayo_d,
       sum(junio) junio_d,
       sum(julio) julio_d,
       sum(agosto) agosto_d,
       sum(septiembre) septiembre_d,
       sum(octubre) octubre_d,
       sum(noviembre) noviembre_d,
       sum(diciembre) diciembre_d,
       sum(errores) errores_d,
       sum(total) total_d
  FROM (SELECT (SELECT cmp.meaning company
                  FROM fnd_lookup_values cmp
                 WHERE cmp.lookup_type = 'NOMINAS POR EMPLEADOR LEGAL'
                   AND cmp.lookup_code = :p_company_id
                   AND cmp.LANGUAGE = userenv('LANG')
               ) company,
               prrv.classification_name,
               prrv.element_name,
                 sum(CASE WHEN (pac_hr_find_period_month(ppav.period_name) = 1) 
                          THEN to_number(prrv.result_value) ELSE 0
                      END
                 ) Enero,
                 sum(CASE WHEN (pac_hr_find_period_month(ppav.period_name) = 2) 
                          THEN to_number(prrv.result_value) ELSE 0
                      END
                 ) Febrero,
                 sum(CASE WHEN (pac_hr_find_period_month(ppav.period_name) = 3) 
                          THEN to_number(prrv.result_value) ELSE 0
                      END
                 ) Marzo,
                 sum(CASE WHEN (pac_hr_find_period_month(ppav.period_name) = 4) 
                          THEN to_number(prrv.result_value) ELSE 0
                      END
                 ) Abril,
                 sum(CASE WHEN (pac_hr_find_period_month(ppav.period_name) = 5) 
                          THEN to_number(prrv.result_value) ELSE 0
                      END
                 ) Mayo,
                 sum(CASE WHEN (pac_hr_find_period_month(ppav.period_name) = 6) 
                          THEN to_number(prrv.result_value) ELSE 0
                      END
                 ) Junio,
                 sum(CASE WHEN (pac_hr_find_period_month(ppav.period_name) = 7) 
                          THEN to_number(prrv.result_value) ELSE 0
                      END
                 ) Julio,
                 sum(CASE WHEN (pac_hr_find_period_month(ppav.period_name) = 8) 
                          THEN to_number(prrv.result_value) ELSE 0
                      END
                 ) Agosto,
                 sum(CASE WHEN (pac_hr_find_period_month(ppav.period_name) = 9) 
                          THEN to_number(prrv.result_value) ELSE 0
                      END
                 ) Septiembre,
                 sum(CASE WHEN (pac_hr_find_period_month(ppav.period_name) = 10) 
                          THEN to_number(prrv.result_value) ELSE 0
                      END
                 ) Octubre,
                 sum(CASE WHEN (pac_hr_find_period_month(ppav.period_name) = 11) 
                          THEN to_number(prrv.result_value) ELSE 0
                      END
                 ) Noviembre,
                 sum(CASE WHEN (pac_hr_find_period_month(ppav.period_name) = 12) 
                          THEN to_number(prrv.result_value) ELSE 0
                      END
                 ) Diciembre,
                  sum(CASE WHEN (pac_hr_find_period_month(ppav.period_name) = -1) 
                          THEN to_number(prrv.result_value) ELSE 0
                      END
                 ) ERRORES,
                 sum (prrv.result_value) total
            FROM pay_payroll_actions_v ppav,
                 pay_assignment_actions_v paav,
                 pay_run_results_v prrv,
                 per_assignments_v7 pav7,
                 hr_soft_coding_keyflex hsck,
                 hr_all_organization_units haou,
                 hr_organization_information hoi,
                 pay_payrolls_f ppf,
                 per_time_period_types_tl ptptl
           WHERE 1 = 1
                 AND ppf.period_type = ptptl.period_type
                 AND ptptl.LANGUAGE = userenv ('LANG')
                 AND ppf.payroll_id = ppav.payroll_id
                 AND sysdate BETWEEN ppf.effective_start_date AND ppf.effective_end_date
                 AND hsck.soft_coding_keyflex_id = pav7.soft_coding_keyflex_id
                 AND substr (hsck.concatenated_segments, 0, instr (hsck.concatenated_segments, '.') - 1) = haou.NAME
                 AND haou.organization_id = hoi.organization_id
                 AND hoi.org_information_context = 'MX_SOC_SEC_DETAILS'
                 AND pav7.assignment_id = paav.assignment_id
                 AND sysdate BETWEEN pav7.effective_start_date
                                 AND pav7.effective_end_date
                 AND ppav.period_name = paav.period_name
                 AND paav.payroll_action_id = ppav.payroll_action_id
                 AND ppav.status_code = 'C'
                 AND (ppav.action_type = 'Q' OR ppav.action_type = 'R')
                 AND paav.messages_exist = 'Y'
                 AND prrv.assignment_action_id = paav.assignment_action_id
                 AND prrv.uom = 'M'
                 AND prrv.result_value IS NOT NULL
                 AND (prrv.classification_name IN ('Involuntary Deductions', 'Voluntary Deductions')
                      OR prrv.element_name IN (SELECT meaning
                                                 FROM fnd_lookup_values_vl
                                                WHERE lookup_type = 'XX_DEDUCCIONES_INFORMATIVAS'))
                 AND ppf.payroll_id = nvl(:p_payroll_id, ppf.payroll_id)
                 AND paav.period_name = nvl(:p_period_name, paav.period_name)
                 AND NOT EXISTS (SELECT 1
                                   FROM hr_all_organization_units ced
                                  WHERE NAME LIKE decode(:p_cedis,'Y','TRAE TODO','N','%CEDI%')
                                    AND ced.organization_id = pav7.organization_id)
                 AND pav7.organization_id = nvl(:p_organization_id, pav7.organization_id)
                 AND paav.assignment_number = nvl(:p_employee_num,paav.assignment_number)
                 AND ppav.period_name LIKE '%'||nvl(:p_year,ppav.period_name)||'%'
        GROUP BY :p_company_id,
                 prrv.classification_name,
                 prrv.element_name
            )
      GROUP BY company, 
               classification_name,
               element_name
      ORDER BY 1,2;
