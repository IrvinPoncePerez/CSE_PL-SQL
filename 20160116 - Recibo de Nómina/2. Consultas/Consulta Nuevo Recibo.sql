
--ALTER SESSION SET NLS_LANGUAGE = 'LATIN AMERICAN SPANISH';
SELECT DISTINCT
       D.COMPANY_NAME,
       D.COMPANY_RFC,
       D.PERIOD_TYPE,
       D.PERIOD_NUM,
       D.PAYMENT_TYPE_NAME,
       D.EMPLOYEE_NUMBER,
       D.EMPLOYEE_NAME,
       D.EMPLOYEE_RFC,
       D.EMPLOYEE_NSS,
       D.EMPLOYER_REGISTRATION,
       D.EMPLOYEE_CURP,
       D.EMPLOYEE_IDW,
       D.SALARY_TYPE,
       D.SHIFT,
       D.PAYROLL_NAME,
       D.DEPARTMENT_NAME,
       D.JOB_NAME,
       D.PAYROLL_ID,
       ROWNUM   RECEIPT,
       D.SALARY_JOURNAL,
       D.PAYMENT_DAYS,
       D.PRINT_DATE,
       D.SAVINGS_ACUM,
       D.PERIOD_NAME,
       D.TIME_PERIOD_ID,
       D.PERSON_ID,
       D.GROCERIES_NUMBER,
       D.GROCERIES_VALUE,
       D.PERIOD_DATES,
       D.ATTACHED,
       D.ATTACHED_COMPANY_NAME,
       D.ATTACHED_COMPANY_DESC,
       ROW_NUMBER() OVER (PARTITION BY D.PAYROLL_ID ORDER BY D.PAYROLL_ID DESC) FOLIO,
       D.PAYMENT_TYPE,
       D.PAYMENT_METHOD_GROCERIES,
       D.ORGANIZATION_ID,
       D.PAYROLL_ACTION_ID, 
       D.ASSIGNMENT_ID
  FROM ( SELECT DISTINCT
                UPPER(PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('NOMINAS POR EMPLEADOR LEGAL', 
                                                        :P_COMPANY_ID))                                     AS  COMPANY_NAME,
                UPPER(OI.ORG_INFORMATION2)                                                                  AS  COMPANY_RFC,
                (CASE 
                    WHEN PTP.PERIOD_TYPE IN ('Semana', 'Week') THEN
                        'SEMANA'
                    WHEN PTP.PERIOD_TYPE IN ('Quincena', 'Semi-Month') THEN
                        'QUINCENA'
                 END)                                                                                       AS  PERIOD_TYPE, 
                PTP.PERIOD_NUM                                                                              AS  PERIOD_NUM, 
                UPPER(PPTV.PAYMENT_TYPE_NAME)                                                               AS  PAYMENT_TYPE_NAME,
                PAPF.EMPLOYEE_NUMBER                                                                        AS  EMPLOYEE_NUMBER,
                UPPER(PAPF.LAST_NAME        || ' ' || 
                      PAPF.PER_INFORMATION1 || ' ' || 
                      PAPF.FIRST_NAME       || ' ' || 
                      PAPF.MIDDLE_NAMES)                                                                    AS  EMPLOYEE_NAME,
                REPLACE(PAPF.PER_INFORMATION2, '-', '')                                                     AS  EMPLOYEE_RFC,
                TO_CHAR(REPLACE(REPLACE(PAPF.PER_INFORMATION3, ' ', ''),'-',''), '00000000000')             AS  EMPLOYEE_NSS,   
                PAC_HR_PAY_PKG.GET_EMPLOYER_REGISTRATION(PAAF.ASSIGNMENT_ID)                                AS  EMPLOYER_REGISTRATION,
                PAPF.NATIONAL_IDENTIFIER                                                                    AS  EMPLOYEE_CURP,
                MAX(NVL(PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAA.ASSIGNMENT_ACTION_ID,
                                                              'Integrated Daily Wage',
                                                              'Pay Value'), 0))                             AS  EMPLOYEE_IDW,
                UPPER(PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('MX_SOCIAL_SECURITY_SALARY_TYPE', 
                                                        HSCK.SEGMENT6))                                     AS  SALARY_TYPE,
                PAAF.ASS_ATTRIBUTE30                                                                        AS  SHIFT,
                PPF.PAYROLL_NAME                                                                            AS  PAYROLL_NAME, 
                HOUV.NAME                                                                                   AS  DEPARTMENT_NAME,
                HAPD.NAME                                                                                   AS  JOB_NAME,
                PPF.PAYROLL_ID                                                                              AS  PAYROLL_ID,
                MAX(NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,
                                                                'P001_SUELDO NORMAL',
                                                                'Sueldo Diario'), '0'))                     AS  SALARY_JOURNAL, 
                MAX(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_DIAPAG(PAA.PAYROLL_ACTION_ID, PAA.ASSIGNMENT_ID), '0'))  AS  PAYMENT_DAYS, 
                TO_CHAR(SYSDATE, 'DD/MON/YYYY')                                                             AS  PRINT_DATE,
                MAX(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_FAHOACUM(PAA.ASSIGNMENT_ACTION_ID,
                                                            PPA.DATE_EARNED,
                                                            PAA.TAX_UNIT_ID), '0'))                         AS  SAVINGS_ACUM,
                PTP.PERIOD_NAME                                                                             AS  PERIOD_NAME,
                PTP.TIME_PERIOD_ID                                                                          AS  TIME_PERIOD_ID,
                PAPF.PERSON_ID                                                                              AS  PERSON_ID,
                (CASE
                    WHEN NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,
                                                                     'P039_DESPENSA',
                                                                     'Pay Value'), '0') = 0 THEN 0
                    ELSE 1 END)                                                                             AS  GROCERIES_NUMBER,
                NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,
                                                            'P039_DESPENSA',
                                                            'Pay Value'), '0')                              AS  GROCERIES_VALUE,
                (PTP.START_DATE || ' AL '  || PTP.END_DATE)                                                 AS  PERIOD_DATES,
                :P_ANEXO                                                                                    AS  ATTACHED,
                UPPER(PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('NOMINAS POR EMPLEADOR LEGAL', :P_COMPANY_ID))      AS  ATTACHED_COMPANY_NAME,
                'BONO CON DERECHO A COMPRA'                                                                 AS  ATTACHED_COMPANY_DESC,                                                                  
                (CASE 
                    WHEN PTP.PERIOD_TYPE IN ('Semana', 'Week') THEN
                        'SEMANAL'
                    WHEN PTP.PERIOD_TYPE IN ('Quincena', 'Semi-Month') THEN
                        'QUINCENAL'
                 END)                                                                                       AS  PAYMENT_TYPE,
                (SELECT UPPER(FLV.DESCRIPTION)
                   FROM PAY_ORG_PAYMENT_METHODS_F       OPM,
                        PAY_PERSONAL_PAYMENT_METHODS_F  PPM,
                        FND_LOOKUP_VALUES               FLV
                  WHERE 1 = 1
                    AND PPM.ORG_PAYMENT_METHOD_ID = OPM.ORG_PAYMENT_METHOD_ID
                    AND PTP.END_DATE BETWEEN PPM.EFFECTIVE_START_DATE AND PPM.EFFECTIVE_END_DATE
                    AND PTP.END_DATE BETWEEN OPM.EFFECTIVE_START_DATE AND OPM.EFFECTIVE_END_DATE
                    AND FLV.LOOKUP_TYPE = 'XXCALV_METODO_DESPENSA'
                    AND FLV.MEANING = OPM.ORG_PAYMENT_METHOD_NAME
                    AND PPM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID 
                    AND ROWNUM = 1 )                                                                        AS  PAYMENT_METHOD_GROCERIES,
                   HOUV.ORGANIZATION_ID,
                   ---------------------
                   PAA.PAYROLL_ACTION_ID                                                                    AS  PAYROLL_ACTION_ID, 
                   PAA.ASSIGNMENT_ID                                                                        AS  ASSIGNMENT_ID
              FROM FND_LOOKUP_VALUES                FLV1,
                   HR_ALL_ORGANIZATION_UNITS        AOU,
                   HR_ORGANIZATION_INFORMATION      OI,
                   PAY_PAYROLLS_F                   PPF,
                   PAY_PAYROLL_ACTIONS              PPA,
                   PER_TIME_PERIODS                 PTP,
                   PER_ALL_ASSIGNMENTS_F            PAAF,
                   PAY_ASSIGNMENT_ACTIONS           PAA,
                   PER_ALL_PEOPLE_F                 PAPF,
                   PAY_RUN_TYPES_X                  PRTX,
                   HR_ORGANIZATION_UNITS_V          HOUV,
                   HR_ALL_POSITIONS_D               HAPD,
                   PAY_CONSOLIDATION_SETS           PCS,
                   PAY_PERSONAL_PAYMENT_METHODS_F   PPPM,
                   PAY_ORG_PAYMENT_METHODS_F        POPM,
                   PAY_PAYMENT_TYPES_TL             PPTV,
                   HR_SOFT_CODING_KEYFLEX           HSCK
             WHERE 1 = 1
               AND FLV1.LOOKUP_TYPE = 'NOMINAS POR EMPLEADOR LEGAL'
               AND FLV1.LOOKUP_CODE = :P_COMPANY_ID
               AND FLV1.LANGUAGE = USERENV('LANG')
               AND AOU.NAME = FLV1.MEANING
               AND AOU.ORGANIZATION_ID = OI.ORGANIZATION_ID
               AND OI.ORG_INFORMATION_CONTEXT = 'MX_TAX_REGISTRATION'
               AND SUBSTR(PPF.PAYROLL_NAME,1,2) = :P_COMPANY_ID
               AND APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
               AND PPF.PAYROLL_ID = NVL(:P_PAYROLL_ID, PPF.PAYROLL_ID) 
               AND PPF.PAYROLL_ID = PPA.PAYROLL_ID
               AND PPA.CONSOLIDATION_SET_ID  = NVL(:P_CONSOLIDATION_ID, PPA.CONSOLIDATION_SET_ID)
               AND PTP.PAYROLL_ID = PPF.PAYROLL_ID
               AND (EXTRACT(YEAR FROM PTP.END_DATE) = :P_YEAR 
                AND EXTRACT(MONTH FROM PTP.END_DATE) = :P_MONTH)
               AND PTP.PERIOD_NAME = NVL(:P_PERIOD_NAME, PTP.PERIOD_NAME)
               AND PAPF.PERSON_ID = NVL(:P_PERSON_ID, PAPF.PERSON_ID)
               AND HOUV.ORGANIZATION_ID = NVL(:P_ORGANIZATION_ID, HOUV.ORGANIZATION_ID)
               AND PPA.EFFECTIVE_DATE BETWEEN PTP.START_DATE AND PTP.END_DATE
               AND PTP.TIME_PERIOD_ID = PPA.TIME_PERIOD_ID   
               AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
               AND PAPF.PERSON_ID = PAAF.PERSON_ID
               AND PPA.EFFECTIVE_DATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
               AND PPA.EFFECTIVE_DATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
               AND PPA.CONSOLIDATION_SET_ID = PCS.CONSOLIDATION_SET_ID
               AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID 
               AND PAA.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
               AND PAA.RUN_TYPE_ID = PRTX.RUN_TYPE_ID
               AND PAAF.ORGANIZATION_ID = NVL(HOUV.ORGANIZATION_ID, PAAF.ORGANIZATION_ID) 
               AND PAAF.POSITION_ID = NVL(HAPD.POSITION_ID, PAAF.POSITION_ID)
               AND PPPM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
               AND PPPM.ORG_PAYMENT_METHOD_ID = POPM.ORG_PAYMENT_METHOD_ID
               AND PPTV.PAYMENT_TYPE_ID = POPM.PAYMENT_TYPE_ID
               AND PTP.END_DATE BETWEEN PPPM.EFFECTIVE_START_DATE AND PPPM.EFFECTIVE_END_DATE
               AND PTP.END_DATE BETWEEN POPM.EFFECTIVE_START_DATE AND POPM.EFFECTIVE_END_DATE
               AND (POPM.ORG_PAYMENT_METHOD_NAME NOT LIKE '%DESPENSA%'
               AND POPM.ORG_PAYMENT_METHOD_NAME NOT LIKE '%EFECTIVALE%'
               AND POPM.ORG_PAYMENT_METHOD_NAME NOT LIKE '%PENSIONES%')
               AND PPTV.LANGUAGE = 'ESA'
               AND HSCK.SOFT_CODING_KEYFLEX_ID = PAAF.SOFT_CODING_KEYFLEX_ID
               --AND PPF.PAYROLL_NAME NOT IN ('02_SEM - GRBE', '02_QUIN - EVENTUAL')
               AND PTP.END_DATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
               AND PTP.END_DATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE 
               AND (   PAC_CFDI_FUNCTIONS_PKG.GET_SUBTBR(PAA.PAYROLL_ACTION_ID, PAA.ASSIGNMENT_ID) <> 0
                    OR PAC_CFDI_FUNCTIONS_PKG.GET_MONDET(PAA.PAYROLL_ACTION_ID, PAA.ASSIGNMENT_ID) <> 0
                    OR PAC_CFDI_FUNCTIONS_PKG.GET_ISRRET(PAA.PAYROLL_ACTION_ID, PAA.ASSIGNMENT_ID) <> 0)
             GROUP BY OI.ORG_INFORMATION2,
                      PTP.PERIOD_TYPE,
                      PTP.PERIOD_NUM, 
                      PPTV.PAYMENT_TYPE_NAME,
                      PAPF.EMPLOYEE_NUMBER,
                      PAPF.LAST_NAME, 
                      PAPF.PER_INFORMATION1, 
                      PAPF.FIRST_NAME, 
                      PAPF.MIDDLE_NAMES,
                      PAPF.PER_INFORMATION2,
                      PAPF.PER_INFORMATION3,
                      PAAF.ASSIGNMENT_ID,
                      PAPF.NATIONAL_IDENTIFIER,
                      HSCK.SEGMENT6,
                      PAAF.ASS_ATTRIBUTE30,
                      PPF.PAYROLL_NAME, 
                      HOUV.NAME,
                      HAPD.NAME,
                      PPF.PAYROLL_ID,
                      PTP.PERIOD_NAME,
                      PTP.TIME_PERIOD_ID,
                      PAPF.PERSON_ID,
                      PAA.ASSIGNMENT_ACTION_ID,
                      PAA.PAYROLL_ACTION_ID, 
                      PAA.ASSIGNMENT_ID,
                      PTP.START_DATE,
                      PTP.END_DATE,
                      HOUV.ORGANIZATION_ID
             ORDER BY HOUV.NAME,
                      TO_NUMBER(PAPF.EMPLOYEE_NUMBER)) D
 WHERE 1 = 1
 ORDER BY ROWNUM
