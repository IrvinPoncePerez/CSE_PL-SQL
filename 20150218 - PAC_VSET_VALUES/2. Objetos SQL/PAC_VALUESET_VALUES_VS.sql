CREATE OR REPLACE FORCE VIEW PAC_VALUESET_VALUES_VS 
AS
SELECT FFVS.FLEX_VALUE_SET_ID,
       FFVS.FLEX_VALUE_SET_NAME,
       FFV.FLEX_VALUE_ID,
       FFV.FLEX_VALUE,
       FFV.ENABLED_FLAG,
       FFV.START_DATE_ACTIVE,
       FFV.END_DATE_ACTIVE,
       FFVT.DESCRIPTION       
  FROM FND_FLEX_VALUE_SETS  FFVS,
       FND_FLEX_VALUES      FFV,
       FND_FLEX_VALUES_TL   FFVT      
 WHERE 1 = 1
   AND FFV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
   AND FFV.FLEX_VALUE_ID = FFVT.FLEX_VALUE_ID
   AND FFVT.LANGUAGE = USERENV('LANG')
   AND (FFVS.FLEX_VALUE_SET_NAME = 'XXCALV_CONDUCTORES_REND'
     OR FFVS.FLEX_VALUE_SET_NAME = 'PAC_LIST_OF_DAMAGE_VS')
 ORDER BY FFVS.FLEX_VALUE_SET_NAME ASC,
          FFV.FLEX_VALUE ASC,
          FFVT.DESCRIPTION ASC,
          FFV.ENABLED_FLAG DESC;
   