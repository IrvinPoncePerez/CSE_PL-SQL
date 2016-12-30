ALTER SESSION SET CURRENT_SCHEMA=APPS;
        
        SELECT DETAIL.ORGANIZATION_ID       AS ORGANIZATION_ID,
               HOUV.ATTRIBUTE7              AS  NUM_DEPARTAMENTO,            
               HOUV.NAME                    AS  DEPARTAMENTO,       
               SUM(SUELDO_NORMAL)           AS SUELDO_NORMAL,      
               SUM(HORAS_EXTRA)             AS HORAS_EXTRA,          
               SUM(FESTIVO_SEPTIMO_DIA)     AS FESTIVO_SEPTIMO_DIA,
               SUM(PRIMA_DOMINICAL)         AS PRIMA_DOMINICAL,    
               SUM(VACACIONES)              AS VACACIONES,        
               SUM(PRIMA_VACACIONAL)        AS PRIMA_VACACIONAL,   
               SUM(PREMIO_ASISTENCIA)       AS PREMIO_ASISTENCIA, 
               SUM(AYUDA_ALIMENTOS)         AS AYUDA_ALIMENTOS, 
               SUM(AYUDA_DEFUNCION)         AS AYUDA_DEFUNCION,
               SUM(COMISIONES)              AS COMISIONES,
               SUM(AGUINALDO)               AS AGUINALDO,            
               SUM(SUBSIDIO_INCAPACIDAD)    AS SUBSIDIO_INCAPACIDAD,    
               SUM(SALARIOS_PENDIENTES)     AS SALARIOS_PENDIENTES,
               SUM(PREMIO_ANTIGUEDAD)       AS PREMIO_ANTIGUEDAD,  
               SUM(DIAS_ESPECIALES)         AS DIAS_ESPECIALES,     
               SUM(PTU)                     AS PTU,     
               SUM(PRIMA_ANTIGUEDAD)        AS PRIMA_ANTIGUEDAD,  
               SUM(PASAJES)                 AS PASAJES,  
               SUM(PREMIO_PUNTUALIDAD)      AS PREMIO_PUNTUALIDAD,
               SUM(BONO_PRODUCTIVIDAD)      AS BONO_PRODUCTIVIDAD,               
               SUM(GRATIFICACION)           AS GRATIFICACION,                                                 
               SUM(AYUDA_ESCOLAR)           AS AYUDA_ESCOLAR,  
               SUM(INDEMNIZACION)           AS INDEMNIZACION,
               SUM(GRATIFICACION_ESPECIAL)  AS GRATIFICACION_ESPECIAL,
               SUM(COMPENSACION)            AS COMPENSACION,                 
               SUM(BECA_EDUCACIONAL)        AS BECA_EDUCACIONAL,         
               SUM(VACACIONES_PAGADAS)      AS VACACIONES_PAGADAS,
               SUM(BONO_EXTRAORDINARIO)     AS BONO_EXTRAORDINARIO,
               SUM(DESPENSA)                AS DESPENSA,     
               SUM(FONDO_AHORRO)            AS FONDO_AHORRO          
          FROM (SELECT DISTINCT
                       PAA.ASSIGNMENT_ACTION_ID,
                       PAA.ASSIGNMENT_ID,
                       PAAF.ORGANIZATION_ID,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P001_SUELDO NORMAL',       'Pay Value'),   '0')    AS  SUELDO_NORMAL,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P002_HORAS EXTRAS',        'Pay Value'),   '0')    AS  HORAS_EXTRA,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P003_FESTIVO SIN SEPTIMO', 'Pay Value'),   '0')    AS  FESTIVO_SEPTIMO_DIA,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P004_PRIMA DOMINICAL',     'Pay Value'),   '0')    AS  PRIMA_DOMINICAL,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P005_VACACIONES',          'Pay Value'),   '0')    AS  VACACIONES,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P006_PRIMA VACACIONAL',    'Pay Value'),   '0')    AS  PRIMA_VACACIONAL,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P007_PREMIO ASISTENCIA',   'Pay Value'),   '0')    AS  PREMIO_ASISTENCIA,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P010 AYUDA DE ALIMENTOS',  'Pay Value'),   '0')    AS  AYUDA_ALIMENTOS,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P008_AYUDA DE DEFUNCION',  'Pay Value'),   '0')    AS  AYUDA_DEFUNCION,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P009_COMISIONES',          'Pay Value'),   '0')    AS  COMISIONES,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P011_AGUINALDO',           'Pay Value'),   '0')    AS  AGUINALDO,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P012_SUBSIDIO INCAPACIDAD','Pay Value'),   '0')    AS  SUBSIDIO_INCAPACIDAD,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P013_SALARIOS PENDIENTES', 'Pay Value'),   '0')    AS  SALARIOS_PENDIENTES,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P014_PREMIO ANTIGÜEDAD',   'Pay Value'),   '0')    AS  PREMIO_ANTIGUEDAD,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P015_DIAS ESPECIALES',     'Pay Value'),   '0')    AS  DIAS_ESPECIALES,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'Profit Sharing',           'Pay Value'),   '0')    AS  PTU,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P017_PRIMA DE ANTIGUEDAD', 'Pay Value'),   '0')    AS  PRIMA_ANTIGUEDAD,   
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P021_PASAJES',             'Pay Value'),   '0')    AS  PASAJES,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P022_PREMIO_PUNTUALIDAD',  'Pay Value'),   '0')    AS  PREMIO_PUNTUALIDAD,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P023_BONO_PRODUCTIVIDAD',  'Pay Value'),   '0')    AS  BONO_PRODUCTIVIDAD,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P024_GRATIFICACION',       'Pay Value'),   '0')    AS  GRATIFICACION,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P025_AYUDA_ESCOLAR',       'Pay Value'),   '0')    AS  AYUDA_ESCOLAR,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P026_INDEMNIZACION',       'Pay Value'),   '0')    AS  INDEMNIZACION,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P027_GRATIFIC_ESP',        'Pay Value'),   '0')    AS  GRATIFICACION_ESPECIAL,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P035_COMPENSACION',        'Pay Value'),   '0')    AS  COMPENSACION,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P036_BECA_EDUCACIONAL',    'Pay Value'),   '0')    AS  BECA_EDUCACIONAL,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P037_VACACIONES P',        'Pay Value'),   '0')    AS  VACACIONES_PAGADAS,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P038_BONO EXTRAORD',       'Pay Value'),   '0')    AS  BONO_EXTRAORDINARIO,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,        'P039_DESPENSA',            'Pay Value'),   '0')    AS  DESPENSA,
                       NVL(apps.PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,      'D091_FONDO DE AHORRO EMPRESA', 'Pay Value'), '0')  AS  FONDO_AHORRO
                  FROM PAY_PAYROLL_ACTIONS          PPA,
                       PER_TIME_PERIODS             PTP,
                       PAY_ASSIGNMENT_ACTIONS       PAA,
                       PAY_PAYROLLS_F               PPF,
                       PER_ALL_ASSIGNMENTS_F        PAAF
                 WHERE PTP.TIME_PERIOD_ID = PPA.TIME_PERIOD_ID
                   AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
                   AND PPA.PAYROLL_ID = PPF.PAYROLL_ID  
                   AND SUBSTR(PPF.PAYROLL_NAME, 1, 2) = :P_COMPANY_ID    
                   AND PPA.ACTION_TYPE IN ('Q', 'R')             
                   AND PTP.PERIOD_NAME LIKE '%' || :P_YEAR || '%'
                   AND (EXTRACT(MONTH FROM PTP.END_DATE) >= :P_START_MONTH
                    AND EXTRACT(MONTH FROM PTP.END_DATE) <= :P_END_MONTH)
                   AND PAA.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
                   AND PPF.ATTRIBUTE1 NOT IN ('GRQE', 'GRBE')
                   AND PPA.EFFECTIVE_DATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
                   ------------------------------------------------------  
                 GROUP BY PAA.ASSIGNMENT_ID,
                          PPF.ATTRIBUTE1,
                          PTP.END_DATE,
                          PTP.PERIOD_NUM,
                          PPA.PAYROLL_ACTION_ID,
                          PAA.ASSIGNMENT_ACTION_ID,
                          PPA.CONSOLIDATION_SET_ID,
                          PPA.EFFECTIVE_DATE,
                          PTP.START_DATE,
                          PTP.END_DATE,
                          PPA.ACTION_TYPE,
                          PAAF.ORGANIZATION_ID
                      )  DETAIL
         RIGHT JOIN HR_ORGANIZATION_UNITS_V HOUV ON HOUV.ORGANIZATION_ID = DETAIL.ORGANIZATION_ID
         WHERE 1 = 1
           AND HOUV.ORGANIZATION_TYPE = 'DEPARTAMENTO'
         GROUP BY  DETAIL.ORGANIZATION_ID,
                   HOUV.ATTRIBUTE7,   
                   HOUV.NAME
         ORDER BY  NUM_DEPARTAMENTO,       
                   DEPARTAMENTO;
