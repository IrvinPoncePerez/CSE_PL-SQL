SELECT PP7.EMPLOYEE_NUMBER
        ,PP7.FULL_NAME
        ,PP7.PERSON_ID
    FROM PER_PEOPLE_V7     PP7
   WHERE 1 = 1
     AND PP7.SYSTEM_PERSON_TYPE        IN ('EMP')
     AND PP7.EFFECTIVE_START_DATE      <= TRUNC(SYSDATE)
     AND EXISTS                        ( SELECT 'S'
                                           FROM XXCALV_VAC_GRUPO_EMP      VGE
                                          WHERE 1 = 1
                                            AND VGE.PERSON_ID = PP7.PERSON_ID
                                       )
ORDER BY PP7.FULL_NAME