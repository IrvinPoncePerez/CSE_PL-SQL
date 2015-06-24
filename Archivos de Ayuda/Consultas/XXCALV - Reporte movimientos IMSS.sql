/* Bajas final version */

SELECT pac_hr_pay_pkg.get_employer_name (ppf.payroll_name) compania,
       DECODE (:p_employer_registration,
               NULL, 'TODOS',
               pac_hr_pay_pkg.get_employer_registration (paaf.assignment_id))
          reg_patro,
       NVL (:p_tipo_de_movimiento, 'TODOS') tipo_mov,
       :p_start_date inicio,
       :p_end_date fin,
       pac_hr_pay_pkg.get_payroll_short_name (ppf.payroll_name) empresa,
       pac_hr_pay_pkg.get_employee_number (pposv.person_id) numero,
       pac_hr_pay_pkg.get_person_name (SYSDATE, pposv.person_id) empleado,
       pposv.actual_termination_date fecha_movimiento,
       'B' tipo_movimiento,
       --     Old salary ppp
       --       TRUNC (
       --          DECODE (
       --             ppf.period_type,
       --             'Week', pac_hr_pay_pkg.GET_SALARY_PPP (paaf.assignment_id)
       --                     / 30.4,
       --             pac_hr_pay_pkg.GET_SALARY_PPP (paaf.assignment_id) / 30),
       --          2)

       PAC_PAY_MX_FF_UDFS.GET_IDW (paaf.assignment_id,
                                   TO_NUMBER (hsck.segment1),
                                   pposv.actual_termination_date,
                                   'REPORT')
          salario,
       pac_hr_pay_pkg.get_employee_ssid (pposv.person_id) nss,
       pac_hr_pay_pkg.get_employee_tax_payer_id (pposv.person_id) rfc,
       pac_hr_pay_pkg.get_department_number (paaf.organization_id) depto,
       pac_hr_pay_pkg.get_employer_registration (paaf.assignment_id) clave,
       pac_hr_pay_pkg.get_admission_date (pposv.person_id) ingreso,
       pac_hr_pay_pkg.get_department_name (paaf.organization_id) departamento,
       pposv.d_leaving_reason observaciones,
       pac_hr_pay_pkg.get_management_by_groupid (people_group_id) gerencia,
       TRUNC (MONTHS_BETWEEN (actual_termination_date, date_start) / 12)
          años,
       MOD (TRUNC (MONTHS_BETWEEN (actual_termination_date, date_start)), 12)
          meses
  FROM PER_PERIODS_OF_SERVICE_V pposv,
       per_all_assignments_f paaf,
       PAY_PAYROLLS_F ppf,
       hr_soft_coding_keyflex hsck
 WHERE     1 = 1
       AND actual_termination_date BETWEEN :p_start_date AND :p_end_date
       AND 'B' = NVL (:p_tipo_de_movimiento, 'B')
       AND PAC_HR_PAY_PKG.get_employer_name (ppf.payroll_name) =
              NVL (:p_employer_name,
                   PAC_HR_PAY_PKG.get_employer_name (ppf.payroll_name))
       AND pac_hr_pay_pkg.get_employer_registration (paaf.assignment_id) =
              NVL (
                 :p_employer_registration,
                 pac_hr_pay_pkg.get_employer_registration (
                    paaf.assignment_id))
       AND paaf.period_of_service_id = pposv.period_of_service_id
       AND ppf.payroll_id = paaf.payroll_id
       AND assignment_status_type_id = 3
       AND hsck.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
UNION ALL
/* ALTAS */
SELECT pac_hr_pay_pkg.get_employer_name (payrolls.payroll_name) compania,
       DECODE (
          :p_employer_registration,
          NULL, 'TODOS',
          pac_hr_pay_pkg.get_employer_registration (
             assignments.assignment_id))
          reg_patro,
       NVL (:p_tipo_de_movimiento, 'TODOS') tipo_mov,
       :p_start_date inicio,
       :p_end_date fin,
       pac_hr_pay_pkg.get_payroll_short_name (payrolls.payroll_name) empresa,
       pac_hr_pay_pkg.get_employee_number (persons.person_id) numero,
       pac_hr_pay_pkg.get_person_name (SYSDATE, persons.person_id) empleado,
       persons.effective_start_date fecha_movimiento,
       'A' tipo_movimiento,
       ---Old ppp salary
       --       TRUNC (
       --          DECODE (
       --             payrolls.period_type,
       --             'Week', pac_hr_pay_pkg.GET_SALARY_PPP (
       --                        assignments.assignment_id)
       --                     / 30.4,
       --             pac_hr_pay_pkg.GET_SALARY_PPP (assignments.assignment_id) / 30),
       --          2)
       --          salario,
       PAC_PAY_MX_FF_UDFS.GET_IDW (assignments.assignment_id,
                                   TO_NUMBER (assignments.tax_organization),
                                   persons.effective_start_date,
                                   'REPORT')
          salario,
       pac_hr_pay_pkg.get_employee_ssid (persons.person_id) nss,
       pac_hr_pay_pkg.get_employee_tax_payer_id (persons.person_id) rfc,
       pac_hr_pay_pkg.get_department_number (assignments.organization_id)
          depto,
       pac_hr_pay_pkg.get_employer_registration (assignments.assignment_id)
          clave,
       pac_hr_pay_pkg.get_admission_date (persons.person_id) ingreso,
       pac_hr_pay_pkg.get_department_name (assignments.organization_id)
          departamento,
       NULL observaciones,
       pac_hr_pay_pkg.get_management_by_groupid (assignments.people_group_id)
          gerencia,
       TRUNC (
          MONTHS_BETWEEN (effective_start_date, effective_start_date) / 12)
          años,
       MOD (
          TRUNC (MONTHS_BETWEEN (effective_start_date, effective_start_date)),
          12)
          meses
  FROM (SELECT papf.employee_number,
               papf.full_name,
               papf.effective_start_date,
               papf.person_id
          FROM per_all_people_f papf
         WHERE 1 = 1
               AND papf.effective_start_date BETWEEN :p_start_date
                                                 AND :p_end_date) persons
       LEFT OUTER JOIN (SELECT UNIQUE person_id,
                                      assignment_id,
                                      payroll_id,
                                      organization_id,
                                      people_group_id,
                                      hsck.segment1 tax_organization
                          FROM per_all_assignments_f paaf,
                               hr_soft_coding_keyflex hsck
                         WHERE 1 = 1
                               AND hsck.soft_coding_keyflex_id(+) =
                                      paaf.soft_coding_keyflex_id
                               AND paaf.effective_start_date BETWEEN :p_start_date
                                                                 AND :p_end_date) assignments
          ON persons.person_id = assignments.person_id
       LEFT OUTER JOIN (SELECT payroll_id, payroll_name, period_type
                          FROM PAY_ALL_PAYROLLS_F) payrolls
          ON assignments.payroll_id = payrolls.payroll_id
 WHERE 1 = 1                                         -------------------------
            AND 'A' = NVL (:p_tipo_de_movimiento, 'A')
       -------------------- COMENTAR PARA EMPLEADOS SIN ASSIGMENT
       AND PAC_HR_PAY_PKG.get_employer_name (payrolls.payroll_name) =
              NVL (:p_employer_name,
                   PAC_HR_PAY_PKG.get_employer_name (payrolls.payroll_name))
       AND pac_hr_pay_pkg.get_employer_registration (
              assignments.assignment_id) =
              NVL (
                 :p_employer_registration,
                 pac_hr_pay_pkg.get_employer_registration (
                    assignments.assignment_id))
------------------------
UNION ALL
/*  modify*/
SELECT pac_hr_pay_pkg.get_employer_name (ppf.payroll_name) compania,
       DECODE (:p_employer_registration,
               NULL, 'TODOS',
               pac_hr_pay_pkg.get_employer_registration (paaf.assignment_id))
          reg_patro,
       NVL (:p_tipo_de_movimiento, 'TODOS') tipo_mov,
       :p_start_date inicio,
       :p_end_date fin,
       pac_hr_pay_pkg.get_payroll_short_name (ppf.payroll_name) empresa,
       pac_hr_pay_pkg.get_employee_number (papf.person_id) numero,
       pac_hr_pay_pkg.get_person_name (SYSDATE, papf.person_id) empleado,
       ppp.change_date fecha_movimiento,
       'MS' tipo_movimiento,
       --       TRUNC (
       --          DECODE (
       --             ppf.period_type,
       --             'Week', pac_hr_pay_pkg.GET_SALARY_PPP (paaf.assignment_id)
       --                     / 30.4,
       --             pac_hr_pay_pkg.GET_SALARY_PPP (paaf.assignment_id) / 30),
       --          2)
       --          salario,
       PAC_PAY_MX_FF_UDFS.GET_IDW (paaf.assignment_id,
                                   TO_NUMBER (hsck.segment1),
                                   ppp.change_date,
                                   'REPORT')
          salario,
       pac_hr_pay_pkg.get_employee_ssid (papf.person_id) nss,
       pac_hr_pay_pkg.get_employee_tax_payer_id (papf.person_id) rfc,
       pac_hr_pay_pkg.get_department_number (paaf.organization_id) depto,
       pac_hr_pay_pkg.get_employer_registration (paaf.assignment_id) clave,
       pac_hr_pay_pkg.get_admission_date (papf.person_id) ingreso,
       pac_hr_pay_pkg.get_department_name (paaf.organization_id) departamento,
       hr_general.decode_lookup ('PROPOSAL_REASON', ppp.PROPOSAL_REASON),
       pac_hr_pay_pkg.get_management_by_groupid (paaf.people_group_id)
          gerencia,
       TRUNC (MONTHS_BETWEEN (change_date, change_date) / 12) años,
       MOD (TRUNC (MONTHS_BETWEEN (change_date, change_date)), 12) meses
  FROM PER_PAY_PROPOSALS ppp,
       per_all_assignments_f paaf,
       per_all_people_f papf,
       PAY_ALL_PAYROLLS_F ppf,
       PER_PERIODS_OF_SERVICE ppos,
       hr_soft_coding_keyflex hsck
 WHERE     1 = 1
       ----------------------
       AND 'MS' = NVL (:p_tipo_de_movimiento, 'MS')
       AND ppp.change_date BETWEEN :p_start_date AND :p_end_date
       AND PAC_HR_PAY_PKG.get_employer_name (ppf.payroll_name) =
              NVL (:p_employer_name,
                   PAC_HR_PAY_PKG.get_employer_name (ppf.payroll_name))
       AND pac_hr_pay_pkg.get_employer_registration (paaf.assignment_id) =
              NVL (
                 :p_employer_registration,
                 pac_hr_pay_pkg.get_employer_registration (
                    paaf.assignment_id))
       -----------------------
       AND hsck.soft_coding_keyflex_id(+) = paaf.soft_coding_keyflex_id
       AND ppos.person_id = papf.person_id
       AND PPF.PAYROLL_ID = paaf.payroll_id
       AND ppp.assignment_id = paaf.assignment_id
       AND paaf.person_id = papf.person_id
       AND TRUNC (SYSDATE) BETWEEN paaf.effective_start_date
                               AND paaf.effective_end_date
       AND TRUNC (SYSDATE) BETWEEN papf.effective_start_date
                               AND papf.effective_end_date
ORDER BY 9;