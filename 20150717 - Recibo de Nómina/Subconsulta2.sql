  SELECT DAT.DEDUC
        ,DECODE(DAT.CONTROL, 'S', TO_NUMBER(NULL), DAT.importededuc) importededuc
        ,DAT.assignment_action_id
    FROM (
            SELECT rrs.element_name                   deduc
                  ,NVL(nov.CONTROL, 'N')              control
                  ,TO_NUMBER (SUM (rrs.result_value)) importededuc,
                   aac1.source_action_id              assignment_action_id
              FROM pay_run_results_v rrs
                  ,pay_assignment_actions aac1
                  ,(SELECT MEANING
                          ,'S'     CONTROL
                      FROM FND_LOOKUP_VALUES
                     WHERE LOOKUP_TYPE = 'XXCALV_INCAP_NO_VALOR'
                       AND LANGUAGE    = 'ESA'
                  ) NOV
             WHERE 1 = 1
               AND rrs.assignment_action_id = aac1.assignment_action_id
               AND NOV.MEANING(+)    = rrs.element_name
                   AND aac1.source_action_id = :assignment_action_id
                   AND (rrs.classification_name IN
                           ('Involuntary Deductions',
                            'Deducciones Involuntarias',
                            'Voluntary Deductions',
                            'Deducciones Voluntarias')
                        OR rrs.element_name IN
                              (SELECT meaning
                                 FROM fnd_lookup_values_vl
                                WHERE lookup_type IN
                                         ('XX_DEDUCCIONES_INFORMATIVAS',
                                          'XXCALV_AUSENCIAS')))
                   AND rrs.element_name NOT LIKE '%Special Features%'
                   AND ((rrs.element_name != 'D056_IMSS' AND exists (select 1 from pay_run_results_v prr2 
                                                                     where prr2.assignment_action_id = rrs.assignment_action_id
                                                                     and prr2.element_name = 'Ajuste D056_IMSS') ) OR   
                     (rrs.element_name != 'Ajuste D056_IMSS' AND not exists (select 1 from pay_run_results_v prr2 
                                                                     where prr2.assignment_action_id = rrs.assignment_action_id
                                                                     and prr2.element_name = 'Ajuste D056_IMSS')) )
                   
          GROUP BY rrs.element_name, aac1.source_action_id, NVL(nov.CONTROL, 'N')
         ) DAT
ORDER BY 1