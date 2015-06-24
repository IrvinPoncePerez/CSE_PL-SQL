CREATE OR REPLACE PACKAGE BODY PAC_FUEL_EC_REPORTS_PKG IS


    FUNCTION GET_START_AND_END_DATE(
        P_DATE          IN  DATE,
        P_START_DATE    OUT DATE,
        P_END_DATE      OUT DATE)                   
      RETURN BOOLEAN
    IS  
        var_day_week    VARCHAR2(50);
        var_date        DATE;
    BEGIN
    
        var_day_week := TO_CHAR(P_DATE, 'D');
        var_date := P_DATE;
        
        IF    var_day_week = '5' THEN
            
            LOOP
            
              
              var_date := var_date -1;
              var_day_week := TO_CHAR(var_date, 'D');
              
              IF   var_day_week = '6' THEN
                P_START_DATE := var_date;
                P_END_DATE := P_DATE;
                EXIT;
              END IF;
            
            END LOOP;
            
            RETURN TRUE;
        
        ELSE
            RETURN FALSE;
        END IF; 
                    
    END;
    
    
    FUNCTION GET_READING_ACUM(
        P_VEHICLE_ID    VARCHAR2,
        P_DATE          DATE)
      RETURN VARCHAR2
    IS
        var_start_date      DATE;
        var_end_date        DATE;
        var_reading_acum    VARCHAR2(50);
    BEGIN
        
        IF PAC_FUEL_EC_REPORTS_PKG.GET_START_AND_END_DATE(P_DATE, var_start_date, var_end_date) = TRUE THEN
            
            SELECT NVL(SUM(PFEE.TRIP_DISTANCE), 0)
              INTO var_reading_acum
              FROM PAC_FUEL_EC_EFFICIENCIES     PFEE,
                   PAC_FUEL_EC_DEPARTURES       PFED
             WHERE PFEE.VEHICLE_ID = P_VEHICLE_ID
               AND PFEE.ARRIVAL_ID = PFED.DEPARTURE_ID
               AND PFEE.ATTRIBUTE4 = 'Y'
               AND PFED.DEPARTURE_TYPE = 'ENTRADA'
               AND PFED.DEPARTURE_DATE BETWEEN var_start_date AND var_end_date;
        
        END IF;
        
        RETURN var_reading_acum;
    
    END;
      
    
    FUNCTION GET_CONSUMED_FUEL_ACUM(
        P_VEHICLE_ID    VARCHAR2,
        P_DATE          DATE)
      RETURN VARCHAR2
    IS
        var_start_date          DATE;
        var_end_date            DATE;
        var_consumed_fuel_acum  VARCHAR2(50);  
    BEGIN
        
        IF PAC_FUEL_EC_REPORTS_PKG.GET_START_AND_END_DATE(P_DATE, var_start_date, var_end_date) = TRUE THEN
        
            SELECT NVL(SUM(PFEE.TOTAL_CONSUMED_FUEL), 0)
              INTO var_consumed_fuel_acum
              FROM PAC_FUEL_EC_EFFICIENCIES     PFEE,
                   PAC_FUEL_EC_DEPARTURES       PFED
             WHERE PFEE.VEHICLE_ID = P_VEHICLE_ID
               AND PFEE.ARRIVAL_ID = PFED.DEPARTURE_ID
               AND PFEE.ATTRIBUTE4 = 'Y'
               AND PFED.DEPARTURE_TYPE = 'ENTRADA'
               AND PFED.DEPARTURE_DATE BETWEEN var_start_date AND var_end_date;
        
        END IF;
        
        RETURN var_consumed_fuel_acum;    
    
    END;
      
    
    FUNCTION GET_EFFICIENCY_ACUM(
        P_VEHICLE_ID    VARCHAR2,
        P_DATE          DATE)
      RETURN VARCHAR2
    IS
        var_start_date          DATE;
        var_end_date            DATE;
        var_trip_distance_acum  VARCHAR2(50);
        var_consumed_fuel_acum  VARCHAR2(50);
        var_efficiency          VARCHAR2(50); 
    BEGIN
        
        IF PAC_FUEL_EC_REPORTS_PKG.GET_START_AND_END_DATE(P_DATE, var_start_date, var_end_date) = TRUE THEN
    
            SELECT NVL(SUM(PFEE.TRIP_DISTANCE), 0),
                   NVL(SUM(PFEE.TOTAL_CONSUMED_FUEL), 0)
              INTO var_trip_distance_acum,
                   var_consumed_fuel_acum
              FROM PAC_FUEL_EC_EFFICIENCIES     PFEE,
                   PAC_FUEL_EC_DEPARTURES       PFED
             WHERE PFEE.VEHICLE_ID = P_VEHICLE_ID
               AND PFEE.ARRIVAL_ID = PFED.DEPARTURE_ID
               AND PFEE.ATTRIBUTE4 = 'Y'
               AND PFED.DEPARTURE_TYPE = 'ENTRADA'
               AND PFED.DEPARTURE_DATE BETWEEN var_start_date AND var_end_date;
               
            BEGIN
                var_efficiency := ROUND((var_trip_distance_acum / var_consumed_fuel_acum),2);
            EXCEPTION WHEN ZERO_DIVIDE THEN
                dbms_output.put_line(':P');
                RETURN '0';
            END;       
        
        END IF;    
    
        RETURN var_efficiency;
    
    END;  
    
    
    FUNCTION GET_TRIP_DISTANCE_BY_MONTH(
        P_VEHICLE_ID    VARCHAR2,
        P_YEAR          NUMBER,
        P_MONTH         NUMBER)
      RETURN NUMBER
    IS
        var_trip_distance   NUMBER;
    BEGIN
    
        SELECT NVL(SUM(PFEE.TRIP_DISTANCE), 0) 
          INTO var_trip_distance
          FROM PAC_FUEL_EC_EFFICIENCIES     PFEE,
               PAC_FUEL_EC_DEPARTURES       PFED
         WHERE PFEE.VEHICLE_ID = P_VEHICLE_ID
           AND PFEE.ARRIVAL_ID = PFED.DEPARTURE_ID
           AND EXTRACT(YEAR FROM PFED.DEPARTURE_DATE) = P_YEAR
           AND EXTRACT(MONTH FROM PFED.DEPARTURE_DATE) = P_MONTH;
    
        RETURN var_trip_distance;
    END;
     
    
    FUNCTION GET_CONSUMED_FUEL_BY_MONTH(
        P_VEHICLE_ID    VARCHAR2,
        P_YEAR          NUMBER,
        P_MONTH         NUMBER)
      RETURN NUMBER
    IS
        var_consumed_fuel   NUMBER;
    BEGIN
    
        SELECT NVL(SUM(PFEE.TOTAL_CONSUMED_FUEL), 0) 
          INTO var_consumed_fuel
          FROM PAC_FUEL_EC_EFFICIENCIES     PFEE,
               PAC_FUEL_EC_DEPARTURES       PFED
         WHERE PFEE.VEHICLE_ID = P_VEHICLE_ID
           AND PFEE.ARRIVAL_ID = PFED.DEPARTURE_ID
           AND EXTRACT(YEAR FROM PFED.DEPARTURE_DATE) = P_YEAR
           AND EXTRACT(MONTH FROM PFED.DEPARTURE_DATE) = P_MONTH;
    
        RETURN var_consumed_fuel;
    END;
      
    
    FUNCTION GET_EFFICIENCY_BY_MONTH(
        P_VEHICLE_ID    VARCHAR2,
        P_YEAR          NUMBER,
        P_MONTH         NUMBER)
      RETURN NUMBER
    IS
        var_trip_distance       NUMBER;
        var_consumed_fuel       NUMBER;
        var_efficiency          NUMBER;
    BEGIN
    
        SELECT NVL(SUM(PFEE.TRIP_DISTANCE), 0), 
               NVL(SUM(PFEE.TOTAL_CONSUMED_FUEL), 0) 
          INTO var_trip_distance,
               var_consumed_fuel
          FROM PAC_FUEL_EC_EFFICIENCIES     PFEE,
               PAC_FUEL_EC_DEPARTURES       PFED
         WHERE PFEE.VEHICLE_ID = P_VEHICLE_ID
           AND PFEE.ARRIVAL_ID = PFED.DEPARTURE_ID
           AND EXTRACT(YEAR FROM PFED.DEPARTURE_DATE) = P_YEAR
           AND EXTRACT(MONTH FROM PFED.DEPARTURE_DATE) = P_MONTH;
           
        BEGIN
            var_efficiency := ROUND((var_trip_distance / var_consumed_fuel), 2);
        EXCEPTION WHEN ZERO_DIVIDE THEN
            RETURN 0;
        END;
    
        RETURN var_efficiency;
    END;    
    
    
    FUNCTION GET_DESTINATION_NAME(
        P_VEHICLE_ID    VARCHAR2,
        P_DATE          DATE)
      RETURN VARCHAR2
    IS
        var_destination_name        VARCHAR2(300) := '';
    BEGIN
    
        SELECT PFED2.TO_ORG_NAME
          INTO var_destination_name
          FROM PAC_FUEL_EC_EFFICIENCIES     PFEE,
               PAC_FUEL_EC_DEPARTURES       PFED1,  --ARRIVAL_ID
               PAC_FUEL_EC_DEPARTURES       PFED2   --DEPARTURE_ID
         WHERE 1 = 1
           AND PFEE.ARRIVAL_ID = PFED1.DEPARTURE_ID
           AND PFEE.DEPARTURE_ID = PFED2.DEPARTURE_ID
           AND PFEE.VEHICLE_ID = P_VEHICLE_ID
           AND PFED1.DEPARTURE_DATE = P_DATE
           AND PFEE.ATTRIBUTE4 = 'Y';        
    
        RETURN var_destination_name;
    END;
    
    
    FUNCTION GET_DRIVER_NAME(
        P_VEHICLE_ID    VARCHAR2,
        P_DATE          DATE)
      RETURN VARCHAR2
    IS
        var_driver_name     VARCHAR2(300) := '';
    BEGIN
        SELECT PFED2.DRIVER_NAME
          INTO var_driver_name
          FROM PAC_FUEL_EC_EFFICIENCIES     PFEE,
               PAC_FUEL_EC_DEPARTURES       PFED1,  --ARRIVAL_ID
               PAC_FUEL_EC_DEPARTURES       PFED2   --DEPARTURE_ID
         WHERE 1 = 1
           AND PFEE.ARRIVAL_ID = PFED1.DEPARTURE_ID
           AND PFEE.DEPARTURE_ID = PFED2.DEPARTURE_ID
           AND PFEE.VEHICLE_ID = P_VEHICLE_ID
           AND PFED1.DEPARTURE_DATE = P_DATE
           AND PFEE.ATTRIBUTE4 = 'Y';       
    
        RETURN var_driver_name;
    END;
    
      
    FUNCTION GET_TRAILER_TYPE(
        P_VEHICLE_ID    VARCHAR2,
        P_DATE          DATE)
      RETURN VARCHAR2
    IS
        var_trailer_type        VARCHAR2(300) := '';
    BEGIN
        SELECT PFED2.TRAILER_TYPE
          INTO var_trailer_type
          FROM PAC_FUEL_EC_EFFICIENCIES     PFEE,
               PAC_FUEL_EC_DEPARTURES       PFED1,  --ARRIVAL_ID
               PAC_FUEL_EC_DEPARTURES       PFED2   --DEPARTURE_ID
         WHERE 1 = 1
           AND PFEE.ARRIVAL_ID = PFED1.DEPARTURE_ID
           AND PFEE.DEPARTURE_ID = PFED2.DEPARTURE_ID
           AND PFEE.VEHICLE_ID = P_VEHICLE_ID
           AND PFED1.DEPARTURE_DATE = P_DATE
           AND PFEE.ATTRIBUTE4 = 'Y';       
    
        RETURN var_trailer_type;
    END;
    
      
    FUNCTION GET_LTS_DIFFERENCE(
        P_VEHICLE_ID    VARCHAR2,
        P_DATE          DATE)
      RETURN VARCHAR2
    IS
        var_lts_difference      VARCHAR2(300) := '';
    BEGIN
        SELECT PFEE.ATTRIBUTE3
          INTO var_lts_difference
          FROM PAC_FUEL_EC_EFFICIENCIES     PFEE,
               PAC_FUEL_EC_DEPARTURES       PFED
         WHERE PFEE.ARRIVAL_ID = PFED.DEPARTURE_ID
           AND PFEE.VEHICLE_ID = P_VEHICLE_ID
           AND PFED.DEPARTURE_DATE = P_DATE
           AND PFEE.ATTRIBUTE4 = 'Y';
           
        RETURN var_lts_difference;
    END;
    
    
    FUNCTION GET_LTS_DIFFERENCE_ACUM(
        P_VEHICLE_ID    VARCHAR2, 
        P_DATE          DATE)
      RETURN VARCHAR2
    IS
        var_start_date      DATE;
        var_end_date        DATE;
        var_lts_difference  VARCHAR2(100);
    BEGIN
        
        IF PAC_FUEL_EC_REPORTS_PKG.GET_START_AND_END_DATE(P_DATE, var_start_date, var_end_date) = TRUE THEN
    
            SELECT NVL(SUM(ROUND(PFEE.ATTRIBUTE3, 0)), 0)
              INTO var_lts_difference
              FROM PAC_FUEL_EC_EFFICIENCIES     PFEE,
                   PAC_FUEL_EC_DEPARTURES       PFED
             WHERE PFEE.VEHICLE_ID = P_VEHICLE_ID
               AND PFEE.ARRIVAL_ID = PFED.DEPARTURE_ID
               AND PFEE.ATTRIBUTE4 = 'Y'
               AND PFED.DEPARTURE_TYPE = 'ENTRADA'
               AND PFED.DEPARTURE_DATE BETWEEN var_start_date AND var_end_date;
        
        END IF;  
            
        RETURN var_lts_difference;
    END;
    
    
    FUNCTION GET_COMMENTS_LIST(
        P_VEHICLE_ID    VARCHAR2,
        P_DATE          DATE)
      RETURN VARCHAR2
    IS
        var_start_date      DATE;
        var_end_date       DATE;
        var_comments        VARCHAR2(500);
    BEGIN
    
        var_comments := '';
        
        IF PAC_FUEL_EC_REPORTS_PKG.GET_START_AND_END_DATE(P_DATE, var_start_date, var_end_date) = TRUE THEN
        
            DECLARE
                
                CURSOR DETAILS IS
                SELECT PFED2.TO_ORG_NAME    AS  DESTINATION_NAME,
                       PFED2.TRAILER_TYPE   AS  TRAILER_TYPE
                  FROM PAC_FUEL_EC_EFFICIENCIES     PFEE,
                       PAC_FUEL_EC_DEPARTURES       PFED1,
                       PAC_FUEL_EC_DEPARTURES       PFED2
                 WHERE PFEE.VEHICLE_ID = P_VEHICLE_ID
                   AND PFEE.ARRIVAL_ID = PFED1.DEPARTURE_ID
                   AND PFEE.ATTRIBUTE4 = 'Y'
                   AND PFED1.DEPARTURE_TYPE = 'ENTRADA'
                   AND PFED1.DEPARTURE_DATE BETWEEN var_start_date AND var_end_date
                   AND PFED2.DEPARTURE_ID = PFEE.DEPARTURE_ID
                   AND PFED2.TRAILER_TYPE LIKE '%FULL%';
                   
            BEGIN
                
                FOR detail IN DETAILS LOOP
                
                    var_comments := var_comments || detail.DESTINATION_NAME || ' ';
                    var_comments := var_comments || '(';
                    var_comments := var_comments || detail.TRAILER_TYPE;
                    var_comments := var_comments || ')' || chr(10);
                    
                
                END LOOP;
            
            END;
        
        END IF;
    
        RETURN var_comments;
    END;


END PAC_FUEL_EC_REPORTS_PKG;
