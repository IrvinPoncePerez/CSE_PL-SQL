DECLARE

    P_ELEMENT_LINK_ID   NUMBER := 3198;
    P_ELEMENT_TYPE_ID   NUMBER := 531;

    CURSOR DETAIL_LIST IS
           SELECT PEEF.ELEMENT_ENTRY_ID,
                  PEEF.EFFECTIVE_START_DATE,
                  PEEF.OBJECT_VERSION_NUMBER,
                  PEEF.ASSIGNMENT_ID
             FROM PAY_ELEMENT_ENTRIES_F PEEF
            WHERE 1=1
              AND PEEF.ELEMENT_LINK_ID = :P_ELEMENT_LINK_ID
              AND PEEF.ELEMENT_TYPE_ID = :P_ELEMENT_TYPE_ID;
              
    P_EFFECTIVE_START_DATE      DATE;
    P_EFFECTIVE_END_DATE        DATE;
    P_DELETE_WARNING            BOOLEAN;
    

BEGIN

    FOR detail IN DETAIL_LIST LOOP
    
        PAY_ELEMENT_ENTRY_API.DELETE_ELEMENT_ENTRY(p_validate => FALSE,
                                                   p_datetrack_delete_mode => 'ZAP',
                                                   p_effective_date => detail.EFFECTIVE_START_DATE,
                                                   p_element_entry_id => detail.ELEMENT_ENTRY_ID,
                                                   p_object_version_number => detail.OBJECT_VERSION_NUMBER,
                                                   p_effective_start_date => P_EFFECTIVE_START_DATE,
                                                   p_effective_end_date => P_EFFECTIVE_END_DATE,
                                                   p_delete_warning => P_DELETE_WARNING);
                                                   
        COMMIT;

    END LOOP;
    
END;

--PAY_ELEMENT_ENTRY_API.DELETE_ELEMENT_ENTRY