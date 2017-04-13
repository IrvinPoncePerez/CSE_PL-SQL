CREATE TABLE APPS.CONFIGURATION_CEDIS_TB
(
    OU_NAME             VARCHAR2(1000), -- Código de Unidad Operativa
    API_NAME            VARCHAR2(1000), -- Nombre de la API usada
    REC_CODE            VARCHAR2(1000), -- Tipo de Registro : PARAMETER / RESULT
    PARAMETER_NAME      VARCHAR2(1000), 
    PARAMETER_VALUE     VARCHAR2(1000),
    RESULT_NAME         VARCHAR2(1000),
    RESULT_VALUE        VARCHAR2(1000)
);