CREATE OR REPLACE PACKAGE APPS.ATET_SB_BACK_OFFICE_PKG
AS
   PROCEDURE CREATE_PAYMENTS_SCHEDULE (
      P_LOAN_ID             IN            NUMBER,
      P_LAST_PAYMENT_DATE      OUT NOCOPY VARCHAR2);

   PROCEDURE CREATE_LOAN_HOLD (P_LOAN_ID             NUMBER,
                               HOLD_REASON_CODE   IN VARCHAR2 DEFAULT NULL);

   PROCEDURE CREATE_REFINANCE_LOAN_CHECK (
      P_ACTUAL_LOAN_ID              IN            NUMBER,
      P_PREVIOUS_LOAN_ID            IN            NUMBER,
      P_PREVIOUS_LOAN_BALANCE_DUE   IN            NUMBER,
      P_TRANSFER_INTEREST_AMOUNT    IN            NUMBER,
      P_CONDONATE_INTEREST_AMOUNT   IN            NUMBER,
      P_ACTUAL_LOAN_CHECK_AMOUNT    IN            NUMBER,
      P_HAS_PREVIOUS_REFINANCED     IN            NUMBER,
      P_CHECK_NUMBER                IN            NUMBER DEFAULT NULL,
      P_CHECK_ID                       OUT NOCOPY NUMBER);

   PROCEDURE RELEASE_LOAN_HOLD (
      ERRBUF                    OUT NOCOPY VARCHAR2,
      RETCODE                   OUT NOCOPY VARCHAR2,
      P_LOAN_ID                            NUMBER,
      P_REASON_DESCRIPTION                 VARCHAR2,
      P_RELEASE_FLAG                       VARCHAR2);

   FUNCTION FIND_CROSS_ENDORSEMENT (P_MEMBER_BORROWER_ID       NUMBER,
                                    P_MEMBER_ENDORSEMENT_ID    NUMBER)
      RETURN NUMBER;

   PROCEDURE CREATE_LOAN_CHECK (P_LOAN_ID    IN            NUMBER,
                                P_CHECK_ID      OUT NOCOPY NUMBER);


   PROCEDURE CREATE_XLA_HEADER (P_ENTITY_CODE       IN            VARCHAR2,
                                P_EVENT_TYPE_CODE   IN            VARCHAR2,
                                P_BATCH_NAME        IN            VARCHAR,
                                P_JOURNAL_NAME      IN            VARCHAR,
                                P_HEADER_ID            OUT NOCOPY NUMBER);


   PROCEDURE CREATE_XLA_LINES (P_HEADER_ID               IN NUMBER,
                               P_ROW_NUMBER                 NUMBER,
                               P_CODE_COMBINATION_ID        NUMBER,
                               P_ACCOUNTING_CLASS_CODE      VARCHAR2,
                               P_ACCOUNTED_DR               NUMBER,
                               P_ACCOUNTED_CR               NUMBER,
                               P_DESCRIPTION                VARCHAR2,
                               P_SOURCE_ID                  NUMBER,
                               P_SOURCE_LINK_TABLE          VARCHAR2);

   FUNCTION SUBMIT_GL_IMPORT (p_gl_access_set_id   IN NUMBER,
                              p_ledger_id          IN NUMBER,
                              p_je_source_name     IN VARCHAR2,
                              p_group_id           IN NUMBER)
      RETURN NUMBER;


   PROCEDURE TRANSFER_JOURNALS_TO_GL;

   FUNCTION GET_PARAMETER_VALUE (P_PARAMETER_CODE    VARCHAR2,
                                 P_SAVING_BANK_ID    NUMBER)
      RETURN VARCHAR2;


   PROCEDURE REFINANCE_LOAN (
      ERRBUF                            OUT NOCOPY VARCHAR2,
      RETCODE                           OUT NOCOPY VARCHAR2,
      P_MEMBER_ID                    IN            NUMBER,
      P_SUBSIDY_INTERES_PERCENTAJE   IN            NUMBER);

   PROCEDURE CREATE_ELECTRONIC_SIGNATURE (
      P_INPUT_STRING    IN            VARCHAR2,
      P_OUTPUT_STRING      OUT NOCOPY VARCHAR2,
      P_OUTPUT_KEY         OUT NOCOPY VARCHAR2);

   PROCEDURE PRINT_CHECK (P_CHECK_ID NUMBER);

   PROCEDURE CANCEL_LOAN (ERRBUF         OUT NOCOPY VARCHAR2,
                          RETCODE        OUT NOCOPY VARCHAR2,
                          P_LOAN_ID   IN            NUMBER);

   PROCEDURE PRINT_PROMISSORY_NOTE (P_LOAN_ID NUMBER);

   PROCEDURE PRINT_PREPAID (P_LOAN_ID                      NUMBER,
                            P_CONDONATE_INTEREST_AMOUNT    NUMBER);

   PROCEDURE PRINT_INTEREST_SUBSIDY (P_LOAN_ID NUMBER);

   PROCEDURE TRANSFER_TO_GUARANTEES (
      ERRBUF                  OUT NOCOPY VARCHAR2,
      RETCODE                 OUT NOCOPY VARCHAR2,
      P_LOAN_ID            IN            NUMBER,
      P_DISCOUNT_PERIODS                 NUMBER);

   PROCEDURE LOG_ERRORS (P_CODE_SECTION       VARCHAR2,
                         P_ERROR_MESSAGE   IN VARCHAR2);

   FUNCTION GET_SOURCE_LINK_DATA (P_SOURCE_ID            NUMBER,
                                  P_SOURCE_LINK_TABLE    VARCHAR2)
      RETURN VARCHAR2;
END ATET_SB_BACK_OFFICE_PKG;
/
