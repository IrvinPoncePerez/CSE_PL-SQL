ALTER SESSION SET CURRENT_SCHEMA=APPS;

        SELECT PAAF.PERSON_ID,
               DETAIL.EMPLOYEE_NUMBER    AS  "NUMERO_EMPLEADO",
               DETAIL.FULL_NAME          AS  NOMBRE_EMPLEADO,
               DETAIL.PER_INFORMATION2   AS  RFC,
               PAC_RESULT_VALUES_PKG.GET_EFFECTIVE_START_DATE(PAAF.PERSON_ID)                   AS  EFFECTIVE_START_DATE,
               PAC_RESULT_VALUES_PKG.GET_TYPE_MOVEMENT(PAAF.PERSON_ID, :P_END_MONTH, :P_YEAR)   AS  TYPE_MOVEMENT,
               PPF.ATTRIBUTE1                                                                   AS  CLAVE_NOMINA,
               PAC_RESULT_VALUES_PKG.GET_EMPLOYEER_REGISTRATION(SYSDATE,        
                                                                PAAF.ASSIGNMENT_ID)              AS  REG_PATRONAL,
               MAX(SUELDO_DIARIO)        AS SUELDO_DIARIO,
               MAX(SALARIO_DIARIO_INTEGRADO) AS SALARIO_DIARIO_INTEGRADO,            
               SUM(SUELDO_NORMAL)        AS SUELDO_NORMAL,      
               SUM(HORAS_EXTRA)          AS HORAS_EXTRA,         
               SUM(HORAS_EXTRA_EXE)      AS HORAS_EXTRA_EXE,    
               SUM(FESTIVO_SEPTIMO_DIA)  AS FESTIVO_SEPTIMO_DIA,
               SUM(PRIMA_DOMINICAL)      AS PRIMA_DOMINICAL,    
               SUM(PRIMA_DOMINICAL_EXE)  AS PRIMA_DOMINICAL_EXE,
               SUM(VACACIONES)           AS VACACIONES,        
               SUM(PRIMA_VACACIONAL)     AS PRIMA_VACACIONAL,   
               SUM(PRIMA_VACACIONAL_EXE) AS PRIMA_VACACIONAL_EXE,
               SUM(PREMIO_ASISTENCIA)    AS PREMIO_ASISTENCIA,  
               SUM(PREMIO_ASISTENCIA_EXE) AS PREMIO_ASISTENCIA_EXE,
               SUM(COMISIONES)           AS COMISIONES,    
               SUM(AYUDA_ALIMENTOS)      AS AYUDA_ALIMENTOS,      
               SUM(SUBSIDIO_INCAPACIDAD) AS SUBSIDIO_INCAPACIDAD,
               SUM(AGUINALDO)            AS AGUINALDO,           
               SUM(AGUINALDO_EXE)        AS AGUINALDO_EXE,       
               SUM(SALARIOS_PENDIENTES)  AS SALARIOS_PENDIENTES, 
               SUM(RETROACTIVO)          AS RETROACTIVO,         
               SUM(PREMIO_ANTIGUEDAD)    AS PREMIO_ANTIGUEDAD,   
               SUM(DIAS_ESPECIALES)      AS DIAS_ESPECIALES,   
               SUM(PRIMA_ANTIGUEDAD)     AS PRIMA_ANTIGUEDAD,  
               SUM(PTU)                  AS PTU,                 
               SUM(PTU_EXE)              AS PTU_EXE,             
               SUM(PASAJES)              AS PASAJES,             
               SUM(PREMIO_PUNTUALIDAD)   AS PREMIO_PUNTUALIDAD,  
               SUM(PREMIO_PUNTUALIDAD_EXE) AS PREMIO_PUNTUALIDAD_EXE,
               SUM(BONO_PRODUCTIVIDAD)   AS BONO_PRODUCTIVIDAD,  
               SUM(GRATIFICACION)        AS GRATIFICACION,
               SUM(AYUDA_ESCOLAR)        AS AYUDA_ESCOLAR,       
               SUM(INDEMNIZACION)        AS INDEMNIZACION,
               SUM(GRATIFICACION_ESPECIAL) AS GRATIFICACION_ESPECIAL,
               SUM(SUBSIDIO_EMPLEO)      AS SUBSIDIO_EMPLEO,     
               SUM(COMPENSACION)         AS COMPENSACION,        
               SUM(BECA_EDUCACIONAL)     AS BECA_EDUCACIONAL,    
               SUM(AYUDA_DEFUNCION)      AS AYUDA_DEFUNCION,    
               SUM(VACACIONES_PAGADAS)   AS VACACIONES_PAGADAS, 
               SUM(BONO_EXTRAORDINARIO)  AS BONO_EXTRAORDINARIO,
               SUM(DESPENSA)             AS DESPENSA,           
               SUM(DESPENSA_EXE)         AS DESPENSA_EXE,       
               SUM(FONDO_AHO_EMP)        AS FONDO_AHO_EMP,      
               SUM(PERMISO_PATERNIDAD)   AS PERMISO_PATERNIDAD,
               SUM(BONO_CUATRIMESTRAL)   AS BONO_CUATRIMESTRAL,
               SUM(FONDO_TR_ACUMULADO)   AS FONDO_TR_ACUMULADO, 
               SUM(FONDO_EM_ACUMULADO)   AS FONDO_EM_ACUMULADO, 
               SUM(INTERES_GANADO)       AS INTERES_GANADO,   
               SUM(ISPT_ANUAL_FAVOR)     AS ISPT_ANUAL_FAVOR, 
               SUM(ISPT_A_FAVOR)         AS ISPT_A_FAVOR,
               SUM(ISPT)                 AS ISPT,            
               SUM(IMSS)                 AS IMSS,
               SUM(INFONAVIT)            AS INFONAVIT,               
               SUM(FONDO_AHO_TR)         AS FONDO_AHO_TR,       
               SUM(FONDO_AHO_EM)         AS FONDO_AHO_EM,       
               SUM(ISR_GRAVADO)          AS ISR_GRAVADO,
               SUM(SUBSIDIO_SEGUN_TABLA) AS SUBSIDIO_SEGUN_TABLA,
               SUM(ISR_SEGUN_TABLA)      AS ISR_SEGUN_TABLA,
               SUM(AJUSTE_ISPT)          AS AJUSTE_ISPT,
               SUM(AJUSTE_SUBSIDIO_EMPLEO)      AS AJUSTE_SUBSIDIO_EMPLEO,
               SUM(AJUSTE_ISR_SEGUN_TABLA)      AS AJUSTE_ISR_SEGUN_TABLA,
               SUM(AJUSTE_SUBSIDIO_SEGUN_TABLA) AS AJUSTE_SUBSIDIO_SEGUN_TABLA, 
               SUM(DIAS_PAGADOS)         AS DIAS_PAGADOS
          FROM (
                SELECT DISTINCT
                       PAPF.PERSON_ID,
                       PAPF.EMPLOYEE_NUMBER,
                       PAPF.FULL_NAME,
                       PAPF.PER_INFORMATION2,
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
                       PAY_PAYROLLS_F               PPF,
                       PER_ALL_ASSIGNMENTS_F        PAAF,
                       PER_ALL_PEOPLE_F             PAPF,
                       PAY_RUN_TYPES_F              PRTF
                 WHERE 1 = 1
                   AND PTP.TIME_PERIOD_ID = PPA.TIME_PERIOD_ID
                   AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
                   AND PPA.PAYROLL_ID = PPF.PAYROLL_ID 
                   AND PTP.PAYROLL_ID = PPF.PAYROLL_ID
                    ----------Parametros de Ejecucion-----------------
                   AND SUBSTR(PPF.PAYROLL_NAME, 1, 2) = :P_COMPANY_ID    
                   AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
                   AND PPA.CONSOLIDATION_SET_ID = NVL(:P_CONSOLIDATION_SET_ID, PPA.CONSOLIDATION_SET_ID)
                   AND PPA.ACTION_TYPE IN ('Q', 'R', 'B')
                   AND PTP.PERIOD_NAME LIKE '%' || :P_YEAR || '%'
                   AND (    EXTRACT(MONTH FROM PTP.END_DATE) >= :P_START_MONTH
                        AND EXTRACT(MONTH FROM PTP.END_DATE) <= :P_END_MONTH)
                   AND PPF.PAYROLL_NAME NOT IN ('02_SEM - GRBE', '02_QUIN - EVENTUAL')
                   ------------------------------------------------------
                   AND PAAF.ASSIGNMENT_ID = PAA.ASSIGNMENT_ID
                   AND PPA.DATE_EARNED BETWEEN PAAF.EFFECTIVE_START_DATE   
                                           AND PAAF.EFFECTIVE_END_DATE
                   AND PAAF.PERSON_ID = PAPF.PERSON_ID  
                   AND PPA.DATE_EARNED BETWEEN PAPF.EFFECTIVE_START_DATE
                                           AND PAPF.EFFECTIVE_END_DATE
                   AND PAPF.PERSON_ID = :P_PERSON_ID
                   AND PAA.RUN_TYPE_ID = PRTF.RUN_TYPE_ID
                   AND PPA.DATE_EARNED BETWEEN PRTF.EFFECTIVE_START_DATE
                                           AND PRTF.EFFECTIVE_END_DATE
                   AND PRTF.RUN_TYPE_NAME IN ('Process Separately', 
                                              'Process Separately - Non Periodic', 
                                              'Standard')
                 GROUP  
                    BY PAPF.PERSON_ID,
                       PAPF.EMPLOYEE_NUMBER,
                       PAPF.FULL_NAME,
                       PAPF.PER_INFORMATION2,
                       PAA.ASSIGNMENT_ID,
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
                       PPF.PERIOD_TYPE
                 ORDER 
                    BY PTP.END_DATE               
                      )  DETAIL,
                         PAY_CONSOLIDATION_SETS     PCS,
                         PER_ALL_ASSIGNMENTS_F      PAAF,
                         PAY_PAYROLLS_F             PPF
         WHERE 1 = 1
           AND PCS.CONSOLIDATION_SET_ID = DETAIL.CONSOLIDATION_SET_ID
           AND PAAF.PERSON_ID = DETAIL.PERSON_ID
           AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
           AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE 
                           AND PAAF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE
                           AND PPF.EFFECTIVE_END_DATE
         GROUP 
            BY PAAF.PERSON_ID,
               PPF.ATTRIBUTE1,
               PAAF.ASSIGNMENT_ID,
               DETAIL.EMPLOYEE_NUMBER,
               DETAIL.FULL_NAME,
               DETAIL.PER_INFORMATION2
         ORDER 
            BY TO_NUMBER(NUMERO_EMPLEADO);                             

                               
PER_ALL_PEOPLE_F
PER_ALL_ASSIGNMENTS_F



                SELECT DISTINCT
                       PAPF.PERSON_ID,
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
                       PAY_PAYROLLS_F               PPF,
                       PER_ALL_ASSIGNMENTS_F        PAAF,
                       PER_ALL_PEOPLE_F             PAPF,
                       PAY_RUN_TYPES_F              PRTF
                 WHERE 1 = 1
                   AND PTP.TIME_PERIOD_ID = PPA.TIME_PERIOD_ID
                   AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
                   AND PPA.PAYROLL_ID = PPF.PAYROLL_ID 
                   AND PTP.PAYROLL_ID = PPF.PAYROLL_ID
                    ----------Parametros de Ejecucion-----------------
                   AND SUBSTR(PPF.PAYROLL_NAME, 1, 2) = :P_COMPANY_ID    
                   AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
                   AND PPA.CONSOLIDATION_SET_ID = NVL(:P_CONSOLIDATION_SET_ID, PPA.CONSOLIDATION_SET_ID)
                   AND PPA.ACTION_TYPE IN ('Q', 'R', 'B')
                   AND PTP.PERIOD_NAME LIKE '%' || :P_YEAR || '%'
                   AND (    EXTRACT(MONTH FROM PTP.END_DATE) >= :P_START_MONTH
                        AND EXTRACT(MONTH FROM PTP.END_DATE) <= :P_END_MONTH)
                   AND PPF.PAYROLL_NAME NOT IN ('02_SEM - GRBE', '02_QUIN - EVENTUAL')
                   ------------------------------------------------------
                   AND PAAF.ASSIGNMENT_ID = PAA.ASSIGNMENT_ID
                   AND PPA.DATE_EARNED BETWEEN PAAF.EFFECTIVE_START_DATE   
                                           AND PAAF.EFFECTIVE_END_DATE
                   AND PAAF.PERSON_ID = PAPF.PERSON_ID  
                   AND PPA.DATE_EARNED BETWEEN PAPF.EFFECTIVE_START_DATE
                                           AND PAPF.EFFECTIVE_END_DATE
                   AND PAPF.PERSON_ID = :P_PERSON_ID
                   AND PAA.RUN_TYPE_ID = PRTF.RUN_TYPE_ID
                   AND PPA.DATE_EARNED BETWEEN PRTF.EFFECTIVE_START_DATE
                                           AND PRTF.EFFECTIVE_END_DATE
                   AND PRTF.RUN_TYPE_NAME IN ('Process Separately', 
                                              'Process Separately - Non Periodic', 
                                              'Standard')
                 GROUP  
                    BY PAPF.PERSON_ID,
                       PAA.ASSIGNMENT_ID,
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
                       PPF.PERIOD_TYPE
                 ORDER 
                    BY PTP.END_DATE;