CREATE OR REPLACE PROCEDURE PAC_SOLICITUD_RFC_SAT_PRC(
            P_ERRBUF    OUT NOCOPY  VARCHAR2,
            P_RETCODE   OUT NOCOPY  VARCHAR2,
            P_COMPANY_ID            VARCHAR2,
            P_PAYROLL_ID            NUMBER,
            P_CONSOLIDATION_ID      NUMBER,
            P_START_DATE            VARCHAR2,
            P_END_DATE              VARCHAR2,
            P_TYPE_MOVEMENT         NUMBER)
IS
    var_start_date  DATE := TRUNC(TO_DATE(P_START_DATE,'RRRR/MM/DD HH24:MI:SS'));
    var_end_date    DATE := TRUNC(TO_DATE(P_END_DATE,'RRRR/MM/DD HH24:MI:SS'));
    var_path        VARCHAR2(250) := 'SOLICITUD_RFC_SAT';
    var_file_name   VARCHAR2(250);
            
    TYPE CURSOR_DETAIL IS REF CURSOR;
    DETAIL_LIST     CURSOR_DETAIL;
    DETAIL          DETAIL_RFC_SAT_TB%ROWTYPE; 
    var_query       VARCHAR2(5000);        
    
    var_detail      VARCHAR2(2000);  
     
BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parametros de Ejecuci�n. ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_COMPANY_ID : '       || P_COMPANY_ID);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_PAYROLL_ID : '       || P_PAYROLL_ID);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_CONSOLIDATION_ID : ' || P_CONSOLIDATION_ID);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_START_DATE : '       || P_START_DATE);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_END_DATE : '         || P_END_DATE);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_TYPE_MOVEMENT : '    || P_TYPE_MOVEMENT);
    
    IF TO_NUMBER(P_TYPE_MOVEMENT) = 1 THEN      --Alta/Reingreso
       var_file_name := 'SOLICITUD_RFC_SAT_A.txt';
       var_query    :=  'SELECT DISTINCT
                            PEOPLE.PERSON_ID                                            AS  PERSON_ID,                           
                            ALL_PEOPLE.PER_INFORMATION2                                 AS  RFC,
                            ALL_PEOPLE.NATIONAL_IDENTIFIER                              AS  CURP,
                            ALL_PEOPLE.LAST_NAME                                        AS  AP_PATERNO,
                            ALL_PEOPLE.PER_INFORMATION1                                 AS  AP_MATERNO,
                            ALL_PEOPLE.FIRST_NAME || '' '' || ALL_PEOPLE.MIDDLE_NAMES     AS  NOMBRES,
                            RVALUES.RESULT_VALUE                                        AS  SALARIO_DIARIO,
                            TO_CHAR(USAGES.EFFECTIVE_START_DATE, ''DD/MM/RRRR'')        AS  FECHA,
                               (SELECT DISTINCT
                                    INFORMATION.ORG_INFORMATION2
                                FROM FND_LOOKUP_VALUES                     COMPANY     
                                INNER JOIN HR_ORGANIZATION_UNITS_V         ORGANIZATIONS    ON COMPANY.MEANING = ORGANIZATIONS.NAME
                                INNER JOIN HR_ORGANIZATION_INFORMATION     INFORMATION      ON INFORMATION.ORGANIZATION_ID = ORGANIZATIONS.ORGANIZATION_ID
                                WHERE COMPANY.lookup_type= ''NOMINAS POR EMPLEADOR LEGAL''
                                  AND COMPANY.lookup_code = :P_COMPANY_ID
                                  AND INFORMATION.ORG_INFORMATION_CONTEXT = ''MX_TAX_REGISTRATION'')  AS RFC_COMPANIA                               
                          FROM PER_PEOPLE_F             PEOPLE,
                               PER_ALL_PEOPLE_F         ALL_PEOPLE,
                               PER_ALL_ASSIGNMENTS_F    ASSIGNMENTS, 
                               PAY_PAYROLLS_F           PAYROLL,     
                               PAY_PAYROLL_ACTIONS      PACTIONS,    
                               PAY_ASSIGNMENT_ACTIONS   ACTIONS,     
                               PAY_RUN_RESULTS          RESULTS,     
                               PAY_RUN_RESULT_VALUES    RVALUES,     
                               PAY_ELEMENT_TYPES_F      ELEMENTT,    
                               PER_PERSON_TYPE_USAGES_F USAGES,
                               PER_PERIODS_OF_SERVICE   SERVICE     
                         WHERE 1 = 1
                           AND PEOPLE.PERSON_ID = ALL_PEOPLE.PERSON_ID
                           AND PEOPLE.PERSON_ID = ASSIGNMENTS.PERSON_ID
                           AND PAYROLL.PAYROLL_ID = ASSIGNMENTS.PAYROLL_ID
                           AND PACTIONS.PAYROLL_ID = PAYROLL.PAYROLL_ID
                           AND ACTIONS.ASSIGNMENT_ID = ASSIGNMENTS.ASSIGNMENT_ID
                           AND ACTIONS.ASSIGNMENT_ACTION_ID = RESULTS.ASSIGNMENT_ACTION_ID
                           AND RESULTS.RUN_RESULT_ID = RVALUES.RUN_RESULT_ID
                           AND RESULTS.ELEMENT_TYPE_ID = ELEMENTT.ELEMENT_TYPE_ID
                           AND USAGES.PERSON_ID = PEOPLE.PERSON_ID
                           AND SERVICE.PERSON_ID= PEOPLE.PERSON_ID 
                           AND ELEMENTT.ELEMENT_NAME = ''I001_SALARIO_DIARIO''
                           AND SUBSTR(PAYROLL.PAYROLL_NAME, 1, 2) = :P_COMPANY_ID
                           AND PAYROLL.PAYROLL_ID = NVL(:P_PAYROLL_ID, PAYROLL.PAYROLL_ID)
                           AND PACTIONS.CONSOLIDATION_SET_ID = NVL(:P_CONSOLIDATION_ID, PACTIONS.CONSOLIDATION_SET_ID)  
                           AND (USAGES.EFFECTIVE_START_DATE BETWEEN :P_START_DATE AND :P_END_DATE) 
                           AND (PEOPLE.EFFECTIVE_START_DATE = ALL_PEOPLE.EFFECTIVE_START_DATE
                            AND PEOPLE.EFFECTIVE_START_DATE = USAGES.EFFECTIVE_START_DATE
                            AND PEOPLE.EFFECTIVE_START_DATE = SERVICE.DATE_START)
                           AND ASSIGNMENTS.PERIOD_OF_SERVICE_ID = SERVICE.PERIOD_OF_SERVICE_ID
                           AND SERVICE.ACTUAL_TERMINATION_DATE IS NULL
                         ORDER BY ALL_PEOPLE.NATIONAL_IDENTIFIER';
    
    ELSIF TO_NUMBER(P_TYPE_MOVEMENT) = 2 THEN   --Baja
        var_file_name := 'SOLICITUD_RFC_SAT_B.txt';
        var_query    :=  'SELECT DISTINCT
                            PEOPLE.PERSON_ID                                            AS  PERSON_ID,                           
                            ALL_PEOPLE.PER_INFORMATION2                                 AS  RFC,
                            ALL_PEOPLE.NATIONAL_IDENTIFIER                              AS  CURP,
                            ALL_PEOPLE.LAST_NAME                                        AS  AP_PATERNO,
                            ALL_PEOPLE.PER_INFORMATION1                                 AS  AP_MATERNO,
                            ALL_PEOPLE.FIRST_NAME || '' '' || ALL_PEOPLE.MIDDLE_NAMES   AS  NOMBRES,
                            RVALUES.RESULT_VALUE                                        AS  SALARIO_DIARIO,
                            TO_CHAR(PERIODS.ACTUAL_TERMINATION_DATE, ''DD/MM/RRRR'')    AS  FECHA,
                              (SELECT DISTINCT
                                    INFORMATION.ORG_INFORMATION2
                                FROM FND_LOOKUP_VALUES                     COMPANY     
                                INNER JOIN HR_ORGANIZATION_UNITS_V         ORGANIZATIONS    ON COMPANY.MEANING = ORGANIZATIONS.NAME
                                INNER JOIN HR_ORGANIZATION_INFORMATION     INFORMATION      ON INFORMATION.ORGANIZATION_ID = ORGANIZATIONS.ORGANIZATION_ID
                                WHERE COMPANY.lookup_type= ''NOMINAS POR EMPLEADOR LEGAL''
                                  AND COMPANY.lookup_code = :P_COMPANY_ID
                                  AND INFORMATION.ORG_INFORMATION_CONTEXT = ''MX_TAX_REGISTRATION'')  AS RFC_COMPANIA
                          FROM PER_PEOPLE_F                 PEOPLE,
                               PER_ALL_PEOPLE_F             ALL_PEOPLE,  
                               PER_ALL_ASSIGNMENTS_F        ASSIGNMENTS, 
                               PAY_PAYROLLS_F               PAYROLL,     
                               PAY_PAYROLL_ACTIONS          PACTIONS,    
                               PAY_ASSIGNMENT_ACTIONS       ACTIONS,     
                               PAY_RUN_RESULTS              RESULTS,     
                               PAY_RUN_RESULT_VALUES        RVALUES,     
                               PAY_ELEMENT_TYPES_F          ELEMENTT,    
                               PER_PERIODS_OF_SERVICE_V     PERIODS      
                         WHERE 1 = 1
                           AND PEOPLE.PERSON_ID = ALL_PEOPLE.PERSON_ID
                           AND PEOPLE.PERSON_ID = ASSIGNMENTS.PERSON_ID
                           AND PAYROLL.PAYROLL_ID = ASSIGNMENTS.PAYROLL_ID
                           AND PACTIONS.PAYROLL_ID = PAYROLL.PAYROLL_ID
                           AND ACTIONS.ASSIGNMENT_ID = ASSIGNMENTS.ASSIGNMENT_ID
                           AND ACTIONS.ASSIGNMENT_ACTION_ID = RESULTS.ASSIGNMENT_ACTION_ID
                           AND RESULTS.RUN_RESULT_ID = RVALUES.RUN_RESULT_ID
                           AND RESULTS.ELEMENT_TYPE_ID = ELEMENTT.ELEMENT_TYPE_ID
                           AND PERIODS.PERSON_ID = PEOPLE.PERSON_ID   
                           AND ELEMENTT.ELEMENT_NAME = ''I001_SALARIO_DIARIO''
                           AND SUBSTR(PAYROLL.PAYROLL_NAME, 1, 2) = :P_COMPANY_ID
                           AND PAYROLL.PAYROLL_ID = NVL(:P_PAYROLL_ID, PAYROLL.PAYROLL_ID)
                           AND PACTIONS.CONSOLIDATION_SET_ID = NVL(:P_CONSOLIDATION_ID, PACTIONS.CONSOLIDATION_SET_ID) 
                           AND PERIODS.ACTUAL_TERMINATION_DATE BETWEEN :P_START_DATE AND :P_END_DATE
                           AND (PEOPLE.EFFECTIVE_START_DATE = ALL_PEOPLE.EFFECTIVE_START_DATE
                            AND PEOPLE.EFFECTIVE_START_DATE = PERIODS.DATE_START)
                           AND ASSIGNMENTS.PERIOD_OF_SERVICE_ID = PERIODS.PERIOD_OF_SERVICE_ID
                           AND PERIODS.ACTUAL_TERMINATION_DATE IS NOT NULL
                         ORDER BY ALL_PEOPLE.PER_INFORMATION2';
    
    END IF;
    
    BEGIN
        pac_append_to_file(var_path, var_file_name, '');
        UTL_FILE.FREMOVE(var_path, var_file_name);
    EXCEPTION WHEN OTHERS THEN
        pac_append_to_file(var_path, var_file_name, '');
        dbms_output.put_line('Error al Limpiar el Archivo.. ' || SQLERRM);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error al Limpiar el Archivo.. ' || SQLERRM);
    END;
    
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Creando el Body del Documento. . .');
    
    BEGIN
        
        OPEN DETAIL_LIST FOR var_query USING P_COMPANY_ID, P_COMPANY_ID, P_PAYROLL_ID, P_CONSOLIDATION_ID, var_start_date, var_end_date;
        
        LOOP
            FETCH DETAIL_LIST INTO DETAIL;
            EXIT WHEN DETAIL_LIST%NOTFOUND;
            
            var_detail := '';
            IF P_TYPE_MOVEMENT = 2 THEN
                var_detail := var_detail || REPLACE(DETAIL.RFC, '-', '') || '|';    --Campo 1: RFC Trabajador. Longitud limitada a 13 posiciones. 
            END IF;
            var_detail := var_detail || DETAIL.CURP || '|';                         --Campo 2 (1): CURP. Longitud limitada a 18 posiciones, tipo alfanumérico.
            var_detail := var_detail || TRIM(DETAIL.AP_PATERNO) || '|';             --Campo 3 (2): Apellido Paterno, requerido. Longitud limitada a 40 posiciones.
            var_detail := var_detail || TRIM(DETAIL.AP_MATERNO) || '|';             --Campo 4 (3): Apellido Materno, requerido. Longitud limitada a 40 posiciones.
            var_detail := var_detail || TRIM(DETAIL.NOMBRES) || '|';                --Campo 5 (4): Nombres, requerido. Longitud limitada a 40 posiciones.
            var_detail := var_detail || DETAIL.FECHA || '|';                        --Campo 6 (5): Fecha del movimiento, requerido. Longitud limitada a 8 posiciones. Formato DD/MM/AAAA
            IF P_TYPE_MOVEMENT = 1 THEN
                IF DETAIL.SALARIO_DIARIO >= 1095.9 THEN
                    var_detail := var_detail || '1' || '|';
                ELSE
                    var_detail := var_detail || '2' || '|';
                END IF;
            ELSIF P_TYPE_MOVEMENT = 2 THEN
                var_detail := var_detail || '1' || '|';                             --Campo 7 (6): Indicador de movimiento, requerido. Longitud limitada a 1 posición. 
            END IF;                                     
            var_detail := var_detail || DETAIL.RFC_COMPANIA;                        --Campo 8 (7): RFC Compañía. Longitud limitada a 13 posiciones. 
            
            dbms_output.put_line(var_detail);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_detail);
            pac_append_to_file(var_path, var_file_name, var_detail);
            
        END LOOP;
        CLOSE DETAIL_LIST;
        
    EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('**Error al Ejecutar la Consulta en el Cursor. ' || SQLERRM); 
        FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Ejecutar la Consulta en el Cursor. ' || SQLERRM);
    END;
    
        
    --Finalización del Procedimiento.
    dbms_output.put_line('Archivo creado!');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Archivo creado!');
    
EXCEPTION WHEN OTHERS THEN
    dbms_output.put_line('**Error al Ejecutar el Procedure PAC_SOLICITUD_RFC_SAT_PRC. ' || SQLERRM);
    FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Ejecutar el Procedure PAC_SOLICITUD_RFC_SAT_PRC. ' || SQLERRM);
END;