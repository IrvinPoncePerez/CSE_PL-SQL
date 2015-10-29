SELECT 
    PPPM.ATTRIBUTE1                                                                AS  NUM_CUENTA,
    PAP.EMPLOYEE_NUMBER                                                            AS  NUM_EMPLEADO,
    (PAP.FIRST_NAME || ' ' || PAP.MIDDLE_NAMES)                                    AS  NOMBRES,
    PAP.LAST_NAME                                                                  AS  AP_PATERNO,
    PAP.PER_INFORMATION1                                                           AS  AP_MATERNO,
    REPLACE(PAP.PER_INFORMATION2, '-' , '')                                        AS  RFC,
    PAP.NATIONAL_IDENTIFIER                                                        AS  CURP,
    TRIM(TO_CHAR(REPLACE(NVL(PAP.PER_INFORMATION3, '0'), '-', ''), '00000000000')) AS  NUM_SEGURO
  FROM PER_ALL_PEOPLE_F                     PAP,
       PER_ALL_ASSIGNMENTS_F                PAA,
       PAY_PAYROLLS_F                       PP,
       PAY_PERSONAL_PAYMENT_METHODS_F       PPPM,
       PER_PERSON_TYPE_USAGES_F             PPTU,
       PER_PERIODS_OF_SERVICE               PPS
 WHERE 1 = 1
   AND PAP.PERSON_ID = PAA.PERSON_ID
   AND PAA.PAYROLL_ID = PP.PAYROLL_ID
   AND PAA.ASSIGNMENT_ID = PPPM.ASSIGNMENT_ID
   AND SUBSTR(PP.PAYROLL_NAME, 1, 2) = P_COMPANY_ID
   AND PAP.PERSON_ID = PPTU.PERSON_ID
   AND (PPTU.EFFECTIVE_START_DATE BETWEEN var_start_date AND var_end_date)
   AND PAP.PERSON_ID = PPS.PERSON_ID
   AND PPPM.ORG_PAYMENT_METHOD_ID = P_PAYMENT_METHOD_ID
   AND (PAP.EFFECTIVE_START_DATE = PPTU.EFFECTIVE_START_DATE
    AND PAP.EFFECTIVE_START_DATE = PPS.DATE_START)
   AND PPS.ACTUAL_TERMINATION_DATE IS NULL
   AND PAA.PERIOD_OF_SERVICE_ID = PPS.PERIOD_OF_SERVICE_ID
   AND PPPM.OBJECT_VERSION_NUMBER = (SELECT MAX(PPPM1.OBJECT_VERSION_NUMBER)
                                       FROM PAY_PERSONAL_PAYMENT_METHODS_F  PPPM1
                                      WHERE PPPM1.PERSONAL_PAYMENT_METHOD_ID = PPPM.PERSONAL_PAYMENT_METHOD_ID);

   