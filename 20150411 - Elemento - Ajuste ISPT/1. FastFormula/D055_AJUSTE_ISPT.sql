/*********************************************************************************

FORMULA NAME : D055_AJUSTE_ISPT

DESCRIPTION : Formula para realizar el ajuste del impuesto ISPT en la 5a. semana
			  y realizar el prorrateo del impuesto

*********************************************************************************/

/*		Database Items begin	 	*/

DEFAULT FOR  ASG_PAYROLL                   		is 'SIN NOMINA'
DEFAULT FOR  mesg                           	is 'NOT ENTERED'
DEFAULT FOR  PAY_PROC_PERIOD_END_DATE      		is '0001/01/02 00:00:00' (DATE)

DEFAULT FOR  Valor_Pago_D055 					is 0
DEFAULT FOR  Valor_Pago_P032					is 0
DEFAULT FOR  Total_a_Cobrar_D055  				is 0
DEFAULT FOR  Saldo_Pendiente_D055				is 0
DEFAULT FOR  Cobros_Pendientes_D055				is 0

/* 		Database items end 			*/

/* 		Inputs section begin 		*/

INPUTS ARE
	   	Valor_Pago_D055,
	   	Valor_Pago_P032,
	   	Total_a_Cobrar_D055,
	   	Saldo_Pendiente_D055,
	   	Cobros_Pendientes_D055

/* 		Inputs section end		*/

/* 		Local Variables	begin	*/

ValorPagoD055 = 0
ValorPagoP032 = 0
TOTALCOBRAR = 0
SALDOPENDIENTE = 0
COBROSPENDIENTES = 0

cobro = 0
num_week = 0
has_subsidy = 0

/* 		Local Variables	begin	*/

/*		Body Formula begin 		*/

IF ASG_PAYROLL LIKE '%SEM%' THEN (
	
	has_subsidy = HAS_SUBSIDY(PAY_PROC_PERIOD_END_DATE)
	num_week = GET_WEEK(PAY_PROC_PERIOD_END_DATE)

	IF num_week = 5 THEN (
		IF has_subsidy = 1 THEN (
		
			Valor_Pago_P032 = AVERAGE_SUBSIDY(PAY_PROC_PERIOD_END_DATE)
			ValorPagoD055 = trunc((( Valor_Pago_D055 + Valor_Pago_P032 ) / 8), 2)
			ValorPagoP032 = Valor_Pago_P032
			TOTALCOBRAR = trunc((Valor_Pago_D055 + Valor_Pago_P032), 2)
			SALDOPENDIENTE = trunc((TOTALCOBRAR - ValorPagoD055), 2)
			COBROSPENDIENTES = 7

			mesg = 'D055_ISPT: Total a Cobrar = ' + to_char(TOTALCOBRAR)
			     + ', Saldo Pendiente = ' + to_char(SALDOPENDIENTE) 
			     + ', Cobros Pendientes = ' + to_char(COBROSPENDIENTES)
			     + ', Semana = ' + to_char(num_week)
			     + '.'
		
		) ELSE (

			ValorPagoD055 = Valor_Pago_D055
			ValorPagoP032 = Valor_Pago_P032
			TOTALCOBRAR = 0
			SALDOPENDIENTE = 0
			COBROSPENDIENTES = 0
		
		)
	) ELSE (
		IF Saldo_Pendiente_D055 <> 0 THEN (

			IF Cobros_Pendientes_D055 > 1 THEN (

				cobro = trunc((Total_a_Cobrar_D055 / 8), 2)
			
				ValorPagoD055 = Valor_Pago_D055 + cobro
				ValorPagoP032 = Valor_Pago_P032
				TOTALCOBRAR = Total_a_Cobrar_D055
				SALDOPENDIENTE = trunc((Saldo_Pendiente_D055 - cobro), 2)
				COBROSPENDIENTES = Cobros_Pendientes_D055 - 1

			) ELSE (
				
				IF Cobros_Pendientes_D055 = 1 THEN (

					cobro = Saldo_Pendiente_D055

					ValorPagoD055 = Valor_Pago_D055 + cobro
					ValorPagoP032 = Valor_Pago_P032
					TOTALCOBRAR = 0
					SALDOPENDIENTE = Saldo_Pendiente_D055 - cobro
					COBROSPENDIENTES = Cobros_Pendientes_D055 - 1

				)

			)

			mesg = 'D055_ISPT: Total a Cobrar = ' + to_char(TOTALCOBRAR)
		     	 + ', Saldo Pendiente = ' + to_char(SALDOPENDIENTE) 
		     	 + ', Cobros Pendientes = ' + to_char(COBROSPENDIENTES)
		     	 + ', Semana = ' + to_char(num_week)
		     	 + '.'

		) ELSE (

			ValorPagoD055 = Valor_Pago_D055
			ValorPagoP032 = Valor_Pago_P032
			TOTALCOBRAR = 0
			SALDOPENDIENTE = 0
			COBROSPENDIENTES = 0

			mesg = 'D055_ISPT: Semana ' + to_char(num_week) + ' sin modificación.'

		)
	)

) ELSE (

	ValorPagoD055 = Valor_Pago_D055
	ValorPagoP032 = Valor_Pago_P032
	TOTALCOBRAR = 0
	SALDOPENDIENTE = 0
	COBROSPENDIENTES = 0

	mesg = 'D055_ISPT: Sin cambios en el elemento.'

)

/*		Body Formula end 		*/

/*		Return RESULTS 		*/
   RETURN 	ValorPagoD055,
   			ValorPagoP032,
			mesg,
			TOTALCOBRAR,
			SALDOPENDIENTE,
			COBROSPENDIENTES

/* End Formula Text */