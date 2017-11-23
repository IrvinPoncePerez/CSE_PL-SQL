ALTER SESSION SET CURRENT_SCHEMA=APPS;


SELECT inv_item_id, 
               -----------------------------------------------------------------  
               -- Cambio solicitado por Ventas, quitar FRAGIL, dejar s?lo la F.
               -- 25 FEB 2013, Abrahan Rinc?n.
               -- descripcion,
               REPLACE(descripcion,'FRAGIL','') descripcion,
               ----------------------------------------------------------------- 
               SUM(cant_facturada) cant_facturada, 
               precio_unitario,  
               uom_line, 
               SUM(cantidad_secundaria) cantidad_secundaria,
               uom, 
               uom2, 
               SUM(tasa_impuesto) tasa_impuesto, 
               SUM(tasa_isr_ret) tasa_isr_ret,
               SUM(tasa_iva_ret) tasa_iva_ret,
               SUM(ttl_impuesto) ttl_impuesto,
               SUM(ttl_isr_ret) ttl_isr_ret,
               SUM(ttl_iva_ret) ttl_iva_ret,                
               SUM(precio_neto) precio_neto,
               tara * SUM(cantidad_secundaria) tara,
               clave_unidad,
               clave_prod
          FROM (SELECT lineas.line_id
                       , lineas.clave_prod
                       , lineas.clave_unidad
                       , lineas.linea
                       , lineas.tipo_linea
                       , lineas.inv_item_id
                       , lineas.code_bar 
                       , lineas.serial_code
                       , tara
                       , DECODE(:p_org_id,83, descripcion,REGEXP_REPLACE(lineas.descripcion, '[^a-zA-Z0-9. ]', '')) descripcion
                       , lineas.cantidad_real_trx cantidad_real_trx
                       , lineas.cant_facturada cant_facturada
                       , lineas.cant_credito cant_credito
                       , lineas.precio_unitario
                       , lineas.uom_line
                       , lineas.cantidad_secundaria cantidad_secundaria
                       , lineas.uom
                       , lineas.uom2
                       , lineas.folio_pedido
                       , SUM(lineas.tasa_impuesto) tasa_impuesto
                       , SUM(lineas.tasa_isr_ret) tasa_isr_ret
                       , SUM(lineas.tasa_iva_ret) tasa_iva_ret
                       , SUM(lineas.ttl_impuesto) ttl_impuesto
                       , SUM(lineas.ttl_isr_ret) ttl_isr_ret
                       , SUM(lineas.ttl_iva_ret) ttl_iva_ret
                       , lineas.precio_neto precio_neto
                       , lineas.descuento
                       , lineas.pedimento
                       , lineas.fecha_pedimento
                       , lineas.aduana
                  FROM (SELECT   ctl.interface_line_attribute6 line_id
                               , (CASE
                                  WHEN CTL.INTERFACE_LINE_CONTEXT = 'CATEGORIAS_SAT'
                                  THEN ctl.INTERFACE_LINE_ATTRIBUTE1
                                  ELSE ''
                                   END) clave_PROD
                               , (CASE
                                  WHEN CTL.INTERFACE_LINE_CONTEXT = 'CATEGORIAS_SAT'
                                  THEN ctl.INTERFACE_LINE_ATTRIBUTE2
                                   END) clave_UNIDAD
                               , ctl.line_number linea
                               , ctl.line_type tipo_linea
                               , ctl.inventory_item_id inv_item_id
                               , '' code_bar
                               , '' serial_code
                               , xxcalv_calcula_tara_cfd(ctl.interface_line_attribute6) tara
                               , TRIM(ctl.description||REPLACE(xxcalv_grade_desc(ctl.interface_line_attribute6),'CASCADO CASCADO','CASCADO')||', ' || (SELECT meaning
                                                                                                                    FROM fnd_lookup_values 
                                                                                                                   WHERE lookup_type = 'CREDIT_MEMO_REASON'
                                                                                                                     AND lookup_code = ctl.reason_code
                                                                                                                     AND LANGUAGE = 'ESA')  
                                                                                                                 ) descripcion
                               , DECODE(ctl.quantity_invoiced,NULL,ABS(ctl.quantity_credited),ctl.quantity_invoiced) cantidad_real_trx
                               , NVL ( DECODE(ctl.quantity_invoiced, NULL, ABS(ctl.quantity_credited), ctl.quantity_invoiced ) ,1) cant_facturada 
                               , '' /*ctl.quantity_credited*/ cant_credito
                               , NVL(ABS(ctl.unit_selling_price),1) precio_unitario
--                               , DECODE(UPPER(ctl.uom_code) 
--                                         ,'CJ' ,'CA'
--                                         ,'CJA','CA'
--                                         ,'CJS','CA'
--                                         ,'PZ','EA'
--                                         ,'KGS','KGM'
--                                         ,'KG','KGM'
--                                         ,'PZ','EA'
--                                         ,'PZS','EA'
--                                         ,'PZS','EA'
--                                         , ctl.uom_code
--                                 ) uom_line
                               , CTL.UOM_CODE UOM_LINE
                               , (SELECT oel.ordered_quantity2 
                                    FROM oe_order_lines_all oel 
                                   WHERE oel.line_id = ctl.interface_line_attribute6 
                                 ) cantidad_secundaria
--                               , DECODE((SELECT UPPER(oel.order_quantity_uom) 
--                                           FROM oe_order_lines_all oel 
--                                          WHERE oel.line_id = ctl.interface_line_attribute6) 
--                                         ,'CJ' ,'CA'
--                                         ,'CJA','CA'
--                                         ,'CJS','CA'
--                                         ,'PZ','EA'
--                                         ,'KGS','KGM'
--                                         ,'KG','KGM'
--                                         ,'PZ','EA'
--                                         ,'PZS','EA'
--                                         ,'PZS','EA'
--                                         ,(SELECT UPPER(oel.order_quantity_uom) 
--                                             FROM oe_order_lines_all oel 
--                                            WHERE oel.line_id = ctl.interface_line_attribute6)
--                                       ) uom
                                 , NVL((SELECT UPPER(oel.order_quantity_uom) 
                                             FROM oe_order_lines_all oel 
                                            WHERE oel.line_id = ctl.interface_line_attribute6),
                                       (SELECT DISTINCT UPPER(UOM_CODE)
                                          FROM MTL_UNITS_OF_MEASURE_TL
                                         WHERE DESCRIPTION = CTL.INTERFACE_LINE_ATTRIBUTE2))
                                    UOM
--                               , DECODE((SELECT UPPER(oel.ordered_quantity_uom2) 
--                                           FROM oe_order_lines_all oel 
--                                          WHERE oel.line_id = ctl.interface_line_attribute6 ) 
--                                         ,'CJ' ,'CA'
--                                         ,'CJA','CA'
--                                         ,'CJS','CA'
--                                         ,'PZ','EA'
--                                         ,'KGS','KGM'
--                                         ,'KG','KGM'
--                                         ,'PZ','EA'
--                                         ,'PZS','EA'
--                                         ,'PZS','EA'
--                                         ,(SELECT UPPER(oel.ordered_quantity_uom2)  
--                                             FROM oe_order_lines_all oel 
--                                            WHERE oel.line_id = ctl.interface_line_attribute6 )
--                                       ) uom2
                                   ,(SELECT UPPER(oel.ordered_quantity_uom2)  
                                             FROM oe_order_lines_all oel 
                                            WHERE oel.line_id = ctl.interface_line_attribute6 )
                                     UOM2
                               , ctl.interface_line_attribute1 folio_pedido  
                               , ABS((CASE tax.vat_tax_id
                                     WHEN 10129 THEN tax.tax_rate
                                     WHEN 10131 THEN tax.tax_rate
                                     WHEN 10153 THEN tax.tax_rate
                                     WHEN 10128 THEN tax.tax_rate
                                     WHEN 10132 THEN tax.tax_rate
                                     WHEN 10236 THEN tax.tax_rate
                                     WHEN 10335 THEN tax.tax_rate
                                 END)) tasa_impuesto,
                                 ABS((CASE tax.vat_tax_id
                                    WHEN 10237 THEN tax.tax_rate
                                    ELSE NULL
                                 END)) tasa_isr_ret,
                                 ABS((CASE tax.vat_tax_id
                                    WHEN 10238 THEN tax.tax_rate
                                    ELSE NULL
                                 END)) tasa_iva_ret,
                                 ABS((CASE tax.vat_tax_id
                                     WHEN 10129 THEN tax.extended_amount
                                     WHEN 10131 THEN tax.extended_amount
                                     WHEN 10153 THEN tax.extended_amount 
                                     WHEN 10128 THEN tax.extended_amount
                                     WHEN 10132 THEN tax.extended_amount
                                     WHEN 10236 THEN tax.extended_amount
                                     WHEN 10335 THEN tax.extended_amount
                                 ELSE NULL
                                 END)) ttl_impuesto,
                                 ABS((CASE tax.vat_tax_id
                                    WHEN 10237 THEN tax.extended_amount
                                    ELSE NULL
                                 END)) ttl_isr_ret,
                                 ABS((CASE tax.vat_tax_id
                                    WHEN 10238 THEN tax.extended_amount
                                    ELSE NULL
                                 END)) ttl_iva_ret
                               , ABS((NVL(  ( DECODE( ctl.quantity_invoiced, NULL, (ABS(ctl.quantity_credited) * ABS(ctl.unit_selling_price)), (ctl.quantity_invoiced * ctl.unit_selling_price) ) ) , ctl.extended_amount)))  precio_neto
                               , '' descuento
                               , '' /*ctl.sales_order*/ pedimento
                               , '' /*ctl.sales_order_date*/ fecha_pedimento
                               , '' aduana
                          FROM ra_customer_trx_lines_all ctl
                             , ra_customer_trx_lines_all tax
                         WHERE ctl.line_type = 'LINE' 
                           AND ctl.customer_trx_id = NVL(:p_customer_trx_id,ctl.customer_trx_id) 
                           AND ctl.org_id = :p_org_id
                           AND tax.line_type(+) = 'TAX' 
                           AND ctl.customer_trx_id = tax.customer_trx_id(+)
                           AND ctl.org_id = tax.org_id(+)
                           AND ctl.customer_trx_line_id = tax.link_to_cust_trx_line_id(+)
                           ) lineas 
            GROUP BY
               lineas.line_id
             , lineas.linea
             , lineas.tipo_linea
             , lineas.inv_item_id
             , lineas.code_bar 
             , lineas.serial_code
             , lineas.tara
             , lineas.descripcion
             , lineas.cantidad_real_trx
             , lineas.cant_facturada
             , lineas.cantidad_secundaria
             , lineas.cant_credito
             , lineas.precio_unitario
             , lineas.precio_neto
             , lineas.uom_line
             , lineas.uom
             , lineas.uom2             
             , lineas.folio_pedido
             , lineas.descuento
             , lineas.pedimento
             , lineas.fecha_pedimento
             , lineas.aduana
             , lineas.clave_unidad
             , lineas.clave_prod
             )
    GROUP BY inv_item_id, 
             tara,
             descripcion,
             precio_unitario,  
             uom_line, 
             uom, 
             uom2,
             clave_unidad,
             clave_prod          
    ORDER BY 1;