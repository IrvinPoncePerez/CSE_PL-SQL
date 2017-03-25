ALTER SESSION SET NLS_LANGUAGE = 'LATIN AMERICAN SPANISH';


SELECT /*+ LEADING(PRR, PRRV) */
       PETF.ELEMENT_NAME,
       SUM(PRRV.RESULT_VALUE),
       PEC.CLASSIFICATION_NAME,
       PIVF.UOM
  FROM PAY_RUN_RESULTS              PRR,
       PAY_RUN_RESULT_VALUES        PRRV,
       PAY_INPUT_VALUES_F           PIVF,
       PAY_ELEMENT_TYPES_F          PETF,
       PAY_ELEMENT_CLASSIFICATIONS  PEC
 WHERE 1 = 1 
   AND PRR.RUN_RESULT_ID = PRRV.RUN_RESULT_ID
   AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
   AND PRR.ELEMENT_TYPE_ID = PETF.ELEMENT_TYPE_ID
   AND PIVF.NAME = 'Pay Value'
   AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
   AND (   PEC.CLASSIFICATION_NAME IN ('Earnings', 
                                       'Supplemental Earnings', 
                                       'Amends', 
                                       'Imputed Earnings',
                                       'Voluntary Deductions',
                                       'Involuntary Deductions')
        OR PETF.ELEMENT_NAME IN (SELECT MEANING
                                   FROM FND_LOOKUP_VALUES
                                  WHERE 1 = 1
                                    AND LOOKUP_TYPE IN ('XX_PERCEPCIONES_INFORMATIVAS',
                                                        'XX_DEDUCCIONES_INFORMATIVAS')
                                    AND LANGUAGE = USERENV('LANG')))
   AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE
                   AND PIVF.EFFECTIVE_END_DATE
   AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE
                   AND PETF.EFFECTIVE_END_DATE
 GROUP
    BY PETF.ELEMENT_NAME,
       PEC.CLASSIFICATION_NAME,
       PIVF.UOM 
 ORDER 
    BY PETF.ELEMENT_NAME
   