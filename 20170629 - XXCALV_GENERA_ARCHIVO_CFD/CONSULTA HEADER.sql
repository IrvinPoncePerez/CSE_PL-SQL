ALTER SESSION SET CURRENT_SCHEMA=APPS;





            SELECT TRAX.DOC_SEQUENCE_VALUE                                                  FACTURA
                 , TRAX.CUSTOMER_TRX_ID                                                     ID_FACTURA
                 , TRAX.ORG_ID                                                              ORG_ID
                 , TRAX.PRIMARY_SALESREP_ID
                 , TRAX.CUST_ATTRIBUTE1                                                     NUMERO_PROVEEDOR
                 , TRAX.CUST_ATTRIBUTE2                                                     CADENA
                 , TRAX.CUST_ATTRIBUTE12                                                    GLN
                 , TRAX.CUST_ATTRIBUTE4                                                     NO_TIENDA
                 , TRAX.CUST_ATTRIBUTE7                                                     TIPO_ADENDA
                 , TRAX.SHIP_ATTRIBUTE1                                                     SHIP_NUMERO_PROVEEDOR
                 , TRAX.SHIP_ATTRIBUTE2                                                     SHIP_CADENA
                 , DECODE(TRAX.CUST_ATTRIBUTE7,
                          'OXXO', DECODE(ORG_ID,
                                         88, '10CTL',
                                         89, '10CTL',
                                         '99AAA'),
                          TRAX.SHIP_ATTRIBUTE3)                                             SHIP_GLN
                 , TRAX.SHIP_ATTRIBUTE4                                                     SHIP_NO_TIENDA
                 , TRAX.RAC_BILL_PARTY_TYPE                                                 TIPO_DE_CLIENTE
                 , (SELECT SEQ.ATTRIBUTE1 
                      FROM FND_DOCUMENT_SEQUENCES SEQ
                     WHERE SEQ.TABLE_NAME = 'RA_CUSTOMER_TRX_ALL' 
                       AND SEQ.DOC_SEQUENCE_ID = TRAX.DOC_SEQUENCE_ID)                      SERIE
                 , (SELECT SEQ.ATTRIBUTE2 
                      FROM FND_DOCUMENT_SEQUENCES SEQ
                     WHERE SEQ.TABLE_NAME = 'RA_CUSTOMER_TRX_ALL' 
                       AND SEQ.DOC_SEQUENCE_ID = TRAX.DOC_SEQUENCE_ID)                      NUM_APROB
                 , (SELECT SEQ.ATTRIBUTE3 
                      FROM FND_DOCUMENT_SEQUENCES SEQ
                     WHERE SEQ.TABLE_NAME = 'RA_CUSTOMER_TRX_ALL' 
                       AND SEQ.DOC_SEQUENCE_ID = TRAX.DOC_SEQUENCE_ID)                      PERIODO_APROB          
                 , CASE
                      WHEN UPPER ( TRAX.CTT_CLASS ) LIKE 'INV' 
                      THEN 'FACTURA'
                      WHEN UPPER ( TRAX.CTT_CLASS ) LIKE 'CM'  
                      THEN 'NOTA DE CREDITO'
                      WHEN UPPER ( TRAX.CTT_CLASS ) LIKE 'DM'  
                      THEN 'NOTA DE CARGO'
                   END                                                                      FUENTE
                 , CASE
                      WHEN UPPER ( TRAX.CTT_CLASS ) LIKE 'INV' 
                      THEN 'I'
                      WHEN UPPER ( TRAX.CTT_CLASS ) LIKE 'CM'  
                      THEN 'E'
                      WHEN UPPER ( TRAX.CTT_CLASS ) LIKE 'DM'  
                      THEN 'I'
                   END                                                                      TIPO_TRANSACCION1
                 , TO_CHAR(TRAX.TRX_DATE,'DD-MM-YYYY')                                      FECHAR
                 , TO_CHAR(TRAX.TRX_DATE,'YYYY-MM-DD')||'T'||TO_CHAR(SYSDATE,'HH24:MI:SS')  FECHA_FACTURA
                 , TO_CHAR(TRAX.TRX_DATE,'YYYY-MM-DD')||'T'||TO_CHAR(SYSDATE,'HH24:MI:SS')  FECCON
                 , TO_CHAR(TRAX.TRX_DATE,'YYYY-MM-DD')                                      FECHA_FACTURA_OXXO
                 , TO_CHAR(TRAX.TRX_DATE,'YYYY-MM-DD')||'T'||TO_CHAR(SYSDATE,'HH24:MI:SS')  FECHA_FACTURA_REM
                 , TRAX.ORGANIZATION_NAME_PHONETIC                                          CLIENTE_MATRIZ
                 , TRAX.RAC_BILL_PARTY_ID                                                   NO_CLIENTE
                 , TRAX.RAC_BILL_TO_CUSTOMER_NAME                                           NOMBRE_CLIENTE
                 , 'CUSTOMER'                                                               TIPO_PERSONA
                 , TRAX.BILL_TO_TAXPAYER_ID                                                 RFC
                 , TRAX.RAC_BILL_PARTY_TAX_REFERENCE                                        RFC_EXTRANJEROS
                 , TRAX.RAA_BILL_TO_ADDRESS1                                                CALLE
                 , REPLACE(TRAX.RAA_BILL_TO_ADDRESS2,'N/A','')                              NO_EXTERIOR
                 , REPLACE(TRAX.RAA_BILL_TO_ADDRESS3_DB,'N/A','')                           NO_INTERIOR             
                 , REPLACE(TRAX.RAA_BILL_TO_ADDRESS4,'N/A','')                              COLONIA
                 , LPAD(TRAX.RAA_BILL_TO_POSTAL_CODE,5,'0')                                 CODIGO_POSTAL
                 , TRAX.RAA_BILL_TO_CITY                                                    CIUDAD
                 , DECODE(TRAX.RAA_BILL_TO_STATE,
                          'DISTRITO FEDERAL', 'DF',
                          TRAX.RAA_BILL_TO_STATE)                                           ESTADO
                 , REPLACE(TRAX.FT_BILL_TO_COUNTRY,'?','E')                                 PAIS
                 , 'PAGO EN UNA SOLA EXHIBICION'                                            FORMA_PAGO
                 , DECODE(TRAX.RAT_TERM_NAME,'0',1,2)                                       CONDICION_PAGO
                 , NVL(TRIM(REPLACE(REPLACE(REPLACE(TRAX.RAT_TERM_NAME, 
                                                    'INMEDIATO', '' ),
                                            'DIAS',''),
                                    'CONTADO','')),0)                                       DIAS_PAGO
                 , TRAX.INVOICE_CURRENCY_CODE                                               TIPO_MONEDA
                 , DECODE(TRAX.INVOICE_CURRENCY_CODE,'MXN',1,EXCHANGE_RATE)                 TIPO_CAMBIO
                 , DECODE(TRAX.INVOICE_CURRENCY_CODE,'MXN',0,1)                             SW_TC
                 , TRAX.PRIMARY_SALESREP_ID                                                 NO_VENDEDOR
                 , TRAX.RAC_SHIP_TO_CUSTOMER_ID                                             NO_COMPRADOR
                 , (SELECT ATTRIBUTE2 
                      FROM HR_ALL_ORGANIZATION_UNITS 
                     WHERE ORGANIZATION_ID = :P_ORG_ID_H) SHIP_FROM 
                 , TRAX.RAC_SHIP_TO_CUSTOMER_ID SHIP_TO
                 , TRAX.RAC_SHIP_TO_CUSTOMER_ID NO_RECEPTOR
                 , NVL(SUBSTR(TRAX.RAC_SHIP_TO_CUSTOMER_NAME,1, INSTR(TRAX.RAC_SHIP_TO_CUSTOMER_NAME, '(')-1),TRAX.RAC_SHIP_TO_CUSTOMER_NAME) NOMBRE_RECEPTOR
                
                 , 'CUSTOMER' TIPO_PERSONA_RECEPT
                 , TRAX.SHIP_TO_TAXPAYER_ID RFC_RECEPTOR
                 , TRAX.RAA_SHIP_TO_ADDRESS1 DIRECCION_RECEPTOR1
                
                 , (SELECT DECODE(TRAX.CUST_ATTRIBUTE7, 'WALMART', DECODE(OE.CUST_PO_NUMBER, '0', NULL, OE.CUST_PO_NUMBER)
                                                      , 'SORIANA', DECODE(OE.CUST_PO_NUMBER, '0', '0' , OE.CUST_PO_NUMBER)
                                                      , LPAD(OE.CUST_PO_NUMBER, 10, '0'))
                      FROM OE_ORDER_HEADERS_ALL OE 
                     WHERE OE.ORDER_NUMBER = NVL(TRAX.CT_REFERENCE,0) 
                       AND  ROWNUM = 1 
                       AND OE.ORG_ID = :P_ORG_ID_H) NO_ORDER_COMPRA 
                
                 , (SELECT TO_DATE(ATTRIBUTE9,'YYYY-MM-DD HH24:MI:SS')
                      FROM OE_ORDER_HEADERS_ALL OE 
                     WHERE OE.ORDER_NUMBER = NVL(TRAX.CT_REFERENCE,0) 
                       AND  ROWNUM = 1 
                       AND OE.ORG_ID = :P_ORG_ID_H) FECH_PED
                 , (SELECT ATTRIBUTE8 
                      FROM OE_ORDER_HEADERS_ALL OE 
                     WHERE OE.ORDER_NUMBER = NVL(TRAX.CT_REFERENCE,0) 
                       AND  ROWNUM = 1 
                       AND OE.ORG_ID = :P_ORG_ID_H) NUM_PED
                 , (SELECT ATTRIBUTE12
                      FROM OE_ORDER_HEADERS_ALL OE 
                     WHERE OE.ORDER_NUMBER = NVL(TRAX.CT_REFERENCE,0) 
                       AND  ROWNUM = 1 
                       AND OE.ORG_ID = :P_ORG_ID_H) ADUANA
                
                 , TRAX.RAA_SHIP_TO_ADDRESS2 DIRECCION_RECEPTOR2
                 , REPLACE(TRAX.RAA_SHIP_TO_ADDRESS3_DB,'N/A','') DIRECCION_RECEPTOR3
                 , REPLACE(TRAX.RAA_SHIP_TO_ADDRESS3,'N/A','') DIRECCION_RECEPTOR4             
                 , LPAD(TRAX.RAA_SHIP_TO_POSTAL_CODE,5,'0') CODIGO_POSTAL_RECEPT
                 , TRAX.RAA_SHIP_TO_CITY CIUDAD_RECEPTOR
                 , DECODE(TRAX.RAA_SHIP_TO_STATE,'DISTRITO FEDERAL','DF',TRAX.RAA_SHIP_TO_STATE) ESTADO_RECEPTOR
                 , REPLACE(DECODE(TRAX.RAA_SHIP_TO_COUNTY,'MX','MEXICO',TRAX.RAA_SHIP_TO_COUNTY),'?','E') PAIS_RECEPTOR
                 , EMAIL
                 , NVL(TRAX.CT_REFERENCE,0) ORDEN_COMPRA
                 , TRAX.INTERFACE_HEADER_ATTRIBUTE1 FOLIO_PEDIDO
                 , TO_CHAR(TRAX.GD_GL_DATE,'YYYY-MM-DD') FECHA_COMPRA
                 , 1 STATUS_FACTURA
                
                 , TO_CHAR(TRAX.TRX_DATE + ((SELECT NAME 
                                               FROM RA_TERMS_TL 
                                              WHERE TERM_ID = TRAX.TERM_ID 
                                                AND LANGUAGE = 'ESA'))  ,'dd/mm/yyyy hh:mi') FECHA_VENCIMIENTO
                 , TO_CHAR(TRAX.SHIP_DATE_ACTUAL,'yyyy-mm-dd')||'T'||TO_CHAR(TRAX.SHIP_DATE_ACTUAL,'hh24:mi:ss') SHIP_DATE_ACTUAL
                 , TRAX.CUSTOMER_CLASS_CODE
                 , TRAX.CUST_TRX_TYPE_ID
                 , TRAX.ATTRIBUTE_CATEGORY
                 , TRAX.ATTRIBUTE8
              FROM RA_CUSTOMER_TRX_PARTIAL_CFD TRAX
             WHERE 1=1
              
               AND TRAX.ORG_ID = :P_ORG_ID_H
               AND TRAX.CUST_TRX_TYPE_ID = :P_ORIGEN_H
               AND TRAX.CTT_CLASS = NVL (:P_TIPO_DOC_H,TRAX.CTT_CLASS)
               AND TO_NUMBER(TRAX.DOC_SEQUENCE_VALUE) BETWEEN NVL ( :P_DOC_INI_H, TO_NUMBER(TRAX.DOC_SEQUENCE_VALUE))
                                                  AND NVL ( :P_DOC_FIN_H, TO_NUMBER(TRAX.DOC_SEQUENCE_VALUE))
               AND TRUNC(TRAX.TRX_DATE) BETWEEN TRUNC(NVL(TO_DATE(:P_FECHA_INI_H,'RRRR/MM/DD HH24:MI:SS'),TRAX.TRX_DATE))
                                            AND TRUNC(NVL(TO_DATE(:P_FECHA_FIN_H,'RRRR/MM/DD HH24:MI:SS'),TRAX.TRX_DATE))           
            
             ORDER BY TO_NUMBER(TRAX.DOC_SEQUENCE_VALUE);
