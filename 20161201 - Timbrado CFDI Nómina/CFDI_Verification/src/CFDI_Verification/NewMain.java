/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package CFDI_Verification;

/**
 *
 * @author McLOVIN
 */
public class NewMain {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        
        System.out.println(CFDI_Verification.test_Connection("Calvario_Servicios"));
        CFDI_Verification.list_directories("Calvario_Servicios");
        
    }
    
}
