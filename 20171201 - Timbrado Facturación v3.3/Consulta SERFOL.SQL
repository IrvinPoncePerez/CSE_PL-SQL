SELECT DISTINCT SERFOL
  FROM PAC_MASTEREDI_REPORT_TB
 WHERE SERFOL IN (SELECT DISTINCT
                         DS.ATTRIBUTE1
                    FROM RA_CUST_TRX_TYPES_ALL            RT,
                         FND_DOC_SEQUENCE_ASSIGNMENTS     DSA,
                         FND_DOCUMENT_SEQUENCES           DS
                   WHERE 1 = 1
                     AND RT.NAME = DSA.CATEGORY_CODE
                     AND DSA.DOC_SEQUENCE_ID = DS.DOC_SEQUENCE_ID
                     AND DS.ATTRIBUTE_CATEGORY = 'CALV_SERIES_FACTURACION'   
                     AND RT.ORG_ID = (CASE 
                                          WHEN 'IPONCE' IN (SELECT FV.FLEX_VALUE
                                                                  FROM FND_FLEX_VALUE_SETS FVS,
                                                                       FND_FLEX_VALUES     FV
                                                                 WHERE 1 = 1
                                                                   AND FVS.FLEX_VALUE_SET_ID = FV.FLEX_VALUE_SET_ID
                                                                   AND FVS.FLEX_VALUE_SET_NAME = 'PAC_SAT_SEARCH_USERS'
                                                                   AND FV.ENABLED_FLAG = 'Y')
                                          THEN RT.ORG_ID
                                          ELSE TO_NUMBER('82')
                                       END))) ORDER BY SERFOL ASC
