select decode(company,:p_company,company,'TODAS' ) company2,
       decode(periodos,:p_periodos,periodos,'TODOS' ) periodo2,
       decode(nomina,:p_nomina,nomina,'TODAS' ) nomina2,
       periodo,
       empresa nomina_ , 
       num_emp,
       nombre, 
       apellido_paterno,
       apellido_materno, 
       nss, 
       curp, 
       puesto description,
       seguro reg_patronal,  
       fecha_desde,
       fecha_mov, 
       estatus, 
       fecha_baja, 
       tipo_mov,  
       :p_start_date Desde, 
       :p_end_date Hasta
       from (
SELECT UNIQUE (per.person_id), pa.assignment_id,
              
                 pac_hr_pay_pkg.get_employer_name (pp.payroll_name) company,
                 pac_hr_pay_pkg.get_payroll_short_name (pp.payroll_name) empresa,
                 pp.payroll_name nomina, per.employee_number num_emp,
                 per.full_name nombre_completo,
                 per.last_name apellido_paterno,
                 per.per_information1 apellido_materno,
                (per.first_name || ' ' || per.middle_names) nombre,
                 SUBSTR (pa.d_position_id,
                         INSTR (pa.d_position_id, '.', 1, 2) + 1
                        ) puesto,
                 per.national_identifier curp,
                 per.per_information3 nss, (haou.NAME) reg_patronall,
                 per.effective_start_date  fecha_desde,
                 per.effective_start_date  fecha_mov,
                 ppb.NAME periodos,  
                 SUBSTR (ppb.NAME, 1, 1) periodo   ,           
                 UPPER (per.d_person_type_id) estatus,
                 pac_hr_pay_pkg.get_employer_registration
                                                    (paa.assignment_id)
                                                                       seguro,
                 pac_hr_pay_pkg.get_actual_termination_date
                                                 (pa.assignment_id)
                                                                   fecha_baja,
   DECODE (( pac_hr_pay_pkg.get_actual_termination_date     (pa.assignment_id)),
                              NULL, 'A',
                              'B'
                             ) tipo_mov
             
            FROM per_people_v7 per,
                 apps.per_all_people_f pap,
                 per_assignments_v7 pa,
                 per_all_assignments_f paa,
                 pay_payrolls_f pp,
                 per_pay_bases ppb,
                 hr_soft_coding_keyflex hsck,
                 hr_all_organization_units haou,
                 hr_organization_information hoi,
                 per_pay_proposals ps,
                 pay_people_groups ppg,
                 per_addresses_v perd,
                 per_images pi
         
           WHERE 1 = 1
             AND per.person_id = pa.person_id
             AND pap.person_id = paa.person_id
             AND per.person_id = pap.person_id
             AND pa.payroll_id = pp.payroll_id(+)
         
             AND TO_NUMBER (hsck.segment1) = haou.organization_id
             AND haou.organization_id = hoi.organization_id
             AND hoi.org_information_context = 'MX_SOC_SEC_DETAILS'
             AND pa.assignment_id = paa.assignment_id
             AND pa.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
             AND pa.assignment_id = ps.assignment_id(+)
             AND ppg.people_group_id(+) = pa.people_group_id
             AND per.person_id = perd.person_id(+)
             AND per.person_id = pi.parent_id(+)
             AND ppb.pay_basis_id(+) = pa.pay_basis_id
             AND TRUNC (SYSDATE) BETWEEN TRUNC (SYSDATE)
                                     AND NVL (TRUNC (ps.date_to),
                                              TRUNC (SYSDATE)
                                             )
             AND SYSDATE BETWEEN pa.effective_start_date AND pa.effective_end_date
             AND SYSDATE BETWEEN per.effective_start_date
                             AND per.effective_end_date
             -- and per.person_id = 1560
             AND pp.payroll_name IS NOT NULL
        ORDER BY per.employee_number ASC)
        
        WHERE 1 = 1
 AND TRUNC (fecha_desde) BETWEEN NVL (
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                             :p_start_date,
                                                                             'RRRR /MM/DD HH24:MI:SS')),
                                                                       TRUNC (
                                                                          fecha_desde))
                                                                AND NVL (
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                             :p_end_date,
                                                                             'RRRR /MM/DD HH24:MI:SS')),
                                                                       TRUNC (
                                                                          fecha_desde))
                                                          
 and company = NVL (:p_company, company)
 and periodos = NVL (:p_periodos, periodos)
 and nomina = NVL (:p_nomina, nomina)
 and num_emp = NVL (:p_num_emp, num_emp)
 and company = NVL (:p_company, company)