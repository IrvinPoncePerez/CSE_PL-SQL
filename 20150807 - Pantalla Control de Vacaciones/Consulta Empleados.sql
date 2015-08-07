SELECT PP7.EMPLOYEE_NUMBER
        ,PP7.FULL_NAME
        ,PP7.PERSON_ID
    FROM PER_PEOPLE_V7     PP7,
         PER_PERIODS_OF_SERVICE PPS
   WHERE 1 = 1
     AND PP7.SYSTEM_PERSON_TYPE        IN ('EMP')
     AND PP7.EFFECTIVE_START_DATE      <= TRUNC(SYSDATE)
     AND EXISTS                        ( SELECT 'S'
                                           FROM XXCALV_VAC_GRUPO_EMP      VGE
                                          WHERE 1 = 1
                                            AND VGE.PERSON_ID = PP7.PERSON_ID
                                       )
     AND PPS.PERSON_ID(+) = PP7.PERSON_ID
   AND (   (PP7.EMPLOYEE_NUMBER IS NULL)
        OR (    PP7.EMPLOYEE_NUMBER IS NOT NULL
            AND PPS.DATE_START = (SELECT MAX (PPS1.DATE_START)
                                    FROM PER_PERIODS_OF_SERVICE PPS1
                                   WHERE PPS1.PERSON_ID = PP7.PERSON_ID)
           )
       )
   AND PP7.EFFECTIVE_START_DATE = (SELECT MAX (PER1.EFFECTIVE_START_DATE)
                                     FROM PER_PEOPLE_F PER1
                                    WHERE PER1.PERSON_ID = PP7.PERSON_ID)
ORDER BY PP7.FULL_NAME