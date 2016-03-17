    FUNCTION   INSERT_LOAN_TRANSACTION(
                    P_EXPORT_REQUEST_ID   NUMBER,
                    P_PAYROLL_RESULT_ID   NUMBER,
                    P_PERSON_ID           NUMBER,
                    P_RUN_RESULT_ID       NUMBER,
                    P_EARNED_DATE         DATE,
                    P_TIME_PERIOD_ID      NUMBER,
                    P_PERIOD_NAME         VARCHAR2,
                    P_ELEMENT_NAME        VARCHAR2,
                    P_ENTRY_NAME          VARCHAR2,
                    P_ENTRY_UNITS         VARCHAR2,
                    P_ENTRY_VALUE         NUMBER,
                    P_DEBIT_AMOUNT        NUMBER,
                    P_CREDIT_AMOUNT       NUMBER)
      RETURN    VARCHAR2
    IS
        var_import_request_id       NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        var_log                     VARCHAR2(1000);
        var_user_id                 NUMBER := FND_GLOBAL.USER_ID;
        
        var_member_id               NUMBER;
        var_member_account_id       NUMBER;
        var_attribute2              VARCHAR2(50);
        var_attribute3              VARCHAR2(50);
        
        var_loan_id                 NUMBER;
        var_loan_number             NUMBER;
        var_entry_value_export      NUMBER;
        
        var_entry_value             NUMBER;
        var_payment_schedule_id     NUMBER;
        var_payment_number          NUMBER;
        var_payment_amount          NUMBER;
        var_payment_capital         NUMBER;
        var_payment_interest        NUMBER;
        var_payment_interest_late   NUMBER;
        var_expected_payment_amount NUMBER;
        
        var_validate                   NUMBER;
        
        var_wd_payment_capital         NUMBER := 0;
        var_wd_payment_interest        NUMBER := 0;
        var_wd_payment_interest_late   NUMBER := 0;
        
        var_nd_payment_capital         NUMBER := 0;
        var_nd_payment_interest        NUMBER := 0;
        var_nd_payment_interest_late   NUMBER := 0;
        
        var_late_interest_rate         NUMBER := 0;
        
        var_p_payment_capital          NUMBER := 0;
        var_p_payment_interest         NUMBER := 0;
        var_p_payment_interest_late    NUMBER := 0;
        
    BEGIN
    
        var_entry_value := P_ENTRY_VALUE;
        var_member_id := GET_MEMBER_ID(P_PERSON_ID);
        var_loan_id := GET_RESULT_FROM_PAYROLL_RESULT(P_PERSON_ID, P_EXPORT_REQUEST_ID, P_RUN_RESULT_ID, 'Futuro 4');
        var_loan_number := GET_RESULT_FROM_PAYROLL_RESULT(P_PERSON_ID, P_EXPORT_REQUEST_ID, P_RUN_RESULT_ID, 'Folio');
        
        IF var_loan_id = 0 AND var_loan_number <> 0 THEN
            var_loan_id := GET_LOAN_ID(
                                P_MEMBER_ID => var_member_id, 
                                P_LOAN_NUMBER => var_loan_number);
        ELSIF var_loan_id = 0 AND var_loan_number = 0 THEN
            var_loan_id := GET_LOAN_ID(
                                P_PERSON_ID => P_PERSON_ID,
                                P_PAYMENT_AMOUNT => GET_RESULT_FROM_PAYROLL_RESULT(P_PERSON_ID, P_EXPORT_REQUEST_ID, P_RUN_RESULT_ID, 'Amount'));
        END IF;
        
        var_member_account_id := GET_LOAN_MEMBER_ACCOUNT_ID(GET_MEMBER_ID(P_PERSON_ID), var_loan_id);
                                                            
                                                            
        SELECT ASPS.PAYMENT_SCHEDULE_ID,
               ASPS.PAYMENT_NUMBER,
               ASPS.PAYMENT_AMOUNT,
               ASPS.PAYMENT_AMOUNT,
               ASPS.PAYMENT_CAPITAL,
               ASPS.PAYMENT_INTEREST,
               ASPS.PAYMENT_INTEREST_LATE
          INTO var_payment_schedule_id,
               var_payment_number,
               var_payment_amount,
               var_expected_payment_amount,
               var_payment_capital,
               var_payment_interest,
               var_payment_interest_late
          FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
         WHERE 1 = 1
           AND ASPS.LOAN_ID = var_loan_id
           AND ASPS.TIME_PERIOD_ID = P_TIME_PERIOD_ID
           AND ASPS.PERIOD_NAME = P_PERIOD_NAME;
           
        IF TRUNC(var_payment_amount, 0) <> TRUNC(var_entry_value, 0) THEN
            var_payment_amount := var_entry_value; 
            
            IF (var_entry_value - var_payment_interest_late) >= 0 THEN
                var_payment_interest_late := var_payment_interest_late;
            ELSE
                var_payment_interest_late := var_entry_value;
            END IF;
            
            var_entry_value := var_entry_value - var_payment_interest_late;
            
            IF (var_entry_value - var_payment_interest) >= 0 THEN
                var_payment_interest := var_payment_interest;
            ELSE
                var_payment_interest := var_entry_value;
            END IF; 
            
            var_entry_value := var_entry_value - var_payment_interest;
            
            IF (var_entry_value - var_payment_capital) >= 0 THEN
                var_payment_capital := var_payment_capital;
            ELSE
                var_payment_capital := var_entry_value;
            END IF;
            
            var_entry_value := var_entry_value - var_payment_capital;
            
        ELSE
            var_payment_amount := var_payment_amount;
            var_payment_capital := var_payment_capital;
            var_payment_interest := var_payment_interest;
            var_payment_interest_late := var_payment_interest_late;
            
            var_entry_value := var_entry_value - var_payment_amount;
        END IF;
    
        INSERT INTO ATET_SB_LOANS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                MEMBER_ID,
                                                PAYROLL_RESULT_ID,
                                                LOAN_ID,
                                                PERSON_ID,
                                                RUN_RESULT_ID,
                                                EARNED_DATE,
                                                TIME_PERIOD_ID,
                                                PERIOD_NAME,
                                                ELEMENT_NAME,
                                                ENTRY_NAME,
                                                ENTRY_UNITS,
                                                ENTRY_VALUE,
                                                TRANSACTION_CODE,
                                                DEBIT_AMOUNT,
                                                CREDIT_AMOUNT,
                                                PAYMENT_AMOUNT,
                                                PAYMENT_CAPITAL,
                                                PAYMENT_INTEREST,
                                                PAYMENT_INTEREST_LATE,
                                                REQUEST_ID,
                                                ACCOUNTED_FLAG,
                                                CREATION_DATE,
                                                CREATED_BY,
                                                LAST_UPDATE_DATE,
                                                LAST_UPDATED_BY)
                                         VALUES (var_member_account_id,
                                                 var_member_id,
                                                 P_PAYROLL_RESULT_ID,
                                                 var_loan_id,
                                                 P_PERSON_ID,
                                                 P_RUN_RESULT_ID,
                                                 P_EARNED_DATE,
                                                 P_TIME_PERIOD_ID,
                                                 P_PERIOD_NAME,
                                                 P_ELEMENT_NAME,
                                                 P_ENTRY_NAME,
                                                 P_ENTRY_UNITS,
                                                 P_ENTRY_VALUE,
                                                 'PROCESSED',
                                                 P_DEBIT_AMOUNT,
                                                 P_CREDIT_AMOUNT,
                                                 var_payment_amount,
                                                 var_payment_capital,
                                                 var_payment_interest,
                                                 var_payment_interest_late,
                                                 var_import_request_id,
                                                 'UNACCOUNTED',
                                                  SYSDATE,
                                                  var_user_id,
                                                  SYSDATE,
                                                  var_user_id);
                                                  
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET DEBIT_BALANCE = DEBIT_BALANCE + P_DEBIT_AMOUNT,
               CREDIT_BALANCE = CREDIT_BALANCE + (var_payment_capital + var_payment_interest),
               LAST_TRANSACTION_DATE = SYSDATE               
         WHERE MEMBER_ID = var_member_id
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET FINAL_BALANCE = DEBIT_BALANCE - CREDIT_BALANCE,
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = var_user_id             
         WHERE MEMBER_ID = var_member_id
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
        UPDATE ATET_SB_LOANS ASL
           SET ASL.LOAN_BALANCE = ASL.LOAN_BALANCE - (var_payment_capital + var_payment_interest),
               ASL.LAST_PAYMENT_DATE = P_EARNED_DATE,
               ASL.LAST_UPDATE_DATE = SYSDATE,
               ASL.LAST_UPDATED_BY = var_user_id
         WHERE 1 = 1
           AND ASL.LOAN_ID = var_loan_id;
           
                     
        IF TRUNC(var_expected_payment_amount, 0) = TRUNC(P_ENTRY_VALUE, 0) THEN
            UPDATE ATET_SB_PAYMENTS_SCHEDULE ASPS
               SET ASPS.STATUS_FLAG = 'PAYED',
                   ASPS.LAST_UPDATE_DATE = SYSDATE,
                   ASPS.LAST_UPDATED_BY = var_user_id
             WHERE ASPS.PAYMENT_SCHEDULE_ID = var_payment_schedule_id
               AND ASPS.LOAN_ID = var_loan_id;
        ELSIF P_ENTRY_VALUE > 0 THEN
            UPDATE ATET_SB_PAYMENTS_SCHEDULE ASPS
               SET ASPS.STATUS_FLAG = 'PARTIAL',
                   ASPS.ATTRIBUTE1 = ASPS.PAYMENT_CAPITAL - var_payment_capital,
                   ASPS.ATTRIBUTE2 = ASPS.PAYMENT_INTEREST - var_payment_interest,
                   ASPS.ATTRIBUTE3 = ASPS.PAYMENT_INTEREST_LATE - var_payment_interest_late,
                   ASPS.ATTRIBUTE6 = HAS_DISABILITIES(P_PERSON_ID, ASPS.TIME_PERIOD_ID),
                   ASPS.LAST_UPDATE_DATE = SYSDATE,
                   ASPS.LAST_UPDATED_BY = var_user_id
             WHERE ASPS.PAYMENT_SCHEDULE_ID = var_payment_schedule_id
               AND ASPS.LOAN_ID = var_loan_id;
        ELSIF P_ENTRY_VALUE = 0 THEN
            UPDATE ATET_SB_PAYMENTS_SCHEDULE ASPS
               SET ASPS.STATUS_FLAG = 'PARTIAL',
                   ASPS.ATTRIBUTE1 = ASPS.PAYMENT_CAPITAL - var_payment_capital,
                   ASPS.ATTRIBUTE2 = ASPS.PAYMENT_INTEREST - var_payment_interest,
                   ASPS.ATTRIBUTE3 = ASPS.PAYMENT_INTEREST_LATE - var_payment_interest_late,
                   ASPS.ATTRIBUTE6 = HAS_DISABILITIES(P_PERSON_ID, ASPS.TIME_PERIOD_ID),
                   ASPS.LAST_UPDATE_DATE = SYSDATE,
                   ASPS.LAST_UPDATED_BY = var_user_id
             WHERE ASPS.PAYMENT_SCHEDULE_ID = var_payment_schedule_id
               AND ASPS.LOAN_ID = var_loan_id;                   
        END IF;
        
        
        UPDATE ATET_SB_PAYMENTS_SCHEDULE ASPS
               SET ASPS.STATUS_FLAG = 'SKIP',
                   ASPS.ATTRIBUTE1 = ASPS.PAYMENT_CAPITAL,
                   ASPS.ATTRIBUTE2 = ASPS.PAYMENT_INTEREST,
                   ASPS.ATTRIBUTE3 = ASPS.PAYMENT_INTEREST_LATE,
                   ASPS.ATTRIBUTE6 = HAS_DISABILITIES(P_PERSON_ID, ASPS.TIME_PERIOD_ID),
                   ASPS.LAST_UPDATE_DATE = SYSDATE,
                   ASPS.LAST_UPDATED_BY = var_user_id
             WHERE 1 = 1
               AND ASPS.LOAN_ID = var_loan_id
               AND ASPS.PAYMENT_NUMBER BETWEEN 1 AND var_payment_number
               AND ASPS.STATUS_FLAG IN ('PENDING', 'EXPORTED');    
               
               
        /***********************  INTERESES  MORATORIOS  **********************/
        
        SELECT COUNT(ASPS.PAYMENT_SCHEDULE_ID)
          INTO var_validate
          FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
         WHERE 1 = 1
           AND ASPS.LOAN_ID = var_loan_id
           AND ASPS.STATUS_FLAG IN ('PENDING', 'EXPORTED')
           AND ASPS.PAYMENT_NUMBER > var_payment_number;
           
        IF var_validate = 0 THEN
        
            SELECT COUNT(ASPS.PAYMENT_SCHEDULE_ID)
              INTO var_validate
              FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
             WHERE 1 = 1
               AND ASPS.LOAN_ID = var_loan_id
               AND ASPS.STATUS_FLAG IN ('SKIP', 'PARTIAL');
               
            IF var_validate > 0 THEN
        
                var_late_interest_rate := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LATE_INT');
                
                SELECT NVL(SUM(ASPS.ATTRIBUTE1), 0)  AS  PAYMENT_CAPITAL,
                       NVL(SUM(ASPS.ATTRIBUTE2), 0)  AS  PAYMENT_INTEREST,
                       NVL(SUM(ASPS.ATTRIBUTE3), 0)  AS  PAYMENT_INTEREST_LATE
                  INTO var_nd_payment_capital,
                       var_nd_payment_interest,
                       var_nd_payment_interest_late
                  FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
                 WHERE 1 = 1
                   AND ASPS.LOAN_ID = var_loan_id
                   AND ASPS.STATUS_FLAG IN ('SKIP', 'PARTIAL')
                   AND ASPS.ATTRIBUTE6 IS NULL;
                   
                SELECT NVL(SUM(ASPS.ATTRIBUTE1), 0)  AS  PAYMENT_CAPITAL,
                       NVL(SUM(ASPS.ATTRIBUTE2), 0)  AS  PAYMENT_INTEREST,
                       NVL(SUM(ASPS.ATTRIBUTE3), 0)  AS  PAYMENT_INTEREST_LATE
                  INTO var_wd_payment_capital,
                       var_wd_payment_interest,
                       var_wd_payment_interest_late
                  FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
                 WHERE 1 = 1
                   AND ASPS.LOAN_ID = var_loan_id
                   AND ASPS.STATUS_FLAG IN ('SKIP', 'PARTIAL')
                   AND ASPS.ATTRIBUTE6 = 'DISABILITIES';
                   
                var_wd_payment_capital := var_wd_payment_capital;
                var_wd_payment_interest := var_wd_payment_interest;
                var_wd_payment_interest_late := var_wd_payment_interest_late;
                
                var_nd_payment_capital := var_nd_payment_capital;
                var_nd_payment_interest := var_nd_payment_interest;
                var_nd_payment_interest_late := TRUNC((var_nd_payment_interest_late + ((var_nd_payment_capital + var_nd_payment_interest) * (var_late_interest_rate / 100))), 2);
                
                var_p_payment_capital := var_wd_payment_capital + var_nd_payment_capital;
                var_p_payment_interest := var_wd_payment_interest + var_nd_payment_interest;
                var_p_payment_interest_late := TRUNC((var_wd_payment_interest_late + var_nd_payment_interest_late), 2);
                
                EXTEND_PAYMENTS_SCHEDULE(P_LOAN_ID => var_loan_id,
                                         P_PERSON_ID => P_PERSON_ID,
                                         P_MEMBER_ID => var_member_id,
                                         P_TIME_PERIOD_ID => P_TIME_PERIOD_ID,
                                         P_ACTUAL_DATE_EARNED => P_EARNED_DATE,
                                         P_PAYMENT_CAPITAL => var_p_payment_capital,
                                         P_PAYMENT_INTEREST => var_p_payment_interest,
                                         P_PAYMENT_INTEREST_LATE => var_p_payment_interest_late);
                                         
            END IF;
        
        END IF;
        
        /**********************************************************************/
        
        SELECT COUNT(ASPS.PAYMENT_NUMBER)
          INTO var_validate
          FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
         WHERE 1 = 1
           AND ASPS.LOAN_ID = var_loan_id
           AND ASPS.STATUS_FLAG NOT IN ('PAYED', 'REFINANCED');
           
        IF var_validate = 0 THEN
        
            UPDATE ATET_SB_LOANS ASL
               SET ASL.LOAN_STATUS_FLAG = 'PAYED',
                   ASL.LAST_UPDATE_DATE = SYSDATE,
                   ASL.LAST_UPDATED_BY = var_user_id
             WHERE ASL.LOAN_ID = var_loan_id;

             
            MERGE INTO ATET_SB_MEMBERS      ASM
                 USING ATET_SB_ENDORSEMENTS ASE
                    ON (    ASE.LOAN_ID = var_loan_id
                        AND ASE.MEMBER_ENDORSEMENT_ID = ASM.MEMBER_ID)
            WHEN MATCHED THEN 
            UPDATE SET ASM.IS_ENDORSEMENT = 'N',
                       ASM.LAST_UPDATE_DATE = SYSDATE,
                       ASM.LAST_UPDATED_BY = var_user_id;      


            SELECT COUNT(ASL.LOAN_ID)
              INTO var_validate
              FROM ATET_SB_LOANS ASL
             WHERE 1 = 1
               AND ASL.MEMBER_ID = var_member_id
               AND ASL.LOAN_STATUS_FLAG = 'ACTIVE';

            IF var_validate = 0 THEN 
                MERGE INTO ATET_SB_MEMBERS      ASM
                     USING ATET_SB_ENDORSEMENTS ASE
                        ON (    ASE.LOAN_ID = var_loan_id
                            AND ASE.MEMBER_BORROWER_ID = ASM.MEMBER_ID)
                WHEN MATCHED THEN 
                UPDATE SET ASM.IS_BORROWER = 'N',
                           ASM.LAST_UPDATE_DATE = SYSDATE,
                           ASM.LAST_UPDATED_BY = var_user_id;
            END IF;
        
        END IF;
           
                                                  
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'MOVIMIENTO PROCESADO: *PRESTAMO*' || P_PAYROLL_RESULT_ID  || ','
                                                                              || P_PERSON_ID          || ','
                                                                              || P_RUN_RESULT_ID      || ','
                                                                              || P_EARNED_DATE        || ','
                                                                              || P_PERIOD_NAME        || ','
                                                                              || P_ELEMENT_NAME       || ','
                                                                              || P_ENTRY_NAME         || ','
                                                                              || P_ENTRY_UNITS        || ','
                                                                              || P_ENTRY_VALUE        || ','
                                                                              || P_DEBIT_AMOUNT       || ','
                                                                              || P_CREDIT_AMOUNT      || '.'); 
                                                                              
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT_LOAN_TRANSACTION(P_EXPORT_REQUEST_ID => ' || P_EXPORT_REQUEST_ID ||
                                                               ',P_PAYROLL_RESULT_ID => ' || P_PAYROLL_RESULT_ID ||
                                                               ',P_PERSON_ID => ' || P_PERSON_ID ||
                                                               ',P_RUN_RESULT_ID => ' || P_RUN_RESULT_ID ||
                                                               ',P_EARNED_DATE => ' || P_EARNED_DATE ||
                                                               ',P_TIME_PERIOD_ID => ' || P_TIME_PERIOD_ID ||
                                                               ',P_PERIOD_NAME => ' || P_PERIOD_NAME ||
                                                               ',P_ELEMENT_NAME => ' || P_ELEMENT_NAME ||
                                                               ',P_ENTRY_NAME => ' || P_ENTRY_NAME ||
                                                               ',P_ENTRY_UNITS => ' || P_ENTRY_UNITS ||
                                                               ',P_ENTRY_VALUE => ' || P_ENTRY_VALUE ||
                                                               ',P_DEBIT_AMOUNT => ' || P_DEBIT_AMOUNT ||
                                                               ',P_CREDIT_AMOUNT => ' || P_CREDIT_AMOUNT || ') RETURN Y');                          
    
        RETURN 'Y';
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'NO SE PROCESO EL MOVIMIENTO: *PRESTAMO*' || P_PAYROLL_RESULT_ID  || ','
                                                                                  || P_PERSON_ID          || ','
                                                                                  || P_RUN_RESULT_ID      || ','
                                                                                  || P_EARNED_DATE        || ','
                                                                                  || P_PERIOD_NAME        || ','
                                                                                  || P_ELEMENT_NAME       || ','
                                                                                  || P_ENTRY_NAME         || ','
                                                                                  || P_ENTRY_UNITS        || ','
                                                                                  || P_ENTRY_VALUE        || ','
                                                                                  || P_DEBIT_AMOUNT       || ','
                                                                                  || P_CREDIT_AMOUNT      || '.' || SQLERRM);
                                                                                  
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT_LOAN_TRANSACTION(P_EXPORT_REQUEST_ID => ' || P_EXPORT_REQUEST_ID ||
                                                               ',P_PAYROLL_RESULT_ID => ' || P_PAYROLL_RESULT_ID ||
                                                               ',P_PERSON_ID => ' || P_PERSON_ID ||
                                                               ',P_RUN_RESULT_ID => ' || P_RUN_RESULT_ID ||
                                                               ',P_EARNED_DATE => ' || P_EARNED_DATE ||
                                                               ',P_TIME_PERIOD_ID => ' || P_TIME_PERIOD_ID ||
                                                               ',P_PERIOD_NAME => ' || P_PERIOD_NAME ||
                                                               ',P_ELEMENT_NAME => ' || P_ELEMENT_NAME ||
                                                               ',P_ENTRY_NAME => ' || P_ENTRY_NAME ||
                                                               ',P_ENTRY_UNITS => ' || P_ENTRY_UNITS ||
                                                               ',P_ENTRY_VALUE => ' || P_ENTRY_VALUE ||
                                                               ',P_DEBIT_AMOUNT => ' || P_DEBIT_AMOUNT ||
                                                               ',P_CREDIT_AMOUNT => ' || P_CREDIT_AMOUNT || ') RETURN N');
                                                               
        ROLLBACK;
        RETURN 'N';
    END INSERT_LOAN_TRANSACTION;