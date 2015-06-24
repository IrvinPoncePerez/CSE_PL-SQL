CREATE OR REPLACE FUNCTION PAC_GET_FULL_VENDOR_NAME(p_vendor_id   NUMBER) 
RETURN VARCHAR2
IS
    var_employee_id         NUMBER;
    var_full_vendor_name    VARCHAR2(200);
BEGIN
    
    SELECT DISTINCT
           EMPLOYEE_ID
      INTO var_employee_id
      FROM PO_VENDORS   PV
     WHERE PV.VENDOR_ID = p_vendor_id;
     
     IF (var_employee_id IS NOT NULL) THEN
        
        SELECT DISTINCT
               (
                TRIM(PAP.FIRST_NAME)    || ' ' ||
                (CASE
                  WHEN PAP.MIDDLE_NAMES IS NULL THEN ''
                  ELSE PAP.MIDDLE_NAMES || ' '
                 END)                   ||
                 TRIM(PAP.LAST_NAME)    || ' ' ||
                 TRIM(PAP.PER_INFORMATION1)
               ) FULL_VENDOR_NAME
          INTO var_full_vendor_name
          FROM PER_ALL_PEOPLE_F   PAP
         WHERE PAP.PERSON_ID = var_employee_id;
     
     ELSE
     
        SELECT DISTINCT
               PV.VENDOR_NAME
          INTO var_full_vendor_name
          FROM PO_VENDORS     PV
         WHERE PV.VENDOR_ID = p_vendor_id;
     
     END IF;
     
     RETURN UPPER(TRIM(var_full_vendor_name));

EXCEPTION WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al consultar el Full Vendor Name en la función PAC_GET_FULL_VENDOR_NAME. ' || SQLERRM);
    dbms_output.put_line('**Error al consultar el Full Vendor Name en la función PAC_GET_FULL_VENDOR_NAME. ' || SQLERRM);
END;