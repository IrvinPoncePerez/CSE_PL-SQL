/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author McLOVIN
 */
public class NewMain {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        System.out.println(PAC_CFDI_JAVA.test_connection("Calvario_Servicios"));
        System.out.println(PAC_CFDI_JAVA.find_file("Calvario_Servicios", "20161209", "CFDI_NOMINA_CS_23_2016_Quincena_AGUINALDO.xml"));
        System.out.println(PAC_CFDI_JAVA.is_working("Calvario_Servicios"));
        System.out.println(PAC_CFDI_JAVA.is_downloading("/Calvario_Servicios/Descarga/2016/12", 3896));
    }
    
}
