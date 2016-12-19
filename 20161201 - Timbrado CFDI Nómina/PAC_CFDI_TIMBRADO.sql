ALTER SESSION SET CURRENT_SCHEMA=APPS;

DROP JAVA SOURCE PAC_CFDI_JAVA;
COMMIT;




SELECT *
  FROM ALL_OBJECTS
 WHERE 1 = 1
   AND OBJECT_TYPE LIKE '%JAVA%'
--   AND STATUS = 'INVALID'
  ORDER BY CREATED DESC;



CREATE OR REPLACE TYPE APPS.PAC_CFDI_OUTPUT_FILES AS TABLE OF VARCHAR2(500);
CREATE OR REPLACE TYPE APPS.PAC_CFDI_ERROR_FILES AS TABLE OF VARCHAR2(500);


CREATE OR REPLACE AND COMPILE JAVA SOURCE NAMED APPS.PAC_CFDI_TIMBRADO AS
/*
 * Import section.
 */
import org.apache.commons.net.ftp.FTPClient;
import java.io.IOException;
import oracle.sql.ARRAY;
import java.sql.Connection;
import java.sql.SQLException;
import oracle.sql.ArrayDescriptor;
import oracle.jdbc.OracleDriver;
/**
 * @author : Irvin Ponce Pérez
 * @created_date : 13 / 12 / 2016
 * @updated_date : 13 / 12 / 2016
 */
public class PAC_CFDI_TIMBRADO {
    
    static String server = "192.1.1.64";
    static String user = "ftpuser";
    static String pass = "Oracle123";
    
    public static String test_connection(String directory) {
        String result = "";
        FTPClient objFTPClient = new FTPClient();
        
        try {
            objFTPClient.connect(server);
            objFTPClient.login(user, pass);
            objFTPClient.enterLocalPassiveMode();
            objFTPClient.changeWorkingDirectory(directory);
            
            if (objFTPClient.isConnected() == true){
                result = "Connected to "  + objFTPClient.printWorkingDirectory();
            }
            
            objFTPClient.logout();
            objFTPClient.disconnect();
        } catch (IOException ex) {
            System.out.println(ex.getMessage());
            result  = "No Connected!";
        } 
        
        return result;      
    }
    
    public static boolean find_file(String directory, String sub_directory, String file_name){
        Boolean result = false;
        FTPClient objFTPClient = new FTPClient();
        String path = directory + "/Out/" + sub_directory;
        
        try {
            objFTPClient.connect(server);
            objFTPClient.login(user, pass);
            objFTPClient.enterLocalPassiveMode();
            objFTPClient.changeWorkingDirectory(path);
            
            if (objFTPClient.isConnected() == true){
                String[] files = objFTPClient.listNames();
                
                for(int i=0; i<files.length; i++){
                    String file  = files[i];
                    if(file_name.equals(file)){
                        result = true;
                        break;
                    } else {
                        result = false;
                    }
                }
            }
            
            objFTPClient.logout();
            objFTPClient.disconnect();
        } catch (IOException ex) {
            System.out.println(ex.getMessage());
            result  = false;
        }
                
        return result;
    }
    
    public static boolean is_working(String directory){
        Boolean result = false;
        FTPClient objFTPClient = new FTPClient();
        String path = directory + "/In/";
        
        try {
            objFTPClient.connect(server);
            objFTPClient.login(user, pass);
            objFTPClient.enterLocalPassiveMode();
            objFTPClient.changeWorkingDirectory(path);
            
            if (objFTPClient.isConnected() == true){
                String[] files = objFTPClient.listNames();
                
                if (files.length == 0){
                    result = false;
                } else {
                    result = true;
                }
            }
            
            objFTPClient.logout();
            objFTPClient.disconnect();
        } catch (IOException ex) {
            System.out.println(ex.getMessage());
            result  = false;
        }
                
        return result;
    }
    
    public static ARRAY get_output_files(String directory, String sub_directory){
        try {
            Connection objConnection = new OracleDriver().defaultConnection();
            ArrayDescriptor objDescriptor = ArrayDescriptor.createDescriptor("PAC_CFDI_OUTPUT_FILES", objConnection);
            FTPClient objFTPClient = new FTPClient();
            
            String path = directory + "/Out/" + sub_directory;
            
            objFTPClient.connect(server);
            objFTPClient.login(user, pass);
            objFTPClient.enterLocalPassiveMode();
            objFTPClient.changeWorkingDirectory(path);
            
            String[] files = objFTPClient.listNames();
            ARRAY output_files = new ARRAY(objDescriptor, objConnection, files);
            
            objFTPClient.logout();
            objFTPClient.disconnect();
            
            return output_files;
        } catch (SQLException ex) {
            System.out.println(ex.getMessage());
        } catch (IOException ex) {
            System.err.println(ex.getMessage());
        }
        
        return null;
    }
    
    public static ARRAY get_error_files(String directory, String sub_directory){
        try {
            Connection objConnection = new OracleDriver().defaultConnection();
            ArrayDescriptor objDescriptor = ArrayDescriptor.createDescriptor("PAC_CFDI_ERROR_FILES", objConnection);
            FTPClient objFTPClient = new FTPClient();
            
            String path = directory + "/Error/" + sub_directory;
            
            objFTPClient.connect(server);
            objFTPClient.login(user, pass);
            objFTPClient.enterLocalPassiveMode();
            objFTPClient.changeWorkingDirectory(path);
            
            String[] files = objFTPClient.listNames();
            ARRAY error_files = new ARRAY(objDescriptor, objConnection, files);
            
            objFTPClient.logout();
            objFTPClient.disconnect();
            
            return error_files;
        } catch (SQLException ex) {
            System.out.println(ex.getMessage());
        } catch (IOException ex) {
            System.err.println(ex.getMessage());
        }
        
        return null;
    }
    
}
;