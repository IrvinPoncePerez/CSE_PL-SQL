/***
Copyright  (c) EL CALVARIO S.A. DE C.V.
All rights reserved.
Implementación Oracle Nómina

   Formula: P011_AGUINALDO_DAYS_X_RATE
      Tipo: Oracle Payroll
   Elemento: P011_AGUINALDO
  

  FECHA     MODIFICO       DESCRIPCION                                    VERS.
  ========  ============   =============================================  =====
  29-JUL-15 AANTONIO(SS)   Actualización por adición de Factor de Integración 
                           de Prestaciones de El Calvario y función de 
                           calculo de Fecha de Antigüedad.                1.2 

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
DEFAULT FOR  EMP_HIRE_DATE                 is '0001/01/01 00:00:00' (DATE)
DEFAULT FOR  EMP_TERM_DATE                 is '4000/01/01 00:00:00'  (DATE)
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
mesg2 = 'NOT ENTERED'
Factor= 30
Ausentismos = /*BALANCE_FETCH('AUSENTISMOS AGUINALDO','_ASG_YTD',PAY_PROC_PERIOD_END_DATE)*/ (A001_AUSENTISMO_Days_ASG_GRE_YTD + A002_INCAPACIDAD_GENERAL_Days_ASG_GRE_YTD + A006_SUSPENSION_Days_ASG_GRE_YTD+
               A005_PERMISO_SIN_GOCE_Days_ASG_GRE_YTD )
			   


/* ===== CALCULATION SECTION BEGIN ===== */

/* === Dias en el Año === */

FechaInicial = TO_DATE (TO_CHAR(PAY_PROC_PERIOD_START_DATE,'YYYY') || '/01/01','YYYY/MM/DD')
FechaFinAño  = TO_DATE (TO_CHAR(PAY_PROC_PERIOD_START_DATE,'YYYY') || '/12/31','YYYY/MM/DD')
DiasAño = DAYS_BETWEEN(FechaFinAño,FechaInicial)+1

/* === Dias Trabajados en el Año === */

FechaContratacion = '0001/01/01 00:00:00' (DATE)

FechaContratacion = GET_HIRE_DATE()
FechaDespido = EMP_TERM_DATE
InicioAño = TO_DATE('01/01/'+ TO_CHAR(PAY_PROC_PERIOD_START_DATE,'YYYY'),('DD/MM/YYYY')) 
FinAño = To_DATE('31/12/'+ TO_CHAR(PAY_PROC_PERIOD_START_DATE, 'YYYY'),('DD/MM/YYYY'))


/******  Alta en el Año ******/

Fecha_Inicio_Calc = GREATEST( InicioAño, FechaContratacion)

/******  Baja en el Año ******/

Fecha_Fin_Calc= LEAST( FinAño, FechaDespido) 

/******  Días Trabajados durante el Año ******/

nDiasTrab = (DAYS_BETWEEN( Fecha_Fin_Calc, Fecha_Inicio_Calc)+1) - Ausentismos 


/* === Fecha de aniversario === */ 

anio_f_inicio_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_START_DATE,'YYYY')) 
mes_f_inicio_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_START_DATE,'MM')) 
 
anio_f_fin_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_END_DATE,'YYYY')) 
mes_f_fin_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_END_DATE,'MM')) 
 

fecha_aniversario =  '0001/01/01 00:00:00' (DATE) 

mes_aniversario = TO_NUMBER(TO_CHAR(FechaContratacion,'MM')) 
dia_aniversario = TO_CHAR(FechaContratacion,'DD') 
 
IF anio_f_inicio_per <> anio_f_fin_per  AND mes_aniversario = mes_f_inicio_per THEN  
  ( 
	nAnioUAniversario 		= anio_f_inicio_per - 1
	IF mes_aniversario = 2 AND dia_aniversario = '29' AND MOD(anio_f_inicio_per,4) <> 0 THEN dia_aniversario = '28' 
 
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
 
	nAnioUAniversario 		= anio_f_inicio_per - 1
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

antiguedad = 0 
renglon_antiguedad = ' ' 
antiguedad = TRUNC(DAYS_BETWEEN(fecha_aniversario,FechaContratacion) / 365, 0)
/*antiguedad = TRUNC(DAYS_BETWEEN(fecha_aniversario,FechaContratacion) / DiasAño, 0)*/
/***antiguedad = ROUND(DAYS_BETWEEN(fecha_aniversario,FechaContratacion) / DiasAño, 2)****/
renglon_antiguedad = TO_CHAR(antiguedad) 

IF ASG_PAYROLL LIKE '%SEM%'  THEN
	 (
        
		dias_prestacion = TO_NUMBER (GET_TABLE_VALUE ('SDI_SEMANAL', 
                                                  'DIAS AGUINALDO', 
                                                   renglon_antiguedad) 
                                )
	 )							
  

IF ASG_PAYROLL LIKE '%QUIN%'  THEN
     
		 (
		 
           dias_prestacion = TO_NUMBER (GET_TABLE_VALUE ('SDI_QUINCENA', 
                                                      'DIAS AGUINALDO', 
                                                       renglon_antiguedad) 
         )                       ) 				
      

IF ASG_PAYROLL LIKE '%02%SEM%AERO%CONF%'  THEN
	      (
		
	        dias_prestacion = TO_NUMBER (GET_TABLE_VALUE ('SDI_AEROLINEAS', 
                                                  'DIAS AGUINALDO', 
                                                   renglon_antiguedad) 
                                       ) 
		  )										
   


/* ===== CALCULO PRINCIPAL DE AGUINALDO ===== */	

IF nDiasTrab = DiasAño THEN
 (
  DiasCorrespon = dias_prestacion
 )
  ELSE
  (
     DiasCorrespon = nDiasTrab * dias_prestacion / DiasAño
  )
    	
   SalarioDiario = ASG_SALARY / Factor
   calc_days = DiasCorrespon
   
  IF Finiquito WAS NOT DEFAULTED THEN
  (
    earnings_amount = Finiquito
  )
  ELSE
   (
    earnings_amount = TRUNC((calc_days * SalarioDiario),2) 
   ) 
   
/* ===== CALCULATION SECTION END ===== */

mesg2 = 'P011_AGUINALDO : ' +
       ' DiasCorrespon: ' + to_char(DiasCorrespon) +
       ' nDiasTrab: '  + to_char(nDiasTrab) +
       ' dias_prestacion: ' + to_char(dias_prestacion) + 
       ' DiasAño: ' + to_char(DiasAño) + 
       ' Ausentismos: ' + to_char(Ausentismos) +
       ' Fecha_Inicio_Calc: ' + to_char(Fecha_Inicio_Calc) + 
       ' Fecha_Fin_Calc: ' + to_char(Fecha_Fin_Calc) +
       ' earnings_amount: ' + to_char(earnings_amount)

/* ======ISR Subject calculation begins ======= */

Veces_SMDG = TO_NUMBER(GET_TABLE_VALUE('CALVARIO TOPES EXENTOS',
                                       'ELEMENTO',
                                       'AGUINALDO')
                       )
ECON_ZONE 	=  GET_MX_ECON_ZONE()	
MIN_WAGE  	=  TO_NUMBER(GET_MIN_WAGE('NONE',ECON_ZONE)) 
TOPE_ISR  	=  (Veces_SMDG * MIN_WAGE)

          isr_exempt	=  LEAST(earnings_amount,TOPE_ISR )
          isr_subject	=  earnings_amount - isr_exempt

/* ======ISR Subject calculation ends ======= */

/* ===== Returns Section Begin ===== */

  soe_ytd         = P011_AGUINALDO_ASG_GRE_YTD
  earnings_days   = calc_days

mesg = 'P011 AGUINALDO: ' +  
       ' AguTot: '      + TO_CHAR(earnings_amount) +
       ' AguGrv: '      + TO_CHAR(isr_subject)+
       ' AguExe: '      + TO_CHAR(isr_exempt)+ 
       ' AguAnt: '      + renglon_antiguedad+ 
       ' DTbl: ' 	+ to_char(dias_prestacion) +  
       ' DAus: ' 	+ to_char(Ausentismos) + 
       ' DTrb: ' 	+ to_char(nDiasTrab) +
       ' DAgu: '        + to_char(earnings_days) +
       ' SdoDia:'	+ to_char(SalarioDiario) +
       ' FhaAnv: '  	+ to_char(fecha_aniversario, 'DD/MM/RRRR') +
       ' FhaCont: ' 	+ to_char(FechaContratacion, 'DD/MM/RRRR') 



  RETURN  earnings_amount
        , earnings_days
        , isr_subject
        , isr_exempt
		, mesg
    , mesg2

/* ===== Returns Section End ===== */

/* End Formula Text */