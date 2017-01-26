CREATE OR REPLACE PACKAGE BODY APPS.PAC_RFC_SAT_PKG AS

    PROCEDURE   UPDATE_RFC(
        P_ERRBUF    OUT NOCOPY  VARCHAR2,
        P_RETCODE   OUT NOCOPY  VARCHAR2,
        P_EMPLOYEE_NUMBER       VARCHAR2,
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

        HR_MX_PERSON_API.UPDATE_MX_PERSON
            (
              p_effective_date             => var_effective_date,
              p_datetrack_update_mode      => var_datetrack_update_mode,
              p_person_id                  => var_person_id,
              p_object_version_number      => var_object_version_number,
              p_employee_number            => var_employee_number,
              p_RFC_id                     => P_RFC,
              p_effective_start_date       => var_effective_start_date,
              p_effective_end_date         => var_effective_end_date,
              p_full_name                  => var_full_name,
              p_comment_id                 => var_comment_id,
              p_name_combination_warning   => var_name_combination_warning,
              p_assign_payroll_warning     => var_assign_payroll_warning,
              p_orig_hire_warning          => var_orig_hire_warning
            );                  
            
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
    
    PROCEDURE   BULK_UPDATE_RFC(
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
            SELECT PURT.EMPLOYEE_NUMBER,
                   PURT.EMPLOYEE_NAME,
                   PURT.RFC
              FROM PAC_UPDATE_RFC_TB    PURT;
                  
    BEGIN

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'XXCALV - Actualización de RFC SAT (Carga de Datos)');
        FND_FILE.PUT_LINE(FND_FILE.LOG,  'Inicio : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS'));
    
        var_request_id :=
            FND_REQUEST.SUBMIT_REQUEST 
                (
                    APPLICATION => 'PER',
                    PROGRAM     => 'PAC_UPDATE_RFC',
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
        
            FOR RFC IN DETAILS LOOP
                FND_FILE.PUT_LINE(FND_FILE.LOG, '');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'XXCALV - Actualización de RFC SAT (Por Empleado)');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parámetros : ' || TO_CHAR(RFC.EMPLOYEE_NUMBER)
                                                                || ', '  
                                                                || TO_CHAR(RFC.EMPLOYEE_NAME)
                                                                || ', '
                                                                || TO_CHAR(RFC.RFC));
                FND_FILE.PUT_LINE(FND_FILE.LOG,  'Inicio : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS'));
                
                 var_request_id :=
                    FND_REQUEST.SUBMIT_REQUEST 
                        (
                            APPLICATION => 'PER',
                            PROGRAM     => 'PAC_UPDATE_RFC_SAT',
                            DESCRIPTION => '',
                            START_TIME  => '',
                            SUB_REQUEST => FALSE,
                            ARGUMENT1   => TO_CHAR(RFC.EMPLOYEE_NUMBER),
                            ARGUMENT2   => TO_CHAR(RFC.RFC)
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
        
        EXECUTE IMMEDIATE 'TRUNCATE TABLE PAC_UPDATE_RFC_TB';
        
    END BULK_UPDATE_RFC;

END PAC_RFC_SAT_PKG;