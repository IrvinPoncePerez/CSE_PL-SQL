DECLARE
    var_result  VARCHAR2(10);
BEGIN

    var_result := PAC_VISITS_CONTROL_EXT_PKG.GET_SEQUENCE();
    
    dbms_output.PUT_LINE('*' || var_result || '*');    

END;