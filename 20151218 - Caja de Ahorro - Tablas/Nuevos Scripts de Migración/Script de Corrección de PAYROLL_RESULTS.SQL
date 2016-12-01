/**************************************************/
/*                  ALTER SESION                  */
/**************************************************/
ALTER SESSION SET CURRENT_SCHEMA=APPS; 

delete atet_sb_payroll_results
 where period_name like '%Semana%'
   and element_name = 'D072_PRESTAMO CAJA DE AHORRO'
   and period_name = '48 2016 Semana'
   and entry_name = 'Folio';
   
commit;

/**************************************************/

ATET_SB_MEMBERS
ATET_SB_LOANS
ATET_SB_PAYROLL_RESULTS

/*************************************************/
/**
    Consulta de ATET_SB_PAYROLL_RESULTS
        para obtener TOO_MANY_ROWS              **/
/*************************************************/
BEGIN
    DBMS_OUTPUT.PUT_LINE('*************************************************************************************');
END;



DECLARE

    var_loan_id     NUMBER;

    CURSOR DETAIL_LIST_LOANS IS
        SELECT ASPR.EXPORT_REQUEST_ID,
               ASPR.PAYROLL_RESULT_ID,
               ASPR.PERSON_ID,
               ASPR.ASSIGNMENT_ID,
               ASPR.ASSIGNMENT_ACTION_ID,
               ASPR.PAYROLL_ACTION_ID,
               ASPR.EARNED_DATE,
               ASPR.TIME_PERIOD_ID,
               ASPR.PERIOD_NAME,
               ASPR.PAYROLL_STATUS,
               ASPR.ELEMENT_NAME,
               ASPR.ENTRY_NAME,
               ASPR.ENTRY_UNITS,
               ASPR.ENTRY_VALUE,
               ASPR.RUN_RESULT_ID,
               ASPR.ELEMENT_ENTRY_ID
          FROM ATET_SB_PAYROLL_RESULTS  ASPR
         WHERE 1 = 1
           AND ASPR.ELEMENT_NAME = ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME')
           AND ASPR.ENTRY_NAME = 'Pay Value'
           AND ASPR.PERIOD_NAME = :VAR_PERIOD_NAME;  
BEGIN

    FOR detail_loan IN DETAIL_LIST_LOANS LOOP
    
        BEGIN
    
    
            SELECT ASL.LOAN_ID
              INTO var_loan_id
              FROM ATET_SB_MEMBERS              ASM,
                   ATET_SB_LOANS                ASL,
                   ATET_SB_PAYMENTS_SCHEDULE    ASPS
             WHERE ASM.PERSON_ID = detail_loan.PERSON_ID
               AND ASM.SAVING_BANK_ID = ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
               AND ASM.MEMBER_ID = ASL.MEMBER_ID
               AND ASL.LOAN_STATUS_FLAG = 'ACTIVE'
               AND ASL.LOAN_ID = ASPS.LOAN_ID
               AND ASPS.PAYMENT_NUMBER = 1;
    

--            DBMS_OUTPUT.PUT_LINE('PRESTAMO : ' || var_loan_id || ' OK');
            
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
                DBMS_OUTPUT.PUT_LINE('NO_DATA_FOUND Person_id : ' ||  detail_loan.PERSON_ID || ' ' || 
                                        ' RunResultID : ' || detail_loan.RUN_RESULT_ID || ' ' ||  
                                        ' EARNED_DATE : ' || detail_loan.EARNED_DATE || ' ' ||
                                        ' ENTRY_VALUE : ' || detail_loan.ENTRY_VALUE || ' ' ||
                                        ' TOO_MANY_ROWS ' || :VAR_PERIOD_NAME);
            WHEN TOO_MANY_ROWS THEN
--                DBMS_OUTPUT.PUT_LINE('PRESTAMO : ' || var_loan_id || ' TOO_MANY_ROWS  RUN_RESULT_ID ' || detail_loan.RUN_RESULT_ID);
                BEGIN
                
                    
                    SELECT ASL.LOAN_ID
                      INTO var_loan_id
                      FROM ATET_SB_MEMBERS              ASM,
                           ATET_SB_LOANS                ASL,
                           ATET_SB_PAYMENTS_SCHEDULE    ASPS
                     WHERE ASM.PERSON_ID = detail_loan.PERSON_ID
                       AND ASM.SAVING_BANK_ID = ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
                       AND ASM.MEMBER_ID = ASL.MEMBER_ID
                       AND ASL.LOAN_STATUS_FLAG = 'ACTIVE'
                       AND ASL.LOAN_ID = ASPS.LOAN_ID
                       AND ASPS.PAYMENT_NUMBER = 1
                       AND TRUNC(ASPS.PAYMENT_AMOUNT, 0) = TRUNC((SELECT ASPR.ENTRY_VALUE
                                                                  FROM ATET_SB_PAYROLL_RESULTS  ASPR
                                                                 WHERE 1 = 1
                                                                   AND ASPR.PERSON_ID = detail_loan.PERSON_ID
                                                                   AND ASPR.EXPORT_REQUEST_ID = detail_loan.EXPORT_REQUEST_ID
                                                                   AND ASPR.RUN_RESULT_ID = detail_loan.RUN_RESULT_ID
                                                                   AND ASPR.ENTRY_NAME = 'Amount'),0);
                
                
                EXCEPTION 
                    WHEN TOO_MANY_ROWS THEN
                        DBMS_OUTPUT.PUT_LINE('Person_id : ' ||  detail_loan.PERSON_ID || ' ' || 
                                                ' RunResultID : ' || detail_loan.RUN_RESULT_ID || ' ' ||  
                                                ' EARNED_DATE : ' || detail_loan.EARNED_DATE || ' ' ||
                                                ' ENTRY_VALUE : ' || detail_loan.ENTRY_VALUE || ' ' ||
                                                ' TOO_MANY_ROWS ' || :VAR_PERIOD_NAME);   
                    WHEN NO_DATA_FOUND THEN
                         DBMS_OUTPUT.PUT_LINE(' NO_DATA_FOUND Person_id : ' ||  detail_loan.PERSON_ID || ' ' ||
                                                ' RunResultID : ' || detail_loan.RUN_RESULT_ID || ' ' ||  
                                                ' EARNED_DATE : ' || detail_loan.EARNED_DATE || ' ' ||
                                                ' ENTRY_VALUE : ' || detail_loan.ENTRY_VALUE || ' ' ||
                                                ' NO_DATA_FOUND ' || :VAR_PERIOD_NAME);
                END;
            
        END;
    
    END LOOP;
    
END;



/**********************************************************/
/**     Bloque para insertar en 
            ATET_SB_PAYROLL_RESULTS                     ***/
/**********************************************************/
select asl.*
  from atet_Sb_loans    asl,
       atet_sb_members  asm
 where 1 = 1
   and asl.MEMBER_ID = asm.MEMBER_ID
   and asm.person_id = :p_person_id
   and asl.LOAN_STATUS_FLAG = 'ACTIVE';



BEGIN

    INSERT 
        INTO ATET_SB_PAYROLL_RESULTS
             (PERSON_ID,
              ASSIGNMENT_ID,
              ASSIGNMENT_ACTION_ID,
              PAYROLL_ACTION_ID,
              EARNED_DATE,
              TIME_PERIOD_ID,
              PERIOD_NAME,
              PAYROLL_STATUS,
              ELEMENT_NAME,
              ENTRY_NAME,
              ENTRY_UNITS,
              ENTRY_VALUE,
              RUN_RESULT_ID,
              ELEMENT_ENTRY_ID,
              EXPORT_REQUEST_ID,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY)
       SELECT PERSON_ID,
              ASSIGNMENT_ID,
              ASSIGNMENT_ACTION_ID,
              PAYROLL_ACTION_ID,
              EARNED_DATE,
              TIME_PERIOD_ID,
              PERIOD_NAME,
              PAYROLL_STATUS,
              ELEMENT_NAME,
              'Folio',
              'Numero',
              :P_FOLIO,
              RUN_RESULT_ID,
              ELEMENT_ENTRY_ID,
              EXPORT_REQUEST_ID,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY 
         FROM ATET_SB_PAYROLL_RESULTS
        WHERE 1 = 1
          AND PERSON_ID = :P_PERSON_ID
          AND RUN_RESULT_ID = :P_RUN_RESULT_ID
          AND ENTRY_NAME = 'Amount';
          
    COMMIT;

END; 



/**************************************************************/
/**
            Consulta de ATET_SB_PAYROLL_RESULTS
            a partir de RUN_RESULT_ID                         */
/**************************************************************/
SELECT PERSON_ID,
      ASSIGNMENT_ID,
      ASSIGNMENT_ACTION_ID,
      PAYROLL_ACTION_ID,
      EARNED_DATE,
      TIME_PERIOD_ID,
      PERIOD_NAME,
      PAYROLL_STATUS,
      ELEMENT_NAME,
      ENTRY_NAME,
      ENTRY_UNITS,
      ENTRY_VALUE,
      RUN_RESULT_ID,
      ELEMENT_ENTRY_ID,
      EXPORT_REQUEST_ID,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY 
 FROM ATET_SB_PAYROLL_RESULTS
WHERE 1 = 1
  AND RUN_RESULT_ID = :P_RUN_RESULT_ID;




/************************************************************/
/***
        Bloque de separación de pagos
            de ATET_SB_PAYROLLL_RESULTS                     */
/************************************************************/
DECLARE
BEGIN

    INSERT 
        INTO ATET_SB_PAYROLL_RESULTS
             (PERSON_ID,
              ASSIGNMENT_ID,
              ASSIGNMENT_ACTION_ID,
              PAYROLL_ACTION_ID,
              EARNED_DATE,
              TIME_PERIOD_ID,
              PERIOD_NAME,
              PAYROLL_STATUS,
              ELEMENT_NAME,
              ENTRY_NAME,
              ENTRY_UNITS,
              ENTRY_VALUE,
              RUN_RESULT_ID,
              ELEMENT_ENTRY_ID,
              EXPORT_REQUEST_ID,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY)
       SELECT PERSON_ID,
              ASSIGNMENT_ID,
              ASSIGNMENT_ACTION_ID,
              PAYROLL_ACTION_ID,
              EARNED_DATE,
              TIME_PERIOD_ID,
              PERIOD_NAME,
              PAYROLL_STATUS,
              ELEMENT_NAME,
              'Folio',
              'Numero',
              :P_FOLIO_1,
              RUN_RESULT_ID,
              ELEMENT_ENTRY_ID,
              EXPORT_REQUEST_ID,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY 
         FROM ATET_SB_PAYROLL_RESULTS
        WHERE 1 = 1
          AND PERSON_ID = :P_PERSON_ID
          AND RUN_RESULT_ID = :P_RUN_RESULT_ID
          AND ENTRY_NAME = 'Amount';



    UPDATE ATET_SB_PAYROLL_RESULTS
       SET ENTRY_VALUE = :P_ENTRY_VALUE_1
     WHERE 1 = 1
       AND PERSON_ID = :P_PERSON_ID
       AND RUN_RESULT_ID = :P_RUN_RESULT_ID
       AND ENTRY_NAME IN ('Amount', 'Pay Value');
       
       
    INSERT 
        INTO ATET_SB_PAYROLL_RESULTS
             (PERSON_ID,
              ASSIGNMENT_ID,
              ASSIGNMENT_ACTION_ID,
              PAYROLL_ACTION_ID,
              EARNED_DATE,
              TIME_PERIOD_ID,
              PERIOD_NAME,
              PAYROLL_STATUS,
              ELEMENT_NAME,
              ENTRY_NAME,
              ENTRY_UNITS,
              ENTRY_VALUE,
              RUN_RESULT_ID,
              ELEMENT_ENTRY_ID,
              EXPORT_REQUEST_ID,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY)
       SELECT PERSON_ID,
              ASSIGNMENT_ID,
              ASSIGNMENT_ACTION_ID,
              PAYROLL_ACTION_ID,
              EARNED_DATE,
              TIME_PERIOD_ID,
              PERIOD_NAME,
              PAYROLL_STATUS,
              ELEMENT_NAME,
              ENTRY_NAME,
              ENTRY_UNITS,
              1,
              RUN_RESULT_ID+5,
              ELEMENT_ENTRY_ID+5,
              EXPORT_REQUEST_ID,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY 
         FROM ATET_SB_PAYROLL_RESULTS
        WHERE 1 = 1
          AND PERSON_ID = :P_PERSON_ID
          AND RUN_RESULT_ID = :P_RUN_RESULT_ID;
          
          
          
    UPDATE ATET_SB_PAYROLL_RESULTS
       SET ENTRY_VALUE = :P_ENTRY_VALUE_2
     WHERE 1 = 1
       AND PERSON_ID = :P_PERSON_ID
       AND RUN_RESULT_ID = :P_RUN_RESULT_ID+5
       AND ENTRY_NAME IN ('Amount', 'Pay Value');       
       
       
       
    UPDATE ATET_SB_PAYROLL_RESULTS
       SET ENTRY_VALUE = :P_FOLIO_2
     WHERE 1 = 1
       AND PERSON_ID = :P_PERSON_ID
       AND RUN_RESULT_ID = :P_RUN_RESULT_ID+5
       AND ENTRY_NAME IN ('Folio');

    COMMIT;       

END;




SELECT PERSON_ID,
      ASSIGNMENT_ID,
      ASSIGNMENT_ACTION_ID,
      PAYROLL_ACTION_ID,
      EARNED_DATE,
      TIME_PERIOD_ID,
      PERIOD_NAME,
      PAYROLL_STATUS,
      ELEMENT_NAME,
      ENTRY_NAME,
      ENTRY_UNITS,
      ENTRY_VALUE,
      RUN_RESULT_ID,
      ELEMENT_ENTRY_ID,
      EXPORT_REQUEST_ID,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY 
 FROM ATET_SB_PAYROLL_RESULTS
WHERE 1 = 1
  AND PERSON_ID = :P_PERSON_ID
  AND PERIOD_NAME = :P_PERIOD_NAME;



          
          
       