SELECT NOM_PER_TIP,
                                    NOM_PER_CVE,
                                    NOM_PER_DESCRI,
                                    NOM_PER_IMPGRA,
                                    NOM_PER_IMPEXE    
                               FROM(SELECT 
                                        NOM_PER_TIP,
                                        NOM_PER_CVE,
                                        NOM_PER_DESCRI,
                                        SUM(NOM_PER_IMPGRA) AS  NOM_PER_IMPGRA,
                                        SUM(NOM_PER_IMPEXE) AS  NOM_PER_IMPEXE 
                                      FROM (SELECT 
                                                NVL((SELECT DISTINCT
                                                            DESCRIPTION
                                                       FROM FND_LOOKUP_VALUES
                                                      WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                         OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                        AND MEANING LIKE PETF.ELEMENT_NAME
                                                        AND LANGUAGE = 'ESA'), '016')       AS  NOM_PER_TIP,
                                                NVL((SELECT DISTINCT
                                                            TAG
                                                       FROM FND_LOOKUP_VALUES
                                                      WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                         OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                        AND MEANING LIKE PETF.ELEMENT_NAME
                                                        AND LANGUAGE = 'ESA'), '000')      AS  NOM_PER_CVE,
                                                (CASE 
                                                    WHEN PETF.ELEMENT_NAME = 'Profit Sharing' THEN
                                                        'REPARTO DE UTILIDADES'
                                                    WHEN PETF.ELEMENT_NAME LIKE 'P0%' THEN
                                                        REPLACE(SUBSTR(PETF.ELEMENT_NAME, 6, LENGTH(PETF.ELEMENT_NAME)), '_', ' ')
                                                    WHEN PETF.ELEMENT_NAME LIKE 'A0%' THEN
                                                        REPLACE(SUBSTR(PETF.ELEMENT_NAME, 6, LENGTH(PETF.ELEMENT_NAME)), '_', ' ')
                                                    ELSE
                                                        REPLACE(UPPER(PETF.ELEMENT_NAME), '_', ' ')
                                                 END)                                       AS  NOM_PER_DESCRI,
                                                (CASE
                                                    WHEN PIVF.NAME = 'ISR Subject' THEN
                                                        SUM(PRRV.RESULT_VALUE)
                                                    ELSE 0
                                                 END)                                       AS  NOM_PER_IMPGRA,
                                                 (CASE
                                                    WHEN PIVF.NAME = 'ISR Exempt' THEN
                                                        SUM(PRRV.RESULT_VALUE)
                                                    ELSE 0
                                                 END)                                       AS  NOM_PER_IMPEXE
                                              FROM PAY_RUN_RESULTS              PRR,
                                                   PAY_ELEMENT_TYPES_F          PETF,
                                                   PAY_RUN_RESULT_VALUES        PRRV,
                                                   PAY_INPUT_VALUES_F           PIVF,
                                                   PAY_ELEMENT_CLASSIFICATIONS  PEC
                                             WHERE PRR.ASSIGNMENT_ACTION_ID = :P_ASSIGNMENT_ACTION_ID
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
                                               AND (PIVF.NAME = 'ISR Subject' OR PIVF.NAME = 'ISR Exempt')
                                               AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
                                               AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                                             GROUP BY PETF.ELEMENT_NAME,
                                                      PETF.REPORTING_NAME,
                                                      PETF.ELEMENT_INFORMATION11,
                                                      PIVF.NAME
                                            UNION
                                            SELECT 
                                                NVL((SELECT DISTINCT
                                                            DESCRIPTION
                                                       FROM FND_LOOKUP_VALUES
                                                      WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                         OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                        AND MEANING LIKE PETF.ELEMENT_NAME
                                                        AND LANGUAGE = 'ESA'), '016')       AS  NOM_PER_TIP,
                                                NVL((SELECT DISTINCT
                                                            TAG
                                                       FROM FND_LOOKUP_VALUES
                                                      WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                         OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                        AND MEANING LIKE PETF.ELEMENT_NAME
                                                        AND LANGUAGE = 'ESA'), '000')      AS  NOM_PER_CVE,
                                                (CASE
                                                    WHEN PETF.ELEMENT_NAME = 'Profit Sharing' THEN
                                                        'REPARTO DE UTILIDADES' 
                                                    WHEN PETF.ELEMENT_NAME LIKE 'P0%' THEN
                                                        REPLACE(SUBSTR(PETF.ELEMENT_NAME, 6, LENGTH(PETF.ELEMENT_NAME)), '_', ' ')
                                                    WHEN PETF.ELEMENT_NAME LIKE 'A0%' THEN
                                                        REPLACE(SUBSTR(PETF.ELEMENT_NAME, 6, LENGTH(PETF.ELEMENT_NAME)), '_', ' ')
                                                    ELSE
                                                        REPLACE(UPPER(PETF.ELEMENT_NAME), '_', ' ')
                                                 END)                                       AS  NOM_PER_DESCRI,
                                                 0                                          AS  NOM_PER_IMPGRA,
                                                 SUM(PRRV.RESULT_VALUE)                     AS  NOM_PER_IMPEXE
                                              FROM PAY_RUN_RESULTS              PRR,
                                                   PAY_ELEMENT_TYPES_F          PETF,
                                                   PAY_RUN_RESULT_VALUES        PRRV,
                                                   PAY_INPUT_VALUES_F           PIVF,
                                                   PAY_ELEMENT_CLASSIFICATIONS  PEC
                                             WHERE PRR.ASSIGNMENT_ACTION_ID = :P_ASSIGNMENT_ACTION_ID
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
                                               AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
                                               AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                                             GROUP BY PETF.ELEMENT_NAME,
                                                      PETF.REPORTING_NAME,
                                                      PETF.ELEMENT_INFORMATION11,
                                                      PIVF.NAME
                                           ) GROUP BY NOM_PER_TIP,
                                                      NOM_PER_CVE,
                                                      NOM_PER_DESCRI)
                              WHERE 1 = 1
                                AND (   NOM_PER_IMPGRA <> 0
                                     OR NOM_PER_IMPEXE <> 0)
                              ORDER BY NOM_PER_CVE;