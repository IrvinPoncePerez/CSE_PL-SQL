DROP TABLE PAC_VISITS_CONTROL_TB;
COMMIT;

CREATE TABLE PAC_VISITS_CONTROL_TB (
    VISITOR_DAY_ID                      NUMBER          NOT NULL,
    VISITOR_NAME                        VARCHAR2(100),
    VISITOR_COMPANY                     VARCHAR2(100),
    IDENTIFICATION_TYPE                 VARCHAR2(100),
    OTHER_IDENTIFICATION_NAME           VARCHAR2(50),
    REASON_VISIT                        VARCHAR2(100),
    ASSOCIATE_PERSON_ID                 NUMBER,
    ASSOCIATE_DEPARTMENT_ID             NUMBER,
    REGISTRATION_TIME_STAMP             VARCHAR2(30)    NOT NULL,
    REGISTRATION_DATE                   VARCHAR2(30),
    REGISTRATION_TIME                   VARCHAR2(30),
    CHECK_IN                            VARCHAR2(30),
    CHECK_OUT                           VARCHAR2(30),
    VISITOR_LENGTH_STAY                 VARCHAR2(100),
    ATTRIBUTE1                          VARCHAR2(350),
    ATTRIBUTE2                          VARCHAR2(350),
    ATTRIBUTE3                          VARCHAR2(350),
    ATTRIBUTE4                          VARCHAR2(350),
    ATTRIBUTE5                          VARCHAR2(350),
    ATTRIBUTE6                          VARCHAR2(350),
    ATTRIBUTE7                          VARCHAR2(350),
    ATTRIBUTE8                          VARCHAR2(350),
    ATTRIBUTE9                          VARCHAR2(350),
    CREATED_BY                          NUMBER(15),
    CREATION_DATE                       DATE,
    LAST_UPDATED_BY                     NUMBER(15),
    LAST_UPDATE_DATE                    DATE,
    LAST_UPDATE_LOGIN                   NUMBER(15)
);
PAC_TIMECLOCK_CHECKS