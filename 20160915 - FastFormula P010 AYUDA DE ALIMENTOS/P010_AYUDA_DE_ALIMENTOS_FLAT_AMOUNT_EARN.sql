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
DEFAULT FOR P010_AYUDA_DE_ALIMENTOS_ASG_GRE_YTD        is 0
DEFAULT FOR ASG_SALARY_BASIS IS 'NOT ENTERED'
DEFAULT FOR ASG_SALARY IS 0
DEFAULT FOR ASG_HOURS IS 40
DEFAULT FOR PAY_PROC_PERIOD_START_DATE IS '0001/01/01 00:00:00' (DATE)
DEFAULT FOR PAY_PROC_PERIOD_END_DATE IS '0001/01/02 00:00:00' (DATE)
DEFAULT FOR ASG_FREQ_CODE IS 'W'
DEFAULT FOR Finiquito IS 0
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

IF Finiquito WAS NOT DEFAULTED THEN
(
flat_amount = Finiquito
)
Else
  (
  IF Finiquito WAS DEFAULTED THEN
    (
    flat_amount = Amount
    )
  ) 


/* ======ISR Subject calculation begins ======= */
    isr_subject = get_subject_earnings_ann
                    (local_tax_type,
                    flat_amount,
                    P010_AYUDA_DE_ALIMENTOS_ASG_GRE_YTD +
                    flat_amount,
                    local_gross_earnings +
                    flat_amount,
                    local_ytd_gross_earnings +
                    flat_amount,
                    local_daily_salary,
                    local_dummy_class_name)
    isr_exempt = flat_amount - isr_subject
/* ======ISR Subject calculation ends ======= */

mesg = 'P010 AYUDA DE ALIMENTOS : ' +
       ' Pay Value ' + to_char(flat_amount) + 
       ' isr_subject ' + to_char(isr_subject) +
       ' isr_exempt ' + to_char(isr_exempt)

soe_ytd = P010_AYUDA_DE_ALIMENTOS_ASG_GRE_YTD

RETURN flat_amount,
       mesg,
       isr_subject,
       isr_exempt

/* End Formula Text */