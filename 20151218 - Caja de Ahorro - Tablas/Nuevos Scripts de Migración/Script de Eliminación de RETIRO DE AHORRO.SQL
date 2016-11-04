ALTER SESSION SET CURRENT_SCHEMA=APPS; 


/******************************************/
/*  Consulta de ATET_SB_MEMBERS_ACCOUNTS
    Cuenta de Ahorro                      */
/******************************************/
SELECT *
  FROM ATET_SB_MEMBERS_ACCOUNTS
 WHERE MEMBER_ID = :P_MEMBER_ID
   AND LOAN_ID IS NULL
   AND ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO';
   

/**********************************************/
/*  Consulta de ATET_SB_SAVINGS_TRANSACTIONS
    Movimiento de Ahorro                     **/
/**********************************************/
SELECT *
  FROM ATET_SB_SAVINGS_TRANSACTIONS
 WHERE 1 = 1 
   AND MEMBER_ID = :P_MEMBER_ID
   AND MEMBER_ACCOUNT_ID = :P_MEMBER_ACCOUNT_ID; 
   
   
DECLARE 
    var_header_id               ATET_XLA_LINES.HEADER_ID%TYPE;
    var_saving_transaction_id   ATET_SB_SAVINGS_TRANSACTIONS.SAVING_TRANSACTION_ID%TYPE := :P_SAVING_TRANSACTION_ID;
    var_member_id               ATET_SB_SAVINGS_TRANSACTIONS.MEMBER_ID%TYPE := :P_MEMBER_ID;
    var_member_account_id       ATET_SB_SAVINGS_TRANSACTIONS.MEMBER_ACCOUNT_ID%TYPE := :P_MEMBER_ACCOUNT_ID; 
    var_debit_amount            ATET_SB_SAVINGS_TRANSACTIONS.DEBIT_AMOUNT%TYPE;
    var_credit_amount           ATET_SB_SAVINGS_TRANSACTIONS.CREDIT_AMOUNT%TYPE;
BEGIN

    SELECT HEADER_ID
      INTO var_header_id
      FROM ATET_XLA_LINES
     WHERE SOURCE_ID = var_saving_transaction_id
       AND SOURCE_LINK_TABLE = 'ATET_SB_SAVINGS_TRANSACTIONS';
       
       
    DELETE FROM ATET_XLA_LINES
     WHERE 1 = 1
       AND HEADER_ID = var_header_id;
       
    DELETE FROM ATET_XLA_HEADERS
     WHERE 1 = 1
       AND HEADER_ID = var_header_id;
       
    DELETE FROM ATET_SB_SAVINGS_TRANSACTIONS
     WHERE 1 = 1
       AND SAVING_TRANSACTION_ID = var_saving_transaction_id;
       
       
    SELECT SUM(DEBIT_AMOUNT),
           SUM(CREDIT_AMOUNT)
      INTO var_debit_amount,
           var_credit_amount
      FROM ATET_SB_SAVINGS_TRANSACTIONS
     WHERE 1 = 1 
       AND MEMBER_ID = var_member_id
       AND MEMBER_ACCOUNT_ID = var_member_account_id;
       
       
    UPDATE ATET_SB_MEMBERS_ACCOUNTS
       SET DEBIT_BALANCE = var_debit_amount,
           CREDIT_BALANCE = var_credit_amount,
           FINAL_BALANCE = var_credit_amount - var_debit_amount
     WHERE 1 = 1
       AND MEMBER_ID = var_member_id
       AND MEMBER_ACCOUNT_ID = var_member_account_id;
       
       
    COMMIT;

END;      