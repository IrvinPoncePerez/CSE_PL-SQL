CREATE OR REPLACE FUNCTION PAC_UPDATE_EDENRED(
        p_employee_number       NUMBER,
        p_account_number        VARCHAR2,
        p_card_number           VARCHAR2)
RETURN VARCHAR2 
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
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
        
        var_message                         VARCHAR2(2000);
        
        FUNCTION DAY_DIFF(START_DATE    DATE, END_DATE    DATE)     RETURN NUMBER
        AS
            var_days    NUMBER;
        BEGIN
        
            var_days := TO_DATE(START_DATE, 'yyyy/mm/dd') - TO_DATE(END_DATE, 'yyyy/mm/dd');
        
            RETURN var_days;
        END;   
BEGIN

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
           AND PAPF.EMPLOYEE_NUMBER = p_employee_number
           AND PAPF.PERSON_ID = PAAF.PERSON_ID
           AND PPPM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
           AND PPPM.ORG_PAYMENT_METHOD_ID = POPM.ORG_PAYMENT_METHOD_ID
           AND POPM.ORG_PAYMENT_METHOD_NAME LIKE '%-EDENRED DESPENSA'
           AND PEA.EXTERNAL_ACCOUNT_ID = PPPM.EXTERNAL_ACCOUNT_ID
           AND PPPM.OBJECT_VERSION_NUMBER = (SELECT 
                                                MAX(PM.OBJECT_VERSION_NUMBER)
                                               FROM PAY_PERSONAL_PAYMENT_METHODS_F PM
                                              WHERE PM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID)
           AND PEA.OBJECT_VERSION_NUMBER = (SELECT
                                               MAX(EA.OBJECT_VERSION_NUMBER)
                                              FROM PAY_EXTERNAL_ACCOUNTS    EA
                                             WHERE EA.EXTERNAL_ACCOUNT_ID = PEA.EXTERNAL_ACCOUNT_ID);
    
    EXCEPTION WHEN OTHERS THEN
    
        RETURN ('**Error al realizar la consulta de los datos del payment method. ' || SQLERRM);
    
    END;  

    BEGIN
    
        IF DAY_DIFF(SYSDATE, var_effective_date) = 0 THEN
        
            var_message := 'CORRECTION ';
        
--            HR_PERSONAL_PAY_METHOD_API.UPDATE_PERSONAL_PAY_METHOD(p_validate => FALSE,
--                                                                  p_effective_date => SYSDATE,
--                                                                  p_datetrack_update_mode => 'CORRECTION',
--                                                                  p_personal_payment_method_id => var_personal_payment_method_id,
--                                                                  p_object_version_number => var_object_version_number,
--                                                                  p_comments => 'XXCALV - Actualización No Cuenta EDENRED CORRECTION' || SYSDATE,
--                                                                  p_attribute1 => p_card_number,
--                                                                  p_segment3 => p_account_number,
--                                                                  p_comment_id => p_comment_id,
--                                                                  p_external_account_id => p_external_account_id, 
--                                                                  p_effective_start_date => p_effective_start_date, 
--                                                                  p_effective_end_date => p_effective_end_date
--                                                                 );
            
        ELSIF DAY_DIFF(SYSDATE, var_effective_date) > 0 THEN
        
            var_message := 'UPDATE ';
        
--            HR_PERSONAL_PAY_METHOD_API.UPDATE_PERSONAL_PAY_METHOD(p_validate => FALSE,
--                                                                  p_effective_date => SYSDATE,
--                                                                  p_datetrack_update_mode => 'UPDATE',
--                                                                  p_personal_payment_method_id => var_personal_payment_method_id,
--                                                                  p_object_version_number => var_object_version_number,
--                                                                  p_comments => 'XXCALV - Actualización No Cuenta EDENRED UPDATE ' || SYSDATE,
--                                                                  p_attribute1 => p_card_number,
--                                                                  p_segment3 => p_account_number,
--                                                                  p_comment_id => p_comment_id,
--                                                                  p_external_account_id => p_external_account_id, 
--                                                                  p_effective_start_date => p_effective_start_date, 
--                                                                  p_effective_end_date => p_effective_end_date
--                                                                 );
            
        END IF;
    
    EXCEPTION WHEN OTHERS THEN
    
        var_message := '**Error al ejecutar la API HR_PERSONAL_PAY_METHOD_API. ' || SQLERRM;
    
        INSERT INTO XXCALV_MESSAGES VALUES(var_message);
        COMMIT;
            
    
        RETURN ('**Error al ejecutar la API HR_PERSONAL_PAY_METHOD_API. ' || SQLERRM);
    
    END;  
    
    BEGIN
    
        SELECT DISTINCT
               PAPF.FULL_NAME,
               PPPM.PERSONAL_PAYMENT_METHOD_ID,
               PPPM.OBJECT_VERSION_NUMBER,
               PPPM.EXTERNAL_ACCOUNT_ID,
               PPPM.ATTRIBUTE1,
               PEA.SEGMENT3
          INTO
               var_full_name,
               var_personal_payment_method_id,
               var_object_version_number,
               var_external_account_id,
               var_attribute1,
               var_segment3
          FROM PER_ALL_PEOPLE_F                 PAPF,
               PER_ALL_ASSIGNMENTS_F            PAAF,
               PAY_PERSONAL_PAYMENT_METHODS_F   PPPM,
               PAY_ORG_PAYMENT_METHODS_F        POPM,
               PAY_EXTERNAL_ACCOUNTS            PEA
         WHERE 1 = 1
           AND PAPF.EMPLOYEE_NUMBER = p_employee_number
           AND PAPF.PERSON_ID = PAAF.PERSON_ID
           AND PPPM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
           AND PPPM.ORG_PAYMENT_METHOD_ID = POPM.ORG_PAYMENT_METHOD_ID
           AND POPM.ORG_PAYMENT_METHOD_NAME LIKE '%-EDENRED DESPENSA'
           AND PEA.EXTERNAL_ACCOUNT_ID = PPPM.EXTERNAL_ACCOUNT_ID
           AND PPPM.OBJECT_VERSION_NUMBER = (SELECT 
                                                MAX(PM.OBJECT_VERSION_NUMBER)
                                               FROM PAY_PERSONAL_PAYMENT_METHODS_F PM
                                              WHERE PM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID)
           AND PEA.OBJECT_VERSION_NUMBER = (SELECT
                                               MAX(EA.OBJECT_VERSION_NUMBER)
                                              FROM PAY_EXTERNAL_ACCOUNTS    EA
                                             WHERE EA.EXTERNAL_ACCOUNT_ID = PEA.EXTERNAL_ACCOUNT_ID);
                                             
        var_message := var_message      || 
                       var_full_name    || 
                       ', account='     || 
                       var_segment3     || 
                       ', card='        || 
                       var_attribute1;
    
    EXCEPTION WHEN OTHERS THEN
        
        RETURN ('**Error al realizar el mensaje de Return. ' ||  SQLERRM);    
      
    END;

    COMMIT;
    
    --Return del mensaje.
    RETURN var_message;

EXCEPTION WHEN OTHERS THEN
    RETURN ('**Error al Ejecutar el Procedure PAC_UPDATE_EDENRED. ' || SQLERRM);
END;