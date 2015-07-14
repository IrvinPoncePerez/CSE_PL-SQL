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
                       
    --Definición de subprogramas para la manipulación del Archivo Excel.
    PROCEDURE OPEN_FILE IS
    BEGIN
        UTL_FILE.FREMOVE(var_path, var_file_name);
        var_file := UTL_FILE.FOPEN(var_path, var_file_name, 'w', 20000);
    EXCEPTION 
        WHEN UTL_FILE.INVALID_OPERATION THEN
            var_file := UTL_FILE.FOPEN(var_path, var_file_name, 'w', 20000);    
        WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error en el Procedimiento openFile(). ' || SQLERRM);
            dbms_output.put_line('**Error en el Procedimiento openFile(). ' || SQLERRM);        
    END;
    
    PROCEDURE CLOSE_FILE IS
    BEGIN
        UTL_FILE.FCLOSE(var_file);
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error en el Procedimiento closeFile(). ' || SQLERRM); 
        dbms_output.put_line('**Error en el Procedimiento closeFile(). ' || SQLERRM);   
    END;
    
    PROCEDURE START_WORKBOOK IS
    BEGIN
        UTL_FILE.PUT_LINE(var_file, '<?xml version="1.0"?>');
        UTL_FILE.PUT_LINE(var_file, '<ss:Workbook xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">');
    END;
    
    PROCEDURE END_WORKBOOK IS
    BEGIN
        UTL_FILE.PUT_LINE(var_file, '</ss:Workbook>');
    END;
    
    PROCEDURE START_WORKSHEET(p_sheetname VARCHAR2) IS
    BEGIN
        UTL_FILE.PUT_LINE(var_file, '<ss:Worksheet ss:Name="' || p_sheetname || '">');
        UTL_FILE.PUT_LINE(var_file, '<ss:Table>');
    END;
    
    PROCEDURE END_WORKSHEET IS
    BEGIN
        UTL_FILE.PUT_LINE(var_file, '</ss:Table>');
        UTL_FILE.PUT_LINE(var_file, '</ss:Worksheet>');
    END;
    
    PROCEDURE ADD_ROW IS
    BEGIN
        UTL_FILE.PUT_LINE(var_file, '<ss:Row>');
    END;
    
    PROCEDURE CLOSE_ROW IS
    BEGIN
        UTL_FILE.PUT_LINE(var_file, '</ss:Row>');
    END;
    
    PROCEDURE ADD_CELL(var_data VARCHAR2, var_type VARCHAR2) IS
    BEGIN
        UTL_FILE.PUT_LINE(var_file, '<ss:Cell>');
        UTL_FILE.PUT_LINE(var_file, '<ss:Data ss:Type="' || var_type || '">' || var_data || '</ss:Data>');
        UTL_FILE.PUT_LINE(var_file, '</ss:Cell>');
    END;    

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
        var_file_name := var_file_name || '.xls';    
        
        --Consulta del Total de Registros Consultados.
        FOR detail IN DETAIL_LIST LOOP
            var_campo7 := DETAIL_LIST%ROWCOUNT;
        END LOOP;           
    
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Consultar los Datos del Header del Documento. ' || SQLERRM);
        dbms_output.put_line('**Error al Consultar los Datos del Header del Documento. ' || SQLERRM);
    END;
    
    BEGIN
    
        OPEN_FILE(); --Creación del Documento Excel.
            START_WORKBOOK();
                START_WORKSHEET('Hoja1');
                
                    ADD_ROW();
                        ADD_CELL(var_campo1, 'Number');     --Campo 1: Valor Constante = '85', requerido
                        ADD_CELL(var_campo2, 'Number');     --Campo 2: Número de sucursal,  valor constante = '001', requerido
                        ADD_CELL(var_campo3, 'Number');     --Campo 3: Valor Constante = '012', requerido 
                        ADD_CELL(var_campo4, 'Number');     --Campo 4: Número de grupo de cliente, Valor Constante = '72256', requerido
                        ADD_CELL(var_campo5, 'Number');     --Campo 5: Número de sucursal,  valor constante = '001', requerido
                        ADD_CELL(var_campo6, 'String');     --Campo 6: Razón Social de su Empresa Longitud de 40 caracteres alfanumérico, requerido.
                        ADD_CELL(var_campo7, 'Number');     --Campo 7: Número total de registro de alta de personas. 
                    CLOSE_ROW();
        
                    --Recorrido de los Registros de Detalle.
                    BEGIN
                        
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Creando los Registros de Detalle. . .');
                        dbms_output.put_line('Creando los Registros de Detalle. . .');
                        
                        FOR detail IN DETAIL_LIST LOOP
                            
                            ADD_ROW();
                                ADD_CELL(TRIM(RPAD(detail.NUM_CUENTA, 16, ' ')), 'String');      --Campo 8: Número de Tarjeta:
                                ADD_CELL(var_campo9, 'String');                                  --Campo 9: Valor constante = 'T', requerido
                                ADD_CELL(TRIM(RPAD(detail.NUM_EMPLEADO, 10, ' ')), 'Number');    --Campo 10: Id de empleado
                                ADD_CELL(TRIM(RPAD(detail.AP_PATERNO, 20, ' ')), 'String');      --Campo 11: Apellido Paterno, requerido. Longitud limitada a 20 posiciones.
                                ADD_CELL(TRIM(RPAD(detail.AP_MATERNO, 20, ' ')), 'String');      --Campo 12: Apellido Materno, requerido. Longitud limitada a 20 posiciones.
                                ADD_CELL(TRIM(RPAD(detail.NOMBRES, 20, ' ')), 'String');         --Campo 13: Nombres, requerido. Longitud limitada a 10 posiciones.
                                ADD_CELL(TRIM(RPAD(detail.RFC, 13, ' ')), 'String');             --Campo 14: RFC Trabajador. Longitud limitada a 13 posiciones. 
                                ADD_CELL(TRIM(RPAD(detail.CURP, 18, ' ')), 'String');            --Campo 15: CURP. Longitud limitada a 18 posiciones, tipo alfanumérico.
                                ADD_CELL(detail.NUM_SEGURO, 'String');                           --Campo 16: NSS del Empleado. Longitud limitada a 11 posiciones. 
                            CLOSE_ROW();  
                        
                        END LOOP;
                    
                    EXCEPTION WHEN OTHERS THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Realizar el Recorrido del Cursor. ' || SQLERRM);
                        dbms_output.put_line('**Error al Realizar el Recorrido del Cursor. ' || SQLERRM);
                    END;
                
                END_WORKSHEET();
            END_WORKBOOK();
        CLOSE_FILE(); --Cierre del Documento Excel.
    
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