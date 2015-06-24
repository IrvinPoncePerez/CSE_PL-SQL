CREATE OR REPLACE PACKAGE BODY PAC_P047_FUNCTIONS_PKG AS

    FUNCTION GET_BALANCE(P_ASSIGNMENT_ID        NUMBER)
    RETURN NUMBER IS
        var_balance     NUMBER := 0;
    BEGIN
    
        BEGIN
            SELECT RESULT_VALUE
              INTO var_balance
              FROM (SELECT PPA.DATE_EARNED,
                           PRRV.RESULT_VALUE,
                           PIVF.NAME
                      FROM PAY_ASSIGNMENT_ACTIONS       PAA,
                           PAY_PAYROLL_ACTIONS          PPA,
                           PAY_RUN_TYPES_X              PRTX,
                           PAY_RUN_RESULTS              PRR,
                           PAY_ELEMENT_TYPES_F          PETF,
                           PAY_RUN_RESULT_VALUES        PRRV,
                           PAY_INPUT_VALUES_F           PIVF,
                           PAY_ELEMENT_CLASSIFICATIONS  PEC
                     WHERE 1 = 1
                       AND PAA.ASSIGNMENT_ID = P_ASSIGNMENT_ID
                       AND PPA.PAYROLL_ACTION_ID = PAA.PAYROLL_ACTION_ID
                       AND PRTX.RUN_TYPE_ID = PAA.RUN_TYPE_ID
--                       AND PRTX.RUN_TYPE_NAME = 'Standard'          
                       AND PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
                       AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
                       AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
                       AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
                       AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
                       AND SYSDATE <= PETF.EFFECTIVE_END_DATE
                       AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
                       AND PEC.CLASSIFICATION_NAME = 'Earnings' 
                       AND PETF.ELEMENT_NAME = 'P047_ISPT ANUAL A FAVOR'
                       AND PIVF.NAME = 'Saldo_Pendiente'
                     ORDER BY TO_DATE(PPA.DATE_EARNED) DESC) D
             WHERE ROWNUM = 1;
        EXCEPTION WHEN OTHERS THEN
            var_balance := 0;
        END;
        
        RETURN var_balance;
    END;
    

END PAC_P047_FUNCTIONS_PKG;