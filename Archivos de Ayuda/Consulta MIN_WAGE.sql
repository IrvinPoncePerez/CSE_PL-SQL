 INSERT INTO FND_SESSIONS (SESSION_ID, EFFECTIVE_DATE)
                      VALUES (USERENV('SESSIONID'), TRUNC(SYSDATE));
                      

DECLARE
                      
    min_wage         NUMBER := 0;                                               
    econ_zone        VARCHAR2(50) := 'C';       
    
    /*************************************
    :P_TAX_UNIT_ID = 852
    :P_EFFECTIVE_DATE = 06-JUL-2015
    :P_ASSIGNMENT_ID = 3023
    :P_PAYROLL_ACTION_ID = 427133
    *************************************/
BEGIN 
    
    min_wage := PAY_MX_UTILITY.GET_MIN_WAGE(p_ctx_date_earned => :P_EFFECTIVE_DATE,
                                            p_tax_basis => 'NONE',
                                            p_econ_zone => econ_zone);

    dbms_output.PUT_LINE('MIN_WAGE : ' || to_char(min_wage));   

END; 