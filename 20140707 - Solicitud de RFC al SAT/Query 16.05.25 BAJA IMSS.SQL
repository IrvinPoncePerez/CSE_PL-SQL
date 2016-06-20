                     SELECT DISTINCT
                            PAPF.PERSON_ID                                              AS  PERSON_ID,                           
                            PAPF.PER_INFORMATION2                                       AS  RFC,
                            PAPF.NATIONAL_IDENTIFIER                                    AS  CURP,
                            PAPF.LAST_NAME                                              AS  AP_PATERNO,
                            PAPF.PER_INFORMATION1                                       AS  AP_MATERNO,
                            PAPF.FIRST_NAME || ' ' || PAPF.MIDDLE_NAMES                 AS  NOMBRES,
                            TO_CHAR(PPOS.ACTUAL_TERMINATION_DATE, 'DD/MM/RRRR')      AS  FECHA,
                              (SELECT DISTINCT
                                    INFORMATION.ORG_INFORMATION2
                                FROM FND_LOOKUP_VALUES                     COMPANY     
                                INNER JOIN HR_ORGANIZATION_UNITS_V         ORGANIZATIONS    ON COMPANY.MEANING = ORGANIZATIONS.NAME
                                INNER JOIN HR_ORGANIZATION_INFORMATION     INFORMATION      ON INFORMATION.ORGANIZATION_ID = ORGANIZATIONS.ORGANIZATION_ID
                                WHERE COMPANY.lookup_type= 'NOMINAS POR EMPLEADOR LEGAL'
                                  AND COMPANY.lookup_code = :P_COMPANY_ID
                                  AND INFORMATION.ORG_INFORMATION_CONTEXT = 'MX_TAX_REGISTRATION')  AS RFC_COMPANIA
                          FROM PER_ALL_PEOPLE_F             PAPF,  
                               PER_ALL_ASSIGNMENTS_F        PAAF, 
                               PAY_PAYROLLS_F               PPF,      
                               PER_PERIODS_OF_SERVICE_V     PPOS      
                         WHERE 1 = 1
                           AND PAPF.PERSON_ID = PAAF.PERSON_ID
                           AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
                           AND PPOS.PERSON_ID= PAPF.PERSON_ID 
                           AND SUBSTR(PPF.PAYROLL_NAME, 1, 2) = :P_COMPANY_ID
                           AND PPF.PAYROLL_ID = NVL(:P_PAYROLL_ID, PPF.PAYROLL_ID)  
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN :P_START_DATE AND :P_END_DATE   
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
                           AND PAAF.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID
                           AND PPOS.ACTUAL_TERMINATION_DATE IS NOT NULL
                         ORDER BY PAPF.NATIONAL_IDENTIFIER;