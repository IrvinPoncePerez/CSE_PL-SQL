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
DEFAULT FOR P007_PREMIO_ASISTENCIA_ASG_GRE_YTD        is 0
DEFAULT FOR ASG_SALARY_BASIS IS 'NOT ENTERED'
DEFAULT FOR ASG_SALARY IS 0
DEFAULT FOR ASG_HOURS IS 40
DEFAULT FOR PAY_PROC_PERIOD_START_DATE IS '0001/01/01 00:00:00' (DATE)
DEFAULT FOR PAY_PROC_PERIOD_END_DATE IS '0001/01/02 00:00:00' (DATE)
DEFAULT FOR ASG_FREQ_CODE IS 'W'
/* Assume that an employee works for 8 hours per day, 5 days a week.*/
DEFAULT FOR Work_Schedule IS '1 Schedule: 8-8-8-8-8-0-0'
DEFAULT FOR ASG_PAYROLL IS ' '
DEFAULT FOR P001_SUELDO_NORMAL_DAYS_ASG_GRE_RUN             is 0
DEFAULT FOR P005_VACACIONES_DAYS_ASG_GRE_RUN                is 0

/* DEFAAULT Retroactivo */
DEFAULT FOR P001_SUELDO_NORMAL_DAYS_ASG_GRE_YTD         is 0
DEFAULT FOR P005_VACACIONES_DAYS_ASG_GRE_YTD            is 0
/* DEFAAULT Retroactivo */

/* Inputs  */

INPUTS ARE        Amount,
				  Tope	

/* =====Local variables =====  */
local_tax_type = 'ISR'
local_dummy_class_name = 'NONE'
isr_subject = 0
isr_exempt = 0
local_daily_salary = 0
local_gross_earnings = GROSS_EARNINGS_ASG_RUN
local_ytd_gross_earnings = GROSS_EARNINGS_ASG_YTD

DIAS_TRAB = P001_SUELDO_NORMAL_DAYS_ASG_GRE_RUN
DIAS_VAC = P005_VACACIONES_DAYS_ASG_GRE_RUN
TOPE_CANT_QUIN = G_TOPE_CANT_QUIN 
TOPE_CANT_SEM = G_TOPE_CANT_SEM
Porcentaje = G_PORCENTAJE/100

/* Variables de Retroactivo */
DIAS_TRAB_RET = P001_SUELDO_NORMAL_DAYS_ASG_GRE_YTD - P001_SUELDO_NORMAL_DAYS_ASG_GRE_RUN
DIAS_VAC_RET = P005_VACACIONES_DAYS_ASG_GRE_YTD - P005_VACACIONES_DAYS_ASG_GRE_RUN
DIAS_RETROACTIVO = TRUNC((DIAS_TRAB_RET + DIAS_VAC_RET), 2)
PREMIO_PAGADO = P007_PREMIO_ASISTENCIA_ASG_GRE_YTD
RETROACTIVO = 0
/* Variables de Retroactivo */

FacSem = 30
FacQuin =30

temp_fixed_idw = 0
temp_variable_idw = 0
temp_idw   =     getIDW('REPORT',
                   temp_fixed_idw,
                   temp_variable_idw,
		   'Y'
                  )
SDI = temp_idw


SalarioDiario_Q = ASG_SALARY / FacQuin
SalarioDiario_S = ASG_SALARY / FacSem

IF ASG_PAYROLL LIKE '%QUIN%' THEN
 (
 
   flat_amount = (((DIAS_TRAB * SalarioDiario_Q)+ (DIAS_VAC*SalarioDiario_Q)) * Porcentaje )
   
   IF flat_amount >  TOPE_CANT_QUIN THEN
   (
    flat_amount  = TOPE_CANT_QUIN
    
   )
   ELSE
   (
    flat_amount = flat_amount
   )
   TOPE = (( SDI * .10)*15)
 )  

IF ASG_PAYROLL LIKE '%SEM%'  THEN
 (
   
   flat_amount = (((DIAS_TRAB * SalarioDiario_S)+ (DIAS_VAC*SalarioDiario_S))* Porcentaje)
   
   
   IF flat_amount >  TOPE_CANT_SEM THEN
   (
    flat_amount  = TOPE_CANT_SEM
    
   )
   ELSE
   (
    flat_amount = flat_amount
   )
   
   TOPE = (( SDI * .10)*7)
 )


/* Bloque del Retroactivo */
IF ASG_PAYROLL LIKE '%QUIN%' THEN (
  RETROACTIVO = ((DIAS_RETROACTIVO * SalarioDiario_Q) * Porcentaje)

  IF RETROACTIVO > TOPE_CANT_QUIN THEN (
    RETROACTIVO = TOPE_CANT_QUIN
  )

  RETROACTIVO = RETROACTIVO - PREMIO_PAGADO

  flat_amount = TRUNC(flat_amount, 2) + ROUND(RETROACTIVO, 2)
) ELSE (
  IF ASG_PAYROLL LIKE '%SEM%' THEN (
    RETROACTIVO = ((DIAS_RETROACTIVO * SalarioDiario_S) * Porcentaje)
    RETROACTIVO = RETROACTIVO - PREMIO_PAGADO

    flat_amount = TRUNC(flat_amount, 2) + TRUNC(RETROACTIVO, 2)
  )
)

mesg  = 'P007_PREMIO_ASISTENCIA: '
      + 'DIAS_RETROACTIVO: ' + TO_CHAR(DIAS_RETROACTIVO)
      + ' SalarioDiario_Q: ' + TO_CHAR(SalarioDiario_Q)
      + ' SalarioDiario_S: ' + TO_CHAR(SalarioDiario_S)
      + ' Porcentaje: ' + TO_CHAR(Porcentaje)
      + ' flat_amount S/Retroactivo: ' + TO_CHAR(flat_amount - RETROACTIVO)
      + ' flat_amount C/Retroactivo: ' + TO_CHAR(flat_amount)
      + ' RETROACTIVO: ' + TO_CHAR(RETROACTIVO)
/* Bloque del Retroactivo */


TOPE_SDI = TOPE
TopeSDI	=  (LEAST(flat_amount,TOPE_SDI))*-1


soe_ytd = P007_PREMIO_ASISTENCIA_ASG_GRE_YTD


isr_subject = flat_amount
isr_exempt = flat_amount - isr_subject

RETURN flat_amount,
       mesg,
       isr_subject,
       isr_exempt,
	   TopeSDI

/* End Formula Text */