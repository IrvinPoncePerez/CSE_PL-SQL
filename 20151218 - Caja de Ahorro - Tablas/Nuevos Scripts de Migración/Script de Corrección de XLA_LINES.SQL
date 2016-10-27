/**************************************************/
/*                  ALTER SESION                  */
/**************************************************/
ALTER SESSION SET CURRENT_SCHEMA=APPS; 




/*****************************************************/
/*      correccón de ATET_XLA_LINES
    en Intereses del Prestamo Refinanciado          **/
/*****************************************************/
DECLARE
    var_header_id       NUMBER := :P_HEADER_ID;
BEGIN


    UPDATE ATET_XLA_LINES
       SET ACCOUNTED_DR = TRUNC(ACCOUNTED_DR, 0)
     WHERE 1 = 1
       AND CODE_COMBINATION_ID = 634167
       AND ACCOUNTING_CLASS_CODE = 'INTEREST_EARN'
       AND DESCRIPTION LIKE '%INTERESES DEL PRESTAMO REFINANCIADO%'
       AND HEADER_ID = var_header_id;
       
    COMMIT;

END;




/*****************************************************/
/*      correccón de ATET_XLA_LINES
    en Intereses Cobrados Prestamo Refinanciado     **/
/*****************************************************/
DECLARE
    var_header_id       NUMBER := :P_HEADER_ID;
BEGIN


    UPDATE ATET_XLA_LINES
       SET ACCOUNTED_CR = :P_ACCOUNTED_CR
     WHERE 1 = 1
       AND CODE_COMBINATION_ID = 634170
       AND ACCOUNTING_CLASS_CODE = 'REFINANCED_SUBSIDIZED'
       AND DESCRIPTION LIKE '%INTERESES COBRADOS DEL PRESTAMO REFINANCIADO%'
       AND HEADER_ID = var_header_id;
       
    COMMIT;

END;


/*****************************************************/
/**     Creación de movimiento de ajuste en
            ATET_XLA_LINES                          **/
/*****************************************************/
DECLARE
    var_header_id       NUMBER := :P_HEADER_ID;
BEGIN

    INSERT 
      INTO ATET_XLA_LINES(HEADER_ID,
                          LINE_NUMBER,
                          CODE_COMBINATION_ID,
                          GL_TRANSFER_MODE_CODE,
                          ACCOUNTING_CLASS_CODE,
                          DESCRIPTION,
                          ACCOUNTED_DR,
                          ACCOUNTED_CR,
                          CURRENCY_CODE,
                          LEDGER_ID,
                          SOURCE_ID,
                          SOURCE_LINK_TABLE,
                          CREATION_DATE,
                          CREATED_BY,
                          LAST_UPDATE_DATE,
                          LAST_UPDATED_BY)
                   SELECT HEADER_ID,
                          7,
                          CODE_COMBINATION_ID,
                          GL_TRANSFER_MODE_CODE,
                          'AJUSTE',
                          'AJUSTE DE PRESTAMO',
                          :P_ACCOUNTED_DR,
                          ACCOUNTED_CR,
                          CURRENCY_CODE,
                          LEDGER_ID,
                          SOURCE_ID,
                          SOURCE_LINK_TABLE,
                          CREATION_DATE,
                          CREATED_BY,
                          LAST_UPDATE_DATE,
                          LAST_UPDATED_BY
                     FROM ATET_XLA_LINES
                    WHERE 1 = 1
                      AND HEADER_ID = var_header_id
                      AND ACCOUNTING_CLASS_CODE = 'REFINANCED_LOAN_CREATION';
                      
                      
    COMMIT;

END;