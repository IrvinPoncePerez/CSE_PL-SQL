/**************************************************/
/*                  ALTER SESION                  */
/**************************************************/
ALTER SESSION SET CURRENT_SCHEMA=APPS; 

SELECT ATP.P_PARTIAL_LOAN_ID,
       ASL.LOAN_ID,
       ASL.LOAN_NUMBER,
       ASL.LOAN_STATUS_FLAG,
       ASL.LOAN_BALANCE,
       ASMA.FINAL_BALANCE,
       SUM(ASLT.DEBIT_AMOUNT),
       SUM(ASLT.CREDIT_AMOUNT)
  FROM ATET_TMP_PREPAYMENT          ATP,
       ATET_SB_LOANS                ASL,
       ATET_SB_MEMBERS_ACCOUNTS     ASMA,
       ATET_SB_LOANS_TRANSACTIONS   ASLT
 WHERE 1 = 1
   AND ATP.P_PARTIAL_LOAN_ID = ASL.LOAN_ID
   AND ASL.LOAN_BALANCE <> 0
   AND ASL.LOAN_ID = ASMA.LOAN_ID
   AND ASL.LOAN_ID = ASLT.LOAN_ID
 GROUP BY ATP.P_PARTIAL_LOAN_ID,
       ASL.LOAN_ID,
       ASL.LOAN_NUMBER,
       ASL.LOAN_STATUS_FLAG,
       ASL.LOAN_BALANCE,
       ASMA.FINAL_BALANCE;
       
       
       
SELECT *
--                SUM(NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL)),
--                   SUM(NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST))
--              INTO var_asps_payment_capital,
--                   var_asps_payment_interest
              FROM ATET_SB_PAYMENTS_SCHEDULE ASPS
             WHERE 1 = 1
               AND ASPS.LOAN_ID = :P_LOAN_ID
--               AND ASPS.STATUS_FLAG IN ('PENDING',
--                                        'SKIP',
--                                        'PARTIAL');
             ORDER BY TIME_PERIOD_ID;
             
             
             
SELECT SUM(NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL))    DEBIT,
                   SUM(NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST)) CREDIT,
                    SUM(NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL)) + SUM(NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST)) BALANCE  
--              INTO var_asps_payment_capital,
--                   var_asps_payment_interest
              FROM ATET_SB_PAYMENTS_SCHEDULE ASPS
             WHERE 1 = 1
               AND ASPS.LOAN_ID = :P_LOAN_ID
               AND ASPS.STATUS_FLAG IN ('PENDING',
                                        'SKIP',
                                        'PARTIAL');
             
             
SELECT SUM(DEBIT_AMOUNT),
       SUM(CREDIT_AMOUNT),
       SUM(DEBIT_AMOUNT) - SUM(CREDIT_AMOUNT),
       SUM(PAYMENT_CAPITAL),
       SUM(PAYMENT_INTEREST)
  FROM ATET_SB_LOANS_TRANSACTIONS
 WHERE 1 = 1
   AND LOAN_ID = :P_LOAN_ID;
   
   
SELECT LOAN_BALANCE,
       LOAN_AMOUNT,
       LOAN_INTEREST_AMOUNT
  FROM ATET_SB_LOANS 
  WHERE 1 = 1 
    AND LOAN_ID = :P_LOAN_ID;
    
DECLARE
        
    P_LOAN_BALANCE            NUMBER;
    P_LOAN_AMOUNT             NUMBER;
    P_LOAN_INTEREST_AMOUNT    NUMBER;
    
    P_PAYMENT_CAPITAL         NUMBER;
    P_PAYMENT_INTEREST        NUMBER;

BEGIN

    SELECT LOAN_BALANCE,
           LOAN_AMOUNT,
           LOAN_INTEREST_AMOUNT
      INTO P_LOAN_BALANCE,
           P_LOAN_AMOUNT,
           P_LOAN_INTEREST_AMOUNT
      FROM ATET_SB_LOANS 
      WHERE 1 = 1 
        AND LOAN_ID = :P_LOAN_ID;
        
        
    UPDATE ATET_SB_PAYMENTS_SCHEDULE
      SET PAYMENT_AMOUNT = P_LOAN_BALANCE/4
     WHERE 1 = 1
       AND LOAN_ID = :P_LOAN_ID
       AND STATUS_FLAG = 'PENDING';

    COMMIT;
    
--    SELECT SUM(DEBIT_AMOUNT),
--           SUM(CREDIT_AMOUNT),
--           SUM(DEBIT_AMOUNT) - SUM(CREDIT_AMOUNT),
--           SUM(PAYMENT_CAPITAL),
--           SUM(PAYMENT_INTEREST)
      SELECT SUM(PAYMENT_CAPITAL),
             SUM(PAYMENT_INTEREST)
        INTO P_PAYMENT_CAPITAL,
             P_PAYMENT_INTEREST
      FROM ATET_SB_LOANS_TRANSACTIONS
     WHERE 1 = 1
       AND LOAN_ID = :P_LOAN_ID;
       
    UPDATE ATET_SB_PAYMENTS_SCHEDULE
      SET PAYMENT_CAPITAL = (P_LOAN_AMOUNT - P_PAYMENT_CAPITAL)/4,
          PAYMENT_INTEREST = (P_LOAN_INTEREST_AMOUNT-P_PAYMENT_INTEREST)/4
     WHERE 1 = 1
       AND LOAN_ID = :P_LOAN_ID
       AND STATUS_FLAG = 'PENDING';

    COMMIT;

END;

