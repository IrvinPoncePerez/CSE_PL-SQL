ALTER SESSION SET CURRENT_SCHEMA=APPS;

/*********************************************
    Consulta ATET_SB_SAVINGS_TRANSACTIONS
*********************************************/

SELECT *
  FROM (SELECT ASPR.PAYROLL_RESULT_ID,
               ASPR.PERIOD_NAME,
               ASPR.ELEMENT_NAME,
               ASPR.ENTRY_VALUE,
               ASST.SAVING_TRANSACTION_ID,
               ASST.PERIOD_NAME AS  PERIOD_NAME_ASST,
               ASST.ENTRY_VALUE AS ENTRY_VALUE_ASST
          FROM ATET_SB_PAYROLL_RESULTS  ASPR
          LEFT 
          JOIN ATET_SB_SAVINGS_TRANSACTIONS ASST
            ON ASST.PAYROLL_RESULT_ID = ASPR.PAYROLL_RESULT_ID
         WHERE 1 = 1
           AND ASPR.ENTRY_NAME = 'Pay Value'
           AND ASPR.PERIOD_NAME LIKE '%2017%'
           AND ASPR.ELEMENT_NAME = 'D071_CAJA DE AHORRO'
       )
 WHERE 1 = 1 
   AND SAVING_TRANSACTION_ID IS NULL;
   
/*********************************************
    Consulta ATET_SB_LOANS_TRANSACTIONS
*********************************************/   
   
SELECT *
  FROM (SELECT ASPR.PAYROLL_RESULT_ID,
               ASPR.PERIOD_NAME,
               ASPR.ELEMENT_NAME,
               ASPR.ENTRY_VALUE,
               ASLT.LOAN_TRANSACTION_ID,
               ASLT.PERIOD_NAME AS  PERIOD_NAME_ASST,
               ASLT.ENTRY_VALUE AS ENTRY_VALUE_ASST
          FROM ATET_SB_PAYROLL_RESULTS  ASPR
          LEFT 
          JOIN ATET_SB_LOANS_TRANSACTIONS ASLT
            ON ASLT.PAYROLL_RESULT_ID = ASPR.PAYROLL_RESULT_ID
         WHERE 1 = 1
           AND ASPR.ENTRY_NAME = 'Pay Value'
           AND ASPR.PERIOD_NAME LIKE '%2017%'
           AND ASPR.ELEMENT_NAME = 'D072_PRESTAMO CAJA DE AHORRO'
       )    
 WHERE 1 = 1
   AND LOAN_TRANSACTION_ID IS NULL;