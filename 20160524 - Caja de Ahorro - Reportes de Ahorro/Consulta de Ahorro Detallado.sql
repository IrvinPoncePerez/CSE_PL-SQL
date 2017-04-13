ALTER SESSION SET CURRENT_SCHEMA=APPS;

SELECT 
       D.ABREVIATE_PERIOD_TYPE,
       D.PERIOD_TYPE,
       D.PAYROLL_ID,
       D.PAYROLL_NAME,
       D.MEMBER_ID,
       D.PERSON_ID,
       D.EMPLOYEE_NUMBER,
       D.EMPLOYEE_FULL_NAME,
       D.TRANSACTION_CODE,
       D.EARNED_DATE,
       D.DEBIT_AMOUNT,
       D.CREDIT_AMOUNT,
       D.ACCOUNTED_FLAG
  FROM (SELECT (CASE 
                 WHEN PPF.PERIOD_TYPE = 'Week' OR PPF.PERIOD_TYPE = 'Semana' THEN 'S'
                 WHEN PPF.PERIOD_TYPE = 'Quincena' OR PPF.PERIOD_TYPE = 'Semi-Month' THEN 'Q'
                END)                    AS  ABREVIATE_PERIOD_TYPE,
               PPF.PERIOD_TYPE,
               PPF.PAYROLL_ID,
               PPF.PAYROLL_NAME,
               ASM.MEMBER_ID,
               ASM.PERSON_ID,
               ASM.EMPLOYEE_NUMBER,
               ASM.EMPLOYEE_FULL_NAME,
               (CASE
                 WHEN ASST.ELEMENT_NAME = 'D071_CAJA DE AHORRO' THEN 'APORTACION VIA NOMINA'
                 ELSE ASST.ELEMENT_NAME
                END )                   AS  TRANSACTION_CODE,
               AXH.ACCOUNTING_DATE      AS  EARNED_DATE,
               ASST.DEBIT_AMOUNT,
               ASST.CREDIT_AMOUNT,
               (CASE
                 WHEN ASST.ACCOUNTED_FLAG = 'ACCOUNTED' THEN 'CONTABILIZADO'
                 ELSE 'PENDIENTE'
                END)                    AS  ACCOUNTED_FLAG
--               SUM(ASST.DEBIT_AMOUNT),
--               SUM(ASST.CREDIT_AMOUNT),
--               SUM(ASST.CREDIT_AMOUNT) - SUM(ASST.DEBIT_AMOUNT),
--               SUM(AXL.ACCOUNTED_DR),
--               SUM(AXL.ACCOUNTED_CR),
--               SUM(AXL.ACCOUNTED_CR) - SUM(AXL.ACCOUNTED_DR)
          FROM ATET_SB_MEMBERS              ASM,
               PER_ASSIGNMENTS_F            PAF,
               PAY_PAYROLLS_F               PPF,
               ATET_SB_MEMBERS_ACCOUNTS     ASMA,
               ATET_SB_SAVINGS_TRANSACTIONS ASST,
               ATET_XLA_LINES               AXL,
               ATET_XLA_HEADERS             AXH
         WHERE 1 = 1
           AND ASM.PERSON_ID = PAF.PERSON_ID
           AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
           AND ASMA.MEMBER_ID = ASM.MEMBER_ID
           AND ASST.MEMBER_ID = ASM.MEMBER_ID
           AND ASST.MEMBER_ACCOUNT_ID =ASMA.MEMBER_ACCOUNT_ID
           AND AXH.ACCOUNTING_DATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
           AND AXH.ACCOUNTING_DATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
           AND ASMA.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO'
           AND ASMA.LOAN_ID IS NULL
           AND AXH.ACCOUNTING_DATE BETWEEN :P_START_DATE
                                       AND :P_END_DATE
           AND AXH.ENTITY_CODE IN ('SAVINGS', 'PAYROLL')
           AND AXH.EVENT_TYPE_CODE IN ('VOLUNTARY_CONTRIBUTION', 'PAYROLL_SAVINGS', 'SAVING_RETIREMENT')
           AND AXL.HEADER_ID = AXH.HEADER_ID
           AND AXL.ACCOUNTING_CLASS_CODE IN ('PAYROLL_SAVINGS', 'SAVING_RETIREMENT', 'VOLUNTARY_CONTRIBUTION')
           AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_SAVINGS_TRANSACTIONS'
           AND AXL.SOURCE_ID <> -1
           AND AXL.CODE_COMBINATION_ID = ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID
                                         (
                                            ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE
                                            (
                                                ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID,
                                                'SAV_CODE_COMB'
                                            )
                                         )
           AND AXL.SOURCE_ID = ASST.SAVING_TRANSACTION_ID
      ORDER BY PPF.PERIOD_TYPE,
               PPF.PAYROLL_ID,
               ASM.EMPLOYEE_NUMBER) D
 WHERE 1 = 1
   AND APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(D.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(D.PAYROLL_NAME))
   AND D.PAYROLL_ID = NVL(:P_PAYROLL_ID, D.PAYROLL_ID)
   AND D.MEMBER_ID = NVL(:P_MEMBER_ID, D.MEMBER_ID)
   AND D.TRANSACTION_CODE = NVL(:P_TRANSACTION_CODE, D.TRANSACTION_CODE) 
 ORDER BY D.ABREVIATE_PERIOD_TYPE,
          D.PAYROLL_ID,
          D.EMPLOYEE_NUMBER,
          D.EARNED_DATE;
          
          
          
        SELECT 
--               (CASE 
--                 WHEN PPF.PERIOD_TYPE = 'Week' OR PPF.PERIOD_TYPE = 'Semana' THEN 'S'
--                 WHEN PPF.PERIOD_TYPE = 'Quincena' OR PPF.PERIOD_TYPE = 'Semi-Month' THEN 'Q'
--                END)                    AS  ABREVIATE_PERIOD_TYPE,
--               PPF.PERIOD_TYPE,
--               PPF.PAYROLL_ID,
--               PPF.PAYROLL_NAME,
--               ASM.MEMBER_ID,
--               ASM.PERSON_ID,
--               ASM.EMPLOYEE_NUMBER,
--               ASM.EMPLOYEE_FULL_NAME,
--               (CASE
--                 WHEN ASST.ELEMENT_NAME = 'D071_CAJA DE AHORRO' THEN 'APORTACION VIA NOMINA'
--                 ELSE ASST.ELEMENT_NAME
--                END )                   AS  TRANSACTION_CODE,
--               AXH.ACCOUNTING_DATE      AS  EARNED_DATE,
--               ASST.DEBIT_AMOUNT,
--               ASST.CREDIT_AMOUNT,
--               (CASE
--                 WHEN ASST.ACCOUNTED_FLAG = 'ACCOUNTED' THEN 'CONTABILIZADO'
--                 ELSE 'PENDIENTE'
--                END)                    AS  ACCOUNTED_FLAG
               SUM(ASST.DEBIT_AMOUNT),
               SUM(ASST.CREDIT_AMOUNT),
               SUM(ASST.CREDIT_AMOUNT) - SUM(ASST.DEBIT_AMOUNT),
               SUM(AXL.ACCOUNTED_DR),
               SUM(AXL.ACCOUNTED_CR),
               SUM(AXL.ACCOUNTED_CR) - SUM(AXL.ACCOUNTED_DR)
          FROM ATET_SB_MEMBERS              ASM,
               PER_ASSIGNMENTS_F            PAF,
               PAY_PAYROLLS_F               PPF,
               ATET_SB_MEMBERS_ACCOUNTS     ASMA,
               ATET_SB_SAVINGS_TRANSACTIONS ASST,
               ATET_XLA_LINES               AXL,
               ATET_XLA_HEADERS             AXH
         WHERE 1 = 1
           AND ASM.PERSON_ID = PAF.PERSON_ID
           AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
           AND ASMA.MEMBER_ID = ASM.MEMBER_ID
           AND ASST.MEMBER_ID = ASM.MEMBER_ID
           AND ASST.MEMBER_ACCOUNT_ID =ASMA.MEMBER_ACCOUNT_ID
           AND AXH.ACCOUNTING_DATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
           AND AXH.ACCOUNTING_DATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
           AND ASMA.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO'
           AND ASMA.LOAN_ID IS NULL
           AND AXH.ACCOUNTING_DATE BETWEEN :P_START_DATE
                                       AND :P_END_DATE
           AND AXH.ENTITY_CODE IN ('SAVINGS', 'PAYROLL')
           AND AXH.EVENT_TYPE_CODE IN ('VOLUNTARY_CONTRIBUTION', 'PAYROLL_SAVINGS', 'SAVING_RETIREMENT')
           AND AXL.HEADER_ID = AXH.HEADER_ID
           AND AXL.ACCOUNTING_CLASS_CODE IN ('PAYROLL_SAVINGS', 'SAVING_RETIREMENT', 'VOLUNTARY_CONTRIBUTION')
           AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_SAVINGS_TRANSACTIONS'
           AND AXL.SOURCE_ID <> -1
           AND AXL.CODE_COMBINATION_ID = ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID
                                         (
                                            ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE
                                            (
                                                ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID,
                                                'SAV_CODE_COMB'
                                            )
                                         )
           AND AXL.SOURCE_ID = ASST.SAVING_TRANSACTION_ID
      ORDER BY PPF.PERIOD_TYPE,
               PPF.PAYROLL_ID,
               ASM.EMPLOYEE_NUMBER;
               
               
SELECT *
  FROM (SELECT DISTINCT
               AXH.HEADER_ID,
               AXL.SOURCE_ID,
               COUNT(AXL.SOURCE_ID) CUENTA
          FROM ATET_XLA_HEADERS             AXH,
               ATET_XLA_LINES               AXL
         WHERE 1 = 1
           AND AXH.ACCOUNTING_DATE BETWEEN :P_START_DATE
                                       AND :P_END_DATE
           AND AXH.ENTITY_CODE IN ('SAVINGS', 'PAYROLL')
           AND AXH.EVENT_TYPE_CODE IN ('VOLUNTARY_CONTRIBUTION', 'PAYROLL_SAVINGS', 'SAVING_RETIREMENT')
           AND AXL.HEADER_ID = AXH.HEADER_ID
           AND AXL.ACCOUNTING_CLASS_CODE IN ('PAYROLL_SAVINGS', 'SAVING_RETIREMENT', 'VOLUNTARY_CONTRIBUTION')
           AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_SAVINGS_TRANSACTIONS'
           AND AXL.SOURCE_ID <> -1
           AND AXL.CODE_COMBINATION_ID = ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID
                                         (
                                            ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE
                                            (
                                                ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID,
                                                'SAV_CODE_COMB'
                                            )
                                         )
         GROUP
            BY AXH.HEADER_ID,
               AXL.SOURCE_ID
        ) D,
       ATET_XLA_LINES   AXL
 WHERE 1 = 1
--   AND (D.CUENTA = 2 OR D.SOURCE_ID = -1)
   AND D.HEADER_ID = AXL.HEADER_ID;
   
   
   
   
        SELECT SUM(AXL.ACCOUNTED_DR),
               SUM(AXL.ACCOUNTED_CR),
               SUM(AXL.ACCOUNTED_CR) - SUM(AXL.ACCOUNTED_DR)
          FROM ATET_XLA_HEADERS             AXH,
               ATET_XLA_LINES               AXL
         WHERE 1 = 1
           AND AXH.ACCOUNTING_DATE BETWEEN :P_START_DATE
                                       AND :P_END_DATE
           AND AXH.ENTITY_CODE IN ('SAVINGS', 'PAYROLL')
           AND AXH.EVENT_TYPE_CODE IN ('VOLUNTARY_CONTRIBUTION', 'PAYROLL_SAVINGS', 'SAVING_RETIREMENT')
           AND AXL.HEADER_ID = AXH.HEADER_ID
           AND AXL.ACCOUNTING_CLASS_CODE IN ('PAYROLL_SAVINGS', 'SAVING_RETIREMENT', 'VOLUNTARY_CONTRIBUTION')
           AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_SAVINGS_TRANSACTIONS'
           AND AXL.SOURCE_ID <> -1
           AND AXL.CODE_COMBINATION_ID = ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID
                                         (
                                            ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE
                                            (
                                                ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID,
                                                'SAV_CODE_COMB'
                                            )
                                         )