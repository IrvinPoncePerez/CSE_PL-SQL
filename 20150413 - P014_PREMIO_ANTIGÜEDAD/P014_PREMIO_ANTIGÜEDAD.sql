/*****************************************************************************

FORMULA NAME: _FLAT_AMOUNT_EARN

FORMULA TYPE: Payroll

DESCRIPTION:  Formula for Flat Amount for Earning Template for Mexico.
              Returns pay value (Amount);

*******************************************************************************

FORMULA TEXT

Formula Results :

 flat_amount           Direct Result for Earnings Amount.

 mesg                  Warning message will be issued for this assignment.

*******************************************************************************/

/* ALIAS section */

ALIAS SCL_ASG_MX_WORK_SCHEDULE AS Work_Schedule

/* Database Item Defaults */

DEFAULT FOR flat_amount                    is 0
DEFAULT FOR mesg                           is 'NOT ENTERED'
DEFAULT FOR P014_PREMIO_ANTIGÜEDAD_ASG_GRE_YTD        is 0
DEFAULT FOR ASG_SALARY_BASIS IS 'NOT ENTERED'
DEFAULT FOR ASG_SALARY IS 0
DEFAULT FOR ASG_HOURS IS 40
DEFAULT FOR PAY_PROC_PERIOD_START_DATE IS '0001/01/01 00:00:00' (DATE)
DEFAULT FOR PAY_PROC_PERIOD_END_DATE IS '0001/01/02 00:00:00' (DATE)
DEFAULT FOR  EMP_HIRE_DATE                 is '0001/01/02 00:00:00' (DATE)
DEFAULT FOR  EMP_TERM_DATE                 is '0001/01/02 00:00:00' (DATE)
DEFAULT FOR ASG_FREQ_CODE IS 'W'
/* Assume that an employee works for 8 hours per day, 5 days a week.*/
DEFAULT FOR Work_Schedule IS '1 Schedule: 8-8-8-8-8-0-0'

/* Inputs  */

INPUTS ARE        Amount

/* =====Local variables =====  */
local_tax_type = 'ISR'
local_dummy_class_name = 'NONE'
isr_subject = 0
isr_exempt = 0
local_daily_salary = 0
local_gross_earnings = GROSS_EARNINGS_ASG_RUN
local_ytd_gross_earnings = GROSS_EARNINGS_ASG_YTD

nAnioUAniversario			= 0
nTempDPrestacion			= 0
flat_amount = 0
mss_por_anio  = 12

/* ===== CALCULATION SECTION BEGIN ===== */

FECHA_INGRESO = EMP_HIRE_DATE
Anios_Antiguedad = DAYS_BETWEEN (EMP_TERM_DATE, FECHA_INGRESO) + 1
  Anios_Antiguedad = TRUNC(Anios_Antiguedad / 365)
  
  Anios_Antiguedad = DAYS_BETWEEN (PAY_PROC_PERIOD_END_DATE, FECHA_INGRESO) + 1
    Dif_Anios_Antig= (Anios_Antiguedad / 365) - (TRUNC(Anios_Antiguedad / 365))
    IF Dif_Anios_Antig > 0.5 THEN Anios_Antiguedad = (TRUNC(Anios_Antiguedad / 365)) + 1 
	ELSE Anios_Antiguedad = TRUNC(Anios_Antiguedad / 365)

/****Dias por Año****/

FechaInicial = TO_DATE ('0001/01/01','YYYY/MM/DD')
FechaFinAño  = TO_DATE ('0001/12/31','YYYY/MM/DD')
dias_por_anio = DAYS_BETWEEN(FechaFinAño,FechaInicial)+1


/* === Fecha de aniversario === */ 

anio_f_inicio_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_START_DATE,'YYYY')) 
mes_f_inicio_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_START_DATE,'MM')) 
 
anio_f_fin_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_END_DATE,'YYYY')) 
mes_f_fin_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_END_DATE,'MM')) 
 
fecha_contratacion = EMP_HIRE_DATE
Fecha_Fija_Aniv =  '0001/04/09 00:00:00' (DATE) 

mes_aniversario = TO_NUMBER(TO_CHAR(Fecha_Fija_Aniv,'MM')) 
dia_aniversario = TO_CHAR(Fecha_Fija_Aniv,'DD') 
 
IF mes_aniversario = 4 AND dia_aniversario = '09'  THEN 
 
	nAnioUAniversario 		= anio_f_inicio_per - 1
    Fecha_Pago 		= TO_DATE(TO_CHAR(anio_f_inicio_per) + '/' + 
                                 TO_CHAR(mes_aniversario) + '/' + 
                                 dia_aniversario, 
                                 'YYYY/MM/DD')

Ant_Pago = TRUNC( (DAYS_BETWEEN(Fecha_Pago, fecha_contratacion)/dias_por_anio ), 5)    /* Antes TRUNC(X, 2) */

    IF Ant_Pago >= 7.00273 AND Ant_Pago <= 8.00274 THEN
	(
	flat_amount= 1200
	)

 	ELSE (

		IF Ant_Pago >= 8.00547 AND Ant_Pago <= 9.00274 THEN
		(
		flat_amount= 600
		)
	     	
		     ELSE(

			IF Ant_Pago >= 9.00547 AND Ant_Pago <= 10.00274 THEN
			(
			flat_amount= 600
			)

			 ELSE(

				IF Ant_Pago >= 10.00547 AND Ant_Pago <= 11.00548 THEN
				(
				flat_amount= 600
				)
					ELSE
					(
					mes= 'No aplica'
					)
				)
		          )
	    )
/* ======ISR Subject calculation begins ======= */
    isr_subject = get_subject_earnings_ann
                    (local_tax_type,
                    flat_amount,
                    P014_PREMIO_ANTIGÜEDAD_ASG_YTD +
                    flat_amount,
                    local_gross_earnings +
                    flat_amount,
                    local_ytd_gross_earnings +
                    flat_amount,
                    local_daily_salary,
                    local_dummy_class_name)
    isr_exempt = flat_amount - isr_subject
/* ======ISR Subject calculation ends ======= */

mesg = 'Fecha Aniversario: ' + to_char(Fecha_Pago) +
       ' Fecha Contratación: ' + to_char(fecha_contratacion) +
       ' Antiguedad: ' + to_char(Anios_Antiguedad) +
	   'Antiguedad dias:' + to_char( Ant_Pago)
soe_ytd = P014_PREMIO_ANTIGÜEDAD_ASG_GRE_YTD

RETURN flat_amount,
       mesg,
       isr_subject,
       isr_exempt

/* End Formula Text */