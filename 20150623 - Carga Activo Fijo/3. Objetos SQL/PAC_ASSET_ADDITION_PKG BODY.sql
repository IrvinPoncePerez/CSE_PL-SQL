CREATE OR REPLACE PACKAGE BODY PAC_ASSET_ADDITION_PKG
IS

    PROCEDURE ASSET_ADDITION
    IS
    BEGIN
        NULL;
    END ASSET_ADDITION;
    
    PROCEDURE ADD_ASSET_ADDITION (
                    P_DESCRIPTION           VARCHAR2,   --Descripcion
                    P_TAG_NUMBER            VARCHAR2,   --Número Etiqueta
                    P_SERIAL_NUMBER         VARCHAR2,   --Número Serie
                    P_UNITS                 NUMBER,     --Unidades
                    P_CATEGORY              VARCHAR2,   --Categoría
                    P_COST                  NUMBER,     --Costo
                    P_VENDOR_NAME           VARCHAR2,   --Nombre Proveedor
                    P_INVOICE_NUMBER        VARCHAR2,   --Número Factura
                    P_BOOK_CODE             VARCHAR2,   --Libro
                    P_DATE_IN_SERVICE       DATE,       --Fecha en Servicio
                    P_DEPRECIATE_METHOD     VARCHAR2,   --Método
                    P_PRORATE_CODE          VARCHAR2,   --Convención Prorrateo
                    P_CODE_COMBINATION      NUMBER,     --Cuenta Gastos
                    P_LOCATION              NUMBER      --Dirección
              )
    IS
    
       l_trans_rec                FA_API_TYPES.trans_rec_type;
       l_dist_trans_rec           FA_API_TYPES.trans_rec_type;
       l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
       l_asset_desc_rec           FA_API_TYPES.asset_desc_rec_type;
       l_asset_cat_rec            FA_API_TYPES.asset_cat_rec_type;
       l_asset_type_rec           FA_API_TYPES.asset_type_rec_type;
       l_asset_hierarchy_rec      FA_API_TYPES.asset_hierarchy_rec_type;
       l_asset_fin_rec            FA_API_TYPES.asset_fin_rec_type;
       l_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;
       l_asset_dist_rec           FA_API_TYPES.asset_dist_rec_type;
       l_asset_dist_tbl           FA_API_TYPES.asset_dist_tbl_type;
       l_inv_tbl                  FA_API_TYPES.inv_tbl_type;
       l_inv_rate_tbl             FA_API_TYPES.inv_rate_tbl_type;
       l_inv_rec                  FA_API_TYPES.inv_rec_type;

       l_return_status            VARCHAR2(1);          
       l_mesg_count               number;
       l_mesg                     varchar2(4000);
       
       
       var_category_id            NUMBER;
       var_vendor_id              NUMBER;
       var_method_code            VARCHAR2(20);
       var_life_in_months         NUMBER;
       var_code_combination_id    NUMBER;
       var_location_id            NUMBER;
       
        
    BEGIN
    
        /********************************************
        TABLAS UTILES:
                    FA_ADDITIONS
                    FA_CATEGORIES_B
                    PO_VENDORS
                    FA_BOOK_CONTROLS
                    FA_METHODS
                    FA_CONVENTION_TYPES,
                    GL_CODE_COMBINATIONS
                    FA_LOCATIONS_KFV
        ********************************************/
        
        
        FND_FILE.PUT_LINE(FND_FILE.LOG , '**************************************************************************************************');
        
        FA_SRVR_MSG.Init_Server_Message;

        l_asset_desc_rec.DESCRIPTION        :=  P_DESCRIPTION;
        l_asset_desc_rec.TAG_NUMBER         :=  P_TAG_NUMBER;
        l_asset_desc_rec.SERIAL_NUMBER      :=  P_SERIAL_NUMBER;
        l_asset_desc_rec.CURRENT_UNITS      :=  P_UNITS;                                
        l_asset_desc_rec.NEW_USED           := 'NEW';                               
                
        /**********************************************
                    CONSULTA DE LA CATEGOORIA
        **********************************************/
        BEGIN
        
            SELECT FCB.CATEGORY_ID
              INTO var_category_id
              FROM FA_CATEGORIES_B  FCB
             WHERE 1 = 1
               AND FCB.SEGMENT1 = SUBSTR(P_CATEGORY, 0, INSTR(P_CATEGORY, '.') - 1)
               AND FCB.SEGMENT2 = SUBSTR(P_CATEGORY, INSTR(P_CATEGORY, '.') + 1);
               
        EXCEPTION WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG , '* * * ERROR * * *: Al consultar la categoría.');
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Descripción : ' || P_DESCRIPTION);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Etiqueta : ' || P_TAG_NUMBER);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Serie : ' || P_SERIAL_NUMBER);
            RETURN;
        END;
        
        
        l_asset_cat_rec.CATEGORY_ID         :=  var_category_id;
            
        l_asset_type_rec.ASSET_TYPE         :=  'CAPITALIZED';                      
        l_asset_fin_rec.COST                :=  P_COST;   
        
        
        /**********************************************
                    CONSULTA DEL PROVEEDOR
        **********************************************/
        BEGIN
        
            SELECT VENDOR_ID
              INTO var_vendor_id
              FROM PO_VENDORS   PV
             WHERE 1 = 1
               AND PV.VENDOR_TYPE_LOOKUP_CODE = 'VENDOR'
               AND PV.VENDOR_NAME = P_VENDOR_NAME;
               
        EXCEPTION WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG , '* * * ERROR * * *: Al consultar el nombre del proveedor.');
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Descripción : ' || P_DESCRIPTION);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Etiqueta : ' || P_TAG_NUMBER);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Serie : ' || P_SERIAL_NUMBER);
            RETURN;
        END;
                                  
                
        l_inv_rec.PO_VENDOR_ID              :=  var_vendor_id; 
        l_inv_rec.INVOICE_NUMBER            :=  P_INVOICE_NUMBER;
        l_inv_rec.DESCRIPTION               :=  l_asset_desc_rec.DESCRIPTION;
        l_inv_rec.PAYABLES_COST             :=  l_asset_fin_rec.COST;
        l_inv_rec.PAYABLES_UNITS            :=  l_asset_desc_rec.CURRENT_UNITS;
            
        l_inv_tbl (1)                       :=  l_inv_rec;
            
        l_asset_hdr_rec.BOOK_TYPE_CODE      :=  P_BOOK_CODE;
            
        l_asset_fin_rec.DATE_PLACED_IN_SERVICE  :=  P_DATE_IN_SERVICE;
        
        
        /**********************************************
              CONSULTA DEL METODO DE DEPRECIACIÓN
        **********************************************/
        BEGIN
        
            SELECT FM.METHOD_CODE,
                   FM.LIFE_IN_MONTHS
              INTO var_method_code,
                   var_life_in_months
              FROM FA_METHODS   FM
             WHERE 1 = 1
               AND FM.METHOD_CODE = P_DEPRECIATE_METHOD;
               
        EXCEPTION WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG , '* * * ERROR * * *: Al consultar el método de depreciación.');
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Descripción : ' || P_DESCRIPTION);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Etiqueta : ' || P_TAG_NUMBER);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Serie : ' || P_SERIAL_NUMBER);
            RETURN;
        END;
        
        
        l_asset_fin_rec.DEPRN_METHOD_CODE   :=  var_method_code;
        l_asset_fin_rec.LIFE_IN_MONTHS      :=  var_life_in_months;
        l_asset_fin_rec.DEPRECIATE_FLAG     :=  'YES';                            
        l_asset_fin_rec.PRORATE_CONVENTION_CODE :=  SUBSTR(P_PRORATE_CODE, 0, 10);
            
        l_asset_dist_rec.UNITS_ASSIGNED     :=  l_asset_desc_rec.CURRENT_UNITS;
        
        /**********************************************
              CONSULTA DEL METODO DE DEPRECIACIÓN
        **********************************************/
        BEGIN
        
            SELECT GCC.CODE_COMBINATION_ID
              INTO var_code_combination_id
              FROM GL_CODE_COMBINATIONS     GCC
             WHERE 1 = 1
               AND GCC.SEGMENT1 ||
                   GCC.SEGMENT2 ||
                   GCC.SEGMENT3 ||
                   GCC.SEGMENT4 ||
                   GCC.SEGMENT5 ||
                   GCC.SEGMENT6 = REPLACE(P_CODE_COMBINATION, '-', '');
        
        EXCEPTION WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG , '* * * ERROR * * *: Al consultar la cuenta contable.');
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Descripción : ' || P_DESCRIPTION);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Etiqueta : ' || P_TAG_NUMBER);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Serie : ' || P_SERIAL_NUMBER);
            RETURN;
        END;
        
        l_asset_dist_rec.EXPENSE_CCID       :=  var_code_combination_id;
        
        /**********************************************
                    CONSULTA DE LA DIRECCIÓN
        **********************************************/
        BEGIN
            
            SELECT FLK.LOCATION_ID
              INTO var_location_id
              FROM FA_LOCATIONS_KFV FLK
             WHERE 1 = 1
               AND FLK.CONCATENATED_SEGMENTS = P_LOCATION
               AND FLK.ENABLED_FLAG = 'Y';
        
        EXCEPTION WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG , '* * * ERROR * * *: Al consultar la dirección de asignación.');
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Descripción : ' || P_DESCRIPTION);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Etiqueta : ' || P_TAG_NUMBER);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Serie : ' || P_SERIAL_NUMBER);
            RETURN;
        END;
        
        l_asset_dist_rec.LOCATION_CCID      :=  var_location_id;                                --Required
        l_asset_dist_rec.ASSIGNED_TO        :=  NULL;
        l_asset_dist_rec.TRANSACTION_UNITS  :=  l_asset_dist_rec.UNITS_ASSIGNED;
        l_asset_dist_tbl(1)                 :=  l_asset_dist_rec;
        
    
       
    
        fa_addition_pub.do_addition(
           p_api_version             => 1.0,
           p_init_msg_list           => FND_API.G_FALSE,
           p_commit                  => FND_API.G_TRUE,
           p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
           p_calling_fn              => null,
           x_return_status           => l_return_status,
           x_msg_count               => l_mesg_count,
           x_msg_data                => l_mesg,
           px_trans_rec              => l_trans_rec,
           px_dist_trans_rec         => l_dist_trans_rec,
           px_asset_hdr_rec          => l_asset_hdr_rec,
           px_asset_desc_rec         => l_asset_desc_rec,
           px_asset_type_rec         => l_asset_type_rec,
           px_asset_cat_rec          => l_asset_cat_rec,
           px_asset_hierarchy_rec    => l_asset_hierarchy_rec,
           px_asset_fin_rec          => l_asset_fin_rec,
           px_asset_deprn_rec        => l_asset_deprn_rec,
           px_asset_dist_tbl         => l_asset_dist_tbl,
           px_inv_tbl                => l_inv_tbl
          );
          
          
       l_mesg_count := fnd_msg_pub.count_msg;

       if l_mesg_count > 0 then

          l_mesg := chr(10) || substr(fnd_msg_pub.get(fnd_msg_pub.G_FIRST, fnd_api.G_FALSE),1, 250);
          FND_FILE.PUT_LINE(FND_FILE.LOG, l_mesg);

          for i in 1..(l_mesg_count - 1) loop
             l_mesg := substr(fnd_msg_pub.get(fnd_msg_pub.G_NEXT, fnd_api.G_FALSE), 1, 250);

             FND_FILE.PUT_LINE(FND_FILE.LOG, l_mesg);
          end loop;

          fnd_msg_pub.delete_msg();

       end if;


       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, '* * * E R R O R * * *');
       ELSE
         FND_FILE.PUT_LINE(FND_FILE.LOG, '* * * REGISTRO SATISFACTORIO * * *');
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Descripción : ' || P_DESCRIPTION);
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Etiqueta : ' || P_TAG_NUMBER);
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Serie : ' || P_SERIAL_NUMBER);
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Activo : ' || l_asset_desc_rec.asset_number);
       END IF;
    
    
    END ADD_ASSET_ADDITION;

END PAC_ASSET_ADDITION_PKG;