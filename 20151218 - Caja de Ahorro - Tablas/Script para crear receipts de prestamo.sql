ALTER SESSION SET CURRENT_SCHEMA=APPS;
   
   SELECT DISTINCT
               ASLT.*
          FROM ATET_SB_LOANS_TRANSACTIONS   ASLT,
               ATET_XLA_LINES               AXL,
               ATET_XLA_HEADERS             AXH
         WHERE 1 = 1
           AND ASLT.PERIOD_NAME IN ('LIQUIDACION', 'PAGO ANTICIPADO')
           AND EXTRACT(YEAR FROM ASLT.CREATION_DATE) = 2017
           AND ASLT.ATTRIBUTE1 IS NOT NULL
           AND AXL.SOURCE_ID = (CASE
                                    WHEN ASLT.PERIOD_NAME = 'LIQUIDACION' THEN
                                        ASLT.LOAN_TRANSACTION_ID
                                    WHEN ASLT.PERIOD_NAME = 'PAGO ANTICIPADO' THEN
                                        ASLT.LOAN_ID 
                                END)
           AND AXL.SOURCE_LINK_TABLE = (CASE
                                            WHEN ASLT.PERIOD_NAME = 'LIQUIDACION' THEN
                                                'ATET_SB_LOANS_TRANSACTIONS'
                                            WHEN ASLT.PERIOD_NAME = 'PAGO ANTICIPADO' THEN
                                                'ATET_SB_LOANS'
                                        END)
           AND ASLT.CREDIT_AMOUNT = AXL.ACCOUNTED_CR 
           AND AXL.CODE_COMBINATION_ID IN (634160, 634161)
--           AND ASLT.CREATION_DATE = AXH.CREATION_DATE
           AND AXH.HEADER_ID = AXL.HEADER_ID
           AND AXH.HEADER_ID NOT IN (SELECT HEADER_ID
                                       FROM ATET_XLA_LINES  AXL_SAV
                                      WHERE 1 = 1 
                                        AND AXL_SAV.ACCOUNTING_CLASS_CODE IN ('SAVING_RETIREMENT'));

DECLARE
    CURSOR RECEIPTS IS
        SELECT DISTINCT
               ASLT.*
          FROM ATET_SB_LOANS_TRANSACTIONS   ASLT,
               ATET_XLA_LINES               AXL,
               ATET_XLA_HEADERS             AXH
         WHERE 1 = 1
           AND ASLT.PERIOD_NAME IN ('LIQUIDACION', 'PAGO ANTICIPADO')
           AND EXTRACT(YEAR FROM ASLT.CREATION_DATE) = 2017
           AND ASLT.ATTRIBUTE1 IS NOT NULL
           AND AXL.SOURCE_ID = (CASE
                                    WHEN ASLT.PERIOD_NAME = 'LIQUIDACION' THEN
                                        ASLT.LOAN_TRANSACTION_ID
                                    WHEN ASLT.PERIOD_NAME = 'PAGO ANTICIPADO' THEN
                                        ASLT.LOAN_ID 
                                END)
           AND AXL.SOURCE_LINK_TABLE = (CASE
                                            WHEN ASLT.PERIOD_NAME = 'LIQUIDACION' THEN
                                                'ATET_SB_LOANS_TRANSACTIONS'
                                            WHEN ASLT.PERIOD_NAME = 'PAGO ANTICIPADO' THEN
                                                'ATET_SB_LOANS'
                                        END)
           AND ASLT.CREDIT_AMOUNT = AXL.ACCOUNTED_CR 
           AND AXL.CODE_COMBINATION_ID IN (634160, 634161)
           AND AXH.HEADER_ID = AXL.HEADER_ID
           AND AXH.HEADER_ID NOT IN (SELECT HEADER_ID
                                       FROM ATET_XLA_LINES  AXL_SAV
                                      WHERE 1 = 1 
                                        AND AXL_SAV.ACCOUNTING_CLASS_CODE IN ('SAVING_RETIREMENT'));
                                        
    var_loan_receipt_seq            NUMBER := 0;
    var_receipts_all_seq            NUMBER;
        
    var_banks_account_id            NUMBER;
    var_banks_account_name          VARCHAR2(100);
    var_banks_account_num           VARCHAR2(100);
    var_banks_currency_code         VARCHAR2(13);
    
    var_employee_number             VARCHAR2(100);
    var_employee_full_name          VARCHAR2(1000);
                         
BEGIN

    FOR RECEIPT IN RECEIPTS LOOP
    
            SELECT ATET_SB_RECEIPT_NUMBER_SEQ.NEXTVAL
              INTO var_loan_receipt_seq 
              FROM DUAL;                         
                                 
                                 
            SELECT ATET_SB_RECEIPTS_ALL_SEQ.NEXTVAL
              INTO var_receipts_all_seq
              FROM DUAL;                 
                                
                                  
            SELECT ASM.EMPLOYEE_NUMBER,
                   ASM.EMPLOYEE_FULL_NAME
              INTO var_employee_number,
                   var_employee_full_name
              FROM ATET_SB_MEMBERS  ASM
             WHERE ASM.MEMBER_ID = RECEIPT.MEMBER_ID;    
                                 
                                          
             SELECT BANK_ACCOUNT_ID,
                    BANK_ACCOUNT_NAME,
                    BANK_ACCOUNT_NUM,
                    CURRENCY_CODE
               INTO var_banks_account_id,
                    var_banks_account_name,
                    var_banks_account_num,
                    var_banks_currency_code
               FROM ATET_SB_BANK_ACCOUNTS
              WHERE 1 = 1
                AND ROWNUM = 1;
                
                
             INSERT 
              INTO ATET_SB_RECEIPTS_ALL (RECEIPT_ID,
                                         RECEIPT_NUMBER,
                                         RECEIPT_DATE,
                                         STATUS_LOOKUP_CODE,
                                         RECEIPT_TYPE_FLAG,
                                         MEMBER_ID,
                                         MEMBER_NAME,
                                         CURRENCY_CODE,
                                         AMOUNT,
                                         COMMENTS,
                                         BANK_ACCOUNT_ID,
                                         BANK_ACCOUNT_NUM,
                                         BANK_ACCOUNT_NAME,
                                         DEPOSIT_DATE,
                                         ATTRIBUTE1,
                                         ATTRIBUTE2,
                                         ATTRIBUTE6,
                                         REQUEST_ID,
                                         REFERENCE_TYPE,
                                         REFERENCE_ID,
                                         LAST_UPDATED_BY,
                                         LAST_UPDATE_DATE,
                                         CREATED_BY,
                                         CREATION_DATE)
                                 VALUES (var_receipts_all_seq,
                                         var_loan_receipt_seq,
                                         TO_DATE(SYSDATE, 'DD/MM/RRRR'),
                                         'CREATED',
                                         'LOANS',
                                         RECEIPT.MEMBER_ID,
                                         var_employee_full_name,
                                         var_banks_currency_code,
                                         RECEIPT.CREDIT_AMOUNT,
                                         var_employee_number || '|' || var_employee_full_name || '|' || RECEIPT.CREDIT_AMOUNT || '|' || TO_CHAR(RECEIPT.CREATION_DATE, 'DD/MM/RRRR'),
                                         var_banks_account_id,
                                         var_banks_account_num,
                                         var_banks_account_name,
                                         TO_DATE(RECEIPT.CREATION_DATE, 'DD/MM/RRRR'),
                                         -1,
                                         RECEIPT.ATTRIBUTE1,
                                         'AJUSTE',
                                         RECEIPT.REQUEST_ID,
                                         'ATET_SB_LOANS_TRANSACTIONS',
                                         RECEIPT.LOAN_TRANSACTION_ID,
                                         RECEIPT.CREATED_BY,
                                         TO_DATE(RECEIPT.CREATION_DATE),
                                         RECEIPT.CREATED_BY,
                                         SYSDATE);

    END LOOP;


END;


ROLLBACK;



SELECT *
  FROM ATET_SB_RECEIPTS_ALL
 where 1 =1
   and extract(year from receipt_date) = 2017
 ORDER
    BY  RECEIPT_DATE,
        TO_NUMBER(RECEIPT_NUMBER);
        
        
UPDATE ATET_SB_RECEIPTS_ALL
   SET ATTRIBUTE7 = ATTRIBUTE6
 WHERE ATTRIBUTE6 = 'AJUSTE';
 
UPDATE ATET_SB_RECEIPTS_ALL
   SET ATTRIBUTE6 = NULL
 WHERE ATTRIBUTE6 = 'AJUSTE';
 
                                
       
