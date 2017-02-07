CREATE OR REPLACE PROCEDURE APPS.PAC_PERCEP_ACUM_PRC(
        P_ERRBUF    OUT NOCOPY  VARCHAR2,
        P_RETCODE   OUT NOCOPY  VARCHAR2,
        P_COMPANY_ID            VARCHAR2,
        P_YEAR                  VARCHAR2,
        P_START_MONTH           VARCHAR2,
        P_END_MONTH             VARCHAR2,
        P_PERIOD_TYPE           VARCHAR2,
        P_PAYROLL_ID            VARCHAR2,
        P_CONSOLIDATION_SET_ID  VARCHAR2,
        P_PERSON_ID             VARCHAR2)
IS
    
    var_company_name                VARCHAR2(250);
    var_payroll_name                VARCHAR2(250);
    var_consolidation_set_name      VARCHAR2(250);
    var_data                        VARCHAR2(30000);
    
    CURSOR DETAIL_LIST IS
        SELECT PAAF.PERSON_ID,
               PAC_HR_PAY_PKG.GET_EMPLOYEE_NUMBER(PAAF.PERSON_ID)                               AS  "NUMERO_EMPLEADO",
               PAC_HR_PAY_PKG.GET_PERSON_NAME(SYSDATE, PAAF.PERSON_ID)                          AS  NOMBRE_EMPLEADO,
               PAC_HR_PAY_PKG.GET_EMPLOYEE_TAX_PAYER_ID(PAAF.PERSON_ID)                         AS  RFC,
               PAC_RESULT_VALUES_PKG.GET_EFFECTIVE_START_DATE(PAAF.PERSON_ID)                   AS  EFFECTIVE_START_DATE,
               PAC_RESULT_VALUES_PKG.GET_TYPE_MOVEMENT(PAAF.PERSON_ID, P_END_MONTH, P_YEAR)     AS  TYPE_MOVEMENT,
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
          FROM (SELECT DISTINCT
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
                       PAY_PAYROLLS_F               PPF
                 WHERE 1 = 1
                   AND PTP.TIME_PERIOD_ID = PPA.TIME_PERIOD_ID
                   AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
                   AND PPA.PAYROLL_ID = PPF.PAYROLL_ID 
                    ----------Parametros de Ejecucion-----------------
                   AND SUBSTR(PPF.PAYROLL_NAME, 1, 2) = P_COMPANY_ID    
                   AND PPA.PAYROLL_ID = NVL(P_PAYROLL_ID,  PPA.PAYROLL_ID)
                   AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(P_PERIOD_TYPE, PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
                   AND PPA.CONSOLIDATION_SET_ID = NVL(P_CONSOLIDATION_SET_ID, PPA.CONSOLIDATION_SET_ID)
                   AND PPA.ACTION_TYPE IN ('Q', 'R', 'B')
                   AND PTP.PERIOD_NAME LIKE '%' || P_YEAR || '%'
                   AND (    EXTRACT(MONTH FROM PTP.END_DATE) >= P_START_MONTH
                        AND EXTRACT(MONTH FROM PTP.END_DATE) <= P_END_MONTH)
                   AND PPF.PAYROLL_NAME NOT IN ('02_SEM - GRBE', '02_QUIN - EVENTUAL')
                   ------------------------------------------------------  
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
                       PPF.PERIOD_TYPE
                      )  DETAIL,
                         PAY_CONSOLIDATION_SETS     PCS,
                         PER_ALL_ASSIGNMENTS_F      PAAF
         WHERE 1 = 1
--           AND PAC_HR_PAY_PKG.GET_EMPLOYEE_NUMBER(PAAF.PERSON_ID) IN ('1998')
           AND PCS.CONSOLIDATION_SET_ID = DETAIL.CONSOLIDATION_SET_ID
           AND PAAF.ASSIGNMENT_ID = DETAIL.ASSIGNMENT_ID
           AND PAAF.PAYROLL_ID = DETAIL.PAYROLL_ID
           AND DETAIL.EFFECTIVE_DATE BETWEEN PAAF.EFFECTIVE_START_DATE 
                                         AND PAAF.EFFECTIVE_END_DATE
           AND PAAF.PERSON_ID = NVL(P_PERSON_ID, PAAF.PERSON_ID)
         GROUP 
            BY PAAF.PERSON_ID
         ORDER 
            BY TO_NUMBER(NUMERO_EMPLEADO);                             

                               
    
           

                   
    TYPE    DETAILS IS TABLE OF DETAIL_LIST%ROWTYPE INDEX BY PLS_INTEGER;
    
    DETAIL  DETAILS;
             
BEGIN

    dbms_output.put_line('P_COMPANY_ID : '          || P_COMPANY_ID);
    dbms_output.put_line('P_YEAR : '                || P_YEAR);
    dbms_output.put_line('P_START_MONTH : '         || P_START_MONTH);
    dbms_output.put_line('P_END_MONTH : '           || P_END_MONTH);
    dbms_output.put_line('P_PERIOD_TYPE : '         || P_PERIOD_TYPE);
    dbms_output.put_line('P_PAYROLL_ID : '          || P_PAYROLL_ID);
    dbms_output.put_line('P_CONSOLIDATION_SET_ID : ' || P_CONSOLIDATION_SET_ID);
    
    fnd_file.put_line(fnd_file.log,'P_COMPANY_ID : '          || P_COMPANY_ID);
    fnd_file.put_line(fnd_file.log,'P_YEAR : '                || P_YEAR);
    fnd_file.put_line(fnd_file.log,'P_START_MONTH : '         || P_START_MONTH);
    fnd_file.put_line(fnd_file.log,'P_END_MONTH : '           || P_END_MONTH);
    fnd_file.put_line(fnd_file.log,'P_PERIOD_TYPE : '         || P_PERIOD_TYPE);
    fnd_file.put_line(fnd_file.log,'P_PAYROLL_ID : '          || P_PAYROLL_ID);
    fnd_file.put_line(fnd_file.log,'P_CONSOLIDATION_SET_ID : ' || P_CONSOLIDATION_SET_ID);
    
         
    BEGIN
    
        SELECT 
               (SELECT UPPER(FLV.MEANING)                        
                  FROM FND_LOOKUP_VALUES    FLV
                 WHERE FLV.LOOKUP_TYPE = 'NOMINAS POR EMPLEADOR LEGAL'
                   AND FLV.LOOKUP_CODE = P_COMPANY_ID
                   AND LANGUAGE = USERENV('LANG')),
               (SELECT NVL(PPF.PAYROLL_NAME, 'TODAS')
                  FROM PAY_PAYROLLS_F   PPF
                 WHERE PPF.PAYROLL_ID LIKE P_PAYROLL_ID),
               (SELECT NVL(PCS.CONSOLIDATION_SET_NAME, 'TODOS')
                  FROM PAY_CONSOLIDATION_SETS       PCS
                 WHERE PCS.CONSOLIDATION_SET_ID LIKE P_CONSOLIDATION_SET_ID)
          INTO var_company_name, 
               var_payroll_name,
               var_consolidation_set_name
          FROM DUAL;
          
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'COMPAÑIA:,'               || var_company_name);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'AÑO,'                     || P_YEAR);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'MES INICIAL:,'            || P_START_MONTH);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'MES FINAL:,'              || P_END_MONTH);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'TIPO DE PERIODO:,'        || NVL(P_PERIOD_TYPE,              'TODOS'));
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'NOMINA:,'                 || NVL(var_payroll_name,           'TODAS'));
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'JUEGO DE CONSOLIDACION:,' || NVL(var_consolidation_set_name, 'TODOS')); 
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ',,');
    
    EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('**Error al Generar el encabezado del documento. ' || SQLERRM);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Generar el encabezado del documento. ' || SQLERRM);
    END;
    
    BEGIN
        
        var_data := 'NUMERO,'                   ||
                    'NOMBRE,'                   ||
                    'RFC,'                      ||
                    'FECHA DE INGRESO,'         ||
                    'TIPO DE MOVIMIENTO,'       ||
                    'SUELDO DIARIO BASE,'       ||
                    'SALARIO DIARIO INTEGRADO,' ||
                    'SUELDO NORMAL,'            ||
                    'HORAS EXTRA,'              ||                  
                    'HORAS EXTRA EXCENTAS I.S.R.,'||
                    'FESTIVO SIN SEPTIMO,'      ||
                    'PRIMA DOMINICAL,'          ||
                    'PRIMA DOMINICAL EXCENTA ISR,' ||
                    'VACACIONES,'               ||
                    'PRIMA VACACIONAL,'         ||
                    'PRIMA VACACIONAL EXCENTA ISR,' ||
                    'PREMIO ASISTENCIA,'        ||
                    'PREMIO ASISTENCIA EXCENTA IMSS,' ||
                    'COMISIONES,'               ||
                    'AYUDA DE ALIMENTOS,'       ||
                    'SUBSIDIO INCAPACIDAD,'     ||
                    'AGUINALDO,'                ||
                    'AGUINALDO EXCENTO ISR,'    ||
                    'SALARIOS PENDIENTES,'      ||
                    'RETROACTIVO,'              ||
                    'PREMIO DE ANTIGUEDAD,'     ||
                    'DIAS ESPECIALES,'          ||
                    'PRIMA DE ANTIGUEDAD,'      ||
                    'P.T.U.,'                   ||
                    'P.T.U. EXCENTO ISR,'       ||
                    'PASAJES,'                  ||
                    'PREMIO PUNTUALIDAD,'       ||
                    'PREMIO PUNTUALIDAD EXCENTO IMSS,' ||
                    'BONO PRODUCTIVIDAD,'       ||
                    'GRATIFICACION,'            ||
                    'AYUDA ESCOLAR,'            ||
                    'INDEMNIZACION,'            ||
                    'GRATIFICACION ESPECIAL,'   ||
                    'SUBSIDIO PARA EL EMPLEO,'  ||
                    'COMPENSACION,'             ||
                    'BECA EDUCACIONAL,'         ||
                    'AYUDA DE DEFUNCION,'       ||
                    'VACACIONES PAGADAS,'       ||
                    'BONO EXTRAORDINARIO,'      ||
                    'DESPENSA,'                 ||
                    'DESPENSA EXCENTO IMSS,'    ||
                    'FONDO AHORRO EMPRESA,'     ||
                    'PERMISO POR PATERNIDAD,'   ||
                    'BONO DE CUATRIMESTRAL,'    ||
                    'FONDO TR ACUMULADO,'       ||
                    'FONDO EM ACUMULADO,'       ||
                    'INTERES GANADO,'           ||
                    'ISPT ANUAL FAVOR,'         ||
                    'ISPT A FAVOR,'             || 
                    'I.S.P.T.,'                 ||
                    'I.M.S.S.,'                 ||
                    'INFONAVIT,'                ||
                    'FONDO AHORRO TRABAJADOR,'  ||
                    'FONDO AHORRO RETENCION EMPRESA,' ||
                    'TOTAL GRAVADO ISR,'        ||
                    'ISR SEGUN TABLA,'          ||
                    'SUBSIDIO SEGUN TABLA,'     ||
                    'AJUSTE ISPT,'              ||
                    'AJUSTE SUBSIDIO PARA EL EMPLEO, '||
                    'AJUSTE ISR SEGUN TABLA,'   ||
                    'AJUSTE SUBSIDIO SEGUN TABLA,'    ||
                    'DIAS PAGADOS';
        
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, var_data);
    
    EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('**Error al Generar el encabezado de la tabla de detalle. ' || SQLERRM);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Generar el encabezado de la tabla de detalle. ' || SQLERRM);
    END;
    
    
    BEGIN
    
        OPEN DETAIL_LIST;
        
        LOOP
        
            FETCH DETAIL_LIST 
                  BULK COLLECT INTO DETAIL LIMIT 500;
            
            EXIT WHEN DETAIL.COUNT = 0;
                  
            FOR rowIndex IN 1 .. DETAIL.COUNT
            LOOP
            
                var_data := '';
                var_data :=    DETAIL(rowIndex).NUMERO_EMPLEADO         || ',' ||
                               DETAIL(rowIndex).NOMBRE_EMPLEADO         || ',' ||
                               DETAIL(rowIndex).RFC                     || ',' ||
                               DETAIL(rowIndex).EFFECTIVE_START_DATE    || ',' ||
                               DETAIL(rowIndex).TYPE_MOVEMENT           || ',' ||
                               DETAIL(rowIndex).SUELDO_DIARIO           || ',' ||
                               DETAIL(rowIndex).SALARIO_DIARIO_INTEGRADO|| ',' ||
                               DETAIL(rowIndex).SUELDO_NORMAL           || ',' ||
                               DETAIL(rowIndex).HORAS_EXTRA             || ',' ||
                               DETAIL(rowIndex).HORAS_EXTRA_EXE         || ',' ||
                               DETAIL(rowIndex).FESTIVO_SEPTIMO_DIA     || ',' ||
                               DETAIL(rowIndex).PRIMA_DOMINICAL         || ',' ||
                               DETAIL(rowIndex).PRIMA_DOMINICAL_EXE     || ',' ||
                               DETAIL(rowIndex).VACACIONES              || ',' ||
                               DETAIL(rowIndex).PRIMA_VACACIONAL        || ',' ||
                               DETAIL(rowIndex).PRIMA_VACACIONAL_EXE    || ',' ||
                               DETAIL(rowIndex).PREMIO_ASISTENCIA       || ',' ||
                               DETAIL(rowIndex).PREMIO_ASISTENCIA_EXE   || ',' ||
                               DETAIL(rowIndex).COMISIONES              || ',' ||
                               DETAIL(rowIndex).AYUDA_ALIMENTOS         || ',' ||
                               DETAIL(rowIndex).SUBSIDIO_INCAPACIDAD    || ',' ||
                               DETAIL(rowIndex).AGUINALDO               || ',' ||
                               DETAIL(rowIndex).AGUINALDO_EXE           || ',' ||
                               DETAIL(rowIndex).SALARIOS_PENDIENTES     || ',' ||
                               DETAIL(rowIndex).RETROACTIVO             || ',' ||
                               DETAIL(rowIndex).PREMIO_ANTIGUEDAD       || ',' ||
                               DETAIL(rowIndex).DIAS_ESPECIALES         || ',' ||
                               DETAIL(rowIndex).PRIMA_ANTIGUEDAD        || ',' ||
                               DETAIL(rowIndex).PTU                     || ',' ||
                               DETAIL(rowIndex).PTU_EXE                 || ',' ||
                               DETAIL(rowIndex).PASAJES                 || ',' ||
                               DETAIL(rowIndex).PREMIO_PUNTUALIDAD      || ',' ||
                               DETAIL(rowIndex).PREMIO_PUNTUALIDAD_EXE  || ',' ||
                               DETAIL(rowIndex).BONO_PRODUCTIVIDAD      || ',' ||
                               DETAIL(rowIndex).GRATIFICACION           || ',' ||
                               DETAIL(rowIndex).AYUDA_ESCOLAR           || ',' ||
                               DETAIL(rowIndex).INDEMNIZACION           || ',' ||
                               DETAIL(rowIndex).GRATIFICACION_ESPECIAL  || ',' ||
                               DETAIL(rowIndex).SUBSIDIO_EMPLEO         || ',' ||
                               DETAIL(rowIndex).COMPENSACION            || ',' ||
                               DETAIL(rowIndex).BECA_EDUCACIONAL        || ',' ||
                               DETAIL(rowIndex).AYUDA_DEFUNCION         || ',' ||
                               DETAIL(rowIndex).VACACIONES_PAGADAS      || ',' ||
                               DETAIL(rowIndex).BONO_EXTRAORDINARIO     || ',' ||
                               DETAIL(rowIndex).DESPENSA                || ',' ||
                               DETAIL(rowIndex).DESPENSA_EXE            || ',' ||
                               DETAIL(rowIndex).FONDO_AHO_EMP           || ',' ||
                               DETAIL(rowIndex).PERMISO_PATERNIDAD      || ',' ||
                               DETAIL(rowIndex).BONO_CUATRIMESTRAL      || ',' ||
                               DETAIL(rowIndex).FONDO_TR_ACUMULADO      || ',' ||
                               DETAIL(rowIndex).FONDO_EM_ACUMULADO      || ',' ||
                               DETAIL(rowIndex).INTERES_GANADO          || ',' ||
                               DETAIL(rowIndex).ISPT_ANUAL_FAVOR        || ',' ||
                               DETAIL(rowIndex).ISPT_A_FAVOR            || ',' ||
                               DETAIL(rowIndex).ISPT                    || ',' ||
                               DETAIL(rowIndex).IMSS                    || ',' ||
                               DETAIL(rowIndex).INFONAVIT               || ',' ||
                               DETAIL(rowIndex).FONDO_AHO_TR            || ',' ||
                               DETAIL(rowIndex).FONDO_AHO_EM            || ',' ||
                               DETAIL(rowIndex).ISR_GRAVADO             || ',' ||
                               DETAIL(rowIndex).ISR_SEGUN_TABLA         || ',' ||
                               DETAIL(rowIndex).SUBSIDIO_SEGUN_TABLA    || ',' ||
                               DETAIL(rowIndex).AJUSTE_ISPT             || ',' ||
                               DETAIL(rowIndex).AJUSTE_SUBSIDIO_EMPLEO  || ',' ||
                               DETAIL(rowIndex).AJUSTE_ISR_SEGUN_TABLA  || ',' ||
                               DETAIL(rowIndex).AJUSTE_SUBSIDIO_SEGUN_TABLA || ',' ||
                               DETAIL(rowIndex).DIAS_PAGADOS            || ',';
                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, var_data);
                
            END LOOP;        
        
        END LOOP;
        
        CLOSE DETAIL_LIST;
    
    EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('**Error al Generar los registros de detalle del documento. ' || SQLERRM);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Generar los registros de detalle del documento. ' || SQLERRM);
    END;
    
EXCEPTION WHEN OTHERS THEN
    dbms_output.put_line('**Error al Ejecutar el Procedure PAC_PERCEP_Y_DEDUC_PRC. ' || SQLERRM);
    FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Ejecutar el Procedure PAC_PERCEP_Y_DEDUC_PRC. ' || SQLERRM);
END;