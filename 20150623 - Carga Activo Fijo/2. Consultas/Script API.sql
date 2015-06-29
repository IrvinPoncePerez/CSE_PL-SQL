declare

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

begin

    FA_SRVR_MSG.Init_Server_Message;

    l_asset_desc_rec.DESCRIPTION        :=  'SEMI REMOLQUE TIPO TOLVA';         --Required
    l_asset_desc_rec.TAG_NUMBER         :=  'E-52';                             --Required
    l_asset_desc_rec.SERIAL_NUMBER      :=  '3R9T84432FD';                      --Required
    l_asset_desc_rec.CURRENT_UNITS      :=  1;                                  --Required
    l_asset_desc_rec.NEW_USED           := 'NEW';                               
            
    l_asset_cat_rec.CATEGORY_ID         :=  106;                                --Required
        
    l_asset_type_rec.ASSET_TYPE         :=  'CAPITALIZED';                      --Required
    l_asset_fin_rec.COST                :=  380000;                             --Required
            
    l_inv_rec.PO_VENDOR_ID              :=  1386;                               --Required
    l_inv_rec.INVOICE_NUMBER            :=  1333;                               --Required
    l_inv_rec.DESCRIPTION               :=  l_asset_desc_rec.DESCRIPTION;
    l_inv_rec.PAYABLES_COST             :=  l_asset_fin_rec.COST;
    l_inv_rec.PAYABLES_UNITS            :=  l_asset_desc_rec.CURRENT_UNITS;
        
    l_inv_tbl (1)                       :=  l_inv_rec;
        
    l_asset_hdr_rec.BOOK_TYPE_CODE      :=  'CORP GRB';                         --Required
        
    l_asset_fin_rec.DATE_PLACED_IN_SERVICE  :=  '01-JAN-2011';                  --Required
    l_asset_fin_rec.DEPRN_METHOD_CODE   :=  'TASA 20';                          --Required
    l_asset_fin_rec.DEPRECIATE_FLAG     :=  'YES';                              --Required
    l_asset_fin_rec.LIFE_IN_MONTHS :=  60;                                      --Required
    l_asset_fin_rec.PRORATE_CONVENTION_CODE :=  'MES SIGUIE';                   --Required
        
    l_asset_dist_rec.UNITS_ASSIGNED     :=  l_asset_desc_rec.CURRENT_UNITS;
    l_asset_dist_rec.EXPENSE_CCID       :=  10692;                              --Required
    l_asset_dist_rec.LOCATION_CCID      :=  104;                                --Required
    l_asset_dist_rec.ASSIGNED_TO        :=  NULL;
    l_asset_dist_rec.TRANSACTION_UNITS  :=  l_asset_dist_rec.UNITS_ASSIGNED;
    l_asset_dist_tbl(1)                 :=  l_asset_dist_rec;
        
        
    --FA_ADDITIONS
    --FA_CATEGORIES_B
    --PO_VENDORS
    --FA_BOOK_CONTROLS
    --FA_METHODS
    --FA_CONVENTION_TYPES,
    --GL_CODE_COMBINATIONS
    --FA_LOCATIONS_KFV
        
        

       

   -- call the api
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
     
   dbms_output.put_line(l_return_status);

   --dump messages
   l_mesg_count := fnd_msg_pub.count_msg;

   if l_mesg_count > 0 then

      l_mesg := chr(10) || substr(fnd_msg_pub.get
                                    (fnd_msg_pub.G_FIRST, fnd_api.G_FALSE),
                                     1, 250);
      dbms_output.put_line(l_mesg);

      for i in 1..(l_mesg_count - 1) loop
         l_mesg :=
                     substr(fnd_msg_pub.get
                            (fnd_msg_pub.G_NEXT,
                             fnd_api.G_FALSE), 1, 250);

         dbms_output.put_line(l_mesg);
      end loop;

      fnd_msg_pub.delete_msg();

   end if;


   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
     dbms_output.put_line('FAILURE');
   else
     dbms_output.put_line('SUCCESS');
     dbms_output.put_line('THID' || to_char(l_trans_rec.transaction_header_id));
     dbms_output.put_line('ASSET_ID' || to_char(l_asset_hdr_rec.asset_id));
     dbms_output.put_line('ASSET_NUMBER' || l_asset_desc_rec.asset_number);
   end if;

end;