CREATE OR REPLACE PACKAGE BODY APPS.XXCALV_PAY_POLIZA_PKG AS
  
     /*=================================================================
     * PROCEDURE print_out
     * Parameters: p_message Mensaje de impresion
     *=================================================================*/
    PROCEDURE print_out(p_message IN VARCHAR2) IS
    BEGIN
     Fnd_File.put_line(Fnd_File.output, p_message);
    EXCEPTION
     WHEN OTHERS THEN
       RETURN;
    END print_out;

    /*=================================================================
     * PROCEDURE print_log
     * Parameters: p_message Mensaje de impresion
     *=================================================================*/
    PROCEDURE print_log(p_message IN VARCHAR2) IS
    BEGIN
     Fnd_File.put_line(Fnd_File.log,p_message);
    EXCEPTION
     WHEN OTHERS THEN
       RETURN;
    END print_log;

/*=================================================================
 * PROCEDURE gl_interface  Inserta en tabla de interface de gl
 *=================================================================*/
PROCEDURE gl_interface( p_ledger_id             IN   NUMBER,
                        p_group_id              IN   NUMBER,
                        p_je_source_name        IN   VARCHAR2,
                        p_je_category_name      IN   VARCHAR2,
                        p_cc_id                 IN   NUMBER,
                        p_segment1              IN   VARCHAR2,
                        p_segment2              IN   VARCHAR2,
                        p_segment3              IN   VARCHAR2,
                        p_segment4              IN   VARCHAR2,
                        p_segment5              IN   VARCHAR2,
                        p_segment6              IN   VARCHAR2,
                        p_segment7              IN   VARCHAR2,
                        p_segment8              IN   VARCHAR2,
                        p_segment9              IN   VARCHAR2,
                        p_accounting_date       IN   DATE,
                        p_period_name           IN   VARCHAR2,
                        p_currency_code         IN   VARCHAR2,
                        p_entered_dr            IN   NUMBER,
                        p_entered_cr            IN   NUMBER,
                        p_batch_name            IN   VARCHAR2,
                        p_batch_desc            IN   VARCHAR2,
                        p_journal_name          IN   VARCHAR2,
                        p_journal_desc          IN   VARCHAR2,
                        p_line_num              IN   VARCHAR2,
                        p_line_desc             IN   VARCHAR2,
                        p_reference21           IN   VARCHAR2,
                        p_reference22           IN   VARCHAR2,
                        p_reference23           IN   VARCHAR2,
                        p_reference24           IN   VARCHAR2,
                        p_reference25           IN   VARCHAR2 ) IS
BEGIN
    g_debug := 'gl_interface';
    
    INSERT INTO GL.GL_INTERFACE( Status,
                                 ledger_id,
                                 set_of_books_id,
                                 accounting_date,
                                 period_name,
                                 currency_code,
                                 currency_conversion_Date,
                                 user_currency_conversion_type,
                                 date_created,
                                 created_by,
                                 actual_flag,
                                 user_je_category_name,
                                 user_je_source_name,
                                 entered_dr,
                                 entered_cr,
                                 code_combination_id,
                                 segment1,
                                 segment2,
                                 segment3,
                                 segment4,
                                 segment5,
                                 segment6,
                                 segment7,
                                 segment8,
                                 segment9,
                                 group_id,
                                 reference1,
                                 reference2,
                                 reference4,
                                 reference5,
                                 reference6,
                                 reference10,
                                 reference21,
                                 reference22,
                                 reference23,
                                 reference24,
                                 reference25 )
           VALUES ( 'NEW',
                    p_ledger_id,
                    p_ledger_id,
                    p_accounting_date,
                    p_period_name,
                    p_currency_code,
                    p_accounting_date,
                    'Corporate',
                    trunc(SYSDATE),
                    801,    --apps.fnd_global.user_id,
                    'A',
                    p_je_category_name,
                    p_je_source_name,
                    decode(p_entered_dr,0,NULL,p_entered_dr),
                    decode(p_entered_cr,0,NULL,p_entered_cr), 
                    p_cc_id,
                    p_segment1,
                    p_segment2,
                    p_segment3,
                    p_segment4,
                    p_segment5,
                    p_segment6,
                    p_segment7,
                    p_segment8,
                    p_segment9,
                    p_group_id,
                    ------
                    p_batch_name,
                    p_batch_desc,
                    p_journal_name,
                    p_journal_desc,
                    p_line_num,
                    p_line_desc,
                    p_reference21,
                    p_reference22,
                    p_reference23,
                    p_reference24,
                    p_reference25 );
                        
    g_debug := 'Fin gl_interface';
EXCEPTION
 WHEN OTHERS THEN
    print_log('* Error inesperado: '|| SQLCODE || ', ' || SQLERRM);
    print_log('* En: '||g_debug);
END gl_interface;

/*==================================================================================
 * PROCEDURE wait_for_request   Espera terminacion de concurrente
 *==================================================================================*/
PROCEDURE wait_for_request( p_request_id     IN   NUMBER ) IS

 l_call_status      BOOLEAN; 
 l_request_print    BOOLEAN; 
 l_rphase           VARCHAR2(80);
 l_rstatus          VARCHAR2(80);
 l_dphase           VARCHAR2(30);
 l_dstatus          VARCHAR2(30);
 l_message          VARCHAR2(240); 
 
BEGIN
       g_debug := 'wait_for_request: '||p_request_id; 
       print_log(g_debug);    
       
       l_call_status := apps.fnd_Concurrent.wait_for_request(
                                         request_id     => p_request_id
                                         , INTERVAL     => 5
                                         , max_wait     => NULL
                                         , phase        => l_rphase
                                         , status       => l_rstatus
                                         , dev_phase    => l_dphase
                                         , dev_status   => l_dstatus
                                         , message      => l_message ) ;
 
EXCEPTION
 WHEN OTHERS THEN
   print_log('Error inesperado: '|| SQLCODE || ', ' || SQLERRM);
   print_log('En: '||g_debug);
END wait_for_request;


/*=========================================================================
 * PROCEDURE submit_gl   Ejecucion de concurrente de importacion de polizas  
 *=========================================================================*/
FUNCTION submit_gl( p_gl_access_set_id     IN   NUMBER,
                    p_ledger_id            IN   NUMBER,
                    p_je_source_name       IN   VARCHAR2,
                    p_group_id             IN   NUMBER  ) RETURN NUMBER IS
 
 l_request_id       NUMBER;
 
BEGIN
       g_debug := 'Ejecutar carga de poliza: '||p_group_id; 
       print_log(g_debug);    

       l_request_id := apps.fnd_request.submit_request(
                             'SQLGL',
                             'GLLEZLSRS',
                             '',
                             '',
                             FALSE,
                             p_gl_access_set_id,
                             p_je_source_name,
                             p_ledger_id, 
                             p_group_id,  
                             'N',          --post errors 
                             'N',         ---create summary 
                             'N'          --- import descriptive
                             );
       
       COMMIT;
       
       print_log('Request id: '||l_request_id);
       
       IF l_request_id > 0 THEN
            wait_for_request( l_request_id );
       END IF;
       
       RETURN l_request_id;
       
EXCEPTION
 WHEN OTHERS THEN
   print_log('Error inesperado: '|| SQLCODE || ', ' || SQLERRM);
   print_log('En: '||g_debug);
   RETURN 0;
END submit_gl;
    
  -- PROCEDURE Principal
  --   Procedimiento principal que realiza el llamado a los diferentes procedimientos y/o funciones.
  PROCEDURE Genera_Poliza
                  ( errbuf                     OUT NOCOPY VARCHAR2
                   ,retcode                    OUT NOCOPY NUMBER
                   ,p_payroll_id               IN         NUMBER
                   ,p_consolidation_id         IN         NUMBER
                   ,p_period_type              IN         VARCHAR2
                   ,p_start_date               IN         VARCHAR2
                   ,p_end_date                 IN         VARCHAR2
                   ,p_assignment_set_id        IN         NUMBER
                   ,p_final_mode               IN         VARCHAR2
                   ,p_je_source_name           IN         VARCHAR2
                   ,p_je_category_name         IN         VARCHAR2
                   ,p_gl_access_set_id         IN         NUMBER
                   ) IS
        
     CURSOR c_elementos(pp_start_date DATE, pp_end_date DATE) IS
        select  ppa.payroll_action_id,
                ppa.assignment_set_id,
                 paa.assignment_action_id,
                 pcd.person_id,
                 ptp.time_period_id,
                 ptp.end_date,
                 pet.element_type_id,
                 pas.assignment_number,
                 pet.element_name,
                 rrs.run_result_id,
                 --pcd.credit_amount,
                 pcd.debit_amount,
                 pc.cost_allocation_keyflex_id,
                 pcd.concatenated_segments seg
                 ,pcd.segment1, pcd.segment2, pcd.segment3, pcd.segment4, pcd.segment5, pcd.segment6
                 ,hao.attribute7 cc, hao.attribute3 mano_de_obra, hao.attribute4 carga_social
                 ,hao.attribute5 bonos, hao.attribute6 fondo_de_ahorro
                 , pet.attribute1 clasificacion_pac 
        from pay_payroll_actions ppa
            ,pay_payrolls_f pp
            ,per_time_periods ptp
            ,pay_assignment_actions paa      
            ,per_all_assignments_f pas 
            ,pay_run_results rrs
            ,pay_element_types_f pet
            ,pay_costs pc
            ,pay_costing_details_v pcd
            ,hr_all_organization_units hao
        where 1 = 1
        and pp.payroll_id = ppa.payroll_id
        and ptp.time_period_id = ppa.time_period_id
        and paa.payroll_action_id = ppa.payroll_action_id
        and pas.assignment_id = paa.assignment_id
        and ppa.effective_date  between pas.effective_start_date and pas.effective_end_date
        and pas.ass_attribute15 = 'PAC'   --Solo empleados PAC
        and rrs.assignment_action_id = paa.assignment_action_id
        and pet.element_type_id = rrs.element_type_id 
        and pet.attribute1 is not null     --Elementos que deben ser transferidos
        and pet.attribute1 != 'N/A'
        and pc.run_result_id = rrs.run_result_id
        and pcd.run_result_id = rrs.run_result_id
        and hao.organization_id = pas.organization_id
        and hao.attribute7 is not null        --Organizaciones con informacion de centro de costos
        and ppa.payroll_id = nvl(p_payroll_id,ppa.payroll_id) 
        and nvl(ppa.consolidation_set_id,0) = nvl(p_consolidation_id,nvl(ppa.consolidation_set_id,0))
        and nvl(ppa.assignment_set_id,0) = nvl(p_assignment_set_id,nvl(ppa.assignment_set_id,0))
        and ppa.effective_date between nvl(pp_start_date,ppa.effective_date) and pp_end_date
        and pp.period_type = p_period_type
        --and ptp.time_period_id = 150258
        --and ppa.payroll_action_id = 10361
        --and ptp.time_period_id IN (SELECT DISTINCT ptp.time_period_id
        --                                                FROM per_time_periods ptp
        --                                               WHERE 1 = 1
        --                                                 AND ptp.start_date >= p_Fecha_Ini
        --                                                 AND ptp.end_date <= p_Fecha_Fin
        --                                                 AND ptp.payroll_id = p_Id_Nomina)
        and ppa.action_type IN ('R', 'Q')
        and paa.action_status = 'C'
        and pcd.debit_amount <> 0
        and pc.debit_or_credit = 'D'
        order by hao.attribute7, pas.assignment_number, pet.element_name;


    CURSOR c_datos IS
      select lookup_code, description
      from fnd_lookup_values_vl
      where lookup_type = 'DATOS DE CUENTA POLIZA PAC';
    
    TYPE t_segmentos   IS TABLE OF VARCHAR(80) INDEX BY VARCHAR2(30);  
    l_segmentos        t_Segmentos;  
    l_cuenta           VARCHAR2(30);
    l_cta_dest         VARCHAR2(100);
    l_mano_obra        NUMBER := 0;
    l_carga_social     NUMBER := 0;
    l_bonos            NUMBER := 0;
    l_fondo_ahorro     NUMBER := 0;
    l_total            NUMBER := 0;
    --
    l_cta_puente       VARCHAR2(100);
    l_cta_pte_id       NUMBER;
    l_libro            VARCHAR2(100);
    --
    l_start_date       DATE;
    l_end_date         DATE;
    l_request_id       NUMBER;
    l_group_id         NUMBER;
    l_error_flag       NUMBER := 0;

       --Obtiene origen de importacion de polizas
   CURSOR c_sources IS
       SELECT user_je_source_name
       FROM gl_je_sources
       WHERE je_source_name = p_je_source_name;   --'Payroll'

   --Obtiene categoria de importacion
   CURSOR c_categories IS
       SELECT user_je_category_name
       FROM gl_je_categories
       WHERE je_category_name = p_je_category_name;  --'Payroll'
       
   --Obtiene libro contable
   CURSOR c_ledger(p_libro VARCHAR2) IS
      SELECT access_set_id, default_ledger_id, chart_of_accounts_id
      FROM gl_access_sets gls      
      WHERE name = p_libro;
      
   CURSOR c_cta_pte(p_cta_puente VARCHAR2) IS
       select code_combination_id
       from gl_code_combinations gcc
       where fnd_flex_ext.get_segs('SQLGL', 'GL#', gcc.chart_of_accounts_id, gcc.code_combination_id) = p_cta_puente;
  
   l_user_je_source_name                  gl_je_sources.user_je_source_name%TYPE;
   l_user_je_category_name                gl_je_categories.user_je_category_name%TYPE;
   l_ledger                               c_ledger%ROWTYPE;

  BEGIN
    --
    l_start_date := NVL(FND_DATE.CANONICAL_TO_DATE(p_start_date),SYSDATE); 
    l_end_date := NVL(FND_DATE.CANONICAL_TO_DATE(p_end_date),SYSDATE); 
    --
    print_out ('***   Procedimiento Genera Poliza   ***');
    print_out ('  Parametros de Entrada');
    print_out ('    p_payroll_id       : ' || p_payroll_id);
    print_out ('    p_consolidation_id : ' || p_consolidation_id);
    print_out ('    p_Fecha_Ini        : ' || TO_CHAR(l_start_date, 'YYYY/MM/DD'));
    print_out ('    p_Fecha_Fin        : ' || TO_CHAR(l_end_date, 'YYYY/MM/DD'));
    print_out ('*********************************');
    print_out (' ');

    FOR l_datos IN c_datos LOOP
      l_segmentos(l_datos.lookup_code) := l_datos.description;
    END LOOP;
      
    OPEN c_sources;
    FETCH c_sources INTO l_user_je_source_name;
    CLOSE c_sources;

    OPEN c_categories;
    FETCH c_categories INTO l_user_je_category_name;
    CLOSE c_categories;
    
    l_cta_puente := l_segmentos('CUENTA');
    l_libro := l_segmentos('LIBRO');
    
    OPEN c_ledger(l_libro);
    FETCH c_ledger INTO l_ledger;
    CLOSE c_ledger;
    
    print_out(rpad('AsignaciÛn',20,' ')||rpad('Elemento',30,' ')||rpad('Monto',20,' ')||rpad('Cuenta Origen',50,' ')||rpad('Cuenta Destino',50,' '));
    print_out(rpad('-',170,'-'));

    IF p_final_mode = 'Y' THEN
        SELECT gl_interface_control_s.nextval
        INTO l_group_id
        FROM DUAL;
        
        
        OPEN c_cta_pte(l_cta_puente);
        FETCH c_cta_pte INTO l_cta_pte_id;
        CLOSE c_cta_pte;
        
        print_out('* Group ID: '||l_group_id);
    END IF;
    
      FOR l IN c_elementos(l_start_date, l_end_date) LOOP
      BEGIN

            IF l.clasificacion_pac = 'MANO DE OBRA' THEN
              l_cuenta := l.mano_de_obra;
              l_mano_obra := l_mano_obra + l.debit_amount;
            ELSIF l.clasificacion_pac = 'CARGA SOCIAL' THEN
              l_cuenta := l.carga_social;
              l_carga_social := l_carga_social + l.debit_amount;
            ELSIF l.clasificacion_pac = 'BONOS' THEN
              l_cuenta := l.bonos;
              l_bonos := l_bonos + l.debit_amount;
            ELSIF l.clasificacion_pac = 'FONDO DE AHORRO' THEN
              l_cuenta := l.fondo_de_ahorro;
              l_fondo_ahorro := l_fondo_ahorro + l.debit_amount;
            ELSE
              print_log ('E: Clasificacion PAC invalida para el elemento: '||l.element_name); 
              l_cuenta := NULL;
            END IF;
            
            l_cta_dest := l_segmentos('COMPANIA')||'.'||l.cc||'.'||l_cuenta||'.'||l_segmentos('FILIAL')||'.'||
                          l_segmentos('FUTURO 1')||'.'||l_segmentos('FUTURO 2');
                          
            l_total := l_total + l.debit_amount;
            
            print_out(rpad(l.assignment_number,20,' ')||rpad(l.element_name,30,' ')||to_char(l.debit_amount,'9999,999,999,999.00')||
                      --lpad(l.seg,50,' ')||
                      lpad(l_cta_dest,50,' ')||lpad(l_cta_puente,50,' '));
            
            IF p_final_mode = 'Y' THEN
              gl_interface( p_ledger_id               => l_ledger.default_ledger_id,
                            p_group_id                => l_group_id, --NULL,
                            p_je_source_name          => l_user_je_source_name,
                            p_je_category_name        => l_user_je_category_name,
                            p_cc_id                   => NULL,
                            p_segment1                => l_segmentos('COMPANIA'),
                            p_segment2                => l.cc,
                            p_segment3                => l_cuenta,
                            p_segment4                => l_segmentos('FILIAL'),
                            p_segment5                => l_segmentos('FUTURO 1'),
                            p_segment6                => l_segmentos('FUTURO 2'),
                            p_segment7                => NULL,
                            p_segment8                => NULL,
                            p_segment9                => NULL,
                            p_accounting_date         => trunc(l.end_date),
                            p_period_name             => NULL,
                            p_currency_code           => 'MXN',
                            p_entered_dr              => l.debit_amount,
                            p_entered_cr              => NULL,
                            p_batch_name              => NULL,
                            p_batch_desc              => NULL,
                            p_journal_name            => NULL,
                            p_journal_desc            => NULL,
                            p_line_num                => NULL,
                            p_line_desc               => NULL,
                            p_reference21             => FND_GLOBAL.CONC_REQUEST_ID,
                            p_reference22             => NULL,--l.cost_allocation_keyflex_id,
                            p_reference23             => NULL,
                            p_reference24             => NULL,
                            p_reference25             => l.payroll_action_id );
            END IF;

      EXCEPTION
        WHEN OTHERS THEN
           print_out('E: Error en la creacion de asientos: '||SQLERRM);
           l_error_flag := 1;
      END;
      END LOOP;
      
      print_out(lpad(' ',50,' ')||lpad('-',20,'-'));
      print_out(lpad('TOTAL:',50,' ')||to_char(l_total,'9999,999,999,999.00'));
      
      print_out(' ');
      --print_out('Mano de Obra: '||to_char(l_mano_obra,'9999,999,999,999.00'));
      --print_out('Carga Social: '||to_char(l_carga_social,'9999,999,999,999.00'));
      --print_out('Bonos: '||to_char(l_bonos,'9999,999,999,999.00'));
      --print_out('Fondo de ahorro: '||to_char(l_fondo_ahorro,'9999,999,999,999.00'));
      
      IF l_error_flag = 0 AND p_final_mode = 'Y' THEN
              gl_interface( p_ledger_id               => l_ledger.default_ledger_id,
                            p_group_id                => l_group_id, 
                            p_je_source_name          => l_user_je_source_name,
                            p_je_category_name        => l_user_je_category_name,
                            p_cc_id                   => l_cta_pte_id,
                            p_segment1                => NULL,
                            p_segment2                => NULL,
                            p_segment3                => NULL,
                            p_segment4                => NULL,
                            p_segment5                => NULL,
                            p_segment6                => NULL,
                            p_segment7                => NULL,
                            p_segment8                => NULL,
                            p_segment9                => NULL,
                            p_accounting_date         => l_end_date,
                            p_period_name             => NULL,
                            p_currency_code           => 'MXN',
                            p_entered_dr              => NULL,
                            p_entered_cr              => l_total,
                            p_batch_name              => NULL,
                            p_batch_desc              => NULL,
                            p_journal_name            => NULL,
                            p_journal_desc            => NULL,
                            p_line_num                => NULL,
                            p_line_desc               => NULL,
                            p_reference21             => FND_GLOBAL.CONC_REQUEST_ID,
                            p_reference22             => NULL,
                            p_reference23             => NULL,
                            p_reference24             => NULL,
                            p_reference25             => NULL );
      COMMIT;
        
        l_request_id := submit_gl( l_ledger.access_set_id, l_ledger.default_ledger_id, p_je_source_name, l_group_id );
        print_out('ID Solicitud GL:'||l_request_id);
      ELSIF l_error_flag = 1 AND p_final_mode = 'Y' THEN
        ROLLBACK;
      END IF;
      
       
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Genera_Poliza: ' || SQLERRM;
      print_log(errbuf);
      retcode := 2;
  END Genera_Poliza;
  
END XXCALV_PAY_POLIZA_PKG;