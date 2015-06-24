DECLARE
    p_errbuf    VARCHAR2(3000);
    p_retcode   VARCHAR2(100);
BEGIN
    PAC_ALTAS_EDENRED_PRC(p_errbuf,
                          p_retcode,
                          '02',
                          '102',
                          '2014/06/01 00:00:00',
                          '2014/06/15 00:00:00');
END;