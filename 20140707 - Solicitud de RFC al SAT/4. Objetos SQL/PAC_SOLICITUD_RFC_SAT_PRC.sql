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
       var_query    :=  'SELECT DISTINCT
                            PAPF.PERSON_ID                                              AS  PERSON_ID,                           
                            PAPF.PER_INFORMATION2                                       AS  RFC,
                            PAPF.NATIONAL_IDENTIFIER                                    AS  CURP,
                            PAPF.LAST_NAME                                              AS  AP_PATERNO,
                            PAPF.PER_INFORMATION1                                       AS  AP_MATERNO,
                            PAPF.FIRST_NAME || '' '' || PAPF.MIDDLE_NAMES                 AS  NOMBRES,
                            PRRV.RESULT_VALUE                                           AS  SALARIO_DIARIO,
                            TO_CHAR(NVL(PPOS.ADJUSTED_SVC_DATE, 
                                        PAPF.ORIGINAL_DATE_OF_HIRE) , ''DD/MM/RRRR'')     AS  FECHA,
                           (SELECT DISTINCT
                                INFORMATION.ORG_INFORMATION2
                            FROM FND_LOOKUP_VALUES                     COMPANY     
                            INNER JOIN HR_ORGANIZATION_UNITS_V         ORGANIZATIONS    ON COMPANY.MEANING = ORGANIZATIONS.NAME
                            INNER JOIN HR_ORGANIZATION_INFORMATION     INFORMATION      ON INFORMATION.ORGANIZATION_ID = ORGANIZATIONS.ORGANIZATION_ID
                            WHERE COMPANY.lookup_type= ''NOMINAS POR EMPLEADOR LEGAL''
                              AND COMPANY.lookup_code = :P_COMPANY_ID
                              AND INFORMATION.ORG_INFORMATION_CONTEXT = ''MX_TAX_REGISTRATION'')  AS RFC_COMPANIA          
                          FROM PER_ALL_PEOPLE_F         PAPF,
                               PER_ALL_ASSIGNMENTS_F    PAAF, 
                               PAY_PAYROLLS_F           PPF,     
                               PAY_PAYROLL_ACTIONS      PPA,    
                               PAY_ASSIGNMENT_ACTIONS   PAA,     
                               PAY_RUN_RESULTS          PRR,     
                               PAY_RUN_RESULT_VALUES    PRRV,     
                               PAY_ELEMENT_TYPES_F      PETF,    
                               PER_PERSON_TYPE_USAGES_F PPTUF,
                               PER_PERIODS_OF_SERVICE   PPOS,   
                               PER_TIME_PERIODS         PTP  
                         WHERE 1 = 1
                           AND PAPF.PERSON_ID = PAAF.PERSON_ID
                           AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
                           AND PPF.PAYROLL_ID = PPA.PAYROLL_ID
                           AND PAAF.ASSIGNMENT_ID = PAA.ASSIGNMENT_ID
                           AND PPA.PAYROLL_ACTION_ID = PAA.PAYROLL_ACTION_ID
                           AND PAA.ASSIGNMENT_ACTION_ID = PRR.ASSIGNMENT_ACTION_ID
                           AND PRR.RUN_RESULT_ID = PRRV.RUN_RESULT_ID
                           AND PRR.ELEMENT_TYPE_ID = PETF.ELEMENT_TYPE_ID
                           AND PPTUF.PERSON_ID = PAPF.PERSON_ID
                           AND PPOS.PERSON_ID= PAPF.PERSON_ID 
                           AND PPA.TIME_PERIOD_ID = PTP.TIME_PERIOD_ID
                           AND PPA.PAYROLL_ID = PTP.PAYROLL_ID
                           AND PETF.ELEMENT_NAME = ''I001_SALARIO_DIARIO''
                           AND SUBSTR(PPF.PAYROLL_NAME, 1, 2) = :P_COMPANY_ID
                           AND PPF.PAYROLL_ID = NVL(:P_PAYROLL_ID, PPF.PAYROLL_ID)
                           AND PPA.CONSOLIDATION_SET_ID = NVL(:P_CONSOLIDATION_ID, PPA.CONSOLIDATION_SET_ID)   
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN :P_START_DATE AND :P_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PTP.START_DATE AND PTP.END_DATE   
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                           AND PAAF.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID
                           AND PPOS.ACTUAL_TERMINATION_DATE IS NULL
                         ORDER BY PAPF.NATIONAL_IDENTIFIER';
    
    ELSIF TO_NUMBER(P_TYPE_MOVEMENT) = 2 THEN   --Baja
        var_query    :=  'SELECT DISTINCT
                            PAPF.PERSON_ID                                              AS  PERSON_ID,                           
                            PAPF.PER_INFORMATION2                                       AS  RFC,
                            PAPF.NATIONAL_IDENTIFIER                                    AS  CURP,
                            PAPF.LAST_NAME                                              AS  AP_PATERNO,
                            PAPF.PER_INFORMATION1                                       AS  AP_MATERNO,
                            PAPF.FIRST_NAME || '' '' || PAPF.MIDDLE_NAMES                 AS  NOMBRES,
                            PRRV.RESULT_VALUE                                           AS  SALARIO_DIARIO,
                            TO_CHAR(PPOS.ACTUAL_TERMINATION_DATE, ''DD/MM/RRRR'')      AS  FECHA,
                              (SELECT DISTINCT
                                    INFORMATION.ORG_INFORMATION2
                                FROM FND_LOOKUP_VALUES                     COMPANY     
                                INNER JOIN HR_ORGANIZATION_UNITS_V         ORGANIZATIONS    ON COMPANY.MEANING = ORGANIZATIONS.NAME
                                INNER JOIN HR_ORGANIZATION_INFORMATION     INFORMATION      ON INFORMATION.ORGANIZATION_ID = ORGANIZATIONS.ORGANIZATION_ID
                                WHERE COMPANY.lookup_type= ''NOMINAS POR EMPLEADOR LEGAL''
                                  AND COMPANY.lookup_code = :P_COMPANY_ID
                                  AND INFORMATION.ORG_INFORMATION_CONTEXT = ''MX_TAX_REGISTRATION'')  AS RFC_COMPANIA
                          FROM PER_ALL_PEOPLE_F             PAPF,  
                               PER_ALL_ASSIGNMENTS_F        PAAF, 
                               PAY_PAYROLLS_F               PPF,     
                               PAY_PAYROLL_ACTIONS          PPA,    
                               PAY_ASSIGNMENT_ACTIONS       PAA,     
                               PAY_RUN_RESULTS              PRR,     
                               PAY_RUN_RESULT_VALUES        PRRV,     
                               PAY_ELEMENT_TYPES_F          PETF,    
                               PER_PERIODS_OF_SERVICE_V     PPOS,
                               PER_TIME_PERIODS             PTP      
                         WHERE 1 = 1
                           AND PAPF.PERSON_ID = PAAF.PERSON_ID
                           AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
                           AND PPF.PAYROLL_ID = PPA.PAYROLL_ID
                           AND PAAF.ASSIGNMENT_ID = PAA.ASSIGNMENT_ID
                           AND PPA.PAYROLL_ACTION_ID = PAA.PAYROLL_ACTION_ID
                           AND PAA.ASSIGNMENT_ACTION_ID = PRR.ASSIGNMENT_ACTION_ID
                           AND PRR.RUN_RESULT_ID = PRRV.RUN_RESULT_ID
                           AND PRR.ELEMENT_TYPE_ID = PETF.ELEMENT_TYPE_ID
                           AND PPOS.PERSON_ID= PAPF.PERSON_ID 
                           AND PPA.TIME_PERIOD_ID = PTP.TIME_PERIOD_ID
                           AND PPA.PAYROLL_ID = PTP.PAYROLL_ID
                           AND PETF.ELEMENT_NAME = ''I001_SALARIO_DIARIO''
                           AND SUBSTR(PPF.PAYROLL_NAME, 1, 2) = :P_COMPANY_ID
                           AND PPF.PAYROLL_ID = NVL(:P_PAYROLL_ID, PPF.PAYROLL_ID)
                           AND PPA.CONSOLIDATION_SET_ID = NVL(:P_CONSOLIDATION_ID, PPA.CONSOLIDATION_SET_ID)  
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN :P_START_DATE AND :P_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PTP.START_DATE AND PTP.END_DATE   
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                           AND PAAF.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID
                           AND PPOS.ACTUAL_TERMINATION_DATE IS NOT NULL
                         ORDER BY PAPF.PER_INFORMATION2';
    
    END IF;
    
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
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, var_detail);
            
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