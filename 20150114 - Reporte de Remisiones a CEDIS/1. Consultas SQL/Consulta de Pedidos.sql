SELECT DTL.GROUP_REPORT,
       DTL.GROUP_ORDER,
       DTL.ORDERED_DATE,
       DTL.ORDER_NUMBER,
       DTL.CUSTOMER_NAME,
       DTL.ORDERED_ITEM,
       DTL.ITEM_DESCRIPTION,
       ROUND(SUM(DTL.ORDER_QUANTITY), 2)  AS  ORDER_QUANTITY,  
       ROUND(SUM(DTL.TO_BOXES), 2)  AS  TO_BOXES,
       ROUND(SUM(DTL.TO_BOXES_360), 2)  AS  TO_BOXES_360,
       ROUND(SUM(DTL.TO_WEIGHT), 2)  AS  TO_WEIGHT,
       DTL.UNIT_SELLING_PRICE,
       ROUND(SUM(DTL.TOTAL), 2)  AS  TOTAL,
       DTL.ORGANIZATION_ID
  FROM (SELECT 1                                            AS  "GROUP_REPORT",
               OOHA.ORDER_NUMBER                            AS  "GROUP_ORDER",
               TO_CHAR(OOHA.ORDERED_DATE, 'DD-MON-YYYY')    AS  "ORDERED_DATE",
               OOHA.ORDER_NUMBER                            AS  "ORDER_NUMBER",
               HP.PARTY_NAME                                AS  "CUSTOMER_NAME",
               OOLA.ORDERED_ITEM                            AS  "ORDERED_ITEM",
               (SELECT MSIB.DESCRIPTION
                  FROM MTL_SYSTEM_ITEMS_B MSIB
                 WHERE MSIB.INVENTORY_ITEM_ID = OOLA.INVENTORY_ITEM_ID
                   AND ROWNUM = 1) || ' ' || 
               OOLA.PREFERRED_GRADE                         AS  "ITEM_DESCRIPTION",
               OOLA.ORDERED_QUANTITY                        AS  "ORDER_QUANTITY",
               APPS.XXCALV_VENTAS_FNC_PUB ('A_CAJAS',
                                           P_SEGMENT1   => OOLA.ORDERED_ITEM,
                                           P_TRX_QTY    => OOLA.ORDERED_QUANTITY,
                                           P_TRX_QTY2   => OOLA.ORDERED_QUANTITY2,
                                           P_GRADE_CODE => OOLA.PREFERRED_GRADE,
                                           P_ITEM_ID    => OOLA.INVENTORY_ITEM_ID)      AS  "TO_BOXES",
               APPS.XXCALV_VENTAS_FNC_PUB ('A_CAJAS_360',
                                           P_SEGMENT1   => OOLA.ORDERED_ITEM, 
                                           P_TRX_QTY    => OOLA.ORDERED_QUANTITY,
                                           P_TRX_QTY2   => OOLA.ORDERED_QUANTITY2,
                                           P_GRADE_CODE => OOLA.PREFERRED_GRADE,
                                           P_ITEM_ID    => OOLA.INVENTORY_ITEM_ID)      AS  "TO_BOXES_360",
               (CASE WHEN (OOLA.ORDER_QUANTITY_UOM = 'KG') THEN
                        APPS.XXCALV_VENTAS_FNC_PUB ('PIEZAS_A_KILOS',
                                                    P_SEGMENT1   => OOLA.ORDERED_ITEM,
                                                    P_TRX_QTY    => OOLA.ORDERED_QUANTITY,
                                                    P_ITEM_ID    => OOLA.INVENTORY_ITEM_ID)
                    ELSE
                        NULL
                END)                                                                    AS  "TO_WEIGHT",
               OOLA.UNIT_SELLING_PRICE                                                  AS  "UNIT_SELLING_PRICE",
               (OOLA.ORDERED_QUANTITY * OOLA.UNIT_SELLING_PRICE)                        AS  "TOTAL",
               PLAA.ORGANIZATION_ID                                                     AS  "ORGANIZATION_ID"
          FROM OE_ORDER_HEADERS_ALL         OOHA,
               HZ_CUST_ACCOUNTS             HCA,
               HZ_PARTIES                   HP,
               OE_TRANSACTION_TYPES_TL      OTTT,
               OE_ORDER_LINES_ALL           OOLA,
               APPS.PO_LOCATION_ASSOCIATIONS_ALL PLAA
         WHERE 1 = 1
           AND OOHA.ORG_ID = 82
           AND PLAA.ORG_ID = 82
           AND OTTT.LANGUAGE = USERENV('LANG')
           AND OOHA.ORDER_TYPE_ID = OTTT.TRANSACTION_TYPE_ID
           AND OTTT.NAME = 'PEDIDO_CEDIS_INTERNO'
           AND OOHA.SOLD_TO_ORG_ID = HCA.CUST_ACCOUNT_ID
           AND HCA.PARTY_ID = HP.PARTY_ID
           AND OOHA.HEADER_ID = OOLA.HEADER_ID
           AND OOLA.SOLD_TO_ORG_ID = PLAA.CUSTOMER_ID
           AND OOHA.ORDERED_DATE BETWEEN :CP_START_DATE AND :CP_END_DATE +1
           AND PLAA.ORGANIZATION_ID = DECODE(:P_ORGANIZATION_ID,
                                             82, PLAA.ORGANIZATION_ID,
                                             XXCALV_VENTAS_FNC_PUB('INV_ORG_ID',
                                                                   p_org_id => :P_ORGANIZATION_ID)) 
           )  DTL 
 GROUP BY DTL.GROUP_REPORT,
          DTL.GROUP_ORDER,
          DTL.ORDERED_DATE,
          DTL.ORDER_NUMBER,
          DTL.CUSTOMER_NAME,
          DTL.ORDERED_ITEM,
          DTL.ITEM_DESCRIPTION,
          DTL.UNIT_SELLING_PRICE,
          DTL.ORGANIZATION_ID
 ORDER BY TO_DATE(DTL.ORDERED_DATE),
          DTL.ORDER_NUMBER,
          DTL.ORDERED_ITEM;
                  
       