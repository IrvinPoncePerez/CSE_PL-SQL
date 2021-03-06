ALTER SESSION SET CURRENT_SCHEMA=APPS;


SELECT DISTINCT
       PE.ORGANIZATION_NUMBER,
       PE.EMPLOYEE_NUMBER,
       PE.EMPLOYEE_NAME,
       PE.TIMECLOCK_DATE,
       PE.TIMECLOCK_DAY,
       PTC.TIME_STAMP,
       apps.TIMECLOCK_PKG.TIMECLOCK_ABSENCE_DESC(PE.PERSON_ID, PE.TIMECLOCK_DATE)           AS  ABSENCE_DESC,
       apps.TIMECLOCK_PKG.TIMECLOCK_FORMAT_HOUR(PTC.TIME_STAMP) || '-' || REPLACE(FUV.USER_NAME, 'ENTRAL', '')  AS  CHECK_HOUR,
       apps.TIMECLOCK_PKG.TIMECLOCK_HAS_DELAY(PTC.TIME_STAMP)                               AS  IS_DELAY,
       apps.TIMECLOCK_PKG.GET_BONUS(PE.PERSON_ID, :var_start_date, :var_end_date)           AS  DESC_BONUS,
       'ENTRADAS/SALIDAS'                                                                   AS  HEADER_COLUMN
  FROM (SELECT DISTINCT
               SUBSTR(APPS.PAC_HR_PAY_PKG.GET_DEPARTMENT_NUMBER(PAAF.ORGANIZATION_ID),1,4)  AS  "ORGANIZATION_NUMBER",
               PAPF.EMPLOYEE_NUMBER                 AS  "EMPLOYEE_NUMBER",
               UPPER(TRIM(PAPF.LAST_NAME          || ' ' ||
                          PAPF.PER_INFORMATION1)  || ' ' || 
                     TRIM(PAPF.FIRST_NAME         || ' ' ||
                          PAPF.MIDDLE_NAMES))       AS  "EMPLOYEE_NAME",
               TDT.TIMECLOCK_DATE,
               TDT.TIMECLOCK_DAY,
               PAPF.PERSON_ID,
               PPF.PAYROLL_ID,
               PAAF.ORGANIZATION_ID               
          FROM PER_ALL_PEOPLE_F             PAPF,
               PER_PERIODS_OF_SERVICE       PPOS,
               PER_ALL_ASSIGNMENTS_F        PAAF,
               PAY_PAYROLLS_F               PPF,
               (SELECT * 
                  FROM apps.TIMECLOCK_DATES_TB
                 ORDER BY TIMECLOCK_DATE)   TDT
         WHERE 1 = 1
           AND PAPF.CURRENT_EMPLOYEE_FLAG = 'Y'
           AND PAPF.PERSON_ID = NVL(:P_PERSON_ID, PAPF.PERSON_ID)                   --@param P_PERSON_ID
           AND PAPF.PERSON_ID = PPOS.PERSON_ID
--           AND PAPF.EFFECTIVE_START_DATE = PPOS.DATE_START
           AND PAPF.PERSON_ID = PAAF.PERSON_ID
           AND PPOS.PERIOD_OF_SERVICE_ID = PAAF.PERIOD_OF_SERVICE_ID
           AND (PAPF.EFFECTIVE_END_DATE = PAAF.EFFECTIVE_END_DATE)
           AND PAAF.ORGANIZATION_ID = NVL(:P_ORGANIZATION_ID, PAAF.ORGANIZATION_ID) --@param P_ORGANIZATION_ID
           AND PPF.PAYROLL_ID = PAAF.PAYROLL_ID
           AND SUBSTR(PPF.PAYROLL_NAME, 1, 2) = :P_COMPANY_ID
           AND apps.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = :P_PERIOD_TYPE
           AND PPF.PAYROLL_ID = NVL(:P_PAYROLL_ID, PPF.PAYROLL_ID)                  --@param P_PAYROLL_ID
           AND PAPF.CURRENT_EMPLOYEE_FLAG = TDT.IDENTIFY
           AND (PPOS.ACTUAL_TERMINATION_DATE IS NULL
             OR PPOS.ACTUAL_TERMINATION_DATE BETWEEN :var_start_date AND :var_end_date)            
      )     PE
  LEFT JOIN PAC_TIMECLOCK_CHECKS    PTC     ON PTC.EMPLOYEE_ID = PE.PERSON_ID AND PTC.CHECK_DAY = PE.TIMECLOCK_DATE
  LEFT JOIN apps.FND_USER_VIEW           FUV     ON FUV.USER_ID = PTC.CREATED_BY
 ORDER BY   TO_NUMBER(ORGANIZATION_NUMBER),
            TO_NUMBER(EMPLOYEE_NUMBER),
            TIMECLOCK_DATE,
            PTC.TIME_STAMP;