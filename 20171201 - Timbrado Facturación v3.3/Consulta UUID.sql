ALTER SESSION SET CURRENT_SCHEMA=APPS;


   
   
   
SELECT * 
  FROM (   
        SELECT RACT.CUSTOMER_TRX_ID,
               RACT.DOC_SEQUENCE_VALUE,
               RACT.CTT_TYPE_NAME,
               RACT.TRX_DATE,
               COUNT(1) ROW_COUNT
          FROM RA_CUSTOMER_TRX_PARTIAL_CFD  RACT,
               AR_NOTES                     ARN
         WHERE 1 = 1
           AND RACT.CUSTOMER_TRX_ID = ARN.CUSTOMER_TRX_ID
           AND EXTRACT(YEAR FROM RACT.TRX_DATE) IN (2017, 2018)
         GROUP 
            BY RACT.CUSTOMER_TRX_ID,
               RACT.DOC_SEQUENCE_VALUE,
               RACT.CTT_TYPE_NAME,
               RACT.TRX_DATE
       )
 WHERE 1 = 1
   AND ROW_COUNT <> 1        ;      
   
   
   
   