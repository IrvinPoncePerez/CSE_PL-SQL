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
import java.io.File;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
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
            
            String url = "jdbc:sqlserver://192.1.1.119:1433;databaseName=masfacturadb;user=iponce;password=Pa55M3";
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
                
                } catch (SQLException ex) {
                    if (objResultSet != null) try { objResultSet.close(); } catch(Exception exe) { return exe.getMessage(); }
                    if (objStatement != null) try { objStatement.close(); } catch(Exception exe) { return exe.getMessage(); }
                    if (objSQLConnection != null) try { objSQLConnection.close(); } catch(Exception exe) { return exe.getMessage(); }
                    return "-DUPLICATE-"+uuid;
                }
                
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
            
            String url = "jdbc:sqlserver://192.1.1.119:1433;databaseName=masfacturadb;user=iponce;password=Pa55M3";
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
            
            String url = "jdbc:sqlserver://192.1.1.119:1433;databaseName=masfacturadb;user=iponce;password=Pa55M3";
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
    
    public static String readXML(String filename){
    
        String result = "";
        
        String nComprobante = "";
        String nEmisor = "";
        String nReceptor = "";
        String nImpuestos = "";
        
        try {
            #sql{
                SELECT PAC_INVOICE_PKG.GET_DESCRIPTION_VALUE('PAC_SAT_NODES','COMPROBANTE'),
                       PAC_INVOICE_PKG.GET_DESCRIPTION_VALUE('PAC_SAT_NODES','EMISOR'),
                       PAC_INVOICE_PKG.GET_DESCRIPTION_VALUE('PAC_SAT_NODES','RECEPTOR'),
                       PAC_INVOICE_PKG.GET_DESCRIPTION_VALUE('PAC_SAT_NODES','IMPUESTOS')
                  INTO :nComprobante,
                       :nEmisor,
                       :nReceptor,
                       :nImpuestos
                  FROM DUAL
            };
        } catch (SQLException ex) {
            return ex.getMessage();
        }
        
        result = result + "|" + nComprobante;
        result = result + "|" + nEmisor;
        result = result + "|" + nReceptor;
        result = result + "|" + nImpuestos;
        
        String aSerie = "";
        String aFolio = "";
        String aFormaPago = "";
        String aSubTotal = "";
        String aTotal = "";
        String aRfcEmisor = "";
        String aRfcReceptor = "";
        String aNombre = "";
        String aUsoCFDI = "";
        String aCodMetPag = "";
        String aVersio = "";
        String aImpuestosRetenidos = "";
        String aImpuestosTrasladados = "";
        
        String rSerie = "";
        String rFolio = "";
        String rFormaPago = "";
        String rSubTotal = "";
        String rTotal = "";
        String rRfcEmisor = "";
        String rRfcReceptor = "";
        String rNombre = "";
        String rUsoCFDI = "";
        String rCodMetPag = "";
        String rVersio = "";
        String rImpuestosRetenidos = "";
        String rImpuestosTrasladados = "";
        
        try {
            #sql{
                SELECT PAC_INVOICE_PKG.GET_DESCRIPTION_VALUE('PAC_SAT_ATTRIBUTES','SERIE'),
                       PAC_INVOICE_PKG.GET_DESCRIPTION_VALUE('PAC_SAT_ATTRIBUTES','FOLIO'),
                       PAC_INVOICE_PKG.GET_DESCRIPTION_VALUE('PAC_SAT_ATTRIBUTES','FORMA_PAGO'),
                       PAC_INVOICE_PKG.GET_DESCRIPTION_VALUE('PAC_SAT_ATTRIBUTES','SUB_TOTAL'),
                       PAC_INVOICE_PKG.GET_DESCRIPTION_VALUE('PAC_SAT_ATTRIBUTES','TOTAL'),
                       PAC_INVOICE_PKG.GET_DESCRIPTION_VALUE('PAC_SAT_ATTRIBUTES','RFC_EMISOR'),
                       PAC_INVOICE_PKG.GET_DESCRIPTION_VALUE('PAC_SAT_ATTRIBUTES','RFC_RECEPTOR'),
                       PAC_INVOICE_PKG.GET_DESCRIPTION_VALUE('PAC_SAT_ATTRIBUTES','NOMBRE'),
                       PAC_INVOICE_PKG.GET_DESCRIPTION_VALUE('PAC_SAT_ATTRIBUTES','USO_CFDI'),
                       PAC_INVOICE_PKG.GET_DESCRIPTION_VALUE('PAC_SAT_ATTRIBUTES','CODMETPAG'),
                       PAC_INVOICE_PKG.GET_DESCRIPTION_VALUE('PAC_SAT_ATTRIBUTES','VERSIO'),
                       PAC_INVOICE_PKG.GET_DESCRIPTION_VALUE('PAC_SAT_ATTRIBUTES','TOTAL_IMPUESTOS_RETENIDOS'),
                       PAC_INVOICE_PKG.GET_DESCRIPTION_VALUE('PAC_SAT_ATTRIBUTES','TOTAL_IMPUESTOS_TRASLADADOS')
                  INTO :aSerie, 
                       :aFolio,
                       :aFormaPago,
                       :aSubTotal,
                       :aTotal,
                       :aRfcEmisor,
                       :aRfcReceptor,
                       :aNombre,
                       :aUsoCFDI,
                       :aCodMetPag,
                       :aVersio,
                       :aImpuestosRetenidos,
                       :aImpuestosTrasladados
                  FROM DUAL
            };
        } catch (SQLException ex) {
            return ex.getMessage();
        }
        
        result = result + "|" + aSerie;
        result = result + "|" + aFolio;
        result = result + "|" + aFormaPago;
        result = result + "|" + aSubTotal;
        result = result + "|" + aTotal;
        result = result + "|" + aRfcEmisor;
        result = result + "|" + aRfcReceptor;
        result = result + "|" + aNombre;
        result = result + "|" + aUsoCFDI;
        result = result + "|" + aCodMetPag;
        result = result + "|" + aVersio;
        result = result + "|" + aImpuestosRetenidos;
        result = result + "|" + aImpuestosTrasladados;
        
        try {

            File objFile = new File(filename);
            DocumentBuilderFactory objFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder objBuilder = objFactory.newDocumentBuilder();
            Document objDocument = objBuilder.parse(objFile);
            objDocument.getDocumentElement().normalize();

            NodeList objList = objDocument.getElementsByTagName(nComprobante);

            for (int temp = 0; temp < objList.getLength(); temp++) {
                Node objNode = objList.item(temp);
                if (objNode.getNodeType() == Node.ELEMENT_NODE) {
                    Element objElement = (Element) objNode;
                    rSerie = objElement.getAttribute(aSerie);
                    rFolio = objElement.getAttribute(aFolio);
                    rFormaPago = objElement.getAttribute(aFormaPago);
                    rSubTotal = objElement.getAttribute(aSubTotal);
                    rTotal = objElement.getAttribute(aTotal);
                    rCodMetPag = objElement.getAttribute(aCodMetPag);
                    rVersio = objElement.getAttribute(aVersio); 
                }
            }
            
            objList = objDocument.getElementsByTagName(nEmisor);

            for (int temp = 0; temp < objList.getLength(); temp++) {
                Node objNode = objList.item(temp);
                if (objNode.getNodeType() == Node.ELEMENT_NODE) {
                    Element objElement = (Element) objNode;
                    rRfcEmisor = objElement.getAttribute(aRfcEmisor);
                }
            }
            
            objList = objDocument.getElementsByTagName(nReceptor);

            for (int temp = 0; temp < objList.getLength(); temp++) {
                Node objNode = objList.item(temp);
                if (objNode.getNodeType() == Node.ELEMENT_NODE) {
                    Element objElement = (Element) objNode;
                    rRfcReceptor = objElement.getAttribute(aRfcReceptor);
                    rNombre = objElement.getAttribute(aNombre);
                    rUsoCFDI = objElement.getAttribute(aUsoCFDI);
                }
            }
            
            objList = objDocument.getElementsByTagName(nImpuestos);

            for (int temp = 0; temp < objList.getLength(); temp++) {
                Node objNode = objList.item(temp);
                if (objNode.getNodeType() == Node.ELEMENT_NODE) {
                    Element objElement = (Element) objNode;
                    if (objElement.getAttribute(aImpuestosRetenidos) != "") {
                        rImpuestosRetenidos = objElement.getAttribute(aImpuestosRetenidos);
                    }
                    if (objElement.getAttribute(aImpuestosTrasladados) != "") {
                        rImpuestosTrasladados = objElement.getAttribute(aImpuestosTrasladados);
                    }
                }
            }
            
            #sql{
                UPDATE PAC_MASTEREDI_REPORT_TB
                   SET NOMREC = :rNombre,
                       FORPAG = :rFormaPago,
                       SUBTBR = :rSubTotal,
                       TOTTRA = :rImpuestosTrasladados,
                       TOTRET = :rImpuestosRetenidos,
                       USOCFDI = :rUsoCFDI,
                       CODMETPAG = :rCodMetPag,
                       VERSIO = :rVersio
                 WHERE 1 = 1
                   AND RFCEMI = :rRfcEmisor
                   AND RFCREC = :rRfcReceptor
                   AND SERFOL = :rSerie
                   AND NUMFOL = :rFolio
            };
            
            #sql{
                COMMIT
            };
            
            if (rSerie == "") { rSerie = "-CHANGE-SERFOL"; }
            if (rFolio == "") { rFolio = "-CHANGE-NUMFOL"; }
            if (rFormaPago == "") { rFormaPago = "-CHANGE-FORPAG"; }
            if (rSubTotal == "") { rSubTotal = "-CHANGE-SUBTOT"; }
            if (rTotal == "") { rTotal = "-CHANGE-TOTAL"; }
            if (rRfcEmisor == "") { rRfcEmisor = "-CHANGE-RFCEMI"; }
            if (rRfcReceptor == "") { rRfcReceptor = "-CHANGE-RFCREC"; }
            if (rNombre == "") { rNombre = "-CHANGE-NOMREC"; }
            if (rUsoCFDI == "") { rUsoCFDI = "-CHANGE-USOCFDI"; }
            if (rCodMetPag == "") { rCodMetPag = "-CHANGE-CODMETPAG"; }
            if (rVersio == "") { rVersio = "-CHANGE-VERSIO"; }
            
            result = result + "|" + rSerie;
            result = result + "|" + rFolio;
            result = result + "|" + rFormaPago;
            result = result + "|" + rSubTotal;
            result = result + "|" + rTotal;
            result = result + "|" + rRfcEmisor;
            result = result + "|" + rRfcReceptor;
            result = result + "|" + rNombre;
            result = result + "|" + rUsoCFDI;
            result = result + "|" + rCodMetPag;
            result = result + "|" + rVersio;
            result = result + "|" + rImpuestosRetenidos;
            result = result + "|" + rImpuestosTrasladados;
            result = result + "|";
            
            result = result + "-OK-";
            
        } catch (Exception e) {
            return e.getMessage();
        }
        
        return result;
    }
        
};