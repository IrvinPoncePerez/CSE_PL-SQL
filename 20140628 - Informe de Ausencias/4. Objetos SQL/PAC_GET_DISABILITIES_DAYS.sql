CREATE OR REPLACE FUNCTION PAC_GET_DISABILITIES_DAYS(
                           P_REGISTRATION_DATE         DATE,
                           P_REGISTRATION_EXP_DATE     DATE,
                           P_MONTH                     VARCHAR2,
                           P_YEAR                      VARCHAR2)   RETURN NUMBER
IS
    var_min_month          NUMBER;
    var_max_month          VARCHAR2(50);
    var_first_day          DATE;
    var_last_day           DATE;
    var_days               NUMBER := 0;
    var_month              VARCHAR(3);
BEGIN
    
    var_min_month := EXTRACT(MONTH FROM P_REGISTRATION_DATE);
    var_max_month := EXTRACT(MONTH FROM P_REGISTRATION_EXP_DATE);
    var_month := TRIM(TO_CHAR(P_MONTH, '00'));

    var_first_day := TRUNC(TO_DATE('01/' || var_month || '/' || P_YEAR, 'DD/MM/YYYY'), 'mm');
    var_last_day := TRUNC(LAST_DAY(TO_DATE('01/' || var_month || '/' || P_YEAR, 'DD/MM/YYYY')));
    
    
        
    IF var_min_month < P_MONTH THEN
        var_days := (P_REGISTRATION_EXP_DATE - (var_first_day - 1));
    ELSIF var_max_month > P_MONTH THEN
        var_days := (var_last_day - (P_REGISTRATION_DATE - 1));
    ELSE
        var_days := (P_REGISTRATION_EXP_DATE - (P_REGISTRATION_DATE - 1));
    END IF;
    
    
    
    RETURN var_days;

EXCEPTION WHEN OTHERS THEN
    dbms_output.put_line('**Error en la función PAC_GET_DISABILITIES_DAYS.' || var_month || SQLERRM);
    FND_FILE.put_line(FND_FILE.LOG, '**Error en la función PAC_GET_DISABILITIES_DAYS. ' || SQLERRM);
END;