CREATE OR REPLACE PACKAGE ATET_SAVINGS_BANK_PKG IS

    /*****************      ARINCON     ****************/
    
    /*****************      SARIAS      ****************/
    
    /*****************      IPONCE      ****************/
    FUNCTION    GET_SAVING_BANK_ID
      RETURN    NUMBER;
    
    FUNCTION    GET_PERIOD_TYPE(P_PERSON_ID             NUMBER)
      RETURN    VARCHAR2;
      
    FUNCTION    GET_REGISTRATION_DATE
      RETURN    DATE;
      
    FUNCTION    GET_PARAMETER_VALUE(P_SAVING_BANK_ID          NUMBER,
                                    P_PARAMETER_CODE          VARCHAR2)
      RETURN    VARCHAR2;
      
    FUNCTION    IF_MEMBER_EXIST(P_EMPLOYEE_NUMBER      NUMBER)
      RETURN    NUMBER;
      
    FUNCTION    GET_MAX_ASSIGNMENT_ACTION_ID(P_ASSIGNMENT_ID        NUMBER,
                                             P_PAYROLL_ID           NUMBER)
      RETURN    NUMBER;
        
    FUNCTION    GET_SUBTBR(P_ASSIGNMENT_ACTION_ID      NUMBER)
      RETURN    NUMBER;
      
    FUNCTION    GET_ISRRET(P_ASSIGNMENT_ACTION_ID      NUMBER)
      RETURN    NUMBER;
      
    FUNCTION    GET_MONDET(P_ASSIGNMENT_ACTION_ID      NUMBER)
      RETURN    NUMBER;
      
    FUNCTION    GET_PERSON_TERMINATION_DATE(P_PERSON_ID     NUMBER)
      RETURN    VARCHAR2;
      
    FUNCTION    GET_MEMBER_TERMINATION_DATE(P_PERSON_ID     NUMBER)
      RETURN    VARCHAR2;
      
      
    PROCEDURE   EXPORT_PAYROLL_RESULTS(P_ERRBUF         OUT NOCOPY  VARCHAR2,
                                       P_RETCODE        OUT NOCOPY  VARCHAR2,
                                       P_PERIOD_TYPE    VARCHAR2,
                                       P_YEAR           NUMBER,
                                       P_MONTH          NUMBER,
                                       P_PERIOD_NAME    VARCHAR2);
                                       
    FUNCTION    GET_LOOKUP_MEANING (P_LOOKUP_TYPE    VARCHAR2,
                                    P_LOOKUP_CODE    VARCHAR2)
      RETURN    VARCHAR2;
      
    PROCEDURE   ROLLBACK_EXPORT_PAYRESULT(P_ERRBUF            OUT NOCOPY  VARCHAR2,
                                          P_RETCODE           OUT NOCOPY  VARCHAR2,
                                          P_EXPORT_REQUEST_ID NUMBER);
                                                
    PROCEDURE   CHANGE_AMOUNT_TO_SAVE(P_ERRBUF            OUT NOCOPY  VARCHAR2,
                                      P_RETCODE           OUT NOCOPY  VARCHAR2,
                                      P_EMPLOYEE_NUMBER   NUMBER,
                                      P_AMOUNT_TO_SAVE    NUMBER);  
                                      
    PROCEDURE   RESTART_SEQUENCE;
    
    FUNCTION    NEXT_VALUE_SEQUENCE(P_SEQUENCE_NAME     VARCHAR2)
      RETURN    NUMBER;
      
    FUNCTION    CURRENT_VALUE_SEQUENCE(P_SEQUENCE_NAME     VARCHAR2)
      RETURN    NUMBER;
    /*****************      LHERNANDEZ  ****************/

END ATET_SAVINGS_BANK_PKG;