SELECT PPF.PERSON_ID                                                    AS  "PERSON_ID",
       PPF.EMPLOYEE_NUMBER                                              AS  "EMPLOYEE_NUMBER",
       PPF.FULL_NAME                                                    AS  "EMPLOYEE_NAME",
       UPPER(PPTT.USER_PERSON_TYPE)                                     AS  "PERSON_TYPE",
       TRUNC(HR_MX_UTILITY.GET_SENIORITY_SOCIAL_SECURITY(PPF.PERSON_ID, 
                                                         SYSDATE))      AS  "SENIORITY_YEARS",
       PPF.PER_INFORMATION2                                             AS  "RFC",
       PPF.NATIONAL_IDENTIFIER                                          AS  "CURP",
       UPPER(PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('SEX', 
                                               PPF.SEX))                AS  "SEX",
       PPF.EMAIL_ADDRESS                                                AS  "EMAIL_ADDRESS",
       PAC_RESULT_VALUES_PKG.GET_EFFECTIVE_START_DATE(PPF.PERSON_ID)    AS  "FFECTIVE_START_DATE",
       PPOS.ACTUAL_TERMINATION_DATE                                     AS  "EFFECTIVE_END_DATE",
       TO_CHAR(SYSDATE, 'DD/MM/YYYY')                                   AS  "REGISTRATION_DATE",
       'N'                                                              AS  "IS_SAVER",
       'N'                                                              AS  "IS_BORROWER",
       'N'                                                              AS  "IS_ENDORSEMENT"
  FROM PER_PEOPLE_F             PPF,
       PER_PERSON_TYPES_TL      PPTT,
       PER_ASSIGNMENTS_F        PAF,
       PER_PERIODS_OF_SERVICE   PPOS
 WHERE 1 = 1
   AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
   AND PPF.PERSON_TYPE_ID = PPTT.PERSON_TYPE_ID
   AND LANGUAGE = USERENV('LANG')
   AND PPTT.USER_PERSON_TYPE IN ('Employee', 'Empleado')
   AND PPF.PERSON_ID = PAF.PERSON_ID
   AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
   AND PPOS.PERSON_ID = PPF.PERSON_ID
   AND PPOS.PERIOD_OF_SERVICE_ID = PAF.PERIOD_OF_SERVICE_ID
 ORDER BY TO_NUMBER(PPF.EMPLOYEE_NUMBER);   