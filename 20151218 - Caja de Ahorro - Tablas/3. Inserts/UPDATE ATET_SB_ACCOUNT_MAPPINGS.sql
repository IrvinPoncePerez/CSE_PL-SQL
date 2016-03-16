            MERGE INTO ATET_SB_ACCOUNT_MAPPING      ASAM
                 USING GL_CODE_COMBINATIONS_V       GL
                    ON (    GL.TEMPLATE_ID IS NULL
                        AND GL.SEGMENT1 = '07'
                        AND (GL.SEGMENT1 ||
                             GL.SEGMENT2 ||
                             GL.SEGMENT3 ||
                             GL.SEGMENT4 ||
                             GL.SEGMENT5 ||
                             GL.SEGMENT6) = ASAM.CONCATENED_SEGMENT_2)
            WHEN MATCHED THEN 
            UPDATE SET ASAM.ACCOUNT_MAPPING_ID = GL.GL.CODE_COMBINATION_ID;
            
            
            SELECT ASAM.ACCOUNT_MAPPING_ID,
                   ASAM.ATTRIBUTE1
              FROM ATET_SB_ACCOUNT_MAPPING  ASAM;
              
              
------            COMMIT;
            
            MERGE INTO ATET_SB_MEMBERS_ACCOUNTS     ASMA
                 USING ATET_SB_ACCOUNT_MAPPING      ASAM
                    ON (ASMA.ACCOUNT_NUMBER = ASAM.CONCATENED_SEGMENT_2)
            WHEN MATCHED THEN
            UPDATE
               SET ASMA.CODE_COMBINATION_ID = ASAM.ACCOUNT_MAPPING_ID;
               
               
            SELECT *
              FROM ATET_SB_MEMBERS_ACCOUNTS;
              
            SELECT *
              FROM ATET_XLA_LINES;


UPDATE ATET_XLA_LINES  AXL
   SET AXL.CODE_COMBINATION_ID = (SELECT ASAM.ACCOUNT_MAPPING_ID
                                    FROM ATET_SB_ACCOUNT_MAPPING ASAM
                                   WHERE 1 = 1
                                     AND ASAM.ATTRIBUTE1 = :ACCOUNT_MAPPING_ID)
 WHERE 1 = 1
   AND AXL.CODE_COMBINATION_ID = :ACCOUNT_MAPPING_ID;
   
   
SELECT *
  FROM ATET_XLA_LINES;
  
  
----  COMMIT;