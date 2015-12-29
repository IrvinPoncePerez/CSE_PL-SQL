CREATE TABLE ATET_SAVINGS_BANK
(
	SAVING_BANK_ID                   NUMBER NOT NULL,
	YEAR                             NUMBER,
	OPENING_DATE                     DATE,
    REGISTRATION_DATE                DATE,
    TERMINATION_DATE                 DATE,
    PROFIT_SHARING_DATE              DATE,
    NEXT_LOAN_NUMBER                 NUMBER,
	NEXT_CHECK_NUMBER                NUMBER,
	NEXT_CHARGED_ENDORSE_NUMBER      NUMBER,
	INITIAL_AMOUNT                   NUMBER,
	FINAL_AMOUNT                     NUMBER,
	INTEREST_RATE_SHARING            NUMBER,
    EFFECTIVE_START_DATE             DATE,
    EFFECTIVE_END_DATE               DATE,    
    SAVING_BANK_STATUS               VARCHAR2(50),
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
	LAST_UPDATED_BY                   NUMBER
);


ALTER TABLE ATET_SAVINGS_BANK
	ADD CONSTRAINT UQ_ATET_SAVINGS_BANK UNIQUE (SAVING_BANK_ID)
 USING INDEX ;


CREATE SEQUENCE ATET_SAVINGS_BANK_SEQ
  START WITH 1
  NOCYCLE
  NOCACHE
  NOORDER;
  
  
CREATE OR REPLACE TRIGGER ATET_SAVINGS_BANK_TGR
BEFORE INSERT
   ON ATET_SAVINGS_BANK
   FOR EACH ROW
DECLARE

   var_next_id  NUMBER;

BEGIN

    SELECT ATET_SAVINGS_BANK_SEQ.NEXTVAL
      INTO var_next_id
      FROM dual;        
      
    :NEW.SAVING_BANK_ID := var_next_id;

END;