CREATE OR REPLACE PACKAGE PAC_CFDI_FUNCTIONS_PKG AS

    /*
    Suma de todas las percepciones suma de gravado mas excento
    */
    FUNCTION GET_SUBTBR(P_ASSIGNMENT_ACTION_ID    NUMBER)
    RETURN NUMBER;

    /*
    ISR Retenido
    */    
    FUNCTION GET_ISRRET(P_ASSIGNMENT_ACTION_ID    NUMBER)
    RETURN NUMBER;
    
    /*
    Suma de los importes de deducciones excepto el ISR. 
    */    
    FUNCTION GET_MONDET(P_ASSIGNMENT_ACTION_ID    NUMBER)
    RETURN NUMBER;
    
    /*
    Dias Pagados.
    */    
    FUNCTION GET_DIAPAG(P_ASSIGNMENT_ACTION_ID    NUMBER)
    RETURN NUMBER;
    
    /*
    Fondo de ahorro acumulado del periodo consultado.
    */    
    FUNCTION GET_FAHOACUM(P_ASSIGNMENT_ACTION_ID    NUMBER,
                          P_DATE_EARNED             DATE,
                          P_TAX_UNIT_ID             NUMBER)
    RETURN NUMBER;

    /*
    TOTAL DE PERCEPCIONES GRAVADAS
    */    
    FUNCTION GET_PER_TOTGRA(P_ASSIGNMENT_ACTION_ID    NUMBER)
    RETURN NUMBER;
    
    /*
    TOTAL DE PERCEPCIONES EXENTAS
    */    
    FUNCTION GET_PER_TOTEXE(P_ASSIGNMENT_ACTION_ID    NUMBER)
    RETURN NUMBER;

    
    FUNCTION GET_NOM_DESCRI(P_PAYROLL_ACTION_ID   NUMBER)
    RETURN VARCHAR2;


END PAC_CFDI_FUNCTIONS_PKG;