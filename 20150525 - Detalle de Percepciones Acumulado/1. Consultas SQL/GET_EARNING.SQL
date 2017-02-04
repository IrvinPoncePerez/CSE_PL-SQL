        SELECT /*+ LEADING(PRR PEC PETF PIVF) */
            TO_CHAR(SUM(PRRV.RESULT_VALUE))
--          INTO
--            result_value
          FROM PAY_RUN_RESULTS              PRR,
               PAY_ELEMENT_TYPES_F          PETF,
               PAY_RUN_RESULT_VALUES        PRRV,
               PAY_INPUT_VALUES_F           PIVF,
               PAY_ELEMENT_CLASSIFICATIONS  PEC
         WHERE PRR.ASSIGNMENT_ACTION_ID = :P_ASSIGNMENT_ACTION_ID
           AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
           AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
           AND PIVF.NAME = :P_INPUT_VALUE_NAME
           AND PRRV.INPUT_VALUE_ID = PIVF.INPUT_VALUE_ID
           AND PETF.ELEMENT_NAME = :P_ELEMENT_NAME
           AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
           AND SYSDATE <= PETF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
           AND (PEC.CLASSIFICATION_NAME IN ('Earnings', 
                                            'Supplemental Earnings', 
                                            'Imputed Earnings',
                                            'Amends') 
                  OR PETF.ELEMENT_NAME  IN (SELECT MEANING
                                              FROM FND_LOOKUP_VALUES 
                                             WHERE LOOKUP_TYPE = 'XX_PERCEPCIONES_INFORMATIVAS'
                                               AND LANGUAGE = USERENV('LANG')));