DECLARE
    ECON_ZONE   VARCHAR2(50);
    MIN_WAGE    NUMBER;
BEGIN

    ECON_ZONE := PAY_MX_UTILITY.GET_MX_ECON_ZONE(P_CTX_TAX_UNIT_ID => 852,
                                                 P_CTX_DATE_EARNED => '11-DEC-2017');
    
    dbms_output.PUT_LINE(ECON_ZONE);
    
    
    MIN_WAGE := PAY_MX_UTILITY.GET_MIN_WAGE(P_CTX_DATE_EARNED => '11-DEC-2017',
                                            P_TAX_BASIS => 'NONE',
                                            P_ECON_ZONE => 'B');
                                            
    dbms_output.PUT_LINE(MIN_WAGE);
    dbms_output.PUT_LINE(MIN_WAGE * 25);
    
END;


