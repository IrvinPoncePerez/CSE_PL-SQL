/**********************************************************/
/*              ACTUALIZACIÓN DE PRESTAMOS                */
/**********************************************************/

UPDATE ATET_SB_LOANS    ASL 
   SET ASL.CREATION_DATE = SYSDATE,
       ASL.CREATED_BY = -1,
       ASL.LAST_UPDATE_DATE = SYSDATE,
       ASL.LAST_UPDATED_BY = -1,
       ASL.LOAN_STATUS_FLAG = 'APPROVED'
 WHERE ASL.LOAN_STATUS_FLAG = 'ENTERED';
  
COMMIT;


/**********************************************************/
/*          ACTUALIZACION DE TABLA DE AVALES              */
/**********************************************************/

UPDATE ATET_SB_ENDORSEMENTS ASE
   SET ASE.CREATION_DATE = SYSDATE,
       ASE.CREATED_BY = -1,
       ASE.LAST_UPDATE_DATE = SYSDATE,
       ASE.LAST_UPDATED_BY = -1,
       ASE.ENDORSEMENT_FLAG = 'ACTIVE';
       
COMMIT;

/**********************************************************/
/*          ACTUALIZACION DE TABLA DE MIEMBROS            */
/**********************************************************/

UPDATE ATET_SB_MEMBERS  ASM
   SET ASM.IS_BORROWER = 'N',
       ASM.IS_ENDORSEMENT = 'N';
       
COMMIT;

MERGE INTO ATET_SB_MEMBERS      ASM
     USING (SELECT DISTINCT 
                   ASE.MEMBER_ENDORSEMENT_ID
              FROM ATET_SB_ENDORSEMENTS ASE) ASE
        ON (ASE.MEMBER_ENDORSEMENT_ID = ASM.MEMBER_ID)
WHEN MATCHED THEN 
UPDATE SET ASM.IS_ENDORSEMENT = 'Y',
           ASM.LAST_UPDATE_DATE = SYSDATE,
           ASM.LAST_UPDATED_BY = -1;
           
COMMIT;

MERGE INTO ATET_SB_MEMBERS      ASM
     USING (SELECT DISTINCT
                   ASE.MEMBER_BORROWER_ID 
              FROM ATET_SB_ENDORSEMENTS ASE) ASE
        ON (ASE.MEMBER_BORROWER_ID = ASM.MEMBER_ID)
WHEN MATCHED THEN 
UPDATE SET ASM.IS_BORROWER = 'Y',
           ASM.LAST_UPDATE_DATE = SYSDATE,
           ASM.LAST_UPDATED_BY = -1;

COMMIT;

/**********************************************************/
/*                    CREACIÓN DE CUENTAS                 */
/**********************************************************/

DECLARE
    CURSOR MEMBERS_DETAILS  IS
           SELECT ASM.PERSON_ID,
                  ASM.MEMBER_ID,
                  ASL.LOAN_ID
             FROM ATET_SB_MEMBERS   ASM,
                  ATET_SB_LOANS     ASL
            WHERE ASM.MEMBER_ID = ASL.MEMBER_ID;                  
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
    
    END LOOP;   

END;

COMMIT;

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
               AND ASL.MEMBER_ID = ASM.MEMBER_ID;        

BEGIN

    FOR C_LOAN IN LOANS_DETAILS LOOP

        ATET_SAVINGS_BANK_PKG.SET_LOAN_BALANCE(C_LOAN.LOAN_ID, 
                                               C_LOAN.LOAN_TOTAL_AMOUNT, 
                                               C_LOAN.PERSON_ID);
        
    END LOOP;	

END;


COMMIT;

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
               AND ASL.MEMBER_ID = ASM.MEMBER_ID; 
               
    VAR_PAYMENT_DEADLINE    VARCHAR2(100);
BEGIN

    FOR C_LOAN IN LOANS_DETAILS LOOP
    
        VAR_PAYMENT_DEADLINE := '';

        ATET_SB_BACK_OFFICE_PKG.CREATE_PAYMENTS_SCHEDULE(C_LOAN.LOAN_ID, VAR_PAYMENT_DEADLINE);
        
        UPDATE ATET_SB_LOANS    ASL
           SET ASL.PAYMENT_DEADLINE = VAR_PAYMENT_DEADLINE
         WHERE 1 = 1
           AND ASL.LOAN_ID = C_LOAN.LOAN_ID;
    
    END LOOP;

END;

SELECT *
  FROM ATET_SB_LOANS; 
  
SELECT *
  FROM ATET_SB_PAYMENTS_SCHEDULE; 
  
COMMIT;


/**********************************************************/
/*              ACTUALIZACIÓN DE PRESTAMOS                */
/**********************************************************/

UPDATE ATET_SB_LOANS    ASL 
   SET ASL.CREATION_DATE = SYSDATE,
       ASL.CREATED_BY = -1,
       ASL.LAST_UPDATE_DATE = SYSDATE,
       ASL.LAST_UPDATED_BY = -1,
       ASL.LOAN_STATUS_FLAG = 'ACTIVE';
  
COMMIT;


/**********************************************************/
/*                  CREACIÓN DE CHEQUES                   */
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
               AND ASL.MEMBER_ID = ASM.MEMBER_ID; 
               
    VAR_CHECK_ID    NUMBER;

BEGIN

    FOR C_LOAN IN LOANS_DETAILS LOOP
        ATET_SB_BACK_OFFICE_PKG.CREATE_LOAN_CHECK(C_LOAN.LOAN_ID, VAR_CHECK_ID);
    END LOOP;
        
END;

SELECT *
  FROM ATET_SB_CHECKS_ALL;
  
  
COMMIT;

