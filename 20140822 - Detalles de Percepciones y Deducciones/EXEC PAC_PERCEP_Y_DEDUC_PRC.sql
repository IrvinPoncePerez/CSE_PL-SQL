DECLARE 
   P_ERRBUF                 VARCHAR2(1000) := NULL;
   P_RETCODE                VARCHAR2(1000) := NULL;
   P_COMPANY_ID                VARCHAR2(1000) := '02';
   P_YEAR                   VARCHAR2(1000) := '2015'; 
   P_START_MONTH            VARCHAR2(1000) := '1';
   P_END_MONTH              VARCHAR2(1000) := '1';
   P_PERIOD_TYPE            VARCHAR2(1000) := 'Week';
   P_PAYROLL_ID             VARCHAR2(1000) := '80';
   P_CONSOLIDATION_SET_ID   VARCHAR2(1000);
   P_PERIOD_NAME            VARCHAR2(1000) := '1 2015 Semana';
BEGIN

    PAC_PERCEP_Y_DEDUC_PRC(P_ERRBUF                 => P_ERRBUF,
                           P_RETCODE                => P_RETCODE, 
                           P_COMPANY_ID                => P_COMPANY_ID, 
                           P_YEAR                   => P_YEAR,  
                           P_START_MONTH            => P_START_MONTH,
                           P_END_MONTH              => P_END_MONTH, 
                           P_PERIOD_TYPE            => P_PERIOD_TYPE, 
                           P_PAYROLL_ID             => P_PAYROLL_ID, 
                           P_CONSOLIDATION_SET_ID   => NULL, 
                           P_PERIOD_NAME            => P_PERIOD_NAME);
                           
                     

EXCEPTION WHEN OTHERS THEN
    dbms_output.put_line(sqlerrm);
END;
