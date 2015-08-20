PACKAGE BODY XXCALV_LABELS_PKG IS

	/*=================================================================
	* Procedimiento para el manejo de eventos del bloque principal
	*=================================================================*/
  PROCEDURE label_header(event IN VARCHAR2) IS

	  --Curso para identificar grado
	  CURSOR c_grado(p_box_weight NUMBER) IS
	    SELECT grade_code, description
	    FROM  MTL_GRADES
	    WHERE DISABLE_FLAG = 'N'
	    AND substr(grade_code,instr(grade_code,' ')+1) = :LABEL_HEADER.ITEM_TYPE
	    AND NVL(ATTRIBUTE3,:LABEL_HEADER.BOX_TYPE) = :LABEL_HEADER.BOX_TYPE
	    AND p_box_weight BETWEEN ATTRIBUTE1 AND ATTRIBUTE2;
	    
	  --Cursor para identificar item pesado
	  CURSOR c_item IS
			SELECT msi.inventory_item_id, msi.primary_uom_code, msi.secondary_uom_code, mp.organization_code
			FROM mtl_system_items_b msi,
			     mtl_parameters mp
			WHERE 1 = 1
			AND mp.organization_id = msi.organization_id
			AND msi.organization_id = :LABEL_HEADER.TO_ORGANIZATION_ID
			AND msi.segment1 = :LABEL_HEADER.ITEM;
  
	  --Obtiene el batch donde sera consumida la etiqueta
	  CURSOR c_batch IS
      select gmd.batch_id, gmd.material_detail_id, gmd.line_no, gbh.batch_no, gmd.line_type,
             mp.organization_code
      from gme_batch_header gbh,
              gme_material_details gmd,
              fm_form_mst ffm,
              mtl_secondary_inventories msi,
              mtl_parameters mp
      where gmd.batch_id = gbh.batch_id
      and ffm.formula_id = gbh.formula_id
      and gbh.organization_id = :LABEL_HEADER.TO_ORGANIZATION_ID
      and gbh.batch_status = 2
      and gmd.line_type = -1
      and gmd.inventory_item_id = :LABEL_HEADER.INVENTORY_ITEM_ID
      and trunc(gbh.plan_start_date) = trunc(sysdate)
      and msi.organization_id =gbh.organization_id
      and msi.secondary_inventory_name = :LABEL_HEADER.TO_SUBINVENTORY
      and msi.attribute13 = ffm.formula_class
      and mp.organization_id = gbh.organization_id;  
    	
  BEGIN
  	
  	IF (Event = 'WHEN-VALIDATE-RECORD' ) THEN
  		
				BEGIN
				  IF :LABEL_HEADER.STATUS = 'CAPTURA' THEN 
				      
				      :LABEL_HEADER.INVENTORY_ITEM_ID := NULL;
				      
				      --Calcula Peso neto y peso por caja
				      :LABEL_HEADER.ORIGINAL_NET_WEIGHT := ROUND(:LABEL_HEADER.WEIGHT - (NVL(:LABEL_HEADER.TARE_WEIGHT,0) + (:LABEL_HEADER.BOX_QTY * NVL(:LABEL_HEADER.CONTAINER_WEIGHT,0))),4);
				      :LABEL_HEADER.UNROUNDED_BOX_WEIGHT := :LABEL_HEADER.ORIGINAL_NET_WEIGHT / :LABEL_HEADER.BOX_QTY;
				      :LABEL_HEADER.BOX_WEIGHT := ROUND(:LABEL_HEADER.ORIGINAL_NET_WEIGHT / :LABEL_HEADER.BOX_QTY,4);
				      
				      --Ajuste de peso por decimales
				      :LABEL_HEADER.NET_WEIGHT := :LABEL_HEADER.BOX_WEIGHT * :LABEL_HEADER.BOX_QTY;
				      :LABEL_HEADER.VARIANCE_WEIGHT := :LABEL_HEADER.ORIGINAL_NET_WEIGHT - :LABEL_HEADER.NET_WEIGHT;
				      
				      
				      --Calcula grado
				      OPEN c_grado(ROUND(:LABEL_HEADER.BOX_WEIGHT,2));
				      FETCH c_grado INTO :LABEL_HEADER.GRADE_CODE, :LABEL_HEADER.GRADE_DESC;
				      CLOSE c_grado;
				      
				      --Identificar articulo de bascula
				      OPEN c_item;
				      FETCH c_item INTO :LABEL_HEADER.INVENTORY_ITEM_ID, 
				                        :LABEL_HEADER.PRIMARY_UOM_CODE, 
				                        :LABEL_HEADER.SECONDARY_UOM_CODE,
				                        :LABEL_HEADER.TO_ORGANIZATION_CODE;
				      CLOSE c_item;
				      
				      IF :LABEL_HEADER.INVENTORY_ITEM_ID IS NULL THEN
							   FND_MESSAGE.Set_Name('FND','No es posible identificar el artículo con la combinación ingresada.');
								 FND_MESSAGE.Error;
								 RAISE form_trigger_failure;
				      END IF;

				  END IF;
				EXCEPTION
				 WHEN OTHERS THEN
				   FND_MESSAGE.Set_Name('FND','Error al identificar articulo: '|| SQLERRM);
					 FND_MESSAGE.Error;
					 RAISE form_trigger_failure;
				END;

  	ELSIF (Event = 'WHEN-NEW-RECORD-INSTANCE' ) THEN

  	   Set_item_property('LABEL_HEADER.REIMPRIMIR',enabled,property_false);
  	   Set_item_property('LABEL_HEADER.CANCELAR',enabled,property_false);
  	   Set_item_property('LABEL_HEADER.CONSUMIR',enabled,property_false);
    
			  --Activa botones de acuerdo al estatus de la etiqueta
			  IF :LABEL_HEADER.STATUS = 'ABIERTA' THEN
			     Set_item_property('LABEL_HEADER.REIMPRIMIR',enabled,property_true);	  		     
			     
			     IF FND_PROFILE.VALUE('PERMITIR_CANCELAR_ETIQUETA') = 'Y' THEN
			         Set_item_property('LABEL_HEADER.CANCELAR',enabled,property_true);
			     END IF;
			     
			     IF :PARAMETER.ESCANEO = 'YES' THEN
			        Set_item_property('LABEL_HEADER.CONSUMIR',enabled,property_true);
			     END IF;
			     --IF FND_PROFILE.VALUE('PERMITIR_ENVIAR_A_PISO') = 'Y' AND :PARAMETER.ESCANEO = 'NO' AND :PARAMETER.ORG_CODE = '200' THEN
			  	 --		Set_item_property('LABEL_HEADER.A_PISO',enabled,property_false);
			  	 --END IF;	
			  END IF;	 		  	 	
			  
			  IF :LABEL_HEADER.STATUS not in ('CANCELADA','INGRESADA') AND 
			  	FND_PROFILE.VALUE('PERMITIR_ENVIAR_A_PISO') = 'Y' AND :PARAMETER.ESCANEO = 'NO' AND :PARAMETER.ORG_CODE = '200' THEN
			  	Set_item_property('LABEL_HEADER.A_PISO',enabled,property_true);
			  END IF;

			--De acuerdo al flag de produccion (des)activa algunos campos
			IF :LABEL_HEADER.BATCH_FLAG = 'Y' THEN
				app_item_property.set_property('LABEL_LINES.BATCH_NO', DISPLAYED,PROPERTY_OFF);	
				app_item_property.set_property('LABEL_LINES.LOT_NUMBER', DISPLAYED,PROPERTY_ON);
				set_item_property('LABEL_LINES.LOT_NUMBER', UPDATEABLE, PROPERTY_OFF);
				app_item_property.set_property('LABEL_LINES.LOT_NUMBER', REQUIRED, PROPERTY_ON);
				
				app_item_property.set_property('LABEL_LINES.FROM_SUBINVENTORY', REQUIRED, PROPERTY_OFF);
				set_item_property('LABEL_LINES.FROM_SUBINVENTORY', INSERT_ALLOWED, PROPERTY_OFF);
				set_item_property('LABEL_LINES.FROM_SUBINVENTORY', NAVIGABLE, PROPERTY_OFF);	
			ELSE
				app_item_property.set_property('LABEL_LINES.LOT_NUMBER', DISPLAYED,PROPERTY_OFF);
				app_item_property.set_property('LABEL_LINES.BATCH_NO', DISPLAYED,PROPERTY_ON);
				set_item_property('LABEL_LINES.BATCH_NO', UPDATEABLE, PROPERTY_OFF);
				set_item_property('LABEL_LINES.BATCH_NO', INSERT_ALLOWED, PROPERTY_OFF);
				set_item_property('LABEL_LINES.BATCH_NO', NAVIGABLE, PROPERTY_OFF);
				app_item_property.set_property('LABEL_LINES.BATCH_NO', REQUIRED, PROPERTY_ON);	

				app_item_property.set_property('LABEL_LINES.FROM_SUBINVENTORY', REQUIRED, PROPERTY_ON);
				set_item_property('LABEL_LINES.FROM_SUBINVENTORY', INSERT_ALLOWED, PROPERTY_ON);	
				set_item_property('LABEL_LINES.FROM_SUBINVENTORY', NAVIGABLE, PROPERTY_ON);
			END IF;

  	ELSIF (Event = 'PRE-QUERY' ) THEN

			IF :parameter.G_query_find = 'TRUE' THEN
			  	app_query.reset('LABEL_HEADER');
			  	
				  copy( name_in( 'LABEL_HEADER_QF.BARCODE' ), 'LABEL_HEADER.BARCODE') ;	
			
			    :parameter.G_query_find := 'FALSE';
			END IF;

  	ELSIF (Event = 'QUERY-FIND' ) THEN	
				app_find.query_find(  'XXCALVZEBRAW'
														, 'XXCALVZEBRAW'
														, 'LABEL_HEADER_QF');
	
  	ELSIF (Event = 'POST-QUERY' ) THEN	
  
  		 --Asigna batch de consumo de forma automatica
  		 IF :PARAMETER.ESCANEO = 'YES' THEN
  		 	IF :LABEL_HEADER.STATUS = 'ABIERTA' THEN
  		 		--set_item_property('LABEL_HEADER.BATCH_NO', UPDATEABLE, PROPERTY_ON);
  		 		set_item_instance_property('LABEL_HEADER.BATCH_NO', CURRENT_RECORD, UPDATEABLE, PROPERTY_ON);
			    OPEN c_batch;
			    FETCH c_batch INTO :LABEL_HEADER.BATCH_ID, :LABEL_HEADER.MATERIAL_DETAIL_ID,
			                       :LABEL_HEADER.BATCH_LINE_NO, :LABEL_HEADER.BATCH_NO, 
			                       :LABEL_HEADER.LINE_TYPE,:LABEL_HEADER.TO_ORGANIZATION_CODE;
			    CLOSE c_batch;  		 		
  		 	ELSIF :LABEL_HEADER.STATUS = 'CERRADA' THEN
  		 		--set_item_property('LABEL_HEADER.BATCH_NO', UPDATEABLE, PROPERTY_OFF);
  		 		set_item_instance_property('LABEL_HEADER.BATCH_NO', CURRENT_RECORD, UPDATEABLE, PROPERTY_OFF);
  		 	END IF;  		 	
  		 END IF;  		 
  		  
  	ELSIF (Event = 'PRE-UPDATE' ) THEN	
  		
  		FND_STANDARD.SET_WHO;
  		
		ELSIF (Event = 'PRE-INSERT' ) THEN

			--Asigna codigo de barras de la tarima
			SELECT XXCALV_TEMP_ETIQUETA_SEQ.NEXTVAL 
			      ,LPAD(XXCALV_TEMP_ETIQUETA_SEQ.NEXTVAL,6,0)
			      ,TO_CHAR(:LABEL_HEADER.LABEL_DATE,'YYYYMMDD')||LPAD(XXCALV_TEMP_ETIQUETA_SEQ.NEXTVAL,6,0)
			INTO :LABEL_HEADER.LABEL_ID, :LABEL_HEADER.LABEL_NUMBER, :LABEL_HEADER.BARCODE
			FROM DUAL;
			
			:LABEL_HEADER.ORGANIZATION_ID := :PARAMETER.ORG_ID;
			
			FND_STANDARD.SET_WHO;
			--Obtiene el movimiento de inventario para realizar una transferencia interorganizacion
			select tt.transaction_type_id,
			         tt.transaction_type_name, 
			         tt.description,          
			         tt.transaction_source_type_id,
			         tst.transaction_source_type_name,
			         tst.description transaction_source,
			         tt.transaction_action_id,            
			         lv.meaning transaction_action    
			into :LABEL_HEADER.TRANSACTION_TYPE_ID,
			     :LABEL_HEADER.TRANSACTION_TYPE_NAME,
			     :LABEL_HEADER.TRANSACTION_DESC,
			     :LABEL_HEADER.TRANSACTION_SOURCE_TYPE_ID,                    
			     :LABEL_HEADER.TRANSACTION_SOURCE_TYPE_NAME,
			     :LABEL_HEADER.TRANSACTION_SOURCE,
			     :LABEL_HEADER.TRANSACTION_ACTION_ID,
			     :LABEL_HEADER.TRANSACTION_ACTION
			from mtl_transaction_types tt,
			        mtl_txn_source_types tst,
			        fnd_lookup_values_vl lv
			where  1 = 1         
			and tst.transaction_source_type_id = tt.transaction_source_type_id
			and nvl(tt.disable_date,sysdate) <= sysdate 
			and lv.lookup_type = 'MTL_TRANSACTION_ACTION'
			and lv.lookup_code = tt.transaction_action_id
			and tt.transaction_type_id = 3
			and tt.transaction_action_id = 3;			

  	ELSIF (Event = 'KEY-COMMIT' ) THEN

			GO_BLOCK('LABEL_LINES');

			--Realiza procesamiento de la etiqueta
			IF :LABEL_HEADER.STATUS = 'CAPTURA' THEN
				IF (NVL(:LABEL_LINES.TOTAL_BOX,0) <> :LABEL_HEADER.BOX_QTY) THEN
						FND_MESSAGE.Set_Name('FND','El número de cajas es incorrecto.');
						FND_MESSAGE.Error;
				ELSE
					  FIRST_RECORD;
					  IF :SYSTEM.RECORD_STATUS = 'NEW' THEN
					  	 FND_MESSAGE.Set_Name('FND','Falta completar el detalle.');
						   FND_MESSAGE.Error;
					  ELSE
					  	XXCALV_LABELS_PKG.label_lines('WHEN-VALIDATE-RECORD');
					  	commit_form;	
							process_label;					  	
					  END IF;
					  
				END IF;		
				
			ELSE
				commit_form;	
			END IF;
		
		END IF;  	  	
  END label_header;	

	/*=================================================================
	* Procedimiento para el manejo de eventos del bloque de detalle
	*=================================================================*/  
  PROCEDURE label_lines(event IN VARCHAR2)IS  
    
    l_onhand    NUMBER;
    l_secuencia VARCHAR2(10);
    l_from_subinventory  VARCHAR2(50);
  
  BEGIN
  	
  	IF (Event = 'WHEN-VALIDATE-RECORD' ) THEN

  		   :LABEL_LINES.NET_WEIGHT := :LABEL_LINES.BOX_QTY * :LABEL_HEADER.BOX_WEIGHT;

  	ELSIF (Event = 'KEY-COMMIT' ) THEN

			--Almacena informacion y realiza procesamiento de etiqueta
			IF :LABEL_HEADER.STATUS = 'CAPTURA' THEN
				IF (NVL(:LABEL_LINES.TOTAL_BOX,0) <> :LABEL_HEADER.BOX_QTY) THEN
						FND_MESSAGE.Set_Name('FND','El número de cajas es incorrecto.');
						FND_MESSAGE.Error;
				ELSE

					  FIRST_RECORD;
					  IF :SYSTEM.RECORD_STATUS = 'NEW' THEN
					  	 FND_MESSAGE.Set_Name('FND','Falta completar el detalle.');
						   FND_MESSAGE.Error;
					  ELSE
					  	XXCALV_LABELS_PKG.label_lines('WHEN-VALIDATE-RECORD');
					  	commit_form;
							process_label;
					  END IF;

				END IF;		
				
			ELSE
				commit_form;	
			END IF;

  	ELSIF (Event = 'PRE-UPDATE' ) THEN	
  		
  		FND_STANDARD.SET_WHO;
  		
		ELSIF (Event = 'PRE-INSERT' ) THEN

			FND_STANDARD.SET_WHO;
			 
			SELECT XXCALV_LABEL_LINES_S.NEXTVAL 
			INTO :LABEL_LINES.LABEL_LINE_ID
			FROM DUAL;
			
			--Obtiene el numero de tarimas pesadas durante el dia por organizacion origen
			SELECT LPAD(COUNT(1) + 1,4,'0')
			INTO l_secuencia
			FROM XXCALV_LABEL_LINES l
			    ,XXCALV_LABEL_HEADER h  
			WHERE h.label_id = l.label_id
			AND l.ORGANIZATION_ID = :LABEL_LINES.ORGANIZATION_ID
			AND l.FROM_SUBINVENTORY = :LABEL_LINES.FROM_SUBINVENTORY
			AND TRUNC(h.label_date) = TRUNC(:LABEL_HEADER.LABEL_DATE);
			
			--Genera numero de lote
			IF :LABEL_LINES.LOT_NUMBER IS NULL THEN
				
				IF :LABEL_LINES.FROM_SUBINVENTORY != :LABEL_HEADER.TO_SUBINVENTORY THEN
					
					IF :LABEL_LINES.SOURCE_SUBINVENTORY IS NULL THEN
						l_from_subinventory := substr(:LABEL_LINES.FROM_SUBINVENTORY,-2);
					ELSE
						l_from_subinventory := substr(:LABEL_LINES.SOURCE_SUBINVENTORY,-2)||'O';
					END IF;
					
					:LABEL_LINES.LOT_NUMBER := TO_CHAR(:LABEL_HEADER.LABEL_DATE,'YYYYMMDD')|| l_from_subinventory ||
					                           --substr(NVL(:LABEL_LINES.SOURCE_SUBINVENTORY,:LABEL_LINES.FROM_SUBINVENTORY),-2)||
					                           --substr(NVL2(:LABEL_LINES.SOURCE_SUBINVENTORY,:LABEL_LINES.SOURCE_SUBINVENTORY||'O',:LABEL_LINES.FROM_SUBINVENTORY),-2)||
					                           l_secuencia||
					                           :LABEL_HEADER.ITEM_TYPE;
				ELSE
					:LABEL_LINES.LOT_NUMBER := TO_CHAR(:LABEL_HEADER.LABEL_DATE,'YYYYMMDD')||
					                           'SM'||
					                           l_secuencia||
					                           :LABEL_HEADER.ITEM_TYPE;					
				END IF;	                           
			END IF;                           

		END IF;  	  	
  END label_lines;

	/*=================================================================
	* Procedimiento para procesar una etiqueta capturada, realiza el 
	* reporte de produccion y transferencia interorganizacion por cada 
	* linea de detalle
	*=================================================================*/    
  PROCEDURE process_label IS
    l_error_flag   VARCHAR2(1);
	  l_message      VARCHAR2(3000);
	  l_result       VARCHAR2(1);  
	  l_commit_result       BOOLEAN;
     
  BEGIN
	
	  l_error_flag := 'N';
		FIRST_RECORD;
		
		--Ajusta el peso en la primer linea en caso de diferencia por redonde de peso neto en caja
		--IF :LABEL_HEADER.NET_WEIGHT <> :LABEL_LINES.TOTAL_WEIGHT THEN
		--   :LABEL_LINES.NET_WEIGHT := :LABEL_LINES.NET_WEIGHT + (:LABEL_HEADER.NET_WEIGHT - :LABEL_LINES.TOTAL_WEIGHT);
		--END IF;	
				
		LOOP
			  app_item_property.set_property('LABEL_LINES.BATCH_NO', ENTERABLE,PROPERTY_OFF);

			  IF :LABEL_HEADER.BATCH_FLAG = 'N' THEN

			  	--Realiza reporte de produccion
			  	XXCALV_LABEL_TRANSACTIONS_PKG.batch_transaction('WIP Completion',l_result,l_message);

					IF l_result = 'T' THEN						
					    :LABEL_LINES.BATCH_TRX_FLAG := 'Y';
					    
					    IF :LABEL_LINES.FROM_SUBINVENTORY != :LABEL_HEADER.TO_SUBINVENTORY THEN
						    --Realiza transaccion de inventarios
				  		  XXCALV_LABEL_TRANSACTIONS_PKG.inv_transaction( p_from_org_id				=> :LABEL_LINES.ORGANIZATION_ID
																									            ,p_from_subinventory  => :LABEL_LINES.FROM_SUBINVENTORY
																									            ,p_to_org_id          => :LABEL_HEADER.TO_ORGANIZATION_ID
																									            ,p_to_subinventory    => :LABEL_HEADER.TO_SUBINVENTORY
																			                        ,x_result             => l_result
																			                        ,x_message            => l_message);
				  		 			  		 
								IF l_result = 'T' THEN	
								    :LABEL_LINES.INV_TRX_FLAG := 'Y';							    
								ELSE
								    :LABEL_LINES.ERROR_EXPLANATION := SUBSTR(l_message,1,240);
								    :LABEL_LINES.INV_TRX_FLAG := 'E';
					
										FND_MESSAGE.Set_Name('FND','Mensaje:'||l_message);
										FND_MESSAGE.Error;
	
						  	    l_error_flag := 'Y';
						  	    EXIT;
	
								END IF;
							ELSE 
									:LABEL_LINES.INV_TRX_FLAG := 'N';
					    END IF;
  
					ELSE  --En caso de no realizar transacion marca que no pudo procesar con exito el registro
					    :LABEL_LINES.ERROR_EXPLANATION := SUBSTR(l_message,1,240);
					    :LABEL_LINES.BATCH_TRX_FLAG := 'E';
	
							FND_MESSAGE.Set_Name('FND',l_message);
							FND_MESSAGE.Error;

			  	    l_error_flag := 'Y';
			  	    EXIT;
					END IF;

			  ELSE

			  	:LABEL_LINES.BATCH_TRX_FLAG := 'N';
			  	:LABEL_LINES.INV_TRX_FLAG := 'N';	

			  END IF;
		  EXIT WHEN :SYSTEM.LAST_RECORD = 'TRUE';
			NEXT_RECORD;
		END LOOP;		
		FIRST_RECORD;  
		
		IF l_error_flag = 'N' THEN
			:LABEL_HEADER.STATUS := 'ABIERTA';
			print_zebra_label;			
			--CLEAR_FORM(DO_COMMIT);
			CLEAR_FORM(NO_VALIDATE);    
			
			--Consultar ultimo registro
				BEGIN
					 select box_type, item_type, box_qty, tare_item, to_subinventory 
					 into :LABEL_HEADER.BOX_TYPE_DESC, :LABEL_HEADER.ITEM_TYPE_DESC, :LABEL_HEADER.BOX_QTY, :LABEL_HEADER.TARE_ITEM_DESC, :LABEL_HEADER.TO_SUBINVENTORY 
					 from XXCALV_LABEL_HEADER_V
					 where label_id = (select max(label_id) from XXCALV_LABEL_HEADER_V);				
				EXCEPTION
					WHEN OTHERS THEN
					  NULL;
				END;

		ELSE  
			--Si ocurrio algun error en el reporte o transaccion de inventario 
			--cancela la etiqueta de forma automatica
			cancel_label;
			:LABEL_HEADER.STATUS := 'CANCELADA BASCULA';
			l_commit_result := APP_FORM.QuietCommit;
		END IF;				
    
  END process_label;

	/*=================================================================
	* Procedimiento para cancelar etiqueta, reversa las operaciones 
	* realizadas, retorna a la organizacion origen y realiza un WIP Completion Return
	*=================================================================*/  
  PROCEDURE cancel_label IS
    l_error_flag   VARCHAR2(1);
	  l_message      VARCHAR2(3000);
	  l_result       VARCHAR2(1);    
  BEGIN
  	
    l_error_flag := 'N';
    GO_BLOCK('LABEL_LINES');
		FIRST_RECORD;
		LOOP
			  IF :LABEL_LINES.INV_TRX_FLAG = 'Y' THEN
			  	  --Revierte transaccion de inventarios
		  		  XXCALV_LABEL_TRANSACTIONS_PKG.inv_transaction( p_from_org_id				=> :LABEL_HEADER.TO_ORGANIZATION_ID
																							            ,p_from_subinventory  => :LABEL_HEADER.TO_SUBINVENTORY
																							            ,p_to_org_id          => :LABEL_LINES.ORGANIZATION_ID
																							            ,p_to_subinventory    => :LABEL_LINES.FROM_SUBINVENTORY
																	                        ,x_result             => l_result
																	                        ,x_message            => l_message);

						IF l_result = 'T' THEN
						    :LABEL_LINES.INV_TRX_FLAG := 'C';

						  	IF :LABEL_LINES.BATCH_TRX_FLAG = 'Y' THEN
						  		--Revierte produccion
						  		XXCALV_LABEL_TRANSACTIONS_PKG.batch_transaction('WIP Completion Return',l_result,l_message);
						  		IF l_result = 'T' THEN						  			
						  		   :LABEL_LINES.BATCH_TRX_FLAG := 'C';
									ELSE
									    :LABEL_LINES.ERROR_EXPLANATION := SUBSTR(l_message,1,240);
					
											FND_MESSAGE.Set_Name('FND',l_message);
											FND_MESSAGE.Error;
				
							  	    l_error_flag := 'Y';
							  	    EXIT;
									END IF;
									
						  	END IF;

						ELSE
						    :LABEL_LINES.ERROR_EXPLANATION := SUBSTR(l_message,1,240);
			
								FND_MESSAGE.Set_Name('FND','Mensaje:'||l_message);
								FND_MESSAGE.Error;

				  	    l_error_flag := 'Y';
				  	    EXIT;

						END IF;

			  ELSIF :LABEL_LINES.BATCH_TRX_FLAG = 'Y' THEN

						  		--Si no realizo transaccion de inventario solo revierte produccion 
						  		XXCALV_LABEL_TRANSACTIONS_PKG.batch_transaction('WIP Completion Return',l_result,l_message);
						  		
						  		IF l_result = 'T' THEN						  			
						  		   :LABEL_LINES.BATCH_TRX_FLAG := 'C';
									ELSE
									    :LABEL_LINES.ERROR_EXPLANATION := SUBSTR(l_message,1,240);
					
											FND_MESSAGE.Set_Name('FND',l_message);
											FND_MESSAGE.Error;
				
							  	    l_error_flag := 'Y';
							  	    EXIT;
									END IF;
							
			  END IF;			  
			  
		  EXIT WHEN :SYSTEM.LAST_RECORD = 'TRUE';
			NEXT_RECORD;
		END LOOP;		
		FIRST_RECORD;  
		
		IF l_error_flag = 'N' THEN
			:LABEL_HEADER.STATUS := 'CANCELADA';
		END IF;
				
    commit_form;
    
  END cancel_label;

	/*=================================================================
	* Procedimiento para realizar el consumo de la etiqueta escaneada
	* WIP Issue
	*=================================================================*/  
  PROCEDURE issue_label IS
	  l_message      VARCHAR2(3000);
	  l_result       VARCHAR2(1); 
	  l_error_flag   VARCHAR2(1);   
    
  BEGIN
	
    l_error_flag := 'N';
        
    IF :LABEL_HEADER.BATCH_ID IS NULL THEN
		   FND_MESSAGE.Set_Name('FND','No hay batch abierto para realizar consumo.');
			 FND_MESSAGE.Error;    
			 RAISE form_trigger_failure;    
    END IF;			        

    GO_BLOCK('LABEL_LINES');
		FIRST_RECORD;
		LOOP
			  --Realiza el consumo por cada linea de detalle en la etiqueta
			  IF (:LABEL_LINES.INV_TRX_FLAG = 'Y') OR (:LABEL_LINES.INV_TRX_FLAG = 'N' AND :LABEL_HEADER.BATCH_FLAG = 'Y') 
			  	OR (:LABEL_LINES.INV_TRX_FLAG = 'N' AND :LABEL_LINES.BATCH_TRX_FLAG = 'Y') THEN
				  	
				  	XXCALV_LABEL_TRANSACTIONS_PKG.batch_transaction('WIP Issue',l_result,l_message);
				
						IF l_result <> 'T' THEN						

						    :LABEL_HEADER.ERROR_EXPLANATION := SUBSTR(l_message,1,240);
				
								FND_MESSAGE.Set_Name('FND',l_message);
								FND_MESSAGE.Error;
				
				  	    l_error_flag := 'Y';
				  	    EXIT;
						END IF;
			  END IF;		  
			  
		  EXIT WHEN :SYSTEM.LAST_RECORD = 'TRUE';
			NEXT_RECORD;
		END LOOP;		
		FIRST_RECORD;  
		
		--Cambia el estatus de la etiqueta a cerrada
		IF l_error_flag = 'N' THEN
			:LABEL_HEADER.ERROR_EXPLANATION := 'WIP Issue OK';
			:LABEL_HEADER.STATUS := 'CERRADA';
		END IF;
				
    CLEAR_FORM(DO_COMMIT);
    
  END issue_label;

	/*=================================================================
	* Procedimiento para la impresion de etiquetas por medio de la 
	* ejecucion del concurrente XXCALV_ETIQUETA_ZEBRA
	*=================================================================*/  
  PROCEDURE print_zebra_label IS
		l_request_id          NUMBER;
		l_set_print           BOOLEAN;
		l_commit_result       BOOLEAN;
		l_concurrent_name     VARCHAR2(30) := 'XXCALV_ETIQUETA_ZEBRA';
		l_printer_name        VARCHAR2(30);
		l_output_print_style  VARCHAR2(30);
		l_procedencia         VARCHAR2(30);  
	
		--Obtener nombre de la impresora y estilo de impresion del concurrente
		CURSOR c_conc(p_concurrent_name VARCHAR2) IS
		    SELECT cp.printer_name,  cp.output_print_style
		    FROM fnd_concurrent_programs  cp
		    WHERE cp.concurrent_program_name = p_concurrent_name
		    AND cp.print_flag = 'Y'
		    AND cp.enabled_flag = 'Y';
	
	BEGIN	      
		      OPEN c_conc(l_concurrent_name);
		      FETCH c_conc INTO l_printer_name, l_output_print_style;
		      CLOSE c_conc;
	
					--Set de impresion
					l_set_print  :=  fnd_request.set_print_options(l_printer_name,
																												 l_output_print_style,
																												 1,
																												 TRUE,
																												 'N');
					
					l_procedencia := :LABEL_LINES.FROM_SUBINVENTORY;
																				                
	        --Ejecucion de concurrente de impresion
	        l_request_id :=  apps.fnd_request.submit_request('INV',
	                                                				 l_concurrent_name,
					                                                 '',
					                                                 SYSDATE,
					                                                 FALSE,
					                                                 :LABEL_HEADER.BARCODE,
	 																												 TO_CHAR(:LABEL_HEADER.LABEL_DATE,'DD'),
	 																												 :LABEL_HEADER.ITEM_TYPE,
	 																												 nvl(:LABEL_HEADER.GRADE_CODE,:LABEL_HEADER.BOX_TYPE),
																													 :LABEL_HEADER.BOX_QTY||','||l_procedencia,
																													 :LABEL_HEADER.WEIGHT,
																													 :LABEL_HEADER.BOX_WEIGHT,
																													 l_procedencia,
																													 :LABEL_HEADER.LABEL_NUMBER);
																																	 
	        IF (l_request_id = 0) THEN
				    bell;
						FND_MESSAGE.Set_Name('FND','Error al ejecutar concurrente de etiquetas.');
						FND_MESSAGE.Error;
	        ELSE
	          --Commit_Form;
	          --COMMIT;  --Salvar ejecucion de concurrente
	          l_commit_result := APP_FORM.QuietCommit;
	        END IF;
	EXCEPTION 
	  WHEN OTHERS THEN 
	    bell;
			FND_MESSAGE.Set_Name('FND','Error al imprimir etiqueta.');
			FND_MESSAGE.Error;	  
  END print_zebra_label;

	/*=================================================================
	* Procedimiento para la impresion de etiquetas por medio de la 
	* ejecucion del concurrente XXCALV_ETIQUETA_ZEBRA
	*=================================================================*/  
  PROCEDURE to_floor_label IS
	BEGIN	      		
		update XXCALV_LABEL_HEADER
		   set ATTRIBUTE1 = 'A PISO'
		 where label_id = :LABEL_HEADER.LABEL_ID;
		commit_form;
	EXCEPTION 
	  WHEN OTHERS THEN 
	    bell;
			FND_MESSAGE.Set_Name('FND','Error al enviar a piso.');
			FND_MESSAGE.Error;
  END to_floor_label;
    
END XXCALV_LABELS_PKG;