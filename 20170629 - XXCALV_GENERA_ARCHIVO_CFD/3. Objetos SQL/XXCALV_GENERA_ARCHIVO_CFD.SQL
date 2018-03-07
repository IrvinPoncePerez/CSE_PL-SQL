CREATE OR REPLACE PROCEDURE APPS."XXCALV_GENERA_ARCHIVO_CFD" ( ERRBUF       OUT NOCOPY VARCHAR2
                                                             , RETCODE      OUT NOCOPY VARCHAR2
                                                             , P_ORG_ID     IN  NUMBER
                                                             , P_TIPO_DOC   IN  VARCHAR2
                                                             , P_ORIGEN     IN  NUMBER
                                                             , P_DOC_INI    IN  NUMBER
                                                             , P_DOC_FIN    IN  NUMBER
                                                             , P_DEPTO      IN  NUMBER
                                                             , P_EXTEMP     IN  NUMBER
                                                             , P_FECHA_INI  IN  VARCHAR2
                                                             , P_FECHA_FIN  IN  VARCHAR2
                                                             , P_PELECHA    IN  VARCHAR2
                                                             , P_TIMBRAR    IN  VARCHAR2)  AUTHID CURRENT_USER
IS

   
   V_MANEJADOR              UTL_FILE.FILE_TYPE;
   V_DIRECTORIO             VARCHAR2(250 BYTE) := 'CALVARIO';
   V_ARCHIVO                VARCHAR2(120 BYTE); 
   V_FECHOC                 VARCHAR2(100);
   V_CONTRA                 VARCHAR2(100);

   
   V_REQUEST_ID             NUMBER;
   WAITING                  BOOLEAN;
   PHASE                    VARCHAR2(80 BYTE);
   STATUS                   VARCHAR2(80 BYTE);
   DEV_PHASE                VARCHAR2(80 BYTE);
   DEV_STATUS               VARCHAR2(80 BYTE);
   MESSAGE                  VARCHAR2(4000 BYTE);
        
   
   V_REGIMEN                VARCHAR2(300);
   V_NOMEMI                 VARCHAR2(300);
   V_CALEMI                 VARCHAR2(240);
   V_NEXEMI                 VARCHAR2(50);
   V_COLEMI                 VARCHAR2(240);
   V_MUNEMI                 VARCHAR2(240);
   V_ESTEMI                 VARCHAR2(240);
   V_PAIEMI                 VARCHAR2(240);
   V_CODEMI                 VARCHAR2(240);
   
   
   V_IVATRA                 NUMBER := 0;   
   V_ISRRET                 NUMBER := 0; 
   V_IVARET                 NUMBER := 0;   
   V_TOTIVA                 NUMBER := 0;
   V_NUMLIN                 NUMBER := 0;
   V_SUBTBR                 NUMBER := 0;
   V_IMP_TOTAL_PED          NUMBER := 0;
   V_TOTPAG                 NUMBER := 0;
   V_TOTCAN                 NUMBER := 0;
   V_REMDES                 VARCHAR2(300);
   V_CALEXP                 VARCHAR2(300);
   V_NEXEXP                 VARCHAR2(300);
   V_COLEXP                 VARCHAR2(300);
   V_MUNEXP                 VARCHAR2(300);
   V_ESTEXP                 VARCHAR2(300);
   V_PAIEXP                 VARCHAR2(300);
   V_CODEXP                 VARCHAR2(300);
   V_CODUPC                 VARCHAR2(150 BYTE);
   V_UNIDAD                 VARCHAR2(100 BYTE) := NULL;
   V_SEC_UOM                VARCHAR2(180) := NULL;
   
   
   V_RFCEMI                 VARCHAR2(300) := 'RFC';
   V_CALENT                 VARCHAR2(300);
   V_NEXENT                 VARCHAR2(300);
   V_NINENT                 VARCHAR2(300);
   V_COLENT                 VARCHAR2(300);
   V_MUNENT                 VARCHAR2(300);
   V_ESTENT                 VARCHAR2(300);        
   V_PAIENT                 VARCHAR2(300);
   V_CODENT                 VARCHAR2(300);
                          
   
   V_TRANSP                 VARCHAR2(240);
   V_EMBARQ                 VARCHAR2(240); 
   V_SELLO1                 VARCHAR2(240); 
   V_SELLO2                 VARCHAR2(240);
   V_SELLO3                 VARCHAR2(240);
   V_SELLO4                 VARCHAR2(240);
   
   
   V_FORPAG                 VARCHAR2(240);
   V_CTAPAG                 VARCHAR2(240) := 'N';
   V_RELUUID                VARCHAR2(100);
   V_RELNUM                 NUMBER;
   V_RELSER                 VARCHAR2(100);
   V_RELFOL                 VARCHAR2(100);
   
   V_IS_CREDIT_NOTE         VARCHAR2(100);
   
   V_HEADERS_COUNT          NUMBER;
   V_REPORT                 VARCHAR2(10);
   
   CURSOR HEADERS_CUR(P_ORG_ID_H        NUMBER,
                      P_TIPO_DOC_H      VARCHAR2,
                      P_ORIGEN_H        NUMBER,
                      P_DOC_INI_H       NUMBER,
                      P_DOC_FIN_H       NUMBER, 
                      P_FECHA_INI_H     VARCHAR2, 
                      P_FECHA_FIN_H     VARCHAR2) 
    IS
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
                   AND OE.ORG_ID = P_ORG_ID_H), TRAX.PURCHASE_ORDER)                NUMEOC
         , TRAX.PURCHASE_ORDER_DATE                                                 FECHOC
         , (SELECT TO_DATE(ATTRIBUTE9,'YYYY-MM-DD HH24:MI:SS')
              FROM OE_ORDER_HEADERS_ALL OE 
             WHERE OE.ORDER_NUMBER = NVL(TRAX.CT_REFERENCE,0) 
               AND  ROWNUM = 1 
               AND OE.ORG_ID = P_ORG_ID_H)                                          FECH_PED
         , (SELECT ATTRIBUTE8 
              FROM OE_ORDER_HEADERS_ALL OE 
             WHERE OE.ORDER_NUMBER = NVL(TRAX.CT_REFERENCE,0) 
               AND  ROWNUM = 1 
               AND OE.ORG_ID = P_ORG_ID_H)                                          NUM_PED
         , (SELECT ATTRIBUTE12
              FROM OE_ORDER_HEADERS_ALL OE 
             WHERE OE.ORDER_NUMBER = NVL(TRAX.CT_REFERENCE,0) 
               AND  ROWNUM = 1 
               AND OE.ORG_ID = P_ORG_ID_H)                                          ADUANA         
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
       AND TRAX.ORG_ID = P_ORG_ID_H
       AND TRAX.CUST_TRX_TYPE_ID = P_ORIGEN_H
       AND TRAX.CTT_CLASS = NVL (P_TIPO_DOC_H,TRAX.CTT_CLASS)
       AND TO_NUMBER(TRAX.DOC_SEQUENCE_VALUE) BETWEEN NVL ( P_DOC_INI_H, TO_NUMBER(TRAX.DOC_SEQUENCE_VALUE))
                                                  AND NVL ( P_DOC_FIN_H, TO_NUMBER(TRAX.DOC_SEQUENCE_VALUE))
       AND TRUNC(TRAX.TRX_DATE) BETWEEN TRUNC(NVL(TO_DATE(P_FECHA_INI_H,'RRRR/MM/DD HH24:MI:SS'),TRAX.TRX_DATE))
                                    AND TRUNC(NVL(TO_DATE(P_FECHA_FIN_H,'RRRR/MM/DD HH24:MI:SS'),TRAX.TRX_DATE))           
     ORDER BY TO_NUMBER(TRAX.DOC_SEQUENCE_VALUE);


   
   CURSOR LINES_CUR (P_CUSTOMER_TRX_ID  NUMBER) 
   IS
    SELECT INV_ITEM_ID, 
           REPLACE(DESCRI,'FRAGIL','')                                              DESCRI, 
           SUM(CANTID)                                                              CANTID, 
           PBRUDE,  
           UOM_LINE, 
           SUM(CANTIDAD_SECUNDARIA)                                                 CANTIDAD_SECUNDARIA,
           UOM, 
           UOM2, 
           SUM(TASIPE)                                                              TASIPE, 
           SUM(TASA_ISR_RET)                                                        TASA_ISR_RET,
           SUM(TASA_IVA_RET)                                                        TASA_IVA_RET,
           SUM(MONIPE)                                                              MONIPE,
           SUM(TTL_ISR_RET)                                                         TTL_ISR_RET,
           SUM(TTL_IVA_RET)                                                         TTL_IVA_RET,                
           SUM(IMPBRU)                                                              IMPBRU,
           TARA * SUM(CANTIDAD_SECUNDARIA)                                          TARA,
           CVEUNIDAD,
           CVEPRODSERV
      FROM (SELECT LINEAS.LINE_ID
                   , LINEAS.CVEPRODSERV
                   , LINEAS.CVEUNIDAD
                   , LINEAS.LINEA
                   , LINEAS.TIPO_LINEA
                   , LINEAS.INV_ITEM_ID
                   , LINEAS.CODE_BAR 
                   , LINEAS.SERIAL_CODE
                   , TARA
                   , DECODE(P_ORG_ID,
                            83, DESCRI,
                            REGEXP_REPLACE(LINEAS.DESCRI, 
                                           '[^a-zA-Z0-9. ]', ''))                   DESCRI
                   , LINEAS.CANTIDAD_REAL_TRX                                       CANTIDAD_REAL_TRX
                   , LINEAS.CANTID                                                  CANTID
                   , LINEAS.CANT_CREDITO                                            CANT_CREDITO
                   , LINEAS.PBRUDE
                   , LINEAS.UOM_LINE
                   , LINEAS.CANTIDAD_SECUNDARIA                                     CANTIDAD_SECUNDARIA
                   , LINEAS.UOM
                   , LINEAS.UOM2
                   , SUM(LINEAS.TASIPE)                                             TASIPE
                   , SUM(LINEAS.TASA_ISR_RET)                                       TASA_ISR_RET
                   , SUM(LINEAS.TASA_IVA_RET)                                       TASA_IVA_RET
                   , SUM(LINEAS.MONIPE)                                             MONIPE
                   , SUM(LINEAS.TTL_ISR_RET)                                        TTL_ISR_RET
                   , SUM(LINEAS.TTL_IVA_RET)                                        TTL_IVA_RET
                   , LINEAS.IMPBRU                                                  IMPBRU
                   , LINEAS.DESCUENTO
                   , LINEAS.PEDIMENTO
                   , LINEAS.FECHA_PEDIMENTO
                   , LINEAS.ADUANA
              FROM (SELECT   CTL.INTERFACE_LINE_ATTRIBUTE6                          LINE_ID
                           , (CASE
                              WHEN CTL.INTERFACE_LINE_CONTEXT = 'CATEGORIAS_SAT'
                              THEN CTL.INTERFACE_LINE_ATTRIBUTE1
                              ELSE ''
                               END)                                                 CVEPRODSERV
                           , (CASE
                              WHEN CTL.INTERFACE_LINE_CONTEXT = 'CATEGORIAS_SAT'
                              THEN CTL.INTERFACE_LINE_ATTRIBUTE2
                               END)                                                 CVEUNIDAD
                           , CTL.LINE_NUMBER                                        LINEA
                           , CTL.LINE_TYPE                                          TIPO_LINEA
                           , CTL.INVENTORY_ITEM_ID                                  INV_ITEM_ID
                           , ''                                                     CODE_BAR
                           , ''                                                     SERIAL_CODE
                           , XXCALV_CALCULA_TARA_CFD(CTL.INTERFACE_LINE_ATTRIBUTE6) TARA
                           , TRIM(CTL.DESCRIPTION||REPLACE(XXCALV_GRADE_DESC(CTL.INTERFACE_LINE_ATTRIBUTE6),
                                                           'CASCADO CASCADO',
                                                           'CASCADO')|| ', ' || (SELECT MEANING
                                                                                   FROM FND_LOOKUP_VALUES 
                                                                                  WHERE LOOKUP_TYPE = 'CREDIT_MEMO_REASON'
                                                                                    AND LOOKUP_CODE = CTL.REASON_CODE
                                                                                    AND LANGUAGE = 'ESA')  
                                                                             )      DESCRI
                           , DECODE(CTL.QUANTITY_INVOICED,
                                    NULL, ABS(CTL.QUANTITY_CREDITED),
                                    CTL.QUANTITY_INVOICED)                          CANTIDAD_REAL_TRX
                           , NVL ( DECODE(CTL.QUANTITY_INVOICED, 
                                          NULL, ABS(CTL.QUANTITY_CREDITED), 
                                          CTL.QUANTITY_INVOICED ),1)                CANTID 
                           , ''                                                     CANT_CREDITO
                           , NVL(ABS(CTL.UNIT_SELLING_PRICE),1)                     PBRUDE
                           , CTL.UOM_CODE                                           UOM_LINE
                           , (SELECT OEL.ORDERED_QUANTITY2 
                                FROM OE_ORDER_LINES_ALL OEL 
                               WHERE OEL.LINE_ID = CTL.INTERFACE_LINE_ATTRIBUTE6 
                             )                                                      CANTIDAD_SECUNDARIA
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
                           , ABS((CASE TAX.VAT_TAX_ID
                                 WHEN 10129 THEN TAX.TAX_RATE
                                 WHEN 10131 THEN TAX.TAX_RATE
                                 WHEN 10153 THEN TAX.TAX_RATE
                                 WHEN 10128 THEN TAX.TAX_RATE
                                 WHEN 10132 THEN TAX.TAX_RATE
                                 WHEN 10236 THEN TAX.TAX_RATE
                                 WHEN 10335 THEN TAX.TAX_RATE
                             END))                                                  TASIPE,
                             ABS((CASE TAX.VAT_TAX_ID
                                WHEN 10237 THEN TAX.TAX_RATE
                                ELSE NULL
                             END))                                                  TASA_ISR_RET,
                             ABS((CASE TAX.VAT_TAX_ID
                                WHEN 10238 THEN TAX.TAX_RATE
                                ELSE NULL
                             END))                                                  TASA_IVA_RET,
                             ABS((CASE TAX.VAT_TAX_ID
                                 WHEN 10129 THEN TAX.EXTENDED_AMOUNT
                                 WHEN 10131 THEN TAX.EXTENDED_AMOUNT
                                 WHEN 10153 THEN TAX.EXTENDED_AMOUNT 
                                 WHEN 10128 THEN TAX.EXTENDED_AMOUNT
                                 WHEN 10132 THEN TAX.EXTENDED_AMOUNT
                                 WHEN 10236 THEN TAX.EXTENDED_AMOUNT
                                 WHEN 10335 THEN TAX.EXTENDED_AMOUNT
                             ELSE NULL
                             END))                                                  MONIPE,
                             ABS((CASE TAX.VAT_TAX_ID
                                WHEN 10237 THEN TAX.EXTENDED_AMOUNT
                                ELSE NULL
                             END))                                                  TTL_ISR_RET,
                             ABS((CASE TAX.VAT_TAX_ID
                                WHEN 10238 THEN TAX.EXTENDED_AMOUNT
                                ELSE NULL
                             END))                                                  TTL_IVA_RET
                           , ABS((NVL(  ( DECODE( CTL.QUANTITY_INVOICED, 
                                                 NULL, (ABS(CTL.QUANTITY_CREDITED) * ABS(CTL.UNIT_SELLING_PRICE)), 
                                                 (CTL.QUANTITY_INVOICED * CTL.UNIT_SELLING_PRICE) ) ) , CTL.EXTENDED_AMOUNT)))  IMPBRU
                           , ''                                                     DESCUENTO
                           , ''                                                     PEDIMENTO
                           , ''                                                     FECHA_PEDIMENTO
                           , ''                                                     ADUANA
                      FROM RA_CUSTOMER_TRX_LINES_ALL CTL
                         , RA_CUSTOMER_TRX_LINES_ALL TAX
                     WHERE CTL.LINE_TYPE = 'LINE' 
                       AND CTL.CUSTOMER_TRX_ID = NVL(P_CUSTOMER_TRX_ID,CTL.CUSTOMER_TRX_ID) 
                       AND CTL.ORG_ID = P_ORG_ID
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
             , LINEAS.DESCRI
             , LINEAS.CANTIDAD_REAL_TRX
             , LINEAS.CANTID
             , LINEAS.CANTIDAD_SECUNDARIA
             , LINEAS.CANT_CREDITO
             , LINEAS.PBRUDE
             , LINEAS.IMPBRU
             , LINEAS.UOM_LINE
             , LINEAS.UOM
             , LINEAS.UOM2             
             , LINEAS.DESCUENTO
             , LINEAS.PEDIMENTO
             , LINEAS.FECHA_PEDIMENTO
             , LINEAS.ADUANA
             , LINEAS.CVEUNIDAD
             , LINEAS.CVEPRODSERV
             )
    GROUP BY INV_ITEM_ID, 
             TARA,
             DESCRI,
             PBRUDE,  
             UOM_LINE, 
             UOM, 
             UOM2,
             CVEUNIDAD,
             CVEPRODSERV          
    ORDER BY 1;    
    
    
    CURSOR REL_CUR(P_CUSTOMER_TRX_ID NUMBER)
    IS
    SELECT AN.TEXT                      REL_UUID,
           TRAX.DOC_SEQUENCE_VALUE      REL_FOL,
           (SELECT SEQ.ATTRIBUTE1 
              FROM FND_DOCUMENT_SEQUENCES SEQ
             WHERE SEQ.TABLE_NAME = 'RA_CUSTOMER_TRX_ALL' 
               AND SEQ.DOC_SEQUENCE_ID = TRAX.DOC_SEQUENCE_ID) REL_SER       
      FROM AR_RECEIVABLE_APPLICATIONS_ALL   ARAA,
           RA_CUSTOMER_TRX_PARTIAL_CFD      TRAX,
           AR_NOTES                         AN
     WHERE 1 = 1 
       AND ARAA.APPLIED_CUSTOMER_TRX_ID = AN.CUSTOMER_TRX_ID
       AND ARAA.CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID
       AND TRAX.CUSTOMER_TRX_ID = AN.CUSTOMER_TRX_ID;
    
    
   CREDIT_NOTE_EXCEPTION    EXCEPTION;
   NO_INVOICE_FOUND         EXCEPTION;
    
    
   PROCEDURE FILE_PUT_LINE (P_MANEJADOR     UTL_FILE.FILE_TYPE,
                            P_STRING_LINE   VARCHAR2)
   IS
   BEGIN 
        IF P_TIMBRAR = 'YES' THEN
            UTL_FILE.PUT_LINE (P_MANEJADOR, P_STRING_LINE);
        END IF;
        FND_FILE.PUT_LINE(FND_FILE.LOG, P_STRING_LINE);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, P_STRING_LINE);
   END FILE_PUT_LINE;
   
   FUNCTION ROUND_TOT (P_AMOUNT     NUMBER)
     RETURN NUMBER
   IS 
        var_result_round    NUMBER;
   BEGIN
        SELECT DECODE(MOD(P_AMOUNT,TRUNC(P_AMOUNT,2)),
                      0.005, ROUND(P_AMOUNT,2),
                      P_AMOUNT)
          INTO var_result_round  
          FROM DUAL; 
          
       RETURN var_result_round;
   END;

BEGIN
   BEGIN
       
       
       SELECT FLN.MEANING                       REMDES,
              FLN.DESCRIPTION                   CALEXP,
              REPLACE(FLN.TAG,'N/A','')         NEXEXP,  
              LOC.ADDRESS_LINE_2                COLEXP,
              LOC.REGION_2                      MUNEXP, 
              DECODE(UPPER(FLV.DESCRIPTION),
                     'DISTRITO FEDERAL','DF',
                     UPPER(FLV.DESCRIPTION))    ESTEXP, 
              REPLACE(T.NLS_TERRITORY,'?','E')  PAIEXP, 
              LOC.POSTAL_CODE                   CODEXP
         INTO V_REMDES, 
              V_CALEXP, 
              V_NEXEXP, 
              V_COLEXP, 
              V_MUNEXP, 
              V_ESTEXP, 
              V_PAIEXP, 
              V_CODEXP
         FROM HR_ORGANIZATION_UNITS O,
              HR_LOOKUPS L,
              HR_LOOKUPS L2,
              HR_LOCATIONS LOC, 
              FND_LOOKUP_VALUES FLV, 
              FND_TERRITORIES T,
              FND_LOOKUP_VALUES FLN
        WHERE O.TYPE = L.LOOKUP_CODE(+)
          AND L.LOOKUP_TYPE(+) = 'ORG_TYPE'
          AND O.INTERNAL_EXTERNAL_FLAG = L2.LOOKUP_CODE(+)
          AND L2.LOOKUP_TYPE(+) = 'INTL_EXTL'
          AND O.LOCATION_ID = LOC.LOCATION_ID(+)
          AND FLV.LOOKUP_TYPE = 'PER_MX_STATE_CODES'
          AND FLV.LANGUAGE = USERENV('LANG')
          AND LOC.REGION_1 = FLV.LOOKUP_CODE
          AND LOC.COUNTRY = T.TERRITORY_CODE
          AND FLN.LOOKUP_TYPE = 'XXCALV_DIRECCIONES_CEDIS'
          AND FLN.LANGUAGE = USERENV('LANG')
          AND FLN.LOOKUP_CODE = ORGANIZATION_ID 
          AND ORGANIZATION_ID = P_ORG_ID;
          
   EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.LOG,'Error inesperado al obtener calle y n?mero exterior de CEDIS. '||SQLERRM);
   END;

   
   
    SELECT COUNT(1)
      INTO V_HEADERS_COUNT 
      FROM RA_CUSTOMER_TRX_PARTIAL_CFD TRAX
     WHERE 1 = 1
       AND TRAX.ORG_ID = P_ORG_ID
       AND TRAX.CUST_TRX_TYPE_ID = P_ORIGEN
       AND TRAX.CTT_CLASS = NVL (P_TIPO_DOC,TRAX.CTT_CLASS)
       AND TO_NUMBER(TRAX.DOC_SEQUENCE_VALUE) BETWEEN NVL ( P_DOC_INI, TO_NUMBER(TRAX.DOC_SEQUENCE_VALUE))
                                                  AND NVL ( P_DOC_FIN, TO_NUMBER(TRAX.DOC_SEQUENCE_VALUE))
       AND TRUNC(TRAX.TRX_DATE) BETWEEN TRUNC(NVL(TO_DATE(P_FECHA_INI,'RRRR/MM/DD HH24:MI:SS'),TRAX.TRX_DATE))
                                    AND TRUNC(NVL(TO_DATE(P_FECHA_FIN,'RRRR/MM/DD HH24:MI:SS'),TRAX.TRX_DATE))           
     ORDER BY TO_NUMBER(TRAX.DOC_SEQUENCE_VALUE);
     
    IF V_HEADERS_COUNT = 0 THEN
        RAISE NO_INVOICE_FOUND;
    END IF;

    
   FOR HED_REC IN HEADERS_CUR(P_ORG_ID, P_TIPO_DOC, P_ORIGEN, P_DOC_INI, P_DOC_FIN, P_FECHA_INI, P_FECHA_FIN) LOOP

       IF (HED_REC.RFCEMI IS NULL) AND (HED_REC.RFCREC IS NULL) THEN
           V_RFCEMI := 'NULO';
           FND_FILE.PUT_LINE (FND_FILE.LOG,'No se encontro RFC del cliente, no es posible generar la factura.');
       ELSE
           BEGIN
           
                SELECT UPPER(LOC_INFORMATION14)                         REGIMEN,
                       UPPER(LOC_INFORMATION15)                         RFCEMI, 
                       UPPER(HOU.NAME)                                  NOMEMI,
                       UPPER(ADDRESS_LINE_1)                            CALEMI,
                       UPPER(ADDRESS_LINE_3)                            NEXEMI,
                       UPPER(ADDRESS_LINE_2)                            COLEMI, 
                       UPPER(TOWN_OR_CITY)                              MUNEMI, 
                       (SELECT UPPER(FLV.MEANING)
                          FROM FND_LOOKUP_VALUES FLV
                         WHERE FLV.LOOKUP_TYPE = 'PER_MX_STATE_CODES'
                           AND FLV.LANGUAGE = USERENV('LANG')
                           AND FLV.LOOKUP_CODE = HL.REGION_1)           ESTEMI, 
                       (SELECT UPPER(NVL(FT.NLS_TERRITORY, 'MEXICO'))
                          FROM FND_TERRITORIES  FT
                         WHERE 1=1
                           AND FT.TERRITORY_CODE = UPPER(HL.COUNTRY))   PAIEMI,
                       UPPER(POSTAL_CODE)                               CODEMI
                  INTO V_REGIMEN,
                       V_RFCEMI,
                       V_NOMEMI,
                       V_CALEMI,
                       V_NEXEMI,
                       V_COLEMI, 
                       V_MUNEMI, 
                       V_ESTEMI, 
                       V_PAIEMI, 
                       V_CODEMI
                  FROM HR_ORGANIZATION_UNITS HOU,
                       HR_LOCATIONS HL,
                       HR_ORGANIZATION_INFORMATION HOI
                 WHERE 1 = 1
                   AND HOU.LOCATION_ID = HL.LOCATION_ID
                   AND HOI.ORGANIZATION_ID = HOU.ORGANIZATION_ID
                   AND HOI.ORG_INFORMATION_CONTEXT = 'Operating Unit Information'
                   AND HOU.ORGANIZATION_ID = DECODE(P_ORG_ID, 85, 85, 84, 84, 83, 83, 82);
                   
           EXCEPTION WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error buscando RFC: '||SQLERRM);
           END;
           
           BEGIN
           
                SELECT NVL(UPPER(ATTRIBUTE15),'N')  CTAPAG
                  INTO V_CTAPAG
                  FROM FND_LOOKUP_VALUES_VL FLV
                 WHERE FLV.LOOKUP_TYPE = 'XXCALV_CUENTAS_FE'
                   AND REPLACE(UPPER(MEANING),'-','') = REPLACE(UPPER(HED_REC.RFCEMI),'-','')
                   AND ENABLED_FLAG = 'Y';
                   
                   
                SELECT FVT.DESCRIPTION
                  INTO V_FORPAG
                  FROM FND_FLEX_VALUE_SETS  FVS,
                       FND_FLEX_VALUES      FV,
                       FND_FLEX_VALUES_TL   FVT
                 WHERE 1 = 1
                   AND FVS.FLEX_VALUE_SET_ID = FV.FLEX_VALUE_SET_ID
                   AND FV.FLEX_VALUE_ID = FVT.FLEX_VALUE_ID
                   AND FVS.FLEX_VALUE_SET_NAME = 'PAC_SAT_FORPAG'
                   AND FVT.LANGUAGE = USERENV('LANG')
                   AND FV.FLEX_VALUE = NVL(HED_REC.CVEFORPAG, '99');

           EXCEPTION WHEN OTHERS THEN
                FND_FILE.PUT_LINE (FND_FILE.LOG,'No se encontro metodo de pago.');
           END;                                 
            
           BEGIN     
                BEGIN
                
                     SELECT LOC.ADDRESS1                          CALENT,   
                            REPLACE(LOC.ADDRESS2,'N/A','')        NEXENT,
                            REPLACE(LOC.ADDRESS3,'N/A','')        NINENT,
                            LOC.ADDRESS4                          COLENT,
                            LOC.CITY                              MUNENT,
                            LOC.STATE                             ESTENT,
                            REPLACE(TERR.NLS_TERRITORY,'?','E')   PAIENT,
                            LPAD(LOC.POSTAL_CODE,5,'0')           CODENT     
                       INTO V_CALENT, 
                            V_NEXENT, 
                            V_NINENT, 
                            V_COLENT, 
                            V_MUNENT, 
                            V_ESTENT,         
                            V_PAIENT, 
                            V_CODENT 
                       FROM HZ_PARTIES HZ,
                            HZ_PARTY_SITES HZS, 
                            HZ_CUST_ACCT_SITES_ALL HZCS,
                            HZ_LOCATIONS LOC,
                            FND_TERRITORIES_VL TERR
                      WHERE HZ.PARTY_ID = HED_REC.NUMCLI 
                        AND HZ.PARTY_ID = HZS.PARTY_ID
                        AND HZS.PARTY_SITE_ID = HZCS.PARTY_SITE_ID
                        AND HZS.LOCATION_ID = LOC.LOCATION_ID
                        AND SHIP_TO_FLAG = 'P'
                        AND TERR.TERRITORY_CODE = LOC.COUNTRY;
                        
                EXCEPTION WHEN OTHERS THEN
                     FND_FILE.PUT_LINE (FND_FILE.LOG,'Error inesperado al obtener direccion de tienda receptora. '||SQLERRM);
                END;
                
                
                V_TOTIVA := 0;
                V_IVATRA := 0;
                V_ISRRET := 0; 
                V_IVARET := 0;
                V_NUMLIN := 0;
                V_SUBTBR := 0;
                V_TOTCAN := 0;
                V_TOTPAG := 0;
                    
                
                V_ARCHIVO := UPPER(NVL(V_RFCEMI,HED_REC.RFCREC)) ||'_'||HED_REC.RFCREC||'_'||HED_REC.SERFOL||'_'||TO_CHAR(HED_REC.NUMFOL)||'.txt';
                V_MANEJADOR := UTL_FILE.FOPEN (V_DIRECTORIO, V_ARCHIVO, 'W');
                
                    
                V_TOTPAG := 0;
                V_IMP_TOTAL_PED := 0;
                
                BEGIN
                    
                    FOR LIN_REC IN LINES_CUR (HED_REC.CUSTOMER_TRX_ID) LOOP
                        V_TOTPAG := V_TOTPAG + LIN_REC.IMPBRU + NVL(LIN_REC.MONIPE,0);
                    END LOOP;
                    
                EXCEPTION WHEN OTHERS THEN
                    FND_FILE.PUT_LINE (FND_FILE.LOG,'Error inesperado al obtener total de lineas de la factura. '||SQLERRM);
                END;

                BEGIN
                    
                    SELECT ROUND(SUM(IMP),2)  
                      INTO V_IMP_TOTAL_PED 
                      FROM (SELECT TRX.DOC_SEQUENCE_VALUE NUM_FACTURA,
                                   HED.ORDER_NUMBER,LIN.LINE_ID,
                                   LIN.SOLD_FROM_ORG_ID,
                                   HR.NAME,
                                   B.DESCRIPTION,B.INVENTORY_ITEM_ID,
                                   LIN.ORDER_QUANTITY_UOM,
                                   LIN.ORDERED_QUANTITY QTY,
                                   LIN.ORDERED_QUANTITY2 QTY2,
                                   LIN.UNIT_SELLING_PRICE PRICE,
                                   LIN.ORDERED_QUANTITY QTY3,
                                   ROUND(LIN.UNIT_SELLING_PRICE*LIN.ORDERED_QUANTITY,2) IMP
                              FROM OE_ORDER_HEADERS_ALL HED,
                                   OE_ORDER_LINES_ALL LIN,
                                   HZ_PARTIES PARTY,
                                   HZ_CUST_ACCOUNTS CUST_ACCT,
                                   HR_ALL_ORGANIZATION_UNITS HR,
                                   MTL_SYSTEM_ITEMS_B B,
                                   OE_TRANSACTION_TYPES_ALL TTA,
                                   RA_CUSTOMER_TRX_ALL TRX, 
                                   RA_CUSTOMER_TRX_LINES_ALL TRXL
                             WHERE 1=1
                               AND HED.HEADER_ID = LIN.HEADER_ID
                               AND TTA.TRANSACTION_TYPE_ID = LIN.LINE_TYPE_ID
                               AND LIN.SOLD_TO_ORG_ID = CUST_ACCT.CUST_ACCOUNT_ID(+)
                               AND CUST_ACCT.PARTY_ID = PARTY.PARTY_ID(+)
                               AND HR.ORGANIZATION_ID = LIN.SOLD_FROM_ORG_ID
                               AND B.INVENTORY_ITEM_ID = LIN.INVENTORY_ITEM_ID
                               AND B.ORGANIZATION_ID = TTA.WAREHOUSE_ID
                               AND TTA.ORG_ID = HR.ORGANIZATION_ID
                               AND (   HED.FLOW_STATUS_CODE IN ('CLOSED','CERRADO') 
                                    OR HED.FLOW_STATUS_CODE IN ('BOOKED','REGISTRADO')
                                   )
                               AND LIN.LINE_ID = TRXL.INTERFACE_LINE_ATTRIBUTE6
                               AND TRXL.LINE_TYPE = 'LINE'
                               AND TRXL.INTERFACE_LINE_CONTEXT = 'ORDER ENTRY'
                               AND TRX.CUSTOMER_TRX_ID = TRXL.CUSTOMER_TRX_ID
                               AND TRX.ORG_ID = HED_REC.ORG_ID
                               AND TRX.CUST_TRX_TYPE_ID = HED_REC.CUST_TRX_TYPE_ID
                               AND TRX.CUSTOMER_TRX_ID = HED_REC.CUSTOMER_TRX_ID
                               ORDER BY LINE_ID
                             )
                         WHERE 1=1
                          GROUP BY NUM_FACTURA
                     ORDER BY 1;
                     
                EXCEPTION WHEN NO_DATA_FOUND THEN
                    FND_FILE.PUT_LINE (FND_FILE.LOG,'No se encontr? pedido, sin embargo se generar? la factura. '||SQLERRM);
                    V_IMP_TOTAL_PED := V_TOTPAG;
                WHEN OTHERS THEN
                    FND_FILE.PUT_LINE (FND_FILE.LOG,'Error inesperado al obtener total de lineas del pedido. '||SQLERRM);
                END;



                IF V_TOTPAG = V_TOTPAG THEN
                    
                    BEGIN
                        
                    
                        SELECT H.ATTRIBUTE1                           TRANSP,
                               H.ATTRIBUTE11                          EMBARQ,
                               H.ATTRIBUTE3                           SELLO1,
                               H.ATTRIBUTE4                           SELLO2,
                               H.ATTRIBUTE5                           SELLO3,
                               H.ATTRIBUTE10                          SELLO4,
                               TO_CHAR(H.REQUEST_DATE,'YYYY-MM-DD')   FECHOC,
                               H.ATTRIBUTE7                           CONTRA
                          INTO V_TRANSP, 
                               V_EMBARQ, 
                               V_SELLO1, 
                               V_SELLO2, 
                               V_SELLO3, 
                               V_SELLO4, 
                               V_FECHOC, 
                               V_CONTRA
                          FROM OE_ORDER_HEADERS_ALL H
                         WHERE ORG_ID = HED_REC.ORG_ID
                           AND ORDER_TYPE_ID <> 1144  
                           AND ORDER_NUMBER = HED_REC.ORDEN_COMPRA;
                           
                    EXCEPTION WHEN OTHERS THEN
                        FND_FILE.PUT_LINE (FND_FILE.LOG,'Error inesperado al buscar el Certificado Zoosanitario. '||SQLERRM);
                    END;
                    
                    
                    
                    
                    FILE_PUT_LINE (V_MANEJADOR, 'VERSIO  3.3');   
                    FILE_PUT_LINE (V_MANEJADOR, 'E');
                    
                    
                    IF HED_REC.TIPO_ADENDA = 'WALMART' THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'TRADPP  '||V_RFCEMI);
                    ELSE
                        FILE_PUT_LINE (V_MANEJADOR, 'TRADPP  '||V_NOMEMI);
                    END IF;
                    
                    
                    FILE_PUT_LINE (V_MANEJADOR, 'CTPPRO  '||'ZZ');
                    FILE_PUT_LINE (V_MANEJADOR, 'CVEREGIMEN ' || (CASE
                                                                    WHEN V_REGIMEN = 'REGIMEN GENERAL DE LA LEY DE PERSONAS MORALES'
                                                                    THEN '601'
                                                                    WHEN V_REGIMEN = 'PERSONA FISICA CON ACTIVIDAD DE ARRENDAMIENTO'
                                                                    THEN '606'
                                                                    WHEN V_REGIMEN = 'REGIMEN DE ACTIVIDADES AGRICOLAS, GANADERAS, SILVICOLAS Y PESQUERAS'
                                                                    THEN '622'
                                                                 END));
                    FILE_PUT_LINE (V_MANEJADOR, 'REGIMEN  '||V_REGIMEN);


                    IF HED_REC.TIPO_ADENDA = 'WALMART' THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'CODMETPAG  ' || 'PPD'); 
                        FILE_PUT_LINE (V_MANEJADOR, 'CVEFORPAG  ' || '99');       
                    ELSE
                        IF UPPER(HED_REC.ATTRIBUTE_CATEGORY) = 'PAYMENT IN PARTIALITIES' THEN
                            FILE_PUT_LINE (V_MANEJADOR, 'CODMETPAG  ' || 'PPD');  
                        ELSIF UPPER(HED_REC.ATTRIBUTE_CATEGORY) = 'PAID IN A SINGLE EXHIBITION' THEN
                            FILE_PUT_LINE (V_MANEJADOR, 'CODMETPAG  ' || 'PUE');  
                        ELSE
                            FILE_PUT_LINE (V_MANEJADOR, 'CODMETPAG  ' || 'PPD');  
                        END IF;    

                        FILE_PUT_LINE (V_MANEJADOR, 'CVEFORPAG  ' || (CASE
                                                                        WHEN HED_REC.CVEFORPAG IS NOT NULL THEN
                                                                            HED_REC.CVEFORPAG
                                                                        ELSE '99'
                                                                      END));

                    END IF;


                    IF V_CTAPAG = 'N' THEN 
                        V_CTAPAG := ''; 
                    END IF;
                    
                    
                    FILE_PUT_LINE (V_MANEJADOR, 'CTAPAG  '||V_CTAPAG);
                    FILE_PUT_LINE (V_MANEJADOR, 'FORPAG  '||V_FORPAG); 
                    FILE_PUT_LINE (V_MANEJADOR, 'METPAG  '||(CASE 
                                                                WHEN UPPER(HED_REC.ATTRIBUTE_CATEGORY) = 'PAYMENT IN PARTIALITIES' THEN
                                                                    'PAGO EN PARCIALIDADES O DIFERIDO' 
                                                                WHEN UPPER(HED_REC.ATTRIBUTE_CATEGORY) = 'PAID IN A SINGLE EXHIBITION' THEN
                                                                    'PAGO EN UNA SOLA EXHIBICION'      
                                                                ELSE
                                                                    'PAGO EN PARCIALIDADES O DIFERIDO' 
                                                              END));
                    FILE_PUT_LINE (V_MANEJADOR, 'NUMFOL  '||HED_REC.NUMFOL); 
                    FILE_PUT_LINE (V_MANEJADOR, 'SERFOL  '||HED_REC.SERFOL);  
                    FILE_PUT_LINE (V_MANEJADOR, 'REFEMI  '||HED_REC.SERFOL||HED_REC.NUMFOL);  
                    
                    
                    IF HED_REC.SERFOL = 'FBTH' THEN
                        IF P_PELECHA = 'Y' THEN
                            FILE_PUT_LINE (V_MANEJADOR, 'PELCHA  '||TO_CHAR(NULL));
                        ELSE
                            FILE_PUT_LINE (V_MANEJADOR, 'PELCHA  '||'AVES DE DESECHO, PROHIBIDO PELECHAR, SÓLO PARA SU SACRIFICIO.');
                        END IF;
                    END IF;
                    
                    
                    FILE_PUT_LINE (V_MANEJADOR, 'FECEXP  '||HED_REC.FECEXP);  


                    IF HED_REC.TIPO_ADENDA = 'CHEDRAUI' AND P_TIPO_DOC = 'CM' THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'FUNDOC  '||'C');
                    ELSE
                        FILE_PUT_LINE (V_MANEJADOR, 'FUNDOC  '||'O'); 
                    END IF;
                    
                    
                    FILE_PUT_LINE (V_MANEJADOR, 'TIPDOC  '||HED_REC.TIPDOC);  
                    FILE_PUT_LINE (V_MANEJADOR, 'NOMDOC  '||HED_REC.NOMDOC);  
                    FILE_PUT_LINE (V_MANEJADOR, 'TIPMON  '||HED_REC.TIPMON);
                    FILE_PUT_LINE (V_MANEJADOR, 'TIPCAM  '||HED_REC.TIPCAM); 
                    FILE_PUT_LINE (V_MANEJADOR, 'SW_TC  ' ||HED_REC.SW_TC);  
                    FILE_PUT_LINE (V_MANEJADOR, 'DIAPAG  '||HED_REC.DIAPAG); 
                    FILE_PUT_LINE (V_MANEJADOR, 'PDPPAG  '||'0');  
                    FILE_PUT_LINE (V_MANEJADOR, 'MDPPAG  '||'0');  
                
                
                    IF (HED_REC.TIPO_ADENDA = 'SORIANA' AND NVL(P_EXTEMP,0) = 0 AND NVL(V_CONTRA,0) > 0) THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'PO_NUMEOC  '||'SI');  
                        FILE_PUT_LINE (V_MANEJADOR, 'TDA_CONTRA  '||V_CONTRA);
                    ELSIF (HED_REC.TIPO_ADENDA = 'SORIANA' AND NVL(P_EXTEMP,0) > 0) THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'PO_NUMEOC  '||'SI');  
                        FILE_PUT_LINE (V_MANEJADOR, 'TDA_CONTRA  '||P_EXTEMP);                     
                    END IF;

                    
                    IF HED_REC.TIPO_ADENDA IN ('COMERCIAL_MEXICANA','CHEDRAUI') THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'NUMDPT  '||P_DEPTO);            
                    END IF;
                    
                    
                    IF HED_REC.TIPO_ADENDA = 'OXXO' THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'TIPROV  '||'02'); 
                        FILE_PUT_LINE (V_MANEJADOR, 'TIPLOC  '||'C');  
                    END IF;
                    
                    
                    FILE_PUT_LINE (V_MANEJADOR, 'NUMEOC  '||HED_REC.NUMEOC); 
                    
                    
                    IF HED_REC.TIPO_ADENDA = 'WALMART' THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'CONTRA  '||V_CONTRA); 
                    END IF;                    
                    
                    FILE_PUT_LINE (V_MANEJADOR, 'FECHOC  '||NVL(V_FECHOC,TO_CHAR(HED_REC.FECHOC,'YYYY-MM-DD')));  
                    
                    IF HED_REC.TIPO_ADENDA = 'SORIANA' THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'FECCON  '||HED_REC.FECCON);  
                    END IF;
                    
                    
--                    FILE_PUT_LINE (V_MANEJADOR, 'NOTAS3 '||REPLACE (UPPER(IBY_AMOUNT_IN_WORDS.GET_AMOUNT_IN_WORDS(ROUND_TOT((V_TOTPAG - ABS(NVL(V_IVARET,0)) - ABS(NVL(V_ISRRET,0)))),'MXN')), 'MXN', HED_REC.TIPMON));
                    FILE_PUT_LINE (V_MANEJADOR, 'TRANSP  '||V_TRANSP);  
                    FILE_PUT_LINE (V_MANEJADOR, 'SELLO1  '||V_SELLO1); 
                    FILE_PUT_LINE (V_MANEJADOR, 'SELLO2  '||V_SELLO2); 
                    FILE_PUT_LINE (V_MANEJADOR, 'SELLO3  '||V_SELLO3);  
                    FILE_PUT_LINE (V_MANEJADOR, 'SELLO4  '||V_SELLO4); 
                    
                    
                    IF HED_REC.TIPO_ADENDA IS NOT NULL THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'ADDEND  '||'1'); 
                    ELSE    
                        FILE_PUT_LINE (V_MANEJADOR, 'ADDEND  '||'0'); 
                    END IF;
                                        
                   
                    FILE_PUT_LINE (V_MANEJADOR, 'RFCEMI  '||V_RFCEMI);  
                    FILE_PUT_LINE (V_MANEJADOR, 'NOMEMI  '||V_NOMEMI);
                    
                    
                    IF V_RFCEMI = 'PAC941215E50' THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'EANEMI  '||'7504003607004'); 
                    ELSE
                        FILE_PUT_LINE (V_MANEJADOR, 'EANEMI  '||'');  
                    END IF;
                    
                    
                    FILE_PUT_LINE (V_MANEJADOR, 'CODLUGEXP   ' || NVL(V_CODEXP, V_CODEMI));
                    FILE_PUT_LINE (V_MANEJADOR, 'NUMEMI  '||HED_REC.NUMEMI);    
                    FILE_PUT_LINE (V_MANEJADOR, 'CALEMI  '||V_CALEMI);  
                    FILE_PUT_LINE (V_MANEJADOR, 'NEXEMI  '||V_NEXEMI);  
                    FILE_PUT_LINE (V_MANEJADOR, 'COLEMI  '||V_COLEMI);  
                    FILE_PUT_LINE (V_MANEJADOR, 'MUNEMI  '||V_MUNEMI);  
                    FILE_PUT_LINE (V_MANEJADOR, 'ESTEMI  '||V_ESTEMI); 
                    FILE_PUT_LINE (V_MANEJADOR, 'PAIEMI  '||V_PAIEMI);
                    FILE_PUT_LINE (V_MANEJADOR, 'CODEMI  '||V_CODEMI);
                    FILE_PUT_LINE (V_MANEJADOR, '');  
                    
                    
                    IF P_ORG_ID NOT IN (82, 84, 85) THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'CALEXP  '||UPPER(V_CALEXP));  
                        FILE_PUT_LINE (V_MANEJADOR, 'NEXEXP  '||REPLACE(V_NEXEXP,'N/A',''));  
                        FILE_PUT_LINE (V_MANEJADOR, 'COLEXP  '||UPPER(REPLACE(V_COLEXP,'N/A','')));  
                        FILE_PUT_LINE (V_MANEJADOR, 'MUNEXP  '||UPPER(V_MUNEXP));    
                        FILE_PUT_LINE (V_MANEJADOR, 'LUGEXP  '||UPPER(V_PAIEXP||' '||V_ESTEXP)); 
                        FILE_PUT_LINE (V_MANEJADOR, 'ESTEXP  '||UPPER(V_ESTEXP));    
                        FILE_PUT_LINE (V_MANEJADOR, 'PAIEXP  '||UPPER(V_PAIEXP));  
                        FILE_PUT_LINE (V_MANEJADOR, 'CODEXP  '||V_CODEXP);   
                        FILE_PUT_LINE (V_MANEJADOR, '');  
                    END IF;
                    
                    
                    FILE_PUT_LINE (V_MANEJADOR, 'RFCREC  '||UPPER(NVL(HED_REC.RFCEMI,HED_REC.RFCREC)));   


                    IF HED_REC.TIPO_DE_CLIENTE = 'PERSON' THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'NOMREC  '||UPPER(HED_REC.NOMRECP));  
                    ELSIF HED_REC.TIPO_DE_CLIENTE = 'ORGANIZATION' THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'NOMREC  '||UPPER(HED_REC.NOMRECO));          
                    END IF;    
                    
                    
                    FILE_PUT_LINE (V_MANEJADOR, 'USOCFDI    ' || NVL(HED_REC.USOCFDI, (CASE
                                                                                         WHEN HED_REC.RFCREC = 'GIT8406265M4' 
                                                                                         THEN 'P01'
                                                                                         WHEN HED_REC.RFCREC = 'DBM121023M10'
                                                                                         THEN 'P01'
                                                                                         WHEN V_RFCEMI = 'PAC941215E50' AND HED_REC.TIPDOC = 'I'
                                                                                         THEN 'G01'
                                                                                         WHEN HED_REC.TIPDOC = 'E'
                                                                                         THEN 'G02'
                                                                                         WHEN HED_REC.RFCREC = 'CSE941214C11' AND V_RFCEMI = 'PAC941215E50'
                                                                                         THEN 'G03'
                                                                                         WHEN HED_REC.RFCREC = 'PAC941215E50' AND V_RFCEMI = 'ROBG560202PS5' 
                                                                                         THEN 'P01'
                                                                                         WHEN HED_REC.RFCREC = 'PAC941215E50' AND V_RFCEMI = 'ROBG560202PS5'
                                                                                         THEN 'P01'
                                                                                         ELSE 'P01'
                                                                                       END)));       
                    
                    
                    IF HED_REC.TIPO_ADENDA IS NOT NULL THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'CALREC  '||REGEXP_REPLACE(UPPER(HED_REC.CALREC), '[^a-zA-Z0-9-,. ]', ''));
                        
                         
                        IF HED_REC.TIPO_ADENDA = 'SORIANA' THEN
                            FILE_PUT_LINE (V_MANEJADOR, 'NEXREC  '||REGEXP_REPLACE(REPLACE(HED_REC.NEXREC,'N/A',NULL), '[^a-zA-Z0-9-,. ]', '')||REGEXP_REPLACE(REPLACE(HED_REC.NINREC,'N/A',NULL), '[^a-zA-Z0-9-,. ]', ''));
                            FILE_PUT_LINE (V_MANEJADOR, 'NINREC  '||NULL);                    
                        ELSE
                            FILE_PUT_LINE (V_MANEJADOR, 'NEXREC  '||REGEXP_REPLACE(REPLACE(HED_REC.NEXREC,'N/A',NULL), '[^a-zA-Z0-9-,. ]', ''));
                            FILE_PUT_LINE (V_MANEJADOR, 'NINREC  '||REGEXP_REPLACE(REPLACE(HED_REC.NINREC,'N/A',NULL), '[^a-zA-Z0-9-,. ]', ''));
                        END IF;
                        
                        
                        FILE_PUT_LINE (V_MANEJADOR, 'COLREC  '||REGEXP_REPLACE(UPPER(REPLACE(HED_REC.COLREC,'N/A',NULL)), '[^a-zA-Z0-9-,?. ]', ''));
                        FILE_PUT_LINE (V_MANEJADOR, 'MUNREC  '||REGEXP_REPLACE(UPPER(HED_REC.MUNREC), '[^a-zA-Z0-9-,. ]', ''));
                        FILE_PUT_LINE (V_MANEJADOR, 'ESTREC  '||REGEXP_REPLACE(UPPER(HED_REC.ESTREC), '[^a-zA-Z0-9-,. ]', ''));        
                        FILE_PUT_LINE (V_MANEJADOR, 'PAIREC  '||REPLACE(UPPER(HED_REC.PAIREC),'?','E')); 
                    ELSE
                        FILE_PUT_LINE (V_MANEJADOR, 'CALREC  '||UPPER(HED_REC.CALREC)); 
                        FILE_PUT_LINE (V_MANEJADOR, 'NEXREC  '||REPLACE(HED_REC.NEXREC,'N/A',NULL)); 
                        FILE_PUT_LINE (V_MANEJADOR, 'NINREC  '||REPLACE(HED_REC.NINREC,'N/A',NULL)); 
                        FILE_PUT_LINE (V_MANEJADOR, 'COLREC  '||UPPER(REPLACE(HED_REC.COLREC,'N/A',NULL)));
                        FILE_PUT_LINE (V_MANEJADOR, 'MUNREC  '||UPPER(HED_REC.MUNREC));
                        FILE_PUT_LINE (V_MANEJADOR, 'ESTREC  '||UPPER(HED_REC.ESTREC));        
                        FILE_PUT_LINE (V_MANEJADOR, 'PAIREC  '||UPPER(HED_REC.PAIREC));                 
                    END IF;


                    FILE_PUT_LINE (V_MANEJADOR, 'CODREC  '||HED_REC.CODREC); 
                    
                    
                    IF HED_REC.TIPO_ADENDA = 'CHEDRAUI' THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'EANREC  '||HED_REC.EANREC2); 
                    ELSE
                        FILE_PUT_LINE (V_MANEJADOR, 'EANREC  '||HED_REC.EANREC1); 
                    END IF;
                    
                    
                    FILE_PUT_LINE (V_MANEJADOR, 'MAIL    '||HED_REC.MAIL); 
                    FILE_PUT_LINE (V_MANEJADOR, 'NUMCLI  '||HED_REC.NUMCLI); 
                    FILE_PUT_LINE (V_MANEJADOR, ''); 
                    
                    
                    IF HED_REC.NOMRECO = 'VENTAS PUBLICO EN GENERAL GALLINAZA (SCTH)' THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'NOMENT  '||NULL);
                    ELSE
                        FILE_PUT_LINE (V_MANEJADOR, 'NOMENT  '||UPPER(HED_REC.NOMENT));
                    END IF;


                    IF HED_REC.TIPO_ADENDA IS NOT NULL THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'CALENT  '||REGEXP_REPLACE(UPPER(V_CALENT), '[^a-zA-Z0-9-,. ]', '')); 
                        FILE_PUT_LINE (V_MANEJADOR, 'NEXENT  '||REGEXP_REPLACE(UPPER(REPLACE(V_NEXENT,'N/A',NULL)), '[^a-zA-Z0-9-,. ]', ''));
                        FILE_PUT_LINE (V_MANEJADOR, 'NINENT  '||REGEXP_REPLACE(UPPER(REPLACE(V_NINENT,'N/A',NULL)), '[^a-zA-Z0-9-,. ]', ''));            
                        FILE_PUT_LINE (V_MANEJADOR, 'COLENT  '||REGEXP_REPLACE(UPPER(REPLACE(V_COLENT,'N/A',NULL)), '[^a-zA-Z0-9-,. ]', ''));
                        FILE_PUT_LINE (V_MANEJADOR, 'MUNENT  '||REGEXP_REPLACE(UPPER(V_MUNENT), '[^a-zA-Z0-9-,. ]', ''));
                        FILE_PUT_LINE (V_MANEJADOR, 'ESTENT  '||REGEXP_REPLACE(UPPER(V_ESTENT), '[^a-zA-Z0-9-,. ]', ''));
                    ELSE
                        FILE_PUT_LINE (V_MANEJADOR, 'CALENT  '||UPPER(V_CALENT)); 
                        FILE_PUT_LINE (V_MANEJADOR, 'NEXENT  '||UPPER(REPLACE(V_NEXENT,'N/A',NULL)));
                        FILE_PUT_LINE (V_MANEJADOR, 'NINENT  '||UPPER(REPLACE(V_NINENT,'N/A',NULL)));            
                        FILE_PUT_LINE (V_MANEJADOR, 'COLENT  '||UPPER(REPLACE(V_COLENT,'N/A',NULL)));
                        FILE_PUT_LINE (V_MANEJADOR, 'MUNENT  '||UPPER(V_MUNENT));
                        FILE_PUT_LINE (V_MANEJADOR, 'ESTENT  '||UPPER(V_ESTENT));
                    END IF;


                    FILE_PUT_LINE (V_MANEJADOR, 'PAIENT  '||UPPER(V_PAIENT));
                    FILE_PUT_LINE (V_MANEJADOR, 'CODENT  '||V_CODENT);


                    IF HED_REC.TIPO_ADENDA = 'SORIANA' THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'EANENT  '||HED_REC.EANENT);  
                        FILE_PUT_LINE (V_MANEJADOR, 'NUMTIE  '||''); 
                    ELSIF HED_REC.TIPO_ADENDA = 'CHEDRAUI' THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'EANENT  '||LPAD(HED_REC.EANENT,13,'0')); 
                        FILE_PUT_LINE (V_MANEJADOR, 'NUMTIE  '||HED_REC.EANENT);                    
                    ELSE
                        FILE_PUT_LINE (V_MANEJADOR, 'EANENT  '||HED_REC.EANREC2);
                        FILE_PUT_LINE (V_MANEJADOR, 'NUMTIE  '||HED_REC.EANENT);
                    END IF;
                    
                    
                    FILE_PUT_LINE (V_MANEJADOR, '');  


                    FOR LIN_REC IN LINES_CUR (HED_REC.CUSTOMER_TRX_ID) LOOP
                        BEGIN
                            V_UNIDAD := NULL;   
                            BEGIN
                              
                              SELECT UNIQUE A.MFG_PART_NUM
                                INTO V_CODUPC
                                FROM MTL_MANUFACTURERS B, MTL_SYSTEM_ITEMS_B IT, MTL_MFG_PART_NUMBERS A
                               WHERE A.MANUFACTURER_ID = B.MANUFACTURER_ID
                                 AND A.INVENTORY_ITEM_ID = IT.INVENTORY_ITEM_ID
                                 AND A.ORGANIZATION_ID = IT.ORGANIZATION_ID
                                 AND B.MANUFACTURER_NAME = HED_REC.TIPO_ADENDA
                                 AND IT.INVENTORY_ITEM_ID = LIN_REC.INV_ITEM_ID;
                                                             
                            EXCEPTION WHEN OTHERS THEN
                                FND_FILE.PUT_LINE (FND_FILE.LOG,'Error al obtener el EAN a nivel l?neas de la factura. '||SQLERRM);
                            END;
                            
                            
                            IF (LIN_REC.INV_ITEM_ID = 879378) AND (HED_REC.TIPO_ADENDA = 'SORIANA') THEN
                                SELECT MEANING
                                  INTO V_CODUPC
                                  FROM FND_LOOKUP_VALUES_VL
                                 WHERE TAG = 'CAJA 180';
                            END IF; 
                            
                            
                            IF V_UNIDAD IS NULL THEN
                               V_UNIDAD := LIN_REC.UOM;
                            END IF;
                            
                            
                            IF V_UNIDAD IS NULL THEN 
                               V_UNIDAD := LIN_REC.UOM2;
                            END IF;
                            
                            
                            IF V_UNIDAD IS NULL THEN
                               V_UNIDAD := LIN_REC.UOM_LINE;
                            END IF;
                            
                            
                            IF (V_UNIDAD IS NULL) AND (HED_REC.TIPDOC IN ('I','E')) THEN
                               IF (P_ORG_ID = 85) OR (P_ORG_ID = 84 AND P_ORIGEN = 1493) OR (P_ORG_ID = 83 AND P_ORIGEN = 1356) THEN
                                    V_UNIDAD := 'SERVICIOS';
                               ELSE
                                    V_UNIDAD := 'NA';
                               END IF;
                            END IF;


                            IF V_UNIDAD = 'PZ' AND HED_REC.SERFOL NOT IN ('FETH', 'FDTH') THEN 
                                V_SEC_UOM := ' PIEZAS DE ';
                                
                                
                                IF V_UNIDAD = 'EA' AND LIN_REC.INV_ITEM_ID = 870378 THEN
                                    V_UNIDAD := 'PZ';
                                END IF;
                            ELSIF V_UNIDAD = 'KG' AND P_ORIGEN <> 1026 THEN 
                                V_SEC_UOM := ' CAJAS DE ';
                            ELSIF V_UNIDAD = 'KGM' AND P_ORIGEN = 1026 THEN 
                                V_SEC_UOM := '';                          
                            END IF;


                            IF V_UNIDAD = 'EA' AND P_ORG_ID = 85 THEN 
                                V_SEC_UOM := '';
                                V_UNIDAD := 'PZ';
                            END IF;

                            
                            V_NUMLIN := V_NUMLIN + 1; 
                                
                            
                            FILE_PUT_LINE (V_MANEJADOR, ''); 
                        
                    
                            IF HED_REC.NOMDOC LIKE 'NOTA DE CREDITO'  THEN
                            
                                V_IS_CREDIT_NOTE := 'N';
                            
                                IF HED_REC.RELTIP IS NULL THEN
                                    FILE_PUT_LINE (V_MANEJADOR, 'RELTIP     ' || '01');
                                ELSE
                                    FILE_PUT_LINE (V_MANEJADOR, 'RELTIP     ' || HED_REC.RELTIP);
                                END IF;
                                
                                V_RELNUM := 1;
                                
                                FOR REL_REC IN REL_CUR(HED_REC.CUSTOMER_TRX_ID) LOOP
                                    V_RELUUID := NULL;
                                    V_IS_CREDIT_NOTE := 'Y';
                                    
                                    V_RELUUID := REL_REC.REL_UUID;    
                                    V_RELSER  := REL_REC.REL_SER;
                                    V_RELFOL  := REL_REC.REL_FOL;
                                                      
                                    FILE_PUT_LINE (V_MANEJADOR, 'RELUUID'||TO_CHAR(V_RELNUM)||'   ' || V_RELUUID);
                                    FILE_PUT_LINE (V_MANEJADOR, 'RELSER'||TO_CHAR(V_RELNUM)||'   ' || V_RELSER);
                                    FILE_PUT_LINE (V_MANEJADOR, 'RELFOL'||TO_CHAR(V_RELNUM)||'   ' || V_RELFOL);
                                    
                                    V_RELNUM := V_RELNUM +1;
                                END LOOP;
                                
                                IF V_IS_CREDIT_NOTE = 'N' THEN
                                    RAISE CREDIT_NOTE_EXCEPTION;
                                END IF;
                            
                            END IF;
                            
                            
                            FILE_PUT_LINE (V_MANEJADOR, '');  
                            
                            
                            FILE_PUT_LINE (V_MANEJADOR, 'CANTID  '||LIN_REC.CANTID); 
                            
                            DECLARE 
                                VAR_CVEUNIDAD       VARCHAR2(10);
                            BEGIN
                            
                                SELECT DISTINCT ATTRIBUTE1
                                  INTO VAR_CVEUNIDAD
                                  FROM MTL_UNITS_OF_MEASURE UOM
                                 WHERE 1 = 1
                                   AND UPPER(UOM.UOM_CODE) = UPPER(NVL(NVL(LIN_REC.UOM, LIN_REC.UOM2), LIN_REC.UOM_LINE));
                                              
                                FILE_PUT_LINE (V_MANEJADOR, 'CVEUNIDAD    ' || VAR_CVEUNIDAD);
                                
                            EXCEPTION WHEN OTHERS THEN
                                FND_FILE.PUT_LINE (FND_FILE.LOG, 'Error - CVEUNIDAD - ' || SQLERRM);
                            
                                FILE_PUT_LINE (V_MANEJADOR, 'CVEUNIDAD    ' || LIN_REC.CVEUNIDAD);
                            END;
                            
                            DECLARE
                                VAR_CVEPRODSERV     VARCHAR2(10); 
                            BEGIN
                                 
                                SELECT DISTINCT
                                       MC.SEGMENT3
                                  INTO VAR_CVEPRODSERV
                                  FROM MTL_SYSTEM_ITEMS_B   MSI,
                                       MTL_ITEM_CATEGORIES  MIC,
                                       MTL_CATEGORIES       MC
                                 WHERE 1 = 1
                                   AND MSI.INVENTORY_ITEM_ID = LIN_REC.INV_ITEM_ID
                                   AND MIC.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                                   AND MIC.ORGANIZATION_ID = MSI.ORGANIZATION_ID
                                   AND MIC.CATEGORY_ID = MC.CATEGORY_ID
                                   AND MC.SEGMENT3 IS NOT NULL;
                            
                                FILE_PUT_LINE (V_MANEJADOR, 'CVEPRODSERV    ' || VAR_CVEPRODSERV);
                                
                            EXCEPTION WHEN OTHERS THEN
                                FILE_PUT_LINE (V_MANEJADOR, 'CVEPRODSERV    ' || LIN_REC.CVEPRODSERV);
                            
                                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error - CVEPRODSERV - ' || SQLERRM);
                            END;
                            
                            IF HED_REC.SERFOL = 'FCTH' THEN
                                FILE_PUT_LINE (V_MANEJADOR, 'DESCRI  '||LIN_REC.DESCRI||' Ton. '||LIN_REC.CANTIDAD_SECUNDARIA);
                                FILE_PUT_LINE (V_MANEJADOR, 'DESCR2  '||LIN_REC.DESCRI||' Ton. '||LIN_REC.CANTIDAD_SECUNDARIA);
                            ELSE        
                                IF HED_REC.CUST_TRX_TYPE_ID = 1030 THEN
                                    FILE_PUT_LINE (V_MANEJADOR, 'DESCRI  '||LIN_REC.DESCRI); 
                                    FILE_PUT_LINE (V_MANEJADOR, 'DESCR2  '||LIN_REC.DESCRI);                                 
                                ELSE
                                    IF HED_REC.ADUANA IS NOT NULL THEN
                                        FILE_PUT_LINE (V_MANEJADOR, 'DESCRI  '||LIN_REC.CANTIDAD_SECUNDARIA||V_SEC_UOM||LIN_REC.DESCRI); 
                                        FILE_PUT_LINE (V_MANEJADOR, 'DESCR2  '||LIN_REC.CANTIDAD_SECUNDARIA||V_SEC_UOM||LIN_REC.DESCRI
                                                                              ||' - Num. Pedimento: '||HED_REC.NUM_PED
                                                                              ||', Aduana: '||HED_REC.ADUANA
                                                                              ||', Fecha: '||HED_REC.FECH_PED||'.');  
                                    ELSE 
                                        IF P_ORG_ID IN (83,84,85) THEN
                                            FILE_PUT_LINE (V_MANEJADOR, 'DESCRI  '||LIN_REC.CANTIDAD_SECUNDARIA||V_SEC_UOM||LIN_REC.DESCRI); 
                                        ELSE
                                            FILE_PUT_LINE (V_MANEJADOR, 'DESCRI  '||LIN_REC.CANTIDAD_SECUNDARIA||V_SEC_UOM||LIN_REC.DESCRI); 
                                            FILE_PUT_LINE (V_MANEJADOR, 'DESCR2  '||LIN_REC.CANTIDAD_SECUNDARIA||V_SEC_UOM||LIN_REC.DESCRI);  
                                        END IF;
                                    END IF;
                                END IF;
                            END IF;
                            
                            FILE_PUT_LINE (V_MANEJADOR, 'CANEMP  '||LIN_REC.CANTID);   
                            FILE_PUT_LINE (V_MANEJADOR, 'CVESKU  '||NULL);
                       
                            
                            IF HED_REC.TIPO_ADENDA = 'CHEDRAUI' AND V_CODUPC IS NULL THEN
                                FILE_PUT_LINE (V_MANEJADOR, 'CODUPC  '||LPAD(9,13,'9'));
                            ELSE
                                FILE_PUT_LINE (V_MANEJADOR, 'CODUPC  '||LPAD(V_CODUPC,13,'0'));
                            END IF;
                            
                            
                            FILE_PUT_LINE (V_MANEJADOR, 'UNIDAD  '||V_UNIDAD);  
                            
                            
                            IF HED_REC.TIPO_ADENDA = 'CHEDRAUI' AND LIN_REC.INV_ITEM_ID = 2838603 THEN
                                FILE_PUT_LINE (V_MANEJADOR, 'PIEPEM  '||TO_CHAR(12));
                            ELSE
                                FILE_PUT_LINE (V_MANEJADOR, 'PIEPEM  '||TO_CHAR(1)); 
                            END IF;
                            
                            
                            FILE_PUT_LINE (V_MANEJADOR, 'CODDUN  '||LPAD(V_CODUPC,13,'0'));
                            FILE_PUT_LINE (V_MANEJADOR, 'PBRUDE  '||(CASE
                                                                        WHEN LIN_REC.PBRUDE = 0
                                                                        THEN 1
                                                                        ELSE LIN_REC.PBRUDE
                                                                       END));  
                            FILE_PUT_LINE (V_MANEJADOR, 'IMPBRU  '||LIN_REC.IMPBRU);
                            FILE_PUT_LINE (V_MANEJADOR, 'TDECON  '||'0'); 
                            FILE_PUT_LINE (V_MANEJADOR, 'MDECON  '||'0');
                            
                            
                            IF HED_REC.TIPO_ADENDA <> 'OXXO' THEN
                                FILE_PUT_LINE (V_MANEJADOR, 'CDECON  '||'0');
                            END IF;
                            
                            
                            FILE_PUT_LINE (V_MANEJADOR, 'VALUNI  '||(CASE
                                                                        WHEN LIN_REC.PBRUDE = 0
                                                                        THEN 1
                                                                        ELSE LIN_REC.PBRUDE
                                                                       END));
                            FILE_PUT_LINE (V_MANEJADOR, 'IMPORT  '||LIN_REC.IMPBRU);
                            
                            
                            IF V_RFCEMI = 'ATE920811K53' AND LIN_REC.TASIPE = 4 THEN
                                FILE_PUT_LINE (V_MANEJADOR, 'TASIPE  '||TO_CHAR(NVL(TO_CHAR(16),0),'99D9999'));
                                FILE_PUT_LINE (V_MANEJADOR, 'FCTTASIPE  ' || TO_CHAR(TO_CHAR(16) / 100, '0D999999'));
                            ELSE
                                FILE_PUT_LINE (V_MANEJADOR, 'TASIPE  '||TO_CHAR(NVL(TO_CHAR(LIN_REC.TASIPE),0),'99D9999'));
                                FILE_PUT_LINE (V_MANEJADOR, 'FCTTASIPE  ' || TO_CHAR(TO_CHAR(LIN_REC.TASIPE) / 100, '0D999999')); 
                            END IF;
                            
                            
                            FILE_PUT_LINE (V_MANEJADOR, 'MONIPE  '||NVL(TO_CHAR(LIN_REC.MONIPE),0)); 
                            FILE_PUT_LINE (V_MANEJADOR, 'NUMLIN  '||V_NUMLIN);
                                
                            
                            IF V_RFCEMI = 'ATE920811K53' AND LIN_REC.TASIPE = 4 THEN
                                FILE_PUT_LINE (V_MANEJADOR, 'IMPORTIPE  ' || TO_CHAR(LIN_REC.PBRUDE*0.25));
                            END IF;
                            
                            
                            IF V_RFCEMI = 'ROBG560202PS5' AND LIN_REC.TASIPE = 16 THEN
                                FILE_PUT_LINE (V_MANEJADOR, 'IMPORTIPE  ' || TO_CHAR(LIN_REC.PBRUDE));
                            END IF;
                            
                            
                            IF V_RFCEMI = 'ROBG560202PS5' AND LIN_REC.TASA_IVA_RET > 0 THEN
                                FILE_PUT_LINE (V_MANEJADOR, 'TIPIVARE    ' || 'Tasa');
                                FILE_PUT_LINE (V_MANEJADOR, 'IVARET_P    ' || TO_CHAR(TRUNC(LIN_REC.TASA_IVA_RET,4), '99D9999'));
                                FILE_PUT_LINE (V_MANEJADOR, 'FCTIVARET_P    ' || TO_CHAR(TRUNC(LIN_REC.TASA_IVA_RET/100, 6), '0D999999'));
                                FILE_PUT_LINE (V_MANEJADOR, 'IVARET_D    ' || LIN_REC.TTL_IVA_RET);
                            END IF;
                            
                            
                            IF V_RFCEMI = 'ROBG560202PS5' AND LIN_REC.TASA_ISR_RET > 0 THEN
                                FILE_PUT_LINE (V_MANEJADOR, 'TIPISRRE   ' || 'Tasa');
                                FILE_PUT_LINE (V_MANEJADOR, 'ISRRET_P    ' || TO_CHAR(TRUNC(LIN_REC.TASA_ISR_RET,4), '99D9999'));
                                FILE_PUT_LINE (V_MANEJADOR, 'FCTISRRET_P    ' || TO_CHAR(TRUNC(LIN_REC.TASA_ISR_RET/100, 6), '0D999999')); 
                                FILE_PUT_LINE (V_MANEJADOR, 'ISRRET_D    ' || LIN_REC.TTL_ISR_RET);
                            END IF;
                                
                                
                            FILE_PUT_LINE (V_MANEJADOR, 'PESUNO  '||TO_CHAR(LIN_REC.CANTID + LIN_REC.TARA));
                            FILE_PUT_LINE (V_MANEJADOR, 'PESDOS  '||LIN_REC.CANTID); 
                            FILE_PUT_LINE (V_MANEJADOR, 'PETARA  '||TO_CHAR(LIN_REC.TARA)); 
                            FILE_PUT_LINE (V_MANEJADOR, '');
                            

                        EXCEPTION
                            WHEN CREDIT_NOTE_EXCEPTION THEN
                                FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR en aplicación de las notas de crédito.');
                                UTL_FILE.FREMOVE(V_DIRECTORIO, V_ARCHIVO);
                            WHEN OTHERS THEN
                                FND_FILE.PUT_LINE (FND_FILE.LOG,'ERROR inesperado en las l?neas de la factura. '||SQLERRM);
                        END;
                        
                                  
                            V_TOTIVA := V_TOTIVA + LIN_REC.TASIPE; 
                            V_IVATRA := V_IVATRA + LIN_REC.MONIPE;    
                            V_ISRRET := V_ISRRET + ABS(LIN_REC.TTL_ISR_RET);
                            V_IVARET := V_IVARET + ABS(LIN_REC.TTL_IVA_RET);
                            V_SUBTBR := V_SUBTBR + LIN_REC.IMPBRU;
                            V_TOTCAN := V_TOTCAN +  LIN_REC.CANTID; 
                        
                    
                    END LOOP;

                    V_TOTIVA := V_TOTIVA/V_NUMLIN;

                    
                    FILE_PUT_LINE (V_MANEJADOR, 'TOTLPF  '||V_NUMLIN); 
                    

                    IF HED_REC.TIPO_ADENDA = 'SORIANA' THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'TOTCAN  '||V_TOTCAN);
                    END IF;
                    

                    FILE_PUT_LINE (V_MANEJADOR, 'SUBTBR  '|| ROUND_TOT(V_SUBTBR)); 
                    FILE_PUT_LINE (V_MANEJADOR, 'CODDES  '||'0'); 
                    FILE_PUT_LINE (V_MANEJADOR, 'MONDET  '||'0'); 
                    FILE_PUT_LINE (V_MANEJADOR, 'PRCDSG  '||'0'); 
                    

                    IF HED_REC.TIPO_ADENDA = 'CHEDRAUI' THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'SUBTAI  '||ROUND_TOT(V_SUBTBR)); 
                    ELSE  

                        IF V_TOTIVA = 16 THEN
                            FILE_PUT_LINE (V_MANEJADOR, 'SUBTSI  '||TO_CHAR(0));  
                            FILE_PUT_LINE (V_MANEJADOR, 'SUBTAI  '||ROUND_TOT(V_SUBTBR)); 
                        ELSIF V_TOTIVA = 0 THEN
                            FILE_PUT_LINE (V_MANEJADOR, 'SUBTSI  '||ROUND_TOT(V_SUBTBR)); 
                            FILE_PUT_LINE (V_MANEJADOR, 'SUBTAI  '||TO_CHAR(0)); 
                        END IF;
                    
                    END IF;    
                    

                    FILE_PUT_LINE (V_MANEJADOR, 'SUBTOT  '||ROUND_TOT(V_SUBTBR)); 
                    

                    IF (V_TOTIVA = 0) OR (V_TOTIVA = 16) THEN 
                        FILE_PUT_LINE (V_MANEJADOR, 'TOTIVA  '||TO_CHAR(V_TOTIVA));
                    ELSIF V_TOTIVA = 4 AND V_RFCEMI = 'ATE920811K53' THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'TOTIVA  '||TO_CHAR(16));
                    ELSE
                        FILE_PUT_LINE (V_MANEJADOR, 'TOTIVA  '||TO_CHAR(0));  
                    END IF;
                    FND_FILE.PUT_LINE(FND_FILE.LOG, '*TOTIVA    ' ||TO_CHAR(V_TOTIVA)); 
                    FND_FILE.PUT_LINE(FND_FILE.LOG, '*RFCEMI    ' ||V_RFCEMI);   
                    
                    FILE_PUT_LINE (V_MANEJADOR, 'IVATRA  '||TO_CHAR(ROUND(NVL(V_IVATRA,0),2)));
                    FILE_PUT_LINE (V_MANEJADOR, 'IVARET  '||ROUND(ABS(NVL(V_IVARET,0)),2)); 
                    FILE_PUT_LINE (V_MANEJADOR, 'ISRRET  '||ROUND(ABS(NVL(V_ISRRET,0)),2)); 
                                        FILE_PUT_LINE (V_MANEJADOR, 'NOTAS3 '||REPLACE (UPPER(IBY_AMOUNT_IN_WORDS.GET_AMOUNT_IN_WORDS(ROUND_TOT((V_TOTPAG - ABS(NVL(V_IVARET,0)) - ABS(NVL(V_ISRRET,0)))),'MXN')), 'MXN', HED_REC.TIPMON));
                    FILE_PUT_LINE (V_MANEJADOR, 'TOTPAG  '||ROUND_TOT((V_TOTPAG - ABS(NVL(V_IVARET,0)) - ABS(NVL(V_ISRRET,0)))));
                    FILE_PUT_LINE (V_MANEJADOR, 'TOTPAG_ORI  '||TRUNC(V_TOTPAG - ABS(NVL(V_IVARET,0)) - ABS(NVL(V_ISRRET,0)),6));
                    
                    
                    IF V_RFCEMI = 'ROBG560202PS5' AND ( V_IVATRA > 0 OR V_IVARET > 0 OR V_ISRRET > 0 ) THEN
                        FILE_PUT_LINE (V_MANEJADOR, 'TOTTRA     ' || TO_CHAR(ROUND(NVL(V_IVATRA,0),2)));
                        FILE_PUT_LINE (V_MANEJADOR, 'TOTRET     ' || TO_CHAR(ROUND(NVL(V_IVARET + V_ISRRET, 0),2))); 
                    END IF;
                    
                    
                    FILE_PUT_LINE (V_MANEJADOR, '');
                    UTL_FILE.FCLOSE (V_MANEJADOR);

                ELSE
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Las lineas de la factura NO coinciden con las l?neas del pedido, por favor val?delas y vuelva A correr el proceso de facturaci?n electr?nica para poder continuar.');
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Importe total de la factura: '||V_TOTPAG);
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Importe total del pedido: '||V_IMP_TOTAL_PED);
                END IF;
                
           EXCEPTION WHEN OTHERS THEN
                FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR inesperado en cabecera de factura: '||SQLERRM);
           END;

       END IF;
       
       
       IF P_TIMBRAR = 'YES' THEN
            IF V_HEADERS_COUNT = 1 THEN 
                V_REPORT := 'YES';
            ELSIF V_HEADERS_COUNT > 1 THEN 
                V_REPORT := 'NO';
            END IF;                          
       
       
             V_REQUEST_ID := APPS.FND_REQUEST.SUBMIT_REQUEST( APPLICATION =>'AR',
                                                              PROGRAM     =>'PAC_INVOICE_SIGNED',
                                                              DESCRIPTION => NULL,
                                                              START_TIME  => NULL,
                                                              SUB_REQUEST => FALSE,
                                                            ARGUMENT1 => V_RFCEMI,
                                                            ARGUMENT2 => UPPER(NVL(HED_REC.RFCEMI,HED_REC.RFCREC)),
                                                            ARGUMENT3 => HED_REC.SERFOL,
                                                            ARGUMENT4 => HED_REC.NUMFOL,
                                                            ARGUMENT5 => HED_REC.CUSTOMER_TRX_ID,
                                                            ARGUMENT6 => V_REPORT                                                                            
                                                          );
       END IF;
       
   END LOOP;
       
--       FND_FILE.PUT_LINE(FND_FILE.LOG, '');
--       FND_FILE.PUT_LINE(FND_FILE.LOG, P_TIMBRAR);
--   
--       BEGIN
--            IF P_TIMBRAR = 'YES' THEN
--               V_REQUEST_ID := APPS.FND_REQUEST.SUBMIT_REQUEST( APPLICATION =>'AR',
--                                                                PROGRAM     =>'MUEVE_CFD',
--                                                                DESCRIPTION => NULL,
--                                                                START_TIME  => NULL,
--                                                                SUB_REQUEST => FALSE
--                                                              );
--               COMMIT;
--               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Request_id: '||V_REQUEST_ID);
--               WAITING := FND_CONCURRENT.WAIT_FOR_REQUEST
--                                        (V_REQUEST_ID,1,0,
--                                         PHASE,
--                                         STATUS,
--                                         DEV_PHASE,
--                                         DEV_STATUS,
--                                         MESSAGE
--                                        );
--            END IF;                                        
--       EXCEPTION WHEN OTHERS THEN
--           FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR lanzando concurrente. '||SQLERRM);
--       END;


EXCEPTION 
    WHEN NO_INVOICE_FOUND THEN
        RETCODE:= 1;
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'NO EXISTEN RESULTADOS QUE CORRESPONDAN A LOS PARAMETROS');
    WHEN OTHERS THEN
        RETCODE:= 1;
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'ERROR inesperado al generar factura. '||SQLERRM);
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Archivo generado: '||V_DIRECTORIO||'/'||V_ARCHIVO);
END;