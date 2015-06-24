CREATE OR REPLACE PACKAGE PAC_FUEL_EC_REPORTS_PKG IS

    /*
        Obtiene la Fecha Inicial (Jueves) y la fecha Final (Miercoles) 
        a partir de una fecha dada.
        Para el reporte XXCALV - Control de Rendimiento de Vehículos
    */
    FUNCTION GET_START_AND_END_DATE(
        P_DATE          IN  DATE,
        P_START_DATE    OUT DATE,
        P_END_DATE      OUT DATE)                   
      RETURN BOOLEAN;
      

    /*
        Obtiene la distancia recorrida acumulada en la semana 
        correspondiente de Jueves a Miercoles.
        Para el reporte XXCALV - Control de Rendimiento de Vehículos
    */
    FUNCTION GET_READING_ACUM(
        P_VEHICLE_ID    VARCHAR2,
        P_DATE          DATE)
      RETURN VARCHAR2;
        
    /*
        Ontiene el combustible consumido en la semana
        correspondiente de Juesves a Miercoles.
        Para el reporte XXCALV - Control de Rendimiento de Vehículos
    */
    FUNCTION GET_CONSUMED_FUEL_ACUM(
        P_VEHICLE_ID    VARCHAR2,
        P_DATE          DATE)
      RETURN VARCHAR2;
  
    /*
        Obtiene la eficiencia acumulada en la semana
        correspondiente de Jueves a Miercoles.
        Para el reporte XXCALV - Control de Rendimiento de Vehículos
    */
    FUNCTION GET_EFFICIENCY_ACUM(
        P_VEHICLE_ID    VARCHAR2,
        P_DATE          DATE)
      RETURN VARCHAR2;  
      
      
    /*
        Obtiene la diferencia en litros en la semana
        correspondiente de Jueves a Miercoles.
        Para el reporte XXCALV - Reporte de Rendimiento de Reparto Semanal.
    */
    FUNCTION GET_LTS_DIFFERENCE_ACUM(
        P_VEHICLE_ID    VARCHAR2, 
        P_DATE          DATE)
      RETURN VARCHAR2;
      
    /*
        Obtiene la lista de comentarios en la semana
        correspondiente de Jueves a Miercoles.
        Para el reporte XXCALV - Reporte de Rendimiento de Reparto Semanal.
    */
    FUNCTION GET_COMMENTS_LIST(
        P_VEHICLE_ID    VARCHAR2,
        P_DATE          DATE)
      RETURN VARCHAR2;
         

    /*
        Obtiene la distancia recorrida en el mes, utilizada
        en el reporte XXCALV - Reporte de Rendimiento Mensual
    */
    FUNCTION GET_TRIP_DISTANCE_BY_MONTH(
        P_VEHICLE_ID    VARCHAR2,
        P_YEAR          NUMBER,
        P_MONTH         NUMBER)
      RETURN NUMBER;
     
    /*
        Obtiene el consumo de combustible en el mes, utilizada
        en el rpeorte XXCALV - Reporte de Rendimiento Mensual
    */
    FUNCTION GET_CONSUMED_FUEL_BY_MONTH(
        P_VEHICLE_ID    VARCHAR2,
        P_YEAR          NUMBER,
        P_MONTH         NUMBER)
      RETURN NUMBER;
      
    /*
        Obtiene la eficiencia obtenida en el mes, utilizada 
        en el reporte XXCALV - Reporte de Rendimiento Mensual
    */
    FUNCTION GET_EFFICIENCY_BY_MONTH(
        P_VEHICLE_ID    VARCHAR2,
        P_YEAR          NUMBER,
        P_MONTH         NUMBER)
      RETURN NUMBER;
      
      
    /**/
    FUNCTION GET_DESTINATION_NAME(
        P_VEHICLE_ID    VARCHAR2,
        P_DATE          DATE)
      RETURN VARCHAR2;
      
    /**/
    FUNCTION GET_DRIVER_NAME(
        P_VEHICLE_ID    VARCHAR2,
        P_DATE          DATE)
      RETURN VARCHAR2;
      
    /**/
    FUNCTION GET_TRAILER_TYPE(
        P_VEHICLE_ID    VARCHAR2,
        P_DATE          DATE)
      RETURN VARCHAR2;
      
    /**/
    FUNCTION GET_LTS_DIFFERENCE(
        P_VEHICLE_ID    VARCHAR2,
        P_DATE          DATE)
      RETURN VARCHAR2;

END PAC_FUEL_EC_REPORTS_PKG;
