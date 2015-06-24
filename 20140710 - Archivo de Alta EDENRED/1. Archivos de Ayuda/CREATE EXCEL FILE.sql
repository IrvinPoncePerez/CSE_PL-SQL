DECLARE
  v_fh        UTL_FILE.FILE_TYPE;
  v_dir       VARCHAR2(30) := 'TEST_IRVIN';
  v_file      VARCHAR2(30) := 'myfile.xls';
  PROCEDURE run_query(p_sql IN VARCHAR2) IS
    v_v_val     VARCHAR2(4000);
    v_n_val     NUMBER;
    v_d_val     DATE;
    v_ret       NUMBER;
    c           NUMBER;
    d           NUMBER;
    col_cnt     INTEGER;
    f           BOOLEAN;
    rec_tab     DBMS_SQL.DESC_TAB;
    col_num     NUMBER;
  BEGIN
    c := DBMS_SQL.OPEN_CURSOR;
    -- parse the SQL statement
    DBMS_SQL.PARSE(c, p_sql, DBMS_SQL.NATIVE);
    -- start execution of the SQL statement
    d := DBMS_SQL.EXECUTE(c);
    -- get a description of the returned columns
    DBMS_SQL.DESCRIBE_COLUMNS(c, col_cnt, rec_tab);
    -- bind variables to columns
    FOR j in 1..col_cnt
    LOOP
      CASE rec_tab(j).col_type
        WHEN 1 THEN DBMS_SQL.DEFINE_COLUMN(c,j,v_v_val,4000);
        WHEN 2 THEN DBMS_SQL.DEFINE_COLUMN(c,j,v_n_val);
        WHEN 12 THEN DBMS_SQL.DEFINE_COLUMN(c,j,v_d_val);
      ELSE
        DBMS_SQL.DEFINE_COLUMN(c,j,v_v_val,4000);
      END CASE;
    END LOOP;
    -- Output the column headers
    UTL_FILE.PUT_LINE(v_fh,'<ss:Row>');
    FOR j in 1..col_cnt
    LOOP
      UTL_FILE.PUT_LINE(v_fh,'<ss:Cell>');
      UTL_FILE.PUT_LINE(v_fh,'<ss:Data ss:Type="String">'||rec_tab(j).col_name||'</ss:Data>');
      UTL_FILE.PUT_LINE(v_fh,'</ss:Cell>');
    END LOOP;
    UTL_FILE.PUT_LINE(v_fh,'</ss:Row>');
    -- Output the data
    LOOP
      v_ret := DBMS_SQL.FETCH_ROWS(c);
      EXIT WHEN v_ret = 0;
      UTL_FILE.PUT_LINE(v_fh,'<ss:Row>');
      FOR j in 1..col_cnt
      LOOP
        CASE rec_tab(j).col_type
          WHEN 1 THEN DBMS_SQL.COLUMN_VALUE(c,j,v_v_val);
                      UTL_FILE.PUT_LINE(v_fh,'<ss:Cell>');
                      UTL_FILE.PUT_LINE(v_fh,'<ss:Data ss:Type="String">'||v_v_val||'</ss:Data>');
                      UTL_FILE.PUT_LINE(v_fh,'</ss:Cell>');
          WHEN 2 THEN DBMS_SQL.COLUMN_VALUE(c,j,v_n_val);
                      UTL_FILE.PUT_LINE(v_fh,'<ss:Cell>');
                      UTL_FILE.PUT_LINE(v_fh,'<ss:Data ss:Type="Number">'||to_char(v_n_val)||'</ss:Data>');
                      UTL_FILE.PUT_LINE(v_fh,'</ss:Cell>');
          WHEN 12 THEN DBMS_SQL.COLUMN_VALUE(c,j,v_d_val);
                      UTL_FILE.PUT_LINE(v_fh,'<ss:Cell ss:StyleID="OracleDate">');
                      UTL_FILE.PUT_LINE(v_fh,'<ss:Data ss:Type="DateTime">'||to_char(v_d_val,'YYYY-MM-DD"T"HH24:MI:SS')||'</ss:Data>');
                      UTL_FILE.PUT_LINE(v_fh,'</ss:Cell>');
        ELSE
          DBMS_SQL.COLUMN_VALUE(c,j,v_v_val);
          UTL_FILE.PUT_LINE(v_fh,'<ss:Cell>');
          UTL_FILE.PUT_LINE(v_fh,'<ss:Data ss:Type="String">'||v_v_val||'</ss:Data>');
          UTL_FILE.PUT_LINE(v_fh,'</ss:Cell>');
        END CASE;
      END LOOP;
      UTL_FILE.PUT_LINE(v_fh,'</ss:Row>');
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(c);
  END;
  --
  PROCEDURE start_workbook IS
  BEGIN
    UTL_FILE.PUT_LINE(v_fh,'<?xml version="1.0"?>');
    UTL_FILE.PUT_LINE(v_fh,'<ss:Workbook xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">');
  END;
  PROCEDURE end_workbook IS
  BEGIN
    UTL_FILE.PUT_LINE(v_fh,'</ss:Workbook>');
  END;
  --
  PROCEDURE start_worksheet(p_sheetname IN VARCHAR2) IS
  BEGIN
    UTL_FILE.PUT_LINE(v_fh,'<ss:Worksheet ss:Name="'||p_sheetname||'">');
    UTL_FILE.PUT_LINE(v_fh,'<ss:Table>');
  END;
  PROCEDURE end_worksheet IS
  BEGIN
    UTL_FILE.PUT_LINE(v_fh,'</ss:Table>');
    UTL_FILE.PUT_LINE(v_fh,'</ss:Worksheet>');
  END;
  --
  PROCEDURE set_date_style IS
  BEGIN
    UTL_FILE.PUT_LINE(v_fh,'<ss:Styles>');
    UTL_FILE.PUT_LINE(v_fh,'<ss:Style ss:ID="OracleDate">');
    UTL_FILE.PUT_LINE(v_fh,'<ss:NumberFormat ss:Format="dd/mm/yyyy\ hh:mm:ss"/>');
    UTL_FILE.PUT_LINE(v_fh,'</ss:Style>');
    UTL_FILE.PUT_LINE(v_fh,'</ss:Styles>');
  END;
BEGIN
  v_fh := UTL_FILE.FOPEN(upper(v_dir),v_file,'w',32767);
  start_workbook;
  set_date_style;
  start_worksheet('EMP');
  run_query('
              SELECT        
               DECODE(EMPRESA,''El CALVARIOS SERVICIOS SA DE CV'',''TODAS'' )     COMPANIA2,
               DECODE(PERIODO,'''',PERIODO,''TODOS'' )     PERIODO2,
               DECODE(NOMINA,'''', NOMINA,''TODAS'' )       NOMINA2,
               DECODE(ESTATUS,UPPER(''''), ESTATUS,''CATALOGOS DE EMPLEADOS REGISTRADOS Y CANCELADOS'') ESTATUS2,
               DECODE(ANO,''2014'', ANO,''TODOS'')                 ANO2,
               EMPRESA, 
               NOMINA,
               PERIODO, 
               ID_EMPLEADO, 
               NOMBRE_COMPLETO,
               APELLIDO_PATERNO, 
               APELLIDO_MATERNO, 
               NOMBRES, 
               SEGUNDO_NOMBRE, 
               CALLE,
               NUM_EXT, 
               NUM_INT, 
               COLONIA, 
               DELEGACION_O_MUNICIPIO,
               LOCALIDAD_O_POBLACION, 
               ESTADO, 
               PAIS, 
               CODIGO_POSTAL, 
               TELEFONO, 
               SEXO,
               NATIONALIDAD, 
               LUG_NACIMIENTO, 
               FECHA_NAC, 
               NIVEL_DE_ESTUDIOS, 
               T_CONTRATO,
               TERMINACION, 
               NUM_GERENCIA, 
               GERENCIA, 
               NUM_DEPARTAMENTO,
               DEPARTAMENTO, 
               PUESTO, 
               TRABAJO, 
               TURNO, 
               SIND, 
               RFC, 
               CURP, 
               NSS,
               DELEGACION_IMSS, 
               SUB_DELEGACIoN_IMSS, 
               UNI_MED_FAM, 
               REG_PATRONAL,
               FECHA_ALTA_CIA, 
               FECHA_ALTA_IMSS, 
               SUELDO_BASE, 
               S_D_I, 
               SEGURO, 
               BONO_DESPENSA,  
               UNIC_INGRESO,
               FORMA_PAGO_DESPENSA, 
               CTA_BONO_DESP, 
               NUM_TARJETA_DESPENSA,
               TIPO_PAGO_SDO,  
               BANCO_DEPOSITO, 
               CUENTA_BANCARIA, 
               BANKO,
               AFORE,
               CREDITO_INFONAVIT,
               FECHA_CREDITO, 
               TIPOC, 
               VALOR_DESCUENTO, 
               SALDO_INICIAL, 
               SALDO_ACTUAL,
               PORCENTAJE,
               MONTO,     
               CORREO_E, 
               ESTADO_CIVIL, 
               REGIMEN_MATRIMONIAL,
               ESTATUS,
               FECHA_BAJA, 
               AREA
              FROM PAC_EMPLOYEE_V
              WHERE 1=1
                 AND EMPRESA = NVL (''El CALVARIOS SERVICIOS SA DE CV'',EMPRESA)
                 AND PERIODO = NVL ('''', PERIODO)
                 AND NOMINA = NVL ('''', NOMINA)
                 AND ESTATUS = NVL ('''', ESTATUS)
                 AND ANO = NVL (''2014'', ANO)
              ');
  end_worksheet;
--  start_worksheet('DEPT');
--  run_query('SELECT *
--               FROM FND_LOOKUP_VALUES
--              WHERE lookup_type = ''XXCALV_ALTA_EDENRED''');
--  end_worksheet;
  end_workbook;
  UTL_FILE.FCLOSE(v_fh);
END;