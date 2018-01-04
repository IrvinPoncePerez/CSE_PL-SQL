CREATE OR REPLACE AND COMPILE JAVA SOURCE NAMED APPS.CFDI_MESSAGES AS

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
public class CFDI_MESSAGES {
    
    public static String getUUID(String rfcemi, String rfcrec, String serfol, String numfol, String rep_emianio, String rep_emimes, String rep_emidia) {
        
        Connection objSQLConnection = null;
        Statement objStatement = null;
        ResultSet objResultSet = null;
            
        try{
            String url = "jdbc:sqlserver://192.1.1.119:1433;databaseName=masfacturadb;user=iponce;password=P@55M3";
            String query = "select rep.rep_UUID "+
                           "from dbo.reporte rep "+
                           "where 1 = 1 " +
                           " and rep.rep_rfc = '"+rfcemi+
                           "' and rep.rep_rfc_receptor = '"+rfcrec+
                           "' and rep.rep_serie = '"+serfol+
                           "' and rep.rep_folio = '"+numfol+
                           "' and rep.rep_emianio = '"+rep_emianio+
                           "' and rep.rep_emimes = '"+rep_emimes+
                           "' and rep.rep_emidia = '"+rep_emidia+
                           "';";

        
            
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver"); 
            objSQLConnection = DriverManager.getConnection(url);
            
            objStatement = objSQLConnection.createStatement();
            objResultSet  = objStatement.executeQuery(query);
            
            while (objResultSet.next()){
                return objResultSet.getString("rep_UUID");
            }
        
        } catch (SQLException ex) {
            System.out.println(ex.getMessage());
        } catch (Exception ex){
            System.out.println(ex.getMessage());
        } finally {
            if (objResultSet != null) try { objResultSet.close(); } catch(Exception e) { System.out.println(e.getMessage()); }
            if (objStatement != null) try { objStatement.close(); } catch(Exception e) { System.out.println(e.getMessage());}
            if (objSQLConnection != null) try { objSQLConnection.close(); } catch(Exception e) { System.out.println(e.getMessage());}
        }
        
        return null;
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
            }
            
            return "OK";
        
        } catch (SQLException ex) {
            System.out.println(ex.getMessage());
        } catch (Exception ex){
            System.out.println(ex.getMessage());
        } finally {
            if (objResultSet != null) try { objResultSet.close(); } catch(Exception e) { System.out.println(e.getMessage()); }
            if (objStatement != null) try { objStatement.close(); } catch(Exception e) { System.out.println(e.getMessage());}
            if (objSQLConnection != null) try { objSQLConnection.close(); } catch(Exception e) { System.out.println(e.getMessage());}
        }
        
        return null;
    }
        
};