ALTER SESSION SET NLS_LANGUAGE = 'LATIN AMERICAN SPANISH';
ALTER SESSION SET CURRENT_SCHEMA=APPS;

             SELECT DISTINCT 
                    PPF.PAYROLL_NAME,
                    (CASE
                        WHEN FLV1.LOOKUP_CODE = '02' THEN 'CS'
                        WHEN FLV1.LOOKUP_CODE = '08' THEN 'POGA'
                        WHEN FLV1.LOOKUP_CODE = '11' THEN 'PAC'
                     END)                                                                           AS  SERFOL,
                    UPPER(OI.ORG_INFORMATION2)                                                      AS  RFCEMI,
                    UPPER(FLV1.MEANING)                                                             AS  NOMEMI,
                    UPPER(LA.ADDRESS_LINE_1)                                                        AS  CALEMI,
                    UPPER(LA.ADDRESS_LINE_2)                                                        AS  COLEMI,
                    UPPER(LA.TOWN_OR_CITY)                                                          AS  MUNEMI,
                    UPPER(FLV2.MEANING)                                                             AS  ESTEMI,
                    LA.POSTAL_CODE                                                                  AS  CODEMI,
                    UPPER(FT1.NLS_TERRITORY)                                                        AS  PAIEMI,
                    REPLACE(PAPF.PER_INFORMATION2, '-', '')                                         AS  RFCREC,
                    UPPER(PAPF.LAST_NAME        || ' ' || 
                          PAPF.PER_INFORMATION1 || ' ' || 
                          PAPF.FIRST_NAME       || ' ' || 
                          PAPF.MIDDLE_NAMES)                                                        AS  NOMREC,
                    (SELECT UPPER(NVL(FT2.NLS_TERRITORY, 'MEXICO'))
                       FROM PER_ADDRESSES    PA,
                            FND_TERRITORIES  FT2
                      WHERE PA.PERSON_ID = PAPF.PERSON_ID
                        AND FT2.TERRITORY_CODE = PA.COUNTRY)                                        AS  PAIREC,
                    NVL(PAPF.EMAIL_ADDRESS, 'NULL')                                                 AS  MAIL,
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_SUBTBR(PAA.ASSIGNMENT_ACTION_ID), '0'))      AS  SUBTBR,     
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_ISRRET(PAA.ASSIGNMENT_ACTION_ID), '0'))      AS  ISRRET,
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_MONDET(PAA.ASSIGNMENT_ACTION_ID), '0'))      AS  MONDET,  
                    PAPF.EMPLOYEE_NUMBER                                                            AS  NOM_NUMEMP,
                    PAPF.NATIONAL_IDENTIFIER                                                        AS  NOM_CURP,
                    (CASE
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%NORMAL%' THEN
                            CASE 
                                WHEN :P_PERIOD_TYPE = 'Week' OR :P_PERIOD_TYPE = 'Semana' THEN
                                     PTP.END_DATE + 4
                                ELSE
                                     PTP.END_DATE
                            END
                        ELSE
                            PTP.END_DATE
                     END)                                                                           AS  NOM_FECPAG,       
                    (CASE
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%NORMAL%' THEN
                            PTP.START_DATE 
                        ELSE 
                            PTP.END_DATE
                     END)                                                                           AS  NOM_FECINI,
                    PTP.END_DATE                                                                    AS  NOM_FECFIN,
                    TO_CHAR(REPLACE(REPLACE(PAPF.PER_INFORMATION3, ' ', ''),'-',''), '00000000000') AS  NOM_NUMSEG,   
                    MAX(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_DIAPAG(PAA.ASSIGNMENT_ACTION_ID), '0'))      AS  NOM_DIAPAG,
                    HOUV.NAME                                                                       AS  NOM_DEPTO,
                    HAPD.NAME                                                                       AS  NOM_PUESTO, 
                    (CASE
                        WHEN PPF.PAYROLL_NAME LIKE '%SEM%' THEN
                             'SEMANAL'
                        WHEN PPF.PAYROLL_NAME LIKE '%QUIN%' THEN
                             'QUINCENAL'
                        ELSE
                             ''
                     END)                                                                           AS  NOM_FORPAG,
                    PTP.PERIOD_NUM                                                                  AS  NOM_NUMERONOM,
                    APPS.PAC_HR_PAY_PKG.GET_EMPLOYER_REGISTRATION(PAAF.ASSIGNMENT_ID)               AS  NOM_REGPAT,
                    MAX(NVL(PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAA.ASSIGNMENT_ACTION_ID,
                                            'Integrated Daily Wage',
                                            'Pay Value'), '0'))                                     AS  NOM_SDI,
                    MAX(NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,
                                              'P001_SUELDO NORMAL',
                                              'Sueldo Diario'), '0'))                               AS  NOM_SALBASE, 
                    MAX(NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,
                                              'P039_DESPENSA',
                                              'Pay Value'), '0'))                                   AS  GROCERIES_VALUE,
                    PPF.ATTRIBUTE1                                                                  AS  NOM_CVENOM,  
                    MAX(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_FAHOACUM(PAA.ASSIGNMENT_ACTION_ID,
                                         PPA.DATE_EARNED,
                                         PAA.TAX_UNIT_ID), '0'))                                    AS  NOM_FAHOACUM,
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_PER_TOTGRA(PAA.ASSIGNMENT_ACTION_ID), '0'))  AS  NOM_PER_TOTGRA,
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_PER_TOTEXE(PAA.ASSIGNMENT_ACTION_ID), '0'))  AS  NOM_PER_TOTEXE,  
                    PAC_CFDI_FUNCTIONS_PKG.GET_NOM_DESCRI(PPA.PAYROLL_ACTION_ID)                    AS  NOM_DESCRI,  
                     NVL((SELECT DISTINCT 
                                 (CASE WHEN PAPF.EMPLOYEE_NUMBER = 13 OR PAPF.EMPLOYEE_NUMBER = 24 THEN
                                        '03-TRANSFERENCIA E' --'TRANSFERENCIA ELECTRONICA'
                                       WHEN PCS.CONSOLIDATION_SET_NAME = 'FINIQUITOS' THEN
                                        '02-CHEQUE' --'CHEQUE'
                                       WHEN POPM.ORG_PAYMENT_METHOD_NAME LIKE '%EFECTIVO%' THEN
                                        '01-EFECTIVO' --'EFECTIVO'
                                       WHEN (POPM.ORG_PAYMENT_METHOD_NAME LIKE '%BANCOMER%'
                                          OR POPM.ORG_PAYMENT_METHOD_NAME LIKE '%BANORTE%'
                                          OR POPM.ORG_PAYMENT_METHOD_NAME LIKE '%HSBC%'
                                          OR POPM.ORG_PAYMENT_METHOD_NAME LIKE '%INVERLAT%') THEN
                                        '03-TRANSFERENCIA E' --'TRANSFERENCIA ELECTRONICA'
                                       
                                  END)
                            FROM PER_ALL_ASSIGNMENTS_F          PAA,
                                 PAY_PERSONAL_PAYMENT_METHODS_F PPPM,
                                 PAY_ORG_PAYMENT_METHODS_F      POPM,
                                 PAY_PAYMENT_TYPES_V            PPTV
                            WHERE PPPM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
                              AND PPPM.ORG_PAYMENT_METHOD_ID = POPM.ORG_PAYMENT_METHOD_ID
                              AND PPTV.PAYMENT_TYPE_ID = POPM.PAYMENT_TYPE_ID
                              AND PPTV.TERRITORY_CODE = 'MX'
                              AND (POPM.ORG_PAYMENT_METHOD_NAME NOT LIKE '%DESPENSA%'
                              AND POPM.ORG_PAYMENT_METHOD_NAME NOT LIKE '%EFECTIVALE%'
                              AND POPM.ORG_PAYMENT_METHOD_NAME NOT LIKE '%PENSIONES%')
                              AND ROWNUM = 1
                                ), '01')                                                            AS  METPAG,
                    PPF.PAYROLL_ID,
                    PAAF.ASSIGNMENT_ID,
                    PPA.PAYROLL_ACTION_ID,
                    PPA.DATE_EARNED,
                    PPA.CONSOLIDATION_SET_ID,
                    PPA.EFFECTIVE_DATE,
                    PTP.END_DATE
                  FROM 
                       FND_LOOKUP_VALUES            FLV1,
                       HR_ALL_ORGANIZATION_UNITS    AOU,
                       HR_LOCATIONS_ALL             LA,
                       HR_ORGANIZATION_INFORMATION  OI,
                       FND_TERRITORIES              FT1,
                       FND_LOOKUP_VALUES            FLV2,
                       PAY_PAYROLLS_F               PPF,
                       PAY_PAYROLL_ACTIONS          PPA,
                       PER_TIME_PERIODS             PTP,
                       PER_ALL_ASSIGNMENTS_F        PAAF,
                       PAY_ASSIGNMENT_ACTIONS       PAA,
                       PER_ALL_PEOPLE_F             PAPF,
                       PAY_RUN_TYPES_X              PRTX,
                       HR_ORGANIZATION_UNITS_V      HOUV,
                       HR_ALL_POSITIONS_D           HAPD,
                       PAY_CONSOLIDATION_SETS       PCS
                 WHERE 1 = 1
                   AND FLV1.LOOKUP_TYPE = 'NOMINAS POR EMPLEADOR LEGAL'
                   AND FLV1.LOOKUP_CODE = :P_COMPANY_ID
                   AND FLV1.LANGUAGE = USERENV('LANG')
                   AND AOU.NAME = FLV1.MEANING
                   AND LA.LOCATION_ID = AOU.LOCATION_ID
                   AND AOU.ORGANIZATION_ID = OI.ORGANIZATION_ID
                   AND OI.ORG_INFORMATION_CONTEXT = 'MX_TAX_REGISTRATION'
                   AND LA.COUNTRY = FT1.TERRITORY_CODE
                   AND FLV2.LOOKUP_CODE = LA.REGION_1
                   AND FLV2.LOOKUP_TYPE = 'MX_STATE'
                   AND FLV2.LANGUAGE = USERENV('LANG')
                   AND SUBSTR(PPF.PAYROLL_NAME,1,2) = FLV1.LOOKUP_CODE
                   AND APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
                   AND PPF.PAYROLL_ID = NVL(:P_PAYROLL_ID, PPF.PAYROLL_ID) 
                   AND PPF.PAYROLL_ID = PPA.PAYROLL_ID
                   AND PPA.CONSOLIDATION_SET_ID  = NVL(:P_CONSOLIDATION_ID, PPA.CONSOLIDATION_SET_ID)
                   AND PTP.PAYROLL_ID = PPF.PAYROLL_ID
                   AND (EXTRACT(YEAR FROM PTP.END_DATE) = :P_YEAR 
                    AND EXTRACT(MONTH FROM PTP.END_DATE) = :P_MONTH)
                   AND PTP.PERIOD_NAME = NVL(:P_PERIOD_NAME, PTP.PERIOD_NAME)
                   AND PPA.EFFECTIVE_DATE BETWEEN PTP.START_DATE AND PTP.END_DATE
                   AND PTP.TIME_PERIOD_ID = PPA.TIME_PERIOD_ID   
                   AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
                   AND PAPF.PERSON_ID = PAAF.PERSON_ID
                   AND PPA.CONSOLIDATION_SET_ID = PCS.CONSOLIDATION_SET_ID
                   AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID 
                   AND PAA.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
                   AND PRTX.RUN_TYPE_ID = PAA.RUN_TYPE_ID
                   AND PAAF.ORGANIZATION_ID = NVL(HOUV.ORGANIZATION_ID, PAAF.ORGANIZATION_ID) 
                   AND PAAF.POSITION_ID = NVL(HAPD.POSITION_ID, PAAF.POSITION_ID)
                   AND PPF.PAYROLL_NAME NOT IN ('02_SEM - GRBE', '02_QUIN - EVENTUAL')
                   AND PPA.EFFECTIVE_DATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
                   AND PPA.EFFECTIVE_DATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
                   AND PPA.EFFECTIVE_DATE BETWEEN HAPD.EFFECTIVE_START_DATE AND HAPD.EFFECTIVE_END_DATE
                   AND PPA.EFFECTIVE_DATE BETWEEN PRTX.EFFECTIVE_START_DATE AND PRTX.EFFECTIVE_END_DATE
                   AND PPA.EFFECTIVE_DATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
                   AND PAC_CFDI_FUNCTIONS_PKG.GET_PAYMENT_METHOD(PAA.ASSIGNMENT_ID) LIKE '%EFECTIVO%'
                 GROUP BY PPF.PAYROLL_NAME,
                          FLV1.LOOKUP_CODE,
                          OI.ORG_INFORMATION2,
                          FLV1.MEANING,
                          LA.ADDRESS_LINE_1,
                          LA.ADDRESS_LINE_2,
                          LA.TOWN_OR_CITY,
                          FLV2.MEANING,
                          LA.POSTAL_CODE,
                          FT1.NLS_TERRITORY,
                          PAPF.PER_INFORMATION2,
                          PAPF.LAST_NAME, 
                          PAPF.PER_INFORMATION1, 
                          PAPF.FIRST_NAME, 
                          PAPF.MIDDLE_NAMES,
                          PAPF.PERSON_ID,
                          PAPF.EMAIL_ADDRESS,
                          PAPF.EMPLOYEE_NUMBER,
                          PAPF.NATIONAL_IDENTIFIER,
                          PCS.CONSOLIDATION_SET_NAME,
                          PTP.END_DATE,
                          PTP.START_DATE,
                          PAPF.PER_INFORMATION3,
                          HOUV.NAME,
                          HAPD.NAME,
                          PTP.PERIOD_NUM,
                          PAAF.ASSIGNMENT_ID,
                          PPF.ATTRIBUTE1,
                          PPA.PAYROLL_ACTION_ID,
                          PPF.PAYROLL_ID,
                          PAAF.ASSIGNMENT_ID,
                          PPA.PAYROLL_ACTION_ID,
                          PPA.DATE_EARNED,
                          PPA.CONSOLIDATION_SET_ID,
                          PPA.EFFECTIVE_DATE,
                          PTP.END_DATE
                 ORDER BY PPF.PAYROLL_NAME,
                          PAPF.EMPLOYEE_NUMBER;