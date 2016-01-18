DECLARE
    DIAS_NORMALES   NUMBER;
    DIAS_VACACIONES NUMBER;
BEGIN
    
    dbms_output.put_line('**************    SEMANA  **************');    

    DIAS_NORMALES := PAC_P044_DIAS_RETROACTIVOS(1762, '19-JAN-2015', 'P001_SUELDO NORMAL', 'SEM');
    DIAS_VACACIONES := PAC_P044_DIAS_RETROACTIVOS(1762, '19-JAN-2015', 'P005_VACACIONES', 'SEM');
    
    dbms_output.PUT_LINE('Dias Normales: ' || to_char(DIAS_NORMALES));
    dbms_output.put_line('Dias Vacaciones: ' || DIAS_VACACIONES);
    dbms_output.put_line(' ');
    
    DIAS_NORMALES := PAC_P044_DIAS_RETROACTIVOS(86, '19-JAN-2015', 'P001_SUELDO NORMAL', 'SEM');
    DIAS_VACACIONES := PAC_P044_DIAS_RETROACTIVOS(86, '19-JAN-2015', 'P005_VACACIONES', 'SEM');
    
    dbms_output.PUT_LINE('Dias Normales: ' || to_char(DIAS_NORMALES));
    dbms_output.put_line('Dias Vacaciones: ' || DIAS_VACACIONES);
    dbms_output.put_line(' ');
    
    DIAS_NORMALES := PAC_P044_DIAS_RETROACTIVOS(1763, '19-JAN-2015', 'P001_SUELDO NORMAL', 'SEM');
    DIAS_VACACIONES := PAC_P044_DIAS_RETROACTIVOS(1763, '19-JAN-2015', 'P005_VACACIONES', 'SEM');
    
    dbms_output.PUT_LINE('Dias Normales: ' || to_char(DIAS_NORMALES));
    dbms_output.put_line('Dias Vacaciones: ' || DIAS_VACACIONES);
    dbms_output.put_line(' ');
    
    dbms_output.put_line('**************    QUINCENA  **************');
    
    DIAS_NORMALES := PAC_P044_DIAS_RETROACTIVOS(737, '31-JAN-2015', 'P001_SUELDO NORMAL', 'QUIN');
    DIAS_VACACIONES := PAC_P044_DIAS_RETROACTIVOS(737, '31-JAN-2015', 'P005_VACACIONES', 'QUIN');
    
    dbms_output.PUT_LINE('Dias Normales: ' || to_char(DIAS_NORMALES));
    dbms_output.put_line('Dias Vacaciones: ' || DIAS_VACACIONES);
    dbms_output.put_line(' ');
    
    DIAS_NORMALES := PAC_P044_DIAS_RETROACTIVOS(977, '31-JAN-2015', 'P001_SUELDO NORMAL', 'QUIN');
    DIAS_VACACIONES := PAC_P044_DIAS_RETROACTIVOS(977, '31-JAN-2015', 'P005_VACACIONES', 'QUIN');
    
    dbms_output.PUT_LINE('Dias Normales: ' || to_char(DIAS_NORMALES));
    dbms_output.put_line('Dias Vacaciones: ' || DIAS_VACACIONES);
    dbms_output.put_line(' ');

END;