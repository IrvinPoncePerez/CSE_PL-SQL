 SELECT 
               PEOPLE.PERSON_ID,
               PEOPLE.RFC,
               PEOPLE.AP_PATERNO,
               PEOPLE.AP_MATERNO,
               PEOPLE.NOMBRES,
               PEOPLE.CUENTA_BANCO,
               PEOPLE.CODIGO_BANCO,
               PEOPLE.CLABE_BANCO,
               PEOPLE.NUM_NOMINA,
               PEOPLE.NUM_SEGURO,
               PEOPLE.CURP,
               PEOPLE.SEXO,
               PEOPLE.VALOR_ALTA,
               RPAD(NVL(PA.ADDRESS_LINE1, ' ') || ' ' || NVL(PA.ADDR_ATTRIBUTE2, ' ') , 40, ' ') AS  CALLE_NUMERO, --Campo 23: Calle y Número. Longitud limitada a 40 posiciones. 
               RPAD(NVL(PA.ADDRESS_LINE2, ' '), 25, ' ')                                         AS  COLONIA,            --Campo 24: Colonia. Longitud limitada a 25 posiciones.
               TO_CHAR(PA.POSTAL_CODE, '00000')                                                  AS  CODIGO_POSTAL,      --Campo 25: Código Postal. Longitud limitada a 5 posiciones.
               RPAD((NVL(PA.TOWN_OR_CITY, ' ') || ', ' || NVL(FLV.MEANING, ' ')), 20, ' ')       AS  CIUDAD              --Campo 26: Ciudad Y Estado. Longitud limitada a 20 posiciones.
          FROM (SELECT DISTINCT
                    PPF.PERSON_ID                                                               AS  PERSON_ID,
                    REPLACE(PAPF.PER_INFORMATION2, '-', '')                                     AS  RFC,                --Campo 11: RFC Trabajador. Longitud limitada a 13 posiciones. 
                    RPAD(TRIM(PAPF.LAST_NAME), 40, ' ')                                         AS  AP_PATERNO,         --Campo 12: Apellido Paterno, requerido. Longitud limitada a 40 posiciones.
                    RPAD(TRIM(PAPF.PER_INFORMATION1), 40, ' ')                                  AS  AP_MATERNO,         --Campo 13: Apellido Materno, requerido. Longitud limitada a 40 posiciones.
                    RPAD(PAPF.FIRST_NAME || ' ' || PAPF.MIDDLE_NAMES, 40, ' ')                  AS  NOMBRES,            --Campo 14: Nombres, requerido. Longitud limitada a 40 posiciones.
                    (SELECT DISTINCT
                        LPAD(MEANING, 13, '0')
                       FROM FND_LOOKUP_VALUES   FLV
                      WHERE FLV.LOOKUP_TYPE = 'XXCALV_APORT_FONDO_AHORRO'
                        AND FLV.LOOKUP_CODE = 'N CUENTA BAN')                                   AS  CUENTA_BANCO,       --Campo 15: Número de Cuenta Bancaria, requerido. Longitud limitada a 13 posiciones.
                    (SELECT DISTINCT
                        LPAD(MEANING, 3, '0')
                       FROM FND_LOOKUP_VALUES   FLV
                      WHERE FLV.LOOKUP_TYPE = 'XXCALV_APORT_FONDO_AHORRO'
                        AND FLV.LOOKUP_CODE = 'COD BANCO CUENT')                                AS  CODIGO_BANCO,       --Campo 16: Código del Banco de la Cuenta, requerido. Longitud limitada a 3 posiciones.
                    (SELECT DISTINCT
                        LPAD(MEANING, 20, '0')
                       FROM FND_LOOKUP_VALUES   FLV
                      WHERE FLV.LOOKUP_TYPE = 'XXCALV_APORT_FONDO_AHORRO'
                        AND FLV.LOOKUP_CODE = 'CLAVE INTERBANCARIA')                            AS  CLABE_BANCO,        --Campo 17: Clabe Interbancaria, requerido. Longitud limitada a 20 posiciones.
                    RPAD(PPF.EMPLOYEE_NUMBER, 20, ' ')                                          AS  NUM_NOMINA,         --Campo 18: Número de Nómina, requerido. Longitud limitada a 20 posiciones.
                    TO_CHAR(REPLACE(NVL(PAPF.PER_INFORMATION3, '0'), '-', ''), '00000000000')   AS  NUM_SEGURO,         --Campo 19: NSS del Empleado. Longitud limitada a 11 posiciones. 
                    RPAD(TRIM(PAPF.NATIONAL_IDENTIFIER), 18, ' ')                               AS  CURP,               --Campo 20: CURP. Longitud limitada a 18 posiciones, tipo alfanumérico.
                    TRIM(PPF.SEX)                                                               AS  SEXO,               --Campo 21: Sexo = F ó M. Longitud limitada a 1 posición.
                    TO_CHAR(PPTUF.EFFECTIVE_START_DATE, 'RRRRMMDD')                             AS  VALOR_ALTA         --Campo 22: Fecha Valor del Alta. Longitud limitada a 8 posiciones. Formato: AAAAMMDD    
                  FROM PER_PEOPLE_F                    PPF,      
                       PER_PERSON_TYPES                PPT, 
                       PER_ALL_PEOPLE_F                PAPF,  
                       PER_ALL_ASSIGNMENTS_F           PAAF,  
                       PER_PERSON_TYPE_USAGES_F        PPTUF,
                       PER_PERIODS_OF_SERVICE          PPS
                 WHERE 1 = 1
                   AND PPF.PERSON_ID = PPTUF.PERSON_ID
                   AND PPF.PERSON_TYPE_ID = PPT.PERSON_TYPE_ID
                   AND PAPF.PERSON_ID = PPF.PERSON_ID
                   AND PAAF.PERSON_ID = PPF.PERSON_ID
                   AND (PPTUF.EFFECTIVE_START_DATE BETWEEN var_start_date AND var_end_date)
                   AND (PPF.EFFECTIVE_START_DATE = PPTUF.EFFECTIVE_START_DATE
                    AND PPF.EFFECTIVE_START_DATE = PAPF.EFFECTIVE_START_DATE
                    AND PPF.EFFECTIVE_START_DATE = PPS.DATE_START)
                   AND PPS.ACTUAL_TERMINATION_DATE IS NULL
                   AND PAAF.PERIOD_OF_SERVICE_ID = PPS.PERIOD_OF_SERVICE_ID  
                   AND PPT.SYSTEM_PERSON_TYPE = 'EMP')  PEOPLE
         LEFT JOIN PER_ADDRESSES                        PA      ON  PEOPLE.PERSON_ID = PA.PERSON_ID
         LEFT JOIN FND_LOOKUP_VALUES                    FLV     ON  FLV.LOOKUP_CODE = PA.REGION_1 AND FLV.LOOKUP_TYPE = 'MX_STATE' AND FLV.LANGUAGE = 'ESA'             
        ORDER BY PEOPLE.PERSON_ID;