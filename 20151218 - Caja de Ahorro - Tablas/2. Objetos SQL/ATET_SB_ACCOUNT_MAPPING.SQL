CREATE TABLE ATET_SB_ACCOUNT_MAPPING
(
    ACCOUNT_MAPPING_ID               NUMBER,
    SEGMENT1                         VARCHAR2(50),
    SEGMENT2                         VARCHAR2(50),
    SEGMENT3                         VARCHAR2(50),
    SEGMENT4                         VARCHAR2(50),
    SEGMENT5                         VARCHAR2(50),
    SEGMENT6                         VARCHAR2(50),
    CONCATENED_SEGMENT_1             VARCHAR2(200),
    CONCATENED_SEGMENT_2             VARCHAR2(200),
    DESCRIPTION                      VARCHAR2(2000),
    ATTRIBUTE1                       NUMBER,
    ATTRIBUTE2                       NUMBER,
    ATTRIBUTE3                       NUMBER,
    ATTRIBUTE4                       NUMBER,
    ATTRIBUTE5                       NUMBER,
    ATTRIBUTE6                       VARCHAR2(250),
    ATTRIBUTE7                       VARCHAR2(250),
    ATTRIBUTE8                       VARCHAR2(250),
    ATTRIBUTE9                       VARCHAR2(250),
    ATTRIBUTE10                      VARCHAR2(250),
    ATTRIBUTE11                      VARCHAR2(250),
    ATTRIBUTE12                      VARCHAR2(250),
    ATTRIBUTE13                      VARCHAR2(250),
	ATTRIBUTE14                      VARCHAR2(250),
	ATTRIBUTE15                      VARCHAR2(250),
	CREATION_DATE                    DATE,
	CREATED_BY                       NUMBER,
	LAST_UPDATE_DATE                 DATE,
	LAST_UPDATED_BY                  NUMBER
);


ALTER TABLE ATET_SB_ACCOUNT_MAPPING
	ADD CONSTRAINT UQ_ATET_SB_ACCOUNT_MAPPING UNIQUE (ACCOUNT_MAPPING_ID)
 USING INDEX ;

CREATE SEQUENCE ATET_SB_ACCOUNT_MAPPING_SEQ
  START WITH 100
  INCREMENT BY 100
  NOCYCLE
  NOCACHE
  NOORDER;
  
  
CREATE OR REPLACE TRIGGER ATET_SB_ACCOUNT_MAPPING_TGR
BEFORE INSERT
   ON ATET_SB_ACCOUNT_MAPPING
   FOR EACH ROW
DECLARE

   var_next_id  NUMBER;

BEGIN

    SELECT ATET_SB_ACCOUNT_MAPPING_SEQ.NEXTVAL
      INTO var_next_id
      FROM dual;        
      
    :NEW.ACCOUNT_MAPPING_ID := var_next_id;

END;