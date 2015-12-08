CREATE OR REPLACE PROCEDURE APPS.XXCALV_TEF_PAY_P (  errbuf                        OUT VARCHAR2
                                               ,retcode                       OUT NUMBER 
                                               ,p_payroll_id                  IN NUMBER
                                               ,p_consolidation_id            IN NUMBER
                                               --,p_time_period_id            IN NUMBER 
                                               --,p_time_period                 IN VARCHAR2
                                               ,p_period_type                 IN VARCHAR2
                                               ,p_start_date                  IN VARCHAR2
                                               ,p_end_date                    IN VARCHAR2
                                               ,p_assignment_set_id           IN NUMBER
                                               ,p_payment_method_id           IN NUMBER
                                               ,p_fecha_aplicacion            IN VARCHAR2 DEFAULT NULL
                                               ) IS

/******************************************************************************************
 Modulo : Human Resources  (HR ) 
 Autor : Javier Juarez Palma
 Fecha : 26/MAY/2014
 Descripcion: CreaciÛn de archivos de transferecia bancaria

 REVISIONS:
 Ver       Date       Author          Description
 --------- ---------- --------------- ------------------------------------
 1.0       26/05/2014 JJUAREZ         1. Created this package.
******************************************************************************************/
   l_fname_bbva                         VARCHAR2(100);
   l_fname_banorte                      VARCHAR2(100);
   l_file_bbva                          UTL_FILE.file_type;
   l_file_banorte                       UTL_FILE.file_type;
   l_dir                                VARCHAR2 ( 500 );   --:= 'EFT_BANCOMER';
   l_count                              NUMBER := 0;
   l_count_bbva                         NUMBER := 0;
   l_count_banorte                      NUMBER := 0;
   l_count_desp                         NUMBER := 0;
   l_count_files                        NUMBER := 1;
   l_importe_total                      NUMBER := 0;
   l_linea                              VARCHAR(1000);
   l_split                              NUMBER := 2000;
   l_start_date                         DATE;
   l_end_date                           DATE;
   l_fecha_aplicacion                   DATE;

   --Obtiene empleados 
   CURSOR c_emp(pp_start_date DATE, pp_end_date DATE) IS
        select rpad(nvl(replace(a.per_information2,'-',''),' '),16,' ') rfc
                 --,pbv.value importe 
                 ,ppp.value importe 
                 ,rpad(nvl(a.full_name,' '),40,' ')  full_name
                 ,b.assignment_id
                 ,ptp.default_dd_date
                 ,a.employee_number
                 --,count(1) OVER (PARTITION BY ppa.payroll_action_id) empleados
                 --,sum(ppp.value) OVER (PARTITION BY ppa.payroll_action_id) importe_total
                 ,count(1) OVER (PARTITION BY 1) empleados
                 ,sum(ppp.value) OVER (PARTITION BY 1) importe_total
        from  apps.per_all_people_f a
            , apps.per_all_assignments_f b       
            , apps.pay_payrolls_f pp    
            , apps.per_time_periods ptp  
            , apps.pay_payroll_actions ppa
            , apps.pay_assignment_actions paa
            , apps.pay_action_interlocks pai
            , apps.pay_pre_payments ppp
            , apps.pay_assignment_actions paa2
            , apps.pay_payroll_actions ppa2
        where 1 = 1 
        and   b.person_id = a.person_id
        and   b.payroll_id = pp.payroll_id
        and   ptp.payroll_id = pp.payroll_id
        and   sysdate between pp.effective_start_date and pp.effective_end_date
        and   ppa.payroll_id = pp.payroll_id
        and   ppa.time_period_id = ptp.time_period_id
        and   paa.payroll_action_id = ppa.payroll_action_id
        --and   paa.source_action_id is not null
         AND exists (select 1 from apps.pay_run_results_v prr 
                                   ,pay_assignment_actions  aac1
                     where prr.assignment_action_id = aac1.assignment_action_id
                     and aac1.source_action_id    = paa.assignment_action_id
                     and prr.result_value is not null
                     and prr.classification_name != 'Information')             
        and   paa.assignment_id = b.assignment_id
        and   pai.locked_action_id = paa.assignment_action_id
        and   ppp.assignment_action_id = pai.locking_action_id
        and   paa2.assignment_action_id = ppp.assignment_action_id
        and   ppa2.payroll_action_id = paa2.payroll_action_id
        and   ppp.org_payment_method_id = p_payment_method_id
        --and   b.assignment_type = 'E'
        --and   b.primary_flag = 'Y'
        --and   a.current_employee_flag = 'Y'
        and  pp.payroll_id = nvl(p_payroll_id,pp.payroll_id)
        and  nvl(ppa.consolidation_set_id,0) = nvl(p_consolidation_id,nvl(ppa.consolidation_set_id,0))
        and  nvl(ppa.assignment_set_id,0) = nvl(p_assignment_set_id,nvl(ppa.assignment_set_id,0))
        --and  ptp.time_period_id = p_time_period_id        
        --and  to_char(ptp.end_date,'YYYY/MM/DD HH24:MI:SS') = p_time_period 
        and ppa2.effective_date between nvl(pp_start_date,ppa2.effective_date) and pp_end_date
        and pp.period_type = p_period_type
        --and   ppa.action_type = 'R'
        and   a.effective_start_date = ( SELECT MAX ( a1.effective_start_date )
                                           FROM apps.per_all_people_f a1
                                          WHERE a1.person_id = a.person_id )
        and   b.effective_start_date = ( SELECT MAX ( b1.effective_start_date )
                                           FROM apps.per_all_assignments_f b1
                                          WHERE b1.assignment_id = b.assignment_id )                                  
        order by a.full_name;
                
   CURSOR c_pago(p_assignment_id NUMBER, p_date DATE) IS
        select opm.org_payment_method_name banco, pea.segment3 cuenta, pea_org.segment3 cuenta_org,
               ppm.payee_id, ppm.payee_type, rpad(nvl(replace(per.per_information2,'-',''),' '),16,' ') rfc, rpad(nvl(per.full_name,' '),40,' ')  full_name,
               decode(pea.segment4,'CHECK','01','DEBIT','02','MASTER','03') tipo_cuenta
        from pay_org_payment_methods_f_tl opmtl
               ,pay_org_payment_methods_f opm
               ,pay_personal_payment_methods_f ppm
               ,pay_external_accounts pea
               ,pay_external_accounts pea_org
               ,per_all_people_f per
        where 1 = 1
        and opm.org_payment_method_id = opmtl.org_payment_method_id
        and opmtl.language = userenv ('LANG')
        and ppm.org_payment_method_id = opm.org_payment_method_id
        and pea.external_account_id = ppm.external_account_id
        and pea_org.external_account_id = opm.external_account_id
        and per.person_id (+)= ppm.payee_id
        and p_date between ppm.effective_start_date and ppm.effective_end_date
        and p_date between opm.effective_start_date and opm.effective_end_date
        and p_date >= per.effective_start_date(+) 
        and p_date <= per.effective_end_date(+)  
        and opmtl.org_payment_method_id = p_payment_method_id
        and ppm.assignment_id = p_assignment_id;            

   l_pago      c_pago%ROWTYPE;           

   CURSOR c_lookup(p_lookup_type VARCHAR2, p_lookup_code VARCHAR2) IS    
        select description
        from apps.fnd_lookup_values_vl
        where lookup_type = p_lookup_type 
        and lookup_code = p_lookup_code;
   
   --Datos bancomer
   l_tipo_cuenta       fnd_lookup_values.description%TYPE;
   l_banco_destino     fnd_lookup_values.description%TYPE;
   l_plaza_destino     fnd_lookup_values.description%TYPE;

   --Datos banorte
   l_tipo_registro        fnd_lookup_values.description%TYPE;
   l_clave_serv           fnd_lookup_values.description%TYPE;
   l_emisora              fnd_lookup_values.description%TYPE;
   l_banco_recept         fnd_lookup_values.description%TYPE;
   l_tipo_registro2       fnd_lookup_values.description%TYPE;
   l_banorte_s             NUMBER;
   l_banorte_files         NUMBER;

   --Datos despensa
   l_001_CALV             fnd_lookup_values.description%TYPE;
   l_NUM_SUC              fnd_lookup_values.description%TYPE;
   l_002_CALV             fnd_lookup_values.description%TYPE;
   l_NUM_GRUPO            fnd_lookup_values.description%TYPE;
   l_NUM_CLIENTE          fnd_lookup_values.description%TYPE;
   l_RAZON_SOCIAL         fnd_lookup_values.description%TYPE;

    /*=================================================================
     * PROCEDURE print_out
     * Parameters: p_message Mensaje de impresion
     *=================================================================*/
    PROCEDURE print_out(p_message IN VARCHAR2) IS
    BEGIN
        apps.Fnd_File.put_line(apps.Fnd_File.output, p_message);
        --dbms_output.put_line(p_message);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN;
    END print_out;
   
   FUNCTION G_XML (P_ETIQUETA IN VARCHAR2, P_DATA IN VARCHAR2)
     RETURN VARCHAR2 IS
   BEGIN
       RETURN    '<'||P_ETIQUETA||'>'||P_DATA||'</'||P_ETIQUETA||'>';
   END;
       
BEGIN
    
    l_start_date := to_date(p_start_date,'YYYY/MM/DD HH24:MI:SS');
    l_end_date := to_date(p_end_date,'YYYY/MM/DD HH24:MI:SS');
    l_fecha_aplicacion := to_date(p_fecha_aplicacion,'YYYY/MM/DD HH24:MI:SS');
    
    FOR l_emp IN c_emp(l_start_date,l_end_date) LOOP
        l_count := l_count + 1;
        
        l_pago := NULL;
        OPEN c_pago(l_emp.assignment_id,l_emp.default_dd_date);
        FETCH c_pago INTO l_pago;
        CLOSE c_pago;
                            
        IF l_pago.banco like '%BANCOMER%' THEN
            l_count_bbva := l_count_bbva + 1;

            --Abrir archivo nuevo
            IF mod(l_count_bbva,l_split) = 1 THEN
                print_out('***** ARCHIVOS DE DISPERSI¿N BANCARIA '||sysdate||' *****');  
                print_out(' ');  
                
                l_dir := 'TEF_BANCOMER';
                l_fname_bbva := substr(l_pago.banco,1,2)||'-PAY'||'-'||l_count_files|| '_LayoutBancomer.txt';
                l_file_bbva := UTL_FILE.fopen ( l_dir, l_fname_bbva, 'w' );
                
                print_out('* ARCHIVO DE DISPERSI¿N BANCOMER: '||l_fname_bbva);    
                
                OPEN c_lookup('DATOS_BANCOMER','MX_TIPO');
                FETCH c_lookup INTO l_tipo_cuenta; 
                CLOSE c_lookup;

                OPEN c_lookup('DATOS_BANCOMER','MX_BANCO');
                FETCH c_lookup INTO l_banco_destino; 
                CLOSE c_lookup;

                OPEN c_lookup('DATOS_BANCOMER','MX_PLAZA');
                FETCH c_lookup INTO l_plaza_destino; 
                CLOSE c_lookup;
                
            END IF;
            
            IF l_pago.payee_type = 'P' THEN
                l_linea := lpad(l_count_bbva,9,'0') || l_pago.rfc || l_tipo_cuenta || rpad(l_pago.cuenta,20,' ')  || trim(replace(to_char(l_emp.importe,'0000000000000.00'),'.','')) || l_pago.full_name || l_banco_destino || l_plaza_destino;
            ELSE
                l_linea := lpad(l_count_bbva,9,'0') || l_emp.rfc || l_tipo_cuenta || rpad(l_pago.cuenta,20,' ')  || trim(replace(to_char(l_emp.importe,'0000000000000.00'),'.','')) || l_emp.full_name || l_banco_destino || l_plaza_destino;
            END IF;

            UTL_FILE.put_line ( l_file_bbva, l_linea );
            print_out(l_linea);  
            
            --cerrar archivo
            IF mod(l_count_bbva,l_split) = 0 THEN
                UTL_FILE.fclose ( l_file_bbva );
                l_count_bbva := 0;
                l_count_files := l_count_files + 1;
            END IF;
            
        ELSIF l_pago.banco like '%BANORTE%'  THEN

            l_count_banorte := l_count_banorte + 1;    

            --Abrir archivo nuevo
            IF l_count_banorte = 1 THEN
                
                    SELECT count(1) + 1
                    INTO l_banorte_files
                    FROM FND_CONCURRENT_PROGRAMS cp,
                             FND_CONCURRENT_REQUESTS cr
                    WHERE cr.concurrent_program_id = cp.concurrent_program_id
                    AND cp.CONCURRENT_PROGRAM_NAME = 'XXCALVTEF'
                    AND cr.argument4 = p_payment_method_id
                    AND trunc(cr.requested_start_date) = trunc(sysdate);

                print_out('***** ARCHIVOS DE DISPERSI¿N BANCARIA '||sysdate||' *****');  
                print_out(' ');  

                OPEN c_lookup('XX_DATOS_BANORTE','TIPO_REGISTRO');
                FETCH c_lookup INTO l_tipo_registro; 
                CLOSE c_lookup;                               

                OPEN c_lookup('XX_DATOS_BANORTE','CLAVE_SERV');
                FETCH c_lookup INTO l_clave_serv; 
                CLOSE c_lookup;                               

                OPEN c_lookup('XX_DATOS_BANORTE','EMISORA');
                FETCH c_lookup INTO l_emisora; 
                CLOSE c_lookup;                               

                OPEN c_lookup('XX_DATOS_BANORTE','TIPO_REGISTRO2');
                FETCH c_lookup INTO l_tipo_registro2; 
                CLOSE c_lookup;                               

                OPEN c_lookup('XX_DATOS_BANORTE','BANCO_RECEPT');
                FETCH c_lookup INTO l_banco_recept; 
                CLOSE c_lookup;
                
                OPEN c_lookup('XX_DATOS_BANORTE','TIPO_CUENTA');
                FETCH c_lookup INTO l_tipo_cuenta; 
                CLOSE c_lookup;

                l_dir := 'TEF_BANORTE';
                l_fname_banorte := 'NI' || l_emisora || lpad(l_banorte_files,2,'0') || '.PAG';
                l_file_banorte := UTL_FILE.fopen ( l_dir, l_fname_banorte, 'w' );
                 print_out('* ARCHIVO DE DISPERSI¿N BANORTE: '||l_fname_banorte);

                l_linea := l_tipo_registro || l_clave_serv || l_emisora || to_char(l_fecha_aplicacion,'YYYYMMDD') || 
                           lpad(l_banorte_files,2,'0') || lpad(l_emp.empleados,6,'0') || trim(replace(to_char(l_emp.importe_total,'0000000000000.00'),'.',''))  || lpad('0',6,'0') || 
                           lpad('0',15,'0') || lpad('0',6,'0') || lpad('0',15,'0') || lpad('0',6,'0') || '0' || lpad(' ',76,' ')||'.';
                UTL_FILE.put_line ( l_file_banorte, l_linea );
                print_out(l_linea);
            END IF;
            
            l_linea := l_tipo_registro2 || to_char(l_fecha_aplicacion,'YYYYMMDD') || lpad(l_emp.employee_number,10,'0') || lpad(' ',40,' ') || lpad(' ',40,' ') ||
                       trim(replace(to_char(l_emp.importe,'0000000000000.00'),'.','')) || l_banco_recept || l_tipo_cuenta || --l_pago.tipo_cuenta ||
                       lpad(l_pago.cuenta,18,'0') || '0 ' || lpad('0',8,'0') || lpad(' ',17,' ')||'.';
            
            UTL_FILE.put_line ( l_file_banorte, l_linea );
            print_out(l_linea);

        ELSIF l_pago.banco like '%DESPENSA%'  THEN
        --ELSIF 1 = 1  THEN
            l_count_desp := l_count_desp + 1;
            
            --imprimir encabezado
            IF l_count_desp = 1 THEN
                print_out('<?xml version="1.0" encoding="ISO-8859-1" ?>');
                print_out('<G_REPORT>');
                
                OPEN c_lookup('XX_DATOS_DESPENSA','001_CALV');
                FETCH c_lookup INTO l_001_CALV; 
                CLOSE c_lookup;                               

                OPEN c_lookup('XX_DATOS_DESPENSA','NUM_SUC');
                FETCH c_lookup INTO l_NUM_SUC; 
                CLOSE c_lookup;                               

                OPEN c_lookup('XX_DATOS_DESPENSA','002_CALV');
                FETCH c_lookup INTO l_002_CALV; 
                CLOSE c_lookup;                               

                OPEN c_lookup('XX_DATOS_DESPENSA','NUM_GRUPO');
                FETCH c_lookup INTO l_NUM_GRUPO; 
                CLOSE c_lookup;                               

                OPEN c_lookup('XX_DATOS_DESPENSA','NUM_CLIENTE');
                FETCH c_lookup INTO l_NUM_CLIENTE; 
                CLOSE c_lookup;                               
                
                OPEN c_lookup('XX_DATOS_DESPENSA','RAZON SOCIAL');
                FETCH c_lookup INTO l_RAZON_SOCIAL; 
                CLOSE c_lookup;                               
                
                print_out('<PARAMETROS>');
                   print_out(g_xml('l001_CALV',l_001_CALV));
                   print_out(g_xml('NUMERO_SUCURSAL',l_NUM_SUC));
                   print_out(g_xml('l002_CALV',l_002_CALV));
                   print_out(g_xml('NUMERO_GRUPO',l_NUM_GRUPO));
                   print_out(g_xml('NUMERO_CLIENTE',l_NUM_CLIENTE));
                   print_out(g_xml('RAZON_SOCIAL',l_RAZON_SOCIAL));
                   print_out(g_xml('TOTAL_EMPLEADOS',l_emp.empleados));
                   print_out(g_xml('IMPORTE_TOTAL',l_emp.importe_total));
                   print_out(g_xml('FECHA_DISPERSION',to_char(l_emp.default_dd_date,'YYYYMMDD')));
                print_out('</PARAMETROS>');
            END IF;
           
           print_out('<EMPLEADO>');
           print_out(g_xml('NUMERO_EMPLEADO',l_emp.employee_number));
           print_out(g_xml('NUMERO_CUENTA',l_pago.cuenta));
           print_out(g_xml('IMPORTE',l_emp.importe));
           print_out('</EMPLEADO>') ;
           
        END IF;                
        
    END LOOP;    
   
   IF l_count_desp > 0 THEN
        print_out('</G_REPORT>');
   ELSIF l_count_banorte + l_count_bbva > 0 THEN
       print_out(' ');  
       print_out('***** FIN DE ARCHIVOS DE DISPERSI¿N BANCARIA '||sysdate||' *****');
       print_out(' ');
       UTL_FILE.fclose_all;
   END IF;
   
EXCEPTION
  WHEN OTHERS THEN
      print_out('E: Error inesperado: '|| SQLCODE || ', ' || SQLERRM);    
      retcode := 1;
END XXCALV_TEF_PAY_P;
/
