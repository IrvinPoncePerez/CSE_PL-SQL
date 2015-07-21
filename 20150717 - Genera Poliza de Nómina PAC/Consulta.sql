--        select  ppa.payroll_action_id,
--                ppa.assignment_set_id,
--                 paa.assignment_action_id,
                 pcd.person_id,
--                 ptp.time_period_id,
--                 ptp.end_date,
--                 pet.element_type_id,
--                 pas.assignment_number,
--                 pet.element_name,
--                 rrs.run_result_id,
                 --pcd.credit_amount,
                 pcd.debit_amount,
--                 pc.cost_allocation_keyflex_id,
                 pcd.concatenated_segments seg
                 ,pcd.segment1, 
                 pcd.segment2, 
                 pcd.segment3, 
                 pcd.segment4, 
                 pcd.segment5, 
                 pcd.segment6
--                 ,hao.attribute7 cc, 
--                 hao.attribute3 mano_de_obra, 
--                 hao.attribute4 carga_social
--                 ,hao.attribute5 bonos, 
--                 hao.attribute6 fondo_de_ahorro
--                 , pet.attribute1 clasificacion_pac 
--        from pay_payroll_actions ppa
--            ,pay_payrolls_f pp
--            ,per_time_periods ptp
--            ,pay_assignment_actions paa      
--            ,per_all_assignments_f pas 
--            ,pay_run_results rrs
--            ,pay_element_types_f pet
--            ,pay_costs pc
            ,pay_costing_details_v pcd
--            ,hr_all_organization_units hao
--        where 1 = 1
--        and pp.payroll_id = ppa.payroll_id
--        and ptp.time_period_id = ppa.time_period_id
--        and paa.payroll_action_id = ppa.payroll_action_id
--        and pas.assignment_id = paa.assignment_id
--        and ppa.effective_date  between pas.effective_start_date and pas.effective_end_date
--        and pas.ass_attribute15 = 'PAC'   --Solo empleados PAC
--        and rrs.assignment_action_id = paa.assignment_action_id
--        and pet.element_type_id = rrs.element_type_id 
--        and pet.attribute1 is not null     --Elementos que deben ser transferidos
--        and pet.attribute1 <> 'N/A'
--        and pc.run_result_id = rrs.run_result_id
        and pcd.run_result_id = rrs.run_result_id
--        and hao.organization_id = pas.organization_id
--        and hao.attribute7 is not null        --Organizaciones con informacion de centro de costos
--        and ppa.payroll_id = nvl(:p_payroll_id,ppa.payroll_id) 
--        and nvl(ppa.consolidation_set_id,0) = nvl(:p_consolidation_id,nvl(ppa.consolidation_set_id,0))
--        and nvl(ppa.assignment_set_id,0) = nvl(:p_assignment_set_id,nvl(ppa.assignment_set_id,0))
--        and ppa.effective_date between nvl(:pp_start_date,PTP.START_DATE) and NVL(:pp_end_date, PTP.END_DATE)
--        and pp.period_type = :p_period_type
        --and ptp.time_period_id = 150258
        --and ppa.payroll_action_id = 10361
        --and ptp.time_period_id IN (SELECT DISTINCT ptp.time_period_id
        --                                                FROM per_time_periods ptp
        --                                               WHERE 1 = 1
        --                                                 AND ptp.start_date >= p_Fecha_Ini
        --                                                 AND ptp.end_date <= p_Fecha_Fin
        --                                                 AND ptp.payroll_id = p_Id_Nomina)
--        and ppa.action_type IN ('R', 'Q')
--        and paa.action_status = 'C'
        and pcd.debit_amount <> 0
        and pc.debit_or_credit = 'D'
--        order by hao.attribute7, pas.assignment_number, pet.element_name;