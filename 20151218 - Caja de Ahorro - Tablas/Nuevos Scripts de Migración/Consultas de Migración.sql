/**************************************************/
/*                  ALTER SESION                  */
/**************************************************/
ALTER SESSION SET CURRENT_SCHEMA=APPS; 



/****************************************************/
/*              CONSULTA DE MIEMBROS                */
/****************************************************/
SELECT ASM.EMPLOYEE_NUMBER,
       ASM.EMPLOYEE_FULL_NAME,
       ASM.EMPLOYEE_NUMBER,
       ASM.MEMBER_ID
  FROM ATET_SB_MEMBERS  ASM
 WHERE 1 = 1;
 
 
/*****************************************************************/
/*              CONSULTA DE PRESTAMOS Y SALDOS                   */ 
/*****************************************************************/ 
SELECT CONCAT(CONCAT(ASM.EMPLOYEE_NUMBER, 
                     ASM.MEMBER_ID), 
              ASL.LOAN_NUMBER)          AS KEY,
       ASM.EMPLOYEE_NUMBER,
       ASM.EMPLOYEE_FULL_NAME,
       ASL.MEMBER_ID,
       ASL.LOAN_ID,
       ASL.LOAN_NUMBER,
       ASL.LOAN_BALANCE,
       ASL.ATTRIBUTE3,
       ASL.LOAN_ID,
       ASL.LOAN_NUMBER,
       ASL.LOAN_BALANCE,
       ASL.LOAN_AMOUNT
  FROM ATET_SB_LOANS    ASL,
       ATET_SB_MEMBERS  ASM
 WHERE 1 = 1
   AND ASL.MEMBER_ID = ASM.MEMBER_ID;
   
   
/*****************************************************************/
/*      CONSULTA DE CUENTAS DE AHORRO Y SALDOS                   */
/*****************************************************************/   
   
SELECT ASM.EMPLOYEE_NUMBER,
       ASM.EMPLOYEE_FULL_NAME,
       ASMA.MEMBER_ACCOUNT_ID,
       ASMA.FINAL_BALANCE
  FROM ATET_SB_MEMBERS          ASM,
       ATET_SB_MEMBERS_ACCOUNTS ASMA
 WHERE 1 = 1
   AND ASM.MEMBER_ID = ASMA.MEMBER_ID
   AND ASMA.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO';
   
/*****************************************************************/
/*      CONSULTA DE RETIROS                                      */
/*****************************************************************/
   
 
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
 ORDER BY AXH.CREATION_DATE DESC;
 
 
   
/*****************************************************************/
/*      CONSULTA DE PAGOS ANTICIPADOS                            */
/*****************************************************************/
 
SELECT ASM.EMPLOYEE_NUMBER||ASL.LOAN_NUMBER,
       ASM.MEMBER_ID,
       ASM.EMPLOYEE_NUMBER,
       ASM.EMPLOYEE_FULL_NAME,
       ASL.LOAN_ID,
       ASL.LOAN_NUMBER,
       ASLT.CREDIT_AMOUNT
  FROM ATET_SB_LOANS_TRANSACTIONS   ASLT,
       ATET_SB_LOANS                ASL,
       ATET_SB_MEMBERS              ASM
 WHERE 1 = 1
   AND ASLT.LOAN_ID = ASL.LOAN_ID
   AND ASL.MEMBER_ID = ASM.MEMBER_ID
   AND ASLT.ELEMENT_NAME  NOT IN ('APERTURA DE PRESTAMO','D072_PRESTAMO CAJA DE AHORRO');
   
   
   
   
/*********************************************************************/
/***            Consulta de CHEQUES                                 **/
/*********************************************************************/


SELECT REPLACE(AXL.DESCRIPTION, 'NUMERO DE CHEQUE:  ', '')||REPLACE(AXH.JOURNAL_NAME, 'PRESTAMO CAJA DE AHORRO REFINANCIADO A: ', '') CLAVE,
       REPLACE(AXL.DESCRIPTION, 'NUMERO DE CHEQUE:  ', '') CHEQUE,
       REPLACE(AXH.JOURNAL_NAME, 'PRESTAMO CAJA DE AHORRO REFINANCIADO A: ', '') NOMBRE
  FROM ATET_XLA_HEADERS AXH,
       ATET_XLA_LINES   AXL
 WHERE 1 = 1
   AND EVENT_TYPE_CODE IN ('REFINANCED_LOAN_CREATION')
   AND AXH.HEADER_ID = AXL.HEADER_ID
   AND AXL.ACCOUNTING_CLASS_CODE IN ('REFINANCED_LOAN_CHECK');
   
   
   
   
/*********************************************************************/
/***            Consulta de BONIFICACIONES                          **/
/*********************************************************************/
SELECT D.ACCOUNTED_CR||D.NOMBRE  CLAVE,
       D.LOAN_NUMBER,
       D.NOMBRE,
       D.ACCOUNTED_DR,
       D.ACCOUNTED_CR,
       D.SOURCE_ID,
       D.SOURCE_LINK_TABLE
  FROM (SELECT ASL.LOAN_NUMBER,
               REPLACE(AXH.JOURNAL_NAME, 'PRESTAMO CAJA DE AHORRO REFINANCIADO A: ', '') NOMBRE,
               SUM(CASE WHEN AXL.ACCOUNTING_CLASS_CODE = 'INTEREST_EARN' THEN
                    ACCOUNTED_DR
                    END) ACCOUNTED_DR,
               SUM(CASE WHEN AXL.ACCOUNTING_CLASS_CODE = 'REFINANCED_SUBSIDIZED' THEN
                    ACCOUNTED_CR
               END) ACCOUNTED_CR,
               AXL.SOURCE_ID,
               AXL.SOURCE_LINK_TABLE
          FROM ATET_XLA_HEADERS AXH,
               ATET_XLA_LINES   AXL,
               ATET_SB_LOANS    ASL
         WHERE 1 = 1
           AND EVENT_TYPE_CODE IN ('REFINANCED_LOAN_CREATION')
           AND AXH.HEADER_ID = AXL.HEADER_ID
           AND AXL.ACCOUNTING_CLASS_CODE IN ('REFINANCED_SUBSIDIZED', 'INTEREST_EARN')
           AND AXL.SOURCE_ID = ASL.LOAN_ID
         GROUP BY ASL.LOAN_NUMBER,
                  AXH.JOURNAL_NAME,
                  AXL.SOURCE_ID,
                  AXL.SOURCE_LINK_TABLE
        ) D
 WHERE 1 = 1
   AND ACCOUNTED_DR <> ACCOUNTED_CR;