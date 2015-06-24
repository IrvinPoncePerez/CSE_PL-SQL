DECLARE
    p_errbuf    VARCHAR2(3000);
    p_retcode   VARCHAR2(100);
BEGIN
    PAC_DISPERSION_EASY_VALE_PRC(p_errbuf,
                                 p_retcode,
                                 'Week',
                                 '',
                                 '64',
                                 '2014-JUL-01 00:00:00',
                                 '2014-JUL-07 00:00:00');
END;