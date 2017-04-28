CREATE OR REPLACE PROCEDURE APPS.PAC_ALTAS_FONDO_AHORRO_PRC(
    p_errbuf        OUT NOCOPY  VARCHAR2,
    p_retcode       OUT NOCOPY  VARCHAR2,
    P_START_DATE                VARCHAR2,
    P_END_DATE                  VARCHAR2)
IS
    var_start_date      DATE := TRUNC(TO_DATE(P_START_DATE,'RRRR/MM/DD HH24:MI:SS'));
    var_end_date        DATE := TRUNC(TO_DATE(P_END_DATE,'RRRR/MM/DD HH24:MI:SS'));
    var_body_document   VARCHAR2(5000);
    
    CURSOR DETAILS_LIST IS
    SELECT DISTINCT
           PAPF.PERSON_ID                                                   AS  PERSON_ID
          ,PAPF.EMPLOYEE_NUMBER                                             AS  EMPLOYEE_NUMBER
          ,TRIM(PAPF.LAST_NAME)                                             AS  LAST_NAME
          ,TRIM(PAPF.PER_INFORMATION1)                                      AS  SECOND_LAST_NAME
          ,TRIM(PAPF.FIRST_NAME || ' ' || PAPF.MIDDLE_NAMES)                AS  NAMES
          ,TRIM(REPLACE(REPLACE(PEA.SEGMENT3,CHR(10), ''),CHR(13), ''))     AS  ACCOUNT_NUMBER      
          ,TRIM(SUBSTR(POPM.ORG_PAYMENT_METHOD_NAME,4))                     AS  BANK_NAME      
          ,TRIM(REPLACE(REPLACE(PPPM.ATTRIBUTE1, CHR(10), ''), CHR(13), ''))AS  CLABE      
          ,TRIM(PAPF.PER_INFORMATION2)                                      AS  RFC                           
          ,TRIM(PAPF.NATIONAL_IDENTIFIER)                                   AS  CURP    
          ,TO_CHAR(SYSDATE, 'RRRRMMDD')                                     AS  DATE_EXP     
      FROM PER_ALL_PEOPLE_F                PAPF      
          ,PER_PERSON_TYPES                PPT   
          ,PER_ALL_ASSIGNMENTS_F           PAAF  
          ,PAY_PERSONAL_PAYMENT_METHODS_F  PPPM
          ,PAY_EXTERNAL_ACCOUNTS           PEA
          ,PAY_ORG_PAYMENT_METHODS_F       POPM
          ,PER_PERIODS_OF_SERVICE          PPOS      
     WHERE 1 = 1
       AND PAPF.PERSON_TYPE_ID =  PPT.PERSON_TYPE_ID
       AND PAAF.PERSON_ID = PAPF.PERSON_ID
       AND PPPM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
       AND PEA.EXTERNAL_ACCOUNT_ID = PPPM.EXTERNAL_ACCOUNT_ID
       AND POPM.ORG_PAYMENT_METHOD_ID = PPPM.ORG_PAYMENT_METHOD_ID
       AND PPOS.PERSON_ID = PAPF.PERSON_ID
       AND PPOS.ACTUAL_TERMINATION_DATE IS NULL
       AND PPT.USER_PERSON_TYPE IN ('Employee', 'Empleado')
       AND ORG_PAYMENT_METHOD_NAME NOT LIKE '%PENSIONES%'
       AND ORG_PAYMENT_METHOD_NAME NOT LIKE '%DESPENSA%'
       AND ORG_PAYMENT_METHOD_NAME NOT LIKE '%EFECTIV%'
       AND ORG_PAYMENT_METHOD_NAME NOT LIKE '%CHEQUE%'
       AND PPT.ACTIVE_FLAG = 'Y'
       AND NVL(PPOS.ADJUSTED_SVC_DATE,  
               PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PAPF.EFFECTIVE_START_DATE
                                               AND PAPF.EFFECTIVE_END_DATE
       AND NVL(PPOS.ADJUSTED_SVC_DATE,  
               PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PAAF.EFFECTIVE_START_DATE
                                               AND PAAF.EFFECTIVE_END_DATE    
       AND NVL(PPOS.ADJUSTED_SVC_DATE,  
               PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PPPM.EFFECTIVE_START_DATE
                                               AND PPPM.EFFECTIVE_END_DATE
       AND NVL(PPOS.ADJUSTED_SVC_DATE,  
               PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN POPM.EFFECTIVE_START_DATE
                                               AND POPM.EFFECTIVE_END_DATE    
       AND NVL(PPOS.ADJUSTED_SVC_DATE,  
               PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN var_start_date
                                               AND var_end_date                            
     ORDER
        BY PAPF.EMPLOYEE_NUMBER;
    
BEGIN

    
    --  Impresión de Parametros de Entrada.
    FND_FILE.PUT_LINE(FND_FILE.LOG,'P_START_DATE : '|| P_START_DATE);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'P_END_DATE : '  || P_END_DATE);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'var_start_date : ' || var_start_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'var_end_date : '   || var_end_date);
      
        
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Creando Body del Documento de Altas de Fondo de Ahorro . . .');
        
    --  Recorrido del Cursor.
    BEGIN
    
        FOR detail  IN DETAILS_LIST LOOP
        
            
            var_body_document := '';
            var_body_document := var_body_document || TO_CHAR(detail.EMPLOYEE_NUMBER)    || ',';
            var_body_document := var_body_document || TO_CHAR(detail.LAST_NAME)          || ',';
            var_body_document := var_body_document || TO_CHAR(detail.SECOND_LAST_NAME)   || ',';
            var_body_document := var_body_document || TO_CHAR(detail.NAMES)              || ',';
            var_body_document := var_body_document || TO_CHAR(detail.ACCOUNT_NUMBER)     || ',';        
            var_body_document := var_body_document || TO_CHAR(detail.BANK_NAME)          || ',';
            var_body_document := var_body_document || TO_CHAR(detail.CLABE)              || ',';
            var_body_document := var_body_document || TO_CHAR(detail.RFC)                || ',';            
            var_body_document := var_body_document || TO_CHAR(detail.CURP)               || ',';
            var_body_document := var_body_document || TO_CHAR(detail.DATE_EXP)           || ',';
            
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, var_body_document);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_body_document);
        
        END LOOP;
    
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error al Recorrer la Lista de Empleados. ' || SQLERRM);
    END;
    
    --Finalización del Procedimiento.
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Archivo creado!');


END;

 