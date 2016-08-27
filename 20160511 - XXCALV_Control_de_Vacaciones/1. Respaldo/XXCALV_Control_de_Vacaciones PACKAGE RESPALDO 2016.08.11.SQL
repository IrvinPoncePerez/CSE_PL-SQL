CREATE OR REPLACE PACKAGE APPS.XXCALV_Control_de_Vacaciones AUTHID CURRENT_USER IS
/******************************************************************************************
 Modulo : PAY
 Autor : Manuel Antonio Álvarez Tovar
 Fecha : 22/07/2014
 Descripcion: Administración de solicitudes de vacaciones.

 REVISIONS:
 Ver      Date      Author           Description
 ---- ---------- --------------- ------------------------------------
 1.0  22/07/2014  MALVAREZ       Created this package.
******************************************************************************************/

  --
  --
  -- PROCEDURE Reconstruye_Saldos
  --
  -- Descripción:  Genera la reconstrucción de saldo, a partir del movimiento de asignación de vacaciones.
  --
  -- Parámetros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminó bien
  --                      1 = terminó con advertencia
  --                      2 = terminó con error
  --            p_Person_Id          : Id de la persona a la cual actualizar los saldo
  --            p_Anio_Antiguedad    : Anio de antiguedad en el cual se actualizarán los saldos
  --            p_Commit             : Indicador para saber si hace COMMIT (TRUE) o no (FALSE).
  --
  PROCEDURE Reconstruye_Saldos
             ( errbuf                   OUT VARCHAR2
              ,retcode                  OUT NUMBER
              ,p_Person_Id           IN     NUMBER
              ,p_Anio_Antiguedad     IN     NUMBER
              ,p_Commit              IN     VARCHAR2 DEFAULT 'FALSE'
             );
  --
  -- PROCEDURE Actualiza_Datos_Anio_Base
  --
  -- Descripción:  Actualiza el saldo de días, ubicando el registro que almacena el dato en la historia.
  --
  -- Parámetros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminó bien
  --                      1 = terminó con advertencia
  --                      2 = terminó con error
  --            p_Person_Id          : Id de la persona a la cual actualizar el saldo
  --            p_Anio_Antiguedad    : Anio de antiguedad en el cual se actualizará el saldo
  --            p_Dias               : Número de días a transaccionar.  Positivo si suma al saldo;  negativo si resta del saldo.
  --
  -- Retorna el nuevo saldo disponible de días.
  --
  FUNCTION Actualiza_Datos_Anio_Base
             ( errbuf                   OUT VARCHAR2
              ,retcode                  OUT NUMBER
              ,p_Person_Id           IN     NUMBER
              ,p_Anio_Antiguedad     IN     NUMBER
              ,p_Dias                IN     NUMBER   DEFAULT NULL  -- positivo si suma al saldo;   negativo si resta del saldo
             ) RETURN NUMBER;
  --
  -- PROCEDURE Inserta_Registro_Historia_Enc
  --
  -- Descripción:  Graba físicamente la información nueva de encabezados en la tabla de historia.
  --
  -- Parámetros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminó bien
  --                      1 = terminó con advertencia
  --                      2 = terminó con error
  --             x_xxcalv_vac_eventos:     Registro de encabezado a grabar.
  --
  PROCEDURE Inserta_Registro_Historia_Enc
             ( errbuf                       IN OUT VARCHAR2
              ,retcode                      IN OUT NUMBER
              ,x_xxcalv_vac_eventos         IN OUT XXCALV_VAC_EVENTOS%ROWTYPE
             );
  --
  -- PROCEDURE Inserta_Registro_Historia_Det
  --
  -- Descripción:  Graba físicamente la información nueva de detalle en la tabla de historia.
  --
  -- Parámetros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminó bien
  --                      1 = terminó con advertencia
  --                      2 = terminó con error
  --             x_xxcalv_vac_eventos_det: Registro de detalle a grabar.
  --
  PROCEDURE Inserta_Registro_Historia_Det
             ( errbuf                       IN OUT VARCHAR2
              ,retcode                      IN OUT NUMBER
              ,x_xxcalv_vac_eventos_det     IN OUT XXCALV_VAC_EVENTOS_DET%ROWTYPE
             );
  --
  -- PROCEDURE Regresa_Datos_Empleado
  --
  -- Descripción:  Toma la infomación de los días asignados para el período actual y siguiente, para luego restar de estos
  --               el número de días utilizados en cada uno.  De esa manera se obtiene cada disponible.
  --
  -- Parámetros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminó bien
  --                      1 = terminó con advertencia
  --                      2 = terminó con error
  --             p_Person_Id: Id de la persona a la que se deben calcular los días.
  --             x_Numero_Empleado            Número de nómina del empleado.
  --             x_Nombre_Completo            Nombre completo del empleado
  --             x_Requiere_Aprobacion        Indicador de si el empleado requiere solicitar aprobación de vacaciones del supervisor.
  --             x_Fecha_Control_Vacaciones   Fecha de la última revisión de datos del proceso de control de vacaciones.
  --             x_Captura_Vacaciones         Indicador de si es capturador de vacaciones o no.
  --             x_Fecha_Ingreso              Fecha de ingreso a la empresa.
  --             x_Antiguedad_Act             Años de antiguedad actual.
  --             x_Antiguedad_Sig             Años de antiguedad siguiente.
  --             x_Dias_Actual:               Número de días disponibles en el período actual.
  --             x_Fecha_Inicio_Act:          Fecha de inicio del período actual.
  --             x_Fecha_Fin_Act:             Fecha de finalización del período actual
  --             x_Días_Siguiente:            Número de días disponibles en el siguiente período
  --             x_Fecha_Inicio_Sig:          Fecha de inicio del período siguiente.
  --             x_Fecha_Fin_Sig:             Fecha de finalización del período siguiente.
  --             x_Registro_Base_Act: Regresa 'S' si el valor del día para el período actual se tomó de la tabla base del sistema o
  --                                          'N' si se tomó de la tabla propia del desarrollo.
  --             x_Registro_Base_Sig: Regresa 'S' si el valor del día para el período siguiente se tomó de la tabla base del sistema o
  --                                          'N' si se tomó de la tabla propia del desarrollo.
  --             x_Fecha_Minima_Vac:  Basado en la última ejecución de pago de nómina o pago rápido,
  --                                  obtiene el primer día disponible para solicitar vacaciones
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
             );
  --
  -- PROCEDURE Actualiza_Evento
  --
  -- Descripción:  Actualiza los datos de un evento.
  --
  -- Parámetros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminó bien
  --                      1 = terminó con advertencia
  --                      2 = terminó con error
  --             p_Event_Id:    Id del evento a actualizar.
  --             p_Respuesta_Solicitud:  Respuesta recibida del WF de aprobación o pantalla.
  --                                    'A' = Aprobado.  'R' = Rechazado.  'C' = Cancelado.
  --
  PROCEDURE Actualiza_Evento
             ( errbuf                      IN OUT VARCHAR2
              ,retcode                     IN OUT NUMBER
              ,p_Event_Id                  IN     NUMBER
              ,p_Respuesta_Solicitud       IN     VARCHAR2 DEFAULT NULL
             );
  --
  -- PROCEDURE Actualiza_Evento_WF
  --
  -- Descripción:  Actualiza los datos de un evento, proveniente del Work Flow, inicializando valores de sesión.
  --
  -- Parámetros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminó bien
  --                      1 = terminó con advertencia
  --                      2 = terminó con error
  --             p_Event_Id:    Id del evento a actualizar.
  --             p_Respuesta_Solicitud:  Respuesta recibida del WF de aprobación o pantalla.
  --                                    'A' = Aprobado.  'R' = Rechazado.  'C' = Cancelado.
  --
  PROCEDURE Actualiza_Evento_WF
             ( errbuf                      IN OUT VARCHAR2
              ,retcode                     IN OUT NUMBER
              ,p_Event_Id                  IN     NUMBER
              ,p_Respuesta_Solicitud       IN     VARCHAR2 DEFAULT NULL
             );
  --
  -- PROCEDURE Carga_Archivo_Saldos
  --
  -- Descripción:  Carga el archivo de saldos de vacaciones ya procesadas a la tabla del histórico.
  --
  -- Parámetros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminó bien
  --                      1 = terminó con advertencia
  --                      2 = terminó con error
  --             p_Id_Ruta:         Nombre de identificador en ALL_TABLES que contiene la ruta de carga del archivo.
  --             p_Nombre_Archivo:  Nombre del archivo con los datos a cargar.
  --
  PROCEDURE Carga_Archivo_Saldos
             ( errbuf                   OUT VARCHAR2
              ,retcode                  OUT NUMBER
              ,p_Id_Ruta             IN     VARCHAR2
              ,p_Nombre_Archivo      IN     VARCHAR2
             );
  --
  -- PROCEDURE Verifica_Cambios_Fecha
  --
  -- Descripción:  Valida los movimientos que haya tenido un empelado desde la última actualización del registro.
  --               Ingresa la información nueva en la tabla de historia.
  --
  -- Parámetros: errbuf:  Mensaje de error en caso de presentarse uno
  --             retcode: 0 = terminó bien
  --                      1 = terminó con advertencia
  --                      2 = terminó con error
  --             p_person_id:  Ide de la persona a evaluar;  si es nulo, evalua todos los activos.
  --
  PROCEDURE Verifica_Cambios_Fecha
             ( errbuf                   OUT VARCHAR2
              ,retcode                  OUT NUMBER
              ,p_person_id           IN     NUMBER
             );
  --
  g_xxcalv_vac_eventos           XXCALV_VAC_EVENTOS%ROWTYPE;
  g_User_Id                      NUMBER;
  g_Org_Id                       NUMBER;
  g_Responsibility_Id            NUMBER;
  g_Resp_Appl_Id                 NUMBER;
  g_Login_Id                     NUMBER;
  g_Conc_Id_Actual               NUMBER;
  g_Id_Juego_de_Libros           NUMBER;
  g_Dias_Max_Vacaciones          NUMBER := 0;
  g_Max_Meses_Disfrutar          NUMBER := 0;
  --
END XXCALV_Control_de_Vacaciones;
/
