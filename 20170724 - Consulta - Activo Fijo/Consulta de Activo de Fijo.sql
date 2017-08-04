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
    FROM fa_additions_b fab,--
         fa_additions_tl fat,--
         fa_distribution_history fdh,--
         gl_code_combinations gcc,
         fnd_flex_value_sets ffvs_cc,
         fnd_flex_values ffv_cc,
         fnd_flex_values_tl ffvt_cc,
         fnd_flex_value_sets ffvs_cia,
         fnd_flex_values ffv_cia,
         fnd_flex_values_tl ffvt_cia,
         fa_books fb,
         
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



po_vendors po, 
fa_asset_invoices ai,
fa_invoice_details_v,
fa_retirements,
fa_transaction_headers		th,
fa_distribution_history		dh,
fa_asset_history			ah,


SELECT     /*+ ordered */
        &ACCT_FLEX_BAL_SEG        comp_code,
    falu.meaning                asset_type,
    decode (ah.asset_type,
        'CIP', cb.cip_cost_acct,
        cb.asset_cost_acct)            account,
    &ACCT_FLEX_COST_SEG        cost_center,
    ad.asset_number,
    ret.date_retired,
    ad.asset_number || ' - ' || ad.description        asset_num_desc,
    th.transaction_type_code,
    th.asset_id,
    books.date_placed_in_service,
    sum(decode(aj.adjustment_type, 'COST', 1, 'CIP COST', 1, 0) *
        decode(aj.debit_credit_flag, 'DR', -1, 'CR', 1, 0) *
        aj.adjustment_amount)        cost,
    sum(decode(aj.adjustment_type, 'NBV RETIRED', -1, 0) *
        decode(aj.debit_credit_flag, 'DR', -1, 'CR', 1, 0) *
        aj.adjustment_amount)        nbv,
/*    round(decode(ret.units, null,
        (decode(th.transaction_type_code, 'REINSTATEMENT',
        -ret.proceeds_of_sale, ret.proceeds_of_sale)
         * (dh.units_assigned / ah.units)),
        (decode(th.transaction_type_code, 'REINSTATEMENT',
        -ret.proceeds_of_sale, ret.proceeds_of_sale)
         * nvl(-dh.transaction_units,dh.units_assigned) / ret.units)), 4)    proceeds,  */
    sum(decode(aj.adjustment_type, 'PROCEEDS CLR', 1, 'PROCEEDS', 1, 0) *
        decode(aj.debit_credit_flag, 'DR', 1, 'CR', -1, 0) *
        aj.adjustment_amount)        proceeds,            
    sum(decode(aj.adjustment_type, 'REMOVALCOST', -1, 0) *
        decode(aj.debit_credit_flag, 'DR', -1, 'CR', 1, 0) *
        aj.adjustment_amount)        removal,    
    sum(decode(aj.adjustment_type,'REVAL RSV RET',1,0)*
        decode(aj.debit_credit_flag, 'DR',-1,'CR',1,0)*
         aj.adjustment_amount)        reval_rsv_ret,
    th.transaction_header_id,
    decode (th.transaction_type_code,
        'REINSTATEMENT', '*','PARTIAL RETIREMENT','P',
		to_char(null))			code
FROM
	fa_transaction_headers		th,
	fa_additions			ad,
	&lp_fa_books				books,
	&lp_fa_retirements			ret,
	&lp_fa_adjustments			aj,
	fa_distribution_history		dh,
	gl_code_combinations		dhcc,
	fa_asset_history			ah,
	fa_category_books			cb,
	fa_lookups			falu
WHERE 	
	th.date_effective		 >= :PERIOD1_POD		AND
	th.date_effective		 <= :PERIOD2_PCD		AND
	th.book_type_code		 =  :P_BOOK		AND
	th.transaction_key		= 'R'
AND
	ret.book_type_code		= :P_BOOK		AND	
	ret.asset_id		= books.asset_id		AND
	decode (th.transaction_type_code,
		'REINSTATEMENT', ret.transaction_header_id_out,
		ret.transaction_header_id_in)	= th.transaction_header_id
AND
	ad.asset_id		= th.asset_id
AND
	aj.asset_id		= ret.asset_id		AND
	aj.book_type_code	= :P_BOOK		
     and aj.adjustment_type not in (select  'PROCEEDS' from &lp_fa_adjustments aj1
				where aj1.book_type_code = aj.book_type_code
				and aj1.asset_id = aj.asset_id
				and aj1.transaction_header_id = aj.transaction_header_id
				and aj1.adjustment_type = 'PROCEEDS CLR')  
AND	aj.transaction_header_id	= th.transaction_header_id
AND
	ah.asset_id		= ad.asset_id		AND
	ah.date_effective		<= th.date_effective		AND
	nvl(ah.date_ineffective, th.date_effective+1)
				> th.date_effective
AND
	falu.lookup_code		= ah.asset_type		AND
	falu.lookup_type		= 'ASSET TYPE'
AND
	books.transaction_header_id_out
				= th.transaction_header_id	AND
	books.book_type_code	= :P_BOOK		AND
	books.asset_id		= ad.asset_id
AND	
	cb.category_id		= ah.category_id		AND
	cb.book_type_code		= :P_BOOK
AND
	dh.distribution_id	= aj.distribution_id
/*   AND   (dh.date_effective <= th.date_effective
 OR nvl(dh.date_ineffective, th.date_effective+1) >= th.date_effective)   
 AND th.book_type_code = dh.book_type_code  */
AND th.asset_id = dh.asset_id   
AND
	dhcc.code_combination_id	= dh.code_combination_id
GROUP BY
	falu.meaning,
	&ACCT_FLEX_BAL_SEG,
	&ACCT_FLEX_COST_SEG,
	th.transaction_type_code,
	th.asset_id,
	cb.asset_cost_acct,
	cb.cip_cost_acct,
	ad.asset_number,
 	ad.description,
	books.date_placed_in_service,
	ret.date_retired,
	th.transaction_header_id,
	ah.asset_type,
	ret.gain_loss_amount
ORDER BY 1,2,3,4,5,6
