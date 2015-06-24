    SELECT aac1.source_action_id assignment_action_id          
           ,rrs.element_name concepto
              ,(SELECT TO_NUMBER(sum(rrv.result_value)) 
                  FROM pay_run_result_values_v rrv
                  WHERE 1=1
                      AND rrv.run_result_id   = rrs.run_result_id
                      AND rrv.name   = 'Saldo Anterior' 
               )SALD_ANT
             ,TO_NUMBER(sum(rrs.result_value)) movimiento
            ,(SELECT TO_NUMBER(rrv.result_value) 
                  FROM pay_run_result_values_v rrv
                  WHERE 1=1
                      AND rrv.run_result_id   = rrs.run_result_id
                      AND rrv.name   = 'Saldo Restante' 
               )sald_rest
            ---  ,rrs.*
   FROM  pay_run_results_v rrs
        ,pay_assignment_actions  aac1
 WHERE 1=1
      AND rrs.assignment_action_id  = aac1.assignment_action_id
     AND aac1.source_action_id    =  :assignment_action_id
    -- AND rrs.assignment_action_id    =  :assignment_action_id---104102 --104075
  AND (rrs.classification_name           IN ('Involuntary Deductions', 'Deducciones Involuntarias', 'Voluntary Deductions','Deducciones Voluntarias')
                 AND rrs.element_name  IN (SELECT meaning
                                             FROM fnd_lookup_values_vl 
                                           WHERE lookup_type = 'XX_DEDUCCIONES_ESTADOS_CUENTA')
               ) 
   AND rrs.element_name NOT LIKE '%Special Features%'  
   GROUP BY aac1.source_action_id ,rrs.element_name,rrs.run_result_id
   UNION
SELECT * 
  FROM (SELECT D.ASSIGNMENT_ACTION_ID,
               D.ELEMENT_NAME concepto,
               (CASE WHEN (SELECT PAA2.ASSIGNMENT_ACTION_ID
                             FROM PAY_ASSIGNMENT_ACTIONS PAA2
                            WHERE PAA2.SOURCE_ACTION_ID = :ASSIGNMENT_ACTION_ID) = D.ASSIGNMENT_ACTION_ID THEN
                       TO_NUMBER(NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(D.ASSIGNMENT_ACTION_ID,    
                                                                               'P047_ISPT ANUAL A FAVOR',  
                                                                               'Saldo_Pendiente'),   '0')) 
                       +  TO_NUMBER(NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(D.ASSIGNMENT_ACTION_ID,    
                                                                     'P047_ISPT ANUAL A FAVOR',  
                                                                     'Pay Value'),   '0')) 
                     ELSE
                        TO_NUMBER(NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(D.ASSIGNMENT_ACTION_ID,
                                                                        'P047_ISPT ANUAL A FAVOR',
                                                                        'Saldo_Pendiente'),    '0'))
                        END) SALD_ANT,
              (CASE WHEN (SELECT PAA2.ASSIGNMENT_ACTION_ID
                             FROM PAY_ASSIGNMENT_ACTIONS PAA2
                            WHERE PAA2.SOURCE_ACTION_ID = :ASSIGNMENT_ACTION_ID) = D.ASSIGNMENT_ACTION_ID THEN
                      TO_NUMBER(NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(D.ASSIGNMENT_ACTION_ID,
                                                                            'P047_ISPT ANUAL A FAVOR',
                                                                            'Pay Value'),         '0'))
                    ELSE 0 END) movimiento,
              TO_NUMBER(NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(D.ASSIGNMENT_ACTION_ID,
                                                                        'P047_ISPT ANUAL A FAVOR',
                                                                        'Saldo_Pendiente'),    '0')) sald_rest 
        FROM (  SELECT PPA.DATE_EARNED,
                       PRRV.RESULT_VALUE,
                       PIVF.NAME,
                       PETF.ELEMENT_NAME,
                       PAA.ASSIGNMENT_ACTION_ID
                  FROM PAY_ASSIGNMENT_ACTIONS       PAA,
                       PAY_PAYROLL_ACTIONS          PPA,
                       PAY_RUN_TYPES_X              PRTX,
                       PAY_RUN_RESULTS              PRR,
                       PAY_ELEMENT_TYPES_F          PETF,
                       PAY_RUN_RESULT_VALUES        PRRV,
                       PAY_INPUT_VALUES_F           PIVF,
                       PAY_ELEMENT_CLASSIFICATIONS  PEC
                 WHERE 1 = 1
                   AND PAA.ASSIGNMENT_ID = (SELECT PA.ASSIGNMENT_ID 
                                              FROM PAY_ASSIGNMENT_ACTIONS PA 
                                             WHERE PA.SOURCE_ACTION_ID = :ASSIGNMENT_ACTION_ID )
                   AND PPA.PAYROLL_ACTION_ID = PAA.PAYROLL_ACTION_ID
                   AND PRTX.RUN_TYPE_ID = PAA.RUN_TYPE_ID        
                   AND PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
                   AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
                   AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
                   AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
                   AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
                   AND SYSDATE <= PETF.EFFECTIVE_END_DATE
                   AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
                   AND PEC.CLASSIFICATION_NAME = 'Earnings' 
                   AND PETF.ELEMENT_NAME = 'P047_ISPT ANUAL A FAVOR'
                   AND PPA.DATE_EARNED <= (SELECT PPA1.DATE_EARNED
                                             FROM PAY_ASSIGNMENT_ACTIONS PAA1,
                                                  PAY_PAYROLL_ACTIONS    PPA1
                                            WHERE PAA1.PAYROLL_ACTION_ID = PPA1.PAYROLL_ACTION_ID
                                              AND PAA1.SOURCE_ACTION_ID = :ASSIGNMENT_ACTION_ID )
                   AND PIVF.NAME = 'Saldo_Pendiente'
                 ORDER BY TO_DATE(PPA.DATE_EARNED) DESC) D
         WHERE ROWNUM = 1 ) D
WHERE 1 = 1
  AND (D.SALD_ANT <> 0
      OR D.movimiento <> 0
      OR D.sald_rest <> 0)