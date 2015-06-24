CREATE OR REPLACE FORCE VIEW apps.pac_employee_act_v (person_id,
                                                      assignment_id,
                                                      ano,
                                                      empresa,
                                                      nomina,
                                                      id_empleado,
                                                      nombre_completo,
                                                      apellido_paterno,
                                                      apellido_materno,
                                                      nombres,
                                                      segundo_nombre,
                                                      calle,
                                                      num_ext,
                                                      num_int,
                                                      colonia,
                                                      delegacion_o_municipio,
                                                      localidad_o_poblacion,
                                                      estado,
                                                      pais,
                                                      codigo_postal,
                                                      telefono,
                                                      sexo,
                                                      nacionalidad,
                                                      lug_nacimiento,
                                                      fecha_nac,
                                                      nivel_de_estudios,
                                                      t_contrato,
                                                      terminacion,
                                                      n_gerencia,
                                                      gerencia,
                                                      n_area,
                                                      area,
                                                      num_departamento,
                                                      departamento,
                                                      puesto,
                                                      trabajo,
                                                      turno,
                                                      sind,
                                                      rfc,
                                                      curp,
                                                      nss,
                                                      delegacion_imss,
                                                      sub_delegacion_imss,
                                                      uni_med_fam,
                                                      seguro,
                                                      sueldo_base,
                                                      s_d_i,
                                                      reg_patronal,
                                                      periodo,
                                                      bono_despensa,
                                                      afore,
                                                      correo_e,
                                                      estado_civil,
                                                      regimen_matrimonial,
                                                      estatus,
                                                      fecha_baja,
                                                      unic_ingreso,
                                                      fecha_alta_cia,
                                                      fecha_alta_imss,
                                                      no_cuenta_despensa,
                                                      no_targeta_desp,
                                                      tp_pago_despensa,
                                                      metodo_pago_desp,
                                                      cuenta_pago,
                                                      banco_pago,
                                                      targeta_pago,
                                                      tipo_pago,
                                                      cuenta_pension_a,
                                                      banco_pension,
                                                      tipo_pago_pension,
                                                      porcentaje_pension,
                                                      monto_pension,
                                                      no_cred_inf,
                                                      fecha_cred_inf,
                                                      tipo_descuento_inf,
                                                      valor_descuento_inf,
                                                      saldo_inicial_inf,
                                                      saldo_actual_inf
                                                     )
AS
   SELECT empl.person_id, empl1.assignment_id, ano, empresa, nomina,
          id_empleado, nombre_completo, apellido_paterno, apellido_materno,
          nombres, segundo_nombre, calle, num_ext, num_int, colonia,
          delegacion_o_municipio, localidad_o_poblacion, estado, pais,
          codigo_postal, telefono, sexo, nacionalidad, lug_nacimiento,
          fecha_nac, nivel_de_estudios, t_contrato, terminacion, n_gerencia,
          gerencia, n_area, area, num_departamento, departamento, puesto,
          trabajo, turno, sind, rfc, curp, nss, delegacion_imss,
          sub_delegacion_imss, uni_med_fam, seguro, sueldo_base, s_d_i,
          reg_patronal, periodo, bono_despensa, afore, correo_e, estado_civil,
          regimen_matrimonial, estatus, fecha_baja, 'SI' unic_ingreso,
          CASE
             WHEN empl.person_type_id IN
                            ('Ex-empleado', 'Ex-employee')
                THEN ini.initial_date
             WHEN empl.person_type_id NOT IN
                            ('Ex-empleado', 'Ex-employee')
                THEN (TO_CHAR (empl.effective_start_date, 'dd/mm/yyyy')
                     )
          END AS fecha_alta_cia,
          CASE
             WHEN empl.person_type_id IN
                           ('Ex-empleado', 'Ex-employee')
                THEN ini.initial_date
             WHEN empl.person_type_id NOT IN
                           ('Ex-empleado', 'Ex-employee')
                THEN (TO_CHAR (empl.effective_start_date, 'dd/mm/yyyy')
                     )
          END AS fecha_alta_imss,
          REPLACE (REPLACE (desp.n_cuenta_dep, CHR (13), ''),
                   CHR (10),
                   ''
                  ) no_cuenta_despensa,
          REPLACE (REPLACE (desp.n_targ_dep, CHR (13), ''),
                   CHR (10),
                   ''
                  ) no_targeta_desp,
          NVL (UPPER (desp.met_pago_desp), 'EFECTIVO') tp_pago_despensa,
          desp.banco_despensa metodo_pago_desp,
          pago.n_cuenta_pago cuenta_pago, pago.banco_pago banco_pago,
          pago.n_targ_pag targeta_pago,
          NVL (UPPER (pago.tipo_pag), 'EFECTIVO') tipo_pago,
          pensio.n_cuenta_pension cuenta_pension_a, pensio.banco_pension,
          pensio.tipo_pension tipo_pago_pension,
          inf.porcentaje_pension porcentaje_pension,
          inf.monto_pension monto_pension, inf.no_cred_infonavit no_cred_inf,
          SUBSTR (inf.fecha_infonavit,
                  1,
                  INSTR (inf.fecha_infonavit, ' ', 1, 1) - 1
                 ) fecha_cred_inf,
          DECODE (NVL (inf.tipo_infonavit, ''),
                  '2', 'CUOTA FIJA',
                  '1', 'PORCENTAJE',
                  '3', 'VECES',
                  ''
                 ) tipo_descuento_inf,
          inf.valor_infonavit valor_descuento_inf,
          inf.saldo_inicial_inf saldo_inicial_inf,
          inf.saldo_actual_inf saldo_actual_inf
     FROM (SELECT UNIQUE (per.person_id), pa.assignment_id,
                         TO_CHAR (per.effective_start_date, 'YYYY') ano,
                         per.employee_number id_empleado,
                         per.d_person_type_id person_type_id,
                         per.effective_start_date effective_start_date,
                         per.full_name nombre_completo,
                         per.last_name apellido_paterno,
                         per.per_information1 apellido_materno,
                         per.first_name nombres,
                         per.middle_names segundo_nombre,
                         UPPER
                            (apps.hr_general.decode_lookup ('NATIONALITY',
                                                            per.nationality
                                                           )
                            ) nacionalidad,
                         per.date_of_birth fecha_nac,
                         DECODE (per.sex, 'M', 'MASCULINO', 'FEMENINO') sexo,
                         UPPER (per.attribute10) nivel_de_estudios,
                         per.per_information2 rfc,
                         per.national_identifier curp,
                         per.per_information3 nss,
                         UPPER (per.email_address) correo_e,
                         UPPER
                            (apps.hr_general.decode_lookup ('MAR_STATUS',
                                                            per.marital_status
                                                           )
                            ) estado_civil,
                         per.attribute5 regimen_matrimonial,
                         UPPER (per.d_person_type_id) estatus,  --datos en per
                         UPPER
                            (DECODE
                                (pa.assignment_type,
                                 'E', apps.hr_general.decode_lookup
                                                       ('EMP_CAT',
                                                        pa.employment_category
                                                       ),
                                 'C', apps.hr_general.decode_lookup
                                                       ('CWK_ASG_CATEGORY',
                                                        pa.employment_category
                                                       )
                                )
                            ) t_contrato,
                         SUBSTR (pa.ass_attribute1,
                                 1,
                                 INSTR (pa.ass_attribute1, ' ', 1, 1) - 1
                                ) terminacion,
                         LTRIM
                            (SUBSTR (pa.d_organization_id,
                                     1,
                                       INSTR (pa.d_organization_id, ' ', 1, 1)
                                     - 1
                                    ),
                             'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
                            ) num_departamento,
                         UPPER (LTRIM (pa.d_organization_id, '1234567890-')
                               ) departamento,
                         SUBSTR (pa.d_position_id,
                                 INSTR (pa.d_position_id, '.', 1, 2) + 1
                                ) puesto,
                         pa.d_job_id trabajo, pa.ass_attribute30 turno,
                         ROUND
                            ((  (pac_hr_pay_pkg.get_salary (pa.pay_basis_id,
                                                            pa.assignment_id
                                                           )
                                )
                              / 30
                             ),
                             2
                            ) sueldo_base,
                         UPPER (pa.ass_attribute20) bono_despensa,
                         UPPER (pa.ass_attribute10) afore,
                         pac_hr_pay_pkg.get_actual_termination_date
                                                 (pa.assignment_id)
                                                                   fecha_baja,
                         NVL
                            (DECODE
                                ((pac_pay_mx_ff_udfs.get_idw
                                                    (pa.assignment_id,
                                                     TO_NUMBER (hsck.segment1),
                                                     per.effective_start_date,
                                                     'REPORT'
                                                    )
                                 ),
                                 '0', pac_hr_pay_pkg.get_diary_salary
                                                                (per.person_id),
                                 (pac_pay_mx_ff_udfs.get_idw
                                                    (pa.assignment_id,
                                                     TO_NUMBER (hsck.segment1),
                                                     per.effective_start_date,
                                                     'REPORT'
                                                    )
                                 )
                                ),
                             '0'
                            ) s_d_i,
                         
                         --  datos de  pa
                         pac_hr_pay_pkg.get_employer_name
                                                     (pp.payroll_name)
                                                                      empresa,
                         pp.payroll_name nomina, ppb.NAME periodo,
                         
                         --datos de pp
                         perd.address_line1 calle,
                         perd.addr_attribute2 num_ext,
                         perd.addr_attribute1 num_int,
                         perd.address_line2 colonia,
                         perd.region_2 delegacion_o_municipio,
                         perd.town_or_city localidad_o_poblacion,
                         UPPER ((SELECT flv.meaning
                                   FROM fnd_lookup_values flv
                                  WHERE flv.lookup_type = 'PER_MX_STATE_CODES'
                                    AND flv.LANGUAGE = USERENV ('LANG')
                                    AND flv.lookup_code = perd.region_1)
                               ) estado,
                         UPPER ((SELECT territory_short_name
                                   FROM fnd_territories_vl
                                  WHERE territory_code = perd.country)) pais,
                         perd.postal_code codigo_postal,
                         perd.telephone_number_1 telefono
                    FROM per_people_v7 per,
                         per_pay_bases ppb,
                         hr_soft_coding_keyflex hsck,
                         pay_payrolls_f pp,
                         per_assignments_v7 pa,
                         per_addresses_v perd
                   WHERE 1 = 1                    --per.employee_number = 1597
                     AND per.person_id = pa.person_id
                     AND ppb.pay_basis_id(+) = pa.pay_basis_id
                     AND hsck.soft_coding_keyflex_id(+) =
                                                     pa.soft_coding_keyflex_id
                     AND pa.payroll_id = pp.payroll_id(+)
                     AND per.person_id = perd.person_id(+)
                     AND pp.payroll_name IS NOT NULL
                     AND SYSDATE BETWEEN pa.effective_start_date
                                     AND pa.effective_end_date
                     AND SYSDATE BETWEEN per.effective_start_date
                                     AND per.effective_end_date
                ORDER BY per.employee_number ASC) empl,
          (SELECT UNIQUE (pap.person_id) person_id, paa.assignment_id,
                         pap.region_of_birth lug_nacimiento,
                         pap.attribute15 delegacion_imss,
                         pap.attribute20 sub_delegacion_imss,
                         pap.per_information4 uni_med_fam,
                         UPPER
                            (apps.hr_general.decode_lookup
                                                        ('EMPLOYEE_CATG',
                                                         paa.employee_category
                                                        )
                            ) sind,
                         pac_hr_pay_pkg.get_employer_registration
                                              (paa.assignment_id)
                                                                 reg_patronal,
                         (haou.NAME) seguro, ppg.segment2 n_gerencia,
                         DECODE
                            (ppg.segment2,
                             NULL, '',
                             (pac_hr_pay_pkg.get_management (ppg.segment2)
                             )
                            ) gerencia,
                         ppg.segment1 n_area,
                         DECODE (ppg.segment1,
                                 NULL, '',
                                 (pac_hr_pay_pkg.get_area (ppg.segment1)
                                 )
                                ) area
                    FROM apps.per_all_people_f pap,
                         apps.per_all_assignments_f paa,
                         hr_soft_coding_keyflex hsck,
                         per_pay_proposals ps,
                         hr_all_organization_units haou,
                         hr_organization_information hoi,
                         pay_people_groups ppg
                   WHERE 1 = 1
                     AND pap.person_id = paa.person_id
                     AND paa.people_group_id = ppg.people_group_id(+)
                     AND hsck.soft_coding_keyflex_id(+) =
                                                    paa.soft_coding_keyflex_id
                     AND TO_NUMBER (hsck.segment1) = haou.organization_id
                     AND haou.organization_id = hoi.organization_id
                     AND hoi.org_information_context = 'MX_SOC_SEC_DETAILS'
                     AND paa.assignment_id = ps.assignment_id(+)
                     AND SYSDATE BETWEEN paa.effective_start_date
                                     AND paa.effective_end_date
                     AND SYSDATE BETWEEN pap.effective_start_date
                                     AND pap.effective_end_date) empl1,
          
          ---
          (SELECT initial_date, assignment_id
             FROM (SELECT UNIQUE (paaf.assignment_id) assignment_id,
                                 TO_CHAR (date_start) AS initial_date,
                                 paaf.last_update_date paaf_update_date,
                                 ppt.user_person_type
                            FROM per_all_people_f papf,
                                 per_all_assignments_f paaf,
                                 per_periods_of_service pps,
                                 hr.per_person_type_usages_f pptu,
                                 hr.per_person_types ppt
                           WHERE paaf.person_id = papf.person_id
                             AND paaf.primary_flag = 'Y'
                             AND paaf.assignment_type != 'B'
                             AND papf.person_id = pptu.person_id
                             AND papf.person_type_id = pptu.person_type_id
                             AND pptu.person_type_id = ppt.person_type_id
                             AND papf.person_type_id = ppt.person_type_id
                             AND papf.business_group_id =
                                                         ppt.business_group_id
                             AND paaf.period_of_service_id =
                                                      pps.period_of_service_id
                             AND papf.person_id = pps.person_id
                             AND pps.actual_termination_date IS NOT NULL
                             AND ppt.user_person_type IN
                                               ('Ex-empleado', 'ex-employee')
                        ORDER BY paaf.assignment_id ASC) emp,
                  
                  ----
                  (SELECT   paaf.assignment_id assignment_idd,
                            MAX (paaf.last_update_date) paaf_update_date
                       FROM per_all_people_f papf,
                            per_all_assignments_f paaf,
                            per_periods_of_service pps,
                            hr.per_person_type_usages_f pptu,
                            hr.per_person_types ppt
                      WHERE paaf.person_id = papf.person_id
                        AND paaf.primary_flag = 'Y'
                        AND paaf.assignment_type != 'B'
                        AND papf.person_id = pptu.person_id
                        AND papf.person_type_id = pptu.person_type_id
                        AND pptu.person_type_id = ppt.person_type_id
                        AND papf.person_type_id = ppt.person_type_id
                        AND papf.business_group_id = ppt.business_group_id
                        AND paaf.period_of_service_id =
                                                      pps.period_of_service_id
                        AND papf.person_id = pps.person_id
                        AND pps.actual_termination_date IS NOT NULL
                        AND ppt.user_person_type IN
                                               ('Ex-empleado', 'ex-employee')
                   GROUP BY paaf.assignment_id
                   ORDER BY paaf.assignment_id ASC) maxf
            WHERE maxf.assignment_idd = emp.assignment_id
              AND maxf.paaf_update_date = emp.paaf_update_date) ini,
          
          ---
          (SELECT UNIQUE (paf.assignment_id) desp_assignment_id,
                         pppm.attribute1 n_targ_dep,
                         SUBSTR
                            (popm.org_payment_method_name,
                               INSTR (popm.org_payment_method_name, '-', 1, 1)
                             + 1
                            ) banco_despensa,
                         pea.segment3 n_cuenta_dep,
                         popm.org_payment_method_name tipo_desp,
                         CASE
                            WHEN pptv.payment_type_name IN
                                   ('Cash', 'Mexican Cash',
                                    'Efectivo')
                               THEN 'EFECTIVO'
                            WHEN pptv.payment_type_name IN
                                   ('Cheque',
                                    'Mexican Cheque',
                                    'Cheque')
                               THEN 'EFECTIVO'
                            WHEN pptv.payment_type_name IN
                                   ('Direct Deposit',
                                    'Deposito Directo',
                                    'Mexican Direct Deposit',
                                    'Deposito Directo')
                               THEN 'DEPOSITO DIRECTO'
                         END AS met_pago_desp
                    FROM pay_personal_payment_methods_f pppm,
                         pay_external_accounts pea,
                         pay_payment_types pptv,
                         per_all_assignments_f paf,
                         pay_org_payment_methods_f popm
                   WHERE 1 = 1
                     AND pppm.assignment_id(+) = paf.assignment_id
                     AND pppm.external_account_id = pea.external_account_id(+)
                     AND popm.org_payment_method_id =
                                                    pppm.org_payment_method_id
                     AND pptv.territory_code = 'MX'
                     AND pptv.payment_type_id = popm.payment_type_id
                     AND REGEXP_LIKE (popm.org_payment_method_name,
                                      'DESPENSA|EFECTIVALE'
                                     )
                     AND pppm.object_version_number =
                            (SELECT MAX (pppm1.object_version_number)
                               FROM pay_personal_payment_methods_f pppm1
                              WHERE pppm1.personal_payment_method_id =
                                               pppm.personal_payment_method_id)
                     AND PPPM.EFFECTIVE_END_DATE > SYSDATE) desp,
          (SELECT UNIQUE (paf.assignment_id) metp_assignment_id,
                         pppm.attribute1 n_targ_pag,
                         SUBSTR
                            (popm.org_payment_method_name,
                               INSTR (popm.org_payment_method_name, '-', 1, 1)
                             + 1
                            ) banco_pago,
                         pea.segment3 n_cuenta_pago,
                         popm.org_payment_method_name forma_pago,
                         CASE
                            WHEN pptv.payment_type_name IN
                                   ('Cash', 'Mexican Cash',
                                    'Efectivo')
                               THEN 'EFECTIVO'
                            WHEN pptv.payment_type_name IN
                                   ('Cheque', 'Mexican Cheque',
                                    'Cheque')
                               THEN 'CHEQUE'
                            WHEN pptv.payment_type_name IN
                                   ('Direct Deposit',
                                    'Deposito Directo',
                                    'Mexican Direct Deposit',
                                    'Deposito Directo')
                               THEN 'DEPOSITO DIRECTO'
                         END AS tipo_pag
                    FROM pay_personal_payment_methods_f pppm,
                         pay_external_accounts pea,
                         pay_payment_types pptv,
                         per_all_assignments_f paf,
                         pay_org_payment_methods_f popm
                   WHERE 1 = 1
                     AND pppm.assignment_id(+) = paf.assignment_id
                     AND pppm.external_account_id = pea.external_account_id(+)
                     AND popm.org_payment_method_id =
                                                    pppm.org_payment_method_id
                     AND pptv.territory_code = 'MX'
                     AND pptv.payment_type_id = popm.payment_type_id
                     AND NOT REGEXP_LIKE (popm.org_payment_method_name,
                                          'DESPENSA|EFECTIVALE|PENSIONES'
                                         )
                     AND pppm.object_version_number =
                            (SELECT MAX (pppm1.object_version_number)
                               FROM pay_personal_payment_methods_f pppm1
                              WHERE pppm1.personal_payment_method_id =
                                               pppm.personal_payment_method_id)
                     AND PPPM.EFFECTIVE_END_DATE > SYSDATE) pago,
          
          ---
          (SELECT UNIQUE (paf.assignment_id) pens_assignment_id,
                         pppm.attribute1 n_targ_pens,
                         SUBSTR
                            (popm.org_payment_method_name,
                               INSTR (popm.org_payment_method_name, '-', 1, 1)
                             + 1
                            ) banco_pension,
                         pea.segment3 n_cuenta_pension,
                         popm.org_payment_method_name forma_pago_pension,
                         CASE
                            WHEN pptv.payment_type_name IN
                                   ('Cash', 'Mexican Cash',
                                    'Efectivo')
                               THEN 'EFECTIVO'
                            WHEN pptv.payment_type_name IN
                                   ('Cheque',
                                    'Mexican Cheque',
                                    'Cheque')
                               THEN 'CHEQUE'
                            WHEN pptv.payment_type_name IN
                                   ('Direct Deposit',
                                    'Deposito Directo',
                                    'Mexican Direct Deposit',
                                    'Deposito Directo')
                               THEN 'DEPOSITO DIRECTO'
                         END AS tipo_pension
                    FROM pay_personal_payment_methods_f pppm,
                         pay_external_accounts pea,
                         pay_payment_types pptv,
                         per_all_assignments_f paf,
                         pay_org_payment_methods_f popm
                   WHERE 1 = 1
                     AND pppm.assignment_id(+) = paf.assignment_id
                     AND pppm.external_account_id = pea.external_account_id(+)
                     AND popm.org_payment_method_id =
                                                    pppm.org_payment_method_id
                     AND pptv.territory_code = 'MX'
                     AND pptv.payment_type_id = popm.payment_type_id
                     AND REGEXP_LIKE (popm.org_payment_method_name,
                                      'PENSIONES'
                                     )
                     AND pppm.object_version_number =
                            (SELECT MAX (pppm1.object_version_number)
                               FROM pay_personal_payment_methods_f pppm1
                              WHERE pppm1.personal_payment_method_id =
                                               pppm.personal_payment_method_id)) pensio,
          
          --
          (SELECT UNIQUE (asg.assignment_id) inf_assignment_id,
                         MAX
                            (CASE
                                WHEN pet.element_name = 'D058_INFONAVIT'
                                AND piv.NAME = 'Credit Number'
                                   THEN peev.screen_entry_value
                             END
                            ) no_cred_infonavit,
                         MAX
                            (CASE
                                WHEN pet.element_name = 'D058_INFONAVIT'
                                AND piv.NAME = 'Credit Grant Date'
                                   THEN peev.screen_entry_value
                             END
                            ) fecha_infonavit,
                         MAX
                            (CASE
                                WHEN pet.element_name = 'D058_INFONAVIT'
                                AND piv.NAME = 'Discount Type'
                                   THEN peev.screen_entry_value
                             END
                            ) tipo_infonavit,
                         MAX
                            (CASE
                                WHEN pet.element_name = 'D058_INFONAVIT'
                                AND piv.NAME = 'Discount Value'
                                   THEN peev.screen_entry_value
                             END
                            ) valor_infonavit,
                         MAX
                            (CASE
                                WHEN pet.element_name = 'D058_INFONAVIT'
                                AND piv.NAME = 'Saldo Inicial'
                                   THEN peev.screen_entry_value
                             END
                            ) saldo_inicial_inf,
                         MAX
                            (CASE
                                WHEN pet.element_name = 'D058_INFONAVIT'
                                AND piv.NAME = 'Saldo Actual'
                                   THEN peev.screen_entry_value
                             END
                            ) saldo_actual_inf,
                         MAX
                            (CASE
                                WHEN pet.element_name =
                                                      'D076_DESC_PENSION_ALIM'
                                AND piv.NAME = 'Porcentaje'
                                   THEN peev.screen_entry_value
                             END
                            ) porcentaje_pension,
                         MAX
                            (CASE
                                WHEN pet.element_name =
                                                      'D076_DESC_PENSION_ALIM'
                                AND piv.NAME = 'Amount'
                                   THEN peev.screen_entry_value
                             END
                            ) monto_pension
                    FROM pay_element_entry_values_f peev,
                         pay_element_entries_f pee,
                         pay_element_links_f pel,
                         pay_input_values_f piv,
                         pay_element_types_f pet,
                         per_all_assignments_f asg
                   WHERE asg.assignment_id = pee.assignment_id
                     AND pet.element_name IN
                                 ('D058_INFONAVIT', 'D076_DESC_PENSION_ALIM')
                     AND pee.element_link_id = pel.element_link_id
                     AND pel.element_type_id = pet.element_type_id
                     AND pee.element_entry_id = peev.element_entry_id
                     AND peev.input_value_id + 0 = piv.input_value_id
                     AND TRUNC (SYSDATE) BETWEEN piv.effective_start_date
                                             AND piv.effective_end_date
                     AND TRUNC (SYSDATE) BETWEEN pee.effective_start_date
                                             AND pee.effective_end_date
                     AND TRUNC (SYSDATE) BETWEEN peev.effective_start_date
                                             AND peev.effective_end_date
                     AND TRUNC (SYSDATE) BETWEEN asg.effective_start_date
                                             AND asg.effective_end_date
                GROUP BY asg.assignment_id
                ORDER BY asg.assignment_id ASC) inf
    WHERE 1 = 1
      AND empl.person_id = empl1.person_id
      AND empl1.assignment_id = desp.desp_assignment_id(+)
      AND empl1.assignment_id = pago.metp_assignment_id(+)
      AND empl1.assignment_id = pensio.pens_assignment_id(+)
      AND empl1.assignment_id = inf.inf_assignment_id(+)
      -- AND empl.id_empleado in ('70','106','192','496','644','1528','1597')
      AND empl1.assignment_id = ini.assignment_id(+);
