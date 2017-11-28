ALTER SESSION SET CURRENT_SCHEMA=APPS;


        SELECT INV_ITEM_ID, 
               REPLACE(DESCRIPCION,'FRAGIL','')                         DESCRIPCION, 
               SUM(CANT_FACTURADA)                                      CANT_FACTURADA, 
               PRECIO_UNITARIO,  
               UOM_LINE, 
               SUM(CANTIDAD_SECUNDARIA)                                 CANTIDAD_SECUNDARIA,
               UOM, 
               UOM2, 
               SUM(TASA_IMPUESTO)                                       TASA_IMPUESTO, 
               SUM(TASA_ISR_RET)                                        TASA_ISR_RET,
               SUM(TASA_IVA_RET)                                        TASA_IVA_RET,
               SUM(TTL_IMPUESTO)                                        TTL_IMPUESTO,
               SUM(TTL_ISR_RET)                                         TTL_ISR_RET,
               SUM(TTL_IVA_RET)                                         TTL_IVA_RET,                
               SUM(PRECIO_NETO)                                         PRECIO_NETO,
               TARA * SUM(CANTIDAD_SECUNDARIA)                          TARA,
               CLAVE_UNIDAD,
               CLAVE_PROD
          FROM (SELECT LINEAS.LINE_ID
                       , LINEAS.CLAVE_PROD
                       , LINEAS.CLAVE_UNIDAD
                       , LINEAS.LINEA
                       , LINEAS.TIPO_LINEA
                       , LINEAS.INV_ITEM_ID
                       , LINEAS.CODE_BAR 
                       , LINEAS.SERIAL_CODE
                       , TARA
                       , DECODE(:P_ORG_ID,
                                83, DESCRIPCION,
                                REGEXP_REPLACE(LINEAS.DESCRIPCION, 
                                               '[^a-zA-Z0-9. ]', ''))   DESCRIPCION
                       , LINEAS.CANTIDAD_REAL_TRX                       CANTIDAD_REAL_TRX
                       , LINEAS.CANT_FACTURADA                          CANT_FACTURADA
                       , LINEAS.CANT_CREDITO                            CANT_CREDITO
                       , LINEAS.PRECIO_UNITARIO
                       , LINEAS.UOM_LINE
                       , LINEAS.CANTIDAD_SECUNDARIA                     CANTIDAD_SECUNDARIA
                       , LINEAS.UOM
                       , LINEAS.UOM2
                       , LINEAS.FOLIO_PEDIDO
                       , SUM(LINEAS.TASA_IMPUESTO)                      TASA_IMPUESTO
                       , SUM(LINEAS.TASA_ISR_RET)                       TASA_ISR_RET
                       , SUM(LINEAS.TASA_IVA_RET)                       TASA_IVA_RET
                       , SUM(LINEAS.TTL_IMPUESTO)                       TTL_IMPUESTO
                       , SUM(LINEAS.TTL_ISR_RET)                        TTL_ISR_RET
                       , SUM(LINEAS.TTL_IVA_RET)                        TTL_IVA_RET
                       , LINEAS.PRECIO_NETO                             PRECIO_NETO
                       , LINEAS.DESCUENTO
                       , LINEAS.PEDIMENTO
                       , LINEAS.FECHA_PEDIMENTO
                       , LINEAS.ADUANA
                  FROM (SELECT   CTL.INTERFACE_LINE_ATTRIBUTE6          LINE_ID
                               , (CASE
                                  WHEN CTL.INTERFACE_LINE_CONTEXT = 'CATEGORIAS_SAT'
                                  THEN CTL.INTERFACE_LINE_ATTRIBUTE1
                                  ELSE ''
                                   END)                                 CLAVE_PROD
                               , (CASE
                                  WHEN CTL.INTERFACE_LINE_CONTEXT = 'CATEGORIAS_SAT'
                                  THEN CTL.INTERFACE_LINE_ATTRIBUTE2
                                   END)                                 CLAVE_UNIDAD
                               , CTL.LINE_NUMBER                        LINEA
                               , CTL.LINE_TYPE                          TIPO_LINEA
                               , CTL.INVENTORY_ITEM_ID                  INV_ITEM_ID
                               , ''                                     CODE_BAR
                               , ''                                     SERIAL_CODE
                               , XXCALV_CALCULA_TARA_CFD(CTL.INTERFACE_LINE_ATTRIBUTE6) TARA
                               , TRIM(CTL.DESCRIPTION||REPLACE(XXCALV_GRADE_DESC(CTL.INTERFACE_LINE_ATTRIBUTE6),
                                                               'CASCADO CASCADO',
                                                               'CASCADO')|| ', ' || (SELECT MEANING
                                                                                       FROM FND_LOOKUP_VALUES 
                                                                                      WHERE LOOKUP_TYPE = 'CREDIT_MEMO_REASON'
                                                                                        AND LOOKUP_CODE = CTL.REASON_CODE
                                                                                        AND LANGUAGE = 'ESA')  
                                                                                 )      DESCRIPCION
                               , DECODE(CTL.QUANTITY_INVOICED,
                                        NULL, ABS(CTL.QUANTITY_CREDITED),
                                        CTL.QUANTITY_INVOICED)          CANTIDAD_REAL_TRX
                               , NVL ( DECODE(CTL.QUANTITY_INVOICED, 
                                              NULL, ABS(CTL.QUANTITY_CREDITED), 
                                              CTL.QUANTITY_INVOICED ),1)CANT_FACTURADA 
                               , ''                                     CANT_CREDITO
                               , NVL(ABS(CTL.UNIT_SELLING_PRICE),1)     PRECIO_UNITARIO
                               , CTL.UOM_CODE                           UOM_LINE
                               , (SELECT OEL.ORDERED_QUANTITY2 
                                    FROM OE_ORDER_LINES_ALL OEL 
                                   WHERE OEL.LINE_ID = CTL.INTERFACE_LINE_ATTRIBUTE6 
                                 )                                      CANTIDAD_SECUNDARIA
                                 , NVL((SELECT UPPER(OEL.ORDER_QUANTITY_UOM) 
                                             FROM OE_ORDER_LINES_ALL OEL 
                                            WHERE OEL.LINE_ID = CTL.INTERFACE_LINE_ATTRIBUTE6),
                                       (SELECT DISTINCT UPPER(UOM_CODE)
                                          FROM MTL_UNITS_OF_MEASURE_TL
                                         WHERE DESCRIPTION = CTL.INTERFACE_LINE_ATTRIBUTE2))
                                                                        UOM
                                   ,(SELECT UPPER(OEL.ORDERED_QUANTITY_UOM2)  
                                             FROM OE_ORDER_LINES_ALL OEL 
                                            WHERE OEL.LINE_ID = CTL.INTERFACE_LINE_ATTRIBUTE6 )
                                                                        UOM2
                               , CTL.INTERFACE_LINE_ATTRIBUTE1          FOLIO_PEDIDO  
                               , ABS((CASE TAX.VAT_TAX_ID
                                     WHEN 10129 THEN TAX.TAX_RATE
                                     WHEN 10131 THEN TAX.TAX_RATE
                                     WHEN 10153 THEN TAX.TAX_RATE
                                     WHEN 10128 THEN TAX.TAX_RATE
                                     WHEN 10132 THEN TAX.TAX_RATE
                                     WHEN 10236 THEN TAX.TAX_RATE
                                     WHEN 10335 THEN TAX.TAX_RATE
                                 END))                                  TASA_IMPUESTO,
                                 ABS((CASE TAX.VAT_TAX_ID
                                    WHEN 10237 THEN TAX.TAX_RATE
                                    ELSE NULL
                                 END))                                  TASA_ISR_RET,
                                 ABS((CASE TAX.VAT_TAX_ID
                                    WHEN 10238 THEN TAX.TAX_RATE
                                    ELSE NULL
                                 END))                                  TASA_IVA_RET,
                                 ABS((CASE TAX.VAT_TAX_ID
                                     WHEN 10129 THEN TAX.EXTENDED_AMOUNT
                                     WHEN 10131 THEN TAX.EXTENDED_AMOUNT
                                     WHEN 10153 THEN TAX.EXTENDED_AMOUNT 
                                     WHEN 10128 THEN TAX.EXTENDED_AMOUNT
                                     WHEN 10132 THEN TAX.EXTENDED_AMOUNT
                                     WHEN 10236 THEN TAX.EXTENDED_AMOUNT
                                     WHEN 10335 THEN TAX.EXTENDED_AMOUNT
                                 ELSE NULL
                                 END))                                  TTL_IMPUESTO,
                                 ABS((CASE TAX.VAT_TAX_ID
                                    WHEN 10237 THEN TAX.EXTENDED_AMOUNT
                                    ELSE NULL
                                 END))                                  TTL_ISR_RET,
                                 ABS((CASE TAX.VAT_TAX_ID
                                    WHEN 10238 THEN TAX.EXTENDED_AMOUNT
                                    ELSE NULL
                                 END))                                  TTL_IVA_RET
                               , ABS((NVL(  ( DECODE( CTL.QUANTITY_INVOICED, 
                                                     NULL, (ABS(CTL.QUANTITY_CREDITED) * ABS(CTL.UNIT_SELLING_PRICE)), 
                                                     (CTL.QUANTITY_INVOICED * CTL.UNIT_SELLING_PRICE) ) ) , CTL.EXTENDED_AMOUNT)))  PRECIO_NETO
                               , ''                                     DESCUENTO
                               , ''                                     PEDIMENTO
                               , ''                                     FECHA_PEDIMENTO
                               , ''                                     ADUANA
                          FROM RA_CUSTOMER_TRX_LINES_ALL CTL
                             , RA_CUSTOMER_TRX_LINES_ALL TAX
                         WHERE CTL.LINE_TYPE = 'LINE' 
                           AND CTL.CUSTOMER_TRX_ID = NVL(:P_CUSTOMER_TRX_ID,CTL.CUSTOMER_TRX_ID) 
                           AND CTL.ORG_ID = :P_ORG_ID
                           AND TAX.LINE_TYPE(+) = 'TAX' 
                           AND CTL.CUSTOMER_TRX_ID = TAX.CUSTOMER_TRX_ID(+)
                           AND CTL.ORG_ID = TAX.ORG_ID(+)
                           AND CTL.CUSTOMER_TRX_LINE_ID = TAX.LINK_TO_CUST_TRX_LINE_ID(+)
                           ) LINEAS 
            GROUP BY
               LINEAS.LINE_ID
             , LINEAS.LINEA
             , LINEAS.TIPO_LINEA
             , LINEAS.INV_ITEM_ID
             , LINEAS.CODE_BAR 
             , LINEAS.SERIAL_CODE
             , LINEAS.TARA
             , LINEAS.DESCRIPCION
             , LINEAS.CANTIDAD_REAL_TRX
             , LINEAS.CANT_FACTURADA
             , LINEAS.CANTIDAD_SECUNDARIA
             , LINEAS.CANT_CREDITO
             , LINEAS.PRECIO_UNITARIO
             , LINEAS.PRECIO_NETO
             , LINEAS.UOM_LINE
             , LINEAS.UOM
             , LINEAS.UOM2             
             , LINEAS.FOLIO_PEDIDO
             , LINEAS.DESCUENTO
             , LINEAS.PEDIMENTO
             , LINEAS.FECHA_PEDIMENTO
             , LINEAS.ADUANA
             , LINEAS.CLAVE_UNIDAD
             , LINEAS.CLAVE_PROD
             )
    GROUP BY INV_ITEM_ID, 
             TARA,
             DESCRIPCION,
             PRECIO_UNITARIO,  
             UOM_LINE, 
             UOM, 
             UOM2,
             CLAVE_UNIDAD,
             CLAVE_PROD          
    ORDER BY 1;