
DECLARE
    VAR_RESULT          VARCHAR2(1000);
BEGIN

    VAR_RESULT := PAC_FACTURACION_PKG.SYNC('2018');
    
    DBMS_OUTPUT.PUT_LINE(VAR_RESULT);
    
END;


select *
  from pac_masteredi_report_tb
 order 
    by emianio desc,
       emimes desc,
       emidia desc;