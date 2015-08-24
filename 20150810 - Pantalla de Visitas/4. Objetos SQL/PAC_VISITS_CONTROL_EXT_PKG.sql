CREATE OR REPLACE PACKAGE PAC_VISITS_CONTROL_EXT_PKG IS

    FUNCTION   IS_CHECK_EXISTS(
                    FOLIO       VARCHAR2,   
                    DATETIME    VARCHAR2)   RETURN BOOLEAN;
    
    FUNCTION   IS_CREATE_CHECK(
                    FOLIO       VARCHAR2,   
                    DATETIME    VARCHAR2)   RETURN BOOLEAN;
    
    FUNCTION   GET_VISITOR_LENGTH_STAY(
                    FOLIO       VARCHAR2)   RETURN VARCHAR2;
    
    PROCEDURE  PRINT_LABEL(
                    ERRBUF                  OUT VARCHAR2,       
                    RETCODE                 OUT VARCHAR2,
                    P_FOLIO                 VARCHAR2,
                    P_VISITS_NAME           VARCHAR2,
                    P_VISITS_COMPANY        VARCHAR2,
                    P_ASSOCIATE_PERSON      VARCHAR2,
                    P_ASSOCIATE_DEPARTMENT  VARCHAR2);    
                    
END PAC_VISITS_CONTROL_EXT_PKG;