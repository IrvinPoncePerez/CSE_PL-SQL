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
DEFAULT FOR  ASG_SALARY                    is 0
DEFAULT FOR  ASG_SALARY_BASIS              is 'NOT ENTERED'
DEFAULT FOR  ASG_PAYROLL                   is 'SIN NOMINA'
DEFAULT FOR  EMP_HIRE_DATE                 is '0001/01/02 00:00:00' (DATE)
DEFAULT FOR  EMP_TERM_DATE                 is '0001/01/02 00:00:00' (DATE)


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
DiasGratif = 15
Factor =30



/* ===== CALCULATION SECTION BEGIN ===== */
anio_f_inicio_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_START_DATE,'YYYY')) 
mes_f_inicio_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_START_DATE,'MM')) 
dia_f_inicio_per = TO_CHAR(PAY_PROC_PERIOD_START_DATE,'DD')
 
anio_f_fin_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_END_DATE,'YYYY')) 
mes_f_fin_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_END_DATE,'MM')) 


fecha_contratacion = EMP_HIRE_DATE
fecha_aniversario =  '0001/01/01 00:00:00' (DATE) 

mes_aniversario = TO_NUMBER(TO_CHAR(fecha_contratacion,'MM')) 
dia_aniversario = TO_CHAR(fecha_contratacion,'DD') 
 
IF anio_f_inicio_per <> anio_f_fin_per  AND mes_aniversario = mes_f_inicio_per THEN  
  ( 
    IF mes_aniversario = 2 AND dia_aniversario = '29' AND MOD(anio_f_inicio_per,4) <> 0 THEN dia_aniversario = '28' 
 
	nAnioUAniversario 		= anio_f_inicio_per - 1
    fecha_aniversario 		= TO_DATE(TO_CHAR(anio_f_inicio_per) + '/' + 
                                 TO_CHAR(mes_aniversario) + '/' + 
                                 dia_aniversario, 
                                 'YYYY/MM/DD') 
	fecha_aniversario_ant	= TO_DATE(TO_CHAR(nAnioUAniversario) + '/' + 
								TO_CHAR(mes_aniversario) + '/' + 
								dia_aniversario, 
								'YYYY/MM/DD') 
  ) 
ELSE 
( 
    IF mes_aniversario = 2 AND dia_aniversario = '29' AND MOD(anio_f_fin_per,4) <> 0 THEN dia_aniversario = '28' 
 
	nAnioUAniversario 		= anio_f_fin_per - 1
    fecha_aniversario 		= TO_DATE(TO_CHAR(anio_f_fin_per) + '/' + 
                                TO_CHAR(mes_aniversario) + '/' + 
                                dia_aniversario, 
                                'YYYY/MM/DD') 
	fecha_aniversario_ant	= TO_DATE(TO_CHAR(nAnioUAniversario) + '/' + 
								TO_CHAR(mes_aniversario) + '/' + 
								dia_aniversario, 
								'YYYY/MM/DD') 
																
) 

/* === Antigüedad === */
MesPago = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_END_DATE,'MM'))

FechaInicial = TO_DATE ('0001/01/01','YYYY/MM/DD')
FechaFinAño  = TO_DATE ('0001/12/31','YYYY/MM/DD')
DiasAño = DAYS_BETWEEN(FechaFinAño,FechaInicial)+1

FinAño = To_DATE('31/12/'+ TO_CHAR(PAY_PROC_PERIOD_START_DATE, 'YYYY'),('DD/MM/YYYY'))

AnioUltPeriodo = TO_NUMBER(TO_CHAR(FinAño,'YYYY'))
MesUltPeriodo = TO_NUMBER(TO_CHAR(FinAño,'MM')) 
DiaUltPeriodo = TO_CHAR(FinAño,'DD') 


AnioAnterior = AnioUltPeriodo -1

FechaUltPeriodoAnt = TO_DATE(TO_CHAR(AnioAnterior) + '/' + 
								TO_CHAR(MesUltPeriodo) + '/' + 
								DiaUltPeriodo, 
								'YYYY/MM/DD')


FechaPeriodoAct = TO_DATE(TO_CHAR(anio_f_inicio_per) + '/' + 
								TO_CHAR(mes_f_inicio_per) + '/' + 
								dia_f_inicio_per, 
								'YYYY/MM/DD') 
											
								

NumPerAño= GET_PERIOD_PER_YEAR(FechaFinAño)	

IF  ASG_PAYROLL LIKE '%SEM%' THEN
(
  DiasAnio = NumPerAño * 7
)  
ELSE
( 
  IF  ASG_PAYROLL LIKE '%QUIN%' THEN
  (
    DiasAnio = 360
  )
)

PTU = BALANCE_FETCH('Profit Sharing','_ASG_YTD',PAY_PROC_PERIOD_END_DATE)	
SueldoAnt= XXCALV_GET_LAST_SALARY_F(FechaUltPeriodoAnt) 	
SalarioDiario = SueldoAnt / Factor
	 
	  
antiguedad = 0 
renglon_antiguedad = ' ' 
antiguedad = TRUNC(MONTHS_BETWEEN(/*fecha_aniversario*/FechaUltPeriodoAnt, fecha_contratacion) / 12, 0)
renglon_antiguedad = TO_CHAR(antiguedad)
 
dias_prestacion = TO_NUMBER (GET_TABLE_VALUE ('TABLA GRATIFICACION MAYO', 
                                                  'P027_GRATIFICACION_ESP', 
                                                   renglon_antiguedad) 
												   
                                  )


DIAS1= BALANCE_FETCH('P001_SUELDO NORMAL Days','_ASG_YTD',FechaUltPeriodoAnt) 
DIAS2= BALANCE_FETCH('A004_INCAP RIES TRABAJO Days','_ASG_YTD',FechaUltPeriodoAnt)
DIAS3= BALANCE_FETCH('P005_VACACIONES Days','_ASG_YTD',FechaUltPeriodoAnt)



DIAS = DIAS1 + DIAS2 + DIAS3

IF DIAS = DiasAnio THEN
  (
     
     DiasGratifMar = DiasGratif  
	 DiasGratifMay = dias_prestacion
	 
	 
  )
   ELSE
    (
	  DiasGratifMar = DIAS * DiasGratif / DiasAnio
	  DiasGratifMay = DIAS * dias_prestacion / DiasAnio
    )	
									  
	  
Gratificacion = 0
	 
	 
IF  FLAG_GRATIFICACION = 'MARZO' AND DIAS >= 60 THEN
( 
     
	 GratifMarzo = SalarioDiario * DiasGratifMar
	 Gratificacion = GratifMarzo

)  ELSE (
  
  IF  FLAG_GRATIFICACION = 'MAYO' AND DIAS >= 60  THEN 
   (
       IF antiguedad > 2 AND SalarioDiario >= SUELDO_MAX THEN						
  	       (							  
  			GratifMayo = (SalarioDiario * ((DIAS *15)/DiasAnio)) - PTU
  			                                  
  		   )
              ELSE
  			  (
  			    IF ASG_ORG LIKE '%1101%02%' OR ASG_ORG LIKE '%1102%' OR ASG_ORG LIKE '%1103%02%' OR ASG_ORG LIKE '%1104%' THEN
  				(
  				   GratifMayo = (SalarioDiario * ((DIAS *15)/DiasAnio)) - PTU
  				 )
                    ELSE				 
                      (			
  		               GratifMayo = (SalarioDiario * DiasGratifMay) - PTU
  			         )
  			  )	 
  			  
  	        Gratificacion = GratifMayo
   )

)
  
   earnings_amount = Gratificacion 
					 
					 
	 mesg1 = 'Fecha fin de año: ' + to_char(FinAño)
          + ', Dias Año Anterior: ' + to_char(DIAS)
          + ', Mes del Año: ' + to_char(MesPago)	
          + ', PTU: ' + to_char(PTU)	
		  + ',Fecha INICIO: ' + to_char(FechaPeriodoAct)
		  + ',Antiguedad: ' + (renglon_antiguedad)
		  + ',Sueldo Ant: ' + to_char(SueldoAnt)
		  + ',Fecha Ant: ' + to_char(FechaUltPeriodoAnt)
		  + ',Num Per Año: ' + to_char(NumPerAño)
		  + ',Dias Año: ' + to_char(DiasAnio)
		  /*+ ',Dias 1: ' + to_char(DIAS1)
		  + ',Dias 2: ' + to_char(DIAS2)
		  + ',Dias 3: ' + to_char(DIAS3)*/
	  

/* ===== CALCULATION SECTION END ===== */

/* ======ISR Subject calculation begins ======= */
    isr_subject = get_subject_earnings_ann
                    (local_tax_type,
                    earnings_amount,
                    P027_GRATIFIC_ESP_ASG_YTD +
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

  soe_ytd         = P027_GRATIFIC_ESP_ASG_GRE_YTD
  /*earnings_days   = calc_days*/

  RETURN  earnings_amount
       /* , earnings_days*/
        , isr_subject
        , isr_exempt
		, mesg1

/* ===== Returns Section End ===== */

/* End Formula Text */