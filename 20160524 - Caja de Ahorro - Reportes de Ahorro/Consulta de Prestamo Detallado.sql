ALTER SESSION SET CURRENT_SCHEMA=APPS;


SELECT D.ABREVIATE_PERIOD_TYPE,
       D.PERIOD_TYPE,
       D.PAYROLL_ID,
       D.PAYROLL_NAME,
       D.MEMBER_ID,
       D.PERSON_ID,
       D.EMPLOYEE_NUMBER,
       D.EMPLOYEE_FULL_NAME,
       D.PERSON_TYPE,
       D.IS_SAVER,
       D.TRANSACTION_CODE,
       D.EARNED_DATE,
       D.DEBIT_AMOUNT,
       D.CREDIT_AMOUNT,
       D.ACCOUNTED_FLAG
  FROM (SELECT 
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
           AND AXH.ACCOUNTING_DATE BETWEEN :P_START_DATE
                                       AND :P_END_DATE
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
                                             THEN 'ATET_SB_LOANS'
                                             WHEN AXL.ACCOUNTING_CLASS_CODE IN ('PAYROLL_LOANS')
                                             THEN 'ATET_SB_LOANS_TRANSACTIONS'
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
                                    WHEN AXL.ACCOUNTING_CLASS_CODE IN('LOAN_CREATION', 
                                                                      'ENDORSEMENT_LOAN_CREATION',
                                                                      'LOAN_PREPAID',
                                                                      'REFINANCED_LOAN_CREATION')
                                    THEN ASLT.LOAN_ID
                                    WHEN AXL.ACCOUNTING_CLASS_CODE IN ('PAYROLL_LOANS')
                                    THEN ASLT.LOAN_TRANSACTION_ID
                                END)       
           AND ASLT.TRANSACTION_CODE = (CASE
                                        WHEN AXL.ACCOUNTING_CLASS_CODE IN ('PAYROLL_LOANS',
                                                                           'LOAN_PREPAID') 
                                        THEN 'PROCESSED'
                                        WHEN AXL.ACCOUNTING_CLASS_CODE IN('LOAN_CREATION', 
                                                                          'ENDORSEMENT_LOAN_CREATION',
                                                                          'REFINANCED_LOAN_CREATION')
                                        THEN 'OPENING'
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
        SELECT 
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
           AND AXH.ACCOUNTING_DATE BETWEEN :P_START_DATE
                                       AND :P_END_DATE
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
                                             'REFINANCED_LOAN_CREATION',
                                             'PREVIOUS_LOAN')
           AND AXL.SOURCE_LINK_TABLE = (CASE WHEN AXL.ACCOUNTING_CLASS_CODE IN ('PREVIOUS_LOAN') 
                                             THEN 'ATET_SB_LOANS'
                                             WHEN AXL.ACCOUNTING_CLASS_CODE IN ('PAYROLL_LOANS')
                                             THEN 'ATET_SB_LOANS_TRANSACTIONS'
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
       ) D
 WHERE 1 = 1
   AND APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(D.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(D.PAYROLL_NAME))
   AND D.PAYROLL_ID = NVL(:P_PAYROLL_ID, D.PAYROLL_ID)
   AND D.MEMBER_ID = NVL(:P_MEMBER_ID, D.MEMBER_ID)
   AND D.TRANSACTION_CODE = NVL(:P_TRANSACTION_CODE, D.TRANSACTION_CODE) 
 ORDER BY D.ABREVIATE_PERIOD_TYPE,
          D.PAYROLL_ID,
          D.EMPLOYEE_NUMBER,
          D.EARNED_DATE;
          
               

                                         
                            
