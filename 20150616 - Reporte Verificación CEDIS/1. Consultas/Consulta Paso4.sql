SELECT FUV1.USER_NAME                                       CREATED_BY,
       TO_CHAR(CREATION_DATE, 'DD-MON-YYYY HH24:MI:SS')     CREATION_DATE,
       FUV2.USER_NAME                                       LAST_UPDATED_BY,
       TO_CHAR(LAST_UPDATE_DATE, 'DD-MON-YYYY HH24:MI:SS')  LAST_UPDATE_DATE,
       REPLACE(COLUMN_DESC, '_', ' ')                       COLUMN_DESC,
       COLUMN_VAL,  
       PAC_VERIFY_CEDIS_PKG.VERIFY_STEP4(COLUMN_DESC, COLUMN_VAL, :P_ORG_INVENTORY_ID, :P_OPERATING_UNIT_ID)  VALIDATION
  FROM (SELECT TO_CHAR(HOU.NAME)                             AS  "Name",
                       TO_CHAR(HOU.DATE_FROM)                AS  "Date_From",
                       TO_CHAR(HLA.LOCATION_CODE)            AS  "Location",
                       TO_CHAR(HL2.MEANING)                  AS  "Internal_or_External",
                       TO_CHAR(HOU.ATTRIBUTE2)               AS  ID_UOSTO_FACT_ELECTR,
                       TO_CHAR(HL.MEANING)                   AS  "Organization_Classifications",
                       TO_CHAR(HOI.ORG_INFORMATION2)         AS  "Enabled",
                       TO_CHAR(HOI2.ORG_INFORMATION_CONTEXT) AS  "Additional_Information",
                       TO_CHAR(GL.NAME)                      AS  "Primary_Ledger",                 
                       TO_CHAR(LE.NAME)                      AS  "Legal_Entity",
                       TO_CHAR(HOU2.NAME)                    AS  "Operating_Unit",
                       HOU.CREATED_BY,
                       HOU.CREATION_DATE,
                       HOU.LAST_UPDATED_BY,
                       HOI2.LAST_UPDATE_DATE     
                  FROM HR_ORGANIZATION_UNITS        HOU,
                       HR_ORGANIZATION_INFORMATION  HOI,
                       HR_LOCATIONS_ALL             HLA,
                       HR_LOOKUPS                   HL,
                       HR_LOOKUPS                   HL2,
                       HR_ORGANIZATION_INFORMATION  HOI2,
                       GL_LEDGERS                   GL,
                       XLE_ENTITY_PROFILES          LE,
                       HR_ORGANIZATION_UNITS        HOU2
                 WHERE 1 = 1
                   AND HOU.ORGANIZATION_ID = :P_ORG_INVENTORY_ID
                   AND HOU.ORGANIZATION_ID = HOI.ORGANIZATION_ID
                   AND HOU.LOCATION_ID = HLA.LOCATION_ID
                   AND HOI.ORG_INFORMATION_CONTEXT = 'CLASS'
                   AND HL.LOOKUP_TYPE = 'ORG_CLASS'
                   AND HL.LOOKUP_CODE = HOI.ORG_INFORMATION1
                   AND HL2.LOOKUP_TYPE = 'INTL_EXTL'
                   AND HL2.LOOKUP_CODE = HOU.INTERNAL_EXTERNAL_FLAG
                   AND HOI2.ORGANIZATION_ID = HOU.ORGANIZATION_ID
                   AND HOI2.ORG_INFORMATION_CONTEXT = 'Accounting Information'
                   AND GL.LEDGER_CATEGORY_CODE = 'PRIMARY' 
                   AND GL.LEDGER_ID = HOI2.ORG_INFORMATION1
                   AND LE.LEGAL_ENTITY_ID = HOI2.ORG_INFORMATION2
                   AND HOU2.ORGANIZATION_ID = HOI2.ORG_INFORMATION3
        ) DETAIL
 UNPIVOT (COLUMN_VAL FOR COLUMN_DESC IN( "Name",
                                         "Date_From",
                                         "Location",
                                         "Internal_or_External",
                                         "Organization_Classifications",
                                         "Enabled",
                                         "Additional_Information",
                                         "Legal_Entity",
                                         "Operating_Unit")),
       FND_USER_VIEW  FUV1,
       FND_USER_VIEW  FUV2    
 WHERE 1 = 1
   AND FUV1.USER_ID = CREATED_BY
   AND FUV2.USER_ID = LAST_UPDATED_BY     
                 