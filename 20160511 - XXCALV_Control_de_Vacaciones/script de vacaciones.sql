SELECT PPF.PERSON_ID
  FROM PER_PEOPLE_F PPF
 WHERE 1 = 1
   AND PPF.EMPLOYEE_NUMBER = 55;
   
   SELECT *
     FROM ( SELECT DISTINCT 
                   PPF.PERSON_ID,
                   PPF.EMPLOYEE_NUMBER,
                   PPF.FULL_NAME,
                   XVE.ID_EVENTO,
                   XVE.ID_TIPO_EVENTO,
                   XVE.ESTADO_REGISTRO,
                   XVE.ESTADO_CONTROL,
                   XVE.FECHA_ESTADO_CONTROL,
                   XVE.ANIO_ANTIGUEDAD,
                   XVE.DIAS_EVENTO,
                   XVE.DIAS_DESPLEGAR,
                   XVE.SALDO_DIAS,
                   XVE.FECHA_DESDE,
                   XVE.FECHA_HASTA,
                   XVE.FECHA_DESDE_DESPLEGAR,
                   XVE.FECHA_HASTA_DESPLEGAR,
                   XVE.ID_EVENTO_PADRE,
                   XVE.OBJECT_ID,
                   XVE.OBJECT_VERSION_NUMBER,
                   XVE.DESPLEGAR_P1,
                   XVE.ATTRIBUTE1
              FROM PER_ALL_PEOPLE_F     PPF,
                   PER_ASSIGNMENTS_F    PAF,
                   PER_PERSON_TYPES     PPT,
                   XXCALV_VAC_EVENTOS   XVE
             WHERE 1 = 1
               AND PPF.PERSON_ID = PAF.PERSON_ID
               AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
               AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
               AND PPT.PERSON_TYPE_ID = PPF.PERSON_TYPE_ID
               AND PPF.PERSON_ID = XVE.PERSON_ID
               AND XVE.DESPLEGAR_P1 = 'S'
               AND PPF.PERSON_ID = 1771
             ORDER BY XVE.ID_EVENTO DESC,
                      XVE.FECHA_ESTADO_CONTROL DESC) DET
    WHERE 1 = 1
      AND ROWNUM = 1;

SELECT *
  FROM XXCALV_VAC_EVENTOS       XVE,
       XXCALV_VAC_EVENTOS_DET   XVED
 WHERE 1 = 1
   AND XVE.ID_EVENTO = XVED.ID_EVENTO
   AND PERSON_ID = 3052
 ORDER BY XVE.ID_EVENTO DESC;
 
SELECT *
  FROM XXCALV_VAC_EVENTOS       XVE
 WHERE 1 = 1
   AND PERSON_ID = 3052
 ORDER BY XVE.ID_EVENTO DESC;
 
 
 SELECT DISTINCT 
               PPF.PERSON_ID,
               PPF.EMPLOYEE_NUMBER,
               PPF.FULL_NAME
--               XVE.ID_EVENTO
          FROM PER_ALL_PEOPLE_F     PPF,
               PER_ASSIGNMENTS_F    PAF,
               PER_PERSON_TYPES     PPT,
               XXCALV_VAC_EVENTOS   XVE
         WHERE 1 = 1
           AND PPF.PERSON_ID = PAF.PERSON_ID
           AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
           AND PPT.PERSON_TYPE_ID = PPF.PERSON_TYPE_ID
--           AND PPT.USER_PERSON_TYPE IN ('Ex-employee', 'Ex-empleado')
           AND PPF.PERSON_ID = XVE.PERSON_ID
           AND PPF.PERSON_ID = 3052;
   
XXCALV_VAC_CATALOGO
XXCALV_VAC_DESGLOSE
XXCALV_VAC_EVENTOS
XXCALV_VAC_EVENTOS_DET
XXCALV_VAC_GRUPO_EMP
XXCALV_VAC_SALDOS_INI
XXCALV_VAC_TIPOS_EVENTO


DECLARE
    
    CURSOR c_CANCELACIONES IS
        SELECT DISTINCT 
               PPF.PERSON_ID,
               PPF.EMPLOYEE_NUMBER,
               PPF.FULL_NAME,
               XVE.ID_EVENTO
          FROM PER_ALL_PEOPLE_F     PPF,
               PER_ASSIGNMENTS_F    PAF,
               PER_PERSON_TYPES     PPT,
               XXCALV_VAC_EVENTOS   XVE
         WHERE 1 = 1
           AND PPF.PERSON_ID = PAF.PERSON_ID
           AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
           AND PPT.PERSON_TYPE_ID = PPF.PERSON_TYPE_ID
           AND PPT.USER_PERSON_TYPE IN ('Ex-employee', 'Ex-empleado')
           AND PPF.PERSON_ID = XVE.PERSON_ID
           AND PPF.PERSON_ID = 3052;

    CURSOR c_RESTRUCTURACIONES IS
         SELECT DISTINCT 
               PPF.PERSON_ID,
               PPF.EMPLOYEE_NUMBER,
               PPF.FULL_NAME
          FROM PER_ALL_PEOPLE_F     PPF,
               PER_ASSIGNMENTS_F    PAF,
               PER_PERSON_TYPES     PPT,
               XXCALV_VAC_EVENTOS   XVE
         WHERE 1 = 1
           AND PPF.PERSON_ID = PAF.PERSON_ID
           AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
           AND PPT.PERSON_TYPE_ID = PPF.PERSON_TYPE_ID
           AND PPF.PERSON_ID = XVE.PERSON_ID
           AND PPF.PERSON_ID = 3052;
           
           
    var_PERSON_ID               NUMBER;
    var_ID_EVENTO               NUMBER;
    var_ID_TIPO_EVENTO          NUMBER;
    var_ESTADO_REGISTRO         VARCHAR2(1);
    var_ESTADO_CONTROL          VARCHAR2(1);
    var_FECHA_ESTADO_CONTROL    DATE;
    var_ANIO_ANTIGUEDAD         NUMBER;
    var_DIAS_EVENTO             NUMBER;
    var_DIAS_DESPLEGAR          NUMBER;
    var_SALDO_DIAS              NUMBER;
    var_FECHA_DESDE             DATE;
    var_FECHA_HASTA             DATE;
    var_FECHA_DESDE_DESPLEGAR   DATE;
    var_FECHA_HASTA_DESPLEGAR   DATE;
    var_ID_EVENTO_PADRE         NUMBER;
    var_OBJECT_ID               NUMBER;
    var_OBJECT_VERSION_NUMBER   NUMBER;
    var_DESPLEGAR_P1            VARCHAR2(1);

BEGIN

    FOR v_cancelacion IN c_CANCELACIONES LOOP
        
       DELETE FROM XXCALV_VAC_EVENTOS_DET
		 WHERE 1 = 1
		   AND ID_EVENTO = v_cancelacion.ID_EVENTO;
           
           
--		DELETE FROM XXCALV_VAC_EVENTOS
--		 WHERE 1 = 1
--		   AND PERSON_ID = v_cancelacion.PERSON_ID
--           AND ID_EVENTO = v_cancelacion.ID_EVENTO;
		
        
		UPDATE PER_ALL_PEOPLE_F
           SET ATTRIBUTE29 = NULL
         WHERE 1 = 1
           AND PERSON_ID = v_cancelacion.PERSON_ID;
  	
                                
    
    END LOOP;
    
    FOR v_restructuracion IN c_RESTRUCTURACIONES LOOP
    
           SELECT DET.PERSON_ID,
                  DET.ID_EVENTO,
                  DET.ID_TIPO_EVENTO,
                  DET.ESTADO_REGISTRO,
                  DET.ESTADO_CONTROL,
                  DET.FECHA_ESTADO_CONTROL,
                  DET.ANIO_ANTIGUEDAD,
                  DET.DIAS_EVENTO,
                  DET.DIAS_DESPLEGAR,
                  DET.SALDO_DIAS,
                  DET.FECHA_DESDE,
                  DET.FECHA_HASTA,
                  DET.FECHA_DESDE_DESPLEGAR,
                  DET.FECHA_HASTA_DESPLEGAR,
                  DET.ID_EVENTO_PADRE,
                  DET.OBJECT_ID,
                  DET.OBJECT_VERSION_NUMBER,
                  DET.DESPLEGAR_P1
             INTO var_PERSON_ID,
                  var_ID_EVENTO,
                  var_ID_TIPO_EVENTO,
                  var_ESTADO_REGISTRO,
                  var_ESTADO_CONTROL,
                  var_FECHA_ESTADO_CONTROL,
                  var_ANIO_ANTIGUEDAD,
                  var_DIAS_EVENTO,
                  var_DIAS_DESPLEGAR,
                  var_SALDO_DIAS,
                  var_FECHA_DESDE,
                  var_FECHA_HASTA,
                  var_FECHA_DESDE_DESPLEGAR,
                  var_FECHA_HASTA_DESPLEGAR,
                  var_ID_EVENTO_PADRE,
                  var_OBJECT_ID,
                  var_OBJECT_VERSION_NUMBER,
                  var_DESPLEGAR_P1
             FROM ( SELECT DISTINCT 
                           PPF.PERSON_ID,
                           PPF.EMPLOYEE_NUMBER,
                           PPF.FULL_NAME,
                           XVE.ID_EVENTO,
                           XVE.ID_TIPO_EVENTO,
                           XVE.ESTADO_REGISTRO,
                           XVE.ESTADO_CONTROL,
                           XVE.FECHA_ESTADO_CONTROL,
                           XVE.ANIO_ANTIGUEDAD,
                           XVE.DIAS_EVENTO,
                           XVE.DIAS_DESPLEGAR,
                           XVE.SALDO_DIAS,
                           XVE.FECHA_DESDE,
                           XVE.FECHA_HASTA,
                           XVE.FECHA_DESDE_DESPLEGAR,
                           XVE.FECHA_HASTA_DESPLEGAR,
                           XVE.ID_EVENTO_PADRE,
                           XVE.OBJECT_ID,
                           XVE.OBJECT_VERSION_NUMBER,
                           XVE.DESPLEGAR_P1
                      FROM PER_ALL_PEOPLE_F     PPF,
                           PER_ASSIGNMENTS_F    PAF,
                           PER_PERSON_TYPES     PPT,
                           XXCALV_VAC_EVENTOS   XVE
                     WHERE 1 = 1
                       AND PPF.PERSON_ID = PAF.PERSON_ID
                       AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
                       AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
                       AND PPT.PERSON_TYPE_ID = PPF.PERSON_TYPE_ID
                       AND PPF.PERSON_ID = XVE.PERSON_ID
                       AND XVE.DESPLEGAR_P1 = 'S'
                       AND PPF.PERSON_ID = v_restructuracion.PERSON_ID
                     ORDER BY XVE.ID_EVENTO DESC,
                              XVE.FECHA_ESTADO_CONTROL DESC) DET
                    WHERE 1 = 1
                      AND ROWNUM = 1;

        DELETE FROM XXCALV_VAC_EVENTOS
		 WHERE 1 = 1
		   AND PERSON_ID = v_restructuracion.PERSON_ID;
           
        INSERT 
          INTO XXCALV_VAC_EVENTOS (ID_EVENTO,
                                   ID_TIPO_EVENTO,
                                   PERSON_ID,
                                   ESTADO_REGISTRO,
                                   ESTADO_CONTROL,
                                   FECHA_ESTADO_CONTROL,
                                   ANIO_ANTIGUEDAD,
                                   DIAS_EVENTO,
                                   DIAS_DESPLEGAR,
                                   SALDO_DIAS,
                                   FECHA_DESDE,
                                   FECHA_HASTA,
                                   FECHA_DESDE_DESPLEGAR,
                                   FECHA_HASTA_DESPLEGAR,
                                   ID_EVENTO_PADRE,
                                   OBJECT_ID,
                                   OBJECT_VERSION_NUMBER,
                                   DESPLEGAR_P1,
                                   CREATION_DATE,
                                   CREATED_BY,
                                   LAST_UPDATE_DATE,
                                   LAST_UPDATE_BY)
                           VALUES (var_ID_EVENTO,                                   
                                   11,
                                   var_PERSON_ID,                           
                                   var_ESTADO_REGISTRO,
                                   var_ESTADO_CONTROL,
                                   SYSDATE,
                                   var_ANIO_ANTIGUEDAD,
                                   var_SALDO_DIAS,
                                   var_SALDO_DIAS, 
                                   0, --var_DIAS_DESPLEGAR,
                                   var_FECHA_DESDE,
                                   var_FECHA_HASTA,
                                   var_FECHA_DESDE_DESPLEGAR,
                                   var_FECHA_HASTA_DESPLEGAR,
                                   var_ID_EVENTO_PADRE,
                                   var_OBJECT_ID,
                                   var_OBJECT_VERSION_NUMBER,
                                   var_DESPLEGAR_P1,
                                   SYSDATE,
                                   -1,
                                   SYSDATE,
                                   -1);
    
    END LOOP;
    

END;

ROLLBACK;


COMMIT;