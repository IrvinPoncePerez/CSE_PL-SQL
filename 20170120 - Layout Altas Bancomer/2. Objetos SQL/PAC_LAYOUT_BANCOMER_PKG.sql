CREATE OR REPLACE PACKAGE APPS.PAC_LAYOUT_BANCOMER_PKG 
IS

    PROCEDURE   LAYOUT_BANCOMER
                (
                    P_ERRBUF         OUT NOCOPY VARCHAR2,
                    P_RETCODE        OUT NOCOPY VARCHAR2,
                    P_START_DATE                VARCHAR2,
                    P_END_DATE                  VARCHAR2
                );

END PAC_LAYOUT_BANCOMER_PKG;