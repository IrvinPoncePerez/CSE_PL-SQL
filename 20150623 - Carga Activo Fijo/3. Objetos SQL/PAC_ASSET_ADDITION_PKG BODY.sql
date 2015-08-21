CREATE OR REPLACE PACKAGE BODY PAC_ASSET_ADDITION_PKG
IS

    PROCEDURE ASSET_ADDITION(
                    P_ERRBUF    OUT NOCOPY  VARCHAR2,
                    P_RETCODE   OUT NOCOPY  VARCHAR2
              )
    IS
    
            CURSOR DETAIL_LIST  IS
                SELECT TRIM(UPPER(PAAT.DESCRIPTION))                        AS  DESCRIPTION,
                       TRIM(UPPER(PAAT.TAG_NUMBER))                         AS  TAG_NUMBER,
                       TRIM(UPPER(PAAT.SERIAL_NUMBER))                      AS  SERIAL_NUMBER,
                       TO_NUMBER(PAAT.UNITS)                                AS  UNITS,
                       (TRIM(PAAT.CATEGORY) || '.' ||
                        TRIM(PAAT.SUBCATEGORY))                                   AS  CATEGORY,
                       TO_NUMBER(REPLACE(PAAT.COST, ',', ''))               AS  COST,
                       TRIM(UPPER(PAAT.VENDOR_NAME))                        AS  VENDOR_NAME,
                       TRIM(UPPER(PAAT.INVOICE_NUMBER))                     AS  INVOICE_NUMBER,
                       PAAT.BOOK_CODE                                       AS  BOOK_CODE,
                       TO_DATE(UPPER(PAAT.DATE_IN_SERVICE), 'dd/mm/yyyy')   AS  DATE_IN_SERVICE,
                       PAAT.DEPRECIATE_METHOD                               AS  DEPRECIATE_METHOD,
                       PAAT.PRORATE_CODE                                    AS  PRORATE_CODE,
                       REPLACE(TO_CHAR(PAAT.CODE_COMPANY,  '00') || 
                               TO_CHAR(PAAT.CODE_CCOST,    '0000') ||
                               TO_CHAR(PAAT.CODE_ACCOUNT,  '000000000000') ||
                               TO_CHAR(PAAT.CODE_INTERORG, '00') ||
                               TO_CHAR(PAAT.CODE_FUTURO1,  '0000') ||
                               TO_CHAR(PAAT.CODE_FUTURO1,  '0000'), ' ', '')AS  CODE_COMBINATION,
                       (PAAT.LOCATION_STATE || '.' ||
                        PAAT.LOCATION_CITY || '.' ||
                        PAAT.LOCATION_COST)                                 AS  LOCATION
                  FROM PAC_ASSET_ADDITIONS_TB   PAAT;
    
    BEGIN
    
    
        FOR detail  IN  DETAIL_LIST LOOP
        BEGIN
        
--            FND_FILE.PUT_LINE(FND_FILE.LOG, detail.DESCRIPTION       || '*' ||
--                                            detail.TAG_NUMBER        || '*' ||
--                                            detail.SERIAL_NUMBER     || '*' ||
--                                            detail.UNITS             || '*' ||
--                                            detail.CATEGORY          || '*' ||
--                                            detail.COST              || '*' ||
--                                            detail.VENDOR_NAME       || '*' ||
--                                            detail.INVOICE_NUMBER    || '*' ||
--                                            detail.BOOK_CODE         || '*' ||
--                                            detail.DATE_IN_SERVICE   || '*' ||
--                                            detail.DEPRECIATE_METHOD || '*' ||
--                                            detail.PRORATE_CODE      || '*' ||
--                                            detail.CODE_COMBINATION  || '*' ||
--                                            detail.LOCATION          );
        
            ADD_ASSET_ADDITION(
                P_DESCRIPTION       => REPLACE(REPLACE(TRIM(detail.DESCRIPTION), CHR(10), ''), CHR(13), ''),
                P_TAG_NUMBER        => REPLACE(REPLACE(TRIM(detail.TAG_NUMBER), CHR(10), ''), CHR(13), ''),
                P_SERIAL_NUMBER     => REPLACE(REPLACE(TRIM(detail.SERIAL_NUMBER), CHR(10), ''), CHR(13), ''),
                P_UNITS             => REPLACE(REPLACE(TRIM(detail.UNITS), CHR(10), ''), CHR(13), ''),
                P_CATEGORY          => REPLACE(REPLACE(TRIM(detail.CATEGORY), CHR(10), ''), CHR(13), ''),
                P_COST              => REPLACE(REPLACE(TRIM(detail.COST), CHR(10), ''), CHR(13), ''),
                P_VENDOR_NAME       => REPLACE(REPLACE(TRIM(detail.VENDOR_NAME), CHR(10), ''), CHR(13), ''),
                P_INVOICE_NUMBER    => REPLACE(REPLACE(TRIM(detail.INVOICE_NUMBER), CHR(10), ''), CHR(13), ''),
                P_BOOK_CODE         => REPLACE(REPLACE(TRIM(detail.BOOK_CODE), CHR(10), ''), CHR(13), ''),
                P_DATE_IN_SERVICE   => REPLACE(REPLACE(TRIM(detail.DATE_IN_SERVICE), CHR(10), ''), CHR(13), ''),
                P_DEPRECIATE_METHOD => REPLACE(REPLACE(TRIM(detail.DEPRECIATE_METHOD), CHR(10), ''), CHR(13), ''),
                P_PRORATE_CODE      => REPLACE(REPLACE(TRIM(detail.PRORATE_CODE), CHR(10), ''), CHR(13), ''),
                P_CODE_COMBINATION  => REPLACE(REPLACE(TRIM(detail.CODE_COMBINATION), CHR(10), ''), CHR(13), ''),
                P_LOCATION          => REPLACE(REPLACE(TRIM(detail.LOCATION), CHR(10), ''), CHR(13), '')
            );

--            FND_FILE.PUT_LINE(FND_FILE.LOG, '---' ||
--                                detail.DESCRIPTION|| '**' ||
--                                detail.TAG_NUMBER|| '**' ||
--                                detail.SERIAL_NUMBER|| '**' ||
--                                detail.UNITS|| '**' ||
--                                detail.CATEGORY|| '**' ||
--                                detail.COST|| '**' ||
--                                detail.VENDOR_NAME|| '**' ||
--                                detail.INVOICE_NUMBER|| '**' ||
--                                detail.BOOK_CODE|| '**' ||
--                                detail.DATE_IN_SERVICE|| '**' ||
--                                detail.DEPRECIATE_METHOD|| '**' ||
--                                detail.PRORATE_CODE|| '**' ||
--                                detail.CODE_COMBINATION|| '**' ||
--                                REPLACE(REPLACE(detail.LOCATION, chr(10), ''), chr(13), '') || '---');
            
            
            
        EXCEPTION WHEN OTHERS THEN
             FND_FILE.PUT_LINE(FND_FILE.LOG, detail.DESCRIPTION       || '**' ||
                                            detail.TAG_NUMBER        || '**' ||
                                            detail.SERIAL_NUMBER     || '**' ||
                                            detail.UNITS             || '**' ||
                                            detail.CATEGORY          || '**' ||
                                            detail.COST              || '**' ||
                                            detail.VENDOR_NAME       || '**' ||
                                            detail.INVOICE_NUMBER    || '**' ||
                                            detail.BOOK_CODE         || '**' ||
                                            detail.DATE_IN_SERVICE   || '**' ||
                                            detail.DEPRECIATE_METHOD || '**' ||
                                            detail.PRORATE_CODE      || '**' ||
                                            detail.CODE_COMBINATION  || '**' ||
                                            detail.LOCATION          || '**' ||
                                            SQLERRM);   
        END;   
        END LOOP;
        
        
        FND_FILE.PUT_LINE(FND_FILE.LOG , '**************************************************************************************************');
        
        
        DELETE FROM PAC_ASSET_ADDITIONS_TB;   
        COMMIT;     
    
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
                    P_CODE_COMBINATION      VARCHAR2,     --Cuenta Gastos
                    P_LOCATION              VARCHAR2      --Dirección
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
            
        
--            FND_FILE.PUT_LINE(FND_FILE.LOG, P_DESCRIPTION       || '*' ||
--                                            P_TAG_NUMBER        || '*' ||
--                                            P_SERIAL_NUMBER     || '*' ||
--                                            P_UNITS             || '*' ||
--                                            P_CATEGORY          || '*' ||
--                                            P_COST              || '*' ||
--                                            P_VENDOR_NAME       || '*' ||
--                                            P_INVOICE_NUMBER    || '*' ||
--                                            P_BOOK_CODE         || '*' ||
--                                            P_DATE_IN_SERVICE   || '*' ||
--                                            P_DEPRECIATE_METHOD || '*' ||
--                                            P_PRORATE_CODE      || '*' ||
--                                            P_CODE_COMBINATION  || '*' ||
--                                            P_LOCATION          );
--            RETURN;
        
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
        FND_FILE.PUT_LINE(FND_FILE.LOG , '');
        
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
            FND_FILE.PUT_LINE(FND_FILE.LOG , '* * * ERROR * * *: Al consultar la categoría.' || SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Descripción : ' || P_DESCRIPTION);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Etiqueta : ' || P_TAG_NUMBER);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Serie : ' || P_SERIAL_NUMBER);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Categoría : ' || P_CATEGORY);
            RETURN;
        END;
        
        
        l_asset_cat_rec.CATEGORY_ID         :=  var_category_id;
            
        l_asset_type_rec.ASSET_TYPE         :=  'CAPITALIZED';                      
        l_asset_fin_rec.COST                :=  P_COST;   
        
        
        /**********************************************
                    CONSULTA DEL PROVEEDOR
        **********************************************/
        BEGIN
            IF P_VENDOR_NAME IS NOT NULL THEN
                SELECT VENDOR_ID
                  INTO var_vendor_id
                  FROM PO_VENDORS   PV
                 WHERE 1 = 1
                   AND PV.VENDOR_TYPE_LOOKUP_CODE = 'VENDOR'
                   AND PV.VENDOR_NAME = P_VENDOR_NAME;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG , '* * * ERROR * * *: Al consultar el nombre del proveedor.' || SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Descripción : ' || P_DESCRIPTION);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Etiqueta : ' || P_TAG_NUMBER);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Serie : ' || P_SERIAL_NUMBER);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Proveedor : ' || P_VENDOR_NAME);
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
            FND_FILE.PUT_LINE(FND_FILE.LOG , '* * * ERROR * * *: Al consultar el método de depreciación.' || SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Descripción : ' || P_DESCRIPTION);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Etiqueta : ' || P_TAG_NUMBER);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Serie : ' || P_SERIAL_NUMBER);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Método de Depreciación : ' || P_DEPRECIATE_METHOD);
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
            FND_FILE.PUT_LINE(FND_FILE.LOG , '* * * ERROR * * *: Al consultar la cuenta contable.' || SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Descripción : ' || P_DESCRIPTION);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Etiqueta : ' || P_TAG_NUMBER);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Serie : ' || P_SERIAL_NUMBER);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cuenta de Gastos : ' || P_CODE_COMBINATION);
            RETURN;
        END;
        
        l_asset_dist_rec.EXPENSE_CCID       :=  var_code_combination_id;
        
        /**********************************************
                    CONSULTA DE LA DIRECCIÓN
        **********************************************/
        DECLARE
            var_segment1    VARCHAR2(100);
            var_segment2    VARCHAR2(100);
            var_segment3    VARCHAR2(100);
            var_location    VARCHAR2(100);
        BEGIN  
        
--            var_segment1 := TRIM(SUBSTR(P_LOCATION, 0, INSTR(P_LOCATION, '.') - 1));
--            var_location := TRIM(REPLACE(P_LOCATION, SUBSTR(P_LOCATION, 0, INSTR(P_LOCATION, '.')), ''));
--            var_segment2 := TRIM(SUBSTR(var_location, 0, INSTR(var_location, '.') - 1));
--            var_segment3 := TRIM(REPLACE(var_location, SUBSTR(var_location, 0, INSTR(var_location, '.')), ''));
            
--            SELECT FL.LOCATION_ID
--              INTO var_location_id
--              FROM FA_LOCATIONS FL
--             WHERE SEGMENT1 = var_segment1
--               AND SEGMENT2 = var_segment2
--               AND SEGMENT3 = SUBSTR(var_segment3, 0, 4);

            SELECT FL.LOCATION_ID
              INTO var_location_id
              FROM FA_LOCATIONS FL
             WHERE (SEGMENT1 || '.' || SEGMENT2 || '.' || SEGMENT3) LIKE P_LOCATION;
        
        EXCEPTION WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, '* * * ERROR * * *: Al consultar la dirección de asignación.' || SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Descripción : ' || P_DESCRIPTION);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Etiqueta : ' || P_TAG_NUMBER);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Número Serie : ' || P_SERIAL_NUMBER);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Dirección : *' || P_LOCATION || '*');
            RETURN;
        END;
        
        l_asset_dist_rec.LOCATION_CCID      :=  var_location_id;                                
        l_asset_dist_rec.ASSIGNED_TO        :=  NULL;
        l_asset_dist_rec.TRANSACTION_UNITS  :=  l_asset_dist_rec.UNITS_ASSIGNED;
        l_asset_dist_tbl(1)                 :=  l_asset_dist_rec;
        
    
       
    
        fa_addition_pub.do_addition(
           p_api_version             => 1.0,
           p_init_msg_list           => FND_API.G_FALSE,
           p_commit                  => FND_API.G_TRUE,
           p_validation_level        => FND_API.G_VALID_LEVEL_NONE,
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