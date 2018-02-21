SELECT PAC_MASTEREDI_REPORT_EO.EMIANIO, 
       PAC_MASTEREDI_REPORT_EO.EMIMES, 
       PAC_MASTEREDI_REPORT_EO.EMIDIA, 
       PAC_MASTEREDI_REPORT_EO.EMITION_DATE,
       (CASE
    WHEN PAC_MASTEREDI_REPORT_EO.TIPDOC = 1 
     THEN 'FACTURA'
    WHEN PAC_MASTEREDI_REPORT_EO.TIPDOC = 2
     THEN 'NOTA DE CREDITO'
    END) TIPDOC, 
       PAC_MASTEREDI_REPORT_EO.RFCEMI, 
       PAC_MASTEREDI_REPORT_EO.RFCREC, 
       PAC_MASTEREDI_REPORT_EO.NOMREC,
       PAC_MASTEREDI_REPORT_EO.SERFOL, 
       PAC_MASTEREDI_REPORT_EO.NUMFOL, 
       TRIM(TO_CHAR(PAC_MASTEREDI_REPORT_EO.SUBTBR, '9,999,999,999.99' )) SUBTBR, 
       TRIM(TO_CHAR(PAC_MASTEREDI_REPORT_EO.TOTPAG, '9,999,999,999.99' )) TOTPAG, 
       TRIM(TO_CHAR(NVL(PAC_MASTEREDI_REPORT_EO.TOTRET,0), '9,999,999,999.99' )) TOTRET, 
       TRIM(TO_CHAR(NVL(PAC_MASTEREDI_REPORT_EO.TOTTRA,0), '9,999,999,999.99' )) TOTTRA, 
       PAC_MASTEREDI_REPORT_EO.UUID, 
       PAC_MASTEREDI_REPORT_EO.VERSIO, 
       (CASE 
    WHEN PAC_MASTEREDI_REPORT_EO.CODMETPAG = 'PAGO EN UNA SOLA EXHIBICION' 
    THEN 'PUE'
    ELSE PAC_MASTEREDI_REPORT_EO.CODMETPAG
    END)    CODMETPAG
FROM PAC_MASTEREDI_REPORT_TB PAC_MASTEREDI_REPORT_EO
WHERE 1 = 1
--  AND PAC_MASTEREDI_REPORT_EO.EMITION_DATE BETWEEN TO_DATE(:P_START_DATE,'DD/MM/RRRR') AND TO_DATE(:P_END_DATE, 'DD/MM/RRRR')
  AND (CASE   WHEN PAC_MASTEREDI_REPORT_EO.TIPDOC = 1 
     THEN 'FACTURA'
    WHEN PAC_MASTEREDI_REPORT_EO.TIPDOC = 2
     THEN 'NOTA DE CREDITO'
    END) LIKE :P_TIPDOC
  AND PAC_MASTEREDI_REPORT_EO.RFCEMI LIKE :P_RFCEMI

  AND SERFOL IN (SELECT DISTINCT
                         DS.ATTRIBUTE1
                    FROM RA_CUST_TRX_TYPES_ALL            RT,
                         FND_DOC_SEQUENCE_ASSIGNMENTS     DSA,
                         FND_DOCUMENT_SEQUENCES           DS
                   WHERE 1 = 1
                     AND RT.NAME = DSA.CATEGORY_CODE
                     AND DSA.DOC_SEQUENCE_ID = DS.DOC_SEQUENCE_ID
                     AND DS.ATTRIBUTE_CATEGORY = 'CALV_SERIES_FACTURACION'   
                     AND RT.ORG_ID = (CASE 
                                          WHEN :P_USER_NAME IN (SELECT FV.FLEX_VALUE
                                                                  FROM FND_FLEX_VALUE_SETS FVS,
                                                                       FND_FLEX_VALUES     FV
                                                                 WHERE 1 = 1
                                                                   AND FVS.FLEX_VALUE_SET_ID = FV.FLEX_VALUE_SET_ID
                                                                   AND FVS.FLEX_VALUE_SET_NAME = 'PAC_SAT_SEARCH_USERS'
                                                                   AND FV.ENABLED_FLAG = 'Y')
                                          THEN RT.ORG_ID
                                          ELSE TO_NUMBER(:P_ORG_ID)
                                       END))