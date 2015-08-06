CREATE OR REPLACE PACKAGE BODY APPS.XXCALV_Control_de_Vacaciones IS
--  PROCEDURE graba_Mensaje ( p_Mensaje   IN VARCHAR2) IS
--    PRAGMA AUTONOMOUS_TRANSACTION;
--  BEGIN
--    INSERT INTO MAAT_DASH VALUES (SYSTIMESTAMP, p_Mensaje);
--    COMMIT;
--  END;
  --
  -- PROCEDURE Inicializar_Valores
  --
  -- DescripciÛn:  Inicializa variables globales o ngenerales del PKG.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --
  PROCEDURE Inicializar_Valores
             ( errbuf                IN OUT VARCHAR2
              ,retcode               IN OUT NUMBER
             ) IS
    --
  BEGIN
    --
    EXECUTE IMMEDIATE ('ALTER SESSION SET NLS_DATE_LANGUAGE=''LATIN AMERICAN SPANISH''');
    errbuf               := NULL;
    retcode              := 0;
    g_Org_Id             := FND_GLOBAL.ORG_ID;
    g_User_Id            := FND_GLOBAL.USER_ID;
    g_Responsibility_Id  := FND_GLOBAL.RESP_ID;
    g_Resp_Appl_Id       := FND_GLOBAL.RESP_APPL_ID;
    g_Login_Id           := FND_GLOBAL.LOGIN_ID;
    g_Conc_Id_Actual     := FND_GLOBAL.CONC_REQUEST_ID;
    g_Id_Juego_de_Libros := FND_PROFILE.VALUE_SPECIFIC
                                         ( 'GL_SET_OF_BKS_ID'
                                          ,g_User_Id
                                          ,g_Responsibility_Id
                                          ,g_Resp_Appl_Id
                                         );
    --
    BEGIN
      SELECT TO_NUMBER(MEANING)
        INTO g_Dias_Max_Vacaciones
        FROM APPS.FND_LOOKUP_VALUES
      WHERE 1 = 1
        AND LOOKUP_TYPE = 'XXCALV_DIAS_MAX_DISPLAY_VACACI'
        AND LOOKUP_CODE = 'MAX_DIAS'
        AND LANGUAGE = 'ESA';
    EXCEPTION
      WHEN OTHERS THEN
        --XXSTO_TOOLS_PKG.genera_salida('Error 1:  ' || SQLERRM, 'B');
        g_Dias_Max_Vacaciones := 0;
    END;
    --
    --XXSTO_TOOLS_PKG.genera_salida('g_Dias_Max_Vacaciones: ' || g_Dias_Max_Vacaciones, 'B');
    --
    BEGIN
      SELECT TO_NUMBER(MEANING)
        INTO g_Max_Meses_Disfrutar
        FROM APPS.FND_LOOKUP_VALUES
      WHERE 1 = 1
        AND LOOKUP_TYPE = 'XXCALV_MESES_MAX_DISFRUTAR_VAC'
        AND LOOKUP_CODE = 'MAX_MESES'
        AND LANGUAGE = 'ESA';
    EXCEPTION
      WHEN OTHERS THEN
        --XXSTO_TOOLS_PKG.genera_salida('Error 2:  ' || SQLERRM, 'B');
        g_Max_Meses_Disfrutar := 0;
    END;
    --
    --XXSTO_TOOLS_PKG.genera_salida('g_Max_Meses_Disfrutar: ' || g_Max_Meses_Disfrutar, 'B');
    --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Inicializar_Valores: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Inicializar_Valores;
  --
  --
  -- PROCEDURE Reconstruye_Saldos
  --
  -- DescripciÛn:  Genera la reconstrucciÛn de saldo, a partir del movimiento de asignaciÛn de vacaciones.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --            p_Person_Id          : Id de la persona a la cual actualizar los saldo
  --            p_Anio_Antiguedad    : Anio de antiguedad en el cual se actualizar·n los saldos
  --            p_Commit             : Indicador para saber si hace COMMIT (TRUE) o no (FALSE).
  --
  PROCEDURE Reconstruye_Saldos
             ( errbuf                   OUT VARCHAR2
              ,retcode                  OUT NUMBER
              ,p_Person_Id           IN     NUMBER
              ,p_Anio_Antiguedad     IN     NUMBER
              ,p_Commit              IN     VARCHAR2 DEFAULT 'FALSE'
             ) IS
    --
    CURSOR c_Unicos  ( p_Person_Id        IN NUMBER
                      ,p_Anio_Antiguedad  IN NUMBER
                     ) IS
        SELECT DISTINCT
               XVE.PERSON_ID
              ,XVE.ANIO_ANTIGUEDAD
          FROM XXCALV_VAC_EVENTOS       XVE
         WHERE 1 = 1
           AND XVE.PERSON_ID          = NVL(p_Person_Id, XVE.PERSON_ID)
           AND XVE.ANIO_ANTIGUEDAD    = NVL(p_Anio_Antiguedad, XVE.ANIO_ANTIGUEDAD)
      ORDER BY XVE.PERSON_ID
              ,XVE.ANIO_ANTIGUEDAD;
    --
    CURSOR c_Eventos ( p_Person_Id        IN NUMBER
                      ,p_Anio_Antiguedad  IN NUMBER
                     ) IS
        SELECT XVE.ROWID ROW_ID
              ,XVE.*
          FROM XXCALV_VAC_EVENTOS       XVE
         WHERE 1 = 1
           AND XVE.PERSON_ID          = NVL(p_Person_Id, XVE.PERSON_ID)
           AND XVE.ANIO_ANTIGUEDAD    = NVL(p_Anio_Antiguedad, XVE.ANIO_ANTIGUEDAD)
      ORDER BY XVE.PERSON_ID
              ,XVE.ANIO_ANTIGUEDAD
              ,NVL(XVE.ID_EVENTO_PADRE, XVE.ID_EVENTO)
              ,XVE.ID_EVENTO;
    --
    v_Saldo_Inicial           NUMBER;
    v_Saldo_Final             NUMBER;
    v_Nuevo_Saldo             NUMBER;
    --
  BEGIN
    --
    errbuf          := NULL;
    retcode         := 0;
    v_Saldo_Inicial := NULL;
    v_Saldo_Final   := NULL;
    v_Nuevo_Saldo   := NULL;
    FOR v_Unicos  IN c_Unicos (p_Person_Id, p_Anio_Antiguedad) LOOP
      FOR v_Eventos IN c_Eventos (v_Unicos.PERSON_ID, v_Unicos.ANIO_ANTIGUEDAD) LOOP
        --
        IF v_Eventos.ID_TIPO_EVENTO = 1 THEN
          v_Saldo_Inicial := v_Eventos.DIAS_EVENTO;
          v_Saldo_Final   := v_Eventos.SALDO_DIAS;
          v_Nuevo_Saldo   := v_Saldo_Inicial;
        ELSE
          IF v_Saldo_Inicial IS NULL THEN
            errbuf  := 'Error:  Orden de eventos no v·lido para id_persona: ' || v_Eventos.Person_Id || ' - AÒo: ' || v_Eventos.Anio_Antiguedad;
            XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
            retcode := 2;
            RETURN;
          END IF;
          --
          IF    v_Eventos.ID_TIPO_EVENTO IN (2, 3, 4, 11) THEN  -- Saldo inicial, solicitudes y vacaciones perdidas disminuyen el saldo.
            v_Nuevo_Saldo   := v_Nuevo_Saldo - v_Eventos.DIAS_EVENTO;
          ELSIF v_Eventos.ID_TIPO_EVENTO IN (6, 7, 8) THEN  -- Rechazo, CancelaciÛn y Vencimiento regresan los saldos.
            v_Nuevo_Saldo   := v_Nuevo_Saldo + v_Eventos.DIAS_EVENTO;
          ELSE -- (5, 9, 10)  -- AprobaciÛn, vacaciones disfrutadas y vacaciones pagadas, solo confirman el saldo
            v_Nuevo_Saldo   := v_Nuevo_Saldo;
          END IF;
          --
          BEGIN
            UPDATE XXCALV_VAC_EVENTOS
               SET SALDO_DIAS         = v_Nuevo_Saldo
             WHERE 1 = 1
               AND ROWID = v_Eventos.ROW_ID;
          EXCEPTION
            WHEN OTHERS THEN
              errbuf  := 'Error al actualizar saldo: ' || SQLERRM;
              XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
              retcode := 2;
              RETURN;
          END;
          --
          IF SQL%ROWCOUNT = 0 THEN
            errbuf  := 'No se pudo actualizar saldo del evento.';
            XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
            retcode := 2;
            RETURN;
          END IF;
          --
        END IF;
        --
      END LOOP;
      --
--      IF v_Nuevo_Saldo <> v_Saldo_Final THEN
--        errbuf  := 'El saldo final almacenado y el calculado no coinciden.';
--        XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
--        retcode := 2;
--        RETURN;
--      END IF;
      --
      IF p_Commit = 'TRUE' THEN
        COMMIT;
      END IF;
    END LOOP;
    --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Reconstruye_Saldos: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Reconstruye_Saldos;
  --
  --
  -- PROCEDURE Calcula_Dias_Disponibles
  --
  -- DescripciÛn:  Toma la infomaciÛn de los dÌas asignados para el perÌodo actual y siguiente, para luego restar de estos
  --               el n¿mero de dÌas utilizados en cada uno.  De esa manera se obtiene cada disponible.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --             p_Business_Group_Id: Id del Grupo de negocios.  (Est· asociado al empleado)
  --             p_Assignment_Id:      Id de la asignaciÛn del empleado
  --             p_Payroll_Id:         Id dela nÛmina del empleado
  --             p_Procesar_Fecha_Min:'S' para regresar la fecha MÌnima de vacaciones.  'N' para no hacer este prceso (consume tiempo)
  --             x_Fecha_Minima_Vac:  Basado en la ¿ltima ejecuciÛn de pago de nÛmina o pago r·pido,
  --                                  obtiene el primer dÌa disponible para solicitar vacaciones
  --
  PROCEDURE Calcula_Fecha_Minima_Vac
             ( errbuf                      IN OUT VARCHAR2
              ,retcode                     IN OUT NUMBER
              ,p_Business_Group_Id         IN     NUMBER
              ,p_Assignment_Id             IN     NUMBER
              ,p_Payroll_Id                IN     NUMBER
              ,p_Procesar_Fecha_Min        IN     VARCHAR2
              ,x_Fecha_Minima_Vac             OUT DATE
             ) IS
    --
    CURSOR c_Fecha_Max
                  ( p_Business_Group_Id         IN NUMBER
                   ,p_Assignment_Id             IN NUMBER
                   ,p_Payroll_Id                IN NUMBER
                  ) IS
      SELECT MAX(PTP.END_DATE) + 1
        FROM PAY_ASSIGNMENT_ACTIONS_V    PAA
            ,PER_TIME_PERIODS_V          PTP
       WHERE 1 = 1
         AND PTP.PAYROLL_ID          = p_Payroll_Id
         AND PTP.PERIOD_NAME         = PAA.PERIOD_NAME
         AND ASSIGNMENT_ID           = p_Assignment_Id
         AND BUSINESS_GROUP_ID + 0   = p_Business_Group_Id
         AND PAA.MESSAGES_EXIST      = 'N' 
         AND PAA.ACTION_TYPE        IN ('Q', 'R')
      --   AND NVL (date_earned, effective_date) BETWEEN TO_DATE (
      --                                                             '01-01-0001'
      --                                                            ,'DD-MM-YYYY'
      --                                                            )
      --                                                AND TO_DATE (
      --                                                             '31-12-4712'
      --                                                            ,'DD-MM-YYYY'
      --                                                            )
         AND ( ('MX' = 'US'
            AND PAA.ACTION_TYPE != 'I')
           OR  ('MX' != 'US'
            AND ( (PAA.ACTION_TYPE = 'I'
               AND NOT EXISTS
                         (SELECT 1
                            FROM PAY_ASSIGNMENT_ACTIONS AAC
                                ,PAY_RUN_RESULTS RRS
                           WHERE AAC.ASSIGNMENT_ID = PAA.ASSIGNMENT_ID
                             AND AAC.ACTION_SEQUENCE > PAA.ACTION_SEQUENCE
                             AND AAC.ASSIGNMENT_ACTION_ID = RRS.ASSIGNMENT_ACTION_ID
                             AND RRS.ELEMENT_TYPE_ID +
                                 0 IN
                                   (SELECT RRS1.ELEMENT_TYPE_ID
                                      FROM PAY_RUN_RESULTS RRS1
                                     WHERE RRS1.ASSIGNMENT_ACTION_ID =
                                             PAA.ASSIGNMENT_ACTION_ID)))
              OR  (PAA.ACTION_TYPE != 'I'))))
         AND ( ('' IS NOT NULL
            AND ( (EXISTS
                     (SELECT 1
                        FROM PAY_RESTRICTION_VALUES PRV1
                       WHERE PRV1.RESTRICTION_CODE = 'ACTION_TYPE'
                         AND PRV1.CUSTOMIZED_RESTRICTION_ID = ''
                         AND PRV1.VALUE = PAA.ACTION_TYPE))
              OR  (NOT EXISTS
                     (SELECT 1
                        FROM PAY_RESTRICTION_VALUES PRV1
                       WHERE PRV1.RESTRICTION_CODE = 'ACTION_TYPE'
                         AND PRV1.CUSTOMIZED_RESTRICTION_ID = ''))))
           OR  '' IS NULL)
      --ORDER BY PAA.ACTION_SEQUENCE DESC
      ;
    --
  BEGIN
    --
      x_Fecha_Minima_Vac := NULL;
      IF NVL(p_Procesar_Fecha_Min, 'N') = 'S' THEN
        OPEN  c_Fecha_Max (p_Business_Group_Id, p_Assignment_Id, p_Payroll_Id);
        FETCH c_Fecha_Max INTO x_Fecha_Minima_Vac;
        IF c_Fecha_Max%NOTFOUND THEN
          x_Fecha_Minima_Vac := NULL;
        END IF;
        CLOSE c_Fecha_Max;
      END IF;
    --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Calcula_Fecha_Minima_Vac: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Calcula_Fecha_Minima_Vac;
  --
  --
  -- PROCEDURE Calcula_Dias_Disponibles
  --
  -- DescripciÛn:  Toma la infomaciÛn de los dÌas asignados para el perÌodo actual y siguiente, para luego restar de estos
  --               el n¿mero de dÌas utilizados en cada uno.  De esa manera se obtiene cada disponible.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --             p_Person_Id: Id de la persona a la que se deben calcular los dÌas.
  --             p_Business_Group_Id: Id del Grupo de negocios.  (Est· asociado al empleado)
  --             p_Procesar_Fecha_Min:'S' para regresar la fecha MÌnima de vacaciones.  'N' para no hacer este prceso (consume tiempo)
  --             p_Valida_Informativo: 'S' si debe validar que el registro tipo 1 con los saldos ya est· creado.  Otro valor trae el saldo con base en la antiguedad. 
  --             x_Dias_Actual:       N¿mero de dÌas disponibles en el perÌodo actual.
  --             x_DÌas_Siguiente:    N¿mero de dÌas disponibles en el siguiente perÌodo
  --             x_Registro_Base_Act: Regresa 'S' si el valor del dÌa para el perÌodo actual se tomÛ de la tabla base del sistema o
  --                                          'N' si se tomÛ de la tabla propia del desarrollo.
  --             x_Registro_Base_Sig: Regresa 'S' si el valor del dÌa para el perÌodo siguiente se tomÛ de la tabla base del sistema o
  --                                          'N' si se tomÛ de la tabla propia del desarrollo.
  --             x_Fecha_Minima_Vac:  Basado en la ¿ltima ejecuciÛn de pago de nÛmina o pago r·pido,
  --                                  obtiene el primer dÌa disponible para solicitar vacaciones
  --             x_Supervisor_Id:     Valor del Id para el supervisor del empleado que se consulta.
  --
  PROCEDURE Calcula_Dias_Disponibles
             ( errbuf                      IN OUT VARCHAR2
              ,retcode                     IN OUT NUMBER
              ,p_Person_Id                 IN     NUMBER
              ,p_Antiguedad_Act            IN     NUMBER
              ,p_Antiguedad_Sig            IN     NUMBER
              ,p_Business_Group_Id         IN     NUMBER
              ,p_Procesar_Fecha_Min        IN     VARCHAR2
              ,p_Valida_Informativo        IN     VARCHAR2
              ,x_Dias_Actual                  OUT NUMBER
              ,x_Dias_Siguiente               OUT NUMBER
              ,x_Registro_Base_Act            OUT VARCHAR2
              ,x_Registro_Base_Sig            OUT VARCHAR2
              ,x_Fecha_Minima_Vac             OUT DATE
              ,x_Supervisor_Id                OUT NUMBER
             ) IS
    --
    CURSOR c_Asignaciones (p_Person_Id     IN NUMBER) IS
      SELECT PA7.ASSIGNMENT_ID
            ,PA7.PAYROLL_ID
            ,PA7.SUPERVISOR_ID
        FROM PER_ASSIGNMENTS_V7   PA7
       WHERE 1 = 1
         AND PA7.PERSON_ID                  = p_Person_Id
         AND SYSDATE                  BETWEEN PA7.EFFECTIVE_START_DATE  AND PA7.EFFECTIVE_END_DATE
         AND PA7.PRIMARY_FLAG               = 'Y';
    --
    CURSOR c_Tipo_Nomina (p_Assignment_Id     NUMBER) IS
      SELECT HLU.MEANING
        FROM PAY_ELEMENT_TYPES_F          ETF
            ,PAY_ELEMENT_ENTRIES_F        EEF
            ,PAY_INPUT_VALUES_F           IVF
            ,PAY_ELEMENT_ENTRY_VALUES_F   EEV
            ,HR_LOOKUPS                   HLU
       WHERE 1 = 1
         AND ETF.ELEMENT_NAME           = 'Integrated Daily Wage'
         AND EEF.ELEMENT_TYPE_ID        = ETF.ELEMENT_TYPE_ID
         AND EEF.ASSIGNMENT_ID          = p_Assignment_Id
         AND IVF.ELEMENT_TYPE_ID        = ETF.ELEMENT_TYPE_ID
         AND IVF.DISPLAY_SEQUENCE       = 4
         AND EEV.ELEMENT_ENTRY_ID       = EEF.ELEMENT_ENTRY_ID
         AND EEV.INPUT_VALUE_ID         = IVF.INPUT_VALUE_ID
         AND HLU.LOOKUP_TYPE            = IVF.LOOKUP_TYPE      --'MX_IDW_FACTOR_TABLES'
         AND HLU.ENABLED_FLAG           = 'Y'
         AND HLU.LOOKUP_CODE            = EEV.SCREEN_ENTRY_VALUE
         AND SYSDATE BETWEEN EEV.EFFECTIVE_START_DATE AND EEV.EFFECTIVE_END_DATE
         AND SYSDATE BETWEEN EEF.EFFECTIVE_START_DATE AND EEF.EFFECTIVE_END_DATE;
    --
    CURSOR c_Dias ( p_Tipo_Nomina     VARCHAR2
                   ,p_Antiguedad      NUMBER
                  ) IS
      SELECT UCI.VALUE
        FROM PAY_USER_TABLES_FV               UTF
            ,PAY_USER_COLUMNS_FV              UCF
            ,XXCALV_PAY_USER_COLUMN_INST_V    UCI
       WHERE 1 = 1
         AND UTF.BASE_USER_TABLE_NAME          = p_Tipo_Nomina
         AND UCF.USER_TABLE_ID                 = UTF.USER_TABLE_ID
         AND UCF.BASE_USER_COLUMN_NAME         = 'DIAS VACACIONES'
         AND UCI.USER_COLUMN_ID                = UCF.USER_COLUMN_ID
         AND p_Antiguedad + 0.1          BETWEEN UCI.ROW_LOW_RANGE_OR_NAME AND UCI.ROW_HIGH_RANGE;
    --
    v_Assignment_Id           NUMBER;
    v_Tipo_Nomina             HR_LOOKUPS.MEANING%TYPE;
    v_Payroll_Id              NUMBER;
    --
  BEGIN
    --
    x_Registro_Base_Act := 'N';
    x_Registro_Base_Sig := 'N';
    IF p_Person_Id IS NULL THEN
      errbuf  := 'Error:  Debe indicarse el empleado a calcular.';
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
    END IF;
    --
    errbuf           := NULL;
    retcode          := 0;
    v_Assignment_Id := NULL;
    FOR v_Asignaciones IN c_Asignaciones(p_person_id) LOOP
      --
      v_Assignment_Id := v_Asignaciones.assignment_id;
      x_Supervisor_Id := v_Asignaciones.SUPERVISOR_ID;
      v_Payroll_Id    := v_Asignaciones.PAYROLL_ID;
      --
      EXIT;
      --
    END LOOP;
    --
    IF v_Assignment_Id IS NULL THEN
      errbuf  := 'Empleado no tiene datos de asignaciÛn.';
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
    ELSE
      --
      Calcula_Fecha_Minima_Vac
             ( errbuf                      => errbuf
              ,retcode                     => retcode
              ,p_Business_Group_Id         => p_Business_Group_Id
              ,p_Assignment_Id             => v_Assignment_Id
              ,p_Payroll_Id                => v_Payroll_Id
              ,p_Procesar_Fecha_Min        => p_Procesar_Fecha_Min
              ,x_Fecha_Minima_Vac          => x_Fecha_Minima_Vac
             );
      --
      v_Tipo_Nomina := NULL;
      OPEN  c_Tipo_Nomina (v_Assignment_Id);
      FETCH c_Tipo_Nomina INTO v_Tipo_Nomina;
      IF c_Tipo_Nomina%NOTFOUND THEN
        v_Tipo_Nomina := NULL;
      END IF;
      CLOSE c_Tipo_Nomina;
      --
      IF v_Tipo_Nomina IS NULL THEN
        errbuf  := 'Empleado no tiene asignada tabla de SDI.';
        XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
        retcode := 2;
        RETURN;
      ELSE
        --
        BEGIN
          SELECT NVL(SALDO_DIAS, 0)
            INTO x_Dias_Actual
            FROM XXCALV_VAC_EVENTOS
           WHERE 1 = 1
             AND PERSON_ID         = p_Person_Id
             AND ID_TIPO_EVENTO    = 1       -- N¿mero de dÌas de saldo se tiene en este registro 
             AND ANIO_ANTIGUEDAD   = p_Antiguedad_Act;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_Dias_Actual := NULL;
            OPEN  c_Dias (v_Tipo_Nomina, p_Antiguedad_Act);
            FETCH c_Dias INTO x_Dias_Actual;
            IF c_Dias%NOTFOUND THEN
              x_Dias_Actual := NULL;
            END IF;
            CLOSE c_Dias;
            x_Registro_Base_Act := 'S';
          WHEN OTHERS THEN
            x_Dias_Actual := NULL;
        END;
        --
        BEGIN
          SELECT NVL(SALDO_DIAS, 0)
            INTO x_Dias_Siguiente
            FROM XXCALV_VAC_EVENTOS
           WHERE 1 = 1
             AND PERSON_ID         = p_Person_Id
             AND ID_TIPO_EVENTO    = 1       -- N¿mero de dÌas de saldo se tiene en este registro 
             AND ANIO_ANTIGUEDAD   = p_Antiguedad_Sig;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF p_Valida_Informativo = 'S' THEN
              --
              errbuf  := 'El empleado a¿n no tiene el registro informativo de saldos.  Espere la ejecuciÛn del concurrente nocturno.';
              XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
              retcode := 2;
              x_Dias_Siguiente := NULL;
              RETURN;
              --
            ELSE
              --
              x_Dias_Siguiente := NULL;
              OPEN  c_Dias (v_Tipo_Nomina, p_Antiguedad_Sig);
              FETCH c_Dias INTO x_Dias_Siguiente;
              IF c_Dias%NOTFOUND THEN
                x_Dias_Siguiente := NULL;
              END IF;
              CLOSE c_Dias;
              x_Registro_Base_Sig := 'S';
              --
            END IF;
            --
          WHEN OTHERS THEN
            x_Dias_Siguiente := NULL;
        END;
        --
      END IF;
      --
    END IF;
    --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Calcula_Dias_Disponibles: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Calcula_Dias_Disponibles;
  --
  -- PROCEDURE Regresa_Datos_Empleado
  --
  -- DescripciÛn:  Toma la infomaciÛn de los dÌas asignados para el perÌodo actual y siguiente, para luego restar de estos
  --               el n¿mero de dÌas utilizados en cada uno.  De esa manera se obtiene cada disponible.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --             p_Person_Id: Id de la persona a la que se deben calcular los dÌas.
  --             x_Numero_Empleado            N¿mero de nÛmina del empleado.
  --             x_Nombre_Completo            Nombre completo del empleado
  --             x_Requiere_Aprobacion        Indicador de si el empleado requiere solicitar aprobaciÛn de vacaciones del supervisor.
  --             x_Fecha_Control_Vacaciones   Fecha de la ¿ltima revisiÛn de datos del proceso de control de vacaciones.
  --             x_Captura_Vacaciones         Indicador de si es capturador de vacaciones o no.
  --             x_Fecha_Ingreso              Fecha de ingreso a la empresa.
  --             x_Antiguedad_Act             AÒos de antiguedad actual.
  --             x_Antiguedad_Sig             AÒos de antiguedad siguiente.
  --             x_Dias_Actual:               N¿mero de dÌas disponibles en el perÌodo actual.
  --             x_Fecha_Inicio_Act:          Fecha de inicio del perÌodo actual.
  --             x_Fecha_Fin_Act:             Fecha de finalizaciÛn del perÌodo actual
  --             x_DÌas_Siguiente:            N¿mero de dÌas disponibles en el siguiente perÌodo
  --             x_Fecha_Inicio_Sig:          Fecha de inicio del perÌodo siguiente.
  --             x_Fecha_Fin_Sig:             Fecha de finalizaciÛn del perÌodo siguiente.
  --             x_Registro_Base_Act: Regresa 'S' si el valor del dÌa para el perÌodo actual se tomÛ de la tabla base del sistema o
  --                                          'N' si se tomÛ de la tabla propia del desarrollo.
  --             x_Registro_Base_Sig: Regresa 'S' si el valor del dÌa para el perÌodo siguiente se tomÛ de la tabla base del sistema o
  --                                          'N' si se tomÛ de la tabla propia del desarrollo.
  --             x_Fecha_Minima_Vac:  Basado en la ¿ltima ejecuciÛn de pago de nÛmina o pago r·pido,
  --                                  obtiene el primer dÌa disponible para solicitar vacaciones
  --             x_Supervisor_Id:     Valor del Id para el supervisor del empleado que se consulta.
  --             x_Business_Group_Id: Business_Group_Id asociado al empleado.
  --
  --
  PROCEDURE Regresa_Datos_Empleado
             ( errbuf                           OUT VARCHAR2
              ,retcode                          OUT NUMBER
              ,p_Person_Id                   IN     NUMBER
              ,x_Numero_Empleado                OUT VARCHAR2
              ,x_Nombre_Completo                OUT VARCHAR2
              ,x_Requiere_Aprobacion            OUT VARCHAR2
              ,x_Fecha_Control_Vacaciones       OUT VARCHAR2
              ,x_Captura_Vacaciones             OUT VARCHAR2
              ,x_Fecha_Ingreso                  OUT DATE
              ,x_Antiguedad_Act                 OUT NUMBER
              ,x_Antiguedad_Sig                 OUT NUMBER
              ,x_Dias_Actual                    OUT NUMBER
              ,x_Fecha_Inicio_Act               OUT DATE
              ,x_Fecha_Fin_Act                  OUT DATE
              ,x_Dias_Siguiente                 OUT NUMBER
              ,x_Fecha_Inicio_Sig               OUT DATE
              ,x_Fecha_Fin_Sig                  OUT DATE
              ,x_Registro_Base_Act              OUT VARCHAR2
              ,x_Registro_Base_Sig              OUT VARCHAR2
              ,x_Fecha_Minima_Vac               OUT DATE
              ,x_Supervisor_Id                  OUT NUMBER
              ,x_Business_Group_Id              OUT NUMBER
             ) IS
    --
    CURSOR c_Personas (p_Person_Id   IN NUMBER) IS
      SELECT DAT.ROW_ID
            ,DAT.FULL_NAME
            ,DAT.EMPLOYEE_NUMBER
            ,DAT.PERSON_ID
            ,DAT.BUSINESS_GROUP_ID
            ,DAT.REQUIERE_APROBACION
            ,DAT.FECHA_CONTROL_VACACIONES
            ,DAT.CAPTURA_VACACIONES
            ,DAT.HIRE_DATE
            ,DAT.ANTIGUEDAD_ACT
            ,DAT.FECHA_INICIO_PERIODO_ACT
            ,ADD_MONTHS(DAT.FECHA_INICIO_PERIODO_ACT, g_Max_Meses_Disfrutar) - 1      FECHA_FIN_PERIODO_ACT
            ,DAT.ANTIGUEDAD_SIG
            ,DAT.FECHA_INICIO_PERIODO_SIG
            ,ADD_MONTHS(DAT.FECHA_INICIO_PERIODO_SIG, g_Max_Meses_Disfrutar) - 1      FECHA_FIN_PERIODO_SIG
        FROM (
              SELECT COM.*
                    ,ADD_MONTHS(HIRE_DATE, (COM.ANTIGUEDAD_ACT * 12))              FECHA_INICIO_PERIODO_ACT
                    ,COM.ANTIGUEDAD_ACT + 1                                        ANTIGUEDAD_SIG
                    ,ADD_MONTHS(HIRE_DATE, ((COM.ANTIGUEDAD_ACT + 1) * 12))        FECHA_INICIO_PERIODO_SIG
                FROM (
                      SELECT PP7.ROW_ID
                            ,PP7.FULL_NAME
                            ,PP7.EMPLOYEE_NUMBER
                            ,PP7.PERSON_ID
                            ,PP7.BUSINESS_GROUP_ID
                            ,NVL(PP7.ATTRIBUTE28, 'N')        REQUIERE_APROBACION
                            ,PP7.ATTRIBUTE29                  FECHA_CONTROL_VACACIONES
                            ,NVL(PP7.ATTRIBUTE30, 'N')        CAPTURA_VACACIONES
                            --,TRUNC(PP7.HIRE_DATE)             HIRE_DATE
                            ,TRUNC(get_Hire_Date(PP7.PERSON_ID)) HIRE_DATE
                            --,TRUNC(MONTHS_BETWEEN(SYSDATE, PP7.HIRE_DATE)/12)
                            ,TRUNC(MONTHS_BETWEEN(SYSDATE, get_Hire_Date(PP7.PERSON_ID))/12)
                                                              ANTIGUEDAD_ACT
                        FROM PER_PEOPLE_V7     PP7
                       WHERE 1 = 1
                         AND PP7.EFFECTIVE_START_DATE      <= TRUNC(SYSDATE)
                         AND PP7.SYSTEM_PERSON_TYPE        IN ('EMP')
                         AND PP7.PERSON_ID                  = p_Person_Id
                     ) COM
             ) DAT;
    --
  BEGIN
    --
    errbuf               := NULL;
    retcode              := 0;
    --
    Inicializar_Valores
             ( errbuf
              ,retcode
             );
    IF retcode = 2 THEN
      RETURN;
    END IF;
    --
    FOR v_Personas IN c_Personas(p_Person_Id) LOOP
      --
      x_Numero_Empleado              := v_Personas.EMPLOYEE_NUMBER;
      x_Nombre_Completo              := v_Personas.FULL_NAME;
      x_Requiere_Aprobacion          := v_Personas.REQUIERE_APROBACION;
      x_Fecha_Control_Vacaciones     := v_Personas.FECHA_CONTROL_VACACIONES;
      x_Captura_Vacaciones           := v_Personas.CAPTURA_VACACIONES;
      x_Fecha_Ingreso                := v_Personas.HIRE_DATE;
      x_Antiguedad_Act               := v_Personas.ANTIGUEDAD_ACT;
      x_Antiguedad_Sig               := v_Personas.ANTIGUEDAD_SIG;
      x_Fecha_Inicio_Act             := v_Personas.FECHA_INICIO_PERIODO_ACT;
      x_Fecha_Fin_Act                := v_Personas.FECHA_FIN_PERIODO_ACT;
      x_Fecha_Inicio_Sig             := v_Personas.FECHA_INICIO_PERIODO_SIG;
      x_Fecha_Fin_Sig                := v_Personas.FECHA_FIN_PERIODO_SIG;
      x_Business_Group_Id            := v_Personas.BUSINESS_GROUP_ID;
      --
      Calcula_Dias_Disponibles
             ( errbuf                => errbuf
              ,retcode               => retcode
              ,p_Person_Id           => p_Person_Id
              ,p_Antiguedad_Act      => v_Personas.ANTIGUEDAD_ACT
              ,p_Antiguedad_Sig      => v_Personas.ANTIGUEDAD_SIG
              ,p_Business_Group_Id   => v_Personas.Business_Group_Id
              ,p_Procesar_Fecha_Min  => 'S'
              ,p_Valida_Informativo  => 'S'
              ,x_Dias_Actual         => x_Dias_Actual
              ,x_Dias_Siguiente      => x_Dias_Siguiente
              ,x_Registro_Base_Act   => x_Registro_Base_Act
              ,x_Registro_Base_Sig   => x_Registro_Base_Sig
              ,x_Fecha_Minima_Vac    => x_Fecha_Minima_Vac
              ,x_Supervisor_Id       => x_Supervisor_Id
             );

      IF retcode = 2 THEN
        RETURN;
      END IF;
      --
      EXIT;
    END LOOP;
    --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Regresa_Datos_Empleado: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Regresa_Datos_Empleado;
  --
  -- PROCEDURE Actualiza_Fecha_Control
  --
  -- DescripciÛn:  Actualiza la fecha control del empleado, con la ¿ltima fecha en que se generÛ una revisiÛn y actualizaciÛn de datos.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --             p_row_id: rowid a actualizar
  --
  PROCEDURE Actualiza_Fecha_Control
             ( errbuf                IN OUT VARCHAR2
              ,retcode               IN OUT NUMBER
              ,p_Row_Id              IN     PER_PEOPLE_V7.ROW_ID%TYPE
             ) IS
    --
  BEGIN
    --
    UPDATE PER_ALL_PEOPLE_F
       SET ATTRIBUTE29 = TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS')
     WHERE 1 = 1
       AND ROWID = p_Row_Id;
    --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Actualiza_Fecha_Control: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Actualiza_Fecha_Control;
  --
  -- FUNCTION Actualiza_Datos_Anio_Base
  --
  -- DescripciÛn:  Actualiza el saldo de dÌas, ubicando el registro que almacena el dato en la historia.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --            p_Person_Id          : Id de la persona a la cual actualizar el saldo
  --            p_Anio_Antiguedad    : Anio de antiguedad en el cual se actualizar· el saldo
  --            p_Dias               : N¿mero de dÌas a transaccionar.  Positivo si suma al saldo;  negativo si resta del saldo.
  --
  -- Retorna el nuevo saldo disponible de dÌas.
  --
  FUNCTION Actualiza_Datos_Anio_Base
             ( errbuf                   OUT VARCHAR2
              ,retcode                  OUT NUMBER
              ,p_Person_Id           IN     NUMBER
              ,p_Anio_Antiguedad     IN     NUMBER
              ,p_Dias                IN     NUMBER   DEFAULT NULL  -- positivo si suma al saldo;   negativo si resta del saldo
             ) RETURN NUMBER IS
    --
    CURSOR c_Saldo
              ( p_Person_Id           IN NUMBER
               ,p_Anio_Antiguedad     IN NUMBER
              )  IS
        SELECT XVE.ROWID                ROW_ID
              ,NVL(XVE.SALDO_DIAS, 0)   SALDO_DIAS
          FROM XXCALV_VAC_EVENTOS       XVE
         WHERE 1 = 1
           AND XVE.PERSON_ID           = p_Person_Id
           AND XVE.ID_TIPO_EVENTO      = 1                 --  DÌas asignados del periodo y ahÌ almacena saldo en dÌas
           AND XVE.ANIO_ANTIGUEDAD     = p_Anio_Antiguedad
      ORDER BY XVE.ID_EVENTO;    
    --
    v_Nuevo_Saldo             NUMBER;
  BEGIN
    --
    errbuf        :=  NULL;
    retcode       := 0;
    v_Nuevo_Saldo := NULL;
    FOR v_Saldo IN c_Saldo (p_Person_Id, p_Anio_Antiguedad) LOOP
      v_Nuevo_Saldo := NVL(v_Saldo.SALDO_DIAS, 0)  + NVL(p_Dias, 0);
      UPDATE XXCALV_VAC_EVENTOS
         SET SALDO_DIAS         = NVL2(p_Dias, v_Nuevo_Saldo, SALDO_DIAS)
       WHERE 1 = 1
         AND ROWID = v_Saldo.ROW_ID;
      EXIT;
    END LOOP;
    --
    RETURN v_Nuevo_Saldo;
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Actualiza_Datos_Anio_Base: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN NULL;
  END Actualiza_Datos_Anio_Base;
  --
  -- PROCEDURE Inserta_Registro_Historia_Enc
  --
  -- DescripciÛn:  Graba fÌsicamente la informaciÛn nueva de encabezados en la tabla de historia.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --             x_xxcalv_vac_eventos:     Registro de encabezado a grabar.
  --
  PROCEDURE Inserta_Registro_Historia_Enc
             ( errbuf                       IN OUT VARCHAR2
              ,retcode                      IN OUT NUMBER
              ,x_xxcalv_vac_eventos         IN OUT XXCALV_VAC_EVENTOS%ROWTYPE
             ) IS
    --
  BEGIN
    --
    SELECT XXCALV_VAC_EVENTO_S.NEXTVAL
      INTO x_xxcalv_vac_eventos.ID_EVENTO
      FROM DUAL;
    --
    INSERT INTO XXCALV_VAC_EVENTOS VALUES x_xxcalv_vac_eventos;
    --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Inserta_Registro_Historia_Enc: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Inserta_Registro_Historia_Enc;
  --
  -- PROCEDURE Inserta_Registro_Historia_Det
  --
  -- DescripciÛn:  Graba fÌsicamente la informaciÛn nueva de detalle en la tabla de historia.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --             x_xxcalv_vac_eventos_det: Registro de detalle a grabar.
  --
  PROCEDURE Inserta_Registro_Historia_Det
             ( errbuf                       IN OUT VARCHAR2
              ,retcode                      IN OUT NUMBER
              ,x_xxcalv_vac_eventos_det     IN OUT XXCALV_VAC_EVENTOS_DET%ROWTYPE
             ) IS
    --
  BEGIN
    --
    INSERT INTO XXCALV_VAC_EVENTOS_DET VALUES x_xxcalv_vac_eventos_det;
    --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Inserta_Registro_Historia_Det: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Inserta_Registro_Historia_Det;
  --
  -- PROCEDURE Elimina_Ausencia
  --
  -- DescripciÛn:  Elimina una ausencia especÌfica asociada a un empelado.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --             p_Absence_Attendance_Id         Id de la ausencia a eliminar.
  --             p_Object_Version_Number         N¿mero de versiÛn del objeto a eliminar.
  --
  PROCEDURE Elimina_Ausencia
             ( errbuf                          IN OUT VARCHAR2
              ,retcode                         IN OUT NUMBER
              ,p_Absence_Attendance_Id         IN OUT NUMBER
              ,p_Object_Version_Number         IN OUT NUMBER
             ) IS
    --
    v_Validate                      BOOLEAN     := FALSE;  
    v_Error_Code                    VARCHAR2(1000);
    v_SqlErrMsg_Ini                 VARCHAR2(2000);
    v_Error_Msg                     VARCHAR2(2000);
  --
    --
  BEGIN
    APPS.Hr_Person_Absence_Api.Delete_Person_Absence
          (p_validate                      => v_Validate
          ,p_absence_attendance_id         => p_Absence_Attendance_Id
          ,p_object_version_number         => p_Object_Version_Number
          );
    --
  EXCEPTION
    WHEN OTHERS THEN
      v_SqlErrMsg_Ini := SQLERRM;
      v_Error_Code    := REPLACE(TRIM(SUBSTR(v_SqlErrMsg_Ini, 12)), ':');
      XXSTO_TOOLS_PKG.genera_salida('SQLERRM: ' || v_SqlErrMsg_Ini);
      XXSTO_TOOLS_PKG.genera_salida('v_Error_Code: ' || v_Error_Code);
      BEGIN
        SELECT MESSAGE_TEXT
          INTO v_Error_Msg
          FROM FND_NEW_MESSAGES
         WHERE MESSAGE_NAME     = v_Error_Code
           AND APPLICATION_ID   = 800
           AND LANGUAGE_CODE    = USERENV('LANG');
      EXCEPTION
        WHEN OTHERS THEN
          v_Error_Msg := v_SqlErrMsg_Ini;
      END;
      errbuf  := 'Error en Elimina_Ausencia: ' || v_Error_Msg;
      retcode := 2;
      RETURN;
  END Elimina_Ausencia;
  --
  -- PROCEDURE Genera_Ausencia
  --
  -- DescripciÛn:  Genera los movimientos de ausencia por vacaciones asociados al empleado.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --             p_Person_Id                     Id de la persona a la cual generar la ausencia
  --             p_Business_Group_Id             Business Group Id asociado al empleado
  --             p_Absence_Attendance_Type_Id    Id del tipo de ausencia para VACACIONES
  --             p_Date_Start                    Dia en que inicia la ausencia
  --             p_Date_End                      Dia en que concluye la ausencia
  --             p_Absence_Days                  Dias de ausencia a reportar
  --             x_Absence_Attendance_Id         Regresa Id de la ausencia generada
  --             x_Object_Version_Number         Regresa N¿mero de versiÛn del objeto generado.
  --             x_Element_Id                    Regresa el ID asociado al elemento creado.
  --
  PROCEDURE Genera_Ausencia
             ( errbuf                          IN OUT VARCHAR2
              ,retcode                         IN OUT NUMBER
              ,p_Person_Id                     IN     NUMBER
              ,p_Business_Group_Id             IN     NUMBER
              ,p_Absence_Attendance_Type_Id    IN     NUMBER
              ,p_Date_Start                    IN     DATE
              ,p_Date_End                      IN     DATE
              ,p_Absence_Days                  IN OUT NUMBER
              ,x_Absence_Attendance_Id         IN OUT NUMBER
              ,x_Object_Version_Number         IN OUT NUMBER
              ,x_Element_Id                    IN OUT NUMBER
             ) IS
    --
    v_Validate                      BOOLEAN     := FALSE;  
    v_Effective_Date                DATE        := TRUNC(SYSDATE);
    v_Absence_Hours                 NUMBER      := NULL;
    v_Occurrence                    NUMBER;
    v_Dur_Dys_Less_Warning          BOOLEAN;
    v_Dur_Hrs_Less_Warning          BOOLEAN;
    v_Exceeds_Pto_Entit_Warning     BOOLEAN;
    v_Exceeds_Run_Total_Warning     BOOLEAN;
    v_Abs_Overlap_Warning           BOOLEAN;
    v_Abs_Day_After_Warning         BOOLEAN;
    v_Dur_Overwritten_Warning       BOOLEAN;
    --
    v_Dias_Leidos                   NUMBER;
    --
  BEGIN
    per_abs_shd.g_absence_days := p_Absence_Days;
    APPS.Hr_Person_Absence_Api.Create_Person_Absence
        (p_validate                      => v_validate
        ,p_effective_date                => v_effective_date
        ,p_person_id                     => p_Person_Id
        ,p_business_group_id             => p_Business_Group_Id
        ,p_absence_attendance_type_id    => p_Absence_Attendance_Type_Id
        ,p_date_start                    => p_Date_Start
        ,p_date_end                      => p_Date_End
        ,p_absence_days                  => p_Absence_Days
        ,p_absence_hours                 => v_absence_hours
        ,p_absence_attendance_id         => x_absence_attendance_id
        ,p_object_version_number         => x_object_version_number
        ,p_occurrence                    => v_occurrence
        ,p_dur_dys_less_warning          => v_dur_dys_less_warning
        ,p_dur_hrs_less_warning          => v_dur_hrs_less_warning
        ,p_exceeds_pto_entit_warning     => v_exceeds_pto_entit_warning
        ,p_exceeds_run_total_warning     => v_exceeds_run_total_warning
        ,p_abs_overlap_warning           => v_abs_overlap_warning
        ,p_abs_day_after_warning         => v_abs_day_after_warning
        ,p_dur_overwritten_warning       => v_dur_overwritten_warning
        );
    --
    IF x_absence_attendance_id IS NOT NULL THEN
      BEGIN
        SELECT MAX(absence_days)
          INTO v_Dias_Leidos
          FROM PER_ABSENCE_ATTENDANCES
         WHERE 1 = 1
           AND ABSENCE_ATTENDANCE_ID = x_absence_attendance_id;
      EXCEPTION
        WHEN OTHERS THEN
          v_Dias_Leidos := 0;
      END;
      --
      IF v_Dias_Leidos <> p_Absence_Days THEN
        errbuf  := 'Los dÌas generados no corresponden a los dÌas envÌados a grabar.';
        XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
        retcode := 2;
        RETURN;
      END IF;
      --
    END IF;
    --
    BEGIN
      SELECT MAX(ELEMENT_ENTRY_ID)
        INTO x_Element_Id
        FROM XXCALV_PAY_ELEMENT_ENTRIES
       WHERE 1 = 1
         AND CREATOR_ID = x_absence_attendance_id;
    EXCEPTION
      WHEN OTHERS THEN
        errbuf  := 'Error al localizar elemento generado para id ' || x_absence_attendance_id || ' : ' || SQLERRM;
        XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
        retcode := 2;
        RETURN;
    END;
    --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Genera_Ausencia: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Genera_Ausencia;
  --
  -- PROCEDURE Elimina_Elemento
  --
  -- DescripciÛn:  Elimina los elemento por pago de vacaciones asociados al empleado.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --             p_Element_Entry_Id              Id de la entrada del elemento a eliminar.
  --             p_Object_Version_Number         N¿mero de versiÛn del objeto a eliminar.
  --
  PROCEDURE Elimina_Elemento
             ( errbuf                          IN OUT VARCHAR2
              ,retcode                         IN OUT NUMBER
              ,p_Element_Entry_Id              IN     NUMBER
              ,p_Object_Version_Number         IN     NUMBER
              ,p_Effective_Date                IN     DATE       DEFAULT TRUNC(SYSDATE)
             ) IS
    --
    v_Validate                      BOOLEAN       := FALSE;  
    v_Object_Version_Number         NUMBER;
    v_Datetrack_Delete_Mode         VARCHAR2(100) := 'ZAP';
    v_Effective_Start_Date          DATE;
    v_Effective_End_Date            DATE;
    v_Create_Warning                BOOLEAN;
    --
  BEGIN
    --
    v_Object_Version_Number := p_Object_Version_Number;
    --
    PAY_ELEMENT_ENTRY_API.delete_element_entry
                 ( p_validate                      => v_Validate
                  ,p_datetrack_delete_mode         => v_Datetrack_Delete_Mode
                  ,p_effective_date                => p_Effective_Date
                  ,p_element_entry_id              => p_Element_Entry_Id
                  ,p_object_version_number         => v_Object_Version_Number
                  ,p_effective_start_date          => v_Effective_Start_Date
                  ,p_effective_end_date            => v_Effective_End_Date
                  ,p_delete_warning                => v_Create_Warning
                 );
    --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Elimina_Elemento: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Elimina_Elemento;
  --
  -- PROCEDURE Genera_Elemento
  --
  -- DescripciÛn:  Genera los elemento por pago de vacaciones asociados al empleado.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --             p_Person_Id                     Id de la persona a la cual generar la ausencia
  --             p_Business_Group_Id             Business Group Id asociado al empleado
  --             p_Assignment_Id                 Id de la asignaciÛn relacionada a la persona.
  --             p_Dias                          N¿mero de dÌas a grabar en el elemento.
  --             x_Element_Entry_Id              Regresa Id del elemento generado.
  --             x_Object_Version_Number         Regresa N¿mero de versiÛn del objeto generado.
  --
  PROCEDURE Genera_Elemento
             ( errbuf                          IN OUT VARCHAR2
              ,retcode                         IN OUT NUMBER
              ,p_Business_Group_Id             IN     NUMBER
              ,p_Assignment_Id                 IN     NUMBER
              ,p_Dias                          IN     VARCHAR2
              ,p_Fecha_Elemento                IN     DATE     DEFAULT TRUNC(SYSDATE)
              ,x_Element_Entry_Id                 OUT NUMBER
              ,x_Object_Version_Number            OUT NUMBER
             ) IS
    --
    CURSOR c_Element_Type IS
      SELECT ELEMENT_TYPE_ID
        FROM PAY_ELEMENT_TYPES_F
       WHERE 1 = 1
         AND TRUNC(SYSDATE) BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
         AND ELEMENT_NAME         = 'P037_VACACIONES P';
    --
    CURSOR c_Input_Values IS
      SELECT IVF.INPUT_VALUE_ID
        FROM PAY_ELEMENT_TYPES_F          ETF
            ,PAY_INPUT_VALUES_F           IVF
       WHERE 1 = 1
         AND ETF.ELEMENT_NAME           = 'P037_VACACIONES P'
         AND IVF.ELEMENT_TYPE_ID        = ETF.ELEMENT_TYPE_ID
         AND IVF.DISPLAY_SEQUENCE       = 2;
    --
    v_Element_Type_Id               NUMBER;     
    v_Element_Link_Id               NUMBER;
    v_Input_Value_Id2               NUMBER;
    --
    v_Validate                      BOOLEAN       := FALSE;  
    v_Effective_Date                DATE          := p_Fecha_Elemento;
    v_Entry_Type                    VARCHAR2(1)   := 'E';
    v_Effective_Start_Date          DATE;
    v_Effective_End_Date            DATE;
    v_Create_Warning                BOOLEAN;
    --
  BEGIN
    --
    OPEN c_Element_Type;
    FETCH c_Element_Type INTO v_Element_Type_Id;
    IF c_Element_Type%NOTFOUND THEN
      CLOSE c_Element_Type;
      errbuf  := 'No se encontrÛ el tipo de elemento "P037_VACACIONES P".';
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
    END IF;
    CLOSE c_Element_Type;
    --
    OPEN c_Input_Values;
    FETCH c_Input_Values INTO v_Input_Value_Id2;
    IF c_Input_Values%NOTFOUND THEN
      CLOSE c_Input_Values;
      errbuf  := 'No se encontrÛ el id para la secuencia 2 del tipo de elemento "P037_VACACIONES P".';
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
    END IF;
    CLOSE c_Input_Values;
    --
    v_Element_Link_Id := hr_entry_api.get_link 
                                ( p_assignment_id       => p_Assignment_Id
                                 ,p_element_type_id     => v_Element_Type_Id
                                 ,p_session_date        => v_Effective_Date
                                );
    IF v_Element_Link_Id IS NULL THEN
      errbuf  := 'No se encontrÛ el LINK_ID para el elemento "P037_VACACIONES P".';
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
    END IF;
    --
    PAY_ELEMENT_ENTRY_API.create_element_entry
                 ( p_validate                      => v_Validate
                  ,p_effective_date                => v_Effective_Date
                  ,p_business_group_id             => p_Business_Group_Id
                  ,p_assignment_id                 => p_Assignment_Id
                  ,p_element_link_id               => v_Element_Link_Id
                  ,p_entry_type                    => v_Entry_Type
                  ,p_input_value_id2               => v_Input_Value_Id2
                  ,p_entry_value2                  => p_Dias
                  ,p_effective_start_date          => v_Effective_Start_Date
                  ,p_effective_end_date            => v_Effective_End_Date
                  ,p_element_entry_id              => x_Element_Entry_Id
                  ,p_object_version_number         => x_Object_Version_Number
                  ,p_create_warning                => v_Create_Warning
                 );
    --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Genera_Elemento: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Genera_Elemento;
  --
  -- PROCEDURE Actualiza_Evento
  --
  -- DescripciÛn:  Actualiza los datos de un evento.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --             p_Event_Id:    Id del evento a actualizar.
  --             p_Respuesta_Solicitud:  Respuesta recibida del WF de aprobaciÛn o pantalla.
  --                                    'A' = Aprobado.  'R' = Rechazado.
  --                                    'C' = Cancelado.
  --                                    'V' = Vencido.
  --                                    'P' = Procesado (Costeado).
  --
  PROCEDURE Actualiza_Evento
             ( errbuf                      IN OUT VARCHAR2
              ,retcode                     IN OUT NUMBER
              ,p_Event_Id                  IN     NUMBER
              ,p_Respuesta_Solicitud       IN     VARCHAR2 DEFAULT NULL
             ) IS
    --
    CURSOR c_Eventos (p_Event_Id    IN NUMBER) IS
      SELECT XVE.ROWID  ROW_ID
            ,XVE.*
        FROM XXCALV_VAC_EVENTOS  XVE
       WHERE 1 = 1
         AND XVE.ID_EVENTO = NVL(p_Event_Id, -1);
    --
    CURSOR c_Eventos_Det_Asc ( p_Event_Id    IN NUMBER) IS
        SELECT XED.ROWID   ROW_ID
              ,XED.*
          FROM XXCALV_VAC_EVENTOS_DET      XED
         WHERE 1 = 1
           AND XED.ID_EVENTO       = p_Event_Id
           AND NVL(XED.INCLUIR, 0) = 1
      ORDER BY XED.FECHA;
    --
    CURSOR c_Eventos_Det_Desc ( p_Event_Id    IN NUMBER) IS
        SELECT XED.ROWID   ROW_ID
              ,XED.*
          FROM XXCALV_VAC_EVENTOS_DET      XED
         WHERE 1 = 1
           AND XED.ID_EVENTO       = p_Event_Id
           AND NVL(XED.INCLUIR, 0) = 1
      ORDER BY XED.FECHA DESC;
    --
    CURSOR c_Personas (p_Person_Id   IN NUMBER) IS
      SELECT PP7.BUSINESS_GROUP_ID
        FROM PER_PEOPLE_V7     PP7
       WHERE 1 = 1
         AND PERSON_ID = p_Person_Id;
    --
    CURSOR c_Ausencia (p_Group_Id   IN NUMBER) IS
      SELECT AAT.ABSENCE_ATTENDANCE_TYPE_ID
        FROM PER_ABSENCE_ATTENDANCE_TYPES     AAT
       WHERE 1= 1
         AND AAT.BUSINESS_GROUP_ID   = p_Group_Id
         AND AAT.NAME                = 'VACACIONES';
    --
    CURSOR c_Asignaciones (p_Person_Id     IN NUMBER) IS
      SELECT PA7.ASSIGNMENT_ID
            ,PA7.PAYROLL_ID
        FROM PER_ASSIGNMENTS_V7   PA7
       WHERE 1 = 1
         AND PA7.PERSON_ID                  = p_Person_Id
         AND SYSDATE                  BETWEEN PA7.EFFECTIVE_START_DATE  AND PA7.EFFECTIVE_END_DATE
         AND PA7.PRIMARY_FLAG               = 'Y';
    --
    CURSOR c_Ejecutado (p_Element_Entry_Id   IN NUMBER) IS
      SELECT DISTINCT 'S'
        FROM PAY_RUN_RESULTS
       WHERE 1 = 1
         AND ELEMENT_ENTRY_ID = p_Element_Entry_Id;
    --
    v_xxcalv_vac_evento_loc          c_Eventos%ROWTYPE;
    v_xxcalv_vac_eventos             XXCALV_VAC_EVENTOS%ROWTYPE;
    v_Anio_Antiguedad                XXCALV_VAC_EVENTOS.ANIO_ANTIGUEDAD%TYPE;
    v_Nuevo_Saldo                    NUMBER;
    v_Object_Id                      NUMBER;
    v_Object_Version_Number          NUMBER;
    v_Element_Id                     NUMBER;
    v_Business_Group_Id              NUMBER;
    v_Absence_Attendance_Type_Id     NUMBER;
    v_Assignment_Id                  NUMBER;
    v_Payroll_Id                     NUMBER;
    v_Fecha_Minima_Vac               DATE;
    v_Fecha_Evento                   DATE;
    v_Actualizar_Fecha               VARCHAR2(1);
    --
  BEGIN
    errbuf  := NULL;
    retcode := 0;
    --
    OPEN c_Eventos (p_Event_Id);
    FETCH c_Eventos INTO v_xxcalv_vac_evento_loc;
    IF c_Eventos%NOTFOUND THEN
      errbuf  := 'Error:  Evento ' || p_Event_Id || ' no encontrado';
      retcode := 2;
      CLOSE c_Eventos;
      RETURN;
    END IF;
    CLOSE c_Eventos;
    --
    IF NVL(p_Respuesta_Solicitud, 'XXX') IN ('A', 'R', 'C', 'V', 'P') THEN
      -- Respuesta del WF de aprobaciÛn de vacaciones'A' Û 'R'.  
      -- CancelaciÛn recibido de pantalla 'C'.
      -- Vencimiento de una solicitud 'V'.
      SAVEPOINT RESPUESTA;
      --
      OPEN  c_Personas (v_xxcalv_vac_evento_loc.PERSON_ID);
      FETCH c_Personas INTO v_Business_Group_Id;
      IF c_Personas%NOTFOUND THEN
        errbuf  := 'Error al obtener Business_Group_Id: ' || SQLERRM;
        retcode := 2;
        ROLLBACK TO RESPUESTA;
        CLOSE c_Personas;
        RETURN;
      END IF;
      CLOSE c_Personas;
      --
      OPEN c_Asignaciones (v_xxcalv_vac_evento_loc.PERSON_ID);
      FETCH c_Asignaciones INTO v_Assignment_Id, v_Payroll_Id;
      IF c_Asignaciones%NOTFOUND THEN
        errbuf  := 'Error al obtener AsignaciÛn: ' || SQLERRM;
        retcode := 2;
        ROLLBACK TO RESPUESTA;
        CLOSE c_Asignaciones;
        RETURN;
      END IF;
      CLOSE c_Asignaciones;
      --
      Calcula_Fecha_Minima_Vac
             ( errbuf                      => errbuf
              ,retcode                     => retcode
              ,p_Business_Group_Id         => v_Business_Group_Id
              ,p_Assignment_Id             => v_Assignment_Id
              ,p_Payroll_Id                => v_Payroll_Id
              ,p_Procesar_Fecha_Min        => 'S'
              ,x_Fecha_Minima_Vac          => v_Fecha_Minima_Vac
             );
      IF v_Fecha_Minima_Vac IS NULL OR v_Fecha_Minima_Vac <= TRUNC(SYSDATE) THEN
        v_Fecha_Evento := TRUNC(SYSDATE);
      ELSE
        v_Fecha_Evento := v_Fecha_Minima_Vac;
      END IF;
      --
      IF    p_Respuesta_Solicitud = 'A' THEN               -- Solicitud Aprobada
        v_xxcalv_vac_eventos.ID_TIPO_EVENTO                    := 5;    -- AprobaciÛn
        v_xxcalv_vac_eventos.SALDO_DIAS                        := v_xxcalv_vac_evento_loc.SALDO_DIAS;
        v_xxcalv_vac_eventos.DIAS_EVENTO                       := NULL;
        v_xxcalv_vac_eventos.DIAS_DESPLEGAR                    := NULL;
        --
        --
        OPEN  c_Ausencia (v_Business_Group_Id);
        FETCH c_Ausencia INTO v_Absence_Attendance_Type_Id;
        IF c_Ausencia%NOTFOUND THEN
          errbuf  := 'Error al obtener Absence_Attendance_Type_Id: ' || SQLERRM;
          retcode := 2;
          ROLLBACK TO RESPUESTA;
          CLOSE c_Ausencia;
          RETURN;
        END IF;
        CLOSE c_Ausencia;
        --
      ELSIF p_Respuesta_Solicitud = 'R' THEN                 -- Solicitud Rechazada
        v_xxcalv_vac_eventos.ID_TIPO_EVENTO                    := 6;    -- Rechazo
        v_xxcalv_vac_eventos.SALDO_DIAS                        := v_xxcalv_vac_evento_loc.SALDO_DIAS  + v_xxcalv_vac_evento_loc.DIAS_EVENTO;
        v_xxcalv_vac_eventos.DIAS_EVENTO                       := v_xxcalv_vac_evento_loc.DIAS_EVENTO;
        v_xxcalv_vac_eventos.DIAS_DESPLEGAR                    := v_xxcalv_vac_evento_loc.DIAS_EVENTO;
      ELSIF p_Respuesta_Solicitud = 'C' THEN                 -- Solicitud Cancelada
        v_xxcalv_vac_eventos.ID_TIPO_EVENTO                    := 7;    -- CancelaciÛn
        v_xxcalv_vac_eventos.SALDO_DIAS                        := v_xxcalv_vac_evento_loc.SALDO_DIAS  + v_xxcalv_vac_evento_loc.DIAS_EVENTO;
        v_xxcalv_vac_eventos.DIAS_EVENTO                       := v_xxcalv_vac_evento_loc.DIAS_EVENTO;
        v_xxcalv_vac_eventos.DIAS_DESPLEGAR                    := v_xxcalv_vac_evento_loc.DIAS_EVENTO;
      ELSIF p_Respuesta_Solicitud = 'V' THEN                 -- Vencimiento de Solicitud.
        v_xxcalv_vac_eventos.ID_TIPO_EVENTO                    := 8;    -- Vencimiento
        v_xxcalv_vac_eventos.SALDO_DIAS                        := v_xxcalv_vac_evento_loc.SALDO_DIAS  + v_xxcalv_vac_evento_loc.DIAS_EVENTO;
        v_xxcalv_vac_eventos.DIAS_EVENTO                       := v_xxcalv_vac_evento_loc.DIAS_EVENTO;
        v_xxcalv_vac_eventos.DIAS_DESPLEGAR                    := v_xxcalv_vac_evento_loc.DIAS_EVENTO;
      ELSIF p_Respuesta_Solicitud = 'P' THEN                 --  Vacaciones procesadas.
        IF v_xxcalv_vac_evento_loc.ID_TIPO_EVENTO = 3 THEN
          v_xxcalv_vac_eventos.ID_TIPO_EVENTO                  := 9;    -- Vacaciones disfrutadas
        ELSE
          v_xxcalv_vac_eventos.ID_TIPO_EVENTO                  := 10;   -- Vacaciones pagadas
        END IF;
        v_xxcalv_vac_eventos.SALDO_DIAS                        := v_xxcalv_vac_evento_loc.SALDO_DIAS  + v_xxcalv_vac_evento_loc.DIAS_EVENTO;
        v_xxcalv_vac_eventos.DIAS_EVENTO                       := v_xxcalv_vac_evento_loc.DIAS_EVENTO;
        v_xxcalv_vac_eventos.DIAS_DESPLEGAR                    := v_xxcalv_vac_evento_loc.DIAS_EVENTO;
      END IF;
      --
      v_Anio_Antiguedad                                        := v_xxcalv_vac_evento_loc.ANIO_ANTIGUEDAD;
      --
      v_xxcalv_vac_eventos.ANIO_ANTIGUEDAD                     := v_Anio_Antiguedad;
      v_xxcalv_vac_eventos.PERSON_ID                           := v_xxcalv_vac_evento_loc.PERSON_ID;
      v_xxcalv_vac_eventos.ESTADO_REGISTRO                     := 'F';  -- Finalizado
      v_xxcalv_vac_eventos.ESTADO_CONTROL                      := 'F';  -- Finalizado
      v_xxcalv_vac_eventos.FECHA_ESTADO_CONTROL                := TRUNC(SYSDATE);
      --
      v_xxcalv_vac_eventos.FECHA_DESDE                         := v_Fecha_Evento;
      v_xxcalv_vac_eventos.FECHA_HASTA                         := v_Fecha_Evento;
      v_xxcalv_vac_eventos.FECHA_DESDE_DESPLEGAR               := v_Fecha_Evento;
      v_xxcalv_vac_eventos.FECHA_HASTA_DESPLEGAR               := v_Fecha_Evento;
      v_xxcalv_vac_eventos.ID_EVENTO_PADRE                     := p_Event_Id;
      v_xxcalv_vac_eventos.DESPLEGAR_P1                        := 'N';
      v_xxcalv_vac_eventos.CREATION_DATE                       := SYSDATE;
      v_xxcalv_vac_eventos.CREATED_BY                          := FND_GLOBAL.USER_ID;
      v_xxcalv_vac_eventos.LAST_UPDATE_DATE                    := SYSDATE;
      v_xxcalv_vac_eventos.LAST_UPDATE_BY                      := FND_GLOBAL.USER_ID;
      --
      Inserta_Registro_Historia_Enc
                 ( errbuf                       => errbuf
                  ,retcode                      => retcode
                  ,x_xxcalv_vac_eventos         => v_xxcalv_vac_eventos
                 );
      IF retcode = 2 THEN
        ROLLBACK TO RESPUESTA;
        RETURN;
      END IF;
      --
      v_Actualizar_Fecha := 'N';
      IF v_xxcalv_vac_evento_loc.ID_TIPO_EVENTO  = 4 AND
         p_Respuesta_Solicitud   IN ('A', 'R') THEN
        v_Actualizar_Fecha := 'S';
        v_xxcalv_vac_evento_loc.FECHA_DESDE           := v_Fecha_Evento;
        v_xxcalv_vac_evento_loc.FECHA_HASTA           := v_Fecha_Evento;
        v_xxcalv_vac_evento_loc.FECHA_DESDE_DESPLEGAR := v_Fecha_Evento;
        v_xxcalv_vac_evento_loc.FECHA_HASTA_DESPLEGAR := v_Fecha_Evento;
      END IF;
      --
      BEGIN
        UPDATE XXCALV_VAC_EVENTOS
           SET ESTADO_REGISTRO       = p_Respuesta_Solicitud
              ,ESTADO_CONTROL        = DECODE ( p_Respuesta_Solicitud, 'A', 'A'    --  Si es aprobado, debe esperar a que el elemnto sea 'P'
                                                                          , 'F'
                                              )
              ,FECHA_ESTADO_CONTROL  = TRUNC(SYSDATE)
              ,FECHA_DESDE           = DECODE( v_Actualizar_Fecha, 'S', v_Fecha_Evento, FECHA_DESDE)
              ,FECHA_HASTA           = DECODE( v_Actualizar_Fecha, 'S', v_Fecha_Evento, FECHA_HASTA)
              ,FECHA_DESDE_DESPLEGAR = DECODE( v_Actualizar_Fecha, 'S', v_Fecha_Evento, FECHA_DESDE_DESPLEGAR)
              ,FECHA_HASTA_DESPLEGAR = DECODE( v_Actualizar_Fecha, 'S', v_Fecha_Evento, FECHA_HASTA_DESPLEGAR)
         WHERE ROWID = v_xxcalv_vac_evento_loc.ROW_ID;
      EXCEPTION
        WHEN OTHERS THEN
          errbuf  := 'Error al actualizar Evento ' || p_Event_Id || '. ' || SQLERRM;
          retcode := 2;
          ROLLBACK TO RESPUESTA;
          RETURN;
      END;
      IF SQL%NOTFOUND THEN
        errbuf  := 'Error al actualizar Evento ' || p_Event_Id || '. No se encontrÛ el registro.';
        retcode := 2;
        ROLLBACK TO RESPUESTA;
        RETURN;
      END IF;
      --
      IF p_Respuesta_Solicitud = 'R' THEN
        v_Nuevo_Saldo := Actualiza_Datos_Anio_Base
                           ( errbuf                => errbuf
                            ,retcode               => retcode
                            ,p_Person_Id           => v_xxcalv_vac_eventos.PERSON_ID
                            ,p_Anio_Antiguedad     => v_Anio_Antiguedad
                            ,p_Dias                => v_xxcalv_vac_evento_loc.DIAS_EVENTO
                           );
        --
        IF retcode = 2 THEN
          ROLLBACK TO RESPUESTA;
          RETURN;
        END IF;
      END IF;
      --
      IF p_Respuesta_Solicitud = 'A' THEN
        --
        IF v_xxcalv_vac_evento_loc.ID_TIPO_EVENTO = 3 THEN  -- Solicitud de Vacaciones
          --
          FOR v_Eventos_Det IN c_Eventos_Det_Asc (p_Event_Id) LOOP
          --
            Genera_Ausencia
                   ( errbuf                          => errbuf
                    ,retcode                         => retcode
                    ,p_Person_Id                     => v_xxcalv_vac_evento_loc.PERSON_ID
                    ,p_Business_Group_Id             => v_Business_Group_Id
                    ,p_Absence_Attendance_Type_Id    => v_Absence_Attendance_Type_Id
                    ,p_Date_Start                    => v_Eventos_Det.FECHA
                    ,p_Date_End                      => v_Eventos_Det.FECHA
                    ,p_Absence_Days                  => v_Eventos_Det.MEDIO_DIA
                    ,x_Absence_Attendance_Id         => v_Object_Id
                    ,x_Object_Version_Number         => v_Object_Version_Number
                    ,x_Element_Id                    => v_Element_Id
                   );
            --
            IF retcode = 2 THEN
              ROLLBACK TO RESPUESTA;
              RETURN;
            END IF;
            --
            BEGIN
              --
              UPDATE XXCALV_VAC_EVENTOS_DET
                 SET OBJECT_ID              = v_Object_Id
                    ,OBJECT_VERSION_NUMBER  = v_Object_Version_Number
                    ,OBJECT_ID_1            = v_Element_Id
               WHERE 1 = 1
                 AND ROWID = v_Eventos_Det.ROW_ID;
              --
              IF SQL%ROWCOUNT = 0 THEN
                errbuf  := 'No se pudo actualizar ausencia relacionada.';
                retcode := 2;
                ROLLBACK TO RESPUESTA;
                RETURN;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                errbuf  := 'Error al actualizar ausencia relacionada: ' || SQLERRM;
                retcode := 2;
                ROLLBACK TO RESPUESTA;
                RETURN;
                --
            END;
            --
          END LOOP;
          --
        ELSE  -- Pago de vacaciones
          --
          Genera_Elemento
                 ( errbuf                          => errbuf
                  ,retcode                         => retcode
                  ,p_Business_Group_Id             => v_Business_Group_Id
                  ,p_Assignment_Id                 => v_Assignment_Id
                  ,p_Dias                          => v_xxcalv_vac_evento_loc.DIAS_EVENTO
                  ,p_Fecha_Elemento                => v_xxcalv_vac_evento_loc.FECHA_DESDE
                  ,x_Element_Entry_Id              => v_Object_Id
                  ,x_Object_Version_Number         => v_Object_Version_Number
                 );
          --
          IF retcode = 2 THEN
            ROLLBACK TO RESPUESTA;
            RETURN;
          END IF;
          --
          BEGIN
            --
            UPDATE XXCALV_VAC_EVENTOS
               SET OBJECT_ID              = v_Object_Id
                  ,OBJECT_VERSION_NUMBER  = v_Object_Version_Number
             WHERE 1 = 1
               AND ID_EVENTO = v_xxcalv_vac_evento_loc.ID_EVENTO;
            --
            IF SQL%ROWCOUNT = 0 THEN
              errbuf  := 'No se pudo actualizar pago relacionado.';
              retcode := 2;
              ROLLBACK TO RESPUESTA;
              RETURN;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              errbuf  := 'Error al actualizar pago relacionado: ' || SQLERRM;
              retcode := 2;
              ROLLBACK TO RESPUESTA;
              RETURN;
              --
          END;
          --
        END IF;
        --
      ELSIF p_Respuesta_Solicitud = 'C' THEN
        --
        IF v_xxcalv_vac_evento_loc.ID_TIPO_EVENTO = 3 THEN  -- Solicitud de Vacaciones
          --
          FOR v_Eventos_Det IN c_Eventos_Det_Desc (p_Event_Id) LOOP
            --
            IF v_Eventos_Det.OBJECT_ID IS NOT NULL THEN  -- Solo se eliminan los elementos si ya fueron creados
              --
              FOR v_Ejecutado IN c_Ejecutado (v_Eventos_Det.OBJECT_ID_1) LOOP
                --
                errbuf  := 'No se puede cancelar una solicitud que ya fue procesada en pago.';
                retcode := 2;
                ROLLBACK TO RESPUESTA;
                RETURN;
                --
              END LOOP;
              --
              Elimina_Ausencia
                   ( errbuf                          => errbuf
                    ,retcode                         => retcode
                    ,p_Absence_Attendance_Id         => v_Eventos_Det.OBJECT_ID
                    ,p_Object_Version_Number         => v_Eventos_Det.OBJECT_VERSION_NUMBER
                   );
              --
              IF retcode = 2 THEN
                ROLLBACK TO RESPUESTA;
                RETURN;
              END IF;
              --
            END IF;
            --
            BEGIN
              --
              UPDATE XXCALV_VAC_EVENTOS_DET
                 SET CANCELADO              = 'S'
               WHERE 1 = 1
                 AND ROWID = v_Eventos_Det.ROW_ID;
              --
              IF SQL%ROWCOUNT = 0 THEN
                errbuf  := 'No se pudo eliminar ausencia/pago relacionado.';
                retcode := 2;
                ROLLBACK TO RESPUESTA;
                RETURN;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                errbuf  := 'Error al actualizar ausencia/pago relacionado: ' || SQLERRM;
                retcode := 2;
                ROLLBACK TO RESPUESTA;
                RETURN;
                --
            END;
            --
          END LOOP;
          --
        ELSE  -- Pago de vacaciones
          --
          IF v_xxcalv_vac_evento_loc.OBJECT_ID IS NOT NULL THEN  -- Solo se eliminan los elementos si ya fueron creados
            --
            FOR v_Ejecutado IN c_Ejecutado (v_xxcalv_vac_evento_loc.OBJECT_ID) LOOP
              --
              errbuf  := 'No se puede cancelar una solicitud que ya fue procesada en pago.';
              retcode := 2;
              ROLLBACK TO RESPUESTA;
              RETURN;
              --
            END LOOP;
            --
            Elimina_Elemento
               ( errbuf                          => errbuf
                ,retcode                         => retcode
                ,p_Element_Entry_Id              => v_xxcalv_vac_evento_loc.OBJECT_ID
                ,p_Object_Version_Number         => v_xxcalv_vac_evento_loc.OBJECT_VERSION_NUMBER
                ,p_Effective_Date                => v_xxcalv_vac_evento_loc.FECHA_DESDE
               );
            --
            IF retcode = 2 THEN
              ROLLBACK TO RESPUESTA;
              RETURN;
            END IF;
            --
            END IF;
            --
        END IF;
      ELSIF p_Respuesta_Solicitud = 'V' THEN
        --
        v_Nuevo_Saldo := Actualiza_Datos_Anio_Base
                             ( errbuf                => errbuf
                              ,retcode               => retcode
                              ,p_Person_Id           => v_xxcalv_vac_evento_loc.PERSON_ID
                              ,p_Anio_Antiguedad     => v_xxcalv_vac_evento_loc.ANIO_ANTIGUEDAD
                              ,p_Dias                => v_xxcalv_vac_evento_loc.DIAS_EVENTO
                             );
        --
        IF retcode = 2 THEN
          ROLLBACK TO RESPUESTA;
          RETURN;
        END IF;
        --
        BEGIN
          wf_engine.AbortProcess
              ( itemtype   => 'CALVAPPV'
               ,itemkey    => 'CALVAPPV_' || TRIM(TO_CHAR(v_xxcalv_vac_evento_loc.ID_EVENTO))
               ,process    => 'APPVAC_MAIN'
               ,result     => '#FORCE'
              );
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        --
      END IF;
      --
      IF p_Respuesta_Solicitud IN ('R', 'C', 'V') THEN      
        Reconstruye_Saldos
             ( errbuf                => errbuf
              ,retcode               => retcode
              ,p_Person_Id           => v_xxcalv_vac_evento_loc.PERSON_ID
              ,p_Anio_Antiguedad     => v_xxcalv_vac_evento_loc.ANIO_ANTIGUEDAD
              ,p_Commit              => 'FALSE'
             );
        --
        IF retcode = 2 THEN
          ROLLBACK TO RESPUESTA;
          RETURN;
        END IF;
        --
      END IF;      
      --
      COMMIT;
      --
    ELSE
      -- 
      errbuf  := 'Error:  Evento ' || p_Event_Id || ' no controlado.';
      retcode := 2;
      ROLLBACK TO RESPUESTA;
      RETURN;
      --
    END IF;
    --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Actualiza_Evento: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Actualiza_Evento;
  --
  -- PROCEDURE Actualiza_Evento_WF
  --
  -- DescripciÛn:  Actualiza los datos de un evento, proveniente del Work Flow, inicializando valores de sesiÛn.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --             p_Event_Id:    Id del evento a actualizar.
  --             p_Respuesta_Solicitud:  Respuesta recibida del WF de aprobaciÛn o pantalla.
  --                                    'A' = Aprobado.  'R' = Rechazado.  'C' = Cancelado.  
  --
  PROCEDURE Actualiza_Evento_WF
             ( errbuf                      IN OUT VARCHAR2
              ,retcode                     IN OUT NUMBER
              ,p_Event_Id                  IN     NUMBER
              ,p_Respuesta_Solicitud       IN     VARCHAR2 DEFAULT NULL
             ) IS
  BEGIN
    --
    g_User_Id            := FND_GLOBAL.USER_ID;
    g_Responsibility_Id  := FND_GLOBAL.RESP_ID;
    g_Resp_Appl_Id       := 800;                   -- Human Resources
    --
    BEGIN
      SELECT RESPONSIBILITY_ID
        INTO g_Responsibility_Id
        FROM FND_RESPONSIBILITY
       WHERE 1 = 1
         AND APPLICATION_ID     = g_Resp_Appl_Id 
         AND RESPONSIBILITY_KEY = 'MX_HRMS_MANAGER';
    EXCEPTION
      WHEN OTHERS THEN
        errbuf  := 'Error al localizar respondsabilidad MX_HRMS_MANAGER: ' || SQLERRM;
        XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
        retcode := 2;
        RETURN;
    END;
    --
    fnd_global.apps_initialize
                ( user_id         => g_User_Id
                 ,resp_id         => g_Responsibility_Id
                 ,resp_appl_id    => g_Resp_Appl_Id
                );
    --
    Actualiza_Evento
           ( errbuf                      => errbuf
            ,retcode                     => retcode
            ,p_Event_Id                  => p_Event_Id
            ,p_Respuesta_Solicitud       => p_Respuesta_Solicitud
           );
    --
    IF retcode = 2 THEN
      RETURN;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Actualiza_Evento_WF: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Actualiza_Evento_WF;
  --
  -- PROCEDURE Cancela_Saldo_Anio
  --
  -- DescripciÛn:  Genera los movimientos cuando el saldo en dÌas por disfrutar delÒ periodo vencido es > 0.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --             p_Person_Id          : Id de la persona a la cual cancelar el saldo
  --             p_Anio_Antiguedad    : Anio de antiguedad en el cual se cancelar· el saldo.
  --
  PROCEDURE Cancela_Saldo_Anio
             ( errbuf                          IN OUT VARCHAR2
              ,retcode                         IN OUT NUMBER
              ,p_Person_Id           IN     NUMBER
              ,p_Anio_Antiguedad     IN     NUMBER
             ) IS
    --
    CURSOR c_Eventos ( p_Person_Id    IN NUMBER
                      ,p_Anio         IN NUMBER
                     ) IS
      SELECT XVE.ROWID  ROW_ID
            ,XVE.*
        FROM XXCALV_VAC_EVENTOS  XVE
       WHERE 1 = 1
         AND XVE.PERSON_ID        = p_Person_Id
         AND XVE.ANIO_ANTIGUEDAD  = p_Anio
         AND XVE.ID_TIPO_EVENTO   = 1
         AND XVE.SALDO_DIAS       > 0;
    --
    v_Reg_Eventos                    c_Eventos%ROWTYPE;
    v_xxcalv_vac_eventos             XXCALV_VAC_EVENTOS%ROWTYPE;
    v_Nuevo_Saldo                    NUMBER;
    --
  BEGIN
    --
    OPEN c_Eventos (p_Person_Id, p_Anio_Antiguedad);
    FETCH c_Eventos INTO v_Reg_Eventos;
    IF c_Eventos%NOTFOUND THEN
      CLOSE c_Eventos;
      errbuf  := 'No se encontrÛ el registro de saldo para la antiguedad: ' || p_Anio_Antiguedad;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
    END IF;
    CLOSE c_Eventos;
    --
    SAVEPOINT PERDIDAS;
    v_xxcalv_vac_eventos.ID_TIPO_EVENTO                      := 11;    -- Vacaciones perdidas.
    v_xxcalv_vac_eventos.PERSON_ID                           := v_Reg_Eventos.PERSON_ID;
    v_xxcalv_vac_eventos.ESTADO_REGISTRO                     := 'F';  -- Finalizado
    v_xxcalv_vac_eventos.ESTADO_CONTROL                      := 'F';  -- Finalizado
    v_xxcalv_vac_eventos.FECHA_ESTADO_CONTROL                := TRUNC(SYSDATE);
    v_xxcalv_vac_eventos.ANIO_ANTIGUEDAD                     := v_Reg_Eventos.ANIO_ANTIGUEDAD;
    v_xxcalv_vac_eventos.DIAS_EVENTO                         := v_Reg_Eventos.SALDO_DIAS;
    v_xxcalv_vac_eventos.DIAS_DESPLEGAR                      := v_Reg_Eventos.SALDO_DIAS;
    v_xxcalv_vac_eventos.SALDO_DIAS                          := 0;
    v_xxcalv_vac_eventos.FECHA_DESDE                         := v_Reg_Eventos.FECHA_DESDE;
    v_xxcalv_vac_eventos.FECHA_HASTA                         := v_Reg_Eventos.FECHA_HASTA;
    v_xxcalv_vac_eventos.FECHA_DESDE_DESPLEGAR               := NULL;
    v_xxcalv_vac_eventos.FECHA_HASTA_DESPLEGAR               := NULL;
    v_xxcalv_vac_eventos.ID_EVENTO_PADRE                     := NULL;
    v_xxcalv_vac_eventos.DESPLEGAR_P1                        := 'S';
    v_xxcalv_vac_eventos.CREATION_DATE                       := SYSDATE;
    v_xxcalv_vac_eventos.CREATED_BY                          := FND_GLOBAL.USER_ID;
    v_xxcalv_vac_eventos.LAST_UPDATE_DATE                    := SYSDATE;
    v_xxcalv_vac_eventos.LAST_UPDATE_BY                      := FND_GLOBAL.USER_ID;
    --
    Inserta_Registro_Historia_Enc
               ( errbuf                       => errbuf
                ,retcode                      => retcode
                ,x_xxcalv_vac_eventos         => v_xxcalv_vac_eventos
               );
    IF retcode = 2 THEN
      ROLLBACK TO PERDIDAS;
      RETURN;
    END IF;
    --
    v_Nuevo_Saldo := Actualiza_Datos_Anio_Base
                       ( errbuf                => errbuf
                        ,retcode               => retcode
                        ,p_Person_Id           => v_xxcalv_vac_eventos.PERSON_ID
                        ,p_Anio_Antiguedad     => v_Reg_Eventos.ANIO_ANTIGUEDAD
                        ,p_Dias                => -v_Reg_Eventos.SALDO_DIAS
                       );
    --
    IF retcode = 2 THEN
      ROLLBACK TO PERDIDAS;
      RETURN;
    END IF;
    --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Cancela_Saldo_Anio: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Cancela_Saldo_Anio;
  --
  -- PROCEDURE Actualiza_Fecha_Control
  --
  -- DescripciÛn:  Actualiza los registros a desplegar en la pantalla de captura de vacaciones.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --             p_person_id:  Id de la persona para la cual actualizar los registros;  si es nulo, evalua todos.
  --
  PROCEDURE Actualiza_Desplegar_P1
             ( errbuf                IN OUT VARCHAR2
              ,retcode               IN OUT NUMBER
              ,p_person_id           IN     NUMBER
             ) IS
    --
  BEGIN
    --
    BEGIN
      UPDATE XXCALV_VAC_EVENTOS       XVE
         SET ESTADO_CONTROL        = 'F'
            ,FECHA_ESTADO_CONTROL  = TRUNC(SYSDATE)
       WHERE 1 = 1
         AND XVE.ESTADO_CONTROL            = 'P'
         AND XVE.PERSON_ID                 = NVL(p_Person_Id, XVE.PERSON_ID)
         AND XVE.DESPLEGAR_P1              = 'S';

    EXCEPTION
      WHEN OTHERS THEN
        errbuf  := 'Error al actualizar registros procesados: ' || SQLERRM;
        XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
        retcode := 2;
        RETURN;
    END;
    --
    BEGIN
      UPDATE XXCALV_VAC_EVENTOS       XVE
         SET XVE.ESTADO_CONTROL        = 'F'
            ,XVE.FECHA_ESTADO_CONTROL  = TRUNC(SYSDATE)
       WHERE 1 = 1
         AND XVE.ESTADO_CONTROL            = 'I'
         AND XVE.PERSON_ID                 = NVL(p_Person_Id, XVE.PERSON_ID)
         AND XVE.FECHA_HASTA               < TRUNC(SYSDATE)
         AND XVE.DESPLEGAR_P1              = 'S';
    EXCEPTION
      WHEN OTHERS THEN
        errbuf  := 'Error al actualizar registros informativos: ' || SQLERRM;
        XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
        retcode := 2;
        RETURN;
    END;
    --
    BEGIN
      UPDATE XXCALV_VAC_EVENTOS       XVE
         SET XVE.DESPLEGAR_P1          = 'N'
       WHERE 1 = 1
         AND XVE.ESTADO_CONTROL            = 'F'
         AND XVE.PERSON_ID                 = NVL(p_Person_Id, XVE.PERSON_ID)
         AND XVE.DESPLEGAR_P1              = 'S'
         AND TRUNC(SYSDATE)                > XVE.FECHA_ESTADO_CONTROL + g_Dias_Max_Vacaciones;

    EXCEPTION
      WHEN OTHERS THEN
        errbuf  := 'Error al actualizar registros a no desplegar: ' || SQLERRM;
        XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
        retcode := 2;
        RETURN;
    END;
    --
    BEGIN
      UPDATE XXCALV_VAC_EVENTOS       XVE
         SET XVE.DESPLEGAR_P1          = 'S'
       WHERE 1 = 1
         AND XVE.ESTADO_CONTROL            = 'I'
         AND XVE.PERSON_ID                 = NVL(p_Person_Id, XVE.PERSON_ID)
         AND XVE.DESPLEGAR_P1              = 'N'
         AND TRUNC(SYSDATE)               >= XVE.FECHA_DESDE;

    EXCEPTION
      WHEN OTHERS THEN
        errbuf  := 'Error al actualizar registros a desplegar: ' || SQLERRM;
        XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
        retcode := 2;
        RETURN;
    END;
    --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Actualiza_Desplegar_P1: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Actualiza_Desplegar_P1;
  --
  -- PROCEDURE Carga_Archivo_Saldos
  --
  -- DescripciÛn:  Carga el archivo de saldos de vacaciones ya procesadas a la tabla del histÛrico.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --             p_Id_Ruta:         Nombre de identificador en ALL_TABLES que contiene la ruta de carga del archivo.
  --             p_Nombre_Archivo:  Nombre del archivo con los datos a cargar.
  --
  PROCEDURE Carga_Archivo_Saldos
             ( errbuf                   OUT VARCHAR2
              ,retcode                  OUT NUMBER
              ,p_Id_Ruta             IN     VARCHAR2   
              ,p_Nombre_Archivo      IN     VARCHAR2
             ) IS
    --
    CURSOR c_Carga IS
      SELECT *
        FROM XXCALV_VAC_SALDOS_INI
       WHERE 1 = 1;
    --
    CURSOR c_Personas (p_Emp_Number   IN VARCHAR2) IS
        SELECT DAT.*
          FROM (
                SELECT PP7.EMPLOYEE_NUMBER
                      ,PP7.PERSON_ID
                      ,PP7.BUSINESS_GROUP_ID
                      ,NVL(PP7.ATTRIBUTE28, 'N')        REQUIERE_APROBACION
                      ,PP7.ATTRIBUTE29                  FECHA_CONTROL_VACACIONES
                      --,TRUNC(MONTHS_BETWEEN(SYSDATE, PP7.HIRE_DATE)/12)
                      ,TRUNC(MONTHS_BETWEEN(SYSDATE, get_Hire_Date(PP7.PERSON_ID))/12)
                                                        ANIO_ANTIGUEDAD
                  FROM PER_PEOPLE_V7     PP7
                 WHERE 1 = 1
                   AND PP7.EFFECTIVE_START_DATE      <= TRUNC(SYSDATE)
                   AND PP7.SYSTEM_PERSON_TYPE        IN ('EMP')
                   AND PP7.EMPLOYEE_NUMBER            = NVL(p_Emp_Number, PP7.EMPLOYEE_NUMBER)
               ) DAT
      ORDER BY DAT.EMPLOYEE_NUMBER;
    --
    CURSOR c_Historia ( p_Person_Id            IN NUMBER
                       ) IS
      SELECT *
        FROM XXCALV_VAC_EVENTOS
       WHERE 1 = 1
         AND PERSON_ID       = p_Person_Id
         AND ID_TIPO_EVENTO  = 1
     ORDER BY ANIO_ANTIGUEDAD;
    --
    v_Ruta_Base                      VARCHAR2(2000);
    v_xxcalv_vac_eventos             XXCALV_VAC_EVENTOS%ROWTYPE;
    v_Procesar                       VARCHAR2(1);
    v_errbuf                         VARCHAR2(2000);
    v_retcode                        NUMBER;
    v_Personas                       c_Personas%ROWTYPE;
    v_Num_Registro                   NUMBER;
    v_Primer_Anio                    NUMBER;
    v_Saldo_Actual                   NUMBER;
    v_Nuevo_Saldo                    NUMBER;
    --
  BEGIN
    --
    Inicializar_Valores
             ( errbuf
              ,retcode
             );
    IF retcode = 2 THEN
      RETURN;
    END IF;
    --
    XXSTO_TOOLS_PKG.Genera_Salida('****    Parametros Recibido    ****', 'B');
    XXSTO_TOOLS_PKG.Genera_Salida('Pv_Id_Ruta: ' || p_Id_Ruta, 'B');
    XXSTO_TOOLS_PKG.Genera_Salida('Pv_Nombre_Archivo: ' || p_Nombre_Archivo, 'B');
    XXSTO_TOOLS_PKG.Genera_Salida('***********************************', 'B');
    --
    BEGIN
      SELECT DIRECTORY_PATH
        INTO v_Ruta_Base
        FROM ALL_DIRECTORIES
       WHERE DIRECTORY_NAME = p_Id_Ruta;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        XXSTO_TOOLS_PKG.Genera_Salida('Error!!! El directorio de trabajo no esta definido: ' || p_Id_Ruta, 'L');
        retcode := 2;
        RETURN;
      WHEN OTHERS THEN
        XXSTO_TOOLS_PKG.Genera_Salida('Error  al cargar el directorio de trabajo: ' || p_Id_Ruta || ': ' || SQLERRM, 'L');
        retcode := 2;
        RETURN;
    END;
    --
    XXSTO_TOOLS_PKG.Genera_Salida('Ruta Base de Lectura y Escritura : ' || v_Ruta_Base, 'B');
    XXSTO_TOOLS_PKG.Genera_Salida('Archivo a Procesar : ' || v_Ruta_Base || '/' || p_Nombre_Archivo, 'B');
    --
    XXSTO_TOOLS_PKG.Carga_Archivo
                             ( p_Control            => ','
                              ,p_Ruta               => p_Id_Ruta
                              ,p_Archivo            => p_Nombre_Archivo
                              ,p_Esquema            => 'APPS'
                              ,p_Tabla              => 'XXCALV_VAC_SALDOS_INI'
                              ,x_Msg_Error          => errbuf
                              ,p_Log_Activado       => TRUE
                              ,p_Commit             => 'T'
                              ,p_Cadena_Previa      => NULL
                              ,p_Formato_Entrada    => 'UTF8'
                              ,p_Formato_Salida     => 'WE8ISO8859P1'
                             );
    --
    IF errbuf IS NOT NULL THEN
      XXSTO_TOOLS_PKG.Genera_Salida('Error al cargar archivo: ' || p_Nombre_Archivo, 'B');
      XXSTO_TOOLS_PKG.Genera_Salida('                         ' || errbuf, 'B');
      retcode := 2;
      RETURN;
    END IF;
    --
    XXSTO_TOOLS_PKG.Genera_Salida('***   Procesamiento de datos cargados  **', 'B');
    FOR v_Carga IN c_Carga LOOP
      --
      v_retcode  := 0;
      v_errbuf   := NULL;
      SAVEPOINT EMPLEADO;
      XXSTO_TOOLS_PKG.Genera_Salida('N¿mero Empleado: ' || v_Carga.EMPLOYEE_NUMBER || '.  DÌas: ' || v_Carga.NUM_DIAS, 'B');
      v_Procesar := 'S';
      --
      OPEN c_Personas (v_Carga.EMPLOYEE_NUMBER);
      FETCH c_Personas INTO v_Personas;
      IF c_Personas%NOTFOUND THEN
        v_errbuf := '  Empleado  no existe o no activo.';
        XXSTO_TOOLS_PKG.Genera_Salida(v_errbuf, 'B');
        v_Procesar := 'N';
        v_retcode  := 2;
      END IF;
      CLOSE c_Personas;
      --
      IF v_Procesar = 'S' THEN
        --
        BEGIN
          SELECT COUNT (*)
            INTO v_Num_Registro
            FROM XXCALV_VAC_EVENTOS
           WHERE 1 = 1
             AND PERSON_ID       = v_Personas.PERSON_ID;
          --
          IF v_Num_Registro <> 2 THEN
            --
            v_errbuf := '  Para cargar saldos del empleado, deben existir exactamente dos registros informativos de saldo actual.  Registros totales existentes: ' || v_Num_Registro;
            XXSTO_TOOLS_PKG.Genera_Salida(v_errbuf, 'B');
            v_Procesar := 'N';
            v_retcode  := 2;
            --
          END IF;
          --
        EXCEPTION
          WHEN OTHERS THEN
            v_errbuf := '  Error en conteo de registros: ' || SQLERRM;
            XXSTO_TOOLS_PKG.Genera_Salida(v_errbuf, 'B');
            v_Procesar := 'N';
            v_retcode  := 2;
        END;
        --
        IF v_Procesar = 'S' THEN
          v_Num_Registro := 0;
          FOR v_Historia IN c_Historia (v_Personas.PERSON_ID) LOOP
            --
            v_Num_Registro := v_Num_Registro + 1;
            --
            IF v_Num_Registro = 1 THEN
              v_Primer_Anio  := v_Historia.ANIO_ANTIGUEDAD;
              v_Saldo_Actual := v_Historia.SALDO_DIAS;
              IF v_Historia.ANIO_ANTIGUEDAD <> v_Personas.ANIO_ANTIGUEDAD THEN
                v_errbuf := '  El aÒo de antig¸edad actual del empleado (' || v_Personas.ANIO_ANTIGUEDAD ||
                            ') no coincide con el primer registro de la historia (' || v_Historia.ANIO_ANTIGUEDAD || ').';
                XXSTO_TOOLS_PKG.Genera_Salida(v_errbuf, 'B');
                v_Procesar := 'N';
                v_retcode  := 2;
              END IF;
              --
              IF v_Procesar = 'S' AND v_Carga.NUM_DIAS > v_Saldo_Actual THEN
                v_errbuf := '  El n¿mero de dias devengados (' || v_Carga.NUM_DIAS ||
                            ') es mayor que el saldo actual (' || v_Saldo_Actual || ').';
                XXSTO_TOOLS_PKG.Genera_Salida(v_errbuf, 'B');
                v_Procesar := 'N';
                v_retcode  := 2;
              END IF; 
              --
            ELSIF v_Num_Registro = 2 THEN
              --
              IF v_Historia.ANIO_ANTIGUEDAD <> v_Primer_Anio + 1 THEN
                v_errbuf := '  El aÒo de antig¸edad siguiente del empleado (' || v_Personas.ANIO_ANTIGUEDAD ||
                            ') es incorrecto respecto al actual (' || v_Primer_Anio || ').';
                XXSTO_TOOLS_PKG.Genera_Salida(v_errbuf, 'B');
                v_Procesar := 'N';
                v_retcode  := 2;
              END IF;
              --
            END IF;
            --
          END LOOP;
          --
        END IF;
        --
      END IF;
      --
      IF v_Procesar = 'S' THEN
        v_xxcalv_vac_eventos.ID_TIPO_EVENTO                := 2;
        v_xxcalv_vac_eventos.PERSON_ID                     := v_Personas.PERSON_ID;
        v_xxcalv_vac_eventos.ESTADO_REGISTRO               := 'I';
        v_xxcalv_vac_eventos.ESTADO_CONTROL                := 'F';
        v_xxcalv_vac_eventos.FECHA_ESTADO_CONTROL          := TRUNC(SYSDATE);
        v_xxcalv_vac_eventos.ANIO_ANTIGUEDAD               := v_Personas.ANIO_ANTIGUEDAD;
        v_xxcalv_vac_eventos.DIAS_EVENTO                   := v_Carga.NUM_DIAS;
        v_xxcalv_vac_eventos.DIAS_DESPLEGAR                := v_Carga.NUM_DIAS;
        v_xxcalv_vac_eventos.SALDO_DIAS                    := v_Saldo_Actual - v_Carga.NUM_DIAS;
        v_xxcalv_vac_eventos.FECHA_DESDE                   := TRUNC(SYSDATE);
        v_xxcalv_vac_eventos.FECHA_HASTA                   := TRUNC(SYSDATE);
        v_xxcalv_vac_eventos.FECHA_DESDE_DESPLEGAR         := NULL;
        v_xxcalv_vac_eventos.FECHA_HASTA_DESPLEGAR         := NULL; 
        v_xxcalv_vac_eventos.DESPLEGAR_P1                  := 'S';
        v_xxcalv_vac_eventos.CREATION_DATE                 := TRUNC(SYSDATE);
        v_xxcalv_vac_eventos.CREATED_BY                    := g_User_Id;
        v_xxcalv_vac_eventos.LAST_UPDATE_DATE              := TRUNC(SYSDATE);
        v_xxcalv_vac_eventos.LAST_UPDATE_BY                := g_User_Id;
        --
        Inserta_Registro_Historia_Enc
                   ( errbuf                       => v_errbuf
                    ,retcode                      => v_retcode
                    ,x_xxcalv_vac_eventos         => v_xxcalv_vac_eventos
                   );
        --
        IF v_retcode = 2 THEN
          NULL;
        ELSE
          v_Nuevo_Saldo := Actualiza_Datos_Anio_Base
                             ( errbuf                => v_errbuf
                              ,retcode               => v_retcode
                              ,p_Person_Id           => v_Personas.PERSON_ID
                              ,p_Anio_Antiguedad     => v_Personas.ANIO_ANTIGUEDAD
                              ,p_Dias                => -v_Carga.NUM_DIAS
                             );
          --
          IF v_retcode = 2 THEN
            v_Procesar := 'N';
            v_retcode  := 2;
          END IF;
        END IF;
        --
      END IF;
      --
      IF v_retcode <> 2 THEN
        COMMIT;
      ELSE
        ROLLBACK TO EMPLEADO;
      END IF;
    END LOOP;
    --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Carga_Archivo_Saldos: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Carga_Archivo_Saldos;
  --
  -- PROCEDURE Verifica_Cambios_Estado
  --
  -- DescripciÛn:  Valida los registros que deben de cambiar de estado, basado en la fecha de proceso.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --             p_person_id:  Id de la persona para la cual revisar los estados;  si es nulo, evalua todos.
  --
  PROCEDURE Verifica_Cambios_Estado
             ( errbuf                   OUT VARCHAR2
              ,retcode                  OUT NUMBER
              ,p_person_id           IN     NUMBER
             ) IS
    --
    CURSOR c_Vencidos IS
        SELECT PP7.ROW_ID
              ,XVE.*
          FROM XXCALV_VAC_EVENTOS       XVE
              ,PER_PEOPLE_V7            PP7
         WHERE 1 = 1
           AND XVE.PERSON_ID         = NVL(p_Person_Id, XVE.PERSON_ID)
           AND XVE.ESTADO_REGISTRO   = 'S'
           AND XVE.FECHA_DESDE       < TRUNC(SYSDATE)
           AND PP7.PERSON_ID         = XVE.PERSON_ID;
    --
    CURSOR c_Costeados IS
        SELECT DISTINCT
               OBJ.ID_EVENTO
              ,OBJ.ROW_ID
          FROM PAY_RUN_RESULTS          PRR
              ,(
                SELECT NVL(XVE.OBJECT_ID, XVD.OBJECT_ID_1)     OBJECT_ID
                      ,XVE.ID_EVENTO
                      ,PP7.ROW_ID
                  FROM XXCALV_VAC_EVENTOS       XVE
                      ,XXCALV_VAC_EVENTOS_DET   XVD
                      ,PER_PEOPLE_V7            PP7
                 WHERE 1 = 1
                   AND XVE.ID_TIPO_EVENTO        IN (3, 4)
                   AND XVE.ESTADO_REGISTRO        = 'A'
                   AND XVD.ID_EVENTO(+)           = XVE.ID_EVENTO
                   AND NVL(XVD.INCLUIR(+), 0)     = 1
                   AND PP7.PERSON_ID              = XVE.PERSON_ID
               )                        OBJ
              ,PAY_COSTS                PCO
         WHERE 1 = 1
           AND PRR.ELEMENT_ENTRY_ID  = OBJ.OBJECT_ID
           AND PCO.RUN_RESULT_ID     = PRR.RUN_RESULT_ID
      ORDER BY OBJ.ID_EVENTO;
    --
    v_errbuf                  VARCHAR2(2000);
    v_retcode                 NUMBER;
    v_Total_Ven_Procesados    NUMBER;
    v_Total_Ven_Grabados      NUMBER;
    v_Total_Ven_Errores       NUMBER;
    v_Total_Cos_Procesados    NUMBER;
    v_Total_Cos_Grabados      NUMBER;
    v_Total_Cos_Errores       NUMBER;
    --
  BEGIN
    --
    errbuf                  := NULL;
    retcode                 := 0;
    v_Total_Ven_Procesados  := 0;
    v_Total_Ven_Grabados    := 0;
    v_Total_Ven_Errores     := 0;
    --
    FOR v_Vencidos IN c_Vencidos LOOP
      --
      v_Total_Ven_Procesados  := v_Total_Ven_Procesados + 1;
      v_errbuf                := NULL;
      v_retcode               := 0;
      SAVEPOINT VENCIDO;
      --
      Actualiza_Evento
             ( errbuf                      => v_errbuf
              ,retcode                     => v_retcode
              ,p_Event_Id                  => v_Vencidos.ID_EVENTO
              ,p_Respuesta_Solicitud       => 'V'     -- Vencimiento
             );
      --
      IF v_retcode = 2 THEN
        --
        XXSTO_TOOLS_PKG.genera_salida(v_errbuf, 'E');
        IF retcode < 1 THEN
          errbuf  := SUBSTR(errbuf || v_errbuf, 1, 2000);
          retcode := 1;
        END IF;
        --
        ROLLBACK TO VENCIDO;
        v_Total_Ven_Errores := v_Total_Ven_Errores + 1;
        --
      ELSE
        --
        Actualiza_Fecha_Control
             ( errbuf                => v_errbuf
              ,retcode               => v_retcode
              ,p_Row_Id              => v_Vencidos.ROW_ID
             );
        COMMIT;
        v_Total_Ven_Grabados := v_Total_Ven_Grabados + 1;
        --
      END IF;
      --
    END LOOP;
    --
    v_Total_Cos_Procesados  := 0;
    v_Total_Cos_Grabados    := 0;
    v_Total_Cos_Errores     := 0;
    --
    FOR v_Costeados IN c_Costeados LOOP
      --
      v_Total_Cos_Procesados  := v_Total_Cos_Procesados + 1;
      v_errbuf                := NULL;
      v_retcode               := 0;
      SAVEPOINT COSTEADO;
      --
      Actualiza_Evento
             ( errbuf                      => v_errbuf
              ,retcode                     => v_retcode
              ,p_Event_Id                  => v_Costeados.ID_EVENTO
              ,p_Respuesta_Solicitud       => 'P'     -- Procesado
             );
      --
      IF v_retcode = 2 THEN
        --
        XXSTO_TOOLS_PKG.genera_salida(v_errbuf, 'E');
        IF retcode < 1 THEN
          errbuf  := SUBSTR(errbuf || v_errbuf, 1, 2000);
          retcode := 1;
        END IF;
        --
        ROLLBACK TO COSTEADO;
        v_Total_Cos_Errores := v_Total_Cos_Errores + 1;
        --
      ELSE
        --
        Actualiza_Fecha_Control
             ( errbuf                => v_errbuf
              ,retcode               => v_retcode
              ,p_Row_Id              => v_Costeados.ROW_ID
             );
        COMMIT;
        v_Total_Cos_Grabados := v_Total_Cos_Grabados + 1;
        --
      END IF;
      --
    END LOOP;
    --
    XXSTO_TOOLS_PKG.genera_salida('***********************************************', 'B');
    XXSTO_TOOLS_PKG.genera_salida('Total Costeados Procesados : ' || v_Total_Cos_Procesados, 'B');
    XXSTO_TOOLS_PKG.genera_salida('Total Costeados Grabados   : ' || v_Total_Cos_Grabados, 'B');
    XXSTO_TOOLS_PKG.genera_salida('Total Costeados Errores    : ' || v_Total_Cos_Errores, 'B');
    XXSTO_TOOLS_PKG.genera_salida('***********************************************', 'B');
    --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Verifica_Cambios_Estado: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Verifica_Cambios_Estado;
  --
  -- PROCEDURE Verifica_Cambios_Fecha
  --
  -- DescripciÛn:  Valida los movimientos que haya tenido un empelado desde la ¿ltima actualizaciÛn del registro.
  --               Ingresa la informaciÛn nueva en la tabla de historia.
  --
  -- Par·metros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminÛ bien
  --                      1 = terminÛ con advertencia
  --                      2 = terminÛ con error
  --             p_person_id:  Ide de la persona a evaluar;  si es nulo, evalua todos los activos.
  --
  PROCEDURE Verifica_Cambios_Fecha
             ( errbuf                   OUT VARCHAR2
              ,retcode                  OUT NUMBER
              ,p_person_id           IN     NUMBER
             ) IS
    --
    CURSOR c_Personas (p_Person_Id   IN NUMBER) IS
        SELECT DAT.ROW_ID
              ,DAT.FULL_NAME
              ,DAT.EMPLOYEE_NUMBER
              ,DAT.PERSON_ID
              ,DAT.BUSINESS_GROUP_ID
              ,DAT.REQUIERE_APROBACION
              ,DAT.FECHA_CONTROL_VACACIONES
              ,DAT.HIRE_DATE
              ,DAT.ANTIGUEDAD_ANT
              ,DAT.ANTIGUEDAD_NUE
              ,DAT.FECHA_INICIO_PERIODO_ACT
              ,ADD_MONTHS(DAT.FECHA_INICIO_PERIODO_ACT, g_Max_Meses_Disfrutar) - 1      FECHA_FIN_PERIODO_ACT
              ,DAT.ANTIGUEDAD_SIG
              ,DAT.FECHA_INICIO_PERIODO_SIG
              ,ADD_MONTHS(DAT.FECHA_INICIO_PERIODO_SIG, g_Max_Meses_Disfrutar) - 1      FECHA_FIN_PERIODO_SIG
          FROM (
                SELECT COM.*
                      ,ADD_MONTHS(HIRE_DATE, (COM.ANTIGUEDAD_NUE * 12))              FECHA_INICIO_PERIODO_ACT
                      ,COM.ANTIGUEDAD_NUE + 1                                        ANTIGUEDAD_SIG
                      ,ADD_MONTHS(HIRE_DATE, ((COM.ANTIGUEDAD_NUE + 1) * 12))        FECHA_INICIO_PERIODO_SIG
                  FROM (
                        SELECT PP7.ROW_ID
                              ,PP7.FULL_NAME
                              ,PP7.EMPLOYEE_NUMBER
                              ,PP7.PERSON_ID
                              ,PP7.BUSINESS_GROUP_ID
                              ,NVL(PP7.ATTRIBUTE28, 'N')        REQUIERE_APROBACION
                              ,PP7.ATTRIBUTE29                  FECHA_CONTROL_VACACIONES
                              --,TRUNC(PP7.HIRE_DATE)             HIRE_DATE
                              ,TRUNC(get_Hire_Date(PP7.PERSON_ID)) HIRE_DATE
                              --,TRUNC(MONTHS_BETWEEN(SYSDATE, PP7.HIRE_DATE)/12)
                              ,TRUNC(MONTHS_BETWEEN(SYSDATE, get_Hire_Date(PP7.PERSON_ID))/12)
                                                                ANTIGUEDAD_NUE
                              ,TRUNC(MONTHS_BETWEEN(NVL2(PP7.ATTRIBUTE29, TO_DATE(PP7.ATTRIBUTE29, 'YYYY/MM/DD HH24:MI:SS')
                              --                                          , PP7.HIRE_DATE), PP7.HIRE_DATE)/12)
                                                                        , get_Hire_Date(PP7.PERSON_ID)), get_Hire_Date(PP7.PERSON_ID))/12)
                                                                ANTIGUEDAD_ANT
                          FROM PER_PEOPLE_V7     PP7
                         WHERE 1 = 1
                           AND PP7.EFFECTIVE_START_DATE      <= TRUNC(SYSDATE)
                           AND PP7.SYSTEM_PERSON_TYPE        IN ('EMP')
                           AND PP7.PERSON_ID                  = NVL(p_Person_Id, PP7.PERSON_ID)
                       ) COM
               ) DAT
      ORDER BY DAT.EMPLOYEE_NUMBER;
    --
    CURSOR c_Asignaciones (p_Person_Id     IN NUMBER) IS
      SELECT PA7.ASSIGNMENT_ID
        FROM PER_ASSIGNMENTS_V7   PA7
       WHERE 1 = 1
         AND PA7.PERSON_ID                  = p_Person_Id
         AND SYSDATE                  BETWEEN PA7.EFFECTIVE_START_DATE  AND PA7.EFFECTIVE_END_DATE
         AND PA7.PRIMARY_FLAG               = 'Y';
    --
    CURSOR c_Tipo_Nomina (p_Assignment_Id     NUMBER) IS
      SELECT HLU.MEANING
        FROM PAY_ELEMENT_TYPES_F          ETF
            ,PAY_ELEMENT_ENTRIES_F        EEF
            ,PAY_INPUT_VALUES_F           IVF
            ,PAY_ELEMENT_ENTRY_VALUES_F   EEV
            ,HR_LOOKUPS                   HLU
       WHERE 1 = 1
         AND ETF.ELEMENT_NAME           = 'Integrated Daily Wage'
         AND EEF.ELEMENT_TYPE_ID        = ETF.ELEMENT_TYPE_ID
         AND EEF.ASSIGNMENT_ID          = p_Assignment_Id
         AND IVF.ELEMENT_TYPE_ID        = ETF.ELEMENT_TYPE_ID
         AND IVF.DISPLAY_SEQUENCE       = 4
         AND EEV.ELEMENT_ENTRY_ID       = EEF.ELEMENT_ENTRY_ID
         AND EEV.INPUT_VALUE_ID         = IVF.INPUT_VALUE_ID
         AND HLU.LOOKUP_TYPE            = IVF.LOOKUP_TYPE      --'MX_IDW_FACTOR_TABLES'
         AND HLU.ENABLED_FLAG           = 'Y'
         AND HLU.LOOKUP_CODE            = EEV.SCREEN_ENTRY_VALUE
         AND SYSDATE BETWEEN EEV.EFFECTIVE_START_DATE AND EEV.EFFECTIVE_END_DATE
         AND SYSDATE BETWEEN EEF.EFFECTIVE_START_DATE AND EEF.EFFECTIVE_END_DATE;
    --
    CURSOR c_Dias ( p_Tipo_Nomina     VARCHAR2
                   ,p_Antiguedad      NUMBER
                  ) IS
      SELECT UCI.VALUE
        FROM PAY_USER_TABLES_FV               UTF
            ,PAY_USER_COLUMNS_FV              UCF
            ,XXCALV_PAY_USER_COLUMN_INST_V    UCI
       WHERE 1 = 1
         AND UTF.BASE_USER_TABLE_NAME          = p_Tipo_Nomina
         AND UCF.USER_TABLE_ID                 = UTF.USER_TABLE_ID
         AND UCF.BASE_USER_COLUMN_NAME         = 'DIAS VACACIONES'
         AND UCI.USER_COLUMN_ID                = UCF.USER_COLUMN_ID
         AND p_Antiguedad + 0.1          BETWEEN UCI.ROW_LOW_RANGE_OR_NAME AND UCI.ROW_HIGH_RANGE;
    --
    v_Assignment_Id           NUMBER;
    v_Tipo_Nomina             HR_LOOKUPS.MEANING%TYPE;
    v_Dias_Asignados_Act      XXCALV_PAY_USER_COLUMN_INST_V.VALUE%TYPE;
    v_Dias_Asignados_Sig      XXCALV_PAY_USER_COLUMN_INST_V.VALUE%TYPE;
    v_Registro_Base_Act       VARCHAR2(2);
    v_Registro_Base_Sig       VARCHAR2(2);
    v_Fecha_Minima_Vac        DATE;
    v_Supervisor_Id           NUMBER;
    v_errbuf                  VARCHAR2(2000);
    v_retcode                 NUMBER;
    v_Total_Procesados        NUMBER;
    v_Total_Grabados          NUMBER;
    v_Total_Errores           NUMBER;
    v_Contar                  VARCHAR2(2);
    --
  BEGIN
    --
    Inicializar_Valores
             ( errbuf
              ,retcode
             );
    IF retcode = 2 THEN
      RETURN;
    END IF;
    --
    v_Total_Procesados := 0;
    v_Total_Grabados   := 0;
    v_Total_Errores    := 0;
    --
    FOR v_Personas IN c_Personas(p_person_id) LOOP
      --
      v_Total_Procesados := v_Total_Procesados + 1;
      v_errbuf           := NULL;
      v_retcode          := 0;
      v_Contar           := 'N';
      XXSTO_TOOLS_PKG.genera_salida('Empleado n¿mero: ' || v_Personas.EMPLOYEE_NUMBER, 'B');
      v_Assignment_Id := NULL;
      FOR v_Asignaciones IN c_Asignaciones(v_Personas.person_id) LOOP
        --
        v_Assignment_Id := v_Asignaciones.assignment_id;
        EXIT;
        --
      END LOOP;
      --
      IF v_Assignment_Id IS NULL THEN
        v_errbuf  := 'Empleado no tiene datos de asignaciÛn.';
        XXSTO_TOOLS_PKG.genera_salida(v_errbuf, 'B');
        v_retcode := 2;
      ELSE
        --
        IF v_Personas.FECHA_CONTROL_VACACIONES IS NULL OR
           v_Personas.ANTIGUEDAD_NUE > v_Personas.ANTIGUEDAD_ANT THEN
          --
          v_Tipo_Nomina := NULL;
          OPEN  c_Tipo_Nomina (v_Assignment_Id);
          FETCH c_Tipo_Nomina INTO v_Tipo_Nomina;
          IF c_Tipo_Nomina%NOTFOUND THEN
            v_Tipo_Nomina := NULL;
          END IF;
          CLOSE c_Tipo_Nomina;
          --
          IF v_Tipo_Nomina IS NULL THEN
            v_errbuf  := 'Empleado no tiene tabla de SDI asociada.';
            XXSTO_TOOLS_PKG.genera_salida('  ' || v_errbuf, 'B');
            v_retcode := 2;
          ELSE
            Calcula_Dias_Disponibles
                   ( errbuf                => v_errbuf
                    ,retcode               => v_retcode
                    ,p_Person_Id           => v_Personas.person_id
                    ,p_Antiguedad_Act      => v_Personas.ANTIGUEDAD_NUE
                    ,p_Antiguedad_Sig      => v_Personas.ANTIGUEDAD_NUE + 1
                    ,p_Business_Group_Id   => v_Personas.Business_Group_Id
                    ,p_Procesar_Fecha_Min  => 'N'
                    ,p_Valida_Informativo  => 'N'
                    ,x_Dias_Actual         => v_Dias_Asignados_Act
                    ,x_Dias_Siguiente      => v_Dias_Asignados_Sig
                    ,x_Registro_Base_Act   => v_Registro_Base_Act
                    ,x_Registro_Base_Sig   => v_Registro_Base_Sig
                    ,x_Fecha_Minima_Vac    => v_Fecha_Minima_Vac
                    ,x_Supervisor_Id       => v_Supervisor_Id
                   );
          END IF;
          --
          IF v_retcode <> 2 AND NVL(v_Dias_Asignados_Act, 0) > 0 THEN
            IF NVL(v_Registro_Base_Act, 'N') = 'S' THEN
              IF  v_Personas.FECHA_CONTROL_VACACIONES IS NULL  THEN     -- Solo cuando el actual no habÌa sido creado previamente
                --
                g_xxcalv_vac_eventos                               := NULL;
                g_xxcalv_vac_eventos.ID_TIPO_EVENTO                := 1;
                g_xxcalv_vac_eventos.PERSON_ID                     := v_Personas.PERSON_ID;
                g_xxcalv_vac_eventos.ESTADO_REGISTRO               := 'I';
                g_xxcalv_vac_eventos.ESTADO_CONTROL                := 'I';
                g_xxcalv_vac_eventos.FECHA_ESTADO_CONTROL          := TRUNC(SYSDATE);
                g_xxcalv_vac_eventos.ANIO_ANTIGUEDAD               := v_Personas.ANTIGUEDAD_NUE;
                g_xxcalv_vac_eventos.DIAS_EVENTO                   := v_Dias_Asignados_Act;
                g_xxcalv_vac_eventos.DIAS_DESPLEGAR                := v_Dias_Asignados_Act;
                g_xxcalv_vac_eventos.SALDO_DIAS                    := v_Dias_Asignados_Act;
                g_xxcalv_vac_eventos.DESPLEGAR_P1                  := 'S';
                g_xxcalv_vac_eventos.FECHA_DESDE                   := v_Personas.FECHA_INICIO_PERIODO_ACT;
                g_xxcalv_vac_eventos.FECHA_HASTA                   := v_Personas.FECHA_FIN_PERIODO_ACT;
                g_xxcalv_vac_eventos.FECHA_DESDE_DESPLEGAR         := v_Personas.FECHA_INICIO_PERIODO_ACT;
                g_xxcalv_vac_eventos.FECHA_HASTA_DESPLEGAR         := v_Personas.FECHA_FIN_PERIODO_ACT;
                g_xxcalv_vac_eventos.CREATION_DATE                 := SYSDATE;
                g_xxcalv_vac_eventos.CREATED_BY                    := g_User_Id;
                g_xxcalv_vac_eventos.LAST_UPDATE_DATE              := SYSDATE;
                g_xxcalv_vac_eventos.LAST_UPDATE_BY                := g_User_Id;
                --
                Inserta_Registro_Historia_Enc
                   ( errbuf                => v_errbuf
                    ,retcode               => v_retcode
                    ,x_xxcalv_vac_eventos  => g_xxcalv_vac_eventos
                   );
                IF v_retcode = 2 THEN
                  XXSTO_TOOLS_PKG.genera_salida('  ' || v_errbuf, 'B');
                END IF;
              ELSE
                --
                IF v_Personas.ANTIGUEDAD_ANT > 0 THEN  -- Para localizar el periodo anterior y crear como perdidas las anteriores.
                  --
                  Cancela_Saldo_Anio
                         ( errbuf                => v_errbuf
                          ,retcode               => v_retcode
                          ,p_Person_Id           => v_Personas.PERSON_ID
                          ,p_Anio_Antiguedad     => v_Personas.ANTIGUEDAD_ANT
                         );
                  --
                END IF;
                --
              END IF;
            END IF;
          END IF;
          --
          IF v_retcode <> 2 AND NVL(v_Dias_Asignados_Sig, 0) > 0 THEN
            IF NVL(v_Registro_Base_Sig, 'N') = 'S' THEN
              g_xxcalv_vac_eventos                               := NULL;
              g_xxcalv_vac_eventos.ID_TIPO_EVENTO                := 1;
              g_xxcalv_vac_eventos.PERSON_ID                     := v_Personas.PERSON_ID;
              g_xxcalv_vac_eventos.ESTADO_REGISTRO               := 'I';
              g_xxcalv_vac_eventos.ESTADO_CONTROL                := 'I';
              g_xxcalv_vac_eventos.FECHA_ESTADO_CONTROL          := TRUNC(SYSDATE);
              g_xxcalv_vac_eventos.ANIO_ANTIGUEDAD               := v_Personas.ANTIGUEDAD_NUE + 1;
              g_xxcalv_vac_eventos.DIAS_EVENTO                   := v_Dias_Asignados_Sig;
              g_xxcalv_vac_eventos.DIAS_DESPLEGAR                := v_Dias_Asignados_Sig;
              g_xxcalv_vac_eventos.SALDO_DIAS                    := v_Dias_Asignados_Sig;
              g_xxcalv_vac_eventos.DESPLEGAR_P1                  := 'N';
              g_xxcalv_vac_eventos.FECHA_DESDE                   := v_Personas.FECHA_INICIO_PERIODO_SIG;
              g_xxcalv_vac_eventos.FECHA_HASTA                   := v_Personas.FECHA_FIN_PERIODO_SIG;
              g_xxcalv_vac_eventos.FECHA_DESDE_DESPLEGAR         := v_Personas.FECHA_INICIO_PERIODO_SIG;
              g_xxcalv_vac_eventos.FECHA_HASTA_DESPLEGAR         := v_Personas.FECHA_FIN_PERIODO_SIG;
              g_xxcalv_vac_eventos.CREATION_DATE                 := SYSDATE;
              g_xxcalv_vac_eventos.CREATED_BY                    := g_User_Id;
              g_xxcalv_vac_eventos.LAST_UPDATE_DATE              := SYSDATE;
              g_xxcalv_vac_eventos.LAST_UPDATE_BY                := g_User_Id;
              --
              Inserta_Registro_Historia_Enc
                 ( errbuf                => v_errbuf
                  ,retcode               => v_retcode
                  ,x_xxcalv_vac_eventos  => g_xxcalv_vac_eventos
                 );
            END IF;
            --
            v_Contar := 'S';
            XXSTO_TOOLS_PKG.genera_salida('Grabado   : ' || v_Personas.EMPLOYEE_NUMBER, 'B');
          --
          END IF;
          --
        END IF;
        --
      END IF;
      --
      IF v_retcode <> 2 THEN
        Actualiza_Desplegar_P1
             ( errbuf                => v_errbuf
              ,retcode               => v_retcode
              ,p_person_id           => v_Personas.PERSON_ID
             );
      END IF;
      --
      IF v_retcode <> 2 THEN
        Actualiza_Fecha_Control
             ( errbuf                => v_errbuf
              ,retcode               => v_retcode
              ,p_Row_Id              => v_Personas.ROW_ID
             );
      END IF;
      --
      IF v_Contar = 'S' THEN
        v_Total_Grabados  := v_Total_Grabados + 1;
      END IF;
      --
      IF v_retcode <> 2 THEN
        COMMIT;
      ELSE
        ROLLBACK;
        v_Total_Errores    := v_Total_Errores + 1;
      END IF;
      IF v_retcode > retcode THEN
        retcode := v_retcode;
      END IF;
      --
    END LOOP;
    --
    XXSTO_TOOLS_PKG.genera_salida('***********************************************', 'B');
    XXSTO_TOOLS_PKG.genera_salida('Total Procesados : ' || v_Total_Procesados, 'B');
    XXSTO_TOOLS_PKG.genera_salida('Total Grabados   : ' || v_Total_Grabados, 'B');
    XXSTO_TOOLS_PKG.genera_salida('Total Errores    : ' || v_Total_Errores, 'B');
    XXSTO_TOOLS_PKG.genera_salida('***********************************************', 'B');
    --
    Verifica_Cambios_Estado
             ( errbuf                => errbuf
              ,retcode               => retcode
              ,p_person_id           => p_person_id
             );
    --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := 'Error en Verifica_Cambios_Fecha: ' || SQLERRM;
      XXSTO_TOOLS_PKG.genera_salida(errbuf, 'B');
      retcode := 2;
      RETURN;
  END Verifica_Cambios_Fecha;
  
  
  FUNCTION get_Hire_Date(p_person_id   IN NUMBER)
  RETURN DATE
  IS
    var_hire_date   DATE;
  BEGIN
  
  
    SELECT NVL(PPS.ADJUSTED_SVC_DATE, PER.ORIGINAL_DATE_OF_HIRE)
      INTO var_hire_date
      FROM PER_PERIODS_OF_SERVICE PPS,
           PER_PEOPLE_F PER
     WHERE 1 = 1
       AND PPS.PERSON_ID(+) = PER.PERSON_ID
       AND (   (PER.EMPLOYEE_NUMBER IS NULL)
            OR (    PER.EMPLOYEE_NUMBER IS NOT NULL
                AND PPS.DATE_START = (SELECT MAX (PPS1.DATE_START)
                                        FROM PER_PERIODS_OF_SERVICE PPS1
                                       WHERE PPS1.PERSON_ID = PER.PERSON_ID)
               )
           )
       AND PER.EFFECTIVE_START_DATE = (SELECT MAX (PER1.EFFECTIVE_START_DATE)
                                         FROM PER_PEOPLE_F PER1
                                        WHERE PER1.PERSON_ID = PER.PERSON_ID)
       AND PER.PERSON_ID = p_person_id;
       
    RETURN var_hire_date;
       
  END get_Hire_Date;
  
  
END XXCALV_Control_de_Vacaciones;
/