/***
Copyright  (c) EL CALVARIO S.A. DE C.V.
All rights reserved.
Implementación Oracle Nómina

   Formula: P006_PRIMA_VACACIONAL_DAYS_X_RATE
      Tipo: Oracle Payroll
   Elemento: P006_PRIMA VACACIONAL
  

  FECHA     MODIFICO       DESCRIPCION                                    VERS.
  ========  ============   =============================================  =====
  29-JUL-15 AANTONIO(SS)   Actualización por adición de función de calculo
                           de Fecha de Antigüedad.                        1.0   

***/

/* ===== Alias Section Begin ====== */

ALIAS SCL_ASG_MX_WORK_SCHEDULE AS Work_Schedule
ALIAS SCL_ASG_MX_TIMECARD_REQUIRED AS Timecard_Required

/* ===== Alias Section End ====== */

/* ===== Defaults Section Begin ===== */

DEFAULT FOR  PAY_PROC_PERIOD_START_DATE    is '0001/01/01 00:00:00' (DATE)
DEFAULT FOR  PAY_PROC_PERIOD_END_DATE      is '0001/01/02 00:00:00' (DATE)
DEFAULT FOR  ASG_SALARY                    is 0
DEFAULT FOR  ASG_SALARY_BASIS              is 'NOT ENTERED'
DEFAULT FOR  EMP_HIRE_DATE                 is '0001/01/02 00:00:00' (DATE)
DEFAULT FOR  EMP_TERM_DATE                 is '0001/01/02 00:00:00' (DATE)
DEFAULT FOR  ASG_PAYROLL                   is 'SIN NOMINA'


  /* IF Work_Schedule is not entered, this is assumed that employee works
     8 hours a day and 5 days a week */

DEFAULT FOR  Work_Schedule                 is '1 Schedule: 8-8-8-8-8-0-0'
DEFAULT FOR  Timecard_Required             is 'N'
DEFAULT FOR  Includes_Rest_Days            is 'N'
DEFAULT FOR  Days                          is 0
DEFAULT FOR  Rate                          is 0
DEFAULT FOR  Multiple                      is 1
DEFAULT FOR  ASG_FREQ_CODE                 is 'W'
DEFAULT FOR  ASG_HOURS                     is 40
DEFAULT FOR  Finiquito                     is 0


/* ===== Defaults Section End ===== */

/* ===== Inputs Section Begin ===== */

Inputs are      Days,
                Rate,
                Multiple,
		Finiquito

/* ===== Inputs Section End ===== */

/* =====Local variables =====  */
local_tax_type = 'ISR'
local_dummy_class_name = 'NONE'
isr_subject = 0
isr_exempt = 0
local_daily_salary = 0
local_gross_earnings = GROSS_EARNINGS_ASG_RUN
local_ytd_gross_earnings = GROSS_EARNINGS_ASG_YTD
mesg = 'NOT ENTERED'
Minimum_Wage      = 0
Factor = 30
nAnioUAniversario			= 0
nTempDPrestacion			= 0
mss_por_anio  = 12
FactPrim = .25

/* ===== CALCULATION SECTION BEGIN ===== */

SalarioDiario = ASG_SALARY / Factor

/****Dias por Año****/

FechaInicial = TO_DATE ('0001/01/01','YYYY/MM/DD')
FechaFinAño  = TO_DATE ('0001/12/31','YYYY/MM/DD')
DiasAnio = DAYS_BETWEEN(FechaFinAño,FechaInicial)+1


/* === Fecha de aniversario === */ 

anio_f_inicio_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_START_DATE,'YYYY')) 
mes_f_inicio_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_START_DATE,'MM')) 
 
anio_f_fin_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_END_DATE,'YYYY')) 
mes_f_fin_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_END_DATE,'MM')) 

fecha_contratacion = '0001/01/01 00:00:00' (DATE)

fecha_contratacion = GET_HIRE_DATE()
fecha_aniversario  = '0001/01/01 00:00:00' (DATE) 

mes_aniversario = TO_NUMBER(TO_CHAR(fecha_contratacion,'MM')) 
dia_aniversario = TO_CHAR(fecha_contratacion,'DD') 
 
IF anio_f_inicio_per <> anio_f_fin_per  AND mes_aniversario = mes_f_inicio_per THEN  
  ( 
    IF mes_aniversario = 2 AND dia_aniversario = '29' AND MOD(anio_f_inicio_per,4) <> 0 THEN dia_aniversario = '28' 
 
	nAnioUAniversario 		= anio_f_inicio_per - 1
    fecha_aniversario 		= TO_DATE(TO_CHAR(anio_f_inicio_per) + '/' + 
                                 TO_CHAR(mes_aniversario) + '/' + 
                                 dia_aniversario, 
                                 'YYYY/MM/DD') 
	fecha_aniversario_ant	= TO_DATE(TO_CHAR(nAnioUAniversario) + '/' + 
								TO_CHAR(mes_aniversario) + '/' + 
								dia_aniversario, 
								'YYYY/MM/DD') 
  ) 
ELSE 
( 
    IF mes_aniversario = 2 AND dia_aniversario = '29' AND MOD(anio_f_fin_per,4) <> 0 THEN dia_aniversario = '28' 
 
	nAnioUAniversario 		= anio_f_fin_per - 1
    fecha_aniversario 		= TO_DATE(TO_CHAR(anio_f_fin_per) + '/' + 
                                TO_CHAR(mes_aniversario) + '/' + 
                                dia_aniversario, 
                                'YYYY/MM/DD') 
	fecha_aniversario_ant	= TO_DATE(TO_CHAR(nAnioUAniversario) + '/' + 
								TO_CHAR(mes_aniversario) + '/' + 
								dia_aniversario, 
								'YYYY/MM/DD') 
																
) 

/* === Antigüedad === */

TablaSDI = ' '
TablaSDI = XXCALV_TABLA_SDI()

antiguedad = 0 
renglon_antiguedad = ' ' 
antiguedad = ROUND(DAYS_BETWEEN(fecha_aniversario,fecha_contratacion) / DiasAnio, 2)
renglon_antiguedad = TO_CHAR(antiguedad) 
DIAS_PRESTACION = 0


IF (TablaSDI LIKE '%SDI%AEROLINEAS%FINAL%') OR (TablaSDI LIKE '%SDI%AEROLINEAS%')  THEN
(

 IF (fecha_aniversario >= PAY_PROC_PERIOD_START_DATE AND fecha_aniversario <= PAY_PROC_PERIOD_END_DATE)  THEN
  (
    dias_prestacion = TO_NUMBER (GET_TABLE_VALUE ('VACACIONES AEROLINEAS', 
                                                  'VACACIONES', 
                                                   renglon_antiguedad) 
                                ) 
  )
) 

IF (TablaSDI LIKE '%SDI%QUINCENA%FINAL%') OR (TablaSDI LIKE '%SDI%QUINCENA%')  THEN
	(
	  IF (fecha_aniversario >= PAY_PROC_PERIOD_START_DATE AND fecha_aniversario <= PAY_PROC_PERIOD_END_DATE)  THEN
     (
        dias_prestacion = TO_NUMBER (GET_TABLE_VALUE ('VACACIONES CALVARIO', 
                                                      'VACACIONES', 
                                                       renglon_antiguedad) 
                                ) 
		
      )
	) 
       
  
IF (TablaSDI LIKE '%SDI%SEMANAL%FINAL%') OR (TablaSDI LIKE '%SDI%SEMANAL%')   THEN
	   (
	     IF (fecha_aniversario >= PAY_PROC_PERIOD_START_DATE AND fecha_aniversario <= PAY_PROC_PERIOD_END_DATE) THEN
          (
            dias_prestacion = TO_NUMBER (GET_TABLE_VALUE ('VACACIONES CALVARIO', 
                                                  'VACACIONES', 
                                                   renglon_antiguedad) 
                                       ) 
		
          )  
 
              ELSE
              (
                 dias_prestacion = 0 
	             SalarioDiario = 0
              )	  
          )
       
    

/* === Verifica Baja del Empleado === */ 


	  IF Finiquito WAS NOT DEFAULTED THEN
	   (
       	 
		 dias_prestacion = 0
		 PrimVac = Finiquito
		 		 
	   ) 
	    ELSE
		(
		  IF Finiquito WAS DEFAULTED THEN
          (		
		   PrimVac = (dias_prestacion * SalarioDiario * FactPrim)
		  )
		)  


 
		
	
     earnings_amount = PrimVac  
  
 	
mesg = 'P006_PRIMA VAC: Fecha Aniversario:'   + to_char(fecha_aniversario) +
       ' Fecha Contratación: ' + to_char(fecha_contratacion) +
       ' Antiguedad: ' + to_char(antiguedad) +       
	   ' Días en el año: ' + to_char(DiasAnio) +
       ' Días en prestacion: ' + to_char(nTempDPrestacion)  + 
	   ' Finiquito: ' + to_char(Finiquito)+
	   ' Salario DIario:'+ to_char(SalarioDiario) +
	   ' Dias Prestación:'+ to_char( dias_prestacion) +
	   ' TABLA:'+ ( TablaSDI)
	 
	

/* ===== CALCULATION SECTION END ===== */

/* ======ISR Subject calculation begins ======= */

Veces_SMDG = TO_NUMBER(GET_TABLE_VALUE('CALVARIO TOPES EXENTOS',
                                       'ELEMENTO',
                                       'PRIMA VACACIONAL')
                       )
UMA         = GET_UMA_VALUE()
ECON_ZONE 	=  GET_MX_ECON_ZONE()	
MIN_WAGE  	=  TO_NUMBER(GET_MIN_WAGE('NONE',ECON_ZONE)) 
TOPE_ISR  	=  (Veces_SMDG * UMA)

          isr_exempt	=  LEAST(earnings_amount,TOPE_ISR )
          isr_subject	=  earnings_amount - isr_exempt
            
/* ======ISR Subject calculation ends ======= */

/* ===== Returns Section Begin ===== */

  soe_ytd         = P006_PRIMA_VACACIONAL_ASG_GRE_YTD
  /*earnings_days   = calc_days*/

  RETURN  earnings_amount
        /*, earnings_days*/
        , isr_subject
        , isr_exempt
		, mesg

/* ===== Returns Section End ===== */

/* End Formula Text */