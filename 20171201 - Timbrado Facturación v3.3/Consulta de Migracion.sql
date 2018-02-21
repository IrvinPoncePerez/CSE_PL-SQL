ALTER SESSION SET CURRENT_SCHEMA=APPS;

   
   
   
   
SELECT ROWINDEX,
       EMIANIO,
       EMIMES,
       DESCRI,
       REGISTROS
  FROM (   
        SELECT COUNT(1) REGISTROS,
               'MIGRADOS' DESCRI,
               1    ROWINDEX,       
               EMIANIO,
               EMIMES
          FROM PAC_MASTEREDI_REPORT_TB
         WHERE 1 = 1
         GROUP
            BY EMIANIO,
               EMIMES
        UNION
        SELECT COUNT(1) REGISTROS,
               'PENDIENTES' DESCRI,
               2    ROWINDEX,
               EMIANIO,
               EMIMES
          FROM PAC_MASTEREDI_REPORT_TB
         WHERE 1 = 1
           AND NOMREC IS NULL
         GROUP
            BY EMIANIO,
               EMIMES
        UNION
        SELECT COUNT(1) REGISTROS,
               'CON RETENCION' DESCRI,
               3    ROWINDEX,
               EMIANIO,
               EMIMES
          FROM PAC_MASTEREDI_REPORT_TB
         WHERE 1 = 1
           AND TOTRET IS NOT NULL
         GROUP 
            BY EMIANIO,
               EMIMES
        UNION
        SELECT COUNT(1) REGISTROS,
               'CON TRASLADO' DESCRI,
               4    ROWINDEX,
               EMIANIO,
               EMIMES
          FROM PAC_MASTEREDI_REPORT_TB
         WHERE 1 = 1
           AND TOTTRA <> 0
         GROUP
            BY EMIANIO,
               EMIMES
      )
 ORDER 
    BY EMIANIO  DESC,
       EMIMES   DESC,
       ROWINDEX ASC; 
               
               
               
               

   
SELECT *
  FROM PAC_MASTEREDI_REPORT_TB
 WHERE 1 = 1
   AND EMIANIO = 2014
   AND EMIMES = 11;                  