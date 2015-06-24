SELECT CREATED_BY,
       TO_CHAR(CREATION_DATE, 'DD-MON-YYYY HH24:MI:SS')     CREATION_DATE,
       LAST_UPDATED_BY,
       TO_CHAR(LAST_UPDATE_DATE, 'DD-MON-YYYY HH24:MI:SS')  LAST_UPDATE_DATE,
       REPLACE(COLUMN_DESC, '_', ' ')                       COLUMN_DESC,
       COLUMN_VAL,  
       PAC_VERIFY_CEDIS_PKG.VERIFY_STEP1(COLUMN_DESC, COLUMN_VAL)  VALIDATION
  FROM (SELECT TO_CHAR(HLA.LOCATION_CODE)                                                       AS  "Name",
               TO_CHAR(HLA.DESCRIPTION)                                                         AS  "Description",
               TO_CHAR((CASE WHEN HLA.BUSINESS_GROUP_ID IS NULL THEN
                                  'GLOBAL'
                             ELSE 
                                  'LOCAL'   END))                                               AS  "Scope",
               TO_CHAR(FND.DESCRIPTIVE_FLEX_CONTEXT_NAME)                                       AS  "Address_Style",
               TO_CHAR(HLA.ADDRESS_LINE_1)                                                      AS  "Street",
               TO_CHAR(HLA.ADDRESS_LINE_2)                                                      AS  "Neighborhood",
               TO_CHAR(HLA.REGION_2)                                                            AS  "Municipality",
               TO_CHAR(HLA.POSTAL_CODE)                                                         AS  "Postal_Code",
               TO_CHAR(HLA.TOWN_OR_CITY)                                                        AS  "City",
               TO_CHAR(FLV1.MEANING)                                                            AS  "State",   
               TO_CHAR(FT.NLS_TERRITORY)                                                        AS  "Country",
               TO_CHAR(HLA.TELEPHONE_NUMBER_1)                                                  AS  "Telephone",
               TO_CHAR(FTV.NAME)                                                                AS  "Timezone",
               TO_CHAR(HLA2.LOCATION_CODE)                                                      AS  "Ship_To_Location",
               TO_CHAR(HLA2.SHIP_TO_SITE_FLAG)                                                  AS  "Ship_To_Site",
               TO_CHAR(HLA2.BILL_TO_SITE_FLAG)                                                  AS  "Bill_To_Site",
               TO_CHAR(HLA2.RECEIVING_SITE_FLAG)                                                AS  "Receiving_Site",
               TO_CHAR(HLA2.IN_ORGANIZATION_FLAG)                                               AS  "Internal_Site",
               TO_CHAR(HLA2.OFFICE_SITE_FLAG)                                                   AS  "Office_Site",
               TO_CHAR(MP.ORGANIZATION_CODE || '-' || HOU.NAME)                                 AS  "Inventory_Organization",
               HLA.INVENTORY_ORGANIZATION_ID,
               FUV1.USER_NAME                                                                   AS  CREATED_BY,
               HLA.CREATION_DATE,
               FUV2.USER_NAME                                                                   AS  LAST_UPDATED_BY,
               HLA.LAST_UPDATE_DATE
          FROM HR_LOCATIONS_ALL             HLA,
               FND_TIMEZONES_VL             FTV,
               FND_DESCR_FLEX_CONTEXTS_TL   FND,
               FND_LOOKUP_VALUES            FLV1,
               FND_TERRITORIES_VL           FT,
               HR_LOCATIONS_ALL             HLA2,
               HR_ORGANIZATION_UNITS        HOU,
               MTL_PARAMETERS               MP,
               FND_USER_VIEW                FUV1,
               FND_USER_VIEW                FUV2
         WHERE 1 = 1
           AND HLA.INVENTORY_ORGANIZATION_ID = :P_ORG_INVENTORY_ID
           AND FTV.TIMEZONE_CODE = HLA.TIMEZONE_CODE 
           AND FTV.ENABLED_FLAG = 'Y'
           AND HLA.STYLE = FND.DESCRIPTIVE_FLEX_CONTEXT_CODE
           AND FND.DESCRIPTIVE_FLEXFIELD_NAME(+) = 'Address Location'
           AND FND.LANGUAGE(+) = USERENV ('LANG')
           AND FLV1.LOOKUP_TYPE = 'PER_MX_STATE_CODES' 
           AND FLV1.LANGUAGE = USERENV('LANG') 
           AND FLV1.LOOKUP_CODE = HLA.REGION_1
           AND FT.OBSOLETE_FLAG <> 'Y'
           AND FT.TERRITORY_CODE = HLA.COUNTRY
           AND HLA.LOCATION_ID = HLA2.SHIP_TO_LOCATION_ID
           AND HLA.INVENTORY_ORGANIZATION_ID = HOU.ORGANIZATION_ID 
           AND HOU.ORGANIZATION_ID = MP.ORGANIZATION_ID
           AND HLA.CREATED_BY = FUV1.USER_ID
           AND HLA.LAST_UPDATED_BY = FUV2.USER_ID
        ) DETAIL
 UNPIVOT (COLUMN_VAL FOR COLUMN_DESC IN( "Name",
                                         "Description",
                                         "Scope",
                                         "Address_Style",
                                         "Street",
                                         "Neighborhood",
                                         "Municipality",
                                         "Postal_Code",
                                         "City",
                                         "State",
                                         "Country",
                                         "Telephone",
                                         "Timezone",
                                         "Ship_To_Location",
                                         "Ship_To_Site",
                                         "Bill_To_Site",
                                         "Receiving_Site",
                                         "Internal_Site",
                                         "Office_Site",
                                         "Inventory_Organization"))