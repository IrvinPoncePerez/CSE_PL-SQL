DECLARE
    P_ERRBUF         varchar2(500);
    P_RETCODE        varchar2(500);
BEGIN

    ATET_SAVINGS_BANK_PKG.SEND_TO_XLA(P_ERRBUF => P_ERRBUF,
                P_RETCODE => P_RETCODE,
                P_PERIOD_TYPE => 'Semi-Month',
                P_YEAR => 2016,
                P_MONTH => 2,
                P_PERIOD_NAME => '4 2016 Quincena',
                P_ELEMENT_NAME => 'D071_CAJA DE AHORRO');

END;