SELECT B.EMPLOYEE_NUMBER,
       B.FIRST_LAST_NAME,
       B.SECOND_LAST_NAME,
       B.NAMES,
       SUM(D080)    AS D080,
       SUM(D091)    AS D091
  FROM (SELECT PAPF.EMPLOYEE_NUMBER         AS  EMPLOYEE_NUMBER,
               PAPF.LAST_NAME               AS  FIRST_LAST_NAME,
               PAPF.PER_INFORMATION1        AS  SECOND_LAST_NAME,
               PAPF.FIRST_NAME  
               || ' ' ||
               PAPF.MIDDLE_NAMES            AS  NAMES,
               (CASE
                    WHEN PETF.ELEMENT_NAME = 'D080_FONDO AHORRO TRABAJADOR'
                    THEN PRRV.RESULT_VALUE
                    ELSE '0'
                END)                        AS  D080,
               (CASE
                    WHEN PETF.ELEMENT_NAME = 'D091_FONDO DE AHORRO EMPRESA'
                    THEN PRRV.RESULT_VALUE
                    ELSE '0'
                END)                        AS  D091
          FROM PAY_ELEMENT_TYPES_F          PETF
              ,PAY_ELEMENT_CLASSIFICATIONS  PEC
              ,PAY_RUN_RESULT_VALUES        PRRV
              ,PAY_INPUT_VALUES_F           PIVF
              ,PAY_RUN_RESULTS              PRR
              ,PAY_ASSIGNMENT_ACTIONS       PAA
              ,PAY_PAYROLL_ACTIONS          PPA
              ,PAY_ALL_PAYROLLS_F           PPF
              ,PER_ALL_ASSIGNMENTS_F        PAAF 
              ,PER_ALL_PEOPLE_F             PAPF
         WHERE 1 = 1
           AND PETF.CLASSIFICATION_ID = PEC.CLASSIFICATION_ID
           AND PRRV.INPUT_VALUE_ID = PIVF.INPUT_VALUE_ID 
           AND PRR.RUN_RESULT_ID = PRRV.RUN_RESULT_ID
           AND PRR.ELEMENT_TYPE_ID = PETF.ELEMENT_TYPE_ID
           AND PAA.ASSIGNMENT_ACTION_ID = PRR.ASSIGNMENT_ACTION_ID
           AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
           AND PAA.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
           AND PPA.PAYROLL_ID = PPF.PAYROLL_ID
           AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
           AND PAAF.PERSON_ID = PAPF.PERSON_ID
           AND PPA.DATE_EARNED BETWEEN PETF.EFFECTIVE_START_DATE
                                   AND PETF.EFFECTIVE_END_DATE
           AND PPA.DATE_EARNED BETWEEN PIVF.EFFECTIVE_START_DATE
                                   AND PIVF.EFFECTIVE_END_DATE
           AND PPA.DATE_EARNED BETWEEN PPF.EFFECTIVE_START_DATE
                                   AND PPF.EFFECTIVE_END_DATE
           AND PPA.DATE_EARNED BETWEEN PAAF.EFFECTIVE_START_DATE
                                   AND PAAF.EFFECTIVE_END_DATE
           AND PPA.DATE_EARNED BETWEEN PAPF.EFFECTIVE_START_DATE
                                   AND PAPF.EFFECTIVE_END_DATE
           AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, PAC_HR_PAY_PKG.GET_PERIOD_TYPE (PPF.PAYROLL_NAME))
           AND SUBSTR(PPF.PAYROLL_NAME,1,2) = :P_COMPANY_ID
           AND PPA.DATE_EARNED BETWEEN :var_start_date
                                   AND :var_end_date
           AND PPA.ACTION_TYPE IN ('Q', 'R')
           AND PIVF.NAME = 'Pay Value'
           AND PETF.ELEMENT_NAME IN ('D080_FONDO AHORRO TRABAJADOR', 'D091_FONDO DE AHORRO EMPRESA')
       ) B            
 GROUP
    BY B.EMPLOYEE_NUMBER,
       B.FIRST_LAST_NAME,
       B.SECOND_LAST_NAME,
       B.NAMES
 ORDER 
    BY B.EMPLOYEE_NUMBER;
            
                   