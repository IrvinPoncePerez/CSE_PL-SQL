                SELECT DISTINCT /*+ USE_NL LEADING(PPA PTP PAA PPF) INDEX_JOIN(PTP PAY_PAYROLL_ACTIONS_FK8 PER_TIME_PERIODS_PK) INDEX_JOIN(PAA PAY_PAYROLL_ACTIONS_PK PAY_ASSIGNMENT_ACTIONS_N4) INDEX_JOIN(PPF PAY_PAYROLL_ACTIONS_N50 PAY_PAYROLLS_F_PK)*/
                       PAA.TAX_UNIT_ID,
                       PPA.PAYROLL_ACTION_ID,
                       PAA.ASSIGNMENT_ID,
                       PAA.ASSIGNMENT_ACTION_ID,
                       PPF.PAYROLL_ID,
                       PPA.CONSOLIDATION_SET_ID,
                       PPA.EFFECTIVE_DATE,
                       PTP.START_DATE,
                       PTP.END_DATE,
                       PPA.DATE_EARNED,
                       PAA.RUN_TYPE_ID,
                       (SELECT meaning 
                          FROM HR_LOOKUPS 
                         WHERE LOOKUP_TYPE = 'ACTION_TYPE'
                           AND LOOKUP_CODE = PPA.ACTION_TYPE )                                  AS  ACTION_TYPE,
                       EXTRACT(YEAR FROM PTP.END_DATE)                                          AS  ANIO,
                       EXTRACT(MONTH FROM PTP.END_DATE)                                         AS  MES,
                       PTP.PERIOD_NUM                                                           AS  NUM_NOMINA,
                       -----------------------------------------------------------------------------------------
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAA.ASSIGNMENT_ACTION_ID,      'I001_SALARIO_DIARIO',      'Pay Value'), '0')    AS  SUELDO_DIARIO,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_INFORMATION_VALUE(PAA.ASSIGNMENT_ACTION_ID,'Integrated Daily Wage',    'Pay Value'), '0')    AS  SALARIO_DIARIO_INTEGRADO,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P001_SUELDO NORMAL',       'Pay Value'), '0')    AS  SUELDO_NORMAL,
                       -----------------------------------------------------------------------------------------
                       ----                     DETALLE DE          PERCEPCIONES 
                       -----------------------------------------------------------------------------------------
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P002_HORAS EXTRAS',        'Pay Value'),   '0')    AS  HORAS_EXTRA,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P002_HORAS EXTRAS',        'ISR Exempt'),  '0')    AS  HORAS_EXTRA_EXE,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P003_FESTIVO SIN SEPTIMO', 'Pay Value'),   '0')    AS  FESTIVO_SEPTIMO_DIA,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P004_PRIMA DOMINICAL',     'Pay Value'),   '0')    AS  PRIMA_DOMINICAL,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P004_PRIMA DOMINICAL',     'ISR Exempt'),  '0')    AS  PRIMA_DOMINICAL_EXE,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P005_VACACIONES',          'Pay Value'),   '0')    AS  VACACIONES,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P006_PRIMA VACACIONAL',    'Pay Value'),   '0')    AS  PRIMA_VACACIONAL,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P006_PRIMA VACACIONAL',    'ISR Exempt'),  '0')    AS  PRIMA_VACACIONAL_EXE,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P007_PREMIO ASISTENCIA',   'Pay Value'),   '0')    AS  PREMIO_ASISTENCIA,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EXEMPT_VALUE(PAA.ASSIGNMENT_ACTION_ID,     'P007_PREMIO ASISTENCIA',   'Pay Value',    'Tope'), '0')   AS  PREMIO_ASISTENCIA_EXE,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P009_COMISIONES',          'Pay Value'),   '0')    AS  COMISIONES,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P010 AYUDA DE ALIMENTOS',  'Pay Value'),   '0')    AS  AYUDA_ALIMENTOS,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P012_SUBSIDIO INCAPACIDAD','Pay Value'),   '0')    AS  SUBSIDIO_INCAPACIDAD,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P011_AGUINALDO',           'Pay Value'),   '0')    AS  AGUINALDO,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P011_AGUINALDO',           'ISR Exempt'),  '0')    AS  AGUINALDO_EXE,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P013_SALARIOS PENDIENTES', 'Pay Value'),   '0')    AS  SALARIOS_PENDIENTES,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P044_RETROACTIVO',         'Pay Value'),   '0')    AS  RETROACTIVO,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P014_PREMIO ANTIGÜEDAD',   'Pay Value'),   '0')    AS  PREMIO_ANTIGUEDAD,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P015_DIAS ESPECIALES',     'Pay Value'),   '0')    AS  DIAS_ESPECIALES,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P017_PRIMA DE ANTIGUEDAD',   'Pay Value'),   '0')  AS  PRIMA_ANTIGUEDAD,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'Profit Sharing',           'Pay Value'),   '0')    AS  PTU,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'Profit Sharing',           'ISR Exempt'),  '0')    AS  PTU_EXE,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P021_PASAJES',             'Pay Value'),   '0')    AS  PASAJES,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P022_PREMIO_PUNTUALIDAD',  'Pay Value'),   '0')    AS  PREMIO_PUNTUALIDAD,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EXEMPT_VALUE(PAA.ASSIGNMENT_ACTION_ID,     'P022_PREMIO_PUNTUALIDAD',  'Pay Value',    'TOPE'), '0')   AS  PREMIO_PUNTUALIDAD_EXE,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P023_BONO_PRODUCTIVIDAD',  'Pay Value'),   '0')    AS  BONO_PRODUCTIVIDAD,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P024_GRATIFICACION',       'Pay Value'),   '0')    AS  GRATIFICACION,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P025_AYUDA_ESCOLAR',       'Pay Value'),   '0')    AS  AYUDA_ESCOLAR,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P026_INDEMNIZACION',       'Pay Value'),   '0')    AS  INDEMNIZACION,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P027_GRATIFIC_ESP',        'Pay Value'),   '0')    AS  GRATIFICACION_ESPECIAL, --P027_GRATIFICACION_ESP
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P032_SUBSIDIO_PARA_EMPLEO','Pay Value'),   '0')    AS  SUBSIDIO_EMPLEO,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P035_COMPENSACION',        'Pay Value'),   '0')    AS  COMPENSACION, 
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P036_BECA_EDUCACIONAL',    'Pay Value'),   '0')    AS  BECA_EDUCACIONAL,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P008_AYUDA DE DEFUNCION',  'Pay Value'),   '0')    AS  AYUDA_DEFUNCION,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P037_VACACIONES P',        'Pay Value'),   '0')    AS  VACACIONES_PAGADAS,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P038_BONO EXTRAORD',       'Pay Value'),   '0')    AS  BONO_EXTRAORDINARIO,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P039_DESPENSA',            'Pay Value'),   '0')    AS  DESPENSA,
                       NVL(PAC_RESULT_VALUES_PKG.GET_DESPENSA_EXEMPT(PAA.ASSIGNMENT_ACTION_ID, PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P039_DESPENSA',            'Pay Value'), PPA.EFFECTIVE_DATE, PPF.PERIOD_TYPE),   '0')    AS  DESPENSA_EXE,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P043_FONDO AHORRO EMP',    'Pay Value'),   '0')    AS  FONDO_AHO_EMP,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P045_PERMISO X PATERNIDAD','Pay Value'),   '0')    AS  PERMISO_PATERNIDAD,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P046_BONO CUATRIMESTRAL',  'Pay Value'),   '0')    AS  BONO_CUATRIMESTRAL,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P080_FONDO AHORRO TR ACUM','Pay Value'),   '0')    AS  FONDO_TR_ACUMULADO,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P091_FONDO AHORRO E ACUM', 'Pay Value'),   '0')    AS  FONDO_EM_ACUMULADO,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P042_INTERES_GANADO',      'Pay Value'),   '0')    AS  INTERES_GANADO,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P047_ISPT ANUAL A FAVOR',  'Pay Value'),   '0')    AS  ISPT_ANUAL_FAVOR,
                       NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P047_ISPT_A_FAVOR',        'Pay Value'),   '0')    AS  ISPT_A_FAVOR,
                       ---------------------------------------------------------------------------------------
                       --                     DETALLE DE          DEDUCCIONES
                       ---------------------------------------------------------------------------------------  
                       NVL(PAC_RESULT_VALUES_PKG.GET_INFORMATION_VALUE(PAA.ASSIGNMENT_ACTION_ID,'D055_ISPT',                'Pay Value'),   '0')    AS  ISPT, --D066_ISPT
                       NVL(PAC_RESULT_VALUES_PKG.GET_INFORMATION_VALUE(PAA.ASSIGNMENT_ACTION_ID,'D056_IMSS',                'Pay Value'),   '0')    AS  IMSS,
                       NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D058_INFONAVIT',           'Pay Value'),   '0')    AS  INFONAVIT,
                       NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D080_FONDO AHORRO TRABAJADOR','Pay Value'),'0')    AS  FONDO_AHO_TR,    
                       NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D091_FONDO DE AHORRO EMPRESA','Pay Value'),'0')    AS  FONDO_AHO_EM,
                       NVL(PAC_RESULT_VALUES_PKG.GET_OTHER_SUM_VALUE(PAA.ASSIGNMENT_ACTION_ID,'ISR Subsidy for Employment', 'ISR Subsidy for Employment'),   '0')    AS   SUBSIDIO_SEGUN_TABLA,
                       NVL(PAC_RESULT_VALUES_PKG.GET_OTHER_SUM_VALUE(PAA.ASSIGNMENT_ACTION_ID,'ISR',                        'ISR Calculated'),   '0')                AS   ISR_SEGUN_TABLA,
                       NVL(PAC_RESULT_VALUES_PKG.GET_BALANCE(PAA.ASSIGNMENT_ACTION_ID, 
                                                             PPA.DATE_EARNED,
                                                             'ISR Tax Balance Adjustments',
                                                             'ISR Withheld') ,   '0')                  AS   AJUSTE_ISPT,
                       NVL(PAC_RESULT_VALUES_PKG.GET_BALANCE(PAA.ASSIGNMENT_ACTION_ID, 
                                                             PPA.DATE_EARNED,
                                                             'ISR Tax Balance Adjustments',
                                                             'ISR Subsidy for Employment Paid'),   '0') AS   AJUSTE_SUBSIDIO_EMPLEO,
                       NVL(PAC_RESULT_VALUES_PKG.GET_BALANCE(PAA.ASSIGNMENT_ACTION_ID, 
                                                             PPA.DATE_EARNED,
                                                             'ISR Tax Balance Adjustments',
                                                             'ISR Calculated'),   '0')                AS   AJUSTE_ISR_SEGUN_TABLA,
                       NVL(PAC_RESULT_VALUES_PKG.GET_BALANCE(PAA.ASSIGNMENT_ACTION_ID, 
                                                             PPA.DATE_EARNED,
                                                             'ISR Tax Balance Adjustments',
                                                             'ISR Subsidy for Employment'),   '0')    AS   AJUSTE_SUBSIDIO_SEGUN_TABLA,  
--                       ---------------------------------------------------------------------------------------
                       (
                        SELECT 
                            SUM(PRRV.RESULT_VALUE)
                          FROM PAY_RUN_RESULTS              PRR,
                               PAY_ELEMENT_TYPES_F          PETF,
                               PAY_RUN_RESULT_VALUES        PRRV,
                               PAY_INPUT_VALUES_F           PIVF,
                               PAY_ELEMENT_CLASSIFICATIONS  PEC
                         WHERE PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
                           AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
                           AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
                           AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
                           AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
                           AND (PEC.CLASSIFICATION_NAME IN ('Earnings', 
                                                            'Supplemental Earnings', 
                                                            'Amends', 
                                                            'Imputed Earnings') 
                                   OR PETF.ELEMENT_NAME IN (SELECT MEANING
                                                              FROM FND_LOOKUP_VALUES 
                                                             WHERE LOOKUP_TYPE = 'XX_PERCEPCIONES_INFORMATIVAS'
                                                               AND LANGUAGE = USERENV('LANG')))
                           AND PIVF.NAME = 'ISR Subject'
                           AND PIVF.UOM = 'M'
                       )                                                                       AS  ISR_GRAVADO, 
                       (NVL(TRUNC((SELECT 
                                   SUM(PRRV.RESULT_VALUE)
                              FROM PAY_RUN_RESULTS          PRR,
                                   PAY_ELEMENT_TYPES_F      PETF,
                                   PAY_RUN_RESULT_VALUES    PRRV,
                                   PAY_INPUT_VALUES_F       PIVF
                             WHERE PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
                               AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
                               AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
                               AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
                               AND (PETF.ELEMENT_NAME = 'P001_SUELDO NORMAL'
                                 OR PETF.ELEMENT_NAME = 'P005_VACACIONES')
                               AND PIVF.NAME = 'Days'
                              ),2), '0'))                                                         AS  DIAS_PAGADOS 
                  FROM PAY_PAYROLL_ACTIONS          PPA,
                       PER_TIME_PERIODS             PTP,
                       PAY_ASSIGNMENT_ACTIONS       PAA,
                       PAY_ALL_PAYROLLS_F           PPF
                 WHERE 1 = 1
                   AND PTP.TIME_PERIOD_ID = PPA.TIME_PERIOD_ID
                   AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
                   AND PPF.PAYROLL_ID = PPA.PAYROLL_ID      
                   AND PPA.CONSOLIDATION_SET_ID = NVL(:P_CONSOLIDATION_SET_ID, PPA.CONSOLIDATION_SET_ID)
                   AND PPA.ACTION_TYPE IN ('Q', 'R', 'B')
                   AND PPA.PAYROLL_ID = NVL(:P_PAYROLL_ID,  PPA.PAYROLL_ID)
                   AND PTP.PERIOD_NAME LIKE '%' || :P_YEAR || '%'
                   AND (    EXTRACT(MONTH FROM PTP.END_DATE) >= :P_START_MONTH
                        AND EXTRACT(MONTH FROM PTP.END_DATE) <= :P_END_MONTH)
                   AND PPF.PAYROLL_NAME NOT IN ('02_SEM - GRBE', '02_QUIN - EVENTUAL')
                   AND SUBSTR(PPF.PAYROLL_NAME, 1, 2) = :P_COMPANY_ID
                   AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
                 GROUP  
                    BY PAA.ASSIGNMENT_ID,
                       PPF.ATTRIBUTE1,
                       PTP.END_DATE,
                       PTP.PERIOD_NUM,
                       PPA.PAYROLL_ACTION_ID,
                       PAA.ASSIGNMENT_ACTION_ID,
                       PPF.PAYROLL_ID,
                       PPA.CONSOLIDATION_SET_ID,
                       PPA.EFFECTIVE_DATE,
                       PTP.START_DATE,
                       PTP.END_DATE,
                       PPA.ACTION_TYPE,
                       PPA.DATE_EARNED,
                       PAA.TAX_UNIT_ID,
                       PAA.RUN_TYPE_ID,
                       PPF.PERIOD_TYPE;
                      
