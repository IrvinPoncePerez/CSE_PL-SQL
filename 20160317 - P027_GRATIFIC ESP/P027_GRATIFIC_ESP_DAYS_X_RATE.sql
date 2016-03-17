/***
Copyright  (c) EL CALVARIO S.A. DE C.V.
All rights reserved.
Implementación Oracle Nómina

   Formula: P027_GRATIFIC_ESP_DAYS_X_RATE
      Tipo: Oracle Payroll
   Elemento: P027_GRATIFIC_ESP
  

  FECHA     MODIFICO       DESCRIPCION                                    VERS.
  ========  ============   =============================================  =====
  29-JUL-15 AANTONIO(SS)   Actualización por adición de función de calculo
                           de Fecha de Antigüedad.                        1.0 

  17-AGO-15 AANTONIO(SS)   Actualización por adición de Organizaciones los
                           no se les calcula la Gratificación.   

***/

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
mesg1 = ' '
DiasGratif    = 15
Factor        = 30
DiasGratifMar = 0
DiasGratifMay = 0

/* ===== CALCULATION SECTION BEGIN ===== */
anio_f_inicio_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_START_DATE,'YYYY')) 
mes_f_inicio_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_START_DATE,'MM')) 
dia_f_inicio_per = TO_CHAR(PAY_PROC_PERIOD_START_DATE,'DD')
 
anio_f_fin_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_END_DATE,'YYYY')) 
mes_f_fin_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_END_DATE,'MM')) 

fecha_contratacion = '0001/01/01 00:00:00' (DATE)

fecha_contratacion = GET_HIRE_DATE()
fecha_aniversario  = '0001/01/01 00:00:00' (DATE) 

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

/**** Se adiciona condición para Organzaiciones Especiales *****/

Flag_Gratif_Esp_Org = 'N'
IF ASG_ORG LIKE '%1101%02%' OR ASG_ORG LIKE '%1102%' OR ASG_ORG LIKE '%1103%02%' OR ASG_ORG LIKE '%1104%' 
THEN
   (
    Flag_Gratif_Esp_Org = 'Y'
   )   

IF  FLAG_GRATIFICACION = 'MARZO' AND DIAS >= 60 THEN
( 
         IF Flag_Gratif_Esp_Org = 'Y' 
         THEN      
             (
              GratifMarzo   = 0
	      Gratificacion = GratifMarzo
             )
         ELSE
	     (
              GratifMarzo   = SalarioDiario * DiasGratifMar
	      Gratificacion = GratifMarzo
             )
)  ELSE (
  
  IF  FLAG_GRATIFICACION = 'MAYO' AND DIAS >= 60  THEN 
   (
       IF antiguedad > 2 AND SalarioDiario >= SUELDO_MAX THEN						
  	       (							  
  			GratifMayo = (SalarioDiario * ((DIAS *15)/DiasAnio)) - PTU
  			                                  
  		   )
              ELSE
  			  (
  			    IF Flag_Gratif_Esp_Org = 'Y' THEN
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
  
IF Gratificacion < 0 THEN  Gratificacion = 0

earnings_amount = ROUND(Gratificacion,2) 
					 
					 
	 mesg1 = 'P027: '             + to_char(earnings_amount)
         /*+ ',FhaFinAño: '            + to_char(FinAño)*/
          + ',DiasAñoAnt: '           + to_char(DIAS)
          + ',MesAño: '               + to_char(MesPago)	
          + ',PTU: '                  + to_char(PTU)	
		  + ',FhaIni: '       + to_char(FechaPeriodoAct)
		  + ',Antig: '        + (renglon_antiguedad)
		  + ',SdoAnt: '       + to_char(SueldoAnt)
		  + ',FhaAnt: '       + to_char(FechaUltPeriodoAnt)
		  + ',NumPerAño: '    + to_char(NumPerAño)
		  + ',DiasAño: '      + to_char(DiasAnio)
                 /* + ',Flag: '         + (Flag_Gratif_Esp_Org)*/ 
                  + ',DGMar: '        + to_char(TRUNC(DiasGratifMar,2))   
                  + ',DGMay: '        + to_char(TRUNC(DiasGratifMay,2)) 
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