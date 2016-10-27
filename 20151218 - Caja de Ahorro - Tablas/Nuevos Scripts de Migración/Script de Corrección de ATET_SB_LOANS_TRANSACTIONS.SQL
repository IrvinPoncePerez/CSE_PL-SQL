/**************************************************/
/*                  ALTER SESION                  */
/**************************************************/
ALTER SESSION SET CURRENT_SCHEMA=APPS;


/**********************************************************/
/*          Insert ATET_SB_LOANS_TRANSACTIONS
            de apertura.                                  */
/**********************************************************/

SELECT ASL.LOAN_ID,
                   ASL.LOAN_TOTAL_AMOUNT,
                   ASM.PERSON_ID,
                   ASM.MEMBER_ID
              FROM ATET_SB_LOANS    ASL,
                   ATET_SB_MEMBERS  ASM
             WHERE 1 = 1
               AND ASL.MEMBER_ID = ASM.MEMBER_ID;

DECLARE
    
    CURSOR  LOANS_DETAILS   IS
            SELECT ASL.LOAN_ID,
                   ASL.LOAN_TOTAL_AMOUNT,
                   ASM.PERSON_ID,
                   ASM.MEMBER_ID,
                   ASL.TRANSACTION_DATE
              FROM ATET_SB_LOANS    ASL,
                   ATET_SB_MEMBERS  ASM
             WHERE 1 = 1
               AND ASL.MEMBER_ID = ASM.MEMBER_ID ; 
               
    var_member_account_id   NUMBER;                
                          

BEGIN

    FOR C_LOAN IN LOANS_DETAILS LOOP
    
    
        var_member_account_id := ATET_SAVINGS_BANK_PKG.GET_LOAN_MEMBER_ACCOUNT_ID
                                (ATET_SAVINGS_BANK_PKG.GET_MEMBER_ID(C_LOAN.PERSON_ID), 
                                    C_LOAN.LOAN_ID);

        INSERT INTO ATET_SB_LOANS_TRANSACTIONS(MEMBER_ACCOUNT_ID,
                                               MEMBER_ID,
                                               PAYROLL_RESULT_ID,
                                               LOAN_ID,
                                               PERSON_ID,
                                               EARNED_DATE,
                                               PERIOD_NAME,
                                               ELEMENT_NAME,
                                               TRANSACTION_CODE,
                                               DEBIT_AMOUNT,
                                               CREDIT_AMOUNT,
                                               ACCOUNTED_FlAG,
                                               CREATION_DATE,
                                               CREATED_BY,
                                               LAST_UPDATE_DATE,
                                               LAST_UPDATED_BY)
                                       VALUES (var_member_account_id,
                                               C_LOAN.MEMBER_ID,
                                               -1,
                                               C_LOAN.LOAN_ID,
                                               C_LOAN.PERSON_ID,
                                               C_LOAN.TRANSACTION_DATE,
                                               'APERTURA',
                                               'APERTURA DE PRESTAMO',
                                               'OPENING',
                                               C_LOAN.LOAN_TOTAL_AMOUNT,
                                               0,
                                               'ACCOUNTED',
                                               C_LOAN.TRANSACTION_DATE,
                                               -1,
                                               C_LOAN.TRANSACTION_DATE,
                                               -1);
        
    END LOOP;	

END;

/***************************************************/
--ATET_SB_LOANS_TRANSACTIONS
--ATET_SB_PAYMENTS_SCHEDULE
--COMMIT;

DECLARE

    VAR_DEBIT_AMOUNT        NUMBER;   
    VAR_CREDIT_AMOUNT       NUMBER;

BEGIN
    SELECT SUM(DEBIT_AMOUNT),
           SUM(CREDIT_AMOUNT)
      INTO VAR_DEBIT_AMOUNT,
           VAR_CREDIT_AMOUNT
      FROM ATET_SB_LOANS_TRANSACTIONS
     WHERE 1 = 1
       AND LOAN_ID = :P_LOAN_ID
       AND MEMBER_ID = :P_MEMBER_ID;
       
       
       
       
    UPDATE ATET_SB_MEMBERS_ACCOUNTS
       SET DEBIT_BALANCE = VAR_DEBIT_AMOUNT,
           CREDIT_BALANCE = VAR_CREDIT_AMOUNT,
           FINAL_BALANCE = VAR_DEBIT_AMOUNT - VAR_CREDIT_AMOUNT
     WHERE 1 = 1
       AND LOAN_ID = :P_LOAN_ID
       AND MEMBER_ID = :P_MEMBER_ID;
       
       
       
       
    UPDATE ATET_SB_LOANS
       SET LOAN_BALANCE = VAR_DEBIT_AMOUNT - VAR_CREDIT_AMOUNT
     WHERE 1 = 1
       AND LOAN_ID = :P_LOAN_ID
       AND MEMBER_ID = :P_MEMBER_ID;
    
    
    
    COMMIT;
END;
       