CREATE OR REPLACE PROCEDURE APPS.atet_autoloans_prc (errbuf       OUT NOCOPY varchar2,
                                               retcode      OUT NOCOPY varchar2
                                              )  AUTHID CURRENT_USER
IS
    --Autoloans
    v_loan_number       number;
    v_loan_id           number;
    v_payment_deadline  date;
    v_check_id          number;

    --Pagare
    add_layout_boolean  BOOLEAN;
    v_request_id        number;
    waiting             BOOLEAN;
    phase               varchar2(80 BYTE);
    status              varchar2(80 BYTE);
    dev_phase           varchar2(80 BYTE);
    dev_status          varchar2(80 BYTE);
    v_message           varchar2(4000 BYTE);

    --Cheque
    v_request_id_ch     number;
    waiting_ch          BOOLEAN;
    phase_ch            varchar2(80 BYTE);
    status_ch           varchar2(80 BYTE);
    dev_phase_ch        varchar2(80 BYTE);
    dev_status_ch       varchar2(80 BYTE);
    v_message_ch        varchar2(4000 BYTE);

    -- Empleados que deben más de 50 pesos de intereses 
    -- a los que se les creará un préstamos obligatorio en automático
    CURSOR autoloans_cur 
    IS
    SELECT MEMBER_ID,
           PERSON_ID,
           EMPLOYEE_NUMBER,
           EMPLOYEE_FULL_NAME,
           DECODE (PERIOD_TYPE, 'Week', 'Semana', 'Quincena') PERIOD_TYPE,
           AMOUNT_TO_SAVE,
           MINIMUM_INTEREST,
           PAYED_INTEREST,
           INTEREST_REMAINING,
           MANDATORY_LOAN_AMOUNT,
           INTEREST_REMAINING + MANDATORY_LOAN_AMOUNT TOTAL_AMOUNT,
           CASE PERIOD_TYPE 
                WHEN 'Week' THEN 16
                WHEN 'Semi-Month' THEN 8 
           END TERM_PERIODS
      FROM (SELECT MEMBERS.MEMBER_ID,
                   PERSON_ID,
                   EMPLOYEE_NUMBER,
                   EMPLOYEE_FULL_NAME,
                   PERIOD_TYPE,
                   AMOUNT_TO_SAVE,
                   --                 MINIMUM_LOAN,
                   MINIMUM_INTEREST,
                   --                 NVL (LOAN, MINIMUM_LOAN) LOAN,
                   NVL (INTEREST, 0) PAYED_INTEREST,
                   --                 NVL (MINIMUM_LOAN - LOAN, MINIMUM_LOAN) LOAN_REMAINING,
                   NVL (MINIMUM_INTEREST - INTEREST, MINIMUM_INTEREST)
                   INTEREST_REMAINING,
                   (NVL (MINIMUM_INTEREST - INTEREST, MINIMUM_INTEREST) * 1) / 0.08 MANDATORY_LOAN_AMOUNT
              FROM (SELECT EMPLOYEE_NUMBER,
                           EMPLOYEE_FULL_NAME,
                           ASM.MEMBER_ID,
                           ASM.PERSON_ID,
                           ASM.ATTRIBUTE6,
                           PPF.PERIOD_TYPE,
                           AMOUNT_TO_SAVE,
                           CASE PPF.PERIOD_TYPE
                               WHEN 'Week' THEN (AMOUNT_TO_SAVE * 16)
                               WHEN 'Semi-Month' THEN (AMOUNT_TO_SAVE * 8)
                           END
                           MINIMUM_LOAN,
                           CASE PPF.PERIOD_TYPE
                               WHEN 'Week'
                               THEN
                                    (AMOUNT_TO_SAVE * 16) * 0.08
                               WHEN 'Semi-Month'
                               THEN
                                    (AMOUNT_TO_SAVE * 8) * 0.08
                           END
                           MINIMUM_INTEREST
                      FROM ATET_SB_MEMBERS ASM,
                           PER_ALL_ASSIGNMENTS_F PAAF,
                           PAY_PAYROLLS_F PPF
                     WHERE 1 = 1
                       AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE
                       AND PPF.EFFECTIVE_END_DATE
                       AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE
                       AND PAAF.EFFECTIVE_END_DATE
                       AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
                       AND PAAF.PERSON_ID = ASM.PERSON_ID
                       AND ASM.ATTRIBUTE6 = PPF.PERIOD_TYPE
                       AND IS_SAVER = 'Y'          
                       --                            AND MEMBER_ID = 1765
                       AND ATET_SAVINGS_BANK_PKG.GET_PERSON_TYPE(ASM.MEMBER_ID) IN ('Employee', 'Empleado')
                       AND SAVING_BANK_ID = ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                       ) MEMBERS
              LEFT OUTER JOIN
              (SELECT MEMBER_ID,
                      SUM (LOAN_AMOUNT) LOAN,
                      SUM (LOAN_INTEREST_AMOUNT) INTEREST
                 FROM ATET_SB_LOANS
                WHERE 1 = 1 AND LOAN_STATUS_FLAG IN ('PAYED', 'ACTIVE')
                GROUP BY MEMBER_ID) LOANS
                ON MEMBERS.MEMBER_ID = LOANS.MEMBER_ID
             ORDER BY 4)
     WHERE 1 = 1 AND INTEREST_REMAINING > ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID,'MIN_INTEREST_REMAINING')
     ORDER 
        BY INTEREST_REMAINING;
BEGIN
    dbms_output.put_line('0');
    FOR autoloans IN autoloans_cur LOOP
        dbms_output.put_line('1');    
        --Obtiene consecutivo del número de préstamo
        BEGIN
            SELECT atet_sb_loan_number_seq.NEXTVAL
              INTO v_loan_number
              FROM dual;
            dbms_output.put_line('2');
        EXCEPTION WHEN others THEN
            dbms_output.put_line('Error en secuencia número de préstamo.');
            fnd_file.put_line (fnd_file.LOG, 'Error en secuencia número de préstamo.');
            RAISE;
        END;
        
        --Obtiene consecutivo del id del préstamo
        BEGIN
            SELECT atet_sb_loans_seq.NEXTVAL
              INTO v_loan_id
              FROM dual;
            dbms_output.put_line('3');
        EXCEPTION WHEN others THEN
            dbms_output.put_line('Error en secuencia ID de préstamo.');
            fnd_file.put_line (fnd_file.LOG, 'Error en secuencia ID de préstamo.');
            RAISE;
        END;
        
        --Crea el registro del préstamo
        BEGIN
           INSERT INTO atet_sb_loans 
           VALUES (v_loan_id,                               --loan_id
                   autoloans.member_id,                     --member_id
                   v_loan_number,                           --loan_number
                   autoloans.total_amount,                  --loan_total_amount
                   autoloans.mandatory_loan_amount,         --loan_amount
                   autoloans.interest_remaining,            --loan_interest_amount
                   8,                                       --loan_interest_rate                                       
                   autoloans.term_periods,                  --term_periods
                   2,                                       --normal_interest_rate
                   5,                                       --late_interest_rate
                   TO_CHAR(SYSDATE,'DD/MM/RRRR'),           --transaction_date
                   TO_DATE(NULL),                           --payment_deadline
                   autoloans.period_type,                   --period_type
                   'ACTIVE',                                --loan_status_flag
                   autoloans.total_amount,                  --loan_balance                                       
                   TO_DATE(NULL),                           --last_payment_date
                   TO_CHAR(autoloans.total_amount/
                   autoloans.term_periods),                 --attribute1 - partial_loan_amout
                   NULL,                                    --attribute2 - loan_id refinanciamiento
                   NULL,                                    --attribute3 - check_loan_id (de tabla excel)
                   NULL,                                    --attribute4
                   NULL,                                    --attribute5 - monto del cheque del refinanciamiento
                   NULL,                                    --attribute6
                   NULL,                                    --attribute7
                   NULL,                                    --attribute8
                   NULL,                                    --attribute9
                   NULL,                                    --attribute10
                   NULL,                                    --attribute11
                   NULL,                                    --attribute12
                   NULL,                                    --attribute13
                   NULL,                                    --attribute14
                   NULL,                                    --attribute15
                   SYSDATE,                                 --creation_date
                   -1,                                      --created_by
                   SYSDATE,                                 --last_update_date
                   -1                                       --last_updated_by
                  );
           dbms_output.put_line('4');
        EXCEPTION WHEN others THEN
            dbms_output.put_line('Error en insert into ATET_SB_LOANS.');
            fnd_file.put_line (fnd_file.LOG, 'Error en insert into ATET_SB_LOANS.');
            RAISE;
        END;                  
        --Crea cuenta
        BEGIN
            IF atet_savings_bank_pkg.get_member_is_saver(autoloans.member_id) = 'Y' THEN
                --Crea la cuenta del préstamo del ahorrador
                atet_savings_bank_pkg.create_account(autoloans.person_id, 'LOAN_ELEMENT_NAME', 'LOAN_SAV_CODE_COMB');
            ELSE
                --Crea la cuenta del préstamo del no ahorrador
                atet_savings_bank_pkg.create_account(autoloans.person_id, 'LOAN_ELEMENT_NAME', 'LOAN_NO_SAV_CODE_COMB');
            END IF;
            dbms_output.put_line('5');
        EXCEPTION WHEN others THEN
            dbms_output.put_line('Error en código de mandingo 1.');
            fnd_file.put_line (fnd_file.LOG, 'Error en código de mandingo 1.');
            RAISE;
        END;

        --Establece el saldo inicial de la cuenta del préstamo
        BEGIN            
            atet_savings_bank_pkg.set_loan_balance(v_loan_id, autoloans.total_amount, autoloans.person_id);
            dbms_output.put_line('6');
        EXCEPTION WHEN others THEN
            dbms_output.put_line('Error en código de mandingo 2.');
            fnd_file.put_line (fnd_file.LOG, 'Error en código de mandingo 2.');
            RAISE;
        END;

        --Crea la programación de pagos
        BEGIN
            atet_sb_back_office_pkg.create_payments_schedule(v_loan_id, v_payment_deadline);
            UPDATE atet_sb_loans
               set payment_deadline = v_payment_deadline
             WHERE loan_id = v_loan_id;
            dbms_output.put_line('7');
        EXCEPTION WHEN others THEN
            dbms_output.put_line('Error en código de Sam 1.');
            fnd_file.put_line (fnd_file.LOG, 'Error en código Sam 1.');
            RAISE;
        END;
        
        -- Actualización de estatus IS_BORROWER.
        UPDATE ATET_SB_MEMBERS  ASM
           SET IS_BORROWER = 'Y'
         WHERE 1 = 1
           AND MEMBER_ID = autoloans.MEMBER_ID;

        COMMIT;
            
        --Impresión de pagaré
        BEGIN    
            BEGIN
                add_layout_boolean := fnd_request.add_layout (template_appl_name   => 'PER',
                                                              template_code        => 'ATET_SB_PROMISSORY_NOTE',
                                                              template_language    => 'Spanish', --use language from template definition
                                                              template_territory   => 'Mexico', --use territory from template definition
                                                              output_format        => 'PDF' --use output format from template definition
                                                             );

                v_request_id := fnd_request.submit_request ('PER',                        -- application
                                                            'ATET_SB_PROMISSORY_NOTE', -- program short name
                                                            '',                           -- description
                                                            '',                            -- start time
                                                            FALSE,                        -- sub request
                                                            TO_CHAR (v_loan_id),       -- argument1
                                                            CHR (0)       -- represents end of arguments
                                                           );
                COMMIT;
                waiting := fnd_concurrent.wait_for_request (v_request_id,1,0,
                                                            phase,
                                                            status,
                                                            dev_phase,
                                                            dev_status,
                                                            v_message
                                                           );               

                dbms_output.put_line('Por favor imprima la solicitud: '||v_request_id);
                fnd_file.put_line (fnd_file.LOG, 'Por favor imprima la solicitud: '||v_request_id);
                
            EXCEPTION WHEN others THEN
               dbms_output.put_line('Error lanzando concurrente. '||SQLERRM);
               fnd_file.put_line (fnd_file.LOG, 'Error lanzando concurrente. '||SQLERRM);
            END;
        END;

        --Impresión de cheque
        BEGIN
            atet_sb_back_office_pkg.create_loan_check(v_loan_id, v_check_id);
            BEGIN
                /*
                add_layout_boolean :=
                fnd_request.add_layout (
                template_appl_name   => 'per',
                template_code        => 'atet_sb_print_check',
                template_language    => 'spanish', --use language from template definition
                template_territory   => 'mexico', --use territory from template definition
                output_format        => 'pdf' --use output format from template definition
                );
                */                
                                                                
                v_request_id := fnd_request.submit_request ('PER',                      -- application
                                                            'ATET_SB_PRINT_CHECK',      -- program short name
                                                            '',                         -- description
                                                            '',                         -- start time
                                                            FALSE,                      -- sub request
                                                            TO_CHAR (v_check_id),       -- argument1
                                                            CHR (0)                     -- represents end of arguments
                                                           );
                COMMIT;
                waiting := fnd_concurrent.wait_for_request (v_request_id,1,0,
                                                            phase,
                                                            status,
                                                            dev_phase,
                                                            dev_status,
                                                            v_message
                                                           );               
                           dbms_output.put_line('Por favor imprima la solicitud: '||v_request_id);
                           fnd_file.put_line (fnd_file.LOG, 'Por favor imprima la solicitud: '||v_request_id);
            EXCEPTION WHEN others THEN
               dbms_output.put_line('Error lanzando concurrente. '||SQLERRM);
               fnd_file.put_line (fnd_file.LOG, 'Error lanzando concurrente. '||SQLERRM);
            END;
             dbms_output.put_line('8');
        EXCEPTION WHEN others THEN
            dbms_output.put_line('Error creando cheque y lanzando concurrente de impresión.');
            fnd_file.put_line (fnd_file.LOG, 'Error creando cheque y lanzando concurrente de impresión.');
            RAISE;
        END;
/*
        begin
           atet_sb_back_office_pkg.transfer_journals_to_gl;
           dbms_output.put_line('9');
        exception when others then
           dbms_output.put_line('error disparando transfer_journals_to_gl.');
           fnd_file.put_line (fnd_file.log, 'error disparando transfer_journals_to_gl.');
           raise;
        end;                
*/                
    END LOOP;    
    
    
    ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL;
    
                           
EXCEPTION WHEN others THEN
    dbms_output.put_line('Código de error: '||SQLERRM);
    fnd_file.put_line (fnd_file.LOG, 'Código de error: '||SQLERRM);
END;
/
