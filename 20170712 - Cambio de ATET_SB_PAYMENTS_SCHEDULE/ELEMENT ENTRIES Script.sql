ATET_SB_CREATE_ELEMENT_ENTRIES




SELECT MEMBER_ID,
             PPF.PERIOD_TYPE,
             asm.attribute6,
             amount_to_save
        FROM PER_ALL_ASSIGNMENTS_F PAAF,
             ATET_SB_MEMBERS ASM,
             PAY_PAYROLLS_F PPF
       WHERE ASM.PERSON_ID = PAAF.PERSON_ID
             AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
             AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE
                             AND PPF.EFFECTIVE_END_DATE
             AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE
                             AND PAAF.EFFECTIVE_END_DATE
             AND PPF.PERIOD_TYPE <> asm.attribute6
             AND ASM.SAVING_BANK_ID = ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID;
             
             
             
Row#	MEMBER_ID	PERIOD_TYPE	ATTRIBUTE6	AMOUNT_TO_SAVE

1	2521	Week	Semi-Month	600
2	2754	Semi-Month	Week	
3	1785	Week	Semi-Month	700
             

SELECT MEMBER_ID,
       EMPLOYEE_NUMBER,
       EMPLOYEE_FULL_NAME,
       AMOUNT_TO_SAVE,
       ATTRIBUTE6
  FROM ATET_SB_MEMBERS
 WHERE 1 = 1
   AND MEMBER_ID IN (2521, 2754, 1785);
             
   
SELECT DISTINCT ASL.LOAN_ID
  FROM ATET_SB_LOANS                ASL,
       ATET_SB_PAYMENTS_SCHEDULE    ASPS
 WHERE 1 = 1
   AND ASL.LOAN_ID = ASPS.LOAN_ID
   AND ASL.MEMBER_ID = :P_MEMBER_ID
   AND ASL.LOAN_STATUS_FLAG = 'ACTIVE'
   AND ASPS.STATUS_FLAG IN ('PENDING', 'SKIP', 'PARTIAL')
 GROUP 
    BY ASL.LOAN_ID;

   
             
DECLARE

    CURSOR  C_MEMBERS_CHANGES
        IS
    SELECT MEMBER_ID,
             PPF.PERIOD_TYPE,
             asm.attribute6,
             amount_to_save
        FROM PER_ALL_ASSIGNMENTS_F PAAF,
             ATET_SB_MEMBERS ASM,
             PAY_PAYROLLS_F PPF
       WHERE ASM.PERSON_ID = PAAF.PERSON_ID
             AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
             AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE
                             AND PPF.EFFECTIVE_END_DATE
             AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE
                             AND PAAF.EFFECTIVE_END_DATE
             AND PPF.PERIOD_TYPE <> asm.attribute6
             AND ASM.SAVING_BANK_ID = ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID; 

    ln_updated_amount           NUMBER;
    
    /*****************************************************/
    /*         CHANGE ATET_SB_PAYMENTS_SCHEDULE          */
    
    var_count_loans             NUMBER;
    
    CURSOR C_LOANS_CHANGES
        IS 
    SELECT DISTINCT ASL.LOAN_ID
      FROM ATET_SB_LOANS                ASL,
           ATET_SB_PAYMENTS_SCHEDULE    ASPS
     WHERE 1 = 1
       AND ASL.LOAN_ID = ASPS.LOAN_ID
       AND ASL.MEMBER_ID = CHANGES.MEMBER_ID
       AND ASL.LOAN_STATUS_FLAG = 'ACTIVE'
       AND ASPS.STATUS_FLAG IN ('PENDING', 'SKIP', 'PARTIAL')
     GROUP 
        BY ASL.LOAN_ID;
        
    /*****************************************************/        

BEGIN
      FOR changes IN C_MEMBERS_CHANGES
      LOOP
         BEGIN
            IF changes.attribute6 IN ('Week', 'Semana')
               AND changes.period_type IN ('Semi-Month', 'Quincena')
            THEN
               ln_updated_amount := changes.amount_to_save * 2;
            ELSE
               ln_updated_amount := changes.amount_to_save / 2;
            END IF;

            UPDATE ATET_SB_MEMBERS
               SET attribute6 = changes.period_type,
                   amount_to_save = ln_updated_amount
             WHERE member_id = changes.member_id;

--            COMMIT;
         END;
         
         
         /*****************************************************/
         /*         CHANGE ATET_SB_PAYMENTS_SCHEDULE          */
         
         BEGIN
         
            SELECT COUNT(DISTINCT ASL.LOAN_ID)
              INTO var_count_loans
              FROM ATET_SB_LOANS                ASL,
                   ATET_SB_PAYMENTS_SCHEDULE    ASPS
             WHERE 1 = 1
               AND ASL.LOAN_ID = ASPS.LOAN_ID
               AND ASL.MEMBER_ID = CHANGES.MEMBER_ID
               AND ASL.LOAN_STATUS_FLAG = 'ACTIVE'
               AND ASPS.STATUS_FLAG IN ('PENDING', 'SKIP', 'PARTIAL')
             GROUP 
                BY ASL.LOAN_ID;
                    
                
            IF var_count_loans > 0 THEN                
            
                FOR LOAN_CHANGE IN C_LOANS_CHANGES LOOP
            
                    IF    CHANGES.ATTRIBUTE6 IN ('Week', 'Semana') AND CHANGES.PERIOD_TYPE IN ('Semi-Month', 'Quincena') THEN
                       NULL;
                    ELSIF CHANGES.ATTRIBUTE6 IN ('Semi-Month', 'Quincena') AND CHANGES.PERIOD_TYPE IN ('Week', 'Semana') THEN
                       NULL;
                    END IF;
                
                END LOOP;
            
            END IF;
         
         END;
         
         /*****************************************************/
         
         
      END LOOP;
EXCEPTION
  WHEN OTHERS
  THEN
     DBMS_OUTPUT.PUT_LINE ('Error al actualizar miembros');
END;
   

   
   
--ROLLBACK;
   
   

        
        
        
        
        
        
        
        
        