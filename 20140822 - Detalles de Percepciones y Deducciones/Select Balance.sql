 SELECT APPS.PAY_BALANCE_PKG.GET_VALUE(
                        P_DEFINED_BALANCE_ID    => PDB.DEFINED_BALANCE_ID,
                        P_ASSIGNMENT_ACTION_ID  => :P_ASSIGNMENT_ACTION_ID, 
                        P_TAX_UNIT_ID => :P_TAX_UNIT_ID,
                        P_JURISDICTION_CODE => NULL, 
                        P_SOURCE_ID => NULL, 
                        P_TAX_GROUP => NULL,
                        P_DATE_EARNED => :P_DATE_EARNED) BALNCE
--               INTO var_result_value      
               FROM PAY_BALANCE_TYPES        PBT,
                    PAY_BALANCE_DIMENSIONS   PBD,
                    PAY_DEFINED_BALANCES     PDB
              WHERE 1 = 1
                AND PBT.BALANCE_NAME = :P_BALANCE_NAME
                AND PBD.DATABASE_ITEM_SUFFIX = :P_ITEM_SUFFIX
                AND PBD.LEGISLATION_CODE = 'MX'
                AND (PDB.BALANCE_TYPE_ID = PBT.BALANCE_TYPE_ID
                AND PDB.BALANCE_DIMENSION_ID = PBD.BALANCE_DIMENSION_ID);
                
                
SELECT PEEV.ENTRY_VALUE  
  FROM PAY_ELEMENT_ENTRIES_V PEEV 
 WHERE 1 = 1
   AND PEEV.ELEMENT_NAME = :P_ELEMENT_NAME
   AND PEEV.NAME = :P_ENTRY_NAME
   AND PEEV.ASSIGNMENT_ACTION_ID = :P_ASSIGNMENT_ACTION_ID;
--   AND PEEV.PEE_EFFECTIVE_END_DATE = :P_END_DATE;