CREATE OR REPLACE PACKAGE APPS.XXCALV_READ_XMLFILEAR_PKG
AS
/*********************************************************************************************
 * Nombre : XX_READ_XMLFILE_PKG.pkb          *
 * Creador : Condor Consulting Team (RASM)           *
 * Version : 1.1                                                                            *
 * Fecha creacion: 26-SEP-2014                           *
 * Ultima Modificacion: 28/01/2015                                                         *
 * Descripcion: Lee los archivos XML de una ruta especifica y actualiza el UUID              *
 * Control de versiones:                                                                     *
 *    Fecha        Cambio                                   Autor                 Version    *
 *    -----------  ---------------------------------------  --------------------  -------    *
 *  26-SEP-2014     CCT(RASM)        Initial Creation                                                                                         *
 *  26-SEP-2014     CCT(SEJR)        Version 1.1                                                                                         *
 *********************************************************************************************/
   CURSOR lookup_cur IS
    SELECT 'TRX_DATE' AS lookup_code, 'cfdi:Comprobante/@Fecha' AS tag
    FROM DUAL
    UNION
    SELECT 'TRX_NUMBER', 'cfdi:Comprobante/@Folio'
    FROM DUAL;

   TYPE lookup_tbl IS TABLE OF lookup_cur%ROWTYPE
                         INDEX BY BINARY_INTEGER;

   TYPE XXCALV_FILES_DIR IS TABLE OF XXCALV_ELECT_DIR_LIST%ROWTYPE INDEX BY BINARY_INTEGER;
   v_files_dir  XXCALV_FILES_DIR;


   --global variables
   g_uuid   VARCHAR2 (100);
   g_cont_file     NUMBER := 0; --count files valid
   g_cont_ok     NUMBER := 0; --count files valid
   g_cont_error NUMBER := 0; --count files with error

   FUNCTION get_path (p_directory_name IN VARCHAR2) RETURN VARCHAR2;

--   PROCEDURE borrar_archivo_PR (P_DIRARCH IN VARCHAR2);

   PROCEDURE MAIN (errbuf                  OUT VARCHAR2,
                   retcode                 OUT NUMBER,
                   p_application_id     IN     NUMBER,
                   p_source_directory   IN     VARCHAR2,
                   p_dest_directory     IN     VARCHAR2
                   --p_flex_name          IN     VARCHAR2,
                   --p_flex_context       IN     VARCHAR2,
                  -- p_flex_column        IN     VARCHAR2
                    );
END XXCALV_READ_XMLFILEAR_PKG;
/
