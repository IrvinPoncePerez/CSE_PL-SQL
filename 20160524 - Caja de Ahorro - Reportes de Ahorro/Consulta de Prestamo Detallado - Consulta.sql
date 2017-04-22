SELECT DISTINCT
                        (CASE 
                         WHEN PPF.PERIOD_TYPE = 'Week' OR PPF.PERIOD_TYPE = 'Semana' THEN 'S'
                         WHEN PPF.PERIOD_TYPE = 'Quincena' OR PPF.PERIOD_TYPE = 'Semi-Month' THEN 'Q'
                        END)                    AS  ABREVIATE_PERIOD_TYPE,
                       ASMA.CODE_COMBINATION_ID,
                       PPF.PERIOD_TYPE,
                       PPF.PAYROLL_ID,
                       PPF.PAYROLL_NAME,
                       ASM.MEMBER_ID,
                       ASM.PERSON_ID,
                       ASM.EMPLOYEE_NUMBER,
                       ASM.EMPLOYEE_FULL_NAME,
                       (CASE
                         WHEN ASLT.ELEMENT_NAME = 'D072_PRESTAMO CAJA DE AHORRO' THEN 'PAGO VIA NOMINA'
                         ELSE ASLT.ELEMENT_NAME
                        END )                   AS  TRANSACTION_CODE,
                       AXH.ACCOUNTING_DATE      AS  EARNED_DATE,
                       ASLT.DEBIT_AMOUNT,
                       ASLT.CREDIT_AMOUNT,
                       (CASE
                         WHEN ASLT.ACCOUNTED_FLAG = 'ACCOUNTED' THEN 'CONTABILIZADO'
                         ELSE 'PENDIENTE'
                        END)                    AS  ACCOUNTED_FLAG,
                       (CASE
                         WHEN ASM.IS_SAVER = 'Y' THEN 'SI'
                         WHEN ASM.IS_SAVER = 'N' THEN 'NO'
                        END)                    AS  IS_SAVER,
                       (CASE 
                         WHEN ASM.PERSON_TYPE IN ('EMPLEADO', 'EMPLOYEE')  THEN 'EMPLEADO'
                         WHEN ASM.PERSON_TYPE IN ('EX-EMPLEADO', 'EX-EMPLOYEE') THEN 'EX-EMPLEADO'
                        END)                    AS  PERSON_TYPE
        --               AXL.CODE_COMBINATION_ID,
        --               SUM(AXL.ACCOUNTED_DR)                            AS  ACCOUNTED_DR,
        --               SUM(AXL.ACCOUNTED_CR)                            AS  ACCOUNTED_CR,
        --               SUM(AXL.ACCOUNTED_CR) - SUM(AXL.ACCOUNTED_DR)    AS  DIFFERENCE,
        --               SUM(ASLT.DEBIT_AMOUNT)                           AS  DEBIT_AMOUNT,
        --               SUM(ASLT.CREDIT_AMOUNT)                          AS  CREDIT_AMOUNT,
        --               SUM(ASLT.CREDIT_AMOUNT) - SUM(ASLT.DEBIT_AMOUNT) AS  DIFFERENCE  
                  FROM ATET_XLA_HEADERS             AXH,
                       ATET_XLA_LINES               AXL,
                       ATET_SB_LOANS_TRANSACTIONS   ASLT,
                       ATET_SB_MEMBERS              ASM,
                       PER_ASSIGNMENTS_F            PAF,
                       PAY_PAYROLLS_F               PPF,
                       ATET_SB_MEMBERS_ACCOUNTS     ASMA
                 WHERE 1 = 1
                   AND AXH.ACCOUNTING_DATE BETWEEN :CP_START_DATE
                                               AND :CP_END_DATE
                   AND AXH.ENTITY_CODE IN ('PAYROLL',
                                           'ENDORSEMENT_LOANS',
                                           'LOANS',
                                           'REFINANCED_LOANS')
                   AND AXH.EVENT_TYPE_CODE IN ('PAYROLL_LOANS',
                                               'ENDORSEMENT_LOAN_CREATION',
                                               'LOAN_CREATION',
                                               'LOAN_PREPAID',
                                               'REFINANCED_LOAN_CREATION')
                   AND AXL.HEADER_ID = AXH.HEADER_ID
                   AND AXL.ACCOUNTING_CLASS_CODE IN ('LOAN_CREATION', 
                                                     'PAYROLL_LOANS', 
                                                     'ENDORSEMENT_LOAN_CREATION',
                                                     'LOAN_PREPAID',
                                                     'REFINANCED_LOAN_CREATION')
                   AND AXL.SOURCE_LINK_TABLE = (CASE WHEN AXL.ACCOUNTING_CLASS_CODE IN ('LOAN_CREATION', 
                                                                                        'ENDORSEMENT_LOAN_CREATION',
                                                                                        'LOAN_PREPAID',
                                                                                        'REFINANCED_LOAN_CREATION') 
                                                      AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                                     THEN 'ATET_SB_LOANS'
                                                     WHEN AXL.ACCOUNTING_CLASS_CODE IN ('PAYROLL_LOANS')
                                                      AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS_TRANSACTIONS'
                                                     THEN 'ATET_SB_LOANS_TRANSACTIONS'
                                                     WHEN AXL.ACCOUNTING_CLASS_CODE IN ('LOAN_PREPAID')
                                                      AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS_TRANSACTIONS'
                                                     THEN 'ATET_SB_LOANS_TRANSACTIONS'
                                                     WHEN AXL.ACCOUNTING_CLASS_CODE = 'PREVIOUS_LOAN'
                                                      AND AXH.ENTITY_CODE = 'ENDORSEMENT_LOANS' 
                                                     THEN 'ATET_SB_LOANS'
                                                END)
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
                   AND AXL.SOURCE_ID = (CASE
                                            WHEN AXL.ACCOUNTING_CLASS_CODE IN ('LOAN_CREATION', 
                                                                               'ENDORSEMENT_LOAN_CREATION',
                                                                               'LOAN_PREPAID',
                                                                               'REFINANCED_LOAN_CREATION') 
                                             AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                            THEN ASLT.LOAN_ID
                                            WHEN AXL.ACCOUNTING_CLASS_CODE IN ('PAYROLL_LOANS')
                                             AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS_TRANSACTIONS'
                                            THEN ASLT.LOAN_TRANSACTION_ID
                                            WHEN AXL.ACCOUNTING_CLASS_CODE IN ('LOAN_PREPAID')
                                             AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS_TRANSACTIONS'
                                            THEN ASLT.LOAN_TRANSACTION_ID
                                            WHEN AXL.ACCOUNTING_CLASS_CODE = 'PREVIOUS_LOAN'
                                             AND AXH.ENTITY_CODE = 'ENDORSEMENT_LOANS'
                                            THEN ASLT.LOAN_TRANSACTION_ID
                                        END)       
                   AND ASLT.TRANSACTION_CODE = (CASE
                                                WHEN AXL.ACCOUNTING_CLASS_CODE IN ('PAYROLL_LOANS')
                                                 AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS_TRANSACTIONS' 
                                                THEN 'PROCESSED'
                                                WHEN AXL.ACCOUNTING_CLASS_CODE IN ('LOAN_PREPAID')
                                                 AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                                THEN 'PROCESSED'
                                                WHEN AXL.ACCOUNTING_CLASS_CODE IN ('LOAN_PREPAID')
                                                 AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS_TRANSACTIONS'
                                                THEN 'SETTLEMENT_LOAN'
                                                WHEN AXL.ACCOUNTING_CLASS_CODE IN('LOAN_CREATION')
                                                 AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                                THEN 'OPENING'
                                                WHEN AXL.ACCOUNTING_CLASS_CODE IN ('REFINANCED_LOAN_CREATION')
                                                 AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                                THEN 'OPENING'
                                                WHEN AXL.ACCOUNTING_CLASS_CODE IN ('ENDORSEMENT_LOAN_CREATION')
                                                 AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                                THEN 'OPENING'
                                               END)
                   AND ASLT.PERIOD_NAME = (CASE
                                            WHEN AXH.ENTITY_CODE = 'LOANS'
                                             AND AXH.EVENT_TYPE_CODE = 'LOAN_PREPAID'
                                             AND AXL.ACCOUNTING_CLASS_CODE = 'LOAN_PREPAID'
                                             AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                            THEN 'PAGO ANTICIPADO'
                                            ELSE ASLT.PERIOD_NAME
                                           END)
                   AND ASM.PERSON_ID = PAF.PERSON_ID
                   AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
                   AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
                   AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
                   AND ASMA.MEMBER_ID = ASM.MEMBER_ID
                   AND ASMA.ACCOUNT_DESCRIPTION = 'D072_PRESTAMO CAJA DE AHORRO'
                   AND ASMA.LOAN_ID = ASLT.LOAN_ID
                   AND ASLT.MEMBER_ID = ASM.MEMBER_ID
                   AND ASLT.MEMBER_ACCOUNT_ID = ASMA.MEMBER_ACCOUNT_ID
        UNION
                SELECT DISTINCT
               (CASE 
                 WHEN PPF.PERIOD_TYPE = 'Week' OR PPF.PERIOD_TYPE = 'Semana' THEN 'S'
                 WHEN PPF.PERIOD_TYPE = 'Quincena' OR PPF.PERIOD_TYPE = 'Semi-Month' THEN 'Q'
                END)                    AS  ABREVIATE_PERIOD_TYPE,
               ASMA.CODE_COMBINATION_ID,
               PPF.PERIOD_TYPE,
               PPF.PAYROLL_ID,
               PPF.PAYROLL_NAME,
               ASM.MEMBER_ID,
               ASM.PERSON_ID,
               ASM.EMPLOYEE_NUMBER,
               ASM.EMPLOYEE_FULL_NAME,
               (CASE
                 WHEN ASLT.ELEMENT_NAME = 'D072_PRESTAMO CAJA DE AHORRO' THEN 'PAGO VIA NOMINA'
                 ELSE ASLT.ELEMENT_NAME
                END )                   AS  TRANSACTION_CODE,
               AXH.ACCOUNTING_DATE      AS  EARNED_DATE,
               ASLT.DEBIT_AMOUNT,
               ASLT.CREDIT_AMOUNT,
               (CASE
                 WHEN ASLT.ACCOUNTED_FLAG = 'ACCOUNTED' THEN 'CONTABILIZADO'
                 ELSE 'PENDIENTE'
                END)                    AS  ACCOUNTED_FLAG,
               (CASE
                 WHEN ASM.IS_SAVER = 'Y' THEN 'SI'
                 WHEN ASM.IS_SAVER = 'N' THEN 'NO'
                END)                    AS  IS_SAVER,
               (CASE 
                 WHEN ASM.PERSON_TYPE IN ('EMPLEADO', 'EMPLOYEE')  THEN 'EMPLEADO'
                 WHEN ASM.PERSON_TYPE IN ('EX-EMPLEADO', 'EX-EMPLOYEE') THEN 'EX-EMPLEADO'
                END)                    AS  PERSON_TYPE
--               AXL.CODE_COMBINATION_ID,
--               SUM(AXL.ACCOUNTED_DR)                            AS  ACCOUNTED_DR,
--               SUM(AXL.ACCOUNTED_CR)                            AS  ACCOUNTED_CR,
--               SUM(AXL.ACCOUNTED_CR) - SUM(AXL.ACCOUNTED_DR)    AS  DIFFERENCE,
--               SUM(ASLT.DEBIT_AMOUNT)                           AS  DEBIT_AMOUNT,
--               SUM(ASLT.CREDIT_AMOUNT)                          AS  CREDIT_AMOUNT,
--               SUM(ASLT.CREDIT_AMOUNT) - SUM(ASLT.DEBIT_AMOUNT) AS  DIFFERENCE
                  FROM ATET_XLA_HEADERS             AXH,
                       ATET_XLA_LINES               AXL,
                       ATET_SB_LOANS                ASL,
                       ATET_SB_LOANS_TRANSACTIONS   ASLT,
                       ATET_SB_MEMBERS              ASM,
                       PER_ASSIGNMENTS_F            PAF,
                       PAY_PAYROLLS_F               PPF,
                       ATET_SB_MEMBERS_ACCOUNTS     ASMA
                 WHERE 1 = 1
                   AND AXH.ACCOUNTING_DATE BETWEEN :CP_START_DATE
                                               AND :CP_END_DATE
                   AND AXH.ENTITY_CODE IN ('PAYROLL',
                                           'LOANS',
                                           'REFINANCED_LOANS')
                   AND AXH.EVENT_TYPE_CODE IN ('PAYROLL_LOANS',
                                               'ENDORSEMENT_LOAN_CREATION',
                                               'LOAN_CREATION',
                                               'LOAN_PREPAID',
                                               'REFINANCED_LOAN_CREATION')
                   AND AXL.HEADER_ID = AXH.HEADER_ID
                   AND AXL.ACCOUNTING_CLASS_CODE IN ('PAYROLL_LOANS',
                                                     'PREVIOUS_LOAN')
                   AND AXL.SOURCE_LINK_TABLE = (CASE WHEN AXL.ACCOUNTING_CLASS_CODE IN ('PREVIOUS_LOAN') 
                                                     THEN 'ATET_SB_LOANS'
                                                END)
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
                   AND AXL.SOURCE_ID = ASL.ATTRIBUTE2
                   AND ASLT.LOAN_ID = ASL.LOAN_ID
                   AND ASLT.TRANSACTION_CODE = 'SETTLEMENT_LOAN'
                   AND ASM.PERSON_ID = PAF.PERSON_ID
                   AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
                   AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
                   AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
                   AND ASMA.MEMBER_ID = ASM.MEMBER_ID
                   AND ASMA.ACCOUNT_DESCRIPTION = 'D072_PRESTAMO CAJA DE AHORRO'
                   AND ASMA.LOAN_ID = ASLT.LOAN_ID
                   AND ASLT.MEMBER_ID = ASM.MEMBER_ID
                   AND ASLT.MEMBER_ACCOUNT_ID = ASMA.MEMBER_ACCOUNT_ID