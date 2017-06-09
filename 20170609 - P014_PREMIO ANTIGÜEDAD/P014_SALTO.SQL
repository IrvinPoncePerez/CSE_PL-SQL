DEFAULT FOR flat_amount                    is 0
DEFAULT FOR Amount 						   is 0
DEFAULT FOR mesg                           is 'NOT ENTERED'
DEFAULT FOR P014_PREMIO_ANTIGÜEDAD_ASG_GRE_YTD        is 0
DEFAULT FOR ASG_SALARY_BASIS IS 'NOT ENTERED'
DEFAULT FOR ASG_SALARY IS 0
DEFAULT FOR PAY_PROC_PERIOD_START_DATE IS '0001/01/01 00:00:00' (DATE)
DEFAULT FOR PAY_PROC_PERIOD_END_DATE IS '0001/01/02 00:00:00' (DATE)
DEFAULT FOR  EMP_HIRE_DATE                 is '0001/01/02 00:00:00' (DATE)
DEFAULT FOR  EMP_TERM_DATE                 is '0001/01/02 00:00:00' (DATE)
DEFAULT FOR ASG_FREQ_CODE IS 'W'
/* Assume that an employee works for 8 hours per day, 5 days a week.*/
DEFAULT FOR Work_Schedule IS '1 Schedule: 8-8-8-8-8-0-0'

INPUTS ARE Amount

flat_amount = Amount
/****Dias por Año****/

FechaInicial = TO_DATE ('0001/01/01','YYYY/MM/DD')
FechaFinAño  = TO_DATE ('0001/12/31','YYYY/MM/DD')
dias_por_anio = DAYS_BETWEEN(FechaFinAño,FechaInicial)+1

/* === Fecha de aniversario === */ 

anio_f_inicio_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_START_DATE,'YYYY')) 
mes_f_inicio_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_START_DATE,'MM')) 
 
anio_f_fin_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_END_DATE,'YYYY')) 
mes_f_fin_per = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_END_DATE,'MM')) 
dia_f_fin_per = TO_CHAR(PAY_PROC_PERIOD_END_DATE,'DD')
 
fecha_contratacion = GET_HIRE_DATE()
anio_contratacion  = TO_NUMBER(TO_CHAR(fecha_contratacion,'YYYY')) 
mes_contratacion   = TO_NUMBER(TO_CHAR(fecha_contratacion,'MM')) 
dia_contratacion   = TO_CHAR(fecha_contratacion,'DD') 

Fecha_Fija_Aniv = '0001/04/09 00:00:00' (DATE)
anio_aniversario  = TO_NUMBER(TO_CHAR(Fecha_Fija_Aniv,'YYYY'))  
mes_aniversario = TO_NUMBER(TO_CHAR(Fecha_Fija_Aniv,'MM')) 
dia_aniversario = TO_CHAR(Fecha_Fija_Aniv,'DD') 
 
Fecha_Pago = TO_DATE(TO_CHAR(anio_f_inicio_per) + '/' + 
                     TO_CHAR(mes_aniversario) + '/' + 
                              dia_aniversario, 
                                 'YYYY/MM/DD')

Antiguedad_d = TRUNC(MONTHS_BETWEEN(Fecha_Pago, fecha_contratacion) / 12, 0)
  
IF (Fecha_Pago >= PAY_PROC_PERIOD_START_DATE) AND (Fecha_Pago <= PAY_PROC_PERIOD_END_DATE) 
 AND (Antiguedad_d >= 7) AND (Antiguedad_d < 11) THEN
 ( 
  SKIP_FLAG = 'N'
 )
 ELSE
   (
    SKIP_FLAG = 'Y'
	 )
IF (flat_amount >= 1 ) THEN
(
	SKIP_FLAG = 'N'	
)

 
RETURN SKIP_FLAG