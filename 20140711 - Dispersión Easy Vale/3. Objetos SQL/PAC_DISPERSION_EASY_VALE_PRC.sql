CREATE OR REPLACE PROCEDURE APPS.PAC_DISPERSION_EASY_VALE_PRC(
                P_ERRBUF    OUT NOCOPY  VARCHAR2,
                P_RETCODE   OUT NOCOPY  VARCHAR2,
                P_PERIOD_TYPE           VARCHAR2,
                P_PAYROLL_ID            VARCHAR2,
                P_CONSOLIDATION_ID      VARCHAR2,
                P_START_DATE            VARCHAR2,
                P_END_DATE              VARCHAR2)
AS

    var_start_date  DATE := TRUNC(TO_DATE(P_START_DATE,'RRRR/MM/DD HH24:MI:SS'));
    var_end_date    DATE := TRUNC(TO_DATE(P_END_DATE,'RRRR/MM/DD HH24:MI:SS'));
    
    var_path        VARCHAR2(250) := 'DISPERSION_EASY_VALE';
    var_file_name   VARCHAR2(250) := 'DISPERSION_EASY_VALE.xls';
    var_file        UTL_FILE.FILE_TYPE;
    
    CURSOR DETAIL_LIST IS
    SELECT DISTINCT
           POPM.PMETH_INFORMATION1          AS  ID_EMPRESA,
           TO_NUMBER(PAPF.EMPLOYEE_NUMBER)  AS  NUM_EMPLEADO,
           PPP.VALUE                        AS  IMPORTE,
           FLV.MEANING                      AS  BANCO
      FROM PAY_PAYROLLS_F               PPF,
           PAY_PAYROLL_ACTIONS          PPA,
           PER_ALL_ASSIGNMENTS_F        PAAF,
           PAY_ASSIGNMENT_ACTIONS       PAA,
           PAY_PRE_PAYMENTS             PPP,
           PAY_ORG_PAYMENT_METHODS_F    POPM,
           PER_ALL_PEOPLE_F             PAPF,
           PAY_EXTERNAL_ACCOUNTS        PEA,
           FND_LOOKUP_VALUES            FLV
     WHERE PPF.PAYROLL_ID = NVL(P_PAYROLL_ID, PPF.PAYROLL_ID)
       AND PPF.PAYROLL_ID = PPA.PAYROLL_ID
       AND PPA.ACTION_TYPE IN('P', 'U')
       AND PPA.CONSOLIDATION_SET_ID = NVL(P_CONSOLIDATION_ID, PPA.CONSOLIDATION_SET_ID)
       AND PPA.START_DATE >= var_start_date 
       AND PPA.EFFECTIVE_DATE <= var_end_date
       AND APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = P_PERIOD_TYPE
       AND PPF.PAYROLL_ID = PAAF.PAYROLL_ID
       AND PAAF.ASSIGNMENT_ID = PAA.ASSIGNMENT_ID
       AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
       AND PPA.EFFECTIVE_DATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
       AND PPP.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
       AND PPP.ORG_PAYMENT_METHOD_ID = POPM.ORG_PAYMENT_METHOD_ID
       AND POPM.ORG_PAYMENT_METHOD_NAME LIKE'%EASYVALE%'
       AND SUBSTR(POPM.ORG_PAYMENT_METHOD_NAME, 1, 2) = SUBSTR(PPF.PAYROLL_NAME, 1, 2)
       AND POPM.PMETH_INFORMATION1 IS NOT NULL
       AND PAPF.PERSON_ID = PAAF.PERSON_ID
       AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE AND NVL(PAAF.EFFECTIVE_END_DATE, SYSDATE +1)
       AND PAAF.PRIMARY_FLAG = 'Y'
       AND PAAF.ASSIGNMENT_TYPE = 'E'
       AND PAPF.CURRENT_EMPLOYEE_FLAG = 'Y'
       AND POPM.EXTERNAL_ACCOUNT_ID = PEA.EXTERNAL_ACCOUNT_ID
       AND FLV.LOOKUP_TYPE = 'MX_BANK'
       AND FLV.LANGUAGE = USERENV('LANG')
       AND FLV.LOOKUP_CODE = PEA.SEGMENT1
     ORDER BY 2 ASC;
    
     --Definición de subprogramas para la manipulación del Archivo Excel.
    PROCEDURE OPEN_FILE IS
    BEGIN
        UTL_FILE.FREMOVE(var_path, var_file_name);
        var_file := UTL_FILE.FOPEN(var_path, var_file_name, 'A', 20000);
    EXCEPTION 
        WHEN UTL_FILE.INVALID_OPERATION THEN
            var_file := UTL_FILE.FOPEN(var_path, var_file_name, 'A', 20000);    
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
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_PERIOD_TYPE : '       || P_PERIOD_TYPE);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_PAYROLL_ID : '        || P_PAYROLL_ID);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_CONSOLIDATION_ID : '  || P_CONSOLIDATION_ID);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_START_DATE : '        || P_START_DATE || ' - '   || var_start_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_END_DATE : '          || P_END_DATE || ' - '     || var_end_date);
    
    dbms_output.put_line('P_PERIOD_TYPE : '         || P_PERIOD_TYPE);
    dbms_output.put_line('P_PAYROLL_ID : '          || P_PAYROLL_ID);
    dbms_output.put_line('P_CONSOLIDATION_ID : '    || P_CONSOLIDATION_ID);
    dbms_output.put_line('P_START_DATE : '          || P_START_DATE || ' - '    || var_start_date);
    dbms_output.put_line('P_END_DATE : '            || P_END_DATE || ' - '      || var_end_date);

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Creando Documento. . .');
    dbms_output.put_line('Creando Documento. . .');
    
    
    BEGIN
    
        OPEN_FILE();
            START_WORKBOOK();
                START_WORKSHEET('Hoja 1');
                
                    ADD_ROW();
                        ADD_CELL('ID EMPRESA',      'String');--Nueva solicitud  11.09.2014
                        ADD_CELL('NUMERO EMPLEADO', 'String');--Nueva solicitud  11.09.2014
                        ADD_CELL('IMPORTE',         'String');--Nueva solicitud  11.09.2014
                        ADD_CELL('PRODUCTO',        'String');--Nueva solicitud  11.09.2014
                    CLOSE_ROW();
                
                    BEGIN
                    
                        FOR DETAIL IN DETAIL_LIST LOOP
                        
                            ADD_ROW();
                                ADD_CELL(DETAIL.ID_EMPRESA, 'String');      --Campo 1: ID EMPRESA, requerido.
                                ADD_CELL(DETAIL.NUM_EMPLEADO, 'String');    --Campo 2: NUMERO EMPLEADO, requerido. 
                                ADD_CELL(DETAIL.IMPORTE, 'String');         --Campo 3: IMPORTE, requerido. 
                                ADD_CELL(DETAIL.BANCO, 'String');           --Campo 4: PRODUCTO, requerido. 
                            CLOSE_ROW();
                            
                             FND_FILE.PUT_LINE(FND_FILE.LOG, 'Agregando Empleado : ' || DETAIL.NUM_EMPLEADO);
                            dbms_output.put_line('Agregando Empleado : ' || DETAIL.NUM_EMPLEADO);
                        
                        END LOOP;
                    
                    EXCEPTION WHEN OTHERS THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Recorrer la Lista de Detalles del Cuerpo del Documento. ' || SQLERRM);
                        dbms_output.put_line('**Error al Recorrer la Lista de Detalles del Cuerpo del Documento. ' || SQLERRM);
                    END;
                
                END_WORKSHEET();
            END_WORKBOOK();
        CLOSE_FILE();
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Creando los Registros del Documento. . .');
        dbms_output.put_line('Creando los Registros del Documento. . .');
    
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Crear el Body del Documento Excel. ' || SQLERRM);
        dbms_output.put_line('**Error al Crear el Body del Documento Excel.' || SQLERRM);
    END;
    
    
    --Mensaje de Finalización.
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Archivo creado!');
    dbms_output.put_line('Archivo creado!');

EXCEPTION WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Ejecutar el Procedimiento PAC_DISPERSION_EASY_VALE_PRC. ' || SQLERRM);
    dbms_output.put_line('**Error al Ejecutar el Procedimiento PAC_DISPERSION_EASY_VALE_PRC. ' || SQLERRM);
END;