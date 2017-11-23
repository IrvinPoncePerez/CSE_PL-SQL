CREATE OR REPLACE PACKAGE BODY APPS.ATET_SB_BACK_OFFICE_PKG
AS
   PROCEDURE LOG_ERRORS (P_CODE_SECTION       VARCHAR2,
                         P_ERROR_MESSAGE   IN VARCHAR2)
   AS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      INSERT INTO ATET_SB_ERROR_LOGS (ERROR_LOG_ID_ID,
                                      LOG_TIMESTAMP,
                                      CODE_SECTION,
                                      ERROR_MESSAGE)
           VALUES (ATET_SB_ERROR_LOGS_SEQ.NEXTVAL,
                   SYSTIMESTAMP,
                   P_CODE_SECTION,
                   P_ERROR_MESSAGE);

      COMMIT;
   END;

   PROCEDURE CREATE_REFINANCE_LOAN_CHECK (
      P_ACTUAL_LOAN_ID              IN            NUMBER,
      P_PREVIOUS_LOAN_ID            IN            NUMBER,
      P_PREVIOUS_LOAN_BALANCE_DUE   IN            NUMBER,
      P_TRANSFER_INTEREST_AMOUNT    IN            NUMBER,
      P_CONDONATE_INTEREST_AMOUNT   IN            NUMBER,
      P_ACTUAL_LOAN_CHECK_AMOUNT    IN            NUMBER,
      P_HAS_PREVIOUS_REFINANCED     IN            NUMBER,
      P_CHECK_NUMBER                IN            NUMBER DEFAULT NULL,
      P_CHECK_ID                       OUT NOCOPY NUMBER)
   IS
      LN_BANK_ACCOUNT_ID             NUMBER;
      LC_BANK_ACCOUNT_NAME           VARCHAR2 (150);
      LC_BANK_ACCOUNT_NUM            VARCHAR2 (150);
      LC_BANK_NAME                   VARCHAR2 (150);
      LC_CURRENCY_CODE               VARCHAR2 (150);
      LN_MEMBER_ID                   NUMBER;
      LC_EMPLOYEE_FULL_NAME          VARCHAR2 (300);
      LC_INT_REC_CODE_COMB           VARCHAR2 (150);
      LN_LOAN_AMOUNT                 NUMBER;
      LN_LOAN_TOTAL_AMOUNT           NUMBER;
      LN_LOAN_INTEREST_AMOUNT        NUMBER;
      LN_PREVIUOUS_LOAN_NUMBER       NUMBER;
      LN_LOAN_ID                     NUMBER;
      LN_LOAN_NUMBER                 NUMBER;
      LD_TRANSACTION_DATE            DATE;
      LN_CHECK_NUMBER                NUMBER;
      LN_CONDONED_INTEREST_ID        NUMBER;
      LN_CHECK_ID                    NUMBER;
      P_ENTITY_CODE                  VARCHAR2 (150);
      P_EVENT_TYPE_CODE              VARCHAR2 (150);
      P_BATCH_NAME                   VARCHAR2 (150);
      P_JOURNAL_NAME                 VARCHAR (150);
      LN_NOT_REC_CODE_COMB           NUMBER;
      LN_UNE_INT_CODE_COMB           NUMBER;
      P_INTEREST_EVENT_TYPE_CODE     VARCHAR2 (150);
      P_CHECK_EVENT_TYPE_CODE        VARCHAR2 (150);
      P_SUBSIDIZED_EVENT_TYPE_CODE   VARCHAR2 (150);
      P_INTEREST_EARN_TYPE_CODE      VARCHAR2 (150);
      P_PREV_LOAN_EVENT_TYPE_CODE    VARCHAR2 (150);
      LN_PREV_NOT_REC_CODE_COMB      NUMBER;
      LN_BANK_CODE_COMB              NUMBER;
      P_HEADER_ID                    NUMBER;
      LN_ROW_NUMBER                  NUMBER := 1;
      INPUT_STRING                   VARCHAR2 (200);
      OUTPUT_STRING                  VARCHAR2 (200);
      ENCRYPTED_RAW                  RAW (2000); -- stores encrypted binary text
      DECRYPTED_RAW                  RAW (2000); -- stores decrypted binary text
      NUM_KEY_BYTES                  NUMBER := 256 / 8; -- key length 256 bits (32 bytes)
      KEY_BYTES_RAW                  RAW (32); -- stores 256-bit encryption key
      ENCRYPTION_TYPE                PLS_INTEGER
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
            DBMS_OUTPUT.PUT_LINE ('Error al buscar la cuenta bantaria');
            LOG_ERRORS (
               'CREATE_REFINANCE_LOAN_CHECK => BUSCANDO CUENTAS BANCARIAS',
               P_ERROR_MESSAGE   => SQLERRM);

            FND_FILE.PUT_LINE (FND_FILE.LOG,
                               'Error al buscar la cuenta bantaria');
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
             WHERE LOAN_ID = P_ACTUAL_LOAN_ID
                   AND NOT EXISTS
                          (SELECT LOAN_ID
                             FROM ATET_LOAN_PAYMENTS_ALL ALPA
                            WHERE ALPA.LOAN_ID = ASL.LOAN_ID);
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.PUT_LINE (
                  'Error al buscar préstamo o el cheque ya fue generado');
               LOG_ERRORS (
                  'CREATE_REFINANCE_LOAN_CHECK => ERROR AL BUSCAR EL PRESTAMO O EL CHEQUE YA FUE GENERADO',
                  P_ERROR_MESSAGE   => SQLERRM);

               FND_FILE.PUT_LINE (
                  FND_FILE.LOG,
                  'Error al buscar préstamo o el cheque ya fue generado');
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
               LOG_ERRORS (
                  'CREATE_REFINANCE_LOAN_CHECK => ERROR AL BUSCAR EL MIEMBRO',
                  P_ERROR_MESSAGE   => SQLERRM);
               DBMS_OUTPUT.PUT_LINE ('Error al buscar el miembro');
               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Error al buscar el miembro');
               RAISE;
         END;


         BEGIN
            SELECT LOAN_NUMBER
              INTO LN_PREVIUOUS_LOAN_NUMBER
              FROM ATET_SB_LOANS
             WHERE LOAN_ID = P_PREVIOUS_LOAN_ID;
         EXCEPTION
            WHEN OTHERS
            THEN
               LOG_ERRORS (
                  'CREATE_REFINANCE_LOAN_CHECK => ERROR AL BUSCAR EL PRESTAMO ANTERIOR',
                  P_ERROR_MESSAGE   => SQLERRM);
               DBMS_OUTPUT.PUT_LINE ('Error al buscar el prestamo anterior');
               FND_FILE.PUT_LINE (
                  FND_FILE.LOG,
                  'Error al buscar el prestamo anterior en LN_PREVIUOUS_LOAN_NUMBER');
               RAISE;
         END;


         BEGIN
            SELECT ATET_SB_CHECKS_ALL_SEQ.NEXTVAL INTO LN_CHECK_ID FROM DUAL;

            IF P_CHECK_NUMBER IS NULL
            THEN
               SELECT ATET_SB_CHECK_NUMBER_SEQ.NEXTVAL
                 INTO LN_CHECK_NUMBER
                 FROM DUAL;
            ELSE
               LN_CHECK_NUMBER := P_CHECK_NUMBER;
            END IF;


            INPUT_STRING :=
                  TO_CHAR (P_ACTUAL_LOAN_CHECK_AMOUNT)
               || ','
               || LN_CHECK_ID
               || ','
               || LN_CHECK_NUMBER
               || ','
               || LN_MEMBER_ID
               || ','
               || FND_GLOBAL.USER_ID
               || ','
               || TO_CHAR (CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF');

            DBMS_OUTPUT.PUT_LINE ('Original string: ' || input_string);
            key_bytes_raw := DBMS_CRYPTO.RANDOMBYTES (num_key_bytes);
            encrypted_raw :=
               DBMS_CRYPTO.ENCRYPT (
                  src   => UTL_I18N.STRING_TO_RAW (input_string, 'AL32UTF8'),
                  typ   => encryption_type,
                  key   => key_bytes_raw);
            -- The encrypted value "encrypted_raw" can be used here

            decrypted_raw :=
               DBMS_CRYPTO.DECRYPT (src   => encrypted_raw,
                                    typ   => encryption_type,
                                    key   => key_bytes_raw);
            output_string := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
            DBMS_OUTPUT.PUT_LINE ('Cadena a encriptar: ' || input_string);
            DBMS_OUTPUT.PUT_LINE ('Cadena encriptada: ' || encrypted_raw);
            DBMS_OUTPUT.PUT_LINE ('LLave: ' || key_bytes_raw);
            DBMS_OUTPUT.PUT_LINE ('Decrypted string: ' || output_string);
         EXCEPTION
            WHEN OTHERS
            THEN
               LOG_ERRORS (
                  'CREATE_REFINANCE_LOAN_CHECK => ERROR AL GENERAR LA FIRMA DIGITAL',
                  P_ERROR_MESSAGE   => SQLERRM);
               DBMS_OUTPUT.PUT_LINE ('Error al generar  fima digital');
               FND_FILE.PUT_LINE (FND_FILE.LOG,
                                  'Error al generar  fima digital');
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
                                            CREATION_DATE)
                 VALUES (LN_CHECK_ID,
                         P_ACTUAL_LOAN_CHECK_AMOUNT,
                         LN_BANK_ACCOUNT_ID,
                         LC_BANK_ACCOUNT_NAME,
                         SYSDATE,
                         LN_CHECK_NUMBER,
                         LC_CURRENCY_CODE,
                         'REFINANCED_CHECK_LOAN',
                         'CREATED',
                         LN_MEMBER_ID,
                         LC_EMPLOYEE_FULL_NAME,
                         LC_BANK_ACCOUNT_NUM,
                         ENCRYPTED_RAW,
                         KEY_BYTES_RAW,
                         FND_GLOBAL.USER_ID,
                         SYSDATE,
                         FND_GLOBAL.USER_ID,
                         SYSDATE);

            P_CHECK_ID := LN_CHECK_ID;
         --            COMMIT;
         EXCEPTION
            WHEN OTHERS
            THEN
               LOG_ERRORS (
                  'CREATE_REFINANCE_LOAN_CHECK => ERROR AL INSERTAR EN LA TABLA DE CHEQUES',
                  P_ERROR_MESSAGE   => SQLERRM);
               DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);

               FND_FILE.PUT_LINE (
                  FND_FILE.LOG,
                  'Error al insertar en la tabla de cheques' || SQLERRM);

               RAISE;
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
                 VALUES (P_ACTUAL_LOAN_CHECK_AMOUNT,
                         1,
                         LN_CHECK_ID,
                         LN_LOAN_ID,
                         'REFINANCED_LOAN_CHECK',
                         FND_GLOBAL.USER_ID,
                         SYSDATE,
                         FND_GLOBAL.USER_ID,
                         SYSDATE);

            --            COMMIT;

            ----Inicia proceso de crear contabilidad
            BEGIN
               P_ENTITY_CODE := 'REFINANCED_LOANS';

               P_EVENT_TYPE_CODE := 'REFINANCED_LOAN_CREATION';
               P_INTEREST_EVENT_TYPE_CODE := 'REFINANCED_LOAN_INTEREST';
               P_CHECK_EVENT_TYPE_CODE := 'REFINANCED_LOAN_CHECK';
               P_SUBSIDIZED_EVENT_TYPE_CODE := 'REFINANCED_SUBSIDIZED';
               P_INTEREST_EARN_TYPE_CODE := 'INTEREST_EARN';
               P_PREV_LOAN_EVENT_TYPE_CODE := 'PREVIOUS_LOAN';

               P_BATCH_NAME := 'PRESTAMO REFINANCIADO DE CAJA DE AHORRO';
               P_JOURNAL_NAME :=
                  'PRESTAMO CAJA DE AHORRO REFINANCIADO A: '
                  || LC_EMPLOYEE_FULL_NAME;
               P_HEADER_ID := NULL;


               ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (P_ENTITY_CODE,
                                                          P_EVENT_TYPE_CODE,
                                                          P_BATCH_NAME,
                                                          P_JOURNAL_NAME,
                                                          P_HEADER_ID);

               DBMS_OUTPUT.PUT_LINE ('HEADER_ID: ' || P_HEADER_ID);



               IF ATET_SAVINGS_BANK_PKG.GET_MEMBER_IS_SAVER (LN_MEMBER_ID) =
                     'Y'
               THEN
                  SELECT ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID (
                            (SELECT ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                                       'NOT_REC_SAV_CODE_COMB',
                                       (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                                          FROM DUAL))
                                       CONCATENATED_SEGMENTS
                               FROM DUAL))
                    INTO LN_NOT_REC_CODE_COMB --DOCUMENTOS POR COBRAR DEL NUEVO PRESTAMO(AHORRADORES)
                    FROM DUAL CCID;
               ELSE
                  SELECT ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID (
                            (SELECT ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                                       'NOT_REC_NO_SAV_CODE_COMB',
                                       (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                                          FROM DUAL))
                                       CONCATENATED_SEGMENTS
                               FROM DUAL))
                    INTO LN_NOT_REC_CODE_COMB --DOCUMENTOS POR COBRAR DEL NUEVO PRESTAMO (NO AHORRADORES)
                    FROM DUAL CCID;
               END IF;


               BEGIN
                  SELECT CODE_COMBINATION_ID
                    INTO LN_PREV_NOT_REC_CODE_COMB --DOCUMENTOS POR COBRAR DEL PRESTAMO ANTERIOR (AHORRADOR O NO AHORRADOR)
                    FROM ATET_XLA_LINES
                   WHERE SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
                         AND SOURCE_ID = P_PREVIOUS_LOAN_ID
                         AND ACCOUNTING_CLASS_CODE IN
                                ('LOAN_CREATION', 'REFINANCED_LOAN_CREATION');
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     LOG_ERRORS (
                        'CREATE_REFINANCE_LOAN_CHECK => ERROR AL BUSCAR DOCUMENTOS POR COBRAR DEL PRESTAMO ANTERIOR (AHORRADOR O NO AHORRADOR)',
                        P_ERROR_MESSAGE   => SQLERRM);
                     FND_FILE.PUT_LINE (
                        FND_FILE.LOG,
                        'CREATE_REFINANCE_LOAN_CHECK =>  ERROR AL BUSCAR DOCUMENTOS POR COBRAR DEL PRESTAMO ANTERIOR (AHORRADOR O NO AHORRADOR) '
                        || SQLERRM);
                     RAISE;
               END;

               BEGIN
                  SELECT ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID (
                            (SELECT ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                                       'BANK_CODE_COMB',
                                       (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                                          FROM DUAL))
                                       CONCATENATED_SEGMENTS
                               FROM DUAL))
                    INTO LN_BANK_CODE_COMB                   --Bancos / checks
                    FROM DUAL CCID;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     LOG_ERRORS (
                        'CREATE_REFINANCE_LOAN_CHECK =>ERROR AL BUSCAR LA CUENTA BANK_CODE_COMB',
                        P_ERROR_MESSAGE   => SQLERRM);

                     FND_FILE.PUT_LINE (
                        FND_FILE.LOG,
                        'ERROR AL BUSCAR LA CUENTA BANK_CODE_COMB '
                        || SQLERRM);
                     RAISE;
               END;

               BEGIN
                  SELECT ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID (
                            (SELECT ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                                       'UNE_INT_CODE_COMB',
                                       (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                                          FROM DUAL))
                                       CONCATENATED_SEGMENTS
                               FROM DUAL))
                    INTO LN_UNE_INT_CODE_COMB         --INTERESES POR DEVENGAR
                    FROM DUAL CCID;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     LOG_ERRORS (
                        'CREATE_REFINANCE_LOAN_CHECK =>ERROR AL BUSCAR LA CUENTA UNE_INT_CODE_COMB',
                        P_ERROR_MESSAGE   => SQLERRM);
                     FND_FILE.PUT_LINE (
                        FND_FILE.LOG,
                        'ERROR AL BUSCAR LA CUENTA UNE_INT_CODE_COMB '
                        || SQLERRM);
                     RAISE;
               END;

               BEGIN
                  SELECT ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID (
                            (SELECT ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                                       'INT_REC_CODE_COMB',
                                       (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                                          FROM DUAL))
                                       CONCATENATED_SEGMENTS
                               FROM DUAL))
                    INTO LC_INT_REC_CODE_COMB             --INTERESES COBRADOS
                    FROM DUAL CCID;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     LOG_ERRORS (
                        'CREATE_REFINANCE_LOAN_CHECK =>ERROR AL BUSCAR LA CUENTA INT_REC_CODE_COMB ',
                        P_ERROR_MESSAGE   => SQLERRM);

                     FND_FILE.PUT_LINE (
                        FND_FILE.LOG,
                        'ERROR AL BUSCAR LA CUENTA INT_REC_CODE_COMB '
                        || SQLERRM);
                     RAISE;
               END;

               -------------------------------------- CREACION DE LINEAS EN XLA

               ---DOCUMENTOS POR COBRAR NUEVO PRESTAMO
               ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
                  P_HEADER_ID               => P_HEADER_ID,
                  P_ROW_NUMBER              => 1,
                  P_CODE_COMBINATION_ID     => LN_NOT_REC_CODE_COMB,
                  P_ACCOUNTING_CLASS_CODE   => P_EVENT_TYPE_CODE,
                  P_ACCOUNTED_DR            => LN_LOAN_TOTAL_AMOUNT,
                  P_ACCOUNTED_CR            => 0,
                  P_DESCRIPTION             =>   'PRESTAMO A: '
                                              || LC_EMPLOYEE_FULL_NAME
                                              || ' '
                                              || LN_LOAN_NUMBER,
                  P_SOURCE_ID               => ln_loan_id,
                  P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');

               ---BANCOS CHEQUES
               ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
                  P_HEADER_ID               => P_HEADER_ID,
                  P_ROW_NUMBER              => 2,
                  P_CODE_COMBINATION_ID     => LN_BANK_CODE_COMB,
                  P_ACCOUNTING_CLASS_CODE   => P_CHECK_EVENT_TYPE_CODE,
                  P_ACCOUNTED_DR            => 0,
                  P_ACCOUNTED_CR            => P_ACTUAL_LOAN_CHECK_AMOUNT,
                  P_DESCRIPTION             => 'NUMERO DE CHEQUE:  '
                                              || LN_CHECK_NUMBER,
                  P_SOURCE_ID               => LN_CHECK_ID,
                  P_SOURCE_LINK_TABLE       => 'ATET_SB_CHECKS_ALL');


               ---- INTERESES POR DEVENGAR NUEVO PRÉSTAMO
               ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
                  P_HEADER_ID               => P_HEADER_ID,
                  P_ROW_NUMBER              => 3,
                  P_CODE_COMBINATION_ID     => LN_UNE_INT_CODE_COMB,
                  P_ACCOUNTING_CLASS_CODE   => P_INTEREST_EARN_TYPE_CODE,
                  P_ACCOUNTED_DR            => 0,
                  P_ACCOUNTED_CR            => LN_LOAN_INTEREST_AMOUNT,
                  P_DESCRIPTION             => 'INTERESES DEL PRESTAMO: '
                                              || LN_LOAN_NUMBER,
                  P_SOURCE_ID               => ln_loan_id,
                  P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');



               ---DOCUMENTOS POR COBRAR PRESTAMO ANTERIOR

               ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
                  P_HEADER_ID               => P_HEADER_ID,
                  P_ROW_NUMBER              => 4,
                  P_CODE_COMBINATION_ID     => LN_PREV_NOT_REC_CODE_COMB,
                  P_ACCOUNTING_CLASS_CODE   => P_PREV_LOAN_EVENT_TYPE_CODE,
                  P_ACCOUNTED_DR            => 0,
                  P_ACCOUNTED_CR            => P_PREVIOUS_LOAN_BALANCE_DUE,
                  P_DESCRIPTION             => 'REFINANCIAMIENTO DEL PRESTAMO: '
                                              || LN_PREVIUOUS_LOAN_NUMBER,
                  P_SOURCE_ID               => ln_loan_id,
                  P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');


               --INTERESES POR DEVENGAR
               ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
                  P_HEADER_ID               => P_HEADER_ID,
                  P_ROW_NUMBER              => 5,
                  P_CODE_COMBINATION_ID     => LN_UNE_INT_CODE_COMB,
                  P_ACCOUNTING_CLASS_CODE   => P_INTEREST_EARN_TYPE_CODE,
                  P_ACCOUNTED_DR            => P_TRANSFER_INTEREST_AMOUNT
                                              + P_CONDONATE_INTEREST_AMOUNT,
                  P_ACCOUNTED_CR            => 0,
                  P_DESCRIPTION             => 'INTERESES DEL PRESTAMO REFINANCIADO: '
                                              || LN_PREVIUOUS_LOAN_NUMBER,
                  P_SOURCE_ID               => ln_loan_id,
                  P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');


               --INTERESES cobrados

               IF P_HAS_PREVIOUS_REFINANCED = 0
               THEN
                  ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
                     P_HEADER_ID               => P_HEADER_ID,
                     P_ROW_NUMBER              => 6,
                     P_CODE_COMBINATION_ID     => LC_INT_REC_CODE_COMB,
                     P_ACCOUNTING_CLASS_CODE   => P_SUBSIDIZED_EVENT_TYPE_CODE,
                     P_ACCOUNTED_DR            => 0,
                     P_ACCOUNTED_CR            => P_TRANSFER_INTEREST_AMOUNT, --P_CONDONATE_INTEREST_AMOUNT, 25-jan-2017 Se cambió para que se registre una bonificación diferente al 50%
                     P_DESCRIPTION             => 'INTERESES COBRADOS DEL PRESTAMO REFINANCIADO: '
                                                 || LN_PREVIUOUS_LOAN_NUMBER,
                     P_SOURCE_ID               => ln_loan_id,
                     P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');


                  BEGIN
                     SELECT ATET_SB_CONDONED_INTEREST_SEQ.NEXTVAL
                       INTO LN_CONDONED_INTEREST_ID
                       FROM DUAL;
                  END;

                  BEGIN
                     INSERT
                       INTO ATET_SB_CONDONED_INTEREST (
                               SUBSIDIZED_INTEREST_ID,
                               SUBSIDIZED_INTEREST_NUMBER,
                               LOAN_ID,
                               LOAN_NUMBER,
                               CONDONED_INTEREST_AMOUNT,
                               XLA_HEADER_ID,
                               XLA_LINE_NUMBER,
                               ACCOUNTING_CLASS_CODE,
                               CODE_COMBINATION_ID,
                               DESCRIPTION,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_DATE,
                               LAST_UPDATED_BY)
                     VALUES (LN_CONDONED_INTEREST_ID,
                             LN_CONDONED_INTEREST_ID,
                             P_PREVIOUS_LOAN_ID,
                             LN_PREVIUOUS_LOAN_NUMBER,
                             P_CONDONATE_INTEREST_AMOUNT,
                             P_HEADER_ID,
                             6,
                             P_SUBSIDIZED_EVENT_TYPE_CODE,
                             LC_INT_REC_CODE_COMB,
                             'INTERESES BONIFICADOS',
                             SYSDATE,
                             FND_GLOBAL.USER_ID,
                             SYSDATE,
                             FND_GLOBAL.USER_ID);
                  END;
               ELSE
                  ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
                     P_HEADER_ID               => P_HEADER_ID,
                     P_ROW_NUMBER              => 6,
                     P_CODE_COMBINATION_ID     => LC_INT_REC_CODE_COMB,
                     P_ACCOUNTING_CLASS_CODE   => P_SUBSIDIZED_EVENT_TYPE_CODE,
                     P_ACCOUNTED_DR            => 0,
                     P_ACCOUNTED_CR            => P_TRANSFER_INTEREST_AMOUNT
                                                 - P_CONDONATE_INTEREST_AMOUNT,
                     P_DESCRIPTION             => 'INTERESES COBRADOS DEL PRESTAMO REFINANCIADO: '
                                                 || LN_PREVIUOUS_LOAN_NUMBER,
                     P_SOURCE_ID               => ln_loan_id,
                     P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');
               END IF;
            --               COMMIT;
            END;
         EXCEPTION
            WHEN OTHERS
            THEN
               LOG_ERRORS (
                  'CREATE_REFINANCE_LOAN_CHECK =>ERROR EN XLA LINES',
                  P_ERROR_MESSAGE   => SQLERRM);
               DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
               FND_FILE.PUT_LINE (FND_FILE.LOG, 'EN XLA LINES' || SQLERRM);
               RAISE;
         END;
      EXCEPTION
         WHEN OTHERS
         THEN
            LOG_ERRORS (
               'CREATE_REFINANCE_LOAN_CHECK =>ERROR FATAL FATALISIMO POR INCONSISTENCIA EN LOS DATOS',
               P_ERROR_MESSAGE   => SQLERRM);
            DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
            DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
            FND_FILE.PUT_LINE (
               FND_FILE.LOG,
               'ERROR FATAL FATALISIMO POR INCONSISTENCIA EN LOS DATOS'
               || SQLERRM);
            RAISE;
      END;
   END CREATE_REFINANCE_LOAN_CHECK;

   PROCEDURE CREATE_PAYMENTS_SCHEDULE (
      P_LOAN_ID                           NUMBER,
      P_LAST_PAYMENT_DATE      OUT NOCOPY VARCHAR2)
   IS
      LN_PAYROLL_ID                NUMBER;
      LN_ASSIGNMENT_ID             NUMBER;
      LC_PERIOD_NAME               VARCHAR (250);
      LD_DATE_EARNED               DATE;
      LN_LOAN_ID                   NUMBER;
      LN_EMPLOYEE_NUMBER           NUMBER;
      LN_MEMBER_ID                 NUMBER;
      LN_LOAN_TOTAL_AMOUNT         NUMBER;
      LN_LOAN_AMOUNT               NUMBER;
      LN_LOAN_INTEREST_AMOUNT      NUMBER;
      LN_TERM_PERIODS              NUMBER;
      LN_TRANSACTION_DATE          DATE;
      LN_PARTIAL_AMOUNT            NUMBER;
      LN_ACCRUED_PAYMENTS          NUMBER := 0;
      LN_ACCRUED_INTEREST          NUMBER := 0;
      LN_ACCRUED_CAPITAL           NUMBER := 0;
      LN_LOAN_BALANCE              NUMBER := 0;
      LN_OPENING_BALANCE           NUMBER := 0;
      LN_PAYMENT_INTEREST          NUMBER;
      LN_CAPITAL_PAYMENT           NUMBER;
      LN_PAYMENT_SCHEDULE_EXISTS   NUMBER;
      LC_EXTEMP_LOANS              VARCHAR2 (19);
      LN_LOAN_EXISTS               NUMBER;
      LN_CREATION_STATUS_FLAG      VARCHAR2 (100);
      LC_LAST_PAYMENT_DATE         VARCHAR (250);

      CURSOR C_PAYMENT_SEQUENCE
      IS
         SELECT PAYROLL_ID,
                TIME_PERIOD_ID,
                END_DATE,
                PERIOD_NAME,
                PERIOD_NUM,
                PERIOD_SEQUENCE
           FROM (  SELECT PAYROLL_ID,
                          TIME_PERIOD_ID,
                          END_DATE,
                          PERIOD_NAME,
                          PERIOD_NUM,
                          ROW_NUMBER ()
                             OVER (PARTITION BY PAYROLL_ID ORDER BY END_DATE)
                             PERIOD_SEQUENCE
                     FROM PER_TIME_PERIODS
                    WHERE PAYROLL_ID = LN_PAYROLL_ID
                          AND (END_DATE > (LD_DATE_EARNED)
                               AND END_DATE > (LN_TRANSACTION_DATE))
                 ORDER BY END_DATE)
          WHERE PERIOD_SEQUENCE <= LN_TERM_PERIODS;
   BEGIN
      BEGIN
         SELECT COUNT (1)
           INTO LN_LOAN_EXISTS
           FROM ATET_SB_LOANS
          WHERE LOAN_ID = P_LOAN_ID;
      EXCEPTION
         WHEN OTHERS
         THEN
            LN_LOAN_EXISTS := 0;
      END;

      BEGIN
         SELECT COUNT (1)
           INTO LN_PAYMENT_SCHEDULE_EXISTS
           FROM ATET_SB_PAYMENTS_SCHEDULE
          WHERE LOAN_ID = P_LOAN_ID;
      EXCEPTION
         WHEN OTHERS
         THEN
            LN_PAYMENT_SCHEDULE_EXISTS := 0;
      END;

      IF LN_PAYMENT_SCHEDULE_EXISTS = 0 AND LN_LOAN_EXISTS <> 0
      THEN
         BEGIN
            LN_CREATION_STATUS_FLAG := 'PENDING';

            SELECT LOAN_ID,
                   ASM.EMPLOYEE_NUMBER,
                   ASL.MEMBER_ID,
                   LOAN_TOTAL_AMOUNT,
                   LOAN_AMOUNT,
                   LOAN_INTEREST_AMOUNT,
                   TERM_PERIODS,
                   TRANSACTION_DATE,
                   ASL.ATTRIBUTE1 PARTIAL_AMOUNT,
                   TRUNC ( (LOAN_INTEREST_AMOUNT / TERM_PERIODS), 2)
                      PAYMENT_INTEREST
              INTO LN_LOAN_ID,
                   LN_EMPLOYEE_NUMBER,
                   LN_MEMBER_ID,
                   LN_LOAN_TOTAL_AMOUNT,
                   LN_LOAN_AMOUNT,
                   LN_LOAN_INTEREST_AMOUNT,
                   LN_TERM_PERIODS,
                   LN_TRANSACTION_DATE,
                   LN_PARTIAL_AMOUNT,
                   LN_PAYMENT_INTEREST
              FROM ATET_SB_LOANS ASL, ATET_SB_MEMBERS ASM
             WHERE     1 = 1
                   AND ASL.MEMBER_ID = ASM.MEMBER_ID
                   AND LOAN_ID = P_LOAN_ID;

            LN_CAPITAL_PAYMENT := LN_PARTIAL_AMOUNT - LN_PAYMENT_INTEREST;
            LN_LOAN_BALANCE := LN_LOAN_TOTAL_AMOUNT;
            LN_OPENING_BALANCE := LN_LOAN_TOTAL_AMOUNT;
         END;


         BEGIN
            SELECT ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                      'EXTEMP_LOANS',
                      (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                         FROM DUAL))
                      CONCATENATED_SEGMENTS
              INTO LC_EXTEMP_LOANS
              FROM DUAL;
         END;


         IF LC_EXTEMP_LOANS = 'N'
         THEN
            BEGIN
               SELECT ASSIGNMENT_ID,
                      PERIOD_NAME,
                      DATE_EARNED,
                      PAYROLL_ID
                 INTO LN_ASSIGNMENT_ID,
                      LC_PERIOD_NAME,
                      LD_DATE_EARNED,
                      LN_PAYROLL_ID
                 FROM (SELECT ASSIGNMENT_ID,
                              PERIOD_NAME,
                              DATE_EARNED,
                              PAYROLL_ID,
                              ROW_NUMBER ()
                              OVER (PARTITION BY ASSIGNMENT_ID
                                    ORDER BY DATE_EARNED DESC)
                                 LATEST
                         FROM (  SELECT UNIQUE
                                        AAC.ASSIGNMENT_ID,
                                        PAC.EFFECTIVE_DATE,
                                        PAC.ACTION_TYPE,
                                        ASG.PAYROLL_ID,
                                        DECODE (
                                           PAC.ACTION_TYPE,
                                           'T', DECODE (
                                                   INSTRB (
                                                      PAC.LEGISLATIVE_PARAMETERS,
                                                      'SLA_MODE=Y'),
                                                   0, HR_GENERAL.DECODE_LOOKUP (
                                                         'TRANSFER_TO_LEDGER',
                                                         'GL'),
                                                   NULL, HR_GENERAL.DECODE_LOOKUP (
                                                            'TRANSFER_TO_LEDGER',
                                                            'GL'),
                                                   HR_GENERAL.DECODE_LOOKUP (
                                                      'TRANSFER_TO_LEDGER',
                                                      'SLA')),
                                           LO1.MEANING)
                                           TYPE,
                                        HR_PAYROLLS.DISPLAY_PERIOD_NAME (
                                           PAC.PAYROLL_ACTION_ID)
                                           PERIOD_NAME,
                                        PEO.FULL_NAME,
                                        PEO.EFFECTIVE_START_DATE PEO_START_DATE,
                                        PEO.EFFECTIVE_END_DATE PEO_END_DATE,
                                        ASG.ASSIGNMENT_NUMBER,
                                        ASG.EFFECTIVE_START_DATE ASG_START_DATE,
                                        ASG.EFFECTIVE_END_DATE ASG_END_DATE,
                                        AAC.ACTION_STATUS STATUS_CODE,
                                        PAY_ASSIGNMENT_ACTIONS_PKG.GET_ACTION_STATUS (
                                           AAC.ASSIGNMENT_ACTION_ID,
                                           PAC.ACTION_TYPE,
                                           AAC.ACTION_STATUS)
                                           ACTION_STATUS,
                                        PAC.DATE_EARNED
                                   FROM PER_ASSIGNMENTS_F2 ASG,
                                        PER_PEOPLE_F PEO,
                                        HR_LOOKUPS LO1,
                                        PAY_PAYROLL_ACTIONS PAC,
                                        PAY_ASSIGNMENT_ACTIONS AAC
                                  WHERE AAC.ASSIGNMENT_ID = ASG.ASSIGNMENT_ID
                                        AND ASG.PERSON_ID = PEO.PERSON_ID
                                        AND LO1.LOOKUP_TYPE = 'ACTION_TYPE'
                                        AND LO1.LOOKUP_CODE = PAC.ACTION_TYPE
                                        AND AAC.PAYROLL_ACTION_ID =
                                               PAC.PAYROLL_ACTION_ID
                                        AND PAC.ACTION_TYPE IN ('R', 'Q') /* INCLUDES RUN TYPE */
                                        AND SYSDATE BETWEEN ASG.EFFECTIVE_START_DATE
                                                        AND ASG.EFFECTIVE_END_DATE
                                        AND PAC.EFFECTIVE_DATE BETWEEN PEO.EFFECTIVE_START_DATE
                                                                   AND PEO.EFFECTIVE_END_DATE
                                        AND PAC.EFFECTIVE_DATE BETWEEN ASG.EFFECTIVE_START_DATE
                                                                   AND ASG.EFFECTIVE_END_DATE
                                        AND PAC.PAYROLL_ID = ASG.PAYROLL_ID
                                        AND TO_NUMBER (PEO.EMPLOYEE_NUMBER) =
                                               LN_EMPLOYEE_NUMBER
                               ORDER BY PAC.DATE_EARNED DESC))
                WHERE LATEST = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  SELECT ASSIGNMENT_ID,
                         PERIOD_NAME,
                         DATE_EARNED,
                         PAYROLL_ID
                    INTO LN_ASSIGNMENT_ID,
                         LC_PERIOD_NAME,
                         LD_DATE_EARNED,
                         LN_PAYROLL_ID
                    FROM (SELECT ASSIGNMENT_ID,
                                 PERIOD_NAME,
                                 DATE_EARNED,
                                 PAYROLL_ID,
                                 ROW_NUMBER ()
                                 OVER (PARTITION BY ASSIGNMENT_ID
                                       ORDER BY DATE_EARNED DESC)
                                    LATEST
                            FROM (  SELECT UNIQUE
                                           AAC.ASSIGNMENT_ID,
                                           PAC.EFFECTIVE_DATE,
                                           PAC.ACTION_TYPE,
                                           ASG.PAYROLL_ID,
                                           DECODE (
                                              PAC.ACTION_TYPE,
                                              'T', DECODE (
                                                      INSTRB (
                                                         PAC.LEGISLATIVE_PARAMETERS,
                                                         'SLA_MODE=Y'),
                                                      0, HR_GENERAL.DECODE_LOOKUP (
                                                            'TRANSFER_TO_LEDGER',
                                                            'GL'),
                                                      NULL, HR_GENERAL.DECODE_LOOKUP (
                                                               'TRANSFER_TO_LEDGER',
                                                               'GL'),
                                                      HR_GENERAL.DECODE_LOOKUP (
                                                         'TRANSFER_TO_LEDGER',
                                                         'SLA')),
                                              LO1.MEANING)
                                              TYPE,
                                           HR_PAYROLLS.DISPLAY_PERIOD_NAME (
                                              PAC.PAYROLL_ACTION_ID)
                                              PERIOD_NAME,
                                           PEO.FULL_NAME,
                                           PEO.EFFECTIVE_START_DATE
                                              PEO_START_DATE,
                                           PEO.EFFECTIVE_END_DATE PEO_END_DATE,
                                           ASG.ASSIGNMENT_NUMBER,
                                           ASG.EFFECTIVE_START_DATE
                                              ASG_START_DATE,
                                           ASG.EFFECTIVE_END_DATE ASG_END_DATE,
                                           AAC.ACTION_STATUS STATUS_CODE,
                                           PAY_ASSIGNMENT_ACTIONS_PKG.GET_ACTION_STATUS (
                                              AAC.ASSIGNMENT_ACTION_ID,
                                              PAC.ACTION_TYPE,
                                              AAC.ACTION_STATUS)
                                              ACTION_STATUS,
                                           PAC.DATE_EARNED
                                      FROM PER_ASSIGNMENTS_F2 ASG,
                                           PER_PEOPLE_F PEO,
                                           HR_LOOKUPS LO1,
                                           PAY_PAYROLL_ACTIONS PAC,
                                           PAY_ASSIGNMENT_ACTIONS AAC
                                     WHERE AAC.ASSIGNMENT_ID =
                                              ASG.ASSIGNMENT_ID
                                           AND ASG.PERSON_ID = PEO.PERSON_ID
                                           AND LO1.LOOKUP_TYPE = 'ACTION_TYPE'
                                           AND LO1.LOOKUP_CODE =
                                                  PAC.ACTION_TYPE
                                           AND AAC.PAYROLL_ACTION_ID =
                                                  PAC.PAYROLL_ACTION_ID
                                           AND PAC.ACTION_TYPE IN ('R', 'Q') /* INCLUDES RUN TYPE */
                                           --                                        AND SYSDATE BETWEEN ASG.EFFECTIVE_START_DATE
                                           --                                                        AND ASG.EFFECTIVE_END_DATE
                                           AND PAC.EFFECTIVE_DATE BETWEEN PEO.EFFECTIVE_START_DATE
                                                                      AND PEO.EFFECTIVE_END_DATE
                                           AND PAC.EFFECTIVE_DATE BETWEEN ASG.EFFECTIVE_START_DATE
                                                                      AND ASG.EFFECTIVE_END_DATE
                                           AND PAC.PAYROLL_ID = ASG.PAYROLL_ID
                                           AND TO_NUMBER (PEO.EMPLOYEE_NUMBER) =
                                                  LN_EMPLOYEE_NUMBER
                                  ORDER BY PAC.DATE_EARNED DESC))
                   WHERE LATEST = 1;

                  LOG_ERRORS (
                     'CREATE_PAYMENT_SCHEDULES =>ERROR AL BUSCAR EJECUCIONES ANTERIORES DE NOMINA LC_EXTEMP_LOANS = N Y TUVE QUE TRAER LA ASIGNACIÓN ALTERNA ANTERIOR',
                     P_ERROR_MESSAGE   => SQLERRM);
               WHEN OTHERS
               THEN
                  LOG_ERRORS (
                     'CREATE_PAYMENT_SCHEDULES =>ERROR AL BUSCAR EJECUCIONES ANTERIORES DE NOMINA LC_EXTEMP_LOANS = N',
                     P_ERROR_MESSAGE   => SQLERRM);

                  RAISE;
            END;
         END IF;



         IF LC_EXTEMP_LOANS = 'Y'
         THEN
            BEGIN
               SELECT ASSIGNMENT_ID, PAYROLL_ID
                 INTO LN_ASSIGNMENT_ID, LN_PAYROLL_ID
                 FROM PER_ALL_ASSIGNMENTS_F PAAF, PER_ALL_PEOPLE_F PAPF
                WHERE 1 = 1
                      AND LN_TRANSACTION_DATE BETWEEN PAAF.EFFECTIVE_START_DATE
                                                  AND PAAF.EFFECTIVE_END_DATE
                      AND LN_TRANSACTION_DATE BETWEEN PAPF.EFFECTIVE_START_DATE
                                                  AND PAPF.EFFECTIVE_END_DATE
                      AND PAAF.PERSON_ID = PAPF.PERSON_ID
                      AND TO_NUMBER (EMPLOYEE_NUMBER) = LN_EMPLOYEE_NUMBER;
            EXCEPTION
               WHEN OTHERS
               THEN
                  LOG_ERRORS (
                     'CREATE_PAYMENT_SCHEDULES =>ERROR AL BUSCAR EJECUCIONES ANTERIORES DE NOMINA LC_EXTEMP_LOANS = Y',
                     P_ERROR_MESSAGE   => SQLERRM);

                  RAISE;
            END;



            BEGIN
               SELECT EFFECTIVE_START_DATE, PERIOD_NAME
                 INTO LD_DATE_EARNED, LC_PERIOD_NAME
                 FROM (SELECT EFFECTIVE_START_DATE,
                              PERIOD_NAME,
                              ROW_NUMBER ()
                                 OVER (ORDER BY EFFECTIVE_START_DATE)
                                 PERIOD
                         FROM (  SELECT PEEF.EFFECTIVE_START_DATE, PERIOD_NAME
                                   FROM PAY_ELEMENT_ENTRIES_F PEEF,
                                        PAY_ELEMENT_ENTRY_VALUES_F PEEV,
                                        PER_ALL_ASSIGNMENTS_F PAV,
                                        PER_TIME_PERIODS PTP
                                  WHERE 1 = 1
                                        AND PEEF.EFFECTIVE_START_DATE =
                                               START_DATE
                                        AND PEEF.EFFECTIVE_END_DATE = END_DATE
                                        AND PAV.ASSIGNMENT_ID =
                                               PEEF.ASSIGNMENT_ID
                                        AND PTP.PAYROLL_ID = PAV.PAYROLL_ID
                                        AND LN_TRANSACTION_DATE BETWEEN PAV.EFFECTIVE_START_DATE
                                                                    AND PAV.EFFECTIVE_END_DATE
                                        AND PAV.ASSIGNMENT_ID =
                                               LN_ASSIGNMENT_ID
                                        AND PEEF.EFFECTIVE_START_DATE >=
                                               TO_DATE ('01/01/2016',
                                                        'dd/mm/yyyy')
                                        AND PEEF.ELEMENT_ENTRY_ID =
                                               PEEV.ELEMENT_ENTRY_ID
                                        AND ELEMENT_LINK_ID IN (73, 74, 2764)
                                        AND ELEMENT_TYPE_ID = 193
                                        AND INPUT_VALUE_ID = 647
                               ORDER BY EFFECTIVE_START_DATE))
                WHERE PERIOD = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  LOG_ERRORS (
                     'CREATE_PAYMENT_SCHEDULES =>ERROR BUSCANDO LOS PERIODOS'
                     || 'LOAN_ID: '
                     || P_LOAN_ID,
                     P_ERROR_MESSAGE   => SQLERRM);

                  BEGIN
                     SELECT ASSIGNMENT_ID,
                            PERIOD_NAME,
                            DATE_EARNED,
                            PAYROLL_ID
                       INTO LN_ASSIGNMENT_ID,
                            LC_PERIOD_NAME,
                            LD_DATE_EARNED,
                            LN_PAYROLL_ID
                       FROM (SELECT ASSIGNMENT_ID,
                                    PERIOD_NAME,
                                    DATE_EARNED,
                                    PAYROLL_ID,
                                    ROW_NUMBER ()
                                    OVER (PARTITION BY ASSIGNMENT_ID
                                          ORDER BY DATE_EARNED DESC)
                                       LATEST
                               FROM (  SELECT UNIQUE
                                              AAC.ASSIGNMENT_ID,
                                              PAC.EFFECTIVE_DATE,
                                              PAC.ACTION_TYPE,
                                              ASG.PAYROLL_ID,
                                              DECODE (
                                                 PAC.ACTION_TYPE,
                                                 'T', DECODE (
                                                         INSTRB (
                                                            PAC.LEGISLATIVE_PARAMETERS,
                                                            'SLA_MODE=Y'),
                                                         0, HR_GENERAL.DECODE_LOOKUP (
                                                               'TRANSFER_TO_LEDGER',
                                                               'GL'),
                                                         NULL, HR_GENERAL.DECODE_LOOKUP (
                                                                  'TRANSFER_TO_LEDGER',
                                                                  'GL'),
                                                         HR_GENERAL.DECODE_LOOKUP (
                                                            'TRANSFER_TO_LEDGER',
                                                            'SLA')),
                                                 LO1.MEANING)
                                                 TYPE,
                                              HR_PAYROLLS.DISPLAY_PERIOD_NAME (
                                                 PAC.PAYROLL_ACTION_ID)
                                                 PERIOD_NAME,
                                              PEO.FULL_NAME,
                                              PEO.EFFECTIVE_START_DATE
                                                 PEO_START_DATE,
                                              PEO.EFFECTIVE_END_DATE
                                                 PEO_END_DATE,
                                              ASG.ASSIGNMENT_NUMBER,
                                              ASG.EFFECTIVE_START_DATE
                                                 ASG_START_DATE,
                                              ASG.EFFECTIVE_END_DATE
                                                 ASG_END_DATE,
                                              AAC.ACTION_STATUS STATUS_CODE,
                                              PAY_ASSIGNMENT_ACTIONS_PKG.GET_ACTION_STATUS (
                                                 AAC.ASSIGNMENT_ACTION_ID,
                                                 PAC.ACTION_TYPE,
                                                 AAC.ACTION_STATUS)
                                                 ACTION_STATUS,
                                              PAC.DATE_EARNED
                                         FROM PER_ASSIGNMENTS_F2 ASG,
                                              PER_PEOPLE_F PEO,
                                              HR_LOOKUPS LO1,
                                              PAY_PAYROLL_ACTIONS PAC,
                                              PAY_ASSIGNMENT_ACTIONS AAC
                                        WHERE AAC.ASSIGNMENT_ID =
                                                 ASG.ASSIGNMENT_ID
                                              AND ASG.PERSON_ID = PEO.PERSON_ID
                                              AND LO1.LOOKUP_TYPE =
                                                     'ACTION_TYPE'
                                              AND LO1.LOOKUP_CODE =
                                                     PAC.ACTION_TYPE
                                              AND AAC.PAYROLL_ACTION_ID =
                                                     PAC.PAYROLL_ACTION_ID
                                              AND PAC.ACTION_TYPE IN ('R', 'Q') /* INCLUDES RUN TYPE */
                                              AND LN_TRANSACTION_DATE BETWEEN ASG.EFFECTIVE_START_DATE
                                                                          AND ASG.EFFECTIVE_END_DATE
                                              AND PAC.EFFECTIVE_DATE BETWEEN PEO.EFFECTIVE_START_DATE
                                                                         AND PEO.EFFECTIVE_END_DATE
                                              AND PAC.EFFECTIVE_DATE BETWEEN ASG.EFFECTIVE_START_DATE
                                                                         AND ASG.EFFECTIVE_END_DATE
                                              AND PAC.PAYROLL_ID =
                                                     ASG.PAYROLL_ID
                                              AND TO_NUMBER (
                                                     PEO.EMPLOYEE_NUMBER) =
                                                     LN_EMPLOYEE_NUMBER
                                              AND LN_TRANSACTION_DATE >=
                                                     DATE_EARNED
                                     ORDER BY PAC.DATE_EARNED DESC))
                      WHERE LATEST = 1;
                  END;
            END;
         END IF;

         DBMS_OUTPUT.PUT_LINE (' ASSIGNMENT: ' || LN_ASSIGNMENT_ID);
         DBMS_OUTPUT.PUT_LINE (' Ultimo periodo de pago: ' || LC_PERIOD_NAME);
         DBMS_OUTPUT.PUT_LINE (' Fecha de pago: ' || LD_DATE_EARNED);
         DBMS_OUTPUT.PUT_LINE (' Payroll_id: ' || LN_PAYROLL_ID);


         IF LC_EXTEMP_LOANS = 'Y'
         THEN
            LN_TRANSACTION_DATE := TO_DATE (LN_TRANSACTION_DATE) - 1;
         END IF;


         BEGIN
            FOR SCHEDULE IN C_PAYMENT_SEQUENCE
            LOOP
               BEGIN
                  DBMS_OUTPUT.PUT_LINE (
                     ' Secuencia de cobro: ' || SCHEDULE.PERIOD_SEQUENCE);
                  DBMS_OUTPUT.PUT_LINE (
                     ' Periodo de nomina: ' || SCHEDULE.PERIOD_NUM);
                  DBMS_OUTPUT.PUT_LINE (
                     ' Nombre del periodo: ' || SCHEDULE.PERIOD_NAME);
                  DBMS_OUTPUT.PUT_LINE (
                     ' FECHA DE COBRO: ' || SCHEDULE.END_DATE);



                  LN_LOAN_BALANCE := LN_LOAN_BALANCE - TRUNC(LN_PARTIAL_AMOUNT,2);
                  LN_ACCRUED_PAYMENTS :=
                     LN_ACCRUED_PAYMENTS + TRUNC(LN_PARTIAL_AMOUNT,2);
                  LN_ACCRUED_INTEREST :=
                     LN_ACCRUED_INTEREST + TRUNC(LN_PAYMENT_INTEREST,2);
                  LN_ACCRUED_CAPITAL :=
                     LN_ACCRUED_CAPITAL + TRUNC(LN_CAPITAL_PAYMENT,2);

                  DBMS_OUTPUT.PUT_LINE (
                     ' PAGO TOTAL ACUMULADO: ' || LN_ACCRUED_PAYMENTS);
                  DBMS_OUTPUT.PUT_LINE (
                     ' CAPITAL ACUMULADO: ' || LN_ACCRUED_CAPITAL);
                  DBMS_OUTPUT.PUT_LINE (
                     ' INTERES ACUMULADO: ' || LN_ACCRUED_INTEREST);

                  IF LN_LOAN_BALANCE <> 0
                     AND SCHEDULE.PERIOD_SEQUENCE = LN_TERM_PERIODS
                  THEN
                     LN_PARTIAL_AMOUNT := LN_PARTIAL_AMOUNT + LN_LOAN_BALANCE;

                     LN_ACCRUED_PAYMENTS :=
                        LN_ACCRUED_PAYMENTS + LN_LOAN_BALANCE;

                     IF LN_LOAN_AMOUNT <> LN_ACCRUED_CAPITAL
                     THEN
                        LN_CAPITAL_PAYMENT :=
                           LN_CAPITAL_PAYMENT
                           + (LN_LOAN_AMOUNT - LN_ACCRUED_CAPITAL);
                     END IF;

                     IF LN_LOAN_INTEREST_AMOUNT <> LN_ACCRUED_INTEREST
                     THEN
                        LN_PAYMENT_INTEREST :=
                           LN_PAYMENT_INTEREST
                           + (LN_LOAN_INTEREST_AMOUNT - LN_ACCRUED_INTEREST);
                     END IF;



                     LN_LOAN_BALANCE := LN_LOAN_BALANCE - LN_LOAN_BALANCE;
                  END IF;

                  INSERT
                    INTO ATET_SB_PAYMENTS_SCHEDULE (LOAN_ID,
                                                    TIME_PERIOD_ID,
                                                    PAYMENT_NUMBER,
                                                    PERIOD_NUMBER,
                                                    PERIOD_NAME,
                                                    PAYMENT_DATE,
                                                    PAYROLL_ID,
                                                    ASSIGNMENT_ID,
                                                    OPENING_BALANCE,
                                                    ACCRUAL_PAYMENT_AMOUNT,
                                                    PAYMENT_AMOUNT,
                                                    PAYMENT_CAPITAL,
                                                    FINAL_BALANCE,
                                                    PAYMENT_INTEREST,
                                                    STATUS_FLAG,
                                                    PAYMENT_INTEREST_LATE,
                                                    CREATION_DATE,
                                                    CREATED_BY,
                                                    LAST_UPDATE_DATE,
                                                    LAST_UPDATED_BY)
                  VALUES (LN_LOAN_ID,
                          SCHEDULE.TIME_PERIOD_ID,
                          SCHEDULE.PERIOD_SEQUENCE,
                          SCHEDULE.PERIOD_NUM,
                          SCHEDULE.PERIOD_NAME,
                          SCHEDULE.END_DATE,
                          LN_PAYROLL_ID,
                          LN_ASSIGNMENT_ID,
                          LN_OPENING_BALANCE,
                          LN_ACCRUED_PAYMENTS,
                          LN_PARTIAL_AMOUNT,
                          LN_CAPITAL_PAYMENT,
                          LN_LOAN_BALANCE,
                          LN_PAYMENT_INTEREST,
                          LN_CREATION_STATUS_FLAG,
                          0,
                          SYSDATE,
                          FND_GLOBAL.USER_ID,
                          SYSDATE,
                          FND_GLOBAL.USER_ID);

                  LN_OPENING_BALANCE := LN_OPENING_BALANCE - LN_PARTIAL_AMOUNT;
                  LC_LAST_PAYMENT_DATE := SCHEDULE.END_DATE;
               --                  COMMIT;
               END;
            END LOOP;

            P_LAST_PAYMENT_DATE := LC_LAST_PAYMENT_DATE;
         END;
      ELSE
         IF LN_PAYMENT_SCHEDULE_EXISTS <> 0
         THEN
            DBMS_OUTPUT.PUT_LINE ('El payment schedule ya existe');
         END IF;

         IF LN_LOAN_EXISTS = 0
         THEN
            DBMS_OUTPUT.PUT_LINE ('El prestamo no existe');
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         LOG_ERRORS (
            'CREATE_PAYMENT_SCHEDULES =>ERROR FATAL EN TODO EL PROCEDIMIENTO',
            P_ERROR_MESSAGE   => SQLERRM);

         RAISE;
   END;



   PROCEDURE CREATE_LOAN_HOLD (P_LOAN_ID             NUMBER,
                               HOLD_REASON_CODE   IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      DBMS_OUTPUT.PUT_LINE ('Se ha creado la retención');

      INSERT INTO ATET_SB_LOAN_HOLDS (CREATION_DATE,
                                      CREATED_BY,
                                      LAST_UPDATE_DATE,
                                      LAST_UPDATED_BY,
                                      HOLD_SOURCE_ID,
                                      LOAN_ID,
                                      HOLD_REASON_CODE,
                                      RELEASED_FLAG)
           VALUES (SYSDATE,
                   FND_GLOBAL.USER_ID,
                   SYSDATE,
                   FND_GLOBAL.USER_ID,
                   1,
                   P_LOAN_ID,
                   NVL (HOLD_REASON_CODE, 'HOLD'),
                   'N');

      COMMIT;
   END;

   PROCEDURE RELEASE_LOAN_HOLD (
      ERRBUF                    OUT NOCOPY VARCHAR2,
      RETCODE                   OUT NOCOPY VARCHAR2,
      P_LOAN_ID                            NUMBER,
      P_REASON_DESCRIPTION                 VARCHAR2,
      P_RELEASE_FLAG                       VARCHAR2)
   IS
      LN_LOAN_HOLD_ID        NUMBER;
      LN_LOAN_ID             NUMBER;
      LC_RELEASED_FLAG       VARCHAR2 (15);
      LN_HOLD_RELEASE_ID     NUMBER;
      LC_IS_REFINANCE_LOAN   VARCHAR2 (150);
   BEGIN
      IF P_RELEASE_FLAG = 'Y'
      THEN
         DBMS_OUTPUT.PUT_LINE ('Buscando la retención');

         BEGIN
            SELECT LOAN_HOLD_ID,
                   LOAN_ID,
                   RELEASED_FLAG,
                   HOLD_REASON_CODE
              INTO LN_LOAN_HOLD_ID,
                   LN_LOAN_ID,
                   LC_RELEASED_FLAG,
                   LC_IS_REFINANCE_LOAN
              FROM ATET_SB_LOAN_HOLDS
             WHERE LOAN_ID = P_LOAN_ID AND RELEASED_FLAG = 'N';
         EXCEPTION
            WHEN OTHERS
            THEN
               LOG_ERRORS (
                  'RELEASE_LOAN_HOLD =>ERROR AL BUSCAR LA RETENCION DEL PRESTAMO',
                  P_ERROR_MESSAGE   => SQLERRM);

               DBMS_OUTPUT.PUT_LINE ('No se encontro la retencion');
               DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Error: ' || SQLERRM);
               RAISE;
         END;



         IF LC_IS_REFINANCE_LOAN = 'REFINANCE'
         THEN
            INSERT INTO ATET_SB_HOLD_RELEASES (CREATION_DATE,
                                               CREATED_BY,
                                               LAST_UPDATE_DATE,
                                               LAST_UPDATED_BY,
                                               RELEASE_REASON_CODE,
                                               RELEASE_COMMENT,
                                               LOAN_HOLD_ID)
                 VALUES (SYSDATE,
                         FND_GLOBAL.USER_ID,
                         SYSDATE,
                         FND_GLOBAL.USER_ID,
                         'RELEASED_REFINANCE',
                         P_REASON_DESCRIPTION,
                         LN_LOAN_HOLD_ID);

            COMMIT;

            DBMS_OUTPUT.PUT_LINE ('Este préstamo es un refinanciamiento');

            SELECT ATET_SB_HOLD_RELEASES_SEQ.CURRVAL
              INTO LN_HOLD_RELEASE_ID
              FROM DUAL;


            UPDATE ATET_SB_LOAN_HOLDS
               SET RELEASED_FLAG = 'Y',
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                   HOLD_RELEASE_ID = LN_HOLD_RELEASE_ID
             WHERE     LOAN_ID = P_LOAN_ID
                   AND RELEASED_FLAG = 'N'
                   AND LOAN_HOLD_ID = LN_LOAN_HOLD_ID;


            UPDATE ATET_SB_LOANS
               SET LOAN_STATUS_FLAG = 'REFINANCE',
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = FND_GLOBAL.USER_ID
             WHERE LOAN_ID = P_LOAN_ID;

            COMMIT;
         ELSE
            INSERT INTO ATET_SB_HOLD_RELEASES (CREATION_DATE,
                                               CREATED_BY,
                                               LAST_UPDATE_DATE,
                                               LAST_UPDATED_BY,
                                               RELEASE_REASON_CODE,
                                               RELEASE_COMMENT,
                                               LOAN_HOLD_ID)
                 VALUES (SYSDATE,
                         FND_GLOBAL.USER_ID,
                         SYSDATE,
                         FND_GLOBAL.USER_ID,
                         'RELEASED',
                         P_REASON_DESCRIPTION,
                         LN_LOAN_HOLD_ID);


            SELECT ATET_SB_HOLD_RELEASES_SEQ.CURRVAL
              INTO LN_HOLD_RELEASE_ID
              FROM DUAL;


            UPDATE ATET_SB_LOAN_HOLDS
               SET RELEASED_FLAG = 'Y',
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                   HOLD_RELEASE_ID = LN_HOLD_RELEASE_ID
             WHERE     LOAN_ID = P_LOAN_ID
                   AND RELEASED_FLAG = 'N'
                   AND LOAN_HOLD_ID = LN_LOAN_HOLD_ID;


            UPDATE ATET_SB_LOANS
               SET LOAN_STATUS_FLAG = 'APPROVED',
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = FND_GLOBAL.USER_ID
             WHERE LOAN_ID = P_LOAN_ID;

            COMMIT;

            DBMS_OUTPUT.PUT_LINE ('Se ha liberado la retención');
         END IF;
      ELSE
         SELECT LOAN_HOLD_ID, LOAN_ID, RELEASED_FLAG
           INTO LN_LOAN_HOLD_ID, LN_LOAN_ID, LC_RELEASED_FLAG
           FROM ATET_SB_LOAN_HOLDS
          WHERE LOAN_ID = P_LOAN_ID AND RELEASED_FLAG = 'N';

         DBMS_OUTPUT.PUT_LINE (
            'Se ha rechazado la lineración de la retención');

         INSERT INTO ATET_SB_HOLD_RELEASES (CREATION_DATE,
                                            CREATED_BY,
                                            LAST_UPDATE_DATE,
                                            LAST_UPDATED_BY,
                                            RELEASE_REASON_CODE,
                                            RELEASE_COMMENT,
                                            LOAN_HOLD_ID)
              VALUES (SYSDATE,
                      FND_GLOBAL.USER_ID,
                      SYSDATE,
                      FND_GLOBAL.USER_ID,
                      'REJECTED',
                      P_REASON_DESCRIPTION,
                      LN_LOAN_HOLD_ID);

         SELECT ATET_SB_HOLD_RELEASES_SEQ.CURRVAL
           INTO LN_HOLD_RELEASE_ID
           FROM DUAL;


         UPDATE ATET_SB_LOAN_HOLDS
            SET RELEASED_FLAG = 'R',
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                HOLD_RELEASE_ID = LN_HOLD_RELEASE_ID
          WHERE     LOAN_ID = P_LOAN_ID
                AND RELEASED_FLAG = 'N'
                AND LOAN_HOLD_ID = LN_LOAN_HOLD_ID;


         UPDATE ATET_SB_LOANS
            SET LOAN_STATUS_FLAG = 'REJECTED',
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATED_BY = FND_GLOBAL.USER_ID
          WHERE LOAN_ID = P_LOAN_ID;

         COMMIT;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         LOG_ERRORS ('RELEASE_LOAN_HOLD =>LA RETENCION NO EXISTE',
                     P_ERROR_MESSAGE   => SQLERRM);

         DBMS_OUTPUT.PUT_LINE ('No existe la retención');
         DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
         FND_FILE.PUT_LINE (FND_FILE.LOG, 'Error: ' || SQLERRM);
         RAISE;
   END;

   FUNCTION FIND_CROSS_ENDORSEMENT (P_MEMBER_BORROWER_ID       NUMBER,
                                    P_MEMBER_ENDORSEMENT_ID    NUMBER)
      RETURN NUMBER
   IS
      LN_PARTICIPANTES   NUMBER := 0;
   BEGIN
        SELECT PARTICIPANTES
          INTO LN_PARTICIPANTES
          FROM (    SELECT MEMBER_BORROWER_ID,
                           MEMBER_ENDORSEMENT_ID,
                           LEVEL PARTICIPANTES,
                           CONNECT_BY_ISCYCLE CICLICO
                      FROM (SELECT MEMBER_BORROWER_ID, MEMBER_ENDORSEMENT_ID
                              FROM ATET_SB_ENDORSEMENTS
                            UNION
                            (SELECT P_MEMBER_BORROWER_ID MEMBER_BORROWER_ID,
                                    P_MEMBER_ENDORSEMENT_ID MEMBER_ENDORSEMENT_ID
                               FROM DUAL))
                START WITH MEMBER_BORROWER_ID = P_MEMBER_BORROWER_ID
                CONNECT BY NOCYCLE PRIOR MEMBER_BORROWER_ID =
                                      MEMBER_ENDORSEMENT_ID
                  ORDER BY LEVEL)
         WHERE CICLICO > 0
      ORDER BY 1;

      RETURN (LN_PARTICIPANTES);
   EXCEPTION
      WHEN OTHERS
      THEN
         --         LOG_ERRORS (
         --            'FIND_CROSS_ENDORSEMENT =>ERROR AL BUSCAR AVALES CRUZADOS',
         --            P_ERROR_MESSAGE   => SQLERRM);

         RETURN (LN_PARTICIPANTES);
   END FIND_CROSS_ENDORSEMENT;

   PROCEDURE CREATE_LOAN_CHECK (P_LOAN_ID    IN            NUMBER,
                                P_CHECK_ID      OUT NOCOPY NUMBER)
   IS
      LN_BANK_ACCOUNT_ID           NUMBER;
      LC_BANK_ACCOUNT_NAME         VARCHAR2 (150);
      LC_BANK_ACCOUNT_NUM          VARCHAR2 (150);
      LC_BANK_NAME                 VARCHAR2 (150);
      LC_CURRENCY_CODE             VARCHAR2 (150);
      LN_MEMBER_ID                 NUMBER;
      LC_EMPLOYEE_FULL_NAME        VARCHAR2 (300);
      LN_LOAN_AMOUNT               NUMBER;
      LN_LOAN_TOTAL_AMOUNT         NUMBER;
      LN_LOAN_INTEREST_AMOUNT      NUMBER;
      LN_LOAN_ID                   NUMBER;
      LN_EXTEMP_CHECK_NUMBER       NUMBER;

      --      LN_REFINANCE_AMOUNT        NUMBER;
      LN_LOAN_NUMBER               NUMBER;
      LD_TRANSACTION_DATE          DATE;
      LN_CHECK_NUMBER              NUMBER;
      LN_CHECK_ID                  NUMBER;
      P_ENTITY_CODE                VARCHAR2 (150);
      P_EVENT_TYPE_CODE            VARCHAR2 (150);
      P_INTEREST_EVENT_TYPE_CODE   VARCHAR2 (150);
      P_CHECK_EVENT_TYPE_CODE      VARCHAR2 (150);
      P_BATCH_NAME                 VARCHAR2 (150);
      P_JOURNAL_NAME               VARCHAR (150);
      LC_NOT_REC_CODE_COMB         NUMBER;
      LC_UNE_INT_CODE_COMB         NUMBER;
      LC_BANK_CODE_COMB            NUMBER;
      P_HEADER_ID                  NUMBER;
      LN_ROW_NUMBER                NUMBER := 1;
      INPUT_STRING                 VARCHAR2 (200);
      OUTPUT_STRING                VARCHAR2 (200);
      ENCRYPTED_RAW                RAW (2000); -- stores encrypted binary text
      DECRYPTED_RAW                RAW (2000); -- stores decrypted binary text
      NUM_KEY_BYTES                NUMBER := 256 / 8; -- key length 256 bits (32 bytes)
      KEY_BYTES_RAW                RAW (32);  -- stores 256-bit encryption key
      ENCRYPTION_TYPE              PLS_INTEGER
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
            LOG_ERRORS (
               'CREATE_LOAN_CHECK =>ERROR AL BUSCAR LA CUENTA BANCARIA',
               P_ERROR_MESSAGE   => SQLERRM);
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
                   TRANSACTION_DATE,
                   ATTRIBUTE3
              INTO LN_MEMBER_ID,
                   LN_LOAN_ID,
                   LN_LOAN_NUMBER,
                   LN_LOAN_TOTAL_AMOUNT,
                   LN_LOAN_INTEREST_AMOUNT,
                   LN_LOAN_AMOUNT,
                   LD_TRANSACTION_DATE,
                   LN_EXTEMP_CHECK_NUMBER
              FROM ATET_SB_LOANS ASL
             WHERE LOAN_ID = P_LOAN_ID
                   AND NOT EXISTS
                          (SELECT LOAN_ID
                             FROM ATET_LOAN_PAYMENTS_ALL ALPA
                            WHERE ALPA.LOAN_ID = ASL.LOAN_ID);
         EXCEPTION
            WHEN OTHERS
            THEN
               LOG_ERRORS (
                  'CREATE_LOAN_CHECK =>ERROR AL BUSCAR EL PRESTAMO O EL CHEQUE YA FUE GENERADO',
                  P_ERROR_MESSAGE   => SQLERRM);
               DBMS_OUTPUT.PUT_LINE (
                  'Error al buscar préstamo o el cheque ya fue generado');
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
               LOG_ERRORS ('CREATE_LOAN_CHECK =>ERROR AL BUSCAR EL MIEBRO',
                           P_ERROR_MESSAGE   => SQLERRM);
               DBMS_OUTPUT.PUT_LINE ('Error al buscar el miembro');
               RAISE;
         END;



         BEGIN
            BEGIN
               SELECT ATET_SB_CHECKS_ALL_SEQ.NEXTVAL
                 INTO LN_CHECK_ID
                 FROM DUAL;


               IF LN_EXTEMP_CHECK_NUMBER IS NULL
               THEN
                  SELECT ATET_SB_CHECK_NUMBER_SEQ.NEXTVAL
                    INTO LN_CHECK_NUMBER
                    FROM DUAL;
               ELSE
                  LN_CHECK_NUMBER := LN_EXTEMP_CHECK_NUMBER;
               END IF;
            END;


            INPUT_STRING :=
                  TO_CHAR (LN_LOAN_AMOUNT)
               || ','
               || LN_CHECK_ID
               || ','
               || LN_CHECK_NUMBER
               || ','
               || LN_MEMBER_ID
               || ','
               || FND_GLOBAL.USER_ID
               || ','
               || TO_CHAR (CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF');

            DBMS_OUTPUT.PUT_LINE ('Original string: ' || input_string);
            key_bytes_raw := DBMS_CRYPTO.RANDOMBYTES (num_key_bytes);
            encrypted_raw :=
               DBMS_CRYPTO.ENCRYPT (
                  src   => UTL_I18N.STRING_TO_RAW (input_string, 'AL32UTF8'),
                  typ   => encryption_type,
                  key   => key_bytes_raw);
            -- The encrypted value "encrypted_raw" can be used here

            decrypted_raw :=
               DBMS_CRYPTO.DECRYPT (src   => encrypted_raw,
                                    typ   => encryption_type,
                                    key   => key_bytes_raw);
            output_string := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
            DBMS_OUTPUT.PUT_LINE ('Cadena a encriptar: ' || input_string);
            DBMS_OUTPUT.PUT_LINE ('Cadena encriptada: ' || encrypted_raw);
            DBMS_OUTPUT.PUT_LINE ('LLave: ' || key_bytes_raw);
            DBMS_OUTPUT.PUT_LINE ('Decrypted string: ' || output_string);
         EXCEPTION
            WHEN OTHERS
            THEN
               LOG_ERRORS (
                  'CREATE_LOAN_CHECK =>ERROR AL GENERAR LA FIRMA DIGITAL',
                  P_ERROR_MESSAGE   => SQLERRM);

               DBMS_OUTPUT.PUT_LINE ('Error al generar  fima digital');
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
                                            CREATION_DATE)
                 VALUES (LN_CHECK_ID,
                         LN_LOAN_AMOUNT,
                         LN_BANK_ACCOUNT_ID,
                         LC_BANK_ACCOUNT_NAME,
                         SYSDATE,
                         LN_CHECK_NUMBER,
                         LC_CURRENCY_CODE,
                         'CHECK_LOAN',
                         'CREATED',
                         LN_MEMBER_ID,
                         LC_EMPLOYEE_FULL_NAME,
                         LC_BANK_ACCOUNT_NUM,
                         ENCRYPTED_RAW,
                         KEY_BYTES_RAW,
                         FND_GLOBAL.USER_ID,
                         SYSDATE,
                         FND_GLOBAL.USER_ID,
                         SYSDATE);

            P_CHECK_ID := LN_CHECK_ID;
         --            COMMIT;
         EXCEPTION
            WHEN OTHERS
            THEN
               LOG_ERRORS (
                  'CREATE_LOAN_CHECK =>ERROR AL INSERTAR EN LA TABLA DE CHEQUES',
                  P_ERROR_MESSAGE   => SQLERRM);
               DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
               ROLLBACK;
               RAISE;
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
                 VALUES (LN_LOAN_AMOUNT,
                         1,
                         LN_CHECK_ID,
                         LN_LOAN_ID,
                         'LOAN_CHECK',
                         FND_GLOBAL.USER_ID,
                         SYSDATE,
                         FND_GLOBAL.USER_ID,
                         SYSDATE);

            --            COMMIT;

            BEGIN
               P_ENTITY_CODE := 'LOANS';
               P_EVENT_TYPE_CODE := 'LOAN_CREATION';
               P_INTEREST_EVENT_TYPE_CODE := 'LOAN_INTEREST';
               P_CHECK_EVENT_TYPE_CODE := 'LOAN_CHECK';

               P_BATCH_NAME := 'PRESTAMO CAJA DE AHORRO';
               P_JOURNAL_NAME :=
                  'PRESTAMO CAJA DE AHORRO A: ' || LC_EMPLOYEE_FULL_NAME;
               P_HEADER_ID := NULL;

               ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (P_ENTITY_CODE,
                                                          P_EVENT_TYPE_CODE,
                                                          P_BATCH_NAME,
                                                          P_JOURNAL_NAME,
                                                          P_HEADER_ID);

               DBMS_OUTPUT.PUT_LINE ('HEADER_ID: ' || P_HEADER_ID);

               IF ATET_SAVINGS_BANK_PKG.GET_MEMBER_IS_SAVER (LN_MEMBER_ID) =
                     'Y'
               THEN
                  SELECT ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID (
                            (SELECT ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                                       'NOT_REC_SAV_CODE_COMB',
                                       (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                                          FROM DUAL))
                                       CONCATENATED_SEGMENTS
                               FROM DUAL))
                    INTO LC_NOT_REC_CODE_COMB
                    FROM DUAL CCID;
               ELSE
                  SELECT ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID (
                            (SELECT ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                                       'NOT_REC_NO_SAV_CODE_COMB',
                                       (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                                          FROM DUAL))
                                       CONCATENATED_SEGMENTS
                               FROM DUAL))
                    INTO LC_NOT_REC_CODE_COMB
                    FROM DUAL CCID;
               END IF;


               SELECT ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID (
                         (SELECT ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                                    'UNE_INT_CODE_COMB',
                                    (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                                       FROM DUAL))
                                    CONCATENATED_SEGMENTS
                            FROM DUAL))
                 INTO LC_UNE_INT_CODE_COMB
                 FROM DUAL CCID;



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
                  P_ROW_NUMBER              => 1,
                  P_CODE_COMBINATION_ID     => LC_NOT_REC_CODE_COMB,
                  P_ACCOUNTING_CLASS_CODE   => P_EVENT_TYPE_CODE,
                  P_ACCOUNTED_DR            => LN_LOAN_TOTAL_AMOUNT,
                  P_ACCOUNTED_CR            => 0,
                  P_DESCRIPTION             =>   'PRESTAMO A: '
                                              || LC_EMPLOYEE_FULL_NAME
                                              || ' '
                                              || LN_LOAN_NUMBER,
                  P_SOURCE_ID               => ln_loan_id,
                  P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');

               ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
                  P_HEADER_ID               => P_HEADER_ID,
                  P_ROW_NUMBER              => 2,
                  P_CODE_COMBINATION_ID     => LC_BANK_CODE_COMB,
                  P_ACCOUNTING_CLASS_CODE   => P_CHECK_EVENT_TYPE_CODE,
                  P_ACCOUNTED_DR            => 0,
                  P_ACCOUNTED_CR            => LN_LOAN_AMOUNT,
                  P_DESCRIPTION             => 'NUMERO DE CHEQUE:  '
                                              || LN_CHECK_NUMBER,
                  P_SOURCE_ID               => LN_CHECK_ID,
                  P_SOURCE_LINK_TABLE       => 'ATET_SB_CHECKS_ALL');


               ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
                  P_HEADER_ID               => P_HEADER_ID,
                  P_ROW_NUMBER              => 3,
                  P_CODE_COMBINATION_ID     => LC_UNE_INT_CODE_COMB,
                  P_ACCOUNTING_CLASS_CODE   => P_INTEREST_EVENT_TYPE_CODE,
                  P_ACCOUNTED_DR            => 0,
                  P_ACCOUNTED_CR            => LN_LOAN_INTEREST_AMOUNT,
                  P_DESCRIPTION             => 'INTERESES DEL PRESTAMO: '
                                              || LN_LOAN_NUMBER,
                  P_SOURCE_ID               => ln_loan_id,
                  P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');

               COMMIT;
            END;
         EXCEPTION
            WHEN OTHERS
            THEN
               LOG_ERRORS ('CREATE_LOAN_CHECK =>ERROR AL CREAR XLA LINES',
                           P_ERROR_MESSAGE   => SQLERRM);

               DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
               RAISE;
         END;
      EXCEPTION
         WHEN OTHERS
         THEN
            LOG_ERRORS (
               'CREATE_LOAN_CHECK =>ERROR FALTAL EN EL PROCESO CREATE_LOAN_CHECK',
               P_ERROR_MESSAGE   => SQLERRM);

            DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
            ROLLBACK;
            RAISE;
      END;
   END CREATE_LOAN_CHECK;


   FUNCTION CHECK_CCID (P_SOB_ID IN INTEGER, P_CCID IN INTEGER)
      RETURN BOOLEAN
   IS
      CURSOR C_CHECK
      IS
         SELECT 'x'
           FROM GL_CODE_COMBINATIONS GCC, GL_SETS_OF_BOOKS GSOB
          WHERE     GSOB.SET_OF_BOOKS_ID = P_SOB_ID
                AND GCC.CODE_COMBINATION_ID = P_CCID
                AND GCC.CHART_OF_ACCOUNTS_ID = GSOB.CHART_OF_ACCOUNTS_ID
                AND GCC.ENABLED_FLAG = 'Y';

      P_CHECK   C_CHECK%ROWTYPE;
   BEGIN
      OPEN C_CHECK;

      FETCH C_CHECK INTO P_CHECK;

      IF C_CHECK%NOTFOUND
      THEN
         CLOSE C_CHECK;

         RETURN FALSE;
      END IF;

      CLOSE C_CHECK;

      RETURN TRUE;
   END CHECK_CCID;

   PROCEDURE CREATE_XLA_HEADER (P_ENTITY_CODE       IN            VARCHAR2,
                                P_EVENT_TYPE_CODE   IN            VARCHAR2,
                                P_BATCH_NAME        IN            VARCHAR,
                                P_JOURNAL_NAME      IN            VARCHAR,
                                P_HEADER_ID            OUT NOCOPY NUMBER)
   IS
      LN_HEADER_ID   NUMBER;
   BEGIN
      SELECT ATET_XLA_HEADERS_SEQ.NEXTVAL INTO LN_HEADER_ID FROM DUAL;

      P_HEADER_ID := LN_HEADER_ID;

      INSERT INTO ATET_XLA_HEADERS (HEADER_ID,
                                    ENTITY_CODE,
                                    EVENT_TYPE_CODE,
                                    GL_TRANSFER_STATUS,
                                    BATCH_NAME,
                                    JOURNAL_NAME,
                                    LEDGER_ID,
                                    ACCOUNTING_DATE,
                                    GL_TRANSFER_DATE,
                                    PERIOD_NAME,
                                    REQUEST_ID,
                                    CREATION_DATE,
                                    CREATED_BY,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATED_BY)
           VALUES (LN_HEADER_ID,
                   P_ENTITY_CODE,
                   P_EVENT_TYPE_CODE,
                   'P',
                   P_BATCH_NAME,
                   P_JOURNAL_NAME,
                   2084,
                   TRUNC (SYSDATE),
                   NULL,
                   NULL,
                   NULL,
                   SYSDATE,
                   FND_GLOBAL.USER_ID,
                   SYSDATE,
                   FND_GLOBAL.USER_ID);

      --      COMMIT;

      NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         LOG_ERRORS ('CREATE_XLA_HEADER =>ERROR AL CREAR XLA HEADERS',
                     P_ERROR_MESSAGE   => SQLERRM);
         DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
         RAISE;
   END;


   PROCEDURE CREATE_XLA_LINES (P_HEADER_ID               IN NUMBER,
                               P_ROW_NUMBER                 NUMBER,
                               P_CODE_COMBINATION_ID        NUMBER,
                               P_ACCOUNTING_CLASS_CODE      VARCHAR2,
                               P_ACCOUNTED_DR               NUMBER,
                               P_ACCOUNTED_CR               NUMBER,
                               P_DESCRIPTION                VARCHAR2,
                               P_SOURCE_ID                  NUMBER,
                               P_SOURCE_LINK_TABLE          VARCHAR2)
   IS
   BEGIN
      INSERT INTO ATET_XLA_LINES (HEADER_ID,
                                  LINE_NUMBER,
                                  CODE_COMBINATION_ID,
                                  GL_TRANSFER_MODE_CODE,
                                  ACCOUNTING_CLASS_CODE,
                                  DESCRIPTION,
                                  ACCOUNTED_DR,
                                  ACCOUNTED_CR,
                                  CURRENCY_CODE,
                                  REQUEST_ID,
                                  ACCOUNTING_DATE,
                                  LEDGER_ID,
                                  SOURCE_ID,
                                  SOURCE_LINK_TABLE,
                                  CREATION_DATE,
                                  CREATED_BY,
                                  LAST_UPDATE_DATE,
                                  LAST_UPDATED_BY)
           VALUES (P_HEADER_ID,
                   P_ROW_NUMBER,
                   P_CODE_COMBINATION_ID,
                   'P',
                   P_ACCOUNTING_CLASS_CODE,
                   P_DESCRIPTION,
                   P_ACCOUNTED_DR,
                   P_ACCOUNTED_CR,
                   'MXN',
                   NULL,
                   NULL,
                   2084,
                   P_SOURCE_ID,
                   P_SOURCE_LINK_TABLE,
                   SYSDATE,
                   FND_GLOBAL.USER_ID,
                   SYSDATE,
                   FND_GLOBAL.USER_ID);
   --      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         LOG_ERRORS ('CREATE_XLA_LINES =>ERROR AL CREAR XLA LINES',
                     P_ERROR_MESSAGE   => SQLERRM);
         DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
         RAISE;
   END;

   FUNCTION SUBMIT_GL_IMPORT (p_gl_access_set_id   IN NUMBER,
                              p_ledger_id          IN NUMBER,
                              p_je_source_name     IN VARCHAR2,
                              p_group_id           IN NUMBER)
      RETURN NUMBER
   IS
      l_request_id      NUMBER;
      l_call_status     BOOLEAN;
      l_request_print   BOOLEAN;
      l_rphase          VARCHAR2 (80);
      l_rstatus         VARCHAR2 (80);
      l_dphase          VARCHAR2 (30);
      l_dstatus         VARCHAR2 (30);
      l_message         VARCHAR2 (240);

      l_ledger_id       NUMBER;
   BEGIN
      l_request_id :=
         APPS.fnd_request.submit_request ('SQLGL',
                                          'GLLEZLSRS',
                                          '',
                                          '',
                                          FALSE,
                                          p_gl_access_set_id,
                                          p_je_source_name,
                                          p_ledger_id,
                                          p_group_id,
                                          'N',                   --post errors
                                          'N',               ---create summary
                                          'N'           --- import descriptive
                                             );

      COMMIT;


      IF l_request_id > 0
      THEN
         l_call_status :=
            fnd_Concurrent.wait_for_request (request_id   => l_request_id,
                                             INTERVAL     => 5,
                                             max_wait     => NULL,
                                             phase        => l_rphase,
                                             status       => l_rstatus,
                                             dev_phase    => l_dphase,
                                             dev_status   => l_dstatus,
                                             MESSAGE      => l_message);
      END IF;

      RETURN l_request_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         LOG_ERRORS ('SUBMIT_GL_IMPORT =>ERROR AL IMPORTAR A GL',
                     P_ERROR_MESSAGE   => SQLERRM);

         RETURN 0;
   END SUBMIT_GL_IMPORT;

   PROCEDURE TRANSFER_JOURNALS_TO_GL
   IS
      l_group_id          NUMBER;
      l_request_id        NUMBER;
      LC_SESS_LANGUAJE    VARCHAR2 (150);
      LC_JE_SOURCE_NAME   VARCHAR2 (150);

      CURSOR C_ATET_XLA_HEADERS
      IS
           SELECT HEADER_ID
             FROM ATET_XLA_HEADERS
            WHERE GL_TRANSFER_STATUS = 'P'
         GROUP BY HEADER_ID;

      CURSOR C_ATET_XLA_LINES (P_HEADER_ID IN NUMBER)
      IS
           SELECT AXH.HEADER_ID,
                  AXH.ENTITY_CODE,
                  AXH.EVENT_TYPE_CODE,
                  AXL.GL_TRANSFER_MODE_CODE,
                  AXH.BATCH_NAME,
                  AXH.PERIOD_NAME,
                  AXH.JOURNAL_NAME,
                  AXH.LEDGER_ID,
                  AXH.ACCOUNTING_DATE,
                  LINE_NUMBER,
                  CODE_COMBINATION_ID,
                  ACCOUNTING_CLASS_CODE,
                  DESCRIPTION,
                  ACCOUNTED_DR,
                  ACCOUNTED_CR,
                  CURRENCY_CODE,
                  SOURCE_ID,
                  AXH.GL_TRANSFER_STATUS
             FROM ATET_XLA_HEADERS AXH, ATET_XLA_LINES AXL
            WHERE AXH.HEADER_ID = AXL.HEADER_ID AND AXH.HEADER_ID = P_HEADER_ID
         ORDER BY HEADER_ID, LINE_NUMBER;
   BEGIN
      BEGIN
         SELECT USERENV ('LANG') INTO LC_SESS_LANGUAJE FROM DUAL;

         IF LC_SESS_LANGUAJE LIKE 'US'
         THEN
            LC_JE_SOURCE_NAME := 'Manual';
         ELSE
            LC_JE_SOURCE_NAME := 'Manuales';
         END IF;
      END;


      FOR XLA_HEADERS IN C_ATET_XLA_HEADERS
      LOOP
         SELECT gl_interface_control_s.NEXTVAL INTO l_group_id FROM DUAL;

         FOR XLA_LINES IN C_ATET_XLA_LINES (XLA_HEADERS.HEADER_ID)
         LOOP
            BEGIN
               INSERT INTO GL.GL_INTERFACE (Status,
                                            ledger_id,
                                            accounting_date,
                                            period_name,
                                            currency_code,
                                            date_created,
                                            created_by,
                                            actual_flag,
                                            user_je_category_name,
                                            user_je_source_name,
                                            entered_dr,
                                            entered_cr,
                                            code_combination_id,
                                            GROUP_ID,
                                            reference1,
                                            reference2,
                                            reference4,
                                            reference5,
                                            reference10)
                    VALUES ('NEW',
                            XLA_LINES.LEDGER_ID,
                            XLA_LINES.ACCOUNTING_DATE,
                            XLA_LINES.PERIOD_NAME,
                            XLA_LINES.CURRENCY_CODE,
                            SYSDATE,
                            apps.fnd_global.user_id,
                            'A',
                            'Diario',
                            LC_JE_SOURCE_NAME,
                            XLA_LINES.ACCOUNTED_DR,
                            XLA_LINES.ACCOUNTED_CR,
                            XLA_LINES.CODE_COMBINATION_ID,
                            L_GROUP_ID,
                            ------
                            XLA_LINES.BATCH_NAME,
                            XLA_LINES.BATCH_NAME,
                            XLA_LINES.JOURNAL_NAME,
                            XLA_LINES.JOURNAL_NAME,
                            XLA_LINES.DESCRIPTION);
            END;


            COMMIT;
         --            ROLLBACK;
         END LOOP;


         BEGIN
            DBMS_OUTPUT.PUT_LINE ('LC_JE_SOURCE_NAME: ' || LC_JE_SOURCE_NAME);

            --            fnd_global.apps_initialize (user_id        => 1159,
            --                                        resp_id        => 53698,
            --                                        resp_appl_id   => 101);

            fnd_global.apps_initialize (fnd_profile.VALUE ('USER_ID'),
                                        fnd_profile.VALUE ('RESP_ID'),
                                        fnd_profile.VALUE ('RESP_APPL_ID'));

            mo_global.set_policy_context ('S', 1349);

            l_request_id :=
               submit_gl_import (1061,
                                 2084,
                                 'Manual',
                                 l_group_id);
            DBMS_OUTPUT.PUT_LINE ('Reqid: ' || l_request_id);
         EXCEPTION
            WHEN OTHERS
            THEN
               LOG_ERRORS ('TRANSFER_JOURNALS_TO_GL =>ERROR EN GL_INTERFACE',
                           P_ERROR_MESSAGE   => SQLERRM);



               --COMMIT;

               ROLLBACK;


               UPDATE ATET_XLA_LINES
                  SET GL_TRANSFER_MODE_CODE = 'E'
                WHERE HEADER_ID = XLA_HEADERS.HEADER_ID;

               UPDATE ATET_XLA_HEADERS
                  SET GL_TRANSFER_STATUS = 'E'
                WHERE HEADER_ID = XLA_HEADERS.HEADER_ID;

               COMMIT;
               --               ROLLBACK;

               DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
               RAISE;
         END;

         UPDATE ATET_XLA_LINES
            SET GL_TRANSFER_MODE_CODE = 'S'
          WHERE HEADER_ID = XLA_HEADERS.HEADER_ID;

         UPDATE ATET_XLA_HEADERS
            SET GL_TRANSFER_STATUS = 'S'
          WHERE HEADER_ID = XLA_HEADERS.HEADER_ID;

         COMMIT;
      --         ROLLBACK;
      END LOOP;
   END;


   FUNCTION GET_PARAMETER_VALUE (P_PARAMETER_CODE    VARCHAR2,
                                 P_SAVING_BANK_ID    NUMBER)
      RETURN VARCHAR2
   IS
      LC_PARAMETER_VALUE   VARCHAR2 (200);
   BEGIN
      SELECT parameter_value
        INTO LC_PARAMETER_VALUE
        FROM ATET_SB_PARAMETERS
       WHERE parameter_code = P_PARAMETER_CODE
             AND saving_bank_id = P_SAVING_BANK_ID
             AND SYSDATE BETWEEN effective_start_date
                             AND NVL (effective_end_date,
                                      TO_DATE ('31/12/4712', 'DD/MM/YYYY'));

      RETURN LC_PARAMETER_VALUE;
   END;



   PROCEDURE REFINANCE_LOAN (
      ERRBUF                            OUT NOCOPY VARCHAR2,
      RETCODE                           OUT NOCOPY VARCHAR2,
      P_MEMBER_ID                    IN            NUMBER,
      --      P_PREVIOUS_LOAN_ID             IN            NUMBER,
      --      P_ACTUAL_LOAN_ID               IN            NUMBER,
      P_SUBSIDY_INTERES_PERCENTAJE   IN            NUMBER)
   IS
      LN_PREVIOUS_LOAN_BALANCE_DUE     NUMBER;
      LN_PREVIOUS_LOAN_ID              NUMBER;
      P_PREVIOUS_LOAN_ID               NUMBER;
      P_ACTUAL_LOAN_ID                 NUMBER;
      LN_ACTUAL_LOAN_AMOUNT            NUMBER;
      LN_ACTUAL_LOAN_ID                NUMBER;
      P_OUT_CHECK_ID                   NUMBER;
      LN_PAYMENT_DEADLINE              DATE;
      LN_MEMBER_ID                     NUMBER;
      LN_FIND_REFINANCE                NUMBER := 0;
      LN_PERSON_ID                     NUMBER;
      LN_ACTUAL_LOAN_TOTAL_AMOUNT      NUMBER;
      LN_PREVIOUS_LOAN_BALANCE_CALC    NUMBER;
      LN_CONDONATE_INTEREST_AMOUNT     NUMBER;
      LN_TRANSFER_INTEREST_AMOUNT      NUMBER;
      LN_ACTUAL_LOAN_CHECK_AMOUNT      NUMBER;
      LN_HAS_PREVIOUS_REFINANCED       NUMBER;
      LN_SUBSIDY_INTEREST_PERCENTAJE   NUMBER;

      CURSOR C_PREVIOUS_LOAN (
         P_SUBSIDY_INTEREST_PERCENTAJE NUMBER)
      IS
           SELECT ASL.LOAN_ID,
                  ASL.MEMBER_ID,
                  LOAN_NUMBER,
                  TRANSACTION_DATE,
                  LOAN_BALANCE,
                  LOAN_TOTAL_AMOUNT,
                  LOAN_AMOUNT,
                  LOAN_INTEREST_AMOUNT,
                  LOAN_TOTAL_AMOUNT - SUM (NVL (PAYMENT_AMOUNT, 0))
                     LOAN_BALANCE_CALC,
                  SUM (NVL (PAYMENT_AMOUNT, 0)) PAYMENT_AMOUNT,
                  SUM (NVL (PAYMENT_CAPITAL, 0)) PAYMENT_CAPITAL,
                  SUM (NVL (PAYMENT_INTEREST, 0)) PAYMENT_INTEREST,
                  LOAN_AMOUNT - SUM (NVL (PAYMENT_CAPITAL, 0)) CAPITAL_DUE,
                  LOAN_INTEREST_AMOUNT - SUM (NVL (PAYMENT_INTEREST, 0))
                     INTEREST_DUE,
                  (TO_NUMBER (
                      ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                         'INT_SUBSIDY',
                         (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                            FROM DUAL))))
                     PARAMETER_SUBSIDIZED_INTEREST,
                  (P_SUBSIDY_INTEREST_PERCENTAJE)
                     ENTERED_SUBSIDY_INT_PERCENTAJE,
                  (LOAN_INTEREST_AMOUNT - SUM (NVL (PAYMENT_INTEREST, 0)))
                  * ( (P_SUBSIDY_INTEREST_PERCENTAJE / 100))
                     SUBSIDY_INTEREST_AMOUNT,
                  (LOAN_INTEREST_AMOUNT - SUM (NVL (PAYMENT_INTEREST, 0)))
                  * (1 - (P_SUBSIDY_INTEREST_PERCENTAJE / 100))
                     TRANSFER_INTEREST_AMOUNT,
                  LAST_PAYMENT_DATE,
                  (LOAN_INTEREST_AMOUNT - SUM (NVL (PAYMENT_INTEREST, 0)))
                  * (1 - (P_SUBSIDY_INTEREST_PERCENTAJE / 100))
                  + (LOAN_AMOUNT - SUM (NVL (PAYMENT_CAPITAL, 0)))
                     TOTAL_BALANCE_DUE
             FROM ATET_SB_LOANS ASL, ATET_SB_LOANS_TRANSACTIONS ASLT
            WHERE     ASL.LOAN_ID = ASLT.LOAN_ID
                  AND ASLT.LOAN_ID = P_PREVIOUS_LOAN_ID
                  AND LOAN_STATUS_FLAG = 'ACTIVE'
         GROUP BY ASL.LOAN_ID,
                  ASL.MEMBER_ID,
                  LOAN_NUMBER,
                  TRANSACTION_DATE,
                  LOAN_BALANCE,
                  LOAN_TOTAL_AMOUNT,
                  LOAN_AMOUNT,
                  LOAN_INTEREST_AMOUNT,
                  LAST_PAYMENT_DATE,
                  LOAN_TOTAL_AMOUNT;


      CURSOR C_ACTUAL_LOAN
      IS
         SELECT LOAN_ID,
                MEMBER_ID,
                LOAN_BALANCE,
                LOAN_TOTAL_AMOUNT,
                LOAN_AMOUNT,
                TRANSACTION_DATE
           FROM ATET_SB_LOANS
          WHERE     LOAN_ID = P_ACTUAL_LOAN_ID
                AND LOAN_BALANCE = LOAN_TOTAL_AMOUNT
                AND LOAN_STATUS_FLAG = 'REFINANCE';
   BEGIN
      BEGIN
         SELECT LOAN_ID
           INTO P_PREVIOUS_LOAN_ID
           FROM ATET_SB_LOANS
          WHERE MEMBER_ID = P_MEMBER_ID AND LOAN_STATUS_FLAG = 'ACTIVE';

         SELECT LOAN_ID
           INTO P_ACTUAL_LOAN_ID
           FROM ATET_SB_LOANS
          WHERE MEMBER_ID = P_MEMBER_ID AND LOAN_STATUS_FLAG = 'REFINANCE';
      EXCEPTION
         WHEN OTHERS
         THEN
            LOG_ERRORS (
               'REFINANCE_LOAN =>ERROR AL BUSCAR EL PRESTAMO ANTERIOR Y ACTUAL',
               P_ERROR_MESSAGE   => SQLERRM);

            FND_FILE.PUT_LINE (
               FND_FILE.LOG,
               'Error al buscar préstamo actual y anterior: ' || SQLERRM);
            RAISE;
      END;



      BEGIN
         LN_SUBSIDY_INTEREST_PERCENTAJE := P_SUBSIDY_INTERES_PERCENTAJE;

         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            'Porcentaje calculado de condonación de intereses: '
            || LN_SUBSIDY_INTEREST_PERCENTAJE);



         SELECT COUNT (1)
           INTO LN_HAS_PREVIOUS_REFINANCED
           FROM ATET_SB_LOANS
          WHERE ATTRIBUTE2 IS NOT NULL AND MEMBER_ID = P_MEMBER_ID;

         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            'Cantidad de refinanciamientos: ' || LN_HAS_PREVIOUS_REFINANCED);

         IF LN_HAS_PREVIOUS_REFINANCED > 0
         THEN
            LN_SUBSIDY_INTEREST_PERCENTAJE := 0;

            FND_FILE.PUT_LINE (
               FND_FILE.LOG,
               'Porcentaje calculado de condonación de intereses: '
               || LN_SUBSIDY_INTEREST_PERCENTAJE);
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            LOG_ERRORS (
               'REFINANCE_LOAN =>ERROR AL BUSCAR SI TIENE OTROS PRESTAMOS REFINANCIADOS',
               P_ERROR_MESSAGE   => SQLERRM);
            FND_FILE.PUT_LINE (
               FND_FILE.LOG,
               'Error al buscar si tiene otros prestamos refinanciados: '
               || SQLERRM);
            RAISE;
      END;

      FND_FILE.PUT_LINE (
         FND_FILE.LOG,
         'Porcentaje calculado de condonación de intereses antes de abrir el cursor: '
         || LN_SUBSIDY_INTEREST_PERCENTAJE);

      FOR PREVIOUS_LOAN_REC
         IN C_PREVIOUS_LOAN (LN_SUBSIDY_INTEREST_PERCENTAJE)
      LOOP
         LN_PREVIOUS_LOAN_ID := PREVIOUS_LOAN_REC.LOAN_ID;
         LN_PREVIOUS_LOAN_BALANCE_DUE := PREVIOUS_LOAN_REC.TOTAL_BALANCE_DUE;
         LN_PREVIOUS_LOAN_BALANCE_CALC := PREVIOUS_LOAN_REC.LOAN_BALANCE_CALC;
         LN_TRANSFER_INTEREST_AMOUNT :=
            PREVIOUS_LOAN_REC.TRANSFER_INTEREST_AMOUNT;
         LN_CONDONATE_INTEREST_AMOUNT :=
            PREVIOUS_LOAN_REC.SUBSIDY_INTEREST_AMOUNT;

         LN_MEMBER_ID := PREVIOUS_LOAN_REC.MEMBER_ID;

         DBMS_OUTPUT.PUT_LINE (
            'Interés a transferir: ' || LN_TRANSFER_INTEREST_AMOUNT);
         DBMS_OUTPUT.PUT_LINE (
            'Interés condonado: ' || LN_CONDONATE_INTEREST_AMOUNT);
         DBMS_OUTPUT.PUT_LINE (
            'Balance a transferir: ' || LN_PREVIOUS_LOAN_BALANCE_DUE);

         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            'Interés a transferir: ' || LN_TRANSFER_INTEREST_AMOUNT);
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            'Interés condonado: ' || LN_CONDONATE_INTEREST_AMOUNT);
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            'Balance a transferir: ' || LN_PREVIOUS_LOAN_BALANCE_DUE);
      END LOOP;

      BEGIN
         SELECT COUNT (1)
           INTO LN_FIND_REFINANCE
           FROM ATET_SB_PAYMENTS_SCHEDULE
          WHERE LOAN_ID = LN_PREVIOUS_LOAN_ID AND STATUS_FLAG = 'REFINANCED';
      EXCEPTION
         WHEN OTHERS
         THEN
            LOG_ERRORS (
               'REFINANCE_LOAN =>ERROR AL BUSCAR SI TIENE PAGOS REFIANCIADOS POR MORA',
               P_ERROR_MESSAGE   => SQLERRM);
            FND_FILE.PUT_LINE (
               FND_FILE.LOG,
               'Error al buscar si tiene pagos refinanciados por mora: '
               || SQLERRM);
            RAISE;
      END;

      IF LN_FIND_REFINANCE = 0
      THEN
         FOR ACTUAL_LOAN_REC IN C_ACTUAL_LOAN
         LOOP
            LN_ACTUAL_LOAN_AMOUNT := ACTUAL_LOAN_REC.LOAN_AMOUNT;
            LN_ACTUAL_LOAN_TOTAL_AMOUNT := ACTUAL_LOAN_REC.LOAN_TOTAL_AMOUNT;
            LN_ACTUAL_LOAN_ID := ACTUAL_LOAN_REC.LOAN_ID;

            DBMS_OUTPUT.PUT_LINE (
               'Cantidad nuevo préstamo: ' || LN_ACTUAL_LOAN_AMOUNT);
            FND_FILE.PUT_LINE (
               FND_FILE.LOG,
               'Cantidad nuevo préstamo: ' || LN_ACTUAL_LOAN_AMOUNT);
         END LOOP;


         IF LN_ACTUAL_LOAN_AMOUNT >= LN_PREVIOUS_LOAN_BALANCE_DUE
         THEN
            LN_ACTUAL_LOAN_CHECK_AMOUNT :=
               TRUNC(LN_ACTUAL_LOAN_AMOUNT - LN_PREVIOUS_LOAN_BALANCE_DUE,2);

            DBMS_OUTPUT.PUT_LINE (
               'Pagaré del nuevo préstamo: ' || LN_ACTUAL_LOAN_TOTAL_AMOUNT);

            DBMS_OUTPUT.PUT_LINE (
               'Importe del nuevo cheque: ' || LN_ACTUAL_LOAN_CHECK_AMOUNT);

            FND_FILE.PUT_LINE (
               FND_FILE.LOG,
               'Pagaré del nuevo préstamo: ' || LN_ACTUAL_LOAN_TOTAL_AMOUNT);
            FND_FILE.PUT_LINE (
               FND_FILE.LOG,
               'Importe del nuevo cheque: ' || LN_ACTUAL_LOAN_CHECK_AMOUNT);

            BEGIN
               ATET_SB_BACK_OFFICE_PKG.CREATE_PAYMENTS_SCHEDULE (
                  LN_ACTUAL_LOAN_ID,
                  LN_PAYMENT_DEADLINE);

               UPDATE ATET_SB_LOANS
                  SET LOAN_STATUS_FLAG = 'ACTIVE',
                      PAYMENT_DEADLINE = LN_PAYMENT_DEADLINE
                WHERE LOAN_ID = LN_ACTUAL_LOAN_ID;

               --               COMMIT;


               BEGIN
                  CREATE_REFINANCE_LOAN_CHECK (LN_ACTUAL_LOAN_ID,
                                               LN_PREVIOUS_LOAN_ID,
                                               LN_PREVIOUS_LOAN_BALANCE_CALC,
                                               LN_TRANSFER_INTEREST_AMOUNT,
                                               LN_CONDONATE_INTEREST_AMOUNT,
                                               LN_ACTUAL_LOAN_CHECK_AMOUNT,
                                               LN_HAS_PREVIOUS_REFINANCED,
                                               NULL,
                                               P_OUT_CHECK_ID);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     LOG_ERRORS (
                        'REFINANCE_LOAN =>ERROR EN EL PROCEDIMIENTO CREATE_REFINANCE_LOAN_CHECK',
                        P_ERROR_MESSAGE   => SQLERRM);
                     FND_FILE.PUT_LINE (
                        FND_FILE.LOG,
                        'Error en CREATE_REFINANCE_LOAN_CHECK: ' || SQLERRM);
                     RAISE;
               END;

               UPDATE ATET_SB_LOANS
                  SET ATTRIBUTE2 = LN_ACTUAL_LOAN_ID
                WHERE LOAN_ID = LN_PREVIOUS_LOAN_ID;

               --               COMMIT;

               BEGIN
                  ATET_SB_BACK_OFFICE_PKG.PRINT_PREPAID (
                     LN_PREVIOUS_LOAN_ID,
                     LN_CONDONATE_INTEREST_AMOUNT);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     LOG_ERRORS (
                        'REFINANCE_LOAN =>ERROR AL IMPRIMIR EL DOCUMENTO DE LIQUIDACION DEL PRESTAMO',
                        P_ERROR_MESSAGE   => SQLERRM);

                     FND_FILE.PUT_LINE (
                        FND_FILE.LOG,
                        'Error al imprimir el documento de liquidación de préstamo: '
                        || SQLERRM);
               END;

               BEGIN
                  ATET_SAVINGS_BANK_PKG.SETTLEMENT_LOAN (LN_PREVIOUS_LOAN_ID);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     LOG_ERRORS (
                        'REFINANCE_LOAN =>ERROR EN EL PROCEDIMIENTO SETTLEMENT_LOAN',
                        P_ERROR_MESSAGE   => SQLERRM);

                     FND_FILE.PUT_LINE (
                        FND_FILE.LOG,
                        'Error en SETTLEMENT_LOAN: ' || SQLERRM);
                     RAISE;
               END;

               BEGIN
                  SELECT PERSON_ID
                    INTO LN_PERSON_ID
                    FROM ATET_SB_MEMBERS
                   WHERE MEMBER_ID = LN_MEMBER_ID;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     LOG_ERRORS (
                        'REFINANCE_LOAN =>ERROR AL BUSCAR EL MIEBRO',
                        P_ERROR_MESSAGE   => SQLERRM);

                     FND_FILE.PUT_LINE (
                        FND_FILE.LOG,
                        'Error al buscar miembro: ' || SQLERRM);
                     RAISE;
               END;

               BEGIN
                  IF ATET_SAVINGS_BANK_PKG.GET_MEMBER_IS_SAVER (
                        P_MEMBER_ID => LN_MEMBER_ID) = 'Y'
                  THEN
                     ATET_SAVINGS_BANK_PKG.CREATE_ACCOUNT (
                        P_PERSON_ID                => LN_PERSON_ID,
                        P_PARAM_ELEMENT_NAME       => 'LOAN_ELEMENT_NAME',
                        P_PARAM_CODE_COMBINATION   => 'LOAN_SAV_CODE_COMB');
                  ELSIF ATET_SAVINGS_BANK_PKG.GET_MEMBER_IS_SAVER (
                           P_MEMBER_ID => LN_MEMBER_ID) = 'N'
                  THEN
                     ATET_SAVINGS_BANK_PKG.CREATE_ACCOUNT (
                        P_PERSON_ID                => LN_PERSON_ID,
                        P_PARAM_ELEMENT_NAME       => 'LOAN_ELEMENT_NAME',
                        P_PARAM_CODE_COMBINATION   => 'LOAN_NO_SAV_CODE_COMB');
                  END IF;

                  ATET_SAVINGS_BANK_PKG.SET_LOAN_BALANCE (
                     P_LOAN_ID       => LN_ACTUAL_LOAN_ID,
                     P_LOAN_AMOUNT   => LN_ACTUAL_LOAN_TOTAL_AMOUNT,
                     P_PERSON_ID     => LN_PERSON_ID);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     LOG_ERRORS (
                        'REFINANCE_LOAN =>ERROR EN LA CREACION DE CUENTAS',
                        P_ERROR_MESSAGE   => SQLERRM);

                     FND_FILE.PUT_LINE (
                        FND_FILE.LOG,
                        'Error en creacion de cuentas: ' || SQLERRM);
                     RAISE;
               END;

               COMMIT;

               BEGIN
                  ATET_SB_BACK_OFFICE_PKG.PRINT_PROMISSORY_NOTE (
                     LN_ACTUAL_LOAN_ID);
                  ATET_SB_BACK_OFFICE_PKG.PRINT_CHECK (P_OUT_CHECK_ID);

                  ATET_SB_BACK_OFFICE_PKG.PRINT_INTEREST_SUBSIDY (
                     LN_PREVIOUS_LOAN_ID);
                  ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     LOG_ERRORS (
                        'REFINANCE_LOAN =>ERROR EL IMPRIMIR LOS MULTIPLES DOCUMENTOS',
                        P_ERROR_MESSAGE   => SQLERRM);

                     FND_FILE.PUT_LINE (
                        FND_FILE.LOG,
                        'Error al imprimir alguno de los muchos documentos: '
                        || SQLERRM);
                     RAISE;
               END;
            EXCEPTION
               WHEN OTHERS
               THEN
                  LOG_ERRORS (
                     'REFINANCE_LOAN =>ERROR EN EL PROCEDIMIENTO DEL MANDINGO',
                     P_ERROR_MESSAGE   => SQLERRM);
                  ROLLBACK;

                  FND_FILE.PUT_LINE (
                     FND_FILE.LOG,
                     'Error en procedimiento de mandingo: ' || SQLERRM);
                  RAISE;
            END;
         ELSE
            DBMS_OUTPUT.PUT_LINE (
               'Cantidad nuevo préstamo insificiente para cubrir el anterior o los préstamos no existen');
            FND_FILE.PUT_LINE (
               FND_FILE.LOG,
               'Cantidad nuevo préstamo insificiente para cubrir el anterior o los préstamos no existen');
         END IF;
      ELSE
         DBMS_OUTPUT.PUT_LINE (
            'El préstamo tiene refinanciamiento por mora, no es posible continuar.');
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            'El préstamo tiene refinanciamiento por mora, no es posible continuar.');
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         LOG_ERRORS ('REFINANCE_LOAN =>ERROR FATAL EN TODO EL PROCEDIMIENTO',
                     P_ERROR_MESSAGE   => SQLERRM);

         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            'Error fatal en todo el procedimiento: ' || SQLERRM);
         ROLLBACK;
         RAISE;
   END;


   PROCEDURE CREATE_ELECTRONIC_SIGNATURE (
      P_INPUT_STRING    IN            VARCHAR2,
      P_OUTPUT_STRING      OUT NOCOPY VARCHAR2,
      P_OUTPUT_KEY         OUT NOCOPY VARCHAR2)
   IS
      INPUT_STRING      VARCHAR2 (200);
      OUTPUT_STRING     VARCHAR2 (200);
      ENCRYPTED_RAW     RAW (2000);            -- stores encrypted binary text
      DECRYPTED_RAW     RAW (2000);            -- stores decrypted binary text
      NUM_KEY_BYTES     NUMBER := 256 / 8;   -- key length 256 bits (32 bytes)
      KEY_BYTES_RAW     RAW (32);             -- stores 256-bit encryption key
      ENCRYPTION_TYPE   PLS_INTEGER
         :=                                           -- total encryption type
           DBMS_CRYPTO.ENCRYPT_AES256
            + DBMS_CRYPTO.CHAIN_CBC
            + DBMS_CRYPTO.PAD_PKCS5;
   BEGIN
      BEGIN
         INPUT_STRING := P_INPUT_STRING;


         DBMS_OUTPUT.PUT_LINE ('Original string: ' || input_string);
         key_bytes_raw := DBMS_CRYPTO.RANDOMBYTES (num_key_bytes);
         encrypted_raw :=
            DBMS_CRYPTO.ENCRYPT (
               src   => UTL_I18N.STRING_TO_RAW (input_string, 'AL32UTF8'),
               typ   => encryption_type,
               key   => key_bytes_raw);
         -- The encrypted value "encrypted_raw" can be used here

         decrypted_raw :=
            DBMS_CRYPTO.DECRYPT (src   => encrypted_raw,
                                 typ   => encryption_type,
                                 key   => key_bytes_raw);
         output_string := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
         DBMS_OUTPUT.PUT_LINE ('Cadena a encriptar: ' || input_string);
         DBMS_OUTPUT.PUT_LINE ('Cadena encriptada: ' || encrypted_raw);
         P_OUTPUT_STRING := ENCRYPTED_RAW;
         P_OUTPUT_KEY := KEY_BYTES_RAW;
         DBMS_OUTPUT.PUT_LINE ('LLave: ' || key_bytes_raw);
         DBMS_OUTPUT.PUT_LINE ('Decrypted string: ' || output_string);
      EXCEPTION
         WHEN OTHERS
         THEN
            LOG_ERRORS ('REFINANCE_LOAN =>ERROR AL GENERAR LA FIRMA DIGITAL',
                        P_ERROR_MESSAGE   => SQLERRM);

            DBMS_OUTPUT.PUT_LINE ('Error al generar  fima digital');
            RAISE;
      END;
   END;

   PROCEDURE PRINT_CHECK (P_CHECK_ID NUMBER)
   IS
      add_layout_boolean   BOOLEAN;
      v_request_id         NUMBER;
      waiting              BOOLEAN;
      phase                VARCHAR2 (80 BYTE);
      status               VARCHAR2 (80 BYTE);
      dev_phase            VARCHAR2 (80 BYTE);
      dev_status           VARCHAR2 (80 BYTE);
      V_message            VARCHAR2 (4000 BYTE);
   BEGIN
      BEGIN
         --         add_layout_boolean :=
         --            fnd_request.add_layout (
         --               template_appl_name   => 'PER',
         --               template_code        => 'ATET_SB_PRINT_CHECK',
         --               template_language    => 'Spanish', --Use language from template definition
         --               template_territory   => 'Mexico', --Use territory from template definition
         --               output_format        => 'PDF' --Use output format from template definition
         --                                            );



         v_request_id :=
            fnd_request.submit_request ('PER',                  -- application
                                        'ATET_SB_PRINT_CHECK', -- program short name
                                        '',                     -- description
                                        '',                      -- start time
                                        FALSE,                  -- sub request
                                        TO_CHAR (P_CHECK_ID),     -- argument1
                                        CHR (0) -- represents end of arguments
                                               );
         STANDARD.COMMIT;
         waiting :=
            fnd_concurrent.wait_for_request (v_request_id,
                                             1,
                                             0,
                                             phase,
                                             status,
                                             dev_phase,
                                             dev_status,
                                             V_message);
      EXCEPTION
         WHEN OTHERS
         THEN
            LOG_ERRORS ('PRINT_CHECK =>AL IMPRIMIR EL CHEQUE',
                        P_ERROR_MESSAGE   => SQLERRM);

            RAISE;
      END;
   END PRINT_CHECK;



   PROCEDURE CANCEL_LOAN (ERRBUF         OUT NOCOPY VARCHAR2,
                          RETCODE        OUT NOCOPY VARCHAR2,
                          P_LOAN_ID   IN            NUMBER)
   IS
      LN_LOAN_ID           NUMBER;
      LOAN_STATUS_FLAG     VARCHAR2 (150);
      LN_TERM_PERIODS      NUMBER;
      LN_PENDING_PERIODS   NUMBER;
      LN_CHECK_ID          NUMBER;
   BEGIN
      SELECT LOAN_ID, LOAN_STATUS_FLAG
        INTO LN_LOAN_ID, LOAN_STATUS_FLAG
        FROM ATET_SB_LOANS
       WHERE LOAN_STATUS_FLAG IN
                ('REFINANCE', 'ON_HOLD', 'ENTERED', 'APPROVED', 'ACTIVE')
             AND LOAN_ID = P_LOAN_ID;

      IF LOAN_STATUS_FLAG = 'ACTIVE'
      THEN
         BEGIN
              SELECT TERM_PERIODS
                INTO LN_TERM_PERIODS
                FROM ATET_SB_LOANS
               WHERE LOAN_ID = LN_LOAN_ID
            ORDER BY 1 DESC;

            SELECT COUNT (1) PENDING
              INTO LN_PENDING_PERIODS
              FROM ATET_SB_PAYMENTS_SCHEDULE
             WHERE 1 = 1 AND STATUS_FLAG = 'PENDING' AND LOAN_ID = LN_LOAN_ID;


            IF LN_TERM_PERIODS = LN_PENDING_PERIODS
            THEN
               SELECT CHECK_ID
                 INTO LN_CHECK_ID
                 FROM ATET_LOAN_PAYMENTS_ALL
                WHERE loan_id = LN_LOAN_ID;

               UPDATE ATET_SB_CHECKS_ALL
                  SET STATUS_LOOKUP_CODE = 'CANCELLED',
                      LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                      LAST_UPDATE_DATE = SYSDATE
                WHERE CHECK_ID = LN_CHECK_ID
                      AND STATUS_LOOKUP_CODE = 'CREATED';

               --               UPDATE ATET_SB_PAYMENTS_SCHEDULE
               --                  SET STATUS_FLAG = 'CANCELLED',
               --                      LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
               --                      LAST_UPDATE_DATE = SYSDATE
               --                WHERE     1 = 1
               --                      AND STATUS_FLAG = 'PENDING'
               --                      AND LOAN_ID = LN_LOAN_ID;
               --
               --               UPDATE ATET_SB_LOANS
               --                  SET LOAN_STATUS_FLAG = 'CANCELLED'
               --                WHERE LOAN_ID = LN_LOAN_ID;
               --
               --               DELETE FROM ATET_SB_ENDORSEMENTS
               --                     WHERE LOAN_ID = LN_LOAN_ID;


               ATET_SAVINGS_BANK_PKG.CANCELLED_LOAN (LN_LOAN_ID);
            ELSE
               LOG_ERRORS (
                  'CANCEL_LOAN =>EL NUMERO DE PERIODOS TOTALES Y PENDIENTES NO ES EL MISMO',
                  P_ERROR_MESSAGE   => SQLERRM);

               FND_FILE.PUT_LINE (
                  FND_FILE.LOG,
                  'EL NUMERO DE PERIODOS TOTALES Y PENDIENTES NO ES EL MISMO');
            END IF;
         END;
      ELSE
         DELETE FROM ATET_SB_ENDORSEMENTS
               WHERE LOAN_ID = LN_LOAN_ID;

         UPDATE ATET_SB_LOANS
            SET LOAN_STATUS_FLAG = 'CANCELED'
          WHERE LOAN_ID = LN_LOAN_ID;
      END IF;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         LOG_ERRORS ('CANCEL_LOAN =>AL CANCELAR EL PRESTAMO',
                     P_ERROR_MESSAGE   => SQLERRM);
         ROLLBACK;
         RAISE;
   END;


   PROCEDURE PRINT_PROMISSORY_NOTE (P_LOAN_ID NUMBER)
   IS
      add_layout_boolean   BOOLEAN;
      v_request_id         NUMBER;
      waiting              BOOLEAN;
      phase                VARCHAR2 (80 BYTE);
      status               VARCHAR2 (80 BYTE);
      dev_phase            VARCHAR2 (80 BYTE);
      dev_status           VARCHAR2 (80 BYTE);
      V_message            VARCHAR2 (4000 BYTE);
   BEGIN
      BEGIN
         add_layout_boolean :=
            fnd_request.add_layout (
               template_appl_name   => 'PER',
               template_code        => 'ATET_SB_PROMISSORY_NOTE',
               template_language    => 'Spanish', --Use language from template definition
               template_territory   => 'Mexico', --Use territory from template definition
               output_format        => 'PDF' --Use output format from template definition
                                            );



         v_request_id :=
            fnd_request.submit_request ('PER',                  -- application
                                        'ATET_SB_PROMISSORY_NOTE', -- program short name
                                        '',                     -- description
                                        '',                      -- start time
                                        FALSE,                  -- sub request
                                        TO_CHAR (P_LOAN_ID),      -- argument1
                                        CHR (0) -- represents end of arguments
                                               );
         STANDARD.COMMIT;
         waiting :=
            fnd_concurrent.wait_for_request (v_request_id,
                                             1,
                                             0,
                                             phase,
                                             status,
                                             dev_phase,
                                             dev_status,
                                             V_message);
      EXCEPTION
         WHEN OTHERS
         THEN
            LOG_ERRORS (
               'PRINT_PROMISSORY_NOTE =>ERROR AL IMPRIMIR EL PAGARE',
               P_ERROR_MESSAGE   => SQLERRM);

            RAISE;
      END;
   END PRINT_PROMISSORY_NOTE;

   PROCEDURE PRINT_PREPAID (P_LOAN_ID                      NUMBER,
                            P_CONDONATE_INTEREST_AMOUNT    NUMBER)
   IS
      ADD_LAYOUT_BOOLEAN   BOOLEAN;
      V_REQUEST_ID         NUMBER;
      WAITING              BOOLEAN;
      PHASE                VARCHAR2 (80 BYTE);
      STATUS               VARCHAR2 (80 BYTE);
      DEV_PHASE            VARCHAR2 (80 BYTE);
      DEV_STATUS           VARCHAR2 (80 BYTE);
      V_MESSAGE            VARCHAR2 (4000 BYTE);
      LN_FOLIO             NUMBER;
   BEGIN
      BEGIN
         SELECT ATET_SB_PREPAID_SEQ.NEXTVAL INTO LN_FOLIO FROM DUAL;
      END;

      BEGIN
         add_layout_boolean :=
            fnd_request.add_layout (
               template_appl_name   => 'PER',
               template_code        => 'ATET_SB_PRINT_PREPAID',
               template_language    => 'Spanish', --Use language from template definition
               template_territory   => 'Mexico', --Use territory from template definition
               output_format        => 'PDF' --Use output format from template definition
                                            );



         v_request_id :=
            fnd_request.submit_request (
               'PER',                                           -- application
               'ATET_SB_PRINT_PREPAID',                  -- program short name
               '',                                              -- description
               '',                                               -- start time
               FALSE,                                           -- sub request
               TO_CHAR (P_LOAN_ID),                               -- argument1
               TO_CHAR (LN_FOLIO),                                -- argument2
               TO_CHAR (P_CONDONATE_INTEREST_AMOUNT),             -- argument3
               CHR (0)                          -- represents end of arguments
                      );
         STANDARD.COMMIT;
         waiting :=
            fnd_concurrent.wait_for_request (v_request_id,
                                             1,
                                             0,
                                             phase,
                                             status,
                                             dev_phase,
                                             dev_status,
                                             V_message);
      EXCEPTION
         WHEN OTHERS
         THEN
            LOG_ERRORS ('PRINT_PREPAID =>ERROR AL IMPRIMIR EL PREPAGO',
                        P_ERROR_MESSAGE   => SQLERRM);
            RAISE;
      END;
   END PRINT_PREPAID;


   PROCEDURE PRINT_INTEREST_SUBSIDY (P_LOAN_ID NUMBER)
   IS
      ADD_LAYOUT_BOOLEAN   BOOLEAN;
      V_REQUEST_ID         NUMBER;
      WAITING              BOOLEAN;
      PHASE                VARCHAR2 (80 BYTE);
      STATUS               VARCHAR2 (80 BYTE);
      DEV_PHASE            VARCHAR2 (80 BYTE);
      DEV_STATUS           VARCHAR2 (80 BYTE);
      V_MESSAGE            VARCHAR2 (4000 BYTE);
      LN_FOLIO             NUMBER;
   BEGIN
      BEGIN
         add_layout_boolean :=
            fnd_request.add_layout (
               template_appl_name   => 'PER',
               template_code        => 'ATET_SB_PRINT_INTEREST_SUBSIDY',
               template_language    => 'Spanish', --Use language from template definition
               template_territory   => 'Mexico', --Use territory from template definition
               output_format        => 'PDF' --Use output format from template definition
                                            );

         v_request_id :=
            fnd_request.submit_request ('PER',                  -- application
                                        'ATET_SB_PRINT_INTEREST_SUBSIDY', -- program short name
                                        '',                     -- description
                                        '',                      -- start time
                                        FALSE,                  -- sub request
                                        TO_CHAR (P_LOAN_ID),      -- argument1
                                        CHR (0) -- represents end of arguments
                                               );
         STANDARD.COMMIT;
         waiting :=
            fnd_concurrent.wait_for_request (v_request_id,
                                             1,
                                             0,
                                             phase,
                                             status,
                                             dev_phase,
                                             dev_status,
                                             V_message);
      EXCEPTION
         WHEN OTHERS
         THEN
            LOG_ERRORS (
               'PRINT_INTEREST_SUBSIDY =>ERROR AL IMPRIMIR LOS INTERESES CONDONADOS',
               P_ERROR_MESSAGE   => SQLERRM);
            RAISE;
      END;
   END PRINT_INTEREST_SUBSIDY;

   PROCEDURE TRANSFER_TO_GUARANTEES (
      ERRBUF                  OUT NOCOPY VARCHAR2,
      RETCODE                 OUT NOCOPY VARCHAR2,
      P_LOAN_ID            IN            NUMBER,
      P_DISCOUNT_PERIODS                 NUMBER)
   IS
      LN_LOAN_ID                       NUMBER;
      LN_NEW_LOAN_ID                   NUMBER;
      LD_PAYMENT_DEADLINE              DATE;
      LN_PARTIAL_PAYMENT_AMOUNT        NUMBER;
      MEMBER_BORROWER_ID               NUMBER;
      LN_LOAN_BALANCE_DUE              NUMBER;
      LN_TOTAL_ENDORSEMENTS            NUMBER;
      LN_DISTRIBUTION_PERCENTAGE       NUMBER;
      LN_TRANSFER_AMOUNT               NUMBER;
      LN_SUBSIDY_INTEREST_PERCENTAJE   NUMBER := 0;
      LN_LOAN_ID_TRX                   NUMBER;
      LN_LOAN_BALANCE_DUE_TRX          NUMBER;
      LN_LOAN_BALANCE_CALC             NUMBER;
      LN_TRANSFER_INTEREST_AMOUNT      NUMBER;
      LN_CONDONATE_INTEREST_AMOUNT     NUMBER;
      LN_MEMBER_ID                     NUMBER;
      LN_LOAN_AMOUNT                   NUMBER;
      LN_LOAN_INTEREST                 NUMBER;
      LN_NOT_REC_CODE_COMB             NUMBER;
      LN_UNE_INT_CODE_COMB             NUMBER;
      LN_NEW_LOAN_NUMBER               NUMBER;
      LN_PREVIOUS_LOAN_NUMBER          NUMBER;
      LN_LINE_COUNTER                  NUMBER := 0;
      LN_PERSON_ID                     NUMBER;

      P_ENTITY_CODE                    VARCHAR2 (150);

      P_EVENT_TYPE_CODE                VARCHAR2 (150);
      P_INTEREST_EVENT_TYPE_CODE       VARCHAR2 (150);
      P_INTEREST_EARN_TYPE_CODE        VARCHAR2 (150);
      P_PREV_LOAN_EVENT_TYPE_CODE      VARCHAR2 (150);

      P_BATCH_NAME                     VARCHAR2 (150);
      P_JOURNAL_NAME                   VARCHAR2 (150);
      P_HEADER_ID                      NUMBER;

      CURSOR C_ACTUAL_LOAN (
         P_SUBSIDY_INTEREST_PERCENTAJE NUMBER)
      IS
           SELECT ASL.LOAN_ID,
                  ASL.MEMBER_ID,
                  LOAN_NUMBER,
                  TRANSACTION_DATE,
                  LOAN_BALANCE,
                  LOAN_TOTAL_AMOUNT,
                  LOAN_AMOUNT,
                  LOAN_INTEREST_AMOUNT,
                  LOAN_TOTAL_AMOUNT - SUM (NVL (PAYMENT_AMOUNT, 0))
                     LOAN_BALANCE_CALC,
                  SUM (NVL (PAYMENT_AMOUNT, 0)) PAYMENT_AMOUNT,
                  SUM (NVL (PAYMENT_CAPITAL, 0)) PAYMENT_CAPITAL,
                  SUM (NVL (PAYMENT_INTEREST, 0)) PAYMENT_INTEREST,
                  LOAN_AMOUNT - SUM (NVL (PAYMENT_CAPITAL, 0)) CAPITAL_DUE,
                  LOAN_INTEREST_AMOUNT - SUM (NVL (PAYMENT_INTEREST, 0))
                     INTEREST_DUE,
                  (TO_NUMBER (
                      ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                         'INT_SUBSIDY',
                         (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                            FROM DUAL))))
                     PARAMETER_SUBSIDIZED_INTEREST,
                  (P_SUBSIDY_INTEREST_PERCENTAJE)
                     ENTERED_SUBSIDY_INT_PERCENTAJE,
                  (LOAN_INTEREST_AMOUNT - SUM (NVL (PAYMENT_INTEREST, 0)))
                  * ( (P_SUBSIDY_INTEREST_PERCENTAJE / 100))
                     SUBSIDY_INTEREST_AMOUNT,
                  (LOAN_INTEREST_AMOUNT - SUM (NVL (PAYMENT_INTEREST, 0)))
                  * (1 - (P_SUBSIDY_INTEREST_PERCENTAJE / 100))
                     TRANSFER_INTEREST_AMOUNT,
                  LAST_PAYMENT_DATE,
                  (LOAN_INTEREST_AMOUNT - SUM (NVL (PAYMENT_INTEREST, 0)))
                  * (1 - (P_SUBSIDY_INTEREST_PERCENTAJE / 100))
                  + (LOAN_AMOUNT - SUM (NVL (PAYMENT_CAPITAL, 0)))
                     TOTAL_BALANCE_DUE
             FROM ATET_SB_LOANS ASL, ATET_SB_LOANS_TRANSACTIONS ASLT
            WHERE     ASL.LOAN_ID = ASLT.LOAN_ID
                  AND ASLT.LOAN_ID = P_LOAN_ID
                  AND LOAN_STATUS_FLAG = 'ACTIVE'
         GROUP BY ASL.LOAN_ID,
                  ASL.MEMBER_ID,
                  LOAN_NUMBER,
                  TRANSACTION_DATE,
                  LOAN_BALANCE,
                  LOAN_TOTAL_AMOUNT,
                  LOAN_AMOUNT,
                  LOAN_INTEREST_AMOUNT,
                  LAST_PAYMENT_DATE,
                  LOAN_TOTAL_AMOUNT;

      CURSOR C_MEMBER_ENDORSEMENTS
      IS
         SELECT ENDORSEMENT_ID,
                LOAN_ID,
                MEMBER_BORROWER_ID,
                MEMBER_ENDORSEMENT_ID
           FROM ATET_SB_ENDORSEMENTS
          WHERE LOAN_ID = P_LOAN_ID;

      LV_ENDORSEMENTS                  C_MEMBER_ENDORSEMENTS%ROWTYPE;
   BEGIN
      BEGIN
         SELECT LOAN_ID, LOAN_BALANCE
           INTO LN_LOAN_ID, LN_LOAN_BALANCE_DUE
           FROM ATET_SB_LOANS
          WHERE LOAN_STATUS_FLAG = 'ACTIVE' AND LOAN_ID = P_LOAN_ID;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE (
               'No se encuentra el préstamo a transferir');

            LOG_ERRORS (
               'TRANSFER_TO_GUARANTEES => NO SE ENCUENTRA EL PRESTAMO A TRANSFERIR',
               P_ERROR_MESSAGE   => SQLERRM);

            RAISE;
      END;


      BEGIN
         SELECT COUNT (1)
           INTO LN_TOTAL_ENDORSEMENTS
           FROM ATET_SB_ENDORSEMENTS
          WHERE LOAN_ID = P_LOAN_ID;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE ('Error al buscar el número de avales');
            LOG_ERRORS (
               'TRANSFER_TO_GUARANTEES => ERROR AL BUSCAR EL NUMERO DE AVALES',
               P_ERROR_MESSAGE   => SQLERRM);
            RAISE;
      END;

      BEGIN
         LN_DISTRIBUTION_PERCENTAGE := 1 / LN_TOTAL_ENDORSEMENTS;
      EXCEPTION
         WHEN ZERO_DIVIDE
         THEN
            DBMS_OUTPUT.PUT_LINE (
               'Es préstamo no tiene avales, es imposible seguir el proceso de transferencia a avales. ');
            LOG_ERRORS (
               'TRANSFER_TO_GUARANTEES => EL PRESTAMO NO TIENE AVALES Y ES IMPOSIBLE SEGUIR EL PROCESO DE TRANSFERENCIA',
               P_ERROR_MESSAGE   => SQLERRM);
            RAISE;
      END;

      DBMS_OUTPUT.PUT_LINE ('Total de avales: ' || LN_TOTAL_ENDORSEMENTS);
      DBMS_OUTPUT.PUT_LINE (
         'Porcentaje de distrubición del saldo: '
         || LN_DISTRIBUTION_PERCENTAGE);

      BEGIN
         FOR ACTUAL_LOAN_REC
            IN C_ACTUAL_LOAN (LN_SUBSIDY_INTEREST_PERCENTAJE)
         LOOP
            LN_LOAN_ID_TRX := ACTUAL_LOAN_REC.LOAN_ID;
            LN_LOAN_AMOUNT := ACTUAL_LOAN_REC.LOAN_AMOUNT;
            LN_LOAN_BALANCE_DUE_TRX := ACTUAL_LOAN_REC.TOTAL_BALANCE_DUE;
            LN_LOAN_BALANCE_CALC := ACTUAL_LOAN_REC.LOAN_BALANCE_CALC;
            LN_TRANSFER_INTEREST_AMOUNT :=
               ACTUAL_LOAN_REC.TRANSFER_INTEREST_AMOUNT;
            LN_CONDONATE_INTEREST_AMOUNT :=
               ACTUAL_LOAN_REC.SUBSIDY_INTEREST_AMOUNT;
            LN_LOAN_INTEREST := TRUNC(LN_TRANSFER_INTEREST_AMOUNT / LN_LOAN_AMOUNT,2);
            LN_PREVIOUS_LOAN_NUMBER := ACTUAL_LOAN_REC.LOAN_NUMBER;
            LN_MEMBER_ID := ACTUAL_LOAN_REC.MEMBER_ID;

            DBMS_OUTPUT.PUT_LINE (
               'Saldo del prestamo a transferir: ' || LN_LOAN_AMOUNT);
            DBMS_OUTPUT.PUT_LINE (
               'Interés a transferir: ' || LN_TRANSFER_INTEREST_AMOUNT);

            DBMS_OUTPUT.PUT_LINE (
               'Tasa de Interés a transferir: ' || LN_LOAN_INTEREST);


            DBMS_OUTPUT.PUT_LINE (
               'Interés condonado: ' || LN_CONDONATE_INTEREST_AMOUNT);
            DBMS_OUTPUT.PUT_LINE (
               'Balance calculado total a transferir: '
               || LN_LOAN_BALANCE_DUE_TRX);

            FND_FILE.PUT_LINE (
               FND_FILE.LOG,
               'Interés a transferir: ' || LN_TRANSFER_INTEREST_AMOUNT);
            FND_FILE.PUT_LINE (
               FND_FILE.LOG,
               'Interés condonado: ' || LN_CONDONATE_INTEREST_AMOUNT);
            FND_FILE.PUT_LINE (
               FND_FILE.LOG,
               'Balance a transferir: ' || LN_LOAN_BALANCE_DUE_TRX);
         END LOOP;
      END;


      IF LN_LOAN_BALANCE_DUE_TRX = LN_LOAN_BALANCE_DUE
      THEN
         DBMS_OUTPUT.PUT_LINE (
            'El balance a transferir es correcto: '
            || LN_LOAN_BALANCE_DUE_TRX);

         -------------------- GL header creation
         P_ENTITY_CODE := 'ENDORSEMENT_LOANS';
         P_EVENT_TYPE_CODE := 'ENDORSEMENT_LOAN_CREATION';
         P_INTEREST_EVENT_TYPE_CODE := 'ENDORSEMENT_LOAN_INTEREST';
         P_INTEREST_EARN_TYPE_CODE := 'INTEREST_EARN';
         P_PREV_LOAN_EVENT_TYPE_CODE := 'PREVIOUS_LOAN';
         P_BATCH_NAME := 'CARGO A AVAL DE PRESTAMO DE CAJA DE AHORRO';
         P_JOURNAL_NAME := 'CARGO A AVAL DE PRESTAMO DE CAJA DE AHORRO';
         P_HEADER_ID := NULL;


         ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (P_ENTITY_CODE,
                                                    P_EVENT_TYPE_CODE,
                                                    P_BATCH_NAME,
                                                    P_JOURNAL_NAME,
                                                    P_HEADER_ID);


         IF ATET_SAVINGS_BANK_PKG.GET_MEMBER_IS_SAVER (LN_MEMBER_ID) = 'Y'
         THEN
            SELECT ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID (
                      (SELECT ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                                 'NOT_REC_SAV_CODE_COMB',
                                 (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                                    FROM DUAL))
                                 CONCATENATED_SEGMENTS
                         FROM DUAL))
              INTO LN_NOT_REC_CODE_COMB                --DOCUMENTOS POR COBRAR
              FROM DUAL CCID;
         ELSE
            SELECT ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID (
                      (SELECT ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                                 'NOT_REC_NO_SAV_CODE_COMB',
                                 (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                                    FROM DUAL))
                                 CONCATENATED_SEGMENTS
                         FROM DUAL))
              INTO LN_NOT_REC_CODE_COMB                --DOCUMENTOS POR COBRAR
              FROM DUAL CCID;
         END IF;


         SELECT ATET_SAVINGS_BANK_PKG.GET_CODE_COMBINATION_ID (
                   (SELECT ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                              'UNE_INT_CODE_COMB',
                              (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                                 FROM DUAL))
                              CONCATENATED_SEGMENTS
                      FROM DUAL))
           INTO LN_UNE_INT_CODE_COMB                  --INTERESES POR DEVENGAR
           FROM DUAL CCID;

         ---------------------

         BEGIN
            OPEN C_MEMBER_ENDORSEMENTS;


            LOOP
               FETCH C_MEMBER_ENDORSEMENTS INTO LV_ENDORSEMENTS;

               EXIT WHEN C_MEMBER_ENDORSEMENTS%NOTFOUND;



               BEGIN
                  LN_TRANSFER_AMOUNT :=
                     TRUNC (LN_LOAN_BALANCE_DUE * LN_DISTRIBUTION_PERCENTAGE,
                            2);
                  DBMS_OUTPUT.PUT_LINE (
                     'Aval id: ' || LV_ENDORSEMENTS.MEMBER_ENDORSEMENT_ID);
                  DBMS_OUTPUT.PUT_LINE (
                     'Saldo a transferir: ' || LN_TRANSFER_AMOUNT);
                  DBMS_OUTPUT.PUT_LINE (
                     'Saldo a transferir calculado: '
                     || LN_LOAN_BALANCE_DUE * LN_DISTRIBUTION_PERCENTAGE);

                  DBMS_OUTPUT.PUT_LINE (
                     'Intereses a transferir: '
                     || TRUNC (
                           LN_TRANSFER_INTEREST_AMOUNT
                           * LN_DISTRIBUTION_PERCENTAGE,
                           2));


                  LN_NEW_LOAN_ID := ATET_SB_LOANS_SEQ.NEXTVAL;
                  LN_NEW_LOAN_NUMBER := ATET_SB_LOAN_NUMBER_SEQ.NEXTVAL;
                  LN_PARTIAL_PAYMENT_AMOUNT :=
                     TRUNC (LN_TRANSFER_AMOUNT / P_DISCOUNT_PERIODS, 2);

                  INSERT INTO ATET_SB_LOANS (LOAN_ID,
                                             MEMBER_ID,
                                             PERIOD_TYPE,
                                             LOAN_STATUS_FLAG,
                                             TRANSACTION_DATE,
                                             LOAN_NUMBER,
                                             NORMAL_INTEREST_RATE,
                                             LATE_INTEREST_RATE,
                                             LOAN_INTEREST_RATE,
                                             LOAN_AMOUNT,
                                             LOAN_INTEREST_AMOUNT,
                                             LOAN_TOTAL_AMOUNT,
                                             ATTRIBUTE1,
                                             LOAN_BALANCE,
                                             TERM_PERIODS,
                                             ATTRIBUTE3,
                                             CREATION_DATE,
                                             LAST_UPDATE_DATE,
                                             CREATED_BY,
                                             LAST_UPDATED_BY,
                                             ATTRIBUTE6)
                       VALUES (
                                 LN_NEW_LOAN_ID,
                                 LV_ENDORSEMENTS.MEMBER_ENDORSEMENT_ID,
                                 (SELECT ATET_SAVINGS_BANK_PKG.GET_PERIOD_TYPE (
                                            ATET_SAVINGS_BANK_PKG.GET_PERSON_ID (
                                               LV_ENDORSEMENTS.MEMBER_ENDORSEMENT_ID))
                                    FROM DUAL),
                                 'ACTIVE',
                                 TRUNC (SYSDATE),
                                 LN_NEW_LOAN_NUMBER,
                                 (SELECT TO_NUMBER (
                                            ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                                               'INT_RATE_SAV',
                                               (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                                                  FROM DUAL)))
                                            INT_RATE_SAV
                                    FROM DUAL),
                                 (SELECT TO_NUMBER (
                                            ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                                               'LATE_INT',
                                               (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                                                  FROM DUAL)))
                                            LATE_INT
                                    FROM DUAL),
                                 LN_LOAN_INTEREST * 100, ---Tasa de interés del préstamo
                                 TRUNC(LN_TRANSFER_AMOUNT
                                 - (LN_TRANSFER_INTEREST_AMOUNT
                                    * LN_DISTRIBUTION_PERCENTAGE),2),
                                 LN_TRANSFER_INTEREST_AMOUNT
                                 * LN_DISTRIBUTION_PERCENTAGE,
                                 LN_TRANSFER_AMOUNT,
                                 LN_PARTIAL_PAYMENT_AMOUNT,     --PAGO PARCIAL
                                 LN_TRANSFER_AMOUNT,
                                 P_DISCOUNT_PERIODS,
                                 NULL,
                                 SYSDATE,
                                 SYSDATE,
                                 FND_GLOBAL.USER_ID,
                                 FND_GLOBAL.USER_ID,
                                 'TRANSFER_TO_GUARANTEES');

                  BEGIN
                     SELECT PERSON_ID
                       INTO LN_PERSON_ID
                       FROM ATET_SB_MEMBERS
                      WHERE MEMBER_ID = LV_ENDORSEMENTS.MEMBER_ENDORSEMENT_ID;


                     BEGIN
                        ATET_SAVINGS_BANK_PKG.CREATE_ACCOUNT (
                           LN_PERSON_ID,
                           'LOAN_ELEMENT_NAME',
                           'LOAN_SAV_CODE_COMB');

                        ATET_SAVINGS_BANK_PKG.SET_LOAN_BALANCE (
                           LN_NEW_LOAN_ID,
                           LN_TRANSFER_AMOUNT,
                           LN_PERSON_ID);
                     END;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        ROLLBACK;
                        LOG_ERRORS (
                           'TRANSFER_TO_GUARANTEES => ERROR EN EL CICLO DE CREACION DE CUENTAS DE PRESTAMO',
                           P_ERROR_MESSAGE   => SQLERRM);
                        RAISE;
                  END;


                  ATET_SB_BACK_OFFICE_PKG.CREATE_PAYMENTS_SCHEDULE (
                     LN_NEW_LOAN_ID,
                     LD_PAYMENT_DEADLINE);
                     

                  UPDATE ATET_SB_LOANS
                     SET PAYMENT_DEADLINE = LD_PAYMENT_DEADLINE
                   WHERE LOAN_ID = LN_NEW_LOAN_ID;

                  ---DOCUMENTOS POR COBRAR NUEVO PRESTAMO
                  LN_LINE_COUNTER := LN_LINE_COUNTER + 1;

                  ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
                     P_HEADER_ID               => P_HEADER_ID,
                     P_ROW_NUMBER              => LN_LINE_COUNTER,
                     P_CODE_COMBINATION_ID     => LN_NOT_REC_CODE_COMB,
                     P_ACCOUNTING_CLASS_CODE   => P_EVENT_TYPE_CODE,
                     P_ACCOUNTED_DR            => LN_TRANSFER_AMOUNT,
                     P_ACCOUNTED_CR            => 0,
                     P_DESCRIPTION             => 'CARGO A AVAL: '
                                                 || LV_ENDORSEMENTS.MEMBER_ENDORSEMENT_ID
                                                 || ' '
                                                 || LN_NEW_LOAN_NUMBER,
                     P_SOURCE_ID               => LN_NEW_LOAN_ID,
                     P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');

                  LN_LINE_COUNTER := LN_LINE_COUNTER + 1;

                  ---- INTERESES POR DEVENGAR NUEVO PRÉSTAMO
                  ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
                     P_HEADER_ID               => P_HEADER_ID,
                     P_ROW_NUMBER              => LN_LINE_COUNTER,
                     P_CODE_COMBINATION_ID     => LN_UNE_INT_CODE_COMB,
                     P_ACCOUNTING_CLASS_CODE   => P_INTEREST_EARN_TYPE_CODE,
                     P_ACCOUNTED_DR            => 0,
                     P_ACCOUNTED_CR            => TRUNC (
                                                    LN_TRANSFER_INTEREST_AMOUNT
                                                    * LN_DISTRIBUTION_PERCENTAGE,
                                                    2),
                     P_DESCRIPTION             => 'INTERESES DEL PRESTAMO: '
                                                 || LN_NEW_LOAN_NUMBER,
                     P_SOURCE_ID               => LN_NEW_LOAN_ID,
                     P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');


                  UPDATE ATET_SB_ENDORSEMENTS
                     SET ENDORSEMENT_FLAG = 'TRANSFERED',
                         ATTRIBUTE2 = LN_NEW_LOAN_ID
                   WHERE ENDORSEMENT_ID = LV_ENDORSEMENTS.ENDORSEMENT_ID;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     ROLLBACK;
                     LOG_ERRORS (
                        'TRANSFER_TO_GUARANTEES => ERROR EN EL CICLO DE CREACION DE NUEVOS PRESTAMOS',
                        P_ERROR_MESSAGE   => SQLERRM);
                     RAISE;
               END;
            END LOOP;



            CLOSE C_MEMBER_ENDORSEMENTS;

            ATET_SAVINGS_BANK_PKG.SETTLEMENT_LOAN (LN_LOAN_ID);

            ---DOCUMENTOS POR COBRAR PRESTAMO ANTERIOR
            LN_LINE_COUNTER := LN_LINE_COUNTER + 1;

            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
               P_HEADER_ID               => P_HEADER_ID,
               P_ROW_NUMBER              => LN_LINE_COUNTER,
               P_CODE_COMBINATION_ID     => LN_NOT_REC_CODE_COMB,
               P_ACCOUNTING_CLASS_CODE   => P_PREV_LOAN_EVENT_TYPE_CODE,
               P_ACCOUNTED_DR            => 0,
               P_ACCOUNTED_CR            => LN_LOAN_BALANCE_DUE,
               P_DESCRIPTION             => 'CARGO A AVAL PRESTAMO: '
                                           || LN_PREVIOUS_LOAN_NUMBER,
               P_SOURCE_ID               => ln_loan_id,
               P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');


            --INTERESES POR DEVENGAR
            LN_LINE_COUNTER := LN_LINE_COUNTER + 1;

            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
               P_HEADER_ID               => P_HEADER_ID,
               P_ROW_NUMBER              => LN_LINE_COUNTER,
               P_CODE_COMBINATION_ID     => LN_UNE_INT_CODE_COMB,
               P_ACCOUNTING_CLASS_CODE   => P_INTEREST_EARN_TYPE_CODE,
               P_ACCOUNTED_DR            => LN_TRANSFER_INTEREST_AMOUNT,
               P_ACCOUNTED_CR            => 0,
               P_DESCRIPTION             => 'INTERESES DEL PRESTAMO TRASPASADO A AVALES: '
                                           || LN_PREVIOUS_LOAN_NUMBER,
               P_SOURCE_ID               => ln_loan_id,
               P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');


            COMMIT;
         EXCEPTION
            WHEN OTHERS
            THEN
               CLOSE C_MEMBER_ENDORSEMENTS;

               LOG_ERRORS (
                  'TRANSFER_TO_GUARANTEES => ERROR GRAVE AL TRANSFERIR PRESTAMOS, NO SE REALIZO NUNGUNA ACCION',
                  P_ERROR_MESSAGE   => SQLERRM);
               ROLLBACK;
               RAISE;
         END;
      ELSE
         DBMS_OUTPUT.PUT_LINE ('Los saldos no son iguales');
         DBMS_OUTPUT.PUT_LINE (
            'Balance calculado por transacciones: '
            || LN_LOAN_BALANCE_DUE_TRX);
         DBMS_OUTPUT.PUT_LINE (
            'Balance obtenido de la tabla de préstamos: '
            || LN_LOAN_BALANCE_DUE);
         LOG_ERRORS (
            'TRANSFER_TO_GUARANTEES => LOS SALDOS NO SON IGUALES, NO HACE NADA',
            P_ERROR_MESSAGE   => SQLERRM);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         LOG_ERRORS (
            'TRANSFER_TO_GUARANTEES => ERROR EN TODO EL PROCESO DE CARGO A AVALES',
            P_ERROR_MESSAGE   => SQLERRM);
         RAISE;
   END;


   FUNCTION GET_SOURCE_LINK_DATA (P_SOURCE_ID            NUMBER,
                                  P_SOURCE_LINK_TABLE    VARCHAR2)
      RETURN VARCHAR2
   IS
      DINAMYC_QUERY   VARCHAR2 (4000);
      KEY_FIELD       VARCHAR2 (150);
      DATA_RECORD     VARCHAR2 (150);
      UNIQUE_FIELD    VARCHAR2 (150);
   BEGIN
      BEGIN
         IF P_SOURCE_LINK_TABLE = 'ATET_SB_CHECKS_ALL'
         THEN
            KEY_FIELD := 'CHECK_NUMBER';
            UNIQUE_FIELD := 'CHECK_ID';
         ELSIF P_SOURCE_LINK_TABLE = 'ATET_SB_LOANS'
         THEN
            KEY_FIELD := 'LOAN_NUMBER';
            UNIQUE_FIELD := 'LOAN_ID';
         ELSIF P_SOURCE_LINK_TABLE = 'ATET_SB_LOANS_TRANSACTIONS'
         THEN
            KEY_FIELD := 'ELEMENT_NAME';
            UNIQUE_FIELD := 'LOAN_TRANSACTION_ID';
         ELSIF P_SOURCE_LINK_TABLE = 'ATET_SB_SAVINGS_TRANSACTIONS'
         THEN
            KEY_FIELD := 'PERIOD_NAME ||'' ''||ELEMENT_NAME';
            UNIQUE_FIELD := 'SAVING_TRANSACTION_ID';
         ELSE
            KEY_FIELD := NULL;
            UNIQUE_FIELD := NULL;
         END IF;
      END;


      DINAMYC_QUERY :=
            'SELECT '
         || KEY_FIELD
         || ' FROM '
         || P_SOURCE_LINK_TABLE
         || ' WHERE '
         || UNIQUE_FIELD
         || '='
         || P_SOURCE_ID;

      DBMS_OUTPUT.PUT_LINE ('Query: ' || DINAMYC_QUERY);

      EXECUTE IMMEDIATE DINAMYC_QUERY INTO DATA_RECORD;

      RETURN DATA_RECORD;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'SIN DATOS DE ORIGEN';
   END GET_SOURCE_LINK_DATA;

   PROCEDURE SET_CHECK_SEQUENCE (ERRBUF                OUT NOCOPY VARCHAR2,
                                 RETCODE               OUT NOCOPY VARCHAR2,
                                 P_START_SEQUENCE   IN            NUMBER)
   IS
   BEGIN
      EXECUTE IMMEDIATE ('DROP SEQUENCE APPS.ATET_SB_CHECKS_ALL_SEQ');

      EXECUTE IMMEDIATE
         (   '
CREATE SEQUENCE APPS.ATET_SB_CHECKS_ALL_SEQ
  START WITH '
          || P_START_SEQUENCE
          || '
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER');
   END;

   PROCEDURE CREATE_ANONYMOUS_LOAN (P_MEMBER_ID              IN     NUMBER,
                                    P_PERIOD_TYPE            IN     VARCHAR2,
                                    P_TERM_PERIODS           IN     NUMBER,
                                    P_LOAN_AMOUNT            IN     NUMBER,
                                    P_LOAN_INTEREST          IN     NUMBER,
                                    P_LOAN_INTEREST_AMOUNT   IN     NUMBER,
                                    P_LOAN_TOTAL_AMOUNT      IN     NUMBER,
                                    P_LOAN_NUMBER               OUT NUMBER)
   IS
      LN_NEW_LOAN_ID              NUMBER;
      LN_NEW_LOAN_NUMBER          NUMBER;
      LN_PARTIAL_PAYMENT_AMOUNT   NUMBER;
      LD_PAYMENT_DEADLINE         DATE;
   BEGIN
      LN_NEW_LOAN_ID := ATET_SB_LOANS_SEQ.NEXTVAL;
      LN_NEW_LOAN_NUMBER := ATET_SB_LOAN_NUMBER_SEQ.NEXTVAL;

      LN_PARTIAL_PAYMENT_AMOUNT := TRUNC(P_LOAN_TOTAL_AMOUNT / P_TERM_PERIODS,2);


      INSERT INTO ATET_SB_LOANS (LOAN_ID,
                                 MEMBER_ID,
                                 PERIOD_TYPE,
                                 LOAN_STATUS_FLAG,
                                 TRANSACTION_DATE,
                                 LOAN_NUMBER,
                                 NORMAL_INTEREST_RATE,
                                 LATE_INTEREST_RATE,
                                 LOAN_INTEREST_RATE,
                                 LOAN_AMOUNT,
                                 LOAN_INTEREST_AMOUNT,
                                 LOAN_TOTAL_AMOUNT,
                                 ATTRIBUTE1,
                                 LOAN_BALANCE,
                                 TERM_PERIODS,
                                 ATTRIBUTE3,
                                 CREATION_DATE,
                                 LAST_UPDATE_DATE,
                                 CREATED_BY,
                                 LAST_UPDATED_BY)
           VALUES (
                     LN_NEW_LOAN_ID,
                     P_MEMBER_ID,
                     (SELECT ATET_SAVINGS_BANK_PKG.GET_PERIOD_TYPE (
                                ATET_SAVINGS_BANK_PKG.GET_PERSON_ID (
                                   P_MEMBER_ID))
                        FROM DUAL),
                     'ACTIVE',
                     TRUNC (SYSDATE),
                     LN_NEW_LOAN_NUMBER,
                     (SELECT TO_NUMBER (
                                ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                                   'INT_RATE_SAV',
                                   (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                                      FROM DUAL)))
                                INT_RATE_SAV
                        FROM DUAL),
                     (SELECT TO_NUMBER (
                                ATET_SB_BACK_OFFICE_PKG.GET_PARAMETER_VALUE (
                                   'LATE_INT',
                                   (SELECT ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                                      FROM DUAL)))
                                LATE_INT
                        FROM DUAL),
                     P_LOAN_INTEREST,          ---Tasa de interés del préstamo
                     P_LOAN_AMOUNT,
                     P_LOAN_INTEREST_AMOUNT,
                     P_LOAN_TOTAL_AMOUNT,
                     LN_PARTIAL_PAYMENT_AMOUNT,                 --PAGO PARCIAL
                     P_LOAN_TOTAL_AMOUNT,
                     P_TERM_PERIODS,
                     NULL,
                     SYSDATE,
                     SYSDATE,
                     FND_GLOBAL.USER_ID,
                     FND_GLOBAL.USER_ID);


      ATET_SB_BACK_OFFICE_PKG.CREATE_PAYMENTS_SCHEDULE (LN_NEW_LOAN_ID,
                                                        LD_PAYMENT_DEADLINE);

      UPDATE ATET_SB_LOANS
         SET PAYMENT_DEADLINE = LD_PAYMENT_DEADLINE
       WHERE LOAN_ID = LN_NEW_LOAN_ID;
   END;
END ATET_SB_BACK_OFFICE_PKG;
/
