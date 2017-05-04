CREATE OR REPLACE PACKAGE APPS.PAC_CFDI_FUNCTIONS_PKG AS

    /*
    Suma de todas las percepciones suma de gravado mas excento
    */
    FUNCTION GET_SUBTBR(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER;

    /*
    Suma de otras percepciones 
    */
    FUNCTION GET_SUBEMP(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER;
      
    /*
    Suma de pago por separación, prima de antigüedad e indemnización 
    */
    FUNCTION GET_TOTSEP(
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

    FUNCTION GET_PER_TOTSUL(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER;
      
    FUNCTION GET_PER_TOTSEP(
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
      
    FUNCTION IS_DOWNLOADING(
        P_DIRECTORY             VARCHAR2,
        P_RECORDS               NUMBER)
      RETURN BOOLEAN;    
      
    PROCEDURE TIMBRADO_CFDI_NOMINA(   
        P_ERRBUF    OUT NOCOPY  VARCHAR2,
        P_RETCODE   OUT NOCOPY  VARCHAR2,
        P_FILE_NAME             VARCHAR2,
        P_DIRECTORY_NAME        VARCHAR2);
        
    FUNCTION GET_PAYMENT_METHOD(
        P_ASSIGNMENT_ID         NUMBER)
      RETURN VARCHAR2;
      
    FUNCTION GET_UUID(
        P_EMPLOYEE_NUMBER           NUMBER,
        P_START_DATE                DATE,
        P_END_DATE                  DATE,
        P_CONSOLIDATION_SET_NAME    VARCHAR2)
      RETURN VARCHAR2;    
      
    FUNCTION GET_SUBSIDIO_EMPLEO(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER;
      
    FUNCTION GET_EFFECTIVE_START_DATE(
             P_PERSON_ID      NUMBER)
      RETURN DATE;
      
    FUNCTION GET_NOM_HEX_DIAS(
        P_ASSIGNMENT_ACTION_ID    NUMBER,
        P_INPUT_VALUE_NAME        VARCHAR2)
      RETURN NUMBER;
      
    FUNCTION GET_NOM_PER_TOTPAG(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER;
      
    FUNCTION GET_PROPOSED_SALARY(
        P_ASSIGNMENT_ID           NUMBER)
      RETURN NUMBER;

END PAC_CFDI_FUNCTIONS_PKG;