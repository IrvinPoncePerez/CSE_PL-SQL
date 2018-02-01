/*****************************************************************************
FORMULA NAME:   HOURS_X_RATE

FORMULA TYPE:   Payroll

DESCRIPTION:    Formula for Hours X Rate element
                where Hours must be input, Multiple defaults to 1
                if not input,  and Rate is determined by one of
                the following, in order of preference:
                1) Entry of "Rate" input value
                2) Salary Admin "Pay Basis" information

--
INPUTS:         Hours
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
DEFAULT FOR  ASG_SALARY                    is 0
DEFAULT FOR  ASG_SALARY_BASIS              is 'NOT ENTERED'
DEFAULT FOR ASG_PAYROLL IS ' '
  /* IF Work_Schedule is not entered, this is assumed that employee works
     8 hours a day and 5 days a week */

DEFAULT FOR  Work_Schedule                 is '1 Schedule: 8-8-8-8-8-0-0'
DEFAULT FOR  Timecard_Required             is 'N'
/*DEFAULT FOR  Includes_Rest_Days            is 'N'*/
DEFAULT FOR  Hours                         is 0
DEFAULT FOR  Rate                          is 0
DEFAULT FOR  Multiple                      is 1
DEFAULT FOR  ASG_FREQ_CODE                 is 'W'
DEFAULT FOR  ASG_HOURS                     is 40
DEFAULT FOR  mesg                          is 'NOT ENTERED'
DEFAULT FOR Finiquito IS 0
DEFAULT FOR  EMP_HIRE_DATE                 is '0001/01/02 00:00:00' (DATE)
DEFAULT FOR  EMP_TERM_DATE                 is '0001/01/02 00:00:00' (DATE)

/* ===== Defaults Section End ===== */

/* ===== Inputs Section Begin ===== */

Inputs are      Hours,
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

/* ===== CALCULATION SECTION BEGIN ===== */
FactorSem= 30
FactorQui= 30
TOPE_DOBLEQ=18
TOPE_DOBLE_S=9
ECON_ZONE =  GET_MX_ECON_ZONE()	
MIN_WAGE =  TO_NUMBER(GET_MIN_WAGE('NONE',ECON_ZONE))
UMA = GET_UMA_VALUE()
EX_SDI= 0
isr_exempt_1 = 0
isr_subject_1= 0

isr_exempt_2 = 0
isr_subject_2= 0

IF Finiquito WAS NOT DEFAULTED THEN
(
       earnings_amount = Finiquito
       SD = 0
       Cost_x_Hora = 0

    IF ASG_PAYROLL LIKE '%QUIN%' THEN
      (
       isr_exempt_2  = 10 * UMA
       isr_exempt_2  = LEAST(isr_exempt_2 , ( earnings_amount/2 ))
       isr_subject_2 = earnings_amount - isr_exempt_2
	   )
	 ELSE  
	 (
	    isr_exempt_1  = 5 * UMA
        isr_exempt_1  = LEAST(isr_exempt_1 , ( earnings_amount/2))
        isr_subject_1 = earnings_amount - isr_exempt_1
      )

)

ELSE
(
  IF Finiquito WAS  DEFAULTED THEN
  (
 
     IF ASG_PAYROLL LIKE '%QUIN%' THEN
     (
       SD = ASG_SALARY / FactorQui
       Cost_x_Hora= (SD/8)*2
	   DOBLEQ= LEAST( Hours, TOPE_DOBLEQ)
   	   earnings_amount = (DOBLEQ*Cost_x_Hora)
	
       isr_exempt_2  = 10 * UMA
       isr_exempt_2  = LEAST(isr_exempt_2 , ( earnings_amount/2 ))
       isr_subject_2 = earnings_amount - isr_exempt_2
	 )  
       ELSE
      (
	   SD = ASG_SALARY / FactorSem
       Cost_x_Hora= (SD/8)*2
	   DOBLE_S= LEAST( Hours, TOPE_DOBLE_S)
	   earnings_amount = (DOBLE_S*Cost_x_Hora)
		
        isr_exempt_1  = 5 * UMA
        isr_exempt_1  = LEAST(isr_exempt_1 , ( earnings_amount/2))
        isr_subject_1 = earnings_amount - isr_exempt_1
       )
   )
 )  
   
  mesg = 'SD:' + TO_CHAR(SD) + 'CUOTA DÍARIA:' + TO_CHAR (Cost_x_Hora)
   
   EX_SDI = earnings_amount * -1
   
   
   
   

/* ===== CALCULATION SECTION END ===== */

/* ======ISR Subject calculation begins ======= */
    isr_subject = isr_subject_2 + isr_subject_1
    isr_exempt = isr_exempt_2 + isr_exempt_1
/* ======ISR Subject calculation ends ======= */

/* ===== Returns Section Begin ===== */

  soe_ytd         = P002_HORAS_EXTRAS_ASG_GRE_YTD
  earnings_hours  = hours

  RETURN  earnings_amount
        , earnings_hours
        , mesg
        , isr_subject
        , isr_exempt
		, EX_SDI

/* ===== Returns Section End ===== */

/* End Formula Text */