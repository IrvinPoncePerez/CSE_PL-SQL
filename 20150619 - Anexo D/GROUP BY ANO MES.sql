SELECT ANO,
       MES,
       SEQ.ATTRIBUTE1,
       MIN(FACTURA),
       MAX(FACTURA),
       DETAIL.NAME
  FROM (
              SELECT /*RG.NAME,*/
--                     TO_NUMBER(CT.TRX_NUMBER ) FACTURA,
                     TO_NUMBER(CT.DOC_SEQUENCE_VALUE ) FACTURA,
                     CTT.NAME,
                     CT.DOC_SEQUENCE_ID,
                     EXTRACT (YEAR FROM CT.TRX_DATE) AS ANO,
                     EXTRACT (MONTH FROM CT.TRX_DATE) MES,
                     'HUEVO BLANCO' PRODUCTO,
                     'TEHUACAN' ORIGEN,
                     DECODE (CTL.UOM_CODE,
                             'KG', 'GRANEL',
                             'Cja', 'GRANEL',
                             'PZ', 'EMPAQUE',
                             CTL.UOM_CODE)
                        PRESENTACION,
                     DECODE (
                        CTL.UOM_CODE,
                        'PZ', NVL (REGEXP_REPLACE (CTL.DESCRIPTION, '[^[:digit:]]', ''),
                                   '30')
                              || ' '
                              || 'PIEZAS',
                        DECODE (
                           CTL.inventory_item_id,
                           34, 'CAJA CON 200 PZAS',
                           102, 'CAJA CON 200 PZAS',
                           122, 'CAJA CON 200 PZAS',
                           56, '30 PIEZAS',
                           52, 'CAJA CON 180 PZAS',
                           50, 'CAJA CON 180 PZAS',
                           101355, '30 PIEZAS',
                           101354, '20 PIEZAS',
                           879378,    'CAJA CON '
                                   || xxcalv_qty_finder (CTL.interface_line_attribute6)
                                   || ' PZAS',
                           'CAJA CON 360 PZAS'))
                        CANTIDAD_EMPAQUE,
                     --         xxcalv_grade_code (CTL.interface_line_attribute6) GRADO_OPM,
                     /*CTL.DESCRIPTION PRODUCTO,*/
                     CTL.UOM_CODE UNIDAD_MEDIDA,
                     NVL(CTL.QUANTITY_INVOICED, CTL.QUANTITY_CREDITED)  VOLUMEN_VENTA,
                     CTL.UOM_CODE,
                     CTL.UNIT_SELLING_PRICE VALOR_UNITARIO,
                     CTL.EXTENDED_AMOUNT VALOR_TOTAL,
                     DECODE(CLASS, 'INV', RAC_SHIP_PARTY.PARTY_NAME, RAC_SHIP_PARTY.ORGANIZATION_NAME_PHONETIC) CLIENTE,
                     DECODE (org.organization_id,
                             111, 'TEH_DISTRIBUIDOR',
                             RAC_SHIP.CUSTOMER_CLASS_CODE)
                        CANAL,
                        org.NAME ORGANIZATION_ID ,
--                        LOC.ADDRESS1
--                     || ';'
--                     || LOC.ADDRESS2
--                     || ' '
--                     || LOC.ADDRESS3
--                     || ';'
--                     || LOC.ADDRESS4
--                     || ';'
--                     || LOC.CITY
--                     || ';'
--                     || LOC.POSTAL_CODE
                     LOC.CITY   DOMICILIO,
                     CTL.WAREHOUSE_ID,
                     CTL.INVENTORY_ITEM_ID,
                     (CASE
                        WHEN xxcalv_grade_code (CTL.interface_line_attribute6) = 'CASCADO'
                        THEN
                           'CASCADO'
                        WHEN xxcalv_grade_code (CTL.interface_line_attribute6) =
                                'CASCADO C'
                        THEN
                           'CASCADO'
                        WHEN xxcalv_grade_code (CTL.interface_line_attribute6) = 'EXTRA CS'
                        THEN
                           'CASCADO'
                        WHEN xxcalv_grade_code (CTL.interface_line_attribute6) = 'EXTRA EC'
                        THEN
                           'CASCADO'
                        WHEN xxcalv_grade_code (CTL.interface_line_attribute6) = 'EXTRA IC'
                        THEN
                           'CASCADO'
                        WHEN xxcalv_grade_code (CTL.interface_line_attribute6) =
                                'INDUSTRIAL CI'
                        THEN
                           'CASCADO'
                        ELSE
                           'BLANCO'
                     END) TIPO
                FROM AR_LOOKUPS AL_TAX,
                     AR_LOOKUPS AL_CM_REASON,
                     AR_LOOKUPS AL_INV_REASON,
                     FND_LOOKUPS AL_TAX_REASON,
                     RA_RULES RR,
                     MTL_UNITS_OF_MEASURE UOM,
                     MTL_UNITS_OF_MEASURE UOM_PREV,
                     RA_CUSTOMER_TRX_LINES_ALL CTL_PREV,
                     RA_CUSTOMER_TRX_LINES_ALL CTL,
                     RA_CUSTOMER_TRX_ALL CT,
                     RA_CUST_TRX_TYPES_ALL CTT,
                     AR_MEMO_LINES ML,
                     AR_VAT_TAX VAT,
                     hr_all_organization_units ORG,
                     HZ_CUST_ACCT_SITES_ALL RADD,
                     HZ_PARTY_SITES PARTY_SITE,
                     HZ_LOCATIONS LOC,
                     HZ_CUST_SITE_USES_ALL SITE,
                     HZ_CUST_ACCT_SITES RAA_SHIP,
                     HZ_CUST_ACCOUNTS RAC_SHIP,
                     HZ_PARTIES RAC_SHIP_PARTY,
                     HZ_CUST_SITE_USES SU_SHIP,
                     FND_TERRITORIES_TL FT_SHIP,
                     HZ_LOCATIONS RAA_SHIP_LOC,
                     HZ_PARTY_SITES RAA_SHIP_PS,
                     HZ_CUST_ACCOUNT_ROLES RACO_SHIP,
                     HZ_PARTIES RACO_SHIP_PARTY,
                     HZ_RELATIONSHIPS RACO_SHIP_REL,
                     AR_PAYMENT_SCHEDULES_ALL APSA
               WHERE     CTL.CUSTOMER_TRX_ID = CT.CUSTOMER_TRX_ID
                     AND CTL.ORG_ID = CT.ORG_ID
                     AND CT.CUST_TRX_TYPE_ID = CTT.CUST_TRX_TYPE_ID
                     AND CT.ORG_ID = CTT.ORG_ID
                     AND CTT.TYPE NOT IN ('DEP', 'GUAR', 'BR') /* 19-APR-2000 J Rautiainen BR Implementation */
                     AND CTL.PREVIOUS_CUSTOMER_TRX_LINE_ID =
                            CTL_PREV.CUSTOMER_TRX_LINE_ID(+)
                     AND CTL.ORG_ID = CTL_PREV.ORG_ID(+)
                     AND CTL.UOM_CODE = UOM.UOM_CODE(+)
                     AND CTL_PREV.UOM_CODE = UOM_PREV.UOM_CODE(+)
                     AND CTL.ACCOUNTING_RULE_ID = RR.RULE_ID(+)
                     AND 'TAX_CONTROL_FLAG' = AL_TAX.LOOKUP_TYPE(+)
                     AND CTL.TAX_EXEMPT_FLAG = AL_TAX.LOOKUP_CODE(+)
                     AND 'INVOICING_REASON' = AL_INV_REASON.LOOKUP_TYPE(+)
                     AND CTL.REASON_CODE = AL_INV_REASON.LOOKUP_CODE(+)
                     AND 'CREDIT_MEMO_REASON' = AL_CM_REASON.LOOKUP_TYPE(+)
                     AND CTL.REASON_CODE = AL_CM_REASON.LOOKUP_CODE(+)
                     AND 'ZX_EXEMPTION_REASON_CODE' = AL_TAX_REASON.LOOKUP_TYPE(+)
                     AND CTL.TAX_EXEMPT_REASON_CODE = AL_TAX_REASON.LOOKUP_CODE(+)
                     AND CTL.MEMO_LINE_ID = ML.MEMO_LINE_ID(+)
                     AND CTL.ORG_ID = ML.ORG_ID(+)
                     AND CTL.VAT_TAX_ID = VAT.VAT_TAX_ID(+)
                     AND CTL.ORG_ID = VAT.ORG_ID(+)
                     AND CTL.WAREHOUSE_ID = ORG.ORGANIZATION_ID(+)
                     AND CT.BILL_TO_SITE_USE_ID = SITE.SITE_USE_ID
                     AND CT.ORG_ID = SITE.ORG_ID
                     AND SITE.CUST_ACCT_SITE_ID = RADD.CUST_ACCT_SITE_ID
                     AND SITE.ORG_ID = RADD.ORG_ID
                     AND RADD.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
                     AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
                     AND CTL.SHIP_TO_SITE_USE_ID = SU_SHIP.SITE_USE_ID(+)
                     AND SU_SHIP.CUST_ACCT_SITE_ID = RAA_SHIP.CUST_ACCT_SITE_ID(+)
                     AND CTL.SHIP_TO_CUSTOMER_ID = RAC_SHIP.CUST_ACCOUNT_ID(+)
                     AND RAA_SHIP.PARTY_SITE_ID = RAA_SHIP_PS.PARTY_SITE_ID(+)
                     AND RAA_SHIP_PS.LOCATION_ID = RAA_SHIP_LOC.LOCATION_ID(+)
                     AND RAA_SHIP_LOC.COUNTRY = FT_SHIP.TERRITORY_CODE(+)
                     AND FT_SHIP.LANGUAGE(+) = USERENV ('LANG')
                     AND CTL.SHIP_TO_CONTACT_ID = RACO_SHIP.CUST_ACCOUNT_ROLE_ID(+)
                     AND RACO_SHIP.PARTY_ID = RACO_SHIP_REL.PARTY_ID(+)
                     AND RAC_SHIP.PARTY_ID = RAC_SHIP_PARTY.PARTY_ID(+)
                     AND RACO_SHIP_REL.SUBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
                     AND RACO_SHIP_REL.OBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
                     AND RACO_SHIP_REL.DIRECTIONAL_FLAG(+) = 'F'
                     AND RACO_SHIP.ROLE_TYPE(+) = 'CONTACT'
                     AND RACO_SHIP_REL.SUBJECT_ID = RACO_SHIP_PARTY.PARTY_ID(+)
                     AND RACO_SHIP_REL.STATUS(+) = 'A'
                     ----------------------------
                     AND CLASS IN ('INV', 'CM')
                     AND APSA.CUSTOMER_TRX_ID = CTL.CUSTOMER_TRX_ID
                     --         AND ctl.inventory_item_id = 101355
                     --         AND ctl.CUSTOMER_TRX_LINE_ID = 45300
                     --         AND CT.CUSTOMER_TRX_ID = 566364
                     --         AND CT.TRX_DATE > :P_START_DATE
                     --         AND CT.TRX_NUMBER = 33703
--                     AND EXTRACT (YEAR FROM CT.TRX_DATE) = 2015
                     AND CTL.LINE_TYPE = 'LINE'
                     AND CTL.WAREHOUSE_ID IS NOT NULL
                     AND CTL.WAREHOUSE_ID NOT IN (110)
                     AND CTL.INVENTORY_ITEM_ID NOT IN
                            (870378, 870378, 870379, 871378, 871379, 869378, 869379)
            ORDER BY CT.TRX_DATE, CT.TRX_NUMBER 
        ) DETAIL,
          fnd_document_sequences seq
                      WHERE seq.table_name = 'RA_CUSTOMER_TRX_ALL' AND seq.doc_sequence_id = DETAIL.DOC_SEQUENCE_ID
       
    GROUP BY DETAIL.ANO,
             DETAIL.MES,
             DETAIL.NAME,
             SEQ.ATTRIBUTE1
    ORDER BY ANO,
             MES
            
            
--            ) DETAIL
-- WHERE 1 = 1
---- GROUP BY DETAIL.ANO,
----          DETAIL.MES,
----          DETAIL.PRODUCTO,
----          DETAIL.ORIGEN,
----          DETAIL.DOMICILIO,
----          DETAIL.PRESENTACION,
----          DETAIL.CANAL,
----          DETAIL.CANTIDAD_EMPAQUE,
----          UOM_CODE,
------          CANAL
----ORGANIZATION_ID
----          DETAIL.CLIENTE
----          DETAIL.CLIENTE,

--          
-- ORDER BY DETAIL.ANO,
--          DETAIL.MES;
--            