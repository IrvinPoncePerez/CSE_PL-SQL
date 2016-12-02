

declare
    result  varchar2(100);
begin

    select  HolaMundo_greeting 
    into result
    from dual;
    
    dbms_output.PUT_LINE(result);
    
end;