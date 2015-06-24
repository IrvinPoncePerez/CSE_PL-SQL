declare
    p_errbuf    VARCHAR2(3000);
    p_retcode   VARCHAR2(100);
begin
    
    PAC_ALTAS_FONDO_AHORRO_PRC(p_errbuf, p_retcode, '2014/01/01 00:00:00', '2014/12/15 00:00:00');
    
end;