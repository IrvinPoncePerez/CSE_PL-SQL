SELECT DISTINCT
       PPF.PERSON_ID,
       PPF.EMPLOYEE_NUMBER,
       PPF.FULL_NAME,
       XVE.ID_EVENTO,
       XVE.SALDO_DIAS
--       xve.*
  FROM PER_PEOPLE_F             PPF,
       APPS.XXCALV_VAC_EVENTOS  XVE
 WHERE 1 = 1
   AND PPF.EMPLOYEE_NUMBER = :P_EMPLOYEE_NUMBER
   AND PPF.PERSON_ID = XVE.PERSON_ID
   AND SYSDATE BETWEEN XVE.FECHA_DESDE AND XVE.FECHA_HASTA;


XXCALV_VAC_EVENTOS_DET
   
   
   
MERGE INTO apps.XXCALV_VAC_EVENTOS   XVE
     USING (SELECT DISTINCT
                   PPF.PERSON_ID,
                   PPF.FULL_NAME,
                   XVE.ID_EVENTO,
                   XVE.SALDO_DIAS
              FROM PER_PEOPLE_F             PPF,
                   APPS.XXCALV_VAC_EVENTOS  XVE
             WHERE 1 = 1
               AND PPF.EMPLOYEE_NUMBER = :P_EMPLOYEE_NUMBER
               AND PPF.PERSON_ID = XVE.PERSON_ID
               AND SYSDATE BETWEEN XVE.FECHA_DESDE AND XVE.FECHA_HASTA
            ) XVE_SOURCE
        ON (    XVE.ID_EVENTO = XVE_SOURCE.ID_EVENTO
            AND XVE.PERSON_ID = XVE_SOURCE.PERSON_ID)
      WHEN MATCHED THEN
    UPDATE SET XVE.SALDO_DIAS = :P_SALDO_DIAS;
    
       
    
COMMIT;    
   
   
   

   
   
  