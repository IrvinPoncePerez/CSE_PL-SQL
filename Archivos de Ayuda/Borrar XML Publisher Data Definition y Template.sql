DECLARE
    var_application_short_name  VARCHAR2(500) := 'EAM';
    var_template_code           VARCHAR2(500) := 'PAC_REPORTE_REND_SEMANAL';
BEGIN

    BEGIN
        XDO_TEMPLATES_PKG.DELETE_ROW(var_application_short_name, var_template_code);
        commit;
    EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
    END;
    
    BEGIN
        XDO_DS_DEFINITIONS_PKG.DELETE_ROW(var_application_short_name, var_template_code);
        commit;
    EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
    END;

END;