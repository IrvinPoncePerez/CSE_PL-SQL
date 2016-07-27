            SELECT NVL(PPOS.ADJUSTED_SVC_DATE, PPF.ORIGINAL_DATE_OF_HIRE),
                   PPF.EMPLOYEE_NUMBER,
                   PPF.FULL_NAME
              FROM PER_PEOPLE_F             PPF,
                   PER_PERIODS_OF_SERVICE   PPOS    
             WHERE 1 = 1 
               AND PPF.PERSON_ID = PPOS.PERSON_ID
               AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
               AND PPOS.ACTUAL_TERMINATION_DATE IS NULL
               AND EXTRACT(DAY FROM NVL(PPOS.ADJUSTED_SVC_DATE, PPF.ORIGINAL_DATE_OF_HIRE)) = 27
               AND EXTRACT(MONTH FROM NVL(PPOS.ADJUSTED_SVC_DATE, PPF.ORIGINAL_DATE_OF_HIRE)) = 7;
               
               
SELECT  xve.*
--SUM(XVE.DIAS_DESPLEGAR)
--	      INTO :CONTROL.VAC_PAG_PER_ACTUAL
				FROM XXCALV_VAC_EVENTOS         XVE,
				     XXCALV_VAC_TIPOS_EVENTO    XVTE,
                     XXCALV_VAC_CATALOGO        XVC
			 WHERE 1 = 1
			   AND XVE.ID_TIPO_EVENTO = XVTE.ID_TIPO_EVENTO
			   AND XVE.ESTADO_REGISTRO = XVC.VALOR
               AND XVE.PERSON_ID = :P_PERSON_ID 
               AND XVC.DESCRIPCION IN ('Aprobado', 'Procesado')
			   AND XVTE.NOMBRE_TIPO_EVENTO = 'Solicitud de pago de vacaciones'
               AND XVE.FECHA_DESDE >= TO_DATE(EXTRACT(DAY FROM :P_FECHA_INGRESO) || '/' ||
                                              EXTRACT(MONTH FROM :P_FECHA_INGRESO) || '/' ||
                                              (EXTRACT(YEAR FROM SYSDATE)-1), 'DD/MM/RRRR');
               

SELECT NVL(PPS.ADJUSTED_SVC_DATE, PP7.ORIGINAL_DATE_OF_HIRE) HIRE_DATE
    FROM PER_all_PEOPLE_F     PP7,
         PER_PERIODS_OF_SERVICE PPS
   WHERE 1 = 1
     AND PP7.EFFECTIVE_START_DATE      <= TRUNC(SYSDATE)
     AND PPS.PERSON_ID = PP7.PERSON_ID
     AND PPS.PERSON_ID = :P_PERSON_ID
       AND (   (PP7.EMPLOYEE_NUMBER IS NULL)
            OR (    PP7.EMPLOYEE_NUMBER IS NOT NULL
                AND PPS.DATE_START = (SELECT MAX (PPS1.DATE_START)
                                        FROM PER_PERIODS_OF_SERVICE PPS1
                                       WHERE PPS1.PERSON_ID = PP7.PERSON_ID)
               )
           )
       AND PP7.EFFECTIVE_START_DATE = (SELECT MAX (PER1.EFFECTIVE_START_DATE)
                                         FROM PER_PEOPLE_F PER1
                                        WHERE PER1.PERSON_ID = PP7.PERSON_ID)
ORDER BY PP7.FULL_NAME