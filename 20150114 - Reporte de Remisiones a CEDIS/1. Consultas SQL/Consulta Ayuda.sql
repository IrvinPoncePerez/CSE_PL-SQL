 SELECT sold_from_org_id,
         name ,
         num_factura,
         cta_cliente,
         num_cliente,
         cliente,
         NULL tipo_pedido,
         NULL inventory_item_id,
         description,
         NULL estado,
         DiaF,
         nom_vendedor,
         DECODE (cadena, '-1', '', cadena) cadena,
         num_fac2,
         ROUND (SUM (kilos), 2) peso,
         ROUND (SUM (cajas), 2) En_Cajas_de_360,
         ROUND (SUM (cajasn), 2) En_Cajas_Normales,
         ABS (ROUND (SUM (cant), 2)) cantidad,
         ROUND (SUM (importe), 2) importe,
         precio_unit_prom,
         NULL al_class_meaning
    FROM (  SELECT oola.sold_from_org_id,
                   hr.name,
                   doc_sequence_value num_factura,
                   cust_acct.account_number cta_cliente,
                   oola.sold_to_org_id num_cliente,
                   party_name cliente,
                   NULL tipo_pedido,
                   NULL inventory_item_id,
                   DECODE (msib.description, 'Primera', NULL, msib.description)
                   || ' '
                   || DECODE (mtln.grade_code, 'Primera', NULL, mtln.grade_code)
                      description,
                   NULL estado,
                   rcta.trx_date DiaF,
                   j.resource_name nom_vendedor,
                   --hol.name nom_vendedor,
                   DECODE (cust_acct.attribute2, '', '-1', cust_acct.attribute2)
                      cadena,
                   doc_sequence_value num_fac2,
                   ROUND (
                      SUM (
                         DECODE (
                            ORDER_QUANTITY_UOM,
                            'PZ', mtln.transaction_quantity,
                            (  mtln.transaction_quantity
                             * mtln.secondary_transaction_quantity
                             / ABS (mtln.transaction_quantity)))),
                      2)
                      Cant,
                   ROUND (
                      SUM (
                         DECODE (mtln.inventory_item_id,
                                 879378, NULL,
                                 mtln.transaction_quantity))
                      * -1)
                      piezas,
                   SUM (apps.xxcalv_ventas_fnc_pub (
                           'PIEZAS_A_KILOS',
                           p_segment1   => msib.segment1,
                           p_trx_qty    => mtln.transaction_quantity,
                           p_item_id    => mmt.inventory_item_id)
                        * -1)
                      kilos,
                   SUM (apps.xxcalv_ventas_fnc_pub (
                           'A_CAJAS_360',
                           p_segment1     => msib.segment1,
                           p_trx_qty      => mtln.transaction_quantity,
                           p_trx_qty2     => mtln.secondary_transaction_quantity,
                           p_grade_code   => mtln.grade_code,
                           p_item_id      => mmt.inventory_item_id)
                        * -1)
                      cajas,
                      
                   SUM (apps.xxcalv_ventas_fnc_pub (
                           'A_CAJAS',
                           p_segment1     => msib.segment1,
                           p_trx_qty      => mtln.transaction_quantity,
                           p_trx_qty2     => mtln.secondary_transaction_quantity,
                           p_grade_code   => mtln.grade_code,
                           p_item_id      => mmt.inventory_item_id)
                        * -1)
                      cajasn,   
                      
                      
                      
                   SUM (
                      rctla.unit_selling_price * mtln.transaction_quantity * -1)
                      importe,
                   rctla.unit_selling_price precio_unit_prom
              FROM inv.mtl_material_transactions mmt,
                   ont.oe_order_lines_all oola,
                   ont.oe_order_headers_all ooha,
                   inv.mtl_system_items_b msib,
                   inv.mtl_transaction_lot_numbers mtln,
                   hr.hr_all_organization_units hr,
                   ar.ra_customer_trx_all rcta,
                   ar.hz_parties party,
                   ar.ra_customer_trx_lines_all rctla,
                   ar.hz_cust_accounts cust_acct,
                   APPS.jtf_rs_defresources_v j, 
                   APPS.jtf_rs_salesreps s
                  -- jtf.jtf_rs_salesreps hol
                   
             WHERE     1 = 1
                   --and  rcta.PRIMARY_SALESREP_ID=hol.salesrep_id(+)
                   and j.resource_id(+) = s.resource_id
                   and s.salesrep_id(+) = rcta.PRIMARY_SALESREP_ID
                   AND rcta.customer_trx_id = rctla.customer_trx_id
                   AND oola.line_id = rctla.interface_line_attribute6
                   AND oola.sold_to_org_id = cust_acct.cust_account_id(+)
                   AND cust_acct.party_id = party.party_id(+)
                   AND mmt.trx_source_line_id = oola.line_id
                   AND oola.header_id = ooha.header_id
                   AND hr.organization_id = oola.sold_from_org_id
                   AND transaction_type_id IN (33)
                   AND msib.inventory_item_id = mmt.inventory_item_id
                   AND mtln.transaction_id = mmt.transaction_id
                   AND msib.organization_id = mmt.organization_id
                   AND mmt.organization_id =
                          TO_NUMBER (
                             apps.xxcalv_ventas_fnc_pub ('INV_ORG_ID',
                                                         p_org_id   => :p_org_id))
                   AND oola.sold_to_org_id =
                          DECODE (:p_customer_id,
                                  9999, oola.sold_to_org_id,
                                  NULL, oola.sold_to_org_id,
                                  :p_customer_id)
                   AND TRUNC (rcta.trx_date) BETWEEN NVL (
                                                        TRUNC (
                                                           TO_DATE (
                                                              :p_fecha_ini,
                                                              'DD/MM/RRRR HH24:MI:SS')),
                                                        TRUNC (rcta.trx_date))
                                                 AND NVL (
                                                        TRUNC (
                                                           TO_DATE (
                                                              :p_fecha_fin,
                                                              'DD/MM/RRRR HH24:MI:SS')),
                                                        TRUNC (rcta.trx_date))
                 GROUP BY oola.sold_from_org_id,
                  hr.name,
                  j.resource_name,
                  --hol.name,
                   doc_sequence_value,
                   cust_acct.account_number,
                   oola.sold_to_org_id,
                   party_name,
                   DECODE (msib.description, 'Primera', NULL, msib.description)
                   || ' '
                   || DECODE (mtln.grade_code,
                              'Primera', NULL,
                              mtln.grade_code),
                   rcta.trx_date,
                   cust_acct.attribute2,
                   doc_sequence_value,
                   rctla.unit_selling_price)
   WHERE 1 = 1
         AND cadena =
                DECODE (:p_cadena,  'TODAS', cadena,  NULL, cadena,  :p_cadena)
GROUP BY sold_from_org_id,
         name,
         num_factura,
         cta_cliente,
         num_cliente,
         cliente,
         description,
         DiaF,
         nom_vendedor,
         cadena,
         num_fac2,
         precio_unit_prom
ORDER BY num_factura, cliente