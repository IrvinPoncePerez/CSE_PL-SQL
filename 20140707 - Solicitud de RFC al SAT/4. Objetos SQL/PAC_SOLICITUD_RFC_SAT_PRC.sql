CREATE OR REPLACE PROCEDURE PAC_SOLICITUD_RFC_SAT_PRC(
            P_ERRBUF    OUT NOCOPY  VARCHAR2,
            P_RETCODE   OUT NOCOPY  VARCHAR2,
            P_COMPANY_ID            VARCHAR2,
            P_PAYROLL_ID            NUMBER,
            P_START_DATE            VARCHAR2,
            P_END_DATE              VARCHAR2,
            P_TYPE_MOVEMENT         NUMBER)
IS
    var_start_date  DATE := TRUNC(TO_DATE(P_START_DATE,'RRRR/MM/DD HH24:MI:SS'));
    var_end_date    DATE := TRUNC(TO_DATE(P_END_DATE,'RRRR/MM/DD HH24:MI:SS'));
    var_detail      VARCHAR2(500);
            
    CURSOR  ALTA_REINGRESO_DETAILS  IS
                     SELECT DISTINCT
                            PAPF.PERSON_ID                                              AS  PERSON_ID,                           
                            PAPF.PER_INFORMATION2                                       AS  RFC,
                            PAPF.NATIONAL_IDENTIFIER                                    AS  CURP,
                            PAPF.LAST_NAME                                              AS  AP_PATERNO,
                            PAPF.PER_INFORMATION1                                       AS  AP_MATERNO,
                            PAPF.FIRST_NAME || ' ' || PAPF.MIDDLE_NAMES                 AS  NOMBRES,
                            TO_DATE(NVL(PPOS.ADJUSTED_SVC_DATE, 
                                        PAPF.ORIGINAL_DATE_OF_HIRE) , 'DD/MM/RRRR')     AS  FECHA,
                           (SELECT DISTINCT
                                INFORMATION.ORG_INFORMATION2
                            FROM FND_LOOKUP_VALUES                     COMPANY     
                            INNER JOIN HR_ORGANIZATION_UNITS_V         ORGANIZATIONS    ON COMPANY.MEANING = ORGANIZATIONS.NAME
                            INNER JOIN HR_ORGANIZATION_INFORMATION     INFORMATION      ON INFORMATION.ORGANIZATION_ID = ORGANIZATIONS.ORGANIZATION_ID
                            WHERE COMPANY.lookup_type= 'NOMINAS POR EMPLEADOR LEGAL'
                              AND COMPANY.lookup_code = P_COMPANY_ID
                              AND INFORMATION.ORG_INFORMATION_CONTEXT = 'MX_TAX_REGISTRATION')  AS RFC_COMPANIA,
                            PAPF.EMAIL_ADDRESS                                          AS  EMAIL_ADDRESS,
                           (PEEVF.SCREEN_ENTRY_VALUE / 30)                              AS  SALARIO_DIARIO                              
                          FROM PER_ALL_PEOPLE_F             PAPF,
                               PER_ALL_ASSIGNMENTS_F        PAAF, 
                               PAY_PAYROLLS_F               PPF,     
                               PER_PERSON_TYPE_USAGES_F     PPTUF,
                               PER_PERIODS_OF_SERVICE       PPOS,
                               PAY_ELEMENT_ENTRIES_F        PEEF,     
                               PAY_ELEMENT_TYPES_F          PETF,
                               PAY_ELEMENT_ENTRY_VALUES_F   PEEVF,
                               PAY_INPUT_VALUES_F           PIVF
                         WHERE 1 = 1
                           AND PAPF.PERSON_ID = PAAF.PERSON_ID
                           AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
                           AND PPTUF.PERSON_ID = PAPF.PERSON_ID
                           AND PPOS.PERSON_ID= PAPF.PERSON_ID 
                           AND SUBSTR(PPF.PAYROLL_NAME, 1, 2) = NVL(P_COMPANY_ID, SUBSTR(PPF.PAYROLL_NAME, 1, 2)) 
                           AND PPF.PAYROLL_ID = NVL(P_PAYROLL_ID, PPF.PAYROLL_ID)   
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN var_start_date AND var_end_date   
                           AND PAAF.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID
                           AND PEEF.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
                           AND PEEF.ELEMENT_TYPE_ID = PETF.ELEMENT_TYPE_ID
                           AND PETF.ELEMENT_NAME = 'P001_SUELDO NORMAL'
                           AND PEEVF.ELEMENT_ENTRY_ID = PEEF.ELEMENT_ENTRY_ID
                           AND PIVF.ELEMENT_TYPE_ID = PETF.ELEMENT_TYPE_ID
                           AND PIVF.INPUT_VALUE_ID = PEEVF.INPUT_VALUE_ID
                           AND PIVF.NAME = 'Rate'
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PEEF.EFFECTIVE_START_DATE AND PEEF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PEEVF.EFFECTIVE_START_DATE AND PEEVF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
                         ORDER BY PAPF.NATIONAL_IDENTIFIER;

    
    
    
    CURSOR  BAJAS_DETAILS IS             
             SELECT DISTINCT
                    PAPF.PERSON_ID                                              AS  PERSON_ID,                           
                    PAPF.PER_INFORMATION2                                       AS  RFC,
                    PAPF.NATIONAL_IDENTIFIER                                    AS  CURP,
                    PAPF.LAST_NAME                                              AS  AP_PATERNO,
                    PAPF.PER_INFORMATION1                                       AS  AP_MATERNO,
                    PAPF.FIRST_NAME || ' ' || PAPF.MIDDLE_NAMES                 AS  NOMBRES,
                    TO_DATE(PPOS.ACTUAL_TERMINATION_DATE, 'DD/MM/RRRR')         AS  FECHA,
                      (SELECT DISTINCT
                            INFORMATION.ORG_INFORMATION2
                        FROM FND_LOOKUP_VALUES                     COMPANY     
                        INNER JOIN HR_ORGANIZATION_UNITS_V         ORGANIZATIONS    ON COMPANY.MEANING = ORGANIZATIONS.NAME
                        INNER JOIN HR_ORGANIZATION_INFORMATION     INFORMATION      ON INFORMATION.ORGANIZATION_ID = ORGANIZATIONS.ORGANIZATION_ID
                        WHERE COMPANY.lookup_type= 'NOMINAS POR EMPLEADOR LEGAL'
                          AND COMPANY.lookup_code = P_COMPANY_ID
                          AND INFORMATION.ORG_INFORMATION_CONTEXT = 'MX_TAX_REGISTRATION')  AS RFC_COMPANIA,
                    PAPF.EMAIL_ADDRESS                                          AS  EMAIL_ADDRESS
                  FROM PER_ALL_PEOPLE_F             PAPF,  
                       PER_ALL_ASSIGNMENTS_F        PAAF, 
                       PAY_PAYROLLS_F               PPF,      
                       PER_PERIODS_OF_SERVICE_V     PPOS      
                 WHERE 1 = 1
                   AND PAPF.PERSON_ID = PAAF.PERSON_ID
                   AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
                   AND PPOS.PERSON_ID= PAPF.PERSON_ID 
                   AND SUBSTR(PPF.PAYROLL_NAME, 1, 2) = P_COMPANY_ID
                   AND PPF.PAYROLL_ID = NVL(P_PAYROLL_ID, PPF.PAYROLL_ID)  
                   AND PPOS.ACTUAL_TERMINATION_DATE BETWEEN var_start_date AND var_end_date   
                   AND PAAF.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID
                   AND PPOS.ACTUAL_TERMINATION_DATE IS NOT NULL
                 ORDER BY PAPF.NATIONAL_IDENTIFIER;

     
BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parametros de Ejecuci�n. ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_COMPANY_ID : '       || P_COMPANY_ID);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_PAYROLL_ID : '       || P_PAYROLL_ID);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_START_DATE : '       || P_START_DATE);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_END_DATE : '         || P_END_DATE);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_TYPE_MOVEMENT : '    || P_TYPE_MOVEMENT);
    
    IF TO_NUMBER(P_TYPE_MOVEMENT) = 1 THEN      --Alta/Reingreso
    
        FOR DETAIL IN ALTA_REINGRESO_DETAILS LOOP
        
            var_detail := '';
            var_detail := var_detail || DETAIL.CURP || '|';                         --Campo 2 (1): CURP. Longitud limitada a 18 posiciones, tipo alfanumérico.
            var_detail := var_detail || TRIM(DETAIL.AP_PATERNO) || '|';             --Campo 3 (2): Apellido Paterno, requerido. Longitud limitada a 40 posiciones.
            var_detail := var_detail || TRIM(DETAIL.AP_MATERNO) || '|';             --Campo 4 (3): Apellido Materno, requerido. Longitud limitada a 40 posiciones.
            var_detail := var_detail || TRIM(DETAIL.NOMBRES) || '|';                --Campo 5 (4): Nombres, requerido. Longitud limitada a 40 posiciones.
            var_detail := var_detail || TO_CHAR(DETAIL.FECHA, 'DD/MM/RRRR') || '|';                        --Campo 6 (5): Fecha del movimiento, requerido. Longitud limitada a 8 posiciones. Formato DD/MM/AAAA
            IF DETAIL.SALARIO_DIARIO >= 1095.9 THEN
                var_detail := var_detail || '1' || '|';
            ELSE
                var_detail := var_detail || '2' || '|';
            END IF;                                  
            var_detail := var_detail || DETAIL.RFC_COMPANIA;                        --Campo 8 (7): RFC Compañía. Longitud limitada a 13 posiciones.
            var_detail := var_detail || DETAIL.EMAIL_ADDRESS; 
            
            dbms_output.put_line(var_detail);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_detail);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, var_detail);
        
        END LOOP;
    
    ELSIF TO_NUMBER(P_TYPE_MOVEMENT) = 2 THEN   --Baja
        
        FOR DETAIL IN BAJAS_DETAILS LOOP
            var_detail := '';
            var_detail := var_detail || REPLACE(DETAIL.RFC, '-', '') || '|';    --Campo 1: RFC Trabajador. Longitud limitada a 13 posiciones. 
            var_detail := var_detail || DETAIL.CURP || '|';                         --Campo 2 (1): CURP. Longitud limitada a 18 posiciones, tipo alfanumérico.
            var_detail := var_detail || TRIM(DETAIL.AP_PATERNO) || '|';             --Campo 3 (2): Apellido Paterno, requerido. Longitud limitada a 40 posiciones.
            var_detail := var_detail || TRIM(DETAIL.AP_MATERNO) || '|';             --Campo 4 (3): Apellido Materno, requerido. Longitud limitada a 40 posiciones.
            var_detail := var_detail || TRIM(DETAIL.NOMBRES) || '|';                --Campo 5 (4): Nombres, requerido. Longitud limitada a 40 posiciones.
            var_detail := var_detail || TO_CHAR(DETAIL.FECHA, 'DD/MM/RRRR') || '|';                        --Campo 6 (5): Fecha del movimiento, requerido. Longitud limitada a 8 posiciones. Formato DD/MM/AAAA
            var_detail := var_detail || '1' || '|';                             --Campo 7 (6): Indicador de movimiento, requerido. Longitud limitada a 1 posición.                                      
            var_detail := var_detail || DETAIL.RFC_COMPANIA;                        --Campo 8 (7): RFC Compañía. Longitud limitada a 13 posiciones.
            var_detail := var_detail || DETAIL.EMAIL_ADDRESS; 
            
            dbms_output.put_line(var_detail);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_detail);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, var_detail);
        END LOOP;
    
    END IF;
    
        
    --Finalización del Procedimiento.
    dbms_output.put_line('Archivo creado!');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Archivo creado!');
    
EXCEPTION WHEN OTHERS THEN
    dbms_output.put_line('**Error al Ejecutar el Procedure PAC_SOLICITUD_RFC_SAT_PRC. ' || SQLERRM);
    FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Ejecutar el Procedure PAC_SOLICITUD_RFC_SAT_PRC. ' || SQLERRM);
END;