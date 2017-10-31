ALTER SESSION SET CURRENT_SCHEMA=APPS;





SELECT *
  FROM (
        SELECT *
          FROM (
          
                SELECT ASM.MEMBER_ID,
                       ASM.PERSON_ID,
                       ASM.EMPLOYEE_NUMBER,
                       ASM.EMPLOYEE_FULL_NAME,
                       ASL.TRANSACTION_DATE,
                       ASL.LOAN_ID,
                       ASL.LOAN_NUMBER,
                       ASL.LOAN_BALANCE,
                       ASMA.FINAL_BALANCE,
                       SUM(NVL(ASPS.OWED_AMOUNT, ASPS.PAYMENT_AMOUNT)) - SUM(ASPS.PAYMENT_INTEREST_LATE)   ASPS_BALANCE,
                       SUM(NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL) +
                           NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST) ) ASPS_PAYMENT_BALANCE
                  FROM ATET_SB_MEMBERS                  ASM,
                       ATET_SB_LOANS                    ASL,
                       ATET_SB_MEMBERS_ACCOUNTS         ASMA,
                       ATET_SB_PAYMENTS_SCHEDULE        ASPS
                 WHERE 1 = 1
                   AND ASM.SAVING_BANK_ID = 2
                   AND ASM.MEMBER_ID = ASL.MEMBER_ID
                   AND ASMA.MEMBER_ID = ASM.MEMBER_ID
                   AND ASMA.LOAN_ID = ASL.LOAN_ID
                   AND ASPS.LOAN_ID = ASL.LOAN_ID
                   AND ASPS.STATUS_FLAG IN ('SKIP',
                                            'PARTIAL',
                                            'PENDING',
                                            'EXPORTED')
                 GROUP 
                    BY ASM.MEMBER_ID,
                       ASM.PERSON_ID,
                       ASM.EMPLOYEE_NUMBER,
                       ASM.EMPLOYEE_FULL_NAME,
                       ASL.TRANSACTION_DATE,
                       ASL.LOAN_ID,
                       ASL.LOAN_NUMBER,
                       ASL.LOAN_BALANCE,
                       ASMA.FINAL_BALANCE,
                       ASL.LOAN_TOTAL_AMOUNT
               
               ) DET
         WHERE 1 = 1
           AND (   
                   DET.LOAN_BALANCE <> DET.FINAL_BALANCE
                OR DET.LOAN_BALANCE <> DET.ASPS_BALANCE
                OR DET.LOAN_BALANCE <> DET.ASPS_PAYMENT_BALANCE
                OR DET.FINAL_BALANCE <> DET.ASPS_BALANCE
                OR DET.FINAL_BALANCE <> DET.ASPS_PAYMENT_BALANCE
                OR DET.ASPS_BALANCE <> DET.ASPS_PAYMENT_BALANCE)
       )DET2
 WHERE 1 = 1
             
    ;
    
    
    
   
SELECT ASL.LOAN_ID,
       ASL.MEMBER_ID,
       ASL.LOAN_TOTAL_AMOUNT,
       ASL.LOAN_AMOUNT,
       ASL.LOAN_INTEREST_AMOUNT,
       ASL.TERM_PERIODS,
       ASL.LOAN_BALANCE,
       ASL.ATTRIBUTE1,
       ASL.TRANSACTION_DATE
  FROM ATET_SB_LOANS    ASL
 WHERE 1 = 1
   AND LOAN_ID = :P_LOAN_ID;
   
   
SELECT ASMA.DEBIT_BALANCE,
       ASMA.CREDIT_BALANCE,
       ASMA.FINAL_BALANCE
  FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
 WHERE 1 = 1
   AND LOAN_ID = :P_LOAN_ID;
   
  
   
   
SELECT SUM(ASLT.DEBIT_AMOUNT)           DEBIT_AMOUNT,
       SUM(ASLT.CREDIT_AMOUNT)          CREDIT_AMOUNT,
       SUM(ASLT.PAYMENT_AMOUNT)         PAYMENT_AMOUNT,
       SUM(ASLT.PAYMENT_CAPITAL)        PAYMENT_CAPITAL,
       SUM(ASLT.PAYMENT_INTEREST)       PAYMENT_INTEREST,
       SUM(ASLT.PAYMENT_INTEREST_LATE)  PAYMENT_INTEREST_LATE
  FROM ATET_SB_LOANS_TRANSACTIONS   ASLT
 WHERE 1 = 1
   AND LOAN_ID = :P_LOAN_ID;
   
   
ATET_SB_LOANS_TRANSACTIONS   
ATET_SB_PAYMENTS_SCHEDULE
ATET_SB_LOANS