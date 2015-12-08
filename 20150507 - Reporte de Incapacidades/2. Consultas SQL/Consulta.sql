 ALTER SESSION SET NLS_LANGUAGE = 'LATIN AMERICAN SPANISH';

SELECT PPF.PAYROLL_ID,
       (CASE
            WHEN PPF.PERIOD_TYPE = 'Week' OR PPF.PERIOD_TYPE = 'Semana' THEN 'S'
            WHEN PPF.PERIOD_TYPE = 'Semi-Month' OR PPF.PERIOD_TYPE = 'Quincena' THEN 'Q'
        END)                            AS  "PERIOD_TYPE",
       PPF.PAYROLL_NAME                 AS  "PAYROLL_NAME",
       PAAF.ORGANIZATION_ID,             
       HAOU.NAME                        AS  "ORGANIZATION_NAME",
       PAPF.PERSON_ID,
       PAPF.EMPLOYEE_NUMBER             AS  "EMPLOYEE_NUMBER",
       PAPF.FULL_NAME                   AS  "EMPLOYEE_NAME",
       PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('EMPLOYEE_CATG', PAAF.EMPLOYEE_CATEGORY) AS  "EMPLOYEE_CATEGORY",
       PAPF.EFFECTIVE_START_DATE        AS  "EFFECTIVE_DATE",
       PDF.CATEGORY,
       PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('DISABILITY_CATEGORY', PDF.CATEGORY)     AS  "CATEGORY_DISABILITY",
       PDF.REGISTRATION_DATE            AS  "START_DATE",
       PDF.REGISTRATION_EXP_DATE        AS  "END_DATE",
       PDF.DIS_INFORMATION2             AS  "DAYS",
       PDF.DIS_INFORMATION1             AS  "DISABILITY_ID",
       PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('MX_DISABILITIES', PDF.DIS_INFORMATION3) AS  "DISABILITY_TYPE",
       PDF.DIS_INFORMATION3,
       (CASE
            WHEN PDF.DIS_INFORMATION3 = 3 THEN
                PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('HR_MX_DISABILITY_CTL_MATERNITY', PDF.DIS_INFORMATION5)          
            WHEN PDF.DIS_INFORMATION3 = 2 THEN
                PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('HR_MX_DISABILITY_CTL_GENERAL', PDF.DIS_INFORMATION5)
            WHEN PDF.DIS_INFORMATION3 = 1 THEN
                PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('HR_MX_DISABILITY_CONTROL', PDF.DIS_INFORMATION5)
        END)                               AS  "DISABILITY_CONTROL",
       (CASE
            WHEN PDF.DIS_INFORMATION3 = 1 THEN
                PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('DISABILITY_REASON', PDF.REASON)
        END)                               AS  "RISK_INCIDENT",
       (CASE
            WHEN PDF.DIS_INFORMATION3 = 1 THEN
                PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('HR_MX_DISABILITY_CONSEQUENCE', PDF.DIS_INFORMATION4)
            ELSE
                PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('HR_MX_DISABILITY_CONSEQUENCE', PDF.DIS_INFORMATION4)
        END)                                                                      AS  "CONSEQUENCE", 
       PAC_HR_PAY_PKG.GET_EMPLOYER_REGISTRATION(PAAF.ASSIGNMENT_ID)               AS  "EMPLOYEER_REGISTRATION"
  FROM PAY_PAYROLLS_F               PPF,
       PER_ALL_ASSIGNMENTS_F        PAAF,
       HR_ALL_ORGANIZATION_UNITS    HAOU,
       PER_ALL_PEOPLE_F             PAPF,
       PER_DISABILITIES_F           PDF
 WHERE 1 = 1
   AND SUBSTR(PPF.PAYROLL_NAME, 1, 2) = :P_COMPANY_ID
   AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
   AND PPF.PAYROLL_ID = NVL(:P_PAYROLL_ID, PPF.PAYROLL_ID)
   AND PPF.PAYROLL_ID = PAAF.PAYROLL_ID
   AND PAAF.ORGANIZATION_ID = HAOU.ORGANIZATION_ID
   AND PAAF.ORGANIZATION_ID = NVL(:P_ORGANIZATION_ID, PAAF.ORGANIZATION_ID)
   AND PAAF.PERSON_ID = PAPF.PERSON_ID
   AND PAPF.PERSON_ID = NVL(:P_PERSON_ID, PAPF.PERSON_ID)
   AND PDF.PERSON_ID = PAPF.PERSON_ID
   AND PDF.CATEGORY = NVL(:P_CATEGORY_DISABILITY, PDF.CATEGORY)
   AND PDF.DIS_INFORMATION3 IS NOT NULL
   AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
   AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
   AND (   :CP_START_DATE BETWEEN PDF.REGISTRATION_DATE AND PDF.REGISTRATION_EXP_DATE   
        OR :CP_END_DATE BETWEEN PDF.REGISTRATION_DATE AND PDF.REGISTRATION_EXP_DATE
        OR PDF.REGISTRATION_DATE BETWEEN :CP_START_DATE AND :CP_END_DATE
        OR PDF.REGISTRATION_EXP_DATE BETWEEN :CP_START_DATE AND :CP_END_DATE)
--   AND PAPF.EMPLOYEE_NUMBER IN (832)
 ORDER BY PERIOD_TYPE,
          PAYROLL_NAME,
          EMPLOYEE_NAME,
          START_DATE;   