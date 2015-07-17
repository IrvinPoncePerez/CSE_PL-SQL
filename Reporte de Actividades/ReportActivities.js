function mergeRange(numSheet){
  //var objSpreadSheet = SpreadsheetApp.getActiveSpreadsheet();
  //var objSheet = objSpreadSheet.getSheets()[numSheet];
  
  //for (i = 11; i <= objSheet.getLastRow(); i++){
    //var range = objSheet.getRange(i, 1);
    //var value = range.getValue();   
  //}
}

function debuggerScript(){
  
  sendWeeklyReport();
  sendMontlyReport();
  
}

function onFormSubmit(e){
  var objSpreadSheet = SpreadsheetApp.getActiveSpreadsheet();
  var objSheet1 = objSpreadSheet.getSheets()[1];
  var objSheet2 = objSpreadSheet.getSheets()[2];
  
  var values1 = [e.values[1], //Línea Estratégica
                e.values[2].toString() + e.values[3].toString() + e.values[11].toString(), //Módulo/Proyectos en desarrollo
                e.values[5], //Actividad
                e.values[6], //Resumen del resultado obtenido
                e.values[7], //Observaciones
                e.values[8], //Porcentaje de avance
                e.values[9], //Fecha de realización
                e.values[10]]; //Realizado por
  
  var values2 = [e.values[1], //Línea Estratégica
                e.values[2].toString() + e.values[3].toString() + e.values[11].toString(), //Módulo/Proyectos en desarrollo
                e.values[5], //Actividad
                e.values[6], //Resumen del resultado obtenido
                e.values[7], //Observaciones
                e.values[9], //Fecha de realización
                e.values[10]]; //Realizado por
  
  objSheet1.appendRow(values1);  
  
  if (e.values[8] == '100') {
    objSheet2.appendRow(values2);
  }
  
  setFormat(1);
  setFormat(2);
}

function sendWeeklyReport(){
  
  var objFile, 
      fileId,
      objSpreadSheet,
      objSheet,
      title,
      newSpreadSheet,
      objFolder,
      objBlob;
      
  objSpreadSheet = SpreadsheetApp.getActiveSpreadsheet();
  objSheet = objSpreadSheet.getSheets()[1];
  
  title = 'REPORTE DE ACTIVIDADES - ' + getDescriptionDate(1)
  newSpreadSheet = SpreadsheetApp.create(title);
  objFolder = DriveApp.getFolderById('0B4ALFd2MlYZhLVRiOG9DWldFM2M');  
  
  objSheet.copyTo(newSpreadSheet);
  newSpreadSheet.deleteSheet(newSpreadSheet.getSheets()[0]);
  
  objBlob = UrlFetchApp.fetch('https://docs.google.com/spreadsheets/d/' + newSpreadSheet.getId() + 
                                   '/export?format=xlsx&id=' + newSpreadSheet.getId(), 
                                   {headers: {'Authorization': 'Bearer ' +  
                                              ScriptApp.getOAuthToken() }
                                   }).getAs('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  
  fileId = objFolder.createFile(objBlob).getId();  
    
  objFile = DriveApp.getFileById(newSpreadSheet.getId());
  DriveApp.removeFile(objFile);
  
  objFile = DriveApp.getFileById(fileId);
  objFile.setName(title);
  
  //sendMail(fileId, title, "Reporte de Actividades.");
}

function sendMail(fileId, subject, body){
  GmailApp.sendEmail("irvinponceperez@gmail.com, ariasam@gmail.com, abrahan@gmail.com", subject, body, {attachments: DriveApp.getFileById(fileId)});
}

function sendMontlyReport(){
 
  var objFile, 
      fileId,
      objSpreadSheet,
      objSheet,
      title,
      newSpreadSheet,
      objFolder,
      objBlob;
      
  objSpreadSheet = SpreadsheetApp.getActiveSpreadsheet();
  objSheet = objSpreadSheet.getSheets()[2];
  
  title = 'REPORTE DE ACTIVIDADES - ' + getDescriptionDate(2)
  newSpreadSheet = SpreadsheetApp.create(title);
  objFolder = DriveApp.getFolderById('0B4ALFd2MlYZhSVhfZDEyYV9fT1k');  
  
  objSheet.copyTo(newSpreadSheet);
  newSpreadSheet.deleteSheet(newSpreadSheet.getSheets()[0]);
  
  objBlob = UrlFetchApp.fetch('https://docs.google.com/spreadsheets/d/' + newSpreadSheet.getId() + 
                                   '/export?format=xlsx&id=' + newSpreadSheet.getId(), 
                                   {headers: {'Authorization': 'Bearer ' +  
                                              ScriptApp.getOAuthToken() }
                                   }).getAs('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  
  fileId = objFolder.createFile(objBlob).getId();  
    
  objFile = DriveApp.getFileById(newSpreadSheet.getId());
  DriveApp.removeFile(objFile);
  
  objFile = DriveApp.getFileById(fileId);
  objFile.setName(title);
  
  //sendMail(fileId, title, "Reporte de Actividades.");    
}

function getFileId(objFolder, objSheet, title){

  var newSpreadSheet,
      objBlob,
      fileId,
      objFile;
  
  newSpreadSheet = SpreadsheetApp.create(title);
  
  objSheet.copyTo(newSpreadSheet);
  newSpreadSheet.deleteSheet(newSpreadSheet.getSheets()[0]);
  
  objBlob = UrlFetchApp.fetch('https://docs.google.com/spreadsheets/d/' + newSpreadSheet.getId() + 
                                   '/export?format=xlsx&id=' + newSpreadSheet.getId(), 
                                   {headers: {'Authorization': 'Bearer ' +  
                                              ScriptApp.getOAuthToken() }
                                   }).getAs('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  
  fileId = objFolder.createFile(objBlob).getId();  
    
  objFile = DriveApp.getFileById(newSpreadSheet.getId());
  DriveApp.removeFile(objFile);
  
  objFile = DriveApp.getFileById(fileId);
  objFile.setName(title);
  
  return fileId;
}

function setFormat(numSheet){
  
  var objSpreadSheet = SpreadsheetApp.getActiveSpreadsheet();
  var objSheet = objSpreadSheet.getSheets()[numSheet];
  var objRange; 
   
  
  if (numSheet == 1) {
    
    objRange = objSheet.getRange('A10:H' + objSheet.getLastRow().toString());
    objSheet.getRange('A11:H' + objSheet.getLastRow().toString()).sort([{column: 1, ascending: true}, {column: 2, ascending: true}, {column: 7, ascending: true}]);
    alignRange(objSheet.getRange('G11:G' + objSheet.getLastRow().toString()), "center", "middle");
    
  } else if(numSheet == 2) {
    
    objRange = objSheet.getRange('A10:G' + objSheet.getLastRow().toString());
    objSheet.getRange('A11:H' + objSheet.getLastRow().toString()).sort([{column: 1, ascending: true}, {column: 2, ascending: true}, {column: 6, ascending: true}]);
    alignRange(objSheet.getRange('G11:G' + objSheet.getLastRow().toString()), "left", "middle");
    
  }
  
  objSheet.getRange('B8').setValue(getDescriptionDate(numSheet));
  objRange.setBorder(true, true, true, true, true, true);
  alignRange(objRange, "center", "middle");
  objRange.setWrap(true);
  
  alignRange(objSheet.getRange('A11:A' + objSheet.getLastRow().toString()), "center", "middle");
  alignRange(objSheet.getRange('B11:B' + objSheet.getLastRow().toString()), "center", "middle");
  alignRange(objSheet.getRange('C11:C' + objSheet.getLastRow().toString()), "left", "top");
  alignRange(objSheet.getRange('D11:D' + objSheet.getLastRow().toString()), "left", "top");
  alignRange(objSheet.getRange('E11:E' + objSheet.getLastRow().toString()), "left", "top");
  alignRange(objSheet.getRange('F11:F' + objSheet.getLastRow().toString()), "center", "middle");
  alignRange(objSheet.getRange('H11:H' + objSheet.getLastRow().toString()), "left", "middle");
  
}

function alignRange(range, horizontal, vertical){
  range.setHorizontalAlignment(horizontal);
  range.setVerticalAlignment(vertical);
}

function getDescriptionDate(numSheet){

  var date = new Date();
  var year = date.getFullYear();
  var month = date.getMonth();
  
  if      ( month == 0) { month = 'ENERO'; }
  else if ( month == 1) { month = 'FEBRERO'; }
  else if ( month == 2) { month = 'MARZO'; }
  else if ( month == 3) { month = 'ABRIL'; }
  else if ( month == 4) { month = 'MAYO'; }
  else if ( month == 5) { month = 'JUNIO'; }         
  else if ( month == 6) { month = 'JULIO'; }         
  else if ( month == 7) { month = 'AGOSTO'; } 
  else if ( month == 8) { month = 'SEPTIEMBRE'; } 
  else if ( month == 9) { month = 'OCTUBRE'; } 
  else if ( month == 10) { month = 'NOVIEMBRE'; } 
  else if ( month == 11) { month = 'DICIEMBRE'; } 
  
  var value;
  
  if (numSheet == 1) {
    value = 'DEL ' + getFirstDay(date) + ' AL ' + getLastDay(date) + ' DE ' + month + ' ' + year;
  } else if (numSheet == 2){
    value = 'DE ' + month + ' ' + year;
  }
    
  return value;  
}

function getFirstDay(d) {
  d = new Date(d);
  var day = d.getDay(),
      diff = (d.getDate() -7) - day + (day == 0 ? -6:6);  
  return new Date(d.setDate(diff)).getDate();
}

function getLastDay(d) {
  d = new Date(d)
  var day = d.getDay(),
      diff = d.getDate() - day  + (day == 0 ? -6:5);
  return new Date(d.setDate(diff)).getDate();
}
