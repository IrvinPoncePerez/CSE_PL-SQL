DECLARE
    var_message     VARCHAR2(2000);
BEGIN
    var_message := PAC_UPDATE_EDENRED('300006',
                                      '34345356',
                                      '6036810152906993');
    
    dbms_output.put_line('var_message=' || var_message);
END;