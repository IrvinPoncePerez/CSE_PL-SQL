/* Formatted on 2017/07/24 17:27 (Formatter Plus v4.8.8) */
/* FORMATTED ON 2017/07/24 17:05 (FORMATTER PLUS V4.8.8) */
SELECT   fab.asset_number AS numero,
         UPPER (fat.description) AS descripcion,
         (CASE
             WHEN fab.owned_leased = 'OWNED'
                THEN 'PROPIEDAD'
             WHEN fab.owned_leased = 'LEASED'
                THEN 'ARRENDADO'
          END
         ) AS tipo_movimiento,
         fab.attribute_category_code AS categoria,
         fdh.units_assigned AS unidades,
         gcc.segment1 AS clave_compania,
         ffvt_cia.description AS compania,
         gcc.segment2 AS clave_centro_costo,
         ffvt_cc.description AS centro_costos,
         fb.date_placed_in_service AS fecha_en_servicio,
         fb.COST AS costo
    FROM fa_additions_b fab,
         fa_additions_tl fat,
         fa_distribution_history fdh,
         gl_code_combinations gcc,
         fnd_flex_value_sets ffvs_cc,
         fnd_flex_values ffv_cc,
         fnd_flex_values_tl ffvt_cc,
         fnd_flex_value_sets ffvs_cia,
         fnd_flex_values ffv_cia,
         fnd_flex_values_tl ffvt_cia,
         fa_books fb
   WHERE 1 = 1
     AND fab.asset_id = fat.asset_id
     AND fat.LANGUAGE = USERENV ('LANG')
     AND fab.asset_id = fdh.asset_id
     AND fdh.code_combination_id = gcc.code_combination_id
     AND fdh.date_ineffective IS NULL
     AND ffvs_cc.flex_value_set_name = 'CC_ CALVARIO'
     AND ffv_cc.flex_value_set_id = ffvs_cc.flex_value_set_id
     AND ffv_cc.flex_value_id = ffvt_cc.flex_value_id
     AND ffvt_cc.LANGUAGE = USERENV ('LANG')
     AND ffv_cc.enabled_flag = 'Y'
     AND ffv_cc.flex_value = gcc.segment2
     AND ffvs_cia.flex_value_set_name = 'CIA_CALVARIO'
     AND ffv_cia.flex_value_set_id = ffvs_cia.flex_value_set_id
     AND ffv_cia.flex_value_id = ffvt_cia.flex_value_id
     AND ffvt_cia.LANGUAGE = USERENV ('LANG')
     AND ffv_cia.enabled_flag = 'Y'
     AND ffv_cia.flex_value = gcc.segment1
     AND fb.book_type_code = fdh.book_type_code
     AND fb.asset_id = fab.asset_id
     AND fb.date_ineffective IS NULL
ORDER BY gcc.segment1, fab.attribute_category_code;