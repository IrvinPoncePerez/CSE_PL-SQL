ALTER SESSION SET CURRENT_SCHEMA=APPS;


SELECT AN.TEXT
  FROM AR_RECEIVABLE_APPLICATIONS_ALL   ARAA,
       AR_NOTES                         AN
 WHERE 1 = 1 
   AND ARAA.APPLIED_CUSTOMER_TRX_ID = AN.CUSTOMER_TRX_ID
   AND ARAA.CUSTOMER_TRX_ID = :P_CUSTOMER_TRX_ID;
         
         