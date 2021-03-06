CREATE TABLE ATET_SB_TABLE_VALUES
(
    VALUE_ID                NUMBER          NOT NULL,
    TABLE_ID                NUMBER          NOT NULL,
    LOWER_BOUND             NUMBER,
    UPPER_BOUND             NUMBER,
    LOWER_VALUE             NUMBER,
    UPPER_VALUE             NUMBER,
    UNITS                   VARCHAR2(50),
    EFFECTIVE_START_DATE    DATE,
    EFFECTIVE_END_DATE      DATE,
    ATTRIBUTE1              NUMBER,
    ATTRIBUTE2              NUMBER,
    ATTRIBUTE3              NUMBER,
    ATTRIBUTE4              NUMBER,
    ATTRIBUTE5              NUMBER,
    ATTRIBUTE6              VARCHAR2(250),
    ATTRIBUTE7              VARCHAR2(250),
    ATTRIBUTE8              VARCHAR2(250),
    ATTRIBUTE9              VARCHAR2(250),
    ATTRIBUTE10             VARCHAR2(250),
    CREATION_DATE           DATE,
    CREATED_BY              NUMBER,
    LAST_UPDATE_DATE        DATE,
    LAST_UPDATED_BY         NUMBER
);


ALTER TABLE ATET_SB_TABLE_VALUES
    ADD CONSTRAINT UQ_ATET_SB_TABLE_VALUES UNIQUE (VALUE_ID)
 USING INDEX ;

ALTER TABLE ATET_SB_TABLE_VALUES
    ADD CONSTRAINT FK_TABLEVALUES_TABLES
        FOREIGN KEY (TABLE_ID)
        REFERENCES ATET_SB_TABLES(TABLE_ID);

CREATE SEQUENCE ATET_SB_TABLE_VALUES_SEQ
  START WITH 1
  NOCYCLE
  NOCACHE
  NOORDER;
  
  
CREATE OR REPLACE TRIGGER ATET_SB_TABLE_VALUES_TGR
BEFORE INSERT
   ON ATET_SB_TABLE_VALUES
   FOR EACH ROW
DECLARE

   var_next_id  NUMBER;

BEGIN

    SELECT ATET_SB_TABLE_VALUES_SEQ.NEXTVAL
      INTO var_next_id
      FROM dual;        
      
    :NEW.VALUE_ID := var_next_id;

END;