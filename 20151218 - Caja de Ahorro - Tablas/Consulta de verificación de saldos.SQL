ALTER SESSION SET CURRENT_SCHEMA=APPS; 


SELECT ASM.EMPLOYEE_NUMBER,
       ASM.EMPLOYEE_FULL_NAME,
       ASM.PERSON_ID,
       C.LOAN_ID,
       C.MEMBER_ID,
       C.MEMBER_ACCOUNT_ID,
       C.LOAN_BALANCE,
       C.FINAL_BALANCE,
       (SUM(ASLT.DEBIT_AMOUNT)-SUM(ASLT.CREDIT_AMOUNT)) PAYMENTS_BALANCE,
       C.PAYMENT_AMOUNT,
       C.LOAN_STATUS_FLAG
  FROM (SELECT LOAN_ID,
               MEMBER_ID,
               MEMBER_ACCOUNT_ID,
               LOAN_BALANCE,
               FINAL_BALANCE,
               B.PAYMENT_AMOUNT,
               LOAN_STATUS_FLAG
          FROM (SELECT D.LOAN_ID,
                       D.MEMBER_ID,
                       D.LOAN_BALANCE,
                       D.LOAN_STATUS_FLAG,
                       D.MEMBER_ACCOUNT_ID,
                       D.FINAL_BALANCE,
                       SUM(NVL(ASPS.OWED_AMOUNT,ASPS.PAYMENT_AMOUNT))       AS  PAYMENT_AMOUNT,
                       SUM(NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL))    AS  PAYMENT_CAPITAL,
                       SUM(NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST))  AS  PAYMENT_INTEREST
                  FROM (SELECT ASL.LOAN_ID,
                               ASL.MEMBER_ID,
                               ASL.LOAN_BALANCE,
                               ASL.LOAN_STATUS_FLAG,
                               ASMA.MEMBER_ACCOUNT_ID,
                               ASMA.FINAL_BALANCE
                          FROM ATET_SB_LOANS            ASL,
                               ATET_SB_MEMBERS_ACCOUNTS ASMA
                         WHERE 1 = 1
                           AND ASL.LOAN_STATUS_FLAG NOT IN ('PAYED', 'CANCELED')
                           AND ASL.LOAN_ID = ASMA.LOAN_ID
                           AND ASL.MEMBER_ID = ASMA.MEMBER_ID
                       ) D,
                         ATET_SB_PAYMENTS_SCHEDULE      ASPS
                 WHERE 1 = 1
                   AND D.LOAN_BALANCE = D.FINAL_BALANCE
                   AND ASPS.LOAN_ID = D.LOAN_ID
                   AND ASPS.STATUS_FLAG NOT IN ('PAYED', 'REFINANCED')
                   AND ASPS.STATUS_FLAG IN ('PENDING', 'PARTIAL', 'SKIP')
                 GROUP BY D.LOAN_ID,
                          D.MEMBER_ID,
                          D.LOAN_BALANCE,
                          D.LOAN_STATUS_FLAG,
                          D.MEMBER_ACCOUNT_ID,
                          D.FINAL_BALANCE,
                          ASPS.LOAN_ID
               ) B  
         WHERE 1 = 1
           AND B.LOAN_BALANCE <> PAYMENT_AMOUNT
           AND B.FINAL_BALANCE <> PAYMENT_AMOUNT
       ) C,
       ATET_SB_LOANS_TRANSACTIONS   ASLT,
       ATET_SB_MEMBERS              ASM
 WHERE 1 = 1 
   AND C.LOAN_ID = ASLT.LOAN_ID
   AND C.MEMBER_ID = ASM.MEMBER_ID
 GROUP BY ASM.EMPLOYEE_NUMBER,
          ASM.EMPLOYEE_FULL_NAME,
          ASM.PERSON_ID,
          C.LOAN_ID,
          C.MEMBER_ID,
          C.MEMBER_ACCOUNT_ID,
          C.LOAN_BALANCE,
          C.FINAL_BALANCE,
          C.PAYMENT_AMOUNT,
          C.LOAN_STATUS_FLAG;
       
   
   
   
  
  
SELECT *
  FROM ATET_SB_LOANS
 WHERE 1 = 1
   AND LOAN_BALANCE = 0
   AND LOAN_STATUS_FLAG = 'ACTIVE';
   
   
   
   
   
   
SELECT ASM.MEMBER_ID,
       ASM.EMPLOYEE_NUMBER,
       ASL.LOAN_ID,
       ASL.LOAN_BALANCE
  FROM ATET_SB_LOANS        ASL,
       ATET_SB_MEMBERS      ASM
 WHERE 1 = 1
   AND ASL.MEMBER_ID = ASM.MEMBER_ID
   AND LOAN_BALANCE > 0
   AND LOAN_BALANCE < 1
   AND LOAN_STATUS_FLAG = 'ACTIVE'
 ORDER BY LOAN_BALANCE;
   
   
ATET_SB_PAYMENTS_SCHEDULE
ATET_SB_LOANS