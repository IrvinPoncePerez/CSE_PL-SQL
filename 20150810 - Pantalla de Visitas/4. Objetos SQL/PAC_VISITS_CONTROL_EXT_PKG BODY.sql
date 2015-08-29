CREATE OR REPLACE PACKAGE BODY PAC_VISITS_CONTROL_EXT_PKG IS


    FUNCTION   IS_CHECK_EXISTS(FOLIO    VARCHAR2,   DATETIME    VARCHAR2)   RETURN BOOLEAN IS
        
        var_last_check        DATE;
        var_new_check         DATE := TO_DATE(DATETIME, 'DD-MM-YYYY HH24:MI:SS');
        var_diff_in_minutes   NUMBER;
        var_result            BOOLEAN := FALSE;
        
    BEGIN
    
        BEGIN
            
            SELECT TO_DATE(TO_CHAR(SYSDATE , 'DD-MM-YYYY') || ' ' || PVC.CHECK_IN, 'DD-MM-YYYY HH24:MI:SS')
              INTO var_last_check
              FROM PAC_VISITS_CONTROL_TB PVC
             WHERE 1 = 1
               AND PVC.CHECK_IN IS NOT NULL
               AND PVC.CHECK_OUT IS NULL
               AND PVC.VISITOR_DAY_ID = FOLIO;
        
        EXCEPTION WHEN NO_DATA_FOUND THEN
            var_last_check := NULL;
            var_result := FALSE;   
        END;
        
        
        IF var_last_check IS NOT NULL THEN
            
            var_diff_in_minutes := ROUND (1440 * (var_new_check - var_last_check), 2);
            
            IF var_diff_in_minutes < 1 THEN
                RETURN TRUE;
            ELSE
                RETURN FALSE;
            END IF;
            
        END IF;        
        
        
        BEGIN
            
            SELECT TO_DATE(TO_CHAR(SYSDATE , 'DD-MM-YYYY') || ' ' || PVC.CHECK_OUT, 'DD-MM-YYYY HH24:MI:SS')
              INTO var_last_check
              FROM PAC_VISITS_CONTROL_TB PVC
             WHERE 1 = 1
               AND PVC.CHECK_IN IS NOT NULL
               AND PVC.CHECK_OUT IS NOT NULL
               AND PVC.VISITOR_DAY_ID = FOLIO;
        
        EXCEPTION WHEN NO_DATA_FOUND THEN
            var_last_check := NULL;
            var_result := FALSE;   
        END;
        
        
        IF var_last_check IS NOT NULL THEN
            
            var_diff_in_minutes := ROUND (1440 * (var_new_check - var_last_check), 2);
            
            IF var_diff_in_minutes < 1 THEN
                RETURN TRUE;
            ELSE
                RETURN FALSE;
            END IF;
            
        END IF;          
        
    
        RETURN var_result;
        
    END IS_CHECK_EXISTS;
    
    
    FUNCTION   IS_CREATE_CHECK(FOLIO    VARCHAR2,   DATETIME    VARCHAR2)   RETURN BOOLEAN IS
        
        var_result              BOOLEAN := FALSE;
        var_visitor_day_id      VARCHAR2(50);
        var_visitor_length_stay VARCHAR2(200);
        
    BEGIN
    
        BEGIN
            
            SELECT PVC.VISITOR_DAY_ID
              INTO var_visitor_day_id
              FROM PAC_VISITS_CONTROL_TB PVC
             WHERE 1 = 1
               AND PVC.CHECK_IN IS NULL
               AND PVC.CHECK_OUT IS NULL
               AND PVC.VISITOR_DAY_ID = FOLIO;
        
        EXCEPTION WHEN NO_DATA_FOUND THEN
            var_visitor_day_id := NULL;
            var_result := FALSE;   
        END;
        
           
        IF var_visitor_day_id IS NOT NULL THEN
        
            UPDATE PAC_VISITS_CONTROL_TB PVC
               SET PVC.CHECK_IN = TO_CHAR(TO_DATE(DATETIME, 'DD-MM-YYYY HH24:MI:SS'), 'HH24:MI:SS')  
             WHERE 1 = 1
               AND PVC.VISITOR_DAY_ID = var_visitor_day_id;
        
            COMMIT;
            
            RETURN TRUE;
                   
        END IF;
        
        
        BEGIN
              
            SELECT PVC.VISITOR_DAY_ID
              INTO var_visitor_day_id
              FROM PAC_VISITS_CONTROL_TB PVC
             WHERE 1 = 1
               AND PVC.CHECK_IN IS NOT NULL
               AND PVC.CHECK_OUT IS NULL
               AND PVC.VISITOR_DAY_ID = FOLIO;
        
        EXCEPTION WHEN NO_DATA_FOUND THEN
            var_visitor_day_id := NULL;
            var_result := FALSE;   
        END;
        
        
        IF var_visitor_day_id IS NOT NULL THEN
        
            UPDATE PAC_VISITS_CONTROL_TB PVC
               SET PVC.CHECK_OUT = TO_CHAR(TO_DATE(DATETIME, 'DD-MM-YYYY HH24:MI:SS'), 'HH24:MI:SS')
             WHERE 1 = 1
               AND PVC.VISITOR_DAY_ID = var_visitor_day_id;
        
            COMMIT;
            
            var_visitor_length_stay := GET_VISITOR_LENGTH_STAY(FOLIO);
            
            UPDATE PAC_VISITS_CONTROL_TB PVC
               SET PVC.VISITOR_LENGTH_STAY = var_visitor_length_stay
             WHERE 1 = 1
               AND PVC.VISITOR_DAY_ID = var_visitor_day_id;
        
            COMMIT;
            
            RETURN TRUE;
        
        END IF;
        
    
        RETURN var_result;
    
        
    END IS_CREATE_CHECK;
    
    
    FUNCTION   GET_VISITOR_LENGTH_STAY(FOLIO    VARCHAR2)   RETURN VARCHAR2 IS
        var_length_stay     VARCHAR2(200);
    BEGIN
    
        SELECT FLOOR(((  TO_DATE(TO_CHAR(SYSDATE, 'DD-MM-YYYY') || ' ' || PVC.CHECK_OUT, 'DD-MM-YYYY HH24:MI:SS')
                       - TO_DATE(TO_CHAR(SYSDATE, 'DD-MM-YYYY') || ' ' || PVC.CHECK_IN, 'DD-MM-YYYY HH24:MI:SS'))*24*60*60)/3600)
               || ' HR ' ||
               FLOOR((((  TO_DATE(TO_CHAR(SYSDATE, 'DD-MM-YYYY') || ' ' || PVC.CHECK_OUT, 'DD-MM-YYYY HH24:MI:SS')
                        - TO_DATE(TO_CHAR(SYSDATE, 'DD-MM-YYYY') || ' ' || PVC.CHECK_IN, 'DD-MM-YYYY HH24:MI:SS'))*24*60*60) -
               FLOOR(((  TO_DATE(TO_CHAR(SYSDATE, 'DD-MM-YYYY') || ' ' || PVC.CHECK_OUT, 'DD-MM-YYYY HH24:MI:SS')
                       - TO_DATE(TO_CHAR(SYSDATE, 'DD-MM-YYYY') || ' ' || PVC.CHECK_IN, 'DD-MM-YYYY HH24:MI:SS'))*24*60*60)/3600)*3600)/60)
               || ' MIN' 
          INTO var_length_stay
          FROM PAC_VISITS_CONTROL_TB PVC
         WHERE 1 = 1
           AND PVC.VISITOR_DAY_ID = FOLIO; 
    
    
        RETURN var_length_stay;
    
    END GET_VISITOR_LENGTH_STAY;
    
    
    PROCEDURE  PRINT_LABEL(
                    ERRBUF                  OUT VARCHAR2,       
                    RETCODE                 OUT VARCHAR2) IS
    BEGIN
        
        XXCALV_UTILS_PKG.XXCALV_VOUT('^XA');
        XXCALV_UTILS_PKG.XXCALV_VOUT('^FO450,30^ADN,20,13^FD15-SEP-2015^FS');           -- Print P_DATE
        XXCALV_UTILS_PKG.XXCALV_VOUT('^FO450,47^ADN,20,13^FD11:30:20 AM^FS');           -- Print P_HOUR
        XXCALV_UTILS_PKG.XXCALV_VOUT('^FO30,100^GB550,0,3,^FS');                        -- Print Line
        XXCALV_UTILS_PKG.XXCALV_VOUT('^FO30,110^ADN,25,15^FDVISITANTE:^FS');            -- Print Label  VISITANTE        
        XXCALV_UTILS_PKG.XXCALV_VOUT('^FO55,127^ADN,30,20^FDNOMBRE VISITANTE^FS');      -- Print P_VISITOR_NAME
        XXCALV_UTILS_PKG.XXCALV_VOUT('^FO55,157^ADN,30,20^FDCOMPAÑIA VISITANTE^FS');    -- Print P_VISITOR_COMPANY
        XXCALV_UTILS_PKG.XXCALV_VOUT('^FO30,187^ADN,25,15^FDASOCIADO:^FS');             -- Print Label  ASOCIADO
        XXCALV_UTILS_PKG.XXCALV_VOUT('^FO55,204^ADN,30,20^FDNOMBRE ASOCIADO^FS');       -- Print P_ASSOCIATE_PERSON
        
        

--        XXCALV_UTILS_PKG.XXCALV_VOUT('^FO50,50^B3N,N,100,Y,N^FDV150916001^FS');
        
        XXCALV_UTILS_PKG.XXCALV_VOUT('^XZ');
                
    EXCEPTION WHEN OTHERS THEN
        XXCALV_UTILS_PKG.XXCALV_VOUT('Existio un Error en la Ejecucion de la Etiqueta: '||sqlerrm);
        XXCALV_UTILS_PKG.XXCALV_VLOG('Existio un Error en la Ejecucion de la Etiqueta: '||sqlerrm);
    END PRINT_LABEL;
    

END PAC_VISITS_CONTROL_EXT_PKG;