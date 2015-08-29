PACKAGE BODY PAC_VALIDATE_PKG IS
  
  FUNCTION	VALIDATE_TRAFFIC_NUMBER(P_TRAFFIC_NUMBER	NUMBER)
  RETURN VARCHAR2
  IS
  BEGIN
  	
  IF NOT (is_departure_exist(p_traffic_number)) THEN
      RETURN ('Tráfico no ha CAPTURADO el vale.');
  ELSIF NOT (is_departure_registered(p_traffic_number)) THEN
      RETURN ('Tráfico no ha REGISTRADO el vale.');
  ELSIF NOT (is_departure_closed(p_traffic_number)) THEN
      RETURN ('Caseta de verificación no ha LIBERADO el registro de SALIDA.');
  ELSIF NOT (is_departure_arrival_complete(p_traffic_number)) THEN
      RETURN ('Caseta de verificación no ha CAPTURADO el registro de ENTRADA.');
  ELSIF NOT (is_arrival_closed(p_traffic_number)) THEN
      RETURN ('Caseta de verificación no ha LIBERADO el registro de ENTRADA.');
  ELSIF (is_cancelled(p_traffic_number)) THEN
      RETURN('Este registro fue CANCELADO');
  ELSE    
      RETURN ('Problema desconocido, solicite informe al departamento de sistemas.');
  END IF;
  	
  	RETURN '';
  	
  END;
  
  FUNCTION	IS_DEPARTURE_EXIST(P_TRAFFIC_NUMBER		NUMBER)
  RETURN BOOLEAN
  IS
  	var_result	VARCHAR2(20);
  BEGIN
  	 
  	SELECT DECODE(COUNT(PFE.DEPARTURE_NUMBER),
              		0, 'FALSE',
              		'TRUE')   
      INTO var_result
  		FROM APPS.PAC_FUEL_EC_DEPARTURES    PFE
 		 WHERE PFE.DEPARTURE_NUMBER = P_TRAFFIC_NUMBER;
  	 
  	RETURN CASE var_result
  					WHEN 'TRUE' THEN TRUE
  					WHEN 'FALSE' THEN FALSE
  					ELSE NULL
  				 END;
  END;
  
  FUNCTION	IS_DEPARTURE_ARRIVAL_COMPLETE(P_TRAFFIC_NUMBER	NUMBER)
  RETURN BOOLEAN
  IS
  	var_result	VARCHAR2(20);
  BEGIN
  	
  	SELECT DECODE(COUNT(PFE.DEPARTURE_NUMBER), 
		              1, 'FALSE',
		              'TRUE')  
		  INTO var_result
		  FROM APPS.PAC_FUEL_EC_DEPARTURES    PFE
		 WHERE PFE.DEPARTURE_NUMBER = P_TRAFFIC_NUMBER
		   AND (   PFE.DEPARTURE_TYPE = 'SALIDA'
		        OR PFE.DEPARTURE_TYPE = 'ENTRADA');
  	
  	RETURN CASE var_result
  					WHEN 'TRUE' THEN TRUE
  					WHEN 'FALSE' THEN FALSE
  					ELSE NULL
  				 END;
  END;
  
  
  FUNCTION IS_DEPARTURE_REGISTERED(P_TRAFFIC_NUMBER		NUMBER)
 	RETURN BOOLEAN
 	IS
 		var_result	VARCHAR2(20);
 	BEGIN
 		
 		SELECT DECODE(COUNT(PFE.DEPARTURE_NUMBER),
		              0, 'FALSE',
		              'TRUE') 
		  INTO var_result
		  FROM APPS.PAC_FUEL_EC_DEPARTURES    PFE
		 WHERE PFE.DEPARTURE_NUMBER = P_TRAFFIC_NUMBER
		   AND PFE.DEPARTURE_TYPE = 'SALIDA'
		   AND (	 PFE.STATUS = 'REGISTRADO'
		   			OR PFE.STATUS = 'EN TRÁNSITO');
 		
  	RETURN CASE var_result
  					WHEN 'TRUE' THEN TRUE
  					WHEN 'FALSE' THEN FALSE
  					ELSE NULL
  				 END;
 		
 	END;
 	
 	FUNCTION IS_DEPARTURE_CLOSED(P_TRAFFIC_NUMBER		NUMBER)
 	RETURN BOOLEAN
 	IS
 		var_result	VARCHAR2(20);
 	BEGIN
 		
 		SELECT DECODE(COUNT(PFE.DEPARTURE_NUMBER),
		              0, 'FALSE',
		              'TRUE') 
			INTO var_result
		  FROM APPS.PAC_FUEL_EC_DEPARTURES    PFE
		 WHERE PFE.DEPARTURE_NUMBER = P_TRAFFIC_NUMBER
		   AND PFE.DEPARTURE_TYPE = 'SALIDA'
		   AND PFE.STATUS = 'EN TRÁNSITO';
		   
  	RETURN CASE var_result
  					WHEN 'TRUE' THEN TRUE
  					WHEN 'FALSE' THEN FALSE
  					ELSE NULL
  				 END;
 		
 	END;
 	
 	
 	FUNCTION IS_ARRIVAL_CLOSED(P_TRAFFIC_NUMBER		NUMBER)
 	RETURN BOOLEAN
 	IS
 		var_result	VARCHAR2(20);
 	BEGIN
 		
 		SELECT DECODE(COUNT(PFE.DEPARTURE_NUMBER),
                  0, 'FALSE',
                  'TRUE') 
		  INTO var_result
      FROM APPS.PAC_FUEL_EC_DEPARTURES    PFE
     WHERE PFE.DEPARTURE_NUMBER = P_TRAFFIC_NUMBER
       AND PFE.DEPARTURE_TYPE = 'ENTRADA'
       AND PFE.STATUS = 'CERRADO';
       
    RETURN CASE var_result
  					WHEN 'TRUE' THEN TRUE
  					WHEN 'FALSE' THEN FALSE
  					ELSE NULL
  				 END;   
 		
 	END;
 	
 	
 	FUNCTION IS_CANCELLED(p_traffic_number number) RETURN BOOLEAN
    IS
        var_result    varchar2(20);
    BEGIN 
        SELECT DECODE(COUNT(pfe.departure_number), 0, 'FALSE', 'TRUE') 
          INTO var_result
          FROM apps.pac_fuel_ec_departures pfe
         WHERE pfe.departure_number = p_traffic_number
           AND pfe.status = 'CANCELADO';
         
        RETURN CASE var_result WHEN 'TRUE' THEN TRUE
                               WHEN 'FALSE' THEN FALSE
                               ELSE NULL
               END;   
    END;
  
  
END;