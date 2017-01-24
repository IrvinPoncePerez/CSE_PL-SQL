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
DEFAULT FOR  ASG_PAYROLL                   is 'SIN NOMINA'

DEFAULT FOR flat_amount                    is 0
DEFAULT FOR mesg                           is 'NOT ENTERED'
DEFAULT FOR P039_DESPENSA_ASG_GRE_YTD        is 0
DEFAULT FOR ASG_SALARY_BASIS IS 'NOT ENTERED'
DEFAULT FOR ASG_SALARY IS 0
DEFAULT FOR ASG_HOURS IS 40
DEFAULT FOR PAY_PROC_PERIOD_START_DATE IS '0001/01/01 00:00:00' (DATE)
DEFAULT FOR PAY_PROC_PERIOD_END_DATE IS '0001/01/02 00:00:00' (DATE)
DEFAULT FOR ASG_FREQ_CODE IS 'W'
DEFAULT FOR Bono                     is 0
DEFAULT FOR Bono_Anterior            is 0

/* Assume that an employee works for 8 hours per day, 5 days a week.*/
DEFAULT FOR Work_Schedule IS '1 Schedule: 8-8-8-8-8-0-0'

/* Inputs  */

INPUTS ARE        Amount,
                  Bono,
				  Bono_Anterior		  

/* =====Local variables =====  */
local_tax_type = 'ISR'
local_dummy_class_name = 'NONE'
isr_subject = 0
isr_exempt = 0
local_daily_salary = 0
local_gross_earnings = GROSS_EARNINGS_ASG_RUN
local_ytd_gross_earnings = GROSS_EARNINGS_ASG_YTD

 ECON_ZONE 	=  GET_MX_ECON_ZONE()	
 MIN_WAGE_SDI  	=  TO_NUMBER(GET_MIN_WAGE('NONE','A' /*ECON_ZONE*/))
 
IF Bono_Anterior WAS NOT DEFAULTED THEN
    (
	   BonoAnt = Bono_Anterior
	 ) 
ELSE
  (
    IF Bono WAS DEFAULTED THEN
     (	
	   BonoAnt = 0
	 )  

   )
   
 IF Bono WAS NOT DEFAULTED THEN
    (
	   IF ASG_PAYROLL LIKE '%QUIN%' THEN
		  (
		    Amount= Bono + Bono_Anterior
			TOPE= (MIN_WAGE_SDI * .40)*15
		  )	
		ELSE
         (
          	IF ASG_PAYROLL LIKE '%SEM%' THEN
              (
                 Amount= Bono + Bono_Anterior
			     TOPE= (MIN_WAGE_SDI * .40)*7
			  )	 
		 )	  
		  
	    
	 )
	ELSE
	 (
	   IF Bono WAS DEFAULTED THEN
        (	
   		   IF ASG_PAYROLL LIKE '%02%QUIN%' THEN
             (
               Amount = BONO_QUIN + BonoAnt
			   TOPE= (MIN_WAGE_SDI * .40)*15
             )  
             ELSE
			 (
			   IF ASG_PAYROLL LIKE '%SEM%' THEN
                 (
                   Amount = BONO_SEM + BonoAnt
				   TOPE = (MIN_WAGE_SDI * .40)*7
                 )  
                ELSE
                  (				
                     IF ASG_PAYROLL LIKE '%08%QUIN%' THEN
                        (
                          Amount = BONO_QUIN_AP + BonoAnt
						  TOPE = (MIN_WAGE_SDI * .40)*15
                        ) 
				  )
              )
         )			  
	 )	
	 

flat_amount = Amount
TOPE_SDI = TOPE 


TopeSDI	=  (LEAST(flat_amount,TOPE_SDI))*-1

 mesg2 = ' SIN MENSAJE '
 Retroactivo = 0
		
/* Cambio porque alicia comentó que exenta este elemento al 100% siempre*/

          isr_exempt	=  flat_amount
          isr_subject	=  0		
		
mesg1 = 'P039 DESPENSA:  Bono: '    + to_char(flat_amount)   +
        ' Tope SDI: ' +   to_char(TopeSDI) 	+	
		' Zona Economica: ' +   to_char(MIN_WAGE_SDI) 	
		
	   
/* ======ISR Subject calculation begins ======= 
    isr_subject = get_subject_earnings_ann
                    (local_tax_type,
                    flat_amount,
                    P039_DESPENSA_ASG_YTD +
                    flat_amount,
                    local_gross_earnings +
                    flat_amount,
                    local_ytd_gross_earnings +
                    flat_amount,
                    local_daily_salary,
                    local_dummy_class_name)
    isr_exempt = flat_amount - isr_subject
 ======ISR Subject calculation ends ======= */

soe_ytd = P039_DESPENSA_ASG_GRE_YTD

RETURN flat_amount,
       isr_subject,
       isr_exempt,
       TopeSDI,
	   BonoAnt,
       mesg1,
       mesg2,
       Retroactivo

/* End Formula Text */