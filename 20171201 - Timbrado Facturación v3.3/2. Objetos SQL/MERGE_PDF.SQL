ALTER SESSION SET CURRENT_SCHEMA=APPS;
CREATE OR REPLACE AND COMPILE JAVA SOURCE NAMED APPS.MERGE_PDF AS

import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import org.apache.pdfbox.exceptions.COSVisitorException;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.util.PDFMergerUtility;
import oracle.sql.ARRAY;
/**
 *
 * @author IPONCE
 */

public class MERGE_PDF {
    
    public static String mergePDF(ARRAY filesArray,String output_directory, String username, String request_id) {
        String file_name = output_directory+username+"_"+request_id+".PDF";
        try {  
            String files[] = (String[])filesArray.getArray();
            PDFMergerUtility PDFmerger = new PDFMergerUtility();
            PDFmerger.setDestinationFileName(file_name);
            
            for(String file_name_pdf : files){
                try{
                    File objFile = new File(file_name_pdf);
                    PDDocument objDocument = PDDocument.load(objFile);
                    PDFmerger.addSource(objFile);
                    objDocument.close();
                } catch (IOException ex) {}
            }
            
            PDFmerger.mergeDocuments();

        } catch (IOException ex) {
            return "-ERROR-IOException-" + ex.getMessage();
        } catch (COSVisitorException ex) {
            return "-ERROR-COSVisitorException-" + ex.getMessage();
        } catch (SQLException ex){
            return "-ERROR-SQLException-" + ex.getMessage();
        }
        
        return "-OK-"+file_name;
    }
    
}