ALTER SESSION SET CURRENT_SCHEMA=APPS;


       
        SELECT D.HEADER_ID,
               D.LOAN_TRANSACTION_ID,
               D.ABREVIATE_PERIOD_TYPE,
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
               D.PAYMENT_CAPITAL,
               D.PAYMENT_INTEREST,
               D.PAYMENT_INTEREST_LATE,
               NVL(ASCI.CONDONED_INTEREST_AMOUNT,0) CONDONED_INTEREST_AMOUNT,
               D.TRANSFERED_INTEREST,
               D.ACCOUNTED_FLAG,
               D.ACCOUNTED_CR,
               D.ACCOUNTED_DR
          FROM (
                SELECT LT.LOAN_TRANSACTION_ID,
                       LT.HEADER_ID,
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
                         WHEN LT.ELEMENT_NAME = 'D072_PRESTAMO CAJA DE AHORRO' THEN 'PAGO VIA NOMINA'
                         ELSE LT.ELEMENT_NAME
                        END )                  AS  TRANSACTION_CODE,
                       LT.ACCOUNTING_DATE      AS  EARNED_DATE,
                       LT.LOAN_ID,
                       LT.DEBIT_AMOUNT,
                       LT.CREDIT_AMOUNT,
                       LT.PAYMENT_CAPITAL,
                       LT.PAYMENT_INTEREST,
                       LT.PAYMENT_INTEREST_LATE,
                       LT.TRANSFERED_INTEREST,
                       (CASE
                         WHEN LT.ACCOUNTED_FLAG = 'ACCOUNTED' THEN 'CONTABILIZADO'
                         ELSE 'PENDIENTE'
                        END)                    AS  ACCOUNTED_FLAG,
                       (CASE
                         WHEN ASM.IS_SAVER = 'Y' THEN 'SI'
                         WHEN ASM.IS_SAVER = 'N' THEN 'NO'
                        END)                    AS  IS_SAVER,
                       (CASE 
                         WHEN ASM.PERSON_TYPE IN ('EMPLEADO', 'EMPLOYEE')  THEN 'EMPLEADO'
                         WHEN ASM.PERSON_TYPE IN ('EX-EMPLEADO', 'EX-EMPLOYEE') THEN 'EX-EMPLEADO'
                        END)                    AS  PERSON_TYPE,
                       LT.ACCOUNTED_CR,
                       LT.ACCOUNTED_DR
                  FROM (                
                        SELECT AXH.HEADER_ID
                              ,ASLT.ELEMENT_NAME
                              ,ASLT.DEBIT_AMOUNT
                              ,ASLT.CREDIT_AMOUNT
                              ,NVL(ASLT.PAYMENT_CAPITAL, 0)       AS  PAYMENT_CAPITAL
                              ,NVL(ASLT.PAYMENT_INTEREST, 0)      AS  PAYMENT_INTEREST
                              ,NVL(ASLT.PAYMENT_INTEREST_LATE, 0) AS  PAYMENT_INTEREST_LATE
                              ,AXH.ACCOUNTING_DATE
                              ,ASLT.ACCOUNTED_FLAG
                              ,ASLT.LOAN_ID
                              ,ASLT.MEMBER_ID
                              ,ASLT.LOAN_TRANSACTION_ID
                              ,ASLT.MEMBER_ACCOUNT_ID
                              ,(CASE
                                    WHEN ASLT.ELEMENT_NAME = 'APERTURA DE PRESTAMO'
        --                             AND AXH.EVENT_TYPE_CODE = 'LOAN_CREATION'
        --                             AND AXL.ACCOUNTING_CLASS_CODE = 'LOAN_CREATION'
        --                             AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                     AND ASL.ATTRIBUTE6 = 'TRANSFER_TO_GUARANTEES'
                                    THEN ASL.LOAN_INTEREST_AMOUNT
                                    ELSE 0 
                                END)                              AS  TRANSFERED_INTEREST 
                              ,AXL.ACCOUNTED_CR
                              ,AXL.ACCOUNTED_DR
                          FROM ATET_XLA_HEADERS             AXH
                              ,ATET_XLA_LINES               AXL
                              ,ATET_SB_LOANS_TRANSACTIONS   ASLT
                              ,ATET_SB_LOANS                ASL
                         WHERE 1 = 1
                           AND ASLT.LOAN_ID = ASL.LOAN_ID
                           AND AXH.ACCOUNTING_DATE BETWEEN :CP_START_DATE
                                                       AND :CP_END_DATE
                           AND AXL.HEADER_ID = AXH.HEADER_ID
                           AND (
                               AXL.CODE_COMBINATION_ID = ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID
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
                           AND AXH.ENTITY_CODE 
                               IN ('LOANS'
                                  ,'PAYROLL'
                                  ,'ENDORSEMENT_LOANS'
                                  ,'REFINANCED_LOANS')
                           AND AXH.EVENT_TYPE_CODE 
                               IN ('LOAN_CREATION'
                                  ,'LOAN_PREPAID'
                                  ,'PAYROLL_LOANS'
                                  ,'ENDORSEMENT_LOAN_CREATION'
                                  ,'REFINANCED_LOAN_CREATION'
                                  ,'REPAYMENT_LOAN')
                           AND AXL.SOURCE_ID = (CASE
                                                    WHEN AXH.ENTITY_CODE = 'LOANS'
                                                     AND AXH.EVENT_TYPE_CODE = 'LOAN_CREATION'
                                                     AND AXL.ACCOUNTING_CLASS_CODE = 'LOAN_CREATION'
                                                     AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                                         THEN ASLT.LOAN_ID
                                                    WHEN AXH.ENTITY_CODE = 'LOANS'
                                                     AND AXH.EVENT_TYPE_CODE = 'LOAN_PREPAID'
                                                     AND AXL.ACCOUNTING_CLASS_CODE = 'LOAN_PREPAID'
                                                     AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS_TRANSACTIONS'
                                                         THEN ASLT.LOAN_TRANSACTION_ID
                                                    WHEN AXH.ENTITY_CODE = 'PAYROLL'
                                                     AND AXH.EVENT_TYPE_CODE = 'PAYROLL_LOANS'
                                                     AND AXL.ACCOUNTING_CLASS_CODE = 'PAYROLL_LOANS'
                                                     AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS_TRANSACTIONS'
                                                         THEN ASLT.LOAN_TRANSACTION_ID
                                                    WHEN AXH.ENTITY_CODE = 'ENDORSEMENT_LOANS'
                                                     AND AXH.EVENT_TYPE_CODE = 'ENDORSEMENT_LOAN_CREATION'
                                                     AND AXL.ACCOUNTING_CLASS_CODE = 'ENDORSEMENT_LOAN_CREATION'
                                                     AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                                        THEN ASLT.LOAN_ID
                                                    WHEN AXH.ENTITY_CODE = 'ENDORSEMENT_LOANS'
                                                     AND AXH.EVENT_TYPE_CODE = 'ENDORSEMENT_LOAN_CREATION'
                                                     AND AXL.ACCOUNTING_CLASS_CODE = 'PREVIOUS_LOAN'
                                                     AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                                        THEN ASLT.LOAN_ID
                                                    WHEN AXH.ENTITY_CODE = 'REFINANCED_LOANS'
                                                     AND AXH.EVENT_TYPE_CODE = 'REFINANCED_LOAN_CREATION'
                                                     AND AXL.ACCOUNTING_CLASS_CODE = 'REFINANCED_LOAN_CREATION'
                                                     AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                                        THEN ASLT.LOAN_ID
                                                    WHEN AXH.ENTITY_CODE = 'LOANS'
                                                     AND AXH.EVENT_TYPE_CODE = 'REPAYMENT_LOAN'
                                                     AND AXL.ACCOUNTING_CLASS_CODE = 'LOAN_CREATION'
                                                     AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                                        THEN ASLT.LOAN_ID
                                                    WHEN AXH.ENTITY_CODE = 'LOANS'
                                                     AND AXH.EVENT_TYPE_CODE = 'REPAYMENT_LOAN'
                                                     AND AXL.ACCOUNTING_CLASS_CODE = 'REPAYMENT_LOAN'
                                                     AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS_TRANSACTIONS'
                                                        THEN ASLT.LOAN_TRANSACTION_ID
                                                END)
                           AND ASLT.TRANSACTION_CODE = (CASE
                                                            WHEN AXH.ENTITY_CODE = 'LOANS'
                                                             AND AXH.EVENT_TYPE_CODE = 'LOAN_CREATION'
                                                             AND AXL.ACCOUNTING_CLASS_CODE = 'LOAN_CREATION'
                                                             AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                                                 THEN 'OPENING'
                                                            WHEN AXH.ENTITY_CODE = 'LOANS'
                                                             AND AXH.EVENT_TYPE_CODE = 'LOAN_PREPAID'
                                                             AND AXL.ACCOUNTING_CLASS_CODE = 'LOAN_PREPAID'
                                                             AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS_TRANSACTIONS'
                                                                 THEN ASLT.TRANSACTION_CODE
                                                            WHEN AXH.ENTITY_CODE = 'PAYROLL'
                                                             AND AXH.EVENT_TYPE_CODE = 'PAYROLL_LOANS'
                                                             AND AXL.ACCOUNTING_CLASS_CODE = 'PAYROLL_LOANS'
                                                             AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS_TRANSACTIONS'
                                                                 THEN 'PROCESSED'
                                                            WHEN AXH.ENTITY_CODE = 'ENDORSEMENT_LOANS'
                                                             AND AXH.EVENT_TYPE_CODE = 'ENDORSEMENT_LOAN_CREATION'
                                                             AND AXL.ACCOUNTING_CLASS_CODE = 'ENDORSEMENT_LOAN_CREATION'
                                                             AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                                                 THEN 'OPENING'
                                                            WHEN AXH.ENTITY_CODE = 'ENDORSEMENT_LOANS'
                                                             AND AXH.EVENT_TYPE_CODE = 'ENDORSEMENT_LOAN_CREATION'
                                                             AND AXL.ACCOUNTING_CLASS_CODE = 'PREVIOUS_LOAN'
                                                             AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                                                 THEN 'SETTLEMENT_LOAN'
                                                            WHEN AXH.ENTITY_CODE = 'REFINANCED_LOANS'
                                                             AND AXH.EVENT_TYPE_CODE = 'REFINANCED_LOAN_CREATION'
                                                             AND AXL.ACCOUNTING_CLASS_CODE = 'REFINANCED_LOAN_CREATION'
                                                             AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                                                 THEN 'OPENING'
                                                            WHEN AXH.ENTITY_CODE = 'LOANS'
                                                             AND AXH.EVENT_TYPE_CODE = 'REPAYMENT_LOAN'
                                                             AND AXL.ACCOUNTING_CLASS_CODE = 'LOAN_CREATION'
                                                             AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                                                 THEN 'OPENING'
                                                            WHEN AXH.ENTITY_CODE = 'LOANS'
                                                             AND AXH.EVENT_TYPE_CODE = 'REPAYMENT_LOAN'
                                                             AND AXL.ACCOUNTING_CLASS_CODE = 'REPAYMENT_LOAN'
                                                             AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS_TRANSACTIONS'
                                                                 THEN 'REPAYMENT_LOAN'
                                                        END)
        UNION
                        SELECT AXH.HEADER_ID
                              ,ASLT.ELEMENT_NAME
                              ,ASLT.DEBIT_AMOUNT
                              ,ASLT.CREDIT_AMOUNT
                              ,NVL(ASLT.PAYMENT_CAPITAL, 0)       AS  PAYMENT_CAPITAL
                              ,NVL(ASLT.PAYMENT_INTEREST, 0)      AS  PAYMENT_INTEREST
                              ,NVL(ASLT.PAYMENT_INTEREST_LATE, 0) AS  PAYMENT_INTEREST_LATE
                              ,AXH.ACCOUNTING_DATE
                              ,ASLT.ACCOUNTED_FLAG
                              ,ASLT.LOAN_ID
                              ,ASLT.MEMBER_ID
                              ,ASLT.LOAN_TRANSACTION_ID
                              ,ASLT.MEMBER_ACCOUNT_ID
                              ,0                                  AS  TRANSFERED_INTEREST
                              ,AXL.ACCOUNTED_CR
                              ,AXL.ACCOUNTED_DR
                          FROM ATET_XLA_HEADERS             AXH
                              ,ATET_XLA_LINES               AXL
                              ,ATET_SB_LOANS                ASL
                              ,ATET_SB_LOANS_TRANSACTIONS   ASLT
                         WHERE 1 = 1
                           AND AXH.ACCOUNTING_DATE BETWEEN :CP_START_DATE
                                                       AND :CP_END_DATE
                           AND AXL.HEADER_ID = AXH.HEADER_ID
                           AND (
                               AXL.CODE_COMBINATION_ID = ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID
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
                           AND AXH.ENTITY_CODE 
                               IN ('REFINANCED_LOANS')
                           AND AXH.EVENT_TYPE_CODE 
                               IN ('REFINANCED_LOAN_CREATION')
                           AND AXL.SOURCE_ID = ASL.ATTRIBUTE2
                           AND ASL.LOAN_ID = ASLT.LOAN_ID
                           AND ASLT.TRANSACTION_CODE = (CASE
                                                            WHEN AXH.ENTITY_CODE = 'REFINANCED_LOANS'
                                                             AND AXH.EVENT_TYPE_CODE = 'REFINANCED_LOAN_CREATION'
                                                             AND AXL.ACCOUNTING_CLASS_CODE = 'PREVIOUS_LOAN'
                                                             AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                                                                 THEN 'SETTLEMENT_LOAN'
                                                        END)
                       )    LT
                      ,ATET_SB_MEMBERS              ASM
                      ,PER_ASSIGNMENTS_F            PAF
                      ,PAY_PAYROLLS_F               PPF
                      ,ATET_SB_MEMBERS_ACCOUNTS     ASMA
                 WHERE 1 = 1
                   AND ASM.MEMBER_ID = LT.MEMBER_ID
                   AND PAF.PERSON_ID = ASM.PERSON_ID
                   AND PPF.PAYROLL_ID = PAF.PAYROLL_ID
                   AND ASMA.MEMBER_ACCOUNT_ID = LT.MEMBER_ACCOUNT_ID 
                   AND ASMA.LOAN_ID = LT.LOAN_ID
                   AND ASMA.MEMBER_ID = LT.MEMBER_ID
                   AND ASMA.ACCOUNT_DESCRIPTION = 'D072_PRESTAMO CAJA DE AHORRO'
                   AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE 
                                   AND PAF.EFFECTIVE_END_DATE
                   AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE 
                                   AND PPF.EFFECTIVE_END_DATE
               ) D
               LEFT JOIN    ATET_SB_CONDONED_INTEREST   ASCI
                 ON D.LOAN_ID = ASCI.LOAN_ID
                AND D.TRANSACTION_CODE = 'LIQUIDACION DE PRESTAMO'
         WHERE 1 = 1
           AND APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(D.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(D.PAYROLL_NAME))
           AND D.PAYROLL_ID = NVL(:P_PAYROLL_ID, D.PAYROLL_ID)
           AND D.MEMBER_ID = NVL(:P_MEMBER_ID, D.MEMBER_ID)
           AND D.TRANSACTION_CODE = NVL(:P_TRANSACTION_CODE, D.TRANSACTION_CODE) 
         ORDER BY D.HEADER_ID,
                  D.LOAN_TRANSACTION_ID,
                  D.ABREVIATE_PERIOD_TYPE,
                  D.PAYROLL_ID,
                  D.EMPLOYEE_NUMBER,
                  D.EARNED_DATE;
         
         
         
                  
             SELECT 
                     AXH.HEADER_ID,
                     AXH.JOURNAL_NAME,
                     AXL.ACCOUNTED_DR,
                     AXL.ACCOUNTED_CR
--                     SUM(AXL.ACCOUNTED_DR),
--                     SUM(AXL.ACCOUNTED_CR),
--                     SUM(AXL.ACCOUNTED_CR) - SUM(AXL.ACCOUNTED_DR)
                FROM ATET_XLA_HEADERS     AXH,
                     ATET_XLA_LINES       AXL
               WHERE 1 = 1
                 AND AXH.HEADER_ID = AXL.HEADER_ID
                 AND AXH.ACCOUNTING_DATE BETWEEN :P_START_DATE
                                             AND :P_END_DATE
                 AND AXL.CODE_COMBINATION_ID IN (634166);
                  
                 
          SELECT GH.JE_HEADER_ID,
                 GH.NAME,
                 GL.ACCOUNTED_DR,
                 GL.ACCOUNTED_CR
            FROM GL_JE_HEADERS  GH,
                 GL_JE_LINES    GL
           WHERE 1 = 1
             AND GH.JE_HEADER_ID = GL.JE_HEADER_ID
             AND GH.PERIOD_NAME = 'OCT-17'
             AND GL.CODE_COMBINATION_ID = 634166  
             AND GH.LEDGER_ID = 2084