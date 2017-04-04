CREATE OR REPLACE PROCEDURE APPS.ATET_LOAN_CHECK_REPLACEMENT (errbuf       OUT NOCOPY VARCHAR2
                                                             ,retcode      OUT NOCOPY VARCHAR2
                                                             ,P_CHECK_ID IN NUMBER)
IS
      add_layout_boolean BOOLEAN;
      v_request_id NUMBER;
      waiting     BOOLEAN;
      phase      VARCHAR2(80 BYTE);
      status     VARCHAR2(80 BYTE);
      dev_phase  VARCHAR2(80 BYTE);
      dev_status VARCHAR2(80 BYTE);
      V_message    VARCHAR2(4000 BYTE);
      LN_BANK_ACCOUNT_ID         NUMBER;
      LC_BANK_ACCOUNT_NAME       VARCHAR2 (150);
      LC_BANK_ACCOUNT_NUM        VARCHAR2 (150);
      LC_BANK_NAME               VARCHAR2 (150);
      LC_CURRENCY_CODE           VARCHAR2 (150);
      LN_MEMBER_ID               NUMBER;
      LC_EMPLOYEE_FULL_NAME      VARCHAR2 (300);
      LN_LOAN_AMOUNT             NUMBER;
      LN_CHECK_AMOUNT             NUMBER;
      LN_LOAN_TOTAL_AMOUNT       NUMBER;
      LN_LOAN_INTEREST_AMOUNT    NUMBER;
      LN_LOAN_ID                 NUMBER;
      LN_REFINANCE_AMOUNT        NUMBER;
      LN_LOAN_NUMBER             NUMBER;
      LD_TRANSACTION_DATE        DATE;
      LN_CHECK_NUMBER            NUMBER;
      LN_CHECK_ID                NUMBER;
      V_CHECK_ID                 NUMBER;
      V_CHECK_NUMBER             NUMBER;
      P_ENTITY_CODE              VARCHAR2 (150);
      P_EVENT_TYPE_CODE          VARCHAR2 (150);
      P_BATCH_NAME               VARCHAR2 (150);
      P_JOURNAL_NAME             VARCHAR (150);
      LC_NOT_REC_SAV_CODE_COMB   NUMBER;
      LC_UNE_INT_CODE_COMB       NUMBER;
      LC_BANK_CODE_COMB          NUMBER;
      P_HEADER_ID                NUMBER;
      ROW_NUMBER                 NUMBER := 1;
      INPUT_STRING               VARCHAR2 (200);
      OUTPUT_STRING              VARCHAR2 (200);
      ENCRYPTED_RAW              RAW (2000);   -- stores encrypted binary text
      DECRYPTED_RAW              RAW (2000);   -- stores decrypted binary text
      NUM_KEY_BYTES              NUMBER := 256 / 8; -- key length 256 bits (32 bytes)
      KEY_BYTES_RAW              RAW (32);    -- stores 256-bit encryption key
      ENCRYPTION_TYPE            PLS_INTEGER
         :=                                           -- total encryption type
           DBMS_CRYPTO.ENCRYPT_AES256
            + DBMS_CRYPTO.CHAIN_CBC
            + DBMS_CRYPTO.PAD_PKCS5;
   BEGIN
      BEGIN
         SELECT BANK_ACCOUNT_ID,
                BANK_ACCOUNT_NAME,
                BANK_ACCOUNT_NUM,
                BANK_NAME,
                CURRENCY_CODE
           INTO LN_BANK_ACCOUNT_ID,
                LC_BANK_ACCOUNT_NAME,
                LC_BANK_ACCOUNT_NUM,
                LC_BANK_NAME,
                LC_CURRENCY_CODE
           FROM ATET_SB_BANK_ACCOUNTS;
      EXCEPTION
         WHEN OTHERS
         THEN
            FND_FILE.PUT_LINE (FND_FILE.LOG,'Error al buscar la cuenta bantaria');
            DBMS_OUTPUT.PUT_LINE ('Error al buscar la cuenta bantaria');
            RAISE;
      END;

      BEGIN
         BEGIN
            SELECT MEMBER_ID,
                   LOAN_ID,
                   LOAN_NUMBER,
                   LOAN_TOTAL_AMOUNT,
                   LOAN_INTEREST_AMOUNT,
                   LOAN_AMOUNT,
                   TRANSACTION_DATE
              INTO LN_MEMBER_ID,
                   LN_LOAN_ID,
                   LN_LOAN_NUMBER,
                   LN_LOAN_TOTAL_AMOUNT,
                   LN_LOAN_INTEREST_AMOUNT,
                   LN_LOAN_AMOUNT,
                   LD_TRANSACTION_DATE
              FROM ATET_SB_LOANS ASL
             WHERE LOAN_ID = (SELECT LOAN_ID
                                FROM ATET_LOAN_PAYMENTS_ALL ALPA
                               WHERE ALPA.CHECK_ID = P_CHECK_ID);
         EXCEPTION WHEN OTHERS THEN
               FND_FILE.PUT_LINE (FND_FILE.LOG,'Error al buscar préstamo.');
               DBMS_OUTPUT.PUT_LINE ('Error al buscar préstamo.');
               RAISE;
         END;

         BEGIN
            SELECT CHECK_ID, CHECK_NUMBER, AMOUNT
              INTO V_CHECK_ID, V_CHECK_NUMBER, LN_CHECK_AMOUNT
              FROM ATET_SB_CHECKS_ALL ASCA
             WHERE CHECK_ID = P_CHECK_ID
               AND STATUS_LOOKUP_CODE = 'CREATED';
         EXCEPTION WHEN OTHERS THEN
               FND_FILE.PUT_LINE (FND_FILE.LOG,'Error al buscar cheque.');
               DBMS_OUTPUT.PUT_LINE ('Error al buscar cheque.');
               RAISE;
         END;

         BEGIN
            SELECT EMPLOYEE_FULL_NAME
              INTO LC_EMPLOYEE_FULL_NAME
              FROM ATET_SB_MEMBERS
             WHERE MEMBER_ID = LN_MEMBER_ID;
         EXCEPTION
            WHEN OTHERS
            THEN
               FND_FILE.PUT_LINE (FND_FILE.LOG,'Error al buscar el miembro');
               DBMS_OUTPUT.PUT_LINE ('Error al buscar el miembro');
               RAISE;
         END;

         BEGIN
            SELECT ATET_SB_CHECKS_ALL_SEQ.NEXTVAL 
              INTO LN_CHECK_ID 
              FROM DUAL;

            SELECT ATET_SB_CHECK_NUMBER_SEQ.NEXTVAL
              INTO LN_CHECK_NUMBER
              FROM DUAL;

            INPUT_STRING :=   TO_CHAR (LN_CHECK_AMOUNT)  || ','
                            || LN_CHECK_ID              || ','
                            || LN_CHECK_NUMBER          || ','
                            || LN_MEMBER_ID             || ','
                            || FND_GLOBAL.USER_ID       || ','
                            || TO_CHAR (CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF');

            DBMS_OUTPUT.PUT_LINE ('Original string: ' || input_string);
            key_bytes_raw := DBMS_CRYPTO.RANDOMBYTES (num_key_bytes);
            encrypted_raw := DBMS_CRYPTO.ENCRYPT (src   => UTL_I18N.STRING_TO_RAW (input_string, 'AL32UTF8'), typ   => encryption_type, KEY   => key_bytes_raw);
            
            -- The encrypted value "encrypted_raw" can be used here
            decrypted_raw := DBMS_CRYPTO.DECRYPT (src   => encrypted_raw, typ   => encryption_type, KEY   => key_bytes_raw);
            output_string := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
            
            DBMS_OUTPUT.PUT_LINE ('Cadena a encriptar: ' || input_string);
            DBMS_OUTPUT.PUT_LINE ('Cadena encriptada: ' || encrypted_raw);
            DBMS_OUTPUT.PUT_LINE ('LLave: ' || key_bytes_raw);
            DBMS_OUTPUT.PUT_LINE ('Decrypted string: ' || output_string);

         EXCEPTION WHEN OTHERS THEN
               FND_FILE.PUT_LINE (FND_FILE.LOG,'Error al generar  fima digital.');
               DBMS_OUTPUT.PUT_LINE ('Error al generar  fima digital.');
         END;

         BEGIN
            INSERT INTO ATET_SB_CHECKS_ALL (CHECK_ID,
                                            AMOUNT,
                                            BANK_ACCOUNT_ID,
                                            BANK_ACCOUNT_NAME,
                                            CHECK_DATE,
                                            CHECK_NUMBER,
                                            CURRENCY_CODE,
                                            PAYMENT_TYPE_FLAG,
                                            STATUS_LOOKUP_CODE,
                                            MEMBER_ID,
                                            MEMBER_NAME,
                                            BANK_ACCOUNT_NUM,
                                            DIGITAL_SIGNATURE,
                                            DECRYPT_KEY,
                                            LAST_UPDATED_BY,
                                            LAST_UPDATE_DATE,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            PAYMENT_DESCRIPTION)
                 VALUES (LN_CHECK_ID,
                         LN_CHECK_AMOUNT,
                         LN_BANK_ACCOUNT_ID,
                         LC_BANK_ACCOUNT_NAME,
                         SYSDATE,
                         LN_CHECK_NUMBER,
                         LC_CURRENCY_CODE,
                         'CHECK_REPLACEMENT',
                         'CREATED',
                         LN_MEMBER_ID,
                         LC_EMPLOYEE_FULL_NAME,
                         LC_BANK_ACCOUNT_NUM,
                         ENCRYPTED_RAW,
                         KEY_BYTES_RAW,
                         FND_GLOBAL.USER_ID,
                         SYSDATE,
                         FND_GLOBAL.USER_ID,
                         SYSDATE,
                         'REEMPLAZO DE CHEQUE '||V_CHECK_NUMBER);

            --P_CHECK_ID := LN_CHECK_ID;
            
            COMMIT;
         
         EXCEPTION WHEN OTHERS THEN
               FND_FILE.PUT_LINE (FND_FILE.LOG,'Error: '||SQLERRM);
               DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
               RAISE;
         END;
         
         BEGIN
            UPDATE ATET_SB_CHECKS_ALL
               SET PAYMENT_TYPE_FLAG = 'REPLACED'
             WHERE 1 = 1
               AND CHECK_ID = P_CHECK_ID;
               
            COMMIT;               
         END;

         BEGIN
            INSERT INTO ATET_LOAN_PAYMENTS_ALL (AMOUNT,
                                                PAYMENT_NUM,
                                                CHECK_ID,
                                                LOAN_ID,
                                                PAYMENT_TYPE,
                                                LAST_UPDATED_BY,
                                                LAST_UPDATE_DATE,
                                                CREATED_BY,
                                                CREATION_DATE)
                 VALUES (LN_CHECK_AMOUNT,
                         1,
                         LN_CHECK_ID,
                         LN_LOAN_ID,
                         'CHECK_REPLACEMENT',
                         FND_GLOBAL.USER_ID,
                         SYSDATE,
                         FND_GLOBAL.USER_ID,
                         SYSDATE);

            COMMIT;
                
            UPDATE ATET_LOAN_PAYMENTS_ALL
               SET ATTRIBUTE1 = V_CHECK_ID,
                   ATTRIBUTE2 = LN_CHECK_ID,
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = fnd_global.user_id,
                   CHECK_ID = -1
             WHERE CHECK_ID = P_CHECK_ID;
                
            COMMIT;
         EXCEPTION WHEN others THEN
            FND_FILE.PUT_LINE (FND_FILE.LOG,'Error: '||SQLERRM);
            DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
            RAISE;
         END;

         BEGIN
           P_ENTITY_CODE := 'CHECKS';
           P_EVENT_TYPE_CODE := 'CHECK_REPLACEMENT';
           P_BATCH_NAME := 'REEMPLAZO DE CHEQUE';
           P_JOURNAL_NAME := 'REEMPLAZO DEL CHEQUE: ' || V_CHECK_NUMBER;
           P_HEADER_ID := NULL;

           ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (P_ENTITY_CODE,
                                                      P_EVENT_TYPE_CODE,
                                                      P_BATCH_NAME,
                                                      P_JOURNAL_NAME,
                                                      P_HEADER_ID);

           FND_FILE.PUT_LINE (FND_FILE.LOG,'HEADER_ID: ' || P_HEADER_ID);
           DBMS_OUTPUT.PUT_LINE ('HEADER_ID: ' || P_HEADER_ID);

           SELECT ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID (
                     (SELECT ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                                'BANK_CODE_COMB',
                                (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                                   FROM DUAL))
                                CONCATENATED_SEGMENTS
                        FROM DUAL))
             INTO LC_BANK_CODE_COMB
             FROM DUAL CCID;

           ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
              P_HEADER_ID               => P_HEADER_ID,
              P_ROW_NUMBER              => ROW_NUMBER,
              P_CODE_COMBINATION_ID     => LC_BANK_CODE_COMB,
              P_ACCOUNTING_CLASS_CODE   => P_EVENT_TYPE_CODE,
              P_ACCOUNTED_DR            => LN_CHECK_AMOUNT,
              P_ACCOUNTED_CR            => 0,
              P_DESCRIPTION             => 'REEMPLAZO DEL CHEQUE: ' || V_CHECK_NUMBER || ', DEL PRÉSTAMO: '|| LN_LOAN_NUMBER,
              P_SOURCE_ID               => V_CHECK_ID,
              P_SOURCE_LINK_TABLE       => 'ATET_SB_CHECKS_ALL');

           ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
              P_HEADER_ID               => P_HEADER_ID,
              P_ROW_NUMBER              => ROW_NUMBER,
              P_CODE_COMBINATION_ID     => LC_BANK_CODE_COMB,
              P_ACCOUNTING_CLASS_CODE   => P_EVENT_TYPE_CODE,
              P_ACCOUNTED_DR            => 0,
              P_ACCOUNTED_CR            => LN_CHECK_AMOUNT,
              P_DESCRIPTION             => 'NUEVO NÚMERO DE CHEQUE: '|| LN_CHECK_NUMBER || ', DEL PRÉSTAMO: '|| LN_LOAN_NUMBER,
              P_SOURCE_ID               => LN_CHECK_ID,
              P_SOURCE_LINK_TABLE       => 'ATET_SB_CHECKS');

           COMMIT;
            
         EXCEPTION WHEN others THEN
            FND_FILE.PUT_LINE (FND_FILE.LOG,'Error: '||SQLERRM);
            DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
            RAISE;
         END;
         
         ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL;
            --       fnd_global.apps_initialize (user_id => fnd_global.user_id, resp_id => 53698, resp_appl_id => 101);
            --           mo_global.set_policy_context ('S', 1329);
         BEGIN
--               ADD_LAYOUT_BOOLEAN :=
--                 FND_REQUEST.ADD_LAYOUT (
--                    TEMPLATE_APPL_NAME   => 'PER',
--                    TEMPLATE_CODE        => 'ATET_SB_PRINT_CHECK',
--                    TEMPLATE_LANGUAGE    => 'Spanish', --USE LANGUAGE FROM TEMPLATE DEFINITION
--                    TEMPLATE_TERRITORY   => 'Mexico', --USE TERRITORY FROM TEMPLATE DEFINITION
--                    OUTPUT_FORMAT        => 'PDF' --USE OUTPUT FORMAT FROM TEMPLATE DEFINITION
--                                                 );
              V_REQUEST_ID :=
                 FND_REQUEST.SUBMIT_REQUEST ('PER',                        -- APPLICATION
                                             'ATET_SB_PRINT_CHECK', -- PROGRAM SHORT NAME
                                             '',                           -- DESCRIPTION
                                             '',                            -- START TIME
                                             FALSE,                        -- SUB REQUEST
                                             TO_CHAR (LN_CHECK_ID),       -- ARGUMENT1
                                             CHR (0)       -- REPRESENTS END OF ARGUMENTS
                                                    );
               STANDARD.COMMIT;
               WAITING := FND_CONCURRENT.WAIT_FOR_REQUEST(V_REQUEST_ID,1,0,
                                                          PHASE,
                                                          STATUS,
                                                          DEV_PHASE,
                                                          DEV_STATUS,
                                                          V_MESSAGE
                                                         );               

               FND_FILE.PUT_LINE (FND_FILE.LOG,'CHEQUE - REQUEST_ID: '||V_REQUEST_ID );
          
         EXCEPTION WHEN OTHERS THEN
               FND_FILE.PUT_LINE (FND_FILE.LOG,'Error: '||SQLERRM);
               DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
               RAISE;
         END;
         
      EXCEPTION WHEN OTHERS THEN
            FND_FILE.PUT_LINE (FND_FILE.LOG,'Error inesperado: '||SQLERRM);
            DBMS_OUTPUT.PUT_LINE ('Error inesperado: ' || SQLERRM);
      END;
      
   END ATET_LOAN_CHECK_REPLACEMENT;
/
