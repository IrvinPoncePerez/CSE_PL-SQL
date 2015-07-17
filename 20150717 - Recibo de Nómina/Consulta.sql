SELECT EMPRESA
      ,RFC_COMP
      ,periodo 
      ,num_nom
      ,METODO_PAGO
      ,empleado
      ,nom_empl
      ,rfc_empl
      ,NSS
      ,regpatr
      ,CURP
      ,SUM(basecotiz)basecotiz
      ,tiposalario
      ,turno
      ,nomina
      ,depto
      ,puesto
      ,payroll_id
      ,rownum recibo
      ,SUM(salario_diario) salario_diario
      ,SUM(diatrab) diatrab
      ,fechaimpr
      ,SUM(fondoahorro) fondoahorro
      --,XXSTO_TOOLS_PKG.Redondea_Decimales( SUM(netopagarempl), 1) netopagarempl
      ,period_name
      ,time_period_id 
      ,person_id
      ,SUM(bonoempl) bonoempl
      ,SUM(bono1empl)bono1empl
      --,SUM(netopagarempr) netopagarempr
      ,fecha
      ,SUM(bonoempr) bonoempr
      ,SUM(bono2empr)bono2empr
      ,:P_ANEXO ANEXOSINO 
      ,anexoempr
      ,textoanexo
      ,row_number() OVER (PARTITION BY payroll_id ORDER BY payroll_id DESC) folio
      ,periodo2
      ,fechaimpr2
      ,depto2
      ,nombre2
      ,assignment_id 
      ,assignment_action_id
      ,metodo_pago_bono
      ,base_salario
FROM (SELECT   --- encabezado
           ( SELECT hroi.org_information1
               FROM hr_organization_units_v  hrou
                       ,hr_organization_information_v  hroi
                      ,fnd_lookup_values_vl flvv
             WHERE 1=1
                 AND hrou.organization_id     = hroi.organization_id
                 AND hroi.org_information_context   = 'MX_TAX_REGISTRATION'
                 AND flvv.lookup_type                     = 'NOMINAS POR EMPLEADOR LEGAL'
                 AND flvv.meaning                          = hrou.name
                 AND flvv.lookup_code                    = SUBSTR(pro.payroll_name,1,2) --'02'
             ) empresa
            ,(SELECT hroi.org_information2
               FROM hr_organization_units_v  hrou
                       ,hr_organization_information_v  hroi
                      ,fnd_lookup_values_vl flvv
             WHERE 1=1
                 AND hrou.organization_id     = hroi.organization_id
                 AND hroi.org_information_context   = 'MX_TAX_REGISTRATION'
                 AND flvv.lookup_type                     = 'NOMINAS POR EMPLEADOR LEGAL'
                 AND flvv.meaning                          = hrou.name
                 AND flvv.lookup_code                    = SUBSTR(pro.payroll_name,1,2))rfc_comp
            ,(SELECT display_period_type  --5
              FROM  per_time_period_types_tl tpttl
            WHERE 1=1
                AND tpttl.language   = 'ESA'---USERENV ('LANG')
               AND tpttl.period_type  = pro.period_type
           )periodo 
           ,ptp.period_num num_nom
          , (SELECT pttl.payment_type_name
                  FROM  pay_payment_types_tl pttl
                            ,pay_personal_payment_methods_f ppm
                            ,pay_org_payment_methods_f opm
                            ,pay_org_payment_methods_f_tl opmtl -- 
                            ,pay_payment_types pt
                  WHERE 1=1
                      AND opm.payment_type_id              = pt.payment_type_id
                      AND pt.payment_type_id                 = pttl.payment_type_id
                      AND pttl.language                          =  'ESA'---USERENV ('LANG')
                       AND aac.assignment_id                    = ppm.assignment_id
                       AND ppm.org_payment_method_id   = opm.org_payment_method_id
                       AND opm.org_payment_method_id = opmtl.org_payment_method_id
                       AND OPMTL.LANGUAGE                       = USERENV ('LANG')
             AND ptp.default_dd_date between ppm.effective_start_date and ppm.effective_end_date
                       AND EXISTS (SELECT MEANING
                                             FROM FND_LOOKUP_VALUES
                                            WHERE 1=1
                                                 AND LOOKUP_TYPE  = 'XXCALV_METODOS_PAGO'
                                                 AND ENABLED_FLAG  = 'Y'
                                                 AND LANGUAGE         = USERENV ('LANG')
                                                 AND MEANING  = opmtl.org_payment_method_name
                                                                    ) 
                 ) metodo_pago
           ,peo.employee_number empleado
           ,peo.full_name nom_empl
           ,peo.per_information2   rfc_empl
         ,peo.per_information3 nss
          ,(SELECT org_information1
                              FROM hr_soft_coding_keyflex  hsck
                                      ,hr_all_organization_units  hrou
                                      ,hr_organization_information   hoi
                           WHERE 1=1
                                AND hsck.segment1          = hrou.organization_id
                                AND hrou.organization_id   = hoi.organization_id
                                AND hoi.org_information_context   = 'MX_SOC_SEC_DETAILS'  
                                AND hsck.soft_coding_keyflex_id  = pa.soft_coding_keyflex_id--5061
                     ) regpatr
           ,peo.national_identifier CURP
         ,(SELECT prr.result_value  --campo21
                           FROM pay_run_results_v prr
                               ,pay_assignment_actions  aac1
                           WHERE 1=1
                                AND prr.assignment_action_id          = aac1.assignment_action_id
                                AND aac1.source_action_id    = aac.assignment_action_id
                                AND prr.element_name  IN ('Integrated Daily Wage', 'Salario Diario Integrado')
                                AND ROWNUM = 1) basecotiz 
         ,(SELECT SUBSTR(flv.meaning,9 ) valor
            FROM hr_soft_coding_keyflex  hsck
                      ,hr_all_organization_units  hrou
                      ,hr_organization_information   hoi
                      ,fnd_lookup_values flv
           WHERE 1=1
                AND hsck.segment1                      = hrou.organization_id
                AND hrou.organization_id              = hoi.organization_id
                AND hoi.org_information_context   = 'MX_SOC_SEC_DETAILS'  
                AND hsck.segment6                      = flv.lookup_code
                AND flv.lookup_type                      =  'MX_SOCIAL_SECURITY_SALARY_TYPE'
                AND flv.language                          = 'ESA'
                AND hsck.soft_coding_keyflex_id    = pa.soft_coding_keyflex_id --5061
          ) tiposalario
          , pa.ass_attribute30 turno  --campo24
          ,pro.payroll_name nomina
          ,pa.payroll_id
          ,hraou.name depto
          ,hr_general.decode_position_latest_name (pa.position_id) puesto
         ,(SELECT prr.result_value  --campo34
                           FROM pay_run_results_v prr
                                ,pay_assignment_actions  aac1
                           WHERE 1=1
                                AND prr.assignment_action_id          = aac1.assignment_action_id
                                AND aac1.source_action_id    = aac.assignment_action_id
                                AND  prr.element_name =  'I001_SALARIO_DIARIO') salario_diario
           ,(SELECT TO_NUMBER(prrv.result_value)  --campo35,36
                           FROM pay_run_results_v prr
                               ,pay_assignment_actions  aac1
                               ,pay_run_result_values_v prrv
                           WHERE 1=1
                                and prr.run_result_id        = prrv.run_result_id
                                AND prr.assignment_action_id = aac1.assignment_action_id
                                AND aac1.source_action_id    = aac.assignment_action_id
                                AND  prr.element_name =  'P001_SUELDO NORMAL'
                                and prrv.name   IN ('Dias Recibo')--('Dias IMSS')
                                ) diatrab
          ,TO_CHAR(SYSDATE, 'DD/MON/YYYY') fechaimpr
           ,(SELECT b.value
                           FROM pay_balance_values_v b
                               ,pay_assignment_actions  aac1
                           WHERE 1=1
                               AND b.assignment_action_id   = aac1.assignment_action_id
                               AND aac1.source_action_id    = aac.assignment_action_id
                               AND b.balance_name||database_item_suffix  = 'P043_FONDO AHORRO EMP ISR Exempt_ASG_GRE_YTD' 
                         ) fondoahorro
--           ---  fin encabezado
--           --- pie de página empleado
--           ,(SELECT round(b.value)
--                           FROM pay_balance_values_v b
--                               ,pay_assignment_actions  aac1
--                           WHERE 1=1
--                               AND b.assignment_action_id   = aac1.assignment_action_id
--                               AND aac1.source_action_id    = aac.assignment_action_id
--                               AND b.balance_name||database_item_suffix  IN( 'Pago Neto_ASG_GRE_RUN', 'Net Pay_ASG_GRE_RUN')
--              )netopagarempl
           ,hr_payrolls.display_period_name (pac.payroll_action_id) period_name
           ,pac.time_period_id 
           ,peo.person_id
          ,( SELECT 1
             FROM pay_run_results_v rrs
                 ,pay_assignment_actions  aac1
             WHERE 1=1
                 AND rrs.assignment_action_id  = aac1.assignment_action_id 
                 AND aac1.source_action_id    = aac.assignment_action_id
                 AND  rrs.classification_name           IN ('Imputed Earnings', 'Percepciones Imputadas')
                 AND rrs.element_name    = (SELECT meaning
                                             FROM fnd_lookup_values_vl 
                                           WHERE lookup_type = 'XXCALV_DESPENSA')
            ) bonoempl
           ,( SELECT TO_NUMBER(rrs.result_value)
             FROM pay_run_results_v rrs
                 ,pay_assignment_actions  aac1
             WHERE 1=1
                 AND rrs.assignment_action_id  = aac1.assignment_action_id 
                 AND aac1.source_action_id    = aac.assignment_action_id
                 AND  rrs.classification_name           IN ('Imputed Earnings', 'Percepciones Imputadas')
                 AND rrs.element_name    = (SELECT meaning
                                             FROM fnd_lookup_values_vl 
                                           WHERE lookup_type = 'XXCALV_DESPENSA')
            )bono1empl 
--           ,(SELECT round(b.value)
--                           FROM pay_balance_values_v b
--                               ,pay_assignment_actions  aac1
--                           WHERE 1=1
--                               AND b.assignment_action_id   = aac1.assignment_action_id
--                               AND aac1.source_action_id    = aac.assignment_action_id
--                               AND b.balance_name||database_item_suffix  IN( 'Pago Neto_ASG_GRE_RUN', 'Net Pay_ASG_GRE_RUN')
--              )netopagarempr           
           ,TO_CHAR(ptp.start_date, 'DD/MON/YYYY')||' '||' AL'||' '||TO_CHAR(ptp.end_date,'DD/MON/YYYY') fecha
          ,( SELECT 1
             FROM pay_run_results_v rrs
                 ,pay_assignment_actions  aac1
             WHERE 1=1
                 AND rrs.assignment_action_id  = aac1.assignment_action_id 
                 AND aac1.source_action_id    = aac.assignment_action_id
                 AND  rrs.classification_name           IN ('Imputed Earnings', 'Percepciones Imputadas')
                 AND rrs.element_name    = (SELECT meaning
                                             FROM fnd_lookup_values_vl 
                                           WHERE lookup_type = 'XXCALV_DESPENSA')
            ) bonoempr
           ,( SELECT TO_NUMBER(rrs.result_value)
             FROM pay_run_results_v rrs
                ,pay_assignment_actions  aac1
             WHERE 1=1
                 AND rrs.assignment_action_id  = aac1.assignment_action_id 
                 AND aac1.source_action_id    = aac.assignment_action_id
                 AND rrs.classification_name           IN ('Imputed Earnings', 'Percepciones Imputadas')
                 AND rrs.element_name    = (SELECT meaning
                                             FROM fnd_lookup_values_vl 
                                           WHERE lookup_type = 'XXCALV_DESPENSA')
            )bono2empr
           , ( SELECT hroi.org_information1
               FROM hr_organization_units_v  hrou
                       ,hr_organization_information_v  hroi
                      ,fnd_lookup_values_vl flvv
             WHERE 1=1
                 AND hrou.organization_id     = hroi.organization_id
                 AND hroi.org_information_context   = 'MX_TAX_REGISTRATION'
                 AND flvv.lookup_type                     = 'NOMINAS POR EMPLEADOR LEGAL'
                 AND flvv.meaning                          = hrou.name
                 AND flvv.lookup_code                    = SUBSTR(pro.payroll_name,1,2)
             ) anexoempr
            ,'BONO CON DERECHO A COMPRA' textoanexo
            ,row_number() OVER (PARTITION BY pro.payroll_id ORDER BY pro.payroll_id DESC) folio
         ,ptp.period_num periodo2
          ,TO_CHAR(SYSDATE, 'DD/MON/YYYY')fechaimpr2
         ,peo.national_identifier depto2
          , peo.full_name nombre2
          --fiin anexo
          ,aac.assignment_id 
          ,aac.assignment_action_id 
          ,(select flv.description
            from pay_org_payment_methods_f opm
                   ,pay_personal_payment_methods_f ppm
                   ,fnd_lookup_values_vl flv
            where 1 = 1
            and ppm.org_payment_method_id = opm.org_payment_method_id
            and ptp.default_dd_date between ppm.effective_start_date and ppm.effective_end_date
            and ptp.default_dd_date between opm.effective_start_date and opm.effective_end_date
            and flv.lookup_type = 'XXCALV_METODO_DESPENSA'
            and flv.meaning = opm.org_payment_method_name
            and ppm.assignment_id = aac.assignment_id 
            and rownum = 1 ) metodo_pago_bono  --JJ
           ,ppb.name base_salario
FROM pay_payrolls_f pro
        ,pay_payroll_actions pac
        ,per_time_periods ptp
         ,pay_assignment_actions  aac
       --,pay_assignment_actions  aac1       
        ,per_all_assignments_f pa
        ,per_pay_bases ppb
        ,per_people_f peo
        ,hr_all_organization_units   hraou        
WHERE 1=1
     AND pac.payroll_id                          = pro.payroll_id
     AND pac.effective_date                    BETWEEN pro.effective_start_date
                                                                  AND pro.effective_end_date
     AND pac.payroll_id                          = ptp.payroll_id
     AND pac.time_period_id                   = ptp.time_period_id
     AND pac.payroll_action_id                =  aac.payroll_action_id
     --AND aac.assignment_action_id          = aac1.source_action_id
     AND exists (select 1 from pay_run_results_v prr 
                              ,pay_assignment_actions  aac1  
                 where prr.assignment_action_id = aac1.assignment_action_id
                 and aac1.source_action_id    = aac.assignment_action_id
                 and prr.result_value is not null
                 and prr.classification_name != 'Information')     
     AND pac.effective_date                     BETWEEN pa.effective_start_date  AND pa.effective_end_date
     AND aac.assignment_id                  = pa.assignment_id
     AND pa.person_id                          = peo.person_id  
     AND pa.organization_id                  = hraou.organization_id  
     AND ppb.pay_basis_id (+)= pa.pay_basis_id
     AND peo.effective_end_date          >= SYSDATE 
     --parámetros
     AND pa.payroll_id                                         =  :P_NOMINA
     AND to_char(ptp.end_date,'YYYY/MM/DD HH24:MI:SS')         =  :P_PERIODO 
     AND pac.consolidation_set_id                              = :P_JGOCONSL
--     AND pac.assignment_set_id                          = NVL(:P_JGOASIG,NVL(pac.assignment_set_id,0) )      
     AND peo.person_id                                         = NVL(:P_EMPLEADO,peo.person_id)
     AND hraou.name                                            = NVL(:P_DEPTO,hraou.name)      
    order by hraou.name, to_number(peo.employee_number)
)
WHERE 1=1
GROUP BY EMPRESA, RFC_COMP
      ,periodo 
      ,num_nom
      ,METODO_PAGO
      ,empleado
      ,nom_empl
      ,rfc_empl
      ,NSS
      ,regpatr
      ,CURP
      ,tiposalario
      ,turno
      ,nomina
      ,depto
      ,puesto
      ,payroll_id
      ,rownum
      ,fechaimpr
      ,period_name
      ,time_period_id 
      ,person_id 
       ,fecha
       ,anexoempr
      ,textoanexo
      ,assignment_id 
      ,assignment_action_id
      ,metodo_pago_bono
      ,base_salario
order by depto, to_number(empleado)