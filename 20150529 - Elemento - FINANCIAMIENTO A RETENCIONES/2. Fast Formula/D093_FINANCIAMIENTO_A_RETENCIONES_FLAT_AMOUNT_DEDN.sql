/******************************************************************

Formula : D093_FINANCIAMIENTO_A_RETENCIONES_FLAT_AMOUNT_DEDN
Descripcion : Formula para corregir el problema con el impuesto
		 	  en la semana 5.

******************************************************************/

/* 			Database Item Defaults BEGIN		*/

DEFAULT FOR Total_a_Cobrar_P048		is 0
DEFAULT FOR Total_a_Cobrar			is 0
DEFAULT FOR Total_Restante			is 0
DEFAULT FOR Cobros_Restantes		is 0 
DEFAULT FOR Saldo_Acumulado 		is 0
DEFAULT FOR Pago_Unico				is 'N'
DEFAULT FOR ASG_PAYROLL				is 'SIN NOMINA'

/* 			Database Item Defaults END			*/

/* 			Inputs Section BEGIN 				*/

INPUTS ARE Total_a_Cobrar_P048,
		   Total_a_Cobrar,
		   Total_Restante,
		   Cobros_Restantes,
		   Saldo_Acumulado,
		   Pago_Unico

/* 			Inputs Section END 					*/

/*			Local Variables BEGIN				*/

ValorPago = 0
TotalRestante = 0
CobrosRestantes = 0
SaldoAcumulado = 0
SaldoAnterior = 0
SaldoRestante = 0
SaldoPagado = 0
mesg = 'D093_FINANCIAMIENTO_A_RETENCIONES '


/*			Local Variables BEGIN				*/

/*			Formula Body BEGIN					*/

IF ( ASG_PAYROLL LIKE '%SEM%' ) THEN (
	IF ( Total_a_Cobrar_P048 <> 0 ) THEN (
		
		Total_a_Cobrar = Total_a_Cobrar_P048
		Total_Restante = Total_a_Cobrar
		Cobros_Restantes = 8

	) ELSE (
		
		TotalRestante = Total_Restante
		CobrosRestantes = Cobros_Restantes

	)

	IF ( Total_Restante <> 0 ) THEN (

		IF ( Cobros_Restantes > 1 ) THEN (

			ValorPago = trunc((Total_a_Cobrar / 8), 2)
			TotalRestante = Total_Restante - ValorPago
			CobrosRestantes = Cobros_Restantes - 1

		) ELSE (
			IF ( Cobros_Restantes = 1 ) THEN (

				ValorPago = Total_Restante
				TotalRestante = 0
				CobrosRestantes = 0
				Total_a_Cobrar = 0

			)
		)

		SaldoAcumulado = Saldo_Acumulado + ValorPago
		SaldoAnterior = TotalRestante + ValorPago
		SaldoRestante = TotalRestante
		SaldoPagado = SaldoAcumulado

	) ELSE (

		ValorPago = 0
		TotalRestante = 0
		CobrosRestantes = 0
		SaldoAcumulado = 0
		SaldoAnterior = 0
		SaldoRestante = 0
		SaldoPagado = 0

	)

	IF (Pago_Unico = 'Y') THEN (

		ValorPago = Total_Restante
		TotalRestante = Total_Restante - ValorPago
		CobrosRestantes = 0
		SaldoAcumulado = Saldo_Acumulado + ValorPago
		SaldoAnterior = TotalRestante + ValorPago
		SaldoRestante = TotalRestante 
		SaldoPagado = SaldoAcumulado
		Total_a_Cobrar = 0

	)
)

/*			Formula Body END					*/

/*			Formula Results Return 				*/

	RETURN Total_a_Cobrar,
		   TotalRestante,
		   CobrosRestantes,
		   SaldoAcumulado,
		   SaldoAnterior,
		   SaldoRestante,
		   SaldoPagado,
		   ValorPago,
		   mesg

/*			End Formula Text					*/