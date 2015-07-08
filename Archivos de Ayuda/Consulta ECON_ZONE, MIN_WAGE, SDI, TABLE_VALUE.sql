    INSERT INTO FND_SESSIONS (SESSION_ID, EFFECTIVE_DATE)
                      VALUES (USERENV('SESSIONID'), TRUNC(SYSDATE));
                      

DECLARE
    table_value      NUMBER := 0;
    l_fixed_idw      NUMBER;
    l_variable_idw   NUMBER;
    idw              NUMBER;                       
    min_wage         NUMBER := 0;                                               
    econ_zone        VARCHAR2(50);     
    tax_unit_id      NUMBER := :P_TAX_UNIT_ID;
    nveces           NUMBER := 0; 
    
    
    
    /*************************************
    :P_TAX_UNIT_ID = 852
    :P_EFFECTIVE_DATE = 06-JUL-2015
    :P_ASSIGNMENT_ID = 3023
    :P_PAYROLL_ACTION_ID = 427133
    *************************************/
BEGIN
 
    dbms_output.PUT_LINE('TAX_UNIT_ID : ' || to_char(tax_unit_id));   
                                         
    econ_zone := PAY_MX_UTILITY.GET_MX_ECON_ZONE(p_ctx_tax_unit_id => tax_unit_id , 
                                                 p_ctx_date_earned => :P_EFFECTIVE_DATE);
                                                 
    dbms_output.PUT_LINE('ECON_ZONE : ' || to_char(econ_zone));
    
    
    
    
    
    min_wage := PAY_MX_UTILITY.GET_MIN_WAGE(p_ctx_date_earned => :P_EFFECTIVE_DATE,
                                            p_tax_basis => 'NONE',
                                            p_econ_zone => econ_zone);

    dbms_output.PUT_LINE('MIN_WAGE : ' || to_char(min_wage));    
    
    
    
    

    
    idw := PAY_MX_FF_UDFS.GET_IDW (p_assignment_id      => :P_ASSIGNMENT_ID,
                                   p_tax_unit_id        => tax_unit_id,
                                   p_effective_date     => :P_EFFECTIVE_DATE,
                                   p_payroll_action_id  => :P_PAYROLL_ACTION_ID,
                                   p_mode               => 'REPORT',
                                   p_fixed_idw          => l_fixed_idw,
                                   p_variable_idw       => l_variable_idw,
                                   p_execute_old_idw_code => 'Y');
                                   
    dbms_output.PUT_LINE('SDI : ' || to_char(idw));
    dbms_output.PUT_LINE('P_FIXED_IDW : ' || to_char(l_fixed_idw));
    dbms_output.PUT_LINE('P_VARIABLE_IDW : ' || to_char(l_variable_idw));
    
    
    
    
    nveces := (idw / min_wage);
    
    dbms_output.PUT_LINE('NVECES : ' || to_char(nveces));
    
    
    
    
    
    table_value := TO_NUMBER (hruserdt.get_table_value (p_bus_group_id      => 82,
                                                        p_table_name        => 'PORCENTAJES INFONAVIT', 
                                                        p_col_name          => 'INPUT_20',
								                        p_row_value         => nveces,
                                                        p_effective_date    => :P_EFFECTIVE_DATE));
                                                        
    dbms_output.PUT_LINE('TABLE_VALUE : ' || to_char(table_value));


END;