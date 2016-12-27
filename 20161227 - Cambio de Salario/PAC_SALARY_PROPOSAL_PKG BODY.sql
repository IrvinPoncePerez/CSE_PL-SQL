CREATE OR REPLACE PACKAGE BODY PAC_SALARY_PROPOSAL_PKG AS

    PROCEDURE   CHANGE_SALARY (
        P_ERRBUF    OUT NOCOPY  VARCHAR2,
        P_RETCODE   OUT NOCOPY  VARCHAR2,
        P_EMPLOYEE_NUMBER       NUMBER,
        P_SALARY                NUMBER,
        P_EFFECTIVE_DATE        DATE)
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
        var_change_date                   DATE;
        var_proposal_reason               VARCHAR2(500);
        var_proposed_salary_n             NUMBER;
        var_date_to                       DATE;    
    BEGIN
        
        HR_MAINTAIN_PROPOSAL_API.INSERT_SALARY_PROPOSAL
            (
                P_PAY_PROPOSAL_ID           => var_pay_proposal_id,
                P_ASSIGNMENT_ID             => var_assignment_id,
                P_BUSINESS_GROUP_ID         => var_business_group_id,
                P_CHANGE_DATE               => var_change_date,
                P_PROPOSAL_REASON           => var_proposal_reason,
                P_PROPOSED_SALARY_N         => var_proposed_salary_n,
                P_DATE_TO                   => var_date_to,
                P_OBJECT_VERSION_NUMBER     => var_object_version_number,
                P_ELEMENT_ENTRY_ID          => var_element_entry_id,
                P_INV_NEXT_SAL_DATE_WARNING	=> var_inv_next_sal_date_warning,
                P_PROPOSED_SALARY_WARNING   => var_proposed_salary_warning,
                P_APPROVED_WARNING          => var_approved_warning,
                P_PAYROLL_WARNING		    => var_payroll_warning
            );
        
    
    END CHANGE_SALARY;
    
END PAC_SALARY_PROPOSAL_PKG;