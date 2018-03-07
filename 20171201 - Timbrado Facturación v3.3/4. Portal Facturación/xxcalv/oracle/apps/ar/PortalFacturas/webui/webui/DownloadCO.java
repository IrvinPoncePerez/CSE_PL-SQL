/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package xxcalv.oracle.apps.ar.PortalFacturas.webui.webui;


import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageStyledTextBean;
import oracle.apps.fnd.framework.webui.beans.OAImageBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageDateFieldBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageLovInputBean;

import oracle.apps.fnd.framework.webui.beans.message.OAMessageTextInputBean;

import oracle.cabo.style.CSSStyle;

import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;

import xxcalv.oracle.apps.ar.PortalFacturas.server.SERFOLVOImpl;
import xxcalv.oracle.apps.ar.PortalFacturas.server.PAC_MASTEREDI_REPORT_VOImpl;
import xxcalv.oracle.apps.ar.PortalFacturas.server.PAC_MASTEREDI_REPORT_VORowImpl;

/**
 * Controller for ...
 */
public class DownloadCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header$";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");
  public boolean hasData = false;
  public static String directoryServer = "";
  /**
   * Layout and page setup logic for a region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processRequest(OAPageContext pageContext, OAWebBean webBean){
    super.processRequest(pageContext, webBean);  
    
    SERFOLVOImpl.setOrgId(String.valueOf(pageContext.getOrgId()));
    SERFOLVOImpl.setUsername(pageContext.getUserName());
    
    setStyle(pageContext, webBean);
  }

  /**
   * Procedure to handle form submissions for form elements in
   * a region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processFormRequest(OAPageContext pageContext, OAWebBean webBean){
    super.processFormRequest(pageContext, webBean);
    
    if ("Clear".equals(pageContext.getParameter(EVENT_PARAM))){
        clearItems(pageContext, webBean);
    }
    
    if ("Search".equals(pageContext.getParameter(EVENT_PARAM))){
        executeQuery(pageContext, webBean);
        hasData = true;
    }
    
    if ("Export".equals(pageContext.getParameter(EVENT_PARAM))){
        downloadCsvFile(pageContext, webBean);                               
    }
    
    if ("DownloadXML".equals(pageContext.getParameter(EVENT_PARAM))){
        StringBuilder directory = new StringBuilder("");
        StringBuilder filename = new StringBuilder("");
        
        getDirectoryAndFilename(pageContext, directory, filename);
        
        if (getFtpFile(directory.toString(), filename.toString(), ".xml")){
            downloadFile(pageContext, filename.toString(), ".xml");
        }
    } 
    
    if ("DownloadPDF".equals(pageContext.getParameter(EVENT_PARAM))){
        StringBuilder directory = new StringBuilder("");
        StringBuilder filename = new StringBuilder("");
        
        getDirectoryAndFilename(pageContext, directory, filename);
        
        if (getFtpFile(directory.toString(), filename.toString(), ".pdf")){
            downloadFile(pageContext, filename.toString(), ".pdf");
        }
    }
    
  }
  
  public void getDirectoryAndFilename(OAPageContext pageContext, StringBuilder directory, StringBuilder filename){
      String emianio = pageContext.getParameter("EMIANIO");
      String emimes = pageContext.getParameter("EMIMES");
      String rfcemi = pageContext.getParameter("RFCEMI");
      String rfcrec = pageContext.getParameter("RFCREC");
      String serfol = pageContext.getParameter("SERFOL");
      String numfol = pageContext.getParameter("NUMFOL");
      
      if (emimes.length() == 1){
          emimes = "0" + emimes;
      }
      
      directory.append("/" + rfcemi);
      directory.append("/" + emianio);
      directory.append("/" + emimes);
      directory.append("/");
      
      filename.append(rfcemi + "_");
      filename.append(rfcrec + "_");
      filename.append(serfol + "_"); 
      filename.append(numfol);
  }

  public boolean getFtpFile(String directory, String filename, String extension){
      String serverip = "192.1.1.119";
      int port = 2100;
      String user = "cfd";
      String pass = "Facturacion01";
      boolean result = false;
      
      FTPClient objFtpClient = new FTPClient();
      
      try {
          objFtpClient.connect(serverip, port);
          objFtpClient.login(user, pass);
          objFtpClient.enterLocalPassiveMode();
          objFtpClient.setFileType(FTP.BINARY_FILE_TYPE);
          
          if (objFtpClient.isConnected()){
              File objFile = new File(directoryServer+ filename + extension);
              OutputStream objOutputStream = new BufferedOutputStream(new FileOutputStream(objFile));
              result = objFtpClient.retrieveFile(directory+filename+extension, objOutputStream);
              objOutputStream.close();
          }
          
      } catch (IOException ex) {
          throw new OAException(ex.getMessage() , OAException.ERROR);
      } finally {
          try {
              if (objFtpClient.isConnected()){
                  objFtpClient.logout();
                  objFtpClient.disconnect();       
              }
          }
          catch (IOException ex) {
              throw new OAException(ex.getMessage() , OAException.ERROR);
          }
          
          return result;
      }
  }
  
  public void downloadFile(OAPageContext pageContext, String filename, String extension){
      HttpServletResponse objServletResponse = (HttpServletResponse)pageContext.getRenderingContext().getServletResponse();
      File objFile = null;
      
      try {
          objFile = new File(directoryServer+filename+extension);
      } catch (Exception ex) {
          throw new OAException(ex.getMessage(), OAException.ERROR);
      }
      
      if (!objFile.exists()){
          throw new OAException("El archivo no existe", OAException.ERROR);
      }
      
      if (!objFile.canRead()){
          throw new OAException("El archivo no se encuentra disponible.", OAException.ERROR);
      }
      
      String fileType = "";
      if (extension == ".xml"){
          fileType = "text/xml";
      } else if (extension == ".csv"){
          fileType = "text/csv";    
      } else if (extension == ".pdf"){
          fileType = "application/pdf";
      }
      
      objServletResponse.setContentType(fileType);
      objServletResponse.setContentLength((int)objFile.length());
      objServletResponse.setHeader("Content-Disposition", "attachment; filename=\"" + directoryServer+filename+extension + "\"");
      
      InputStream objInputStream = null;
      ServletOutputStream objOutputStream = null;
      
      try {
          objOutputStream = objServletResponse.getOutputStream();
          objInputStream = new BufferedInputStream(new FileInputStream(objFile));
          int characters;
          while ((characters = objInputStream.read()) != -1){
              objOutputStream.write(characters);
          }
      } catch (IOException ex) {
          throw new OAException(ex.getMessage(), OAException.ERROR);
      } finally {
          try {
              objOutputStream.flush();
              objOutputStream.close();
              if (objInputStream != null){
                  objInputStream.close();
              }
          } catch (Exception ex) {
              throw new OAException(ex.getMessage(), OAException.ERROR);    
          }
      }
  }
  
  public void clearItems(OAPageContext pageContext, OAWebBean webBean){
      OAMessageDateFieldBean objStartDateTI = (OAMessageDateFieldBean)webBean.findChildRecursive("StartDateTI");
      OAMessageDateFieldBean objEndDateTI = (OAMessageDateFieldBean)webBean.findChildRecursive("EndDateTI");
      OAMessageLovInputBean objTipdocTI = (OAMessageLovInputBean)webBean.findChildRecursive("TipdocTI");
      OAMessageLovInputBean objRfcemiTI = (OAMessageLovInputBean)webBean.findChildRecursive("RfcemiTI");
      OAMessageLovInputBean objRfcrecTI = (OAMessageLovInputBean)webBean.findChildRecursive("RfcrecTI");
      OAMessageLovInputBean objSerfolTI = (OAMessageLovInputBean)webBean.findChildRecursive("SerfolTI");
      OAMessageTextInputBean objNumfolTI = (OAMessageTextInputBean)webBean.findChildRecursive("NumfolTI");
      
      if (objStartDateTI != null) { objStartDateTI.setValue(pageContext, null); }
      if (objEndDateTI != null) { objEndDateTI.setValue(pageContext, null); }
      if (objTipdocTI != null) { objTipdocTI.setValue(pageContext, null); }
      if (objRfcemiTI != null) { objRfcemiTI.setValue(pageContext, null); }
      if (objRfcrecTI != null) { objRfcrecTI.setValue(pageContext, null); }
      if (objSerfolTI != null) { objSerfolTI.setValue(pageContext, null); }
      if (objNumfolTI != null) { objNumfolTI.setText(pageContext, null); }
  }
  
  public void executeQuery(OAPageContext pageContext, OAWebBean webBean){
      String startDate = pageContext.getParameter("StartDateTI");
      String endDate = pageContext.getParameter("EndDateTI");
      String tipdoc = pageContext.getParameter("TipdocTI");
      String rfcemi = pageContext.getParameter("RfcemiTI");
      String rfcrec = pageContext.getParameter("RfcrecTI");
      String serfol = pageContext.getParameter("SerfolTI");
      String numfol = pageContext.getParameter("NumfolTI");
      
      OAApplicationModule objApplicationModule = pageContext.getApplicationModule(webBean);
      PAC_MASTEREDI_REPORT_VOImpl objView = (PAC_MASTEREDI_REPORT_VOImpl)objApplicationModule.findViewObject("PAC_MASTEREDI_REPORT_VO1"); 
      
      String orgId = String.valueOf(pageContext.getOrgId());
      String userName = pageContext.getUserName();
      
      if (objView != null){
          String query = "SELECT PAC_MASTEREDI_REPORT_EO.EMIANIO, \n" + 
          "       PAC_MASTEREDI_REPORT_EO.EMIMES, \n" + 
          "       PAC_MASTEREDI_REPORT_EO.EMIDIA, \n" + 
          "       PAC_MASTEREDI_REPORT_EO.EMITION_DATE,\n" + 
          "       (CASE\n" + 
          "    WHEN PAC_MASTEREDI_REPORT_EO.TIPDOC = 1 \n" + 
          "     THEN 'INGRESO'\n" + 
          "    WHEN PAC_MASTEREDI_REPORT_EO.TIPDOC = 2\n" + 
          "     THEN 'EGRESO'\n" + 
          "    END) TIPDOC, \n" + 
          "       PAC_MASTEREDI_REPORT_EO.RFCEMI, \n" + 
          "       PAC_MASTEREDI_REPORT_EO.RFCREC, \n" + 
          "       PAC_MASTEREDI_REPORT_EO.NOMREC,\n" + 
          "       PAC_MASTEREDI_REPORT_EO.SERFOL, \n" + 
          "       PAC_MASTEREDI_REPORT_EO.NUMFOL, \n" + 
          "       TRIM(TO_CHAR(PAC_MASTEREDI_REPORT_EO.SUBTBR, '9,999,999,999.99' )) SUBTBR, \n" + 
          "       TRIM(TO_CHAR(PAC_MASTEREDI_REPORT_EO.TOTPAG, '9,999,999,999.99' )) TOTPAG, \n" + 
          "       TRIM(TO_CHAR(NVL(PAC_MASTEREDI_REPORT_EO.TOTRET,0), '9,999,999,999.99' )) TOTRET, \n" + 
          "       TRIM(TO_CHAR(NVL(PAC_MASTEREDI_REPORT_EO.TOTTRA,0), '9,999,999,999.99' )) TOTTRA, \n" + 
          "       PAC_MASTEREDI_REPORT_EO.UUID, \n" + 
          "       PAC_MASTEREDI_REPORT_EO.VERSIO, \n" + 
          "       (CASE \n" + 
          "    WHEN PAC_MASTEREDI_REPORT_EO.CODMETPAG = 'PAGO EN UNA SOLA EXHIBICION' \n" + 
          "    THEN 'PUE'\n" + 
          "    ELSE PAC_MASTEREDI_REPORT_EO.CODMETPAG\n" + 
          "    END)    CODMETPAG\n" + 
          "FROM PAC_MASTEREDI_REPORT_TB PAC_MASTEREDI_REPORT_EO\n" + 
          "WHERE 1 = 1";
          
          
          if (startDate != null && endDate != null){
              query = query + " AND PAC_MASTEREDI_REPORT_EO.EMITION_DATE BETWEEN TO_DATE('"+startDate+"','DD/MM/RRRR') AND TO_DATE('"+endDate+"', 'DD/MM/RRRR')";
          }
          if (tipdoc != ""){
              query = query + " AND (CASE\n" + 
              "    WHEN PAC_MASTEREDI_REPORT_EO.TIPDOC = 1 \n" + 
              "     THEN 'INGRESO'\n" + 
              "    WHEN PAC_MASTEREDI_REPORT_EO.TIPDOC = 2\n" + 
              "     THEN 'EGRESO'\n" + 
              "    END) LIKE UPPER('"+tipdoc+"')";
          }
          if (rfcemi != ""){
              query = query + " AND PAC_MASTEREDI_REPORT_EO.RFCEMI LIKE UPPER('"+rfcemi+"')";
          }
          if (rfcrec != ""){
              query = query + " AND PAC_MASTEREDI_REPORT_EO.RFCREC LIKE UPPER('"+rfcrec+"')";
          }
          if (serfol != ""){
              query = query + " AND PAC_MASTEREDI_REPORT_EO.SERFOL LIKE UPPER('"+serfol+"')";
          }
          if (numfol != ""){
              query = query + " AND PAC_MASTEREDI_REPORT_EO.NUMFOL LIKE '"+numfol+"'";
          }
          if (orgId != "" && userName != ""){
              query = query + "AND SERFOL IN (SELECT DISTINCT\n" + 
              "                         DS.ATTRIBUTE1\n" + 
              "                    FROM RA_CUST_TRX_TYPES_ALL            RT,\n" + 
              "                         FND_DOC_SEQUENCE_ASSIGNMENTS     DSA,\n" + 
              "                         FND_DOCUMENT_SEQUENCES           DS\n" + 
              "                   WHERE 1 = 1\n" + 
              "                     AND RT.NAME = DSA.CATEGORY_CODE\n" + 
              "                     AND DSA.DOC_SEQUENCE_ID = DS.DOC_SEQUENCE_ID\n" + 
              "                     AND DS.ATTRIBUTE_CATEGORY = 'CALV_SERIES_FACTURACION'   \n" + 
              "                     AND RT.ORG_ID = (CASE \n" + 
              "                                          WHEN '"+userName+"' IN (SELECT FV.FLEX_VALUE\n" + 
              "                                                                  FROM FND_FLEX_VALUE_SETS FVS,\n" + 
              "                                                                       FND_FLEX_VALUES     FV\n" + 
              "                                                                 WHERE 1 = 1\n" + 
              "                                                                   AND FVS.FLEX_VALUE_SET_ID = FV.FLEX_VALUE_SET_ID\n" + 
              "                                                                   AND FVS.FLEX_VALUE_SET_NAME = 'PAC_SAT_SEARCH_USERS'\n" + 
              "                                                                   AND FV.ENABLED_FLAG = 'Y')\n" + 
              "                                          THEN RT.ORG_ID\n" + 
              "                                          ELSE TO_NUMBER('"+orgId+"')\n" + 
              "                                       END))";
          }
          
          objView.setFullSqlMode(PAC_MASTEREDI_REPORT_VOImpl.FULLSQL_MODE_AUGMENTATION);
          objView.setQuery(query);
          objView.executeQuery();
      }
      
  }
  
  public void downloadCsvFile(OAPageContext pageContext, OAWebBean webBean){
      OAApplicationModule objApplicationModule = pageContext.getApplicationModule(webBean);
      PAC_MASTEREDI_REPORT_VOImpl objView = (PAC_MASTEREDI_REPORT_VOImpl)objApplicationModule.findViewObject("PAC_MASTEREDI_REPORT_VO1");
      
      if (hasData) {
          String userName = pageContext.getUserName();
          String sysdate = pageContext.getCurrentDBDate().toString();
          String extension = ".csv";
          sysdate = sysdate.substring(0,19);
          sysdate = sysdate.replace(" ", "__");
          sysdate = sysdate.replace("-", "_");
          sysdate = sysdate.replace(":", "_");
          String fileName = userName+"_"+sysdate;
          FileWriter objWriter;
          String line = "";
    
            try {
                objWriter = new FileWriter(directoryServer+fileName+extension);
                line = line + "Fecha de Emision,";
                line = line + "Tipo de Documento,";
                line = line + "RFC Emisor,";
                line = line + "RFC Receptor,";
                line = line + "Nombre Receptor,";
                line = line + "Serie,";
                line = line + "Folio,";
                line = line + "Sub Total,";
                line = line + "Total,";
                line = line + "Total Retenido,";
                line = line + "Total Trasladado,";
                line = line + "UUID,";
                line = line + "Version,";
                line = line + "Metodo de Pago,";
                line = line + "\n";
                objWriter.append(line);
            } catch (IOException e) {
                throw new OAException(e.getMessage(), OAException.INFORMATION);
            }
            
              for (PAC_MASTEREDI_REPORT_VORowImpl row = (PAC_MASTEREDI_REPORT_VORowImpl)objView.first(); row != null;row = (PAC_MASTEREDI_REPORT_VORowImpl)objView.next()){
                  try {
                      line = "";
                      line = line + row.getEmitionDate().toString() + ",";
                      line = line + row.getTipdoc().replace(",","") + ",";
                      line = line + row.getRfcemi().replace(",","") + ",";
                      line = line + row.getRfcrec().replace(",","") + ",";
                      line = line + row.getNomrec().replace(",","") + ",";
                      line = line + row.getSerfol().replace(",","") + ",";
                      line = line + row.getNumfol().replace(",","") + ",";
                      line = line + row.getSubtbr().replace(",","") + ",";
                      line = line + row.getTotpag().replace(",","") + ",";
                      line = line + row.getTotret().replace(",","") + ",";
                      line = line + row.getTottra().replace(",","") + ",";
                      line = line + row.getUuid().replace(",","") + ",";
                      line = line + row.getVersio().replace(",","") + ",";
                      line = line + row.getCodmetpag().replace(",","") + ",";
                      line = line + "\n";
                      objWriter.append(line);
                  } catch (IOException e) {
                      throw new OAException(e.getMessage(), OAException.INFORMATION);
                  }
              }
          try {
              objWriter.flush();
              objWriter.close();
              downloadFile(pageContext, fileName, extension);
          } catch (IOException e) {
              throw new OAException(e.getMessage(), OAException.INFORMATION);
          }
    }
  }
  
  public void setStyle(OAPageContext pageContext, OAWebBean webBean){
      CSSStyle objCssTot = new CSSStyle();
      
      objCssTot.setProperty("display", "block");
      objCssTot.setProperty("text-align", "right");
      
      CSSStyle objCssImage = new CSSStyle();
      
      objCssImage.setProperty("cursor", "hand");
      
      OAMessageStyledTextBean objSubtbr = (OAMessageStyledTextBean)webBean.findChildRecursive("Subtbr");
      OAMessageStyledTextBean objTotpag = (OAMessageStyledTextBean)webBean.findChildRecursive("Totpag");
      OAImageBean objDownloadXML = (OAImageBean)webBean.findChildRecursive("DownloadXML");
      OAImageBean objDownloadPDF = (OAImageBean)webBean.findChildRecursive("DownloadPDF");
      
      if (objSubtbr != null) { 
        objSubtbr.setInlineStyle(objCssTot); }
      if (objTotpag != null) { 
        objTotpag.setInlineStyle(objCssTot); }
      if (objDownloadXML != null) { 
        objDownloadXML.setInlineStyle(objCssImage); }
      if (objDownloadPDF != null) { 
        objDownloadPDF.setInlineStyle(objCssImage); }
  }

}
