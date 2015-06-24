CREATE OR REPLACE PROCEDURE PAC_UPDATE_ACCOUNT_EDENRED_PRC(
            P_ERRBUF    OUT NOCOPY  VARCHAR2,
            P_RETCODE   OUT NOCOPY  VARCHAR2
)
IS

    var_full_name                       VARCHAR2(500);
    var_personal_payment_method_id      NUMBER;
    var_object_version_number           NUMBER;
    var_external_account_id             NUMBER;
    var_attribute1                      VARCHAR2(150);
    var_segment3                        VARCHAR2(150);
    var_effective_date                  DATE;
    
    p_comment_id                        NUMBER;
    p_external_account_id               NUMBER;
    p_effective_start_date              DATE;
    p_effective_end_date                DATE;

    CURSOR DETAILS IS SELECT EMPLOYEE_NUMBER,
                             ACCOUNT_NUMBER,
                             CARD_NUMBER 
                        FROM PAC_UPDATE_ACCOUNT_EDENRED_TB;
                        
    FUNCTION DAY_DIFF(START_DATE    DATE, END_DATE    DATE)     RETURN NUMBER
    AS
        var_days    NUMBER;
    BEGIN
        
        var_days := ROUND(START_DATE - END_DATE);
        
        RETURN var_days;
    END;                           

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '--------------------------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '               RESULTADOS DE ACTUALIZACIÓN DE CUENTA EDENRED');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '--------------------------------------------------------------------------');
    
    
    FOR detail IN DETAILS LOOP
    
        BEGIN
            
            
            SELECT DISTINCT
                   PAPF.FULL_NAME,
                   PPPM.PERSONAL_PAYMENT_METHOD_ID,
                   PPPM.OBJECT_VERSION_NUMBER,
                   PPPM.EXTERNAL_ACCOUNT_ID,
                   PPPM.ATTRIBUTE1,
                   PEA.SEGMENT3,
                   PPPM.EFFECTIVE_START_DATE
              INTO
                   var_full_name,
                   var_personal_payment_method_id,
                   var_object_version_number,
                   var_external_account_id,
                   var_attribute1,
                   var_segment3,
                   var_effective_date
              FROM PER_ALL_PEOPLE_F                 PAPF,
                   PER_ALL_ASSIGNMENTS_F            PAAF,
                   PAY_PERSONAL_PAYMENT_METHODS_F   PPPM,
                   PAY_ORG_PAYMENT_METHODS_F        POPM,
                   PAY_EXTERNAL_ACCOUNTS            PEA
             WHERE 1 = 1
               AND PAPF.EMPLOYEE_NUMBER = detail.EMPLOYEE_NUMBER
               AND PAPF.PERSON_ID = PAAF.PERSON_ID
               AND PPPM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
               AND PPPM.ORG_PAYMENT_METHOD_ID = POPM.ORG_PAYMENT_METHOD_ID
               AND POPM.ORG_PAYMENT_METHOD_NAME LIKE '%-EDENRED DESPENSA'
               AND PEA.EXTERNAL_ACCOUNT_ID = PPPM.EXTERNAL_ACCOUNT_ID
               AND PPPM.OBJECT_VERSION_NUMBER = (SELECT 
                                                    MAX(PM.OBJECT_VERSION_NUMBER)
                                                   FROM PAY_PERSONAL_PAYMENT_METHODS_F PM
                                                  WHERE PM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
                                                    AND PM.ORG_PAYMENT_METHOD_ID = POPM.ORG_PAYMENT_METHOD_ID)
               AND PEA.OBJECT_VERSION_NUMBER = (SELECT
                                                   MAX(EA.OBJECT_VERSION_NUMBER)
                                                  FROM PAY_EXTERNAL_ACCOUNTS    EA
                                                 WHERE EA.EXTERNAL_ACCOUNT_ID = PEA.EXTERNAL_ACCOUNT_ID);
                                                 
                                                 
            FND_FILE.PUT_LINE(FND_FILE.LOG, '        Empleado : ' ||detail.EMPLOYEE_NUMBER || ' - ' || var_full_name);
            FND_FILE.PUT_LINE(FND_FILE.LOG, ' Cuenta Anterior : ' || var_segment3);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Tarjeta Anterior : ' || var_attribute1);
            
            BEGIN 
--                IF DAY_DIFF(SYSDATE, var_effective_date) = 0 THEN
                
                    HR_PERSONAL_PAY_METHOD_API.UPDATE_PERSONAL_PAY_METHOD(p_validate => FALSE,
                                                                          p_effective_date => var_effective_date,
                                                                          p_datetrack_update_mode => 'CORRECTION',
                                                                          p_personal_payment_method_id => var_personal_payment_method_id,
                                                                          p_object_version_number => var_object_version_number,
                                                                          p_comments => 'XXCALV - Actualización No Cuenta EDENRED CORRECTION' || SYSDATE,
                                                                          p_attribute1 => detail.CARD_NUMBER,
                                                                          p_segment3 => detail.ACCOUNT_NUMBER,
                                                                          p_comment_id => p_comment_id,
                                                                          p_external_account_id => p_external_account_id, 
                                                                          p_effective_start_date => p_effective_start_date, 
                                                                          p_effective_end_date => p_effective_end_date
                                                                         );
                                                                         
                    EXECUTE IMMEDIATE 'COMMIT';
                
                    FND_FILE.PUT_LINE(FND_FILE.LOG, '         Estatus : CORREGIDO');
                    
--                ELSIF DAY_DIFF(SYSDATE, var_effective_date) > 0 THEN
--                
--                    HR_PERSONAL_PAY_METHOD_API.UPDATE_PERSONAL_PAY_METHOD(p_validate => FALSE,
--                                                                          p_effective_date => SYSDATE,
--                                                                          p_datetrack_update_mode => 'UPDATE',
--                                                                          p_personal_payment_method_id => var_personal_payment_method_id,
--                                                                          p_object_version_number => var_object_version_number,
--                                                                          p_comments => 'XXCALV - Actualización No Cuenta EDENRED UPDATE ' || SYSDATE,
--                                                                          p_attribute1 => detail.CARD_NUMBER,
--                                                                          p_segment3 => detail.ACCOUNT_NUMBER,
--                                                                          p_comment_id => p_comment_id,
--                                                                          p_external_account_id => p_external_account_id, 
--                                                                          p_effective_start_date => p_effective_start_date, 
--                                                                          p_effective_end_date => p_effective_end_date
--                                                                         );
--            
--                    EXECUTE IMMEDIATE 'COMMIT';
--            
--                    FND_FILE.PUT_LINE(FND_FILE.LOG, '         Estatus : ACTUALIZADO');
                    
--                ELSE 
--                
--                    FND_FILE.PUT_LINE(FND_FILE.LOG, '         Estatus : NO CORREGIDO');                              
--                    
--                END IF;
            EXCEPTION 
                 WHEN OTHERS THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al realizar la actualización del registro. '|| SQLERRM);                                                  
            END;
            
                                                         
        EXCEPTION 
             WHEN NO_DATA_FOUND THEN
             
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'Datos no Encontrados, Empleado : ' ||detail.EMPLOYEE_NUMBER );
        END; 
        
        
            SELECT DISTINCT
                   PAPF.FULL_NAME,
                   PPPM.ATTRIBUTE1,
                   PEA.SEGMENT3
              INTO
                   var_full_name,
                   var_attribute1,
                   var_segment3
              FROM PER_ALL_PEOPLE_F                 PAPF,
                   PER_ALL_ASSIGNMENTS_F            PAAF,
                   PAY_PERSONAL_PAYMENT_METHODS_F   PPPM,
                   PAY_ORG_PAYMENT_METHODS_F        POPM,
                   PAY_EXTERNAL_ACCOUNTS            PEA
             WHERE 1 = 1
               AND PAPF.EMPLOYEE_NUMBER = detail.EMPLOYEE_NUMBER
               AND PAPF.PERSON_ID = PAAF.PERSON_ID
               AND PPPM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
               AND PPPM.ORG_PAYMENT_METHOD_ID = POPM.ORG_PAYMENT_METHOD_ID
               AND POPM.ORG_PAYMENT_METHOD_NAME LIKE '%-EDENRED DESPENSA'
               AND PEA.EXTERNAL_ACCOUNT_ID = PPPM.EXTERNAL_ACCOUNT_ID
               AND PPPM.OBJECT_VERSION_NUMBER = (SELECT 
                                                    MAX(PM.OBJECT_VERSION_NUMBER)
                                                   FROM PAY_PERSONAL_PAYMENT_METHODS_F PM
                                                  WHERE PM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
                                                    AND PM.ORG_PAYMENT_METHOD_ID = POPM.ORG_PAYMENT_METHOD_ID)
               AND PEA.OBJECT_VERSION_NUMBER = (SELECT
                                                   MAX(EA.OBJECT_VERSION_NUMBER)
                                                  FROM PAY_EXTERNAL_ACCOUNTS    EA
                                                 WHERE EA.EXTERNAL_ACCOUNT_ID = PEA.EXTERNAL_ACCOUNT_ID);
        

        FND_FILE.PUT_LINE(FND_FILE.LOG, '   Cuenta Actual : ' || var_segment3);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '  Tarjeta Actual : ' || var_attribute1);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '--------------------------------------------------------------------------');
    
    END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    
    EXECUTE IMMEDIATE 'TRUNCATE TABLE PAC_UPDATE_ACCOUNT_EDENRED_TB';
    EXECUTE IMMEDIATE 'COMMIT';

END;