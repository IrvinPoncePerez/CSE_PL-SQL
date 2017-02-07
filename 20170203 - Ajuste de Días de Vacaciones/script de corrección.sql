ALTER SESSION SET CURRENT_SCHEMA=APPS;

 
DECLARE
    CURSOR EMPLOYEE_VACACIONES
        IS
    SELECT PPF.EMPLOYEE_NUMBER
      FROM XXCALV_VAC_EVENTOS           XVE,
           XXCALV_VAC_TIPOS_EVENTO      XVTE,
           PER_PEOPLE_F                 PPF
     WHERE 1 = 1
       AND XVE.ID_TIPO_EVENTO = XVTE.ID_TIPO_EVENTO
       AND XVE.PERSON_ID = PPF.PERSON_ID
       AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE
                       AND PPF.EFFECTIVE_END_DATE
       AND XVE.FECHA_ESTADO_CONTROL BETWEEN TO_DATE('10/01/2017', 'DD/MM/RRRR')
                                        AND TO_DATE('22/01/2017', 'DD/MM/RRRR')
       AND XVTE.NOMBRE_TIPO_EVENTO NOT IN ('Días correspondientes del período',
                                           'Solicitud de pago de vacaciones',
                                           'Aprobación de solicitud',
                                           'Cancelación de solicitud',
                                           'Solicitud de vacaciones',
                                           'Vacaciones disfrutadas',
                                           'Vacaciones pagadas')
       AND PPF.EMPLOYEE_NUMBER NOT IN (476, 1629, 4488, 768, 1888,
                                       2727, 1870, 4393, 1883, 1860,
                                       2688, 287, 1480, 1540, 999,
                                       1290, 1575, 1571, 1393, 263,
                                       503,  235, 4437, 615, 539)
     GROUP 
        BY PPF.EMPLOYEE_NUMBER;
BEGIN

    FOR EMPLOYEE IN EMPLOYEE_VACACIONES LOOP

        DECLARE
            CURSOR EVENTOS_VACACIONES
                IS
            SELECT XVTE.NOMBRE_TIPO_EVENTO,
                   XVE.ID_EVENTO,
                   XVE.ESTADO_REGISTRO,
                   XVE.FECHA_ESTADO_CONTROL,
                   XVE.ANIO_ANTIGUEDAD,
                   XVE.DIAS_EVENTO,
                   XVE.SALDO_DIAS,
                   XVE.FECHA_DESDE,
                   XVE.FECHA_HASTA,
                   PPF.FULL_NAME,
                   PPF.EMPLOYEE_NUMBER
              FROM XXCALV_VAC_EVENTOS           XVE,
                   XXCALV_VAC_TIPOS_EVENTO      XVTE,
                   PER_PEOPLE_F                 PPF
             WHERE 1 = 1
               AND XVE.PERSON_ID = PPF.PERSON_ID
               AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE
                               AND PPF.EFFECTIVE_END_DATE
               AND XVE.ID_TIPO_EVENTO = XVTE.ID_TIPO_EVENTO
               AND PPF.EMPLOYEE_NUMBER = EMPLOYEE.EMPLOYEE_NUMBER
               AND XVTE.NOMBRE_TIPO_EVENTO IN ('Días correspondientes del período',
                                               'Vencimiento de solicitud')
               AND (CASE
                        WHEN XVTE.NOMBRE_TIPO_EVENTO = 'Días correspondientes del período' THEN
                            SYSDATE
                        WHEN XVTE.NOMBRE_TIPO_EVENTO = 'Vencimiento de solicitud' THEN
                            XVE.FECHA_ESTADO_CONTROL
                    END) BETWEEN (CASE
                                    WHEN XVTE.NOMBRE_TIPO_EVENTO = 'Días correspondientes del período' THEN
                                        XVE.FECHA_DESDE
                                    WHEN XVTE.NOMBRE_TIPO_EVENTO = 'Vencimiento de solicitud' THEN
                                        TO_DATE('10/01/2017', 'DD/MM/RRRR')
                                  END)
                             AND (CASE
                                    WHEN XVTE.NOMBRE_TIPO_EVENTO = 'Días correspondientes del período' THEN
                                        XVE.FECHA_HASTA
                                    WHEN XVTE.NOMBRE_TIPO_EVENTO = 'Vencimiento de solicitud' THEN
                                        TO_DATE('22/01/2017', 'DD/MM/RRRR')
                                  END)
             ORDER BY XVE.ANIO_ANTIGUEDAD DESC,
                      XVE.ID_EVENTO ASC;
                
            var_id_evento           NUMBER;
            var_saldo_dias          NUMBER;
            var_dias_evento         NUMBER := 0;
            var_saldo_dias_anterior NUMBER;
            var_employee_number     VARCHAR2(100);
            var_full_name           VARCHAR2(1000);
                        
        BEGIN

            FOR EVENTO IN EVENTOS_VACACIONES LOOP
                
                IF      EVENTO.NOMBRE_TIPO_EVENTO = 'Días correspondientes del período' THEN
                    var_id_evento := EVENTO.ID_EVENTO;
                    var_saldo_dias := EVENTO.SALDO_DIAS;
                    var_saldo_dias_anterior := EVENTO.SALDO_DIAS;
                ELSIF   EVENTO.NOMBRE_TIPO_EVENTO = 'Vencimiento de solicitud' THEN
                    var_dias_evento := var_dias_evento + EVENTO.DIAS_EVENTO;
                END IF;
                    
                var_full_name := EVENTO.FULL_NAME;
                var_employee_number := EVENTO.EMPLOYEE_NUMBER;
                    
            END LOOP;
                
            var_saldo_dias := var_saldo_dias - var_dias_evento;
                    
            UPDATE XXCALV_VAC_EVENTOS
               SET SALDO_DIAS = var_saldo_dias
             WHERE 1 = 1
               AND ID_EVENTO = var_id_evento;
                   
                   
            INSERT 
              INTO PAC_AJUSTE_VACACIONES_TB
                (
                    EMPLOYEE_NUMBER,
                    FULL_NAME,
                    ID_EVENTO,
                    DIAS_EVENTO,
                    SALDO_ANTERIOR,
                    SALDO_NUEVO
                )       
            VALUES
                (
                    var_employee_number,
                    var_full_name,
                    var_id_evento,
                    var_dias_evento,
                    var_saldo_dias_anterior,
                    var_saldo_dias
                );
                
    --        COMMIT;

        END;
    
    END LOOP;
    
END;

COMMIT;


SELECT PAVT.EMPLOYEE_NUMBER,
       PAVT.FULL_NAME,
       PAVT.DIAS_EVENTO,
       PAVT.SALDO_ANTERIOR,
       PAVT.SALDO_NUEVO,
       XVE.FECHA_DESDE,
       XVE.FECHA_HASTA
  FROM PAC_AJUSTE_VACACIONES_TB PAVT,
       XXCALV_VAC_EVENTOS XVE
 WHERE 1 = 1
   AND PAVT.ID_EVENTO = XVE.ID_EVENTO
 ORDER 
    BY TO_NUMBER(PAVT.EMPLOYEE_NUMBER);
  
  
SELECT PAVT.EMPLOYEE_NUMBER,
       PAVT.FULL_NAME,
       PAVT.DIAS_EVENTO,
       PAVT.SALDO_ANTERIOR,
       PAVT.SALDO_NUEVO,
       XVE.FECHA_DESDE,
       XVE.FECHA_HASTA
  FROM PAC_AJUSTE_VACACIONES_TB PAVT,
       XXCALV_VAC_EVENTOS XVE
 WHERE 1 = 1
   AND PAVT.ID_EVENTO = XVE.ID_EVENTO
   AND XVE.FECHA_DESDE BETWEEN TO_DATE('10/01/2017', 'DD/MM/RRRR')
                           AND TO_DATE('22/01/2017', 'DD/MM/RRRR')
 ORDER 
    BY TO_NUMBER(PAVT.EMPLOYEE_NUMBER);  