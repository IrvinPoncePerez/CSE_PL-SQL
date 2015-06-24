DECLARE
    p_errbuf    VARCHAR2(3000);
    p_retcode   VARCHAR2(100);
BEGIN
    PAC_SOLICITUD_RFC_SAT_PRC(p_errbuf,
                              p_retcode,
                              '02',
                              '',
                              '',
                              '2014/07/01 00:00:00',
                              '2014/07/31 00:00:00',
                              '02');
END;