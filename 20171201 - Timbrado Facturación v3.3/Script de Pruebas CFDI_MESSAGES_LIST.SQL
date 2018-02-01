


/*****************************************************************
 *      Sentencia para eliminar un objeto JAVA SOURCE
 *****************************************************************/
DROP JAVA SOURCE "CFDI";


/*****************************************************
 *      Creación de FUNCTION y PROCEDURE
 ****************************************************/
CREATE OR REPLACE FUNCTION APPS.GET_CFDI_MESSAGES
    (
        P_RFCEMI    VARCHAR2,
        P_RFCREC    VARCHAR2,
        P_SERFOL    VARCHAR2,
        P_NUMFOL    VARCHAR2
    )
        RETURN VARCHAR2
    AS
        LANGUAGE JAVA NAME 'CFDI_MESSAGES.getMessages(java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String';

CREATE OR REPLACE FUNCTION APPS.GET_CFDI_UUID
    (
        P_RFCEMI    VARCHAR2,
        P_RFCREC    VARCHAR2,
        P_SERFOL    VARCHAR2,
        P_NUMFOL    VARCHAR2,
        P_EMIANIO   VARCHAR2,
        P_EMIMES    VARCHAR2,
        P_EMIDIA    VARCHAR2
    )
        RETURN VARCHAR2
    AS 
        LANGUAGE JAVA NAME 'CFDI_MESSAGES.getUUID(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String';



/*****************************************************
 *      Ejecución de función GET_CFDI_MESSAGES.
 ****************************************************/
DECLARE
    MESSAGES   VARCHAR2(1000);  
    
    CURSOR DETAIL_LIST 
    IS
    SELECT ROWINDEX,
           RFCEMI,
           RFCREC,
           SERFOL,
           NUMFOL,
           EVE_DATE,
           EVE_TITLE,
           EVE_DESC
      FROM PAC_MASTEREDI_LOG_TB PML;
    
BEGIN


    MESSAGES := GET_CFDI_UUID
                    (
                        P_RFCEMI => 'PAC941215E50',
                        P_RFCREC => 'VABR5501064M3',
                        P_SERFOL => 'FASC',
                        P_NUMFOL => '25976',
                        P_EMIANIO=> '2017',
                        P_EMIMES => '12',
                        P_EMIDIA => '28'
                    );
    
    DBMS_OUTPUT.PUT_LINE(MESSAGES);
    
    MESSAGES := GET_CFDI_MESSAGES
                    (
                        P_RFCEMI => 'PAC941215E50',
                        P_RFCREC => 'VABR5501064M3',
                        P_SERFOL => 'FASC',
                        P_NUMFOL => '25976'
                    );
    
    DBMS_OUTPUT.PUT_LINE(MESSAGES);
    
    FOR DETAIL IN DETAIL_LIST LOOP
        DBMS_OUTPUT.PUT_LINE(DETAIL.EVE_DESC);
    END LOOP;
    
    COMMIT;
    
END;

