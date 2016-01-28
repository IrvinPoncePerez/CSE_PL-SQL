CREATE OR REPLACE PACKAGE ATET_SAVINGS_BANK_PKG IS


    FUNCTION    GET_SAVING_BANK_ID
      RETURN    NUMBER;
      
    FUNCTION    GET_SAVING_BANK_YEAR
      RETURN    NUMBER;
    
    FUNCTION    GET_AVAILABLE_PERIODS(P_MEMBER_ID   NUMBER)
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
                                       
    PROCEDURE   IMPORT_PAYROLL_RESULTS(P_ERRBUF            OUT NOCOPY  VARCHAR2,
                                       P_RETCODE           OUT NOCOPY  VARCHAR2,
                                       P_EXPORT_REQUEST_ID NUMBER);
                                       
    PROCEDURE   CREATE_ACCOUNT(P_PERSON_ID              NUMBER,
                               P_PARAM_ELEMENT_NAME     VARCHAR2,
                               P_PARAM_CODE_COMBINATION VARCHAR2);
                                       
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
    
    FUNCTION    GET_MEMBER_ID(P_PERSON_ID   NUMBER)
      RETURN    NUMBER;
      
    FUNCTION    GET_MEMBER_IS_SAVER(P_MEMBER_ID     NUMBER)
      RETURN    VARCHAR2;
      
    FUNCTION    GET_CODE_COMBINATION_ID(P_CODE_COMBINATION    VARCHAR2)
      RETURN    NUMBER;
      
    FUNCTION   INSERT_SAVING_TRANSACTION(P_PAYROLL_RESULT_ID   NUMBER,
                                         P_PERSON_ID           NUMBER,
                                         P_EARNED_DATE         DATE,
                                         P_TIME_PERIOD_ID      NUMBER,
                                         P_PERIOD_NAME         VARCHAR2,
                                         P_ELEMENT_NAME        VARCHAR2,
                                         P_ENTRY_NAME          VARCHAR2,
                                         P_ENTRY_UNITS         VARCHAR2,
                                         P_ENTRY_VALUE         NUMBER,
                                         P_DEBIT_AMOUNT        NUMBER,
                                         P_CREDIT_AMOUNT       NUMBER)
      RETURN    VARCHAR2;
      
    FUNCTION   INSERT_LOAN_TRANSACTION(P_EXPORT_REQUEST_ID   NUMBER,
                                       P_PAYROLL_RESULT_ID   NUMBER,
                                       P_PERSON_ID           NUMBER,
                                       P_RUN_RESULT_ID       NUMBER,
                                       P_EARNED_DATE         DATE,
                                       P_TIME_PERIOD_ID      NUMBER,
                                       P_PERIOD_NAME         VARCHAR2,
                                       P_ELEMENT_NAME        VARCHAR2,
                                       P_ENTRY_NAME          VARCHAR2,
                                       P_ENTRY_UNITS         VARCHAR2,
                                       P_ENTRY_VALUE         NUMBER,
                                       P_DEBIT_AMOUNT        NUMBER,
                                       P_CREDIT_AMOUNT       NUMBER)
      RETURN    VARCHAR2;
     
    FUNCTION    GET_SAVING_MEMBER_ACCOUNT_ID(P_MEMBER_ID            NUMBER,
                                             P_ACCOUNT_NUMBER       VARCHAR2,
                                             P_ACCOUNT_DESCRIPTION  VARCHAR2)
      RETURN    NUMBER;
      
    FUNCTION    GET_LOAN_MEMBER_ACCOUNT_ID(P_MEMBER_ID          NUMBER,
                                           P_LOAN_ID            NUMBER)
      RETURN    NUMBER;
      
      
    PROCEDURE   SET_LOAN_BALANCE(P_LOAN_ID            NUMBER,
                                 P_LOAN_AMOUNT        NUMBER,
                                 P_PERSON_ID          NUMBER);


    PROCEDURE   INSERT_EXTEMPORANEOUS_SAVING(P_ERRBUF               OUT NOCOPY  VARCHAR2,
                                             P_RETCODE              OUT NOCOPY  VARCHAR2,
                                             P_PERSON_ID            NUMBER,
                                             P_SAVING_AMOUNT        NUMBER,
                                             P_PENDING_PAYMENT      NUMBER);
                                             
    FUNCTION    GET_POSIBILITY_SAVING(P_PERSON_ID           NUMBER)
      RETURN    NUMBER;
      
    FUNCTION    GET_RESULT_FROM_PAYROLL_RESULT(P_PERSON_ID                 NUMBER,
                                               P_EXPORT_REQUEST_ID         NUMBER,
                                               P_RUN_RESULT_ID             NUMBER,
                                               P_ENTRY_NAME                VARCHAR2)
      RETURN    NUMBER;
      
    FUNCTION    GET_LOAN_ID(P_MEMBER_ID     NUMBER,
                            P_LOAN_NUMBER   NUMBER)
      RETURN    NUMBER;
     
    
    FUNCTION    GET_LOAN_ID(P_PERSON_ID         NUMBER,
                            P_PAYMENT_AMOUNT    NUMBER)
      RETURN    NUMBER;
      
      
    PROCEDURE   SEND_TO_XLA(P_ERRBUF         OUT NOCOPY  VARCHAR2,
                            P_RETCODE        OUT NOCOPY  VARCHAR2,
                            P_PERIOD_TYPE    VARCHAR2,
                            P_YEAR           NUMBER,
                            P_MONTH          NUMBER,
                            P_PERIOD_NAME    VARCHAR2,
                            P_ELEMENT_NAME   VARCHAR2);

END ATET_SAVINGS_BANK_PKG;