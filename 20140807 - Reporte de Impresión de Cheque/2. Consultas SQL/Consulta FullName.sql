SELECT ACA.VENDOR_ID,
               TRIM(ACA.VENDOR_NAME) ACA_VENDOR_NAME,
               TRIM(AVV.VENDOR_NAME) AVV_VENDOR_NAME
--               (TRIM(PPF.FIRST_NAME)      || ' ' || 
--                (CASE 
--                    WHEN PPF.MIDDLE_NAMES IS NULL THEN ''
--                    ELSE PPF.MIDDLE_NAMES || ' ' 
--                 END) || 
--                TRIM(PPF.LAST_NAME)       || ' ' ||
--                TRIM(PPF.PER_INFORMATION1)) FULL_VENDOR_NAME
          FROM AP_CHECKS_ALL        ACA,
               AP_VENDORS_V         AVV,
               PER_ALL_PEOPLE_F     PPF
         WHERE 1 = 1
           AND ACA.VENDOR_ID = AVV.VENDOR_ID
           AND AVV.EMPLOYEE_ID = PPF.PERSON_ID
           AND ACA.VENDOR_NAME <> AVV.VENDOR_NAME
           
