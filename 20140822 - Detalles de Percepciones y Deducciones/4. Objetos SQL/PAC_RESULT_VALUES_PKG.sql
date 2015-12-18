CREATE OR REPLACE PACKAGE PAC_RESULT_VALUES_PKG AS

   
    FUNCTION GET_EARNING_VALUE (
             P_ASSIGNMENT_ACTION_ID    NUMBER,
             P_ELEMENT_NAME            VARCHAR2,
             P_INPUT_VALUE_NAME        VARCHAR2)
      RETURN VARCHAR2;
    
    
    FUNCTION GET_DEDUCTION_VALUE (
             P_ASSIGNMENT_ACTION_ID    NUMBER,
             P_ELEMENT_NAME            VARCHAR2,
             P_INPUT_VALUE_NAME        VARCHAR2)
      RETURN VARCHAR2;
      
    
    FUNCTION GET_INFORMATION_VALUE (
             P_ASSIGNMENT_ACTION_ID    NUMBER,
             P_ELEMENT_NAME            VARCHAR2,
             P_INPUT_VALUE_NAME        VARCHAR2)
      RETURN VARCHAR2;
        
        
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
        
    
    FUNCTION GET_EXEMPT_VALUE (
             P_ASSIGNMENT_ACTION_ID    NUMBER,
             P_ELEMENT_NAME            VARCHAR2,
             P_INPUT_VALUE_NAME1       VARCHAR2,
             P_INPUT_VALUE_NAME2       VARCHAR2)
      RETURN VARCHAR2;
        
    
    FUNCTION GET_DATA_MOVEMENT(
             P_PERSON_ID    NUMBER,
             P_TYPE         VARCHAR2,
             P_START_DATE   DATE,
             P_END_DATE     DATE)
      RETURN VARCHAR2;
      
      
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
      
      
    FUNCTION GET_TYPE_MOVEMENT(P_PERSON_ID      NUMBER,
                               P_END_MONTH    NUMBER,
                               P_YEAR           NUMBER)
      RETURN VARCHAR2;
      
      
    FUNCTION GET_MAX_ASSIGNMENT_ACTION_ID(P_ASSIGNMENT_ID        NUMBER,
                                          P_PAYROLL_ID           NUMBER,
                                          P_YEAR                 NUMBER)
      RETURN NUMBER;


END PAC_RESULT_VALUES_PKG;
