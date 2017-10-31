ALTER SESSION SET CURRENT_SCHEMA=APPS;


/***********************************************************************/
/*          CONSULTA DE DIFERECNIA DE CENTAVOS EN       AHORRO         */
/***********************************************************************/
SELECT *
  FROM (
      
        SELECT ASM.MEMBER_ID,
               ASM.PERSON_ID,
               ASM.EMPLOYEE_NUMBER,
               ASM.EMPLOYEE_FULL_NAME,
               ASMA.FINAL_BALANCE,
               SUM(ASST.CREDIT_AMOUNT) - SUM(ASST.DEBIT_AMOUNT) AS ASST_BALANCE
          FROM ATET_SB_MEMBERS                  ASM,
               ATET_SB_SAVINGS_TRANSACTIONS     ASST,
               ATET_SB_MEMBERS_ACCOUNTS         ASMA
         WHERE 1 = 1
           AND ASM.SAVING_BANK_ID = 2
           AND ASM.MEMBER_ID = ASST.MEMBER_ID
           AND ASST.MEMBER_ACCOUNT_ID = ASMA.MEMBER_ACCOUNT_ID
           AND ASMA.MEMBER_ID = ASM.MEMBER_ID
           AND ASMA.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO'
         GROUP 
            BY ASM.MEMBER_ID,
               ASM.PERSON_ID,
               ASM.EMPLOYEE_NUMBER,
               ASM.EMPLOYEE_FULL_NAME,
               ASMA.FINAL_BALANCE
               
       )
 WHERE 1 = 1
   AND FINAL_BALANCE <> ASST_BALANCE;





/***********************************************************************/
/*          CONSULTA DE DIFERECNIA DE CENTAVOS EN       PRESTAMO       */
/***********************************************************************/
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
 WHERE 1 = 1;