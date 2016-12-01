/**************************************************/
/*                  ALTER SESION                  */
/**************************************************/
ALTER SESSION SET CURRENT_SCHEMA=APPS; 



/***************************************************/
/**
        Consulta de 
            ATET_XLA_LINES                         */
/***************************************************/
SELECT HEADER_ID,
       JOURNAL_NAME,
       ACCOUNTED_DR,
       ACCOUNTED_CR,
       ACCOUNTED_DR-ACCOUNTED_CR
  FROM (SELECT AXH.HEADER_ID,
               AXH.JOURNAL_NAME,
               SUM(ACCOUNTED_DR)    ACCOUNTED_DR,
               SUM(ACCOUNTED_CR)    ACCOUNTED_CR
          FROM ATET_XLA_LINES   AXL,
               ATET_XLA_HEADERS AXH
         WHERE 1 = 1
           AND AXL.HEADER_ID = AXH.HEADER_ID
         GROUP BY AXH.HEADER_ID,   
                  JOURNAL_NAME
        ) D
 WHERE 1 = 1 
   AND ACCOUNTED_DR <> ACCOUNTED_CR;
   
   
   
atet_sb_payments_schedule
atet_sb_loans
atet_sb_members_accounts
   
   
   
SELECT *
  FROM ATET_XLA_LINES
 WHERE HEADER_ID = :P_HEADER_ID;
   
   
 
 
 
 
SELECT AXH.HEADER_ID,
       ASM.EMPLOYEE_NUMBER||AXL.ACCOUNTED_DR,
       ASM.EMPLOYEE_NUMBER,
       SUBSTR(AXH.JOURNAL_NAME ,INSTR(AXH.JOURNAL_NAME, '-')+1) EMPLOYEE_NAME,
       AXL.ACCOUNTED_DR,
       AXL.SOURCE_ID,
       AXL.SOURCE_LINK_TABLE
  FROM ATET_XLA_HEADERS             AXH,
       ATET_XLA_LINES               AXL,
       ATET_SB_SAVINGS_TRANSACTIONS ASST,
       ATET_SB_MEMBERS              ASM
 WHERE 1 = 1
   AND AXH.HEADER_ID = AXL.HEADER_ID
   AND JOURNAL_NAME LIKE '%RETIRO DE CAJA DE AHORRO%'
   AND SOURCE_LINK_TABLE = 'ATET_SB_SAVINGS_TRANSACTIONS'
   AND AXL.SOURCE_ID = ASST.SAVING_TRANSACTION_ID
   AND ASST.MEMBER_ID = ASM.MEMBER_ID
--   AND JOURNAL_NAME NOT LIKE '%PRESTAMO CAJA DE AHORRO A%'
--   AND ACCOUNTING_CLASS_CODE IN ('REFINANCED_LOAN_CREATION','PREVIOUS_LOAN', 'REFINANCED_SUBSIDIZED')
 ORDER BY AXH.CREATION_DATE DESC;
   
   
 
 
/********************************************************/

SELECT *
  FROM ATET_SB_CHECKS_ALL   ASCA
 WHERE 1 = 1 
   AND ASCA.CHECK_NUMBER = 32196;