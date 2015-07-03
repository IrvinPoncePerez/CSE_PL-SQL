CREATE OR REPLACE PACKAGE BODY PAC_VERIFY_CEDIS_PKG  AS
    
    FUNCTION VERIFY_STEP1 (COLUMN_DESC    VARCHAR2,
                           COLUMN_VAL     VARCHAR2)
    RETURN VARCHAR2
    IS
    BEGIN
     
        IF      COLUMN_DESC = 'Scope'           THEN   IF COLUMN_VAL = 'GLOBAL'    THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Address_Style'   THEN   IF COLUMN_VAL = 'Mexico'    THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Timezone'        THEN   IF COLUMN_VAL = 'Central Time' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Ship_To_Site'    THEN   IF COLUMN_VAL = 'Y'         THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Bill_To_Site'    THEN   IF COLUMN_VAL = 'Y'         THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receiving_Site'  THEN   IF COLUMN_VAL = 'Y'         THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Internal_Site'   THEN   IF COLUMN_VAL = 'Y'         THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Office_Site'     THEN   IF COLUMN_VAL = 'Y'         THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSE    RETURN '';
        END IF;
                
    END;
    
    
    FUNCTION VERIFY_STEP2 (COLUMN_DESC    VARCHAR2,
                           COLUMN_VAL     VARCHAR2,
                           P_ORG_INVENTORY_ID NUMBER   DEFAULT 0)
    RETURN VARCHAR2
    IS
    BEGIN
     
        IF      COLUMN_DESC = 'Internal_or_External'    THEN   IF COLUMN_VAL = 'Internal'                           THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Organization_Classifications'  THEN   IF COLUMN_VAL = 'Operating Unit'               THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Enabled'                 THEN   IF COLUMN_VAL = 'Y'                                  THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Additional_Information'  THEN   IF COLUMN_VAL = 'Operating Unit Information'         THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Primary_Ledger'          THEN   IF COLUMN_VAL = 'CALVARIO_LIBRO_CONTABLE'            THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Default_Legal_Context'   THEN   IF COLUMN_VAL = 'Productos Avicolas El Calvario, S. de R.L. de C.V.'  THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Location'                THEN   IF COLUMN_VAL = GET_LOCATION_CODE(P_ORG_INVENTORY_ID)  THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSE    RETURN '';
        END IF;
                
    END;
    
    
    FUNCTION VERIFY_STEP4 (COLUMN_DESC    VARCHAR2,
                           COLUMN_VAL     VARCHAR2,
                           P_ORG_INVENTORY_ID  NUMBER   DEFAULT 0,
                           P_OPERATING_UNIT_ID NUMBER   DEFAULT 0)
    RETURN VARCHAR2
    IS
    BEGIN
     
        IF      COLUMN_DESC = 'Internal_or_External'    THEN   IF COLUMN_VAL = 'Internal'                                           THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Organization_Classifications'  THEN   IF COLUMN_VAL = 'Inventory Organization'                       THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Enabled'                 THEN   IF COLUMN_VAL = 'Y'                                                  THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Additional_Information'  THEN   IF COLUMN_VAL = 'Accounting Information'                             THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Primary_Ledger'          THEN   IF COLUMN_VAL = 'CALVARIO_LIBRO_CONTABLE'                            THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Legal_Entity'            THEN   IF COLUMN_VAL = 'Productos Avicolas El Calvario, S. de R.L. de C.V.' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Location'                THEN   IF COLUMN_VAL = GET_LOCATION_CODE(P_ORG_INVENTORY_ID)                THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Operating_Unit'          THEN   IF COLUMN_VAL = GET_OPERATING_UNIT(P_OPERATING_UNIT_ID)              THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        
        ELSIF   COLUMN_DESC = 'Organization_Code'           THEN    IF COLUMN_VAL = GET_ORGANIZATION_CODE(P_ORG_INVENTORY_ID) THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Item_Master_Organization'    THEN    IF COLUMN_VAL = 'CALVARIO ORGANIZACIÓN MAESTRA'     THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Calendar'                    THEN    IF COLUMN_VAL = 'CALVARIO'                          THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Locator_Control'             THEN    IF COLUMN_VAL = '4'                                 THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Allow_Negative_Balances'     THEN    IF COLUMN_VAL = '2'                                 THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Auto_Delete_Allocations'     THEN    IF COLUMN_VAL = 'Y'                                 THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Process_Manufacturing_Enabled'THEN   IF COLUMN_VAL = 'Y'                                 THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Costing_Organization'        THEN    IF COLUMN_VAL = GET_ORG_INVENTORY(P_ORG_INVENTORY_ID) THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Costing_Method'              THEN    IF COLUMN_VAL = 'Standard'                          THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Transfer_to_GL'              THEN    IF COLUMN_VAL = '1'                                 THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Material'                    THEN    IF COLUMN_VAL LIKE '01-__'|| GET_ID_UOSTO(P_OPERATING_UNIT_ID) ||'-110701000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Outside_Processing'          THEN    IF COLUMN_VAL LIKE '01-__'|| GET_ID_UOSTO(P_OPERATING_UNIT_ID) ||'-110701000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Material_Overhead'           THEN    IF COLUMN_VAL LIKE '01-__'|| GET_ID_UOSTO(P_OPERATING_UNIT_ID) ||'-110701000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Overhead'                    THEN    IF COLUMN_VAL LIKE '01-__'|| GET_ID_UOSTO(P_OPERATING_UNIT_ID) ||'-110701000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Resource'                    THEN    IF COLUMN_VAL LIKE '01-__'|| GET_ID_UOSTO(P_OPERATING_UNIT_ID) ||'-110701000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Expense'                     THEN    IF COLUMN_VAL LIKE '01-__'|| GET_ID_UOSTO(P_OPERATING_UNIT_ID) ||'-110701000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Lot_Control_Generation'      THEN    IF COLUMN_VAL = '3'                                 THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Child_Lot_Control_Total_Length'THEN  IF COLUMN_VAL = '80'                                THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Serial_Control_Generation'   THEN    IF COLUMN_VAL = '3'                                 THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'InterOrg_Transfer_Charge'    THEN    IF COLUMN_VAL = '1'                                 THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Transfer_Credit'             THEN    IF COLUMN_VAL LIKE '01-0000-110723000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Price_Variance'              THEN    IF COLUMN_VAL LIKE '01-__'|| GET_ID_UOSTO(P_OPERATING_UNIT_ID) ||'-840400000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receivable'                  THEN    IF COLUMN_VAL LIKE '01-0000-110407000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Payable'                     THEN    IF COLUMN_VAL LIKE '01-0000-110407000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Intransit_Inventory'         THEN    IF COLUMN_VAL LIKE '01-0000-110723000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Purchase_Price_Variance'     THEN    IF COLUMN_VAL LIKE '01-__'|| GET_ID_UOSTO(P_OPERATING_UNIT_ID) ||'-840400000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Invoice_Price_Variance'      THEN    IF COLUMN_VAL LIKE '01-0000-840100000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Inventory_AP_Accrual'        THEN    IF COLUMN_VAL LIKE '01-0000-210105000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Encumbrance'                 THEN    IF COLUMN_VAL LIKE '01-0000-999901000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Sales'                       THEN    IF COLUMN_VAL LIKE '01-__'|| GET_ID_UOSTO(P_OPERATING_UNIT_ID) ||'-510101000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Cost_of_Goods_Sold'          THEN    IF COLUMN_VAL LIKE '01-__'|| GET_ID_UOSTO(P_OPERATING_UNIT_ID) ||'-810100000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Deferred_COGS_Account'       THEN    IF COLUMN_VAL LIKE '01-__'|| GET_ID_UOSTO(P_OPERATING_UNIT_ID) ||'-810100000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Cost_Variance_Account'       THEN    IF COLUMN_VAL LIKE '01-0000-610700000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'CONTEXT'                     THEN    IF COLUMN_VAL = 'TIPO PROCESO'                      THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'TIPO_PROCESO'                THEN    IF COLUMN_VAL = 'CEDIS'                             THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'AREA'                        THEN    IF COLUMN_VAL = 'CEDIS'                             THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        
        ELSIF   COLUMN_DESC = 'Enforce_Ship-To'             THEN    IF COLUMN_VAL = 'NONE' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'ASN_Control_Action'          THEN    IF COLUMN_VAL = 'NONE' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receipt_Days_Early'          THEN    IF COLUMN_VAL = '1' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receipt_Days_Late'           THEN    IF COLUMN_VAL = '1' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receipt_Days_Exceed-Action'  THEN    IF COLUMN_VAL = 'WARNING' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Over_Receipt_Tolerance'      THEN    IF COLUMN_VAL = '1' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Over_Receipt_Action'         THEN    IF COLUMN_VAL = 'WARNING' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'RMA_Receipt_Routing'         THEN    IF COLUMN_VAL = 'Direct Delivery' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receipt_Routing'             THEN    IF COLUMN_VAL = 'Direct Delivery' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Allow_Substitute_Receipts'   THEN    IF COLUMN_VAL = 'N' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Allow_Unordered_Receipts'    THEN    IF COLUMN_VAL = 'N' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Allow_Express_Transactions'  THEN    IF COLUMN_VAL = 'N' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Allow_Cascade_Transactions'  THEN    IF COLUMN_VAL = 'N' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Allow_Blind_Receiving'       THEN    IF COLUMN_VAL = 'N' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Validate_Serial_Numbers'     THEN    IF COLUMN_VAL = 'N' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receipt_Number_Generation'   THEN    IF COLUMN_VAL = 'AUTOMATIC' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receipt_Number_Type'         THEN    IF COLUMN_VAL = 'ALPHANUMERIC' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Next_Receipt_Number'         THEN    IF COLUMN_VAL >= 0 THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Validate_Lots_on_RMA_Receipts' THEN  IF COLUMN_VAL = 'Y' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receiving_Inventory'         THEN    IF COLUMN_VAL LIKE '01-0000-110722000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Clearing'                    THEN    IF COLUMN_VAL LIKE '01-0000-210106000001-00-0000-0000' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Advanced_Pricing'            THEN    IF COLUMN_VAL = 'N' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Transportation_Execution'    THEN    IF COLUMN_VAL = 'N' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSE    RETURN '';
        END IF;
                
    END;
    
    
    FUNCTION VERIFY_STEP5 (ORGANIZATION_CODE    VARCHAR2, 
                           RESPONSABILITY_NAME  VARCHAR2)   
    RETURN VARCHAR2
    IS 
    BEGIN
        
        IF    RESPONSABILITY_NAME = 'CALVARIO_PO_SUPER_USUARIO'      THEN RETURN 'Y'; 
        ELSIF RESPONSABILITY_NAME = 'CALVARIO_PDSM_SUPER_USUARIO'    THEN RETURN 'Y'; 
        ELSIF RESPONSABILITY_NAME = 'CALVARIO_PROD_SUPER_USUARIO'    THEN RETURN 'Y'; 
        ELSIF RESPONSABILITY_NAME = 'CALVARIO_FOR_SUPER_USUARIO'     THEN RETURN 'Y';
        ELSIF RESPONSABILITY_NAME = 'CALVARIO_OM_SUPER_USUARIO'      THEN RETURN 'Y';
        ELSIF RESPONSABILITY_NAME = 'CALVARIO_FIN_SUPER_USUARIO'     THEN RETURN 'Y';
        ELSIF RESPONSABILITY_NAME = 'CALVARIO_INV_SUPER_USUARIO'     THEN RETURN 'Y';
        ELSIF RESPONSABILITY_NAME = 'CALVARIO_AR_SUPER_USUARIO'     THEN RETURN 'Y';
        
        ELSIF RESPONSABILITY_NAME LIKE 'CEDIS_' || REGEXP_REPLACE(ORGANIZATION_CODE, '(.)', '\1%') ||'_AR_SUPER_USUARIO'    THEN RETURN 'Y';
        ELSIF RESPONSABILITY_NAME LIKE 'CEDIS_' || REGEXP_REPLACE(ORGANIZATION_CODE, '(.)', '\1%') ||'_OM_SUP'              THEN RETURN 'Y';
        ELSIF RESPONSABILITY_NAME LIKE 'CEDIS_' || REGEXP_REPLACE(ORGANIZATION_CODE, '(.)', '\1%') || '_PO_SOLICITUDES'     THEN RETURN 'Y';
        ELSIF RESPONSABILITY_NAME LIKE 'CALVARIO_'|| REGEXP_REPLACE(ORGANIZATION_CODE, '(.)', '\1%')                        THEN RETURN 'Y'; 
        ELSIF RESPONSABILITY_NAME LIKE 'CALVARIO_MANT_' || REGEXP_REPLACE(ORGANIZATION_CODE, '(.)', '\1%')                  THEN RETURN 'Y';
        ELSE  RETURN 'N';
        END IF;
        
    END;
    
    
    FUNCTION VERIFY_STEP6 (COLUMN_DESC    VARCHAR2, 
                           COLUMN_VAL     VARCHAR2) 
    RETURN VARCHAR2
    IS
    BEGIN
    
        IF      COLUMN_DESC = 'Name'                    THEN   IF COLUMN_VAL IN ('DEVOL', 'HUEVO', 'INSUM', 'CEDIS')    THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
--        ELSIF   COLUMN_DESC = 'Description'             THEN   IF COLUMN_VAL IN ('SUBINVENTARIO DE DEVOLUCIONES', 'SUBINVENTARIO DE HUEVO', 'SUBINVENTARIO DE INSUMOS')    THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Status'                  THEN   IF COLUMN_VAL = 'Active'    THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Replenishment_Count_Type'THEN   IF COLUMN_VAL = 'Order Quantity'    THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSE    RETURN '';
        END IF;
    
    END;
    
    
    FUNCTION VERIFY_STEP7 (COLUMN_DESC    VARCHAR2, 
                           COLUMN_VAL     VARCHAR2, 
                           P_ORG_INVENTORY_ID  NUMBER   DEFAULT 0) 
    RETURN VARCHAR2
    IS
    BEGIN
    
        IF      COLUMN_DESC = 'Organization_Code' THEN   IF COLUMN_VAL = GET_ORGANIZATION_CODE(P_ORG_INVENTORY_ID) THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Item_Assign'       THEN   IF COLUMN_VAL IN ('HVOBCO0070',
                                                                            'HVOBCO0200',
                                                                            'HVOBCO0201',
                                                                            'HVOBCO0202',
                                                                            'HVOBCO0203',
                                                                            'HVOBCO0204',
                                                                            'HVOBCO0205',
                                                                            'HVOBCO0206',
                                                                            'HVOCON0001',
                                                                            'HVOCON0002',
                                                                            'HVOCON0003',
                                                                            'HVOCON0007',
                                                                            'HVORES0001')  THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Assigned'          THEN   IF COLUMN_VAL = 'Y'        THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Category_Set'      THEN   IF COLUMN_VAL = 'COSTOS'   THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Control_Level'     THEN   IF COLUMN_VAL = 'Org'      THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Category'          THEN   IF COLUMN_VAL = 'HUEV'     THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSE RETURN '';
        END IF;
        
    END;
    
    
    
    
    
    FUNCTION GET_LOCATION_CODE(P_ORG_INVENTORY_ID  NUMBER)
    RETURN VARCHAR2
    IS
        var_result  VARCHAR2(10) := '';
    BEGIN
    
        SELECT HLA.LOCATION_CODE
          INTO var_result
          FROM HR_LOCATIONS_ALL     HLA
         WHERE 1 = 1
           AND HLA.INVENTORY_ORGANIZATION_ID = P_ORG_INVENTORY_ID;
    
        RETURN var_result;
    END;
    
    
    FUNCTION GET_OPERATING_UNIT(P_OPERATING_UNIT_ID  NUMBER)
    RETURN VARCHAR2
    IS
        var_value   VARCHAR2(500)  := '';
    BEGIN
    
        SELECT HOU.NAME
          INTO var_value
          FROM HR_ORGANIZATION_UNITS    HOU
         WHERE HOU.ORGANIZATION_ID = P_OPERATING_UNIT_ID;
        
        RETURN var_value;
    END;
    
    FUNCTION GET_ORG_INVENTORY(P_ORG_INVENTORY_ID  NUMBER)         
    RETURN VARCHAR2
    IS
        var_value   VARCHAR2(500)  := '';
    BEGIN
    
        SELECT HOU.NAME
          INTO var_value
          FROM HR_ORGANIZATION_UNITS    HOU
         WHERE HOU.ORGANIZATION_ID = P_ORG_INVENTORY_ID;
        
        RETURN var_value;
    END;
    
    
    FUNCTION GET_ACCOUNT(P_CODE_COMBINATION_ID  NUMBER)
    RETURN VARCHAR2
    IS
        var_value   VARCHAR2(100) := ' ';
    BEGIN
    
        SELECT GCC.SEGMENT1 || '-' ||
               GCC.SEGMENT2 || '-' ||
               GCC.SEGMENT3 || '-' ||
               GCC.SEGMENT4 || '-' ||
               GCC.SEGMENT5 || '-' ||
               GCC.SEGMENT6
          INTO var_value
          FROM GL_CODE_COMBINATIONS GCC
         WHERE 1 = 1
           AND GCC.CODE_COMBINATION_ID = P_CODE_COMBINATION_ID;
    
        RETURN var_value;
    END;
    
    
    FUNCTION GET_ORGANIZATION_CODE (P_ORG_INVENTORY_ID  NUMBER)
    RETURN VARCHAR2
    IS
        var_value   VARCHAR2(10) := ' ';
    BEGIN
    
        SELECT MP.ORGANIZATION_CODE
          INTO var_value
          FROM MTL_PARAMETERS           MP
         WHERE 1 = 1
           AND MP.ORGANIZATION_ID = P_ORG_INVENTORY_ID;
    
        RETURN var_value;
    END;
    
    
    FUNCTION GET_ID_UOSTO(P_OPERATING_UNIT_ID   NUMBER)         
    RETURN VARCHAR2
    IS
        var_value       VARCHAR2(10) := ' ';
    BEGIN
        
        SELECT HOU.ATTRIBUTE2
          INTO var_value
          FROM HR_ORGANIZATION_UNITS        HOU
         WHERE 1 = 1
           AND HOU.ORGANIZATION_ID = P_OPERATING_UNIT_ID;
    
        RETURN var_value;
    END;
    

END PAC_VERIFY_CEDIS_PKG;