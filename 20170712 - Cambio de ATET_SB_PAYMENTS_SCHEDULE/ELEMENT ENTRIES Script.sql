ATET_SB_CREATE_ELEMENT_ENTRIES




SELECT MEMBER_ID,
             PPF.PERIOD_TYPE,
             asm.attribute6,
             amount_to_save,
             paaf.PERSON_ID,
             pAAf.PAYROLL_ID
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
   AND ASL.MEMBER_ID IN (2521, 2754, 1785)
   AND ASL.LOAN_STATUS_FLAG = 'ACTIVE'
   AND ASPS.STATUS_FLAG IN ('PENDING')
 GROUP 
    BY ASL.LOAN_ID;


SELECT PTP.TIME_PERIOD_ID,
       PTP.END_DATE
  FROM PER_TIME_PERIODS PTP
 WHERE 1 = 1
   AND PTP.PERIOD_TYPE = :PERIOD_TYPE
   AND PTP.PAYROLL_ID = :PAYROLL_ID
   AND SYSDATE+3 BETWEEN PTP.START_DATE
                     AND PTP.END_DATE;  
                     
                     
                     
                     
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
               AND PTP_PPF.TIME_PERIOD_ID = :CP_TIME_PERIOD_ID
               AND (    PTP.END_DATE > TO_DATE(:CP_ACTUAL_DATE_EARNED)
                    AND PTP.END_DATE > TO_DATE(:CP_ACTUAL_DATE_EARNED))
             ORDER BY PTP.END_DATE)
     WHERE 1 = 1
       AND PERIOD_SEQUENCE <= :CP_TERM_PERIODS
     ORDER BY PERIOD_SEQUENCE;                     


SELECT loan_id,
       member_id,
       loan_number
  FROM ATET_SB_LOANS
 WHERE 1 = 1 
   AND MEMBER_ID IN (2521, 2754, 1785);
   
LOAN_ID	MEMBER_ID	LOAN_NUMBER

2290	2754	126
3601	2521	1437
3608	1785	1444
   


SELECT *
  FROM ATET_SB_PAYMENTS_SCHEDULE
 WHERE 1 = 1 
   AND LOAN_ID = :P_LOAN_ID;
   
             
DECLARE

    RETCODE VARCHAR2(1000);
    ERRBUF  VARCHAR2(1000);

    CURSOR  C_MEMBERS_CHANGES
        IS
    SELECT MEMBER_ID,
             PPF.PERIOD_TYPE,
             asm.attribute6,
             amount_to_save,
             PAAF.PERSON_ID,         --Consulta de PERSON_ID
             PAAF.PAYROLL_ID,         --Consulta de PAYROLL_ID
             PAAF.ASSIGNMENT_ID      --Consulta de ASSIGNMENT_ID
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
    
    var_count_loans                     NUMBER;
    var_count_term_periods              NUMBER;
    var_rebuild_capital                 ATET_SB_PAYMENTS_SCHEDULE.PAYMENT_CAPITAL%TYPE;
    var_rebuild_interest                ATET_SB_PAYMENTS_SCHEDULE.PAYMENT_INTEREST%TYPE;
    var_rebuild_interest_late           ATET_SB_PAYMENTS_SCHEDULE.PAYMENT_INTEREST_LATE%TYPE;
    var_time_period_id                  ATET_SB_PAYMENTS_SCHEDULE.TIME_PERIOD_ID%TYPE;
    var_term_periods                    NUMBER;
    var_earned_date                     ATET_SB_PAYMENTS_SCHEDULE.PAYMENT_DATE%TYPE;
    
    var_sum_payment_capital             NUMBER;
    var_sum_payment_interest            NUMBER;
    var_sum_payment_interest_late       NUMBER;
        
    var_opening_balance                 ATET_SB_PAYMENTS_SCHEDULE.OPENING_BALANCE%TYPE;
    var_payment_amount                  ATET_SB_PAYMENTS_SCHEDULE.PAYMENT_AMOUNT%TYPE;
    var_payment_capital                 ATET_SB_PAYMENTS_SCHEDULE.PAYMENT_CAPITAL%TYPE;
    var_payment_interest                ATET_SB_PAYMENTS_SCHEDULE.PAYMENT_INTEREST%TYPE;
    var_payment_interest_late           ATET_SB_PAYMENTS_SCHEDULE.PAYMENT_INTEREST_LATE%TYPE;
    var_final_balance                   ATET_SB_PAYMENTS_SCHEDULE.FINAL_BALANCE%TYPE;
    var_accrual_payment_amount          ATET_SB_PAYMENTS_SCHEDULE.ACCRUAL_PAYMENT_AMOUNT%TYPE;
    
    var_user_id                         NUMBER := FND_GLOBAL.USER_ID;
    
    CURSOR C_LOANS_CHANGES(CP_MEMBER_ID  NUMBER)
        IS 
    SELECT DISTINCT ASL.LOAN_ID
      FROM ATET_SB_LOANS                ASL,
           ATET_SB_PAYMENTS_SCHEDULE    ASPS
     WHERE 1 = 1
       AND ASL.LOAN_ID = ASPS.LOAN_ID
       AND ASL.MEMBER_ID = CP_MEMBER_ID
       AND ASL.LOAN_STATUS_FLAG = 'ACTIVE'
       AND ASPS.STATUS_FLAG IN ('PENDING', 'SKIP', 'PARTIAL')
     GROUP 
        BY ASL.LOAN_ID;
        
    CURSOR  DETAILS(CP_TIME_PERIOD_ID       NUMBER,
                    CP_ACTUAL_DATE_EARNED   DATE,
                    CP_TERM_PERIODS         NUMBER) 
        IS
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
               AND PTP_PPF.TIME_PERIOD_ID = CP_TIME_PERIOD_ID
               AND (    PTP.END_DATE > TO_DATE(CP_ACTUAL_DATE_EARNED)
                    AND PTP.END_DATE > TO_DATE(CP_ACTUAL_DATE_EARNED))
             ORDER BY PTP.END_DATE)
     WHERE 1 = 1
       AND PERIOD_SEQUENCE <= CP_TERM_PERIODS
     ORDER BY PERIOD_SEQUENCE;        
        
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
            
                FOR LOAN_CHANGE IN C_LOANS_CHANGES(CHANGES.MEMBER_ID) LOOP
                
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
                       
                       
                    SELECT PTP.TIME_PERIOD_ID,
                           PTP.END_DATE
                      INTO var_time_period_id,
                           var_earned_date
                      FROM PER_TIME_PERIODS PTP
                     WHERE 1 = 1
                       AND PTP.PERIOD_TYPE = CHANGES.PERIOD_TYPE
                       AND PTP.PAYROLL_ID = CHANGES.PAYROLL_ID
                       AND SYSDATE+3 BETWEEN PTP.START_DATE
                                         AND PTP.END_DATE;      
                                         
                    dbms_output.put_line(var_time_period_id || ' ' || var_earned_date || ' ' || var_count_term_periods);                                                          
            
                    IF    CHANGES.ATTRIBUTE6 IN ('Week', 'Semana') AND CHANGES.PERIOD_TYPE IN ('Semi-Month', 'Quincena') THEN
                        var_term_periods := ROUND((var_count_term_periods / 2), 0);
                        var_payment_capital := TRUNC((var_rebuild_capital / var_term_periods), 2);
                        var_payment_interest := TRUNC((var_rebuild_interest / var_term_periods), 2);
                        var_payment_interest_late := TRUNC((var_rebuild_interest_late / var_term_periods), 2);
                    ELSIF CHANGES.ATTRIBUTE6 IN ('Semi-Month', 'Quincena') AND CHANGES.PERIOD_TYPE IN ('Week', 'Semana') THEN
                        var_term_periods := ROUND((var_count_term_periods * 2),0);
                        var_payment_capital := TRUNC((var_rebuild_capital / var_term_periods), 2);
                        var_payment_interest := TRUNC((var_rebuild_interest / var_term_periods), 2);
                        var_payment_interest_late := TRUNC((var_rebuild_interest_late / var_term_periods), 2);
                    END IF;
                    
                    dbms_output.put_line('term periods ' ||var_term_periods);
                    
                    UPDATE ATET_SB_PAYMENTS_SCHEDULE    ASPS
                       SET ASPS.STATUS_FLAG = 'REBUILD',
                           ASPS.LAST_UPDATE_DATE = SYSDATE,
                           ASPS.LAST_UPDATED_BY = var_user_id
                     WHERE 1 = 1
                       AND ASPS.LOAN_ID = LOAN_CHANGE.LOAN_ID
                       AND ASPS.STATUS_FLAG IN ('SKIP', 'PARTIAL', 'PENDING');
                    
                    
                    var_sum_payment_capital := 0;
                    var_sum_payment_interest := 0;
                    var_sum_payment_interest_late := 0;
                    var_payment_amount := 0;
                    var_accrual_payment_amount := 0;
                    var_final_balance := 0;
                    var_opening_balance := 0;
                    
                    
                    FOR detail IN DETAILS(var_time_period_id, var_earned_date, var_term_periods) LOOP
            
                        IF detail.PERIOD_SEQUENCE = var_term_periods THEN
                            var_payment_capital := var_rebuild_capital - var_sum_payment_capital; 
                            var_payment_interest := var_rebuild_interest - var_sum_payment_interest;
                            var_payment_interest_late := var_rebuild_interest_LATE - var_sum_payment_interest_late; 
                        END IF;
                        
                        var_sum_payment_capital := var_sum_payment_capital + var_payment_capital;
                        var_sum_payment_interest := var_sum_payment_interest + var_payment_interest;
                        var_sum_payment_interest_late := var_sum_payment_interest_late + var_payment_interest_late;
                        var_payment_amount := var_payment_capital + var_payment_interest + var_payment_interest_late;
                        var_accrual_payment_amount := var_accrual_payment_amount + var_payment_amount;    
                        var_final_balance := (var_rebuild_capital + var_rebuild_interest + var_rebuild_interest_late) - var_accrual_payment_amount;
                        var_opening_balance := var_final_balance + var_payment_amount;
                        
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT ATET_SB_PAYMENTS_SCHEDULE(LOAN_ID => ' || LOAN_CHANGE.LOAN_ID ||
                                                                                       ', PAYMENT_NUMBER => ' || detail.PERIOD_SEQUENCE || 
                                                                                       ', PERIOD_NUMBER => ' || detail.PERIOD_NUM ||
                                                                                       ', TIME_PERIOD_ID => ' || detail.TIME_PERIOD_ID ||
                                                                                       ', PERIOD_NAME => ' || detail.PERIOD_NAME || 
                                                                                       ', PAYMENT_DATE => ' || detail.END_DATE ||
                                                                                       ', PAYROLL_ID => ' || detail.PAYROLL_ID ||
                                                                                       ', ASSIGNMENT_ID => ' || CHANGES.ASSIGNMENT_ID ||
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
                                                 VALUES (LOAN_CHANGE.LOAN_ID,
                                                         detail.PERIOD_SEQUENCE,
                                                         detail.PERIOD_NUM,
                                                         detail.TIME_PERIOD_ID,
                                                         detail.PERIOD_NAME,
                                                         detail.END_DATE,
                                                         detail.PAYROLL_ID,
                                                         CHANGES.ASSIGNMENT_ID,
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
                
                END LOOP;
            
            END IF;
         
         EXCEPTION
            WHEN OTHERS THEN
                RETCODE := 1;
                ERRBUF := 'Error en la reconstruccion de ATET_SB_PAYMENTS_SCHEDULE por cambio de periodo.';

                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error en la reconstruccion de ATET_SB_PAYMENTS_SCHEDULE por cambio de periodo.');
         END;
         
         /*****************************************************/
         
         
      END LOOP;
EXCEPTION
  WHEN OTHERS
  THEN
     DBMS_OUTPUT.PUT_LINE ('Error al actualizar miembros');
END;
   

   
   
ROLLBACK;
   
   



        