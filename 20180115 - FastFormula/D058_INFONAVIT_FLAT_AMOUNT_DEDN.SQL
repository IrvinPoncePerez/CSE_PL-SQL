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

/* ===== Input Value Defaults End ===== */

DEFAULT FOR mesg                           is 'NOT ENTERED'
default for ASG_SALARY							is 0
default for EMP_HIRE_DATE						is '1950/01/01 00:00:00' (date)
default for EMP_TERM_DATE						is '2099/01/02 00:00:00' (date)
default for Discount_Start_Date					is '1950/01/01 00:00:00' (date)
default for PAY_PROC_PERIOD_END_DATE			is '2099/01/02 00:00:00' (date)
default for PAY_PROC_PERIOD_START_DATE			is '1950/01/01 00:00:00' (date)
default for SeguroVivienda						is 7.5 
default for Discount_Type						is 'Not especified'
default for Discount_Value						is 0
DEFAULT FOR Credit_Grant_Date                   IS '1998/02/28 00:00:00' (date)
DEFAULT FOR ASG_PAYROLL IS ' '
default for Finiquito					is 0
/* ===== Inputs Section Begin ===== */

INPUTS ARE
         Amount
        ,Total_Owed
        ,Clear_Arrears (text)
		,Discount_Type
		,Discount_Value
		,Discount_Start_Date
		,Credit_Grant_Date
		,SeguroVivienda
		,Finiquito
		
/* ===== Inputs Section End ===== */

/* ===== Latest balance creation begin ==== */

          SOE_ytd = D058_INFONAVIT_ASG_GRE_YTD
          SOE_mtd = D058_INFONAVIT_ASG_GRE_MTD

/* ===== Latest balance creation end ==== */

dedn_amt          = Amount
to_total_owed     = 0
to_arrears        = 0
to_not_taken      = 0
total_dedn        = 0
insuff_funds_type = INSUFFICIENT_FUNDS_TYPE
net_amount        = NET_PAY_ASG_GRE_RUN

nFijo			  	= 0
nVariable		  	= 0
SeguroVivienda	  	= 0 
dFechaInicioMes		= '1950/01/01 00:00:00' (date)
dFechaFinMes		= '1950/01/31 00:00:00' (date)
Credit_Grant_Date_f  = '1998/02/28 00:00:00' (date)
Periodos = 0 

IF Finiquito WAS NOT DEFAULTED THEN
(
dedn_amt = Finiquito
)
 ELSE (

FUNCION_FLAG = XXCALV_MAX_FECHA_PERIODO (PAY_PROC_PERIOD_END_DATE)

/* SDI = Factor * Sueldo_Diario */
 SDI = GetIDW('REPORT', nFijo, nVariable, 'Y')
 
SMDG = GET_UMA_VALUE()


dFechaInicioDescuento 	= GREATEST(GREATEST(PAY_PROC_PERIOD_START_DATE, EMP_HIRE_DATE),Discount_Start_Date)
dFechaFinDescuento 	= LEAST(PAY_PROC_PERIOD_END_DATE, EMP_TERM_DATE)
dFechaInicioMes		= TO_DATE('01/' + TO_CHAR(PAY_PROC_PERIOD_START_DATE,'MM') + '/' + TO_CHAR(PAY_PROC_PERIOD_START_DATE,'YYYY'),('DD/MM/YYYY'))
dFechaFinMes			= TO_DATE(TO_CHAR(LAST_DAY(PAY_PROC_PERIOD_START_DATE),'DD') + '/' + TO_CHAR(PAY_PROC_PERIOD_START_DATE,'MM') + '/' + TO_CHAR(PAY_PROC_PERIOD_START_DATE,'YYYY'),('DD/MM/YYYY'))
nDiasMes				= DAYS_BETWEEN(dFechaFinMes, dFechaInicioMes) + 1
nDiasPeriodo 			= DAYS_BETWEEN(dFechaFinDescuento, dFechaInicioDescuento) + 1


Mes = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_END_DATE,'MM'))

IF (Mes = 2 OR Mes = 4 OR Mes = 6 OR Mes = 8 OR Mes = 10 OR Mes = 12) AND  ASG_PAYROLL LIKE '%SEM%' THEN
  (
   IF  FUNCION_FLAG = 'Y' THEN
    (
	 SeguroVivienda = 15
	 )
	)
	
	
	IF (Mes = 2 OR Mes = 4 OR Mes = 6 OR Mes = 8 OR Mes = 10 OR Mes = 12) AND  ASG_PAYROLL LIKE '%QUIN%' THEN
        (
        IF  PAY_PROC_PERIOD_START_DATE <= dFechaFinMes AND  dFechaFinMes <= PAY_PROC_PERIOD_END_DATE  THEN
           (
	        SeguroVivienda = 15
	        )
	    )
	
   	
/* Porcentaje */


If Discount_Type = '1' Then 
(
IF ASG_PAYROLL LIKE '%SEM%' THEN
 (

IF Credit_Grant_Date <= Credit_Grant_Date_f THEN
   (
   IF Discount_Value = 20 THEN
   (
    
	ECON_ZONE =  GET_MX_ECON_ZONE()	
    MIN_WAGE =  TO_NUMBER(GET_MIN_WAGE('NONE',ECON_ZONE))
	 
    nVeces = TRUNC((SDI / MIN_WAGE), 2)
    renglon_nVeces = TO_CHAR(nVeces)

    Porcentaje_20 = TO_NUMBER (GET_TABLE_VALUE ('PORCENTAJES INFONAVIT', 
                                                  'INPUT_20', 
                                                   renglon_nVeces) 
								)
								
	Discount_Value = Porcentaje_20 
	PorcentajeFinal= Discount_Value / 100
	
	IF EMP_HIRE_DATE > PAY_PROC_PERIOD_START_DATE and EMP_HIRE_DATE <= PAY_PROC_PERIOD_END_DATE THEN
     ( 
	 PorcentajeFinal= Discount_Value / 100
     DiasNoLab= (days_between(EMP_HIRE_DATE,PAY_PROC_PERIOD_START_DATE ))
	 DiasTrab = 6-DiasNoLab
	 SeptimoDia = 7/6
     dedn_amt = (( SDI *((DiasTrab * SeptimoDia) - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)) * PorcentajeFinal)
	 )
	 ELSE
	 (
	 DiasTrab = 6
	SeptimoDia = 7/6
	dedn_amt = (SDI * ((DiasTrab * SeptimoDia)  - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)  * PorcentajeFinal ) 
	  )
	 )
	
	
	IF Discount_Value = 25 THEN
   (
    
	ECON_ZONE =  GET_MX_ECON_ZONE()	
    MIN_WAGE =  TO_NUMBER(GET_MIN_WAGE('NONE',ECON_ZONE))
	 
    nVeces = TRUNC((SDI / MIN_WAGE), 2)
    renglon_nVeces = TO_CHAR(nVeces)
 
    Porcentaje_25 = TO_NUMBER (GET_TABLE_VALUE ('PORCENTAJES INFONAVIT', 
                                                  'INPUT_25', 
                                                   renglon_nVeces) 
								)
								
	Discount_Value = Porcentaje_25 
	PorcentajeFinal= Discount_Value / 100

	IF EMP_HIRE_DATE > PAY_PROC_PERIOD_START_DATE and EMP_HIRE_DATE <= PAY_PROC_PERIOD_END_DATE THEN
     ( 
	 PorcentajeFinal= Discount_Value / 100
     DiasNoLab= (days_between(EMP_HIRE_DATE,PAY_PROC_PERIOD_START_DATE ))
	 DiasTrab = 6-DiasNoLab
	 SeptimoDia = 7/6
     dedn_amt = (( SDI *((DiasTrab * SeptimoDia) - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)) * PorcentajeFinal)
	 )
	 ELSE
	 (
	 DiasTrab = 6
	SeptimoDia = 7/6
	dedn_amt = (SDI * ((DiasTrab * SeptimoDia)  - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)  * PorcentajeFinal ) 
	  )
	 )	
	
	
	IF Discount_Value = 30 THEN
   (
    
	ECON_ZONE =  GET_MX_ECON_ZONE()	
    MIN_WAGE =  TO_NUMBER(GET_MIN_WAGE('NONE',ECON_ZONE))
	 
    nVeces = TRUNC((SDI / MIN_WAGE), 2)
    renglon_nVeces = TO_CHAR(nVeces)
 
    Porcentaje_30 = TO_NUMBER (GET_TABLE_VALUE ('PORCENTAJES INFONAVIT', 
                                                  'INPUT_30', 
                                                   renglon_nVeces) 
								)
								
	Discount_Value = Porcentaje_30 
	PorcentajeFinal= Discount_Value / 100
	
	IF EMP_HIRE_DATE > PAY_PROC_PERIOD_START_DATE and EMP_HIRE_DATE <= PAY_PROC_PERIOD_END_DATE THEN
     ( 
	 PorcentajeFinal= Discount_Value / 100
     DiasNoLab= (days_between(EMP_HIRE_DATE,PAY_PROC_PERIOD_START_DATE ))
	 DiasTrab = 6-DiasNoLab
	 SeptimoDia = 7/6
     dedn_amt = (( SDI *((DiasTrab * SeptimoDia) - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)) * PorcentajeFinal)
	 )
	 ELSE
	 (
	 DiasTrab = 6
	SeptimoDia = 7/6
	dedn_amt = (SDI * ((DiasTrab * SeptimoDia)  - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)  * PorcentajeFinal ) 
	  )
	 )
	
  )
 ELSE
 (
	nPorcentaje 	= Discount_Value / 100
	
	IF EMP_HIRE_DATE > PAY_PROC_PERIOD_START_DATE and EMP_HIRE_DATE <= PAY_PROC_PERIOD_END_DATE THEN
     ( 
	 PorcentajeFinal= Discount_Value / 100
     DiasNoLab= (days_between(EMP_HIRE_DATE,PAY_PROC_PERIOD_START_DATE ))
	 DiasTrab = 6-DiasNoLab
	 SeptimoDia = 7/6
     dedn_amt = (( SDI *((DiasTrab * SeptimoDia) - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)) * PorcentajeFinal)
	 )
	 ELSE
	 (
	 DiasTrab = 6
	SeptimoDia = 7/6
	dedn_amt = (SDI * ((DiasTrab * SeptimoDia)  - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)  * nPorcentaje ) 
	  )
	 ) 
 
   )
   ELSE
   (
   IF Credit_Grant_Date <= Credit_Grant_Date_f THEN
   (
   IF Discount_Value = 20 THEN
   (
    
	ECON_ZONE =  GET_MX_ECON_ZONE()	
    MIN_WAGE =  TO_NUMBER(GET_MIN_WAGE('NONE',ECON_ZONE))
	 
    nVeces = TRUNC((SDI / MIN_WAGE), 2)
    renglon_nVeces = TO_CHAR(nVeces)

    Porcentaje_20 = TO_NUMBER (GET_TABLE_VALUE ('PORCENTAJES INFONAVIT', 
                                                  'INPUT_20', 
                                                   renglon_nVeces) 
								)
								
	Discount_Value = Porcentaje_20 
	PorcentajeFinal= Discount_Value / 100
	
	IF EMP_HIRE_DATE > PAY_PROC_PERIOD_START_DATE and EMP_HIRE_DATE <= PAY_PROC_PERIOD_END_DATE THEN
     ( 
	 PorcentajeFinal= Discount_Value / 100
     DiasNoLab= (days_between(EMP_HIRE_DATE,PAY_PROC_PERIOD_START_DATE ))
	 DiasTrab = 13-DiasNoLab
	 SeptimoDia = 15/13
     dedn_amt = (( SDI *((DiasTrab * SeptimoDia) - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)) * PorcentajeFinal)
	 )
	 ELSE
	 (
	 DiasTrab = 13
	SeptimoDia = 15/13
	dedn_amt = (SDI * ((DiasTrab * SeptimoDia)  - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)  * PorcentajeFinal ) 
	  )
	 )
	
	
	IF Discount_Value = 25 THEN
   (
    
	ECON_ZONE =  GET_MX_ECON_ZONE()	
    MIN_WAGE =  TO_NUMBER(GET_MIN_WAGE('NONE',ECON_ZONE))
	 
    nVeces = TRUNC((SDI / MIN_WAGE), 2)
    renglon_nVeces = TO_CHAR(nVeces)
 
    Porcentaje_25 = TO_NUMBER (GET_TABLE_VALUE ('PORCENTAJES INFONAVIT', 
                                                  'INPUT_25', 
                                                   renglon_nVeces) 
								)
								
	Discount_Value = Porcentaje_25 
	PorcentajeFinal= Discount_Value / 100

	IF EMP_HIRE_DATE > PAY_PROC_PERIOD_START_DATE and EMP_HIRE_DATE <= PAY_PROC_PERIOD_END_DATE THEN
     ( 
	 PorcentajeFinal= Discount_Value / 100
     DiasNoLab= (days_between(EMP_HIRE_DATE,PAY_PROC_PERIOD_START_DATE ))
	 DiasTrab = 13-DiasNoLab
	 SeptimoDia = 15/13
     dedn_amt = (( SDI *((DiasTrab * SeptimoDia) - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)) * PorcentajeFinal)
	 )
	 ELSE
	 (
	 DiasTrab = 13
	SeptimoDia = 15/13
	dedn_amt = (SDI * ((DiasTrab * SeptimoDia)  - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)  * PorcentajeFinal ) 
	  )
	 )	
	
	
	IF Discount_Value = 30 THEN
   (
    
	ECON_ZONE =  GET_MX_ECON_ZONE()	
    MIN_WAGE =  TO_NUMBER(GET_MIN_WAGE('NONE',ECON_ZONE))
	 
    nVeces = TRUNC((SDI / MIN_WAGE), 2)
    renglon_nVeces = TO_CHAR(nVeces)
 
    Porcentaje_30 = TO_NUMBER (GET_TABLE_VALUE ('PORCENTAJES INFONAVIT', 
                                                  'INPUT_30', 
                                                   renglon_nVeces) 
								)
								
	Discount_Value = Porcentaje_30 
	PorcentajeFinal= Discount_Value / 100
	
	IF EMP_HIRE_DATE > PAY_PROC_PERIOD_START_DATE and EMP_HIRE_DATE <= PAY_PROC_PERIOD_END_DATE THEN
     ( 
	 PorcentajeFinal= Discount_Value / 100
     DiasNoLab= (days_between(EMP_HIRE_DATE,PAY_PROC_PERIOD_START_DATE ))
	 DiasTrab = 13-DiasNoLab
	 SeptimoDia = 15/13
     dedn_amt = (( SDI *((DiasTrab * SeptimoDia) - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)) * PorcentajeFinal)
	 )
	 ELSE
	 (
	 DiasTrab = 13
	SeptimoDia = 15/13
	dedn_amt = (SDI * ((DiasTrab * SeptimoDia)  - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)  * PorcentajeFinal ) 
	  )
	 )
	
  )
 ELSE
 (
	nPorcentaje 	= Discount_Value / 100
	
	IF EMP_HIRE_DATE > PAY_PROC_PERIOD_START_DATE and EMP_HIRE_DATE <= PAY_PROC_PERIOD_END_DATE THEN
     ( 
	 PorcentajeFinal= Discount_Value / 100
     DiasNoLab= (days_between(EMP_HIRE_DATE,PAY_PROC_PERIOD_START_DATE ))
	 DiasTrab = 13-DiasNoLab
	 SeptimoDia = 15/13
     dedn_amt = (( SDI *((DiasTrab * SeptimoDia) - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)) * PorcentajeFinal)
	 )
	 ELSE
	 (
	 DiasTrab = 13
	SeptimoDia = 15/13
	dedn_amt = (SDI * ((DiasTrab * SeptimoDia)  - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)  * nPorcentaje ) 
	  )
	 ) 
   
 )

) 

/* Cuota Fija */
If Discount_Type = '2' Then 
(
  
    IF ASG_PAYROLL LIKE '%SEM%' THEN
    (
	Mes = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_END_DATE,'MM'))
	
	renglon_Mes = TO_CHAR(Mes)
	Periodo = TO_NUMBER (GET_TABLE_VALUE ('PERIODOS INFONAVIT SEM',   /*TABLA QUE SE MODIFICARA CADA AÑO */
                                                  'Mes', 
                                                   renglon_Mes) 
						)     
						
	IF EMP_HIRE_DATE > PAY_PROC_PERIOD_START_DATE and EMP_HIRE_DATE <= PAY_PROC_PERIOD_END_DATE THEN
     ( 
     DiasNoLab= (days_between(EMP_HIRE_DATE,PAY_PROC_PERIOD_START_DATE )) 
     DiasTrab = 6-DiasNoLab
	 SeptimoDia = 7/6
	 Dias_Trabajados = ((DiasTrab * SeptimoDia )- AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)
	 Desc_Dia= ((Discount_Value / Periodo)/7)
	 dedn_amt = (Desc_Dia * Dias_Trabajados)
      )					
	  ELSE
	(				
    SeptimoDia = 7/6
    DiasTrab = 6
	Dias_Trabajados = ((DiasTrab * SeptimoDia )- AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)
	Desc_Dia= ((Discount_Value / Periodo)/7)
	dedn_amt = (Desc_Dia * Dias_Trabajados)
	 )
	) 
		
	IF ASG_PAYROLL LIKE '%QUIN%' THEN
    (
	Mes = TO_NUMBER(TO_CHAR(PAY_PROC_PERIOD_END_DATE,'MM'))
	
	renglon_Mes = TO_CHAR(Mes)
	Periodo = TO_NUMBER (GET_TABLE_VALUE ('PERIODOS INFONAVIT SEM',   /*TABLA QUE SE MODIFICARA CADA AÑO */
                                                  'Mes', 
                                                   renglon_Mes) 
						)
	
	IF EMP_HIRE_DATE > PAY_PROC_PERIOD_START_DATE and EMP_HIRE_DATE <= PAY_PROC_PERIOD_END_DATE THEN
     ( 
     DiasNoLab= (days_between(EMP_HIRE_DATE,PAY_PROC_PERIOD_START_DATE )) 
     DiasTrab = (13 - DiasNoLab)
	 SeptimoDia = 15/13
	 Dias_Trabajados = ((DiasTrab * SeptimoDia )- AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)
	 Desc_Dia= ((Discount_Value / Periodo)/15)
	 dedn_amt = (Desc_Dia * Dias_Trabajados)
      )					
	  ELSE
	(		
	    SeptimoDia = 15/13
        DiasTrab = 13
		Dias_Trabajados = ((DiasTrab * SeptimoDia )- AUSENTISMOS_INFONAVIT_ASG_GRE_RUN)
		Desc_Dia = ((Discount_Value / 2)/15)
		dedn_amt = (Desc_Dia * Dias_Trabajados)
		)
		
	)
)	

/* Descuento en veces salario minimo */
If Discount_Type = '3' Then 
(
	IF ASG_PAYROLL LIKE '%SEM%' THEN
    (
	 
	SeptimoDia = 7/6
    DiasTrab = 6
	nCuotaMes		= ((Discount_Value * SMDG) / 30.4)
	
	IF EMP_HIRE_DATE > PAY_PROC_PERIOD_START_DATE and EMP_HIRE_DATE <= PAY_PROC_PERIOD_END_DATE THEN
     ( 
     DiasNoLab= (days_between(EMP_HIRE_DATE,PAY_PROC_PERIOD_START_DATE )) 
     DiasTrab = 6-DiasNoLab
	 dedn_amt 		= (((DiasTrab * SeptimoDia)  - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN) * nCuotaMes)
      )
	 ELSE
	(
	DiasTrab = 6
	dedn_amt 		= (((DiasTrab * SeptimoDia)- AUSENTISMOS_INFONAVIT_ASG_GRE_RUN) * nCuotaMes)
	 )
	 )
		 
	 IF ASG_PAYROLL LIKE '%QUIN%' THEN
		(
		SeptimoDia = 15/13
        DiasTrab = 13
		nCuota	= (Discount_Value * SMDG) /30
		IF EMP_HIRE_DATE > PAY_PROC_PERIOD_START_DATE and EMP_HIRE_DATE <= PAY_PROC_PERIOD_END_DATE THEN
         ( 
         DiasNoLab= (days_between(EMP_HIRE_DATE,PAY_PROC_PERIOD_START_DATE )) 
         DiasTrab = 13-DiasNoLab
	     dedn_amt 		= (((DiasTrab * SeptimoDia)  - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN) * nCuota)
         )
	    ELSE
		 (		
		DiasTrab = 13
		dedn_amt 		= (((DiasTrab * SeptimoDia)  - AUSENTISMOS_INFONAVIT_ASG_GRE_RUN) * nCuota)
		 )
		)
	
)



dedn_amt = dedn_amt + SeguroVivienda

MESG1 = 'START_DATE:' + TO_CHAR (PAY_PROC_PERIOD_START_DATE) + 'FECHA FIN PER' + TO_CHAR (PAY_PROC_PERIOD_END_DATE) + 'MES:' + TO_CHAR (Mes) + 'FECHA FIN PER' + TO_CHAR (dFechaFinMes)
 
)


/* ====  Entry ITD Check Begin ==== */

   IF ( D058_INFONAVIT_ACCRUED_ENTRY_ITD = 0 AND
        D058_INFONAVIT_ACCRUED_ASG_GRE_ITD <> 0 ) THEN
   (
      to_total_owed = -1 * D058_INFONAVIT_ACCRUED_ASG_GRE_ITD + dedn_amt
   )

   IF ( D058_INFONAVIT_ARREARS_ENTRY_ITD = 0 AND
        D058_INFONAVIT_ARREARS_ASG_GRE_ITD <> 0 ) THEN
   (
      to_arrears = -1 * D058_INFONAVIT_ARREARS_ASG_GRE_ITD
   )

/* ====  Entry ITD Check End ==== */

/* ===== Arrears Section Begin ===== */

   IF Clear_Arrears = 'Y' THEN
   (
      to_arrears = -1 * D058_INFONAVIT_ARREARS_ASG_GRE_ITD
      set_clear = 'No'
   )
   ELSE
   (
      IF D058_INFONAVIT_ARREARS_ASG_GRE_ITD <> 0 THEN
      (
         to_arrears = -1 * D058_INFONAVIT_ARREARS_ASG_GRE_ITD
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
            dedn_amt     = net_amount  /* 0 valor removido */
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
         total_dedn = dedn_amt + D058_INFONAVIT_ARREARS_ASG_GRE_ITD

         IF ( net_amount >= total_dedn ) THEN
         (
            to_arrears   = -1 * D058_INFONAVIT_ARREARS_ASG_GRE_ITD
            to_not_taken = 0
            dedn_amt     = total_dedn
         )
         ELSE
         (
            IF ( insuff_funds_type = 'APD' ) THEN
            (
               to_arrears   = total_dedn - net_amount
               to_arrears   = to_arrears - D058_INFONAVIT_ARREARS_ASG_GRE_ITD

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
                  dedn_amt     = net_amount /* 0 valor removido */
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
      total_accrued  = dedn_amt + D058_INFONAVIT_ACCRUED_ENTRY_ITD

      IF total_accrued  >= Total_Owed THEN
      (
         dedn_amt = Total_Owed - D058_INFONAVIT_ACCRUED_ENTRY_ITD

          /* The total has been reached - the return will stop the entry under
             these conditions.  Also, zero out Accrued balance.  */

          to_total_owed = -1 * D058_INFONAVIT_ACCRUED_ENTRY_ITD
          STOP_ENTRY = 'Y'

          mesg = GET_MESG('PAY','PAY_MX_STOPPED_ENTRY',
                                  'BASE_NAME','D058_INFONAVIT')
       )
   )

/* ===== Stop Rule Section End ===== */

   RETURN dedn_amt,
          to_not_taken,
          to_arrears,
          to_total_owed,
          STOP_ENTRY,
          set_clear,
          mesg,
		  MESG1
	

/* End Formula Text */
