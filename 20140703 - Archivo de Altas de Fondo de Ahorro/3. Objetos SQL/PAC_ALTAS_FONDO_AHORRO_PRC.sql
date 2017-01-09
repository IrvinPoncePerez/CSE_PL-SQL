CREATE OR REPLACE PROCEDURE APPS.PAC_ALTAS_FONDO_AHORRO_PRC(
    p_errbuf OUT NOCOPY VARCHAR2,
    p_retcode OUT NOCOPY VARCHAR2,
    P_START_DATE    VARCHAR2,
    P_END_DATE      VARCHAR2)
IS
    var_start_date  DATE := TRUNC(TO_DATE(P_START_DATE,'RRRR/MM/DD HH24:MI:SS'));
    var_end_date    DATE := TRUNC(TO_DATE(P_END_DATE,'RRRR/MM/DD HH24:MI:SS'));
    var_path        VARCHAR2(250) := 'FONDO_AHORRO_ALTAS';
    var_file_name   VARCHAR2(250) := 'FONDO_AHORRO_ALTAS.txt';
    
    var_header      VARCHAR(2000);
    var_body        VARCHAR(5000);
    var_footer      VARCHAR(2000);
    
    var_exe_seq     NUMBER;
    var_detail_seq  NUMBER;
    var_reg_serv    VARCHAR(50);
    var_detail_rows NUMBER;
    
    CURSOR DETAILS_LIST IS
          SELECT 
               PEOPLE.PERSON_ID,
               PEOPLE.RFC,
               PEOPLE.AP_PATERNO,
               PEOPLE.AP_MATERNO,
               PEOPLE.NOMBRES,
               PEOPLE.CUENTA_BANCO,
               PEOPLE.CODIGO_BANCO,
               PEOPLE.CLABE_BANCO,
               PEOPLE.NUM_NOMINA,
               PEOPLE.NUM_SEGURO,
               PEOPLE.CURP,
               PEOPLE.SEXO,
               PEOPLE.VALOR_ALTA,
               RPAD(NVL(PA.ADDRESS_LINE1, ' ') || ' ' || NVL(PA.ADDR_ATTRIBUTE2, ' ') , 40, ' ') AS  CALLE_NUMERO, --Campo 23: Calle y Número. Longitud limitada a 40 posiciones. 
               RPAD(NVL(PA.ADDRESS_LINE2, ' '), 25, ' ')                                         AS  COLONIA,            --Campo 24: Colonia. Longitud limitada a 25 posiciones.
               TO_CHAR(NVL(PA.POSTAL_CODE, 0), '00000')                                          AS  CODIGO_POSTAL,      --Campo 25: Código Postal. Longitud limitada a 5 posiciones.
               RPAD((NVL(PA.TOWN_OR_CITY, ' ') || ', ' || NVL(FLV.MEANING, ' ')), 20, ' ')       AS  CIUDAD              --Campo 26: Ciudad Y Estado. Longitud limitada a 20 posiciones.
          FROM (SELECT DISTINCT
                    PPF.PERSON_ID                                                               AS  PERSON_ID,
                    REPLACE(PAPF.PER_INFORMATION2, '-', '')                                     AS  RFC,                --Campo 11: RFC Trabajador. Longitud limitada a 13 posiciones. 
                    RPAD(TRIM(PAPF.LAST_NAME), 40, ' ')                                         AS  AP_PATERNO,         --Campo 12: Apellido Paterno, requerido. Longitud limitada a 40 posiciones.
                    RPAD(TRIM(PAPF.PER_INFORMATION1), 40, ' ')                                  AS  AP_MATERNO,         --Campo 13: Apellido Materno, requerido. Longitud limitada a 40 posiciones.
                    RPAD(PAPF.FIRST_NAME || ' ' || PAPF.MIDDLE_NAMES, 40, ' ')                  AS  NOMBRES,            --Campo 14: Nombres, requerido. Longitud limitada a 40 posiciones.
                    (SELECT DISTINCT
                        LPAD(MEANING, 13, '0')
                       FROM FND_LOOKUP_VALUES   FLV
                      WHERE FLV.LOOKUP_TYPE = 'XXCALV_APORT_FONDO_AHORRO'
                        AND FLV.LOOKUP_CODE = 'N CUENTA BAN')                                   AS  CUENTA_BANCO,       --Campo 15: Número de Cuenta Bancaria, requerido. Longitud limitada a 13 posiciones.
                    (SELECT DISTINCT
                        LPAD(MEANING, 3, '0')
                       FROM FND_LOOKUP_VALUES   FLV
                      WHERE FLV.LOOKUP_TYPE = 'XXCALV_APORT_FONDO_AHORRO'
                        AND FLV.LOOKUP_CODE = 'COD BANCO CUENT')                                AS  CODIGO_BANCO,       --Campo 16: Código del Banco de la Cuenta, requerido. Longitud limitada a 3 posiciones.
                    (SELECT DISTINCT
                        LPAD(MEANING, 20, '0')
                       FROM FND_LOOKUP_VALUES   FLV
                      WHERE FLV.LOOKUP_TYPE = 'XXCALV_APORT_FONDO_AHORRO'
                        AND FLV.LOOKUP_CODE = 'CLAVE INTERBANCARIA')                            AS  CLABE_BANCO,        --Campo 17: Clabe Interbancaria, requerido. Longitud limitada a 20 posiciones.
                    RPAD(PPF.EMPLOYEE_NUMBER, 20, ' ')                                          AS  NUM_NOMINA,         --Campo 18: Número de Nómina, requerido. Longitud limitada a 20 posiciones.
                    TO_CHAR(REPLACE(NVL(PAPF.PER_INFORMATION3, '0'), '-', ''), '00000000000')   AS  NUM_SEGURO,         --Campo 19: NSS del Empleado. Longitud limitada a 11 posiciones. 
                    RPAD(TRIM(PAPF.NATIONAL_IDENTIFIER), 18, ' ')                               AS  CURP,               --Campo 20: CURP. Longitud limitada a 18 posiciones, tipo alfanumérico.
                    TRIM(PPF.SEX)                                                               AS  SEXO,               --Campo 21: Sexo = F ó M. Longitud limitada a 1 posición.
                    TO_CHAR(PPTUF.EFFECTIVE_START_DATE, 'RRRRMMDD')                             AS  VALOR_ALTA         --Campo 22: Fecha Valor del Alta. Longitud limitada a 8 posiciones. Formato: AAAAMMDD    
                  FROM PER_PEOPLE_F                    PPF,      
                       PER_PERSON_TYPES                PPT, 
                       PER_ALL_PEOPLE_F                PAPF,  
                       PER_ALL_ASSIGNMENTS_F           PAAF,  
                       PER_PERSON_TYPE_USAGES_F        PPTUF,
                       PER_PERIODS_OF_SERVICE          PPS
                 WHERE 1 = 1
                   AND PPF.PERSON_ID = PPTUF.PERSON_ID
                   AND PPF.PERSON_TYPE_ID = PPT.PERSON_TYPE_ID
                   AND PAPF.PERSON_ID = PPF.PERSON_ID
                   AND PAAF.PERSON_ID = PPF.PERSON_ID
                   AND (PPTUF.EFFECTIVE_START_DATE BETWEEN var_start_date AND var_end_date)
                   AND (PPF.EFFECTIVE_START_DATE = PPTUF.EFFECTIVE_START_DATE
                    AND PPF.EFFECTIVE_START_DATE = PAPF.EFFECTIVE_START_DATE
                    AND PPF.EFFECTIVE_START_DATE = PPS.DATE_START)
                   AND PPS.ACTUAL_TERMINATION_DATE IS NULL
                   AND PAAF.PERIOD_OF_SERVICE_ID = PPS.PERIOD_OF_SERVICE_ID  
                   AND PPT.SYSTEM_PERSON_TYPE = 'EMP')  PEOPLE
         LEFT JOIN PER_ADDRESSES                        PA      ON  PEOPLE.PERSON_ID = PA.PERSON_ID
         LEFT JOIN FND_LOOKUP_VALUES                    FLV     ON  FLV.LOOKUP_CODE = PA.REGION_1 AND FLV.LOOKUP_TYPE = 'MX_STATE' AND FLV.LANGUAGE = 'ESA'             
        ORDER BY PEOPLE.PERSON_ID;
    
BEGIN

    BEGIN
        pac_append_to_file(var_path, var_file_name, '');
        UTL_FILE.FREMOVE(var_path, var_file_name);
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error al Limpiar el Archivo.. ' || SQLERRM);
    END;

    --  Impresión de Parametros de Entrada.
    FND_FILE.PUT_LINE(FND_FILE.LOG,'P_START_DATE : '|| P_START_DATE);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'P_END_DATE : '  || P_END_DATE);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'var_start_date : ' || var_start_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'var_end_date : '   || var_end_date);
    
    --  Consulta del Consecutivo del Ejecutable Diario.
    BEGIN
    
        SELECT PAC_ALTA_FONDO_AHORRO_EXE_SEQ.NEXTVAL
          INTO var_exe_seq
          FROM dual;
    
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error al calcular el consecutivo de ejecución diaria. ' || SQLERRM);
    END;    
    
    
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Creando Header del Documento de Altas de Fondo de Ahorro . . .');
    --  Creación del Header del Archivo de Altas de Fondo de Ahorro.
    BEGIN
        SELECT
            (SELECT meaning
               FROM FND_LOOKUP_VALUES
              WHERE lookup_type = 'XXCALV_APORT_FONDO_AHORRO'
                AND LANGUAGE = userenv('LANG')
                AND lookup_code = '001_CALV') ||    --Campo 1: Tipo de Registro = '01', requerido. Longitud limitada a 2 posiciones.
            (SELECT REPLACE(meaning, '=ALTA')
               FROM FND_LOOKUP_VALUES
              WHERE lookup_type = 'XXCALV_APORT_FONDO_AHORRO'
                AND LANGUAGE = userenv('LANG')
                AND lookup_code = 'ID_SERV_ALT') || --Campo 2: Identificador de Servicio = '01',  requerido. Longitud limitada a 2 posiciones.
            (TO_CHAR(SYSDATE, 'RRRRMMDD'))||        --Campo 3: Fecha de Envío de Información, requerido.
            (TRIM(TO_CHAR(var_exe_seq, '000'))) ||  --Campo 4: Consecutivo del día, requerido. Longitud limitada a 3 posiciones. Tipo Numérico.
            (SELECT TRIM(TO_CHAR(meaning, '0000000'))
               FROM FND_LOOKUP_VALUES
              WHERE lookup_type = 'XXCALV_APORT_FONDO_AHORRO'
                AND LANGUAGE = userenv('LANG')
                AND lookup_code = 'CONTRATO') ||    --Campo 5: Contrato = '0554535', requerido. Longitud limitada a 7 posiciones.
            (SELECT TRIM(TO_CHAR(meaning, '000000'))
               FROM FND_LOOKUP_VALUES
              WHERE lookup_type = 'XXCALV_APORT_FONDO_AHORRO'
                AND LANGUAGE = userenv('LANG')
                AND lookup_code = 'SUBCONTRATO') ||  --Campo 6: Subcontrato = '0', requerido. Longitud limitada a 6 posiciones.
            (RPAD(' ', 772, ' '))  --Campo 7: Uso Futuro. Longitud 772 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
        INTO var_header
        FROM dual;
                
        dbms_output.put_line(var_header);  
        pac_append_to_file(var_path, var_file_name, var_header);      
        
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.LOG,'Error inesperado armando el header. ' || SQLERRM);
    END;    
    
    
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Creando Body del Documento de Altas de Fondo de Ahorro . . .');
    --  Consulta de la Etiqueta Inicial del Body.
    BEGIN
        
        SELECT 
            (SELECT
                TRIM(TO_CHAR(meaning, '00')) 
               FROM FND_LOOKUP_VALUES
              WHERE lookup_type = 'XXCALV_APORT_FONDO_AHORRO'
                AND LANGUAGE = userenv('LANG')
                AND lookup_code = 'TIPO_REG') ||    --Campo 8: Tipo de Registro = '02', requerido. Longitud limitada a 2 posiciones.
            (SELECT 
                REPLACE(meaning, '=ALTA')
               FROM FND_LOOKUP_VALUES
              WHERE lookup_type = 'XXCALV_APORT_FONDO_AHORRO'
                AND LANGUAGE = userenv('LANG')
                AND lookup_code = 'ID_SERV_ALT')    --Campo 9: Identificador de Servicio = '01',  requerido. Longitud limitada a 2 posiciones.
          INTO var_reg_serv
          FROM dual;
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error al Consultar el Tipo de Registro e Identificador de Servicio. ' || SQLERRM);
    END;
    
    --  Reinicio de la secuencia de detalle.
    BEGIN
    
       EXECUTE IMMEDIATE 'DROP SEQUENCE PAC_ALTA_FONDO_AHORRO_DET_SEQ';

       EXECUTE IMMEDIATE
             'CREATE SEQUENCE PAC_ALTA_FONDO_AHORRO_DET_SEQ '
          || 'START WITH 1 '
          || 'INCREMENT BY 1 '
          || 'NOCACHE '
          || 'NOCYCLE';
    
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error al Reiniciar la secuencia de detalle. ' || SQLERRM);
    END;
    
    
    --  Recorrido del Cursor.
    BEGIN
    
        FOR detail  IN DETAILS_LIST LOOP
        
            var_detail_rows := DETAILS_LIST%ROWCOUNT;
            
            --  Consulta del Consecutivo del Row Detail.
            BEGIN
            
                SELECT PAC_ALTA_FONDO_AHORRO_DET_SEQ.NEXTVAL
                  INTO var_detail_seq
                  FROM dual;
            
            EXCEPTION WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error al calcular el consecutivo del Row Detail. ' || SQLERRM);
            END;    
            
            var_body := '';
            var_body := var_body || var_reg_serv;                           --Campo 8 y Campo 9. 
            var_body := var_body || TRIM(TO_CHAR(var_detail_seq, '0000'));  --Campo 10: Consecutivo de Detalle, requerido. Longitud limitada a 9 posiciones y se considerará un valor numérico que sea consecutivo de 1 a n.
            var_body := var_body || RPAD(NVL(detail.RFC, ' '), 13, ' ');    --Campo 11.
            var_body := var_body || RPAD(detail.AP_PATERNO, 40, ' ');       --Campo 12.
            var_body := var_body || RPAD(detail.AP_MATERNO, 40, ' ');       --Campo 13.
            var_body := var_body || RPAD(detail.NOMBRES, 40, ' ');          --Campo 14.
            var_body := var_body || detail.CUENTA_BANCO;                    --Campo 15. 
            var_body := var_body || detail.CODIGO_BANCO;                    --Campo 16. 
            var_body := var_body || detail.CLABE_BANCO;                     --Campo 17. 
            var_body := var_body || detail.NUM_NOMINA;                      --Campo 18.
            var_body := var_body || TRIM(detail.NUM_SEGURO);                --Campo 19.    
            var_body := var_body || detail.CURP;                            --Campo 20.  
            var_body := var_body || detail.SEXO;                            --Campo 21.
            var_body := var_body || detail.VALOR_ALTA;                      --Campo 22.
            var_body := var_body || UPPER(detail.CALLE_NUMERO);             --Campo 23.
            var_body := var_body || UPPER(detail.COLONIA);                  --Campo 24.
            var_body := var_body || TRIM(detail.CODIGO_POSTAL);             --Campo 25.
            var_body := var_body || UPPER(detail.CIUDAD);                   --Campo 26.
            var_body := var_body || RPAD(' ', 20, ' ');                     --Campo 27: Población o Municipio. Longitud limitada a 20 posiciones.
            var_body := var_body || LPAD(' ', 60, ' ');                     --Campo 28: Nombre del Beneficiario 1. Longitud limitada a 60 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
            var_body := var_body || LPAD('0', 3, '0');                      --Campo 29: Porcentaje Benef 1. Longitud limitada a 3 posiciones. Debe ser representado con ceros hasta llegar a su límite de posiciones.
            var_body := var_body || LPAD(' ', 60, ' ');                     --Campo 30: Nombre del Beneficiario 2. Longitud limitada a 60 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
            var_body := var_body || LPAD('0', 3, '0');                      --Campo 31: Porcentaje Benef 2. Longitud limitada a 3 posiciones. Debe ser representado con ceros hasta llegar a su límite de posiciones.
            var_body := var_body || LPAD(' ', 60, ' ');                     --Campo 32: Nombre del Beneficiario 3. Longitud limitada a 60 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones. 
            var_body := var_body || LPAD('0', 3, '0');                      --Campo 33: Porcentaje Benef 3. Longitud limitada a 3 posiciones. Debe ser representado con ceros hasta llegar a su límite de posiciones.
            var_body := var_body || LPAD(' ', 60, ' ');                     --Campo 34: Nombre del Beneficiario 4. Longitud limitada a 60 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
            var_body := var_body || LPAD('0', 3, '0');                      --Campo 35: Porcentaje Benef 4. Longitud limitada a 3 posiciones. Debe ser representado con ceros hasta llegar a su límite de posiciones.
            var_body := var_body || RPAD(' ', 8, ' ');                      --Campo 36: Nivel2. Longitud limitada a 8 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
            var_body := var_body || RPAD(' ', 8, ' ');                      --Campo 37: Nivel3. Longitud limitada a 8 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
            var_body := var_body || RPAD(' ', 8, ' ');                      --Campo 38: Nivel4. Longitud limitada a 8 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
            var_body := var_body || RPAD(' ', 8, ' ');                      --Campo 39: Nivel5. Longitud limitada a 8 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
            var_body := var_body || RPAD(' ', 40, ' ');                     --Campo 40: Debe decir AP Paterno. Longitud limitada a 40 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
            var_body := var_body || RPAD(' ', 40, ' ');                     --Campo 41: Debe decir AP Materno	. Longitud limitada a 40 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
            var_body := var_body || RPAD(' ', 40, ' ');                     --Campo 42: Debe decir Nombre. Longitud limitada a 40 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
            var_body := var_body || RPAD(' ', 20, ' ');                     --Campo 43: Debe decir Número de Nómina. Longitud limitada a 40 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
            var_body := var_body || RPAD(' ', 31, ' ');                     --Campo 44: Uso Futuro. Longitud limitada a 31 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
            
            dbms_output.put_line(var_body);
            pac_append_to_file(var_path, var_file_name, var_body);
        
        END LOOP;
    
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error al Recorrer la Lista de Empleados. ' || SQLERRM);
    END;
    
    
--    --Campos del 36 al 44, por verificar.
--    BEGIN
--    
--        var_body := '';
--        var_body := var_body || RPAD(' ', 8, ' ') || CHR(10);        --Campo 36: Nivel2. Longitud limitada a 8 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
--        var_body := var_body || RPAD(' ', 8, ' ') || CHR(10);        --Campo 37: Nivel3. Longitud limitada a 8 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
--        var_body := var_body || RPAD(' ', 8, ' ') || CHR(10);        --Campo 38: Nivel4. Longitud limitada a 8 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
--        var_body := var_body || RPAD(' ', 8, ' ');                   --Campo 39: Nivel5. Longitud limitada a 8 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
--        var_body := var_body || RPAD('AP PATERNO', 40, ' ');         --Campo 40: Debe decir AP Paterno. Longitud limitada a 40 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
--        var_body := var_body || RPAD('AP MATERNO', 40, ' ');         --Campo 41: Debe decir AP Materno	. Longitud limitada a 40 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
--        var_body := var_body || RPAD('NOMBRE', 40, ' ');             --Campo 42: Debe decir Nombre. Longitud limitada a 40 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
--        var_body := var_body || RPAD('NUMERO DE NOMINA', 40, ' ');   --Campo 43: Debe decir Número de Nómina. Longitud limitada a 40 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
--        var_body := var_body || RPAD(' ', 31, ' ');                  --Campo 44: Uso Futuro. Longitud limitada a 31 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
--        
--        dbms_output.put_line(var_body);   
--        pac_append_to_file(var_path, var_file_name, var_body);
--    
--    EXCEPTION WHEN OTHERS THEN
--        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error al Crear del campo 36 al campo 44. ' || SQLERRM);
--    END;

    
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Creando Footer del Documento de Altas de Fondo de Ahorro . . .');
    --  Creación del Footer del Archivo de Altas de Fondo de Ahorro. 
    BEGIN
    
        SELECT 
            (SELECT
                TRIM(TO_CHAR(meaning, '00'))
               FROM FND_LOOKUP_VALUES
              WHERE lookup_type = 'XXCALV_APORT_FONDO_AHORRO'
                AND LANGUAGE = userenv('LANG')
                AND lookup_code = 'TIPO_REG2') ||                   --Campo 45: Tipo de Registro= '09',  requerido. Longitud limitada a 2 posiciones.
            (SELECT 
                TRIM(TO_CHAR(REPLACE(meaning, '=ALTA', ''), '00'))
               FROM FND_LOOKUP_VALUES
              WHERE lookup_type = 'XXCALV_APORT_FONDO_AHORRO'
                AND LANGUAGE = userenv('LANG')
                AND lookup_code = 'ID_SERV_ALT') ||                 --Campo 46: Identificador de Servicio = '01',  requerido. Longitud limitada a 2 posiciones.
            (TRIM(TO_CHAR(SYSDATE, 'RRRRMMDD'))) ||                 --Campo 47: Fecha de Envío de Información, requerido. Longitud limitada a 8 posiciones. Formato AAAAMMDD
            (TRIM(TO_CHAR(var_exe_seq, '000'))) ||                  --Campo 48: Consecutivo del día, requerido. Longitud limitada a 3 posiciones.
            (TRIM(TO_CHAR(var_detail_rows, '00000000'))) ||         --Campo 49: Total de Registros de Detalle,  requerido. Longitud limitada a 8 posiciones.
            (RPAD(' ', 777, ' '))                                   --Campo 50: Uso Futuro. Longitud limitada a 777 posiciones. Debe ser representado con espacios en blanco hasta llegar a su límite de posiciones.
          INTO var_footer
          FROM dual;
          
        dbms_output.put_line(var_footer);
        pac_append_to_file(var_path, var_file_name, var_footer);
    
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error al Crear el Footer. ' || SQLERRM);
    END;
    
    
    --Finalización del Procedimiento.
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Archivo creado!');

END;

 