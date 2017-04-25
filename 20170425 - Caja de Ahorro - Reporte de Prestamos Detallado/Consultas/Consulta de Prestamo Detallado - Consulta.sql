ALTER SESSION SET CURRENT_SCHEMA=APPS;
                
                SELECT DISTINCT
                       AXL.CODE_COMBINATION_ID,
                       AXH.ENTITY_CODE,
                       AXH.EVENT_TYPE_CODE,
                       AXL.ACCOUNTING_CLASS_CODE,
                       AXL.SOURCE_LINK_TABLE,
                       COUNT(AXH.HEADER_ID)                             AS  LINES,
                       SUM(AXL.ACCOUNTED_DR)                            AS  ACCOUNTED_DR,
                       SUM(AXL.ACCOUNTED_CR)                            AS  ACCOUNTED_CR,
                       SUM(AXL.ACCOUNTED_CR) - SUM(AXL.ACCOUNTED_DR)    AS  DIFFERENCE_AXL
                  FROM ATET_XLA_HEADERS             AXH,
                       ATET_XLA_LINES               AXL
                 WHERE 1 = 1
                   AND AXH.ACCOUNTING_DATE BETWEEN :CP_START_DATE
                                               AND :CP_END_DATE
                   AND AXL.HEADER_ID = AXH.HEADER_ID
                   AND (AXL.CODE_COMBINATION_ID = ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID
                                                 (
                                                    ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE
                                                    (
                                                        ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID,
                                                        'LOAN_SAV_CODE_COMB'
                                                    )           
                                                 ) OR 
                       AXL.CODE_COMBINATION_ID = ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID
                                                 (
                                                    ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE
                                                    (
                                                        ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID,
                                                        'LOAN_NO_SAV_CODE_COMB'
                                                    )
                                                 ))
                 GROUP
                    BY AXL.CODE_COMBINATION_ID,
                       AXH.ENTITY_CODE,
                       AXH.EVENT_TYPE_CODE,
                       AXL.ACCOUNTING_CLASS_CODE,
                       AXL.SOURCE_LINK_TABLE