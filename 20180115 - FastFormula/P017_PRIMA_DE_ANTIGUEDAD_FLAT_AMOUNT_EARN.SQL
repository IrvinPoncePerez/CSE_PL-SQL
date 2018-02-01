/***
Copyright  (c) EL CALVARIO S.A. DE C.V.
All rights reserved.
Implementación Oracle Nómina

   Formula: P017_PRIMA_DE_ANTIGUEDAD_FLAT_AMOUNT_EARN
      Tipo: Oracle Payroll
   Elemento: P017_PRIMA DE ANTIGUEDAD   
  

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
DEFAULT FOR P017_PRIMA_DE_ANTIGUEDAD_ASG_GRE_YTD        is 0
DEFAULT FOR ASG_SALARY_BASIS IS 'NOT ENTERED'
DEFAULT FOR ASG_SALARY IS 0
DEFAULT FOR ASG_HOURS IS 40
DEFAULT FOR PAY_PROC_PERIOD_START_DATE IS '0001/01/01 00:00:00' (DATE)
DEFAULT FOR PAY_PROC_PERIOD_END_DATE IS '0001/01/02 00:00:00' (DATE)
DEFAULT FOR ASG_FREQ_CODE IS 'W'
DEFAULT FOR  Finiquito                     is 0
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
Factor = 30


IF Finiquito WAS NOT DEFAULTED THEN
    (
       Amount = Finiquito
	)

flat_amount = Amount

SalarioDiario = ASG_SALARY / Factor	

        ECON_ZONE 	=  GET_MX_ECON_ZONE()	
        MIN_WAGE  	=  TO_NUMBER(GET_MIN_WAGE('NONE',ECON_ZONE)) 
        UMA         =  GET_UMA_VALUE()
        Sueldo_Diario = LEAST(SalarioDiario,(2 * MIN_WAGE))

	    FechaContratacion = EMP_HIRE_DATE

	    Anos_Cump	= TRUNC((MONTHS_BETWEEN(EMP_TERM_DATE, FechaContratacion) / 12),0)
	    FechaUAni	= ADD_YEARS(FechaContratacion, Anos_Cump)
	    DiasUAniv	= DAYS_BETWEEN(EMP_TERM_DATE, FechaUAni) + 1
	    FechaSAni	= ADD_YEARS(FechaContratacion, (Anos_Cump + 1))
	    DiasSAniv	= DAYS_BETWEEN(FechaSAni, FechaUAni) 
	    Proporcion	= DiasUAniv / DiasSAniv
	    Anos_Comp	= Anos_Cump + Proporcion
		
/* ======ISR Subject calculation begins ======= */
  
TOPE_ISR  	=  (90*UMA) * Anos_Comp

SUMA= P026_INDEMNIZACION_ASG_GRE_RUN +  flat_amount

       isr_exempt	=  LEAST(SUMA,TOPE_ISR )
	   isr_subject	=  flat_amount - isr_exempt
	
	
/* ======ISR Subject calculation ends ======= */

mesg1 = 'P017 PRIMA DE ANTIGUEDAD:      Años Completos: '     + to_char(Anos_Comp) +
        'P026 y P017: ' + to_char(SUMA) 
		



soe_ytd = P017_PRIMA_DE_ANTIGUEDAD_ASG_GRE_YTD

RETURN flat_amount,
       mesg,
       isr_subject,
       isr_exempt,
	   mesg1

/* End Formula Text */