CREATE OR REPLACE PACKAGE PAC_RESULT_VALUES_PKG AS

    /*
    GET EARNINGS, SUPPLEMENTAL EARNINGS AND IMPUTED EARNINGS
    
    ----------------------
    @PARAM  P_ASSIGNMENT_ACTION_ID
    @PARAM  P_ELEMENT_NAME
        Earnings
            P001_SUELDO NORMAL
            P009_COMISIONES
            A001_AUSENTISMO
            A003_INCAP MATERNIDAD
            P027_GRATIFICACION_ESP
            A005_PERMISO SIN GOCE
            P044_RETROACTIVO
            P027_GRATIFIC_ESPECIAL
            A004_INCAP RIES TRABAJO
            P045_PERMISO X PATERNIDAD
            A007_PERMISO PATERNIDAD
            P015_DIAS ESPECIALES
            P013_SALARIOS PENDIENTES
            P012_SUBSIDIO INCAPACIDAD
        Inputed Earnings      
            P039_DESPENSA
            P039_BONO DESPENSA ESP
        Supplemental Earnings
            P042_INTERES_GANADO
            P014_PREMIO ANTIGÜEDAD
            P004_PRIMA DOMINICAL
            P038_BONO EXTRAORD
            P025_AYUDA_ESCOLAR
            P043_FONDO AHORRO EMP
            P011_AGUINALDO
            P006_PRIMA VACACIONAL
            P035_COMPENSACION
            P036_BECA_EDUCACIONAL
            P080_FONDO AHORRO TR ACUM
            P046_BONO CUATRIMESTRAL
            P022_PREMIO_PUNTUALIDAD
            P091_FONDO AHORRO E ACUM
            P021_PASAJES
            P023_BONO_PRODUCTIVIDAD
            P002_HORAS EXTRAS
            P003_FESTIVO SIN SEPTIMO
            P007_PREMIO ASISTENCIA
            P008_AYUDA DE DEFUNCION
    @PARAM  P_INPUT_VALUE_NAME 
    */   
    FUNCTION GET_EARNING_VALUE (
             P_ASSIGNMENT_ACTION_ID    NUMBER,
             P_ELEMENT_NAME            VARCHAR2,
             P_INPUT_VALUE_NAME        VARCHAR2)
      RETURN VARCHAR2;
    
    /*
    GET VOLUNTARY DEDUCTIONS AND INVOLUNTARY DEDUCTIONS
    
    -------------------------------
    @PARAM  P_ASSIGNMENT_ACTION_ID    
    @PARAM  P_ELEMENT_NAME
        Voluntary Deductions
            D058_INFONAVIT
            D072_PRESTAMO CAJA DE AHORRO
            D059_FONACOT
            D078_FINAN_COMPRA_GAS Special Features
            D057_CUOTA_SINDICAL Special Features
            D088_DAMNIFICADOS Special Features
            D083_FINAN_MEDICINA Special Features
            D078_FINAN_COMPRA_GAS
            D074_VARIOS_QYL Special Features
            D083_FINAN_MEDICINA
            D072_PRESTAMO CAJA DE AHORRO Special Features
            D065_LLAM_TELEFONICAS
            D089_COOPERACION
            D089_COOPERACION Special Features
            D066_ANTICIPO_SUELDO
            D058_INFONAVIT Special Features
            D088_DAMNIFICADOS
            D081_REPARACION_UNIDAD Special Features
            D090_DESCUENTOS_GR Special Features
            D087_FINAN_OPTICA
            D077_EXEDENTE_ALIMENTOS Special Features
            D062_FIN_CRED_INFONAVIT Special Features
            D066_ANTICIPO_SUELDO Special Features
            D073_CUOTA_SINDICAL_EXT Special Features
            D059_FONACOT Special Features
            D079_FINAN_CALZADO_IND
            D087_FINAN_OPTICA Special Features
            D085_FIN_ANALISIS_CLIN
            D057_CUOTA_SINDICAL
            D074_VARIOS_QYL
            D090_DESCUENTOS_GR
            D071_CAJA DE AHORRO Special Features
            D084_FALTANTES Special Features
            D062_FIN_CRED_INFONAVIT
            D065_LLAM_TELEFONICAS Special Features
            D079_FINAN_CALZADO_IND Special Features
        Involuntary Deductions
            D080_FONDO AHORRO TRABAJADOR
            D081_REPARACION_UNIDAD
            D077_EXEDENTE_ALIMENTOS
            D091_FONDO DE AHORRO EMPRESA
            D084_FALTANTES
            D076_DESC_PENSION_ALIM
            D073_CUOTA_SINDICAL_EXT            
    @PARAM  P_INPUT_VALUE_NAME 
    */    
    FUNCTION GET_DEDUCTION_VALUE (
             P_ASSIGNMENT_ACTION_ID    NUMBER,
             P_ELEMENT_NAME            VARCHAR2,
             P_INPUT_VALUE_NAME        VARCHAR2)
      RETURN VARCHAR2;
      
    /*
    GET INFORMATION VALUES
    
    ------------------------------
    @PARAM  P_ASSIGNMENT_ACTION_ID
    @PARAM  P_ELEMENT_NAME
        I002_IMSS_PATRONAL
        I001_SALARIO_DIARIO
        D066_ISPT
        P032_SUBSIDIO_PARA_EMPLEO
        D056_IMSS
        I003_INFONAVIT PATRONAL
        I004_IMPUESTO ESTATAL   
    @PARAM  P_INPUT_VALUE_NAME   
    */  
    FUNCTION GET_INFORMATION_VALUE (
             P_ASSIGNMENT_ACTION_ID    NUMBER,
             P_ELEMENT_NAME            VARCHAR2,
             P_INPUT_VALUE_NAME        VARCHAR2)
      RETURN VARCHAR2;
        
        
    /*
    GET OTHER ELEMENT VALUE
    
    @PARAM  P_ASSIGNMENT_ACTION_ID
    @PARAM  P_ELEMENT_NAME
    @PARAM  P_INPUT_VALUE_NAME  
    */    
    FUNCTION GET_OTHER_VALUE (
             P_ASSIGNMENT_ACTION_ID    NUMBER,
             P_ELEMENT_NAME            VARCHAR2,
             P_INPUT_VALUE_NAME        VARCHAR2)
      RETURN VARCHAR2;
      
    FUNCTION GET_OTHER_SUM_VALUE (
             P_ASSIGNMENT_ACTION_ID    NUMBER,
             P_ELEMENT_NAME            VARCHAR2,
             P_INPUT_VALUE_NAME        VARCHAR2)
      RETURN VARCHAR2;
        
    
    /*
    GET THE EXEMPT VALUE FROM COMPARING THE Pay Value WITH Tope.
    */
    FUNCTION GET_EXEMPT_VALUE (
             P_ASSIGNMENT_ACTION_ID    NUMBER,
             P_ELEMENT_NAME            VARCHAR2,
             P_INPUT_VALUE_NAME1       VARCHAR2,
             P_INPUT_VALUE_NAME2       VARCHAR2)
      RETURN VARCHAR2;
        
    
    /*
    GET THE DATA MOVEMENT OF PEOPLE BY PERSON_ID
    
    @PARAM P_PERSON_ID
    @PARAM P_TYPE   'A' ALTA, 'B' BAJA, 'MS' MODIFICACION DE SALARIO
    @P_DATE_START
    @P_DATE_END
    */
    FUNCTION GET_DATA_MOVEMENT(
             P_PERSON_ID    NUMBER,
             P_TYPE         VARCHAR2,
             P_START_DATE   DATE,
             P_END_DATE     DATE)
      RETURN VARCHAR2;
      
      
    /*
    GET THE EFFECTIVE START DATE BY PERSON_ID
    FROM PER_ALL_PEOPLE_F  
     */
    FUNCTION GET_EFFECTIVE_START_DATE(
             P_PERSON_ID      NUMBER)
      RETURN DATE;
      
      
    FUNCTION GET_BALANCE(P_ASSIGNMENT_ACTION_ID    NUMBER,
                           P_DATE_EARNED             DATE,
                           P_ELEMENT_NAME            VARCHAR2,
                           P_ENTRY_NAME              VARCHAR2)
      RETURN NUMBER;  
        
    FUNCTION GET_DESPENSA_EXEMPT(P_ASSIGNMENT_ACTION_ID     NUMBER,
                                 P_DESPENSA_RESULT          NUMBER,
                                 P_EFFECTIVE_DATE           DATE,
                                 P_PERIOD                   VARCHAR2)
      RETURN NUMBER;  

END PAC_RESULT_VALUES_PKG;