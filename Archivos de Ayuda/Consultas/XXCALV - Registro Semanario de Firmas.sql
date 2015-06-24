SELECT *
    FROM (SELECT pac_hr_pay_pkg.get_employer_name (:p_payroll_name)
                    employer_name,
                 pac_hr_pay_pkg.get_employer_address (:p_payroll_name)
                    employer_address,
                 pac_hr_pay_pkg.get_period_type (:p_payroll_name) period_type,
                 :p_payroll_name nomina,
                 pac_hr_pay_pkg.find_period_number (:p_payroll_period_name)
                    period_number,
                 pac_hr_pay_pkg.get_period_start_date (:p_payroll_period_name)
                    period_start_date,
                 pac_hr_pay_pkg.get_period_end_date (:p_payroll_period_name)
                    period_end_date,
                 name departamento,
                 organization_id
            FROM hr_all_organization_units
           WHERE organization_id IN
                    (SELECT houv.organization_id
                       FROM HR_ORGANIZATION_UNITS_V houv,
                            HR_ORGANIZATION_INFORMATION_V hoiv
                      WHERE     1 = 1
                            AND organization_type = 'DEPARTAMENTO'
                            AND houv.organization_id = hoiv.organization_id
                            AND (SUBSTR (houv.name, 1, 4)) BETWEEN :p_department_number_start
                                                               AND :p_department_number_end)) report_header,
         (  SELECT TO_CHAR (tpe.start_date, 'DD') MAR,
                   TO_CHAR (NEXT_DAY (tpe.start_date, 'MIÉ'), 'DD') MIÉ,
                   TO_CHAR (NEXT_DAY (tpe.start_date, 'JUE'), 'DD') JUE,
                   TO_CHAR (NEXT_DAY (tpe.start_date, 'VIE'), 'DD') VIE,
                   TO_CHAR (NEXT_DAY (tpe.start_date, 'SÁB'), 'DD') SÁB,
                   TO_CHAR (NEXT_DAY (tpe.start_date, 'DOM'), 'DD') DOM,
                   TO_CHAR (NEXT_DAY (tpe.start_date, 'LUN'), 'DD') LUN
              FROM pay_all_payrolls_f prl,
                   per_time_period_types tpt,
                   per_time_period_types_tl tpttl,
                   per_time_periods tpe,
                   hr_lookups hl
             WHERE     1 = 1
                   AND tpttl.LANGUAGE = USERENV ('LANG')
                   AND tpt.period_type = prl.period_type
                   AND tpt.period_type = tpttl.period_type
                   AND prl.payroll_id = tpe.payroll_id
                   AND hl.lookup_code = tpe.status
                   AND hl.lookup_type = 'PROCESSING_PERIOD_STATUS'
                   AND prl.payroll_name = :p_payroll_name
                   AND tpe.period_name = :p_payroll_period_name
          ORDER BY 4) days,
         (  SELECT employee_number,
                      last_name
                   || ' '
                   || per_information1
                   || ' '
                   || first_name
                   || ' '
                   || middle_names
                      employee_name,
                   houv.organization_id
              FROM PER_PEOPLE_F per,
                   per_assignments_f pa,
                   HR_ORGANIZATION_UNITS_V houv
             WHERE 1 = 1
                   AND SYSDATE BETWEEN per.effective_start_date
                                   AND per.effective_end_date
                   AND SYSDATE BETWEEN pa.effective_start_date
                                   AND pa.effective_end_date
                   AND pa.person_id = per.person_id
                   AND pa.organization_id = houv.organization_id
                   AND houv.organization_id IN
                          (SELECT houv.organization_id
                             FROM HR_ORGANIZATION_UNITS_V houv,
                                  HR_ORGANIZATION_INFORMATION_V hoiv
                            WHERE     1 = 1
                                  AND organization_type = 'DEPARTAMENTO'
                                  AND houv.organization_id = hoiv.organization_id
                                  AND (SUBSTR (houv.name, 1, 4)) BETWEEN :p_department_number_start
                                                                     AND :p_department_number_end)
          ORDER BY last_name,
                   per_information1,
                   first_name,
                   middle_names) employees
   WHERE employees.organization_id = report_header.organization_id
ORDER BY departamento, employee_name