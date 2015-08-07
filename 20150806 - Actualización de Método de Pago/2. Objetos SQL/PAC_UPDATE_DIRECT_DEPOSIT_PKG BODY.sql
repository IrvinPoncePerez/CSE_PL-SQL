CREATE OR REPLACE PACKAGE BODY PAC_UPDATE_DIRECT_DEPOSIT_PKG IS

    PROCEDURE UPDATE_PAYMENT_METHOD(
                    P_ERRBUF    OUT NOCOPY  VARCHAR2,
                    P_RETCODE   OUT NOCOPY  VARCHAR2,
                    P_PAYMENT_METHOD_ID IN  NUMBER)
    IS
        
        CURSOR DETAILS IS 
            SELECT PUDD.EMPLOYEE_NUMBER AS  EMPLOYEE_NUMBER,
                   PUDD.ACCOUNT_NUMBER  AS  ACCOUNT_NUMBER,
                   PUDD.CARD_NUMBER     AS  CARD_NUMBER
              FROM PAC_UPDATE_DIRECT_DEPOSIT_TB PUDD;
    
    BEGIN
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
        FND_FILE.PUT_LINE(FND_FILE.LOG, '--------------------------------------------------------------------------');
        FND_FILE.PUT_LINE(FND_FILE.LOG, '               RESULTADOS DE ACTUALIZACIÓN DE MÉTODO DE PAGO');
        FND_FILE.PUT_LINE(FND_FILE.LOG, '--------------------------------------------------------------------------');
        
        FOR detail  IN  DETAILS LOOP
            
            UPDATE_PAYMENT_METHOD_BY_ID(
                                P_EMPLOYEE_NUMBER   =>  detail.EMPLOYEE_NUMBER,
                                P_ACCOUNT_NUMBER    =>  detail.ACCOUNT_NUMBER,
                                P_CARD_NUMBER       =>  detail.CARD_NUMBER,
                                P_PAYMENT_METHOD_ID =>  P_PAYMENT_METHOD_ID
                                        );
            
            PRINT_PAYMENT_METHOD_BY_ID(
                                P_EMPLOYEE_NUMBER   =>  detail.EMPLOYEE_NUMBER,
                                P_PAYMENT_METHOD_ID =>  P_PAYMENT_METHOD_ID
                                        );
                    
        END LOOP;
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
        
        EXECUTE IMMEDIATE 'TRUNCATE TABLE PAC_UPDATE_DIRECT_DEPOSIT_TB';
        EXECUTE IMMEDIATE 'COMMIT';
          
    
    END UPDATE_PAYMENT_METHOD;
    
    
    
    PROCEDURE UPDATE_PAYMENT_METHOD_BY_ID(
                    P_EMPLOYEE_NUMBER       VARCHAR2,
                    P_ACCOUNT_NUMBER        VARCHAR2,
                    P_CARD_NUMBER           VARCHAR2,
                    P_PAYMENT_METHOD_ID     NUMBER)
    IS
        var_full_name                       VARCHAR2(500);
        var_payment_method_name             VARCHAR2(500);
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
    BEGIN
        
        SELECT DISTINCT
                   PAPF.FULL_NAME,
                   PPPM.PERSONAL_PAYMENT_METHOD_ID,
                   PPPM.OBJECT_VERSION_NUMBER,
                   PPPM.EXTERNAL_ACCOUNT_ID,
                   PPPM.ATTRIBUTE1,
                   PEA.SEGMENT3,
                   PPPM.EFFECTIVE_START_DATE,
                   POPM.ORG_PAYMENT_METHOD_NAME
              INTO
                   var_full_name,
                   var_personal_payment_method_id,
                   var_object_version_number,
                   var_external_account_id,
                   var_attribute1,
                   var_segment3,
                   var_effective_date,
                   var_payment_method_name
              FROM PER_ALL_PEOPLE_F                 PAPF,
                   PER_ALL_ASSIGNMENTS_F            PAAF,
                   PAY_PERSONAL_PAYMENT_METHODS_F   PPPM,
                   PAY_ORG_PAYMENT_METHODS_F        POPM,
                   PAY_EXTERNAL_ACCOUNTS            PEA
             WHERE 1 = 1
               AND PAPF.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
               AND PAPF.PERSON_ID = PAAF.PERSON_ID
               AND PPPM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
               AND PPPM.ORG_PAYMENT_METHOD_ID = POPM.ORG_PAYMENT_METHOD_ID
               AND PPPM.ORG_PAYMENT_METHOD_ID = P_PAYMENT_METHOD_ID
               AND PEA.EXTERNAL_ACCOUNT_ID = PPPM.EXTERNAL_ACCOUNT_ID
               AND PPPM.OBJECT_VERSION_NUMBER = (SELECT 
                                                    MAX(PM.OBJECT_VERSION_NUMBER)
                                                   FROM PAY_PERSONAL_PAYMENT_METHODS_F PM
                                                  WHERE PM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
                                                    AND PM.ORG_PAYMENT_METHOD_ID = POPM.ORG_PAYMENT_METHOD_ID)
               AND PEA.OBJECT_VERSION_NUMBER = (SELECT
                                                   MAX(EA.OBJECT_VERSION_NUMBER)
                                                  FROM PAY_EXTERNAL_ACCOUNTS    EA
                                                 WHERE EA.EXTERNAL_ACCOUNT_ID = PEA.EXTERNAL_ACCOUNT_ID)
               AND PPPM.EFFECTIVE_END_DATE > SYSDATE;
                                                 
                                                 
            FND_FILE.PUT_LINE(FND_FILE.LOG, '        Empleado : ' || P_EMPLOYEE_NUMBER || ' - ' || var_full_name);
            FND_FILE.PUT_LINE(FND_FILE.LOG, '  Metodo de Pago : ' || var_payment_method_name);
            FND_FILE.PUT_LINE(FND_FILE.LOG, ' Cuenta Anterior : ' || var_segment3);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Tarjeta Anterior : ' || var_attribute1);
            
            
            BEGIN
                
            
                HR_PERSONAL_PAY_METHOD_API.UPDATE_PERSONAL_PAY_METHOD(p_validate                    => FALSE,
                                                                      p_effective_date              => var_effective_date,
                                                                      p_datetrack_update_mode       => 'CORRECTION',
                                                                      p_personal_payment_method_id  => var_personal_payment_method_id,
                                                                      p_object_version_number       => var_object_version_number,
                                                                      p_comments                    => 'XXCALV - Actualización de Método de Pago : ' || SYSDATE,
                                                                      p_attribute1                  => P_CARD_NUMBER,
                                                                      p_segment3                    => P_ACCOUNT_NUMBER,
                                                                      p_comment_id                  => p_comment_id,
                                                                      p_external_account_id         => p_external_account_id, 
                                                                      p_effective_start_date        => p_effective_start_date, 
                                                                      p_effective_end_date          => p_effective_end_date
                                                                     );
                                                                         
                EXECUTE IMMEDIATE 'COMMIT';
                
                FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, '         Estatus :         CORREGIDO');
                FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
                    
            
            EXCEPTION WHEN OTHERS THEN
                 
                FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al realizar la actualización del registro. '|| SQLERRM);                                                  
            
            END;
            
            
    EXCEPTION WHEN NO_DATA_FOUND THEN
             
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Datos no Encontrados, Empleado : ' || P_EMPLOYEE_NUMBER );
    
    END UPDATE_PAYMENT_METHOD_BY_ID;
    
    
    
    PROCEDURE PRINT_PAYMENT_METHOD_BY_ID(
                    P_EMPLOYEE_NUMBER       VARCHAR2,
                    P_PAYMENT_METHOD_ID     NUMBER)
    IS
        var_full_name                       VARCHAR2(500);
        var_payment_method_name             VARCHAR2(500);
        var_attribute1                      VARCHAR2(150);
        var_segment3                        VARCHAR2(150);
    BEGIN
       
        
        SELECT DISTINCT
               PAPF.FULL_NAME,
               PPPM.ATTRIBUTE1,
               PEA.SEGMENT3,
               POPM.ORG_PAYMENT_METHOD_NAME
          INTO
               var_full_name,
               var_attribute1,
               var_segment3,
               var_payment_method_name
          FROM PER_ALL_PEOPLE_F                 PAPF,
               PER_ALL_ASSIGNMENTS_F            PAAF,
               PAY_PERSONAL_PAYMENT_METHODS_F   PPPM,
               PAY_ORG_PAYMENT_METHODS_F        POPM,
               PAY_EXTERNAL_ACCOUNTS            PEA
         WHERE 1 = 1
           AND PAPF.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
           AND PAPF.PERSON_ID = PAAF.PERSON_ID
           AND PPPM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
           AND PPPM.ORG_PAYMENT_METHOD_ID = POPM.ORG_PAYMENT_METHOD_ID
           AND PPPM.ORG_PAYMENT_METHOD_ID = P_PAYMENT_METHOD_ID
           AND PEA.EXTERNAL_ACCOUNT_ID = PPPM.EXTERNAL_ACCOUNT_ID
           AND PPPM.OBJECT_VERSION_NUMBER = (SELECT 
                                                MAX(PM.OBJECT_VERSION_NUMBER)
                                               FROM PAY_PERSONAL_PAYMENT_METHODS_F PM
                                              WHERE PM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
                                                AND PM.ORG_PAYMENT_METHOD_ID = POPM.ORG_PAYMENT_METHOD_ID)
           AND PEA.OBJECT_VERSION_NUMBER = (SELECT
                                               MAX(EA.OBJECT_VERSION_NUMBER)
                                              FROM PAY_EXTERNAL_ACCOUNTS    EA
                                             WHERE EA.EXTERNAL_ACCOUNT_ID = PEA.EXTERNAL_ACCOUNT_ID)
           AND PPPM.EFFECTIVE_END_DATE > SYSDATE;
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, '  Metodo de Pago : ' || var_payment_method_name);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '   Cuenta Actual : ' || var_segment3);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '  Tarjeta Actual : ' || var_attribute1);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '--------------------------------------------------------------------------');
    
    
    EXCEPTION WHEN NO_DATA_FOUND THEN
             
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Datos no Encontrados, Empleado : ' || P_EMPLOYEE_NUMBER );
    
    END PRINT_PAYMENT_METHOD_BY_ID;
    

END PAC_UPDATE_DIRECT_DEPOSIT_PKG;