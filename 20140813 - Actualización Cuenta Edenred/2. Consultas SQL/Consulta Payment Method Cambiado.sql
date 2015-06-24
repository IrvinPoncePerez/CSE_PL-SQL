SELECT 
               PPPM.ATTRIBUTE1,
               PEA.SEGMENT3
--          INTO
--               var_attribute1,
--               var_segment3
          FROM PAY_PERSONAL_PAYMENT_METHODS_F   PPPM,
               PAY_EXTERNAL_ACCOUNTS            PEA
         WHERE 1 = 1
           AND PPPM.PERSONAL_PAYMENT_METHOD_ID = :var_personal_payment_method_id           
           AND PEA.EXTERNAL_ACCOUNT_ID = PPPM.EXTERNAL_ACCOUNT_ID
           AND PEA.EXTERNAL_ACCOUNT_ID = :var_external_account_id
           AND PPPM.OBJECT_VERSION_NUMBER = (SELECT 
                                                MAX(PM.OBJECT_VERSION_NUMBER)
                                               FROM PAY_PERSONAL_PAYMENT_METHODS_F PM
                                              WHERE PM.PERSONAL_PAYMENT_METHOD_ID = PPPM.PERSONAL_PAYMENT_METHOD_ID)
           AND PEA.OBJECT_VERSION_NUMBER = (SELECT
                                               MAX(EA.OBJECT_VERSION_NUMBER)
                                              FROM PAY_EXTERNAL_ACCOUNTS    EA
                                             WHERE EA.EXTERNAL_ACCOUNT_ID = PEA.EXTERNAL_ACCOUNT_ID);