SELECT DISTINCT 
       INFORME.PERSON_ID,
       INFORME.EMPLOYEE_NUMBER,
       INFORME.PAYROLL,
       INFORME.LAST_NAME,
       INFORME.FIRST_NAME,
       INFORME.REG_PATRONAL,
       SUM(INFORME.ABSENCE_DAYS)            AS  ABSENCE_DAYS,
       SUM(INFORME.PERMISSION_DAYS)         AS  PERMISSION_DAYS,
       SUM(INFORME.PERMISSION_PATERNITY)    AS  PERMISSION_PATERNITY,
       SUM(INFORME.SUSPENSION_DAYS)         AS  SUSPENSION_DAYS,
       SUM(INFORME.ABSENCE_DAYS         +
           INFORME.PERMISSION_DAYS      +
           INFORME.PERMISSION_PATERNITY +
           INFORME.SUSPENSION_DAYS)         AS  TOTAL_ABSENCES,
       TO_CHAR(PAAV.DATE_START, 'yyyy/mm/dd') AS DATE_START,
       TO_CHAR(PAAV.DATE_END, 'yyyy/mm/dd')   AS DATE_END,
       SUM(INFORME.INABILITY_RT_DAYS)       AS  INABILITY_RT_DAYS,
       SUM(INFORME.INABILITY_IG_DAYS)       AS  INABILITY_IG_DAYS,
       SUM(INFORME.INABILITY_IM_DAYS)       AS  INABILITY_IM_DAYS,
       SUM(INFORME.INABILITY_RT_DAYS    +
           INFORME.INABILITY_IG_DAYS    +
           INFORME.INABILITY_IM_DAYS)       AS  TOTAL_INABILITIES,
       TO_CHAR(PDF.REGISTRATION_DATE, 'yyyy/mm/dd')     AS  REGISTRATION_DATE,
       TO_CHAR(PDF.REGISTRATION_EXP_DATE, 'yyyy/mm/dd') AS  REGISTRATION_EXP_DATE
FROM(--------------------------------------------------------------------------
     ----           Consulta de Dias de Ausencias                           
     --------------------------------------------------------------------------
     SELECT DISTINCT
            PPF.PERSON_ID,
            PAPF.EMPLOYEE_NUMBER,       
            PAP.ATTRIBUTE1                                                                      AS PAYROLL,
            UPPER(TRIM(PAPF.LAST_NAME  || ' ' || 
                       PAPF.PER_INFORMATION1))                                                  AS LAST_NAME,
            UPPER(TRIM(PAPF.FIRST_NAME || ' ' || 
                       PAPF.MIDDLE_NAMES))                                                      AS FIRST_NAME,
            PAC_HR_PAY_PKG.GET_EMPLOYER_REGISTRATION(PAA.ASSIGNMENT_ID)                         AS REG_PATRONAL,
            PAAV.ABSENCE_ATTENDANCE_ID,
            (CASE 
                WHEN PAAV.C_TYPE_DESC = 'AUSENCIA' THEN
                    apps.PAC_GET_DISABILITIES_DAYS(PAAV.DATE_START, PAAV.DATE_END, :P_MONTH, :P_YEAR)
                ELSE
                    0
             END)                                                                               AS ABSENCE_DAYS,
            (CASE 
                WHEN PAAV.C_TYPE_DESC = 'PERMISO SIN GOCE DE SUELDO' THEN
                    apps.PAC_GET_DISABILITIES_DAYS(PAAV.DATE_START, PAAV.DATE_END, :P_MONTH, :P_YEAR)
                ELSE
                    0
             END)                                                                               AS PERMISSION_DAYS,
            (CASE 
                WHEN PAAV.C_TYPE_DESC = 'PERMISO POR PATERNIDAD' THEN
                    apps.PAC_GET_DISABILITIES_DAYS(PAAV.DATE_START, PAAV.DATE_END, :P_MONTH, :P_YEAR)
                ELSE
                    0
             END)                                                                               AS PERMISSION_PATERNITY,
            (CASE 
                WHEN PAAV.C_TYPE_DESC = 'SUSPENSIÓN' THEN
                    apps.PAC_GET_DISABILITIES_DAYS(PAAV.DATE_START, PAAV.DATE_END, :P_MONTH, :P_YEAR)
                ELSE
                    0
             END)                                                                               AS SUSPENSION_DAYS,
            NULL                                                                                AS DISABILITY_ID,
            0                                                                                   AS INABILITY_RT_DAYS,
            0                                                                                   AS INABILITY_IG_DAYS,
            0                                                                                   AS INABILITY_IM_DAYS
          FROM  PAY_ALL_PAYROLLS_F          PAP,
                PER_PERSON_TYPE_USAGES_F    PPTU,
                PER_PERIODS_OF_SERVICE      PPOS,
                PER_ALL_ASSIGNMENTS_F       PAA,   
                PER_PEOPLE_F                PPF,      
                PER_ALL_PEOPLE_F            PAPF,   
                PER_ABSENCE_ATTENDANCES_V   PAAV   
         WHERE 1 = 1
           AND PPF.PERSON_ID = PPTU.PERSON_ID
           AND PPF.PERSON_ID = PPOS.PERSON_ID
           AND PAA.PAYROLL_ID = PAP.PAYROLL_ID
           AND PAA.PERSON_ID = PPF.PERSON_ID
           AND PAPF.PERSON_ID = PPF.PERSON_ID
           AND (PPF.EFFECTIVE_START_DATE = PAPF.EFFECTIVE_START_DATE
            AND PPF.EFFECTIVE_START_DATE = PPTU.EFFECTIVE_START_DATE
            AND PPF.EFFECTIVE_START_DATE = PPOS.DATE_START) 
           AND PAA.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID
           AND SUBSTR(PAP.PAYROLL_NAME, 1, 2) = :P_COMPANY_ID 
           AND apps.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PAP.PAYROLL_NAME) =  NVL(:P_PERIOD_TYPE, apps.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PAP.PAYROLL_NAME))
           AND PAP.PAYROLL_ID = NVL(:P_PAYROLL_ID, PAP.PAYROLL_ID)
           AND PPF.REGISTERED_DISABLED_FLAG IS NULL
           AND PAAV.PERSON_ID = PPF.PERSON_ID
           AND EXTRACT(YEAR FROM PAAV.DATE_START) = :P_YEAR
           AND ((
                 EXTRACT(YEAR FROM PAAV.DATE_START) = :P_YEAR
             AND TO_CHAR(EXTRACT(MONTH FROM PAAV.DATE_START)) LIKE (TO_CHAR(:P_MONTH) || '%')                      
           ) OR (
                 EXTRACT(YEAR FROM PAAV.DATE_END) = :P_YEAR
             AND TO_CHAR(EXTRACT(MONTH FROM PAAV.DATE_END)) LIKE (TO_CHAR(:P_MONTH) || '%')
                 ))
           AND (PAAV.C_TYPE_DESC = 'AUSENCIA'
             OR PAAV.C_TYPE_DESC = 'PERMISO SIN GOCE DE SUELDO'
             OR PAAV.C_TYPE_DESC = 'PERMISO POR PATERNIDAD'
             OR PAAV.C_TYPE_DESC = 'SUSPENSIÓN') 
           AND SYSDATE BETWEEN PAA.EFFECTIVE_START_DATE AND PAA.EFFECTIVE_END_DATE
         GROUP BY PPF.PERSON_ID,
                  PAPF.EMPLOYEE_NUMBER,
                  PAP.ATTRIBUTE1,
                  PAPF.LAST_NAME,
                  PAPF.PER_INFORMATION1,
                  PAPF.FIRST_NAME,
                  PAPF.MIDDLE_NAMES,
                  PAA.ASSIGNMENT_ID,
                  PPTU.EFFECTIVE_START_DATE,
                  PPF.EFFECTIVE_START_DATE,
                  PAA.ASSIGNMENT_STATUS_TYPE_ID,
                  PPOS.ACTUAL_TERMINATION_DATE,
                  PAA.PERIOD_OF_SERVICE_ID,
                  PAAV.ABSENCE_ATTENDANCE_ID,
                  PAAV.C_TYPE_DESC,
                  PAAV.DATE_START,
                  PAAV.DATE_END
         UNION
     --------------------------------------------------------------------------
     ----           Consulta de Dias de Incapacidades                          
     --------------------------------------------------------------------------
        SELECT DISTINCT
               PPF.PERSON_ID,
               PAPF.EMPLOYEE_NUMBER,       
               PAP.ATTRIBUTE1                                                                      AS PAYROLL,
               UPPER(TRIM(PAPF.LAST_NAME  || ' ' || 
                          PAPF.PER_INFORMATION1))                                                  AS LAST_NAME,
               UPPER(TRIM(PAPF.FIRST_NAME || ' ' || 
                          PAPF.MIDDLE_NAMES))                                                      AS FIRST_NAME,
               PAC_HR_PAY_PKG.GET_EMPLOYER_REGISTRATION(PAA.ASSIGNMENT_ID)                         AS REG_PATRONAL,
               NULL                                                                                AS ABSENCE_ATTENDANCE_ID,
               0                                                                                   AS ABSENCE_DAYS,
               0                                                                                   AS PERMISSION_DAYS,
               0                                                                                   AS PERMISSION_PATERNITY,
               0                                                                                   AS SUSPENSION_DAYS,
               PDF.DISABILITY_ID,
               (CASE
                    WHEN PDF.CATEGORY = 'RT' THEN
                        PAC_GET_DISABILITIES_DAYS(PDF.REGISTRATION_DATE, PDF.REGISTRATION_EXP_DATE, :P_MONTH, :P_YEAR)
                    ELSE
                        0
                END)                                                                                   AS INABILITY_RT_DAYS,
               (CASE
                    WHEN PDF.CATEGORY = 'GRAL' THEN
                        PAC_GET_DISABILITIES_DAYS(PDF.REGISTRATION_DATE, PDF.REGISTRATION_EXP_DATE, :P_MONTH, :P_YEAR)
                    ELSE
                        0
                END)                                                                                   AS INABILITY_IG_DAYS,
               (CASE
                    WHEN PDF.CATEGORY = 'MAT' THEN
                        PAC_GET_DISABILITIES_DAYS(PDF.REGISTRATION_DATE, PDF.REGISTRATION_EXP_DATE, :P_MONTH, :P_YEAR)
                    ELSE
                        0
                END)                                                                                   AS INABILITY_IM_DAYS
          FROM  PAY_ALL_PAYROLLS_F          PAP,
                PER_PERSON_TYPE_USAGES_F    PPTU,
                PER_PERIODS_OF_SERVICE      PPOS,
                PER_ALL_ASSIGNMENTS_F       PAA,   
                PER_PEOPLE_F                PPF,      
                PER_ALL_PEOPLE_F            PAPF,
                PER_DISABILITIES_F          PDF    
         WHERE 1 = 1
           AND PPF.PERSON_ID = PPTU.PERSON_ID
           AND PPF.PERSON_ID = PPOS.PERSON_ID
           AND PAA.PAYROLL_ID = PAP.PAYROLL_ID
           AND PAA.PERSON_ID = PPF.PERSON_ID
           AND PAPF.PERSON_ID = PPF.PERSON_ID
           AND (PPF.EFFECTIVE_START_DATE = PAPF.EFFECTIVE_START_DATE
            AND PPF.EFFECTIVE_START_DATE = PPTU.EFFECTIVE_START_DATE
            AND PPF.EFFECTIVE_START_DATE = PPOS.DATE_START) 
           AND PAA.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID
           AND SUBSTR(PAP.PAYROLL_NAME, 1, 2) = :P_COMPANY_ID 
           AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PAP.PAYROLL_NAME) LIKE (:P_PERIOD_TYPE || '%')
           AND TO_CHAR(PAP.PAYROLL_ID) LIKE (TO_CHAR(:P_PAYROLL_ID) || '%')
           AND PPF.REGISTERED_DISABLED_FLAG IS NULL
           AND PDF.PERSON_ID = PPF.PERSON_ID
           AND (PDF.CATEGORY = 'RT'
             OR PDF.CATEGORY = 'GRAL'
             OR PDF.CATEGORY = 'MAT')
           AND ((
                 EXTRACT(YEAR FROM PDF.REGISTRATION_DATE) = :P_YEAR
             AND TO_CHAR(EXTRACT(MONTH FROM PDF.REGISTRATION_DATE)) LIKE (TO_CHAR(:P_MONTH) || '%')                      
           ) OR (
                 EXTRACT(YEAR FROM PDF.REGISTRATION_EXP_DATE) = :P_YEAR
             AND TO_CHAR(EXTRACT(MONTH FROM PDF.REGISTRATION_EXP_DATE)) LIKE (TO_CHAR(:P_MONTH) || '%')
                ))
           AND SYSDATE BETWEEN PAA.EFFECTIVE_START_DATE AND PAA.EFFECTIVE_END_DATE
         GROUP BY PPF.PERSON_ID,
                  PAPF.EMPLOYEE_NUMBER,
                  PAP.ATTRIBUTE1,
                  PAPF.LAST_NAME,
                  PAPF.PER_INFORMATION1,
                  PAPF.FIRST_NAME,
                  PAPF.MIDDLE_NAMES,
                  PAA.ASSIGNMENT_ID,
                  PPTU.EFFECTIVE_START_DATE,
                  PPF.EFFECTIVE_START_DATE,
                  PAA.ASSIGNMENT_STATUS_TYPE_ID,
                  PPOS.ACTUAL_TERMINATION_DATE,
                  PAA.PERIOD_OF_SERVICE_ID,
                  PDF.DISABILITY_ID,
                  PDF.REGISTRATION_DATE,
                  PDF.REGISTRATION_EXP_DATE,
                  PDF.CATEGORY
    )   INFORME
LEFT JOIN PER_ABSENCE_ATTENDANCES_V     PAAV    ON  (INFORME.PERSON_ID = PAAV.PERSON_ID 
                                                 AND INFORME.ABSENCE_ATTENDANCE_ID = PAAV.ABSENCE_ATTENDANCE_ID)
LEFT JOIN PER_DISABILITIES_F            PDF     ON  (INFORME.PERSON_ID = PDF.PERSON_ID
                                                 AND INFORME.DISABILITY_ID = PDF.DISABILITY_ID) 
GROUP BY INFORME.PERSON_ID,
         INFORME.EMPLOYEE_NUMBER,
         INFORME.PAYROLL,
         INFORME.LAST_NAME,
         INFORME.FIRST_NAME,
         INFORME.REG_PATRONAL,
         PAAV.DATE_START,
         PAAV.DATE_END,
         PDF.REGISTRATION_DATE,
         PDF.REGISTRATION_EXP_DATE
ORDER BY INFORME.LAST_NAME,
         INFORME.FIRST_NAME;