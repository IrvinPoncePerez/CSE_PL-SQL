CREATE OR REPLACE FUNCTION PAC_GET_DISABILITIES_DAYS(
                           P_REGISTRATION_DATE         DATE,
                           P_REGISTRATION_EXP_DATE     DATE,
                           P_MONTH                     VARCHAR2,
                           P_YEAR                      VARCHAR2)   RETURN NUMBER
IS
    var_min_month          NUMBER;
    var_max_month          NUMBER;
    var_first_day          DATE;
    var_last_day           DATE;
    var_days               NUMBER := 0;
    var_month              NUMBER;
BEGIN
    
    var_min_month := TO_NUMBER(EXTRACT(MONTH FROM P_REGISTRATION_DATE));
    var_max_month := TO_NUMBER(EXTRACT(MONTH FROM P_REGISTRATION_EXP_DATE));
    var_month := TO_NUMBER(P_MONTH);

    var_first_day := TRUNC(TO_DATE('01/' || var_month || '/' || P_YEAR, 'DD/MM/YYYY'), 'mm');
    var_last_day := TRUNC(LAST_DAY(TO_DATE('01/' || var_month || '/' || P_YEAR, 'DD/MM/YYYY')));
    
    
    
    dbms_output.put_line(' var_min_month : ' || TO_CHAR(var_min_month) || 
                         ' var_max month : ' || TO_CHAR(var_max_month) || 
                         ' var_month : ' || TO_CHAR(var_month) || 
                         ' var_first_day : ' || TO_CHAR(var_first_day) ||
                         ' var_last_day : ' || TO_CHAR(var_last_day));
    
    
    
        
    IF P_MONTH >  var_min_month AND P_MONTH < var_max_month THEN
    
        var_days := (var_last_day - (var_first_day - 1));
        dbms_output.PUT_LINE('Condición 1: ' || TO_CHAR(var_last_day) || ' - ' || TO_CHAR(var_first_day) || ' var_days : ' || TO_CHAR(var_days));
    
    ELSIF P_MONTH =  var_min_month AND P_MONTH = var_max_month THEN
        
        var_days := (P_REGISTRATION_EXP_DATE - (P_REGISTRATION_DATE - 1));
        dbms_output.PUT_LINE('Condición 2: ' || TO_CHAR(P_REGISTRATION_EXP_DATE) || ' - ' || TO_CHAR(P_REGISTRATION_DATE) || ' var_days : ' || TO_CHAR(var_days));
        
    
    ELSIF P_MONTH > var_min_month AND P_MONTH = var_max_month  THEN
    
        var_days := (P_REGISTRATION_EXP_DATE - (var_first_day - 1));
        dbms_output.PUT_LINE('Condición 3: ' || TO_CHAR(P_REGISTRATION_EXP_DATE) || ' - ' || TO_CHAR(var_first_day) || ' var_days : ' || TO_CHAR(var_days));
        
    ELSIF P_MONTH = var_min_month AND P_MONTH < var_max_month THEN
        
        var_days := (var_last_day - (P_REGISTRATION_DATE - 1));
        dbms_output.PUT_LINE('Condición 4: ' || TO_CHAR(var_last_day) || ' - ' || TO_CHAR(P_REGISTRATION_DATE) || ' var_days : ' || TO_CHAR(var_days));
        
    
    END IF;
    
    dbms_output.put_line(' ');
    
    
    RETURN var_days;

EXCEPTION WHEN OTHERS THEN
    dbms_output.put_line('**Error en la función PAC_GET_DISABILITIES_DAYS.' || var_month || SQLERRM);
    FND_FILE.put_line(FND_FILE.LOG, '**Error en la función PAC_GET_DISABILITIES_DAYS. ' || SQLERRM);
END;