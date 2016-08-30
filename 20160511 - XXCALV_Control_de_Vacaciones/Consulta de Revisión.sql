SELECT DAT.ROW_ID
              ,DAT.FULL_NAME
              ,DAT.EMPLOYEE_NUMBER
              ,DAT.PERSON_ID
              ,DAT.BUSINESS_GROUP_ID
              ,DAT.REQUIERE_APROBACION
              ,DAT.FECHA_CONTROL_VACACIONES
              ,DAT.HIRE_DATE
              ,DAT.ANTIGUEDAD_ANT
              ,DAT.ANTIGUEDAD_NUE
              ,DAT.FECHA_INICIO_PERIODO_ACT
              ,DAT.ANTIGUEDAD_SIG
              ,DAT.FECHA_INICIO_PERIODO_SIG
          FROM (
                SELECT COM.*
                      ,ADD_MONTHS(HIRE_DATE, (COM.ANTIGUEDAD_NUE * 12))              FECHA_INICIO_PERIODO_ACT
                      ,COM.ANTIGUEDAD_NUE + 1                                        ANTIGUEDAD_SIG
                      ,ADD_MONTHS(HIRE_DATE, ((COM.ANTIGUEDAD_NUE + 1) * 12))        FECHA_INICIO_PERIODO_SIG
                  FROM (
                        SELECT PP7.ROW_ID
                              ,PP7.FULL_NAME
                              ,PP7.EMPLOYEE_NUMBER
                              ,PP7.PERSON_ID
                              ,PP7.BUSINESS_GROUP_ID
                              ,NVL(PP7.ATTRIBUTE28, 'N')        REQUIERE_APROBACION
                              ,PP7.ATTRIBUTE29                  FECHA_CONTROL_VACACIONES
                              ,TRUNC(PP7.HIRE_DATE)             HIRE_DATE
                              ,TRUNC(MONTHS_BETWEEN(SYSDATE, PP7.HIRE_DATE)/12)
                                                                ANTIGUEDAD_NUE
                              ,TRUNC(MONTHS_BETWEEN(NVL2(PP7.ATTRIBUTE29, TO_DATE(PP7.ATTRIBUTE29, 'YYYY/MM/DD HH24:MI:SS')
                                                                        , PP7.HIRE_DATE), PP7.HIRE_DATE)/12)
                                                                ANTIGUEDAD_ANT
                          FROM PER_PEOPLE_V7     PP7
                         WHERE 1 = 1
                           AND PP7.EFFECTIVE_START_DATE      <= TRUNC(SYSDATE)
                           AND PP7.SYSTEM_PERSON_TYPE        IN ('EMP')
                           AND PP7.PERSON_ID                  = NVL(:p_Person_Id, PP7.PERSON_ID)
                       ) COM
               ) DAT
      WHERE 1 = 1
        AND DAT.ANTIGUEDAD_NUE > 0
      ORDER BY DAT.EMPLOYEE_NUMBER;
      
      
      
      
      
      SELECT DAT.ROW_ID
            ,DAT.FULL_NAME
            ,DAT.EMPLOYEE_NUMBER
            ,DAT.PERSON_ID
            ,DAT.BUSINESS_GROUP_ID
            ,DAT.REQUIERE_APROBACION
            ,DAT.FECHA_CONTROL_VACACIONES
            ,DAT.CAPTURA_VACACIONES
            ,DAT.HIRE_DATE
            ,DAT.ANTIGUEDAD_ACT
            ,DAT.FECHA_INICIO_PERIODO_ACT
--            ,ADD_MONTHS(DAT.FECHA_INICIO_PERIODO_ACT, g_Max_Meses_Disfrutar) - 1      FECHA_FIN_PERIODO_ACT
            ,DAT.ANTIGUEDAD_SIG
            ,DAT.FECHA_INICIO_PERIODO_SIG
--            ,ADD_MONTHS(DAT.FECHA_INICIO_PERIODO_SIG, g_Max_Meses_Disfrutar) - 1      FECHA_FIN_PERIODO_SIG
        FROM (
              SELECT COM.*
                    ,ADD_MONTHS(HIRE_DATE, (COM.ANTIGUEDAD_ACT * 12))              FECHA_INICIO_PERIODO_ACT
                    ,COM.ANTIGUEDAD_ACT + 1                                        ANTIGUEDAD_SIG
                    ,ADD_MONTHS(HIRE_DATE, ((COM.ANTIGUEDAD_ACT + 1) * 12))        FECHA_INICIO_PERIODO_SIG
                FROM (
                      SELECT PP7.ROW_ID
                            ,PP7.FULL_NAME
                            ,PP7.EMPLOYEE_NUMBER
                            ,PP7.PERSON_ID
                            ,PP7.BUSINESS_GROUP_ID
                            ,NVL(PP7.ATTRIBUTE28, 'N')        REQUIERE_APROBACION
                            ,PP7.ATTRIBUTE29                  FECHA_CONTROL_VACACIONES
                            ,NVL(PP7.ATTRIBUTE30, 'N')        CAPTURA_VACACIONES
                            ,TRUNC(PP7.HIRE_DATE)             HIRE_DATE
                            ,TRUNC(MONTHS_BETWEEN(SYSDATE, PP7.HIRE_DATE)/12)
                                                              ANTIGUEDAD_ACT
                        FROM PER_PEOPLE_V7     PP7
                       WHERE 1 = 1
                         AND PP7.EFFECTIVE_START_DATE      <= TRUNC(SYSDATE)
                         AND PP7.SYSTEM_PERSON_TYPE        IN ('EMP')
                         AND PP7.PERSON_ID                  = :p_Person_Id
                     ) COM
             ) DAT;
             
             
             
             
             
             
             SELECT DAT.ROW_ID
              ,DAT.FULL_NAME
              ,DAT.EMPLOYEE_NUMBER
              ,DAT.PERSON_ID
              ,DAT.BUSINESS_GROUP_ID
              ,DAT.REQUIERE_APROBACION
              ,DAT.FECHA_CONTROL_VACACIONES
              ,DAT.HIRE_DATE
              ,DAT.ANTIGUEDAD_ANT
              ,DAT.ANTIGUEDAD_NUE
              ,DAT.FECHA_INICIO_PERIODO_ACT
--              ,ADD_MONTHS(DAT.FECHA_INICIO_PERIODO_ACT, g_Max_Meses_Disfrutar) - 1      FECHA_FIN_PERIODO_ACT
              ,DAT.ANTIGUEDAD_SIG
              ,DAT.FECHA_INICIO_PERIODO_SIG
--              ,ADD_MONTHS(DAT.FECHA_INICIO_PERIODO_SIG, g_Max_Meses_Disfrutar) - 1      FECHA_FIN_PERIODO_SIG
          FROM (
                SELECT COM.*
                      ,ADD_MONTHS(HIRE_DATE, (COM.ANTIGUEDAD_NUE * 12))              FECHA_INICIO_PERIODO_ACT
                      ,COM.ANTIGUEDAD_NUE + 1                                        ANTIGUEDAD_SIG
                      ,ADD_MONTHS(HIRE_DATE, ((COM.ANTIGUEDAD_NUE + 1) * 12))        FECHA_INICIO_PERIODO_SIG
                  FROM (
                        SELECT PP7.ROW_ID
                              ,PP7.FULL_NAME
                              ,PP7.EMPLOYEE_NUMBER
                              ,PP7.PERSON_ID
                              ,PP7.BUSINESS_GROUP_ID
                              ,NVL(PP7.ATTRIBUTE28, 'N')        REQUIERE_APROBACION
                              ,PP7.ATTRIBUTE29                  FECHA_CONTROL_VACACIONES
                              ,TRUNC(PP7.HIRE_DATE)             HIRE_DATE
                              ,TRUNC(MONTHS_BETWEEN(SYSDATE, PP7.HIRE_DATE)/12)
                                                                ANTIGUEDAD_NUE
                              ,TRUNC(MONTHS_BETWEEN(NVL2(PP7.ATTRIBUTE29, TO_DATE(PP7.ATTRIBUTE29, 'YYYY/MM/DD HH24:MI:SS')
                                                                        , PP7.HIRE_DATE), PP7.HIRE_DATE)/12)
                                                                ANTIGUEDAD_ANT
                          FROM PER_PEOPLE_V7     PP7
                         WHERE 1 = 1
                           AND PP7.EFFECTIVE_START_DATE      <= TRUNC(SYSDATE)
                           AND PP7.SYSTEM_PERSON_TYPE        IN ('EMP')
                           AND PP7.PERSON_ID                  = NVL(:p_Person_Id, PP7.PERSON_ID)
                       ) COM
               ) DAT
      WHERE 1 = 1
        AND DAT.ANTIGUEDAD_NUE > 0
      ORDER BY DAT.EMPLOYEE_NUMBER;
      
      
      
      
      SELECT HLU.MEANING
        FROM PAY_ELEMENT_TYPES_F          ETF
            ,PAY_ELEMENT_ENTRIES_F        EEF
            ,PAY_INPUT_VALUES_F           IVF
            ,PAY_ELEMENT_ENTRY_VALUES_F   EEV
            ,HR_LOOKUPS                   HLU
       WHERE 1 = 1
         AND ETF.ELEMENT_NAME           = 'Integrated Daily Wage'
         AND EEF.ELEMENT_TYPE_ID        = ETF.ELEMENT_TYPE_ID
         AND EEF.ASSIGNMENT_ID          = :p_Assignment_Id
         AND IVF.ELEMENT_TYPE_ID        = ETF.ELEMENT_TYPE_ID
         AND IVF.DISPLAY_SEQUENCE       = 4
         AND EEV.ELEMENT_ENTRY_ID       = EEF.ELEMENT_ENTRY_ID
         AND EEV.INPUT_VALUE_ID         = IVF.INPUT_VALUE_ID
         AND HLU.LOOKUP_TYPE            = IVF.LOOKUP_TYPE      --'MX_IDW_FACTOR_TABLES'
         AND HLU.ENABLED_FLAG           = 'Y'
         AND HLU.LOOKUP_CODE            = EEV.SCREEN_ENTRY_VALUE
         AND SYSDATE BETWEEN EEV.EFFECTIVE_START_DATE AND EEV.EFFECTIVE_END_DATE
         AND SYSDATE BETWEEN EEF.EFFECTIVE_START_DATE AND EEF.EFFECTIVE_END_DATE;
         
         
         
         SELECT UCI.VALUE
        FROM PAY_USER_TABLES_FV               UTF
            ,PAY_USER_COLUMNS_FV              UCF
            ,XXCALV_PAY_USER_COLUMN_INST_V    UCI
       WHERE 1 = 1
         AND UTF.BASE_USER_TABLE_NAME          = :p_Tipo_Nomina
         AND UCF.USER_TABLE_ID                 = UTF.USER_TABLE_ID
         AND UCF.BASE_USER_COLUMN_NAME         = 'DIAS VACACIONES'
         AND UCI.USER_COLUMN_ID                = UCF.USER_COLUMN_ID
         AND :p_Antiguedad         BETWEEN UCI.ROW_LOW_RANGE_OR_NAME AND UCI.ROW_HIGH_RANGE;
         
         SELECT UCI.VALUE
        FROM PAY_USER_TABLES_FV               UTF
            ,PAY_USER_COLUMNS_FV              UCF
            ,XXCALV_PAY_USER_COLUMN_INST_V    UCI
       WHERE 1 = 1
         AND UTF.BASE_USER_TABLE_NAME          = :p_Tipo_Nomina
         AND UCF.USER_TABLE_ID                 = UTF.USER_TABLE_ID
         AND UCF.BASE_USER_COLUMN_NAME         = 'DIAS VACACIONES'
         AND UCI.USER_COLUMN_ID                = UCF.USER_COLUMN_ID
         AND :p_Antiguedad         BETWEEN UCI.ROW_LOW_RANGE_OR_NAME AND UCI.ROW_HIGH_RANGE;