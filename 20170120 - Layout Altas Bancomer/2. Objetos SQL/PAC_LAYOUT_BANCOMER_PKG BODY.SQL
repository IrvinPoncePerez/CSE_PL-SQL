CREATE OR REPLACE PACKAGE BODY PAC_LAYOUT_BANCOMER_PKG 
IS

    PROCEDURE   LAYOUT_BANCOMER
                (
                    P_ERRBUF         OUT NOCOPY VARCHAR2,
                    P_RETCODE        OUT NOCOPY VARCHAR2,
                    P_START_DATE                VARCHAR2,
                    P_END_DATE                  VARCHAR2
                )
    IS
    
        var_start_date  DATE := TRUNC(TO_DATE(P_START_DATE,'RRRR/MM/DD HH24:MI:SS'));
        var_end_date    DATE := TRUNC(TO_DATE(P_END_DATE,'RRRR/MM/DD HH24:MI:SS'));
        var_line        VARCHAR2(2000);
    
        CURSOR  EMPLOYEE_DETAILS
            IS
        SELECT PPF.FIRST_NAME || ' ' || PPF.MIDDLE_NAMES                    AS  FIRST_NAME,
               PPF.LAST_NAME                                                AS  LAST_NAME,
               PPF.PER_INFORMATION1                                         AS  SECOND_LAST_NAME,
               TO_CHAR(DATE_OF_BIRTH, 'RRRR-MM-DD')                         AS  DATE_BIRTH,
               (CASE
                    WHEN FLV.MEANING = 'Casado' 
                        THEN 'C'
                    WHEN FLV.MEANING = 'Divorciado' 
                        THEN 'D'
                    WHEN FLV.MEANING = 'Soltero' 
                        THEN 'S'
                    WHEN FLV.MEANING = 'Unión Libre' 
                        THEN 'U'
                    WHEN FLV.MEANING IN ('Viudo', 'Viuda/Viudo') 
                        THEN 'V'
                    WHEN FLV.MEANING IN ('Separado', 'Separado(1)') 
                        THEN 'X'
                    ELSE     'NO DEFINIDO'
                END)                                                        AS  MARITAL_STATUS,
               PPF.NATIONAL_IDENTIFIER                                      AS  NATIONAL_IDENTIFIER,
               PPF.SEX                                                      AS  SEX,
               (CASE
                    WHEN PPF.NATIONALITY = 'PQH_ME' 
                        THEN 'M'
                    ELSE     'E'
                END)                                                        AS  NATIONALITY,
               (CASE
                    WHEN FLV1.MEANING = 'Guatemala' 
                        THEN 'GUT'
                    WHEN FLV1.MEANING = 'Estados Unidos de América' 
                        THEN 'EUA'
                    WHEN FLV1.MEANING = 'México' 
                        THEN 'MEX'
                    WHEN FLV1.MEANING = 'El Salvador' 
                        THEN 'ESA'
                    WHEN FLV1.MEANING = 'Marruecos' 
                        THEN 'MAR'
                    ELSE     'NO DEFINIDO'
                END)                                                        AS  COUNTRY_OF_BIRTH,
               'EPL'                                                        AS  EMPLOYMENT,
               TO_CHAR(NVL(PPOS.ADJUSTED_SVC_DATE, 
                           PPF.ORIGINAL_DATE_OF_HIRE),
                       'RRRR-MM-DD')                                        AS  DATE_HIRE,
               PA.ADDRESS_LINE1                                             AS  STREET,
               PA.ADDR_ATTRIBUTE2                                           AS  INT_NUMBER,
               PA.ADDR_ATTRIBUTE1                                           AS  EXT_NUMBER,
               PA.ADDRESS_LINE2                                             AS  NEIGHBORHOOD,
               PA.POSTAL_CODE                                               AS  POSTAL_CODE,
               PA.REGION_2                                                  AS  TOWN_OR_CITY,
               (CASE
                    WHEN FLV2.MEANING = 'Morelos' 
                        THEN 'MO'
                    WHEN FLV2.MEANING = 'Tlaxcala' 
                        THEN 'TL'
                    WHEN FLV2.MEANING = 'Tabasco' 
                        THEN 'TA'
                    WHEN FLV2.MEANING = 'Oaxaca' 
                        THEN 'OA'
                    WHEN FLV2.MEANING = 'Guerrero' 
                        THEN 'GO'
                    WHEN FLV2.MEANING = 'Chiapas' 
                        THEN 'CS'
                    WHEN FLV2.MEANING = 'Hidalgo' 
                        THEN 'HI'
                    WHEN FLV2.MEANING = 'Puebla' 
                        THEN 'PU'
                    WHEN FLV2.MEANING = 'Veracruz de Ignacio de la Llave' 
                        THEN 'VE'
                    WHEN FLV2.MEANING = 'México' 
                        THEN 'EM'
                    WHEN FLV2.MEANING = 'Campeche' 
                        THEN 'CA'
                    WHEN FLV2.MEANING = 'Ciudad de México' 
                        THEN 'DF'
                END)                                                        AS  STATE,
               REPLACE(REPLACE(PPPM.ATTRIBUTE1,CHR(10), ''), CHR(13), '')   AS  DEBIT_CARD
          FROM PER_PEOPLE_F                     PPF,
               PER_PERSON_TYPES                 PPT,
               FND_LOOKUP_VALUES                FLV,
               FND_LOOKUP_VALUES                FLV1,
               FND_LOOKUP_VALUES                FLV2,
               PER_PERIODS_OF_SERVICE           PPOS,
               PER_ADDRESSES                    PA,
               PER_ASSIGNMENTS_F                PAF,
               PAY_PERSONAL_PAYMENT_METHODS_F   PPPM,
               PAY_ORG_PAYMENT_METHODS_F        POPM
         WHERE 1 = 1
           AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE
                           AND PPF.EFFECTIVE_END_DATE
           AND PPF.PERSON_TYPE_ID = PPT.PERSON_TYPE_ID
           AND PPT.USER_PERSON_TYPE IN ('Empleado',
                                        'Employee')
           AND FLV.LOOKUP_TYPE = 'MAR_STATUS'                              
           AND FLV.LOOKUP_CODE = PPF.MARITAL_STATUS
           AND FLV.LANGUAGE = 'ESA'
           AND FLV1.LOOKUP_TYPE = 'PER_US_COUNTRY_CODE'
           AND FLV1.LOOKUP_CODE = PPF.COUNTRY_OF_BIRTH
           AND FLV1.LANGUAGE = 'ESA'
           AND PPF.PERSON_ID = PPOS.PERSON_ID
           AND PPOS.ACTUAL_TERMINATION_DATE IS NULL
           AND PPF.PERSON_ID = PA.PERSON_ID
           AND PA.DATE_TO IS NULL
           AND FLV2.LOOKUP_TYPE = 'MX_STATE'
           AND FLV2.LOOKUP_CODE = PA.REGION_1
           AND FLV2.LANGUAGE = 'ESA'
           AND PAF.PERSON_ID = PPF.PERSON_ID
           AND PPOS.PERIOD_OF_SERVICE_ID = PAF.PERIOD_OF_SERVICE_ID
           AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE
                           AND PAF.EFFECTIVE_END_DATE
           AND PPPM.ASSIGNMENT_ID = PAF.ASSIGNMENT_ID
           AND PPPM.ORG_PAYMENT_METHOD_ID = POPM.ORG_PAYMENT_METHOD_ID
           AND POPM.ORG_PAYMENT_METHOD_NAME IN ('11-BANCOMER',
                                                '02-BANCOMER')
           AND NVL(PPOS.ADJUSTED_SVC_DATE, 
                   PPF.ORIGINAL_DATE_OF_HIRE) BETWEEN var_start_date
                                                  AND var_end_date                                        
         ORDER 
            BY TO_NUMBER(PPF.EMPLOYEE_NUMBER);
                
   
    BEGIN
        
        FOR employee IN EMPLOYEE_DETAILS LOOP
            
            var_line := '';
            var_line := var_line || UPPER(employee.FIRST_NAME) || ',';
            var_line := var_line || UPPER(employee.LAST_NAME) || ',';
            var_line := var_line || UPPER(employee.SECOND_LAST_NAME) || ',';
            var_line := var_line || UPPER(employee.DATE_BIRTH) || ',';
            var_line := var_line || UPPER(employee.MARITAL_STATUS) || ',';
            var_line := var_line || UPPER(employee.NATIONAL_IDENTIFIER) || ',';
            var_line := var_line || UPPER(employee.SEX) || ',';
            var_line := var_line || UPPER(employee.NATIONALITY) || ',';
            var_line := var_line || UPPER(employee.COUNTRY_OF_BIRTH) || ',';
            var_line := var_line || UPPER(employee.EMPLOYMENT) || ',';
            var_line := var_line || UPPER(employee.DATE_HIRE) || ',';
            var_line := var_line || UPPER(employee.STREET) || ',';
            var_line := var_line || UPPER(employee.INT_NUMBER) || ',';
            var_line := var_line || UPPER(employee.EXT_NUMBER) || ',';
            var_line := var_line || UPPER(employee.NEIGHBORHOOD) || ',';
            var_line := var_line || UPPER(employee.POSTAL_CODE) || ',';
            var_line := var_line || UPPER(employee.TOWN_OR_CITY) || ',';
            var_line := var_line || UPPER(employee.STATE) || ',';
            var_line := var_line || ',';
            var_line := var_line || ',';
            var_line := var_line || ',';
            var_line := var_line || ',';
            var_line := var_line || ',';
            var_line := var_line || ',';
            var_line := var_line || ',';
            var_line := var_line || ',';
            var_line := var_line || UPPER(employee.DEBIT_CARD) || ',';
            
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,var_line);
            FND_FILE.PUT_LINE(FND_FILE.LOG,var_line);
        
        END LOOP;
    
    END LAYOUT_BANCOMER;

END PAC_LAYOUT_BANCOMER_PKG;