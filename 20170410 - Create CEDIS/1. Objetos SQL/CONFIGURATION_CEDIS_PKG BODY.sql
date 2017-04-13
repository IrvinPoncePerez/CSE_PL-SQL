CREATE OR REPLACE PACKAGE BODY APPS.CONFIGURATION_CEDIS_PKG IS

    PROCEDURE   SET_PARAMETER
                (
                    P_API_NAME          CONFIGURATION_CEDIS_TB.API_NAME%TYPE,
                    P_PARAMETER_NAME    CONFIGURATION_CEDIS_TB.PARAMETER_NAME%TYPE,
                    P_PARAMETER_VALUE   CONFIGURATION_CEDIS_TB.PARAMETER_VALUE%TYPE
                )
    IS
    BEGIN
        
        INSERT 
          INTO CONFIGURATION_CEDIS_TB
            (
                OU_NAME,
                API_NAME,
                REC_CODE,
                PARAMETER_NAME,
                PARAMETER_VALUE
            )
        VALUES
            (
                GET_OU_NAME,
                UPPER(P_API_NAME),
                'PARAMETER',
                UPPER(P_PARAMETER_NAME),
                P_PARAMETER_VALUE
            );
            
        COMMIT;
    
    END SET_PARAMETER;
                
    PROCEDURE   SET_RESULT
                (
                    P_API_NAME          CONFIGURATION_CEDIS_TB.API_NAME%TYPE,
                    P_RESULT_NAME       CONFIGURATION_CEDIS_TB.RESULT_NAME%TYPE,
                    P_RESULT_VALUE      CONFIGURATION_CEDIS_TB.RESULT_VALUE%TYPE
                )
    IS
    BEGIN
    
        INSERT 
          INTO CONFIGURATION_CEDIS_TB
            (
                OU_NAME,
                API_NAME,
                REC_CODE,
                RESULT_NAME,
                RESULT_VALUE
            )
        VALUES
            (
                GET_OU_NAME,
                UPPER(P_API_NAME),
                'RESULT',
                UPPER(P_RESULT_NAME),
                P_RESULT_VALUE
            );
            
        COMMIT;    
    
    END SET_RESULT;
                
    PROCEDURE   INITIALIZE_CEDIS
                (
                    P_OU_NAME               CONFIGURATION_CEDIS_TB.OU_NAME%TYPE,
                    P_LOCATION_CODE         CONFIGURATION_CEDIS_TB.PARAMETER_VALUE%TYPE,
                    P_DESCRIPTION           CONFIGURATION_CEDIS_TB.PARAMETER_VALUE%TYPE
                )
    IS
    BEGIN
        
        INSERT
          INTO CONFIGURATION_CEDIS_TB
            (OU_NAME)
        VALUES
            (P_OU_NAME);
            
        SET_PARAMETER('CREATE_LOCATION', 'p_location_code', P_LOCATION_CODE); 
        SET_PARAMETER('CREATE_LOCATION', 'p_description', P_DESCRIPTION);
        
        
    END INITIALIZE_CEDIS;
    
    PROCEDURE   FINALIZE_CEDIS
    IS
    BEGIN
        
        DELETE 
          FROM CONFIGURATION_CEDIS_TB  CCT
         WHERE 1 = 1
           AND CCT.OU_NAME = GET_OU_NAME;
           
        COMMIT;
    
    END FINALIZE_CEDIS;
    
    FUNCTION    GET_OU_NAME
      RETURN    CONFIGURATION_CEDIS_TB.OU_NAME%TYPE
    IS
      VAR_OU_NAME   CONFIGURATION_CEDIS_TB.OU_NAME%TYPE;   
    BEGIN
        
        SELECT DISTINCT
               CCT.OU_NAME
          INTO VAR_OU_NAME
          FROM CONFIGURATION_CEDIS_TB   CCT;
                
        RETURN VAR_OU_NAME;
    
    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            dbms_output.PUT_LINE('Existe más de un CEDIS en las especificaciones de configuración.');
        WHEN NO_DATA_FOUND THEN
            dbms_output.PUT_LINE('No se ha inicializado la configuración de CEDIS.');
    END GET_OU_NAME;
      
    FUNCTION    GET_PARAMETER_VALUE
                (
                    P_API_NAME          CONFIGURATION_CEDIS_TB.API_NAME%TYPE,
                    P_PARAMETER_NAME    CONFIGURATION_CEDIS_TB.PARAMETER_NAME%TYPE
                )
      RETURN    CONFIGURATION_CEDIS_TB.PARAMETER_VALUE%TYPE
    IS
        VAR_PARAMETER_VALUE     CONFIGURATION_CEDIS_TB.PARAMETER_VALUE%TYPE;
    BEGIN
        
        SELECT CCT.PARAMETER_VALUE
          INTO VAR_PARAMETER_VALUE
          FROM CONFIGURATION_CEDIS_TB   CCT
         WHERE 1 = 1
           AND CCT.OU_NAME = GET_OU_NAME
           AND CCT.API_NAME = UPPER(P_API_NAME)
           AND CCT.PARAMETER_NAME = UPPER(P_PARAMETER_NAME)
           AND CCT.REC_CODE = 'PARAMETER';
           
        RETURN VAR_PARAMETER_VALUE;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.PUT_LINE('No existe el parámetro consultado.');
    END GET_PARAMETER_VALUE;
      
    FUNCTION    GET_RESULT_VALUE
                (
                    P_API_NAME          CONFIGURATION_CEDIS_TB.API_NAME%TYPE,
                    P_RESULT_NAME       CONFIGURATION_CEDIS_TB.RESULT_NAME%TYPE
                )
      RETURN    CONFIGURATION_CEDIS_TB.RESULT_VALUE%TYPE
    IS
        VAR_RESULT_VALUE     CONFIGURATION_CEDIS_TB.RESULT_VALUE%TYPE;
    BEGIN
        
        SELECT CCT.RESULT_VALUE
          INTO VAR_RESULT_VALUE
          FROM CONFIGURATION_CEDIS_TB   CCT
         WHERE 1 = 1
           AND CCT.OU_NAME = GET_OU_NAME
           AND CCT.API_NAME = UPPER(P_API_NAME)
           AND CCT.RESULT_NAME = UPPER(P_RESULT_NAME)
           AND CCT.REC_CODE = 'RESULT';
           
        RETURN VAR_RESULT_VALUE;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.PUT_LINE('No existe el resultado consultado.');
    END GET_RESULT_VALUE;

END CONFIGURATION_CEDIS_PKG;