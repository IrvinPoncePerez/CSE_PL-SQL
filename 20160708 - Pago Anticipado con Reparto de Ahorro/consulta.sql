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
               AND ASMA2.FINAL_BALANCE > 0
               AND ASL.LOAN_ID = ASPS.LOAN_ID
               AND ASPS.STATUS_FLAG = 'PENDING'
               AND ASM.SAVING_BANK_ID = ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
               AND ASM.MEMBER_ID IN (1131, 1132, 1133, 1135, 1136, 1111, 1113, 1126, 1128, 1130)
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
               ;
               
               
               ATET_SB_SAVINGS_TRANSACTIONS
               ATET_SB_LOANS_TRANSACTIONS
               ATET_SB_MEMBERS_ACCOUNTS
               ATET_SB_PAYMENTS_SCHEDULE
               
               SELECT ASM.EMPLOYEE_NUMBER,
                      ASM.EMPLOYEE_FULL_NAME,
                      ASM.MEMBER_ID
               FROM ATET_SB_MEMBERS ASM
               WHERE 1 = 1
                 AND ASM.PERSON_ID IN (3842, 5079, 3127, 2425, 2449);
                 
                 
                 