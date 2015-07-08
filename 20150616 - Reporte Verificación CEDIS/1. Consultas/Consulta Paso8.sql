SELECT FUV1.USER_NAME                                       CREATED_BY,
       TO_CHAR(CREATION_DATE, 'DD-MON-YYYY HH24:MI:SS')     CREATION_DATE,
       FUV2.USER_NAME                                       LAST_UPDATED_BY,
       TO_CHAR(LAST_UPDATE_DATE, 'DD-MON-YYYY HH24:MI:SS')  LAST_UPDATE_DATE,
       GROUPBY,
       REPLACE(COLUMN_DESC, '_', ' ')                       COLUMN_DESC,
       COLUMN_VAL,  
       PAC_VERIFY_CEDIS_PKG.VERIFY_STEP8(COLUMN_DESC, COLUMN_VAL, :P_ORG_INVENTORY_ID)  VALIDATION
  FROM (SELECT ROWNUM                                                           AS  GROUPBY,
               TO_CHAR(MP1.ORGANIZATION_CODE)                                            AS  "From_Organization_Code",
               TO_CHAR(HOU1.NAME)                                                        AS  "From_Organization",
               TO_CHAR(MP2.ORGANIZATION_CODE)                                            AS  "To_Organization_Code",
               TO_CHAR(HOU2.NAME)                                                        AS  "To_Organization",
               TO_CHAR(QP.NAME)                                                          AS  "Price_List",
               TO_CHAR(PAC_VERIFY_CEDIS_PKG.GET_ACCOUNT(MIP.INTERORG_PROFIT_ACCOUNT))    AS  "Interorg_Profit_Account",
               MIP.CREATED_BY,
               MIP.CREATION_DATE,
               MIP.LAST_UPDATED_BY,
               MIP.LAST_UPDATE_DATE
          FROM MTL_INTERORG_PARAMETERS      MIP,
               MTL_PARAMETERS               MP1,
               MTL_PARAMETERS               MP2,
               HR_ORGANIZATION_UNITS        HOU1,
               HR_ORGANIZATION_UNITS        HOU2,
               QP_LIST_HEADERS_TL           QP
         WHERE 1 = 1
           AND ((MIP.FROM_ORGANIZATION_ID = 269
             AND MIP.TO_ORGANIZATION_ID = :P_ORG_INVENTORY_ID)
             OR (MIP.FROM_ORGANIZATION_ID = :P_ORG_INVENTORY_ID
             AND MIP.TO_ORGANIZATION_ID = 269))
           AND MIP.FROM_ORGANIZATION_ID = MP1.ORGANIZATION_ID
           AND MIP.TO_ORGANIZATION_ID = MP2.ORGANIZATION_ID
           AND MIP.FROM_ORGANIZATION_ID = HOU1.ORGANIZATION_ID
           AND MIP.TO_ORGANIZATION_ID = HOU2.ORGANIZATION_ID
           AND MIP.PRICELIST_ID = QP.LIST_HEADER_ID
           AND QP.LANGUAGE = USERENV('LANG')
        ) DETAIL
 UNPIVOT (COLUMN_VAL FOR COLUMN_DESC IN( "From_Organization_Code",
                                         "From_Organization",
                                         "To_Organization_Code",
                                         "To_Organization",
                                         "Price_List",
                                         "Interorg_Profit_Account")),
       FND_USER_VIEW  FUV1,
       FND_USER_VIEW  FUV2    
 WHERE 1 = 1
   AND FUV1.USER_ID = CREATED_BY
   AND FUV2.USER_ID = LAST_UPDATED_BY     