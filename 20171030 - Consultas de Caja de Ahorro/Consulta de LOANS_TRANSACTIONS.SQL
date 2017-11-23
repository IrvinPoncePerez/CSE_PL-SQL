ALTER SESSION SET CURRENT_SCHEMA=APPS;



SELECT *
  FROM (
        SELECT ASM.EMPLOYEE_NUMBER,
               ASM.EMPLOYEE_FULL_NAME,
               ASL.LOAN_ID,
               ASLT.LOAN_TRANSACTION_ID,
               ASLT.DEBIT_AMOUNT,
               ASLT.CREDIT_AMOUNT,
               ASLT.ELEMENT_NAME,
               ASLT.TRANSACTION_CODE,
               ASLT.PAYMENT_AMOUNT,
               ASLT.PAYMENT_CAPITAL + 
               ASLT.PAYMENT_INTEREST+
               ASLT.PAYMENT_INTEREST_LATE   AS  AMOUNT,
               ASLT.PAYMENT_CAPITAL,
               ASLT.PAYMENT_INTEREST,
               ASLT.PAYMENT_INTEREST_LATE
          FROM ATET_SB_LOANS_TRANSACTIONS   ASLT,
               ATET_SB_MEMBERS              ASM,
               ATET_SB_LOANS                ASL
         WHERE 1 = 1
           AND ASM.MEMBER_ID = ASLT.MEMBER_ID
           AND ASL.LOAN_ID = ASLT.LOAN_ID
           AND ASL.MEMBER_ID = ASM.MEMBER_ID
           AND ASM.SAVING_BANK_ID = 2
       ) D
 WHERE 1 = 1 
   AND (   D.PAYMENT_AMOUNT <> D.AMOUNT
        OR D.PAYMENT_AMOUNT <> D.CREDIT_AMOUNT);
        
        
ATET_SB_LOANS_TRANSACTIONS
ATET_SB_PAYMENTS_SCHEDULE
ATET_SB_LOANS


SELECT ASLT.*
  FROM ATET_SB_LOANS_TRANSACTIONS       ASLT,
       ATET_SB_MEMBERS                  ASM,
       ATET_SB_LOANS                    ASL
 WHERE 1 = 1
   AND ASM.MEMBER_ID = ASL.MEMBER_ID
   AND ASLT.MEMBER_ID = ASM.MEMBER_ID
   AND ASLT.LOAN_ID = ASL.LOAN_ID
   AND ASM.SAVING_BANK_ID = 2
   AND (   ASLT.PAYMENT_AMOUNT IS NULL
        OR ASLT.PAYMENT_CAPITAL IS NULL
        OR ASLT.PAYMENT_INTEREST IS NULL
        OR ASLT.PAYMENT_INTEREST_LATE IS NULL)
   AND ASLT.ELEMENT_NAME NOT IN ('APERTURA DE PRESTAMO')
   AND ASLT.TRANSACTION_CODE NOT IN ('OPENING');
   
   
   
   
--SELECT SUM(NVL(ASPS.OWED_AMOUNT, ASPS.PAYMENT_AMOUNT))                  AMOUNT,
--       SUM(NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL))                CAPITAL,
--       SUM(NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST))              INTEREST,
--       SUM(NVL(ASPS.OWED_INTEREST_LATE, ASPS.PAYMENT_INTEREST_LATE))    INTEREST_LATE
--  FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
-- WHERE 1 = 1
--   AND ASPS.LOAN_ID = :P_LOAN_ID
--   AND ASPS.ATTRIBUTE6 = 'PREPAID';
--   
   
--   
--DECLARE

--    var_payment_amount          NUMBER;
--    var_payment_capital         NUMBER;
--    var_payment_interest        NUMBER;
--    var_payment_interest_late   NUMBER;
--    
--    CURSOR  DETAILS
--    IS
--    SELECT ASLT.LOAN_ID,
--           ASLT.LOAN_TRANSACTION_ID
--      FROM ATET_SB_LOANS_TRANSACTIONS       ASLT,
--           ATET_SB_MEMBERS                  ASM,
--           ATET_SB_LOANS                    ASL
--     WHERE 1 = 1
--       AND ASM.MEMBER_ID = ASL.MEMBER_ID
--       AND ASLT.MEMBER_ID = ASM.MEMBER_ID
--       AND ASLT.LOAN_ID = ASL.LOAN_ID
--       AND ASM.SAVING_BANK_ID = 2
--       AND (   ASLT.PAYMENT_AMOUNT IS NULL
--            OR ASLT.PAYMENT_CAPITAL IS NULL
--            OR ASLT.PAYMENT_INTEREST IS NULL
--            OR ASLT.PAYMENT_INTEREST_LATE IS NULL)
--       AND ASLT.ELEMENT_NAME NOT IN ('APERTURA DE PRESTAMO')
--       AND ASLT.TRANSACTION_CODE NOT IN ('OPENING');
--    


--BEGIN


--    FOR DET IN DETAILS LOOP
--    
--        var_payment_amount          := 0;
--        var_payment_capital         := 0;
--        var_payment_interest        := 0;
--        var_payment_interest_late   := 0;
--        
--        
--        
--        
--    
--        SELECT SUM(NVL(ASPS.OWED_AMOUNT, ASPS.PAYMENT_AMOUNT))                  AMOUNT,
--               SUM(NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL))                CAPITAL,
--               SUM(NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST))              INTEREST,
--               SUM(NVL(ASPS.OWED_INTEREST_LATE, ASPS.PAYMENT_INTEREST_LATE))    INTEREST_LATE
--          INTO var_payment_amount,
--               var_payment_capital,
--               var_payment_interest,
--               var_payment_interest_late
--          FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
--         WHERE 1 = 1
--           AND ASPS.LOAN_ID = DET.LOAN_ID
--           AND ASPS.ATTRIBUTE6 = 'PREPAID';
--           
--           
--           
--    
--        UPDATE ATET_SB_LOANS_TRANSACTIONS  ASLT
--           SET ASLT.PAYMENT_AMOUNT = var_payment_amount,
--               ASLT.PAYMENT_CAPITAL = var_payment_capital,
--               ASLT.PAYMENT_INTEREST = var_payment_interest,
--               ASLT.PAYMENT_INTEREST_LATE = var_payment_interest_late
--         WHERE 1 = 1
--           AND ASLT.LOAN_ID = DET.LOAN_ID
--           AND ASLT.LOAN_TRANSACTION_ID = DET.LOAN_TRANSACTION_ID;
--    
--    
--    END LOOP;


--END;



--COMMIT;





--SELECT ASMA.*
--  FROM ATET_SB_MEMBERS              ASM,
--       ATET_SB_MEMBERS_ACCOUNTS     ASMA
-- WHERE 1 = 1
--   AND ASM.SAVING_BANK_ID = 2
--   AND ASM.MEMBER_ID = ASMA.MEMBER_ID
--   AND FINAL_BALANCE < 2
--   AND FINAL_BALANCE > 0