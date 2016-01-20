SELECT D.EARNINGS_ASSIGNMENT_ACTION_ID,
       D.EARNINGS_ELEMENT_NAME,
       D.EARNINGS_RESULT_VALUE,
       D.EARNINGS_RUN_RESULT_ID,
       D.EARNINGS_HOURS
  FROM (SELECT PRR.ASSIGNMENT_ACTION_ID             AS  EARNINGS_ASSIGNMENT_ACTION_ID,
               PETF.ELEMENT_NAME                    AS  EARNINGS_ELEMENT_NAME,
               SUM(PRRV.RESULT_VALUE)               AS  EARNINGS_RESULT_VALUE,
               PRRV.RUN_RESULT_ID                   AS  EARNINGS_RUN_RESULT_ID,
               SUM((SELECT TO_NUMBER(PRRV2.RESULT_VALUE)
                      FROM PAY_RUN_RESULT_VALUES    PRRV2,
                           PAY_INPUT_VALUES_F       PIVF2                   
                     WHERE 1 = 1
                       AND PRRV2.RUN_RESULT_ID = PRRV.RUN_RESULT_ID
                       AND PRRV2.INPUT_VALUE_ID = PIVF2.INPUT_VALUE_ID
                       AND PIVF2.NAME = DECODE (PETF.ELEMENT_NAME,
                                                'P001_SUELDO NORMAL','Dias Recibo',
                                                'P005_VACACIONES','Dias Normales' )) * 8) AS  EARNINGS_HOURS
          FROM PAY_RUN_RESULTS              PRR,
               PAY_ELEMENT_TYPES_F          PETF,
               PAY_RUN_RESULT_VALUES        PRRV,
               PAY_INPUT_VALUES_F           PIVF,
               PAY_ELEMENT_CLASSIFICATIONS  PEC
         WHERE 1 = 1
           AND PRR.ASSIGNMENT_ACTION_ID = :ASSIGNMENT_ACTION_ID
           AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
           AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
           AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
           AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
           AND (PEC.CLASSIFICATION_NAME IN ('Earnings', 
                                            'Supplemental Earnings', 
                                            'Amends', 
                                            'Imputed Earnings') 
                  OR PETF.ELEMENT_NAME  IN (SELECT MEANING
                                              FROM FND_LOOKUP_VALUES 
                                             WHERE LOOKUP_TYPE = 'XX_PERCEPCIONES_INFORMATIVAS'
                                               AND LANGUAGE = USERENV('LANG')))
           AND PETF.ELEMENT_NAME NOT IN (SELECT MEANING
                                           FROM FND_LOOKUP_VALUES_VL 
                                          WHERE LOOKUP_TYPE = 'XXCALV_AUSENCIAS')
           AND PETF.ELEMENT_NAME NOT IN (SELECT MEANING
                                           FROM FND_LOOKUP_VALUES_VL 
                                          WHERE LOOKUP_TYPE = 'XXCALV_EXCLUIR_ELEMENTO')
           AND PETF.ELEMENT_NAME NOT IN ('Ajuste D056_IMSS', 'P039_DESPENSA') 
           AND PIVF.UOM = 'M'
           AND PIVF.NAME = 'Pay Value'
           AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
         GROUP BY PETF.ELEMENT_NAME,
                  PRRV.RUN_RESULT_ID,
                  PRR.ASSIGNMENT_ACTION_ID
         ORDER BY PETF.ELEMENT_NAME) D
 WHERE 1 = 1
   AND D.EARNINGS_RESULT_VALUE <> 0 
 ORDER BY D.EARNINGS_ELEMENT_NAME