CREATE OR REPLACE PACKAGE BODY APPS.PAC_EFT_PKG
AS
   batch_id    NUMBER;
   tot_depts   NUMBER;

   FUNCTION extract_account_number (p_supplier_clabe_account VARCHAR2)
      RETURN NUMBER
   IS
      l_supplier_account   NUMBER;
   BEGIN
      l_supplier_account :=
         TO_NUMBER (SUBSTR (p_supplier_clabe_account, 7, 11));
      RETURN l_supplier_account;
   END;



   FUNCTION create_batch (p_bank_account_id NUMBER)
      RETURN NUMBER
   IS
      new_batch_id          NUMBER;
      l_bank_account_name   VARCHAR2 (50);
      l_bank_account_num    NUMBER;
      l_currency_code       VARCHAR2 (10);
   BEGIN
      SELECT BATCH_HEADER_EFT_SEQ.NEXTVAL INTO new_batch_id FROM DUAL;

      

        SELECT bank_account_name, cba.bank_account_num, cba.currency_code
          INTO l_bank_account_name, l_bank_account_num, l_currency_code
          FROM CE_BANK_ACCOUNTS cba, CE_BANK_ACCT_USES_ALL cbaua
         WHERE     cba.bank_account_id = cbaua.bank_account_id
               AND cba.bank_account_id = p_bank_account_id
               AND org_id = 82
      ORDER BY cba.bank_account_name;
      
      

      INSERT INTO PAC_EFT_BATCH_HEADER
           VALUES (new_batch_id,
                   NULL,
                   'N',
                   p_bank_account_id,
                   l_bank_account_name,
                   l_bank_account_num,
                   l_currency_code,
                   'N',
                   1155,
                   SYSDATE,
                   EMPTY_BLOB (),
                   NULL);

      

      batch_id := new_batch_id;
      RETURN (batch_id);
   END;


   PROCEDURE create_line (p_batch_id          NUMBER,
                          p_line_number       NUMBER,
                          p_invoice_id        NUMBER,
                          output_msg      OUT VARCHAR2)
   IS
      new_line_id                 NUMBER;
      l_bank_account_id           NUMBER;
      l_bank_account_number       NUMBER;
      l_currency_code             VARCHAR2 (3);
      l_vendor_name               VARCHAR2 (80);
      l_vendor_num                NUMBER;
      l_invoice_num               VARCHAR2 (240);
      l_supplier_account_number   NUMBER;
      l_invoice_description       VARCHAR2 (80);
      l_operation_amount          NUMBER;
      l_operation_currency        VARCHAR2 (3);
      l_supplier_clabe_number     VARCHAR2 (80);
   BEGIN
      SELECT BATCH_LINES_EFT_SEQ.NEXTVAL INTO new_line_id FROM DUAL;

      

      SELECT bank_account_id
        INTO l_bank_account_id
        FROM PAC_EFT_BATCH_HEADER
       WHERE batch_id = p_batch_id;

      

        SELECT cba.bank_account_num, cba.currency_code
          INTO l_bank_account_number, l_currency_code
          FROM CE_BANK_ACCOUNTS cba, CE_BANK_ACCT_USES_ALL cbaua
         WHERE     cba.bank_account_id = cbaua.bank_account_id
               AND cba.bank_account_id = l_bank_account_id
               AND org_id = 82
      ORDER BY cba.bank_account_name;


      SELECT UNIQUE aps.vendor_name vendor_name,
             aps.segment1 vendor_num,
             aia.invoice_num,
             SUBSTRB (aia.description, 1, 50),
             apsa.amount_remaining - NVL (apsa.discount_amount_available, 0)
                amount_remaining,
             ieba.BANK_ACCOUNT_NUM,
             pac_eft_pkg.extract_account_number (ieba.BANK_ACCOUNT_NUM),
             aia.invoice_currency_code currency
        INTO l_vendor_name,
             l_vendor_num,
             l_invoice_num,
             l_invoice_description,
             l_operation_amount,
             l_supplier_clabe_number,
             l_supplier_account_number,
             l_operation_currency
        FROM AP_PAYMENT_SCHEDULES_ALL apsa,
             ap_invoices_all aia,
             apps.ap_suppliers aps,
             ap.ap_supplier_sites_all apss,
             apps.iby_ext_bank_accounts ieba,
             apps.iby_account_owners iao,
             apps.iby_ext_banks_v ieb,
             iby_pmt_instr_uses_all uses,
             apps.iby_ext_bank_branches_v iebb
       WHERE     1 = 1
             AND aia.VENDOR_ID = aps.VENDOR_ID
             AND apsa.invoice_id = aia.invoice_id
             AND aia.invoice_id = p_invoice_id
             AND aps.vendor_id = apss.vendor_id
             AND iao.account_owner_party_id = aps.party_id
             AND ieba.ext_bank_account_id = iao.ext_bank_account_id
             AND ieb.bank_party_id = iebb.bank_party_id
             AND ieba.branch_id = iebb.branch_party_id
             AND ieba.bank_id = ieb.bank_party_id
             AND uses.instrument_id = ieba.ext_bank_account_id
             AND uses.end_date IS NULL;



      INSERT INTO PAC_EFT_BATCH_LINES (eft_line_id,
                                       eft_line_number,
                                       line_status,
                                       batch_id,
                                       invoice_id,
                                       invoice_num,
                                       bank_account_id,
                                       supplier_account_number,
                                       supplier_clabe_account,
                                       paying_account_number,
                                       operation_currency,
                                       operation_amount,
                                       payment_description,
                                       tsc_supplier_name,
                                       --   tsc_account_type             ,
                                       --   tsc_bank_number              ,
                                       --   tsc_reference_number         ,
                                       --   tsc_available                ,
                                       currency_code,
                                       delete_mark,
                                       created_by --   creation_date                 ,
                                                 --   operation_code_in            ,
                                                 --   supplier_account_number_in    ,
                                                 --   paying_account_number_in      ,
                                                 --   operation_status_in          ,
                                                 --   transmision_date_in        ,
                                                 --   acceptance_num_or_reject_in  ,
                                                 --   bank_batch_no_in             ,
                                                 --   operation_number_in          ,
                                                 --   operation_currency_in        ,
                                                 --   operation_amount_in          ,
                                                 --   tsc_supplier_name_in        ,
                                                 --   payment_description_in        ,
                                                 --   numeric_reference_in        ,
                                                 --   interbank_number             ,
                                                 --   tsc_bank_number_in            ,
                                                 --   tsc_account_type_in           ,
                                                 --   tsc_available_in              ,
                                                 --   tax_receipt_in                ,          --comprobante fiscal 1/0
                                                 --   tax_payer_id_in               ,
                                                 --   vat_amount_in
                                       )
           VALUES (new_line_id,
                   p_line_number,
                   'PENDIENTE',
                   p_batch_id,
                   p_invoice_id,
                   l_invoice_num,
                   l_bank_account_id,
                   l_supplier_account_number,
                   l_supplier_clabe_number,
                   l_bank_account_number,
                   l_operation_currency,
                   l_operation_amount,
                   l_invoice_description,
                   l_vendor_name,
                   l_currency_code,
                   'N',
                   1155);

      UPDATE ap_invoices_all
         SET attribute15 = 'Y'
       WHERE invoice_id = p_invoice_id;

      output_msg := 'S';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         output_msg := 'Error en los datos del proveedor.' || sqlerrm;
   END;

   PROCEDURE remove_emp (employee_id NUMBER)
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE read_data_form
   IS
   BEGIN
      UPDATE ap_invoices_all aia
         SET aia.attribute15 = 'N'
       WHERE EXISTS
                (SELECT pev.invoice_id
                   FROM PAC_EFT_V pev
                  WHERE pev.invoice_id = aia.invoice_id)
             AND aia.attribute15 <> 'Y';

      COMMIT;
      DBMS_UTILITY.EXEC_DDL_STATEMENT ('TRUNCATE TABLE PAC_EFT_TB_TMP');



      INSERT INTO pac_eft_tb_tmp
         (SELECT 'N',
                 vendor_name,
                 vendor_num,
                 invoice_id,
                 invoice_date,
                 invoice_num,
                 description,
                 due_date,
                 invoice_amount,
                 amount_paid,
                 amount_remaining,
                 currency,
                 exchange_rate,
                 exchange_date,
                 approval,
                 post_status
            FROM pac_eft_v
           WHERE NVL (to_process, 'N') <> 'Y');

      DELETE FROM PAC_EFT_TB_TMP
            WHERE APPROVAL <> 'APPROVED' AND POST_STATUS <> 'Y';

      COMMIT;
   END;



   PROCEDURE create_export_layout (p_batch_id   IN     NUMBER,
                                   v_file          OUT VARCHAR2,
                                   output_msg      OUT VARCHAR2)
   IS
      out_file                UTL_FILE.File_Type;
      
      linebuf                 VARCHAR2 (1999);
      v_total                 NUMBER := 1;
      v_database              VARCHAR2 (30);
      v_db_desc               VARCHAR2 (255);
      v_rep_url               VARCHAR2 (255);
      v_ret_val               VARCHAR2 (2000);
      v_export_dir            VARCHAR2 (30);
      lv_error_text           VARCHAR2 (255);
      l_bbva_mix              NUMBER;
      filename                VARCHAR2 (800)
         :=    'pago_'
            || p_batch_id
            || '_bbva_'
            || TO_CHAR (SYSDATE, 'DDMONRRRR')
            || '.txt';

      b_file_length           BINARY_INTEGER;
      v_checksum              RAW (2048);
      dst_blob                BLOB;
      b_file                  BFILE;
      p_file                  VARCHAR2 (80);


      v_sequence_number       VARCHAR2 (8);
      loop_sequence_ctrl      NUMBER;
      loop_sequence_counter   NUMBER := 0;
      l_random_reference      VARCHAR2 (80);


      CURSOR export_cur
      IS
           SELECT tsc_supplier_name,
                  supplier_account_number,
                  paying_account_number,
                  supplier_clabe_account,
                  operation_currency,
                  SUM (operation_amount) operation_amount                
             FROM PAC_EFT_BATCH_LINES
            WHERE batch_id = p_batch_id
         GROUP BY tsc_supplier_name,
                  supplier_account_number,
                  paying_account_number,
                  supplier_clabe_account,
                  operation_currency;                     
                  
                  
    CURSOR export_cur_BANAMEX
      IS
           SELECT tsc_supplier_name,
                  supplier_account_number,
                  paying_account_number,
                  supplier_clabe_account,
                  operation_currency,
                  SUM (operation_amount) operation_amount,
                  INVOICE_ID,                           --  IPONCE 2017.07.31
                  PAYMENT_DESCRIPTION                   --  IPONCE 2017.08.02           
             FROM PAC_EFT_BATCH_LINES
            WHERE batch_id = p_batch_id
         GROUP BY tsc_supplier_name,
                  supplier_account_number,
                  paying_account_number,
                  supplier_clabe_account,
                  operation_currency,
                  INVOICE_ID,                           --  IPONCE 2017.07.31
                  PAYMENT_DESCRIPTION;                  --  IPONCE 2017.08.02                        
                  
                  
    --IPONCE    2017.07.27
    --Variables de BANAMEX
    
    var_bank_account_name       PAC_EFT_BATCH_HEADER.BANK_ACCOUNT_NAME%TYPE;    
    var_bank_name               APPS.IBY_EXT_BANKS_V.BANK_NAME_ALT%TYPE;
    var_branch_number           APPS.CE_BANK_BRANCHES_V.BRANCH_NUMBER%TYPE;     
    var_account_number          PAC_EFT_BATCH_HEADER.BANK_ACCOUNT_NUM%TYPE;
        
          
   BEGIN
   
    SELECT PEBH.BANK_ACCOUNT_NAME       --  IPONCE 2017.07.27
      INTO var_bank_account_name        --  IPONCE 2017.07.27
      FROM PAC_EFT_BATCH_HEADER PEBH    --  IPONCE 2017.07.27
     WHERE 1 = 1                        --  IPONCE 2017.07.27
       AND PEBH.BATCH_ID = P_BATCH_ID;  --  IPONCE 2017.07.27
        
    IF  var_bank_account_name LIKE '%BANCOMER%' THEN --IPONCE 2017.07.24
      BEGIN
         BEGIN
            SELECT COUNT (supplier_clabe_account)
              INTO l_bbva_mix
              FROM (  SELECT SUBSTR (supplier_clabe_account, 1, 3)
                                supplier_clabe_account
                        FROM PAC_EFT_BATCH_LINES
                       WHERE batch_id = p_batch_id
                    GROUP BY SUBSTR (supplier_clabe_account, 1, 3));

            IF l_bbva_mix > 1
            THEN
               filename :=
                     'pago_'
                  || p_batch_id
                  || '_mixto_'
                  || TO_CHAR (SYSDATE, 'DDMONRRRR')
                  || '.txt';
            END IF;

            out_file := UTL_FILE.Fopen ('EFT_BANCOMER', filename, 'w');
         Exception when others then
         output_msg:='ERROR al definir  EFT_BANCOMER: ' || sqlerrm;
         
         END;



         SELECT COUNT (eft_line_id)
           INTO loop_sequence_ctrl
           FROM PAC_EFT_BATCH_LINES
          WHERE batch_id = p_batch_id;


         FOR export_rec IN export_cur
         LOOP
            /* Code for bancomer provider accont  */
            IF SUBSTR (export_rec.supplier_clabe_account, 1, 3) = '012'
            THEN
               linebuf := NULL;

               IF l_bbva_mix > 1
               THEN
                  linebuf := 'PTC';
               END IF;



               linebuf :=
                  linebuf
                  || LPAD (TO_CHAR (export_rec.supplier_account_number),
                           18,
                           '0');              --attribute 1 lenght 18 pos 1-18
               linebuf :=
                  linebuf
                  || LPAD (TO_CHAR (export_rec.paying_account_number),
                           18,
                           '0');             --attribute 2 lenght 18 pos 19-36

               IF export_rec.operation_currency = 'MXN'
               THEN
                  linebuf := linebuf || 'MXP'; --attribute 3 lenght 3 pos 37-39
               ELSE
                  linebuf := linebuf || export_rec.operation_currency;
               END IF;

               linebuf :=
                  linebuf
                  || LPAD (
                        TRIM (
                           TO_CHAR (export_rec.operation_amount,
                                    '999999999.00')),
                        16,
                        '0');                --attribute 4 lenght 16 pos 40-55
               --MODIFICACIøN PARA QUE SøLO ACEPTE ALFANUMøRICOS EN EL MOTIVO DE PAGO
               --21 AGOSTO 2013
               --ARS
               linebuf :=
                  linebuf
                  || RPAD (
                        SUBSTR (
                           REGEXP_REPLACE (
                                 'LOTE FACTURAS '
                              || p_batch_id
                              || ' '
                              || TO_CHAR (SYSDATE, 'DDMONRRRR'),
                              '[^a-zA-Z0-9 ]',
                              ''),
                           1,
                           30),
                        30,
                        ' ');
            /* Code for CLABE provider accont (Not Bancomer)  */
            ELSE
               SELECT TO_CHAR (ROUND (DBMS_RANDOM.VALUE (1000000, 9999999)))
                         num
                 INTO l_random_reference
                 FROM DUAL;             --Get a random reference 7 digits long

               linebuf := NULL;

               IF l_bbva_mix > 1
               THEN
                  linebuf := 'PSC';
               END IF;

               linebuf :=
                  linebuf
                  || LPAD (TO_CHAR (export_rec.supplier_clabe_account),
                           18,
                           '0');       --1 Asunto beneficiario - nømerico - 18
               linebuf :=
                  linebuf
                  || LPAD (TO_CHAR (export_rec.paying_account_number),
                           18,
                           '0');       --2  asunto solicitante - nømerico - 18


               linebuf := linebuf || 'MXP'; -- 3 divisa de la operaci€n - alfanum»rico - 3 Fijo MXP


               linebuf :=
                  linebuf
                  || LPAD (
                        TRIM (
                           TO_CHAR (export_rec.operation_amount,
                                    '999999999.00')),
                        16,
                        '0');      -- 4 importe  de la operaci€n - monto  - 16

               linebuf :=
                  linebuf
                  || RPAD (
                        SUBSTR (
                           REGEXP_REPLACE (export_rec.tsc_supplier_name,
                                           '[^a-zA-Z0-9 ]',
                                           ''),
                           1,
                           30),
                        30,
                        ' '); -- 5 titular asunto beneficiario - alfanum»rico - 30

               linebuf := linebuf || '40'; -- 6 tipo de cuenta - num»rico - 2   (40 para CLABE)

               linebuf :=
                  linebuf || SUBSTR (export_rec.supplier_clabe_account, 1, 3); -- 7 nømero del banco asunto beneficiario - num»rico - 3

               linebuf :=
                  linebuf
                  || RPAD (
                        SUBSTR (
                           REGEXP_REPLACE (
                                 'LOTE FACTURAS '
                              || p_batch_id
                              || ' '
                              || TO_CHAR (SYSDATE, 'DDMONRRRR'),
                              '[^a-zA-Z0-9 ]',
                              ''),
                           1,
                           30),
                        30,
                        ' ');         -- 8 motivo del pago - alfanum»rico - 30


               linebuf := linebuf || l_random_reference; -- 9 referencia num»rica - num»rico - 7
               linebuf := linebuf || 'H'; --10 Disponibilidad - alfanum»rico - 1
            END IF;

            -----
            -----
            -----
            UTL_FILE.Put_line (out_file, linebuf);
            DBMS_OUTPUT.put_line (linebuf);
         END LOOP;

        
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            UTL_FILE.Fclose (out_file);
            output_msg := 'NO DATA FOUND';
         WHEN UTL_FILE.WRITE_ERROR
         THEN
            DBMS_OUTPUT.PUT_LINE (
               'Operating system error occurred during the write operation.');
            output_msg :=
               'Operating system error occurred during the write operation.';
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (
               'Se ha producido un error inesperado: ' || SQLERRM);
            output_msg := 'Se ha producido un error inesperado: ' || SQLERRM;
      END;
    ELSIF   var_bank_account_name LIKE '%BANAMEX%' THEN --  IPONCE 2017.07.27
        /*************************************************************************/
        /*BEGIN     Bloque para pagos interbancarios BANAMEX    IPONCE 2017.07.27*/
        
         FOR export_rec IN export_cur_BANAMEX LOOP
            
            SELECT UNIQUE UPPER(IEB.BANK_NAME_ALT) 
              INTO var_bank_name
              FROM AP_PAYMENT_SCHEDULES_ALL apsa,
                   ap_invoices_all aia,
                   apps.ap_suppliers aps,
                   ap.ap_supplier_sites_all apss,
                   apps.iby_ext_bank_accounts ieba,
                   apps.iby_account_owners iao,
                   apps.iby_ext_banks_v ieb,
                   apps.iby_ext_bank_branches_v iebb
             WHERE     1 = 1
                   AND aia.VENDOR_ID = aps.VENDOR_ID
                   AND apsa.invoice_id = aia.invoice_id
                   AND aia.invoice_id = export_rec.invoice_id
                   AND aps.vendor_id = apss.vendor_id
                   AND iao.account_owner_party_id = aps.party_id
                   AND ieba.ext_bank_account_id = iao.ext_bank_account_id
                   AND ieb.bank_party_id = iebb.bank_party_id
                   AND ieba.branch_id = iebb.branch_party_id
                   AND ieba.bank_id = ieb.bank_party_id;
                   

            filename :=
                     'pago_'
                  || p_batch_id
                  || '_banamex_'
                  || TO_CHAR (SYSDATE, 'DDMONRRRR')
                  || '.txt';            

            out_file := UTL_FILE.Fopen ('EFT_BANAMEX', filename, 'w');       
            
            SELECT CBB.BRANCH_NUMBER
              INTO var_branch_number
              FROM CE_BANK_BRANCHES_V   CBB
             WHERE 1 = 1
               AND UPPER(CBB.BANK_NAME_ALT) = 'BANAMEX';
               
            SELECT PEBH.BANK_ACCOUNT_NUM
              INTO var_account_number
              FROM PAC_EFT_BATCH_HEADER PEBH
             WHERE 1 = 1
               AND BATCH_ID = p_batch_id;
            
            IF var_bank_name <> 'BANAMEX' THEN
                linebuf := '0301';
            ELSE
                linebuf := '0901';
            END IF;             
            
            linebuf := linebuf || TRIM(LPAD(var_branch_number, 4, 0));
            linebuf := linebuf || TRIM(LPAD(var_account_number, 20, 0));
            
            IF var_bank_name = 'BANAMEX' THEN
                IF    export_rec.supplier_clabe_account < 16 THEN
                    linebuf := linebuf || '06';
                ELSIF export_rec.supplier_clabe_account > 16 THEN
                    linebuf := linebuf || '03';
                END IF;
                
                linebuf := linebuf || '0000';
                linebuf := linebuf || TRIM(LPAD(export_rec.supplier_clabe_account, 20, 0));
                
            END IF;     
            
            linebuf := linebuf || TRIM(LPAD(TRUNC(export_rec.operation_amount), 12, 0));    
            linebuf := linebuf || RPAD(SUBSTR(TO_CHAR(TRUNC(export_rec.operation_amount,2), '999999999999.99'), INSTR(TO_CHAR(TRUNC(export_rec.operation_amount, 2), '999999999999.99'), '.')+1), 2,0);
            
            IF var_bank_name = 'BANAMEX' THEN
                IF      var_bank_account_name = 'BANAMEX MXN' THEN
                    linebuf := linebuf || '001';
                ELSIF   var_bank_account_name = 'BANAMEX DLS' THEN
                    linebuf := linebuf || '005';
                END IF;
            ELSE
                linebuf := linebuf || '001';
            END IF;     
            
            IF var_bank_name = 'BANAMEX' THEN
                linebuf := linebuf || TRIM(RPAD(TRANSLATE(export_rec.PAYMENT_DESCRIPTION,'0*~!#$%^()_-+=&#124}]{{/?.,><','0'),24,' '));
                linebuf := linebuf || TRIM(RPAD(TRANSLATE(export_rec.TSC_SUPPLIER_NAME,'0*~!#$%^()_-+=&#124}]{{/?.,><','0'),34,' '));
                linebuf := linebuf || TRIM(LPAD(TO_CHAR(SYSDATE,'DDMMRRRR'),10,0));
                linebuf := linebuf || '000';
                linebuf := linebuf || '000000';
                linebuf := linebuf || '0000';
            ELSE
                IF       export_rec.supplier_clabe_account < 16 THEN
                    linebuf := linebuf || '01';
                ELSIF    export_rec.supplier_clabe_account = 16 THEN
                    linebuf := linebuf || '03';
                ELSIF export_rec.supplier_clabe_account > 16 THEN
                    linebuf := linebuf || '40';
                END IF;
                
                linebuf := linebuf || TRIM(LPAD(export_rec.supplier_clabe_account, 20, 0));
                linebuf := linebuf || TRIM(RPAD(TRANSLATE(export_rec.PAYMENT_DESCRIPTION,'0*~!#$%^()_-+=&#124}]{{/?.,><','0'),40,' '));
                linebuf := linebuf || TRIM(LPAD(TO_CHAR(SYSDATE,'DDMMRRRR'),7,0));
                                
            END IF;                                                     
                   
         END LOOP;
        
        
        /*END       Bloque para pagos interbancarios BANAMEX    IPONCE 2017.07.27*/
    
    END IF; --IPONCE 2017.07.24
    
    /*************************************************************************/
    
        UTL_FILE.Fclose (out_file);

--         UPDATE PAC_EFT_BATCH_LINES
--            SET LINE_STATUS = 'EN CURSO'
--          WHERE batch_id = p_batch_id;

--         UPDATE PAC_EFT_BATCH_HEADER
--            SET BATCH_STATUS = 'Y'
--          WHERE batch_id = p_batch_id;

--         output_msg := 'S';

--         v_file := filename;

--         BEGIN
--            p_file := filename;
--            DBMS_LOB.createtemporary (dst_blob, TRUE);
--            b_file := BFILENAME ('EFT_BANCOMER', p_file);
--            DBMS_LOB.open (b_file, DBMS_LOB.lob_readonly);
--            b_file_length := DBMS_LOB.getlength (b_file);
--            DBMS_OUTPUT.put_line (TO_CHAR (b_file_length));
--            DBMS_OUTPUT.put_line ( (p_file));


--            DBMS_LOB.loadfromfile (dst_blob, b_file, b_file_length);

--            UPDATE PAC_EFT_BATCH_HEADER
--               SET OUTPUT_BLOB_FILE = dst_blob
--             WHERE batch_id = p_batch_id;

--            DBMS_LOB.fileclose (b_file);
--         END;

--         COMMIT;
    
    /*************************************************************************/
    
   END;
--PROCEDURE increase_sal(employee_id NUMBER, salary_incr NUMBER) IS
--   curr_sal NUMBER;
--   BEGIN
--      SELECT salary INTO curr_sal FROM employees
--      WHERE employees.employee_id = increase_sal.employee_id;
--      IF curr_sal IS NULL
--         THEN RAISE no_sal;
--      ELSE
--         UPDATE employees
--         SET salary = salary + salary_incr
--         WHERE employee_id = employee_id;
--      END IF;
--   END;
--PROCEDURE increase_comm(employee_id NUMBER, comm_incr NUMBER) IS
--   curr_comm NUMBER;
--   BEGIN
--      SELECT commission_pct
--      INTO curr_comm
--      FROM employees
--      WHERE employees.employee_id = increase_comm.employee_id;
--      IF curr_comm IS NULL
--         THEN RAISE no_comm;
--      ELSE
--         UPDATE employees
--         SET commission_pct = commission_pct + comm_incr;
--      END IF;
--   END;
END PAC_EFT_PKG;
/
