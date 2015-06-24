/*****************************************************************************

FORMULA NAME: _FLAT_AMOUNT_DEDN

FORMULA TYPE: Payroll

DESCRIPTION:  Formula for Flat Amount for Deduction Template for Mexico.
              Returns pay value (Amount);

*******************************************************************************

FORMULA TEXT

Formula Results :

 dedn_amt        Direct Result for Deduction Amount
 not_taken       Update Deduction Recurring Entry Not Taken
 to_arrears      Update Deduction Recurring Entry Arrears Contr
 set_clear       Update Deduction Recurring Entry Clear Arrears
 STOP_ENTRY      Stop current recurring entry
 to_total_owed   Update Deduction Recurring Entry Accrued
 mesg            Message (Warning)

*******************************************************************************/


/* Database Item Defaults */

default for INSUFFICIENT_FUNDS_TYPE             is 'NOT ENTERED'

/* ===== Database Item Defaults End ===== */

/* ===== Input Value Defaults Begin ===== */

default for Total_Owed                          is 0
default for Clear_Arrears (text)                is 'N'
default for Amount                              is 0
default for Periodos							is 0
default for Saldo                               is 0
DEFAULT FOR Saldo_Restante						IS 0
DEFAULT FOR PAY_PROC_PERIOD_START_DATE    		is '0001/01/01 00:00:00' (DATE)
DEFAULT FOR PAY_PROC_PERIOD_END_DATE      		is '4000/01/01 00:00:00' (DATE)
DEFAULT FOR EMP_HIRE_DATE                 		is '0001/01/01 00:00:00' (DATE)
DEFAULT FOR EMP_TERM_DATE                 		is '4000/01/01 00:00:00' (DATE)
DEFAULT FOR PERIODICIDAD 						IS 0
DEFAULT FOR CONTADOR 							IS 0
DEFAULT FOR Futuro1               IS 0


/* ===== Input Value Defaults End ===== */

DEFAULT FOR mesg                           is 'NOT ENTERED'
DEFAULT FOR mesg1                          is 'NOT ENTERED'

/* ===== Inputs Section Begin ===== */

INPUTS ARE
         Amount
        ,Total_Owed
        ,Clear_Arrears (text)
		,Periodos
		,Saldo
		,Saldo_Restante
		,PERIODICIDAD
		,CONTADOR
		,VALIDADOR
    ,Futuro1
/* ===== Inputs Section End ===== */

/* ===== Latest balance creation begin ==== */

          SOE_ytd = D062_FIN_CRED_INFONAVIT_ASG_GRE_YTD
          SOE_mtd = D062_FIN_CRED_INFONAVIT_ASG_GRE_MTD

/* ===== Latest balance creation end ==== */

dedn_amt          = Amount
to_total_owed     = 0
to_arrears        = 0
to_not_taken      = 0
total_dedn        = 0
insuff_funds_type = INSUFFICIENT_FUNDS_TYPE
net_amount        = NET_PAY_ASG_GRE_RUN
mSaldoRestante 		= 0
SaldoSinCobrar 		= 0

PERIODICIDAD = PERIODICIDAD
CONTADOR = CONTADOR




CONTADOR1 = CONTADOR + 1 
VALIDADOR1 = PERIODICIDAD - CONTADOR1
VALIDADOR = VALIDADOR1


IF VALIDADOR > 0 THEN
(

dedn_amt= 0
CONTADOR1 = CONTADOR1
VALIDADOR1 = VALIDADOR1

)
ELSE
( 

Amount= Amount / Periodos
dedn_amt= Amount
CONTADOR1 = 0 

) 

/* ====  Entry ITD Check Begin ==== */

   IF ( D062_FIN_CRED_INFONAVIT_ACCRUED_ENTRY_ITD = 0 AND
        D062_FIN_CRED_INFONAVIT_ACCRUED_ASG_GRE_ITD <> 0 ) THEN
   (
      to_total_owed = -1 * D062_FIN_CRED_INFONAVIT_ACCRUED_ASG_GRE_ITD + dedn_amt
   )

   IF ( D062_FIN_CRED_INFONAVIT_ARREARS_ENTRY_ITD = 0 AND
        D062_FIN_CRED_INFONAVIT_ARREARS_ASG_GRE_ITD <> 0 ) THEN
   (
      to_arrears = -1 * D062_FIN_CRED_INFONAVIT_ARREARS_ASG_GRE_ITD
   )

/* ====  Entry ITD Check End ==== */

/* ===== Arrears Section Begin ===== */

   IF Clear_Arrears = 'Y' THEN
   (
      to_arrears = -1 * D062_FIN_CRED_INFONAVIT_ARREARS_ASG_GRE_ITD
      set_clear = 'No'
   )
   ELSE
   (
      IF D062_FIN_CRED_INFONAVIT_ARREARS_ASG_GRE_ITD <> 0 THEN
      (
         to_arrears = -1 * D062_FIN_CRED_INFONAVIT_ARREARS_ASG_GRE_ITD
      )
   )

   IF ( net_amount - dedn_amt < 0 ) THEN
   (
      IF insuff_funds_type = 'ERRA' THEN
      (

         mesg = GET_MESG('PAY','PAY_MX_INSUFF_FUNDS_FOR_DED')
         RETURN mesg
      )
   )

   /* When there is no arrears */

   IF ( insuff_funds_type = 'PD' OR
        insuff_funds_type = 'NONE' ) THEN
   (
      IF ( net_amount - dedn_amt >= 0 ) THEN
      (
         to_arrears   = 0
         to_not_taken = 0
         dedn_amt     = dedn_amt
      )
      ELSE
      (
         IF ( insuff_funds_type = 'PD' ) THEN
         (
            to_arrears   = 0
            to_not_taken = dedn_amt - net_amount
            dedn_amt     = net_amount
         )
         ELSE
         (
            to_arrears   = 0
            to_not_taken = dedn_amt
            dedn_amt     = 0
         )
      )
   )
   ELSE  /* When there is arrears */
   (
      IF ( net_amount <= 0 ) THEN
      (
         to_arrears   = dedn_amt
         to_not_taken = dedn_amt
         dedn_amt     = 0
      )
      ELSE
      (
         total_dedn = dedn_amt + D062_FIN_CRED_INFONAVIT_ARREARS_ASG_GRE_ITD

         IF ( net_amount >= total_dedn ) THEN
         (
            to_arrears   = -1 * D062_FIN_CRED_INFONAVIT_ARREARS_ASG_GRE_ITD
            to_not_taken = 0
            dedn_amt     = total_dedn
         )
         ELSE
         (
            IF ( insuff_funds_type = 'APD' ) THEN
            (
               to_arrears   = total_dedn - net_amount
               to_arrears   = to_arrears - D062_FIN_CRED_INFONAVIT_ARREARS_ASG_GRE_ITD

               IF ( net_amount >= dedn_amt ) THEN
               (
                  to_not_taken = 0
               )
               ELSE
               (
                  to_not_taken = to_arrears
               )

               dedn_amt     = net_amount
            )
            ELSE
            (
               IF ( net_amount >= dedn_amt ) THEN
               (
                  to_arrears   = 0
                  to_not_taken = 0
                  dedn_amt     = dedn_amt
               )
               ELSE
               (
                  to_arrears   = dedn_amt
                  to_not_taken = dedn_amt
                  dedn_amt     = 0
               )
            )
         )
      )
   )

/* ===== Arrears Section End ===== */

/* ===== Stop Rule Section Begin ===== */

   to_total_owed = dedn_amt

   IF Total_Owed WAS NOT DEFAULTED THEN
   (
      total_accrued  = dedn_amt + D062_FIN_CRED_INFONAVIT_ACCRUED_ENTRY_ITD

      IF total_accrued  >= Total_Owed THEN
      (
         dedn_amt = Total_Owed - D062_FIN_CRED_INFONAVIT_ACCRUED_ENTRY_ITD

          /* The total has been reached - the return will stop the entry under
             these conditions.  Also, zero out Accrued balance.  */

          to_total_owed = -1 * D062_FIN_CRED_INFONAVIT_ACCRUED_ENTRY_ITD
          STOP_ENTRY = 'Y'

          mesg = GET_MESG('PAY','PAY_MX_STOPPED_ENTRY',
                                  'BASE_NAME','D062_FIN_CRED_INFONAVIT')
       )
	   
	   /*Definimos comportamiento de este concepto para finiquítos  */
	   
	   mSaldoRestante = (Total_Owed - total_accrued)

	   If (EMP_TERM_DATE >= PAY_PROC_PERIOD_START_DATE AND EMP_TERM_DATE <= PAY_PROC_PERIOD_END_DATE) and ( mSaldoRestante > 0 ) Then
	   (
			dedn_amt = dedn_amt + mSaldoRestante
			If net_amount <= mSaldoRestante Then
			(
				SaldoSinCobrar 	= dedn_amt - net_amount
				dedn_amt 		= net_amount
			)
			mSaldoRestante = Total_Owed - dedn_amt
			to_total_owed = -1 * Total_Owed
			
			STOP_ENTRY = 'Y'

			mesg = GET_MESG('PAY','PAY_MX_STOPPED_ENTRY',
                                  'BASE_NAME','D062_FIN_CRED_INFONAVIT')

	   )   
	   
   )

SALDO_ACUMULADO = trunc(Futuro1, 2) + trunc(dedn_amt, 2)
dedn_amt = trunc(dedn_amt, 2)

IF SALDO_ACUMULADO > 0 /*(D062_FIN_CRED_INFONAVIT_ACCRUED_ASG_GRE_ITD <> 0 )*/ THEN
	(
	Saldo = SALDO_ACUMULADO /* D062_FIN_CRED_INFONAVIT_ACCRUED_ASG_GRE_ITD + dedn_amt*/
	SaldoRestante = Total_Owed - Saldo
	SaldoAnterior = SaldoRestante + dedn_amt
	
	)
   
IF SALDO_ACUMULADO = 0 /*(D062_FIN_CRED_INFONAVIT_ACCRUED_ASG_GRE_ITD = 0)*/ THEN
	(
	Saldo = dedn_amt
	SaldoRestante = Total_Owed - Saldo
	SaldoAnterior = 0
	)
/* ===== Stop Rule Section End ===== */

   RETURN dedn_amt,
          to_not_taken,
          to_arrears,
          to_total_owed,
          STOP_ENTRY,
          set_clear,
		  mesg,
		  mesg1,
		  Saldo,
		  SaldoSinCobrar,
		  SaldoRestante,
		  CONTADOR1,
		  VALIDADOR1,
		  SaldoAnterior,
		  SALDO_ACUMULADO

/* End Formula Text */