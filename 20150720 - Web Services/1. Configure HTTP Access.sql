DECLARE
    web_port    NUMBER;
BEGIN

    SELECT dbms_xdb.gethttpport
      INTO web_port 
      FROM dual;
      
    dbms_output.PUT_LINE(web_port);

--    EXEC dbms_xdb.sethttpport(8080);
    

END;
