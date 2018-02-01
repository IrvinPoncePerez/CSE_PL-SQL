CREATE OR REPLACE AND COMPILE JAVA SOURCE NAMED APPS.CFDI AS

import oracle.sql.ARRAY;
import java.sql.Array;
import java.sql.SQLException;
import java.sql.Connection;
import oracle.jdbc.OracleDriver;
import oracle.sql.ArrayDescriptor;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.DriverManager;
import java.io.IOException;
/**
 *
 * @author Irvin Ponce Perez
 * @since 27.12.2017
 */
public class CFDI {
    
    public static String getUUID(String rfcemi, String rfcrec, String serfol, String numfol, String emianio, String emimes, String emidia) {
        
        Connection objSQLConnection = null;
        Statement objStatement = null;
        ResultSet objResultSet = null;
        String uuid = null;
            
        try{
            
            String url = "jdbc:sqlserver://192.1.1.119:1433;databaseName=masfacturadb;user=iponce;password=P@55M3";
            String query = "select rep_rfc " +
                                  ",rep_rfc_receptor "+
                                  ",rep_serie "+
                                  ",rep_folio "+
                                  ",rep_tipodoc "+
                                  ",rep_emianio "+
                                  ",rep_emimes "+
                                  ",rep_emidia "+
                                  ",rep_emihora "+
                                  ",rep_monto "+
                                  ",rep_UUID "+
                                  ",rep_Versio "+
                                  ",rep_CodMetPag "+
                           "from dbo.reporte rep "+
                           "where 1 = 1 " +
                           " and rep.rep_rfc = '"+rfcemi+"'"+
                           " and rep.rep_rfc_receptor = '"+rfcrec+"'"+
                           " and rep.rep_serie = '"+serfol+"'"+
                           " and rep.rep_folio = '"+numfol+"'"+
                           " and rep.rep_emianio = '"+emianio+"'"+
                           " and rep.rep_emimes = '"+emimes+"'"+
                           " and rep.rep_emidia = '"+emidia+"';";

        
            
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver"); 
            objSQLConnection = DriverManager.getConnection(url);
            
            objStatement = objSQLConnection.createStatement();
            objResultSet  = objStatement.executeQuery(query);
            
            while (objResultSet.next()){
                
                String rep_rfc = objResultSet.getString("rep_rfc");
                String rep_rfc_receptor = objResultSet.getString("rep_rfc_receptor");
                String rep_serie = objResultSet.getString("rep_serie");
                String rep_folio = objResultSet.getString("rep_folio");
                String rep_tipodoc = objResultSet.getString("rep_tipodoc");
                String rep_emianio = objResultSet.getString("rep_emianio");
                String rep_emimes = objResultSet.getString("rep_emimes");
                String rep_emidia = objResultSet.getString("rep_emidia");
                String rep_emihora = objResultSet.getString("rep_emihora");
                String rep_monto = objResultSet.getString("rep_monto");
                uuid = objResultSet.getString("rep_UUID");
                String rep_Versio = objResultSet.getString("rep_Versio");
                String rep_CodMetPag = objResultSet.getString("rep_CodMetPag");
            
                try {
                    #sql { 
                        INSERT 
                          INTO PAC_MASTEREDI_REPORT_TB 
                             ( RFCEMI,
                               RFCREC,
                               SERFOL,
                               NUMFOL,
                               TIPDOC,
                               EMIANIO,
                               EMIMES,
                               EMIDIA,
                               EMIHORA,
                               TOTPAG,
                               UUID,
                               VERSIO,
                               CODMETPAG
                               ) 
                        VALUES 
                             (
                               :rep_rfc,
                               :rep_rfc_receptor,
                               :rep_serie,
                               :rep_folio,
                               :rep_tipodoc,
                               :rep_emianio,
                               :rep_emimes,
                               :rep_emidia,
                               :rep_emihora,
                               :rep_monto,
                               :uuid,
                               :rep_Versio,
                               :rep_CodMetPag
                              )     
                    };
                
                } catch (SQLException ex) {}
                
                #sql {
                    COMMIT
                };
            }
        
        } catch (SQLException ex) {
            return ex.getMessage();
        } catch (Exception ex){
            return ex.getMessage();
        } finally {
            if (objResultSet != null) try { objResultSet.close(); } catch(Exception ex) { return ex.getMessage(); }
            if (objStatement != null) try { objStatement.close(); } catch(Exception ex) { return ex.getMessage(); }
            if (objSQLConnection != null) try { objSQLConnection.close(); } catch(Exception ex) { return ex.getMessage(); }
        }
        
        return "-OK-"+uuid;
    }
    
    public static String getMessages(String rfcemi, String rfcrec, String serfol, String numfol){
        
        Connection objSQLConnection = null;
        Statement objStatement = null;
        ResultSet objResultSet = null;
            
        try{
            
            String url = "jdbc:sqlserver://192.1.1.119:1433;databaseName=masfacturadb;user=iponce;password=P@55M3";
            String query = "select eve.eve_date," +
                                  "eve.eve_title,"+
                                  "eve.eve_desc " +
                           "from dbo.eventos eve "+
                           "where 1 = 1 " +
                           "and eve.eve_desc like '%"+rfcemi+"_"+rfcrec+"_"+serfol+"_"+numfol+"%';";

        
            
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver"); 
            objSQLConnection = DriverManager.getConnection(url);
            
            objStatement = objSQLConnection.createStatement();
            objResultSet  = objStatement.executeQuery(query);
            
            while (objResultSet.next()){
            
                String eve_date = objResultSet.getString("eve_date");
                String eve_title = objResultSet.getString("eve_title");
                String eve_desc = objResultSet.getString("eve_desc");
            
                #sql { 
                    INSERT 
                      INTO PAC_MASTEREDI_LOG_TB 
                         ( RFCEMI,
                           RFCREC,
                           SERFOL,
                           NUMFOL,
                           EVE_DATE,
                           EVE_TITLE,
                           EVE_DESC) 
                    VALUES 
                         ( :rfcemi,
                           :rfcrec,
                           :serfol,
                           :numfol,
                           :eve_date,
                           :eve_title,
                           :eve_desc)     
                };
                
                #sql {
                    COMMIT
                };
            }
        
        } catch (SQLException ex) {
            return ex.getMessage();
        } catch (Exception ex){
            return ex.getMessage();
        } finally {
            if (objResultSet != null) try { objResultSet.close(); } catch(Exception e) { return e.getMessage(); }
            if (objStatement != null) try { objStatement.close(); } catch(Exception e) { return e.getMessage(); }
            if (objSQLConnection != null) try { objSQLConnection.close(); } catch(Exception e) { return e.getMessage(); }
        }
        
        return "OK";
    }
    
    public static String sync(String emianio, String emimes){
        
        Connection objSQLConnection = null;
        Statement objStatement = null;
        ResultSet objResultSet = null;
        String message = null;
        int count = 0;
            
        try{
            
            String url = "jdbc:sqlserver://192.1.1.119:1433;databaseName=masfacturadb;user=iponce;password=P@55M3";
            String query = "select rep_rfc " +
                                  ",rep_rfc_receptor "+
                                  ",rep_serie "+
                                  ",rep_folio "+
                                  ",rep_tipodoc "+
                                  ",rep_emianio "+
                                  ",rep_emimes "+
                                  ",rep_emidia "+
                                  ",rep_emihora "+
                                  ",rep_monto "+
                                  ",rep_UUID "+
                                  ",rep_Versio "+
                                  ",rep_CodMetPag "+
                           "from dbo.reporte rep "+
                           "where 1 = 1 " +
                           " and rep.rep_emianio = '"+emianio+"'"+
                           " and rep.rep_emimes = '"+emimes+"';";

        
            
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver"); 
            objSQLConnection = DriverManager.getConnection(url);
            
            objStatement = objSQLConnection.createStatement();
            objResultSet  = objStatement.executeQuery(query);
            
            while (objResultSet.next()){
                
                String rep_rfc = objResultSet.getString("rep_rfc");
                String rep_rfc_receptor = objResultSet.getString("rep_rfc_receptor");
                String rep_serie = objResultSet.getString("rep_serie");
                String rep_folio = objResultSet.getString("rep_folio");
                String rep_tipodoc = objResultSet.getString("rep_tipodoc");
                String rep_emianio = objResultSet.getString("rep_emianio");
                String rep_emimes = objResultSet.getString("rep_emimes");
                String rep_emidia = objResultSet.getString("rep_emidia");
                String rep_emihora = objResultSet.getString("rep_emihora");
                String rep_monto = objResultSet.getString("rep_monto");
                String rep_UUID = objResultSet.getString("rep_UUID");
                String rep_Versio = objResultSet.getString("rep_Versio");
                String rep_CodMetPag = objResultSet.getString("rep_CodMetPag");
            
                try {
                    #sql { 
                        INSERT 
                          INTO PAC_MASTEREDI_REPORT_TB 
                             ( RFCEMI,
                               RFCREC,
                               SERFOL,
                               NUMFOL,
                               TIPDOC,
                               EMIANIO,
                               EMIMES,
                               EMIDIA,
                               EMIHORA,
                               TOTPAG,
                               UUID,
                               VERSIO,
                               CODMETPAG
                               ) 
                        VALUES 
                             (
                               :rep_rfc,
                               :rep_rfc_receptor,
                               :rep_serie,
                               :rep_folio,
                               :rep_tipodoc,
                               :rep_emianio,
                               :rep_emimes,
                               :rep_emidia,
                               :rep_emihora,
                               :rep_monto,
                               :rep_UUID,
                               :rep_Versio,
                               :rep_CodMetPag
                              )     
                    };
                    
                    count++;
                
                } catch (SQLException ex) {}
                
                #sql {
                    COMMIT
                };
            }
        
        } catch (SQLException ex) {
            return ex.getMessage();
        } catch (Exception ex){
            return ex.getMessage();
        } finally {
            if (objResultSet != null) try { objResultSet.close(); } catch(Exception ex) { return ex.getMessage(); }
            if (objStatement != null) try { objStatement.close(); } catch(Exception ex) { return ex.getMessage(); }
            if (objSQLConnection != null) try { objSQLConnection.close(); } catch(Exception ex) { return ex.getMessage(); }
        }
        
        message = String.valueOf(count) + " REGISTROS";
        
        return message;
        
    }
        
};