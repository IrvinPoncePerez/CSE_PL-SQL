CREATE OR REPLACE PACKAGE BODY PAC_RFC_SAT_PKG AS

    PROCEDURE   UPDATE_RFC(
        P_ERRBUF    OUT NOCOPY  VARCHAR2,
        P_RETCODE   OUT NOCOPY  VARCHAR2,
        P_EMPLOYEE_NUMBER       NUMBER,
        P_RFC                   VARCHAR2)
    IS
        var_effective_date               DATE;
        var_datetrack_update_mode        VARCHAR2(100);
        var_person_id                    NUMBER;
        var_object_version_number        NUMBER;
        var_employee_number              VARCHAR2(100);
        var_effective_start_date         DATE;
        var_effective_end_date           DATE;
        var_full_name                    VARCHAR2(900);
        var_comment_id                   NUMBER;
        var_name_combination_warning     BOOLEAN;
        var_assign_payroll_warning       BOOLEAN;
        var_orig_hire_warning            BOOLEAN;
    BEGIN
    
        SELECT SYSDATE,
               'CORRECTION',
               PPF.PERSON_ID,
               PPF.OBJECT_VERSION_NUMBER,
               PPF.EMPLOYEE_NUMBER
          INTO var_effective_date,
               var_datetrack_update_mode,
               var_person_id,
               var_object_version_number,
               var_employee_number
          FROM PER_PEOPLE_F     PPF
         WHERE 1 = 1
           AND PPF.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
           AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE;
           
        
        HR_PERSON_API.UPDATE_PERSON
            (
              p_effective_date             => var_effective_date
              ,p_datetrack_update_mode      => var_datetrack_update_mode
              ,p_person_id                  => var_person_id
              ,p_object_version_number      => var_object_version_number
              ,p_employee_number            => var_employee_number
              ,p_per_information2           => P_RFC
              ,p_effective_start_date       => var_effective_start_date
              ,p_effective_end_date         => var_effective_end_date
              ,p_full_name                  => var_full_name
              ,p_comment_id                 => var_comment_id
              ,p_name_combination_warning   => var_name_combination_warning
              ,p_assign_payroll_warning     => var_assign_payroll_warning
              ,p_orig_hire_warning          => var_orig_hire_warning
            );   
            
        COMMIT;
            
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_effective_date : ' || TO_CHAR(var_effective_date));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_datetrack_update_mode : ' || TO_CHAR(var_datetrack_update_mode));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_person_id : ' || TO_CHAR(var_person_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_object_version_number : ' || TO_CHAR(var_object_version_number));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_employee_number : ' || TO_CHAR(var_employee_number));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_RFC : ' || TO_CHAR(P_RFC));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_effective_start_date : ' || TO_CHAR(var_effective_start_date));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_effective_end_date : ' || TO_CHAR(var_effective_end_date));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_full_name : ' || TO_CHAR(var_full_name));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_comment_id : ' || TO_CHAR(var_comment_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_name_combination_warning : ' || (CASE WHEN var_name_combination_warning = TRUE THEN 'TRUE' ELSE 'FALSE' END));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_assign_payroll_warning : ' || (CASE WHEN var_assign_payroll_warning = TRUE THEN 'TRUE' ELSE 'FALSE' END));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'var_orig_hire_warning : ' || (CASE WHEN var_orig_hire_warning = TRUE THEN 'TRUE' ELSE 'FALSE' END));
    
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 1;
        P_ERRBUF := 'Error al actualizar el RFC. ' || SQLERRM;
    END UPDATE_RFC;

END PAC_RFC_SAT_PKG;