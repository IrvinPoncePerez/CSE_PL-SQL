ALTER SESSION SET CURRENT_SCHEMA=APPS;


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
