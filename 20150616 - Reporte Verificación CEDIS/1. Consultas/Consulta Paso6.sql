SELECT FUV1.USER_NAME                                       CREATED_BY,
       TO_CHAR(CREATION_DATE, 'DD-MON-YYYY HH24:MI:SS')     CREATION_DATE,
       FUV2.USER_NAME                                       LAST_UPDATED_BY,
       TO_CHAR(LAST_UPDATE_DATE, 'DD-MON-YYYY HH24:MI:SS')  LAST_UPDATE_DATE,
       GROUPBY,
       REPLACE(COLUMN_DESC, '_', ' ')                       COLUMN_DESC,
       COLUMN_VAL,  
       PAC_VERIFY_CEDIS_PKG.VERIFY_STEP6(COLUMN_DESC, COLUMN_VAL)  VALIDATION
  FROM (SELECT TO_CHAR(MSI.SECONDARY_INVENTORY_NAME)     AS  "Name",
               TO_CHAR(MSI.DESCRIPTION)                  AS  "Description",
               TO_CHAR(MMS.STATUS_CODE)                  AS  "Status",
               TO_CHAR(
                       (CASE WHEN MSI.DEFAULT_COUNT_TYPE_CODE = 2 THEN
                                'Order Quantity'
                             ELSE
                                'Order Maximum'
                        END))      AS  "Replenishment_Count_Type",
               MSI.SECONDARY_INVENTORY_NAME              AS  GROUPBY,
               MSI.CREATED_BY,
               MSI.CREATION_DATE,
               MSI.LAST_UPDATED_BY,
               MSI.LAST_UPDATE_DATE
          FROM MTL_SECONDARY_INVENTORIES    MSI,
               MTL_MATERIAL_STATUSES_TL     MMS
         WHERE 1 = 1
           AND MSI.ORGANIZATION_ID = :P_ORG_INVENTORY_ID
           AND MSI.STATUS_ID = MMS.STATUS_ID 
           AND MMS.LANGUAGE = USERENV('LANG')
        ) DETAIL
 UNPIVOT (COLUMN_VAL FOR COLUMN_DESC IN( "Name",
                                         "Description",
                                         "Status",
                                         "Replenishment_Count_Type")),
       FND_USER_VIEW  FUV1,
       FND_USER_VIEW  FUV2    
 WHERE 1 = 1
   AND FUV1.USER_ID = CREATED_BY
   AND FUV2.USER_ID = LAST_UPDATED_BY     