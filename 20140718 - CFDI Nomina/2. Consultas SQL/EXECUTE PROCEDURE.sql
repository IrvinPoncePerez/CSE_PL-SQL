DECLARE
    p_errbuf    VARCHAR2(3000);
    p_retcode   VARCHAR2(100);
BEGIN
    PAC_CFDI_NOMINA_PRC(p_errbuf,
                        p_retcode,
                        '02',               --P_COMPANY_ID
                        'Week',       --P_PERIOD_TYPE
                        '',                 --P_PAYROLL_ID
                        '',                 --P_CONSOLIDATION_ID
                        2017,               --P_YEAR
                        1,                  --P_MONTH
                        '3 2017 Semana');--P_PERIOD_NAME
END;