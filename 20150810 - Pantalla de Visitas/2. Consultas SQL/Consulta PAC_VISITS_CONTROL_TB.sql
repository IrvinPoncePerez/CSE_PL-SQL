SELECT PVC.VISITOR_DAY_ID                           AS  VISITOR_DAY_ID,
       PVC.VISITOR_NAME                             AS  VISITOR_NAME,
       PVC.VISITOR_COMPANY                          AS  VISITOR_COMPANY, 
       DECODE(PVC.IDENTIFICATION_TYPE,
              'Otro', PVC.OTHER_IDENTIFICATION_NAME,
              PVC.IDENTIFICATION_TYPE)              AS  IDENTIFICATION_TYPE,
       PVC.REASON_VISIT                             AS  REASON_VISIT,
       PVC.ATTRIBUTE1                               AS  ASSOCIATE_PERSON,
       PVC.ATTRIBUTE2                               AS  ASSOCIATE_DEPARTMENT,
       PVC.REGISTRATION_DATE                        AS  REGISTRATION_DATE,
       CASE WHEN CHECK_IN IS NOT NULL THEN
           TO_CHAR(TO_DATE(TO_CHAR(TO_DATE(PVC.REGISTRATION_DATE, 
                                           'DD/MM/YYYY'), 
                                   'DD-MM-YYYY') || ' ' || PVC.CHECK_IN, 
                           'DD-MM-YYYY HH24:MI:SS'), 
                   'HH:MM:SS PM') 
       END                                          AS CHECK_IN,
       CASE WHEN CHECK_OUT IS NOT NULL THEN   
           TO_CHAR(TO_DATE(TO_CHAR(TO_DATE(PVC.REGISTRATION_DATE, 
                                           'DD/MM/YYYY'), 
                                   'DD-MM-YYYY') || ' ' || PVC.CHECK_OUT, 
                           'DD-MM-YYYY HH24:MI:SS'),
                   'HH:MM:SS PM') 
       END                                          AS CHECK_OUT,
       PVC.VISITOR_LENGTH_STAY                      AS  VISITOR_LENGHT_STAY
  FROM PAC_VISITS_CONTROL_TB    PVC
 WHERE 1 = 1 
   AND PVC.VISITOR_NAME LIKE '%'||:P_VISITOR_NAME||'%'
   AND PVC.VISITOR_COMPANY LIKE '%'||:P_VISITOR_COMPANY||'%'
   AND PVC.IDENTIFICATION_TYPE = NVL(:P_IDENTIFICATION_TYPE, PVC.IDENTIFICATION_TYPE) 
 ORDER BY PVC.VISITOR_DAY_ID