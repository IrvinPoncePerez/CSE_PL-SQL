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
                 , DECODE(trax.cust_attribute7,'OXXO',DECODE(org_id,88,'10CTL',89,'10CTL','99AAA'),trax.ship_attribute3) ship_gln
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
                      WHEN UPPER ( trax.ctt_class ) LIKE 'INV' THEN 'FACTURA'
                      WHEN UPPER ( trax.ctt_class ) LIKE 'CM'  THEN 'NOTA DE CREDITO'
                      WHEN UPPER ( trax.ctt_class ) LIKE 'DM'  THEN 'NOTA DE CARGO'
                   END fuente
                 , CASE
                      WHEN UPPER ( trax.ctt_class ) LIKE 'INV' THEN 'I'
                      WHEN UPPER ( trax.ctt_class ) LIKE 'CM'  THEN 'E'
                      WHEN UPPER ( trax.ctt_class ) LIKE 'DM'  THEN 'I'
                   END tipo_transaccion1
                 , TO_CHAR(trax.trx_date,'DD-MM-YYYY') fechar
                 , TO_CHAR(trax.trx_date,'YYYY-MM-DD')||'T'||TO_CHAR(SYSDATE,'HH24:MI:SS') fecha_factura --to_char(trax.trx_date,'HH:MI:SS') fecha_factura
                 , TO_CHAR(trax.trx_date,'YYYY-MM-DD')||'T'||TO_CHAR(SYSDATE,'HH24:MI:SS') feccon --'00:00:00' feccon
                 , TO_CHAR(trax.trx_date,'yyyy-mm-dd') fecha_factura_oxxo
                 , TO_CHAR(trax.trx_date,'yyyy-mm-dd')||'T'||TO_CHAR(SYSDATE,'HH24:MI:SS') fecha_factura_rem --to_char(trax.trx_date,'hh:mi:ss') fecha_factura_rem
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
                 , LPAD(trax.raa_bill_to_postal_code,5,'0') codigo_postal
                 , trax.raa_bill_to_city ciudad
                 , DECODE(trax.raa_bill_to_state,'DISTRITO FEDERAL','DF',trax.raa_bill_to_state) estado
                 , REPLACE(trax.ft_bill_to_country,'?','E') pais
                 --, decode(trax.bill_to_taxpayer_id,'UNA2907227Y5','Cheque Nominativo - Banamex, Cuenta: 1830','TSO991022PB6','NO IDENTIFICADO','PAGO EN UNA SOLA EXHIBICION') metodo_pago
                 , 'PAGO EN UNA SOLA EXHIBICION' forma_pago
                 , DECODE(trax.rat_term_name,'0',1,2) condicion_pago
                 , NVL(TRIM(REPLACE(REPLACE(REPLACE(trax.rat_term_name, 'INMEDIATO', '' ),'DIAS',''),'CONTADO','')),0) dias_pago
                 , trax.invoice_currency_code tipo_moneda
                 --, decode(trax.invoice_currency_code,'MXN',0,1) tipo_cambio --paco
                 , DECODE(trax.invoice_currency_code,'MXN',1,exchange_rate) tipo_cambio
                 , DECODE(trax.invoice_currency_code,'MXN',0,1) sw_tc
                 , trax.primary_salesrep_id no_vendedor
                 , trax.rac_ship_to_customer_id no_comprador
                 --, trax.ship_to_customer_id ship_from
                 --, trax.legal_entity_id ship_from
                 , (SELECT attribute2 
                      FROM hr_all_organization_units 
                     WHERE organization_id = :p_org_id_h) ship_from 
                 , trax.rac_ship_to_customer_id ship_to
                 , trax.rac_ship_to_customer_id no_receptor
                 , NVL(SUBSTR(trax.rac_ship_to_customer_name,1, INSTR(trax.rac_ship_to_customer_name, '(')-1),trax.rac_ship_to_customer_name) nombre_receptor
                 --, trax.rac_ship_to_customer_name nombre_receptor
                 , 'CUSTOMER' tipo_persona_recept
                 , trax.ship_to_taxpayer_id rfc_receptor
                 , trax.raa_ship_to_address1 direccion_receptor1
                 --, (SELECT DECODE(oe.cust_po_number,'1',NULL,'0',NULL, DECODE(trax.cust_attribute7, 'WALMART', oe.cust_po_number, LPAD(oe.cust_po_number,10,'0')))
                 , (SELECT DECODE(trax.cust_attribute7, 'WALMART', DECODE(oe.cust_po_number, '0', NULL, oe.cust_po_number)
                                                      , 'SORIANA', DECODE(oe.cust_po_number, '0', '0' , oe.cust_po_number)
                                                      , LPAD(oe.cust_po_number, 10, '0'))
                      FROM oe_order_headers_all oe 
                     WHERE oe.order_number = NVL(trax.ct_reference,0) 
                       AND  ROWNUM = 1 
                       AND oe.org_id = :p_org_id_h) no_order_compra 
                 --Se agregaron 3 campos adicionales para colocarlos en la descripci?n de las lineas para controlar los pedimentos
                 , (SELECT TO_DATE(attribute9,'YYYY-MM-DD HH24:MI:SS')
                      FROM oe_order_headers_all oe 
                     WHERE oe.order_number = NVL(trax.ct_reference,0) 
                       AND  ROWNUM = 1 
                       AND oe.org_id = :p_org_id_h) fech_ped
                 , (SELECT attribute8 
                      FROM oe_order_headers_all oe 
                     WHERE oe.order_number = NVL(trax.ct_reference,0) 
                       AND  ROWNUM = 1 
                       AND oe.org_id = :p_org_id_h) num_ped
                 , (SELECT attribute12
                      FROM oe_order_headers_all oe 
                     WHERE oe.order_number = NVL(trax.ct_reference,0) 
                       AND  ROWNUM = 1 
                       AND oe.org_id = :p_org_id_h) aduana
                 -----------------------------------------------------------------------------------------------------------------      
                 , trax.raa_ship_to_address2 direccion_receptor2
                 , REPLACE(trax.raa_ship_to_address3_db,'N/A','') direccion_receptor3
                 , REPLACE(trax.raa_ship_to_address3,'N/A','') direccion_receptor4             
                 , LPAD(trax.raa_ship_to_postal_code,5,'0') codigo_postal_recept
                 , trax.raa_ship_to_city ciudad_receptor
                 , DECODE(trax.raa_ship_to_state,'DISTRITO FEDERAL','DF',trax.raa_ship_to_state) estado_receptor
                 , REPLACE(DECODE(trax.raa_ship_to_county,'MX','MEXICO',trax.raa_ship_to_county),'?','E') pais_receptor
                 , email
                 , NVL(trax.ct_reference,0) orden_compra
                 , trax.interface_header_attribute1 folio_pedido
                 , TO_CHAR(trax.gd_gl_date,'YYYY-MM-DD') fecha_compra
                 , 1 status_factura
                 --, to_char(trax.term_due_date,'dd/mm/yyyy') fecha_vencimiento
                 , TO_CHAR(trax.trx_date + ((SELECT NAME 
                                               FROM ra_terms_tl 
                                              WHERE term_id = trax.term_id 
                                                AND LANGUAGE = 'ESA'))  ,'dd/mm/yyyy hh:mi') fecha_vencimiento
                 , TO_CHAR(trax.ship_date_actual,'yyyy-mm-dd')||'T'||TO_CHAR(trax.ship_date_actual,'hh24:mi:ss') ship_date_actual
                 , trax.customer_class_code
                 , trax.cust_trx_type_id
                 , trax.attribute_category
              FROM ra_customer_trx_partial_cfd trax
             WHERE 1=1
               --and trax.customer_trx_id in (104900,105400,105900,106000)
               AND trax.org_id = :p_org_id_h
               AND trax.cust_trx_type_id = :p_origen_h
               AND trax.ctt_class = NVL (:p_tipo_doc_h,trax.ctt_class)
--               AND to_number(trax.trx_number) BETWEEN nvl ( p_doc_ini_h, to_number(trax.trx_number)) 
--                                                  AND nvl ( p_doc_fin_h, to_number(trax.trx_number))
               AND TO_NUMBER(trax.doc_sequence_value) BETWEEN NVL ( :p_doc_ini_h, TO_NUMBER(trax.doc_sequence_value))
                                                  AND NVL ( :p_doc_fin_h, TO_NUMBER(trax.doc_sequence_value))
               AND TRUNC(trax.trx_date) BETWEEN TRUNC(NVL(TO_DATE(:p_fecha_ini_h,'RRRR/MM/DD HH24:MI:SS'),trax.trx_date))
                                            AND TRUNC(NVL(TO_DATE(:p_fecha_fin_h,'RRRR/MM/DD HH24:MI:SS'),trax.trx_date))           
             --ORDER BY to_number(trax.trx_number);
             ORDER BY TO_NUMBER(trax.doc_sequence_value);