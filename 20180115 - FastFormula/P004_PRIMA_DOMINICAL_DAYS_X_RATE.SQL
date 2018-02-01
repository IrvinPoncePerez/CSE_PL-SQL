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

/* ===== Alias Section End ====== */

/* ===== Defaults Section Begin ===== */

DEFAULT FOR  PAY_PROC_PERIOD_START_DATE    is '0001/01/01 00:00:00' (DATE)
DEFAULT FOR  PAY_PROC_PERIOD_END_DATE      is '0001/01/02 00:00:00' (DATE)
DEFAULT FOR  EMP_TERM_DATE                 is '0001/01/01 00:00:00' (DATE)
DEFAULT FOR  ASG_SALARY                    is 0
DEFAULT FOR  ASG_SALARY_BASIS              is 'NOT ENTERED'
DEFAULT FOR  ASG_PAYROLL                    is ' '
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
DEFAULT FOR  Importe                       is 0
DEFAULT FOR  Finiquito	     			   IS 0 

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
FactorSem= 30
FactorQui= 30
SalarioDiario= 0
earnings_amount = 0

ECON_ZONE =  GET_MX_ECON_ZONE()	
MIN_WAGE =  TO_NUMBER(GET_MIN_WAGE('NONE',ECON_ZONE))
UMA = GET_UMA_VALUE()

/* ===== CALCULATION SECTION BEGIN ===== */


IF  Finiquito WAS NOT DEFAULTED THEN
   (   
    days = 0
    PrimDom = Finiquito
	)
ELSE
(
	IF Finiquito WAS DEFAULTED THEN
     (	
         IF ASG_PAYROLL LIKE '%QUIN%' THEN
          (
            SalarioDiario = ASG_SALARY / FactorQui
			PrimDom = SalarioDiario * 0.25 * days
          )  
            ELSE
	        (
	            IF ASG_PAYROLL LIKE '%SEM%'  THEN
                 (
                     SalarioDiario = ASG_SALARY / FactorSem
					 PrimDom = SalarioDiario * 0.25 * days
                  )
             )    
		)
 )		

	
  earnings_amount = PrimDom 

 
/* ===== CALCULATION SECTION END ===== */

/* ======ISR Subject calculation begins ======= */


isr_exempt = 0
isr_subject = 0

IF earnings_amount > UMA THEN 
   (
    isr_subject  = earnings_amount - UMA
    isr_exempt = UMA
   )
ELSE
   (
    isr_exempt = earnings_amount
   )

        
/* ======ISR Subject calculation ends ======= */

/* ===== Returns Section Begin ===== */
    calc_days     = days
  soe_ytd         = P004_PRIMA_DOMINICAL_ASG_GRE_YTD
  earnings_days   = calc_days
  
mesg = 'Prima Dominical: '+TO_CHAR( earnings_amount)
      +' Dias: '+TO_CHAR(days)  
      +' SMDG: '+TO_CHAR(MIN_WAGE) 
      +' MIN_WAGE: '+TO_CHAR(MIN_WAGE)
      +' UMA: '+TO_CHAR(UMA)


  RETURN  earnings_amount
        , earnings_days
        , isr_subject
        , isr_exempt
		, mesg

/* ===== Returns Section End ===== */

/* End Formula Text */