CREATE OR REPLACE PACKAGE APPS.PAC_CFDI_FUNCTIONS_PKG AS

    /*
    Suma de todas las percepciones suma de gravado mas excento
    */
    FUNCTION GET_SUBTBR(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER;

    /*
    ISR Retenido
    */    
    FUNCTION GET_ISRRET(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER;
    
    /*
    Suma de los importes de deducciones excepto el ISR. 
    */    
    FUNCTION GET_MONDET(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER;
    
    /*
    Dias Pagados.
    */    
    FUNCTION GET_DIAPAG(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER;
    
    /*
    Fondo de ahorro acumulado del periodo consultado.
    */    
    FUNCTION GET_FAHOACUM(
        P_ASSIGNMENT_ACTION_ID    NUMBER,
        P_DATE_EARNED             DATE,
        P_TAX_UNIT_ID             NUMBER)
      RETURN NUMBER;

    /*
    TOTAL DE PERCEPCIONES GRAVADAS
    */    
    FUNCTION GET_PER_TOTGRA(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER;
    
    /*
    TOTAL DE PERCEPCIONES EXENTAS
    */    
    FUNCTION GET_PER_TOTEXE(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER;

    
    FUNCTION GET_NOM_DESCRI(
        P_PAYROLL_ACTION_ID   NUMBER)
      RETURN VARCHAR2;
      
      
    PROCEDURE CREATE_CFDI_NOMINA(
        P_ERRBUF    OUT NOCOPY  VARCHAR2,
        P_RETCODE   OUT NOCOPY  VARCHAR2,
        P_COMPANY_ID            VARCHAR2,
        P_PERIOD_TYPE           VARCHAR2,
        P_PAYROLL_ID            NUMBER,
        P_CONSOLIDATION_ID      NUMBER,
        P_YEAR                  NUMBER,
        P_MONTH                 NUMBER,
        P_PERIOD_NAME           VARCHAR2);
        
    PROCEDURE FILE_CFDI_NOMINA(
        P_ERRBUF    OUT NOCOPY  VARCHAR2,
        P_RETCODE   OUT NOCOPY  VARCHAR2,
        P_COMPANY_ID            VARCHAR2,
        P_PERIOD_TYPE           VARCHAR2,
        P_PAYROLL_ID            NUMBER,
        P_CONSOLIDATION_ID      NUMBER,
        P_YEAR                  NUMBER,
        P_MONTH                 NUMBER,
        P_PERIOD_NAME           VARCHAR2);

    PROCEDURE REPORT_CFDI_NOMINA(
        P_COMPANY_ID            VARCHAR2,
        P_PERIOD_TYPE           VARCHAR2,
        P_PAYROLL_ID            NUMBER,
        P_CONSOLIDATION_ID      NUMBER,
        P_YEAR                  NUMBER,
        P_MONTH                 NUMBER,
        P_PERIOD_NAME           VARCHAR2);
        
    FUNCTION  TEST_CONNECTION(
        P_DIRECTORY             VARCHAR2)
      RETURN VARCHAR2;  
      
    FUNCTION  FIND_FILE(
        P_DIRECTORY             VARCHAR2, 
        P_SUB_DIRECTORY         VARCHAR2, 
        P_FILE_NAME             VARCHAR2)
      RETURN BOOLEAN;   
      
    FUNCTION  IS_WORKING(
        P_DIRECTORY             VARCHAR2)
      RETURN BOOLEAN;
      
    FUNCTION GET_OUTPUT_FILES(
        P_DIRECTORY             VARCHAR2,
        P_SUB_DIRECTORY         VARCHAR2)
      RETURN PAC_CFDI_OUTPUT_FILES;
      
    FUNCTION GET_ERROR_FILES(
        P_DIRECTORY             VARCHAR2,
        P_SUB_DIRECTORY         VARCHAR2)
      RETURN PAC_CFDI_ERROR_FILES;       
      
    PROCEDURE TIMBRADO_CFDI_NOMINA(   
        P_ERRBUF    OUT NOCOPY  VARCHAR2,
        P_RETCODE   OUT NOCOPY  VARCHAR2,
        P_FILE_NAME             VARCHAR2,
        P_DIRECTORY_NAME        VARCHAR2);

END PAC_CFDI_FUNCTIONS_PKG;