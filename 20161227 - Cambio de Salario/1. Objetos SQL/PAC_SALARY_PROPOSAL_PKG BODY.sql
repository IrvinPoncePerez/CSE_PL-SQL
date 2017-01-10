CREATE OR REPLACE PACKAGE BODY APPS.PAC_SALARY_PROPOSAL_PKG AS

    PROCEDURE   CHANGE_SALARY (
        P_ERRBUF    OUT NOCOPY  VARCHAR2,
        P_RETCODE   OUT NOCOPY  VARCHAR2,
        P_EMPLOYEE_NUMBER       NUMBER,
        P_SALARY                NUMBER,
        P_EFFECTIVE_DATE        VARCHAR2)
    IS
        var_pay_proposal_id               NUMBER; 
        var_object_version_number         NUMBER;
        var_element_entry_id              NUMBER;
        var_inv_next_sal_date_warning	  BOOLEAN;
        var_proposed_salary_warning       BOOLEAN;
        var_approved_warning              BOOLEAN;
        var_payroll_warning		          BOOLEAN;   
    
        var_assignment_id                 NUMBER;
        var_business_group_id             NUMBER;
        var_change_date                   DATE := TRUNC(TO_DATE(P_EFFECTIVE_DATE,'RRRR/MM/DD HH24:MI:SS'));
        var_proposal_reason               VARCHAR2(500);
        var_proposed_salary_n             NUMBER;  
    BEGIN
    
        SELECT PAF.ASSIGNMENT_ID,
               PAF.BUSINESS_GROUP_ID,
               'PERE',
               P_SALARY
          INTO var_assignment_id,
               var_business_group_id,
               var_proposal_reason,
               var_proposed_salary_n
          FROM PER_PEOPLE_F         PPF,
               PER_ASSIGNMENTS_F    PAF
         WHERE 1 = 1
           AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE
                           AND PPF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE
                           AND PAF.EFFECTIVE_END_DATE
           AND PPF.PERSON_ID = PAF.PERSON_ID
           AND PPF.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER;
        
        HR_MAINTAIN_PROPOSAL_API.INSERT_SALARY_PROPOSAL
            (
                P_PAY_PROPOSAL_ID           => var_pay_proposal_id,
                P_ASSIGNMENT_ID             => var_assignment_id,
                P_BUSINESS_GROUP_ID         => var_business_group_id,
                P_CHANGE_DATE               => var_change_date,
                P_PROPOSAL_REASON           => var_proposal_reason,
                P_PROPOSED_SALARY_N         => var_proposed_salary_n,
                P_OBJECT_VERSION_NUMBER     => var_object_version_number,
                P_MULTIPLE_COMPONENTS       => 'N',
                P_APPROVED                  => 'Y',
                P_VALIDATE                  => FALSE,
                P_ELEMENT_ENTRY_ID          => var_element_entry_id,
                P_INV_NEXT_SAL_DATE_WARNING	=> var_inv_next_sal_date_warning,
                P_PROPOSED_SALARY_WARNING   => var_proposed_salary_warning,
                P_APPROVED_WARNING          => var_approved_warning,
                P_PAYROLL_WARNING		    => var_payroll_warning
            );
            
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_pay_proposal_id : ' || var_pay_proposal_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_assignment_id : ' || var_assignment_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_business_group_id : ' || var_business_group_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_change_date : ' || var_change_date);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_proposal_reason : ' || var_proposal_reason);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_proposed_salary_n : ' || var_proposed_salary_n);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_object_version_number : ' || var_object_version_number);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_element_entry_id : ' || var_element_entry_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_inv_next_sal_date_warning : ' || (CASE WHEN var_inv_next_sal_date_warning = TRUE THEN 'TRUE' ELSE 'FALSE' END));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_proposed_salary_warning : ' || (CASE WHEN var_proposed_salary_warning = TRUE THEN 'TRUE' ELSE 'FALSE' END));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_approved_warning : ' || (CASE WHEN var_approved_warning = TRUE THEN 'TRUE' ELSE 'FALSE' END));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_payroll_warning : ' || (CASE WHEN var_payroll_warning = TRUE THEN 'TRUE' ELSE 'FALSE' END));
        
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 1;
        P_ERRBUF := 'Error al crear el registro de salario. ' || SQLERRM;
    END CHANGE_SALARY;
    
    PROCEDURE   BULK_CHANGE_SALARY(
        P_ERRBUF    OUT NOCOPY  VARCHAR2,
        P_RETCODE   OUT NOCOPY  VARCHAR2,
        P_FILE_NAME             VARCHAR2)
    IS
        var_request_id      NUMBER;
        var_waiting         BOOLEAN;
        var_phase           VARCHAR2(1000);
        var_status          VARCHAR2(1000);
        var_dev_phase       VARCHAR2(1000);
        var_dev_status      VARCHAR2(1000);
        var_message         VARCHAR2(1000);
        
        CURSOR DETAILS IS
            SELECT PCST.EMPLOYEE_NUMBER,
                   PCST.PROPOSED_SALARY,
                   PCST.CHANGE_DATE
              FROM PAC_CHANGE_SALARY_TB PCST;
    BEGIN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'XXCALV - Cambio de Salario (Carga de Datos)');
        FND_FILE.PUT_LINE(FND_FILE.LOG,  'Inicio : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS'));
    
        var_request_id :=
            FND_REQUEST.SUBMIT_REQUEST 
                (
                    APPLICATION => 'PER',
                    PROGRAM     => 'PAC_CHANGE_SALARY_CTL',
                    DESCRIPTION => '',
                    START_TIME  => '',
                    SUB_REQUEST => FALSE,
                    ARGUMENT1   => TO_CHAR(P_FILE_NAME)
                );
        
        STANDARD.COMMIT;                                          
                                 
        var_waiting :=
            FND_CONCURRENT.WAIT_FOR_REQUEST 
                (
                    REQUEST_ID  => var_request_id,
                    INTERVAL    => 1,
                    MAX_WAIT    => 0,
                    PHASE       => var_phase,
                    STATUS      => var_status,
                    DEV_PHASE   => var_dev_phase,
                    DEV_STATUS  => var_dev_status,
                    MESSAGE     => var_message
                );
                
        FND_FILE.PUT_LINE(FND_FILE.LOG,  'Finalización : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS')); 
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Fase : ' || var_phase || '     Estatus : ' || var_status);   
                
        IF var_phase IN ('Finalizado', 'Completed') AND var_status IN ('Normal') THEN 
        
            FOR SALARY IN DETAILS LOOP
                FND_FILE.PUT_LINE(FND_FILE.LOG, '');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'XXCALV - Cambio de Salario (Por Empleado)');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parámetros : ' || TO_CHAR(SALARY.EMPLOYEE_NUMBER)
                                                                || ', '  
                                                                || TO_CHAR(SALARY.PROPOSED_SALARY)
                                                                || ', '
                                                                || TO_CHAR(SALARY.CHANGE_DATE));
                FND_FILE.PUT_LINE(FND_FILE.LOG,  'Inicio : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS'));
                
                 var_request_id :=
                    FND_REQUEST.SUBMIT_REQUEST 
                        (
                            APPLICATION => 'PER',
                            PROGRAM     => 'PAC_CHANGE_SALARY',
                            DESCRIPTION => '',
                            START_TIME  => '',
                            SUB_REQUEST => FALSE,
                            ARGUMENT1   => TO_CHAR(SALARY.EMPLOYEE_NUMBER),
                            ARGUMENT2   => TO_CHAR(SALARY.PROPOSED_SALARY),
                            ARGUMENT3   => TO_CHAR(TO_DATE(SALARY.CHANGE_DATE,'DD/MM/RRRR'),'RRRR/MM/DD HH24:MI:SS')
                        );
                
                STANDARD.COMMIT; 
                
                var_waiting :=
                    FND_CONCURRENT.WAIT_FOR_REQUEST 
                        (
                            REQUEST_ID  => var_request_id,
                            INTERVAL    => 1,
                            MAX_WAIT    => 0,
                            PHASE       => var_phase,
                            STATUS      => var_status,
                            DEV_PHASE   => var_dev_phase,
                            DEV_STATUS  => var_dev_status,
                            MESSAGE     => var_message
                        );
                
                FND_FILE.PUT_LINE(FND_FILE.LOG,  'Finalización : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS')); 
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Fase : ' || var_phase || '     Estatus : ' || var_status);
            END LOOP;
                
        END IF;
        
        EXECUTE IMMEDIATE 'TRUNCATE TABLE PAC_CHANGE_SALARY_TB';
    END BULK_CHANGE_SALARY;
    
END PAC_SALARY_PROPOSAL_PKG;