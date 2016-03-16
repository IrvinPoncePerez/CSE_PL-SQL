             SELECT NOM_DED_TIP,
                    NOM_DED_CVE,
                    NOM_DED_DESCRI,
                    NOM_DED_IMPGRA,
                    NOM_DED_IMPEXE
               FROM (SELECT D.NOM_DED_TIP,
                            D.NOM_DED_CVE,
                            D.NOM_DED_DESCRI,
                            TO_NUMBER(D.NOM_DED_IMPGRA) NOM_DED_IMPGRA,
                            TO_NUMBER(D.NOM_DED_IMPEXE) NOM_DED_IMPEXE
                       FROM(SELECT 
                                    NVL((SELECT DISTINCT
                                                DESCRIPTION
                                           FROM FND_LOOKUP_VALUES
                                          WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                             OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                            AND MEANING LIKE PETF.ELEMENT_NAME
                                            AND LANGUAGE = 'ESA'), '004')       AS  NOM_DED_TIP,
                                    NVL((SELECT DISTINCT
                                                TAG
                                           FROM FND_LOOKUP_VALUES
                                          WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                             OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                            AND MEANING LIKE PETF.ELEMENT_NAME
                                            AND LANGUAGE = 'ESA'), '000')      AS  NOM_DED_CVE,
                                   SUBSTR(PETF.ELEMENT_NAME,
                                          6,
                                          LENGTH(PETF.ELEMENT_NAME))AS  NOM_DED_DESCRI,
                                   0                                AS  NOM_DED_IMPGRA,
                                   TO_NUMBER(PRRV.RESULT_VALUE)        AS  NOM_DED_IMPEXE  
                              FROM PAY_ASSIGNMENT_ACTIONS       PAA,
                                   PAY_RUN_RESULTS              PRR,
                                   PAY_ELEMENT_TYPES_F          PETF,
                                   PAY_RUN_RESULT_VALUES        PRRV,
                                   PAY_INPUT_VALUES_F           PIVF,
                                   PAY_ELEMENT_CLASSIFICATIONS  PEC
                             WHERE 1 = 1
                               AND PAA.PAYROLL_ACTION_ID = :PAYROLL_ACTION_ID 
                               AND PAA.ASSIGNMENT_ID = :ASSIGNMENT_ID
                               AND PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
                               AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
                               AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
                               AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
                               AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
                               AND (PEC.CLASSIFICATION_NAME IN ('Voluntary Deductions', 
                                                                'Involuntary Deductions') 
                                       OR PETF.ELEMENT_NAME IN (SELECT MEANING
                                                                  FROM FND_LOOKUP_VALUES 
                                                                 WHERE LOOKUP_TYPE = 'XX_DEDUCCIONES_INFORMATIVAS'
                                                                   AND LANGUAGE = USERENV('LANG')))
                               AND PIVF.UOM = 'M'
                               AND PIVF.NAME = 'Pay Value') D) F
              WHERE 1 = 1
--                AND (   F.NOM_DED_IMPGRA <> 0 
--                     OR F.NOM_DED_IMPEXE <> 0)
              ORDER BY F.NOM_DED_DESCRI;