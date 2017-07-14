ATET_SB_CREATE_ELEMENT_ENTRIES




SELECT MEMBER_ID,
             PPF.PERIOD_TYPE,
             asm.attribute6,
             amount_to_save,
             paaf.PERSON_ID,
             ppf.PAYROLL_ID
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
             
   
SELECT COUNT(DISTINCT ASL.LOAN_ID),
       COUNT(DISTINCT ASPS.PAYMENT_SCHEDULE_ID),
       SUM(NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL)),
       SUM(NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST)),
       SUM(NVL(ASPS.OWED_INTEREST_LATE, ASPS.PAYMENT_INTEREST_LATE))
  FROM ATET_SB_LOANS                ASL,
       ATET_SB_PAYMENTS_SCHEDULE    ASPS
 WHERE 1 = 1
   AND ASL.LOAN_ID = ASPS.LOAN_ID
   AND ASL.MEMBER_ID = :P_MEMBER_ID
   AND ASL.LOAN_STATUS_FLAG = 'ACTIVE'
   AND ASPS.STATUS_FLAG IN ('PENDING', 'SKIP', 'PARTIAL')
 GROUP 
    BY ASL.LOAN_ID;


SELECT PTP.TIME_PERIOD_ID
  FROM PER_TIME_PERIODS PTP
 WHERE 1 = 1
   AND PTP.PERIOD_TYPE = :PERIOD_TYPE
   AND PTP.PAYROLL_ID = :PAYROLL_ID
   AND SYSDATE BETWEEN PTP.START_DATE
                   AND PTP.END_DATE;
   
             
DECLARE

    CURSOR  C_MEMBERS_CHANGES
        IS
    SELECT MEMBER_ID,
             PPF.PERIOD_TYPE,
             asm.attribute6,
             amount_to_save,
             PAAF.PERSON_ID         --Consulta de PERSON_ID
             PPF.PAYROLL_ID         --Consulta de PAYROLL_ID
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
    var_count_term_periods      NUMBER;
    var_rebuild_capital         NUMBER
    var_rebuild_interest        NUMBER;
    var_rebuild_interest_late   NUMBER;
    var_time_period_id          NUMBER;
    
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
              INTO var_count_loans,
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
                
                    SELECT COUNT(DISTINCT ASPS.PAYMENT_SCHEDULE_ID),
                           SUM(NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL)),
                           SUM(NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST)),
                           SUM(NVL(ASPS.OWED_INTEREST_LATE, ASPS.PAYMENT_INTEREST_LATE))
                      INTO var_count_term_periods,
                           var_rebuild_capital,
                           var_rebuild_interest,
                           var_rebuild_interest_late
                      FROM ATET_SB_LOANS                ASL,
                           ATET_SB_PAYMENTS_SCHEDULE    ASPS
                     WHERE 1 = 1
                       AND ASL.LOAN_ID = ASPS.LOAN_ID
                       AND ASL.MEMBER_ID = CHANGES.MEMBER_ID
                       AND ASL.LOAN_ID = LOAN_CHANGE.LOAN_ID
                       AND ASL.LOAN_STATUS_FLAG = 'ACTIVE'
                       AND ASPS.STATUS_FLAG IN ('PENDING', 'SKIP', 'PARTIAL');
                       
                       
                    SELECT PTP.TIME_PERIOD_ID
                      INTO var_time_period_id
                      FROM PER_TIME_PERIODS PTP
                     WHERE 1 = 1
                       AND PTP.PERIOD_TYPE = CHANGES.PERIOD_TYPE
                       AND PTP.PAYROLL_ID = CHANGES.PAYROLL_ID
                       AND SYSDATE BETWEEN PTP.START_DATE
                                       AND PTP.END_DATE;                       
            
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
   
   



    PROCEDURE   EXTEND_PAYMENTS_SCHEDULE(
                    P_LOAN_ID                  NUMBER,
                    P_PERSON_ID                NUMBER,
                    P_MEMBER_ID                NUMBER,
                    P_TIME_PERIOD_ID           NUMBER,
                    P_ACTUAL_DATE_EARNED       DATE,
                    P_PAYMENT_CAPITAL          NUMBER,
                    P_PAYMENT_INTEREST         NUMBER,
                    P_PAYMENT_INTEREST_LATE    NUMBER)
    IS
    
        CURSOR  DETAILS(PP_TIME_PERIOD_ID       NUMBER,
                        PP_ACTUAL_DATE_EARNED   DATE,
                        PP_TERM_PERIODS         NUMBER
                        ) IS
            SELECT PAYROLL_ID,
                   TIME_PERIOD_ID,
                   END_DATE,
                   PERIOD_NAME,
                   PERIOD_NUM,
                   PERIOD_SEQUENCE
              FROM (SELECT PTP.PAYROLL_ID,
                           PTP.TIME_PERIOD_ID,
                           PTP.END_DATE,
                           PTP.PERIOD_NAME,
                           PTP.PERIOD_NUM,
                           ROW_NUMBER () OVER (PARTITION BY PTP.PAYROLL_ID ORDER BY PTP.END_DATE)
                           PERIOD_SEQUENCE
                      FROM PER_TIME_PERIODS  PTP,   
                           PER_TIME_PERIODS  PTP_PPF
                     WHERE PTP.PAYROLL_ID = PTP_PPF.PAYROLL_ID
                       AND PTP_PPF.TIME_PERIOD_ID = PP_TIME_PERIOD_ID
                       AND (    PTP.END_DATE > TO_DATE(PP_ACTUAL_DATE_EARNED)
                            AND PTP.END_DATE > TO_DATE (PP_ACTUAL_DATE_EARNED))
                     ORDER BY PTP.END_DATE)
             WHERE 1 = 1
               AND PERIOD_SEQUENCE <= PP_TERM_PERIODS
             ORDER BY PERIOD_SEQUENCE;
             
        var_term_periods                    NUMBER;
        var_assignment_id                   NUMBER;
        var_member_period_type              VARCHAR2(100);
        
        var_sum_payment_capital             NUMBER;
        var_sum_payment_interest            NUMBER;
        var_sum_payment_interest_late       NUMBER;
        
        var_opening_balance                 NUMBER;
        var_payment_amount                  NUMBER;
        var_payment_capital                 NUMBER;
        var_payment_interest                NUMBER;
        var_payment_interest_late           NUMBER;
        var_final_balance                   NUMBER;
        var_accrual_payment_amount          NUMBER;
        var_user_id                         NUMBER := FND_GLOBAL.USER_ID;
    
    BEGIN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'EXTEND_PAYMENTS_SCHEDULE(P_LOAN_ID => ' || P_LOAN_ID ||
                                                                ',P_PERSON_ID => ' || P_PERSON_ID ||
                                                                ',P_MEMBER_ID => ' || P_MEMBER_ID ||
                                                                ',P_TIME_PERIOD_ID => ' || P_TIME_PERIOD_ID ||
                                                                ',P_ACTUAL_DATE_EARNED => ' || P_ACTUAL_DATE_EARNED ||
                                                                ',P_PAYMENT_CAPITAL => ' || P_PAYMENT_CAPITAL ||
                                                                ',P_PAYMENT_INTEREST => ' || P_PAYMENT_INTEREST ||
                                                                ',P_PAYMENT_INTEREST_LATE => ' || P_PAYMENT_INTEREST_LATE || 
                                                                ')');
                                                                
        SELECT PAF.ASSIGNMENT_ID,
               PPF.PERIOD_TYPE
          INTO var_assignment_id,
               var_member_period_type
          FROM PER_ASSIGNMENTS_F    PAF,
               PAY_PAYROLLS_F       PPF
         WHERE 1 = 1
           AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
           AND PAF.PERSON_ID = P_PERSON_ID
           AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE;
           
           
        IF    var_member_period_type IN ('Week', 'Semana') THEN
            var_term_periods := 4;
            var_payment_capital := TRUNC((P_PAYMENT_CAPITAL / 4), 2);
            var_payment_interest := TRUNC((P_PAYMENT_INTEREST / 4), 2);
            var_payment_interest_late := TRUNC((P_PAYMENT_INTEREST_LATE / 4), 2);
        ELSIF var_member_period_type IN ('Semi-Month', 'Quincena') THEN
            var_term_periods := 2;
            var_payment_capital := TRUNC((P_PAYMENT_CAPITAL / 2), 2);
            var_payment_interest := TRUNC((P_PAYMENT_INTEREST / 2), 2);
            var_payment_interest_late := TRUNC((P_PAYMENT_INTEREST_LATE / 2), 2);
        END IF;
        
        var_sum_payment_capital := 0;
        var_sum_payment_interest := 0;
        var_sum_payment_interest_late := 0;
        var_payment_amount := 0;
        var_accrual_payment_amount := 0;
        var_final_balance := 0;
        var_opening_balance := 0;
        
        FOR detail IN DETAILS(P_TIME_PERIOD_ID, P_ACTUAL_DATE_EARNED, var_term_periods) LOOP
            
            IF detail.PERIOD_SEQUENCE = var_term_periods THEN
                var_payment_capital := P_PAYMENT_CAPITAL - var_sum_payment_capital; 
                var_payment_interest := P_PAYMENT_INTEREST - var_sum_payment_interest;
                var_payment_interest_late := P_PAYMENT_INTEREST_LATE - var_sum_payment_interest_late; 
            END IF;
            
            var_sum_payment_capital := var_sum_payment_capital + var_payment_capital;
            var_sum_payment_interest := var_sum_payment_interest + var_payment_interest;
            var_sum_payment_interest_late := var_sum_payment_interest_late + var_payment_interest_late;
            var_payment_amount := var_payment_capital + var_payment_interest + var_payment_interest_late;
            var_accrual_payment_amount := var_accrual_payment_amount + var_payment_amount;    
            var_final_balance := (P_PAYMENT_CAPITAL + P_PAYMENT_INTEREST + P_PAYMENT_INTEREST_LATE) - var_accrual_payment_amount;
            var_opening_balance := var_final_balance + var_payment_amount;
            
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT ATET_SB_PAYMENTS_SCHEDULE(LOAN_ID => ' || P_LOAN_ID ||
                                                                           ', PAYMENT_NUMBER => ' || detail.PERIOD_SEQUENCE || 
                                                                           ', PERIOD_NUMBER => ' || detail.PERIOD_NUM ||
                                                                           ', TIME_PERIOD_ID => ' || detail.TIME_PERIOD_ID ||
                                                                           ', PERIOD_NAME => ' || detail.PERIOD_NAME || 
                                                                           ', PAYMENT_DATE => ' || detail.END_DATE ||
                                                                           ', PAYROLL_ID => ' || detail.PAYROLL_ID ||
                                                                           ', ASSIGNMENT_ID => ' || var_assignment_id ||
                                                                           ', OPENING_BALANCE => ' || var_opening_balance ||
                                                                           ', PAYMENT_AMOUNT => ' || var_payment_amount ||
                                                                           ', PAYMENT_CAPITAL => ' || var_payment_capital || 
                                                                           ', PAYMENT_INTEREST => ' || var_payment_interest ||
                                                                           ', PAYMENT_INTEREST_LATE => ' || var_payment_interest_late ||
                                                                           ', FINAL_BALANCE => ' || var_final_balance ||
                                                                           ', ACCRUAL_PAYMENT_AMOUNT => ' || var_accrual_payment_amount ||
                                                                           ')');
            
            INSERT 
              INTO ATET_SB_PAYMENTS_SCHEDULE(LOAN_ID,
                                             PAYMENT_NUMBER,
                                             PERIOD_NUMBER,
                                             TIME_PERIOD_ID,
                                             PERIOD_NAME,
                                             PAYMENT_DATE,
                                             PAYROLL_ID,
                                             ASSIGNMENT_ID,
                                             OPENING_BALANCE,
                                             PAYMENT_AMOUNT,
                                             PAYMENT_CAPITAL,
                                             PAYMENT_INTEREST,
                                             PAYMENT_INTEREST_LATE,
                                             FINAL_BALANCE,
                                             ACCRUAL_PAYMENT_AMOUNT,
                                             STATUS_FLAG,
                                             CREATION_DATE,
                                             CREATED_BY,
                                             LAST_UPDATE_DATE,
                                             LAST_UPDATED_BY)
                                     VALUES (P_LOAN_ID,
                                             detail.PERIOD_SEQUENCE,
                                             detail.PERIOD_NUM,
                                             detail.TIME_PERIOD_ID,
                                             detail.PERIOD_NAME,
                                             detail.END_DATE,
                                             detail.PAYROLL_ID,
                                             var_assignment_id,
                                             var_opening_balance,
                                             var_payment_amount,
                                             var_payment_capital,
                                             var_payment_interest,
                                             var_payment_interest_late,
                                             var_final_balance,
                                             var_accrual_payment_amount,
                                             'PENDING',
                                             SYSDATE,
                                             var_user_id,
                                             SYSDATE,
                                             var_user_id);
                                                                             
            
            IF detail.PERIOD_SEQUENCE = var_term_periods THEN
                EXIT;
            END IF;
        
        END LOOP;
        
        UPDATE ATET_SB_PAYMENTS_SCHEDULE    ASPS
           SET ASPS.STATUS_FLAG = 'REFINANCED',
               ASPS.LAST_UPDATE_DATE = SYSDATE,
               ASPS.LAST_UPDATED_BY = var_user_id
         WHERE 1 = 1
           AND ASPS.LOAN_ID = P_LOAN_ID
           AND ASPS.STATUS_FLAG IN ('SKIP', 'PARTIAL');
        
         MERGE 
          INTO ATET_SB_PAYMENTS_SCHEDULE    ASPS
         USING (SELECT DISTINCT ASL.LOAN_ID
                  FROM ATET_SB_MEMBERS              ASM,
                       ATET_SB_LOANS                ASL,
                       PER_ALL_PEOPLE_F             PAPF,
                       PER_PERSON_TYPES             PPT,
                       ATET_SB_PAYMENTS_SCHEDULE    ASPS
                 WHERE 1 = 1
                   AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID
                   AND ASM.MEMBER_ID = ASL.MEMBER_ID
                   AND PAPF.PERSON_ID = ASM.PERSON_ID
                   AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE
                                   AND PAPF.EFFECTIVE_END_DATE
                   AND PPT.PERSON_TYPE_ID = PAPF.PERSON_TYPE_ID
                   AND PPT.USER_PERSON_TYPE IN ('Ex-empleado', 'Ex-employee')
                   AND ASL.LOAN_STATUS_FLAG IN ('ACTIVE')
                   AND ASL.LOAN_ID = ASPS.LOAN_ID
                   AND ASPS.STATUS_FLAG IN ('SKIP', 'PARTIAL', 'PENDING')
                   AND (   ASPS.PAYMENT_INTEREST_LATE > 0
                        OR ASPS.PAYED_INTEREST_LATE > 0
                        OR ASPS.OWED_INTEREST_LATE > 0) 
                   AND ASM.PERSON_ID = P_PERSON_ID
                   AND ASL.LOAN_ID = P_LOAN_ID ) D 
            ON (    ASPS.LOAN_ID = D.LOAN_ID
                AND ASPS.STATUS_FLAG IN ('SKIP', 'PARTIAL', 'PENDING')
                AND (   ASPS.PAYMENT_INTEREST_LATE > 0
                     OR ASPS.PAYED_INTEREST_LATE > 0
                     OR ASPS.OWED_INTEREST_LATE > 0))
          WHEN MATCHED THEN
        UPDATE 
           SET ASPS.PAYMENT_INTEREST_LATE = 0;
         
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en EXTEND_PAYMENTS_SCHEDULE ' || SQLCODE || ' -ERROR- ' || SQLERRM);    
    END EXTEND_PAYMENTS_SCHEDULE;
        
        
        
        
        
        
        
        
        