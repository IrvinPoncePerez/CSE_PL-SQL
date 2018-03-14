ALTER SESSION SET CURRENT_SCHEMA=APPS;


   
   
   
SELECT CUSTOMER_TRX_ID 
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
   AND ROW_COUNT <> 1;      
           
   

DECLARE
    CURSOR FACTURAS 
    IS
    SELECT CUSTOMER_TRX_ID 
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
       AND ROW_COUNT <> 1;

    CURSOR NOTAS(P_CUSTOMER_TRX_ID   NUMBER)
    IS
    SELECT ARN.CREATION_DATE,
           ARN.CREATED_BY,
           ARN.TEXT,
           ARN.NOTE_ID
      FROM AR_NOTES     ARN
     WHERE 1 = 1
       AND CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID
     ORDER 
        BY CREATION_DATE DESC;           
    
BEGIN 

    FOR FACTURA IN FACTURAS LOOP
        DBMS_OUTPUT.PUT_LINE('**********************************************************');
        
        FOR NOTA IN NOTAS(FACTURA.CUSTOMER_TRX_ID) LOOP
            DBMS_OUTPUT.PUT_LINE('CREATION_DATE : ' || NOTA.CREATION_DATE);
            DBMS_OUTPUT.PUT_LINE('CREATED_BY    : ' || NOTA.CREATED_BY);
            DBMS_OUTPUT.PUT_LINE('TEXT          : ' || NOTA.TEXT);
            DBMS_OUTPUT.PUT_LINE('---------------');    
        END LOOP;
        
    END LOOP;
    
    FOR FACTURA IN FACTURAS LOOP
        DBMS_OUTPUT.PUT_LINE('**********************************************************');
        
        FOR NOTA IN NOTAS(FACTURA.CUSTOMER_TRX_ID) LOOP
            DBMS_OUTPUT.PUT_LINE('NOTE_ID       : ' || NOTA.NOTE_ID);
            DBMS_OUTPUT.PUT_LINE('CREATION_DATE : ' || NOTA.CREATION_DATE);
            DBMS_OUTPUT.PUT_LINE('CREATED_BY    : ' || NOTA.CREATED_BY);
            DBMS_OUTPUT.PUT_LINE('TEXT          : ' || NOTA.TEXT);
            
            DELETE AR_NOTES
             WHERE 1 = 1
               AND NOTE_ID = NOTA.NOTE_ID;
                
            COMMIT; 
            
            EXIT;    
        END LOOP;
        
    END LOOP;

END;   
   
   
   
SELECT *
  FROM (SELECT COUNT(1) ROW_COUNT,
               UUID,
               RFCEMI,
               RFCREC,
               SERFOL 
          FROM PAC_MASTEREDI_REPORT_TB
         WHERE 1 = 1
           AND EXTRACT(YEAR FROM EMITION_DATE) <> 2014
         GROUP
            BY UUID,
               RFCEMI,
               RFCREC,
               SERFOL
       )
 WHERE 1 = 1
   AND ROW_COUNT <> 1      