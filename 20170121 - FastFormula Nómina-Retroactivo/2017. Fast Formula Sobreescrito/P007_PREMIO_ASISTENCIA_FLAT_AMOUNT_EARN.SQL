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

  DiasRetroactivo = 0
  SalarioDiarioAnt = 0
  PorcentajeAnt = G_PORCENTAJE_ANT/100
  Retroactivo = 0

  DiasRetroactivo = PAC_P044_DIAS_RETROACTIVOS(PAY_PROC_PERIOD_END_DATE, 'P001_SUELDO NORMAL', ASG_PAYROLL)
  DiasRetroactivo = DiasRetroactivo + PAC_P044_DIAS_RETROACTIVOS(PAY_PROC_PERIOD_END_DATE, 'P005_VACACIONES', ASG_PAYROLL)
  SalarioDiarioAnt = PAC_P044_SALARIO_DIARIO_ANT() 

  Retroactivo = ((DiasRetroactivo * SalarioDiario_Q) * Porcentaje) - ((DiasRetroactivo * SalarioDiarioAnt) * PorcentajeAnt)

  IF Retroactivo > TOPE_CANT_QUIN THEN(
    Retroactivo = 0
  )

  IF Retroactivo < 0 THEN (
    Retroactivo = 0
  )

  flat_amount = TRUNC(flat_amount, 2) + ROUND(Retroactivo, 2)

) ELSE (
  IF ASG_PAYROLL LIKE '%SEM%' THEN (
    DiasRetroactivo = 0
    SalarioDiarioAnt = 0
    PorcentajeAnt = G_PORCENTAJE_ANT/100
    Retroactivo = 0

    DiasRetroactivo = PAC_P044_DIAS_RETROACTIVOS(PAY_PROC_PERIOD_END_DATE, 'P001_SUELDO NORMAL', ASG_PAYROLL)
    DiasRetroactivo = DiasRetroactivo + PAC_P044_DIAS_RETROACTIVOS(PAY_PROC_PERIOD_END_DATE, 'P005_VACACIONES', ASG_PAYROLL)
    SalarioDiarioAnt = PAC_P044_SALARIO_DIARIO_ANT() 

    Retroactivo = ((DiasRetroactivo * SalarioDiario_S) * Porcentaje) - ((DiasRetroactivo * SalarioDiarioAnt) * PorcentajeAnt)

    IF Retroactivo > TOPE_CANT_SEM THEN(
        Retroactivo = TOPE_CANT_SEM
    )

    IF Retroactivo < 0 THEN (
      Retroactivo = 0
    )

    flat_amount = TRUNC(flat_amount, 2) + ROUND(Retroactivo, 2)
  )
)

mesg2 = 'RETROACTIVO '
      + ' DiasRetroactivo: ' + to_char(DiasRetroactivo)
      + ' SalarioDiarioAnt: ' + to_char(SalarioDiarioAnt)
      + ' Retroactivo: ' + to_char(Retroactivo)
      + ' flat_amount: ' + to_char(flat_amount)

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
	   TopeSDI,
     mesg2,
     Retroactivo

/* End Formula Text */