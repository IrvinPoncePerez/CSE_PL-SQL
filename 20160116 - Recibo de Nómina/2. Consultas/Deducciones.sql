SELECT D.DEDUC_ASSIGNMENT_ACTION_ID,
       D.DEDUC_ELEMENT_NAME,
       D.DEDUC_RESULT_VALUE
  FROM (SELECT PRR.ASSIGNMENT_ACTION_ID     AS  DEDUC_ASSIGNMENT_ACTION_ID,
               PETF.ELEMENT_NAME            AS  DEDUC_ELEMENT_NAME,
               (CASE 
                    WHEN PETF.ELEMENT_NAME LIKE 'A0%' THEN
                        NULL
                    ELSE
                        SUM(PRRV.RESULT_VALUE)
                END)                        AS  DEDUC_RESULT_VALUE
          FROM PAY_RUN_RESULTS              PRR,
               PAY_ELEMENT_TYPES_F          PETF,
               PAY_RUN_RESULT_VALUES        PRRV,
               PAY_INPUT_VALUES_F           PIVF,
               PAY_ELEMENT_CLASSIFICATIONS  PEC
         WHERE PRR.ASSIGNMENT_ACTION_ID = :ASSIGNMENT_ACTION_ID
           AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
           AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
           AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
           AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
           AND (PEC.CLASSIFICATION_NAME IN ('Voluntary Deductions', 
                                            'Involuntary Deductions') 
                   OR PETF.ELEMENT_NAME IN (SELECT MEANING
                                              FROM FND_LOOKUP_VALUES 
                                             WHERE LOOKUP_TYPE IN ('XX_DEDUCCIONES_INFORMATIVAS', 'XXCALV_AUSENCIAS')
                                               AND LANGUAGE = USERENV('LANG')))
           AND PETF.ELEMENT_NAME NOT LIKE '%Special Features%'
           AND ((PETF.ELEMENT_NAME != 'D056_IMSS' AND EXISTS (SELECT 1 
                                                                FROM PAY_RUN_RESULTS              PRR2,
                                                                     PAY_ELEMENT_TYPES_F          PETF2,
                                                                     PAY_RUN_RESULT_VALUES        PRRV2
                                                               WHERE 1 = 1
                                                                 AND PRR2.ASSIGNMENT_ACTION_ID = PRR.ASSIGNMENT_ACTION_ID
                                                                 AND PETF2.ELEMENT_TYPE_ID = PRR2.ELEMENT_TYPE_ID 
                                                                 AND PETF2.ELEMENT_NAME = 'Ajuste D056_IMSS') ) OR   
                (PETF.ELEMENT_NAME != 'Ajuste D056_IMSS' AND NOT EXISTS (SELECT 1 
                                                                           FROM PAY_RUN_RESULTS              PRR3,
                                                                                PAY_ELEMENT_TYPES_F          PETF3,
                                                                                PAY_RUN_RESULT_VALUES        PRRV3
                                                                          WHERE 1 = 1
                                                                            AND PRR3.ASSIGNMENT_ACTION_ID = PRR.ASSIGNMENT_ACTION_ID
                                                                            AND PETF3.ELEMENT_TYPE_ID = PRR3.ELEMENT_TYPE_ID 
                                                                            AND PETF3.ELEMENT_NAME = 'Ajuste D056_IMSS')) )
           AND PIVF.UOM = 'M'
           AND PIVF.NAME IN ('Pay Value', 'ISR Exempt')
         GROUP BY PRR.ASSIGNMENT_ACTION_ID,
                  PETF.ELEMENT_NAME 
         ORDER BY PETF.ELEMENT_NAME) D
 WHERE 1 = 1
   AND (DEDUC_RESULT_VALUE <> 0 OR DEDUC_RESULT_VALUE IS NULL)
 ORDER BY D.DEDUC_ELEMENT_NAME