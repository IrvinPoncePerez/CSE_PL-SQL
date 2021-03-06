CREATE OR REPLACE PACKAGE APPS.PAC_RFC_SAT_PKG AS

    PROCEDURE   UPDATE_RFC(
        P_ERRBUF    OUT NOCOPY  VARCHAR2,
        P_RETCODE   OUT NOCOPY  VARCHAR2,
        P_EMPLOYEE_NUMBER       VARCHAR2,
        P_RFC                   VARCHAR2);
        
    PROCEDURE   BULK_UPDATE_RFC(
        P_ERRBUF    OUT NOCOPY  VARCHAR2,
        P_RETCODE   OUT NOCOPY  VARCHAR2,
        P_FILE_NAME             VARCHAR2);

END PAC_RFC_SAT_PKG;