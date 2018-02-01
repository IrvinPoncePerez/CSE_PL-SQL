/***
Copyright  (c) EL CALVARIO S.A. DE C.V.
All rights reserved.
Implementación Oracle Nómina

   Formula: P026_INDEMNIZACION_FLAT_AMOUNT_EARN
      Tipo: Oracle Payroll
   Elemento: P026_INDEMNIZACION
  

  FECHA     MODIFICO       DESCRIPCION                                    VERS.
  ========  ============   =============================================  =====
  29-JUL-15 AANTONIO(SS)   Actualización por adición de función de calculo
                           de Fecha de Antigüedad.                        1.0   

***/

/* ALIAS section */

ALIAS SCL_ASG_MX_WORK_SCHEDULE AS Work_Schedule

/* Database Item Defaults */
DEFAULT FOR  EMP_HIRE_DATE                 is '0001/01/02 00:00:00' (DATE)
DEFAULT FOR  EMP_TERM_DATE                 is '0001/01/02 00:00:00' (DATE)


DEFAULT FOR flat_amount                    is 0
DEFAULT FOR mesg                           is 'NOT ENTERED'
DEFAULT FOR P026_INDEMNIZACION_ASG_GRE_YTD        is 0
DEFAULT FOR ASG_SALARY_BASIS IS 'NOT ENTERED'
DEFAULT FOR ASG_SALARY IS 0
DEFAULT FOR ASG_HOURS IS 40
DEFAULT FOR PAY_PROC_PERIOD_START_DATE IS '0001/01/01 00:00:00' (DATE)
DEFAULT FOR PAY_PROC_PERIOD_END_DATE IS '0001/01/02 00:00:00' (DATE)
DEFAULT FOR ASG_FREQ_CODE IS 'W'
/* Assume that an employee works for 8 hours per day, 5 days a week.*/
DEFAULT FOR Work_Schedule IS '1 Schedule: 8-8-8-8-8-0-0'

/* Inputs  */

INPUTS ARE        Amount,
                  Finiquito

/* =====Local variables =====  */
local_tax_type = 'ISR'
local_dummy_class_name = 'NONE'
isr_subject = 0
isr_exempt = 0
local_daily_salary = 0
local_gross_earnings = GROSS_EARNINGS_ASG_RUN
local_ytd_gross_earnings = GROSS_EARNINGS_ASG_YTD


Anios_Antiguedad = 0
ECON_ZONE =  GET_MX_ECON_ZONE()	
MIN_WAGE =  TO_NUMBER(GET_MIN_WAGE('NONE',ECON_ZONE))
UMA = GET_UMA_VALUE()
Tope_Exento = 0
SM = 0
Factor = 30

FECHA_INGRESO = '0001/01/01 00:00:00' (DATE)

FECHA_INGRESO = GET_HIRE_DATE()
SM = UMA

IF PAY_PROC_PERIOD_START_DATE <= EMP_TERM_DATE AND EMP_TERM_DATE <= PAY_PROC_PERIOD_END_DATE THEN
    (
       Amount = Finiquito
	)


flat_amount = Amount

/* ======ISR Subject calculation begins ======= */
   
	/* Determinar antiguedad */
	
    Anios_Antiguedad = DAYS_BETWEEN (EMP_TERM_DATE, FECHA_INGRESO) + 1
    Anios_Antiguedad = TRUNC(Anios_Antiguedad / 365)
	
    Anios_Antiguedad = DAYS_BETWEEN (PAY_PROC_PERIOD_END_DATE, FECHA_INGRESO) + 1
    Dif_Anios_Antig= (Anios_Antiguedad / 365) - (TRUNC(Anios_Antiguedad / 365))
    IF Dif_Anios_Antig > 0.5 THEN Anios_Antiguedad = (TRUNC(Anios_Antiguedad / 365)) + 1 
	ELSE Anios_Antiguedad = TRUNC(Anios_Antiguedad / 365)
  
 

	Tope_Exento = ((90 * SM) * Anios_Antiguedad)
	
	IF flat_amount >= Tope_Exento THEN
	(
		isr_subject = flat_amount - Tope_Exento
    		isr_exempt = Tope_Exento
	)
	ELSE
	(
		isr_subject = 0
        isr_exempt = flat_amount
	)


   
/* ======ISR Subject calculation ends ======= */


soe_ytd = P026_INDEMNIZACION_ASG_GRE_YTD

mesg = 'P026_Indemnización: ' + TO_CHAR(flat_amount) +  ' Años Antig: ' + TO_CHAR(Anios_Antiguedad)

RETURN flat_amount,
       mesg,
       isr_subject,
       isr_exempt

/* End Formula Text */