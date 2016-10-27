/**************************************************/
/*                  ALTER SESION                  */
/**************************************************/
ALTER SESSION SET CURRENT_SCHEMA=APPS; 


/**********************************************************/
/*              ACTUALIZACIÓN DE PRESTAMOS                */
/**********************************************************/

UPDATE APPS.ATET_SB_LOANS    ASL
   SET ASL.LOAN_INTEREST_RATE = ASL.LOAN_INTEREST_RATE * ASL.NORMAL_INTEREST_RATE
 WHERE ASL.LOAN_STATUS_FLAG = 'ENTERED';

UPDATE APPS.ATET_SB_LOANS    ASL 
   SET ASL.CREATION_DATE = SYSDATE,
       ASL.CREATED_BY = -1,
       ASL.LAST_UPDATE_DATE = SYSDATE,
       ASL.LAST_UPDATED_BY = -1,
       ASL.LOAN_STATUS_FLAG = 'APPROVED'
 WHERE ASL.LOAN_STATUS_FLAG = 'ENTERED';
 
SELECT *
  FROM ATET_SB_LOANS;
  
  
--COMMIT;


/**********************************************************/
/*          ACTUALIZACION DE TABLA DE AVALES              */
/**********************************************************/

UPDATE ATET_SB_ENDORSEMENTS ASE
   SET ASE.CREATION_DATE = SYSDATE,
       ASE.CREATED_BY = -1,
       ASE.LAST_UPDATE_DATE = SYSDATE,
       ASE.LAST_UPDATED_BY = -1,
       ASE.ENDORSEMENT_FLAG = 'ACTIVE';
       
SELECT *
  FROM ATET_SB_ENDORSEMENTS;        
       
--COMMIT;

/**********************************************************/
/*          ACTUALIZACION DE TABLA DE MIEMBROS            */
/**********************************************************/

UPDATE APPS.ATET_SB_MEMBERS  ASM
   SET ASM.IS_BORROWER = 'N',
       ASM.IS_ENDORSEMENT = 'N';
       
--COMMIT;

MERGE INTO ATET_SB_MEMBERS      ASM
     USING (SELECT DISTINCT 
                   ASE.MEMBER_ENDORSEMENT_ID
              FROM ATET_SB_ENDORSEMENTS ASE,
                   ATET_SB_LOANS        ASL
             WHERE ASE.LOAN_ID = ASL.LOAN_ID
               AND ASL.LOAN_STATUS_FLAG = 'APPROVED') ASE
        ON (ASE.MEMBER_ENDORSEMENT_ID = ASM.MEMBER_ID)
WHEN MATCHED THEN 
UPDATE SET ASM.IS_ENDORSEMENT = 'Y',
           ASM.LAST_UPDATE_DATE = SYSDATE,
           ASM.LAST_UPDATED_BY = -1;
           
--COMMIT;

MERGE INTO ATET_SB_MEMBERS      ASM
     USING (SELECT DISTINCT
                   ASE.MEMBER_BORROWER_ID 
              FROM ATET_SB_ENDORSEMENTS ASE,
                   ATET_SB_LOANS        ASL
             WHERE 1 = 1
               AND ASE.LOAN_ID = ASL.LOAN_ID
               AND ASL.LOAN_STATUS_FLAG = 'APPROVED' ) ASE
        ON (ASE.MEMBER_BORROWER_ID = ASM.MEMBER_ID)
WHEN MATCHED THEN 
UPDATE SET ASM.IS_BORROWER = 'Y',
           ASM.LAST_UPDATE_DATE = SYSDATE,
           ASM.LAST_UPDATED_BY = -1;

--COMMIT;

SELECT *
FROM ATET_SB_MEMBERS;

SELECT *
FROM ATET_SB_ENDORSEMENTS;

/**********************************************************/
/*            CREACIÓN DE CUENTAS DE PRESTAMOS            */
/**********************************************************/

SELECT ASM.PERSON_ID,
                  ASM.MEMBER_ID,
                  ASL.LOAN_ID
             FROM APPS.ATET_SB_MEMBERS   ASM,
                  APPS.ATET_SB_LOANS     ASL
            WHERE 1 = 1
              AND ASM.MEMBER_ID = ASL.MEMBER_ID
              AND ASL.LOAN_STATUS_FLAG = 'APPROVED' ;

DECLARE
    CURSOR MEMBERS_DETAILS  IS
           SELECT ASM.PERSON_ID,
                  ASM.MEMBER_ID,
                  ASL.LOAN_ID
             FROM ATET_SB_MEMBERS   ASM,
                  ATET_SB_LOANS     ASL
            WHERE 1 = 1
              AND ASM.MEMBER_ID = ASL.MEMBER_ID
              AND ASL.LOAN_STATUS_FLAG = 'APPROVED' ;                  
BEGIN
    
    FOR C_MEMBER IN MEMBERS_DETAILS LOOP

        IF ATET_SAVINGS_BANK_PKG.GET_MEMBER_IS_SAVER(C_MEMBER.MEMBER_ID) = 'Y' THEN
                 
            INSERT INTO ATET_SB_MEMBERS_ACCOUNTS(MEMBER_ID,
                                                 LOAN_ID,
                                                 CODE_COMBINATION_ID,
                                                 ACCOUNT_NUMBER,
                                                 ACCOUNT_DESCRIPTION,
                                                 DEBIT_BALANCE,
                                                 CREDIT_BALANCE,
                                                 FINAL_BALANCE,
                                                 CREATION_DATE,
                                                 CREATED_BY,
                                                 LAST_UPDATE_DATE,
                                                 LAST_UPDATED_BY)
                                         VALUES (C_MEMBER.MEMBER_ID,
                                                 C_MEMBER.LOAN_ID,
                                                 ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID(ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID, 'LOAN_SAV_CODE_COMB')),
                                                 ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID, 'LOAN_SAV_CODE_COMB'),
                                                 ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME'),
                                                 0,
                                                 0,
                                                 0,
                                                 SYSDATE,
                                                 -1,
                                                 SYSDATE,
                                                 -1);

        ELSE
           
            INSERT INTO ATET_SB_MEMBERS_ACCOUNTS(MEMBER_ID,
                                                 LOAN_ID,
                                                 CODE_COMBINATION_ID,
                                                 ACCOUNT_NUMBER,
                                                 ACCOUNT_DESCRIPTION,
                                                 DEBIT_BALANCE,
                                                 CREDIT_BALANCE,
                                                 FINAL_BALANCE,
                                                 CREATION_DATE,
                                                 CREATED_BY,
                                                 LAST_UPDATE_DATE,
                                                 LAST_UPDATED_BY)
                                         VALUES (C_MEMBER.MEMBER_ID,
                                                 C_MEMBER.LOAN_ID,
                                                 ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID(ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID, 'LOAN_NO_SAV_CODE_COMB')),
                                                 ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID, 'LOAN_NO_SAV_CODE_COMB'),
                                                 ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME'),
                                                 0,
                                                 0,
                                                 0,
                                                 SYSDATE,
                                                 -1,
                                                 SYSDATE,
                                                 -1);
                        
                
        END IF;
        
--        COMMIT;
    
    END LOOP;   

END;

SELECT *
FROM ATET_SB_MEMBERS_ACCOUNTS
WHERE ACCOUNT_DESCRIPTION = 'D072_PRESTAMO CAJA DE AHORRO'
AND DEBIT_BALANCE = 0;

SELECT *
FROM ATET_SB_LOANS
WHERE 1 = 1
AND LOAN_STATUS_FLAG = 'APPROVED';

--COMMIT;

/**********************************************************/
/*            CREACIÓN DE CUENTAS DE AHORRO               */
/**********************************************************/

SELECT ASM.EMPLOYEE_NUMBER,
                  ASM.EMPLOYEE_FULL_NAME,
                  ASM.MEMBER_ID,
                  ASM.PERSON_ID
             FROM ATET_SB_MEMBERS ASM
            WHERE 1 = 1
              AND ASM.IS_SAVER = 'Y';

DECLARE
    CURSOR SAVINGS_DETAILS IS
           SELECT ASM.EMPLOYEE_NUMBER,
                  ASM.EMPLOYEE_FULL_NAME,
                  ASM.MEMBER_ID,
                  ASM.PERSON_ID
             FROM ATET_SB_MEMBERS ASM
            WHERE 1 = 1
              AND ASM.IS_SAVER = 'Y';
BEGIN

    FOR detail_saving IN SAVINGS_DETAILS LOOP
        ATET_SAVINGS_BANK_PKG.CREATE_ACCOUNT(detail_saving.PERSON_ID,
                                               'SAVINGS_ELEMENT_NAME',
                                               'SAV_CODE_COMB');
    END LOOP;

END;

SELECT *
FROM ATET_SB_MEMBERS_ACCOUNTS
WHERE ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO'; 

--COMMIT;

/**********************************************************/
/*          ACTUALIZACION DE SALDOS DE CUENTAS            */
/**********************************************************/

DECLARE
    
    CURSOR  LOANS_DETAILS   IS
            SELECT ASL.LOAN_ID,
                   ASL.LOAN_TOTAL_AMOUNT,
                   ASM.PERSON_ID,
                   ASM.MEMBER_ID
              FROM ATET_SB_LOANS    ASL,
                   ATET_SB_MEMBERS  ASM
             WHERE 1 = 1
               AND ASL.MEMBER_ID = ASM.MEMBER_ID
               AND ASL.LOAN_STATUS_FLAG = 'APPROVED' ;        

BEGIN

    FOR C_LOAN IN LOANS_DETAILS LOOP

        ATET_SAVINGS_BANK_PKG.SET_LOAN_BALANCE(C_LOAN.LOAN_ID, 
                                               C_LOAN.LOAN_TOTAL_AMOUNT, 
                                               C_LOAN.PERSON_ID);
                                               
        DBMS_OUTPUT.PUT_LINE(C_LOAN.LOAN_ID);
        
    END LOOP;	

END;

SELECT *
FROM apps.ATET_SB_LOANS;

SELECT *
FROM apps.ATET_SB_MEMBERS_ACCOUNTS;

SELECT *
FROM apps.ATET_SB_LOANS_TRANSACTIONS;

SELECT *
  FROM apps.ATET_SB_PARAMETERS;

--COMMIT;

/**********************************************************/
/*              CREACIÓN DE PAYMENTS_SCHEDULE             */
/**********************************************************/

DECLARE
    CURSOR  LOANS_DETAILS   IS
            SELECT ASL.LOAN_ID,
                   ASL.LOAN_TOTAL_AMOUNT,
                   ASM.PERSON_ID,
                   ASM.MEMBER_ID
              FROM ATET_SB_LOANS    ASL,
                   ATET_SB_MEMBERS  ASM
             WHERE 1 = 1
               AND ASL.MEMBER_ID = ASM.MEMBER_ID
               AND ASL.LOAN_STATUS_FLAG = 'APPROVED' ; 
               
    VAR_PAYMENT_DEADLINE    VARCHAR2(100);
BEGIN

    FOR C_LOAN IN LOANS_DETAILS LOOP
    
        BEGIN
    
            DBMS_OUTPUT.PUT_LINE('LOAN_ID = ' || C_LOAN.LOAN_ID);
        
            VAR_PAYMENT_DEADLINE := '';

            ATET_SB_BACK_OFFICE_PKG.CREATE_PAYMENTS_SCHEDULE(C_LOAN.LOAN_ID, VAR_PAYMENT_DEADLINE);
            
            UPDATE ATET_SB_LOANS    ASL
               SET ASL.PAYMENT_DEADLINE = VAR_PAYMENT_DEADLINE
             WHERE 1 = 1
               AND ASL.LOAN_ID = C_LOAN.LOAN_ID;

        EXCEPTION WHEN OTHERS THEN
            ROLLBACK;
        END;    
        
        COMMIT;
    
    END LOOP;
    
END;

--ROLLBACK;

SELECT *
  FROM ATET_SB_LOANS; 
  
SELECT *
  FROM ATET_SB_PAYMENTS_SCHEDULE; 
  
  
--COMMIT;


/**********************************************************/
/*              ACTUALIZACIÓN DE PRESTAMOS                */
/**********************************************************/

UPDATE ATET_SB_LOANS    ASL 
   SET ASL.CREATION_DATE = SYSDATE,
       ASL.CREATED_BY = -1,
       ASL.LAST_UPDATE_DATE = SYSDATE,
       ASL.LAST_UPDATED_BY = -1,
       ASL.LOAN_STATUS_FLAG = 'ACTIVE'
 WHERE 1 = 1
   AND ASL.LOAN_STATUS_FLAG = 'APPROVED';
  
--COMMIT;


/**********************************************************/
/*                  CREACIÓN DE CHEQUES                   */
/**********************************************************/
SELECT ASL.LOAN_ID,
       ASL.LOAN_TOTAL_AMOUNT,
       ASM.PERSON_ID,
       ASM.MEMBER_ID,
       ASL.ATTRIBUTE3,
       ASL.ATTRIBUTE5
  FROM ATET_SB_LOANS    ASL,
       ATET_SB_MEMBERS  ASM
 WHERE 1 = 1
   AND ASL.MEMBER_ID = ASM.MEMBER_ID
   AND ASL.LOAN_STATUS_FLAG NOT IN ('CANCELLED')
   AND ASL.ATTRIBUTE5 IS NULL
   AND ASL.ATTRIBUTE3 BETWEEN 30000 AND 40000
 ORDER BY ATTRIBUTE3 ASC; 

DECLARE
    CURSOR  LOANS_DETAILS   IS
        SELECT ASL.LOAN_ID,
               ASL.LOAN_TOTAL_AMOUNT,
               ASM.PERSON_ID,
               ASM.MEMBER_ID,
               ASL.ATTRIBUTE3,
               ASL.ATTRIBUTE5
          FROM ATET_SB_LOANS    ASL,
               ATET_SB_MEMBERS  ASM
         WHERE 1 = 1
           AND ASL.MEMBER_ID = ASM.MEMBER_ID
           AND ASL.LOAN_STATUS_FLAG NOT IN ('CANCELLED')
           AND ASL.ATTRIBUTE5 IS NULL
           AND ASL.ATTRIBUTE3 BETWEEN 30000 AND 40000
         ORDER BY ATTRIBUTE3 ASC;
               
    VAR_CHECK_ID    NUMBER;

BEGIN

    FOR C_LOAN IN LOANS_DETAILS LOOP
        ATET_SB_BACK_OFFICE_PKG.CREATE_LOAN_CHECK(C_LOAN.LOAN_ID, VAR_CHECK_ID);
    END LOOP;
        
END;

SELECT *
  FROM ATET_SB_CHECKS_ALL;
  
  
--COMMIT;

/**********************************************************/
/*                      TRANSFER TO GL                    */
/**********************************************************/

--BEGIN

-- fnd_global.apps_initialize (user_id        => 3397,
--                           resp_id        => 53698,
--                           resp_appl_id   => 101);
--mo_global.set_policy_context ('S', 1329);

--ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL;
--    
--END;



/***********************************************************/
/**     Creación de Cheque por LOAN_ID                  ****/
/***********************************************************/
DECLARE
               
    VAR_CHECK_ID    NUMBER;

BEGIN

        ATET_SB_BACK_OFFICE_PKG.CREATE_LOAN_CHECK(:P_LOAN_ID, VAR_CHECK_ID);
        
END;

commit;