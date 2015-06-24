CREATE OR REPLACE PROCEDURE APPS."XXCALV_GENERA_ARCHIVO_CFD" ( errbuf       OUT NOCOPY VARCHAR2
                                                           , retcode      OUT NOCOPY VARCHAR2
                                                           , p_org_id     IN  NUMBER
                                                           , p_tipo_doc   IN  VARCHAR2
                                                           , p_origen     IN  NUMBER
                                                           , p_doc_ini    IN  NUMBER
                                                           , p_doc_fin    IN  NUMBER
                                                           , p_depto      IN  NUMBER
                                                           , p_extemp     IN  NUMBER
                                                           , p_fecha_ini  IN  VARCHAR2
                                                           , p_fecha_fin  IN  VARCHAR2)  AUTHID CURRENT_USER
IS

   --variables para manipulaci?n de archivo TXT 
   v_manejador    utl_file.file_type;
   v_directorio   VARCHAR2(250 BYTE) := 'CALVARIO';
   v_archivo      VARCHAR2(120 BYTE); 
   v_addenda      VARCHAR2(120 );
   v_fechoc       VARCHAR2(100);

   --control y espera del lanzamiento del concurrente que copia archivo
   v_request_id NUMBER;
   waiting     BOOLEAN;
   phase      VARCHAR2(80 BYTE);
   status     VARCHAR2(80 BYTE);
   dev_phase  VARCHAR2(80 BYTE);
   dev_status VARCHAR2(80 BYTE);
   message    VARCHAR2(4000 BYTE);
        
   --variables para taras, totales y direcci?n del CEDIS emisir
   v_iva_total NUMBER := 0;
   v_iva_global NUMBER := 0;
   v_total_lin NUMBER := 0;
   v_importe_total NUMBER := 0;
   v_imp_total_ped NUMBER := 0;
   v_total NUMBER := 0;
   v_cantidad_total NUMBER := 0;
   v_cedis VARCHAR2(300);
   v_calle VARCHAR2(300);
   v_calle2 VARCHAR2(300);
   v_numext VARCHAR2(300);
   v_colonia VARCHAR2(300);
   v_ciudad VARCHAR2(300);
   v_estado VARCHAR2(300);
   v_pais VARCHAR2(300);
   v_postal VARCHAR2(300);
   v_ean VARCHAR2(150 BYTE);
   v_unidad VARCHAR2(100 BYTE) := NULL;
   v_sec_uom VARCHAR2(180) := NULL;
   v_unidad_pdf VARCHAR2(180) := NULL;
   
   --variables para direcci?n de cedis receptor
   v_rfc    VARCHAR2(300) := 'RFC';
   v_calent VARCHAR2(300);
   v_nexent VARCHAR2(300);
   v_ninent VARCHAR2(300);
   v_colent VARCHAR2(300);
   v_munent VARCHAR2(300);
   v_estent VARCHAR2(300);        
   v_paient VARCHAR2(300);
   v_codent VARCHAR2(300);
                          
   --variables para certificado zoosanitario
   v_transp VARCHAR2(240);
   v_salida VARCHAR2(240); 
   v_sello_L VARCHAR2(240); 
   v_sello_LA VARCHAR2(240);
   v_sello_T VARCHAR2(240);
   v_sello_TA VARCHAR2(240);
   
   --variables para identificar el m?todo de pago
   v_mpago VARCHAR2(240) := 'N';
   v_cuenta VARCHAR2(240) := 'N';

   --cursor de cabecera de las facturas
   CURSOR headers_cur(p_org_id_h NUMBER,p_tipo_doc_h VARCHAR2,p_origen_h NUMBER,
                      p_doc_ini_h NUMBER,p_doc_fin_h NUMBER, p_fecha_ini_h VARCHAR2, p_fecha_fin_h VARCHAR2) IS
            SELECT trax.doc_sequence_value factura --trax.trx_number factura
                 , trax.customer_trx_id id_factura
                 , trax.org_id org_id
                 , trax.primary_salesrep_id
                 , trax.cust_attribute1 numero_proveedor
                 , trax.cust_attribute2 cadena
--                 , trax.cust_attribute12 gln
                 , trax.cust_attribute12 gln
                 , trax.cust_attribute4 no_tienda
                 , trax.cust_attribute7 tipo_adenda
                 , trax.ship_attribute1 ship_numero_proveedor
                 , trax.ship_attribute2 ship_cadena
--                 , trax.ship_attribute3 ship_gln
                 , decode(trax.cust_attribute7,'OXXO',decode(org_id,88,'10CTL',89,'10CTL','99AAA'),trax.ship_attribute3) ship_gln
                 , trax.ship_attribute4 ship_no_tienda
                 , trax.rac_bill_party_type tipo_de_cliente
                 , ( SELECT seq.attribute1 /*,seq.name, seq.doc_sequence_id*/
                       FROM fnd_document_sequences seq
                      WHERE seq.table_name = 'RA_CUSTOMER_TRX_ALL' AND seq.doc_sequence_id = trax.doc_sequence_id ) serie
                 , ( SELECT seq.attribute2 /*,seq.name, seq.doc_sequence_id*/
                       FROM fnd_document_sequences seq
                      WHERE seq.table_name = 'RA_CUSTOMER_TRX_ALL' AND seq.doc_sequence_id = trax.doc_sequence_id ) num_aprob
                 , ( SELECT seq.attribute3 /*,seq.name, seq.doc_sequence_id*/
                       FROM fnd_document_sequences seq
                      WHERE seq.table_name = 'RA_CUSTOMER_TRX_ALL' AND seq.doc_sequence_id = trax.doc_sequence_id ) periodo_aprob          
                 --, trax.ctt_type_name 
                 --, trax.cust_trx_type_id tipo_transaccion
                 --, trax.bs_batch_source_name fuente
                 , CASE
                      WHEN upper ( trax.ctt_class ) LIKE 'INV' THEN 'FACTURA'
                      WHEN upper ( trax.ctt_class ) LIKE 'CM'  THEN 'NOTA DE CREDITO'
                      WHEN upper ( trax.ctt_class ) LIKE 'DM'  THEN 'NOTA DE CARGO'
                   END fuente
                 , CASE
                      WHEN upper ( trax.ctt_class ) LIKE 'INV' THEN 1
                      WHEN upper ( trax.ctt_class ) LIKE 'CM'  THEN 2
                      WHEN upper ( trax.ctt_class ) LIKE 'DM'  THEN 3
                   END tipo_transaccion1
                 , to_char(trax.trx_date,'DD-MM-YYYY') fechar
                 , to_char(trax.trx_date,'YYYY-MM-DD')||'T'||to_char(sysdate,'HH24:MI:SS') fecha_factura --to_char(trax.trx_date,'HH:MI:SS') fecha_factura
                 , to_char(trax.trx_date,'YYYY-MM-DD')||'T'||to_char(sysdate,'HH24:MI:SS') feccon --'00:00:00' feccon
                 , to_char(trax.trx_date,'yyyy-mm-dd') fecha_factura_oxxo
                 , to_char(trax.trx_date,'yyyy-mm-dd')||'T'||to_char(sysdate,'HH24:MI:SS') fecha_factura_rem --to_char(trax.trx_date,'hh:mi:ss') fecha_factura_rem
                 , trax.organization_name_phonetic cliente_matriz
                 , trax.rac_bill_party_id no_cliente
                 , trax.rac_bill_to_customer_name nombre_cliente
                 --, trax.rac_bill_party_type tipo_persona
                 , 'CUSTOMER' tipo_persona
                 , trax.bill_to_taxpayer_id rfc
                 , trax.rac_bill_party_tax_reference rfc_extranjeros
                 , trax.raa_bill_to_address1 calle
                 , REPLACE(trax.raa_bill_to_address2,'N/A','') no_exterior
                 , REPLACE(trax.raa_bill_to_address3_db,'N/A','') no_interior             
                 , REPLACE(trax.raa_bill_to_address4,'N/A','') colonia
                 , lpad(trax.raa_bill_to_postal_code,5,'0') codigo_postal
                 , trax.raa_bill_to_city ciudad
                 , decode(trax.raa_bill_to_state,'DISTRITO FEDERAL','DF',trax.raa_bill_to_state) estado
                 , REPLACE(trax.ft_bill_to_country,'?','E') pais
                 --, decode(trax.bill_to_taxpayer_id,'UNA2907227Y5','Cheque Nominativo - Banamex, Cuenta: 1830','TSO991022PB6','NO IDENTIFICADO','PAGO EN UNA SOLA EXHIBICION') metodo_pago
                 , 'PAGO EN UNA SOLA EXHIBICION' forma_pago
                 , decode(trax.rat_term_name,'0',1,2) condicion_pago
                 , nvl(trim(REPLACE(REPLACE(REPLACE(trax.rat_term_name, 'INMEDIATO', '' ),'DIAS',''),'CONTADO','')),0) dias_pago
                 , trax.invoice_currency_code tipo_moneda
                 --, decode(trax.invoice_currency_code,'MXN',0,1) tipo_cambio --paco
                 , decode(trax.invoice_currency_code,'MXN',1,exchange_rate) tipo_cambio
                 , decode(trax.invoice_currency_code,'MXN',0,1) sw_tc
                 , trax.primary_salesrep_id no_vendedor
                 , trax.rac_ship_to_customer_id no_comprador
                 --, trax.ship_to_customer_id ship_from
                 --, trax.legal_entity_id ship_from
                 , (SELECT attribute2 
                      FROM hr_all_organization_units 
                     WHERE organization_id = p_org_id_h) ship_from 
                 , trax.rac_ship_to_customer_id ship_to
                 , trax.rac_ship_to_customer_id no_receptor
                 , nvl(SUBSTR(trax.rac_ship_to_customer_name,1, INSTR(trax.rac_ship_to_customer_name, '(')-1),trax.rac_ship_to_customer_name) nombre_receptor
                 --, trax.rac_ship_to_customer_name nombre_receptor
                 , 'CUSTOMER' tipo_persona_recept
                 , trax.ship_to_taxpayer_id rfc_receptor
                 , trax.raa_ship_to_address1 direccion_receptor1
                 , (SELECT lpad(oe.cust_po_number,10,'0') 
                      FROM oe_order_headers_all oe 
                     WHERE oe.order_number = nvl(trax.ct_reference,0) 
                       AND  ROWNUM = 1 
                       AND oe.org_id = p_org_id_h) no_order_compra 
                 --Se agregaron 3 campos adicionales para colocarlos en la descripci?n de las lineas para controlar los pedimentos
                 , (SELECT to_date(attribute9,'YYYY-MM-DD HH24:MI:SS')
                      FROM oe_order_headers_all oe 
                     WHERE oe.order_number = nvl(trax.ct_reference,0) 
                       AND  ROWNUM = 1 
                       AND oe.org_id = p_org_id_h) fech_ped
                 , (SELECT attribute8 
                      FROM oe_order_headers_all oe 
                     WHERE oe.order_number = nvl(trax.ct_reference,0) 
                       AND  ROWNUM = 1 
                       AND oe.org_id = p_org_id_h) num_ped
                 , (SELECT attribute12
                      FROM oe_order_headers_all oe 
                     WHERE oe.order_number = nvl(trax.ct_reference,0) 
                       AND  ROWNUM = 1 
                       AND oe.org_id = p_org_id_h) aduana
                 -----------------------------------------------------------------------------------------------------------------      
                 , trax.raa_ship_to_address2 direccion_receptor2
                 , REPLACE(trax.raa_ship_to_address3_db,'N/A','') direccion_receptor3
                 , REPLACE(trax.raa_ship_to_address3,'N/A','') direccion_receptor4             
                 , lpad(trax.raa_ship_to_postal_code,5,'0') codigo_postal_recept
                 , trax.raa_ship_to_city ciudad_receptor
                 , decode(trax.raa_ship_to_state,'DISTRITO FEDERAL','DF',trax.raa_ship_to_state) estado_receptor
                 , REPLACE(decode(trax.raa_ship_to_county,'MX','MEXICO',trax.raa_ship_to_county),'?','E') pais_receptor
                 , email
                 , nvl(trax.ct_reference,0) orden_compra
                 , trax.interface_header_attribute1 folio_pedido
                 , to_char(trax.gd_gl_date,'YYYY-MM-DD') fecha_compra
                 , 1 status_factura
                 --, to_char(trax.term_due_date,'dd/mm/yyyy') fecha_vencimiento
                 , to_char(trax.trx_date + ((SELECT NAME 
                                               FROM ra_terms_tl 
                                              WHERE term_id = trax.term_id 
                                                AND LANGUAGE = 'ESA'))  ,'dd/mm/yyyy hh:mi') fecha_vencimiento
                 , to_char(trax.ship_date_actual,'yyyy-mm-dd')||'T'||to_char(trax.ship_date_actual,'hh24:mi:ss') ship_date_actual
                 , trax.customer_class_code
                 , trax.cust_trx_type_id
              FROM ra_customer_trx_partial_cfd trax
             WHERE 1=1
               --and trax.customer_trx_id in (104900,105400,105900,106000)
               AND trax.org_id = p_org_id_h
               AND trax.cust_trx_type_id = p_origen_h
               AND trax.ctt_class = nvl (p_tipo_doc_h,trax.ctt_class)
--               AND to_number(trax.trx_number) BETWEEN nvl ( p_doc_ini_h, to_number(trax.trx_number)) 
--                                                  AND nvl ( p_doc_fin_h, to_number(trax.trx_number))
               AND to_number(trax.doc_sequence_value) BETWEEN nvl ( p_doc_ini_h, to_number(trax.doc_sequence_value))
                                                  AND nvl ( p_doc_fin_h, to_number(trax.doc_sequence_value))
               AND trunc(trax.trx_date) BETWEEN trunc(NVL(to_date(p_fecha_ini_h,'RRRR/MM/DD HH24:MI:SS'),trax.trx_date))
                                            AND trunc(NVL(to_date(p_fecha_fin_h,'RRRR/MM/DD HH24:MI:SS'),trax.trx_date))           
             --ORDER BY to_number(trax.trx_number);
             ORDER BY to_number(trax.doc_sequence_value);


   --cursor de las l?neas de las facturas
   CURSOR lines_cur (p_customer_trx_id NUMBER) IS
        SELECT inv_item_id, 
               -----------------------------------------------------------------  
               -- Cambio solicitado por Ventas, quitar FRAGIL, dejar s?lo la F.
               -- 25 FEB 2013, Abrahan Rinc?n.
               -- descripcion,
               REPLACE(descripcion,'FRAGIL','') descripcion,
               ----------------------------------------------------------------- 
               sum(cant_facturada) cant_facturada, 
               precio_unitario,  
               uom_line, 
               sum(cantidad_secundaria) cantidad_secundaria,
               uom, 
               uom2, 
               tasa_impuesto, 
               sum(ttl_impuesto) ttl_impuesto, 
               sum(precio_neto) precio_neto,
               --xxcalv_calcula_tara_cfd(:p_org_id,inv_item_id,sum(cantidad_secundaria)) tara
               tara*sum(cantidad_secundaria) tara
          FROM (  SELECT lineas.line_id
                       , lineas.linea
                       , lineas.tipo_linea
                       , lineas.inv_item_id
                       , lineas.code_bar 
                       , lineas.serial_code
                       --, lineas.descripcion
--                       , REPLACE(
--                          REPLACE( 
--                            REPLACE(
--                              REPLACE( 
--                                REPLACE(
--                                  REPLACE(lineas.descripcion,':',' ')
--                                ,'&',' ')
--                              ,'/',' ')
--                            ,',',' ')
--                          ,'+',' ')
--                        ,'%',' ') descripcion
                       , tara
                       , REGEXP_REPLACE(lineas.descripcion, '[^a-zA-Z0-9. ]', '') descripcion 
                       , sum(lineas.cantidad_real_trx) cantidad_real_trx
                       , sum(lineas.cant_facturada) cant_facturada 
                       , sum(lineas.cant_credito ) cant_credito
                       , lineas.precio_unitario
                       , lineas.uom_line
                       , sum(lineas.cantidad_secundaria) cantidad_secundaria
                       , lineas.uom
                       , lineas.uom2
                       , lineas.tasa_impuesto
                       , lineas.folio_pedido
                       , sum(lineas.ttl_impuesto) ttl_impuesto
                       , sum(lineas.precio_neto) precio_neto
                       , lineas.descuento
                       , lineas.pedimento
                       , lineas.fecha_pedimento
                       , lineas.aduana
                  FROM (SELECT   ctl.interface_line_attribute6 line_id
                               , ctl.line_number linea
                               , ctl.line_type tipo_linea
                               , ctl.inventory_item_id inv_item_id
                               , '' code_bar 
                               , '' serial_code
                               --, trim(ctl.description||', '||(SELECT meaning
                               , xxcalv_calcula_tara_cfd(ctl.interface_line_attribute6) tara
                               , trim(ctl.description||REPLACE(xxcalv_grade_desc(ctl.interface_line_attribute6),'CASCADO CASCADO','CASCADO')||', ' || (SELECT meaning
                                                                                                                    FROM fnd_lookup_values 
                                                                                                                   WHERE lookup_type = 'CREDIT_MEMO_REASON'
                                                                                                                     AND lookup_code = ctl.reason_code
                                                                                                                     AND LANGUAGE = 'ESA')  
                                                                                                                 ) descripcion
                               , decode(ctl.quantity_invoiced,NULL,abs(ctl.quantity_credited),ctl.quantity_invoiced) cantidad_real_trx
                               --,(select oel.ordered_quantity2 from  oe_order_lines_all oel where oel.line_id = ctl.interface_line_attribute6 ) cant_facturada
                               , nvl ( decode(ctl.quantity_invoiced, NULL, abs(ctl.quantity_credited), ctl.quantity_invoiced ) ,1) cant_facturada 
                               , '' /*ctl.quantity_credited*/ cant_credito
                               , nvl(abs(ctl.unit_selling_price),0) precio_unitario
                               , decode(upper(ctl.uom_code) 
                                         ,'CJ' ,'CA'
                                         ,'CJA','CA'
                                         ,'CJS','CA'
                                         ,'PZ','EA'
                                         ,'KGS','KGM'
                                         ,'KG','KGM'
                                         ,'PZ','EA'
                                         ,'PZS','EA'
                                         ,'PZS','EA'
                                         , ctl.uom_code
                                 ) uom_line
                               , (SELECT oel.ordered_quantity2 
                                    FROM oe_order_lines_all oel 
                                   WHERE oel.line_id = ctl.interface_line_attribute6 
                                 ) cantidad_secundaria
                               --, (select oel.ordered_quantity_uom2  from  oe_order_lines_all oel where oel.line_id = ctl.interface_line_attribute6 ) uom
                               , decode((SELECT upper(oel.order_quantity_uom) 
                                           FROM oe_order_lines_all oel 
                                          WHERE oel.line_id = ctl.interface_line_attribute6) 
                                         ,'CJ' ,'CA'
                                         ,'CJA','CA'
                                         ,'CJS','CA'
                                         ,'PZ','EA'
                                         ,'KGS','KGM'
                                         ,'KG','KGM'
                                         ,'PZ','EA'
                                         ,'PZS','EA'
                                         ,'PZS','EA'
                                         ,(SELECT upper(oel.order_quantity_uom) 
                                             FROM oe_order_lines_all oel 
                                            WHERE oel.line_id = ctl.interface_line_attribute6)
                                       ) uom
                               , decode((SELECT upper(oel.ordered_quantity_uom2) 
                                           FROM oe_order_lines_all oel 
                                          WHERE oel.line_id = ctl.interface_line_attribute6 ) 
                                         ,'CJ' ,'CA'
                                         ,'CJA','CA'
                                         ,'CJS','CA'
                                         ,'PZ','EA'
                                         ,'KGS','KGM'
                                         ,'KG','KGM'
                                         ,'PZ','EA'
                                         ,'PZS','EA'
                                         ,'PZS','EA'
                                         ,(SELECT upper(oel.ordered_quantity_uom2)  
                                             FROM oe_order_lines_all oel 
                                            WHERE oel.line_id = ctl.interface_line_attribute6 )
                                       ) uom2
                               , nvl(tax.tax_rate,0) tasa_impuesto
                               , ctl.interface_line_attribute1 folio_pedido
                               , ((nvl(tax.tax_rate,0)/100) * abs( nvl(tax.taxable_amount,0) )) ttl_impuesto
                               --, ( decode( ctl.quantity_invoiced, null, (abs(ctl.quantity_credited) * abs(ctl.unit_selling_price)), (ctl.quantity_invoiced * ctl.unit_selling_price) ) ) precio_neto
                               --, round(( nvl ( decode(ctl.quantity_invoiced, null, abs(ctl.quantity_credited), ctl.quantity_invoiced ) ,1) * nvl(abs(ctl.unit_selling_price),0)  ),2) precio_neto
                               , abs(round((nvl(  ( decode( ctl.quantity_invoiced, NULL, (abs(ctl.quantity_credited) * abs(ctl.unit_selling_price)), (ctl.quantity_invoiced * ctl.unit_selling_price) ) ) , ctl.extended_amount)),2))  precio_neto
                               , '' descuento
                               , '' /*ctl.sales_order*/ pedimento
                               , '' /*ctl.sales_order_date*/ fecha_pedimento
                               , '' aduana
                          FROM ra_customer_trx_lines_all ctl
                             , ra_customer_trx_lines_all tax
                         WHERE ctl.line_type = 'LINE' 
                           AND ctl.customer_trx_id = nvl(p_customer_trx_id,ctl.customer_trx_id) 
                           AND ctl.org_id = p_org_id
                           AND tax.line_type(+) = 'TAX' 
                           AND ctl.customer_trx_id = tax.customer_trx_id(+) 
                           AND ctl.org_id = tax.org_id(+)
                           AND ctl.customer_trx_line_id = tax.link_to_cust_trx_line_id(+)
                    ) lineas 
            GROUP BY
               line_id
             , lineas.linea
             , lineas.tipo_linea
             , lineas.inv_item_id
             , lineas.code_bar 
             , lineas.serial_code
             , lineas.tara
             , lineas.descripcion
             --, lineas.cantidad_real_trx
             --, lineas.cant_facturada 
             --, lineas.cant_credito
             , lineas.precio_unitario
             , lineas.uom_line
             --, lineas.cantidad_secundaria
             , lineas.uom
             , lineas.uom2
             , lineas.tasa_impuesto
             , lineas.folio_pedido
             , lineas.ttl_impuesto
             --, lineas.precio_neto
             , lineas.descuento
             , lineas.pedimento
             , lineas.fecha_pedimento
             , lineas.aduana)
    GROUP BY inv_item_id, 
             tara,
             descripcion,
             precio_unitario,  
             uom_line, 
             uom, 
             uom2, 
             tasa_impuesto 
    ORDER BY 1;
    
    v_numext_soriana VARCHAR2(200) := NULL;

BEGIN
   BEGIN
       fnd_file.put_line (fnd_file.log,'Inicia facturaci?n');
       dbms_output.put_line('Inicia facturaci?n');
       --Conculta para obtener los datos del CEDIS que factura, en caso de ser Tehuac?n, entonces no trae nada
       SELECT fln.meaning CEDIS,
              fln.description Calle,
              fln.attribute9 Calle2,
              REPLACE(fln.tag,'N/A','') Exterior,  
              loc.address_line_2 Colonia,
              --town_or_city Ciudad,
              loc.region_2 Ciudad, 
              decode(upper(flv.description),'DISTRITO FEDERAL','DF',upper(flv.description)) Estado, 
              REPLACE(T.NLS_TERRITORY,'?','E') Pais, 
              loc.postal_code codigo_postal
         INTO v_cedis, v_calle, v_calle2, v_numext, v_colonia, v_ciudad, v_estado, v_pais, v_postal
         FROM hr_organization_units o,
              hr_lookups l,
              hr_lookups l2,
              hr_locations loc, 
              fnd_lookup_values flv, 
              fnd_territories T,
              fnd_lookup_values fln
        WHERE o.TYPE = l.lookup_code(+)
          AND l.lookup_type(+) = 'ORG_TYPE'
          AND o.internal_external_flag = l2.lookup_code(+)
          AND l2.lookup_type(+) = 'INTL_EXTL'
          AND o.location_id = loc.location_id(+)
          AND flv.lookup_type = 'PER_MX_STATE_CODES'
          AND flv.LANGUAGE = userenv('LANG')
          AND loc.region_1 = flv.lookup_code
          AND loc.country = T.territory_code
          AND fln.lookup_type = 'XXCALV_DIRECCIONES_CEDIS'
          AND fln.LANGUAGE = userenv('LANG')
          AND fln.lookup_code = organization_id 
          AND organization_id = p_org_id;
   EXCEPTION WHEN OTHERS THEN
        fnd_file.put_line (fnd_file.log,'Error inesperado al obtener calle y n?mero exterior de CEDIS. '||SQLERRM);
        dbms_output.put_line('Error inesperado al obtener calle y n?mero exterior de CEDIS. '||SQLERRM);
   END;

   fnd_file.put_line (fnd_file.log,'Comienza generaci?n de archivo');
   dbms_output.put_line('Error inesperado al obtener calle y n?mero exterior de CEDIS. '||SQLERRM);
    
    --SE ABRE CURSOR QUE CONTIENE Y RECORRE TODAS LAS N FACTURAS
   FOR HED_REC IN HEADERS_CUR(P_ORG_ID, P_TIPO_DOC, P_ORIGEN, P_DOC_INI, P_DOC_FIN, P_FECHA_INI, P_FECHA_FIN) LOOP
--    V_ADDENDA := HED_REC.TIPO_ADENDA;
--    IF (nvl(V_ADDENDA,'OTRO') <> 'SORIANA') OR (nvl(V_ADDENDA,'OTRO') = 'SORIANA' AND HED_REC.FACTURA BETWEEN 38578  AND 38578 ) THEN
       IF (HED_REC.RFC IS NULL) AND (HED_REC.RFC_RECEPTOR IS NULL) THEN
           v_rfc := 'NULO';
           fnd_file.put_line (fnd_file.log,'No se encontro RFC del cliente, no es posible generar la factura.');
       ELSE
           BEGIN
--                SELECT nvl(upper(description),'N'), nvl(upper(attribute15),'N')
--                  INTO v_mpago, v_cuenta
--                  FROM fnd_lookup_values_vl flv
--                 WHERE flv.lookup_type = 'XXCALV_CUENTAS_FE'
--                   AND REPLACE(upper(meaning),'-','') = REPLACE(upper(HED_REC.RFC),'-','');
--
--             CAMBIO SOLICITADO POR EL SR #108990
                SELECT 'N', 'N'
                  INTO v_mpago, v_cuenta
                  FROM dual;
--             CAMBIO SOLICITADO POR EL SR #108990
           EXCEPTION WHEN others THEN
                fnd_file.put_line (fnd_file.log,'No se encontro metodo de pago.');
           END;                                 
            
           BEGIN     
                BEGIN
                     SELECT loc.address1,       --Calle
                            REPLACE(loc.address2,'N/A',''),       --No. Exterior
                            REPLACE(loc.address3,'N/A',''),       --No. Interior
                            loc.address4,       --Colonia
                            loc.city,           --Ciudad
                            --loc.province,
                            loc.state,          --Estado
                            REPLACE(terr.NLS_TERRITORY,'?','E'),  --Pais
                            lpad(loc.postal_code,5,'0')    --CP              
                       INTO v_calent, --calle del domicilio del receptor
                            v_nexent, --nexrec (reservado para especificar el dato de no. exterior del receptor)
                            v_ninent, --ninrec (reservado para especificar el dato de no. interior del receptor)
                            v_colent, --colrec (reservado para especificar el dato de colonia del receptor)
                            v_munent, --munrec (reservado para especificar el dato de municipio y/o delegacion del receptor)
                            v_estent, --estrec (reservado para especificar el dato de estado del receptor)        
                            v_paient, --pa?s del domicilio del receptor
                            v_codent --codrec (reservado para especificar el dato de codigo del receptor)
                       FROM hz_parties hz,
                            hz_party_sites hzs, 
                            hz_cust_acct_sites_all hzcs,
                            hz_locations loc,
                            fnd_territories_vl terr
                      WHERE hz.party_id = HED_REC.NO_CLIENTE 
                        AND hz.party_id = hzs.party_id
                        AND hzs.party_site_id = hzcs.party_site_id
                        AND hzs.location_id = loc.location_id
                        AND ship_to_flag = 'P'
                        AND terr.territory_code = loc.country;
                EXCEPTION WHEN OTHERS THEN
                     fnd_file.put_line (fnd_file.log,'Error inesperado al obtener direccion de tienda receptora. '||SQLERRM);
                     dbms_output.put_line('Error inesperado al obtener direccion de tienda receptora. '||SQLERRM);
                END;
                
                --INICIALIZACI?N DE VARIABLES TOTALES USADAS A NIVEL CABECERA
                v_iva_global := 0;
                v_iva_total := 0;
                v_total_lin := 0;
                v_importe_total := 0;
                v_cantidad_total := 0;
                v_total := 0;
                    
                --CREACI?N DEL ARCHIVO CORRESPONDIENTE A LA FACTURA
                V_ARCHIVO := upper(nvl(HED_REC.RFC,HED_REC.RFC_RECEPTOR)) ||'_'||HED_REC.RFC_RECEPTOR||'_'||HED_REC.SERIE||'_'||TO_CHAR(HED_REC.FACTURA)||'.txt';
                V_MANEJADOR := UTL_FILE.FOPEN (V_DIRECTORIO, V_ARCHIVO, 'W');
                    
                V_TOTAL := 0;
                V_IMP_TOTAL_PED := 0;
                
                BEGIN
                    --TOTAL A NIVEL DOCUMENTO
                    FOR LIN_REC IN LINES_CUR (HED_REC.ID_FACTURA) LOOP
                        V_TOTAL := V_TOTAL + LIN_REC.PRECIO_NETO + LIN_REC.TTL_IMPUESTO;
                    END LOOP;
                EXCEPTION WHEN OTHERS THEN
                    FND_FILE.PUT_LINE (FND_FILE.LOG,'Error inesperado al obtener total de lineas de la factura. '||SQLERRM);
                    dbms_output.put_line('Error inesperado al obtener total de lineas de la factura. '||SQLERRM);
                END;

                BEGIN
                    --TOTAL DEL PEDIDO
                    SELECT round(sum(imp),2) importe
                      INTO v_imp_total_ped 
                      FROM (SELECT trx.doc_sequence_value num_factura,
                                   hed.order_number,lin.line_id,
                                   lin.sold_from_org_id,
                                   hr.NAME,
                                   b.description,b.inventory_item_id,
                                   lin.order_quantity_uom,
                                   lin.ordered_quantity qty,
                                   lin.ordered_quantity2 qty2,
                                   lin.unit_selling_price price,
                                   lin.ordered_quantity qty3,
                                   round(lin.unit_selling_price*lin.ordered_quantity,2) imp
                              FROM oe_order_headers_all hed,
                                   oe_order_lines_all lin,
                                   hz_parties party,
                                   hz_cust_accounts cust_acct,
                                   hr_all_organization_units hr,
                                   mtl_system_items_b b,
                                   oe_transaction_types_all tta,
                                   ra_customer_trx_all trx, 
                                   ra_customer_trx_lines_all trxl
                             WHERE 1=1
                               AND hed.header_id = lin.header_id
                               AND tta.transaction_type_id = lin.line_type_id
                               AND lin.sold_to_org_id = cust_acct.cust_account_id(+)
                               AND cust_acct.party_id = party.party_id(+)
                               AND hr.organization_id = lin.sold_from_org_id
                               AND b.inventory_item_id = lin.inventory_item_id
                               AND b.organization_id = tta.warehouse_id
                               AND tta.org_id = hr.organization_id
                               AND (   hed.flow_status_code IN ('CLOSED','CERRADO') 
                                    OR hed.flow_status_code IN ('BOOKED','REGISTRADO')
                                   )
                               AND lin.line_id = trxl.interface_line_attribute6
                               AND trxl.line_type = 'LINE'
                               AND trxl.interface_line_context = 'ORDER ENTRY'
                               AND trx.customer_trx_id = trxl.customer_trx_id
                               --AND trx.attribute9 IS NULL
                               AND trx.org_id = hed_rec.org_id
                               AND trx.cust_trx_type_id = hed_rec.cust_trx_type_id
                               --AND trx.ctt_class = nvl (p_tipo_doc_h,trax.ctt_class)
                               AND trx.customer_trx_id = hed_rec.id_factura
                               ORDER BY line_id
                             )
                         WHERE 1=1
                          GROUP BY num_factura
                     ORDER BY 1;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                    FND_FILE.PUT_LINE (FND_FILE.LOG,'No se encontr? pedido, sin embargo se generar? la factura. '||SQLERRM);
                    dbms_output.put_line('No se encontr? pedido, sin embargo se generar? la factura. '||SQLERRM);
                    V_IMP_TOTAL_PED := V_TOTAL;
                WHEN OTHERS THEN
                    FND_FILE.PUT_LINE (FND_FILE.LOG,'Error inesperado al obtener total de lineas del pedido. '||SQLERRM);
                    dbms_output.put_line('Error inesperado al obtener total de lineas del pedido. '||SQLERRM);
                END;

                -- SI EL IMPORTE TOTAL DE LAS LINEAS DE LA FACTURA ES IGUAL A LA SUMA TOTAL DE LAS LINEAS DEL PEDIDO            
                --IF V_TOTAL = V_IMP_TOTAL_PED THEN
                IF V_TOTAL = V_TOTAL THEN
                    -- CERTIFICADO ZOOSANITARIO
                    BEGIN
                        
                        --======================================================================-
                        -- Se agregó mnemónico FECHOC para manejar en la addenda de CHEDRAUI
                        -- la fecha de la orden de compra
                        -- 24/03/2014
                        --======================================================================-
                        SELECT H.ATTRIBUTE1,--UNIDAD,
                               H.ATTRIBUTE11,--SALIDA
                               H.ATTRIBUTE3,-- SELLO_L,
                               H.ATTRIBUTE4,-- SELLO_LA,
                               H.ATTRIBUTE5,-- SELLO_T,
                               H.ATTRIBUTE10, --SELLO_TA,
                               to_char(H.REQUEST_DATE,'YYYY-MM-DD') -- FECHOC
                          INTO V_TRANSP, V_SALIDA, V_SELLO_L, V_SELLO_LA, V_SELLO_T, V_SELLO_TA, V_FECHOC
                          FROM OE_ORDER_HEADERS_ALL H
                         WHERE ORG_ID = HED_REC.ORG_ID
                           AND ORDER_NUMBER = HED_REC.ORDEN_COMPRA;
                        --======================================================================-   
                    EXCEPTION WHEN OTHERS THEN
                        FND_FILE.PUT_LINE (FND_FILE.LOG,'Error inesperado al buscar el Certificado Zoosanitario. '||SQLERRM);
                        dbms_output.put_line('Error inesperado al buscar el Certificado Zoosanitario. '||SQLERRM);
                    END;

                    FND_FILE.PUT_LINE (FND_FILE.LOG,'Escribiendo encabezado');
                    dbms_output.put_line('Escribiendo encabezado');
                    --ENCABEZADO DEL DOCUMENTO
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'E');
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'VERSIO  2.0');   --S
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'TRADPP  '||'MASTEDI');  --S(13)
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'CTPPRO  '||'ZZ');  --N(2)
-----------------------17 JUN 2012 --------------- ANEXO -----------------------------
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'REGIMEN  '||'REGIMEN DE ACTIVIDADES AGRICOLAS, GANADERAS, SILVICOLAS Y PESQUERAS');
                    IF v_mpago = 'N' AND v_cuenta = 'N' THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'CTAPAG  '||'NO IDENTIFICADO');  --N(2)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'METPAG  '||'CHEQUE NOMINATIVO O TRANSFERENCIA ELECTRONICA DE FONDOS O EFECTIVO');  --S  METODO DE PAGO
                    ELSE
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'CTAPAG  '||v_cuenta);  --N(2)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'METPAG  '||v_mpago);  --S  METODO DE PAGO                    
                    END IF;
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'FORPAG  '||HED_REC.FORMA_PAGO);  --S  FORMA DE PAGO
-----------------------17 JUN 2012 --------------- ANEXO -----------------------------
--                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'FOLFIS_ORI  '||HED_REC.FACTURA);  --N  N?MERO DEL FOLIO DEL DOCUMENTO
--                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'FOLFIS_ORI  '||HED_REC.SERIE);  --N  SERIE DEL FOLIO DEL DOCUMENTO
--                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'FECEXP_ORI  '||HED_REC.FECHA_FACTURA);  --S  FECHA DE EXPEDICI?N
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'NUMFOL  '||HED_REC.FACTURA);  --N  N?MERO DEL FOLIO DEL DOCUMENTO
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'SERFOL  '||HED_REC.SERIE);  --N  SERIE DEL FOLIO DEL DOCUMENTO
                    IF HED_REC.SERIE = 'FBTH' THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'PELCHA  '||'AVES DE DESECHO, PROHIBIDO PELECHAR, S?LO PARA SU SACRIFICIO.');  
                    ELSE
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'PELCHA  '||to_char(NULL));
                    END IF;
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'FECEXP  '||HED_REC.FECHA_FACTURA);  --S  FECHA DE EXPEDICI?N
--                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'NOAPRO  '||HED_REC.NUM_APROB);  --N  NUMERO DE APROBACI?N
--                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'AOAPRO  '||HED_REC.PERIODO_APROB);  -- A?O DE APROBACI?N

                    --======================================================================-
                    -- Se agregó mnemónico FUNDOC para manejar en la addenda de CHEDRAUI
                    -- 31/03/2014
                    --======================================================================-
                    IF HED_REC.TIPO_ADENDA = 'CHEDRAUI' AND P_TIPO_DOC = 'CM' THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'FUNDOC  '||'C');
                    ELSE
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'FUNDOC  '||'O'); --N -- EAN RECEPTOR
                    END IF;
                    --====================================================================--
                    
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'TIPDOC  '||HED_REC.TIPO_TRANSACCION1);  --  TIPO O CLAVE DEL DOCUMENTO: 1 - FACTURA 
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'NOMDOC  '||HED_REC.FUENTE);  --  NOMBRE DEL DOCUMENTO
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'TIPMON  '||HED_REC.TIPO_MONEDA);  --S  TIPO DE MONEDA. EJEMPLO: MXN
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'TIPCAM  '||HED_REC.TIPO_CAMBIO);  --S  TIPO DE CAMBIO 
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'SW_TC  ' ||HED_REC.SW_TC);  --S  BANDERA PARA HACER LA CONVERSI?N AL TIPO DE CAMBIO,  PARA MONEDA NACIONAL PONER 0, PARA MONEDA EXTRANJERA PONER 1
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'DIAPAG  '||HED_REC.DIAS_PAGO);  --N  D?AS DE PAGO
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'PDPPAG  '||'0');  --N  PORCENTAJE DE DESCUENTO POR PRONTO PAGO
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'MDPPAG  '||'0');  --N  MONTO DE DESCUENTO POR PRONTO PAGO
                    -- Caso facturas extemporaneas (SORIANA)                
                    IF nvl(P_EXTEMP,0) > 0 THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'PO_NUMEOC  '||'SI');  --PO_NUMEOC SI
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'TDA_CONTRA  '||P_EXTEMP);  --TDA_CONTRA #folio
                    END IF;
                    
                    --====================================================================--
                    -- CAMBIO SOLICITADO POR SANDRO CAZARIN, POR ADDENDA CHEDRAUI 21-03-2014
                    --====================================================================--
                    IF HED_REC.TIPO_ADENDA IN ('COMERCIAL_MEXICANA','CHEDRAUI') THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NUMDPT  '||P_DEPTO);--N  DEPARTAMENTO DE ENTREGA DEL CLIENTE            
                    END IF;
--                    IF HED_REC.TIPO_ADENDA = 'COMERCIAL_MEXICANA' THEN
--                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NUMDPT  '||P_DEPTO);--N  DEPARTAMENTO DE ENTREGA DEL CLIENTE            
--                    END IF;
                    --====================================================================--
                    
                    IF HED_REC.TIPO_ADENDA = 'OXXO' THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'TIPROV  '||'02');  --N  DEPARTAMENTO DE ENTREGA DEL CLIENTE
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'TIPLOC  '||'C');  --N  DEPARTAMENTO DE ENTREGA DEL CLIENTE
                    END IF;
                    
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'NUMEOC  '||HED_REC.NO_ORDER_COMPRA); --ORDEN_COMPRA);  --S  NUMERO DE ORDEN DE COMPRA
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'FECHOC  '||V_FECHOC);  --F  FECHA DE ORDEN DE COMPRA
                    
                    IF HED_REC.TIPO_ADENDA = 'SORIANA' THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'FECCON  '||HED_REC.FECCON);  --S  FECHA DE ENTREGA DE MERCANCIA
                    END IF;
                    
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'NOTAS3 '||UPPER(IBY_AMOUNT_IN_WORDS.GET_AMOUNT_IN_WORDS(V_TOTAL,'MXN'))); --S  NOTA 3 (MONTO TOTAL A PAGAR DEL DOCUMENTO CON LETRA)
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'REMDES  '||NVL(V_CEDIS,'MATRIZ TEHUACAN'));  --N  CEDIS PARA MASFACTURA NET - REMITIDO DESDE
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'FECHAR  '||HED_REC.FECHAR);  --FECHA SIN T Y SIN HORA EN FORMATO DD-MM-YYYY        
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'TRANSP  '||V_TRANSP);  --NO UNIDAD
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'EMBARQ  '||V_SALIDA);  --NO  SALIDA
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'SELLO1  '||V_SELLO_L);  --SELLO L
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'SELLO2  '||V_SELLO_LA);  --SELLO LA
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'SELLO3  '||V_SELLO_T);  --SELLO T
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'SELLO4  '||V_SELLO_TA);  --SELLO TA
                    IF HED_REC.TIPO_ADENDA IS NOT NULL THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'ADDEND  '||'1');  --SELLO TA
                    ELSE    
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'ADDEND  '||'0');  --SELLO TA
                    END IF;
                    UTL_FILE.PUT_LINE (V_MANEJADOR, '');  -- L?NEA EN BLANCO
                        
                    FND_FILE.PUT_LINE (FND_FILE.LOG,'Escribiendo emisor');
                    dbms_output.put_line('Escribiendo emisor');
                    
                    --EMISOR
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'RFCEMI  '||'PAC941215E50');  --S  R.F.C. DEL EMISOR DE LA FACTURA        
                    
                    --IF HED_REC.TIPO_ADENDA = 'WALMART' THEN
                    --    UTL_FILE.PUT_LINE (V_MANEJADOR, 'NOMEMI  '||'PRODUCTOS AVICOLAS EL CALVARIO S.A. DE C.V.');  --S  NOMBRE DEL EMISOR DE LA FACTURA
                        --UTL_FILE.PUT_LINE (V_MANEJADOR, 'NOMEMI  '||'PRODUCTOS AVICOLAS EL CALVARIO S. DE R.L. DE C.V.');  --S  NOMBRE DEL EMISOR DE LA FACTURA
                    --ELSE
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NOMEMI  '||'PRODUCTOS AVICOLAS EL CALVARIO S. DE R.L. DE C.V.');  --S  NOMBRE DEL EMISOR DE LA FACTURA      
                    --END IF;
                    
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'EANEMI  '||'7504003607004');  --N  EAN DEL EMISOR
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'NUMEMI  '||HED_REC.NUMERO_PROVEEDOR);  --  NUMERO DEL EMISOR (# PROVEEDOR)  
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'CALEMI  '||'AV. HEROES DE LA INDEPENDENCIA');  --S  CALLE DEL DOMICILIO FISCAL DEL EMISOR
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'NEXEMI  '||'901');  --  NUMERO EXTERIOR DEL DOMICILIO FISCAL DEL EMISOR
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'COLEMI  '||'MIGUEL HIDALGO');  --  COLONIA DEL DOMICILIO FISCAL DEL EMISOR
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'MUNEMI  '||'TEHUACAN');  --S  MUNICIPIO DEL DOMICILIO FISCAL DEL EMISOR (DELEGACION)
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'ESTEMI  '||'PUEBLA'); --  ESTADO DEL DOMICILIO FISCAL DEL EMISOR
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'PAIEMI  '||'MEXICO');  --S  PA?S DEL DOMICILIO FISCAL DEL EMISOR
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'CODEMI  '||'75790');  --  C?DIGO POSTAL DEL DOMICILIO FISCAL DEL EMISOR 
                    UTL_FILE.PUT_LINE (V_MANEJADOR, '');  -- L?NEA EN BLANCO
                    --HR_LOCATIONS_ALL_V

                    --DIRECCI?N EXPEDIDA POR EL EMISOR (CEDIS O MATRIZ)
                    IF P_ORG_ID <> 82 THEN
                        FND_FILE.PUT_LINE (FND_FILE.LOG,'Escribiendo datos de CEDIS');
                        dbms_output.put_line('Escribiendo datos de CEDIS');
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NOMEXP  '||UPPER(V_CEDIS));  --S  NOMBRE DEL CEDIS EMISOR   
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'CALEXP  '||UPPER(V_CALLE));  --S  CALLE DE LA DIRECCI?N DE EXPEDICI?N DE LA FACTURA
                        --UTL_FILE.PUT_LINE (V_MANEJADOR, 'CALEX2  '||UPPER(V_CALLE2));  --S  CALLE DE LA DIRECCI?N DE EXPEDICI?N DE LA FACTURA
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NEXEXP  '||REPLACE(V_NUMEXT,'N/A',''));  --S  NUMERO EXTERIOR DE LA DIRECCI?N DE EXPEDICI?N DE LA FACTURA
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'COLEXP  '||UPPER(REPLACE(V_COLONIA,'N/A','')));  --S  COLONIA DE LA DIRECCI?N DE EXPEDICI?N DE LA FACTURA
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'MUNEXP  '||UPPER(V_CIUDAD));  --S  MUNICIPIO DE LA DIRECCI?N DE EXPEDICI?N  FACTURA (DELEGAC.)  
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'LUGEXP  '||UPPER(V_PAIS||' '||V_ESTADO));     --S  NOMBRE DEL CEDIS EMISOR 
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'ESTEXP  '||UPPER(V_ESTADO));  --S  ESTADO DE LA DIRECCI?N DE EXPEDICI?N DE LA FACTURA  
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'PAIEXP  '||UPPER(V_PAIS));  --S  PA?S DE LA DIRECCI?N DE EXPEDICI?N DE LA FACTURA
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'CODEXP  '||V_POSTAL);  --S  C?DIGO POSTAL DE LA DIRECCI?N DE EXPEDICI?N DE LA FACTURA
                        UTL_FILE.PUT_LINE (V_MANEJADOR, '');  -- L?NEA EN BLANCO
                    END IF;

                    FND_FILE.PUT_LINE (FND_FILE.LOG,'Escribiendo datos del receptor');
                    dbms_output.put_line('Escribiendo datos del receptor');
                    
                    --RECEPTOR
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'RFCREC  '||upper(nvl(HED_REC.RFC,HED_REC.RFC_RECEPTOR)));   --S(12-13) - R.F.C. DEL RECEPTOR DE LA FACTURA

                    IF HED_REC.TIPO_DE_CLIENTE = 'PERSON' THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NOMREC  '||UPPER(HED_REC.NOMBRE_CLIENTE));  --S  NOMBRE DEL RECEPTOR DE LA FACTURA
                    ELSIF HED_REC.TIPO_DE_CLIENTE = 'ORGANIZATION' THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NOMREC  '||UPPER(HED_REC.CLIENTE_MATRIZ));  --S  NOMBRE DEL RECEPTOR DE LA FACTURA        
                    END IF;       

            --        IF HED_REC.TIPO_ADENDA = 'WALMART' THEN
            --            UTL_FILE.PUT_LINE (V_MANEJADOR, 'NOMREC  '||'NUEVA WALMART DE MEXICO S. DE R.L. DE C.V.');  --S  NOMBRE DEL RECEPTOR DE LA FACTURA 
            --        ELSE
            --            UTL_FILE.PUT_LINE (V_MANEJADOR, 'NOMREC  '||UPPER(HED_REC.NOMBRE_CLIENTE));  --S  NOMBRE DEL RECEPTOR DE LA FACTURA
            --        END IF;
                    
                    IF HED_REC.TIPO_ADENDA IS NOT NULL THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'CALREC  '||REGEXP_REPLACE(UPPER(HED_REC.CALLE), '[^a-zA-Z0-9-,. ]', '')); --S CALLE DEL DOMICILIO DEL RECEPTOR
                        IF HED_REC.TIPO_ADENDA = 'SORIANA' THEN
                            UTL_FILE.PUT_LINE (V_MANEJADOR, 'NEXREC  '||REGEXP_REPLACE(REPLACE(HED_REC.NO_EXTERIOR,'N/A',NULL), '[^a-zA-Z0-9-,. ]', '')||REGEXP_REPLACE(REPLACE(HED_REC.NO_INTERIOR,'N/A',NULL), '[^a-zA-Z0-9-,. ]', '')); --S -- NEXREC (RESERVADO PARA ESPECIFICAR EL DATO DE NO. EXTERIOR DEL RECEPTOR)
                            UTL_FILE.PUT_LINE (V_MANEJADOR, 'NINREC  '||NULL); --S -- NEXREC (RESERVADO PARA ESPECIFICAR EL DATO DE NO. EXTERIOR DEL RECEPTOR)                    
                        ELSE
                            UTL_FILE.PUT_LINE (V_MANEJADOR, 'NEXREC  '||REGEXP_REPLACE(REPLACE(HED_REC.NO_EXTERIOR,'N/A',NULL), '[^a-zA-Z0-9-,. ]', '')); --S -- NEXREC (RESERVADO PARA ESPECIFICAR EL DATO DE NO. EXTERIOR DEL RECEPTOR)
                            UTL_FILE.PUT_LINE (V_MANEJADOR, 'NINREC  '||REGEXP_REPLACE(REPLACE(HED_REC.NO_INTERIOR,'N/A',NULL), '[^a-zA-Z0-9-,. ]', '')); --S -- NEXREC (RESERVADO PARA ESPECIFICAR EL DATO DE NO. EXTERIOR DEL RECEPTOR)
                        END IF;
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'COLREC  '||REGEXP_REPLACE(UPPER(REPLACE(HED_REC.COLONIA,'N/A',NULL)), '[^a-zA-Z0-9-,?. ]', ''));-- COLREC (RESERVADO PARA ESPECIFICAR EL DATO DE COLONIA DEL RECEPTOR)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'MUNREC  '||REGEXP_REPLACE(UPPER(HED_REC.CIUDAD), '[^a-zA-Z0-9-,. ]', ''));-- MUNREC (RESERVADO PARA ESPECIFICAR EL DATO DE MUNICIPIO Y/O DELEGACION DEL RECEPTOR)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'ESTREC  '||REGEXP_REPLACE(UPPER(HED_REC.ESTADO), '[^a-zA-Z0-9-,. ]', ''));-- ESTREC (RESERVADO PARA ESPECIFICAR EL DATO DE ESTADO DEL RECEPTOR)        
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'PAIREC  '||REPLACE(UPPER(HED_REC.PAIS),'?','E')); --S PA?S DEL DOMICILIO DEL RECEPTOR
                    ELSE
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'CALREC  '||UPPER(HED_REC.CALLE)); --S CALLE DEL DOMICILIO DEL RECEPTOR
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NEXREC  '||REPLACE(HED_REC.NO_EXTERIOR,'N/A',NULL)); --S -- NEXREC (RESERVADO PARA ESPECIFICAR EL DATO DE NO. EXTERIOR DEL RECEPTOR)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NINREC  '||REPLACE(HED_REC.NO_INTERIOR,'N/A',NULL)); --S -- NEXREC (RESERVADO PARA ESPECIFICAR EL DATO DE NO. EXTERIOR DEL RECEPTOR)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'COLREC  '||UPPER(REPLACE(HED_REC.COLONIA,'N/A',NULL)));-- COLREC (RESERVADO PARA ESPECIFICAR EL DATO DE COLONIA DEL RECEPTOR)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'MUNREC  '||UPPER(HED_REC.CIUDAD));-- MUNREC (RESERVADO PARA ESPECIFICAR EL DATO DE MUNICIPIO Y/O DELEGACION DEL RECEPTOR)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'ESTREC  '||UPPER(HED_REC.ESTADO));-- ESTREC (RESERVADO PARA ESPECIFICAR EL DATO DE ESTADO DEL RECEPTOR)        
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'PAIREC  '||UPPER(HED_REC.PAIS)); --S PA?S DEL DOMICILIO DEL RECEPTOR                
                    END IF;

                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'CODREC  '||HED_REC.CODIGO_POSTAL); -- CODREC (RESERVADO PARA ESPECIFICAR EL DATO DE CODIGO DEL RECEPTOR)
                    
                    --====================================================================--
                    -- CAMBIO SOLICITADO POR SANDRO CAZARIN, POR ADDENDA CHEDRAUI 21-03-2014
                    --====================================================================--
                    IF HED_REC.TIPO_ADENDA = 'CHEDRAUI' THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'EANREC  '||HED_REC.SHIP_GLN); --N -- EAN RECEPTOR
                    ELSE
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'EANREC  '||HED_REC.GLN); --N -- EAN RECEPTOR
                    END IF;
                    --====================================================================--
                    
                    --UTL_FILE.PUT_LINE (V_MANEJADOR, 'EANREC  '||HED_REC.GLN); --N -- EAN RECEPTOR

                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'MAIL  '||HED_REC.EMAIL); --N -- EAN RECEPTOR
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'NUMCLI  '||HED_REC.NO_CLIENTE); --N -- EAN RECEPTOR
                    UTL_FILE.PUT_LINE (V_MANEJADOR, '');  -- L?NEA EN BLANCO

                    FND_FILE.PUT_LINE (FND_FILE.LOG,'Escribiendo lugar de entrega o tienda');
                    FND_FILE.PUT_LINE (FND_FILE.LOG,'ADDENDA: '||HED_REC.TIPO_ADENDA);
                    dbms_output.put_line('Escribiendo lugar de entrega o tienda');
                    
                    --LUGAR DE ENTREGA O TIENDA
                    IF HED_REC.CLIENTE_MATRIZ = 'VENTAS PUBLICO EN GENERAL GALLINAZA (SCTH)' THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NOMENT  '||NULL);-- DEBERAN COLOCAR EL NOMBRE DE LA SUCURSAL Y/O TIENDA
                    ELSE
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NOMENT  '||UPPER(HED_REC.NOMBRE_RECEPTOR));-- DEBERAN COLOCAR EL NOMBRE DE LA SUCURSAL Y/O TIENDA
                    END IF;

                    IF HED_REC.TIPO_ADENDA IS NOT NULL THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'CALENT  '||REGEXP_REPLACE(UPPER(V_CALENT), '[^a-zA-Z0-9-,. ]', '')); -- EL DATO DE CALLE DEBERA SER EL CORRESPONDIENTE A LA SUCURSAL Y/O TIENDA
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NEXENT  '||REGEXP_REPLACE(UPPER(REPLACE(V_NEXENT,'N/A',NULL)), '[^a-zA-Z0-9-,. ]', ''));--UPPER(HED_REC.DIRECCION_RECEPTOR2||' '||HED_REC.DIRECCION_RECEPTOR3));-- NEXENT (RESERVADO PARA ESPECIFICAR EL DATO DE NO. EXTERIOR DEL LUGAR DE ENTREGA)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NINENT  '||REGEXP_REPLACE(UPPER(REPLACE(V_NINENT,'N/A',NULL)), '[^a-zA-Z0-9-,. ]', ''));--INTERIOR            
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'COLENT  '||REGEXP_REPLACE(UPPER(REPLACE(V_COLENT,'N/A',NULL)), '[^a-zA-Z0-9-,. ]', ''));-- COLENT (RESERVADO PARA ESPECIFICAR EL DATO DE COLONIA DEL LUGAR DE ENTREGA)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'MUNENT  '||REGEXP_REPLACE(UPPER(V_MUNENT), '[^a-zA-Z0-9-,. ]', ''));-- MUNENT (RESERVADO PARA ESPECIFICAR EL DATO DE DELEGACION Y/O MUNICIPIO DEL LUGAR DE ENTREGA)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'ESTENT  '||REGEXP_REPLACE(UPPER(V_ESTENT), '[^a-zA-Z0-9-,. ]', ''));-- ESTENT (RESERVADO PARA ESPECIFICAR EL DATO DE ESTADO DEL RECEPTOR)
                    ELSE
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'CALENT  '||UPPER(V_CALENT)); -- EL DATO DE CALLE DEBERA SER EL CORRESPONDIENTE A LA SUCURSAL Y/O TIENDA
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NEXENT  '||UPPER(REPLACE(V_NEXENT,'N/A',NULL)));--UPPER(HED_REC.DIRECCION_RECEPTOR2||' '||HED_REC.DIRECCION_RECEPTOR3));-- NEXENT (RESERVADO PARA ESPECIFICAR EL DATO DE NO. EXTERIOR DEL LUGAR DE ENTREGA)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NINENT  '||UPPER(REPLACE(V_NINENT,'N/A',NULL)));--INTERIOR            
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'COLENT  '||UPPER(REPLACE(V_COLENT,'N/A',NULL)));-- COLENT (RESERVADO PARA ESPECIFICAR EL DATO DE COLONIA DEL LUGAR DE ENTREGA)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'MUNENT  '||UPPER(V_MUNENT));-- MUNENT (RESERVADO PARA ESPECIFICAR EL DATO DE DELEGACION Y/O MUNICIPIO DEL LUGAR DE ENTREGA)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'ESTENT  '||UPPER(V_ESTENT));-- ESTENT (RESERVADO PARA ESPECIFICAR EL DATO DE ESTADO DEL RECEPTOR)
                    END IF;

                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'PAIENT  '||UPPER(V_PAIENT));-- PAIENT (RESERVADO PARA ESPECIFICAR EL DATO DE PAIS DEL RECEPTOR)
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'CODENT  '||V_CODENT);-- CODENT (RESERVADO PARA ESPECIFICAR EL DATO DE CODIGO POSTAL DEL LUGAR DE ENTREGA)

                    --====================================================================--
                    -- CAMBIO SOLICITADO POR SANDRO CAZARIN, POR ADDENDA CHEDRAUI 21-03-2014
                    --====================================================================--
                    IF HED_REC.TIPO_ADENDA = 'SORIANA' THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'EANENT  '||HED_REC.SHIP_NO_TIENDA);  --N(13) EAN RECEPTOR   (EN LIVERPOOL SE PONE EL # TIENDA POR EL MOMENTO)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NUMTIE  '||''); --N  NUMERO DE TIENDA (SIN USO POR EL MOMENTO)
                    ELSIF HED_REC.TIPO_ADENDA = 'CHEDRAUI' THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'EANENT  '||lpad(HED_REC.SHIP_NO_TIENDA,13,'0'));  --N(13) EAN RECEPTOR   (EN LIVERPOOL SE PONE EL # TIENDA POR EL MOMENTO)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NUMTIE  '||HED_REC.SHIP_NO_TIENDA); --N  NUMERO DE TIENDA (SIN USO POR EL MOMENTO)                    
                    ELSE
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'EANENT  '||HED_REC.SHIP_GLN);  --N(13) EAN RECEPTOR   (EN LIVERPOOL SE PONE EL # TIENDA POR EL MOMENTO)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NUMTIE  '||HED_REC.SHIP_NO_TIENDA); --N  NUMERO DE TIENDA (SIN USO POR EL MOMENTO)
                    END IF;
--                    IF HED_REC.TIPO_ADENDA = 'SORIANA' THEN
--                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'EANENT  '||HED_REC.SHIP_NO_TIENDA);  --N(13) EAN RECEPTOR   (EN LIVERPOOL SE PONE EL # TIENDA POR EL MOMENTO)
--                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NUMTIE  '||''); --N  NUMERO DE TIENDA (SIN USO POR EL MOMENTO)
--                    ELSE
--                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'EANENT  '||HED_REC.SHIP_GLN);  --N(13) EAN RECEPTOR   (EN LIVERPOOL SE PONE EL # TIENDA POR EL MOMENTO)
--                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'NUMTIE  '||HED_REC.SHIP_NO_TIENDA); --N  NUMERO DE TIENDA (SIN USO POR EL MOMENTO)
--                    END IF;
                    --====================================================================--
                    
                    UTL_FILE.PUT_LINE (V_MANEJADOR, '');  -- L?NEA EN BLANCO

                    --CONCEPTOS, SE ABRE CURSOR QUE CONTIENE Y RECORRE LAS L?NEAS DE LA FACTURA EN PROCESO
                    FOR LIN_REC IN LINES_CUR (HED_REC.ID_FACTURA) LOOP
                        BEGIN
                            V_UNIDAD := NULL;   
                            BEGIN
                              --CONSULTA PARA OBTENER EL EAN DEL ART?CULO (L?NEA)
                              SELECT UNIQUE A.MFG_PART_NUM
                                INTO V_EAN
                                FROM MTL_MANUFACTURERS B, MTL_SYSTEM_ITEMS_B IT, MTL_MFG_PART_NUMBERS A
                               WHERE A.MANUFACTURER_ID = B.MANUFACTURER_ID
                                 AND A.INVENTORY_ITEM_ID = IT.INVENTORY_ITEM_ID
                                 AND A.ORGANIZATION_ID = IT.ORGANIZATION_ID
                                 AND B.MANUFACTURER_NAME = HED_REC.TIPO_ADENDA
                                 AND IT.INVENTORY_ITEM_ID = LIN_REC.INV_ITEM_ID;                            
                            EXCEPTION WHEN OTHERS THEN
                                FND_FILE.PUT_LINE (FND_FILE.LOG,'Error al obtener el EAN a nivel l?neas de la factura. '||SQLERRM);
                                dbms_output.put_line('Error al obtener el EAN a nivel l?neas de la factura. '||SQLERRM);
                            END;
                            
                            --===============================================--
                            -- 25/09/2012 ARS
                            -- Solicitud de modificaci?n para mostrar c?digo 
                            -- de barras de cajas 180
                            --===============================================--
                            IF (LIN_REC.INV_ITEM_ID = 879378) AND (HED_REC.TIPO_ADENDA = 'SORIANA') THEN
                                SELECT meaning
                                  INTO v_ean
                                  FROM fnd_lookup_values_vl
                                 WHERE tag = 'CAJA 180';
                            END IF; 
                            --===============================================--

                            --===============================================--
                            -- 11/03/2014 ARS
                            -- Solicitud de modificaci?n para mostrar PIEZAS DE o CAJAS DE 
                            -- en lugar de UNID. y cambio de NOAP por NA
                            -- Y mostrar en PDF KG y no KGM
                            --===============================================--                            --UNIDAD DE MEDIDA
                            IF V_UNIDAD IS NULL THEN
                               V_UNIDAD := LIN_REC.UOM;
                            END IF;
                            IF V_UNIDAD IS NULL THEN 
                               V_UNIDAD := LIN_REC.UOM2;
                            END IF;
                            IF V_UNIDAD IS NULL THEN
                               V_UNIDAD := LIN_REC.UOM_LINE;
                            END IF;
                            --=========================--
                            IF (V_UNIDAD IS NULL) AND (HED_REC.TIPO_TRANSACCION1 IN (1,2,3)) THEN
                               V_UNIDAD := 'NA';
                            END IF;
                            IF V_UNIDAD = 'EA' THEN 
                                V_SEC_UOM := ' PIEZAS DE ';
                                V_UNIDAD_PDF := 'PZ';
                            ELSIF V_UNIDAD = 'KGM' THEN 
                                V_SEC_UOM := ' CAJAS DE ';
                                V_UNIDAD_PDF := 'KG';
                            END IF;
                            --=========================--

                            --L?NEAS
                            V_TOTAL_LIN := V_TOTAL_LIN + 1; -- TOTAL DE L?NEAS DE LA FACTURA
                                
                            --NIVEL L?NEAS            
                            FND_FILE.PUT_LINE (FND_FILE.LOG,'Escribiendo l?neas de la factura');
                            dbms_output.put_line('Escribiendo l?neas de la factura');
                            
                            IF HED_REC.SERIE = 'FCTH' THEN
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'CANTID  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.CANT_FACTURADA));  --N  CANTIDAD FACTURADA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'DESCRI  '||LIN_REC.DESCRIPCION||' Ton. '||LIN_REC.CANTIDAD_SECUNDARIA);  --S  DESCRIPCI?N DEL PRODUCTO O SERVICIO
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'DESCR2  '||LIN_REC.DESCRIPCION||' Ton. '||LIN_REC.CANTIDAD_SECUNDARIA);  --S  DESCRIPCI?N DEL PRODUCTO O SERVICIO
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'CANEMP  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.CANT_FACTURADA));  --N  CANTIDAD EMPACADA 
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'CVESKU  '||NULL);-- C?DIGO O CLAVE INTERNA DE LA CADENA COMERCIAL
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'CODUPC  '||LPAD(V_EAN,13,'0'));  --N(13)  C?DIGO EAN/UPC
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'UNIDAD  '||V_UNIDAD);  --N(13)  UNIDAD DE MEDIDA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'PIEPEM  '||XXCALV_ROUND_TWO_DECIMAL(1)); --XXCALV_ROUND_TWO_DECIMAL(LIN_REC.CANT_FACTURADA/1000)); -- PIEZAS POR PAQUETE O EMPAQUE
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'CODDUN  '||LPAD(V_EAN,13,'0'));  --N(14) C?DIGO DUN14
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'PBRUDE  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.PRECIO_UNITARIO));  --N PRECIO UNITARIO BRUTO
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'IMPBRU  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.PRECIO_NETO));  --N IMPORTE BRUTO DE LA PARTIDA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'TDECON  '||'0');  --N % DE DESCUENTO TOTAL DE LA PARTIDA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'MDECON  '||'0');  --N MONTO DEL DESCUENTO TOTAL DE LA PARTIDA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'CDECON  '||'0');  --S(3) C?DIGO DEL DESCUENTO
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'VALUNI  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.PRECIO_UNITARIO));  --N PRECIO UNITARIO NETO
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'IMPORT  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.PRECIO_NETO));  --N IMPORTE NETO DE LA PARTIDA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'TASIPE  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.TASA_IMPUESTO));  --N % DEL IVA TRASLADADO DE LA PARTIDA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'MONIPE  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.TTL_IMPUESTO)); --N  MONTO DE IVA TRASLADADO DE LA PARTIDA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'TASIEP  '||'0');  --N % DEL IEPS TRASLADADO DE LA PARTIDA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'MONIEP  '||'0');  --N MONTO DE IEPS TRASLADADO DE LA PARTIDA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'NUMLIN  '||V_TOTAL_LIN);  --N N?MERO DE L?ENA DE LA FACTURA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'PESUNO  '||XXCALV_ROUND_TWO_DECIMAL((LIN_REC.CANT_FACTURADA + LIN_REC.TARA))); --PESO BRUTO
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'PESDOS  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.CANT_FACTURADA)); --PESO NETO
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'PETARA  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.TARA)); --TARA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, '');
                            ELSE
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'CANTID  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.CANT_FACTURADA));  --N  CANTIDAD FACTURADA
                                /*Cambio solicitado 29/02/2012
                                  Eliminar la palabra Unid. cuando sean notas de cr?dito manuales*/                              
                                IF HED_REC.CUST_TRX_TYPE_ID = 1030 THEN
                                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'DESCRI  '||substr(LIN_REC.DESCRIPCION,1,35));  --S  DESCRIPCI?N DEL PRODUCTO O SERVICIO
                                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'DESCR2  '||LIN_REC.DESCRIPCION);  --S  DESCRIPCI?N DEL PRODUCTO O SERVICIO                                
                                ELSE
                                    IF HED_REC.ADUANA IS NOT NULL THEN
                                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'DESCRI  '||substr(LIN_REC.CANTIDAD_SECUNDARIA||V_SEC_UOM||LIN_REC.DESCRIPCION,1,35));  --S  DESCRIPCI?N DEL PRODUCTO O SERVICIO
                                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'DESCR2  '||substr(LIN_REC.CANTIDAD_SECUNDARIA||V_SEC_UOM||LIN_REC.DESCRIPCION,1,35)
                                                                                           ||' - Num. Pedimento: '||HED_REC.NUM_PED
                                                                                           ||', Aduana: '||HED_REC.ADUANA
                                                                                           ||', Fecha: '||HED_REC.FECH_PED||'.');  --S  DESCRIPCI?N DEL PRODUCTO O SERVICIO
                                    ELSE 
                                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'DESCRI  '||substr(LIN_REC.CANTIDAD_SECUNDARIA||V_SEC_UOM||LIN_REC.DESCRIPCION,1,35));  --S  DESCRIPCI?N DEL PRODUCTO O SERVICIO
                                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'DESCR2  '||LIN_REC.CANTIDAD_SECUNDARIA||V_SEC_UOM||LIN_REC.DESCRIPCION);  --S  DESCRIPCI?N DEL PRODUCTO O SERVICIO
                                    END IF;
                                    --UTL_FILE.PUT_LINE (V_MANEJADOR, 'NUMADU  '||'Num. Pedimento: '||HED_REC.NUMADU);  --Numero de pedimento
                                    --UTL_FILE.PUT_LINE (V_MANEJADOR, 'FECADU  '||'Fecha Pedimento: '||HED_REC.FECADU);  --Fecha de pedimento
                                END IF;
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'CANEMP  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.CANT_FACTURADA));  --N  CANTIDAD EMPACADA 
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'CVESKU  '||NULL);-- C?DIGO O CLAVE INTERNA DE LA CADENA COMERCIAL
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'CODUPC  '||LPAD(V_EAN,13,'0'));  --N(13)  C?DIGO EAN/UPC
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'UNIDAD  '||V_UNIDAD);  --N(13)  UNIDAD DE MEDIDA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'PIEPEM  '||XXCALV_ROUND_TWO_DECIMAL(1)); --LIN_REC.CANT_FACTURADA)); -- PIEZAS POR PAQUETE O EMPAQUE
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'CODDUN  '||LPAD(V_EAN,13,'0'));  --N(14) C?DIGO DUN14
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'PBRUDE  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.PRECIO_UNITARIO));  --N PRECIO UNITARIO BRUTO
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'IMPBRU  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.PRECIO_NETO));  --N IMPORTE BRUTO DE LA PARTIDA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'TDECON  '||'0');  --N % DE DESCUENTO TOTAL DE LA PARTIDA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'MDECON  '||'0');  --N MONTO DEL DESCUENTO TOTAL DE LA PARTIDA
                                IF HED_REC.TIPO_ADENDA <> 'OXXO' THEN
                                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'CDECON  '||'0');  --S(3) C?DIGO DEL DESCUENTO
                                END IF;
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'VALUNI  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.PRECIO_UNITARIO));  --N PRECIO UNITARIO NETO
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'IMPORT  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.PRECIO_NETO));  --N IMPORTE NETO DE LA PARTIDA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'TASIPE  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.TASA_IMPUESTO));  --N % DEL IVA TRASLADADO DE LA PARTIDA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'MONIPE  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.TTL_IMPUESTO)); --N  MONTO DE IVA TRASLADADO DE LA PARTIDA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'TASIEP  '||'0');  --N % DEL IEPS TRASLADADO DE LA PARTIDA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'MONIEP  '||'0');  --N MONTO DE IEPS TRASLADADO DE LA PARTIDA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'NUMLIN  '||V_TOTAL_LIN);  --N N?MERO DE L?ENA DE LA FACTURA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'PESUNO  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.CANT_FACTURADA + LIN_REC.TARA)); --PESO BRUTO
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'PESDOS  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.CANT_FACTURADA)); --PESO NETO
                                UTL_FILE.PUT_LINE (V_MANEJADOR, 'PETARA  '||XXCALV_ROUND_TWO_DECIMAL(LIN_REC.TARA)); --TARA
                                UTL_FILE.PUT_LINE (V_MANEJADOR, '');
                            END IF;
                                 
                            --TOTALES POR FACTURA
                            V_IVA_GLOBAL := V_IVA_GLOBAL + LIN_REC.TASA_IMPUESTO;           -- SUMA DE LAS TASAS DE IVA DE CADA L?NEA
                            V_IVA_TOTAL := V_IVA_TOTAL + LIN_REC.TTL_IMPUESTO;              -- SUMA DE CANTIDADADES DE IVA DE CADA L?NEA
                            V_IMPORTE_TOTAL := V_IMPORTE_TOTAL + LIN_REC.PRECIO_NETO;       -- SUMA DE LOS IMPORTES DE LAS L?NEAS
                            V_CANTIDAD_TOTAL := V_CANTIDAD_TOTAL +  LIN_REC.CANT_FACTURADA; -- SUMA DE CANTIDADES DE LAS L?NEAS
                        
                        EXCEPTION WHEN OTHERS THEN
                            FND_FILE.PUT_LINE (FND_FILE.LOG,'ERROR inesperado en las l?neas de la factura. '||SQLERRM);
                            dbms_output.put_line('ERROR inesperado en las l?neas de la factura. '||SQLERRM);
                        END;
                    
                    END LOOP;

                    --PARA SABER SI EL IVA ES EL MISMO PARA TODAS LAS L?NEAS DE LA FACTURA
                    V_IVA_GLOBAL := V_IVA_GLOBAL/V_TOTAL_LIN;

                    FND_FILE.PUT_LINE (FND_FILE.LOG,'Escribiendo totales');
                    dbms_output.put_line('Escribiendo totales');
                    --TOTALES
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'TOTLPF  '||V_TOTAL_LIN);  --N  TOTAL DE L?NEAS O PARTIDAS
                    
                    IF HED_REC.TIPO_ADENDA = 'SORIANA' THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'TOTCAN  '||V_CANTIDAD_TOTAL); --N TOTAL DE BULTOS
                    END IF;
                    
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'SUBTBR  '||XXCALV_ROUND_TWO_DECIMAL(V_IMPORTE_TOTAL)); --XXCALV_ROUND_TWO_DECIMAL(V_CANTIDAD_TOTAL));  --N  SUBTOTAL BRUTO
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'CODDES  '||'0'); --N  C?DIGO DEL DESCUENTO GENERAL
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'MONDET  '||'0'); --N  SUMA DEL DESCUENTO TOTAL (GENERALES Y POR PARTIDAS)
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'PRCDSG  '||'0'); --N  PORCENTAJE DE DESCUENTO GENERAL TOTAL
                        
                    IF V_IVA_GLOBAL = 16 THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'SUBTSI  '||XXCALV_ROUND_TWO_DECIMAL(0));  --N  SUBTOTAL NETO AL CUAL NO APLICA EL IVA TRASLADADO (IVA 0)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'SUBTAI  '||XXCALV_ROUND_TWO_DECIMAL(V_IMPORTE_TOTAL));  --N  SUBTOTAL NETO AL CUAL SI APLICA EL IVA TRASLADADO (IVA 16)
                    ELSIF V_IVA_GLOBAL = 0 THEN
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'SUBTSI  '||XXCALV_ROUND_TWO_DECIMAL(V_IMPORTE_TOTAL));  --N  SUBTOTAL NETO AL CUAL NO APLICA EL IVA TRASLADADO (IVA 0)
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'SUBTAI  '||XXCALV_ROUND_TWO_DECIMAL(0));  --N  SUBTOTAL NETO AL CUAL SI APLICA EL IVA TRASLADADO (IVA 16)
                    END IF;
                        
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'SUBTOT  '||XXCALV_ROUND_TWO_DECIMAL(V_IMPORTE_TOTAL));  --N  SUBTOTAL NETO
                        
                    -- SI NO HAY IVAS DIFERENTES EN LA FACTURA, SE COLOCA EL IVA GLOBAL, SI HAY ENTONCES LA TASA GLOBAL ES CERO
                    IF (V_IVA_GLOBAL = 0) OR (V_IVA_GLOBAL = 16) THEN 
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'TOTIVA  '||XXCALV_ROUND_TWO_DECIMAL(V_IVA_GLOBAL));--N  TASA IVA GLOBAL
                    ELSE
                        UTL_FILE.PUT_LINE (V_MANEJADOR, 'TOTIVA  '||XXCALV_ROUND_TWO_DECIMAL(0));  --N  TASA IVA GLOBAL
                    END IF;
                        
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'IVATRA  '||XXCALV_ROUND_TWO_DECIMAL(V_IVA_TOTAL));--N  MONTO TOTAL DE IVA TRASLADADO, IVATRA1, IVATRA2, IVATRA3  
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'TATIEP  '||'0'); --N  TASA IEPS GLOBAL
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'IEPTRA  '||'0'); --N  MONTO TOTAL DE IEPS GLOBAL
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'IVARET  '||'0'); --N  IVA RETENIDO (LA SUMA DE IVARET_D)
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'ISRRET  '||'0'); --N  ISR RETENIDO (LA SUMA DE ISRRET_D)
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'TOTPAG  '||XXCALV_ROUND_TWO_DECIMAL(V_TOTAL));--N  TOTAL A PAGAR
                    UTL_FILE.PUT_LINE (V_MANEJADOR, 'TOTPAG_ORI  '||XXCALV_ROUND_TWO_DECIMAL(V_TOTAL));--N  TOTAL A PAGAR
                    UTL_FILE.FCLOSE (V_MANEJADOR);
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Archivo generado: '||V_DIRECTORIO||'/'||V_ARCHIVO);
                    dbms_output.put_line('Archivo generado: '||V_DIRECTORIO||'/'||V_ARCHIVO);
                ELSE
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Las lineas de la factura NO coinciden con las l?neas del pedido, por favor val?delas y vuelva A correr el proceso de facturaci?n electr?nica para poder continuar.');
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Importe total de la factura: '||v_total);
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Importe total del pedido: '||v_imp_total_ped);
                    dbms_output.put_line('Las lineas de la factura NO coinciden con las l?neas del pedido, por favor val?delas y vuelva A correr el proceso de facturaci?n electr?nica para poder continuar.');
                    dbms_output.put_line('Importe total de la factura: '||v_total);
                    dbms_output.put_line('Importe total del pedido: '||v_imp_total_ped);
                END IF;
                
           EXCEPTION WHEN OTHERS THEN
                FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR inesperado en cabecera de factura: '||SQLERRM);
                dbms_output.put_line('ERROR inesperado en cabecera de factura: '||SQLERRM);
           END;

       END IF; --RFC NULO

--    END IF;
   END LOOP;

   
   fnd_file.put_line (fnd_file.log, 'Fin...');
   dbms_output.put_line('Fin...');
   
   IF v_rfc = 'RFC' THEN
    --  IF nvl(V_ADDENDA,'OTRO') <> 'SORIANA' THEN
       BEGIN
           v_request_id := apps.fnd_request.submit_request( application =>'AR',
                                                            PROGRAM     =>'MUEVE_CFD',
                                                            description => NULL,
                                                            start_time  => NULL,
                                                            sub_request => FALSE
                                                          );
           COMMIT;
           fnd_file.put_line (fnd_file.log, 'Request_id: '||v_request_id);
           waiting := fnd_concurrent.wait_for_request
                                    (v_request_id,1,0,
                                     phase,
                                     status,
                                     dev_phase,
                                     dev_status,
                                     message
                                    );
       EXCEPTION WHEN others THEN
           fnd_file.put_line (fnd_file.output, 'ERROR lanzando concurrente. '||SQLERRM);
       END;
    --  END IF;
   END IF; 
EXCEPTION WHEN others THEN
    fnd_file.put_line (fnd_file.output, 'ERROR inesperado al generar factura. '||SQLERRM);
    dbms_output.put_line('ERROR inesperado al generar factura. '||SQLERRM);
    fnd_file.put_line (fnd_file.log, 'Archivo generado: '||v_directorio||'/'||v_archivo);
    dbms_output.put_line('ERROR inesperado al generar factura. '||SQLERRM);
END;
/