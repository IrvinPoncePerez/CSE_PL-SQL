            SELECT PAAF.ASS_ATTRIBUTE15                                                             AS  EMPRESA,
                   CLAVE_NOMINA,
                   (SELECT HOUV.NAME
                              FROM HR_ORGANIZATION_UNITS_V      HOUV
                             WHERE HOUV.ORGANIZATION_ID = PAAF.ORGANIZATION_ID)                     AS  DEPARTAMENTO,
                   PAC_HR_PAY_PKG.GET_NAME_JOB(PAAF.PERSON_ID)                                      AS  PUESTO,                         
                   PAC_HR_PAY_PKG.GET_EMPLOYEE_NUMBER(PAAF.PERSON_ID)                               AS  NUMERO_EMPLEADO,
                   PAC_HR_PAY_PKG.GET_PERSON_NAME(SYSDATE, PAAF.PERSON_ID)                          AS  NOMBRE_EMPLEADO,
                   PAC_HR_PAY_PKG.GET_EMPLOYEE_TAX_PAYER_ID(PERSON_ID)                              AS  RFC,
                   PAC_HR_PAY_PKG.GET_EMPLOYEE_SSID(PERSON_ID)                                      AS  NSS,
                   ANIO,
                   MES,
                   NUM_NOMINA,
--                   (ACTION_TYPE || ' - ' || RUN_TYPE_NAME)                                          AS  TIPO_EJECUCION,
                   PAC_HR_PAY_PKG.GET_EMPLOYER_REGISTRATION(DETAIL.ASSIGNMENT_ID)                   AS  REG_PATRONAL,
                   PCS.CONSOLIDATION_SET_NAME   AS  JUEGO_CONSOLIDACION,
                   PAC_RESULT_VALUES_PKG.GET_EFFECTIVE_START_DATE(PERSON_ID)                        AS  EFFECTIVE_START_DATE,
                   PAC_RESULT_VALUES_PKG.GET_DATA_MOVEMENT(PERSON_ID, 'A', START_DATE, END_DATE)    AS  TIPO_A,
                   PAC_RESULT_VALUES_PKG.GET_DATA_MOVEMENT(PERSON_ID, 'B', START_DATE, END_DATE)    AS  TIPO_B,
                   PAC_RESULT_VALUES_PKG.GET_DATA_MOVEMENT(PERSON_ID, 'MS', START_DATE, END_DATE)   AS  TIPO_MS,
                   MAX(SUELDO_DIARIO)       AS  SUELDO_DIARIO,
                   MAX(SALARIO_DIARIO_INTEGRADO) AS SALARIO_DIARIO_INTEGRADO,
                   MAX(CREDITO_INFONAVIT)    AS CREDITO_INFONAVIT,
                   MAX(FECHA_INFONAVIT)      AS FECHA_INFONAVIT,
                   MAX(TIPO_INFONAVIT)       AS TIPO_INFONAVIT,
                   MAX(VALOR_INFONAVIT)      AS VALOR_INFONAVIT,                
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
                   SUM(FINANCIAMIENTO_IMSS)  AS FINANCIAMIENTO_IMSS,
                   (   SUM(SUELDO_NORMAL)        +
                       SUM(HORAS_EXTRA)          +
                       SUM(FESTIVO_SEPTIMO_DIA)  +
                       SUM(PRIMA_DOMINICAL)      +
                       SUM(VACACIONES)           +
                       SUM(PRIMA_VACACIONAL)     +
                       SUM(PREMIO_ASISTENCIA)    +
                       SUM(COMISIONES)           +
                       SUM(SUBSIDIO_INCAPACIDAD) +
                       SUM(AGUINALDO)            +
                       SUM(SALARIOS_PENDIENTES)  +
                       SUM(RETROACTIVO)          +
                       SUM(PREMIO_ANTIGUEDAD)    +
                       SUM(DIAS_ESPECIALES)      +
                       SUM(PRIMA_ANTIGUEDAD)     +
                       SUM(PTU)                  +
                       SUM(PASAJES)              +
                       SUM(PREMIO_PUNTUALIDAD)   +
                       SUM(BONO_PRODUCTIVIDAD)   +
                       SUM(GRATIFICACION)        +
                       SUM(AYUDA_ESCOLAR)        +
                       SUM(GRATIFICACION_ESPECIAL) +
                       SUM(SUBSIDIO_EMPLEO)      +
                       SUM(COMPENSACION)         +
                       SUM(BECA_EDUCACIONAL)     +
                       SUM(AYUDA_DEFUNCION)      +
                       SUM(VACACIONES_PAGADAS)   +
                       SUM(BONO_EXTRAORDINARIO)  +
                       SUM(FONDO_AHO_EMP)        +
                       SUM(PERMISO_PATERNIDAD)   +
                       SUM(BONO_CUATRIMESTRAL)   +
                       SUM(FONDO_TR_ACUMULADO)   +
                       SUM(FONDO_EM_ACUMULADO)   +
                       SUM(INTERES_GANADO)       +
                       SUM(ISPT_ANUAL_FAVOR)     +
                       SUM(FINANCIAMIENTO_IMSS))        AS PERCEPCIONES_BRUTAS,
                   SUM(INC_EG)            AS INC_EG,
                   SUM(INC_MA)            AS INC_MA,
                   SUM(INC_RT)            AS INC_RT,
                   SUM(AUSENCIAS)         AS AUSENCIAS,
                   SUM(PERMISOS)          AS PERMISOS,
                   SUM(PATERNIDAD)        AS PATERNIDAD,
                   SUM(SUSPENSIONES)      AS SUSPENSIONES,
                   SUM(ISPT)              AS ISPT,               
                   SUM(IMSS)              AS IMSS,               
                   SUM(CUOTA_SINDICAL)    AS CUOTA_SINDICAL,     
                   SUM(INFONAVIT)         AS INFONAVIT,          
                   SUM(FONACOT)           AS FONACOT,            
                   SUM(FINAN_INFONAVIT)   AS FINAN_INFONAVIT,    
                   SUM(LLAMADAS)          AS LLAMADAS,           
                   SUM(ANTICIPOS)         AS ANTICIPOS,          
                   SUM(CAJA_AHORRO)       AS CAJA_AHORRO,        
                   SUM(PRESTAMO_AHORRO)   AS PRESTAMO_AHORRO,    
                   SUM(CUOTA_SINDICAL_EXT) AS CUOTA_SINDICAL_EXT, 
                   SUM(VARIOS_QYL)        AS VARIOS_QYL,         
                   SUM(PENSION_ALIMENTICIA) AS PENSION_ALIMENTICIA,
                   SUM(EXCEDENTE_ALIMENTOS) AS EXCEDENTE_ALIMENTOS,
                   SUM(GAS)               AS GAS,                
                   SUM(CALZADO)           AS CALZADO,            
                   SUM(FONDO_AHO_TR)      AS FONDO_AHO_TR,       
                   SUM(DESCUENTO_GR)      AS DESCUENTO_GR,
                   SUM(FONDO_AHO_EM)      AS FONDO_AHO_EM,       
                   SUM(REPARACION)        AS REPARACION,         
                   SUM(HUEVO)             AS HUEVO,              
                   SUM(MEDICINA)          AS MEDICINA,           
                   SUM(FALTANTES)         AS FALTANTES,          
                   SUM(ANALISIS_CLIN)     AS ANALISIS_CLIN,      
                   SUM(LLANTAS)           AS LLANTAS,            
                   SUM(OPTICA)            AS OPTICA,        
                   SUM(ISPT_ANUAL_CARGO)  AS ISPT_ANUAL_CARGO,
                   (  SUM(ISPT)                 +
                      SUM(IMSS)                 +
                      SUM(CUOTA_SINDICAL)       +
                      SUM(INFONAVIT)            +
                      SUM(FONACOT)              +
                      SUM(FINAN_INFONAVIT)      +
                      SUM(LLAMADAS)             +
                      SUM(ANTICIPOS)            +
                      SUM(CAJA_AHORRO)          +
                      SUM(PRESTAMO_AHORRO)      +
                      SUM(CUOTA_SINDICAL_EXT)   +
                      SUM(VARIOS_QYL)           +
                      SUM(PENSION_ALIMENTICIA)  +
                      SUM(EXCEDENTE_ALIMENTOS)  +
                      SUM(GAS)                  +
                      SUM(CALZADO)              +
                      SUM(FONDO_AHO_TR)         +
                      SUM(DESCUENTO_GR)         +
                      SUM(FONDO_AHO_EM)         +
                      SUM(REPARACION)           +
                      SUM(HUEVO)                +
                      SUM(MEDICINA)             +
                      SUM(FALTANTES)            +
                      SUM(ANALISIS_CLIN)        +
                      SUM(LLANTAS)              +
                      SUM(OPTICA)               +
                      SUM(ISPT_ANUAL_CARGO))        AS DEDUCCIONES_BRUTAS,
                  ((   SUM(SUELDO_NORMAL)        +
                       SUM(HORAS_EXTRA)          +
                       SUM(FESTIVO_SEPTIMO_DIA)  +
                       SUM(PRIMA_DOMINICAL)      +
                       SUM(VACACIONES)           +
                       SUM(PRIMA_VACACIONAL)     +
                       SUM(PREMIO_ASISTENCIA)    +
                       SUM(COMISIONES)           +
                       SUM(SUBSIDIO_INCAPACIDAD) +
                       SUM(AGUINALDO)            +
                       SUM(SALARIOS_PENDIENTES)  +
                       SUM(RETROACTIVO)          +
                       SUM(PREMIO_ANTIGUEDAD)    +
                       SUM(DIAS_ESPECIALES)      +
                       SUM(PRIMA_ANTIGUEDAD)     +
                       SUM(PTU)                  +
                       SUM(PASAJES)              +
                       SUM(PREMIO_PUNTUALIDAD)   +
                       SUM(BONO_PRODUCTIVIDAD)   +
                       SUM(GRATIFICACION)        +
                       SUM(AYUDA_ESCOLAR)        +
                       SUM(GRATIFICACION_ESPECIAL) +
                       SUM(SUBSIDIO_EMPLEO)      +
                       SUM(COMPENSACION)         +
                       SUM(BECA_EDUCACIONAL)     +
                       SUM(AYUDA_DEFUNCION)      +
                       SUM(VACACIONES_PAGADAS)   +
                       SUM(BONO_EXTRAORDINARIO)  +
                       SUM(FONDO_AHO_EMP)        +
                       SUM(PERMISO_PATERNIDAD)   +
                       SUM(BONO_CUATRIMESTRAL)   +
                       SUM(FONDO_TR_ACUMULADO)   +
                       SUM(FONDO_EM_ACUMULADO)   +
                       SUM(INTERES_GANADO)       +
                       SUM(ISPT_ANUAL_FAVOR)     +
                       SUM(FINANCIAMIENTO_IMSS)  ) - (   
                                                  SUM(ISPT)                 +
                                                  SUM(IMSS)                 +
                                                  SUM(CUOTA_SINDICAL)       +
                                                  SUM(INFONAVIT)            +
                                                  SUM(FONACOT)              +
                                                  SUM(FINAN_INFONAVIT)      +
                                                  SUM(LLAMADAS)             +
                                                  SUM(ANTICIPOS)            +
                                                  SUM(CAJA_AHORRO)          +
                                                  SUM(PRESTAMO_AHORRO)      +
                                                  SUM(CUOTA_SINDICAL_EXT)   +
                                                  SUM(VARIOS_QYL)           +
                                                  SUM(PENSION_ALIMENTICIA)  +
                                                  SUM(EXCEDENTE_ALIMENTOS)  +
                                                  SUM(GAS)                  +
                                                  SUM(CALZADO)              +
                                                  SUM(FONDO_AHO_TR)         +
                                                  SUM(DESCUENTO_GR)         +
                                                  SUM(FONDO_AHO_EM)         +
                                                  SUM(REPARACION)           +
                                                  SUM(HUEVO)                +
                                                  SUM(MEDICINA)             +
                                                  SUM(FALTANTES)            +
                                                  SUM(ANALISIS_CLIN)        +
                                                  SUM(LLANTAS)              +
                                                  SUM(OPTICA)               +
                                                  SUM(ISPT_ANUAL_CARGO)     ))  AS NETO_A_PAGAR,
                   SUM(ISR_GRAVADO)       AS ISR_GRAVADO,
                   SUM(DIAS_PAGADOS)      AS DIAS_PAGADOS,
                   SUM(IMPUESTO_ESTATAL)  AS IMPUESTO_ESTATAL,
                   SUM(IMSS_PATRONAL)     AS IMSS_PATRONAL,
                   SUM(INFONAVIT_PATRONAL) AS INFONAVIT_PATRONAL,
                   (  SUM(SUELDO_NORMAL)        +
                      SUM(HORAS_EXTRA)          +
                      SUM(FESTIVO_SEPTIMO_DIA)  +
                      SUM(PRIMA_DOMINICAL)      +
                      SUM(VACACIONES)           +
                      SUM(PRIMA_VACACIONAL)     +
                      SUM(PREMIO_ASISTENCIA)    +
                      SUM(COMISIONES)           +
                      SUM(SUBSIDIO_INCAPACIDAD) +
                      SUM(AGUINALDO)            +
                      SUM(SALARIOS_PENDIENTES)  +
                      SUM(RETROACTIVO)          +
                      SUM(PREMIO_ANTIGUEDAD)    +
                      SUM(DIAS_ESPECIALES)      +
                      SUM(PRIMA_ANTIGUEDAD)     +
                      SUM(PASAJES)              +
                      SUM(PREMIO_PUNTUALIDAD)   +
                      SUM(BONO_PRODUCTIVIDAD)   +
                      SUM(GRATIFICACION)        +
                      SUM(AYUDA_ESCOLAR)        +
                      SUM(GRATIFICACION_ESPECIAL) +
                      SUM(COMPENSACION)         +
                      SUM(BECA_EDUCACIONAL)     +
                      SUM(AYUDA_DEFUNCION)      +
                      SUM(VACACIONES_PAGADAS)   +
                      SUM(BONO_EXTRAORDINARIO)  +
                      SUM(PERMISO_PATERNIDAD)   +
                      SUM(BONO_CUATRIMESTRAL))    AS COSTO_SUELDOS,
                   SUM(DESPENSA)                  AS COSTO_DESPENSA,
                   SUM(FONDO_AHO_EMP)             AS COSTO_FONDO_AHORRO,
                   (((  SUM(SUELDO_NORMAL)        +
                        SUM(HORAS_EXTRA)          +
                        SUM(FESTIVO_SEPTIMO_DIA)  +
                        SUM(PRIMA_DOMINICAL)      +
                        SUM(VACACIONES)           +
                        SUM(PRIMA_VACACIONAL)     +
                        SUM(PREMIO_ASISTENCIA)    +
                        SUM(COMISIONES)           +
                        SUM(SUBSIDIO_INCAPACIDAD) +
                        SUM(AGUINALDO)            +
                        SUM(SALARIOS_PENDIENTES)  +
                        SUM(RETROACTIVO)          +
                        SUM(PREMIO_ANTIGUEDAD)    +
                        SUM(DIAS_ESPECIALES)      +
                        SUM(PRIMA_ANTIGUEDAD)     +
                        SUM(PASAJES)              +
                        SUM(PREMIO_PUNTUALIDAD)   +
                        SUM(BONO_PRODUCTIVIDAD)   +
                        SUM(GRATIFICACION)        +
                        SUM(AYUDA_ESCOLAR)        +
                        SUM(GRATIFICACION_ESPECIAL) +
                        SUM(COMPENSACION)         +
                        SUM(BECA_EDUCACIONAL)     +
                        SUM(AYUDA_DEFUNCION)      +
                        SUM(VACACIONES_PAGADAS)   +
                        SUM(BONO_EXTRAORDINARIO)  +
                        SUM(PERMISO_PATERNIDAD)   +
                        SUM(BONO_CUATRIMESTRAL))  +        
                        SUM(DESPENSA)             +
                        SUM(FONDO_AHO_EMP)        + 
                        SUM(IMPUESTO_ESTATAL)     +
                        SUM(IMSS_PATRONAL)        +
                        SUM(INFONAVIT_PATRONAL)) * PORCENTAJE) AS PORCENTAJE_UTILIDAD,
                           SUM(SUBSIDIO_SEGUN_TABLA) AS SUBSIDIO_SEGUN_TABLA,
                           SUM(ISR_SEGUN_TABLA)      AS ISR_SEGUN_TABLA,
                           SUM(AJUSTE_ISPT)          AS AJUSTE_ISPT,
                           SUM(AJUSTE_SUBSIDIO_EMPLEO)      AS AJUSTE_SUBSIDIO_EMPLEO,
                           SUM(AJUSTE_ISR_SEGUN_TABLA)      AS AJUSTE_ISR_SEGUN_TABLA,
                           SUM(AJUSTE_SUBSIDIO_SEGUN_TABLA) AS AJUSTE_SUBSIDIO_SEGUN_TABLA
              FROM (SELECT DISTINCT
                           PPA.PAYROLL_ACTION_ID,
                           PAA.ASSIGNMENT_ID,
                           PAA.ASSIGNMENT_ACTION_ID,
                           PPF.PAYROLL_ID,
                           PPA.CONSOLIDATION_SET_ID,
                           PPA.EFFECTIVE_DATE,
                           PTP.START_DATE,
                           PTP.END_DATE,
--                           PTF.RUN_TYPE_NAME,
                           (SELECT meaning 
                              FROM HR_LOOKUPS 
                             WHERE LOOKUP_TYPE = 'ACTION_TYPE'
                               AND LOOKUP_CODE = PPA.ACTION_TYPE )                                  AS  ACTION_TYPE,
                           PPF.ATTRIBUTE1                                                           AS  CLAVE_NOMINA,
                           EXTRACT(YEAR FROM PTP.END_DATE)                                          AS  ANIO,
                           EXTRACT(MONTH FROM PTP.END_DATE)                                         AS  MES,
                           PTP.PERIOD_NUM                                                           AS  NUM_NOMINA,
                           -----------------------------------------------------------------------------------------
                           NVL(apps.PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAA.ASSIGNMENT_ACTION_ID,      'I001_SALARIO_DIARIO',      'Pay Value'), '0')    AS  SUELDO_DIARIO,
                           NVL(apps.PAC_RESULT_VALUES_PKG.GET_INFORMATION_VALUE(PAA.ASSIGNMENT_ACTION_ID,'Integrated Daily Wage',    'Pay Value'), '0')    AS  SALARIO_DIARIO_INTEGRADO,
                           NVL(apps.PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P001_SUELDO NORMAL',       'Pay Value'), '0')    AS  SUELDO_NORMAL,
                           -----------------------------------------------------------------------------------------
                           ----                                 DATOS INFONAVIT
                           -----------------------------------------------------------------------------------------
                           apps.PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAA.ASSIGNMENT_ACTION_ID,          'D058_INFONAVIT',           'Credit Number')      AS  CREDITO_INFONAVIT,
                           (CASE 
                            WHEN apps.PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'D058_INFONAVIT',           'Discount Start Date') IS NOT NULL THEN
                                SUBSTR(apps.PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAA.ASSIGNMENT_ACTION_ID,'D058_INFONAVIT',         'Discount Start Date'), 1, 11)
                            END)                                                                                                                      AS  FECHA_INFONAVIT,
                           (CASE apps.PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'D058_INFONAVIT',           'Discount Type')
                              WHEN 'P' THEN '1'
                              WHEN 'C' THEN '2'
                              WHEN 'V' THEN '3'
                              ELSE apps.PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D058_INFONAVIT',           'Discount Type')
                            END)                                                                                                                      AS  TIPO_INFONAVIT,
                           apps.PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAA.ASSIGNMENT_ACTION_ID,          'D058_INFONAVIT',           'Discount Value')     AS  VALOR_INFONAVIT,
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
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P012_SUBSIDIO INCAPACIDAD','Pay Value'),   '0')    AS  SUBSIDIO_INCAPACIDAD,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P011_AGUINALDO',           'Pay Value'),   '0')    AS  AGUINALDO,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P011_AGUINALDO',           'ISR Exempt'),  '0')    AS  AGUINALDO_EXE,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P013_SALARIOS PENDIENTES', 'Pay Value'),   '0')    AS  SALARIOS_PENDIENTES,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P044_RETROACTIVO',         'Pay Value'),   '0')    AS  RETROACTIVO,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P014_PREMIO ANTIGÜEDAD',   'Pay Value'),   '0')    AS  PREMIO_ANTIGUEDAD,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P015_DIAS ESPECIALES',     'Pay Value'),   '0')    AS  DIAS_ESPECIALES,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P017_PRIMA DE ANTIGUEDAD', 'Pay Value'),   '0')    AS  PRIMA_ANTIGUEDAD,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'Profit Sharing',           'Pay Value'),   '0')    AS  PTU,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'Profit Sharing',           'ISR Exempt'),  '0')    AS  PTU_EXE,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P021_PASAJES',             'Pay Value'),   '0')    AS  PASAJES,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P022_PREMIO_PUNTUALIDAD',  'Pay Value'),   '0')    AS  PREMIO_PUNTUALIDAD,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EXEMPT_VALUE(PAA.ASSIGNMENT_ACTION_ID,     'P022_PREMIO_PUNTUALIDAD',  'Pay Value',    'TOPE'), '0')   AS  PREMIO_PUNTUALIDAD_EXE,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P023_BONO_PRODUCTIVIDAD',  'Pay Value'),   '0')    AS  BONO_PRODUCTIVIDAD,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P024_GRATIFICACION',       'Pay Value'),   '0')    AS  GRATIFICACION,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P025_AYUDA_ESCOLAR',       'Pay Value'),   '0')    AS  AYUDA_ESCOLAR,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P027_GRATIFIC_ESP',        'Pay Value'),   '0')    AS  GRATIFICACION_ESPECIAL, --P027_GRATIFICACION_ESP
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P032_SUBSIDIO_PARA_EMPLEO','Pay Value'),   '0')    AS  SUBSIDIO_EMPLEO,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P035_COMPENSACION',        'Pay Value'),   '0')    AS  COMPENSACION, 
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P036_BECA_EDUCACIONAL',    'Pay Value'),   '0')    AS  BECA_EDUCACIONAL,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P008_AYUDA DE DEFUNCION',  'Pay Value'),   '0')    AS  AYUDA_DEFUNCION,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P037_VACACIONES P',        'Pay Value'),   '0')    AS  VACACIONES_PAGADAS,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P038_BONO EXTRAORD',       'Pay Value'),   '0')    AS  BONO_EXTRAORDINARIO,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P039_DESPENSA',            'Pay Value'),   '0')    AS  DESPENSA,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DESPENSA_EXEMPT(PAA.ASSIGNMENT_ACTION_ID, PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P039_DESPENSA',            'Pay Value'), PPA.EFFECTIVE_DATE),   '0')    AS  DESPENSA_EXE,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P043_FONDO AHORRO EMP',    'Pay Value'),   '0')    AS  FONDO_AHO_EMP,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P045_PERMISO X PATERNIDAD','Pay Value'),   '0')    AS  PERMISO_PATERNIDAD,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P046_BONO CUATRIMESTRAL',  'Pay Value'),   '0')    AS  BONO_CUATRIMESTRAL,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P080_FONDO AHORRO TR ACUM','Pay Value'),   '0')    AS  FONDO_TR_ACUMULADO,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P091_FONDO AHORRO E ACUM', 'Pay Value'),   '0')    AS  FONDO_EM_ACUMULADO,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P042_INTERES_GANADO',      'Pay Value'),   '0')    AS  INTERES_GANADO,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P047_ISPT ANUAL A FAVOR',  'Pay Value'),   '0')    AS  ISPT_ANUAL_FAVOR,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'P047_ISPT_A_FAVOR',        'Pay Value'),   '0')    AS  ISPT_A_FAVOR,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'FINAN_TRABAJO_RET',        'Pay Value'),   '0')    AS  FINANCIAMIENTO_IMSS,
                           ---------------------------------------------------------------------------------------
                           --                     DETALLE DE          AUSENCIAS
                           ---------------------------------------------------------------------------------------  
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'A002_INCAPACIDAD GENERAL', 'Dias Normales'),'0')   AS  INC_EG,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'A003_INCAP MATERNIDAD',    'Dias Normales'),'0')   AS  INC_MA,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'A004_INCAP RIES TRABAJO',  'Dias Normales'),'0')   AS  INC_RT,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'A001_AUSENTISMO',          'Dias Normales'),'0')   AS  AUSENCIAS,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'A005_PERMISO SIN GOCE',    'Dias Normales'),'0')   AS  PERMISOS,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'A007_PERMISO PATERNIDAD',  'Dias Normales'),'0')   AS  PATERNIDAD,
                           NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,    'A006_SUSPENSION',          'Dias Normales'),'0')   AS  SUSPENSIONES,
                           ---------------------------------------------------------------------------------------
                           --                     DETALLE DE          DEDUCCIONES
                           ---------------------------------------------------------------------------------------  
                           NVL(PAC_RESULT_VALUES_PKG.GET_INFORMATION_VALUE(PAA.ASSIGNMENT_ACTION_ID,'D055_ISPT',                'Pay Value'),   '0')    AS  ISPT, --D066_ISPT
                           NVL(PAC_RESULT_VALUES_PKG.GET_INFORMATION_VALUE(PAA.ASSIGNMENT_ACTION_ID,'D056_IMSS',                'Pay Value'),   '0')    AS  IMSS,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D057_CUOTA_SINDICAL',      'Pay Value'),   '0')    AS  CUOTA_SINDICAL,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D058_INFONAVIT',           'Pay Value'),   '0')    AS  INFONAVIT,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D059_FONACOT',             'Pay Value'),   '0')    AS  FONACOT, 
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D062_FIN_CRED_INFONAVIT',  'Pay Value'),   '0')    AS  FINAN_INFONAVIT,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D065_LLAM_TELEFONICAS',    'Pay Value'),   '0')    AS  LLAMADAS,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D066_ANTICIPO_SUELDO',     'Pay Value'),   '0')    AS  ANTICIPOS,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D071_CAJA DE AHORRO',      'Pay Value'),   '0')    AS  CAJA_AHORRO,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D072_PRESTAMO CAJA DE AHORRO','Pay Value'),'0')    AS  PRESTAMO_AHORRO,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D073_CUOTA_SINDICAL_EXTRAORDINARIA','Pay Value'),   '0')    AS  CUOTA_SINDICAL_EXT, --D073_CUOTA_SINDICAL_EXT
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D074_VARIOS_QYL',          'Pay Value'),   '0')    AS  VARIOS_QYL,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D076_DESC_PENSION_ALIM',   'Pay Value'),   '0')    AS  PENSION_ALIMENTICIA,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D077_EXEDENTE_ALIMENTOS',  'Pay Value'),   '0')    AS  EXCEDENTE_ALIMENTOS,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D078_FINAN_COMPRA_GAS',    'Pay Value'),   '0')    AS  GAS,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D079_FINAN_CALZADO_IND',   'Pay Value'),   '0')    AS  CALZADO,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D080_FONDO AHORRO TRABAJADOR','Pay Value'),'0')    AS  FONDO_AHO_TR,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D090_DESCUENTOS_VARIOS',   'Pay Value'),   '0')    AS  DESCUENTO_GR, --D090_DESCUENTOS_GR    
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D091_FONDO DE AHORRO EMPRESA','Pay Value'),'0')    AS  FONDO_AHO_EM,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D081_REPARACION_UNIDAD',   'Pay Value'),   '0')    AS  REPARACION,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D082_FALTANTE_HUEVO',      'Pay Value'),   '0')    AS  HUEVO,          --Pendiente  
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D083_FINAN_MEDICINA',      'Pay Value'),   '0')    AS  MEDICINA,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D084_FALTANTES',           'Pay Value'),   '0')    AS  FALTANTES,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D085_FIN_ANALISIS_CLIN',   'Pay Value'),   '0')    AS  ANALISIS_CLIN,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D086_LLANTAS_DAÑADAS',     'Pay Value'),   '0')    AS  LLANTAS,        --Pendiente
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D087_FINAN_OPTICA',        'Pay Value'),   '0')    AS  OPTICA,
                           NVL(PAC_RESULT_VALUES_PKG.GET_INFORMATION_VALUE(PAA.ASSIGNMENT_ACTION_ID,'I003_INFONAVIT PATRONAL',  'Pay Value'),   '0')    AS  INFONAVIT_PATRONAL,
                           NVL(PAC_RESULT_VALUES_PKG.GET_DEDUCTION_VALUE(PAA.ASSIGNMENT_ACTION_ID,  'D092_ISPT ANUAL A CARGO',  'Pay Value'),   '0')    AS  ISPT_ANUAL_CARGO,
                           ---------------------------------------------------------------------------------------
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
                           ---------------------------------------------------------------------------------------
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
                           (NVL((SELECT 
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
                                  ), '0'))                                                         AS  DIAS_PAGADOS,
                           NVL(apps.PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAA.ASSIGNMENT_ACTION_ID,      'Employer State Tax Liability','Pay Value'),'0')    AS  IMPUESTO_ESTATAL,
                           NVL(apps.PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAA.ASSIGNMENT_ACTION_ID,      'Social Security Quota Calculation ER','Pay Value'),'0')    AS  IMSS_PATRONAL,
                           (SELECT (TO_NUMBER(REPLACE(MEANING, '%', '')) / 100)       
                              FROM FND_LOOKUP_VALUES
                             WHERE LOOKUP_TYPE = 'XXCALV_DETALLE_PERC_DEDUCC'
                               AND LOOKUP_CODE = 'PORCENTAJE'
                               AND LANGUAGE = 'ESA')                                               AS  PORCENTAJE 
                      FROM PAY_PAYROLL_ACTIONS          PPA,
                           PER_TIME_PERIODS             PTP,
                           PAY_ASSIGNMENT_ACTIONS       PAA,
                           PAY_PAYROLLS_F               PPF
--                           PAY_RUN_TYPES_F              PTF
                     WHERE PTP.TIME_PERIOD_ID = PPA.TIME_PERIOD_ID
                       AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
                       AND PPA.PAYROLL_ID = PPF.PAYROLL_ID 
--                       AND PAA.RUN_TYPE_ID = PTF.RUN_TYPE_ID
                        ----------Parametros de Ejecucion-----------------
                       AND SUBSTR(PPF.PAYROLL_NAME, 1, 2) = :P_COMPANY_ID    
                       AND PPA.PAYROLL_ID = NVL(:P_PAYROLL_ID,  PPA.PAYROLL_ID)
                       AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
                       AND PPA.CONSOLIDATION_SET_ID = NVL(:P_CONSOLIDATION_SET_ID, PPA.CONSOLIDATION_SET_ID)
                       AND PPA.ACTION_TYPE IN ('Q', 'R', 'B')             
                       AND PTP.PERIOD_NAME LIKE '%' || :P_YEAR || '%'
                       AND PTP.PERIOD_NAME = NVL(:P_PERIOD_NAME, PTP.PERIOD_NAME)
                       AND (EXTRACT(MONTH FROM PTP.END_DATE) >= :P_START_MONTH
                        AND EXTRACT(MONTH FROM PTP.END_DATE) <= :P_END_MONTH)
                       ------------------------------------------------------  
                     GROUP BY PAA.ASSIGNMENT_ID,
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
--                              PTF.RUN_TYPE_NAME,
                              PPA.ACTION_TYPE,
                              PPA.DATE_EARNED
                          )  DETAIL,
                             PAY_CONSOLIDATION_SETS     PCS,
                             PER_ALL_ASSIGNMENTS_F      PAAF
             WHERE 1 = 1
               AND PCS.CONSOLIDATION_SET_ID = DETAIL.CONSOLIDATION_SET_ID
               AND PAAF.ASSIGNMENT_ID = DETAIL.ASSIGNMENT_ID
               AND PAAF.PAYROLL_ID = DETAIL.PAYROLL_ID
               AND DETAIL.EFFECTIVE_DATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
               AND PAAF.PERSON_ID = NVL(:P_PERSON_ID, PAAF.PERSON_ID) 
             GROUP BY  PAAF.ASS_ATTRIBUTE15,
                       DETAIL.ASSIGNMENT_ID,
                       CLAVE_NOMINA,
                       ANIO,
                       MES,
                       NUM_NOMINA,
--                       SUELDO_DIARIO,
--                       SALARIO_DIARIO_INTEGRADO,
--                       CREDITO_INFONAVIT,
--                       FECHA_INFONAVIT,
--                       TIPO_INFONAVIT,
--                       VALOR_INFONAVIT, 
--                       INC_EG,
--                       INC_MA,
--                       INC_RT,
--                       AUSENCIAS,
--                       PERMISOS,
--                       PATERNIDAD,
--                       SUSPENSIONES,
                       PORCENTAJE,
                       PCS.CONSOLIDATION_SET_NAME,
                       PAAF.ORGANIZATION_ID,
                       PAAF.POSITION_ID,
                       PAAF.PERSON_ID,
                       ACTION_TYPE,
--                       RUN_TYPE_NAME,
                       START_DATE,
                       END_DATE
             ORDER BY  6,        --Nombre
                       11;       --Numero de Nomina