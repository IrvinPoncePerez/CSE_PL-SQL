CREATE OR REPLACE PACKAGE BODY PAC_RESULT_VALUES_PKG AS


    FUNCTION GET_EARNING_VALUE (
            P_ASSIGNMENT_ACTION_ID    NUMBER,
            P_ELEMENT_NAME            VARCHAR2,
            P_INPUT_VALUE_NAME        VARCHAR2)
    RETURN VARCHAR2
    IS
        result_value    VARCHAR2(200);
    BEGIN
        SELECT
            TO_CHAR(SUM(PRRV.RESULT_VALUE))
          INTO
            result_value
          FROM PAY_RUN_RESULTS              PRR,
               PAY_ELEMENT_TYPES_F          PETF,
               PAY_RUN_RESULT_VALUES        PRRV,
               PAY_INPUT_VALUES_F           PIVF,
               PAY_ELEMENT_CLASSIFICATIONS  PEC
         WHERE PRR.ASSIGNMENT_ACTION_ID = P_ASSIGNMENT_ACTION_ID
           AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
           AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
           AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
           AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
           AND SYSDATE <= PETF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
           AND (PEC.CLASSIFICATION_NAME IN ('Earnings', 
                                            'Supplemental Earnings', 
                                            'Imputed Earnings',
                                            'Amends') 
                  OR PETF.ELEMENT_NAME  IN (SELECT MEANING
                                              FROM FND_LOOKUP_VALUES 
                                             WHERE LOOKUP_TYPE = 'XX_PERCEPCIONES_INFORMATIVAS'
                                               AND LANGUAGE = USERENV('LANG')))
           AND PETF.ELEMENT_NAME = P_ELEMENT_NAME
           AND PIVF.NAME = P_INPUT_VALUE_NAME;
--           AND ROWNUM = 1;
           
        RETURN result_value;
    
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;        
              WHEN OTHERS THEN
        dbms_output.put_line('**Error en la función GET_EARNING_VALUE, assignment_action_id = ' || P_ASSIGNMENT_ACTION_ID || ', element_name=' || P_ELEMENT_NAME || ', input_value_name=' || P_INPUT_VALUE_NAME || '. ' || SQLERRM);
        FND_FILE.put_line(FND_FILE.LOG, '**Error en la función GET_EARNING_VALUE, assignment_action_id = ' || P_ASSIGNMENT_ACTION_ID|| ', element_name=' || P_ELEMENT_NAME || ', input_value_name=' || P_INPUT_VALUE_NAME || '. ' || SQLERRM);
    END;

    
    FUNCTION GET_DEDUCTION_VALUE (
            P_ASSIGNMENT_ACTION_ID    NUMBER,
            P_ELEMENT_NAME            VARCHAR2,
            P_INPUT_VALUE_NAME        VARCHAR2)
    RETURN VARCHAR2
    IS 
        result_value    VARCHAR2(200);
    BEGIN
        SELECT 
            TO_CHAR(SUM(PRRV.RESULT_VALUE))
          INTO
            result_value
          FROM PAY_RUN_RESULTS              PRR,
               PAY_ELEMENT_TYPES_F          PETF,
               PAY_RUN_RESULT_VALUES        PRRV,
               PAY_INPUT_VALUES_F           PIVF,
               PAY_ELEMENT_CLASSIFICATIONS  PEC
         WHERE PRR.ASSIGNMENT_ACTION_ID = P_ASSIGNMENT_ACTION_ID
           AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
           AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
           AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
           AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
           AND SYSDATE <= PETF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
           AND (PEC.CLASSIFICATION_NAME IN ('Voluntary Deductions', 
                                            'Involuntary Deductions') 
                   OR PETF.ELEMENT_NAME IN (SELECT MEANING
                                              FROM FND_LOOKUP_VALUES 
                                             WHERE LOOKUP_TYPE = 'XX_DEDUCCIONES_INFORMATIVAS'
                                               AND LANGUAGE = USERENV('LANG')))
           AND PETF.ELEMENT_NAME = P_ELEMENT_NAME
           AND PIVF.NAME = P_INPUT_VALUE_NAME;
--           AND ROWNUM = 1;
           
        RETURN result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;        
              WHEN OTHERS THEN
        dbms_output.put_line('**Error en la función GET_DEDUCTION_VALUE, assignment_action_id = ' || P_ASSIGNMENT_ACTION_ID || ', element_name=' || P_ELEMENT_NAME || ', input_value_name=' || P_INPUT_VALUE_NAME || '. ' || SQLERRM);
        FND_FILE.put_line(FND_FILE.LOG, '**Error en la función GET_DEDUCTION_VALUE, assignment_action_id = ' || P_ASSIGNMENT_ACTION_ID || ', element_name=' || P_ELEMENT_NAME || ', input_value_name=' || P_INPUT_VALUE_NAME || '. ' || SQLERRM);
    END;
    

    FUNCTION GET_INFORMATION_VALUE (
            P_ASSIGNMENT_ACTION_ID    NUMBER,
            P_ELEMENT_NAME            VARCHAR2,
            P_INPUT_VALUE_NAME        VARCHAR2)
    RETURN VARCHAR2
    IS
        result_value    VARCHAR2(200);
    BEGIN
        SELECT 
            TO_CHAR(SUM(PRRV.RESULT_VALUE))
          INTO
            result_value
          FROM PAY_RUN_RESULTS              PRR,
               PAY_ELEMENT_TYPES_F          PETF,
               PAY_RUN_RESULT_VALUES        PRRV,
               PAY_INPUT_VALUES_F           PIVF,
               PAY_ELEMENT_CLASSIFICATIONS  PEC
         WHERE PRR.ASSIGNMENT_ACTION_ID = P_ASSIGNMENT_ACTION_ID
           AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
           AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
           AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
           AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
           AND SYSDATE <= PETF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
           AND (PEC.CLASSIFICATION_NAME IN ('Information'))
           AND PETF.ELEMENT_NAME = P_ELEMENT_NAME
           AND PIVF.NAME = P_INPUT_VALUE_NAME;
--           AND ROWNUM = 1;
           
        RETURN result_value;
        
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;        
              WHEN OTHERS THEN
        dbms_output.put_line('**Error en la función GET_INFORMATION_VALUE, assignment_action_id = ' || P_ASSIGNMENT_ACTION_ID || ', element_name=' || P_ELEMENT_NAME || ', input_value_name=' || P_INPUT_VALUE_NAME || '. ' || SQLERRM);
        FND_FILE.put_line(FND_FILE.LOG, '**Error en la función GET_INFORMATION_VALUE, assignment_action_id = ' || P_ASSIGNMENT_ACTION_ID || ', element_name=' || P_ELEMENT_NAME || ', input_value_name=' || P_INPUT_VALUE_NAME || '. ' || SQLERRM);
    END;   
    
    
    FUNCTION GET_OTHER_VALUE (
            P_ASSIGNMENT_ACTION_ID    NUMBER,
            P_ELEMENT_NAME            VARCHAR2,
            P_INPUT_VALUE_NAME        VARCHAR2)
    RETURN VARCHAR2
    IS
        result_value    VARCHAR2(200);
    BEGIN
         SELECT 
                TO_CHAR(PRRV.RESULT_VALUE)
           INTO
                result_value
           FROM PAY_RUN_RESULTS          PRR,
                PAY_ELEMENT_TYPES_F      PETF,
                PAY_RUN_RESULT_VALUES    PRRV,
                PAY_INPUT_VALUES_F       PIVF
          WHERE PRR.ASSIGNMENT_ACTION_ID = P_ASSIGNMENT_ACTION_ID
            AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
            AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
            AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
            AND SYSDATE <= PETF.EFFECTIVE_END_DATE
            AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
            AND PETF.ELEMENT_NAME = P_ELEMENT_NAME
            AND PIVF.NAME = P_INPUT_VALUE_NAME;
            
--            AND ROWNUM = 1;
           
        RETURN result_value;
        
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;        
              WHEN OTHERS THEN
        dbms_output.put_line('**Error en la función GET_OTHER_VALUE, assignment_action_id = ' || P_ASSIGNMENT_ACTION_ID || ', element_name=' || P_ELEMENT_NAME || ', input_value_name=' || P_INPUT_VALUE_NAME || '. ' || SQLERRM);
        FND_FILE.put_line(FND_FILE.LOG, '**Error en la función GET_OTHER_VALUE, assignment_action_id = ' || P_ASSIGNMENT_ACTION_ID || ', element_name=' || P_ELEMENT_NAME || ', input_value_name=' || P_INPUT_VALUE_NAME || '. ' || SQLERRM);
    END;   
    
    
    FUNCTION GET_OTHER_SUM_VALUE (
            P_ASSIGNMENT_ACTION_ID    NUMBER,
            P_ELEMENT_NAME            VARCHAR2,
            P_INPUT_VALUE_NAME        VARCHAR2)
    RETURN VARCHAR2
    IS
        result_value    VARCHAR2(200);
    BEGIN
         SELECT 
                TO_CHAR(SUM(PRRV.RESULT_VALUE))
           INTO
                result_value
           FROM PAY_RUN_RESULTS          PRR,
                PAY_ELEMENT_TYPES_F      PETF,
                PAY_RUN_RESULT_VALUES    PRRV,
                PAY_INPUT_VALUES_F       PIVF
          WHERE PRR.ASSIGNMENT_ACTION_ID = P_ASSIGNMENT_ACTION_ID
            AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
            AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
            AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
            AND SYSDATE <= PETF.EFFECTIVE_END_DATE
            AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
            AND PETF.ELEMENT_NAME = P_ELEMENT_NAME
            AND PIVF.NAME = P_INPUT_VALUE_NAME;
            
--            AND ROWNUM = 1;
           
        RETURN result_value;
        
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;        
              WHEN OTHERS THEN
        dbms_output.put_line('**Error en la función GET_OTHER_SUM_VALUE, assignment_action_id = ' || P_ASSIGNMENT_ACTION_ID || ', element_name=' || P_ELEMENT_NAME || ', input_value_name=' || P_INPUT_VALUE_NAME || '. ' || SQLERRM);
        FND_FILE.put_line(FND_FILE.LOG, '**Error en la función GET_OTHER_SUM_VALUE, assignment_action_id = ' || P_ASSIGNMENT_ACTION_ID || ', element_name=' || P_ELEMENT_NAME || ', input_value_name=' || P_INPUT_VALUE_NAME || '. ' || SQLERRM);
    END;    
    
    
    FUNCTION GET_EXEMPT_VALUE (
             P_ASSIGNMENT_ACTION_ID    NUMBER,
             P_ELEMENT_NAME            VARCHAR2,
             P_INPUT_VALUE_NAME1       VARCHAR2,
             P_INPUT_VALUE_NAME2       VARCHAR2)
      RETURN VARCHAR2
      IS
            var_payvalue               NUMBER;
            var_tope                   NUMBER;
            var_result                 VARCHAR2(50);
      BEGIN
        
            SELECT PAYVALUE,
                   TOPE
              INTO var_payvalue,
                   var_tope    
              FROM (SELECT
                           UPPER(REPLACE(PIVF.NAME, 'Futuro 1' , 'TOPE'))     INPUT_NAME,
                           PRRV.RESULT_VALUE
                      FROM PAY_RUN_RESULTS              PRR,
                           PAY_ELEMENT_TYPES_F          PETF,
                           PAY_RUN_RESULT_VALUES        PRRV,
                           PAY_INPUT_VALUES_F           PIVF,
                           PAY_ELEMENT_CLASSIFICATIONS  PEC
                     WHERE PRR.ASSIGNMENT_ACTION_ID = P_ASSIGNMENT_ACTION_ID
                       AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
                       AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
                       AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
                       AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
                       AND SYSDATE <= PETF.EFFECTIVE_END_DATE
                       AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
                       AND PETF.ELEMENT_NAME = P_ELEMENT_NAME
                       AND (PIVF.NAME = P_INPUT_VALUE_NAME1
                         OR PIVF.NAME = P_INPUT_VALUE_NAME2)
                    ) PIVOT (
                      SUM(RESULT_VALUE) FOR INPUT_NAME IN ('PAY VALUE' AS PAYVALUE,
                                                           'TOPE'      AS TOPE)
                    );
                    
            IF (var_payvalue < var_tope) THEN
                var_result := var_payvalue;
            ELSIF (var_payvalue > var_tope) THEN
                var_result := var_tope * -1;
            ELSE
                var_result := var_payvalue;
            END IF;            
                    

            RETURN var_result;        
      EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;        
              WHEN OTHERS THEN
        dbms_output.put_line('**Error en la función GET_EXEMPT_VALUE, assignment_action_id = ' || P_ASSIGNMENT_ACTION_ID || '. ' || SQLERRM);
        FND_FILE.put_line(FND_FILE.LOG, '**Error en la función GET_EXEMPT_VALUE, assignment_action_id = ' || P_ASSIGNMENT_ACTION_ID || '. ' || SQLERRM);
      END;
      
      
      FUNCTION GET_DATA_MOVEMENT(
             P_PERSON_ID    NUMBER,
             P_TYPE         VARCHAR2,
             P_START_DATE   DATE,
             P_END_DATE     DATE)
      RETURN VARCHAR2
      IS
            var_data        VARCHAR2(500);
      BEGIN
      
          CASE WHEN P_TYPE = 'A' THEN
                  SELECT DISTINCT
                    ('A  ' || MAX(PPTU.EFFECTIVE_START_DATE))
                    INTO var_data
                    FROM PER_PERSON_TYPE_USAGES_F   PPTU,
                         PER_PERIODS_OF_SERVICE     PPOS
                   WHERE PPTU.PERSON_ID = P_PERSON_ID
                     AND PPOS.PERSON_ID = P_PERSON_ID
                     AND PPTU.EFFECTIVE_START_DATE = PPOS.DATE_START
                     AND PPTU.EFFECTIVE_START_DATE BETWEEN P_START_DATE AND P_END_DATE;
                   
               WHEN P_TYPE = 'B' THEN
                  SELECT DISTINCT
                    ('B  ' || MAX(PPOS.ACTUAL_TERMINATION_DATE))
                    INTO var_data
                    FROM PER_PERSON_TYPE_USAGES_F   PPTU,
                         PER_PERIODS_OF_SERVICE     PPOS
                   WHERE PPTU.PERSON_ID = P_PERSON_ID
                     AND PPOS.PERSON_ID = P_PERSON_ID
                     AND PPTU.EFFECTIVE_START_DATE = PPOS.DATE_START
                     AND PPOS.ACTUAL_TERMINATION_DATE BETWEEN P_START_DATE AND P_END_DATE
                     AND PPOS.ACTUAL_TERMINATION_DATE IS NOT NULL;
               WHEN P_TYPE = 'MS' THEN
                  SELECT DISTINCT
                    ('MS ' || MAX(PSP.CHANGE_DATE))
                    INTO var_data
                    FROM PER_PAY_PROPOSALS          PSP,
                         PER_ALL_ASSIGNMENTS_F      PAAF,
                         PER_PERSON_TYPE_USAGES_F   PPTU,
                         PER_PERIODS_OF_SERVICE     PPOS
                   WHERE PAAF.PERSON_ID = P_PERSON_ID
                     AND PPTU.PERSON_ID = P_PERSON_ID
                     AND PPOS.PERSON_ID = P_PERSON_ID
                     AND PPTU.EFFECTIVE_START_DATE = PPOS.DATE_START
                     AND PPOS.PERIOD_OF_SERVICE_ID = PAAF.PERIOD_OF_SERVICE_ID
                     AND PAAF.ASSIGNMENT_ID = PSP.ASSIGNMENT_ID
                     AND PSP.CHANGE_DATE IS NOT NULL
                     AND PSP.CHANGE_DATE <> PPTU.EFFECTIVE_START_DATE
                     AND PSP.CHANGE_DATE BETWEEN P_START_DATE AND P_END_DATE;
                   
          END CASE;
          
          IF (TRIM(var_data) = 'A' OR TRIM(var_data) = 'B' OR TRIM(var_data) = 'MS') THEN
            var_data := NULL;
          END IF;
     
          
          RETURN  var_data;
      
      EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;        
              WHEN OTHERS THEN
        dbms_output.put_line('**Error en la funcion GET_DATA_MOVEMENT. (' || P_PERSON_ID || ',' || P_TYPE || ',' || P_START_DATE || ',' || P_END_DATE || ')' || SQLERRM);
        FND_FILE.put_line(FND_FILE.LOG, '**Error en la funcion GET_DATA_MOVEMENT. (' || P_PERSON_ID || ',' || P_TYPE || ',' || P_START_DATE || ',' || P_END_DATE || ')' || SQLERRM);
      END;
      
      
      FUNCTION GET_EFFECTIVE_START_DATE(
             P_PERSON_ID      NUMBER)
      RETURN DATE
      IS
            var_effective_start_date    DATE;
      BEGIN
      
      
            SELECT MAX(PAPF.EFFECTIVE_START_DATE)
              INTO var_effective_start_date
              FROM PER_ALL_PEOPLE_F         PAPF 
             WHERE PAPF.PERSON_ID = P_PERSON_ID
               AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE ;
      
      
            RETURN var_effective_start_date;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;        
              WHEN OTHERS THEN
        dbms_output.put_line('**Error en la función GET_EFFECTIVE_START_DATET. (' || P_PERSON_ID || ')' || SQLERRM);
        FND_FILE.put_line(FND_FILE.LOG, '**Error en la función GET_EFFECTIVE_START_DATE. (' || P_PERSON_ID || ')' || SQLERRM);
      END;
      
      
      FUNCTION GET_BALANCE(P_ASSIGNMENT_ACTION_ID    NUMBER,
                           P_DATE_EARNED             DATE,
                           P_ELEMENT_NAME            VARCHAR2,
                           P_ENTRY_NAME              VARCHAR2)
        RETURN NUMBER
        IS 
            var_result_value    NUMBER;
        BEGIN
                
            SELECT PEV.SCREEN_ENTRY_VALUE
              INTO var_result_value
              FROM PAY_INPUT_VALUES_F INV,
                   PAY_ELEMENT_ENTRY_VALUES_F PEV,
                   PAY_ELEMENT_TYPES_F PET,
                   PAY_ELEMENT_LINKS_F PEL,
                   PAY_ELEMENT_ENTRIES_F PEE
                WHERE 1 = 1
                  AND INV.INPUT_VALUE_ID = PEV.INPUT_VALUE_ID
                  AND PEE.EFFECTIVE_START_DATE BETWEEN INV.EFFECTIVE_START_DATE
                                                   AND INV.EFFECTIVE_END_DATE
                  AND PEV.ELEMENT_ENTRY_ID = PEE.ELEMENT_ENTRY_ID
                  AND PEE.EFFECTIVE_START_DATE BETWEEN PEV.EFFECTIVE_START_DATE
                                                   AND PEV.EFFECTIVE_END_DATE
                  AND PET.ELEMENT_TYPE_ID = PEL.ELEMENT_TYPE_ID
                  AND PEE.EFFECTIVE_START_DATE BETWEEN PET.EFFECTIVE_START_DATE
                                                   AND PET.EFFECTIVE_END_DATE
                  AND PEL.ELEMENT_LINK_ID = PEE.ELEMENT_LINK_ID
                  AND PEE.EFFECTIVE_START_DATE BETWEEN PEL.EFFECTIVE_START_DATE
                                                   AND PEL.EFFECTIVE_END_DATE
                  AND PEE.ENTRY_TYPE = 'B'
                  AND PET.ELEMENT_NAME = P_ELEMENT_NAME
                  AND INV.NAME = P_ENTRY_NAME
                  AND PEV.EFFECTIVE_END_DATE = P_DATE_EARNED
                  AND PEE.CREATOR_ID = P_ASSIGNMENT_ACTION_ID;

            
            RETURN var_result_value;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 0;
        END;
        
        
      FUNCTION GET_DESPENSA_EXEMPT(P_ASSIGNMENT_ACTION_ID     NUMBER,
                                   P_DESPENSA_RESULT          NUMBER,
                                   P_EFFECTIVE_DATE           DATE)
      RETURN NUMBER
      IS
            var_result              NUMBER := 0;
            var_econ_zone           VARCHAR(1) := 'A';
            var_percent             NUMBER := 40/100;
            var_days                NUMBER := 0;
            var_min_wage            NUMBER := 0;
            var_despensa_exempt     NUMBER := 0;
            
      BEGIN
      
        SELECT 
               SUM(TRUNC(PRRV.RESULT_VALUE, 2))
          INTO var_days
          FROM PAY_RUN_RESULTS          PRR,
               PAY_ELEMENT_TYPES_F      PETF,
               PAY_RUN_RESULT_VALUES    PRRV,
               PAY_INPUT_VALUES_F       PIVF
         WHERE PRR.ASSIGNMENT_ACTION_ID = P_ASSIGNMENT_ACTION_ID
           AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
           AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
           AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
           AND (PETF.ELEMENT_NAME = 'P001_SUELDO NORMAL'
             OR PETF.ELEMENT_NAME = 'P005_VACACIONES')
           AND PIVF.NAME = 'Days';
            
        var_min_wage := PAY_MX_UTILITY.GET_MIN_WAGE(p_ctx_date_earned => P_EFFECTIVE_DATE,
                                                    p_tax_basis => 'NONE',
                                                    p_econ_zone => var_econ_zone);

        var_despensa_exempt := TRUNC(((var_min_wage * var_percent) * var_days), 2);
        
        
        
        IF P_DESPENSA_RESULT >= var_despensa_exempt THEN
            var_result := var_despensa_exempt;
        ELSE
            var_result := P_DESPENSA_RESULT;
        END IF;
        
        
      
        RETURN var_result;  
      
      END; 

    
        
END PAC_RESULT_VALUES_PKG;