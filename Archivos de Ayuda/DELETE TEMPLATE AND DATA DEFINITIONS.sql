select * from XDO_DS_DEFINITIONS_TL  where data_source_code = :p_template_code;

--delete   from XDO_DS_DEFINITIONS_TL  where data_source_code = :p_template_code;
--commit;

select * from XDO_DS_DEFINITIONS_B   where data_source_code = :p_template_code;

--delete   from XDO_DS_DEFINITIONS_b   where data_source_code = :p_template_code;
--commit;

select * from XDO_TEMPLATES_B where template_code = :p_template_code;

--delete from XDO_TEMPLATES_B where template_code = :p_template_code;
--commit;

select * from XDO_TEMPLATES_TL where template_code = :p_template_code;

--delete from XDO_TEMPLATES_TL where template_code = :p_template_code;
--commit;

SELECT * FROM XDO_LOBS WHERE LOB_CODE = :p_template_code;

--delete FROM XDO_LOBS WHERE LOB_CODE = :p_template_code;
--commit
 
SELECT * FROM XDO_CONFIG_VALUES WHERE TEMPLATE_CODE = :p_template_code;