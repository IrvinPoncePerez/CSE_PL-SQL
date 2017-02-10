ALTER SESSION SET CURRENT_SCHEMA=APPS;



                                    SELECT 
                                        NVL((SELECT DISTINCT
                                                    DESCRIPTION
                                               FROM FND_LOOKUP_VALUES
                                              WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                 OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                AND MEANING LIKE PETF.ELEMENT_NAME
                                                AND LANGUAGE = 'ESA'), '016')       AS  NOM_OTR_TIP,
                                        NVL((SELECT DISTINCT
                                                    TAG
                                               FROM FND_LOOKUP_VALUES
                                              WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                 OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                AND MEANING LIKE PETF.ELEMENT_NAME
                                                AND LANGUAGE = 'ESA'), '000')      AS  NOM_OTR_CVE,
                                        (CASE
                                            WHEN PETF.ELEMENT_NAME = 'Profit Sharing' THEN
                                                'REPARTO DE UTILIDADES' 
                                            WHEN PETF.ELEMENT_NAME LIKE 'P0%' THEN
                                                REPLACE(SUBSTR(PETF.ELEMENT_NAME, 6, LENGTH(PETF.ELEMENT_NAME)), '_', ' ')
                                            WHEN PETF.ELEMENT_NAME LIKE 'A0%' THEN
                                                REPLACE(SUBSTR(PETF.ELEMENT_NAME, 6, LENGTH(PETF.ELEMENT_NAME)), '_', ' ')
                                            ELSE
                                                REPLACE(UPPER(PETF.ELEMENT_NAME), '_', ' ')
                                         END)                                       AS  NOM_OTR_DESCRI,
                                         0                                          AS  NOM_OTR_IMPEXE,
                                         SUM(PRRV.RESULT_VALUE)                     AS  NOM_OTR_IMPGRA
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
                                       AND PETF.ELEMENT_NAME  IN ('P032_SUBSIDIO_PARA_EMPLEO')
                                       AND PIVF.UOM = 'M'
                                       AND PIVF.NAME = 'Pay Value'
                                       AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                                       AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
                                     GROUP BY PETF.ELEMENT_NAME,
                                              PETF.REPORTING_NAME,
                                              PETF.ELEMENT_INFORMATION11,
                                              PIVF.NAME;