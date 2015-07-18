select

--pac.payroll_id,
--pac.payroll_id,
     pac.time_period_id,
     pac.payroll_action_id,
     pa.person_id,
     pa.organization_id,
     pa.payroll_id,
     pac.consolidation_set_id,
     peo.person_id,
     hraou.name    

 FROM pay_payrolls_f pro
        ,pay_payroll_actions pac
        ,per_time_periods ptp
         ,pay_assignment_actions  aac
       --,pay_assignment_actions  aac1       
        ,per_all_assignments_f pa
--        ,per_pay_bases ppb
        ,per_people_f peo
        ,hr_all_organization_units   hraou        
WHERE 1=1
     AND pac.payroll_id                          = pro.payroll_id
--     AND pac.effective_date                    BETWEEN pro.effective_start_date
--                                                                  AND pro.effective_end_date
     AND pac.payroll_id                          = ptp.payroll_id
     AND pac.time_period_id                   = ptp.time_period_id
     AND pac.payroll_action_id                =  aac.payroll_action_id
--     AND aac.assignment_action_id          = aac1.source_action_id
--     AND exists (select 1 from pay_run_results_v prr 
--                              ,pay_assignment_actions  aac1  
--                 where prr.assignment_action_id = aac1.assignment_action_id
--                 and aac1.source_action_id    = aac.assignment_action_id
--                 and prr.result_value is not null
--                 and prr.classification_name != 'Information')     
--     AND pac.effective_date                     BETWEEN pa.effective_start_date  AND pa.effective_end_date
----     AND aac.assignment_id                  = pa.assignment_id
     AND pa.person_id                          = peo.person_id  
     AND pa.organization_id                  = hraou.organization_id  
--     AND ppb.pay_basis_id (+)= pa.pay_basis_id
--     AND peo.effective_end_date          >= SYSDATE 
--     --parámetros
     AND pa.payroll_id                                         =  :P_NOMINA
--     AND ptp.end_date         =  :P_PERIODO
     and ptp.TIME_PERIOD_ID = 135281 
     AND pac.consolidation_set_id                              = :P_JGOCONSL
--     AND pac.assignment_set_id                          = NVL(:P_JGOASIG,NVL(pac.assignment_set_id,0) )      
     AND peo.person_id                                         = NVL(:P_EMPLEADO,peo.person_id)
     AND hraou.name                                            = NVL(:P_DEPTO,hraou.name)      
    order by hraou.name, to_number(peo.employee_number)