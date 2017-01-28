DECLARE

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
    
    var_rfc                          VARCHAR2(100);
BEGIN

    FND_GLOBAL.APPS_INITIALIZE (USER_ID        => 3397,
                                RESP_ID        => 53698,
                                RESP_APPL_ID   => 101);
                       
    MO_GLOBAL.SET_POLICY_CONTEXT ('S', 1329);

    SELECT SYSDATE,
           'CORRECTION',
           PPF.PERSON_ID,
           PPF.OBJECT_VERSION_NUMBER,
           PPF.EMPLOYEE_NUMBER,
           PPF.PER_INFORMATION2
      INTO var_effective_date,
           var_datetrack_update_mode,
           var_person_id,
           var_object_version_number,
           var_employee_number,
           var_rfc
      FROM PER_PEOPLE_F     PPF
     WHERE 1 = 1
       AND PPF.EMPLOYEE_NUMBER = :P_EMPLOYEE_NUMBER
       AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE;
       
    dbms_output.put_line(var_rfc);
    
    HR_MX_PERSON_API.UPDATE_MX_PERSON
        (
          p_effective_date             => var_effective_date,
          p_datetrack_update_mode      => var_datetrack_update_mode,
          p_person_id                  => var_person_id,
          p_object_version_number      => var_object_version_number,
          p_employee_number            => var_employee_number,
          p_RFC_id                     => :P_RFC,
          p_effective_start_date       => var_effective_start_date,
          p_effective_end_date         => var_effective_end_date,
          p_full_name                  => var_full_name,
          p_comment_id                 => var_comment_id,
          p_name_combination_warning   => var_name_combination_warning,
          p_assign_payroll_warning     => var_assign_payroll_warning,
          p_orig_hire_warning          => var_orig_hire_warning
        );    
        
    COMMIT;              
            
    SELECT PPF.PER_INFORMATION2
      INTO var_rfc
      FROM PER_PEOPLE_F     PPF
     WHERE 1 = 1
       AND PPF.EMPLOYEE_NUMBER = :P_EMPLOYEE_NUMBER
       AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE;
       
    dbms_output.put_line(var_rfc);
    

END;

