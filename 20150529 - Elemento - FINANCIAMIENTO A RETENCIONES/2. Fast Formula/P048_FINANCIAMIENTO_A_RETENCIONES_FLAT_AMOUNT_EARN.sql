/******************************************************************

Formula : P048_FINANCIAMIENTO_A_RETENCIONES_FLAT_AMOUNT_EARN
Descripcion : Formula para corregir el problema con el impuesto
		 	  en la semana 5.

******************************************************************/

/* 			Database Item Defaults BEGIN		*/

DEFAULT FOR ASG_PAYROLL				is 'SIN NOMINA'
DEFAULT FOR Valor_Pago_D055			is 0
DEFAULT FOR Total_a_Cobrar			is 0

/* 			Database Item Defaults END			*/

/* 			Inputs Section BEGIN 				*/

INPUTS ARE Valor_Pago_D055,
		   Total_a_Cobrar

/* 			Inputs Section END 					*/

/*			Local Variables BEGIN				*/

ValorPago = 0
TotalCobrar = 0
ISRSubject = 0
ISRExempt = 0
Total_Cobrar_D093 = 0

SubsidioPromedio = GET_SUBSIDY()
ImpuestoPromedio = GET_TAX()
numWeek = GET_WEEK() 
hasSubsidy = HAS_SUBSIDY()

mesg = 'P048_FINANCIAMIENTO_A_RETENCIONES: '


/*			Local Variables END				*/

/*			Formula Body BEGIN					*/

IF ( ASG_PAYROLL LIKE '%SEM%') THEN (
	IF ( numWeek = 5 ) THEN (
		IF ( hasSubsidy = 1 ) THEN (

			ValorPago = trunc((Valor_Pago_D055 + SubsidioPromedio), 2)
			TotalCobrar = ValorPago
			ISRExempt = ValorPago

		) ELSE (
			IF ( Valor_Pago_D055 > ImpuestoPromedio ) THEN (
				
				ValorPago = trunc((Valor_Pago_D055 - ImpuestoPromedio), 2)
				TotalCobrar = ValorPago
				ISRExempt = ValorPago

			)
		)
	) ELSE (
		IF ( numWeek = 1 ) THEN (
			IF ( Total_a_Cobrar <> 0 ) THEN (

				Total_Cobrar_D093 = Total_a_Cobrar
				TotalCobrar = 0
			)
		)
	)
) ELSE (
	mesg = mesg + 'no aplica en nómina Quincenal.'
)

/*			Formula Body END					*/

/*			Formula Results Return 				*/

	RETURN ValorPago,
		   TotalCobrar,
		   ISRSubject,
		   ISRExempt,
		   Total_Cobrar_D093

/*			End Formula Text					*/