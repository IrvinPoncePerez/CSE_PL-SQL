  SELECT cmp.meaning company,
             hpv.d_organization_id, 
             hpv.payroll_name,
             hpv.person_id, 
             hpv.employee_number, 
             hpv.full_name, 
             ppp.value, 
             pac_hr_pay_pkg.get_period_type (hpv.payroll_name) period_type,
             paa.period_name,
             ppp.payment_type_name
        FROM pay_payroll_actions pac1,
             pay_assignment_actions_v paa,
             pay_pre_payments_v ppp,
             fnd_lookup_values cmp,
             xxcalv_hr_pay_employees_v hpv
       WHERE 1=1 --ppp.business_group_id = 82
         AND hpv.payroll_id = pac1.payroll_id
         AND pac1.payroll_action_id = paa.payroll_action_id
         AND paa.assignment_action_id = ppp.assignment_action_id
         AND paa.assignment_number = hpv.employee_number
         AND paa.action_type IN ('U','P')
         AND cmp.lookup_type = 'NOMINAS POR EMPLEADOR LEGAL'
         AND cmp.lookup_code = substr(hpv.payroll_name,1,2)
         AND cmp.LANGUAGE = userenv('LANG')
         AND upper(ppp.payment_type_name) IN ('CASH','EFECTIVO')
         --AND to_date(substr(paa.period_name,1,instr(paa.period_name,' ', 1, 1)),'DD-MON-RRRR') = :p_start_date
         --AND to_date(substr(paa.period_name, instr(paa.period_name,' ', 1, 2), length(paa.period_name)),'DD-MON-RRRR') = :p_end_date
         --AND pac_hr_pay_pkg.get_period_type (hpv.payroll_name) = :p_period_type
         --AND hpv.payroll_id = :p_payroll_id
         --AND hpv.organization_id = :p_organization_id
         AND to_date(substr(paa.period_name,1,instr(paa.period_name,' ', 1, 1)),'DD-MON-RRRR') >= :p_start_date
         AND to_date(substr(paa.period_name, instr(paa.period_name,' ', 1, 2), length(paa.period_name)),'DD-MON-RRRR') <= :p_end_date
         AND pac_hr_pay_pkg.get_period_type (hpv.payroll_name) = NVL(:p_period_type, pac_hr_pay_pkg.get_period_type (hpv.payroll_name))
         AND hpv.payroll_id = NVL(:p_payroll_id, hpv.payroll_id)
         AND hpv.organization_id = NVL(:p_organization_id, hpv.organization_id)         
    ORDER BY ppp.pre_payment_id;  