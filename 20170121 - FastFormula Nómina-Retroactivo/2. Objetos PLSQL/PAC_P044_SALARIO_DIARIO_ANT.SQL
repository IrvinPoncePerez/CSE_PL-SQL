CREATE OR REPLACE FUNCTION APPS.PAC_P044_SALARIO_DIARIO_ANT
    (
        P_ASSIGNMENT_ID       NUMBER
    )
RETURN NUMBER
IS
    var_result      NUMBER;
BEGIN

    SELECT D.PROPOSED_SALARY_N / 30
      INTO var_result
      FROM (SELECT PPP.PROPOSED_SALARY_N,
                   PPP.DATE_TO
              FROM PER_PAY_PROPOSALS    PPP
             WHERE 1 = 1
               AND PPP.ASSIGNMENT_ID = P_ASSIGNMENT_ID
               AND PPP.DATE_TO <> TO_DATE('31/12/4712', 'DD/MM/RRRR')
               AND EXTRACT(YEAR FROM PPP.DATE_TO) = 2017  
             ORDER 
                BY DATE_TO DESC
           ) D
     WHERE 1 = 1
       AND ROWNUM = 1;
       
    RETURN var_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END PAC_P044_SALARIO_DIARIO_ANT;