CREATE OR REPLACE PACKAGE BODY APPS.XXCALV_READ_XMLFILEAR_PKG
AS
/*********************************************************************************************
 * Nombre : XX_READ_XMLFILE_PKG.pkb          *
 * Creador : Condor Consulting Team            *
 * Version : 1.1                                                                            *
 * Fecha creacion: 26-SEP-2014                           *
 * Ultima Modificacion: 28/01/2015                                                         *
 * Descripcion: Lee los archivos XML de una ruta especifica y actualiza el UUID              *
 * Control de versiones:                                                                     *
 *    Fecha        Cambio                                   Autor                 Version    *
 *    -----------  ---------------------------------------  --------------------  -------    *
 *  26-SEP-2014     CCT(RASM)        Initial Creation                                                                                         *
  *  28-ENE-2015     CCT(SEJR)        Version 1.1                                                                                         *
 *********************************************************************************************/
   PROCEDURE LOG_ERROR (P_ERROR IN VARCHAR2)
   IS
   BEGIN

      APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.LOG, P_ERROR);
      DBMS_OUTPUT.PUT_LINE (P_ERROR);
   END LOG_ERROR;

   PROCEDURE WRITE_OUTPUT (P_OUTPUT IN VARCHAR2)
   IS
   BEGIN
      APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.OUTPUT, P_OUTPUT);
   END WRITE_OUTPUT;

   PROCEDURE LOG_OUT_P( P_MENSAJE IN VARCHAR2, P_TIPO        IN NUMBER)
  IS
    BEGIN
         IF P_TIPO = 0 THEN
               APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.OUTPUT, P_MENSAJE);
         ELSIF P_TIPO = 1 THEN
               APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.LOG, P_MENSAJE);
         ELSIF P_TIPO = 2 THEN
                APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.LOG, P_MENSAJE);
                APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.OUTPUT, P_MENSAJE);
               DBMS_OUTPUT.PUT_LINE(P_MENSAJE);
         END IF;
    END LOG_OUT_P;
  --llamada a una clase java para hacer la lectura del directorio
  PROCEDURE DIR_LIST_PR (P_DIRECTORY IN VARCHAR2) AS
            LANGUAGE JAVA
                NAME 'XXCALV_READ_XML_AR.getDirList( java.lang.String )';
  --Before Call class java DirList, now change to read file XML from UTL_FILe
  PROCEDURE GET_DIR_LIST (P_FILE_NAME IN VARCHAR2, P_DIRECTORY IN VARCHAR2, RETCODE OUT NUMBER)
   IS
    GL_44001       EXCEPTION;
    FILE_TYPE         SYS.UTL_FILE.FILE_TYPE;
    V_ARCHIVO        SYS.UTL_FILE.FILE_TYPE;
    V_PATH            VARCHAR (100) := P_DIRECTORY;
    V_LINEA           VARCHAR2 (255);
    L_ARCHIVO       VARCHAR2(250):=P_FILE_NAME;
    L_SRC_PATH      VARCHAR2 (250);
    V_CONT_LINEA_ARCHIVO NUMBER:=0;
    L_CONC NUMBER;
    L_REQUEST_ID NUMBER;
  BEGIN
      L_SRC_PATH := GET_PATH (V_PATH)||CHR(47);
      LOG_OUT_P ('l_src_path: ' || L_SRC_PATH,2);
      LOG_OUT_P ('p_directory: ' || P_DIRECTORY,2);
      DIR_LIST_PR (P_DIRECTORY =>L_SRC_PATH);
  EXCEPTION
     WHEN GL_44001 THEN
         LOG_ERROR(' ');
         LOG_ERROR('Error (Lectura Archivo):No se genero el archivo ya que no existen registros ');
         LOG_ERROR(' ');
         RETCODE:=1;
     WHEN NO_DATA_FOUND THEN
         LOG_ERROR(' ');
         LOG_ERROR('Error (Lectura Archivo):No se encontraron registros');
         LOG_ERROR(' ');
         RETCODE:=1;
     WHEN TOO_MANY_ROWS THEN
         LOG_ERROR(' ');
         LOG_ERROR('Error (Lectura Archivo): Too Many Rows');
         LOG_ERROR(' ');
         RETCODE:=1;
     WHEN  SYS.UTL_FILE.INVALID_PATH THEN
         LOG_ERROR(' ');
         LOG_ERROR('El nombre del archivo o la ruta es invalida. '||SQLERRM );
         LOG_ERROR(' ');
         RETCODE:=1;
     WHEN  SYS.UTL_FILE.INVALID_OPERATION THEN
         LOG_ERROR(' ');
         LOG_ERROR('El archivo no puede ser abierto u operado como se requiere, verifique que exista el archivo. '  ||SQLERRM );
         LOG_ERROR(' ');
         RETCODE:=1;
     WHEN OTHERS THEN
         LOG_ERROR(' ');
         LOG_ERROR('Error (Lectura Archivo): ' || SQLERRM||', en linea: '||V_CONT_LINEA_ARCHIVO);
         LOG_ERROR(' ');
         RETCODE:=1;
  END;
  --
  --Function get UUID from xmlType Column
   FUNCTION GET_UUID_XML (P_DATA_XML IN XMLTYPE, P_FILE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      L_UUID   VARCHAR2 (100);
   BEGIN
      SELECT RESULTS
        INTO L_UUID
        FROM XMLTABLE (
                XMLNAMESPACES (
                   'http://www.sat.gob.mx/TimbreFiscalDigital' AS "tfd",
                   'http://www.sat.gob.mx/cfd/3' AS "cfdi"),
                'cfdi:Comprobante/cfdi:Complemento'
                PASSING
                       P_DATA_XML
                COLUMNS RESULTS VARCHAR (100)
                              PATH '//tfd:TimbreFiscalDigital/@UUID');
      RETURN L_UUID;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         LOG_ERROR ('Not found UUID file ' || P_FILE_NAME);
         RETURN ('1');
      WHEN OTHERS
      THEN
         LOG_ERROR (
            'Error en get_uuid_xml file ' || P_FILE_NAME || ': ' || SQLERRM);
         RETURN ('1');
   END GET_UUID_XML;

   -- Function get next value sequence
   FUNCTION GET_SQ_VALUE (P_SEQUENCE_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      L_VALUE   NUMBER;
   BEGIN
      EXECUTE IMMEDIATE 'SELECT ' || P_SEQUENCE_NAME || '.nextval FROM DUAL'
         INTO L_VALUE;

      RETURN (L_VALUE);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         LOG_ERROR ('Sequence ' || P_SEQUENCE_NAME || ' Not found');
         RETURN (-1);
      WHEN OTHERS
      THEN
         LOG_ERROR ('Error in get_sq_value:' || SQLERRM);
         RETURN (-1);
   END GET_SQ_VALUE;

  --llamada a una clase java para borrar archivo
  PROCEDURE BORRAR_ARCHIVO_PR (P_DIRARCH IN VARCHAR2) AS
            LANGUAGE JAVA
                NAME 'XXCALV_DELETE_XML.deleteFile( java.lang.String )';

   --Procedure copy and move files from directory to dest_directory
   PROCEDURE XML_COPY_REMOVE (P_DIRECTORY        IN VARCHAR2,
                              P_FILE_NAME        IN VARCHAR2,
                              P_DEST_DIRECTORY   IN VARCHAR2,
                              P_RUTA_ORIGEN      IN VARCHAR2)
   IS
   BEGIN
/*
       BEGIN
         UTL_FILE.FCOPY (SRC_LOCATION    => P_DIRECTORY,
                         SRC_FILENAME    => P_FILE_NAME,
                         DEST_LOCATION   => P_DEST_DIRECTORY,
                         DEST_FILENAME   => P_FILE_NAME);
      EXCEPTION
         WHEN OTHERS
         THEN
            LOG_ERROR ('Error in utl copy: Archivo: ' || P_FILE_NAME || ' directorio: '||P_DIRECTORY ||','||P_DEST_DIRECTORY||' -- ' || SQLERRM);

            NULL;
      END;
*/
      BEGIN
         --UTL_FILE.FREMOVE (p_directory, p_file_name);
         LOG_ERROR ('borrar Archivo: ' || P_RUTA_ORIGEN||'/'||P_FILE_NAME);
         BORRAR_ARCHIVO_PR (P_DIRARCH =>P_RUTA_ORIGEN||'/'||P_FILE_NAME);
      EXCEPTION
         WHEN OTHERS THEN
          LOG_ERROR ('Error in utl remove: Archivo: ' || P_FILE_NAME || ' directorio: '||P_DIRECTORY ||','||P_DEST_DIRECTORY||' -- ' || SQLERRM);
      END;

   EXCEPTION
      WHEN OTHERS
      THEN
         LOG_ERROR ('Error in utl others: Archivo: ' || P_FILE_NAME || ' directorio: '||P_DIRECTORY ||','||P_DEST_DIRECTORY||' -- ' || SQLERRM);
   END XML_COPY_REMOVE;

  --Obtained serie (Source) of the bill XML
  FUNCTION SERIE_F ( P_DATA_XML IN XMLTYPE) RETURN VARCHAR2
  IS
    L_SERIE VARCHAR2(240);
    BEGIN
        SELECT SERIE
        INTO L_SERIE
        FROM XMLTABLE (
                XMLNAMESPACES (
                   'http://www.sat.gob.mx/TimbreFiscalDigital' AS "tfd",
                   'http://www.sat.gob.mx/cfd/3' AS "cfdi"),
                'cfdi:Comprobante'
                PASSING
                    P_DATA_XML
                COLUMNS SERIE VARCHAR (100)
                              PATH '//@Serie');

RETURN L_SERIE;

EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN L_SERIE;
    LOG_ERROR ('No Data Found  Function serie_f ' || SQLERRM);

WHEN OTHERS THEN
    RETURN L_SERIE;
    LOG_ERROR ('Error  Function serie_f ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

END SERIE_F;
--Obtained Folio (Invoice number) of the bill XML
FUNCTION NUM_FAC_F ( P_DATA_XML IN XMLTYPE) RETURN VARCHAR2
IS
L_FOLIOS VARCHAR2(100);
BEGIN
        SELECT FOLIOS
        INTO L_FOLIOS
        FROM XMLTABLE (
                XMLNAMESPACES (
                   'http://www.sat.gob.mx/TimbreFiscalDigital' AS "tfd",
                   'http://www.sat.gob.mx/cfd/3' AS "cfdi"),
                'cfdi:Comprobante'
                PASSING
                    P_DATA_XML
                COLUMNS FOLIOS VARCHAR (100)
                              PATH '//@Folio');

RETURN L_FOLIOS;

EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN L_FOLIOS;
    LOG_ERROR ('No Data Found  Function num_Fac ' || SQLERRM);

WHEN OTHERS THEN
    RETURN L_FOLIOS;
    LOG_ERROR ('Error  Function num_Fac ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

END NUM_FAC_F;

-- Obtains the amount of the invoice XML
FUNCTION MONTO_F ( P_DATA_XML IN XMLTYPE) RETURN VARCHAR2
IS
L_MONTO VARCHAR2(100) := NULL;
BEGIN
          SELECT MONTO
        INTO L_MONTO
        FROM XMLTABLE (
                XMLNAMESPACES (
                   'http://www.sat.gob.mx/TimbreFiscalDigital' AS "tfd",
                   'http://www.sat.gob.mx/cfd/3' AS "cfdi"),
                'cfdi:Comprobante'
                PASSING
                        P_DATA_XML
                COLUMNS MONTO VARCHAR (100)
                              PATH '//@Total');

RETURN L_MONTO;

EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN L_MONTO;
    LOG_ERROR ('No Data Found  Function monto_f ' || SQLERRM);

WHEN OTHERS THEN
    RETURN L_MONTO;
    LOG_ERROR ('Error  Function monto_f ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

END MONTO_F;

  --HGR I 06jul2016
  -- Obtener el campo moneda del tipo XML
  FUNCTION MONEDA_F ( P_DATA_XML IN XMLTYPE) RETURN VARCHAR2
  IS
    L_MONEDA VARCHAR2(100) := NULL;
    L_EXITE     VARCHAR2(100) := NULL;
    BEGIN
         --
         SELECT MONTO
           INTO L_MONEDA
           FROM XMLTABLE (
                          XMLNAMESPACES ('http://www.sat.gob.mx/TimbreFiscalDigital' AS "tfd",
                                         'http://www.sat.gob.mx/cfd/3' AS "cfdi"),
                                         'cfdi:Comprobante'
                          PASSING
                        P_DATA_XML
                COLUMNS MONTO VARCHAR (100) PATH '//@Moneda');
         --
         --existencia el lookup si corresponde a la descripcion
         select description
           into l_exite
           from fnd_lookup_values flv
          where 1=1
            AND FLV.LANGUAGE = USERENV('LANG')
            AND NVL(FLV.END_DATE_ACTIVE, (SYSDATE)+1 )>TRUNC(SYSDATE)
            AND FLV.ENABLED_FLAG  = 'Y'
            and flv.lookup_type ='XXCALV_DIVISA_MXN'
            and (UPPER(flv.description) =UPPER(l_moneda) or UPPER(flv.meaning) =upper(l_moneda))
            and rownum=1;

         RETURN L_EXITE;
         --
         EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       LOG_ERROR ('No Data Found  Function moneda_f ' || SQLERRM);
                       RETURN L_EXITE;
                       --
                  WHEN OTHERS THEN
                       LOG_ERROR ('Error  Function moneda_f ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
                       RETURN L_EXITE;
                       --
         END MONEDA_F;
  --HGR F

-- Obtains the date of the invoice XML
FUNCTION FECHA_FAC_F ( P_DATA_XML IN XMLTYPE) RETURN DATE
IS
L_FECHA DATE;
BEGIN
         SELECT TO_DATE(REPLACE(SUBSTR (FECHA, 1  , INSTR (FECHA,  'T')- 1), '-', '/'), 'YYYY/MM/DD')
        INTO L_FECHA
        FROM XMLTABLE (
                XMLNAMESPACES (
                   'http://www.sat.gob.mx/TimbreFiscalDigital' AS "tfd",
                   'http://www.sat.gob.mx/cfd/3' AS "cfdi"),
                'cfdi:Comprobante'
                PASSING
                        P_DATA_XML
                COLUMNS FECHA VARCHAR (100)
                              PATH '//@Fecha');

RETURN L_FECHA;

EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN L_FECHA;
    LOG_ERROR ('No Data Found  Function fecha_fac_f ' || SQLERRM);

WHEN OTHERS THEN
    RETURN L_FECHA;
    LOG_ERROR ('Error  Function fecha_fac_f ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

END FECHA_FAC_F;

  --busqueda del proveedor
  FUNCTION RFC_PROVEEDOR_F ( P_DATA_XML IN XMLTYPE)
    RETURN VARCHAR2
  IS
    L_RFC VARCHAR2(100);
    L_RFC_EBS VARCHAR2(150);
    BEGIN
         SELECT RFC
           INTO L_RFC
           FROM XMLTABLE (
                          XMLNAMESPACES ('http://www.sat.gob.mx/TimbreFiscalDigital' AS "tfd",
                                         'http://www.sat.gob.mx/cfd/3' AS "cfdi"),
                                         --'cfdi:Comprobante/cfdi:Receptor'
                                         'cfdi:Comprobante'
                                         PASSING (P_DATA_XML)
                          COLUMNS RFC VARCHAR (100) PATH '//cfdi:Receptor/@Rfc');
         --
         BEGIN
              SELECT HP.JGZZ_FISCAL_CODE
                INTO L_RFC_EBS
                FROM HZ_PARTIES HP
               WHERE 1=1
                 AND (HP.JGZZ_FISCAL_CODE)=L_RFC;
              --
              L_RFC:=L_RFC_EBS;
              --
              EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                            L_RFC:=NULL;
                            LOG_ERROR ('Validacion de RFC de Cliente VsRFC del XML : Error en el RFC ('||L_RFC||')' );
              END;
         --
         RETURN L_RFC;
         --
         EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       RETURN L_RFC;
                       LOG_ERROR ('No Data Found  Function rfc_proveedor_f ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
                  WHEN OTHERS THEN
                       RETURN L_RFC;
                       LOG_ERROR ('Error  Function rfc_proveedor_f ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
         END RFC_PROVEEDOR_F;

-- Obtains the date of the invoice XML
FUNCTION PROVEEDOR_F ( P_DATA_XML IN XMLTYPE) RETURN VARCHAR2
IS
L_RFC VARCHAR2(100);
BEGIN

          SELECT RFC
        INTO L_RFC
        FROM XMLTABLE (
                XMLNAMESPACES (
                   'http://www.sat.gob.mx/TimbreFiscalDigital' AS "tfd",
                   'http://www.sat.gob.mx/cfd/3' AS "cfdi"),
                'cfdi:Comprobante/cfdi:Receptor'
                PASSING                 --                            xmltype(
                     (
                     P_DATA_XML
                     )
                COLUMNS RFC VARCHAR (100)
                              PATH '//cfdi:Receptor/@Nombre');

RETURN L_RFC;

EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN L_RFC;
    LOG_ERROR ('No Data Found  Function proveedor_f ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

WHEN OTHERS THEN
    RETURN L_RFC;
    LOG_ERROR ('Error  Function proveedor_f ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

END PROVEEDOR_F;


-- Obtains the amount of the invoice XML
FUNCTION MONTOSUB_F ( P_DATA_XML IN XMLTYPE) RETURN VARCHAR2
IS
L_MONTO VARCHAR2(100) := NULL;
BEGIN
          SELECT MONTO
        INTO L_MONTO
        FROM XMLTABLE (
                XMLNAMESPACES (
                   'http://www.sat.gob.mx/TimbreFiscalDigital' AS "tfd",
                   'http://www.sat.gob.mx/cfd/3' AS "cfdi"),
                'cfdi:Comprobante'
                PASSING
                        P_DATA_XML
                COLUMNS MONTO VARCHAR (100)
                              PATH '//@SubTotal');

RETURN L_MONTO;

EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN L_MONTO;
    LOG_ERROR ('No Data Found  Function monto_f ' || SQLERRM);

WHEN OTHERS THEN
    RETURN L_MONTO;
    LOG_ERROR ('Error  Function monto_f ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

END MONTOSUB_F;

PROCEDURE DELETE_FILE_NAME_XML (P_FILE_NAME VARCHAR2)
IS
BEGIN

DELETE XXCALV_ELECT_XMLFILES_CTRL WHERE FILE_NAME = P_FILE_NAME;
--Commit;

EXCEPTION WHEN OTHERS THEN
    LOG_ERROR ('Error Function  delete_file_name_xml ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
END DELETE_FILE_NAME_XML;

  --Obtiene la consulta dinamica dependiendo de la aplicacion
  FUNCTION GET_QUERY_AR (P_APPLICATION_ID IN NUMBER,
                         P_RFC IN VARCHAR2,
                         P_FOLIO IN VARCHAR2,
                         P_MONTO IN VARCHAR2,
                         P_MONEDA IN VARCHAR2,--HGR
                         P_FECHA IN DATE,
                         P_SERIE IN VARCHAR2,
                         P_NOMPROVEEDOR IN VARCHAR2,
                         P_SUBMONTO IN VARCHAR2,
                         P_UUID   IN VARCHAR2
                         )
  RETURN VARCHAR2
  IS
    --Variables
    L_QUERY VARCHAR2(4000);
    TYPE L_DATA_QUERY_TABLE IS TABLE OF VARCHAR2(4000)
    INDEX BY BINARY_INTEGER;
    L_DATA_QUERY  L_DATA_QUERY_TABLE;
    L_TRANSACTION_NUM VARCHAR(40);
    --
    BEGIN
         --
         L_QUERY :=   '   SELECT RAH.CUSTOMER_TRX_ID'
         || CHR(10) ||'   ,      RAH.TRX_NUMBER'
         || CHR(10) ||'   ,      CTT.NAME'
         || CHR(10) ||'     FROM RA_CUSTOMER_TRX_ALL RAH '
         || CHR(10) ||'     ,    RA_CUST_TRX_TYPES_ALL CTT '
         || CHR(10) ||'     ,    HZ_CUST_ACCOUNTS ACCT '
         || CHR(10) ||'     ,    HZ_PARTIES HP '
         || CHR(10) ||'    WHERE 1=1'
         || CHR(10) ||'      AND RAH.BILL_TO_CUSTOMER_ID=ACCT.CUST_ACCOUNT_ID'
         || CHR(10) ||'      AND ACCT.PARTY_ID=HP.PARTY_ID'
         || CHR(10) ||'      AND CTT.CUST_TRX_TYPE_ID=RAH.CUST_TRX_TYPE_ID'
         || CHR(10) ||'      and not exists( '
         || CHR(10) ||'                     select text '
         || CHR(10) ||'                       FROM AR_NOTES N '
         || CHR(10) ||'                      WHERE N.CUSTOMER_TRX_ID=RAH.CUSTOMER_TRX_ID) '
         || CHR(10) ||'      AND RAH.TRX_NUMBER = ''' ||P_FOLIO||''''
         || CHR(10) ||'      AND TRUNC(RAH.TRX_DATE)= TRUNC(TO_DATE('''|| TO_CHAR(P_FECHA,'dd-MM-YY') ||''', ''DD-MM-YY''))'
         || CHR(10) ||'      AND RAH.INVOICE_CURRENCY_CODE  ='''|| P_MONEDA||''''
         || CHR(10) ||'      AND (SELECT ABS(SUM(EXTENDED_AMOUNT))'
         || CHR(10) ||'             FROM RA_CUSTOMER_TRX_LINES_ALL CTL'
         || CHR(10) ||'             WHERE CTL.CUSTOMER_TRX_ID=RAH.CUSTOMER_TRX_ID)=' ||P_MONTO
         || CHR(10) ||'      AND HP.JGZZ_FISCAL_CODE  ='''|| P_RFC||'''';

         RETURN (L_QUERY);
         EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       RETURN NULL;
                  WHEN OTHERS THEN
                       LOG_ERROR ('Error Function get_Query_Ar ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
                       RETURN NULL;

         END GET_QUERY_AR;



  --Valida si las facturas AP existen en la aplicacion y valde campos
  FUNCTION VALID_INVOICES_AR(P_APPLICATION_ID NUMBER,
                             P_FILE_NAME VARCHAR2,
                             P_FOLIO VARCHAR2,
                             P_MONTO VARCHAR2,
                             P_MONEDA VARCHAR2,
                             P_FECHA DATE,
                             P_RFC VARCHAR2,
                             P_SERIE VARCHAR2,
                             P_NOMPROVEEDOR VARCHAR2,
                             P_SUBMONTO VARCHAR2,
                             P_UUID   VARCHAR2,
                             P_FOLIO_ID OUT NUMBER,
                             P_TIPO_TRANS OUT VARCHAR2,
                             P_ORIGEN     OUT VARCHAR2)
  RETURN BOOLEAN
  IS
    --Variables de validacion
    L_FOLIO         NUMBER;
    L_QUERY       VARCHAR2(4000);
    L_TIPO_TRANS VARCHAR2(30);
    L_ORIGEN      VARCHAR2(50);
    L_INVOICE_ID   NUMBER;
    L_INVOICE_NUM   VARCHAR2(40);
    L_INVOICE_TYPE VARCHAR2(200);
    BEGIN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, P_FILE_NAME);
        FND_FILE.PUT_LINE(FND_FILE.LOG, P_FOLIO);
        FND_FILE.PUT_LINE(FND_FILE.LOG, P_MONTO);
        FND_FILE.PUT_LINE(FND_FILE.LOG, P_MONEDA);
        FND_FILE.PUT_LINE(FND_FILE.LOG, P_FECHA);
        FND_FILE.PUT_LINE(FND_FILE.LOG, P_RFC);
        FND_FILE.PUT_LINE(FND_FILE.LOG, P_SERIE);
        FND_FILE.PUT_LINE(FND_FILE.LOG, P_NOMPROVEEDOR);
        FND_FILE.PUT_LINE(FND_FILE.LOG, P_SUBMONTO);
        FND_FILE.PUT_LINE(FND_FILE.LOG, P_UUID);
    
         L_QUERY := GET_QUERY_AR (P_APPLICATION_ID => P_APPLICATION_ID
                                 ,P_RFC                   => P_RFC
                                 ,P_FOLIO               => P_FOLIO
                                 ,P_MONTO              => P_MONTO
                                 ,P_MONEDA             =>P_MONEDA
                                 ,P_FECHA                => P_FECHA
                                 ,P_SERIE                => P_SERIE
                                 ,P_NOMPROVEEDOR  => P_NOMPROVEEDOR
                                 ,P_SUBMONTO         => P_SUBMONTO
                                 ,P_UUID                 => P_UUID);
              LOG_OUT_P ('>>>Para Debug: l_query '||L_QUERY, 1);
              EXECUTE IMMEDIATE L_QUERY
                 INTO L_INVOICE_ID,L_INVOICE_NUM, L_INVOICE_TYPE;
              --
              P_FOLIO_ID :=L_INVOICE_ID;
              P_TIPO_TRANS:=L_INVOICE_NUM;
              P_ORIGEN  :=L_INVOICE_TYPE;


        --
        RETURN TRUE;
        --
        EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      LOG_OUT_P ('>>>Error: en el numero de transaccion: ya fue procesado o no esta creado el registro en la EBS (folio:  '||P_FOLIO||','||P_RFC||','||P_MONTO||','||P_MONEDA||','||P_FECHA ||') para este archivo: ' || P_FILE_NAME,2);
                      --Borra el Nombre de la tabla de historico de Archivos
                      DELETE_FILE_NAME_XML(P_FILE_NAME => P_FILE_NAME);
                      RETURN FALSE;
                 WHEN TOO_MANY_ROWS THEN
                      --Borra el Nombre de la tabla de historico de Archivos
                      DELETE_FILE_NAME_XML(P_FILE_NAME => P_FILE_NAME);
                      LOG_OUT_P ('>>>Error: Se encontro mas de un registro, (folio:  '||P_FOLIO||','||P_RFC||','||P_MONTO||','||P_MONEDA||','||P_FECHA ||') para este archivo: ' || P_FILE_NAME,2);
                      RETURN FALSE;
                 WHEN OTHERS THEN
                      LOG_OUT_P ('>>>Error: Function valid_invoices_Ar ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE ,2);
                      LOG_ERROR (' ===================================');
                      LOG_ERROR (L_QUERY);
                      LOG_ERROR (' ===================================');
                      G_CONT_ERROR := G_CONT_ERROR +1;
                      RETURN FALSE;
        END VALID_INVOICES_AR;

   --Function extract_data from xmlType Column
   FUNCTION EXTRACT_DATA (P_DATA_XML    IN XMLTYPE,
                          P_FILE_NAME   IN VARCHAR2,
                          P_PATH        IN VARCHAR2)
      RETURN VARCHAR2
   IS
      L_DATA        VARCHAR2 (250);
      L_SQL_QUERY   VARCHAR2 (250);
   BEGIN

    IF (P_PATH = 'cfdi:Comprobante/@fecha') THEN
   SELECT RESULTS
    INTO L_DATA
     FROM XMLTABLE (
             XMLNAMESPACES (
                'http://www.sat.gob.mx/TimbreFiscalDigital' AS "tfd",
                'http://www.sat.gob.mx/cfd/3' AS "cfdi"),
             ' cfdi:Comprobante'
             PASSING
                    P_DATA_XML
             COLUMNS RESULTS VARCHAR (250) PATH '//@Fecha') ;

    ELSE
   SELECT RESULTS
    INTO L_DATA
     FROM XMLTABLE (
             XMLNAMESPACES (
                'http://www.sat.gob.mx/TimbreFiscalDigital' AS "tfd",
                'http://www.sat.gob.mx/cfd/3' AS "cfdi"),
             ' cfdi:Comprobante'
             PASSING
                    P_DATA_XML
             COLUMNS RESULTS VARCHAR (250) PATH '//@Folio') ;

    END IF;

      RETURN L_DATA;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         LOG_ERROR ('Not found UUID file ' || P_FILE_NAME);
         RETURN (NULL);
      WHEN OTHERS
      THEN
         LOG_ERROR (
            'Error en extract_data file ' || P_FILE_NAME || ': ' || SQLERRM);
         RETURN (NULL);
   END EXTRACT_DATA;

  --
  --se crea la nota por API
  PROCEDURE CREAR_NOTA_PR (P_CUST_TRX_ID IN NUMBER,
                           P_UUID   IN VARCHAR2)
  AS
    V_NOTES_REC    AR_NOTES%ROWTYPE;
    --
    BEGIN
         V_NOTES_REC.NOTE_TYPE               := 'MAINTAIN';
         V_NOTES_REC.CUSTOMER_TRX_ID         := P_CUST_TRX_ID;
         V_NOTES_REC.TEXT                    := P_UUID;
         V_NOTES_REC.CUSTOMER_CALL_TOPIC_ID  := NULL;
         V_NOTES_REC.CALL_ACTION_ID          := NULL;
         V_NOTES_REC.CUSTOMER_CALL_ID        := NULL;
         V_NOTES_REC.CREATION_DATE           := SYSDATE;
         --CALL API
         APPS.ARP_NOTES_PKG.INSERT_P(V_NOTES_REC);
         EXCEPTION
                  WHEN OTHERS THEN
                       LOG_ERROR ('Error Procedimiento crear_nota_PR ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
         END CREAR_NOTA_PR;


  -- valida y empieza la carga de datos is es correcto
  PROCEDURE INSERT_DATA_EBS (P_UUID IN VARCHAR2,
                             P_DATA_XML IN XMLTYPE,
                             P_APPLICATION_ID IN NUMBER,
                             P_FILE_NAME IN VARCHAR2,
                             P_DIRECTORY IN VARCHAR2,
                             P_DEST_DIRECTORY IN VARCHAR2)
  IS
    L_SERIE   VARCHAR2(240);
    L_FOLIO  VARCHAR2(100);
    L_RFC      VARCHAR2(100);
    L_MONTO VARCHAR2(100);
    L_SUBMONTO VARCHAR2(100);
    L_NOMPROVEEDOR VARCHAR2(240);
    L_UUID VARCHAR2(50);
    L_FECHA  DATE;
    L_VALID_AR_AP BOOLEAN := TRUE;
    L_FOLIO_ID NUMBER;
    L_TIPO_TRANS VARCHAR2(30);
    L_USER_ID     NUMBER := APPS.FND_GLOBAL.USER_ID;
    L_ORIGEN       VARCHAR2(50);
    L_ID_SECUENCIA_AUX NUMBER:=0;
    L_MONEDA VARCHAR2(20); --hgr
    L_ID_SEQUENCE   NUMBER := 0;
    --
    BEGIN
         L_ID_SEQUENCE := GET_SQ_VALUE (P_SEQUENCE_NAME => 'XXCALV_AR_ELECT_XMLFILE_CTRL_S');
         L_SERIE := SERIE_F( P_DATA_XML );
         L_UUID := P_UUID;
         L_FOLIO := NUM_FAC_F ( P_DATA_XML );
         L_MONTO := MONTO_F ( P_DATA_XML );
         L_FECHA := FECHA_FAC_F ( P_DATA_XML );
         L_RFC := RFC_PROVEEDOR_F ( P_DATA_XML );--HGR
         L_NOMPROVEEDOR := PROVEEDOR_F ( P_DATA_XML );
         L_SUBMONTO := MONTOSUB_F ( P_DATA_XML );
         L_ID_SECUENCIA_AUX := GET_SQ_VALUE (P_SEQUENCE_NAME => 'XXCALV_AR_ELECT_CFDI_AUX_S');
         L_MONEDA:=MONEDA_F (P_DATA_XML);--HGR
         --
         IF (VALID_INVOICES_AR(P_APPLICATION_ID => P_APPLICATION_ID,
                               P_FILE_NAME      => P_FILE_NAME,
                               P_FOLIO          => L_FOLIO,
                               P_MONTO          => L_MONTO,
                               P_MONEDA         =>L_MONEDA,
                               P_FECHA          => L_FECHA,
                               P_RFC            => L_RFC,
                               P_SERIE          => L_SERIE,
                               P_NOMPROVEEDOR   => L_NOMPROVEEDOR,
                               P_SUBMONTO       => L_SUBMONTO,
                               P_UUID           => L_UUID,
                               P_FOLIO_ID       => L_FOLIO_ID,
                               P_TIPO_TRANS     => L_TIPO_TRANS,
                               P_ORIGEN         => L_ORIGEN)) THEN
            --inserta en la tabla de control si encuentra la factura
            INSERT INTO XXCALV_AR_XMLFILES_CTRL
                 VALUES (L_ID_SEQUENCE,
                         P_FILE_NAME,
                         P_DATA_XML,
                         P_UUID,
                         FND_GLOBAL.CONC_REQUEST_ID,
                         FND_GLOBAL.PROG_APPL_ID,
                         FND_GLOBAL.CONC_PROGRAM_ID,
                         SYSDATE);

            -- se crea la nota con el uuid uuid
            CREAR_NOTA_PR (P_CUST_TRX_ID =>L_FOLIO_ID
                          ,P_UUID   =>P_UUID);

            LOG_ERROR ('>>Tipo : STANDAR '  );
            LOG_OUT_P ('>>Informaci'||UNISTR('\00F3')||'n CORRECTA, el CFDI: ' || P_UUID || ', Folio: ' || L_FOLIO  || ', Serie: ' || L_SERIE || ', el Monto: ' || L_MONTO ||' y Fecha de Factura: ' || L_FECHA,2);
            LOG_ERROR ('>>customer_trx_id= ' || L_FOLIO_ID );
            LOG_ERROR (' ' );
            LOG_ERROR (' ' );
            G_CONT_OK := G_CONT_OK+1;
            V_FILES_DIR(G_CONT_OK).FILENAME:=P_FILE_NAME;
            --
         ELSE
             IF L_MONEDA IS NULL THEN
                LOG_OUT_P ('-->>>Validacion de la Moneda Vs Moneda XML: error en la Divisa ',2);
                LOG_OUT_P (' ',2);
             END IF;
             --
             IF L_RFC IS NULL THEN
                LOG_OUT_P ('-->>> Valiacion del RFC Vs RFC XML; Error en el Proveedor',2);
                LOG_OUT_P (' ',2);
             END IF;
             --
             LOG_OUT_P ('>>>Error, al intentar buscar la factura dentro de EBS  ' || '
                            Serie: ' || L_SERIE || '
                            Folio: ' || L_FOLIO || '
                            RFC  : ' || L_RFC || '
                            Monto: ' || L_MONTO || '
                            Fecha de Factura: ' || L_FECHA || '
                            Moneda: ' || L_MONEDA || '
                            Nombre del Archivo: ' || P_FILE_NAME,2 );
             G_CONT_ERROR := G_CONT_ERROR +1;
         END IF;
         --
         EXCEPTION
                  WHEN OTHERS THEN
                       LOG_ERROR ('Error Procedure insert_data_ebs ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
                       G_CONT_ERROR := G_CONT_ERROR + 1;
         END INSERT_DATA_EBS;
   --
   PROCEDURE INSERT_XML (P_FILE_NAME IN VARCHAR2,
                         P_DATA_XML IN XMLTYPE,
                         P_APPLICATION_ID IN NUMBER,
                         P_DIRECTORY IN VARCHAR2,
                         P_DEST_DIRECTORY IN VARCHAR2)
   IS
     BEGIN
          G_UUID := GET_UUID_XML (P_DATA_XML, P_FILE_NAME);
          --
          IF (G_UUID != '1' ) THEN
             --
             INSERT_DATA_EBS ( P_UUID => G_UUID,
                               P_DATA_XML => P_DATA_XML,
                               P_APPLICATION_ID => P_APPLICATION_ID,
                               P_FILE_NAME => P_FILE_NAME,
                               P_DIRECTORY => P_DIRECTORY,
                               P_DEST_DIRECTORY => P_DEST_DIRECTORY );
          END IF;
          --
          EXCEPTION
                   WHEN OTHERS THEN
                        LOG_ERROR ('Error in insert_xml: ' || SQLERRM);
                        G_CONT_ERROR := G_CONT_ERROR + 1;
          END INSERT_XML;

FUNCTION CONVERT_BLOB (P_CLOB CLOB) RETURN BLOB
AS
 L_BLOB          BLOB;
 L_DEST_OFFSET   INTEGER := 1;
 L_SOURCE_OFFSET INTEGER := 1;
 L_LANG_CONTEXT  INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
 L_WARNING       INTEGER := DBMS_LOB.WARN_INCONVERTIBLE_CHAR;
BEGIN

  DBMS_LOB.CREATETEMPORARY(L_BLOB, TRUE);
  DBMS_LOB.CONVERTTOBLOB
  (
   DEST_LOB    =>L_BLOB,
   SRC_CLOB    =>P_CLOB,
   AMOUNT      =>DBMS_LOB.LOBMAXSIZE,
   DEST_OFFSET =>L_DEST_OFFSET,
   SRC_OFFSET  =>L_SOURCE_OFFSET,
   BLOB_CSID   =>DBMS_LOB.DEFAULT_CSID,
   LANG_CONTEXT=>L_LANG_CONTEXT,
   WARNING     =>L_WARNING
  );
  RETURN L_BLOB;
EXCEPTION
      WHEN OTHERS THEN

      LOG_ERROR ('Error Function  Convert_blob: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
      RETURN NULL;

NULL;
END CONVERT_BLOB;

FUNCTION CONVERT_XML_ERROR(P_XML_CLOB IN CLOB, P_FILE_NAME IN VARCHAR2) RETURN XMLTYPE
IS

L_XML_TEXT VARCHAR2(4000);
L_XML_TEXT2 VARCHAR2(4000);
L_XML_TEXT3 VARCHAR2(4000);
L_XML_TEXT4 VARCHAR2(4000);

L_FILE_DATA BLOB;
L_XML XMLTYPE;

BEGIN

        L_FILE_DATA := CONVERT_BLOB( P_XML_CLOB );

        L_XML_TEXT :=  UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(L_FILE_DATA,2000,1)) || UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(L_FILE_DATA,2000,2001));
        L_XML_TEXT2 := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(L_FILE_DATA,2000,4001))  || UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(L_FILE_DATA,2000,6001));
        L_XML_TEXT3 := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(L_FILE_DATA,2000,8001))  || UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(L_FILE_DATA,2000,10001));
        L_XML_TEXT4 := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(L_FILE_DATA,2000,12001))  || UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(L_FILE_DATA,2000,14001));


        SELECT REPLACE ( L_XML_TEXT,
                    SUBSTR(L_XML_TEXT, 1,
                        INSTR ( L_XML_TEXT, '<' ) -1
                    )
                    , '')
            INTO L_XML_TEXT
        FROM DUAL;

        L_XML := XMLTYPE.CREATEXML (  L_XML_TEXT || L_XML_TEXT2 || L_XML_TEXT3 || L_XML_TEXT4  );

        RETURN L_XML;
--        XMLType.createXML ( l_xml_text || l_xml_text2 || l_xml_text3 || l_xml_text4 || l_xml_text5 || l_xml_text6 || l_xml_text7 || l_xml_text8 );

EXCEPTION
      WHEN OTHERS THEN

--      log_error ( 'XML Error: ' ||  l_xml_text );
--      log_error ('Error Function  Convert_xml_v2: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' Archivo XML: ' || p_file_name );
--      log_error ( 'Despues ' || l_xl_xml_text_replaceml_text );
--      Return l_xml;

NULL;

END CONVERT_XML_ERROR;

  --Carga de archivos a tabla auxiliar
  PROCEDURE CARGA_TABLA_AUX_PR (P_SOURCE_DIRECTORY IN VARCHAR2,
                                P_DEST_DIRECTORY    IN VARCHAR2)
  IS
    l_error VARCHAR2(10000);
    --cursor get name files
    CURSOR INFO_CUR IS
           SELECT FILENAME
             FROM XXCALV_AR_CFDI_DIR_LIST_T
            WHERE UPPER (FILENAME) LIKE '%.XML'
            ORDER BY FILENAME;
             /*     AND NOT EXISTS
                             (SELECT 'X'
                                FROM XXCALV_AR_XMLFILES_CTRL
                               WHERE FILE_NAME = FILENAME)
                               */

      --
      TYPE INFO_TBL IS TABLE OF INFO_CUR%ROWTYPE INDEX BY BINARY_INTEGER;
    R_INFO INFO_TBL;
    V NUMBER:=0;
    --
    L_AP_AUX_ID   NUMBER :=0;
    BEGIN
         --
          OPEN INFO_CUR;
         FETCH INFO_CUR BULK COLLECT INTO R_INFO;
         CLOSE INFO_CUR;
         --
         FOR V IN 1 .. R_INFO.COUNT
             LOOP
                 L_AP_AUX_ID:=XXCALV_ELECT_CFDI_AUX_S.NEXTVAL;
                 --
                 LOG_OUT_P('nombre de archivo: '||R_INFO(V).FILENAME,1);
                 BEGIN
                 INSERT INTO XXCALV_CFDI_AR_AUX_T
                        (AR_AUX_ID
                        ,REQUEST_ID
                        ,FILE_NAME
                        ,XML_DATA
                        )
                   VALUES
                        (L_AP_AUX_ID --AP_aux_id
                        ,FND_GLOBAL.CONC_REQUEST_ID  --request_id
                        ,R_INFO(V).FILENAME --FILE_NAME
                        ,XMLTYPE(BFILENAME(P_SOURCE_DIRECTORY,R_INFO(V).FILENAME),NLS_CHARSET_ID('AL32UTF8'))  --XML_DATA
                        );
                 EXCEPTION
                  WHEN OTHERS THEN
                    l_error := sqlerrm;
                    if instr(l_error,'LPX-00229')>0
                    then
                       LOG_OUT_P ('>>>Error, Archivo vacio  ',2);
                       G_CONT_FILE := G_CONT_FILE+1;
                       G_CONT_ERROR := G_CONT_ERROR+1;

                    end if;
                  END;

             END LOOP;
   END CARGA_TABLA_AUX_PR;

  --Encontrar duplicados
  PROCEDURE DUPLICADOS_PR (P_REQUEST_ID IN NUMBER)
  IS
    --redupera los archivos que son suplicados
    CURSOR INFO_CUR(C_REQUEST_ID IN NUMBER) IS
           SELECT (FOLIO||TOTAL||FECHA||MONEDA||RFCRECEPTOR) DUP
           ,       COUNT(1) CANTIDAD
             FROM (
                   SELECT FILE_NAME
                   ,      EXTRACTVALUE(XML_DATA, '/cfdi:Comprobante/@Folio','xmlns:cfdi="http://www.sat.gob.mx/cfd/3"') FOLIO
                   ,      EXTRACTVALUE(XML_DATA, '/cfdi:Comprobante/@Total','xmlns:cfdi="http://www.sat.gob.mx/cfd/3"') TOTAL
                   ,      EXTRACTVALUE(XML_DATA, '/cfdi:Comprobante/@Fecha','xmlns:cfdi="http://www.sat.gob.mx/cfd/3"') FECHA
                   ,      EXTRACTVALUE(XML_DATA, '/cfdi:Comprobante/@Moneda','xmlns:cfdi="http://www.sat.gob.mx/cfd/3"') MONEDA
                   ,      EXTRACTVALUE(XML_DATA, '/cfdi:Comprobante/cfdi:Receptor/@Rfc','xmlns:cfdi="http://www.sat.gob.mx/cfd/3"') RFCRECEPTOR
                     FROM XXCALV_CFDI_AR_AUX_T
                     WHERE 1=1
                       AND REQUEST_ID=C_REQUEST_ID
                  )
                  GROUP BY (FOLIO||TOTAL||FECHA||MONEDA||RFCRECEPTOR)
                  HAVING COUNT(1)>1;
      --
      TYPE INFO_TBL IS TABLE OF INFO_CUR%ROWTYPE INDEX BY BINARY_INTEGER;
    R_INFO INFO_TBL;
    V NUMBER:=0;
    --
    --redupera los archivos que son suplicados
    CURSOR DUP_CUR(C_REQUEST_ID IN NUMBER
                  ,C_DUP        IN VARCHAR2) IS
           SELECT (FOLIO||' '||TOTAL||' '||FECHA||' '||MONEDA||' '||RFCRECEPTOR) DUP
           ,      FILE_NAME
             FROM (
                   SELECT FILE_NAME
                   ,      EXTRACTVALUE(XML_DATA, '/cfdi:Comprobante/@Folio','xmlns:cfdi="http://www.sat.gob.mx/cfd/3"') FOLIO
                   ,      EXTRACTVALUE(XML_DATA, '/cfdi:Comprobante/@Total','xmlns:cfdi="http://www.sat.gob.mx/cfd/3"') TOTAL
                   ,      EXTRACTVALUE(XML_DATA, '/cfdi:Comprobante/@Fecha','xmlns:cfdi="http://www.sat.gob.mx/cfd/3"') FECHA
                   ,      EXTRACTVALUE(XML_DATA, '/cfdi:Comprobante/@Moneda','xmlns:cfdi="http://www.sat.gob.mx/cfd/3"') MONEDA
                   ,      EXTRACTVALUE(XML_DATA, '/cfdi:Comprobante/cfdi:Receptor/@Rfc','xmlns:cfdi="http://www.sat.gob.mx/cfd/3"') RFCRECEPTOR
                     FROM XXCALV_CFDI_AR_AUX_T
                     WHERE 1=1
                       AND REQUEST_ID=C_REQUEST_ID
                  ) A
                  WHERE 1=1
                    AND (FOLIO||TOTAL||FECHA||MONEDA||RFCRECEPTOR)=C_DUP;
      --
      TYPE DUP_TBL IS TABLE OF DUP_CUR%ROWTYPE INDEX BY BINARY_INTEGER;
    R_DUP DUP_TBL;
    V1 NUMBER:=0;
    --
    BEGIN
         --
          OPEN INFO_CUR(C_REQUEST_ID=>P_REQUEST_ID);
         FETCH INFO_CUR BULK COLLECT INTO R_INFO;
         CLOSE INFO_CUR;
         --
         FOR V IN 1 .. R_INFO.COUNT
             LOOP
                 IF R_INFO.COUNT>0 THEN
                    LOG_OUT_P('Numero de transacciones Duplicadas: '||R_INFO.COUNT,1);
                    --
                     OPEN DUP_CUR(C_REQUEST_ID=>P_REQUEST_ID
                               ,C_DUP=>R_INFO(V).DUP);
                    FETCH DUP_CUR BULK COLLECT INTO R_DUP;
                    CLOSE DUP_CUR;
                    --
                    FOR V1 IN 1 .. R_DUP.COUNT
                        LOOP
                            LOG_OUT_P('Transaccion duplicada folio: '||R_DUP(V1).DUP|| ' Archivo:'||R_DUP(V1).FILE_NAME,2);
                        END LOOP;
                 END IF;
             END LOOP;
    END DUPLICADOS_PR;

  -- Procedure Read file from directory and move to dest_directory
  PROCEDURE READ_XML ( P_APPLICATION_ID     IN NUMBER,
                                      P_DIRECTORY            IN VARCHAR2,
                                      P_SOURCE_DIRECTORY IN VARCHAR2,
                                      P_DEST_DIRECTORY    IN VARCHAR2,
                                      P_LOOKUP_TBL          IN LOOKUP_TBL,
                                      P_CONT_FILES          OUT NUMBER)
  IS
    --cursor get name files
    CURSOR C_DIR_LIST IS
           SELECT A.FILE_NAME
           ,      A.XML_DATA
             FROM XXCALV_CFDI_AR_AUX_T A
            WHERE 1=1
              AND UPPER (A.FILE_NAME) LIKE '%.XML'
              ORDER BY A.FILE_NAME;
/*              AND NOT EXISTS
                            (SELECT 'X'
                               FROM XXCALV_AR_XMLFILES_CTRL B
                              WHERE B.FILE_NAME = A.FILE_NAME)

*/
    --
    TYPE INFO_TBL IS TABLE OF C_DIR_LIST%ROWTYPE INDEX BY BINARY_INTEGER;
    R_INFO INFO_TBL;
    V NUMBER:=0;
    --
    --redupera los archivos que son suplicados
    CURSOR DUP_CUR(C_FILE_NAME IN VARCHAR2) IS
           SELECT (FOLIO||TOTAL||FECHA||MONEDA||RFCRECEPTOR) DUP
           ,       COUNT(1) CANTIDAD
           FROM (SELECT FILE_NAME
                 ,      EXTRACTVALUE(XML_DATA, '/cfdi:Comprobante/@Folio','xmlns:cfdi="http://www.sat.gob.mx/cfd/3"') FOLIO
                 ,      EXTRACTVALUE(XML_DATA, '/cfdi:Comprobante/@Total','xmlns:cfdi="http://www.sat.gob.mx/cfd/3"') TOTAL
                 ,      EXTRACTVALUE(XML_DATA, '/cfdi:Comprobante/@Fecha','xmlns:cfdi="http://www.sat.gob.mx/cfd/3"') FECHA
                 ,      EXTRACTVALUE(XML_DATA, '/cfdi:Comprobante/@Moneda','xmlns:cfdi="http://www.sat.gob.mx/cfd/3"') MONEDA
                 ,      EXTRACTVALUE(XML_DATA, '/cfdi:Comprobante/cfdi:Receptor/@Rfc','xmlns:cfdi="http://www.sat.gob.mx/cfd/3"') RFCRECEPTOR
                   FROM XXCALV_CFDI_AR_AUX_T
                  WHERE 1=1
                    AND FILE_NAME=C_FILE_NAME
                 )
           GROUP BY (FOLIO||TOTAL||FECHA||MONEDA||RFCRECEPTOR)
          HAVING COUNT(1)>1;
    --
    TYPE DUP_TBL IS TABLE OF DUP_CUR%ROWTYPE INDEX BY BINARY_INTEGER;
    R_DUP DUP_TBL;
    V NUMBER:=0;
    --
    L_XMLCLOB       CLOB;
    L_XMLFILE       BFILE;
    L_XML           XMLTYPE;
    L_VALUE         VARCHAR2 (250);

    L_SRC_OFFSET    NUMBER := 1;
    L_DEST_OFFSET  NUMBER := 1;
    L_LANG_CTX      NUMBER := DBMS_LOB.DEFAULT_LANG_CTX;
    L_WARNING      INTEGER;
    L_FILE_NAME   VARCHAR2(100);
    L_CONT_CFDI    NUMBER :=0;
    L_CONT_ERROR   NUMBER :=0;
    BEGIN
          OPEN C_DIR_LIST;
         FETCH C_DIR_LIST BULK COLLECT INTO R_INFO;
         CLOSE C_DIR_LIST;
         --
         FOR V IN 1 .. R_INFO.COUNT
             LOOP
                 --Buscar dup
                  OPEN DUP_CUR(C_FILE_NAME=>R_INFO(V).FILE_NAME);
                 FETCH DUP_CUR BULK COLLECT INTO R_DUP;
                 CLOSE DUP_CUR;
                 --
                 LOG_OUT_P('Se encontraron duplicados: '||R_DUP.COUNT,1);
                 IF R_DUP.COUNT=0 THEN
                    G_CONT_FILE:=G_CONT_FILE+1;
                    L_CONT_CFDI := L_CONT_CFDI + 1;
                    LOG_OUT_P('Archivo XML: '||R_INFO(V).FILE_NAME,1);
                    IF ( L_CONT_ERROR = 0) THEN
                       --
                       INSERT_XML (P_FILE_NAME => R_INFO(V).FILE_NAME
                                  ,P_DATA_XML =>R_INFO(V).XML_DATA
                                  ,P_APPLICATION_ID => P_APPLICATION_ID
                                  ,P_DIRECTORY => P_DIRECTORY
                                  ,P_DEST_DIRECTORY => P_DEST_DIRECTORY );
                       IF G_UUID != '1' THEN
                          FOR IDX IN 1 .. P_LOOKUP_TBL.COUNT
                              LOOP
                                  L_VALUE := EXTRACT_DATA (R_INFO(V).XML_DATA
                                                          , R_INFO(V).FILE_NAME
                                                          , P_LOOKUP_TBL(IDX).TAG);
                              END LOOP;
                          --
                       END IF;
                    END IF;
                 ELSIF R_DUP.COUNT>0 THEN
                       G_CONT_ERROR := G_CONT_ERROR +1;
                 END IF;
            END LOOP;
        --log_error('>>>Total de Archivos obtenidos de Cursor: '||to_char(l_cont_cfdi));
        P_CONT_FILES:=L_CONT_CFDI;
        EXCEPTION
                 WHEN OTHERS THEN
                      LOG_ERROR ('>>>Error: Lectura de Archivo:' || L_FILE_NAME || ' ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
                      G_CONT_ERROR := G_CONT_ERROR + 1;
        END READ_XML;

   --Function get path
   FUNCTION GET_PATH (P_DIRECTORY_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      L_PATH   VARCHAR2 (100);
   BEGIN
      BEGIN
         SELECT TRIM (DIRECTORY_PATH)
           INTO L_PATH
           FROM ALL_DIRECTORIES
          WHERE UPPER (DIRECTORY_NAME) = UPPER (P_DIRECTORY_NAME);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            LOG_ERROR ('Ruta no encontrada para el directorio:' || P_DIRECTORY_NAME);
            L_PATH := NULL;
         WHEN TOO_MANY_ROWS
         THEN
            LOG_ERROR ('Too Many Rows:' || P_DIRECTORY_NAME);
            L_PATH := NULL;
         WHEN OTHERS
         THEN
            LOG_ERROR ('Error: '||SQLERRM||', para obtener ruta del directorio: '|| P_DIRECTORY_NAME);
            L_PATH := NULL;
      END;

      RETURN (L_PATH);
   EXCEPTION
      WHEN OTHERS
      THEN
         LOG_ERROR ('Error in get_path function:' || SQLERRM);
         --ROLLBACK;
         RETURN (NULL);
   END GET_PATH;

   --Function get_dff_column
   FUNCTION GET_DFF_COLUMN (P_APPLICATION_ID   IN NUMBER,
                            P_FLEX_NAME        IN VARCHAR2,
                            P_FLEX_CONTEXT     IN VARCHAR2,
                            P_FLEX_COLUMN      IN VARCHAR2)
      RETURN VARCHAR2
   IS
      L_COLUMN   VARCHAR2 (30);
   BEGIN
      BEGIN
         SELECT APPLICATION_COLUMN_NAME
           INTO L_COLUMN
           FROM FND_DESCR_FLEX_COLUMN_USAGES B
          WHERE     B.APPLICATION_ID = P_APPLICATION_ID
                AND B.DESCRIPTIVE_FLEXFIELD_NAME = P_FLEX_NAME
                AND B.DESCRIPTIVE_FLEX_CONTEXT_CODE = P_FLEX_CONTEXT
                AND B.END_USER_COLUMN_NAME = P_FLEX_COLUMN
                AND B.ENABLED_FLAG = 'Y';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            LOG_ERROR ('No Data Found :' || P_APPLICATION_ID);
            LOG_ERROR ('DFF Name :' || P_FLEX_NAME);
            LOG_ERROR ('DFF Context :' || P_FLEX_CONTEXT);
            LOG_ERROR ('DFF Column :' || P_FLEX_COLUMN);
            L_COLUMN := NULL;
         WHEN TOO_MANY_ROWS
         THEN
            LOG_ERROR ('Too Many Rows:' || P_APPLICATION_ID);
            LOG_ERROR ('DFF Name :' || P_FLEX_NAME);
            LOG_ERROR ('DFF Context :' || P_FLEX_CONTEXT);
            LOG_ERROR ('DFF Column :' || P_FLEX_COLUMN);
            L_COLUMN := NULL;
         WHEN OTHERS
         THEN
            LOG_ERROR ('Error:' || SQLCODE);
            LOG_ERROR ('Appl Id:' || P_APPLICATION_ID);
            LOG_ERROR ('DFF Name :' || P_FLEX_NAME);
            LOG_ERROR ('DFF Context :' || P_FLEX_CONTEXT);
            LOG_ERROR ('DFF Column :' || P_FLEX_COLUMN);
            L_COLUMN := NULL;
      END;

      RETURN (L_COLUMN);
   EXCEPTION
      WHEN OTHERS
      THEN
         LOG_ERROR ('Error in get_dff_column function:' || SQLERRM);
         --ROLLBACK;
         RETURN (NULL);
   END;
  --
  PROCEDURE MAIN (ERRBUF                  OUT VARCHAR2,
                   RETCODE                 OUT NUMBER,
                   P_APPLICATION_ID     IN     NUMBER,
                   P_SOURCE_DIRECTORY   IN     VARCHAR2,
                   P_DEST_DIRECTORY     IN     VARCHAR2
                   --p_flex_name          IN     VARCHAR2,
                   --p_flex_context       IN     VARCHAR2,
                   --p_flex_column        IN     VARCHAR2
                   )
   IS
      L_SRC_PATH      VARCHAR2 (250);
      L_DEST_PATH    VARCHAR2 (250);
      L_COLUMN       VARCHAR2 (50);
      L_LOOKUP_TBL   LOOKUP_TBL;
      L_FILE_NAME    VARCHAR2(240);
      L_REQUEST_ID   NUMBER := APPS.FND_GLOBAL.CONC_REQUEST_ID;
      L_CONT_FILES     NUMBER :=0;
   BEGIN
      -- get source directory path
      L_SRC_PATH := GET_PATH (P_SOURCE_DIRECTORY);
      L_DEST_PATH := GET_PATH (P_DEST_DIRECTORY);

      IF ( L_SRC_PATH IS NOT NULL AND
                  L_DEST_PATH IS NOT NULL ) THEN
        --generate file name with request_id
        L_FILE_NAME :='XXCALV_DIR_LIST_'||TO_CHAR(L_REQUEST_ID)||'.txt';

        LOG_OUT_P ('Ruta Origen: ' || L_SRC_PATH,2);
        LOG_OUT_P ('Ruta Destino: ' || L_DEST_PATH,2);
        LOG_OUT_P ('==============================================================================',2);
        LOG_OUT_P ('          Inicio de Actualizaci'||UNISTR('\00F3')||'n UUID',2);
        LOG_OUT_P ('==============================================================================',2);
        LOG_OUT_P (' ',2);

         OPEN LOOKUP_CUR;
         LOOP
            FETCH LOOKUP_CUR
            BULK COLLECT INTO L_LOOKUP_TBL
            LIMIT 10000;
            EXIT WHEN LOOKUP_CUR%NOTFOUND;
         END LOOP;

         CLOSE LOOKUP_CUR;
         --lectura de los archivos en el directorio
         GET_DIR_LIST (P_FILE_NAME => L_FILE_NAME
                      ,P_DIRECTORY  => P_SOURCE_DIRECTORY
                      ,RETCODE       => RETCODE);
         --carga de los archivos en la tabla auxiliar
         CARGA_TABLA_AUX_PR (P_SOURCE_DIRECTORY =>P_SOURCE_DIRECTORY,
                                 P_DEST_DIRECTORY    =>P_SOURCE_DIRECTORY);

         --
         IF ( RETCODE IS NULL
                 OR RETCODE != 1) THEN
            --read XML file
            READ_XML (P_APPLICATION_ID, L_SRC_PATH, P_SOURCE_DIRECTORY,P_DEST_DIRECTORY, L_LOOKUP_TBL,L_CONT_FILES);
            DUPLICADOS_PR(P_REQUEST_ID=>FND_GLOBAL.CONC_REQUEST_ID);
            LOG_OUT_P ('-->Se validaron '||G_CONT_FILE||' archivo(s) ',2);
            COMMIT;

            --
            IF ( G_CONT_ERROR > 0 ) THEN
                LOG_OUT_P ('-->Total de transacciones con error: '||G_CONT_ERROR,2);
            END IF;
            --
            IF ( L_CONT_FILES > 0 ) THEN
                 LOG_OUT_P ('-->Total de transacciones con exito: '||TO_CHAR(G_CONT_OK),2);

                 FOR I IN V_FILES_DIR.FIRST.. V_FILES_DIR.LAST
                     LOOP
                         XML_COPY_REMOVE (P_DIRECTORY        =>P_SOURCE_DIRECTORY,
                                          P_FILE_NAME        =>V_FILES_DIR(I).FILENAME,
                                          P_DEST_DIRECTORY   =>P_DEST_DIRECTORY,
                                          P_RUTA_ORIGEN      =>L_SRC_PATH);
                     END LOOP;
             ELSE
                 LOG_OUT_P ('No existen CFDIs para subir, Verifique que los archivos XML no hayan sido Cargados anteriormente',2);
                 RETCODE :=  1;
             END IF;
         ELSE
           LOG_OUT_P ('>>>Error: En Carga de archivos XML',2);
            RETCODE :=  1;
         END IF;

      END IF;
     LOG_OUT_P (' ',2);
     LOG_OUT_P  ('==============================================================================',2);
     LOG_OUT_P  ('          Fin de Actualizaci'||UNISTR('\00F3')||'n UUID',2);
     LOG_OUT_P  ('==============================================================================',2);
     LOG_OUT_P  (' ',2);
   EXCEPTION
      WHEN OTHERS
      THEN
         LOG_ERROR ('Error in Procedure MAIN :' || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
         RETCODE :=  1;
         ROLLBACK;
   END MAIN;
END XXCALV_READ_XMLFILEAR_PKG;
/
