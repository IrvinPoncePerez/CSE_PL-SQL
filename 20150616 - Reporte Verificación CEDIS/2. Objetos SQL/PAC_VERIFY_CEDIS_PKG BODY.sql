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
    
    
    FUNCTION VERIFY_STEP4 (COLUMN_DESC    VARCHAR2,
                           COLUMN_VAL     VARCHAR2,
                           P_ORG_INVENTORY_ID  NUMBER   DEFAULT 0,
                           P_OPERATING_UNIT_ID NUMBER   DEFAULT 0)
    RETURN VARCHAR2
    IS
    BEGIN
     
        IF      COLUMN_DESC = 'Internal_or_External'    THEN   IF COLUMN_VAL = 'Internal'                           THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Organization_Classifications'  THEN   IF COLUMN_VAL = 'Inventory Organization'               THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Enabled'                 THEN   IF COLUMN_VAL = 'Y'                                  THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Additional_Information'  THEN   IF COLUMN_VAL = 'Accounting Information'             THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Primary_Ledger'          THEN   IF COLUMN_VAL = 'CALVARIO_LIBRO_CONTABLE'            THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Legal_Entity'            THEN   IF COLUMN_VAL = 'Productos Avicolas El Calvario, S. de R.L. de C.V.'  THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Location'                THEN   IF COLUMN_VAL = GET_LOCATION_CODE(P_ORG_INVENTORY_ID)  THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Operating_Unit'          THEN   IF COLUMN_VAL = GET_OPERATING_UNIT(P_OPERATING_UNIT_ID)THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        
        ELSIF   COLUMN_DESC = 'Organization_Code'           THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Item_Master_Organization'    THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Calendar'                    THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Locator_Control'             THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Allow_Negative_Balances'     THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Auto_Delete_Allocations'     THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Process_Manufacturing_Enabled'THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Costing_Organization'        THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Costing_Method'              THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Transfer_to_GL'              THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Valuation_Accounts'          THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Material'                    THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Outside_Processing'          THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Material_Overhead'           THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Overhead'                    THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Resource'                    THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Expense'                     THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Lot_Control_Generation'      THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Child_Lot_Control_Total_Length'THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Serial_Control_Generation'   THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'InterOrg_Transfer_Charge'    THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'InterOrg_Transfer_Accounts'  THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Transfer_Credit'             THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Price_Variance'              THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receivable'                  THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Payable'                     THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Intransit_Inventory'         THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receiving_Accounts'          THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Purchase_Price_Variance'     THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Invoice_Price_Variance'      THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Inventory_AP_Accrual'        THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Encumbrance'                 THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Profit_and_Loss_Accounts'    THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Sales'                       THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Cost_of_Goods_Sold'          THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Other_Accounts'              THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Deferred_COGS_Account'       THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Cost_Variance_Account'       THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'CONTEXT'                     THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'TIPO_PROCESO'                THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'AREA'                        THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        
        ELSIF   COLUMN_DESC = 'Enforce_Ship-To'             THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'ASN_Control_Action'          THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receipt_Days_Early'          THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receipt_Days_Late'           THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receipt_Days_Exceed-Action'  THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Over_Receipt_Tolerance'      THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Over_Receipt_Action'         THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'RMA_Receipt_Routing'         THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receipt_Routing'             THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Allow_Substitute_Receipts'   THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Allow_Unordered_Receipts'    THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Allow_Express_Transactions'  THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Allow_Cascade_Transactions'  THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Allow_Blind_Receiving'       THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Validate_Serial_Numbers'     THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receipt_Number_Generation'   THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receipt_Number_Type'         THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Next_Receipt_Number'         THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Validate_Lots_on_RMA_Receipts' THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Receiving_Inventory'         THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Retroactive_Price_Adjustment'THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Clearing'                    THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Advanced_Pricing'            THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSIF   COLUMN_DESC = 'Transportation_Execution'    THEN    IF COLUMN_VAL = '' THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;
        ELSE    RETURN '';
        END IF;
                
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
    
    

END PAC_VERIFY_CEDIS_PKG;