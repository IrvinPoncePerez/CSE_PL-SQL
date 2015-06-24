declare
    p_fixed_idw     number := 0;
    p_variable_idw  number := 0;
    p_get_idw       NUMBER  := 0;
begin 

        p_get_idw := PAY_MX_FF_UDFS.GET_IDW(p_assignment_id         => 2844,
                                            p_tax_unit_id           => 855,
                                            p_effective_date        => '26-JAN-2015',
                                            p_mode                  => 'REPORT'
                                            );
                                            
    dbms_output.put_line('p_fixed_idw = ' + to_char(p_fixed_idw)
                        +'p_variable_idw = ' + to_char(p_variable_idw)
                        +'p_get_idw = ' + to_char(p_get_idw));

end;