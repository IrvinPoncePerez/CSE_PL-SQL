ALTER SESSION SET CURRENT_SCHEMA=APPS;

DECLARE
    var_id_evento       NUMBER;
    var_dias_evento     NUMBER;
    var_saldo_anterior  NUMBER;
BEGIN

    SELECT PAVT.ID_EVENTO,
           PAVT.SALDO_ANTERIOR,
           PAVT.DIAS_EVENTO
      INTO var_id_evento,
           var_saldo_anterior,
           var_dias_evento
      FROM PAC_AJUSTE_VACACIONES_TB PAVT
     WHERE 1 = 1
       AND EMPLOYEE_NUMBER = :P_EMPLOYEE_NUMBER;
       
       
    UPDATE XXCALV_VAC_EVENTOS   XVE
       SET XVE.SALDO_DIAS = XVE.SALDO_DIAS + var_dias_evento
     WHERE 1 = 1
       AND ID_EVENTO = var_id_evento;
       
    COMMIT;
       
END;

