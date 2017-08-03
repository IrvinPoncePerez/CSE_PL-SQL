CREATE OR REPLACE VIEW  APPS.ATET_SB_PAYMENT_NUMBER_V
AS
         SELECT LEVEL NUM_ROW,
                'Semana' AS PERIOD_TYPE
           FROM DUAL 
          WHERE ROWNUM <= 1
        CONNECT BY LEVEL = ROWNUM
          UNION
         SELECT LEVEL NUM_ROW,
                'Semana' AS PERIOD_TYPE
           FROM DUAL 
          WHERE ROWNUM <= 16
        CONNECT BY LEVEL = ROWNUM
        UNION
        SELECT LEVEL NUM_ROW,
               'Quincena' AS PERIOD_TYPE
           FROM DUAL 
          WHERE ROWNUM <= 1
        CONNECT BY LEVEL = ROWNUM
          UNION
         SELECT LEVEL NUM_ROW,
                'Quincena' AS PERIOD_TYPE
           FROM DUAL 
          WHERE ROWNUM <= 8
        CONNECT BY LEVEL = ROWNUM;
       
   
 
   
  --ATET_SB_PAYMENT_NUMBER             