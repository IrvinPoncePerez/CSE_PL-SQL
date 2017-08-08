SELECT DISTINCT
       ASS.ASSET_NUMBER                 AS  "Asset Number",
       ASS.OWNED_LEASED                 AS  "Owned/Leased",
       ASS.NEW_USED                     AS  "New/Used",
       ASS.ATTRIBUTE_CATEGORY_CODE      AS  "Category Code",
       ASS.DESCRIPTION                  AS  "Description",
       ASS.BOOK_TYPE_CODE               AS  "Book Code",
       ASS.SEGMENT1                     AS  "Location",
       ASS.SEGMENT2                     AS  "Sub Location",
       ASS.COMPANY_CODE                 AS  "Company Code", 
       ASS.COMPANY_DESC                 AS  "Company Description", 
       ASS.CC_CODE                      AS  "CC Code", 
       ASS.CC_DESC                      AS  "CC Description",
       ASS.DATE_PLACED_IN_SERVICE       AS  "Date Placed in Service",        
       ASS.ORIGINAL_COST                AS  "Original Cost",
       ASS.TRANSACTION_DATE_ENTERED     AS  "Transaction Date",
       ASS.TRANSACTION_TYPE_CODE        AS  "Transaction Code",
       ASS.COST                         AS  "Transaction Cost", 
       ASS.UNITS_ASSIGNED               AS  "Addition Units Assigned",
       FAI.INVOICE_NUMBER               AS  "Addition Invoice Number",
       FAI.INVOICE_LINE_NUMBER          AS  "Addition Invoice Line Number",
       FAI.DESCRIPTION                  AS  "Addition Invoice Description",
       PV.VENDOR_NAME                   AS  "Addition Vendor Name",    
       FR.DATE_RETIRED                  AS  "Retired Date",
       FR.COST_RETIRED                  AS  "Retired Cost",
       FR.UNITS                         AS  "Retired Units",
       FR.REFERENCE_NUM                 AS  "Retired Reference Number",
       FR.SOLD_TO                       AS  "Retired Sold To"
  FROM (SELECT 
               FA.ASSET_ID,
               FA.ASSET_NUMBER,
               FA.OWNED_LEASED,
               FA.NEW_USED,
               FA.ATTRIBUTE_CATEGORY_CODE,
               FAT.DESCRIPTION,
               FDH.BOOK_TYPE_CODE,
               FDH.UNITS_ASSIGNED,
               GCC.SEGMENT1                 AS  COMPANY_CODE, 
               FFVT_CIA.DESCRIPTION         AS  COMPANY_DESC, 
               GCC.SEGMENT2                 AS  CC_CODE, 
               FFVT_CC.DESCRIPTION          AS  CC_DESC, 
               FB.DATE_PLACED_IN_SERVICE, 
               FB.ORIGINAL_COST,
               FB.COST, 
               FL.SEGMENT1,
               FL.SEGMENT2,
               FDH.RETIREMENT_ID,
               FB.TRANSACTION_HEADER_ID_IN,
               FB.TRANSACTION_HEADER_ID_OUT,
               FTH.TRANSACTION_TYPE_CODE,
               FTH.TRANSACTION_DATE_ENTERED
          FROM FA_ADDITIONS_B           FA,
               FA_ADDITIONS_TL          FAT,
               FA_DISTRIBUTION_HISTORY  FDH,
               FA_LOCATIONS             FL,
               GL_CODE_COMBINATIONS     GCC,
               FND_FLEX_VALUE_SETS      FFVS_CC,
               FND_FLEX_VALUES          FFV_CC,
               FND_FLEX_VALUES_TL       FFVT_CC,
               FND_FLEX_VALUE_SETS      FFVS_CIA,
               FND_FLEX_VALUES          FFV_CIA,
               FND_FLEX_VALUES_TL       FFVT_CIA,
               FA_BOOKS                 FB,
               FA_TRANSACTION_HEADERS   FTH
         WHERE 1 = 1
           AND FA.ASSET_ID = FAT.ASSET_ID
           AND FAT.LANGUAGE = USERENV('LANG')
           AND FA.ASSET_ID = FDH.ASSET_ID
           AND FDH.LOCATION_ID = FL.LOCATION_ID
           AND FDH.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND FFVS_CC.FLEX_VALUE_SET_NAME = 'CC_ CALVARIO'
           AND FFV_CC.FLEX_VALUE_SET_ID = FFVS_CC.FLEX_VALUE_SET_ID
           AND FFV_CC.FLEX_VALUE_ID = FFVT_CC.FLEX_VALUE_ID
           AND FFVT_CC.LANGUAGE = USERENV ('LANG')
           AND FFV_CC.ENABLED_FLAG = 'Y'
           AND FFV_CC.FLEX_VALUE = GCC.SEGMENT2
           AND FFVS_CIA.FLEX_VALUE_SET_NAME = 'CIA_CALVARIO'
           AND FFV_CIA.FLEX_VALUE_SET_ID = FFVS_CIA.FLEX_VALUE_SET_ID
           AND FFV_CIA.FLEX_VALUE_ID = FFVT_CIA.FLEX_VALUE_ID
           AND FFVT_CIA.LANGUAGE = USERENV ('LANG')
           AND FFV_CIA.ENABLED_FLAG = 'Y'
           AND FFV_CIA.FLEX_VALUE = GCC.SEGMENT1
           AND FB.BOOK_TYPE_CODE = FDH.BOOK_TYPE_CODE
           AND FB.ASSET_ID = FA.ASSET_ID
           AND FTH.ASSET_ID = FA.ASSET_ID
           AND FTH.TRANSACTION_HEADER_ID = FB.TRANSACTION_HEADER_ID_IN
           AND FDH.DATE_INEFFECTIVE IS NULL
           AND FDH.TRANSACTION_HEADER_ID_OUT IS NULL
           AND FTH.TRANSACTION_TYPE_CODE IN ('ADDITION', 'FULL RETIREMENT')
       ) ASS
  LEFT JOIN FA_RETIREMENTS          FR
    ON (    FR.RETIREMENT_ID = ASS.RETIREMENT_ID AND FR.ASSET_ID = ASS.ASSET_ID
        AND ASS.TRANSACTION_TYPE_CODE LIKE 'FULL RETIREMENT')
  LEFT JOIN FA_TRANSACTION_HEADERS  FTH
    ON (FTH.TRANSACTION_HEADER_ID = ASS.TRANSACTION_HEADER_ID_IN)
  LEFT JOIN FA_ASSET_INVOICES       FAI
    ON (    FAI.ASSET_ID = ASS.ASSET_ID
        AND ASS.TRANSACTION_TYPE_CODE LIKE 'ADDITION')
  LEFT JOIN PO_VENDORS              PV
    ON (    FAI.PO_VENDOR_ID = PV.VENDOR_ID
        AND ASS.TRANSACTION_TYPE_CODE LIKE 'ADDITION')
 WHERE 1 = 1
 ORDER
    BY ASS.COMPANY_CODE,
       ASS.CC_CODE,
       ASS.ATTRIBUTE_CATEGORY_CODE,
       ASS.ASSET_NUMBER,
       ASS.TRANSACTION_DATE_ENTERED;
       