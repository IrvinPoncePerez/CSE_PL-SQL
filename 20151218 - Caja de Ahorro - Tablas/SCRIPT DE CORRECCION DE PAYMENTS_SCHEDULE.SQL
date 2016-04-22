DECLARE

    var_loan_id                     NUMBER := 370;
    
    var_period_number               NUMBER;
    var_time_period_id              NUMBER;
    var_period_name                 VARCHAR2(100);
    var_payment_date                DATE;
    var_payroll_id                  NUMBER;
    
    var_payment_number              NUMBER;
    var_opening_balance             NUMBER;
    var_payment_amount              NUMBER;
    var_payment_capital             NUMBER;
    var_payment_interest            NUMBER;
    var_final_balance               NUMBER;
    var_accrual_payment_amount      NUMBER;

    CURSOR PAYMENTS_DETAILS IS
        SELECT ASPS.PAYMENT_SCHEDULE_ID,
               ASPS.LOAN_ID,
               ASPS.PERIOD_NUMBER
          FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
         WHERE 1 = 1
           AND LOAN_ID = var_loan_id
         ORDER BY PAYMENT_NUMBER,   
                  PERIOD_NUMBER;
         
    
BEGIN

    SELECT ASPS.PERIOD_NUMBER -1,
           ASPS.PAYROLL_ID
      INTO var_period_number,
           var_payroll_id
      FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
     WHERE 1 = 1
       AND ASPS.LOAN_ID = var_loan_id
       AND ASPS.PAYMENT_NUMBER = 1;
       
    dbms_output.PUT_LINE(var_period_number || ' ' || var_payroll_id);
    
    SELECT PTP.TIME_PERIOD_ID,
           PTP.PERIOD_NAME,
           PTP.END_DATE
      INTO var_time_period_id,
           var_period_name,
           var_payment_date
      FROM PER_TIME_PERIODS PTP
     WHERE 1 = 1
       AND PTP.PERIOD_NUM = var_period_number
       AND PTP.PAYROLL_ID = var_payroll_id
       AND PTP.PERIOD_NAME LIKE '%2016%';
     

    INSERT INTO ATET_SB_PAYMENTS_SCHEDULE(
        LOAN_ID,
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
        PAYED_AMOUNT,
        PAYED_CAPITAL,
        PAYED_INTEREST,
        PAYED_INTEREST_LATE,
        OWED_AMOUNT,
        OWED_CAPITAL,
        OWED_INTEREST,
        OWED_INTEREST_LATE,
        FINAL_BALANCE,
        ACCRUAL_PAYMENT_AMOUNT,
        STATUS_FLAG,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY)
    SELECT
        LOAN_ID,
        PAYMENT_NUMBER,
        var_period_number,
        var_time_period_id,
        var_period_name,
        var_payment_date,
        PAYROLL_ID,
        ASSIGNMENT_ID,
        OPENING_BALANCE,
        PAYMENT_AMOUNT,
        PAYMENT_CAPITAL,
        PAYMENT_INTEREST,
        PAYMENT_INTEREST_LATE,
        PAYED_AMOUNT,
        PAYED_CAPITAL,
        PAYED_INTEREST,
        PAYED_INTEREST_LATE,
        OWED_AMOUNT,
        OWED_CAPITAL,
        OWED_INTEREST,
        OWED_INTEREST_LATE,
        FINAL_BALANCE,
        ACCRUAL_PAYMENT_AMOUNT,
        STATUS_FLAG,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY
    FROM ATET_SB_PAYMENTS_SCHEDULE  ASPS
   WHERE 1 = 1
     AND ASPS.LOAN_ID = var_loan_id
     AND ASPS.PAYMENT_NUMBER = 1;
     
     
    
    BEGIN
        FOR PAYMENT IN PAYMENTS_DETAILS LOOP
        
            SELECT ASPS.PAYMENT_NUMBER,
                   ASPS.OPENING_BALANCE,
                   ASPS.PAYMENT_AMOUNT,
                   ASPS.PAYMENT_CAPITAL,
                   ASPS.PAYMENT_INTEREST,
                   ASPS.FINAL_BALANCE,
                   ASPS.ACCRUAL_PAYMENT_AMOUNT
              INTO var_payment_number,
                   var_opening_balance,
                   var_payment_amount,
                   var_payment_capital,
                   var_payment_interest,
                   var_final_balance,
                   var_accrual_payment_amount
              FROM ATET_SB_PAYMENTS_SCHEDULE ASPS
             WHERE 1 = 1
               AND ASPS.LOAN_ID = PAYMENT.LOAN_ID
               AND ASPS.PERIOD_NUMBER = PAYMENT.PERIOD_NUMBER + 1;
               
            UPDATE ATET_SB_PAYMENTS_SCHEDULE ASPS
               SET ASPS.PAYMENT_NUMBER = var_payment_number,
                   ASPS.OPENING_BALANCE = var_opening_balance,
                   ASPS.PAYMENT_AMOUNT = var_payment_amount,
                   ASPS.PAYMENT_CAPITAL = var_payment_capital, 
                   ASPS.PAYMENT_INTEREST = var_payment_interest, 
                   ASPS.FINAL_BALANCE = var_final_balance,
                   ASPS.ACCRUAL_PAYMENT_AMOUNT = var_accrual_payment_amount
             WHERE 1 = 1 
               AND ASPS.LOAN_ID = PAYMENT.LOAN_ID
               AND ASPS.PAYMENT_SCHEDULE_ID = PAYMENT.PAYMENT_SCHEDULE_ID;
        
        END LOOP;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END; 
    
    
    DELETE FROM ATET_SB_PAYMENTS_SCHEDULE   ASPS
     WHERE 1 = 1
       AND ASPS.LOAN_ID = var_loan_id
       AND ASPS.PERIOD_NUMBER = (SELECT MAX(ASPS1.PERIOD_NUMBER)
                                    FROM ATET_SB_PAYMENTS_SCHEDULE ASPS1
                                   WHERE 1 = 1
                                     AND ASPS1.LOAN_ID = var_loan_id);
   
    
    UPDATE ATET_SB_PAYMENTS_SCHEDULE ASPS
       SET ASPS.PAYED_AMOUNT = ASPS.PAYMENT_AMOUNT,
           ASPS.PAYED_CAPITAL = ASPS.PAYMENT_CAPITAL,
           ASPS.PAYED_INTEREST = ASPS.PAYMENT_INTEREST,
           ASPS.STATUS_FLAG = 'PAYED'
     WHERE ASPS.LOAN_ID = var_loan_id
       AND ASPS.PAYMENT_NUMBER = 1; 
    
    
    UPDATE ATET_SB_LOANS    ASL
       SET ASL.PAYMENT_DEADLINE = (SELECT MAX(ASPS.PAYMENT_DATE)
                                     FROM ATET_SB_PAYMENTS_SCHEDULE     ASPS
                                    WHERE 1 = 1
                                      AND ASPS.LOAN_ID = var_loan_id)
     WHERE 1 = 1
       AND ASL.LOAN_ID = var_loan_id;
       
       
    SELECT ASPS.PAYMENT_AMOUNT,
           ASPS.PAYMENT_CAPITAL,
           ASPS.PAYMENT_INTEREST
      INTO var_payment_amount,
           var_payment_capital,
           var_payment_interest
      FROM ATET_SB_PAYMENTS_SCHEDULE ASPS
     WHERE 1 = 1
       AND ASPS.LOAN_ID = var_loan_id
       AND ASPS.TIME_PERIOD_ID = var_time_period_id
       AND ASPS.PERIOD_NAME = var_period_name;
              
       
    UPDATE ATET_SB_LOANS_TRANSACTIONS ASLT
       SET ASLT.PAYMENT_AMOUNT = var_payment_amount,
           ASLT.PAYMENT_CAPITAL = var_payment_capital,
           ASLT.PAYMENT_INTEREST = var_payment_interest,
           ASLT.ATTRIBUTE6 = NULL
     WHERE ASLT.LOAN_ID = var_loan_id
       AND ASLT.PERIOD_NAME = var_period_name
       AND ASLT.TIME_PERIOD_ID = var_time_period_id; 

END;



SELECT *
  FROM ATET_SB_PAYMENTS_SCHEDULE
 WHERE 1 = 1
   AND LOAN_ID = 72
 ORDER BY PAYMENT_NUMBER,   
          PERIOD_NUMBER; 
          
          
          
SELECT *
  FROM ATET_SB_LOANS ASL
 WHERE 1 = 1
   AND ASL.LOAN_ID = 92;
   
   
   
SELECT *
  FROM ATET_SB_LOANS_TRANSACTIONS ASLT
 WHERE 1 = 1
   AND ASLT.LOAN_ID = 98;
   
   
    
--ROLLBACK;
--COMMIT;


DECLARE
    
    var_employee_number     NUMBER := 3858;
    var_loan_id             NUMBER := 92; 
    
    var_term_period         NUMBER;
    var_count_periods       NUMBER;
    
    var_payment_deadline   DATE;
    
BEGIN

    SELECT ASL.TERM_PERIODS
      INTO var_term_period
      FROM ATET_SB_LOANS ASL
     WHERE 1 = 1
       AND ASL.LOAN_ID = var_loan_id;
       
    SELECT COUNT(ASPS.PAYMENT_SCHEDULE_ID)
      INTO var_count_periods
      FROM ATET_SB_PAYMENTS_SCHEDULE ASPS
     WHERE 1 = 1
       AND ASPS.LOAN_ID = var_loan_id;
       
    IF var_term_period = var_count_periods THEN
    
        SELECT MAX(ASPS.PAYMENT_DATE)
          INTO var_payment_deadline
          FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS  
         WHERE 1 = 1
           AND ASPS.LOAN_ID = var_loan_id;
           
           
        UPDATE ATET_SB_LOANS ASL
           SET ASL.PAYMENT_DEADLINE = var_payment_deadline
         WHERE 1 = 1
           AND ASL.LOAN_ID = var_loan_id;
    
    
    END IF; 

    COMMIT;

END;



SELECT ASM.EMPLOYEE_NUMBER,
       ASM.EMPLOYEE_FULL_NAME,
       ASL.LOAN_ID,
       ASL.TERM_PERIODS,
       ASL.TRANSACTION_DATE,
       ASL.PAYMENT_DEADLINE,
       ASPS.PAYMENT_NUMBER,
       ASPS.PERIOD_NAME,
       ASPS.PAYMENT_DATE
  FROM ATET_SB_MEMBERS              ASM,
       ATET_SB_LOANS                ASL,
       ATET_SB_PAYMENTS_SCHEDULE    ASPS
 WHERE 1 = 1
   AND ASM.MEMBER_ID = ASL.MEMBER_ID
   AND ASL.LOAN_ID = ASPS.LOAN_ID
   AND ASM.EMPLOYEE_NUMBER = :P_EMPLOYEE_NUMBER
   AND ASL.LOAN_ID = :P_LOAN_ID
 ORDER BY ASPS.PAYMENT_NUMBER;


