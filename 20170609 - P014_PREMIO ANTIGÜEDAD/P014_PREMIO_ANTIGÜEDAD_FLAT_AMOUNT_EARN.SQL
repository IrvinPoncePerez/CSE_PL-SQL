/***
Copyright  (c) EL CALVARIO S.A. DE C.V.
All rights reserved.
Implementación Oracle Nómina

   Formula: P014_PREMIO_ANTIGÜEDAD_FLAT_AMOUNT_EARN   
      Tipo: Oracle Payroll
   Elemento: P014_PREMIO ANTIGÜEDAD
  

  FECHA     MODIFICO       DESCRIPCION                                    VERS.
  ========  ============   =============================================  =====
  29-JUL-15 AANTONIO(SS)   Actualización por adición de función de calculo
                           de Fecha de Antigüedad.                        1.0
  17-AGO-15 AANTONIO(SS)   Actualización para calcular la antigüedad en 
                           base a meses.                                  1.1

***/

/* ALIAS section */

ALIAS SCL_ASG_MX_WORK_SCHEDULE AS Work_Schedule

/* Database Item Defaults */

DEFAULT FOR flat_amount                    is 0
DEFAULT FOR mesg                           is 'NOT ENTERED'
DEFAULT FOR P014_PREMIO_ANTIGÜEDAD_ASG_GRE_YTD        is 0
DEFAULT FOR ASG_SALARY_BASIS IS 'NOT ENTERED'
DEFAULT FOR ASG_SALARY IS 0
DEFAULT FOR ASG_HOURS IS 40
DEFAULT FOR PAY_PROC_PERIOD_START_DATE IS '0001/01/01 00:00:00' (DATE)
DEFAULT FOR PAY_PROC_PERIOD_END_DATE IS '0001/01/02 00:00:00' (DATE)
DEFAULT FOR  EMP_HIRE_DATE                 is '0001/01/02 00:00:00' (DATE)
DEFAULT FOR  EMP_TERM_DATE                 is '0001/01/02 00:00:00' (DATE)
DEFAULT FOR ASG_FREQ_CODE IS 'W'
/* Assume that an employee works for 8 hours per day, 5 days a week.*/
DEFAULT FOR Work_Schedule IS '1 Schedule: 8-8-8-8-8-0-0'

/* Inputs  */

INPUTS ARE        Amount

/* =====Local variables =====  */
local_tax_type = 'ISR'
local_dummy_class_name = 'NONE'
isr_subject = 0
isr_exempt = 0
local_daily_salary = 0
local_gross_earnings = GROSS_EARNINGS_ASG_RUN
local_ytd_gross_earnings = GROSS_EARNINGS_ASG_YTD

nAnioUAniversario     = 0
nTempDPrestacion      = 0
flat_amount = 0
mss_por_anio  = 12

/* ===== CALCULATION SECTION BEGIN ===== */

FECHA_INGRESO = '0001/01/01 00:00:00' (DATE)

FECHA_INGRESO = GET_HIRE_DATE()
Anios_Antiguedad = DAYS_BETWEEN (EMP_TERM_DATE, FECHA_INGRESO) + 1
Anios_Antiguedad = TRUNC(Anios_Antiguedad / 365)
  
  Anios_Antiguedad = DAYS_BETWEEN (PAY_PROC_PERIOD_END_DATE, FECHA_INGRESO) + 1
    Dif_Anios_Antig= (Anios_Antiguedad / 365) - (TRUNC(Anios_Antiguedad / 365))
    IF Dif_Anios_Antig > 0.5 THEN Anios_Antiguedad = (TRUNC(Anios_Antiguedad / 365)) + 1 
  ELSE Anios_Antiguedad = TRUNC(Anios_Antiguedad / 365)

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

Fecha_Fija_Aniv =  '0001/04/09 00:00:00' (DATE) 
anio_aniversario  = TO_NUMBER(TO_CHAR(Fecha_Fija_Aniv,'YYYY')) 
mes_aniversario = TO_NUMBER(TO_CHAR(Fecha_Fija_Aniv,'MM')) 
dia_aniversario = TO_CHAR(Fecha_Fija_Aniv,'DD') 

Fecha_Pago = TO_DATE(TO_CHAR(anio_f_inicio_per) + '/' + 
                          TO_CHAR(mes_aniversario) + '/' + 
                                 dia_aniversario, 
                                 'YYYY/MM/DD')

Ant_Pago=TRUNC(MONTHS_BETWEEN(Fecha_Pago, fecha_contratacion) / 12, 0)

    IF Ant_Pago = 7  THEN
  (
  flat_amount= 1200
  )

  ELSE (

    IF Ant_Pago = 8 THEN
    (
    flat_amount= 600
    )
        
         ELSE(

      IF Ant_Pago = 9 THEN
      (
      flat_amount= 600
      )

       ELSE(

        IF Ant_Pago = 10 THEN
        (
        flat_amount= 600
        )
          ELSE
          (
          mes= 'No aplica'
          )
        )
              )
      )
/* ======ISR Subject calculation begins ======= */
    isr_subject = get_subject_earnings_ann
                    (local_tax_type,
                    flat_amount,
                    P014_PREMIO_ANTIGÜEDAD_ASG_YTD +
                    flat_amount,
                    local_gross_earnings +
                    flat_amount,
                    local_ytd_gross_earnings +
                    flat_amount,
                    local_daily_salary,
                    local_dummy_class_name)
    isr_exempt = flat_amount - isr_subject
/* ======ISR Subject calculation ends ======= */

mesg = 'P014 Premio Ant: ' + to_char(flat_amount) +
       ' Fha Aniv: '       + to_char(Fecha_Pago) + 
       ' Fha Contrn: '     + to_char(fecha_contratacion) +
       ' Antig Pago: '     + to_char(Ant_Pago)+
       ' DiasxAnl: '       + to_char(dias_por_anio)

soe_ytd = P014_PREMIO_ANTIGÜEDAD_ASG_GRE_YTD

RETURN flat_amount,
       mesg,
       isr_subject,
       isr_exempt

/* End Formula Text */