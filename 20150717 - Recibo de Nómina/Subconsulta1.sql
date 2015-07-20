SELECT rrs.element_name percep
            ,TO_NUMBER(SUM(rrs.result_value))  importepercep
            ,aac1.source_action_id assignment_action_id
           ,sum((select TO_NUMBER(prrv.result_value)  from pay_run_result_values_v prrv where  prrv.run_result_id  = rrs.run_result_id 
            and prrv.name = decode(rrs.element_name,'P001_SUELDO NORMAL','Dias Recibo','P005_VACACIONES','Dias Normales')  ) * 8 ) horas
 FROM  pay_run_results_v rrs
       ,pay_assignment_actions  aac1  
 WHERE 1=1
     AND rrs.assignment_action_id  = aac1.assignment_action_id
     AND aac1.source_action_id    = :assignment_action_id ---104075
     AND (rrs.classification_name           IN ('Earnings', 'Percepciones', 'Supplemental Earnings','Percepciones Complementarias', 'Amends') 
                 OR rrs.element_name  IN (SELECT meaning
                                             FROM fnd_lookup_values_vl 
                                           WHERE lookup_type = 'XX_PERCEPCIONES_INFORMATIVAS'))
     AND rrs.element_name NOT IN (SELECT meaning
                                             FROM fnd_lookup_values_vl 
                                           WHERE lookup_type = 'XXCALV_AUSENCIAS')
     AND rrs.element_name NOT IN (SELECT meaning
                                             FROM fnd_lookup_values_vl 
                                           WHERE lookup_type = 'XXCALV_EXCLUIR_ELEMENTO')
     AND rrs.element_name != 'Ajuste D056_IMSS'  
     GROUP BY rrs.element_name ,aac1.source_action_id
     ORDER BY 1 asc