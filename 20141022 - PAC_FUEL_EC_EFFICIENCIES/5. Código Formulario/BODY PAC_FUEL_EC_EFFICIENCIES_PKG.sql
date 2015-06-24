PACKAGE BODY PAC_FUEL_EC_EFFICIENCIES_PKG IS


		/*
			Función GET_ASSET_GROUP_DESCRIPTION, realiza la consulta del ASSET_GROUP 
			a partir del VEHICLE_ID.
		*/
    FUNCTION GET_ASSET_GROUP_DESCRIPTION(VEHICLE_ID VARCHAR2) RETURN VARCHAR2
    IS
        var_group_description      VARCHAR2(200);
        var_alert_number 					 NUMBER;
    BEGIN
       
        SELECT DISTINCT 
               MSIB.DESCRIPTION
          INTO var_group_description
          FROM MTL_SYSTEM_ITEMS_B    MSIB,
               CSI_ITEM_INSTANCES    CII
         WHERE MSIB.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
           AND CII.SERIAL_NUMBER = VEHICLE_ID;
        
        RETURN var_group_description;
    
    EXCEPTION WHEN OTHERS THEN
    	set_alert_property('ERROR_MSG', alert_message_text, 'GET_ASSET_GROUP_DESCRIPTION: ' || SQLERRM);
			var_alert_number := show_alert('ERROR_MSG');
			RAISE FORM_TRIGGER_FAILURE;   
    END;
    
    
		/*
			Procedimiento CLEAR_CONTROLS Realiza la limpieza de los datos de los campos 
			invocado desde el evento WHEN_VALIDATE_ITEM.
		*/    
    PROCEDURE CLEAR_CONTROLS(P_CONTROL VARCHAR2)
    IS
    BEGIN
    	
    	IF (P_CONTROL = 'AREA') THEN
    		:TRAFFIC_NUMBER := NULL;
    	END IF;
    	
    	:EFFICIENCY_ID := NULL;
    	:DEPARTURE_ID := NULL;
    	:ARRIVAL_ID	:= NULL;
    	:VEHICLE_ID := NULL;
    	:VEHICLE := NULL;
    	:VEHICLE_TYPE := NULL;
    	:LAST_READING := NULL;
    	:ACTUAL_READING := NULL;
    	:TRIP_DISTANCE := NULL;
    	:FUEL_TYPE := NULL;
    	:CONSUMED_FUEL := NULL;
    	:EXTERNAL_CONSUMED_FUEL := NULL;
    	:TOTAL_CONSUMED_FUEL := NULL;
    	:EXPECTED_TRIP_DISTANCE := NULL;
    	:EXPECTED_EFFICIENCY := NULL;
    	:REAL_EFFICIENCY := NULL;
    	:PREVIOUS_EFFICIENCY_ID := NULL;
    	:CREATION_DATE := NULL;
    	:CREATED_BY := NULL;
    	:LAST_UPDATE_DATE := NULL;
    	:LAST_UPDATED_BY := NULL;
    	:ATTRIBUTE1 := NULL;
    	:ATTRIBUTE2 := NULL;
    	:ATTRIBUTE3 := NULL;
    	:ATTRIBUTE4 := NULL;
    	:ATTRIBUTE5 := NULL;
    	:ATTRIBUTE6 := NULL;
    	:ATTRIBUTE7 := NULL;
    	:ATTRIBUTE8 := NULL;
    	:ATTRIBUTE9 := NULL;
    	
    	PAC_FUEL_EC_EFFICIENCIES_PKG.SET_COLOR(0);
    	
    END;
    
    
    /*
	    Procedimiento CALCULATE_EFFICIENCY realiza:
	    	*Cálculo del Rendimiento
	    	*Variación de Rendimiento
	    	*Diferencia de Litros
	    en el procedimiento se realiza el cambio del BACKGROUND_COLOR.
    */
    PROCEDURE CALCULATE_EFFICIENCY
    AS
    	var_efficiency		NUMBER;
    	var_percent 			NUMBER;
    BEGIN
    	
    	--Calculo del rendimiento real.
    	var_efficiency := ROUND((:TRIP_DISTANCE / :TOTAL_CONSUMED_FUEL), 2);
    	:REAL_EFFICIENCY := var_efficiency;
    	
    	--Calculo de litros. (Reporte de Elda).
    	:ATTRIBUTE3 := ROUND((:TOTAL_CONSUMED_FUEL - (:TRIP_DISTANCE / :EXPECTED_EFFICIENCY)), 2);
    	
    	--Calculo de la Variación de Rendimeinto.
    	var_percent := ROUND(((:REAL_EFFICIENCY * 100) / :EXPECTED_EFFICIENCY), 0);
    	:ATTRIBUTE2 := var_percent || '%';
    	
    	--Cambio de color del elemento ATTRIBUTE2.
    	PAC_FUEL_EC_EFFICIENCIES_PKG.SET_COLOR(var_percent);
    
    EXCEPTION WHEN ZERO_DIVIDE THEN
    	MESSAGE('Cálculo de rendimiento pendiente.');
    END;
    
    
    /*
	    Procedimiento ENABLED_CONTROLS, realiza el bloque de los elementos TEXT_ITEM 
	    de la interfaz de usuario.
    */
    PROCEDURE ENABLED_CONTROLS(P_AREA VARCHAR2)
    IS
    BEGIN
    	
    	app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.CREATION_DATE', ENABLED, PROPERTY_OFF);
			app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.VEHICLE', ENABLED, PROPERTY_OFF);
			app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.VEHICLE_TYPE', ENABLED, PROPERTY_OFF);
			app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.TOTAL_CONSUMED_FUEL', ENABLED, PROPERTY_OFF);
			app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.LAST_READING', ENABLED, PROPERTY_OFF);
			app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.TRIP_DISTANCE', ENABLED, PROPERTY_OFF);
			app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.EXPECTED_TRIP_DISTANCE', ENABLED, PROPERTY_OFF);
			app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.REAL_EFFICIENCY', ENABLED, PROPERTY_OFF);
			app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.EXPECTED_EFFICIENCY', ENABLED, PROPERTY_OFF);
			app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE3', ENABLED, PROPERTY_OFF);
			app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE2', ENABLED, PROPERTY_OFF); 	
			app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE5', ENABLED, PROPERTY_OFF);
    		
    	IF P_AREA = 'REPARTO' THEN
    		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.VEHICLE_ID', ENABLED, PROPERTY_OFF);
    		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.VEHICLE_ID', LOV_NAME, '');
    		
    		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE1', ENABLED, PROPERTY_ON);
    		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE6', ENABLED, PROPERTY_ON);
    		
    		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE1', LOV_NAME, 'PAC_FUEL_EC_DESTINO');
    		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE6', LOV_NAME, 'PAC_FUEL_EC_CARGA');
    	ELSIF P_AREA <> 'REPARTO' THEN
    		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.VEHICLE_ID', ENABLED, PROPERTY_ON);
    		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.VEHICLE_ID', LOV_NAME, 'PAC_FUEL_EC_VEHICLE_LOV');
    		
    		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE1', ENABLED, PROPERTY_OFF);
    		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE6', ENABLED, PROPERTY_OFF);
    		
    		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE1', LOV_NAME, '');
    		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE6', LOV_NAME, '');
    	END IF;
    	
    END;
    
  
  	/*
  		Procedimiento VALIDATE_AREA del evento WHEN-VALIDATE_ITEM, consulta el SYSDATE 
  		cuando el AREA es diferente de REPARTO y el CREATION_DATE del 
  		PAC_FUEL_EC_EFFICIENCIES cuando el area es REPARTO.
  	*/
	  PROCEDURE VALIDATE_AREA
	  IS
	  BEGIN
		
			PAC_FUEL_EC_EFFICIENCIES_PKG.CLEAR_CONTROLS('AREA');
			PAC_FUEL_EC_EFFICIENCIES_PKG.ENABLED_CONTROLS(:AREA);
		
			IF :AREA = 'REPARTO' THEN
		
				:CREATION_DATE := NULL;
		
			END IF;
		
		END;
  
  
	  /*
	  	Procedimiento VALIDATE_TRAFFIC_NUMBER del evento WHEN-VALIDATE_ITEM.
	  	Realiza la consulta de los campos de PAC_FUEL_EC_EFFICIENCIES,
	  	se encarga tambien de realizar la consulta de los rendimientos 
	  	esperado en XXCALV_REND_X_DESTINO.
	  */
	  PROCEDURE VALIDATE_TRAFFIC_NUMBER
		IS
			var_alert_number					NUMBER;
			var_group_description			VARCHAR2(200);
			var_course								VARCHAR2(500);
			var_driver_name						VARCHAR2(200);
			var_trailer_type					VARCHAR2(500);
			var_box_number						NUMBER;
			var_meter_id							NUMBER;
		BEGIN
			
			PAC_FUEL_EC_EFFICIENCIES_PKG.CLEAR_CONTROLS('TRAFFIC_NUMBER');
			PAC_FUEL_EC_EFFICIENCIES_PKG.ENABLED_CONTROLS(:AREA);
			
			IF :TRAFFIC_NUMBER IS NOT NULL THEN	
				IF :AREA = 'REPARTO' THEN
				 	
				 	
			 		--Consulta de elmentos 
			 			--DEPARTURE_ID, 
			 			--VEHICLE_ID, 
			 			--VEHICLE, 
			 			--VEHICLE_TYPE, 
			 			--CREATION_DATE
			 		--de la tabla PAC_FUEL_EC_EFFICIENCIES
					BEGIN
					
					 	SELECT PFEE.EFFICIENCY_ID,
					 				 PFEE.DEPARTURE_ID,
					 				 PFEE.ARRIVAL_ID,
					  			 PFEE.VEHICLE_ID,
					  			 PFEE.VEHICLE,
					  			 PFEE.VEHICLE_TYPE,
					  			 PFEE.LAST_READING,
					  			 PFEE.ACTUAL_READING,
					  			 PFEE.TRIP_DISTANCE,
					  			 PFEE.FUEL_TYPE,
					  			 PFEE.CONSUMED_FUEL,
					  			 PFEE.EXTERNAL_CONSUMED_FUEL,
					  			 PFEE.TOTAL_CONSUMED_FUEL,
					  			 PFEE.EXPECTED_TRIP_DISTANCE,
					  			 PFEE.EXPECTED_EFFICIENCY,
					  			 PFEE.REAL_EFFICIENCY,
					  			 PFEE.PREVIOUS_EFFICIENCY_ID,
					  			 PFEE.CREATION_DATE,
					  			 PFEE.ATTRIBUTE1,
					  			 PFEE.ATTRIBUTE2,
					  			 PFEE.ATTRIBUTE3,
					  			 PFEE.ATTRIBUTE4,
					  			 PFEE.ATTRIBUTE5,
					  			 PFEE.ATTRIBUTE6,
					  			 PFEE.ATTRIBUTE7,
					  			 PFEE.ATTRIBUTE8,
					  			 PFEE.ATTRIBUTE9
					  	INTO :EFFICIENCY_ID,
					 				 :DEPARTURE_ID,
					 				 :ARRIVAL_ID,
					  			 :VEHICLE_ID,
					  			 :VEHICLE,
					  			 :VEHICLE_TYPE,
					  			 :LAST_READING,
					  			 :ACTUAL_READING,
					  			 :TRIP_DISTANCE,
					  			 :FUEL_TYPE,
					  			 :CONSUMED_FUEL,
					  			 :EXTERNAL_CONSUMED_FUEL,
					  			 :TOTAL_CONSUMED_FUEL,
					  			 :EXPECTED_TRIP_DISTANCE,
					  			 :EXPECTED_EFFICIENCY,
					  			 :REAL_EFFICIENCY,
					  			 :PREVIOUS_EFFICIENCY_ID,
					  			 :CREATION_DATE,
					  			 :ATTRIBUTE1,
					  			 :ATTRIBUTE2,
					  			 :ATTRIBUTE3,
					  			 :ATTRIBUTE4,
					  			 :ATTRIBUTE5,
					  			 :ATTRIBUTE6,
					  			 :ATTRIBUTE7,
					  			 :ATTRIBUTE8,
					  			 :ATTRIBUTE9
					    FROM PAC_FUEL_EC_EFFICIENCIES	PFEE
					   WHERE PFEE.TRAFFIC_NUMBER = :TRAFFIC_NUMBER
					   	 AND PFEE.AREA = 'REPARTO'
					     AND PFEE.EFFICIENCY_ID = (SELECT MAX(EFFICIENCY_ID)
					     														 FROM PAC_FUEL_EC_EFFICIENCIES PFEE1
					     														WHERE PFEE1.TRAFFIC_NUMBER = :TRAFFIC_NUMBER
					     														  AND EXTRACT(YEAR FROM PFEE1.CREATION_DATE) = EXTRACT(YEAR FROM SYSDATE));
					     														  
					EXCEPTION WHEN OTHERS THEN
			    	set_alert_property('ERROR_MSG', 
			    										 alert_message_text, 
			    										 PAC_VALIDATE_PKG.VALIDATE_TRAFFIC_NUMBER(:TRAFFIC_NUMBER));
						var_alert_number := show_alert('ERROR_MSG');
						RAISE FORM_TRIGGER_FAILURE;				     														  
					END;				     			
					
					
					--Consulta en la tabla PAC_FUEL_EC_EDEPARTURES,
					--Si no se encuentra el registro de ENTRADA a partir del
					--del folio se genera la excepción NO_DATA_FOUND y se envia 
					--la alerta.
					IF :ARRIVAL_ID IS NULL THEN
						BEGIN
													
								SELECT PFED.DEPARTURE_ID
							  	INTO :ARRIVAL_ID
							  	FROM PAC_FUEL_EC_DEPARTURES	PFED
							 	 WHERE PFED.DEPARTURE_NUMBER = :TRAFFIC_NUMBER
							   	 AND PFED.DEPARTURE_TYPE = 'ENTRADA'
							   	 AND EXTRACT(YEAR FROM PFED.CREATION_DATE) = EXTRACT(YEAR FROM SYSDATE);
						   	 
					  EXCEPTION WHEN OTHERS THEN
				    	set_alert_property('ERROR_MSG', 
				    										 alert_message_text, 
				    										 'No se ha encontrado el registro de entrada de verificación.');
							var_alert_number := show_alert('ERROR_MSG');
							RAISE FORM_TRIGGER_FAILURE;
					 	END;
				  END IF;   							
								
					--Consulta de Combustible.
					IF :FUEL_TYPE IS NULL THEN
						BEGIN
						
							SELECT DISTINCT
										 ATTRIBUTE10
							  INTO :FUEL_TYPE
							  FROM CSI_ITEM_INSTANCES		CII
							 WHERE CII.SERIAL_NUMBER = :VEHICLE_ID;
							 
						EXCEPTION WHEN OTHERS THEN
							MESSAGE('Sin registro de combustible.');
						END;
					END IF;			
							
										
					--Consulta de elementos para la consulta de 
					--rendimiento esperados.
					BEGIN
						
						SELECT PFED.TO_ORG_NAME,
									 PFED.TRAILER_TYPE,
									 PFED.BOX_NUMBER,
									 PFED.DRIVER_NAME
							INTO var_course,
									 var_trailer_type,
									 var_box_number,
									 var_driver_name
						  FROM PAC_FUEL_EC_DEPARTURES	PFED
						 WHERE PFED.DEPARTURE_NUMBER = :TRAFFIC_NUMBER
						   AND PFED.DEPARTURE_ID = :DEPARTURE_ID
						   AND PFED.DEPARTURE_TYPE = 'SALIDA';
						   
						IF :ATTRIBUTE1 IS NULL OR :ATTRIBUTE1 = 'N' THEN
							:ATTRIBUTE1 := var_course;
						END IF;
						
						:ATTRIBUTE5 := var_driver_name;
						
						IF :ATTRIBUTE6 IS NULL THEN
							:ATTRIBUTE6 := var_trailer_type;
						END IF;
						
						:ATTRIBUTE7 := var_box_number;
						   
					EXCEPTION WHEN OTHERS THEN
			    	set_alert_property('ERROR_MSG', 
			    										 alert_message_text, 
			    										 'Error al Consultar los datos del registro de salida correspondiente al vale '
			    										 || :TRAFFIC_NUMBER 
			    										 || ': ' 
			    										 || SQLERRM);
						var_alert_number := show_alert('ERROR_MSG');
						RAISE FORM_TRIGGER_FAILURE;
					END;
					 
					var_group_description := PAC_FUEL_EC_EFFICIENCIES_PKG.GET_ASSET_GROUP_DESCRIPTION(:VEHICLE_ID);
					:ATTRIBUTE8 := var_group_description;
					  
					--Consulta de rendimientos esperados 
					PAC_FUEL_EC_EFFICIENCIES_PKG.GET_EFFICIENCY_EXPECTED;
					
					
					--Consulta del registro previo al registro actual.
					IF :PREVIOUS_EFFICIENCY_ID IS NULL THEN
						BEGIN
							
							SELECT NVL(MAX(PFEE.EFFICIENCY_ID), 0)
		       			INTO :PREVIOUS_EFFICIENCY_ID
		  					FROM PAC_FUEL_EC_EFFICIENCIES    PFEE
		 					 WHERE PFEE.VEHICLE_ID = :VEHICLE_ID
		  					 AND PFEE.TRAFFIC_NUMBER <> :TRAFFIC_NUMBER
		  					 AND EXTRACT(YEAR FROM PFEE.CREATION_DATE) = EXTRACT(YEAR FROM SYSDATE);
							 
						EXCEPTION WHEN NO_DATA_FOUND THEN
							MESSAGE('Registro inicial');
							:PREVIOUS_EFFICIENCY_ID := 0;
						END;
					END IF;
					
					
					IF 	 :LAST_READING IS NULL 
						OR :LAST_READING = '0'
						OR :LAST_READING = 0 THEN
							BEGIN
								
	 							 	var_meter_id := PAC_FUEL_EFFICIENCY.FIND_METER_ID(:VEHICLE_ID);
	 								:LAST_READING := PAC_FUEL_EFFICIENCY.GET_METER_READING(var_meter_id);
								   
								 
							EXCEPTION WHEN NO_DATA_FOUND THEN
								set_alert_property('ERROR_MSG', 
																	 alert_message_text, 
																	 'No se ha podido consultar la lectura anterior del kilometraje de la unidad '
																	 || :VEHICLE_ID); 
								var_alert_number := show_alert('ERROR_MSG');
								RAISE FORM_TRIGGER_FAILURE;
							END;				
					END IF;
					
					PAC_FUEL_EC_EFFICIENCIES_PKG.CHECK_STATUS_BY_CONTROL();
			
				ELSIF :AREA <> 'REPARTO' THEN
				BEGIN			
					
						SELECT PFEC.EFFICIENCY_ID,
									 PFEC.DEPARTURE_ID,
									 PFEC.ARRIVAL_ID,
									 PFEC.TRAFFIC_NUMBER,
									 PFEC.AREA,
									 PFEC.VEHICLE_ID,
									 PFEC.VEHICLE,
									 PFEC.VEHICLE_TYPE,
									 PFEC.LAST_READING,
									 PFEC.ACTUAL_READING,
									 PFEC.TRIP_DISTANCE,
									 PFEC.FUEL_TYPE,
									 PFEC.CONSUMED_FUEL,
									 PFEC.EXTERNAL_CONSUMED_FUEL,
									 PFEC.TOTAL_CONSUMED_FUEL,
									 PFEC.EXPECTED_TRIP_DISTANCE,
									 PFEC.EXPECTED_EFFICIENCY,
									 PFEC.REAL_EFFICIENCY,
									 PFEC.PREVIOUS_EFFICIENCY_ID,
									 PFEC.CREATION_DATE,
									 PFEC.CREATED_BY,
									 PFEC.ATTRIBUTE1,
									 PFEC.ATTRIBUTE2,
									 PFEC.ATTRIBUTE3,
									 PFEC.ATTRIBUTE4,
									 PFEC.ATTRIBUTE5,
									 PFEC.ATTRIBUTE6,
									 PFEC.ATTRIBUTE7,
									 PFEC.ATTRIBUTE8,
									 PFEC.ATTRIBUTE9
							INTO :EFFICIENCY_ID,
									 :DEPARTURE_ID,
									 :ARRIVAL_ID,
									 :TRAFFIC_NUMBER,
									 :AREA,
									 :VEHICLE_ID,
									 :VEHICLE,
									 :VEHICLE_TYPE,
									 :LAST_READING,
									 :ACTUAL_READING,
									 :TRIP_DISTANCE,
									 :FUEL_TYPE,
									 :CONSUMED_FUEL,
									 :EXTERNAL_CONSUMED_FUEL,
									 :TOTAL_CONSUMED_FUEL,
									 :EXPECTED_TRIP_DISTANCE,
									 :EXPECTED_EFFICIENCY,
									 :REAL_EFFICIENCY,
									 :PREVIOUS_EFFICIENCY_ID,
									 :CREATION_DATE,
									 :CREATED_BY,
									 :ATTRIBUTE1,
									 :ATTRIBUTE2,
									 :ATTRIBUTE3,
									 :ATTRIBUTE4,
									 :ATTRIBUTE5,
									 :ATTRIBUTE6,
									 :ATTRIBUTE7,
									 :ATTRIBUTE8,
									 :ATTRIBUTE9
						  FROM PAC_FUEL_EC_EFFICIENCIES PFEC
						 WHERE PFEC.AREA = :AREA
						   AND PFEC.TRAFFIC_NUMBER = :TRAFFIC_NUMBER
						   AND EXTRACT(YEAR FROM CREATION_DATE) = EXTRACT(YEAR FROM SYSDATE);
					MESSAGE('Registro consultado...');		   
				EXCEPTION WHEN NO_DATA_FOUND THEN
					MESSAGE('Creando un registro nuevo...');
				END;				
				END IF;
			END IF;	
					
		END;
  
  
	  
	  
	  
	  /*
	  	Procedimiento VALIDATE_CONSUMED_FUEL del WHEN-VALIDATE-ITEM. realiza la suma
	  	del campo CONSUMED_FUEL + EXTERNAL_CONSUMED_FUEL, posteriormente realiza
	  	el cálculo del rendimiento.
	  */
	  PROCEDURE VALIDATE_CONSUMED_FUEL
	  IS
	  BEGIN
			
			IF :CONSUMED_FUEL IS NULL THEN
				:CONSUMED_FUEL := 0;
			END IF;
			
			IF :EXTERNAL_CONSUMED_FUEL IS NULL THEN
				:EXTERNAL_CONSUMED_FUEL := 0;
			END IF;
			
			IF :ACTUAL_READING IS NULL THEN
				:ACTUAL_READING := 0;
			END IF;
			
			:TOTAL_CONSUMED_FUEL := :CONSUMED_FUEL + :EXTERNAL_CONSUMED_FUEL;
			
			--Calculo del rendimiento.
			PAC_FUEL_EC_EFFICIENCIES_PKG.CALCULATE_EFFICIENCY();
			
		END;
	  
	  
	  /*
	  	Procedimiento VALIDATE_ACTUAL_READING del evento WHEN-VALIDATE-ITEM. Realiza el cálculo
	  	del TRIP_DISTANCE, y ejecuta el cálculo del rendimiento.
	  */
	  PROCEDURE VALIDATE_ACTUAL_READING
	  IS
	  BEGIN
			
			IF :LAST_READING IS NULL THEN
				:LAST_READING := 0;
			END IF;
			
			:TRIP_DISTANCE := :ACTUAL_READING - :LAST_READING;
			
			--Calculo del rendimiento.
			PAC_FUEL_EC_EFFICIENCIES_PKG.CALCULATE_EFFICIENCY();
			
	  END;
	  
	  
	  /*
	  	Procedimiento SET_COLOR, establece el color a partir del Porcentaje dado.
	  */
	  PROCEDURE SET_COLOR(P_PERCENT NUMBER)
	  IS
	  	var_alert_number	NUMBER;
	  BEGIN
	    	
	  	BEGIN
	  	
		  		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE2', ENABLED, PROPERTY_TRUE);
		  	
		  		IF		(P_PERCENT >= 100) THEN
		  			set_item_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE2', BACKGROUND_COLOR, 'r0g255b0');
		  		ELSIF (P_PERCENT < 100 AND P_PERCENT > 0) THEN
		  			set_item_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE2', BACKGROUND_COLOR, 'r255g0b0');
		  		ELSIF (P_PERCENT = 0) THEN
		    		set_item_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE2', BACKGROUND_COLOR, 'r255g255b255');
		  		END IF;
		  	
		  		--IF 		(P_PERCENT > 120) THEN
		    		--set_item_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE2', BACKGROUND_COLOR, 'r255g0b0');
		    	--ELSIF (P_PERCENT > 110 	AND P_PERCENT <= 120) THEN
		    		--set_item_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE2', BACKGROUND_COLOR, 'r255g255b0');
		    	--ELSIF (P_PERCENT > 90 	AND P_PERCENT <= 110) THEN
		    		--set_item_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE2', BACKGROUND_COLOR, 'r0g255b0');
		    	--ELSIF (P_PERCENT > 80 	AND P_PERCENT <= 90) THEN
		    		--set_item_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE2', BACKGROUND_COLOR, 'r255g255b0');
		    	--ELSIF (P_PERCENT >= 1  AND P_PERCENT <= 80) THEN
		    		--set_item_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE2', BACKGROUND_COLOR, 'r255g0b0');
		    	--ELSIF (P_PERCENT = 0) THEN
		    		--set_item_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE2', BACKGROUND_COLOR, 'r255g255b255');
		    	--END IF;
	  	
		    	app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE2', ENABLED, PROPERTY_FALSE);
		    	
    	EXCEPTION WHEN OTHERS THEN
				set_alert_property('ERROR_MSG', alert_message_text, 'SET_COLOR: ' || SQLERRM);
				var_alert_number := show_alert('ERROR_MSG');
				RAISE FORM_TRIGGER_FAILURE;
    	END;
	  	
	  END;
	  
	  
	  /*
	  	Realiza la inserción del registro cuando el EFFICIENCY_ID es NULL y la actualización del
	  	registro cuando ya tiene un ID el registro.
	  */
	  PROCEDURE ON_SAVE_PROCEDURE
	  IS
	  	var_alert_number 		NUMBER;
	  BEGIN
	  	  
	  	--Registro sin validar y bloquear.
	  	IF :ATTRIBUTE4 IS NULL THEN
	  		:ATTRIBUTE4 := 'N';
	  	END IF;

	  	
	  	IF :EFFICIENCY_ID IS NULL THEN
						
				--Selección 
				SELECT PAC_FUEL_EC_EFFICIENCIES_SEQ.NEXTVAL
				  INTO :EFFICIENCY_ID
				  FROM DUAL;
						  
	  		BEGIN
	  		
					INSERT INTO PAC_FUEL_EC_EFFICIENCIES(EFFICIENCY_ID,
																							 DEPARTURE_ID,
																							 ARRIVAL_ID,
																							 TRAFFIC_NUMBER,
																							 AREA,
																							 VEHICLE_ID,
																							 VEHICLE,
																							 VEHICLE_TYPE,
																							 LAST_READING,
																							 ACTUAL_READING,
																							 TRIP_DISTANCE,
																							 FUEL_TYPE,
																							 CONSUMED_FUEL,
																							 EXTERNAL_CONSUMED_FUEL,
																							 TOTAL_CONSUMED_FUEL,
																							 EXPECTED_TRIP_DISTANCE,
																							 EXPECTED_EFFICIENCY,
																							 REAL_EFFICIENCY,
																							 PREVIOUS_EFFICIENCY_ID,
																							 CREATION_DATE,
																							 CREATED_BY,
																							 LAST_UPDATE_DATE,
																							 LAST_UPDATED_BY,
																							 ATTRIBUTE1,
																							 ATTRIBUTE2,
																							 ATTRIBUTE3,
																							 ATTRIBUTE4,
																							 ATTRIBUTE5,
																							 ATTRIBUTE6,
																							 ATTRIBUTE7,
																							 ATTRIBUTE8,
																							 ATTRIBUTE9)
																			VALUES (:EFFICIENCY_ID,
																							:DEPARTURE_ID,
																							:ARRIVAL_ID,
																							:TRAFFIC_NUMBER,
																							:AREA,
																							:VEHICLE_ID,
																							:VEHICLE,
																							:VEHICLE_TYPE,
																							:LAST_READING,
																							:ACTUAL_READING,
																							:TRIP_DISTANCE,
																							:FUEL_TYPE,
																							:CONSUMED_FUEL,
																							:EXTERNAL_CONSUMED_FUEL,
																							:TOTAL_CONSUMED_FUEL,
																							:EXPECTED_TRIP_DISTANCE,
																							:EXPECTED_EFFICIENCY,
																							:REAL_EFFICIENCY,
																							:PREVIOUS_EFFICIENCY_ID,
																							SYSDATE,
																							FND_GLOBAL.USER_ID,
																							SYSDATE,
																							FND_GLOBAL.USER_ID,
																							:ATTRIBUTE1,
																							:ATTRIBUTE2,
																							:ATTRIBUTE3,
																							:ATTRIBUTE4,
																							:ATTRIBUTE5,
																							:ATTRIBUTE6,
																							:ATTRIBUTE7,
																							:ATTRIBUTE8,
																							:ATTRIBUTE9);	
																							
				EXCEPTION WHEN OTHERS THEN
			    	set_alert_property('ERROR_MSG', alert_message_text, 'ON_SAVE_PROCEDURE INSERT: ' || SQLERRM);
						var_alert_number := show_alert('ERROR_MSG');
						RAISE FORM_TRIGGER_FAILURE;																							
				END;																											
			
	  	ELSE
	  		
	  		BEGIN
	  		
		  		UPDATE PAC_FUEL_EC_EFFICIENCIES
		  		   SET ARRIVAL_ID = :ARRIVAL_ID,
								 TRAFFIC_NUMBER = :TRAFFIC_NUMBER,
								 AREA = :AREA,
								 VEHICLE_ID = :VEHICLE_ID,
								 VEHICLE = :VEHICLE,
								 VEHICLE_TYPE = :VEHICLE_TYPE,
								 LAST_READING = :LAST_READING,
								 ACTUAL_READING = :ACTUAL_READING,
								 TRIP_DISTANCE = :TRIP_DISTANCE,
								 FUEL_TYPE = :FUEL_TYPE,
								 CONSUMED_FUEL = :CONSUMED_FUEL,
								 EXTERNAL_CONSUMED_FUEL = :EXTERNAL_CONSUMED_FUEL,
								 TOTAL_CONSUMED_FUEL = :TOTAL_CONSUMED_FUEL,
								 EXPECTED_TRIP_DISTANCE = :EXPECTED_TRIP_DISTANCE,
								 EXPECTED_EFFICIENCY = :EXPECTED_EFFICIENCY,
								 REAL_EFFICIENCY = :REAL_EFFICIENCY,
								 PREVIOUS_EFFICIENCY_ID = :PREVIOUS_EFFICIENCY_ID,
								 LAST_UPDATE_DATE = SYSDATE,
								 LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
								 ATTRIBUTE1 = :ATTRIBUTE1,
								 ATTRIBUTE2 = :ATTRIBUTE2,
								 ATTRIBUTE3 = :ATTRIBUTE3,
								 ATTRIBUTE4 = :ATTRIBUTE4,
								 ATTRIBUTE5 = :ATTRIBUTE5,
								 ATTRIBUTE6 = :ATTRIBUTE6,
								 ATTRIBUTE7 = :ATTRIBUTE7,
								 ATTRIBUTE8 = :ATTRIBUTE8,
						     ATTRIBUTE9 = :ATTRIBUTE9
		  		 WHERE EFFICIENCY_ID = :EFFICIENCY_ID
		  		   AND TRAFFIC_NUMBER = :TRAFFIC_NUMBER;
		  		 
		  	EXCEPTION WHEN OTHERS THEN
		    	set_alert_property('ERROR_MSG', alert_message_text, 'ON_SAVE_PROCEDURE UPDATE: ' || SQLERRM);
					var_alert_number := show_alert('ERROR_MSG');
					RAISE FORM_TRIGGER_FAILURE;
				END;
	  		
			END IF;
	  	
	  END;
	  
	  
	  /*
	  	Procedimiento CHECK_STATUS, realiza el bloqueo y desbloque de las propiedades
	  	INSERT_ALLOW,
	  	DELETE_ALLOW,
	  	UPDATE_ALLOW
	  */
	  PROCEDURE CHECK_STATUS
	  IS
	  BEGIN
	  	
	  	IF (:ATTRIBUTE4 IS NULL OR :ATTRIBUTE4 = 'N') THEN
	  		--SET_BLOCK_PROPERTY('PAC_FUEL_EC_EFFICIENCIES', INSERT_ALLOWED, PROPERTY_TRUE);
	  		SET_BLOCK_PROPERTY('PAC_FUEL_EC_EFFICIENCIES', UPDATE_ALLOWED, PROPERTY_TRUE);
	  		app_item_property.set_property('CONTROL.BTN_VALIDATE', ENABLED, PROPERTY_ON);
	  	ELSIF (:ATTRIBUTE4 = 'Y') THEN
	  		--SET_BLOCK_PROPERTY('PAC_FUEL_EC_EFFICIENCIES', INSERT_ALLOWED, PROPERTY_FALSE);
	  		SET_BLOCK_PROPERTY('PAC_FUEL_EC_EFFICIENCIES', UPDATE_ALLOWED, PROPERTY_FALSE);
	  		app_item_property.set_property('CONTROL.BTN_VALIDATE', ENABLED, PROPERTY_OFF);
	  	END IF;
	  	
	  END;
	  
	  
	  /*
	  	Procedimiento CHECK_STATUS, realiza el bloqueo y desbloque de las propiedades
	  	INSERT_ALLOW,
	  	DELETE_ALLOW,
	  	UPDATE_ALLOW
	  */
	  PROCEDURE CHECK_STATUS_BY_CONTROL
	  IS
	  BEGIN
	  	
	  	IF (:ATTRIBUTE4 IS NULL OR :ATTRIBUTE4 = 'N') THEN
	  		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.AREA', ENABLED, PROPERTY_ON);
	  		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.TRAFFIC_NUMBER', ENABLED, PROPERTY_ON);
	  		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.CONSUMED_FUEL', ENABLED, PROPERTY_ON);
	  		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.EXTERNAL_CONSUMED_FUEL', ENABLED, PROPERTY_ON);
	  		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ACTUAL_READING', ENABLED, PROPERTY_ON);
	  		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE1', ENABLED, PROPERTY_ON);
    		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE6', ENABLED, PROPERTY_ON);
	  		app_item_property.set_property('CONTROL.BTN_VALIDATE', ENABLED, PROPERTY_ON);
	  	ELSIF (:ATTRIBUTE4 = 'Y') THEN
	  		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.AREA', ENABLED, PROPERTY_OFF);
	  		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.TRAFFIC_NUMBER', ENABLED, PROPERTY_OFF);
	  		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.VEHICLE_ID', ENABLED, PROPERTY_OFF);
	  		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.FUEL_TYPE', ENABLED, PROPERTY_OFF);
	  		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.CONSUMED_FUEL', ENABLED, PROPERTY_OFF);
	  		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.EXTERNAL_CONSUMED_FUEL', ENABLED, PROPERTY_OFF);
	  		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ACTUAL_READING', ENABLED, PROPERTY_OFF);
	  		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE1', ENABLED, PROPERTY_OFF);
    		app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE6', ENABLED, PROPERTY_OFF);
	  		app_item_property.set_property('CONTROL.BTN_VALIDATE', ENABLED, PROPERTY_OFF);
	  	END IF;
	  	
			IF (:AREA IS NULL OR :AREA <> 'REPARTO') THEN
  			app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.VEHICLE_ID', ENABLED, PROPERTY_ON);
			ELSE
				app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.VEHICLE_ID', ENABLED, PROPERTY_OFF);
			END IF;
			
  		IF (:FUEL_TYPE IS NULL) THEN
  			app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.FUEL_TYPE', ENABLED, PROPERTY_ON);
  		ELSE
  			app_item_property.set_property('PAC_FUEL_EC_EFFICIENCIES.FUEL_TYPE', ENABLED, PROPERTY_OFF);
  		END IF;
	  	
	  END;
	  
	  
	  /*
	  	Procedimiento BUTTON_PRESSED, del evento WHEN-BUTTON_PRESSED, usado para validar y 
	  	realizar el bloqueo del registro.
	  */
	  PROCEDURE BUTTON_PRESSED
	  IS
	  		var_alert_number		NUMBER;
	  		var_alert_button		NUMBER;
	  BEGIN
	  	
	  	IF (VALIDATE_FORM() = TRUE) THEN

	  		SET_BLOCK_PROPERTY('PAC_FUEL_EC_EFFICIENCIES',ONETIME_WHERE,'EFFICIENCY_ID='||:EFFICIENCY_ID);
				GO_BLOCK('PAC_FUEL_EC_EFFICIENCIES');
				EXECUTE_QUERY;

	  		IF :SYSTEM.FORM_STATUS = 'CHANGED' THEN
		  		--Actualización de Kilometraje en EAM.
		  		var_alert_button := show_alert('SAVE');
		  		
					IF var_alert_button = ALERT_BUTTON1 THEN		  		
			  		PAC_FUEL_EFFICIENCY.increase_hierarchy_counter (:VEHICLE_ID,
																														:TRIP_DISTANCE,
																														:ATTRIBUTE1);
			  		
			  		:PAC_FUEL_EC_EFFICIENCIES.ATTRIBUTE4 := 'Y';
		  			
		  			COMMIT_FORM;
	  			END IF;
	  		END IF;
	  	
	  	ELSE
	  		set_alert_property('ERROR_MSG', 
	  											 alert_message_text, 
	  											 'Falta alguno de los siguientes datos en el registro (:AREA, ' || 
	  											 ':TRAFFIC_NUMBER, ' || 
	  											 ':CREATION_DATE, ' || 
	  											 ':VEHICLE_ID, ' || 
	  											 ':VEHICLE, ' || 
	  											 ':VEHICLE_TYPE, ' || 
	  											 ':TOTAL_CONSUMED_FUEL, ' || 
	  											 ':TRIP_DISTANCE).');
				var_alert_number := show_alert('ERROR_MSG');
	  	END IF;
	  	
	  EXCEPTION WHEN OTHERS THEN
	  	
  			set_alert_property('ERROR_MSG', alert_message_text, 'ON_BUTTON_PRESEED: ' || SQLERRM);
				var_alert_number := show_alert('ERROR_MSG');
				RAISE FORM_TRIGGER_FAILURE;
	  	
	  END;
	  
	  
	  /*
	  	Función VALIDATE_FORM encargada de realizar la validación y bloqueo del
	  	registro. 	
	  */
	  FUNCTION VALIDATE_FORM RETURN BOOLEAN
	  IS
	  	var_alert_number 	NUMBER;
	  BEGIN
	  	
	  	IF :AREA IS NULL THEN
	  		RETURN FALSE;
	  	END IF;
	  	
	  	IF :TRAFFIC_NUMBER IS NULL THEN
	  		RETURN FALSE;
	  	END IF;
	  	
	  	IF :CREATION_DATE IS NULL THEN
	  		RETURN FALSE;
	  	END IF;
	  	
	  	IF :VEHICLE_ID IS NULL THEN
	  		RETURN FALSE;
	  	END IF;
	  	
	  	IF :VEHICLE IS NULL THEN
	  		RETURN FALSE;
	  	END IF;
	  	
	  	IF :VEHICLE_TYPE IS NULL THEN
	  		RETURN FALSE;
	  	END IF;
	  	
	  	IF :TOTAL_CONSUMED_FUEL = 0 THEN
  			set_alert_property('ERROR_MSG', 
  												 alert_message_text, 
  												 'No se ha registrado el combustible consumido por la unidad.');
				var_alert_number := show_alert('ERROR_MSG');
				--RAISE FORM_TRIGGER_FAILURE;
				RETURN FALSE;
	  	END IF;
	  	
	  	IF :TRIP_DISTANCE <= 0 THEN
	  		set_alert_property('ERROR_MSG', 
  												 alert_message_text, 
  												 'No se ha registrado la lectura actual de kilometraje de la unidad.');
				var_alert_number := show_alert('ERROR_MSG');
				--RAISE FORM_TRIGGER_FAILURE;
				RETURN FALSE;
	  	END IF;
	  	
	  	RETURN TRUE;
	  END;
	   
	/*
		Procedimiento VALIDATE_VEHICLE_ID, valida el vehiculo para
		la funcionalidad de otros rendimientos.
	*/ 
	PROCEDURE VALIDATE_VEHICLE_ID IS
		var_group_description VARCHAR2(1000);
		var_alert_number			NUMBER;
	BEGIN
		
		IF :AREA <> 'REPARTO' THEN
			IF :CREATION_DATE IS NULL THEN			

				SELECT SYSDATE
					INTO :CREATION_DATE
				  FROM DUAL;	

			END IF;		
			
			BEGIN
							
					 SELECT CCR.COUNTER_READING
						 INTO :LAST_READING
             FROM APPS.CSI_ITEM_INSTANCES          CSI, 
                  APPS.CSI_COUNTER_ASSOCIATIONS    CCA,
                  APPS.CSI_COUNTER_READINGS        CCR,
          				APPS.CSI_COUNTERS_V              CCV                                    
            WHERE CSI.INSTANCE_ID = CCA.SOURCE_OBJECT_ID
              AND CCA.COUNTER_ID = CCR.COUNTER_ID
      				AND CCV.COUNTER_ID = CCR.COUNTER_ID
      				AND CCV.UOM_CODE = 'KM'
      				AND CCA.END_DATE_ACTIVE IS NULL
              AND CSI.INSTANCE_NUMBER = :VEHICLE_ID
              AND NVL (CCR.DISABLED_FLAG, 'N') = 'N'
              AND CCR.CREATION_DATE = (SELECT MAX(CCR1.CREATION_DATE)
                                         FROM APPS.CSI_ITEM_INSTANCES CSI1, 
                                              APPS.CSI_COUNTER_ASSOCIATIONS CCA1,
                                              APPS.CSI_COUNTER_READINGS CCR1
                                        WHERE CSI1.INSTANCE_ID = CCA1.SOURCE_OBJECT_ID
                                          AND CCA1.COUNTER_ID = CCR1.COUNTER_ID
                                          AND CSI1.INSTANCE_NUMBER = :VEHICLE_ID
                                          AND NVL (CCR1.DISABLED_FLAG, 'N') = 'N');
				 
			EXCEPTION WHEN NO_DATA_FOUND THEN
				set_alert_property('ERROR_MSG', 
													 alert_message_text, 
													 'No se ha podido consultar la lectura anterior del kilometraje de la unidad. '
													 || :VEHICLE_ID); 
				var_alert_number := show_alert('ERROR_MSG');
				RAISE FORM_TRIGGER_FAILURE;
			END;			
			
			var_group_description := PAC_FUEL_EC_EFFICIENCIES_PKG.GET_ASSET_GROUP_DESCRIPTION(:VEHICLE_ID);
			
			SELECT AVG(XRXD.RENDIMIENTO_ESPERA)
				INTO :EXPECTED_EFFICIENCY
			  FROM XXCALV_REND_X_DESTINO XRXD
			 WHERE DESTINO IS NULL
			   AND XRXD.GRUPO_UNIDAD = var_group_description;
			  
			IF :EFFICIENCY_ID IS NULL THEN	   
				
				SELECT MAX(PFEE.EFFICIENCY_ID)
			    INTO :PREVIOUS_EFFICIENCY_ID
					FROM PAC_FUEL_EC_EFFICIENCIES PFEE
				 WHERE PFEE.VEHICLE_ID = :VEHICLE_ID;
				 
			ELSIF :EFFICIENCY_ID IS NOT NULL THEN
				
				SELECT MAX(PFEE.EFFICIENCY_ID)
				  INTO :PREVIOUS_EFFICIENCY_ID
				  FROM PAC_FUEL_EC_EFFICIENCIES	PFEE
				 WHERE PFEE.VEHICLE_ID = :VEHICLE_ID
				   AND PFEE.EFFICIENCY_ID < :EFFICIENCY_ID;
				
			END IF;
						
		END IF;
		
	END;
	
	
	PROCEDURE GET_EFFICIENCY_EXPECTED
	IS 
			var_alert_number		NUMBER;
	BEGIN
		
		SELECT XRXD.RENDIMIENTO_ESPERA,
				 	 XRXD.KM_ESPERADOS
	  	INTO :EXPECTED_EFFICIENCY,
	  		 	 :EXPECTED_TRIP_DISTANCE
	  	FROM XXCALV_REND_X_DESTINO XRXD
	 	 WHERE XRXD.DESTINO IS NOT NULL
	 	 	 AND XRXD.GRUPO_UNIDAD = :ATTRIBUTE8
	   	 AND XRXD.DESTINO = :ATTRIBUTE1
	   	 AND XRXD.TIPO_CARGA = :ATTRIBUTE6
	   	 AND :ATTRIBUTE7 BETWEEN XRXD.CANTIDAD_CAJAS AND XRXD.CANTIDAD_CAJAS_R;
	   	 
	EXCEPTION 
		WHEN NO_DATA_FOUND THEN
			set_alert_property('ERROR_MSG', 
												 alert_message_text, 
												 'No se ha encontrado un rendimiento esperado que coincida con los valores: ' 
												 		|| chr(10) || 'Grupo de Activos: ' || :ATTRIBUTE8 	|| ', ' 
												 		|| chr(10) || 'Destino: ' 				 || :ATTRIBUTE1		|| ', ' 
												 		|| chr(10) || 'Tipo de Carga: ' 	 || :ATTRIBUTE6		|| ', ' 
												 		|| chr(10) || 'Cajas: '						 || :ATTRIBUTE7		|| '.');
			var_alert_number := show_alert('ERROR_MSG');
			RAISE FORM_TRIGGER_FAILURE;
		WHEN TOO_MANY_ROWS THEN
			set_alert_property('ERROR_MSG', 
												 alert_message_text, 
												 'Se ha encontrado más de un rendimiento esperado que coincide con los siguientes valores: ' 
												 		|| chr(10) || 'Grupo de Activos: ' || :ATTRIBUTE8 	|| ', ' 
												 		|| chr(10) || 'Destino: ' 				 || :ATTRIBUTE1		|| ', ' 
												 		|| chr(10) || 'Tipo de Carga: ' 	 || :ATTRIBUTE6		|| ', ' 
												 		|| chr(10) || 'Cajas: '						 || :ATTRIBUTE7		|| '.');
			var_alert_number := show_alert('ERROR_MSG');
			RAISE FORM_TRIGGER_FAILURE;
	END;

	 
END;