SELECT ASM.EMPLOYEE_NUMBER,
       ASM.EMPLOYEE_FULL_NAME,
       D.*
  FROM ( 
        SELECT ASL.LOAN_ID,
               ASL.MEMBER_ID,
               ASL.LOAN_BALANCE,
               ASMA.FINAL_BALANCE,
               (CASE
                    WHEN ASL.LOAN_BALANCE = ASMA.FINAL_BALANCE THEN
                        'SI'
                    ELSE
                        'NO'
                END)    VALIDACION, 
               SUM(NVL(ASPS.OWED_AMOUNT, ASPS.PAYMENT_AMOUNT)) ASPS_BALANCE,
               (CASE
                    WHEN ASL.LOAN_BALANCE = ASMA.FINAL_BALANCE AND ASL.LOAN_BALANCE = SUM(NVL(ASPS.OWED_AMOUNT, ASPS.PAYMENT_AMOUNT)) THEN
                        'SI'
                    ELSE
                    
                        'NO'
                END) SEGUNDA_VALIDACION,
               (ASL.LOAN_BALANCE - SUM(NVL(ASPS.OWED_AMOUNT, ASPS.PAYMENT_AMOUNT))) DIFERENCIA  
          FROM ATET_SB_LOANS                ASL,
               ATET_SB_MEMBERS_ACCOUNTS     ASMA,
               ATET_SB_PAYMENTS_SCHEDULE    ASPS
         WHERE 1 = 1
           AND ASL.LOAN_ID = ASMA.LOAN_ID
           AND ASL.LOAN_ID = ASPS.LOAN_ID
           AND ASPS.STATUS_FLAG NOT IN ('PAYED', 'REFINANCED')
         GROUP BY ASL.LOAN_ID,
                  ASL.MEMBER_ID,
                  ASL.LOAN_BALANCE,
                  ASMA.FINAL_BALANCE
        ) D,
       ATET_SB_MEMBERS      ASM
 WHERE 1 = 1
   AND ASM.MEMBER_ID = D.MEMBER_ID
   AND (D.VALIDACION = 'NO' OR D.SEGUNDA_VALIDACION = 'NO');   
        
   
   
/***************************************************************/
/*                   revisión de prestamos                     */
/***************************************************************/
SELECT DISTINCT
       ASM.EMPLOYEE_NUMBER,
       ASM.EMPLOYEE_FULL_NAME,
       ASPS.STATUS_FLAG,
       ASPS.LOAN_ID
  FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS,
       ATET_SB_LOANS                ASL,
       ATET_SB_MEMBERS              ASM
 WHERE 1 = 1
   AND ASPS.LOAN_ID = ASL.LOAN_ID
   AND ASL.MEMBER_ID = ASM.MEMBER_ID
   AND ASPS.STATUS_FLAG <> 'PENDING'
   AND ASPS.PERIOD_NAME LIKE '%Semana'
   AND PERIOD_NUMBER > 14;
   
   
/***********************************************/

SELECT ASM.EMPLOYEE_NUMBER,
       ASM.EMPLOYEE_FULL_NAME,
       ASL.LOAN_ID,
       ASL.TRANSACTION_DATE,
       TO_CHAR(ASL.TRANSACTION_DATE, 'DAY')
  FROM ATET_SB_LOANS                ASL,
       ATET_SB_MEMBERS              ASM,
       ATET_SB_PAYMENTS_SCHEDULE    ASPS
 WHERE 1 = 1
   AND ASL.MEMBER_ID = ASM.MEMBER_ID
   AND ASL.LOAN_ID = ASPS.LOAN_ID
   AND ASPS.PAYMENT_NUMBER = 1
   AND ASL.TRANSACTION_DATE <> ASPS.PAYMENT_DATE
   AND TO_CHAR(ASL.TRANSACTION_DATE, 'DAY') LIKE '%MONDAY%'
   AND ASPS.PERIOD_NAME LIKE '%Semana%';


/***********************************************/


SELECT ASM.EMPLOYEE_NUMBER,
       ASM.EMPLOYEE_FULL_NAME,
       ASL.LOAN_ID,
       ASL.TRANSACTION_DATE,
       TO_CHAR(ASL.TRANSACTION_DATE, 'DAY')
  FROM ATET_SB_LOANS                ASL,
       ATET_SB_MEMBERS              ASM,
       ATET_SB_PAYMENTS_SCHEDULE    ASPS
 WHERE 1 = 1
   AND ASL.MEMBER_ID = ASM.MEMBER_ID
   AND ASL.LOAN_ID = ASPS.LOAN_ID
   AND ASPS.PAYMENT_NUMBER = (SELECT MAX(ASPS1.PAYMENT_NUMBER)
                                FROM ATET_SB_PAYMENTS_SCHEDULE ASPS1
                               WHERE 1 = 1
                                 AND ASPS1.LOAN_ID = ASL.LOAN_ID)
   AND ASL.PAYMENT_DEADLINE <> ASPS.PAYMENT_DATE
   AND ASPS.PERIOD_NAME LIKE '%Semana%'
   AND TO_CHAR(ASL.TRANSACTION_DATE, 'DAY') LIKE '%MONDAY%';   
    
   
/***********************************************/