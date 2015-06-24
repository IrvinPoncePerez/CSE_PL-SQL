DECLARE

    var_storage_value VARCHAR2(1000);
    
BEGIN

    

    FND_FLEX_VAL_API.CREATE_INDEPENDENT_VSET_VALUE( p_flex_value_set_name => 'XXCALV_CONDUCTORES_REND', 
                                                    p_flex_value => 'PRUEBA DE API', 
                                                    p_description => 'PRUEBA DE API',
                                                    p_enabled_flag => 'Y',
                                                    p_start_date_active => SYSDATE,
                                                    x_storage_value => var_storage_value);
                                                    
    COMMIT;
                                                    
    dbms_output.put_line(var_storage_value);                                                    
                                                    

END;