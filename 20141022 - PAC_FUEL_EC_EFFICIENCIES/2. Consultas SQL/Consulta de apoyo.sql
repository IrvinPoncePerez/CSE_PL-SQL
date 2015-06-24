SELECT   NVL (cii.instance_description, msn.descriptive_text) AS descripcion,
         msn.serial_number no_activo, msi.description grupo_activos,
         cii.attribute1 modelo, cii.attribute2 placa, cii.attribute3 motor,
         cii.attribute4 serie_motor, cii.attribute5 cpl, cii.attribute6 marca,
         cii.attribute7 chasis, cii.attribute8 uni_ant, cii.attribute9 nota,
         cii.attribute10 combustible, cii.attribute11 vin,
         eomd.accounting_class_code cuenta_wip,
         el.location_codes area, 
         mp.organization_code codigo_inv
    FROM mtl_parameters mp,
         csi_item_instances cii,
         eam_org_maint_defaults eomd,
         csi_i_assets cia,
         mfg_lookups ml1,
         bom_departments bd,
         pn_locations_all pl,
         mtl_eam_locations el,
         mtl_categories_kfv mck,
         mtl_categories_tl mct,
         mtl_system_items_b_kfv msi,
         mtl_system_items msi_prod,
         mtl_serial_numbers msn_prod,
         mtl_parameters mp_prod,
         fa_additions_b fa,
         mtl_object_genealogy mog,
         mtl_serial_numbers msn,
         mtl_serial_numbers msn_parent,
         csi_item_instances cii2,
         mfg_lookups ml2,
         csi_ii_geolocations geo
   WHERE mp.organization_id = msn.current_organization_id
     AND msn.current_organization_id = msi.organization_id
     AND msi.inventory_item_id = msn.inventory_item_id
     AND msi.eam_item_type IN (1, 3)
     AND msi.serial_number_control_code <> 1
     AND msn.inventory_item_id = cii.inventory_item_id(+)
     AND msn.serial_number = cii.serial_number(+)
     AND msn.gen_object_id = mog.object_id(+)
     AND cii.instance_id = eomd.object_id(+)
     AND eomd.object_type = 50
     AND (eomd.organization_id = mp.maint_organization_id)
     AND cii.asset_criticality_code = ml1.lookup_code(+)
     AND ml1.lookup_type(+) = 'MTL_EAM_ASSET_CRITICALITY'
     AND eomd.owning_department_id = bd.department_id(+)
     AND cii.pn_location_id = pl.location_id(+)
     AND SYSDATE >= NVL (pl.active_start_date(+), SYSDATE)
     AND SYSDATE <= NVL (pl.active_end_date(+), SYSDATE)
     AND eomd.area_id = el.location_id(+)
     AND cii.category_id = mck.category_id(+)
     AND cii.equipment_gen_object_id = msn_prod.gen_object_id(+)
     AND msn_prod.current_organization_id = msi_prod.organization_id(+)
     AND msn_prod.inventory_item_id = msi_prod.inventory_item_id(+)
     AND msi_prod.organization_id = mp_prod.organization_id(+)
     AND msi_prod.equipment_type(+) = 1
     AND cii.instance_id = cia.instance_id(+)
     AND cia.fa_asset_id = fa.asset_id(+)
     AND cii.instance_id = geo.instance_id(+)
     AND geo.valid_flag(+) = 'Y'
     AND SYSDATE >= NVL (cia.active_start_date(+), SYSDATE)
     AND SYSDATE <= NVL (cia.active_end_date(+), SYSDATE)
     AND mog.parent_object_id = msn_parent.gen_object_id(+)
     AND mog.genealogy_type(+) = 5
     AND SYSDATE >= NVL (mog.start_date_active(+), SYSDATE)
     AND SYSDATE <= NVL (mog.end_date_active(+), SYSDATE)
     AND msn_parent.inventory_item_id = cii2.inventory_item_id(+)
     AND msn_parent.serial_number = cii2.serial_number(+)
     AND ml2.lookup_type(+) = 'SERIAL_NUM_STATUS'
     AND ml2.lookup_code(+) = msn.current_status
     AND mck.category_id = mct.category_id(+)
     AND mct.LANGUAGE(+) = USERENV ('LANG')
     AND mp.organization_code = :P_CODIGO
     AND msn.serial_number NOT LIKE 'PAC%'
     AND msn.serial_number NOT LIKE 'NUEV%'
     AND msn.serial_number NOT LIKE 'ERR%'
     AND cii.instance_description NOT LIKE 'PAC%'
     AND cii.instance_description NOT LIKE 'NUEV%'
     AND cii.instance_description NOT LIKE 'ERR%'
     AND msn.serial_number NOT LIKE 'POS%'
     AND cii.instance_description NOT LIKE 'POS%'
     AND msn.serial_number NOT LIKE 'INV%'
     AND cii.instance_description NOT LIKE 'INV%'
     AND msn.serial_number NOT LIKE '%REN%'
     AND cii.instance_description NOT LIKE '%REN%'
     AND msn.serial_number NOT LIKE 'GRB%'
     AND cii.instance_description NOT LIKE 'GRB%'
     --and cii.maintainable_flag != 'N'
     AND cii.active_end_date IS NULL
ORDER BY msn.serial_number asc, el.location_codes asc 