/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package CFDI_Verification;

import java.io.IOException;
import org.apache.commons.net.ftp.FTPClient;
import java.sql.SQLException;
import oracle.sql.ARRAY;
import java.sql.Connection;
import oracle.sql.ArrayDescriptor;
import oracle.jdbc.OracleDriver;

/**
 * @author : Irvin Ponce Pérez
 * @since : 09 - Diciembre - 2016
 */

public class CFDI_Verification {
    
    public static String test_Connection(String  directory){
        
        String server = "192.1.1.64";
        String user = "ftpuser";
        String pass = "Oracle123";
        String result = "No Connected!";
        
        FTPClient ftpClient = new FTPClient();
        
        try {
            ftpClient.connect(server);
            ftpClient.login(user, pass);
            ftpClient.enterLocalPassiveMode();
            ftpClient.changeWorkingDirectory(directory);
            
            if (ftpClient.isConnected() == true){
                result = "Connected to " + ftpClient.printWorkingDirectory();
            }
            
            ftpClient.logout();
            ftpClient.disconnect();
            
        } catch (IOException ex){
            System.out.println("Ooops! Error en conexión."+ ex.getMessage());
        } finally {
            return result;
        }
    }
    
    public static void list_directories(String directory){
        String server = "192.1.1.64";
        String user = "ftpuser";
        String pass = "Oracle123";
        String result = "No Connected!";
        
        FTPClient ftpClient = new FTPClient();
        
        try {
            ftpClient.connect(server);
            ftpClient.login(user, pass);
            ftpClient.enterLocalPassiveMode();
            ftpClient.changeWorkingDirectory(directory);
            
            String[] directories = ftpClient.listNames();
            String dir;
            
            for(int i=0; i<directories.length; i++){
                System.out.println(directories[i]);
                dir = directories[i];
            }
            
            ftpClient.logout();
            ftpClient.disconnect();
            
        } catch (IOException ex){
            System.out.println("Ooops! Error en conexión."+ ex.getMessage());
        }
    }
    
    public static ARRAY getDirectories(String directory) throws SQLException{
        Connection conn = new OracleDriver().defaultConnection();
        ArrayDescriptor descriptor = ArrayDescriptor.createDescriptor("DIRECTORIES_LIST", conn); 
        
        String server = "192.1.1.64";
        String user = "ftpuser";
        String pass = "Oracle123";
        String result = "No Connected!";
        
        FTPClient ftpClient = new FTPClient();
        
        try {
            ftpClient.connect(server);
            ftpClient.login(user, pass);
            ftpClient.enterLocalPassiveMode();
            ftpClient.changeWorkingDirectory(directory);
            
            String[] directories = ftpClient.listNames();
            ARRAY directories_list  = new ARRAY(descriptor, conn, directories);
            
            ftpClient.logout();
            ftpClient.disconnect();
         
            return directories_list;
        } catch (IOException ex){
            System.out.println("Ooops! Error en conexión."+ ex.getMessage());
        }
        return null;
    }
}
