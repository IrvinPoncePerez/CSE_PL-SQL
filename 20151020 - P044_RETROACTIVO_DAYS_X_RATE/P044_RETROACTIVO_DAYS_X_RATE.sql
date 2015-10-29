/*****************************************************************************
FORMULA NAME:   DAYS_X_RATE

FORMULA TYPE:   Payroll

DESCRIPTION:    Formula for Days X Rate element
                where Days must be input, Multiple defaults to 1
                if not input,  and Rate is determined by one of
                the following, in order of preference:
                1) Entry of "Rate" input value
                2) Salary Admin "Pay Basis" information

--
INPUTS:         Days
                Rate
                Multiple

--
Change History
--
**********************************************************************

Formula Results :
 earnings_amount  Direct Result for Earnings Pay Value.
 mesg             Message indicating that this earnings will be deleted
                  for this assignment.

**********************************************************************/

/* ===== Alias Section Begin ====== */

ALIAS SCL_ASG_MX_WORK_SCHEDULE AS Work_Schedule
ALIAS SCL_ASG_MX_TIMECARD_REQUIRED AS Timecard_Required
ALIAS ASG_NUMBER AS NUMERO

/* ===== Alias Section End ====== */

/* ===== Defaults Section Begin ===== */


DEFAULT FOR  PAY_PROC_PERIOD_START_DATE    is '0001/01/01 00:00:00' (DATE)
DEFAULT FOR  PAY_PROC_PERIOD_END_DATE      is '0001/01/02 00:00:00' (DATE)
DEFAULT FOR  ASG_SALARY                    is 0
DEFAULT FOR  ASG_SALARY_BASIS              is 'NOT ENTERED'
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
DEFAULT FOR NUMERO                         IS 'NUMEROAS'


/* ===== Defaults Section End ===== */

/* ===== Inputs Section Begin ===== */

Inputs are      Days,
                Rate,
                Multiple

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
Factor = 30


/* ===== CALCULATION SECTION BEGIN ===== */
/*Ausentismos = AUSENTISMOS_RETROACTIVO_ASG_GRE_YTD*/

FromDate = To_DATE(P044_FECHA_RETROACTIVO, 'DD/MM/YYYY')

AnioUltPeriodo = TO_NUMBER(TO_CHAR(FromDate,'YYYY'))
MesUltPeriodo = TO_NUMBER(TO_CHAR(FromDate,'MM')) 
DiaUltPeriodo = TO_CHAR(FromDate,'DD') 


FechaUltPeriodoAnt = TO_DATE(P044_FECHA_ULT_PERIODO, 'YYYY/MM/DD')


SueldoAnterior= XXCALV_GET_LAST_SALARY_F(FechaUltPeriodoAnt)
FechaPrimPer= XXCALV_FECHA_INICIO(PAY_PROC_PERIOD_END_DATE)

DIAS_RETRO = DAYS_BETWEEN(PAY_PROC_PERIOD_START_DATE, FechaPrimPer)

DIAS_TOT = 0 

IF (Days = 0) (
  DIAS_TOT = P001_SUELDO_NORMAL_Days_ASG_GRE_YTD - P001_SUELDO_NORMAL_Days_ASG_GRE_RUN
) ELSE (
  DIAS_TOT = Days
)

calc_days = ( DIAS_TOT + P005_VACACIONES_Days_ASG_GRE_YTD) /*- Ausentismos*/



IF ASG_PAYROLL LIKE '%QUIN%' THEN
 (   
   SalarioDiario = ASG_SALARY / Factor
   SalarioDiarioRet = SueldoAnterior /Factor

 )  

IF ASG_PAYROLL LIKE '%SEM%'  THEN
 (
   SalarioDiario = ASG_SALARY / Factor
   SalarioDiarioRet = SueldoAnterior /Factor
 )

earnings_amount = ( SalarioDiario - SalarioDiarioRet) * calc_days 

 mesg1 = 'P044_RETROACTIVO: Sueldo Ant: '  + to_char(SueldoAnterior) 
                +'Fecha ier Periodo:'+ to_char(FechaPrimPer) 
				+'Dias Normales:'+ to_char(DIAS_RETRO)
                +'Dias Vac:'+ to_char(P005_VACACIONES_Days_ASG_GRE_YTD)	
				+'Dias SUELDO AÑO:'+ to_char(P001_SUELDO_NORMAL_Days_ASG_GRE_YTD)
                +'Dias EJECUCION:'+ to_char(P001_SUELDO_NORMAL_Days_ASG_GRE_RUN)				
				+'Dias Totales:'+ to_char(calc_days)					
    

/* ===== CALCULATION SECTION END ===== */

/* ======ISR Subject calculation begins ======= */
    isr_subject = get_subject_earnings_ann
                    (local_tax_type,
                    earnings_amount,
                    P044_RETROACTIVO_ASG_YTD +
                    earnings_amount,
                    local_gross_earnings +
                    earnings_amount,
                    local_ytd_gross_earnings +
                    earnings_amount,
                    local_daily_salary,
                    local_dummy_class_name)
    isr_exempt = earnings_amount - isr_subject
/* ======ISR Subject calculation ends ======= */

/* ===== Returns Section Begin ===== */

  soe_ytd         = P044_RETROACTIVO_ASG_GRE_YTD
  earnings_days   = calc_days

  RETURN  earnings_amount
        , earnings_days
        , isr_subject
        , isr_exempt
		, mesg1

/* ===== Returns Section End ===== */

/* End Formula Text */