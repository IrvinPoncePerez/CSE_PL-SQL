CREATE OR REPLACE PACKAGE APPS.XXCALV_READ_XMLFILE_PAY_PKG
AUTHID CURRENT_USER
AS
/*********************************************************************************************
 * Nombre : XXCALV_READ_XMLFILE_PAY_PKG.pks          *
 * Creador : Condor Consulting Team (FJQR)           *
 * Version : 1.0                                                                            *
 * Fecha creacion: 07-JUL-2016                           *
 * Ultima Modificacion:                                                          *
 * Descripcion: Lee los archivos XML de una ruta especifica y actualiza el UUID              *
 * Control de versiones:                                                                     *
 *    Fecha        Cambio                                   Autor                 Version    *
 *    -----------  ---------------------------------------  --------------------  -------    *
 *  26-SEP-2014     CCT(RASM)        Initial Creation                                           *
 *  15-MAY-2017     IPONCE          Corrección Gratificación                                 *
 *********************************************************************************************/

PROCEDURE get_dir_list (p_directory IN VARCHAR2);

   PROCEDURE MAIN (errbuf                  OUT VARCHAR2,
                               retcode                 OUT NUMBER,
                               p_source_directory   IN     VARCHAR2);
END XXCALV_READ_XMLFILE_PAY_PKG;
/
