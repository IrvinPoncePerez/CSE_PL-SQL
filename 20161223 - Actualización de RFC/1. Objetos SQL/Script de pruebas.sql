DECLARE
    
    CURSOR  RFC_DETAILS
        IS
    SELECT PURT.EMPLOYEE_NUMBER,
           PURT.RFC
      FROM PAC_UPDATE_RFC_TB    PURT
     WHERE 1 = 1; 
    
BEGIN

    FND_GLOBAL.APPS_INITIALIZE 
        (
            USER_ID        => 3397,
            RESP_ID        => 50668,
            RESP_APPL_ID   => 800
        );
                       
    MO_GLOBAL.SET_POLICY_CONTEXT 
        (
            P_ACCESS_MODE   => 'S',
            P_ORG_ID        => 1329
        );
        
        
    FOR RFC IN RFC_DETAILS LOOP        
        DECLARE
            var_effective_date               DATE           := NULL;
            var_datetrack_update_mode        VARCHAR2(100)  := NULL;
            var_person_id                    NUMBER         := NULL;
            var_object_version_number        NUMBER         := NULL;
            var_employee_number              VARCHAR2(100)  := NULL;
            var_effective_start_date         DATE           := NULL;
            var_effective_end_date           DATE           := NULL;
            var_full_name                    VARCHAR2(900)  := NULL;
            var_comment_id                   NUMBER         := NULL;
            var_name_combination_warning     BOOLEAN        := NULL;
            var_assign_payroll_warning       BOOLEAN        := NULL;
            var_orig_hire_warning            BOOLEAN        := NULL;
            var_rfc                          VARCHAR2(100)  := NULL;
        BEGIN
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
               AND PPF.EMPLOYEE_NUMBER = RFC.EMPLOYEE_NUMBER
               AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE;
               
            dbms_output.put('Empleado : ' || var_employee_number || '|' || var_rfc || '|');
            
            HR_PERSON_API.UPDATE_PERSON
                (
                  p_validate                   => FALSE,
                  p_effective_date             => var_effective_date,
                  p_datetrack_update_mode      => var_datetrack_update_mode,
                  p_person_id                  => var_person_id,
                  p_object_version_number      => var_object_version_number,
                  p_employee_number            => var_employee_number,
                  p_per_information2           => RFC.RFC,
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
               AND PPF.EMPLOYEE_NUMBER = RFC.EMPLOYEE_NUMBER
               AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE;
               
            dbms_output.put_line(var_full_name || '|' || var_rfc);
        END;
    END LOOP;
    
    DELETE FROM PAC_UPDATE_RFC_TB;
    COMMIT;

END;

ORA-20001: FLEX-VALUE TOO LONG: N, VALUE, SAHA-940102-6V8
, N, LENGTH, 15
ORA-06512: at "APPS.HR_PERSON_API", line 1100
ORA-06512: at "APPS.HR_MX_PERSON_API", line 193


SELECT *
  FROM DBA_INVALID_OBJECTS;