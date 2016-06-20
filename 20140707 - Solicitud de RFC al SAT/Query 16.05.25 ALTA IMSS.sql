                     SELECT DISTINCT
                            PAPF.PERSON_ID                                              AS  PERSON_ID,                           
                            PAPF.PER_INFORMATION2                                       AS  RFC,
                            PAPF.NATIONAL_IDENTIFIER                                    AS  CURP,
                            PAPF.LAST_NAME                                              AS  AP_PATERNO,
                            PAPF.PER_INFORMATION1                                       AS  AP_MATERNO,
                            PAPF.FIRST_NAME || ' ' || PAPF.MIDDLE_NAMES                 AS  NOMBRES,
                            TO_CHAR(NVL(PPOS.ADJUSTED_SVC_DATE, 
                                        PAPF.ORIGINAL_DATE_OF_HIRE) , 'DD/MM/RRRR')     AS  FECHA,
                           (SELECT DISTINCT
                                INFORMATION.ORG_INFORMATION2
                            FROM FND_LOOKUP_VALUES                     COMPANY     
                            INNER JOIN HR_ORGANIZATION_UNITS_V         ORGANIZATIONS    ON COMPANY.MEANING = ORGANIZATIONS.NAME
                            INNER JOIN HR_ORGANIZATION_INFORMATION     INFORMATION      ON INFORMATION.ORGANIZATION_ID = ORGANIZATIONS.ORGANIZATION_ID
                            WHERE COMPANY.lookup_type= 'NOMINAS POR EMPLEADOR LEGAL'
                              AND COMPANY.lookup_code = :P_COMPANY_ID
                              AND INFORMATION.ORG_INFORMATION_CONTEXT = 'MX_TAX_REGISTRATION')  AS RFC_COMPANIA,
                           (PEEVF.SCREEN_ENTRY_VALUE / 30)                              AS  SALARIO_DIARIO                              
                          FROM PER_ALL_PEOPLE_F             PAPF,
                               PER_ALL_ASSIGNMENTS_F        PAAF, 
                               PAY_PAYROLLS_F               PPF,     
                               PER_PERSON_TYPE_USAGES_F     PPTUF,
                               PER_PERIODS_OF_SERVICE       PPOS,
                               PAY_ELEMENT_ENTRIES_F        PEEF,     
                               PAY_ELEMENT_TYPES_F          PETF,
                               PAY_ELEMENT_ENTRY_VALUES_F   PEEVF,
                               PAY_INPUT_VALUES_F           PIVF
                         WHERE 1 = 1
                           AND PAPF.PERSON_ID = PAAF.PERSON_ID
                           AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
                           AND PPTUF.PERSON_ID = PAPF.PERSON_ID
                           AND PPOS.PERSON_ID= PAPF.PERSON_ID 
                           AND SUBSTR(PPF.PAYROLL_NAME, 1, 2) = NVL(:P_COMPANY_ID, SUBSTR(PPF.PAYROLL_NAME, 1, 2)) 
                           AND PPF.PAYROLL_ID = NVL(:P_PAYROLL_ID, PPF.PAYROLL_ID)   
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN :P_START_DATE AND :P_END_DATE   
                           AND PAAF.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID
                           AND PEEF.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
                           AND PEEF.ELEMENT_TYPE_ID = PETF.ELEMENT_TYPE_ID
                           AND PETF.ELEMENT_NAME = 'P001_SUELDO NORMAL'
                           AND PEEVF.ELEMENT_ENTRY_ID = PEEF.ELEMENT_ENTRY_ID
                           AND PIVF.ELEMENT_TYPE_ID = PETF.ELEMENT_TYPE_ID
                           AND PIVF.INPUT_VALUE_ID = PEEVF.INPUT_VALUE_ID
                           AND PIVF.NAME = 'Rate'
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PEEF.EFFECTIVE_START_DATE AND PEEF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PEEVF.EFFECTIVE_START_DATE AND PEEVF.EFFECTIVE_END_DATE
                           AND NVL(PPOS.ADJUSTED_SVC_DATE, PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
                           AND PAPF.PERSON_ID IN (17397, 15837, 11675)
                         ORDER BY PAPF.NATIONAL_IDENTIFIER
