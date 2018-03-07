ALTER SESSION SET CURRENT_SCHEMA=APPS;    
    
    
    SELECT TRAX.DOC_SEQUENCE_VALUE                                                  NUMFOL
         , TRAX.CUSTOMER_TRX_ID
         , TRAX.ORG_ID
         , TRAX.PRIMARY_SALESREP_ID
         , TRAX.CUST_ATTRIBUTE1                                                     NUMEMI
         , TRAX.CUST_ATTRIBUTE12                                                    EANREC1
         , TRAX.CUST_ATTRIBUTE7                                                     TIPO_ADENDA
         , DECODE(TRAX.CUST_ATTRIBUTE7,
                  'OXXO', DECODE(ORG_ID,
                                 88, '10CTL',
                                 89, '10CTL',
                                 '99AAA'),
                  TRAX.SHIP_ATTRIBUTE3)                                             EANREC2
         , TRAX.SHIP_ATTRIBUTE4                                                     EANENT
         , TRAX.RAC_BILL_PARTY_TYPE                                                 TIPO_DE_CLIENTE
         , (SELECT SEQ.ATTRIBUTE1 
              FROM FND_DOCUMENT_SEQUENCES SEQ
             WHERE SEQ.TABLE_NAME = 'RA_CUSTOMER_TRX_ALL' 
               AND SEQ.DOC_SEQUENCE_ID = TRAX.DOC_SEQUENCE_ID)                      SERFOL          
         , CASE
              WHEN UPPER ( TRAX.CTT_CLASS ) LIKE 'INV' 
              THEN 'FACTURA'
              WHEN UPPER ( TRAX.CTT_CLASS ) LIKE 'CM'  
              THEN 'NOTA DE CREDITO'
              WHEN UPPER ( TRAX.CTT_CLASS ) LIKE 'DM'  
              THEN 'NOTA DE CARGO'
           END                                                                      NOMDOC
         , CASE
              WHEN UPPER ( TRAX.CTT_CLASS ) LIKE 'INV' 
              THEN 'I'
              WHEN UPPER ( TRAX.CTT_CLASS ) LIKE 'CM'  
              THEN 'E'
              WHEN UPPER ( TRAX.CTT_CLASS ) LIKE 'DM'  
              THEN 'I'
           END                                                                      TIPDOC
         , TO_CHAR(TRAX.TRX_DATE,'DD-MM-YYYY')                                      FECHAR
         , TO_CHAR(TRAX.TRX_DATE,'YYYY-MM-DD')||'T'||TO_CHAR(SYSDATE,'HH24:MI:SS')  FECEXP
         , TO_CHAR(TRAX.TRX_DATE,'YYYY-MM-DD')||'T'||TO_CHAR(SYSDATE,'HH24:MI:SS')  FECCON
         , TRAX.ORGANIZATION_NAME_PHONETIC                                          NOMRECO
         , TRAX.RAC_BILL_PARTY_ID                                                   NUMCLI
         , TRAX.RAC_BILL_TO_CUSTOMER_NAME                                           NOMRECP
         , TRAX.BILL_TO_TAXPAYER_ID                                                 RFCEMI
         , TRAX.RAA_BILL_TO_ADDRESS1                                                CALREC
         , REPLACE(TRAX.RAA_BILL_TO_ADDRESS2,'N/A','')                              NEXREC
         , REPLACE(TRAX.RAA_BILL_TO_ADDRESS3_DB,'N/A','')                           NINREC             
         , REPLACE(TRAX.RAA_BILL_TO_ADDRESS4,'N/A','')                              COLREC
         , LPAD(TRAX.RAA_BILL_TO_POSTAL_CODE,5,'0')                                 CODREC
         , TRAX.RAA_BILL_TO_CITY                                                    MUNREC
         , DECODE(TRAX.RAA_BILL_TO_STATE,
                  'DISTRITO FEDERAL', 'DF',
                  TRAX.RAA_BILL_TO_STATE)                                           ESTREC
         , REPLACE(TRAX.FT_BILL_TO_COUNTRY,'?','E')                                 PAIREC
         , NVL(TRIM(REPLACE(REPLACE(REPLACE(TRAX.RAT_TERM_NAME, 
                                            'INMEDIATO', '' ),
                                    'DIAS',''),
                            'CONTADO','')),0)                                       DIAPAG
         , TRAX.INVOICE_CURRENCY_CODE                                               TIPMON
         , DECODE(TRAX.INVOICE_CURRENCY_CODE,
                  'MXN', 1,
                  EXCHANGE_RATE)                                                    TIPCAM
         , DECODE(TRAX.INVOICE_CURRENCY_CODE,
                  'MXN', 0,
                  1)                                                                SW_TC 
         , NVL(SUBSTR(TRAX.RAC_SHIP_TO_CUSTOMER_NAME,
                      1, INSTR(TRAX.RAC_SHIP_TO_CUSTOMER_NAME, '(')-1),
               TRAX.RAC_SHIP_TO_CUSTOMER_NAME)                                      NOMENT
         , TRAX.SHIP_TO_TAXPAYER_ID                                                 RFCREC
         , NVL((SELECT DECODE(TRAX.CUST_ATTRIBUTE7, 
                              'WALMART', DECODE(OE.CUST_PO_NUMBER, 
                                                '0', NULL, 
                                                OE.CUST_PO_NUMBER),
                              'SORIANA', DECODE(OE.CUST_PO_NUMBER, 
                                                '0', '0', 
                                                OE.CUST_PO_NUMBER),
                              LPAD(OE.CUST_PO_NUMBER, 10, '0'))
                  FROM OE_ORDER_HEADERS_ALL OE 
                 WHERE OE.ORDER_NUMBER = NVL(TRAX.CT_REFERENCE,0) 
                   AND  ROWNUM = 1 
                   AND OE.ORG_ID = :P_ORG_ID_H),TRAX.PURCHASE_ORDER)                NUMEOC
         , TRAX.PURCHASE_ORDER_DATE                                                 FECHOC            
         , TRAX.CUST_ATTRIBUTE7
         , TRAX.CT_REFERENCE      
         , (SELECT TO_DATE(ATTRIBUTE9,'YYYY-MM-DD HH24:MI:SS')
              FROM OE_ORDER_HEADERS_ALL OE 
             WHERE OE.ORDER_NUMBER = NVL(TRAX.CT_REFERENCE,0) 
               AND  ROWNUM = 1 
               AND OE.ORG_ID = :P_ORG_ID_H)                                          FECH_PED
         , (SELECT ATTRIBUTE8 
              FROM OE_ORDER_HEADERS_ALL OE 
             WHERE OE.ORDER_NUMBER = NVL(TRAX.CT_REFERENCE,0) 
               AND  ROWNUM = 1 
               AND OE.ORG_ID = :P_ORG_ID_H)                                          NUM_PED
         , (SELECT ATTRIBUTE12
              FROM OE_ORDER_HEADERS_ALL OE 
             WHERE OE.ORDER_NUMBER = NVL(TRAX.CT_REFERENCE,0) 
               AND  ROWNUM = 1 
               AND OE.ORG_ID = :P_ORG_ID_H)                                          ADUANA         
         , EMAIL                                                                    MAIL
         , NVL(TRAX.CT_REFERENCE,0)                                                 ORDEN_COMPRA
         , TRAX.CUSTOMER_CLASS_CODE
         , TRAX.CUST_TRX_TYPE_ID
         , TRAX.ATTRIBUTE_CATEGORY
         , TRAX.ATTRIBUTE8                                                          CVEFORPAG
         , TRAX.ATTRIBUTE9                                                          USOCFDI
         , TRAX.ATTRIBUTE10                                                         RELTIP
      FROM RA_CUSTOMER_TRX_PARTIAL_CFD TRAX
     WHERE 1 = 1
       AND TRAX.ORG_ID = :P_ORG_ID_H
       AND TRAX.CUST_TRX_TYPE_ID = :P_ORIGEN_H
       AND TRAX.CTT_CLASS = NVL (:P_TIPO_DOC_H,TRAX.CTT_CLASS)
       AND TO_NUMBER(TRAX.DOC_SEQUENCE_VALUE) BETWEEN NVL ( :P_DOC_INI_H, TO_NUMBER(TRAX.DOC_SEQUENCE_VALUE))
                                                  AND NVL ( :P_DOC_FIN_H, TO_NUMBER(TRAX.DOC_SEQUENCE_VALUE))
       AND TRUNC(TRAX.TRX_DATE) BETWEEN TRUNC(NVL(TO_DATE(:P_FECHA_INI_H,'RRRR/MM/DD HH24:MI:SS'),TRAX.TRX_DATE))
                                    AND TRUNC(NVL(TO_DATE(:P_FECHA_FIN_H,'RRRR/MM/DD HH24:MI:SS'),TRAX.TRX_DATE))           
     ORDER BY TO_NUMBER(TRAX.DOC_SEQUENCE_VALUE);
