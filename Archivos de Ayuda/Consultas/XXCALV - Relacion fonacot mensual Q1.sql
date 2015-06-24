SELECT periodos, 
       nomina, 
       employer_name,                            
       periodo per, 
       n_nom num_nomina,
       id_empleado empleado, 
       nombre_completo nombre, 
       no_credito no_credito,
       pay_value aport__mensual, 
       total_owed saldo_inicial,
       saldo_pagado aport_acu, 
       saldo_restante saldo_acum, 
       folio,
       :p_mes mes,
       :p_ano ano,
       decode(employer_name,:employer_name,employer_name,'TODAS' ) compañia2,
       decode(n_nom,:n_nom,n_nom,'TODAS' ) n_nom2
  FROM (SELECT pap.person_id, 
               paa.assignment_id,
               pap.employee_number id_empleado, 
               pap.full_name nombre_completo,
               ppb.NAME periodos, 
               papf.payroll_name nomina,
               papf.attribute1 n_nom, 
               SUBSTR (ppb.NAME, 1, 1) periodo,
               pac_hr_pay_pkg.get_employer_name(papf.payroll_name) employer_name
          FROM apps.per_all_people_f pap,
               apps.per_all_assignments_f paa,
               apps.per_pay_bases ppb,
               apps.pay_all_payrolls_f papf
         WHERE pap.person_id = paa.person_id
           AND ppb.pay_basis_id(+) = paa.pay_basis_id
           AND papf.payroll_id(+) = paa.payroll_id
           AND SYSDATE BETWEEN paa.effective_start_date AND paa.effective_end_date
           AND SYSDATE BETWEEN pap.effective_start_date AND pap.effective_end_date) ass,
       (SELECT   assignment_id, 
                 folio, 
                 no_credito, 
                 pay_value, 
                 total_owed,
                 saldo_pagado, 
                 saldo_restante, 
                 MAX (payroll_run_date),
                 :p_mes,
                 :p_ano
            FROM pac_fonacot
           WHERE mes = decode (LENGTH(:p_mes),'2',:p_mes,('0'||''||:p_mes)) 
                 AND ano = :p_ano
        GROUP BY assignment_id,
                 folio,
                 no_credito,
                 pay_value,
                 total_owed,
                 saldo_pagado,
                 saldo_restante
        ORDER BY assignment_id) fon
        --           
 WHERE ass.assignment_id = fon.assignment_id
      AND employer_name  = NVL (:employer_name , employer_name )
      AND n_nom  = NVL (:n_nom ,  n_nom)        