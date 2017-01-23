/*****************************************************************************

SALTO DE CÁLCULO PARA BONO DE DESPENSA EN ESPECIE  

*****************************************************************************/

/* ===== Defaults Section Begin ===== */

DEFAULT FOR  PAY_PROC_PERIOD_END_DATE      is '0001/01/02 00:00:00' (DATE)
DEFAULT FOR  ASG_PAYROLL                   is 'SIN NOMINA'
DEFAULT FOR  ASG_ORG                       is 'NOT ENTERED'


Ausentismos = (A003_INCAP_MATERNIDAD_Days_ASG_GRE_RUN + A004_INCAP_RIES_TRABAJO_Days_ASG_GRE_RUN + A006_SUSPENSION_Days_ASG_GRE_RUN)

 IF Ausentismos > 0 THEN
 ( 
  SKIP_FLAG = 'Y'
 )
  
 ELSE
 (
  SKIP_FLAG = 'N'
 )

 RETURN SKIP_FLAG