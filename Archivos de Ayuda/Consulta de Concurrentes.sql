SELECT DISTINCT
       FCPT.USER_CONCURRENT_PROGRAM_NAME,
       FAV.APPLICATION_NAME,
       FUV.USER_NAME,
       
       DECODE (FE.EXECUTION_METHOD_CODE
             , 'A', 'Spawned'
             , 'B', 'Request Set Stage Function'
             , 'E', 'Perl Concurrent Program'
             , 'H', 'Host'
             , 'I', 'PL/SQL Stored Procedure'
             , 'J', 'Java Stored Procedure'
             , 'K', 'Java Concurrent Program'
             , 'L', 'SQL*Loader'
             , 'M', 'Multi Language Function'
             , 'P', 'Oracle Reports'
             , 'Q', 'SQL*Plus'
             , 'S', 'Immediate'
             , 'Other') EXECUTION_METHOD_DESC,
       TO_CHAR(FCP.CREATION_DATE, 'YYYY/MM/DD') CREATION_DATE
  FROM FND_CONCURRENT_PROGRAMS      FCP,
       FND_CONCURRENT_PROGRAMS_TL   FCPT,
       FND_EXECUTABLES              FE,
       APPS.FND_APPLICATION_VL           FAV, 
       APPS.FND_USER_VIEW           FUV 
 WHERE FCPT.USER_CONCURRENT_PROGRAM_NAME LIKE '%XXCALV%'
   AND FCP.EXECUTABLE_ID = FE.EXECUTABLE_ID
   AND FCPT.CONCURRENT_PROGRAM_ID = FCP.CONCURRENT_PROGRAM_ID
   AND FCP.CREATED_BY = FUV.USER_ID
   AND FCP.APPLICATION_ID = FAV.APPLICATION_ID
   AND FCP.ENABLED_FLAG = 'Y'
   AND (FUV.USER_NAME <> 'JFCASTRO'
    AND FUV.USER_NAME <> 'RCARDENAS'
    AND FUV.USER_NAME <> 'ASANTIAGO')
 ORDER BY 5 
   