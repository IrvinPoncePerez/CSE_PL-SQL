package xxcalv.oracle.apps.ar.PortalFacturas.server;

import oracle.apps.fnd.framework.server.OAViewObjectImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class SERFOLVOImpl extends OAViewObjectImpl {
    /**This is the default constructor (do not remove)
     */
    public SERFOLVOImpl() {
        super();
        this.setFullSqlMode(this.FULLSQL_MODE_AUGMENTATION);
        this.setQuery("SELECT DISTINCT SERFOL " + 
        "  FROM PAC_MASTEREDI_REPORT_TB " + 
        " WHERE SERFOL IN (SELECT DISTINCT " + 
        "                         DS.ATTRIBUTE1 " + 
        "                    FROM RA_CUST_TRX_TYPES_ALL            RT, " + 
        "                         FND_DOC_SEQUENCE_ASSIGNMENTS     DSA, " + 
        "                         FND_DOCUMENT_SEQUENCES           DS " + 
        "                   WHERE 1 = 1 " + 
        "                     AND RT.NAME = DSA.CATEGORY_CODE " + 
        "                     AND DSA.DOC_SEQUENCE_ID = DS.DOC_SEQUENCE_ID " + 
        "                     AND DS.ATTRIBUTE_CATEGORY = 'CALV_SERIES_FACTURACION' " + 
        "                     AND RT.ORG_ID = (CASE " + 
        "                                          WHEN '"+username+"' IN (SELECT FV.FLEX_VALUE " + 
        "                                                                  FROM FND_FLEX_VALUE_SETS FVS, " + 
        "                                                                       FND_FLEX_VALUES     FV " + 
        "                                                                 WHERE 1 = 1 " + 
        "                                                                   AND FVS.FLEX_VALUE_SET_ID = FV.FLEX_VALUE_SET_ID " + 
        "                                                                   AND FVS.FLEX_VALUE_SET_NAME = 'PAC_SAT_SEC_SERFOL' " + 
        "                                                                   AND FV.ENABLED_FLAG = 'Y') " + 
        "                                          THEN RT.ORG_ID " + 
        "                                          ELSE TO_NUMBER('"+orgId+"') " + 
        "                                       END)) ORDER BY SERFOL ASC ");
    }
    
    private static String orgId="";
    private static String username="";
    
    public static void setOrgId(String org_id){
        orgId = org_id;
    }
    
    public static void setUsername(String user_name){
        username = user_name;
    }
    
}
