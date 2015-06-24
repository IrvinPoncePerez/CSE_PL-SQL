select  decode(empresa,:p_empresa,empresa,'TODAS' ) empresa2,
        decode(periodo,:p_periodo,periodo,'TODOS' ) periodo2,
        decode(nomina,:p_nomina,nomina,'TODAS' ) nomina2,
        decode(departamento,:p_departamento,departamento,'TODOS' ) departamento2,
        decode(empleado,:p_empleado,empleado,'TODOS' ) empleado2,
        decode(tipo_incap,:p_tipo_incap,tipo_incap,'TODOS' ) tipo_incap2,
        :p_start_date Fecha_Inicial ,
        :p_end_date Fecha_Final,
        empresa,
        periodo,
        per,
        nomina,
        departamento,
        numero,
        empleado,
        sindic,
        fecha_ingreso,
        tipo_incap,
        fecha_ini,
        fecha_fin,
        dias,
        desc_incap,
        desc_control,
        desc_riesgo,
        desc_secuela,
        reg_patronal 
        FROM (
SELECT UNIQUE (per.person_id), 
              pa.assignment_id,
              pac_hr_pay_pkg.get_employer_name (pp.payroll_name) empresa,
              ppb.NAME periodo, 
              SUBSTR (ppb.NAME, 1, 1) per,
              pp.payroll_name nomina, 
              pa.d_organization_id departamento,
              per.employee_number numero,
              (   per.last_name
               || ' '
               || per.per_information1
               || ' '
               || per.first_name
               || ' '
               || per.middle_names
              ) empleado,
              UPPER
                 (apps.hr_general.decode_lookup ('EMPLOYEE_CATG',
                                                 paa.employee_category
                                                )
                 ) sindic,
              per.effective_start_date fecha_ingreso,
              aba.c_type_desc tipo_incap, 
              aba.date_start fecha_ini,
              aba.date_end fecha_fin, 
              aba.absence_days dias,
              
--              UPPER( SUBSTR (hr_general.decode_lookup ('DISABILITY_CATEGORY',
--                                            dis.CATEGORY
--                                           ),
--                  1,
--                  80
--                 ))Tipo_Incap2,
              dis.registration_id fol_inc,
                                          -- dis.dis_information1,
              UPPER (ds.meaning) desc_incap,
              UPPER (hd.meaning) desc_control,
              UPPER (incc.meaning) desc_riesgo,
              UPPER (con.meaning) desc_secuela,
              
              -- (haou.NAME) Reg_patronal,
              pac_hr_pay_pkg.get_employer_registration
                                              (paa.assignment_id)
                                                                 reg_patronal
         FROM per_disabilities_f dis,
              per_absence_attendances_v aba,
              per_people_v7 per,
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
              per_work_incidents inc,
              per_medical_assessments mea,
              (SELECT hdc.lookup_code, hdc.meaning
                 FROM fnd_lookup_values hdc
                WHERE 1 = 1
                  AND hdc.lookup_type = 'HR_MX_DISABILITY_CONTROL'
                  AND hdc.LANGUAGE = 'ESA'
                  AND hdc.enabled_flag = 'Y') hd,
              (SELECT cons.lookup_code, cons.meaning
                 FROM fnd_lookup_values cons
                WHERE 1 = 1
                  AND cons.lookup_type = 'HR_MX_DISABILITY_CONSEQUENCE'
                  AND cons.LANGUAGE = 'ESA'
                  AND cons.enabled_flag = 'Y') con,
              (SELECT ccp.lookup_code, ccp.meaning
                 FROM fnd_lookup_values ccp
                WHERE 1 = 1
                  AND ccp.lookup_type = 'MX_DISABILITIES'
                  AND ccp.LANGUAGE = 'ESA'
                  AND ccp.enabled_flag = 'Y') ds,
              (SELECT ccp.lookup_code, ccp.meaning
                 FROM fnd_lookup_values ccp
                WHERE 1 = 1
                  AND ccp.lookup_type = 'MX_WORK_RISKS'
                  AND ccp.LANGUAGE = 'ESA'
                  AND ccp.enabled_flag = 'Y') incc
        WHERE 1 = 1
          AND per.person_id = pa.person_id
          AND pap.person_id = paa.person_id
          AND aba.person_id(+) = per.person_id
          AND per.person_id = pap.person_id
          AND pa.payroll_id = pp.payroll_id(+)
          AND dis.person_id = per.person_id
          AND dis.incident_id = inc.incident_id(+)
          AND dis.dis_information5 = hd.lookup_code(+)
          AND dis.dis_information4 = con.lookup_code(+)
          AND dis.dis_information3 = ds.lookup_code(+)
          AND dis.disability_id = mea.disability_id(+)
          AND inc.inc_information1 = incc.lookup_code(+)
          AND TO_NUMBER (hsck.segment1) = haou.organization_id
          AND haou.organization_id = hoi.organization_id
            AND aba.c_type_desc IN ('INCAPACIDAD GENERAL','INCAPACIDAD POR MATERNIDAD','INCAPACIDAD RIESGO DE TRABAJO' )
          AND hoi.org_information_context = 'MX_SOC_SEC_DETAILS'
          AND pa.assignment_id = paa.assignment_id
          AND pa.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
          AND pa.assignment_id = ps.assignment_id(+)
          AND ppg.people_group_id(+) = pa.people_group_id
          AND ppb.pay_basis_id(+) = pa.pay_basis_id
          AND TRUNC (SYSDATE) BETWEEN TRUNC (SYSDATE)
                                  AND NVL (TRUNC (ps.date_to),
                                           TRUNC (SYSDATE))
          AND SYSDATE BETWEEN pa.effective_start_date AND pa.effective_end_date
          AND SYSDATE BETWEEN per.effective_start_date AND per.effective_end_date
          -- and per.person_id = 1560
          AND pp.payroll_name IS NOT NULL
     ORDER BY per.employee_number ASC)
    where 1=1
        AND empresa = NVL(:p_empresa,empresa)
        AND periodo = NVL(:p_periodo,periodo)
        AND nomina = NVL(:p_nomina,nomina)
        AND departamento= NVL(:p_departamento,departamento)
        AND empleado = NVL(:p_empleado,empleado)
        AND tipo_incap = NVL(:p_tipo_incap,tipo_incap)
       -- AND fecha_ini BETWEEN (:p_fecha_ini)
         AND TRUNC (fecha_ini) BETWEEN NVL (
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                             :p_start_date,
                                                                             'RRRR /MM/DD HH24:MI:SS')),
                                                                       TRUNC (
                                                                          fecha_ini))
                                                                AND NVL (
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                             :p_end_date,
                                                                             'RRRR /MM/DD HH24:MI:SS')),
                                                                       TRUNC (
                                                                          fecha_ini))
          AND TRUNC (fecha_fin) BETWEEN NVL (
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                             :p_start_date,
                                                                             'RRRR /MM/DD HH24:MI:SS')),
                                                                       TRUNC (
                                                                          fecha_fin))
                                                                AND NVL (
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                             :p_end_date,
                                                                             'RRRR /MM/DD HH24:MI:SS')),
                                                                       TRUNC (
                                                                          fecha_fin))