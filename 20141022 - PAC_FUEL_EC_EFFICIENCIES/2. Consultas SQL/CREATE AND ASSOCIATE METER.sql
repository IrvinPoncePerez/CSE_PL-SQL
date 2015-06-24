DECLARE

    CURSOR DETAILS IS
            SELECT SERIAL_NUMBER,
                   INVENTORY_ITEM_ID,
                   AREA,
                   CATEGORY_NAME,
                   EAM_ITEM_TYPE,
                   PAC_FUEL_EFFICIENCY.FIND_METER_ID (SERIAL_NUMBER) METER_ID,
                   PAC_FUEL_EFFICIENCY.GET_METER_READING(PAC_FUEL_EFFICIENCY.FIND_METER_ID (SERIAL_NUMBER)) METER_READING,
                   CURRENT_ORGANIZATION_ID,
                   LEVEL ,
                   CONNECT_BY_ISLEAF 
                   
              FROM MTL_EAM_ASSET_NUMBERS_ALL_V MOG
             WHERE ACTIVE_END_DATE IS NULL
               AND CURRENT_ORGANIZATION_ID = 102 
        --       CONNECT_BY_ROOT serial_number = serial_number
        --       AND CATEGORY_NAME LIKE '%LLANTA%' 
        --       AND CATEGORY_NAME LIKE '%VEHICULO%'
               AND SERIAL_NUMBER NOT LIKE 'POS%'
        --       AND ROWNUM <= 10
        --       AND EAM_ITEM_TYPE = 1       
               AND AREA <> 'GRB'
        --       AND AREA = 'REPARTO'
               AND PAC_FUEL_EFFICIENCY.FIND_METER_ID (SERIAL_NUMBER) = -1
             START WITH PARENT_GEN_OBJECT_ID IS NULL
           CONNECT BY NOCYCLE PRIOR GEN_OBJECT_ID = PARENT_GEN_OBJECT_ID;
           



   L_STAT       VARCHAR2 (10);
   L_COUNT      NUMBER;
   L_DATA       VARCHAR2 (100);
   L_METER_ID   NUMBER;
   
   
   
BEGIN

    FOR detail IN DETAILS LOOP
    
        L_METER_ID := 0;

         EAM_METER_PUB.CREATE_METER(P_API_VERSION               => 1.0,
                                    X_RETURN_STATUS             => L_STAT,
                                    X_MSG_COUNT                 => L_COUNT,
                                    X_MSG_DATA                  => L_DATA,
                                    P_METER_NAME                => 'ODOMETRO ' || detail.SERIAL_NUMBER, 
                                    P_METER_UOM                 => 'KM',              
                                    P_METER_TYPE                => 1,                 
                                    P_VALUE_CHANGE_DIR          => 1,                 
                                    P_EAM_REQUIRED_FLAG         => 'Y',                 
                                    P_USED_IN_SCHEDULING        => 'Y',                 
                                    P_USER_DEFINED_RATE         => 20,                  
                                    P_USE_PAST_READING          => 1,                   
                                    P_INITIAL_READING           => 0,                   
                                    P_DESCRIPTION               => 'MEDIDOR DEL ' || detail.SERIAL_NUMBER, 
                                    P_FROM_EFFECTIVE_DATE       => SYSDATE,             
                                    P_INITIAL_READING_DATE      => SYSDATE,             
                                    P_TMPL_FLAG                 => NULL,
                                    X_NEW_METER_ID              => L_METER_ID
                                   );
                                   
        COMMIT;

       DBMS_OUTPUT.PUT_LINE(detail.SERIAL_NUMBER || ',  L_STAT : ' || L_STAT  ||',  L_COUNT : ' || L_COUNT || ',  L_DATA : ' || L_DATA || ',  L_METER_ID : ' || L_METER_ID);        
                                   
        EAM_METERASSOC_PUB.INSERT_ASSETMETERASSOC(p_api_version             =>  1.0,
                                                  x_return_status		    =>  L_STAT,
                                                  x_msg_count		        =>  L_COUNT,
                                                  x_msg_data		        =>  L_DATA,
                                                  p_meter_id		        =>  L_METER_ID,
                                                  P_organization_id	        =>  detail.CURRENT_ORGANIZATION_ID,
                                                  p_asset_group_id	        =>  detail.INVENTORY_ITEM_ID,
                                                  p_asset_number		    =>  detail.SERIAL_NUMBER,
                                                  p_maintenance_object_type =>  3,
                                                  p_primary_failure_flag	=> 'N',
                                                  p_start_date_active       =>  SYSDATE
                                                  
                                              );

       COMMIT;
                                               
       DBMS_OUTPUT.PUT_LINE(detail.SERIAL_NUMBER || ',  L_STAT : ' || L_STAT  ||',  L_COUNT : ' || L_COUNT || ',  L_DATA : ' || L_DATA || ',  L_METER_ID : ' || L_METER_ID);
       DBMS_OUTPUT.PUT_LINE('  ');                                       
        
    END LOOP;

END;