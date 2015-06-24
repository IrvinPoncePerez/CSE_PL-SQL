SELECT DISTINCT
                            PEOPLE.PERSON_ID                                            AS  PERSON_ID,                           
                            ALL_PEOPLE.PER_INFORMATION2                                 AS  RFC,
                            ALL_PEOPLE.NATIONAL_IDENTIFIER                              AS  CURP,
                            ALL_PEOPLE.LAST_NAME                                        AS  AP_PATERNO,
                            ALL_PEOPLE.PER_INFORMATION1                                 AS  AP_MATERNO,
                            ALL_PEOPLE.FIRST_NAME || ' ' || ALL_PEOPLE.MIDDLE_NAMES   AS  NOMBRES,
                            RVALUES.RESULT_VALUE                                        AS  SALARIO_DIARIO,
                            TO_CHAR(PERIODS.ACTUAL_TERMINATION_DATE, 'DD/MM/RRRR')    AS  FECHA,
                              (SELECT DISTINCT
                                    INFORMATION.ORG_INFORMATION2
                                FROM FND_LOOKUP_VALUES                     COMPANY     
                                INNER JOIN HR_ORGANIZATION_UNITS_V         ORGANIZATIONS    ON COMPANY.MEANING = ORGANIZATIONS.NAME
                                INNER JOIN HR_ORGANIZATION_INFORMATION     INFORMATION      ON INFORMATION.ORGANIZATION_ID = ORGANIZATIONS.ORGANIZATION_ID
                                WHERE COMPANY.lookup_type= 'NOMINAS POR EMPLEADOR LEGAL'
                                  AND COMPANY.lookup_code = :P_COMPANY_ID
                                  AND INFORMATION.ORG_INFORMATION_CONTEXT = 'MX_TAX_REGISTRATION')  AS RFC_COMPANIA
                          FROM PER_PEOPLE_F                 PEOPLE,
                               PER_ALL_PEOPLE_F             ALL_PEOPLE,  
                               PER_ALL_ASSIGNMENTS_F        ASSIGNMENTS, 
                               PAY_PAYROLLS_F               PAYROLL,     
                               PAY_PAYROLL_ACTIONS          PACTIONS,    
                               PAY_ASSIGNMENT_ACTIONS       ACTIONS,     
                               PAY_RUN_RESULTS              RESULTS,     
                               PAY_RUN_RESULT_VALUES        RVALUES,     
                               PAY_ELEMENT_TYPES_F          ELEMENTT,    
                               PER_PERIODS_OF_SERVICE_V     PERIODS      
                         WHERE 1 = 1
                           AND PEOPLE.PERSON_ID = ALL_PEOPLE.PERSON_ID
                           AND PEOPLE.PERSON_ID = ASSIGNMENTS.PERSON_ID
                           AND PAYROLL.PAYROLL_ID = ASSIGNMENTS.PAYROLL_ID
                           AND PACTIONS.PAYROLL_ID = PAYROLL.PAYROLL_ID
                           AND ACTIONS.ASSIGNMENT_ID = ASSIGNMENTS.ASSIGNMENT_ID
                           AND ACTIONS.ASSIGNMENT_ACTION_ID = RESULTS.ASSIGNMENT_ACTION_ID
                           AND RESULTS.RUN_RESULT_ID = RVALUES.RUN_RESULT_ID
                           AND RESULTS.ELEMENT_TYPE_ID = ELEMENTT.ELEMENT_TYPE_ID
                           AND PERIODS.PERSON_ID = PEOPLE.PERSON_ID   
                           AND ELEMENTT.ELEMENT_NAME = 'I001_SALARIO_DIARIO'
                           AND SUBSTR(PAYROLL.PAYROLL_NAME, 1, 2) = :P_COMPANY_ID
                           AND PAYROLL.PAYROLL_ID = NVL(:P_PAYROLL_ID, PAYROLL.PAYROLL_ID)
                           AND PACTIONS.CONSOLIDATION_SET_ID = NVL(:P_CONSOLIDATION_ID, PACTIONS.CONSOLIDATION_SET_ID) 
                           AND PERIODS.ACTUAL_TERMINATION_DATE BETWEEN :P_START_DATE AND :P_END_DATE
                           AND (PEOPLE.EFFECTIVE_START_DATE = ALL_PEOPLE.EFFECTIVE_START_DATE
                            AND PEOPLE.EFFECTIVE_START_DATE = PERIODS.DATE_START)
                           AND ASSIGNMENTS.PERIOD_OF_SERVICE_ID = PERIODS.PERIOD_OF_SERVICE_ID
                           AND PERIODS.ACTUAL_TERMINATION_DATE IS NOT NULL
                         ORDER BY ALL_PEOPLE.PER_INFORMATION2