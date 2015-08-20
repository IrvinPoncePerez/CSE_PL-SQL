CREATE OR REPLACE PROCEDURE APPS.XXCALV_IMPRESION_ETIQUETAS_PRC (P_ETIQUETA          IN VARCHAR2,       -- Numero Etiqueta--
                                                                 P_DIA               IN VARCHAR2,       -- Dia de Transaccion--
                                                                 P_CAJAS             IN VARCHAR2,       -- Cajas--
                                                                 P_TAMANO            IN VARCHAR2,       -- Tamaño del huevo--
                                                                 P_TIPO_HUEVO        IN VARCHAR2,       -- Tipo de Huevo--
                                                                 P_PESO              IN VARCHAR2,       -- Peso--
                                                                 P_PESO_CAJA         IN VARCHAR2,       -- Peso Caja--
                                                                 P_PROCEDENCIA       IN VARCHAR2,       -- Procedencia--
                                                                 P_FOLIO             IN VARCHAR2,       -- Numero Etiqueta                                                                   
                                                                 ERRBUF              OUT VARCHAR2,       
                                                                 RETCODE             OUT VARCHAR2
                                                                 )       
IS

/**
 **   DESCRIPCION: Impresion Etiqueta Zebra 
 **
 **   Procedimiento de Impresion de Etiqueta Zebra  
 **
 **   DEPENDENCIAS:
 **
 **           PACKAGES:     XXCALV_UTILS_PKG
 **
 **  CREACIÓN.
 **
 **  VERS. FECHA           AUTOR                                  
 **  ----- -----------     ----------------------------------  
 **   1.0  06-DIC-2010     Roberto Cárdenas. (JRCA) STO                     
 **
 **  MODIFICACIóN.
 **
 **  VERS. FECHA           AUTOR                                 DESCRIPCION MODIFICACION
 **  ----- -----------     ----------------------------------    -------------
 **  
 **
 **/

v_1 varchar2(10);
v_2 varchar2(10);

BEGIN

select replace(regexp_substr(P_PESO_CAJA,',[^,]+'),',',''),regexp_substr(P_PESO_CAJA,'[^,]+')
  into v_1,v_2
  from dual;

XXCALV_UTILS_PKG.XXCALV_VOUT('^XA');
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO0,360^GB601,0,4^FS');
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO0,200^GB601,0,4^FS');
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO30,55^B3N,N,140,Y,Y^FD'||P_CAJAS||'^FS');   
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO60,220^AEN,25,10^FDDIA:^FS');
---
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO60,315^AEN,25,10^FD'||v_1||'^FS');
---
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO200,220^AEN,25,10^FDFOLIO:^FS');
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO440,220^AEN,25,10^FDTIPO:^FS');
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO70,260^AEN,40,20^FD'||P_TAMANO||'^FS');        
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO60,310^ADN,40,20^FD'||P_ETIQUETA||'^FS');         
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO210,260^AEN,70,22^FD'||SUBSTR(P_CAJAS,-6)||'^FS');
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO350,260^ADN,40,20^FD'||P_TIPO_HUEVO||'^FS');      
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO350,310^ADN,40,20^FD'||P_PESO||'^FS');                 
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO35,380^AEN,25,10^FDCAJAS:^FS');
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO240,380^AEN,25,10^FDPESO:^FS');
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO420,380^AEN,25,10^FDP/CAJA:^FS');
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO25,435^A0N,40,40^FD'||v_2||'^FS');       
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO210,415^AEN,70,22^FD'||P_PROCEDENCIA||'^FS');    
XXCALV_UTILS_PKG.XXCALV_VOUT('^FO420,415^AEN,70,22^FD'||round(P_FOLIO,2)||'^FS');          
XXCALV_UTILS_PKG.XXCALV_VOUT('^XZ');

EXCEPTION
WHEN OTHERS THEN
XXCALV_UTILS_PKG.XXCALV_VOUT('Existio un Error en la Ejecucion de la Etiqueta: '||sqlerrm);
XXCALV_UTILS_PKG.XXCALV_VLOG('Existio un Error en la Ejecucion de la Etiqueta: '||sqlerrm);
END;