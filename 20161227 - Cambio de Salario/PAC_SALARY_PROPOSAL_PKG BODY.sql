CREATE OR REPLACE PACKAGE BODY PAC_SALARY_PROPOSAL_PKG AS

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
    
END PAC_SALARY_PROPOSAL_PKG;