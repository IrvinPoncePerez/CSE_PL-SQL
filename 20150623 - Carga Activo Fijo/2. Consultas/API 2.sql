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

   l_return_status            VARCHAR2(1);     
   l_mesg_count               number;
   l_mesg                     varchar2(4000);

begin

   dbms_output.enable(10000000);

   FA_SRVR_MSG.Init_Server_Message;

   -- desc info
   l_asset_desc_rec.description                  := '&description';
   l_asset_desc_rec.asset_key_ccid               := null;

   -- cat info 
   l_asset_cat_rec.category_id                   := &category_id

   --type info
   l_asset_type_rec.asset_type                   := '&asset_type';

   -- fin info
   l_asset_fin_rec.cost                          := &cost
   l_asset_fin_rec.date_placed_in_service        := '&DPIS';
   l_asset_fin_rec.depreciate_flag               := 'YES';

   -- deprn info
   l_asset_deprn_rec.ytd_deprn                   := &ytd
   l_asset_deprn_rec.deprn_reserve               := &reserve
   l_asset_deprn_rec.bonus_ytd_deprn             := 0;
   l_asset_deprn_rec.bonus_deprn_reserve         := 0;

   -- book / trans info
   l_asset_hdr_rec.book_type_code                := '&book';

   -- distribution info
   l_asset_dist_rec.units_assigned               := 1;
   l_asset_dist_rec.expense_ccid                 := &ccid
   l_asset_dist_rec.location_ccid                := &location_id
   l_asset_dist_rec.assigned_to                  := null;
   l_asset_dist_rec.transaction_units            := l_asset_dist_rec.units_assigned;
   l_asset_dist_tbl(1)                           := l_asset_dist_rec;

   -- call the api 
   fa_addition_pub.do_addition(
           -- std parameters
           p_api_version             => 1.0,
           p_init_msg_list           => FND_API.G_FALSE,
           p_commit                  => FND_API.G_FALSE,
           p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
           p_calling_fn              => null,
           x_return_status           => l_return_status,
           x_msg_count               => l_mesg_count,
           x_msg_data                => l_mesg,
           -- api parameters
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