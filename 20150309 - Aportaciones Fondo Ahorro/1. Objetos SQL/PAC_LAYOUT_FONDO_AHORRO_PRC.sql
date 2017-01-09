CREATE OR REPLACE PROCEDURE APPS.PAC_LAYOUT_FONDO_AHORRO_PRC (p_errbuf OUT NOCOPY varchar2,
                                                         p_retcode OUT NOCOPY varchar2,
                                                         p_company_id varchar2,
                                                         p_period_type varchar2,
                                                         --p_consolidation_set_id number,
                                                         p_start_date varchar2,
                                                         p_end_date varchar2,
                                                         p_separator varchar2 DEFAULT NULL
                                                        )
IS
    v_start_date date; -- := trunc(to_date(p_start_date,'RRRR/MM/DD HH24:MI:SS'));
    v_end_date date; -- := trunc(to_date(p_end_date,'RRRR/MM/DD HH24:MI:SS'));
    v_daily_seq number;
    v_detail_seq number;
    v_header varchar2(2000);
    v_summary varchar2(2000);
    v_pre_detail varchar2(1000);
    v_total_emp number := 0;
    v_total_emp_acc number := 0;
    v_total_ent_acc number := 0;
    v_path varchar2(250) := 'FONDO_AHORRO';
    v_file_name varchar2(250):= 'FONDO_AHO_APORTACIONES.txt';
    v_period_type varchar2(200);

    CURSOR v_detail (p_period_type varchar2) IS
            SELECT sum(CASE WHEN ety.element_name = 'D091_FONDO DE AHORRO EMPRESA' THEN
                      rrv.result_value
                   END) enterprise_acc,
                   sum(CASE WHEN ety.element_name = 'D080_FONDO AHORRO TRABAJADOR' THEN
                      rrv.result_value
                   END) employee_acc,
                   rpad(employee_number,20,' ')||p_separator|| -- campo 12: número de nómina, requerido. longitud a 20 posiciones.
                   rpad(nvl(papf.last_name,' '), 40,' ')||p_separator|| -- campo 13: apellido paterno, requerido. longitud a 40 posiciones.
                   rpad(nvl(papf.per_information1,' '), 40,' ')||p_separator|| -- campo 14: apellido materno, requerido. longitud a 40 posiciones.
                   rpad(papf.first_name||' '||middle_names, 40,' ')||p_separator|| -- campo 15: nombres, requerido. longitud a 40 posiciones.
                   lpad(
                    REPLACE(
                        REPLACE(
                            TRIM(
                                TO_CHAR(
                                    sum(CASE WHEN ety.element_name = 'D091_FONDO DE AHORRO EMPRESA' THEN
                                            rrv.result_value
                                        END)
                                , '000000.00')
                            )
                        ,',','')
                    ,'.','')
                   , 15, '0')||p_separator|| -- campo 16: aportación empresa, requerido. longitud a 15 posiciones, con  13 enteros y hasta 2 decimales.
                   lpad(
                    REPLACE(
                        REPLACE(
                            TRIM(
                                TO_CHAR(
                                    sum(CASE WHEN ety.element_name = 'D080_FONDO AHORRO TRABAJADOR' THEN
                                            rrv.result_value
                                        END)
                                , '000000.00')
                            )
                        ,',','')
                    ,'.','')
                   , 15, '0')||p_separator|| -- campo 17: aportación trabajador, requerido. longitud a 15 posiciones, con  13 enteros y hasta 2 decimales.
                   lpad('0', 15, '0')||p_separator||-- campo 18: importe 3. longitud 15 posiciones. cero.
                   lpad('0', 15, '0')||p_separator||-- campo 19: importe 4. longitud 15 posiciones. cero.
                   lpad('0', 15, '0')||p_separator||-- campo 20: importe 5. longitud 15 posiciones. cero.
                   lpad('0', 15, '0')||p_separator||-- campo 21: importe 6. longitud 15 posiciones. cero.
                   lpad('0', 15, '0')||p_separator||-- campo 22: importe 7. longitud 15 posiciones. cero.
                   lpad('0', 15, '0')||p_separator||-- campo 23: importe 8. longitud 15 posiciones. cero.
                   lpad('0', 15, '0')||p_separator||-- campo 24: importe 9. longitud 15 posiciones. cero.
                   lpad('0', 15, '0')||p_separator||-- campo 25: importe 10. longitud 15 posiciones. cero.
                   lpad(' ', 589, ' ')-- campo 26: filler. longitud 589 posiciones. espacios en blanco.
                   det_row
              FROM pay_element_types_f ety,
                   pay_element_classifications cla,
                   pay_run_result_values rrv,
                   pay_input_values_f inv,
                   pay_run_results rrs,
                   pay_assignment_actions assact,
                   pay_payroll_actions ppact,
                   pay_payrolls_f ppayrolls,
                   per_all_assignments_f paaf, 
                   per_all_people_f papf
             WHERE 1 = 1
                   AND paaf.person_id = papf.person_id
                   AND paaf.assignment_id = assact.assignment_id
                   AND ppact.effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date
                   AND ppact.effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
                   AND pac_hr_pay_pkg.get_period_type (ppayrolls.payroll_name) = nvl(p_period_type, pac_hr_pay_pkg.get_period_type (ppayrolls.payroll_name))
                   AND trunc(to_date(pac_hr_pay_pkg.get_period_start_date(hr_payrolls.display_period_name(ppact.payroll_action_id)),'DD-MON-RRRR')) >= v_start_date
                   AND trunc(to_date(pac_hr_pay_pkg.get_period_end_date(hr_payrolls.display_period_name(ppact.payroll_action_id)),'DD-MON-RRRR')) <= v_end_date
                   AND substr(ppayrolls.payroll_name,1,2) = p_company_id
                   AND ety.element_name IN ('D080_FONDO AHORRO TRABAJADOR','D091_FONDO DE AHORRO EMPRESA')
                   AND ppayrolls.payroll_id = ppact.payroll_id
                   AND ppact.payroll_action_id = assact.payroll_action_id
                   AND (ppact.action_type = 'Q' OR ppact.action_type = 'R')
                   AND assact.assignment_action_id = rrs.assignment_action_id
                   AND inv.element_type_id = ety.element_type_id
                   AND rrs.element_type_id = ety.element_type_id
                   AND cla.classification_id = ety.classification_id
                   AND rrs.run_result_id = rrv.run_result_id
                   AND rrv.input_value_id = inv.input_value_id
                   AND inv.NAME = 'Pay Value'
             GROUP BY rpad(employee_number,20,' ')||p_separator||
                   rpad(nvl(papf.last_name,' '), 40,' ')||p_separator||
                   rpad(nvl(papf.per_information1,' '), 40,' ')||p_separator||
                   rpad(papf.first_name||' '||middle_names, 40,' ');
BEGIN

    BEGIN
        SELECT period_type
          INTO v_period_type
          FROM per_time_period_types_tl
         WHERE display_period_type = p_period_type;
    EXCEPTION WHEN others THEN
        fnd_file.put_line (fnd_file.log,'Error seteando tipo de período.');
    END;
    execute immediate 'ALTER SESSION set NLS_LANGUAGE = ''American''';
    
    
    v_start_date := trunc(to_date(p_start_date,'RRRR/MM/DD HH24:MI:SS'));
    v_end_date := trunc(to_date(p_end_date,'RRRR/MM/DD HH24:MI:SS'));
    
    BEGIN
        fnd_file.put_line (fnd_file.log,'P_COMPANY_ID: '||p_company_id);
        fnd_file.put_line (fnd_file.log,'P_PERIOD_TYPE: '||p_period_type); --v_period_type
        --fnd_file.put_line (fnd_file.log,'P_CONSOLIDATION_SET_ID: '||p_consolidation_set_id);
        fnd_file.put_line (fnd_file.log,'P_START_DATE: '||p_start_date);
        fnd_file.put_line (fnd_file.log,'P_END_DATE: '||p_end_date);
        fnd_file.put_line (fnd_file.log,'');
        fnd_file.put_line (fnd_file.log,'Inicia proceso de creación de archivo de dispersión para la aportación fondo de ahorro.');
        dbms_output.put_line('P_COMPANY_ID: '||p_company_id);
        dbms_output.put_line('P_PERIOD_TYPE: '||p_period_type); --v_period_type
        --dbms_output.put_line('P_CONSOLIDATION_SET_ID: '||p_consolidation_set_id);
        dbms_output.put_line('P_START_DATE: '||p_start_date);
        dbms_output.put_line('P_END_DATE: '||p_end_date);
        dbms_output.put_line('');
        dbms_output.put_line('Inicia proceso de creación de archivo de dispersión para la aportación fondo de ahorro.');
    EXCEPTION WHEN others THEN
         fnd_file.put_line (fnd_file.log,'Error al imprimir parámetros: '||SQLERRM);
    END;

    BEGIN
        dbms_output.put_line(' ');
        pac_append_to_file (v_path, v_file_name, ' ');
        utl_file.fremove(v_path,v_file_name);
    EXCEPTION WHEN others THEN
         dbms_output.put_line('Error al remover archivo: '||SQLERRM);
         fnd_file.put_line (fnd_file.log,'Error al remover archivo: '||SQLERRM);
    END;

    BEGIN
        SELECT pac_fondo_ahorro_daily_seq.NEXTVAL
          INTO v_daily_seq
          FROM dual;
    EXCEPTION WHEN others THEN
        dbms_output.put_line('Error al incrementar pac_fondo_ahorro_daily_seq.NEXTVAL: '||SQLERRM);
        fnd_file.put_line (fnd_file.log,'Error al incrementar pac_fondo_ahorro_daily_seq.NEXTVAL: '||SQLERRM);
    END;

    BEGIN
        --borrado y creación de la secuencia pac_fondo_ahorro_daily_seq
        execute immediate 'DROP SEQUENCE PAC_FONDO_AHORRO_DETAIL_SEQ';
        execute immediate 'CREATE SEQUENCE PAC_FONDO_AHORRO_DETAIL_SEQ '||
                          'START WITH 1 '   ||
                          'INCREMENT BY 1 ' ||
                          'NOCACHE '        ||
                          'NOCYCLE';

    EXCEPTION WHEN others THEN
        dbms_output.put_line('Error creando PAC_FONDO_AHORRO_DETAIL_SEQ: '||SQLERRM);
        fnd_file.put_line (fnd_file.log,'Error creando PAC_FONDO_AHORRO_DETAIL_SEQ: '||SQLERRM);
    END;

    BEGIN
        SELECT (SELECT meaning
                 FROM fnd_lookup_values flv
                WHERE lookup_type = 'XXCALV_APORT_FONDO_AHORRO'
                  AND LANGUAGE = userenv('LANG')
                  AND lookup_code = '001_CALV'
               )||p_separator|| -- campo 1: tipo de registro = '01', requerido. longitud 2
               (SELECT meaning
                  FROM fnd_lookup_values flv
                 WHERE lookup_type = 'XXCALV_APORT_FONDO_AHORRO'
                   AND LANGUAGE = userenv('LANG')
                   AND lookup_code = 'IDE_SERV'
               )||p_separator|| -- campo 2: identificador de servicio = 04,  requerido. longitud 2
               to_char(sysdate,'RRRRMMDD')||p_separator|| -- campo 3: fecha de envío de información, requerido. 8 posiciones. formato aaaammdd.
               lpad(v_daily_seq, 3, '0')||p_separator|| -- campo 4: consecutivo del día, requerido. longitud 3 posiciones y se considerará un consecutivo de 1 a n.
               (SELECT meaning
                  FROM fnd_lookup_values flv
                 WHERE lookup_type = 'XXCALV_APORT_FONDO_AHORRO'
                   AND LANGUAGE = userenv('LANG')
                   AND lookup_code = 'CONTRATO'
               )||p_separator|| -- campo 5: contrato = 0554535, requerido. longitud 7 posiciones.
               (SELECT meaning
                  FROM fnd_lookup_values flv
                 WHERE lookup_type = 'XXCALV_APORT_FONDO_AHORRO'
                   AND LANGUAGE = userenv('LANG')
                   AND lookup_code = 'SUBCONTRATO'
               )||p_separator|| -- campo 6: subcontrato = 0, requerido. longitud  posiciones.
               lpad(' ', 572, ' ') hed_row -- campo 7: filler. longitud 572 posiciones. espacios en blanco.
          INTO v_header
          FROM dual;
    EXCEPTION WHEN others THEN
        dbms_output.put_line('Error inesperado armando el header. '||SQLERRM);
        fnd_file.put_line (fnd_file.log,'Error inesperado armando el header. '||SQLERRM);
    END;

    BEGIN
        fnd_file.put_line (fnd_file.log,v_header);
        dbms_output.put_line(v_header);
        pac_append_to_file (v_path, v_file_name, v_header);
    EXCEPTION WHEN others THEN
        dbms_output.put_line('Error al escribir en archivo (línea 164): '||SQLERRM);
        fnd_file.put_line (fnd_file.log,'Error al escribir en archivo (línea 164): '||SQLERRM);
    END;
    
    fnd_file.put_line (fnd_file.log,'Inicia escritura de detalle con los siguientes parámetros:');
    fnd_file.put_line (fnd_file.log,'p_company_id: '||p_company_id);
    fnd_file.put_line (fnd_file.log,'p_period_type: '||p_period_type); --v_period_type
    fnd_file.put_line (fnd_file.log,'v_start_date: '||v_start_date);
    fnd_file.put_line (fnd_file.log,'v_end_date: '||v_end_date);
    fnd_file.put_line (fnd_file.log,'p_separator: '||p_separator);
    dbms_output.put_line('Inicia escritura de detalle con los siguientes parámetros:');
    dbms_output.put_line('p_company_id: '||p_company_id);
    dbms_output.put_line('p_period_type: '||p_period_type); --v_period_type
    dbms_output.put_line('v_start_date: '||v_start_date);
    dbms_output.put_line('v_end_date: '||v_end_date);
    dbms_output.put_line('p_separator: '||p_separator);
    
    BEGIN
        FOR i IN v_detail (v_period_type) LOOP
            BEGIN
                BEGIN
                    SELECT pac_fondo_ahorro_detail_seq.NEXTVAL
                      INTO v_detail_seq
                      FROM dual;
                EXCEPTION WHEN others THEN
                    dbms_output.put_line('Error al incrementar pac_fondo_ahorro_detail_seq.NEXTVAL: '||SQLERRM);
                    fnd_file.put_line (fnd_file.log,'Error al incrementar pac_fondo_ahorro_detail_seq.NEXTVAL: '||SQLERRM);
                END;
        
                SELECT (SELECT meaning
                          FROM fnd_lookup_values flv
                         WHERE lookup_type = 'XXCALV_APORT_FONDO_AHORRO'
                           AND LANGUAGE = userenv('LANG')
                           AND lookup_code = 'TIPO_REG'
                       )||p_separator|| -- campo 8: tipo de registro, requerido. longitud 2.
                       (SELECT meaning
                          FROM fnd_lookup_values flv
                         WHERE lookup_type = 'XXCALV_APORT_FONDO_AHORRO'
                           AND LANGUAGE = userenv('LANG')
                           AND lookup_code = 'IDE_SERV'
                       )||p_separator|| -- campo 9: identificador de servicio, requerido. longitud 2.
                       lpad(v_detail_seq, 9, '0')||p_separator|| -- campo 10: consecutivo de detalle, requerido. longitud 9 posiciones y se considerará un consecutivo de 1 a n.
                       to_char(sysdate,'RRRRMMDD') -- campo 11: fecha valor de movimiento, requerido. 8 posiciones. formato aaaammdd.
                  INTO v_pre_detail
                  FROM dual;
            EXCEPTION WHEN others THEN
                dbms_output.put_line('Error inesperado armando el pre-detail. '||SQLERRM);
                fnd_file.put_line (fnd_file.log,'Error inesperado armando el pre-detail. '||SQLERRM);
            END;

            BEGIN
                dbms_output.put_line(v_pre_detail||p_separator||i.det_row);
                pac_append_to_file (v_path, v_file_name, v_pre_detail||p_separator||i.det_row);
                fnd_file.put_line (fnd_file.log,v_pre_detail||p_separator||i.det_row);
            EXCEPTION WHEN others THEN
                dbms_output.put_line('Error al escribir en archivo (línea 197): '||SQLERRM);
                fnd_file.put_line (fnd_file.log,'Error al escribir en archivo (línea 197): '||SQLERRM);
            END;

            v_total_emp := v_total_emp + 1;
            v_total_emp_acc := v_total_emp_acc + i.enterprise_acc;
            v_total_ent_acc := v_total_ent_acc + i.employee_acc;

        END LOOP;
    EXCEPTION WHEN others THEN
        dbms_output.put_line('Error al abrir cursor: '||SQLERRM);
        fnd_file.put_line (fnd_file.log,'Error al abrir cursor: '||SQLERRM);
    END;
    
    BEGIN
        dbms_output.put_line('Inicia escritura del pie del reporte.');
        fnd_file.put_line (fnd_file.log,'Inicia escritura del pie del reporte.');
        SELECT (SELECT meaning
                   FROM fnd_lookup_values flv
                  WHERE lookup_type = 'XXCALV_APORT_FONDO_AHORRO'
                    AND LANGUAGE = userenv('LANG')
                    AND lookup_code = 'TIPO_REG2'
                 )||p_separator|| -- campo 27: tipo de registro, requerido. longitud de 2 posiciones.
                (SELECT meaning
                   FROM fnd_lookup_values flv
                  WHERE lookup_type = 'XXCALV_APORT_FONDO_AHORRO'
                    AND LANGUAGE = userenv('LANG')
                    AND lookup_code = 'IDE_SERV'
                 )||p_separator|| -- campo 27: tipo de registro, requerido. longitud de 2 posiciones.
                 to_char(sysdate,'RRRRMMDD')||p_separator|| -- campo 29: fecha de envío de información, requerido.
                 lpad(v_daily_seq, 3, '0')||p_separator|| -- campo 30: consecutivo del día,  requerido. longitud.
                 lpad(v_total_emp, 8, '0')||p_separator|| -- campo 31: total de registro de detalle,  requerido. longitud .
                 lpad(REPLACE(REPLACE(v_total_ent_acc,',',''),'.',''), 15, '0')||p_separator|| -- campo 32: suma de aportaciones empresa. longitud 15, 13 enteros y hasta 2 decimales.
                 lpad(REPLACE(REPLACE(v_total_emp_acc,',',''),'.',''), 15, '0')||p_separator|| -- campo 33: suma de aportaciones trabajador. longitud 15, 13 enteros y hasta 2 decimales.
                 lpad('0', 15, '0')||p_separator|| -- campo 34: suma de importe 3 de detalle. longitud 15 posiciones. cero.
                 lpad('0', 15, '0')||p_separator|| -- campo 35: suma de importe 4 de detalle. longitud 15 posiciones. cero.
                 lpad('0', 15, '0')||p_separator|| -- campo 36: suma de importe 5 de detalle. longitud 15 posiciones. cero.
                 lpad('0', 15, '0')||p_separator|| -- campo 37: suma de importe 6 de detalle. longitud 15 posiciones. cero.
                 lpad('0', 15, '0')||p_separator|| -- campo 38: suma de importe 7 de detalle. longitud 15 posiciones. cero.
                 lpad('0', 15, '0')||p_separator|| -- campo 39: suma de importe 8 de detalle. longitud 15 posiciones. cero.
                 lpad('0', 15, '0')||p_separator|| -- campo 40: suma de importe 9 de detalle. longitud 15 posiciones. cero.
                 lpad('0', 15, '0')||p_separator|| -- campo 41: suma de importe 10 de detalle. longitud 15 posiciones. cero.
                 lpad(REPLACE(REPLACE(v_total_ent_acc + v_total_emp_acc,',',''),'.',''), 15, '0')||p_separator|| -- campo 42: suma de importe 10 de detalle. longitud 15 posiciones. cero.
                 lpad(' ', 412, ' ') -- Campo 43: Filler. Longitud 412 posiciones. Espacios en blanco.
            INTO v_summary
            FROM dual;
    EXCEPTION WHEN others THEN
        dbms_output.put_line('Error inesperado armando el summary. '||SQLERRM);
        fnd_file.put_line (fnd_file.log,'Error inesperado armando el summary. '||SQLERRM);
    END;

    BEGIN
        pac_append_to_file (v_path, v_file_name, v_summary);
        fnd_file.put_line (fnd_file.log,v_summary);
        dbms_output.put_line(v_summary);
    EXCEPTION WHEN others THEN
        dbms_output.put_line('Error al escribir en archivo (línea 244): '||SQLERRM);
        fnd_file.put_line (fnd_file.log,'Error al escribir en archivo (línea 244): '||SQLERRM);
    END;

END;
