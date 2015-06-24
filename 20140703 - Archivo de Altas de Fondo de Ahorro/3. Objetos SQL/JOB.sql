-- BEGIN 
--   SYS.DBMS_JOB.REMOVE(322);
-- COMMIT;
-- END;
-- /

DECLARE
  X NUMBER;
BEGIN
  SYS.DBMS_JOB.SUBMIT
  ( job       => X 
   ,what      => 'APPS.RESET_SEQUENCE_PRC;'
   ,next_date => to_date('09/09/2014 00:00:00','dd/mm/yyyy hh24:mi:ss')
   ,interval  => 'TRUNC(SYSDATE+1)'
   ,no_parse  => FALSE
  );
  SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
COMMIT;
END;
