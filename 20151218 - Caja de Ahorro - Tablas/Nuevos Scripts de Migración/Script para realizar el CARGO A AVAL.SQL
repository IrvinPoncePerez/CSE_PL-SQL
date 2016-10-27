/**************************************************/
/*                  ALTER SESION                  */
/**************************************************/
ALTER SESSION SET CURRENT_SCHEMA=APPS; 


SELECT SUM(NVL(ASPS.OWED_AMOUNT, ASPS.PAYMENT_AMOUNT)),
       SUM(NVL(ASPS.OWED_CAPITAL, ASPS.PAYMENT_CAPITAL)),
       SUM(NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST))
  FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
 WHERE LOAN_ID = :P_LOAN_ID
   AND STATUS_FLAG IN ('PENDING', 'SKIP', 'PARTIAL');

DECLARE

    P_ENTITY_CODE                    VARCHAR2 (150);

      P_EVENT_TYPE_CODE                VARCHAR2 (150);
      P_INTEREST_EVENT_TYPE_CODE       VARCHAR2 (150);
      P_INTEREST_EARN_TYPE_CODE        VARCHAR2 (150);
      P_PREV_LOAN_EVENT_TYPE_CODE      VARCHAR2 (150);

      P_BATCH_NAME                     VARCHAR2 (150);
      P_JOURNAL_NAME                   VARCHAR2 (150);
      P_HEADER_ID                      NUMBER;
      
      LN_NOT_REC_CODE_COMB             NUMBER;
      LN_LOAN_ID                       NUMBER;
      LN_LOAN_BALANCE_DUE              NUMBER;
      LN_UNE_INT_CODE_COMB             NUMBER;
      
      LN_LINE_COUNTER                  NUMBER := 0;
      LN_TRANSFER_AMOUNT               NUMBER;
      LN_NEW_LOAN_NUMBER               NUMBER;
      LN_TRANSFER_INTEREST_AMOUNT      NUMBER;
      LN_PREVIOUS_LOAN_NUMBER          NUMBER;
      
BEGIN


     BEGIN
         SELECT LOAN_ID, LOAN_BALANCE
           INTO LN_LOAN_ID, LN_LOAN_BALANCE_DUE
           FROM ATET_SB_LOANS
          WHERE LOAN_STATUS_FLAG = 'ACTIVE' AND LOAN_ID = :P_LOAN_ID;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE (
               'No se encuentra el préstamo a transferir');

            ATET_SB_BACK_OFFICE_PKG.LOG_ERRORS (
               'TRANSFER_TO_GUARANTEES => NO SE ENCUENTRA EL PRESTAMO A TRANSFERIR',
               P_ERROR_MESSAGE   => SQLERRM);

            RAISE;
      END;

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
                                                    
    IF ATET_SAVINGS_BANK_PKG.GET_MEMBER_IS_SAVER (:LN_MEMBER_ID) = 'Y'
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
           
           
    SELECT LOAN_NUMBER
      INTO LN_NEW_LOAN_NUMBER
      FROM ATET_SB_LOANS
     WHERE 1 = 1
       AND LOAN_ID = :LN_NEW_LOAN_ID;
       
    SELECT LOAN_NUMBER
      INTO LN_PREVIOUS_LOAN_NUMBER
      FROM ATET_SB_LOANS
     WHERE 1 = 1 
       AND LOAN_ID = :P_LOAN_ID;
           
       
    SELECT SUM(NVL(ASPS.OWED_INTEREST, ASPS.PAYMENT_INTEREST))
      INTO LN_TRANSFER_INTEREST_AMOUNT
      FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
     WHERE LOAN_ID = :P_LOAN_ID
       AND STATUS_FLAG IN ('PENDING', 'SKIP', 'PARTIAL');
               
           

    LN_TRANSFER_AMOUNT := LN_LOAN_BALANCE_DUE;        
           
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
                                                 || :MEMBER_ENDORSEMENT_ID
                                                 || ' '
                                                 || LN_NEW_LOAN_NUMBER,
                     P_SOURCE_ID               => :LN_NEW_LOAN_ID,
                     P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');

                  LN_LINE_COUNTER := LN_LINE_COUNTER + 1;

                  ---- INTERESES POR DEVENGAR NUEVO PRÉSTAMO
                  ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES (
                     P_HEADER_ID               => P_HEADER_ID,
                     P_ROW_NUMBER              => LN_LINE_COUNTER,
                     P_CODE_COMBINATION_ID     => LN_UNE_INT_CODE_COMB,
                     P_ACCOUNTING_CLASS_CODE   => P_INTEREST_EARN_TYPE_CODE,
                     P_ACCOUNTED_DR            => 0,
                     P_ACCOUNTED_CR            => LN_TRANSFER_INTEREST_AMOUNT,
                     P_DESCRIPTION             => 'INTERESES DEL PRESTAMO: '
                                                 || LN_NEW_LOAN_NUMBER,
                     P_SOURCE_ID               => :LN_NEW_LOAN_ID,
                     P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS');
                     
                     
    ATET_SAVINGS_BANK_PKG.SETTLEMENT_LOAN (:P_LOAN_ID);
    
    
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
    
    
END;