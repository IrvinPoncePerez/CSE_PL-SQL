SELECT DTL.PERIOD_TYPE,
       DTL.PAYROLL,
       DTL.EMPLOYEE_NUMBER,
       DTL.EMPLOYEE_NAME,
       DTL.EMPLOYEE_AP,
       DTL.EMPLOYEE_AM,
       DTL.EMPLOYEE_NSS,
       DTL.EMPLOYEE_CURP,
       DTL.POSITION_NUMBER,
       DTL.POSITION_NAME,
       PAC_RESULT_VALUES_PKG.GET_EMPLOYEER_REGISTRATION(DTL.EFFECTIVE_START_DATE,
                                                        DTL.ASSIGNMENT_ID)  AS  "BREAK",
       PAC_RESULT_VALUES_PKG.GET_EMPLOYEER_REGISTRATION(DTL.EFFECTIVE_START_DATE,
                                                        DTL.ASSIGNMENT_ID)  AS  "REG_PATRONAL",
       DTL.EFFECTIVE_START_DATE,
       DTL.EFFECTIVE_END_DATE,
       (CASE
            WHEN DT.TYPE_MOVEMENT = 'B' THEN 'CA'
            ELSE 'RE'
        END)            AS  PERSON_TYPE,
       DT.EFFECTIVE_DATE,
       DT.TYPE_MOVEMENT
  FROM (SELECT DISTINCT
               (CASE
                    WHEN PPF.PERIOD_TYPE IN ('Week', 'Semana') THEN 'S'
                    WHEN PPF.PERIOD_TYPE IN ('Semi-Month', 'Quincena') THEN 'Q'
                END)                                    AS  "PERIOD_TYPE",
               PPF.ATTRIBUTE1                           AS  "PAYROLL",
               PAPF.EMPLOYEE_NUMBER                     AS  "EMPLOYEE_NUMBER",
               TRIM(PAPF.FIRST_NAME || ' ' ||
                    NVL(PAPF.MIDDLE_NAMES, ' '))        AS  "EMPLOYEE_NAME",
               PAPF.LAST_NAME                           AS  "EMPLOYEE_AP",
               PAPF.PER_INFORMATION1                    AS  "EMPLOYEE_AM",
               PAPF.PER_INFORMATION3                    AS  "EMPLOYEE_NSS",
               PAPF.NATIONAL_IDENTIFIER                 AS  "EMPLOYEE_CURP",
               PPD.SEGMENT2                             AS  "POSITION_NUMBER",
               PPD.SEGMENT1                             AS  "POSITION_NAME",
               NVL(PPOS.ADJUSTED_SVC_DATE, 
                   PAPF.ORIGINAL_DATE_OF_HIRE)          AS  "EFFECTIVE_START_DATE",
               PAPF.EFFECTIVE_END_DATE                  AS  "EFFECTIVE_END_DATE",
               PAPF.PERSON_ID,
               PAAF.ASSIGNMENT_ID
          FROM PAY_PAYROLLS_F           PPF,
               PER_ALL_ASSIGNMENTS_F    PAAF,
               PER_ALL_PEOPLE_F         PAPF,
               PER_PERIODS_OF_SERVICE   PPOS,
               HR_ALL_POSITIONS_F       PAPO,
               PER_POSITION_DEFINITIONS PPD,
               PER_PERSON_TYPES         PPT
         WHERE 1 = 1
           AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
           AND PAPF.PERSON_ID = PAAF.PERSON_ID
           AND PAPF.PERSON_ID = PPOS.PERSON_ID
           AND (   (PAPF.EMPLOYEE_NUMBER IS NULL)
                OR (    PAPF.EMPLOYEE_NUMBER IS NOT NULL
                    AND PPOS.DATE_START =
                          (SELECT MAX (PPS1.DATE_START)
                             FROM PER_PERIODS_OF_SERVICE PPS1
                            WHERE PPS1.PERSON_ID = PAPF.PERSON_ID
                              AND PPS1.DATE_START <= PAPF.EFFECTIVE_END_DATE)
                   )
               )
           AND PAAF.EFFECTIVE_END_DATE = PAPF.EFFECTIVE_END_DATE
           AND PAPO.POSITION_ID = PAAF.POSITION_ID
           AND PAPO.POSITION_DEFINITION_ID = PPD.POSITION_DEFINITION_ID
           AND PAPF.PERSON_TYPE_ID = PPT.PERSON_TYPE_ID
           AND PPF.ATTRIBUTE1 NOT IN ('GRBE', 'GRQE')
           AND SUBSTR(PPF.PAYROLL_NAME, 1, 2) = :P_COMPANY_ID
           AND apps.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, apps.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))    
           AND PPF.PAYROLL_ID = NVL(:P_PAYROLL_ID,  PPF.PAYROLL_ID)
           AND PAPF.EMPLOYEE_NUMBER = NVL(:P_EMPLOYEE_NUMBER, PAPF.EMPLOYEE_NUMBER)
           AND PPT.USER_PERSON_TYPE IN ('Employee', 'Empleado')
           AND PAPF.EFFECTIVE_END_DATE >= :CP_START_DATE 
           AND PAPF.EFFECTIVE_START_DATE <= :CP_END_DATE) DTL
  LEFT JOIN (SELECT PPTU.PERSON_ID                   AS "PERSON_ID",
                    'A'                              AS "TYPE_MOVEMENT",
                    PPTU.EFFECTIVE_START_DATE        AS "EFFECTIVE_DATE"
               FROM PER_PERSON_TYPE_USAGES_F   PPTU,
                    PER_PERIODS_OF_SERVICE     PPOS
              WHERE PPTU.PERSON_ID = PPOS.PERSON_ID
                AND PPTU.EFFECTIVE_START_DATE = PPOS.DATE_START
                AND PPTU.EFFECTIVE_START_DATE BETWEEN :CP_START_DATE AND :CP_END_DATE
                AND (   PPOS.ACTUAL_TERMINATION_DATE IS NULL
                     OR PPOS.ACTUAL_TERMINATION_DATE >= :CP_END_DATE)
              UNION
             SELECT PPTU.PERSON_ID                   AS "PERSON_ID",
                    'B'                              AS "TYPE_MOVEMENT",
                    PPOS.ACTUAL_TERMINATION_DATE     AS "EFFECTIVE_DATE"
               FROM PER_PERSON_TYPE_USAGES_F   PPTU,
                    PER_PERIODS_OF_SERVICE     PPOS
              WHERE PPTU.PERSON_ID = PPOS.PERSON_ID 
                AND PPTU.EFFECTIVE_START_DATE = PPOS.DATE_START
                AND PPOS.ACTUAL_TERMINATION_DATE BETWEEN :CP_START_DATE AND :CP_END_DATE
                AND PPOS.ACTUAL_TERMINATION_DATE IS NOT NULL) DT
       ON DTL.PERSON_ID = DT.PERSON_ID
 WHERE 1 = 1      
 ORDER BY REG_PATRONAL,
          TO_NUMBER(EMPLOYEE_NUMBER); 