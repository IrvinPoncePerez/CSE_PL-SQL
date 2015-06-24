SELECT   --- encabezado
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
                           WHERE 1=1
                                AND prr.assignment_action_id          = aac1.assignment_action_id
                                AND  prr.element_name  IN ('Integrated Daily Wage', 'Salario Diario Integrado')
                       )basecotiz 
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
           ,hraou.name depto
           ,hr_general.decode_position_latest_name (pa.position_id) puesto
          ,row_number() OVER (PARTITION BY pro.payroll_id ORDER BY pro.payroll_id DESC)  recibo
         ,(SELECT prr.result_value  --campo34
                           FROM pay_run_results_v prr
                           WHERE 1=1
                                AND prr.assignment_action_id          = aac1.assignment_action_id
                                AND  prr.element_name =  'I001_SALARIO_DIARIO') salario_diario
           ,(SELECT TO_NUMBER(prrv.result_value)  --campo35,36
                           FROM pay_run_results_v prr
                                      ,pay_run_result_values_v prrv
                           WHERE 1=1
                                and prr.run_result_id                      = prrv.run_result_id
                                AND prr.assignment_action_id          = aac1.assignment_action_id
                                AND  prr.element_name =  'P001_SUELDO NORMAL'
                                and prrv.name   IN ('Days','Días' )
                                ) diatrab
          ,TO_CHAR(SYSDATE, 'DD/MON/YYYY') fechaimpr
           ,(SELECT b.value
                           FROM pay_balance_values_v b
                           WHERE 1=1
                               AND b.assignment_action_id   = aac1.assignment_action_id
                               AND b.balance_name||database_item_suffix  = 'P043_FONDO AHORRO EMP_ASG_GRE_YTD' -- 'P041_FONDO DE AHORRO EMP_ASG_YTD'
                         ) fondoahorro
           ---  fin encabezado
           --- pie de página empleado
           ,(SELECT round(b.value)
                           FROM pay_balance_values_v b
                           WHERE 1=1
                               AND b.assignment_action_id   = aac1.assignment_action_id
                               AND b.balance_name||database_item_suffix  IN( 'Pago Neto_ASG_GRE_RUN', 'Net Pay_ASG_GRE_RUN')
              )netopagarempl
           ,hr_payrolls.display_period_name (pac.payroll_action_id) period_name
           ,pac.time_period_id 
           ,pro.payroll_id
           ,peo.person_id
          ,( SELECT 1
             FROM pay_run_results_v rrs
             WHERE 1=1
                 AND rrs.assignment_action_id  = aac1.assignment_action_id 
                 AND  rrs.classification_name           IN ('Imputed Earnings', 'Percepciones Impuestas')
                 AND rrs.element_name    = 'P039_BONO DESPENSA ESP'
            ) bonoempl
           ,( SELECT TO_NUMBER(rrs.result_value)
             FROM pay_run_results_v rrs
             WHERE 1=1
                 AND rrs.assignment_action_id  = aac1.assignment_action_id 
                 AND  rrs.classification_name           IN ('Imputed Earnings', 'Percepciones Impuestas')
                 AND rrs.element_name    = 'P039_BONO DESPENSA ESP'
            )bono1empl
            --pie de pag empresa
           ,(SELECT round(b.value)
                           FROM pay_balance_values_v b
                           WHERE 1=1
                               AND b.assignment_action_id   = aac1.assignment_action_id
                               AND b.balance_name||database_item_suffix  IN( 'Pago Neto_ASG_GRE_RUN', 'Net Pay_ASG_GRE_RUN')
              )netopagarempr           
           ,TO_CHAR(ptp.start_date, 'DD/MON/YYYY')||' '||' AL'||' '||TO_CHAR(ptp.end_date,'DD/MON/YYYY') fecha
          ,( SELECT 1
             FROM pay_run_results_v rrs
             WHERE 1=1
                 AND rrs.assignment_action_id  = aac1.assignment_action_id 
                 AND  rrs.classification_name           IN ('Imputed Earnings', 'Percepciones Impuestas')
                 AND rrs.element_name    = 'P039_BONO DESPENSA ESP'
            ) bonoempr
           ,( SELECT TO_NUMBER(rrs.result_value)
             FROM pay_run_results_v rrs
             WHERE 1=1
                 AND rrs.assignment_action_id  = aac1.assignment_action_id 
                 AND  rrs.classification_name           IN ('Imputed Earnings', 'Percepciones Impuestas')
                 AND rrs.element_name    = 'P039_BONO DESPENSA ESP'
            )bono2empr
            --anexo si el paráemetro es sí
           ,:P_ANEXO ANEXOSINO 
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
          ,aac1.assignment_action_id 
          ,pac.assignment_set_id
          ,pac.consolidation_set_id          
FROM pay_payrolls_f pro--PAY_ALL_PAYROLLS_F PRL
        ,pay_payroll_actions pac
        ,per_time_periods ptp
       -- ,pay_assignment_actions_v aac  --validar
         ,pay_assignment_actions  aac
        ,pay_assignment_actions  aac1       
        ,per_all_assignments_f pa
        ,per_people_f peo
        ,hr_all_organization_units   hraou        
WHERE 1=1
     AND pac.payroll_id                          = pro.payroll_id
     AND pac.effective_date                    BETWEEN pro.effective_start_date
                                                                  AND pro.effective_end_date
     AND pac.payroll_id                          = ptp.payroll_id
     AND pac.time_period_id                   = ptp.time_period_id
     AND pac.payroll_action_id                =  aac.payroll_action_id
     AND aac.assignment_action_id          = aac1.source_action_id
     AND pac.effective_date                     BETWEEN pa.effective_start_date  AND pa.effective_end_date
     AND aac.assignment_id                  = pa.assignment_id
     AND pa.person_id                          = peo.person_id  
     AND pa.organization_id                  = hraou.organization_id  
     AND peo.effective_end_date          >= SYSDATE 
     --parámetros
     AND pa.payroll_id                                                              = :P_NOMINA --79         --nómina
     AND to_char(ptp.end_date,'YYYY/MM/DD HH24:MI:SS')         =  :P_PERIODO --103289 periodo
     AND pac.consolidation_set_id                                                    = :P_JGOCONSL  -- juego de consolidacion
     AND NVL(pac.assignment_set_id,0)                                       = NVL(:P_JGOASIG,NVL(pac.assignment_set_id,0) )  --juego de asignación     
     AND peo.person_id                                                             = NVL(:P_EMPLEADO,peo.person_id)-- IN ( 1564,1573)     --id empleado
     AND hraou.name                                                                = NVL(:P_DEPTO,hraou.name)  -- DEPTO     
 --  AND hr_payrolls.display_period_name (pac.payroll_action_id)  like '18%' 