declare
    var_result      varchar2(1000);
begin
    var_result := PAC_INVOICE_PKG.READ_XML('/var/tmp/CARGAS/CALVARIO/ROBG560202PS5_PAC941215E50_RA_125.XML');
    dbms_output.put_line(var_result);
    var_result := PAC_INVOICE_PKG.READ_XML('/var/tmp/CARGAS/CALVARIO/PAC941215E50_ACO6405017L0_CRCB_1993.XML');
    dbms_output.put_line(var_result);
    var_result := PAC_INVOICE_PKG.READ_XML('/var/tmp/CARGAS/CALVARIO/ROBG560202PS5_PAC941215E50_FA_300.XML');
    dbms_output.put_line(var_result);
end;
