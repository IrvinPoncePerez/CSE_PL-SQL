CREATE OR REPLACE PACKAGE BODY APPS.XXCALV_READ_XMLFILE_PAY_PKG
AS
   
/*********************************************************************************************
 * Nombre : XXCALV_READ_XMLFILE_PAY_PKG.pkb          *
 * Creador : Condor Consulting Team (FJQR)           *
 * Version : 1.0
 * Fecha creacion: 06-JUL-2016                           *
 * Ultima Modificacion:                                                          *
 * Descripcion: Lee los archivos XML de una ruta especifica y carga a una tabla Custom              *
 * Control de versiones:                                                                     *
 *      Fecha        Cambio                                   Autor                 Version    *
 *    -----------  ---------------------------------------  --------------------  -------    *
 *  26-SEP-2014     CCT(EAB)        Initial Creation                                                                                         *
 *  15-MAY-2017     IPONCE          Corrección GRATIFICACION                                 *
 *********************************************************************************************/

     TYPE r_columns_pay IS RECORD (
             company    fnd_lookup_values.lookup_code%TYPE
            ,company_name    fnd_lookup_values.meaning%TYPE
            ,bank_account   fnd_lookup_values.description%TYPE
            ,uuid VARCHAR2(50)
            ,num_employee    VARCHAR2(150)
            ,bank   VARCHAR2(50)
            ,payment_date VARCHAR2(15)
            ,periodI VARCHAR2(15)
            ,periodF VARCHAR2(15)
            ,beneficiary   VARCHAR2(300)
            ,rfc    VARCHAR2(20)
            ,beneficiary_rfc VARCHAR (20)
            ,amount NUMBER
            ,currency VARCHAR2(20)
            ,cta_dest VARCHAR2(50)
            ,juego_con varchar2(100)
            ,tipo_nomina varchar2(100)
            ,fecha_pago varchar2(100)
            ,METODO_PAGO VARCHAR2(150)
      );
      g_columns_pay r_columns_pay;

   --global variable
   g_uuid   VARCHAR2 (100);
   g_periodo   VARCHAR2 (100);
   g_directory_source VARCHAR2(100) := 'XXCALV_REPOSITORY_XMLFILES_PAY';
   g_directory_destination VARCHAR2(100) := 'XX_REPOSITORY_XMLFILES_PAY_BK';
   g_retcode NUMBER := 0;

    
    /*iponce 15-MAY-2017*/
   PROCEDURE debug_read_xml(message varchar2)
   IS
   BEGIN
      fnd_file.put_line(fnd_file.log, message);
   END debug_read_xml;

 --Procedure for printing errors in the log or predefined messages for development
   PROCEDURE log_error (p_error IN VARCHAR2)
   IS
   BEGIN

      apps.fnd_file.put_line (apps.fnd_file.LOG, p_error);
      dbms_output.put_line (p_error);
      apps.fnd_file.put_line (apps.fnd_file.output, p_error);
   END log_error;

--Procedure for the print output errors or predefined messages for development
   PROCEDURE write_output (p_output IN VARCHAR2)
   IS
   BEGIN
      apps.fnd_file.put_line (apps.fnd_file.output, p_output);
   END write_output;
--Borrar Archivos
 PROCEDURE borrar_archivo_PR (P_DIRARCH IN VARCHAR2) AS
            LANGUAGE JAVA
                NAME 'XXCALV_DELETE_XML_AR.deleteFile( java.lang.String )';
   --Call class CALV DirList
   PROCEDURE get_dir_list (p_directory IN VARCHAR2)
   AS
      LANGUAGE JAVA
      NAME 'DirList.getList( java.lang.String )';

   --Function get from xmlType all Columns
   FUNCTION get_data_xml (p_data_xml IN XMLTYPE, p_file_name IN VARCHAR2)
      RETURN g_columns_pay%TYPE
   IS
   l_bank VARCHAR2(300);
   l_payment_date VARCHAR2(150);
   l_periodI VARCHAR2(150);
   l_periodF VARCHAR2(150);
   l_num_employee    VARCHAR2(150);

   BEGIN

   SELECT bank
              ,TO_CHAR( TO_DATE(payment_date, 'YYYY/MM/DD'), 'DD/MM/YYYY' ) AS payment_date
              ,TO_CHAR( TO_DATE(payment_dateI, 'YYYY/MM/DD'), 'DD-MM-YY' ) as periodI
              ,TO_CHAR( TO_DATE(payment_dateF, 'YYYY/MM/DD'), 'DD-MM-YY' ) as periodF
              ,uuid
              ,employee_num
              ,beneficiary
              ,rfc
              ,beneficiary_rfc
              ,TO_NUMBER(amount) AS amount
              ,currency
              ,company
    INTO     g_columns_pay.bank
               ,g_columns_pay.payment_date
               ,g_columns_pay.periodI
               ,g_columns_pay.periodF
               ,g_columns_pay.uuid
               ,g_columns_pay.num_employee
               ,g_columns_pay.beneficiary
               ,g_columns_pay.COMPANY_NAME
               ,g_columns_pay.beneficiary_rfc
               ,g_columns_pay.amount
               ,g_columns_pay.currency
               ,g_columns_pay.company_name

        FROM XMLTABLE (XMLNAMESPACES ('http://www.sat.gob.mx/TimbreFiscalDigital' AS "tfd",
                                                          'http://www.sat.gob.mx/cfd/3' AS "cfdi",
                                                          'http://www.sat.gob.mx/nomina' AS  "nomina",
                                                          'http://www.sat.gob.mx/nomina12' AS "nomina12"),
                                                          'cfdi:Comprobante'
                                PASSING ( p_data_xml )
                                COLUMNS
                                                bank VARCHAR (100) PATH '//nomina:Nomina/@Banco'
                                               ,payment_date VARCHAR (100) PATH '//nomina:Nomina/@FechaPago'
                                               ,payment_dateI VARCHAR (100) PATH '//nomina:Nomina/@FechaInicialPago'
                                               ,payment_dateF VARCHAR (100) PATH '//nomina:Nomina/@FechaFinalPago'
                                               ,uuid VARCHAR (100) PATH '//tfd:TimbreFiscalDigital/@UUID'
                                               ,employee_num VARCHAR (100) PATH '//nomina:Nomina/@NumEmpleado'
                                               ,beneficiary VARCHAR (100) PATH '//cfdi:Receptor/@Nombre'
                                               ,company VARCHAR (100) PATH '//cfdi:Emisor/@Nombre'
                                               ,rfc VARCHAR (100) PATH '//cfdi:Emisor/@Rfc'
                                               ,beneficiary_rfc VARCHAR (100) PATH '//cfdi:Receptor/@Rfc'
                                               ,amount VARCHAR (100) PATH '//@Total'
                                               ,currency VARCHAR (100) PATH '//@Moneda'
                                               );

    SELECT bank
              ,TO_CHAR( TO_DATE(payment_date, 'YYYY/MM/DD'), 'DD/MM/YYYY' ) AS payment_date
              ,TO_CHAR( TO_DATE(payment_dateI, 'YYYY/MM/DD'), 'DD-MM-YY' ) as periodI
              ,TO_CHAR( TO_DATE(payment_dateF, 'YYYY/MM/DD'), 'DD-MM-YY' ) as periodF
              ,employee_num
    INTO     l_bank
            ,l_payment_date
            ,l_periodI
            ,l_periodF
            ,l_num_employee
    FROM XMLTABLE (XMLNAMESPACES ('http://www.sat.gob.mx/TimbreFiscalDigital' AS "tfd",
                                                          'http://www.sat.gob.mx/cfd/3' AS "cfdi",
                                                          'http://www.sat.gob.mx/nomina' AS  "nomina",
                                                          'http://www.sat.gob.mx/nomina12' AS "nomina12"),
                                                          'cfdi:Comprobante'
                                PASSING ( p_data_xml )
                                COLUMNS
                                                bank VARCHAR (100) PATH '//nomina12:Nomina/@Banco'
                                               ,payment_date VARCHAR (100) PATH '//nomina12:Nomina/@FechaPago'
                                               ,payment_dateI VARCHAR (100) PATH '//nomina12:Nomina/@FechaInicialPago'
                                               ,payment_dateF VARCHAR (100) PATH '//nomina12:Nomina/@FechaFinalPago'
                                               ,employee_num VARCHAR (100) PATH '//nomina12:Receptor/@NumEmpleado'
                                               );
        g_columns_pay.bank := NVL(g_columns_pay.bank,l_bank);
        g_columns_pay.payment_date := NVL(g_columns_pay.payment_date,l_payment_date);
        g_columns_pay.periodI := NVL(g_columns_pay.periodI,l_periodI);
        g_columns_pay.periodF := NVL(g_columns_pay.periodF ,l_periodF);
        g_columns_pay.num_employee := NVL(g_columns_pay.num_employee,l_num_employee);

--        log_error ('g_columns_pay.bank => ' || to_char(g_columns_pay.bank));
--        log_error ('g_columns_pay.payment_date => ' || to_char(g_columns_pay.payment_date));
--        log_error ('g_columns_pay.periodI => ' || to_char(g_columns_pay.periodI));
--        log_error ('g_columns_pay.periodF => ' || to_char(g_columns_pay.periodF));
--        log_error ('g_columns_pay.uuid => ' || to_char(g_columns_pay.uuid));
--        log_error ('g_columns_pay.num_employee => ' || to_char(g_columns_pay.num_employee));
--        log_error ('g_columns_pay.beneficiary => ' || to_char(g_columns_pay.beneficiary));
--        log_error ('g_columns_pay.COMPANY_NAME => ' || to_char(g_columns_pay.COMPANY_NAME));
--        log_error ('g_columns_pay.beneficiary_rfc => ' || to_char(g_columns_pay.beneficiary_rfc));
--        log_error ('g_columns_pay.amount => ' || to_char(g_columns_pay.amount));
--        log_error ('g_columns_pay.currency => ' || to_char(g_columns_pay.currency));
--        log_error ('g_columns_pay.company_name => ' || to_char(g_columns_pay.company_name));
--        log_error ('l_bank => ' || to_char(l_bank));
--        log_error ('l_payment_date => ' || to_char(l_payment_date));
--        log_error ('l_periodI => ' || to_char(l_periodI));
--        log_error ('l_periodF => ' || to_char(l_periodF));
--        log_error ('l_num_employee => ' || to_char(l_num_employee));

      RETURN g_columns_pay;

   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         log_error ('Not found Data XML file ' || p_file_name);
         RETURN ( NULL);
      WHEN OTHERS
      THEN
         log_error (
            'Error en get_data_xml file ' || p_file_name || ': ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
         RETURN (NULL );
   END get_data_xml;
   --Function get Nemonicos
   FUNCTION get_Nemonicos(p_nemonico IN VARCHAR2,XML XMLType,p_nivel number)
    RETURN VARCHAR2
   IS
   v_value VARCHAR2(300);
   BEGIN
     if p_nivel = 1 then
          SELECT X.NEMONICO into v_value
            FROM
            XMLTABLE (XMLNAMESPACES('http://www.sat.gob.mx/cfd/3' as "cfdi",'http://www.masteredi.com.mx/masfactura2' as "mf"),
                            '$d/cfdi:Comprobante/cfdi:Addenda/mf:MASFACTURA2/mf:NOMINA/mf:NEMONICO' passing XML as "d"
                            COLUMNS
                            nombre            varchar2(100)  PATH '@nombre',
                            NEMONICO          varchar2(100)  PATH '/mf:NEMONICO'
                            ) X
            where X.nombre = p_nemonico;
      elsif p_nivel = 2 then
        SELECT X.NEMONICO into v_value
            FROM
            XMLTABLE (XMLNAMESPACES('http://www.sat.gob.mx/cfd/3' as "cfdi",'http://www.masteredi.com.mx/masfactura2' as "mf"),
                            '$d/cfdi:Comprobante/cfdi:Addenda/mf:MASFACTURA2/mf:ENCAB/mf:NEMONICO' passing XML as "d"
                            COLUMNS
                            nombre            varchar2(100)  PATH '@nombre',
                            NEMONICO          varchar2(100)  PATH '/mf:NEMONICO'
                            ) X
      where X.nombre = p_nemonico;
      END IF;
      RETURN v_value;
    EXCEPTION
    WHEN NO_DATA_FOUND
      THEN
         log_error ('Error no existe ningun valor para el nemonico ' || p_nemonico || ' Not found');
         RETURN '';
      WHEN OTHERS
      THEN
         log_error ('Error al intentar obtener nemonico :' || p_nemonico || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE  );
         RETURN '';
   END get_Nemonicos;
   -- Function get next value sequence
   FUNCTION get_sq_value (p_sequence_name IN VARCHAR2)
      RETURN NUMBER
   IS
      l_value   NUMBER;
   BEGIN
      EXECUTE IMMEDIATE 'SELECT ' || p_sequence_name || '.nextval FROM DUAL'
         INTO l_value;

      RETURN (l_value);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         log_error ('Sequence ' || p_sequence_name || ' Not found');
         RETURN (-1);
      WHEN OTHERS
      THEN
         log_error ('Error in get_sq_value:' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE  );
         RETURN (-1);
   END get_sq_value;

--Copy the XML file to the folder and deletes Bakup origin
PROCEDURE copy_remove_files ( p_file_name IN VARCHAR2)
IS
BEGIN

      /*Utl_File.fcopy (
           src_location  => g_directory_source,
           src_filename  => p_file_name,
           dest_location => g_directory_destination,
           dest_filename => p_file_name );*/

        /*UTL_FILE.fremove(LOCATION=>g_directory_source,
                                      filename=>p_file_name);*/
        borrar_archivo_PR('/var/tmp/CARGAS/CFE/INTERFACE_NOM_O/'||p_file_name);


EXCEPTION
        WHEN OTHERS THEN
                log_error ('Error Function copy_remove_files  ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
END copy_remove_files;

--Gets lookup columns of the corresponding application
FUNCTION get_data_values_pay (p_company_name IN VARCHAR2,
                                              p_rfc IN VARCHAR2,
                                              p_file_name IN VARCHAR2
                                           ) RETURN g_columns_pay%TYPE
IS
    --Variables
l_error VARCHAR2(2000);
BEGIN

SELECT lookup_code
            ,meaning
            ,description
            ,tag
    INTO g_columns_pay.company
            ,g_columns_pay.company_name
            ,g_columns_pay.bank_account
            ,g_columns_pay.rfc
FROM fnd_lookup_values
WHERE lookup_type = 'ABSMEX_COMPANIAS_NOMINA'
    AND LANGUAGE = USERENV('LANG')
    AND meaning = p_company_name
    AND tag = SUBSTR (p_rfc, 1, 13 );

        RETURN (g_columns_pay);

EXCEPTION
    WHEN Too_Many_Rows THEN
        log_error ('Error Function get_data_values_PAY  Existen mas de un Registro: ' || ' ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
        g_columns_pay := NULL;
        RETURN NULL;
    WHEN No_Data_Found THEN
        log_error ( 'Warning,  verifica los datos, el nombre de la compania o el RFC, no existen con el Lookup ABSMEX_COMPANIAS_NOMINA, Compania:' || p_company_name || ', RFC: ' || p_rfc || ' En el Archivo: ' || p_file_name );
        g_columns_pay := NULL;
        RETURN g_columns_pay;
    WHEN Others THEN
        log_error ('Error Function get_data_values_PAY  ' || ' ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
        g_columns_pay := NULL;
        RETURN NULL;
END get_data_values_pay;

--Validates the RFC enter the length valid for the SAT
FUNCTION valid_lenth_rfc (p_rfc IN VARCHAR2 ) RETURN BOOLEAN
IS
    --Variables
    l_length_rfc NUMBER := 0;
BEGIN

SELECT  Length ( p_rfc )
    INTO l_length_rfc
FROM dual;

    IF ( l_length_rfc <= 11 OR l_length_rfc > 13 ) THEN
        log_error ( 'Warning, la longitud de el RFC:  ' || p_rfc || ' no es correcta ' );
        RETURN (FALSE);
    ELSE
        RETURN (TRUE);
    END IF;

EXCEPTION
    WHEN Others THEN
        log_error ('Error Function valid_lenth_rfc  ' || ' ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
        RETURN (FALSE);

END valid_lenth_rfc;

--Validates XML currency vs the currency lookup coins
FUNCTION valid_dabge (p_badge IN VARCHAR2,
                               p_file_name IN VARCHAR2) RETURN BOOLEAN
IS
    --Variables
    l_divisa VARCHAR2(100) := NULL;
BEGIN

SELECT  meaning
    INTO g_columns_pay.currency
FROM fnd_lookup_values
WHERE lookup_type = 'ABSMEX_CATALOGO_MONEDAS_SAT'
    AND LANGUAGE = USERENV('LANG')
    AND UPPER( description ) = UPPER( p_badge );

        RETURN (TRUE);

EXCEPTION
    WHEN Too_Many_Rows THEN
        log_error ('Error Function valid_dabge  Existen mas de un Registro: ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
        RETURN (FALSE);
    WHEN No_Data_Found THEN
        log_error ( 'Warning, La moneda del XML no existe en el Lookup: ABSMEX_CATALOGO_MONEDAS_SAT, moneda XML: ' || p_badge || ' En el Archivo: ' || p_file_name );
        RETURN FALSE;
    WHEN Others THEN
        log_error ('Error Function get_data_values_PAY  ' || ' ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
        RETURN (FALSE);
END valid_dabge;

--Validates that is not beyond the file previously loaded
FUNCTION valid_file_exists ( p_file_name VARCHAR2 )
RETURN BOOLEAN
IS
    --Variables
    l_file_name VARCHAR2(2000) := NULL;
BEGIN
    
     SELECT file_name
        INTO l_file_name
        FROM APPS.XXCALV_UUID_NOM
       WHERE file_name = p_file_name;

    log_error ( 'Warning, Ya se proceso el archivo: ' ||  p_file_name);
    RETURN ( FALSE );

EXCEPTION
    WHEN TOO_MANY_ROWS THEN
        log_error ( 'Warning Function valid_file_exists, existe mas de un archivo con el nombre: ' ||  p_file_name);
        RETURN ( FALSE );
    WHEN NO_DATA_FOUND THEN
        RETURN ( TRUE );
    WHEN Others THEN
        log_error ( 'Error Function valid_file_exists  ' || ' ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
        RETURN ( FALSE );

END valid_file_exists;
--Valida Fecha
FUNCTION valid_Fechas ( p_jego_con IN VARCHAR2,
                                       p_file_name IN VARCHAR2,p_date IN VARCHAR2,p_num_emp in varchar2) RETURN BOOLEAN
IS
    --Variables
    l_count NUMBER:=0;
BEGIN
    SELECT
        COUNT(1)
        INTO  l_count
    FROM pay_payrolls_f pro ,
        pay_payroll_actions pac1
        ,PAY_ASSIGNMENT_ACTIONS_V paa
        WHERE 1= 1
        AND pac1.ACTION_TYPE = 'P'
        AND pac1.payroll_action_id = paa.PAYROLL_ACTION_ID
        AND pro.PAYROLL_ID = pac1.PAYROLL_ID
        AND REGEXP_SUBSTR(paa.ASSIGNMENT_NUMBER,'[^-]+', 1,1) = p_num_emp
        AND pay_payroll_actions_pkg.v_name (pac1.payroll_action_id ,pac1.action_type ,pac1.consolidation_set_id ,pac1.display_run_number ,pac1.element_set_id ,pac1.assignment_set_id ,pac1.effective_date) = p_jego_con
        ;
     IF l_count > 0 THEN
        RETURN (TRUE);
     ELSE
        RETURN (FALSE);
     END IF;
EXCEPTION
WHEN Others THEN
   RETURN (FALSE);
END valid_Fechas;
FUNCTION valid_Fechas2 ( p_date IN VARCHAR2,p_num_emp IN VARCHAR2) RETURN BOOLEAN
IS
    --Variables
    l_count NUMBER:=0;
BEGIN
      SELECT
        COUNT(REGEXP_SUBSTR(paa.ASSIGNMENT_NUMBER,'[^-]+', 1,1))numero_empleado
        INTO l_count
    FROM pay_payrolls_f pro ,
        pay_payroll_actions pac1
        ,PAY_ASSIGNMENT_ACTIONS_V paa
        WHERE 1= 1
        AND pac1.ACTION_TYPE = 'Q'
        AND pac1.payroll_action_id = paa.PAYROLL_ACTION_ID
        AND pro.PAYROLL_ID = pac1.PAYROLL_ID
        AND REGEXP_SUBSTR(paa.ASSIGNMENT_NUMBER,'[^-]+', 1,1) = p_num_emp
        group by
        REGEXP_SUBSTR(paa.ASSIGNMENT_NUMBER,'[^-]+', 1,1);
     IF g_columns_pay.periodI=g_columns_pay.periodF AND g_columns_pay.periodI = p_date AND l_count>0 THEN
        RETURN (FALSE);
     ELSE
        RETURN (TRUE);
     END IF;
EXCEPTION
WHEN Others THEN
   RETURN (FALSE);
END valid_Fechas2;
--Valida num empleado
  FUNCTION valid_num_empleado ( p_jego_con IN VARCHAR2,
                                       p_file_name IN VARCHAR2,p_date IN VARCHAR2,p_num_emp in varchar2) RETURN BOOLEAN
IS
    --Variables
    l_count NUMBER:=0;
BEGIN
    SELECT
        COUNT(1)
        INTO  l_count
        FROM pay_payrolls_f pro ,
        pay_payroll_actions pac1
        ,PAY_ASSIGNMENT_ACTIONS_V paa
        WHERE 1= 1
        AND (TO_DATE(pac1.START_DATE,'DD/MM/YYYY') = TO_DATE(p_date,'DD/MM/YYYY') OR TO_DATE(paa.EFFECTIVE_DATE,'DD/MM/YYYY') = TO_DATE(p_date,'DD/MM/YYYY'))
        AND pac1.ACTION_TYPE = 'P'
        AND pac1.payroll_action_id = paa.PAYROLL_ACTION_ID
        AND pro.PAYROLL_ID = pac1.PAYROLL_ID
        AND REGEXP_SUBSTR(paa.ASSIGNMENT_NUMBER,'[^-]+', 1,1) = p_num_emp
        ;
     IF l_count > 0 THEN
        RETURN (TRUE);
     ELSE
        RETURN (FALSE);
     END IF;
EXCEPTION
WHEN Others THEN
   RETURN (FALSE);
END valid_num_empleado;
--Valida tipo de Nomina
FUNCTION valid_tipo_nom_lookup ( p_tipo_nomina IN VARCHAR2,
                                       p_file_name IN VARCHAR2 ) RETURN BOOLEAN
IS
    --Variables
    l_tipo_nomina VARCHAR2(100) :=p_tipo_nomina;
BEGIN
SELECT  meaning
    INTO g_columns_pay.tipo_nomina
FROM fnd_lookup_values
WHERE lookup_type = 'XXCALV_TIPOS_NOMINA'
    AND LANGUAGE = USERENV('LANG')
    AND description = p_tipo_nomina;

        RETURN (TRUE);

EXCEPTION
    WHEN Too_Many_Rows THEN
        -- log_error (l_tipo_nomina);
        g_columns_pay.tipo_nomina := l_tipo_nomina;
        RETURN (FALSE);
    WHEN No_Data_Found THEN

        RETURN FALSE;
    WHEN Others THEN
        --log_error ('Error Function valid_JuegoCon_lookup  ' || ' ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
        RETURN (FALSE);
END valid_tipo_nom_lookup;
--valida quick pay
FUNCTION valid_quick ( p_jego_con IN VARCHAR2,
                                       p_file_name IN VARCHAR2,p_date IN VARCHAR2,p_num_emp in varchar2,p_tipo_nom in varchar2 ) RETURN BOOLEAN
IS
    l_num_empleado VARCHAR2(300);
    l_tipo_nomina varchar(300);
BEGIN
 IF p_jego_con = 'FINIQUITOS' OR p_jego_con = 'PTU' OR p_jego_con = 'GRATIFICACION' THEN
 
    log_error (' valid_quick : ' ||
               ' p_jego_con  => ' || to_char(p_jego_con ) ||
               ' p_file_name  => ' || to_char(p_file_name ) ||
               ' p_date  => ' || to_char(p_date ) ||
               ' p_num_emp  => ' || to_char(p_num_emp ) ||
               ' p_tipo_nom => ' || to_char(p_tipo_nom));
 
 SELECT
        REGEXP_SUBSTR(paa.ASSIGNMENT_NUMBER,'[^-]+', 1,1) numero_empleado,
        pro.PAYROLL_NAME
        INTO l_num_empleado,
        l_tipo_nomina
    FROM pay_payrolls_f pro ,
        pay_payroll_actions pac1
        ,PAY_ASSIGNMENT_ACTIONS_V paa
        WHERE 1= 1
        AND TO_DATE(paa.EFFECTIVE_DATE,'DD/MM/RRRR') = (CASE
                                                            WHEN p_jego_con = 'FINIQUITOS'
                                                            THEN TO_DATE(paa.EFFECTIVE_DATE,'DD/MM/RRRR')
                                                            ELSE TO_DATE(p_date,'DD/MM/RRRR')
                                                        END)
        AND pac1.ACTION_TYPE = 'Q'
        AND pac1.payroll_action_id = paa.PAYROLL_ACTION_ID
        AND pro.PAYROLL_ID = pac1.PAYROLL_ID
        AND REGEXP_SUBSTR(paa.ASSIGNMENT_NUMBER,'[^-]+', 1,1) = p_num_emp
        group by
        REGEXP_SUBSTR(paa.ASSIGNMENT_NUMBER,'[^-]+', 1,1),
        pro.PAYROLL_NAME;
        IF p_num_emp <> l_num_empleado THEN
            log_error ('Error E01 en el Número de Empleado  '||p_num_emp ||' en el archivo '||p_file_name);
            RETURN (FALSE);
         ELSIF p_tipo_nom <> l_tipo_nomina THEN
         IF p_tipo_nom = 'EJEC' AND (l_tipo_nomina = '02_QUIN - EJEC CONFIANZA' OR l_tipo_nomina = '11_QUIN - PACQ CONFIANZA') THEN
            RETURN (TRUE);
         ELSE
         log_error ('Error en el Tipo de Nómina '||p_tipo_nom||' en el archivo '||p_file_name);
            RETURN (FALSE);
         END IF;
        END IF;
        RETURN (TRUE);
    ELSE
        IF p_num_emp <> l_num_empleado THEN
            log_error ('Error E02 en el Número de Empleado  '||p_num_emp ||' en el archivo '||p_file_name);
            RETURN (FALSE);
         ELSIF p_tipo_nom <> l_tipo_nomina THEN
         IF p_tipo_nom = 'EJEC' AND (l_tipo_nomina = '02_QUIN - EJEC CONFIANZA' OR l_tipo_nomina = '11_QUIN - PACQ CONFIANZA') THEN
            RETURN (TRUE);
         ELSE
         log_error ('Error en el Tipo de Nómina '||p_tipo_nom||' en el archivo '||p_file_name);
            RETURN (FALSE);
         END IF;
        END IF;
        RETURN (FALSE);
    END IF;
EXCEPTION
    WHEN Too_Many_Rows THEN
        log_error ('Error Function valid_quick de Consolidacio  Existen mas de un Registro: ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
        RETURN (FALSE);
    WHEN No_Data_Found THEN
          IF valid_Fechas2(p_date,p_num_emp ) THEN
            log_error ('Error en el Periodo en el archivo '||p_file_name);
          ELSE
            log_error ('Error E03 en el Número de Empleado  '||p_num_emp ||' en el archivo '||p_file_name);
          END IF;
        RETURN FALSE;
    WHEN Others THEN
        log_error ('Error Function valid quick  ' || ' ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
        RETURN (FALSE);
END valid_quick;
--Valida juego de consolidacion
FUNCTION valid_JuegoCon_lookup ( p_jego_con IN VARCHAR2,
                                       p_file_name IN VARCHAR2 ) RETURN BOOLEAN
IS
    --Variables
BEGIN

SELECT  description
    INTO g_columns_pay.juego_con
FROM fnd_lookup_values
WHERE lookup_type = 'XXCALV_JUEGO_CONSOLIDACION'
    AND LANGUAGE = USERENV('LANG')
    AND meaning = p_jego_con;

        RETURN (TRUE);

EXCEPTION
    WHEN Too_Many_Rows THEN
        --log_error ('Error Function valid_JuegoCon_lookup de Consolidacio  Existen mas de un Registro: ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
        RETURN (FALSE);
    WHEN No_Data_Found THEN
       -- log_error ( 'Warning, El juego de consolidacion en del XML no existe en el Lookup: XXCALV_JUEGO_CONSOLIDACION, Juego de Consolidacion XML: ' || p_jego_con || ' En el Archivo: ' || p_file_name );
        RETURN FALSE;
    WHEN Others THEN
        --log_error ('Error Function valid_JuegoCon_lookup  ' || ' ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
        RETURN (FALSE);
END valid_JuegoCon_lookup;

FUNCTION valid_JuegoCon ( p_jego_con IN VARCHAR2,
                                       p_file_name IN VARCHAR2,p_date IN VARCHAR2,p_beneficiario IN VARCHAR2,p_num_emp in varchar2,p_tipo_nom in varchar2 ) RETURN BOOLEAN
IS
    --Variables
    l_juego_con varchar2(300):='';
    l_date DATE;
    l_num_empleado VARCHAR2(300):='';
    l_tipo_nomina varchar(300):='';
BEGIN

--    log_error ('p_jego_con => ' || to_char(p_jego_con) ||
--               'p_file_name => ' || to_char(p_file_name) ||
--               'p_date => ' || to_char(p_date) ||
--               'p_beneficiario => ' || to_char(p_beneficiario) ||
--               'p_num_emp => ' || to_char(p_num_emp) ||
--               'p_tipo_nom => ' || to_char(p_tipo_nom));

    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_LANGUAGE = ''Latin American Spanish''';
    SELECT
        pay_payroll_actions_pkg.v_name (pac1.payroll_action_id ,pac1.action_type ,pac1.consolidation_set_id ,pac1.display_run_number ,pac1.element_set_id ,pac1.assignment_set_id ,pac1.effective_date) name,
        REGEXP_SUBSTR(paa.ASSIGNMENT_NUMBER,'[^-]+', 1,1) numero_empleado,
        pro.PAYROLL_NAME
        INTO  l_juego_con,
        l_num_empleado,
        l_tipo_nomina
    FROM pay_payrolls_f pro ,
        pay_payroll_actions pac1
        ,PAY_ASSIGNMENT_ACTIONS_V paa
        WHERE 1= 1
        AND (TO_DATE(pac1.START_DATE,'DD/MM/YYYY') = TO_DATE(p_date,'DD/MM/YYYY') OR TO_DATE(paa.EFFECTIVE_DATE,'DD/MM/YYYY') = TO_DATE(p_date,'DD/MM/YYYY'))
        AND pac1.ACTION_TYPE = 'P'
        AND pac1.payroll_action_id = paa.PAYROLL_ACTION_ID
        AND pro.PAYROLL_ID = pac1.PAYROLL_ID
        AND REGEXP_SUBSTR(paa.ASSIGNMENT_NUMBER,'[^-]+', 1,1) = p_num_emp
        AND pay_payroll_actions_pkg.v_name (pac1.payroll_action_id ,pac1.action_type ,pac1.consolidation_set_id ,pac1.display_run_number ,pac1.element_set_id ,pac1.assignment_set_id ,pac1.effective_date) = p_jego_con
        ;
        
        
        IF p_jego_con <> 'FINIQUITOS' AND p_jego_con <> 'PTU' AND p_jego_con <> 'GRATIFICACION'
        AND p_num_emp <> l_num_empleado THEN
            log_error ('Error E04 en el Número de Empleado  '||p_num_emp ||' en el archivo '||p_file_name);
            RETURN (FALSE);
        END IF;
        IF p_jego_con <> 'FINIQUITOS' AND p_jego_con <> 'PTU' AND p_jego_con <> 'GRATIFICACION'
        AND p_tipo_nom <> l_tipo_nomina THEN
         IF p_tipo_nom = 'EJEC' AND (l_tipo_nomina = '02_QUIN - EJEC CONFIANZA' OR l_tipo_nomina = '11_QUIN - PACQ CONFIANZA') THEN
            RETURN (TRUE);
         ELSE
         log_error ('Error en el Tipo de Nómina '||p_tipo_nom||' en el archivo '||p_file_name);
            RETURN (FALSE);
         END IF;
        END IF;
        RETURN (TRUE);
EXCEPTION
    WHEN Too_Many_Rows THEN
        log_error ('Error Function valid_JuegoCon de Consolidacio  Existen mas de un Registro: ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
        RETURN (FALSE);
    WHEN No_Data_Found THEN
     

        IF p_jego_con <> 'FINIQUITOS' AND p_jego_con <> 'PTU' AND p_jego_con <> 'GRATIFICACION' THEN
           IF valid_num_empleado ( p_jego_con, p_file_name ,p_date ,p_num_emp ) THEN
            log_error ('Error en el Juego De Consolidación '||p_jego_con||' en el archivo '||p_file_name);
           ELSIF valid_Fechas ( p_jego_con, p_file_name ,p_date ,p_num_emp ) THEN
            log_error ('Error en el Periodo en el archivo '||p_file_name);
           ELSE
            log_error ('Error E05 en el Número de Empleado  '||p_num_emp ||' en el archivo '||p_file_name);
           END IF;
           -- RETURN (FALSE);
        END IF;
        --log_error ( 'Error el Juego de Consolidación  ' || p_jego_con || ' es incorrecto En el Archivo: ' || p_file_name ||TO_DATE(p_date,'DD/MM/YYYY')||p_beneficiario);
        RETURN valid_quick( p_jego_con,p_file_name ,p_date ,p_num_emp ,p_tipo_nom );
    WHEN Others THEN
        log_error ('Error Function valid_JuegoCon  ' || ' ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
        RETURN (FALSE);
END valid_JuegoCon;

--Valida la divisa del XML vs la moneda del lookup de monedas
FUNCTION valid_CtaDest ( p_employee_num IN VARCHAR2,
                                       p_file_name IN VARCHAR2 ) RETURN BOOLEAN
IS
    --Variables
BEGIN

SELECT  tag
    INTO g_columns_pay.cta_dest
FROM fnd_lookup_values
WHERE lookup_type = 'ABSMEX_CUENTAS_EMPLEADOS'
    AND LANGUAGE = USERENV('LANG')
    AND meaning = p_employee_num;

        RETURN (TRUE);

EXCEPTION
    WHEN Too_Many_Rows THEN
        log_error ('Error Function valid_CtaDest  Existen mas de un Registro: ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
        RETURN (FALSE);
    WHEN No_Data_Found THEN
        log_error ( 'Warning, El numero del empleado del XML no existe en el Lookup: ABSMEX_CUENTAS_EMPLEADOS, no. Empleado XML: ' || p_employee_num || ' En el Archivo: ' || p_file_name );
        RETURN FALSE;
    WHEN Others THEN
        log_error ('Error Function valid_CtaDest  ' || ' ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
        RETURN (FALSE);
END valid_CtaDest;

   -- Procedure insert data into Table XXCALV_UUID_NOM from xml File
   PROCEDURE insert_xml (p_file_name IN VARCHAR2,
                                       p_data_xml IN XMLTYPE )
   IS
   --Variables
      l_id_sequence   NUMBER := 0;
      l_customer_trx_id   VARCHAR2(50);
      v_lookup_juego boolean;
      v_lookuo_tipo_nomina boolean;
   BEGIN

       IF valid_file_exists( p_file_name ) THEN
       

          g_columns_pay := get_data_xml ( p_data_xml, p_file_name ) ;
          g_columns_pay.juego_con := get_Nemonicos('NOM_DESCRI',p_data_xml,1);
          
          
          g_columns_pay.METODO_PAGO := get_Nemonicos('METPAG',p_data_xml,2);
          g_columns_pay.tipo_nomina := get_Nemonicos('NOM_CVENOM',p_data_xml,1);
          v_lookup_juego := valid_JuegoCon_lookup ( g_columns_pay.juego_con,
                                       p_file_name  );
          v_lookuo_tipo_nomina := valid_tipo_nom_lookup(g_columns_pay.tipo_nomina, p_file_name);
         /* g_columns_pay := get_data_values_pay ( g_columns_pay.company_name
                                                                      ,g_columns_pay.rfc
                                                                      ,p_file_name );*/
                                                                      

            IF  ( g_columns_pay.company_name IS NOT NULL
            AND valid_JuegoCon(g_columns_pay.JUEGO_CON,p_file_name,g_columns_pay.periodI,g_columns_pay.BENEFICIARY,g_columns_pay.NUM_EMPLOYEE,g_columns_pay.TIPO_NOMINA)
          /*  AND valid_dabge ( g_columns_pay.currency, p_file_name )
            AND valid_lenth_rfc ( g_columns_pay.beneficiary_rfc)
            AND valid_CtaDest ( g_columns_pay.num_employee, p_file_name )*/ ) THEN

                fnd_file.put_line(fnd_file.log, '***************Valido');
                l_id_sequence := get_sq_value (p_sequence_name => 'APPS.XXCALV_XMLFILES_CTRL_SEQ');

                    --     validate sequence value and UUID
                  IF (l_id_sequence > 0 ) THEN


                    INSERT INTO APPS.XXCALV_UUID_NOM
                      VALUES (l_id_sequence,
                                    g_columns_pay.COMPANY_NAME,
                                    g_columns_pay.bank_account,
                                    null,
                                    g_columns_pay.cta_dest,
                                    g_columns_pay.bank,
                                    g_columns_pay.payment_date,
                                    g_columns_pay.uuid,
                                    g_columns_pay.num_employee,
                                    g_columns_pay.beneficiary,
--                                    g_columns_PAY.Rfc,
                                    g_columns_pay.beneficiary_rfc,
                                    g_columns_pay.amount,
                                    g_columns_pay.currency,
                                    g_columns_pay.periodI||' '||g_columns_pay.periodF,
                                    g_columns_pay.juego_con,
                                    REGEXP_SUBSTR(g_columns_pay.metodo_pago,'[^,;]+', 1,1), -- FJQR 27/09/2016
                                    p_file_name,
                                    p_data_xml,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    apps.fnd_global.user_id,
                                    SYSDATE,
                                    apps.fnd_global.user_id,
                                    SYSDATE,
                                    apps.fnd_global.user_id,
                                    fnd_global.conc_request_id);
                     COMMIT;
                    --Copy the directory backup file and deletes the source directory
                    copy_remove_files( p_file_name );
                  END IF;
            END IF;
       END IF;--valid exist File name Table custom
   EXCEPTION
      WHEN OTHERS
      THEN
         log_error ('Error de duplicidad en xml '||p_file_name);
   END insert_xml;

--Funcion convierte un CLOB a BLOB
FUNCTION convert_blob (p_clob CLOB) RETURN BLOB
AS
 l_blob          blob;
 l_dest_offset   integer := 1;
 l_source_offset integer := 1;
 l_lang_context  integer := DBMS_LOB.DEFAULT_LANG_CTX;
 l_warning       integer := DBMS_LOB.WARN_INCONVERTIBLE_CHAR;
BEGIN

  DBMS_LOB.CREATETEMPORARY(l_blob, TRUE);
  DBMS_LOB.CONVERTTOBLOB
  (
   dest_lob    =>l_blob,
   src_clob    =>p_clob,
   amount      =>DBMS_LOB.LOBMAXSIZE,
   dest_offset =>l_dest_offset,
   src_offset  =>l_source_offset,
   blob_csid   =>DBMS_LOB.DEFAULT_CSID,
   lang_context=>l_lang_context,
   warning     =>l_warning
  );
  RETURN l_blob;
EXCEPTION
      WHEN OTHERS THEN

      log_error ('Error Function  Convert_blob: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
      RETURN NULL;

NULL;
END convert_blob;

--XML is improving after a bad writing
FUNCTION convert_xml_error(p_xml_clob IN CLOB, p_file_name IN VARCHAR2) RETURN XMLTYPE
IS

l_xml_text Varchar2(4000);
l_xml_text2 Varchar2(4000);
l_xml_text3 Varchar2(4000);
l_xml_text4 Varchar2(4000);
l_file_data BLOB;
l_xml XMLTYPE;
BEGIN
        l_file_data := convert_blob( p_xml_clob );

        l_xml_text :=  UTL_RAW.cast_to_varchar2(dbms_lob.substr(l_file_data,2000,1)) || UTL_RAW.cast_to_varchar2(dbms_lob.substr(l_file_data,2000,2001));
        l_xml_text2 := UTL_RAW.cast_to_varchar2(dbms_lob.substr(l_file_data,2000,4001))  || UTL_RAW.cast_to_varchar2(dbms_lob.substr(l_file_data,2000,6001));
        l_xml_text3 := UTL_RAW.cast_to_varchar2(dbms_lob.substr(l_file_data,2000,8001))  || UTL_RAW.cast_to_varchar2(dbms_lob.substr(l_file_data,2000,10001));
        l_xml_text4 := UTL_RAW.cast_to_varchar2(dbms_lob.substr(l_file_data,2000,12001))  || UTL_RAW.cast_to_varchar2(dbms_lob.substr(l_file_data,2000,14001));

        SELECT REPLACE ( l_xml_text,
                    Substr(l_xml_text, 1,
                        instr ( l_xml_text, '<' ) -1
                    )
                    , '')
            INTO l_xml_text
        FROM dual;

        l_xml := XMLTYPE.createxml (  l_xml_text || l_xml_text2 || l_xml_text3 || l_xml_text4  );

        RETURN l_xml;

EXCEPTION
      WHEN OTHERS THEN
    --No hace nada, así la siguiente excepcion la captura
    NULL;

END convert_xml_error;

--Cuenta el numero de registros cargados con el parametro Reques_id
FUNCTION count_rows_load
RETURN NUMBER
IS
l_trx_num NUMBER;
BEGIN

SELECT Count( 1 )
    INTO l_trx_num
FROM APPS.XXCALV_UUID_NOM
WHERE request_id = fnd_global.conc_request_id;

    RETURN ( l_trx_num );

EXCEPTION
    WHEN TOO_MANY_ROWS THEN
                log_error ('Error Function count_rows_load existen mas de una transaccion con:  ' || l_trx_num || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
                RETURN ( 0 );
            WHEN NO_DATA_FOUND THEN
                RETURN ( 0 );
            WHEN OTHERS THEN
                log_error ('Error Function count_rows_load  ' || SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
                RETURN ( 0 );
END count_rows_load;

   -- Procedure Read file from directory and move to dest_directory
   PROCEDURE read_xml
   IS
      --cursor get name files
      CURSOR c_dir_list
      IS
           SELECT filename
             FROM APPS.XXCALV_NOM_DIR_J
            WHERE UPPER (filename) LIKE '%.XML'
         ORDER BY filename;

      l_xmlclob       CLOB;
      l_xmlfile       BFILE;
      l_xml           XMLTYPE;
      l_value         VARCHAR2 (250);

      l_src_offset    NUMBER := 1;
      l_dest_offset   NUMBER := 1;
      l_lang_ctx      NUMBER := DBMS_LOB.DEFAULT_LANG_CTX;
      l_warning       INTEGER;
      l_file_name VARCHAR2(100);
      l_count_rows NUMBER := 0;
      l_contador_vacios NUMBER :=0;
   BEGIN

      

      FOR i IN c_dir_list
      LOOP
         --reset variables
         l_xmlclob := NULL;
         l_xmlfile := NULL;
         l_src_offset := 1;
         l_dest_offset := 1;
         l_file_name := i.filename;
         
         PAC_CFDI_FUNCTIONS_PKG.CFDI_LOGGING(l_file_name, 'READ FILE : ' || l_file_name);

         l_count_rows := l_count_rows + 1;
         --find file
         l_xmlfile := BFILENAME ( g_directory_source, i.filename );     --p_file_name);
         BEGIN
         l_xml :=XMLTYPE(l_xmlfile,NLS_CHARSET_ID('AL32UTF8'));
         EXCEPTION
          WHEN  OTHERS THEN
           log_error ('Error de archivo vacio');
           l_contador_vacios := l_contador_vacios +1;
           g_retcode :=  1;
         END;
         /*
         --fetch xml data into clob
         DBMS_LOB.CREATETEMPORARY (l_xmlclob, TRUE);
         DBMS_LOB.FILEOPEN (l_xmlfile, DBMS_LOB.FILE_READONLY);
         DBMS_LOB.LOADCLOBFROMFILE (l_xmlclob,
                                    l_xmlfile,
                                    DBMS_LOB.LOBMAXSIZE,
                                    l_src_offset,
                                    l_dest_offset,
                                    DBMS_LOB.DEFAULT_CSID,
                                    l_lang_ctx,
                                    l_warning);

         --    change format clob to xmltype
         BEGIN
            l_xml := XMLTYPE.createxml (l_xmlclob);
         EXCEPTION WHEN others THEN

            --BEGIN
                --Extrae el XML del servidor
                --l_xml := convert_xml_error( l_xmlclob, i.filename );

            --EXCEPTION WHEN Others THEN
                l_xml := NULL;
                log_error ('Tiene Errores de escritura el XML el Archivo: ' || l_file_name||sqlerrm );

            --END;
         END;

         DBMS_LOB.FILECLOSEALL ();
         DBMS_LOB.FREETEMPORARY (l_xmlclob);
        */
         --    call procedure
         --===================================================================================
        IF (l_xml IS NOT NULL AND l_contador_vacios = 0) THEN

         insert_xml (p_file_name => i.filename
                         ,p_data_xml => l_xml );
                         
        ELSE
           IF l_contador_vacios = 0 THEN
            log_error ('No hay el XML  ' || i.filename||sqlerrm);
           END IF;
        END IF;

      END LOOP;

      --Log
      log_error ('  ');
      log_error (' Numero de registros Leidos: ' || l_count_rows );
      log_error (' Numero de registros Cargados : ' || count_rows_load() );
      log_error (' Numero de registros sin Cargar : ' || ( l_count_rows - count_rows_load() ) );
      log_error (' ');

   EXCEPTION
      WHEN OTHERS
      THEN
         log_error ('Error al Leer el Archivo:' || l_file_name || ' ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
         ROLLBACK;
   END read_xml;

   --Function get path
   FUNCTION get_path (p_directory_name IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_path   VARCHAR2 (100);
   BEGIN
      BEGIN
         SELECT TRIM (directory_path)
           INTO l_path
           FROM all_directories
          WHERE UPPER (directory_name) = UPPER (p_directory_name);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            log_error ('No Data Found :' || p_directory_name);
            l_path := NULL;
         WHEN TOO_MANY_ROWS
         THEN
            log_error ('Too Many Rows:' || p_directory_name);
            l_path := NULL;
         WHEN OTHERS
         THEN
            log_error ('Error:' || SQLCODE);
            l_path := NULL;
      END;

      RETURN (l_path);
   EXCEPTION
      WHEN OTHERS
      THEN
         log_error ('Error in get_path function:' || SQLERRM);
         ROLLBACK;
         RETURN (NULL);
   END;

    --The main proceedings
   PROCEDURE MAIN (errbuf                  OUT VARCHAR2,
                               retcode                 OUT NUMBER,
                               p_source_directory   IN     VARCHAR2)
   IS
      l_src_path         VARCHAR2 (250);
   BEGIN
   
      
      -- get source directory path
      write_output('Begin... ');
      l_src_path := get_path ( g_directory_source );
      write_output('l_src_path : ' || g_directory_source );

     -- g_periodo := p_periodo;
      log_error ('==============================================================================');
      log_error ('                   Carga de Archivos UUID');
      log_error ('==============================================================================');
      log_error (' ');

      -- insert files name from directory path in tempory table
      get_dir_list( l_src_path );
      -- read XML file
      read_xml ( );
      retcode := g_retcode;

   EXCEPTION
      WHEN OTHERS
      THEN
         log_error ('Error in Procedure MAIN :' || SQLERRM );
         ROLLBACK;
   END MAIN;

END XXCALV_READ_XMLFILE_PAY_PKG;
/
