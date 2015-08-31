PACKAGE BODY PAC_VISITS_VIEW_PKG IS
  

  PROCEDURE ON_PRE_QUERY IS
  BEGIN
  	
  	:CONTROL.TXT_TOTAL_VISITS := '0';
  	:CONTROL.TXT_ACTUAL_VISITS := '0';
  	
  END ON_PRE_QUERY;


	PROCEDURE ON_POST_QUERY IS
	BEGIN
		
		IF    :PAC_VISITS_VIEW_TB.CHECK_IN IS NULL AND :PAC_VISITS_VIEW_TB.CHECK_OUT IS NULL THEN
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.VISITOR_DAY_ID', 'BACKGROUND_WHITE');
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.VISITOR_NAME', 'BACKGROUND_WHITE');
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.VISITOR_COMPANY', 'BACKGROUND_WHITE');
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.CHECK_IN', 'BACKGROUND_WHITE');
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.CHECK_OUT', 'BACKGROUND_WHITE');
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.VISITOR_LENGTH_STAY', 'BACKGROUND_WHITE');
		ELSIF :PAC_VISITS_VIEW_TB.CHECK_IN IS NOT NULL AND :PAC_VISITS_VIEW_TB.CHECK_OUT IS NOT NULL THEN
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.VISITOR_DAY_ID', 'BACKGROUND_GRAY');
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.VISITOR_NAME', 'BACKGROUND_GRAY');
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.VISITOR_COMPANY', 'BACKGROUND_GRAY');
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.CHECK_IN', 'BACKGROUND_GRAY');
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.CHECK_OUT', 'BACKGROUND_GRAY');
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.VISITOR_LENGTH_STAY', 'BACKGROUND_GRAY');
		ELSIF :PAC_VISITS_VIEW_TB.CHECK_IN IS NOT NULL AND :PAC_VISITS_VIEW_TB.CHECK_OUT IS NULL THEN
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.VISITOR_DAY_ID', 'BACKGROUND_GREEN');
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.VISITOR_NAME', 'BACKGROUND_GREEN');
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.VISITOR_COMPANY', 'BACKGROUND_GREEN');
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.CHECK_IN', 'BACKGROUND_GREEN');
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.CHECK_OUT', 'BACKGROUND_GREEN');
			SET_BACKGROUND('PAC_VISITS_VIEW_TB.VISITOR_LENGTH_STAY', 'BACKGROUND_GREEN');
		END IF;		
		
		FND_STANDARD.SET_WHO;
		
		SELECT COUNT(PVC.VISITOR_DAY_ID)
		  INTO :CONTROL.TXT_TOTAL_VISITS 
		  FROM PAC_VISITS_CONTROL_TB PVC
		 WHERE 1 = 1
		   AND VISITOR_DAY_ID LIKE (TO_CHAR(SYSDATE, 'YYMMDD') || '%');
		 
		SELECT COUNT(PVC.VISITOR_DAY_ID)
		  INTO :CONTROL.TXT_ACTUAL_VISITS 
		  FROM PAC_VISITS_CONTROL_TB PVC
		 WHERE 1 = 1
		   AND VISITOR_DAY_ID LIKE (TO_CHAR(SYSDATE, 'YYMMDD') || '%')
		   AND CHECK_IN IS NOT NULL
		   AND CHECK_OUT IS NULL;
		  
		
	END ON_POST_QUERY;
	
	
	PROCEDURE SET_BACKGROUND(ITEM VARCHAR2, BACKGROUND VARCHAR2) IS
	BEGIN
		app_item_property.set_property(ITEM, ENABLED, PROPERTY_TRUE);
		SET_ITEM_INSTANCE_PROPERTY(ITEM, CURRENT_RECORD, VISUAL_ATTRIBUTE, BACKGROUND);
		app_item_property.set_property(ITEM, ENABLED, PROPERTY_FALSE);
	END SET_BACKGROUND;
	
	
	PROCEDURE PRINT_LABEL IS
		l_request_id          NUMBER;
		l_set_print           BOOLEAN;
		l_commit_result       BOOLEAN;
		l_concurrent_name     VARCHAR2(30) := 'PAC_PRINT_VISIT_LABEL';
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
	
		P_FOLIO									VARCHAR2(50);
    P_DATE									VARCHAR2(50);
    P_HOUR									VARCHAR2(50);
    P_VISITOR_NAME					VARCHAR2(50);
    P_VISITOR_COMPANY				VARCHAR2(50);
    P_ASSOCIATE_PERSON			VARCHAR2(50);
    P_ASSOCIATE_DEPARTMENT	VARCHAR2(50);
		 
	
	BEGIN	      
		      OPEN c_conc(l_concurrent_name);
		      FETCH c_conc INTO l_printer_name, l_output_print_style;
		      CLOSE c_conc;
		      
		      --Set Values
		      P_FOLIO								 := :PAC_VISITS_VIEW_TB.VISITOR_DAY_ID;
          P_DATE								 :=	:PAC_VISITS_VIEW_TB.REGISTRATION_DATE;
          P_HOUR								 :=	:PAC_VISITS_VIEW_TB.REGISTRATION_TIME;
          P_VISITOR_NAME				 := :PAC_VISITS_VIEW_TB.VISITOR_NAME;
          P_VISITOR_COMPANY			 := :PAC_VISITS_VIEW_TB.VISITOR_COMPANY;
          P_ASSOCIATE_PERSON 		 := :PAC_VISITS_VIEW_TB.ATTRIBUTE1;
          P_ASSOCIATE_DEPARTMENT := :PAC_VISITS_VIEW_TB.ATTRIBUTE2;
		      		      
	
					--Set de impresion
					l_set_print  :=  fnd_request.set_print_options(l_printer_name,
																												 l_output_print_style,
																												 1,
																												 TRUE,
																												 'N');
																				                
	        --Ejecucion de concurrente de impresion
	        l_request_id :=  apps.fnd_request.submit_request('PER',
	                                                				 l_concurrent_name,
					                                                 '',
					                                                 SYSDATE,
					                                                 FALSE,
					                                                 P_FOLIO,
					                                                 P_DATE,
					                                                 P_HOUR,
					                                                 P_VISITOR_NAME,
					                                                 P_VISITOR_COMPANY,
					                                                 P_ASSOCIATE_PERSON,
					                                                 P_ASSOCIATE_DEPARTMENT);
																																	 
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
	END PRINT_LABEL;
		
  
END;