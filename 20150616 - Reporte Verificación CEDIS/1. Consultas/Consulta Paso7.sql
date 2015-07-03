SELECT FUV1.USER_NAME                                       CREATED_BY,
       TO_CHAR(CREATION_DATE, 'DD-MON-YYYY HH24:MI:SS')     CREATION_DATE,
       FUV2.USER_NAME                                       LAST_UPDATED_BY,
       TO_CHAR(LAST_UPDATE_DATE, 'DD-MON-YYYY HH24:MI:SS')  LAST_UPDATE_DATE,
       GROUPBY,
       REPLACE(COLUMN_DESC, '_', ' ')                       COLUMN_DESC,
       COLUMN_VAL,  
       PAC_VERIFY_CEDIS_PKG.VERIFY_STEP7(COLUMN_DESC, COLUMN_VAL, :P_ORG_INVENTORY_ID)  VALIDATION
  FROM (SELECT MSI.INVENTORY_ITEM_ID,
               MSI.SEGMENT1                          AS  GROUPBY,
               TO_CHAR(DETAIL.ORGANIZATION_CODE)     AS  "Organization_Code",
               TO_CHAR(DETAIL.SEGMENT1)              AS  "Item_Assign",
               TO_CHAR(DETAIL.DESCRIPTION)           AS  "Description",
               TO_CHAR(DETAIL.ASSIGNED_FLAG)         AS  "Assigned",
               TO_CHAR(DETAIL.CATEGORY_SET_NAME)     AS  "Category_Set",
               TO_CHAR(DETAIL.CONTROL_LEVEL_DISP)    AS  "Control_Level",
               TO_CHAR(DETAIL.CATEGORY_CONCAT_SEGS)  AS  "Category",
               DETAIL.CREATED_BY,
               DETAIL.CREATION_DATE,
               DETAIL.LAST_UPDATED_BY,
               DETAIL.LAST_UPDATE_DATE
          FROM MTL_SYSTEM_ITEMS_B       MSI
          LEFT JOIN (SELECT MSI1.INVENTORY_ITEM_ID,
                            MP.ORGANIZATION_CODE,
                            MSI1.SEGMENT1,
                            MSI1.DESCRIPTION,
                            MOA.ASSIGNED_FLAG,
                            MIC1.CATEGORY_SET_NAME,
                            MIC1.CONTROL_LEVEL_DISP,
                            MIC1.CATEGORY_CONCAT_SEGS,
                            MSI1.CREATED_BY,
                            MSI1.CREATION_DATE,
                            MSI1.LAST_UPDATED_BY,
                            MSI1.LAST_UPDATE_DATE
                       FROM MTL_SYSTEM_ITEMS_B      MSI1,
                            MTL_PARAMETERS          MP,
                            MTL_ORG_ASSIGN_V        MOA,
                            MTL_ITEM_CATEGORIES_V   MIC1
                      WHERE 1 = 1 
                        AND MSI1.ORGANIZATION_ID = :P_ORG_INVENTORY_ID
                        AND MP.ORGANIZATION_ID = MSI1.ORGANIZATION_ID
                        AND MOA.ORGANIZATION_ID = MSI1.ORGANIZATION_ID
                        AND MSI1.INVENTORY_ITEM_ID = MOA.INVENTORY_ITEM_ID
                        AND MIC1.ORGANIZATION_ID = MSI1.ORGANIZATION_ID
                        AND MIC1.INVENTORY_ITEM_ID = MSI1.INVENTORY_ITEM_ID
                        AND MIC1.CATEGORY_SET_NAME = 'COSTOS'
                     ) DETAIL    ON MSI.INVENTORY_ITEM_ID = DETAIL.INVENTORY_ITEM_ID    
         WHERE 1 = 1 
           AND MSI.ORGANIZATION_ID = 101
           AND MSI.SEGMENT1 IN ('HVOBCO0070',
                                'HVOBCO0200',
                                'HVOBCO0201',
                                'HVOBCO0202',
                                'HVOBCO0203',
                                'HVOBCO0204',
                                'HVOBCO0205',
                                'HVOBCO0206',
                                'HVOCON0001',
                                'HVOCON0002',
                                'HVOCON0003',
                                'HVOCON0007',
                                'HVORES0001')
        ) DETAIL
 UNPIVOT (COLUMN_VAL FOR COLUMN_DESC IN( "Organization_Code",
                                         "Item_Assign",
                                         "Description",
                                         "Assigned",
                                         "Category_Set",
                                         "Control_Level",
                                         "Category")),
       FND_USER_VIEW  FUV1,
       FND_USER_VIEW  FUV2    
 WHERE 1 = 1
   AND FUV1.USER_ID = CREATED_BY
   AND FUV2.USER_ID = LAST_UPDATED_BY     