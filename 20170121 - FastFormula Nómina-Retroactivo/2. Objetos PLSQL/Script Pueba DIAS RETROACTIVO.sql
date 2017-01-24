SELECT PRRV.RESULT_VALUE       AS  DAYS,
                   PPA.EFFECTIVE_DATE
              FROM PAY_ASSIGNMENT_ACTIONS       PAA,
                   PAY_PAYROLL_ACTIONS          PPA,
                   PAY_RUN_RESULTS              PRR,
                   PAY_ELEMENT_TYPES_F          PETF,
                   PAY_RUN_RESULT_VALUES        PRRV,
                   PAY_INPUT_VALUES_F           PIVF,
                   PAY_ELEMENT_CLASSIFICATIONS  PEC
             WHERE 1 = 1
               AND PAA.ASSIGNMENT_ID = :P_ASSIGNMENT_ID
               AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID 
               AND EXTRACT(YEAR FROM PPA.EFFECTIVE_DATE) = EXTRACT(YEAR FROM :P_DATE)
               AND PPA.EFFECTIVE_DATE < :P_DATE 
               AND PPA.ACTION_TYPE IN ('Q', 'R')
               AND PAA.RUN_TYPE_ID IS NOT NULL
               AND PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
               AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
               AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
               AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
               AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
               AND SYSDATE <= PETF.EFFECTIVE_END_DATE
               AND PETF.ELEMENT_NAME = :P_ELEMENT_NAME
               AND PIVF.NAME IN ('Dias Recibo', 'Dias Normales')
             ORDER BY PPA.EFFECTIVE_DATE;
             

declare
    var_result  NUMBER;             
begin
    var_result := PAC_P044_DIAS_RETROACTIVOS
                    (
                        P_ASSIGNMENT_ID => 6465,
                        P_DATE          => TO_DATE('16/01/2017', 'DD/MM/RRRR'),
                        P_ELEMENT_NAME  => 'P001_SUELDO NORMAL',
                        P_PAYROLL       => '02_SEM - CEDIS TUXTEPEC'
                    );
                    
    var_result := var_result + PAC_P044_DIAS_RETROACTIVOS
                               (
                                    P_ASSIGNMENT_ID => 6465,
                                    P_DATE          => TO_DATE('16/01/2017', 'DD/MM/RRRR'),
                                    P_ELEMENT_NAME  => 'P005_VACACIONES',
                                    P_PAYROLL       => '02_SEM - CEDIS TUXTEPEC'
                               );
                               
    DBMS_OUTPUT.PUT_LINE(var_result);
end;


DECLARE
    var_result  NUMBER;
BEGIN
    var_result := PAC_P044_SALARIO_DIARIO_ANT(6465);
    DBMS_OUTPUT.PUT_LINE(var_result);
    var_result := PAC_P044_SALARIO_DIARIO_ANT(1751);
    DBMS_OUTPUT.PUT_LINE(var_result);
END;