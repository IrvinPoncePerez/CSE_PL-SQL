    CREATE OR REPLACE PROCEDURE PAC_ALTAS_EDENRED_PRC (
                P_ERRBUF    OUT NOCOPY  VARCHAR2,
                P_RETCODE   OUT NOCOPY  VARCHAR2,
                P_COMPANY_ID            VARCHAR2,
                P_PAYMENT_METHOD_ID     VARCHAR2,
                P_START_DATE            VARCHAR2,
                P_END_DATE              VARCHAR2)
IS
    var_start_date  DATE := TRUNC(TO_DATE(P_START_DATE,'RRRR/MM/DD HH24:MI:SS'));
    var_end_date    DATE := TRUNC(TO_DATE(P_END_DATE,'RRRR/MM/DD HH24:MI:SS'));
    
    var_path        VARCHAR2(250) := 'ALTAS_EDENRED';
    var_file_name   VARCHAR2(250) := '';
    var_file        UTL_FILE.FILE_TYPE;
    
    var_campo1      VARCHAR2(100);  --Campo 1: Valor Constante = '85', requerido 
    var_campo2      VARCHAR2(100);  --Campo 2: Número de sucursal,  valor constante = '001', requerido
    var_campo3      VARCHAR2(100);  --Campo 3: Valor Constante = '012', requerido
    var_campo4      VARCHAR2(100);  --Campo 4: Número de grupo de cliente, Valor Constante = '72256', requerido
    var_campo5      VARCHAR2(100);  --Campo 5: Número de sucursal,  valor constante = '001', requerido  
    var_campo6      VARCHAR2(100);  --Campo 6: Razón Social de su Empresa Longitud de 40 caracteres alfanumérico, requerido.
    var_campo7      VARCHAR2(100);  --Campo 7: Número total de registro de alta de personas.
    var_campo9      VARCHAR2(50);   --Campo 9: Valor constante = 'T', requerido
    
    CURSOR DETAIL_LIST  IS
            SELECT 
    PPPM.ATTRIBUTE1                                                                AS  NUM_CUENTA,
    PAP.EMPLOYEE_NUMBER                                                            AS  NUM_EMPLEADO,
    (PAP.FIRST_NAME || ' ' || PAP.MIDDLE_NAMES)                                    AS  NOMBRES,
    PAP.LAST_NAME                                                                  AS  AP_PATERNO,
    PAP.PER_INFORMATION1                                                           AS  AP_MATERNO,
    REPLACE(PAP.PER_INFORMATION2, '-' , '')                                        AS  RFC,
    PAP.NATIONAL_IDENTIFIER                                                        AS  CURP,
    TRIM(TO_CHAR(REPLACE(NVL(PAP.PER_INFORMATION3, '0'), '-', ''), '00000000000')) AS  NUM_SEGURO
  FROM PER_ALL_PEOPLE_F                     PAP,
       PER_ALL_ASSIGNMENTS_F                PAA,
       PAY_PAYROLLS_F                       PP,
       PAY_PERSONAL_PAYMENT_METHODS_F       PPPM,
       PER_PERSON_TYPE_USAGES_F             PPTU,
       PER_PERIODS_OF_SERVICE               PPS
 WHERE 1 = 1
   AND PAP.PERSON_ID = PAA.PERSON_ID
   AND PAA.PAYROLL_ID = PP.PAYROLL_ID
   AND PAA.ASSIGNMENT_ID = PPPM.ASSIGNMENT_ID
   AND SUBSTR(PP.PAYROLL_NAME, 1, 2) = P_COMPANY_ID
   AND PAP.PERSON_ID = PPTU.PERSON_ID
   AND (PPTU.EFFECTIVE_START_DATE BETWEEN var_start_date AND var_end_date)
   AND PAP.PERSON_ID = PPS.PERSON_ID
   AND PPPM.ORG_PAYMENT_METHOD_ID = P_PAYMENT_METHOD_ID
   AND (PAP.EFFECTIVE_START_DATE = PPTU.EFFECTIVE_START_DATE
    AND PAP.EFFECTIVE_START_DATE = PPS.DATE_START)
   AND PPS.ACTUAL_TERMINATION_DATE IS NULL
   AND PAA.PERIOD_OF_SERVICE_ID = PPS.PERIOD_OF_SERVICE_ID
   AND PPPM.OBJECT_VERSION_NUMBER = (SELECT MAX(PPPM1.OBJECT_VERSION_NUMBER)
                                       FROM PAY_PERSONAL_PAYMENT_METHODS_F  PPPM1
                                      WHERE PPPM1.PERSONAL_PAYMENT_METHOD_ID = PPPM.PERSONAL_PAYMENT_METHOD_ID);
                          

BEGIN

    -- Impresión de los parametros.
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_COMPANY_ID : '        || P_COMPANY_ID);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_PAYMENT_METHOD_ID : ' || P_PAYMENT_METHOD_ID);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_START_DATE : '        || P_START_DATE || ' - '   || var_start_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_END_DATE : '          || P_END_DATE || ' - '     || var_end_date);
    
    dbms_output.put_line('P_COMPANY_ID : '          || P_COMPANY_ID);
    dbms_output.put_line('P_PAYMENT_METHOD_ID : '   || P_PAYMENT_METHOD_ID);
    dbms_output.put_line('P_START_DATE : '          || P_START_DATE || ' - '    || var_start_date);
    dbms_output.put_line('P_END_DATE : '            || P_END_DATE || ' - '      || var_end_date);

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Creando Documento. . .');
    dbms_output.put_line('Creando Documento. . .');
    
    --Consulta de los campos del Header del Documento.
    BEGIN
            
        SELECT
            (SELECT DISTINCT
                meaning
               FROM FND_LOOKUP_VALUES
              WHERE lookup_type = 'XXCALV_ALTA_EDENRED'
                AND lookup_code = '001_CALV') AS campo1,
            (SELECT DISTINCT
                meaning
               FROM FND_LOOKUP_VALUES
              WHERE lookup_type = 'XXCALV_ALTA_EDENRED'
                AND lookup_code = '002_CALV') AS campo2,
            (SELECT DISTINCT
                meaning
               FROM FND_LOOKUP_VALUES
              WHERE lookup_type = 'XXCALV_ALTA_EDENRED'
                AND lookup_code = '003_CALV') AS campo3,
            (SELECT DISTINCT
                meaning
               FROM FND_LOOKUP_VALUES
              WHERE lookup_type = 'XXCALV_ALTA_EDENRED'
                AND lookup_code = '004_CALV') AS campo4,
            (CASE
                WHEN P_COMPANY_ID = '02' THEN
                    (SELECT DISTINCT
                        meaning
                       FROM FND_LOOKUP_VALUES
                      WHERE lookup_type = 'XXCALV_ALTA_EDENRED'
                        AND lookup_code = '002_CALV')
                WHEN P_COMPANY_ID = '08' THEN
                    (SELECT DISTINCT
                        meaning
                       FROM FND_LOOKUP_VALUES
                      WHERE lookup_type = 'XXCALV_ALTA_EDENRED'
                        AND lookup_code = '010_CALV')
             END) AS campo5,
            (CASE
                WHEN P_COMPANY_ID = '02' THEN
                    (SELECT DISTINCT
                        TRIM(RPAD(meaning, 40,' '))
                      FROM FND_LOOKUP_VALUES
                     WHERE lookup_type = 'XXCALV_ALTA_EDENRED'
                       AND lookup_code = '005_CALV')
                WHEN P_COMPANY_ID = '08' THEN
                    (SELECT DISTINCT
                        TRIM(RPAD(meaning, 40,' '))
                      FROM FND_LOOKUP_VALUES
                     WHERE lookup_type = 'XXCALV_ALTA_EDENRED'
                       AND lookup_code = '006_CALV')
                ELSE
                    'NO SE ENCONTRO.'
            END) AS campo6,
            (SELECT DISTINCT
                meaning
               FROM FND_LOOKUP_VALUES
              WHERE lookup_type = 'XXCALV_ALTA_EDENRED'
                AND lookup_code = '007_CALV') AS campo9
          INTO
            var_campo1,
            var_campo2,
            var_campo3,
            var_campo4,
            var_campo5,
            var_campo6,
            var_campo9
          FROM dual;
        
        --Armado del Nombre del Archivo.
        var_file_name := 'QF';
        var_file_name := var_file_name || var_campo4; 
        var_file_name := var_file_name || var_campo2; 
        var_file_name := var_file_name || TRIM(TO_CHAR(SYSDATE, 'RRRRMMDD')); 
        var_file_name := var_file_name || '.csv';    
        
        
        
        BEGIN
        
            var_file := UTL_FILE.FOPEN(var_path, var_file_name, 'A', 30000);
            UTL_FILE.FREMOVE(var_path, var_file_name);
        
        EXCEPTION WHEN UTL_FILE.INVALID_OPERATION THEN
            var_file := UTL_FILE.FOPEN(var_path, var_file_name, 'A', 30000); 
                  WHEN OTHERS THEN
            dbms_output.put_line('**Error al Limpiar el Archivo. ' || SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Limpiar el Archivo. ' || SQLERRM);
        END;
        
        var_file := UTL_FILE.FOPEN(var_path, var_file_name, 'A', 30000);
        
        
        
        --Consulta del Total de Registros Consultados.
        FOR detail IN DETAIL_LIST LOOP
            var_campo7 := DETAIL_LIST%ROWCOUNT;
        END LOOP;           
    
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Consultar los Datos del Header del Documento. ' || SQLERRM);
        dbms_output.put_line('**Error al Consultar los Datos del Header del Documento. ' || SQLERRM);
    END;
    
    BEGIN
    
                     
        UTL_FILE.PUT_LINE(var_file, 
                                var_campo1 || ',' ||     --Campo 1: Valor Constante = '85', requerido
                                var_campo2 || ',' ||     --Campo 2: Número de sucursal,  valor constante = '001', requerido
                                var_campo3 || ',' ||     --Campo 3: Valor Constante = '012', requerido 
                                var_campo4 || ',' ||     --Campo 4: Número de grupo de cliente, Valor Constante = '72256', requerido
                                var_campo5 || ',' ||     --Campo 5: Número de sucursal,  valor constante = '001', requerido
                                var_campo6 || ',' ||     --Campo 6: Razón Social de su Empresa Longitud de 40 caracteres alfanumérico, requerido.
                                var_campo7 || ','        --Campo 7: Número total de registro de alta de personas. 
                          );
        
        --Recorrido de los Registros de Detalle.
        BEGIN
                        
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Creando los Registros de Detalle. . .');
            dbms_output.put_line('Creando los Registros de Detalle. . .');
                        
            FOR detail IN DETAIL_LIST LOOP
                            
                UTL_FILE.PUT_LINE(var_file,
                                    TO_CHAR(TRIM(RPAD(detail.NUM_CUENTA, 16, ' ')))  || ',' ||      --Campo 8: Número de Tarjeta:
                                    TO_CHAR(TRIM(var_campo9))                        || ',' ||      --Campo 9: Valor constante = 'T', requerido
                                    TO_CHAR(TRIM(RPAD(detail.NUM_EMPLEADO, 10, ' ')))|| ',' ||      --Campo 10: Id de empleado
                                    TO_CHAR(TRIM(RPAD(detail.AP_PATERNO, 20, ' ')))  || ',' ||      --Campo 11: Apellido Paterno, requerido. Longitud limitada a 20 posiciones.
                                    TO_CHAR(TRIM(RPAD(detail.AP_MATERNO, 20, ' ')))  || ',' ||      --Campo 12: Apellido Materno, requerido. Longitud limitada a 20 posiciones.
                                    TO_CHAR(TRIM(RPAD(detail.NOMBRES, 20, ' ')))     || ',' ||      --Campo 13: Nombres, requerido. Longitud limitada a 10 posiciones.
                                    TO_CHAR(TRIM(RPAD(detail.RFC, 13, ' ')))         || ',' ||      --Campo 14: RFC Trabajador. Longitud limitada a 13 posiciones. 
                                    TO_CHAR(TRIM(RPAD(detail.CURP, 18, ' ')))        || ',' ||      --Campo 15: CURP. Longitud limitada a 18 posiciones, tipo alfanumérico.
                                    TO_CHAR(TRIM(detail.NUM_SEGURO))                 || ','         --Campo 16: NSS del Empleado. Longitud limitada a 11 posiciones. 
                                  );  
                                  
                 FND_FILE.PUT_LINE(FND_FILE.LOG,
                                    TO_CHAR(TRIM(RPAD(detail.NUM_CUENTA, 16, ' ')))  || ',' ||      --Campo 8: Número de Tarjeta:
                                    TO_CHAR(TRIM(var_campo9))                        || ',' ||      --Campo 9: Valor constante = 'T', requerido
                                    TO_CHAR(TRIM(RPAD(detail.NUM_EMPLEADO, 10, ' ')))|| ',' ||      --Campo 10: Id de empleado
                                    TO_CHAR(TRIM(RPAD(detail.AP_PATERNO, 20, ' ')))  || ',' ||      --Campo 11: Apellido Paterno, requerido. Longitud limitada a 20 posiciones.
                                    TO_CHAR(TRIM(RPAD(detail.AP_MATERNO, 20, ' ')))  || ',' ||      --Campo 12: Apellido Materno, requerido. Longitud limitada a 20 posiciones.
                                    TO_CHAR(TRIM(RPAD(detail.NOMBRES, 20, ' ')))     || ',' ||      --Campo 13: Nombres, requerido. Longitud limitada a 10 posiciones.
                                    TO_CHAR(TRIM(RPAD(detail.RFC, 13, ' ')))         || ',' ||      --Campo 14: RFC Trabajador. Longitud limitada a 13 posiciones. 
                                    TO_CHAR(TRIM(RPAD(detail.CURP, 18, ' ')))        || ',' ||      --Campo 15: CURP. Longitud limitada a 18 posiciones, tipo alfanumérico.
                                    TO_CHAR(TRIM(detail.NUM_SEGURO))                 || ','         --Campo 16: NSS del Empleado. Longitud limitada a 11 posiciones. 
                                  );                   
                        
            END LOOP;
                    
        EXCEPTION WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Realizar el Recorrido del Cursor. ' || SQLERRM);
            dbms_output.put_line('**Error al Realizar el Recorrido del Cursor. ' || SQLERRM);
        END;
                
               
    
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Ejecutar el Crear l Cuerpo del Documento Excel. ' || SQLERRM);
        dbms_output.put_line('****Error al Ejecutar el Crear l Cuerpo del Documento Excel. ' || SQLERRM);
    END;
    
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Archivo creado! ');
    dbms_output.put_line('Archivo creado! ');
    
EXCEPTION WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Ejecutar el Procedimiento PAC_ALTAS_EDENRED_PRC. ' || SQLERRM);
    dbms_output.put_line('**Error al Ejecutar el Procedimiento PAC_ALTAS_EDENRED_PRC. ' || SQLERRM);
END;