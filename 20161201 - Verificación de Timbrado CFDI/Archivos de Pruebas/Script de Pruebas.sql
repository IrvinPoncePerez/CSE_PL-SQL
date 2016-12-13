/*****************************************************
 *      Consulta de objetos JAVA invalidos.
 ****************************************************/

SELECT *
  FROM ALL_OBJECTS
 WHERE OBJECT_TYPE LIKE '%JAVA%'
--   AND OBJECT_NAME LIKE '%ARRAY%'
   AND STATUS = 'INVALID'
--   AND TO_DATE(CREATED, 'DD/MM/RRRR') = TO_DATE(SYSDATE, 'DD/MM/RRRR') 
 ORDER BY CREATED DESC;
 

/*****************************************************
 *      Creación de objeto tipo tabla.
 ****************************************************/
CREATE OR REPLACE TYPE DIRECTORIES_LIST AS TABLE OF VARCHAR2(500);


 
/*****************************************************
 *      Creación de FUNCTION y PROCEDURE
 ****************************************************/
CREATE OR REPLACE FUNCTION APPS.TEST_CONNECTION(
    P_DIRECTORY VARCHAR2
  )
  RETURN VARCHAR2
  AS LANGUAGE JAVA NAME 'CFDI_Verification.test_Connection(java.lang.String) return java.lang.String';
  


CREATE OR REPLACE PROCEDURE APPS.list_directories (dir IN VARCHAR2)
AS
LANGUAGE JAVA
NAME 'CFDI_Verification.list_directories(java.lang.String)';



CREATE OR REPLACE FUNCTION APPS.GET_DIRECTORIES(p_directory VARCHAR2)
       RETURN DIRECTORIES_LIST
    AS
       LANGUAGE JAVA NAME 'CFDI_Verification.getDirectories(java.lang.String) return oracle.sql.ARRAY';
  
  




/*****************************************************
 *      Ejecución de función TEST_CONNECTION.
 ****************************************************/  
DECLARE
    P_RESULT        VARCHAR2(100);
BEGIN
    SELECT APPS.TEST_CONNECTION('Calvario_Servicios')
    INTO P_RESULT
    FROM DUAL;
    
    DBMS_OUTPUT.PUT_LINE(P_RESULT);
END;


/*****************************************************
 *      Ejecución de procedimiento LIST_DIRECTORIES
 ****************************************************/
BEGIN
    DBMS_JAVA.SET_OUTPUT(10000);
    LIST_DIRECTORIES('Calvario_Servicios');
END;




/*****************************************************
 *      Ejecución de función GET_DIRECTORIES.
 ****************************************************/
DECLARE
    DIRECTORIES   DIRECTORIES_LIST;  
BEGIN

    DBMS_OUTPUT.PUT_LINE('***********************************');

    DIRECTORIES := GET_DIRECTORIES('Calvario_Servicios');
    
    FOR var_index IN 1..DIRECTORIES.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(DIRECTORIES(var_index));
    END LOOP;
    
END;





