CREATE OR REPLACE PROCEDURE APPS.PAC_CAT_EMPLEADO_PRC(
                P_ERRBUF    OUT NOCOPY  VARCHAR2,
                P_RETCODE   OUT NOCOPY  VARCHAR2,
                P_EMPRESA               VARCHAR2,
                P_PERIODO               VARCHAR2,
                P_NOMINA                VARCHAR2,
                P_ESTATUS               VARCHAR2,
                P_ANO                   VARCHAR2)
IS
    
    var_path        VARCHAR2(250) := 'CAT_EMPLEADOS';
    var_file_name   VARCHAR2(250) := 'CAT_EMPLEADOS.csv';
    var_file        UTL_FILE.FILE_TYPE;
    
    var_data                        VARCHAR2(30000);
    
    CURSOR DETAIL_LIST IS
    SELECT DECODE (empresa, p_empresa, empresa, 'TODAS') compania2,
       DECODE (periodo, p_periodo, periodo, 'TODOS') periodo2,
       DECODE (nomina,p_nomina, nomina, 'TODAS') nomina2,
       DECODE (estatus,UPPER (p_estatus), estatus,
               'CATALOGOS DE EMPLEADOS REGISTRADOS Y CANCELADOS'
              ) estatus2,
       DECODE (ano, p_ano, ano, 'TODOS') ano2, 
       empresa, nomina, id_empleado,
       nombre_completo, apellido_paterno, apellido_materno, nombres,
       segundo_nombre, calle, num_ext, num_int, colonia,
       delegacion_o_municipio, localidad_o_poblacion, estado, pais,
       codigo_postal, telefono, sexo, nacionalidad, lug_nacimiento, fecha_nac,
       nivel_de_estudios, t_contrato, terminacion, n_gerencia, gerencia,
       n_area, area, num_departamento, departamento, puesto, trabajo, turno,
       sind, rfc, curp, nss, delegacion_imss, sub_delegacion_imss,
       uni_med_fam, seguro, fecha_alta_cia, fecha_alta_imss,
       decode ( nomina,'02_QUIN - EJEC CONFIANZA', ' ',
                       '11_QUIN - EJEC CONFIANZA', ' ',
                         sueldo_base) sueldo_base,
        decode ( nomina,'02_QUIN - EJEC CONFIANZA', ' ',
                        '11_QUIN - EJEC CONFIANZA', ' ',
                                            s_d_i) s_d_i,
       reg_patronal, periodo, bono_despensa, afore, correo_e,
       estado_civil, regimen_matrimonial, estatus, fecha_baja, unic_ingreso,
       no_cred_inf, fecha_cred_inf, tipo_descuento_inf, valor_descuento_inf,
       saldo_inicial_inf, saldo_actual_inf, no_cuenta_despensa,
       no_targeta_desp,tp_pago_despensa, metodo_pago_desp, cuenta_pago, banco_pago, targeta_pago,
       tipo_pago, cuenta_pension_a,banco_pension, tipo_pago_pension,porcentaje_pension, monto_pension
  FROM pac_employee_act_v 
 WHERE 1 = 1
   AND empresa = NVL (p_empresa, empresa)
   AND periodo = NVL (p_periodo, periodo)
   AND nomina = NVL (p_nomina, nomina)
   AND estatus = NVL (UPPER (p_estatus), estatus)
    AND ano = NVL (p_ano, ano);
    
    
    TYPE    DETAILS IS TABLE OF DETAIL_LIST%ROWTYPE INDEX BY PLS_INTEGER;
    
    DETAIL  DETAILS;
BEGIN
     

            BEGIN 
                EXECUTE IMMEDIATE 'ALTER SESSION SET nls_language =''LATIN AMERICAN SPANISH''';
                INSERT INTO fnd_sessions (SESSION_ID, EFFECTIVE_DATE)
                VALUES (USERENV ('SESSIONID'), TRUNC (SYSDATE));
            END; 
            
        dbms_output.put_line('P_EMPRESA : '  || P_EMPRESA);
        dbms_output.put_line('P_PERIODO : '  || P_PERIODO);
        dbms_output.put_line('P_NOMINA : '   || P_NOMINA);
        dbms_output.put_line('P_ESTATUS : '  || P_ESTATUS);
        dbms_output.put_line('P_ANO : '      || P_ANO);
        
        fnd_file.put_line(fnd_file.log, 'P_EMPRESA : '  || p_empresa);
        fnd_file.put_line(fnd_file.log, 'P_PERIODO : '  || p_periodo);
        fnd_file.put_line(fnd_file.log, 'P_NOMINA : '   || p_nomina);
        fnd_file.put_line(fnd_file.log, 'P_ESTATUS : '  || p_estatus);
        fnd_file.put_line(fnd_file.log, 'P_ANO : '      || p_ano);
        
        
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
   
    BEGIN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Creando los Registros del Documento. . .');
        dbms_output.put_line('Creando los Registros del Documento. . .');
    
           UTL_FILE.PUT(var_file, 'EMPRESA:      '|| P_EMPRESA);
           UTL_FILE.PUT_LINE(var_file, '');
           UTL_FILE.PUT(var_file, 'PERIODO:       '|| P_PERIODO);
           UTL_FILE.PUT_LINE(var_file, '');
           UTL_FILE.PUT(var_file, 'NOMINA:        '|| P_NOMINA);
           UTL_FILE.PUT_LINE(var_file, '');
           UTL_FILE.PUT(var_file, 'ESTATUS:   '|| P_ESTATUS);
           UTL_FILE.PUT_LINE(var_file, '');
           UTL_FILE.PUT(var_file, 'AÒO:              '|| P_ANO);
           UTL_FILE.PUT_LINE(var_file, '');
           UTL_FILE.PUT_LINE(var_file, '');
           UTL_FILE.PUT_LINE(var_file, '');    
            EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('**Error al Generar el encabezado del documento. ' || SQLERRM);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Generar el encabezado del documento. ' || SQLERRM);
    END;
        
        BEGIN
               
            var_data := 'EMPRESA,'||
                        'NOMINA,'||
                        'NO EMPLEADO,'||
                        'NOMBRE COMPLETO,'||
                        'APELLIDO PATERNO,'||
                        'APELLIDO MATERNO,'||
                        'NOMBRES,'||
                        'SEGUNDO NOMBRE,'||
                        'CALLE,'||
                        'NUM EXT,'||
                        'NUM INT,'||
                        'COLONIA,'||
                        'DELEGACION O MUNICIPIO,'||
                        'LOCALIDAD O POBLACION,'||
                        'ESTADO,'||
                        'PAIS,'||
                        'CODIGO POSTAL,'||
                        'TELEFONO,'||
                        'SEXO,'||
                        'NACIONALIDAD,'||
                        'LUGAR DE NACIMIENTO,'||
                        'FECHA DE NACIMIENTO,'||
                        'NIVEL DE ESTUDIOS,'||
                        'TIPO DE CONTRATO,'||
                        'TERMINACION,'||
                        'NO DE GERENCIA,'||
                        'GERENCIA,'||
                        'NO DE AREA,'||
                        'AREA,'||
                        'NO DE DEPARTAMENTO,'||
                        'DEPARTAMENTO,'||
                        'PUESTO,'||
                        'TRABAJO,'||
                        'TURNO,'||
                        'SINDICATO,'||
                        'RFC,'||
                        'CURP,'||
                        'NSS,'||
                        'DELEGACION IMSS,'||
                        'SUBDELEGACION IMSS,'||
                        'UNIDAD MED FAM,'||
                        'SEGURO,'||
                        'FECHA ALTA CIA,'||
                        'FECHA ALTA IMSS,'||
                        'SUELDO BASE,'||
                        'S D I,'||
                        'REG PATRONAL,'||
                        'PERIODO,'||
                        'BONO DESPENSA,'||
                        'AFORE,'||
                        'CORREO E,'||
                        'ESTADO CIVIL,'||
                        'REGIMEN MATRIMONIAL,'||
                        'ESTATUS,'||
                        'FECHA BAJA,'||
                        'UNICO INGRESO,'||
                        'NO CREDITO INFONAVIT,'||
                        'FECHA DE CREDITO INFONAVIT,'||
                        'TIPO DE DESCUENTO INFONAVIT,'||
                        'VALOR DE DESCUENTO INFONAVIT,'||
                        'SALDO INICIAL INFONAVIT,'||
                        'SALDO ACTUAL INFONAVIT,'||
                        'NO CUENTA DE DESPENSA,'||
                        'NO TARJETA DE DESPENSA,'||
                        'TIPO PAGO DESPENSA,'||
                        'METODO DE PAGO DE DESPENSA,'||
                        'CUENTA DE PAGO,'||
                        'BANCO DE PAGO,'||
                        'TARJETA BANCARIA,' ||
                        'TIPO DE PAGO SUELDO,'||
                        'CUENTA_PENSION_A ,'||
                        'BANCO_PENSION,'||
                        'TIPO_PAGO_PENSION,'|| 
                        'PORCENTAJE DE PENSION,'||
                        'MONTO DE PENSION,';
                          UTL_FILE.PUT_LINE(var_file, var_data);
    
    EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('**Error al Generar el encabezado de cuadro basico. ' || SQLERRM);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Generar el encabezado de cuadro basico. ' || SQLERRM);
    END;
           
                      
                                            
    BEGIN
    
        OPEN DETAIL_LIST;
        
            LOOP
        
            FETCH DETAIL_LIST 
                  BULK COLLECT INTO DETAIL LIMIT 500;
            
            EXIT WHEN DETAIL.COUNT = 0;
                  
            FOR rowIndex IN 1 .. DETAIL.COUNT
                        LOOP
                        
                            var_data := '';
                            var_data :=               DETAIL(rowIndex).EMPRESA             || ',' ||
                                                    DETAIL(rowIndex).NOMINA              || ',' ||
                                                    DETAIL(rowIndex).ID_EMPLEADO         || ',' ||
                                                    DETAIL(rowIndex).NOMBRE_COMPLETO     || ',' ||
                                                    DETAIL(rowIndex).APELLIDO_PATERNO    || ',' ||
                                                    DETAIL(rowIndex).APELLIDO_MATERNO    || ',' ||
                                                    DETAIL(rowIndex).NOMBRES             || ',' ||
                                                    DETAIL(rowIndex).SEGUNDO_NOMBRE             || ',' ||
                                                    DETAIL(rowIndex).CALLE                      || ',' ||
                                                    DETAIL(rowIndex).NUM_EXT                    || ',' ||
                                                    DETAIL(rowIndex).NUM_INT                    || ',' ||
                                                    DETAIL(rowIndex).COLONIA                    || ',' ||
                                                    DETAIL(rowIndex).DELEGACION_O_MUNICIPIO     || ',' ||
                                                    DETAIL(rowIndex).LOCALIDAD_O_POBLACION      || ',' ||
                                                    DETAIL(rowIndex).ESTADO                     || ',' ||
                                                    DETAIL(rowIndex).PAIS                       || ',' ||
                                                    DETAIL(rowIndex).CODIGO_POSTAL              || ',' ||
                                                    DETAIL(rowIndex).TELEFONO                   || ',' ||
                                                    DETAIL(rowIndex).SEXO                       || ',' ||
                                                    DETAIL(rowIndex).NACIONALIDAD               || ',' ||
                                                    DETAIL(rowIndex).LUG_NACIMIENTO             || ',' ||
                                                    DETAIL(rowIndex).FECHA_NAC                  || ',' ||
                                                    DETAIL(rowIndex).NIVEL_DE_ESTUDIOS          || ',' ||
                                                    DETAIL(rowIndex).T_CONTRATO                 || ',' ||
                                                    DETAIL(rowIndex).TERMINACION                || ',' ||
                                                    DETAIL(rowIndex).N_GERENCIA                 || ',' ||
                                                    DETAIL(rowIndex).GERENCIA                   || ',' ||
                                                    DETAIL(rowIndex).N_AREA                     || ',' ||
                                                    DETAIL(rowIndex).AREA                       || ',' ||
                                                    DETAIL(rowIndex).NUM_DEPARTAMENTO           || ',' ||
                                                    DETAIL(rowIndex).DEPARTAMENTO               || ',' ||
                                                    DETAIL(rowIndex).PUESTO                     || ',' ||
                                                    DETAIL(rowIndex).TRABAJO                    || ',' ||
                                                    DETAIL(rowIndex).TURNO                      || ',' ||
                                                    DETAIL(rowIndex).SIND                       || ',' ||
                                                    DETAIL(rowIndex).RFC                        || ',' ||
                                                    DETAIL(rowIndex).CURP                       || ',' ||
                                                    DETAIL(rowIndex).NSS                        || ',' ||
                                                    DETAIL(rowIndex).DELEGACION_IMSS            || ',' ||
                                                    DETAIL(rowIndex).SUB_DELEGACION_IMSS        || ',' ||
                                                    DETAIL(rowIndex).UNI_MED_FAM                || ',' ||
                                                    DETAIL(rowIndex).SEGURO                     || ',' ||
                                                    DETAIL(rowIndex).FECHA_ALTA_CIA             || ',' ||
                                                    DETAIL(rowIndex).FECHA_ALTA_IMSS            || ',' ||
                                                    DETAIL(rowIndex).SUELDO_BASE                || ',' ||
                                                    DETAIL(rowIndex).S_D_I                      || ',' ||
                                                    DETAIL(rowIndex).REG_PATRONAL               || ',' ||
                                                    DETAIL(rowIndex).PERIODO                    || ',' ||
                                                    DETAIL(rowIndex).BONO_DESPENSA              || ',' ||
                                                    DETAIL(rowIndex).AFORE                      || ',' ||
                                                    DETAIL(rowIndex).CORREO_E                   || ',' ||
                                                    DETAIL(rowIndex).ESTADO_CIVIL               || ',' ||
                                                    DETAIL(rowIndex).REGIMEN_MATRIMONIAL        || ',' ||
                                                    DETAIL(rowIndex).ESTATUS                    || ',' ||
                                                    DETAIL(rowIndex).FECHA_BAJA                 || ',' ||
                                                    DETAIL(rowIndex).UNIC_INGRESO               || ',' ||
                                                    DETAIL(rowIndex).NO_CRED_INF                || ',' ||
                                                    DETAIL(rowIndex).FECHA_CRED_INF             || ',' ||
                                                    DETAIL(rowIndex).TIPO_DESCUENTO_INF         || ',' ||
                                                    DETAIL(rowIndex).VALOR_DESCUENTO_INF        || ',' ||
                                                    DETAIL(rowIndex).SALDO_INICIAL_INF          || ',' ||
                                                    DETAIL(rowIndex).SALDO_ACTUAL_INF           || ',' ||
                                                    DETAIL(rowIndex).NO_CUENTA_DESPENSA         || ',' ||
                                                    DETAIL(rowIndex).NO_TARGETA_DESP            || ',' ||
                                                    DETAIL(rowIndex).TP_PAGO_DESPENSA           || ',' ||
                                                    DETAIL(rowIndex).METODO_PAGO_DESP           || ',' ||
                                                    DETAIL(rowIndex).CUENTA_PAGO                || ',' ||
                                                    DETAIL(rowIndex).BANCO_PAGO                 || ',' ||
                                                    DETAIL(rowIndex).TARGETA_PAGO               || ',' ||
                                                    DETAIL(rowIndex).TIPO_PAGO                  || ',' ||
                                                    DETAIL(rowIndex).CUENTA_PENSION_A           || ',' ||
                                                    DETAIL(rowIndex).BANCO_PENSION              || ',' ||
                                                    DETAIL(rowIndex).TIPO_PAGO_PENSION          || ',' ||               
                                                    DETAIL(rowIndex).PORCENTAJE_PENSION         || ',' ||
                                                    DETAIL(rowIndex).MONTO_PENSION              || ',' ;
                                                    
                                                    UTL_FILE.PUT_LINE(var_file, var_data);
                                            
                                 
                        END LOOP;        
        
        END LOOP;
        
        CLOSE DETAIL_LIST;
                    

    begin
        ROLLBACK;
    end;

EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('**Error al Generar los registros de detalle del documento. ' || SQLERRM);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Generar los registros de detalle del documento. ' || SQLERRM);
    END;
    
EXCEPTION WHEN OTHERS THEN
    dbms_output.put_line('**Error al Ejecutar el Procedure Cuadro Basico. ' || SQLERRM);
    FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Ejecutar el Procedure Cuadro Basico. ' || SQLERRM);
END;
/