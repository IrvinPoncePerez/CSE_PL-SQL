Alter session set JAVA_JIT_ENABLED=FALSE;

declare
    result  varchar2(100);
begin

    select  HolaMundo_greeting 
    into result
    from dual;
    
end;