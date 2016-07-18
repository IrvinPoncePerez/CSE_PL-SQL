SELECT UNIQUE
       D.JOURNAL_NAME,
       D.HEADER_ID,
       D.ACCOUNTED_DR,
       D.ACCOUNTED_CR,
       AXL.SOURCE_ID    AS  LOAN_ID,
       ASL.MEMBER_ID,
       D.CREATION_DATE
  FROM (SELECT AXH.JOURNAL_NAME,
               AXH.HEADER_ID,
               SUM(AXL.ACCOUNTED_DR)                    AS  ACCOUNTED_DR,
               SUM(AXL.ACCOUNTED_CR)                    AS  ACCOUNTED_CR,
               TO_DATE(AXH.CREATION_DATE, 'DD/MM/RRRR') AS  CREATION_DATE
          FROM ATET_XLA_HEADERS     AXH,
               ATET_XLA_LINES       AXL
         WHERE 1 = 1 
           AND AXH.JOURNAL_NAME LIKE '%PAGO ANTICIPADO CON REPARTO DE AHORRO%'
           AND AXH.HEADER_ID = AXL.HEADER_ID
         GROUP BY AXH.JOURNAL_NAME,
                  AXH.HEADER_ID,
                  AXH.CREATION_DATE) D,
       ATET_XLA_LINES   AXL,
       ATET_SB_LOANS    ASL
 WHERE 1 = 1 
--   AND D.ACCOUNTED_DR <> D.ACCOUNTED_CR
   AND D.HEADER_ID = AXL.HEADER_ID
   AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
   AND AXL.SOURCE_ID = ASL.LOAN_ID;
   
   
   
DECLARE
    CURSOR DETAILS IS
        SELECT UNIQUE
               D.JOURNAL_NAME,
               D.HEADER_ID,
               D.ACCOUNTED_DR,
               D.ACCOUNTED_CR,
               AXL.SOURCE_ID    AS  LOAN_ID,
               ASL.MEMBER_ID,
               D.CREATION_DATE
          FROM (SELECT AXH.JOURNAL_NAME,
                       AXH.HEADER_ID,
                       SUM(AXL.ACCOUNTED_DR)                    AS  ACCOUNTED_DR,
                       SUM(AXL.ACCOUNTED_CR)                    AS  ACCOUNTED_CR,
                       TO_DATE(AXH.CREATION_DATE, 'DD/MM/RRRR') AS  CREATION_DATE
                  FROM ATET_XLA_HEADERS     AXH,
                       ATET_XLA_LINES       AXL
                 WHERE 1 = 1 
                   AND AXH.JOURNAL_NAME LIKE '%PAGO ANTICIPADO CON REPARTO DE AHORRO%'
                   AND AXH.HEADER_ID = AXL.HEADER_ID
                 GROUP BY AXH.JOURNAL_NAME,
                          AXH.HEADER_ID,
                          AXH.CREATION_DATE) D,
               ATET_XLA_LINES   AXL,
               ATET_SB_LOANS    ASL
         WHERE 1 = 1 
        --   AND D.ACCOUNTED_DR <> D.ACCOUNTED_CR
           AND D.HEADER_ID = AXL.HEADER_ID
           AND AXL.SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
           AND AXL.SOURCE_ID = ASL.LOAN_ID;
           
    var_debit_balance       NUMBER;
    var_credit_balance      NUMBER;
    var_member_account_id   NUMBER;
     
BEGIN

    FOR detail IN DETAILS LOOP
    
        DELETE 
          FROM ATET_XLA_LINES 
         WHERE 1 = 1 
           AND HEADER_ID = detail.HEADER_ID;
        
        DELETE 
          FROM ATET_XLA_HEADERS 
         WHERE 1 = 1 
           AND HEADER_ID = detail.HEADER_ID;
           
        DELETE 
          FROM ATET_SB_SAVINGS_TRANSACTIONS
         WHERE 1 = 1
           AND MEMBER_ID = detail.MEMBER_ID
           AND ATTRIBUTE6 = 'RETIRO POR PAGO ANTICIPADO'
           AND ATTRIBUTE7 = 'REPARTO DE AHORRO';
           
        DELETE 
          FROM ATET_SB_LOANS_TRANSACTIONS
         WHERE 1 = 1 
           AND MEMBER_ID = detail.MEMBER_ID
           AND LOAN_ID = detail.LOAN_ID
           AND ELEMENT_NAME = 'PAGO ANTICIPADO'
           AND ATTRIBUTE7 = 'REPARTO DE AHORRO';
           
        DELETE 
          FROM ATET_SB_PAYMENTS_SCHEDULE
         WHERE 1 = 1
           AND LOAN_ID = detail.LOAN_ID
           AND TO_DATE(CREATION_DATE, 'DD/MM/RRRR') = TO_DATE(detail.CREATION_DATE, 'DD/MM/RRRR');
            
        UPDATE ATET_SB_PAYMENTS_SCHEDULE
           SET ATTRIBUTE6 = NULL,
               STATUS_FLAG = 'PENDING',
               PAYED_AMOUNT = NULL,
               PAYED_CAPITAL = NULL,
               PAYED_INTEREST = NULL,
               PAYED_INTEREST_LATE = NULL,
               OWED_AMOUNT = NULL,
               OWED_CAPITAL = NULL,
               OWED_INTEREST = NULL,
               OWED_INTEREST_LATE = NULL
         WHERE 1 = 1
           AND LOAN_ID = detail.LOAN_ID
           AND TO_DATE(LAST_UPDATE_DATE, 'DD/MM/RRRR') = TO_DATE(detail.CREATION_DATE, 'DD/MM/RRRR');
           
        var_debit_balance := 0;
        var_credit_balance := 0;
        var_member_account_id := NULL;
           
        SELECT SUM(NVL(DEBIT_AMOUNT, 0)),
               SUM(NVL(CREDIT_AMOUNT, 0)),
               ASMA.MEMBER_ACCOUNT_ID
          INTO var_debit_balance,
               var_credit_balance,
               var_member_account_id
          FROM ATET_SB_MEMBERS_ACCOUNTS     ASMA,
               ATET_SB_SAVINGS_TRANSACTIONS ASST
         WHERE 1 = 1
           AND ASMA.MEMBER_ID = detail.MEMBER_ID 
           AND ASMA.ACCOUNT_DESCRIPTION = 'INTERES GANADO'
           AND ASST.MEMBER_ID = ASMA.MEMBER_ID
           AND ASST.MEMBER_ACCOUNT_ID = ASMA.MEMBER_ACCOUNT_ID
         GROUP BY ASMA.MEMBER_ACCOUNT_ID;
         
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET DEBIT_BALANCE = var_debit_balance,
               CREDIT_BALANCE = var_credit_balance,
               FINAL_BALANCE = var_credit_balance - var_debit_balance 
         WHERE 1 = 1
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
        
        
        var_debit_balance := 0;
        var_credit_balance := 0;
        var_member_account_id := NULL;
        
        SELECT SUM(NVL(DEBIT_AMOUNT, 0)),
               SUM(NVL(CREDIT_AMOUNT, 0)),
               ASMA.MEMBER_ACCOUNT_ID
          INTO var_debit_balance,
               var_credit_balance,
               var_member_account_id
          FROM ATET_SB_MEMBERS_ACCOUNTS     ASMA,
               ATET_SB_SAVINGS_TRANSACTIONS ASST
         WHERE 1 = 1
           AND ASMA.MEMBER_ID = detail.MEMBER_ID 
           AND ASMA.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO'
           AND ASST.MEMBER_ID = ASMA.MEMBER_ID
           AND ASST.MEMBER_ACCOUNT_ID = ASMA.MEMBER_ACCOUNT_ID
         GROUP BY ASMA.MEMBER_ACCOUNT_ID;
         
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET DEBIT_BALANCE = var_debit_balance,
               CREDIT_BALANCE = var_credit_balance,
               FINAL_BALANCE = var_credit_balance - var_debit_balance 
         WHERE 1 = 1
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
        
        
        var_debit_balance := 0;
        var_credit_balance := 0;
        var_member_account_id := NULL;
        
        SELECT SUM(NVL(DEBIT_AMOUNT, 0)),
               SUM(NVL(CREDIT_AMOUNT, 0)),
               ASMA.MEMBER_ACCOUNT_ID
          INTO var_debit_balance,
               var_credit_balance,
               var_member_account_id
          FROM ATET_SB_MEMBERS_ACCOUNTS     ASMA,
               ATET_SB_LOANS_TRANSACTIONS   ASLT
         WHERE 1 = 1
           AND ASMA.MEMBER_ID = detail.MEMBER_ID 
           AND ASMA.ACCOUNT_DESCRIPTION = 'D072_PRESTAMO CAJA DE AHORRO'
           AND ASMA.LOAN_ID = detail.LOAN_ID
           AND ASLT.MEMBER_ID = ASMA.MEMBER_ID
           AND ASLT.MEMBER_ACCOUNT_ID = ASMA.MEMBER_ACCOUNT_ID
         GROUP BY ASMA.MEMBER_ACCOUNT_ID;
         
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET DEBIT_BALANCE = var_debit_balance,
               CREDIT_BALANCE = var_credit_balance,
               FINAL_BALANCE = var_debit_balance - var_credit_balance 
         WHERE 1 = 1
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
        UPDATE ATET_SB_LOANS    ASL
           SET ASL.LOAN_STATUS_FLAG = 'ACTIVE',
               ASL.LOAN_BALANCE = var_debit_balance - var_credit_balance
         WHERE 1 = 1
           AND LOAN_ID = detail.LOAN_ID;
           
    END LOOP;

END;


COMMIT;





            SELECT ASM.MEMBER_ID,
                   ASM.PERSON_ID,
                   ASM.EMPLOYEE_NUMBER,
                   ASM.EMPLOYEE_FULL_NAME,
                   ASMA1.MEMBER_ACCOUNT_ID  AS SAVING_MEMBER_ACCOUNT_ID,
                   ASMA1.FINAL_BALANCE      AS SAVING_FINAL_BALANCE,
                   ASMA2.MEMBER_ACCOUNT_ID  AS INTEREST_MEMBER_ACCOUNT_ID,
                   ASMA2.FINAL_BALANCE       AS INTEREST_FINAL_BALANCE,
                   ASL.LOAN_ID,
                   ASL.LOAN_NUMBER,
                   ASMA3.FINAL_BALANCE,
                   SUM(ASPS.PAYMENT_AMOUNT) PAYMENTS_BALANCE,
                   ASL.LOAN_BALANCE
              FROM ATET_SB_MEMBERS          ASM,
                   ATET_SB_MEMBERS_ACCOUNTS ASMA1,
                   ATET_SB_MEMBERS_ACCOUNTS ASMA2,
                   ATET_SB_MEMBERS_ACCOUNTS ASMA3,
                   ATET_SB_LOANS            ASL,
                   ATET_SB_PAYMENTS_SCHEDULE ASPS
             WHERE 1 = 1
               AND ASL.MEMBER_ID = ASM.MEMBER_ID
               AND ASM.MEMBER_ID = ASMA1.MEMBER_ID
               AND ASMA1.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO'
               AND ASMA1.FINAL_BALANCE > 0
               AND ASM.MEMBER_ID = ASMA2.MEMBER_ID
               AND ASMA2.ACCOUNT_DESCRIPTION = 'INTERES GANADO'
               AND ASM.MEMBER_ID = ASMA3.MEMBER_ID
               AND ASMA3.ACCOUNT_DESCRIPTION LIKE 'D072%'
               AND ASMA3.LOAN_ID = ASL.LOAN_ID
               AND ASMA2.FINAL_BALANCE > 0
               AND ASL.LOAN_ID = ASPS.LOAN_ID
               AND ASPS.STATUS_FLAG = 'PENDING'
               AND ASM.SAVING_BANK_ID = ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
--               AND ASM.MEMBER_ID IN (1131, 1132, 1133, 1135, 1136, 1111, 1113, 1126, 1128, 1130)
             GROUP BY ASM.MEMBER_ID,
                       ASM.PERSON_ID,
                       ASM.EMPLOYEE_NUMBER,
                       ASM.EMPLOYEE_FULL_NAME,
                       ASMA1.MEMBER_ACCOUNT_ID,
                       ASMA1.FINAL_BALANCE,
                       ASMA2.MEMBER_ACCOUNT_ID,
                       ASMA2.FINAL_BALANCE,
                       ASL.LOAN_ID,
                       ASL.LOAN_NUMBER,
                       ASMA3.FINAL_BALANCE,
                       ASL.LOAN_BALANCE
             ORDER BY ASM.MEMBER_ID;