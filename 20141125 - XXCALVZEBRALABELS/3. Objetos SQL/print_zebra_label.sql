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