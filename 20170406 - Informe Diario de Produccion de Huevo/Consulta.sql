select subinventory_code,
          inventory_item_id,
          QTTY_DIA_ANTERIOR2, ENTRADA3, VENTAS4, DESECHO5, MUERTES6, SALIDAS25, CAMPO7, CAMPO8
          
          , ((entrada3 + qtty_dia_anterior2) - (ventas4+desecho5+muertes6) - salidas25)  existencia_actual,

trunc((muertes6*100)/decode(((entrada3 + qtty_dia_anterior2) - (ventas4+desecho5+muertes6) - salidas25),0,1,((entrada3 + qtty_dia_anterior2) - (ventas4+desecho5+muertes6) - salidas25)),2) porc_mu
      
,SEMANAS9, Cajas10, restos11, cascado15, sucio16,normal17,KILOS18, KILOS_TOT, QTTY_DIA_ANTERIOR19,ENTRADA20,SALIDAS26,CONSUMO21,EXISTENCIA_ACTUAL22,
          FACTOR_CONVER23,GRS_X_AVE24
from (  
select 
          decode(x.segment11, :P_PELECHAS, x.name||' PE',x.name)  subinventory_code, --Nombre de Subinventario
          --x.name,
          x.inventory_item_id,
          XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_INV_DIA_ANT(trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.inventory_item_id, x.subinventory_code, x.organization_id, 'AVE') QTTY_DIA_ANTERIOR2, --Existencia_Anterior_Aves
          XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_DOT_DIA_FNC(trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.inventory_item_id, :P_POLLITA_COMERCIAL,x.subinventory_code, x.organization_id, 'AVE') ENTRADA3, --Entrada_de_Aves
          abs(XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_MOI_DIA_FNC(trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.inventory_item_id, x.subinventory_code, x.organization_id, 'VENTA')) VENTAS4, --Venta_Aves
          abs(XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_MOI_DIA_FNC(trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.inventory_item_id, x.subinventory_code, x.organization_id, 'DESECHOS')) DESECHO5, --Desecho_Aves
          abs(XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_MOI_DIA_FNC(trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.inventory_item_id, x.subinventory_code, x.organization_id, 'MUERTE')) MUERTES6, --Muerte_Aves
          nvl(XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_DOTSOT_FNC(trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.inventory_item_id, x.subinventory_code, x.organization_id, 'AVE'),0) SALIDAS25, -- Salida_Aves
          'CAMPO6/CAMPO8' CAMPO7, --%Mortandad
          '(CAMPO3 + CAMPO2) - (CAMPO4+CAMPO5+CAMP6)' CAMPO8, --Existencia_Actual
          XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_EDAD_FNC(x.subinventory_code, x.organization_id, trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS'))) SEMANAS9, --Semanas_Ave
          XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_WIPC_HBSC_FNC(x.organization_id, trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.subinventory_code, 'CAJAS', :P_HUEVO_SUCABL)  Cajas10, --Cajas_de_Huevo
          XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_WIPC_HBSC_FNC(x.organization_id, trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.subinventory_code, 'RESTOS', :P_HUEVO_BLANCO_EXTRA)  restos11, --Cajas_de_Huevo_2
          '(CAMPO12/CAMPO2)*100' CAMPO14, --%Postura
          XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_WIPC_XTH_FNC(x.organization_id, trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.subinventory_code, :P_HUEVO_CASCADO, 'S') cascado15, --Huevo_Cascado
          XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_WIPC_XTH_FNC(x.organization_id, trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.subinventory_code, :P_HUEVO_SUCIO, 'S') sucio16, --Huevo_Sucio
          nvl(XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_WIPC_XTH_FNC(x.organization_id, trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.subinventory_code, :P_HUEVO_BLANCO, 'S'),0) normal17, --Huevo_Normal
          --+ nvl(XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_WIPC_XTH_FNC(trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.subinventory_code, :P_HUEVO_BLANCO_EXTRA, 'S'),0) 
          round(XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_WIPC_XTH_FNC(x.organization_id, trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.subinventory_code, NULL, 'P')) KILOS18, --Kilos_De_Huevo
          round(XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_WIPC_XTH_FNC(x.organization_id, trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.subinventory_code, :P_HUEVO_BLANCO, 'HK')) KILOS_TOT, --Total_Kg_Huevo_Normal
          nvl(XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_INV_DIA_ANT(trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.inventory_item_id, x.subinventory_code, x.organization_id, 'ALIMENTO'),0) QTTY_DIA_ANTERIOR19, --Existencia_Anterior_Alimento
          XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_DOT_DIA_FNC(trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.inventory_item_id, NULL,x.subinventory_code, x.organization_id, 'ALIMENTO') ENTRADA20, --Entrada_Alimento
          nvl(XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_DOTSOT_FNC(trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.inventory_item_id, x.subinventory_code, x.organization_id, 'ALIMENTO'),0) SALIDAS26, --Salida_X_Traspaso
          abs(XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_WIS_FNC(trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.subinventory_code, x.organization_id)) CONSUMO21,  --Consumo_Alimento
          nvl(XXCALV_REPORTE_PROD_HUEVO_PKG.XXCALV_ONHAND_FNC(trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS')), x.subinventory_code,x.organization_id),0) EXISTENCIA_ACTUAL22, --Existencia_Actual_Alimento
          'CAMPO21/CAMPO18' FACTOR_CONVER23, -- Factor_De_Conversion
          'CAMPO21/CAMPO8' GRS_X_AVE24,  --Gramos_x_Ave
          x.gh
from
        ( 
            --Para obtener los subinvetarios que contienen on-hand en ciertas organizaciones, 
          select x.subinventory_code,
                   x.name,
                   x.organization_id,
                   x.inventory_item_id,
                   x.segment11,
                  -- x.parent_lot_number,
                   x.gh
          from 
          (select  moq.subinventory_code,
                      hl.name, 
                      hl.organization_id,
                      moq.inventory_item_id,
                      mcb.segment11,
                     mt.parent_lot_number,
                     to_number(REGEXP_REPLACE(moq.subinventory_code,'[A-Z,a-z]')) gh,
                     (sum(moq.primary_transaction_quantity)
                     -
                    nvl((
                    SELECT SUM(mt1.primary_quantity)
                    FROM mtl_material_transactions mt1, 
                              mtl_transaction_lot_numbers ml,
                              mtl_lot_numbers mn
                    WHERE 1 = 1  
                    AND mt1.transaction_id = ml.transaction_id
                    AND mt1.inventory_item_id = moq.inventory_item_id 
                    AND mt1.subinventory_code = moq.subinventory_code
                    and mt1.organization_id = hl.organization_id
                    and ml.lot_number = mn.lot_number
                    and ml.organization_id = mn.organization_id
                    and ml.inventory_item_id = mn.inventory_item_id
                    and mn.parent_lot_number = mt.parent_lot_number    
                    AND TRUNC(mt1.transaction_date) > trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS'))
                    ), 0) 
                     ) numero
            from mtl_onhand_quantities_detail moq,
                    mtl_lot_numbers mt,
                    --mtl_system_items_b msi,
                    mtl_item_categories mc,
                    mtl_category_sets_tl ms,
                    mtl_categories_b mcb,
                    hr_all_organization_units hl
            where 1 = 1 
            and moq.lot_number = mt.lot_number
            and moq.organization_id = mt.organization_id
            and moq.inventory_item_id = mt.inventory_item_id
            and mt.parent_lot_number is not null
            --and moq.organization_id = msi.organization_id
            and moq.inventory_item_id  = mc.inventory_item_id
            and moq.organization_id = mc.organization_id
           -- and moq.inventory_item_id = msi.inventory_item_id
            --and msi.inventory_item_id = mc.inventory_item_id
            --and msi.organization_id = mc.organization_id
            and mc.category_set_id = ms.category_set_id
            and mc.category_id = mcb.category_id
            --and trunc(sysdate) <= trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS'))
            and ms.language = USERENV('LANG')
            and ms.category_set_name = :P_AVES
            and moq.organization_id = hl.organization_id
            and exists (
                            select 1
                            from mtl_parameters mp 
                            where 1 = 1
                            and mp.organization_id = moq.organization_id 
                            and mp.attribute_category = 'TIPO PROCESO'
                            and mp.attribute10 = 'PC'
                            )                            
            and not exists (
                                    select 1
                                    from mtl_onhand_quantities_detail oh,
                                            mtl_item_categories mc,
                                            mtl_category_sets_tl ms,
                                            mtl_categories_b mcb        
                                    where 1 = 1
                                    and oh.subinventory_code = moq.subinventory_code  
                                    and oh.organization_id = moq.organization_id
                                    and oh.inventory_item_id = mc.inventory_item_id
                                    and oh.organization_id = mc.organization_id
                                    and mc.category_set_id = ms.category_set_id
                                    and mc.category_id = mcb.category_id
                                    and ms.language = USERENV('LANG')
                                    and ms.category_set_name = :P_COSTOS
                                    and mcb.segment1  in (:P_ALIMENTO,:P_HUEVO)
                                )
            and not exists (
                                    select 1
                                    from mtl_material_transactions mm,
                                            mtl_item_categories mc,
                                            mtl_category_sets_tl ms,
                                            mtl_categories_b mcb        
                                    where 1 = 1
                                    and mm.subinventory_code = moq.subinventory_code
                                    and mm.organization_id = moq.organization_id
                                    and mm.inventory_item_id = mc.inventory_item_id
                                    and mm.organization_id = mc.organization_id
                                    and mc.category_set_id = ms.category_set_id
                                    and mc.category_id = mcb.category_id
                                    and ms.language = USERENV('LANG')
                                    and ms.category_set_name = :P_COSTOS
                                    and mcb.segment1  in (:P_ALIMENTO,:P_HUEVO)
                                 )            
--            &P_ARTICULOS
            group by moq.subinventory_code, hl.name, hl.organization_id, moq.inventory_item_id, mcb.segment11, mt.parent_lot_number
            ) 
            x
            where x.numero > 0
            group by x.subinventory_code,
                   x.name,
                   x.organization_id,
                   x.inventory_item_id,
                   x.segment11,
                  -- x.parent_lot_number,
                   x.gh
            union
            -- Obtener el subinventario mediante la existencia de transaciones
            Select mt.subinventory_code,
                      hl.name, 
                      hl.organization_id,
                      mt.inventory_item_id,
                      mcb.segment11,
                      --ml.parent_lot_number,
                      to_number(REGEXP_REPLACE(mt.subinventory_code,'[A-Z,a-z]')) gh
            from mtl_material_transactions mt
                   ,mtl_transaction_lot_numbers mtl
                   ,mtl_lot_numbers ml,
                   --,mtl_system_items_b msi,
                    mtl_item_categories mc,
                    mtl_category_sets_tl ms,
                    mtl_categories_b mcb,
                    hr_all_organization_units hl
            where 1 = 1
            and mt.transaction_id = mtl.transaction_id
            and mtl.lot_number = ml.lot_number
            and ml.parent_lot_number is not null
            and mtl.organization_id = ml.organization_id
            and mtl.inventory_item_id = ml.inventory_item_id
            and mt.inventory_item_id = mc.inventory_item_id
            and mt.organization_id = mc.organization_id
            --and msi.inventory_item_id = mt.inventory_item_id 
            --and msi.organization_id = mt.organization_id
            --and msi.inventory_item_id = mc.inventory_item_id
            --and msi.organization_id = mc.organization_id
            and mc.category_set_id = ms.category_set_id
            and mc.category_id = mcb.category_id
            and sysdate > trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS'))
            and ms.language = USERENV('LANG')
            and ms.category_set_name = :P_AVES
            and mtl.organization_id = hl.organization_id
            and not exists (
                                    select 1
                                    from mtl_onhand_quantities_detail oh,
                                            mtl_item_categories mc,
                                            mtl_category_sets_tl ms,
                                            mtl_categories_b mcb        
                                    where 1 = 1
                                    and oh.subinventory_code = mt.subinventory_code  
                                    and oh.inventory_item_id = mc.inventory_item_id
                                    and oh.organization_id = mc.organization_id
                                    and mc.category_set_id = ms.category_set_id
                                    and mc.category_id = mcb.category_id
                                    and ms.language = USERENV('LANG')
                                    and ms.category_set_name = :P_COSTOS
                                    and mcb.segment1  in (:P_ALIMENTO,:P_HUEVO)
                                    and exists (
                                                       select 1
                                                       from mtl_parameters mp 
                                                       where 1 = 1
                                                       and mp.organization_id = oh.organization_id 
                                                        and mp.attribute_category = 'TIPO PROCESO'
                                                        and mp.attribute10 = 'PC'
                                                       )   
                                )
                                and 0 = nvl((
                                    select sum(oh.primary_transaction_quantity)
                                                 -   nvl((
                                                        SELECT SUM(mt1.primary_quantity)
                                                        FROM mtl_material_transactions mt1
                                                        WHERE 1 = 1  
                                                        AND mt1.inventory_item_id = oh.inventory_item_id 
                                                        AND mt1.subinventory_code = oh.subinventory_code
                                                        AND mt1.organization_id = oh.organization_id    
                                                        AND TRUNC(mt1.transaction_date) > trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS'))
                                                        ), 0)
                                    from mtl_onhand_quantities_detail oh,
                                            mtl_item_categories mc,
                                            mtl_category_sets_tl ms,
                                            mtl_categories_b mcb        
                                    where 1 = 1
                                    and oh.subinventory_code = mt.subinventory_code  
                                    and oh.organization_id = mt.organization_id
                                    and oh.inventory_item_id = mc.inventory_item_id
                                    and oh.organization_id = mc.organization_id
                                    and mc.category_set_id = ms.category_set_id
                                    and mc.category_id = mcb.category_id
                                    and ms.language = USERENV('LANG')
                                    and ms.category_set_name = :P_AVES
                                    and mcb.segment11  = :P_PELECHAS
                                    group by oh.subinventory_code, oh.organization_id, oh.inventory_item_id
                                ),0)
--            and not exists (
--                                    select 1
--                                    from mtl_onhand_quantities_detail oh,
--                                            mtl_item_categories mc,
--                                            mtl_category_sets_tl ms,
--                                            mtl_categories_b mcb        
--                                    where 1 = 1
--                                    and oh.subinventory_code = mt.subinventory_code  
--                                    and oh.inventory_item_id = mc.inventory_item_id
--                                    and oh.organization_id = mc.organization_id
--                                    and mc.category_set_id = ms.category_set_id
--                                    and mc.category_id = mcb.category_id
--                                    and ms.language = USERENV('LANG')
--                                    and ms.category_set_name = :P_AVES
--                                    and exists (
--                                                    select 1
--                                              from mtl_parameters mp 
--                                              where 1 = 1
--                                              and mp.organization_id = oh.organization_id 
--                                             and mp.attribute_category = 'TIPO PROCESO'
--                                             and mp.attribute10 = 'PC'
--                                                      )   
--                                    --and mcb.segment11  = :P_PELECHAS
--                                )    
            and not exists (
                                    select 1
                                    from mtl_material_transactions mm,
                                            mtl_item_categories mc,
                                            mtl_category_sets_tl ms,
                                            mtl_categories_b mcb        
                                    where 1 = 1
                                    and mm.subinventory_code = mt.subinventory_code
                                    and mm.organization_id = mt.organization_id
                                    and mm.inventory_item_id = mc.inventory_item_id
                                    and mm.organization_id = mc.organization_id
                                    and mc.category_set_id = ms.category_set_id
                                    and mc.category_id = mcb.category_id
                                    and ms.language = USERENV('LANG')
                                    and ms.category_set_name = :P_COSTOS
                                    and mcb.segment1  in (:P_ALIMENTO,:P_HUEVO)
                                 )
            and exists (
                            select 1
                            from mtl_parameters mp 
                            where 1 = 1
                            and mp.organization_id = mt.organization_id 
                            and mp.attribute_category = 'TIPO PROCESO'
                            and mp.attribute10 = 'PC'
                            )     
            and trunc(mt.transaction_date) = trunc(to_date(:p_date,'yyyy/mm/dd HH24:MI:SS'))
--            &P_ARTICULOS
            group by mt.subinventory_code, hl.name, hl.organization_id, mt.inventory_item_id, mcb.segment11--, ml.parent_lot_number
        )             x
        order by gh
)           
group by   subinventory_code,
          inventory_item_id,
          QTTY_DIA_ANTERIOR2, ENTRADA3, VENTAS4, DESECHO5, MUERTES6, SALIDAS25, CAMPO7, CAMPO8,SEMANAS9, Cajas10, restos11, cascado15, sucio16,normal17,KILOS18, KILOS_TOT, QTTY_DIA_ANTERIOR19,ENTRADA20,SALIDAS26,CONSUMO21,EXISTENCIA_ACTUAL22,
          FACTOR_CONVER23,GRS_X_AVE24, gh
        order by gh 