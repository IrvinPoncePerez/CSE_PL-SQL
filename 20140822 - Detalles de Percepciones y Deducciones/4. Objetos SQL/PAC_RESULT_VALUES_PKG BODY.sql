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
        dbms_output.put_line('**Error en la función GET_OTHER_VALUE, assignment_action_id = ' || P_ASSIGNMENT_ACTION_ID || ', element_name=' || P_ELEMENT_NAME || ', input_value_name=' || P_INPUT_VALUE_NAME || '. ' || SQLERRM);
        FND_FILE.put_line(FND_FILE.LOG, '**Error en la función GET_OTHER_VALUE, assignment_action_id = ' || P_ASSIGNMENT_ACTION_ID || ', element_name=' || P_ELEMENT_NAME || ', input_value_name=' || P_INPUT_VALUE_NAME || '. ' || SQLERRM);
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
                  SELECT 
                    ('A  ' || MAX(PPTU.EFFECTIVE_START_DATE))
                    INTO var_data
                    FROM PER_PERSON_TYPE_USAGES_F   PPTU,
                         PER_PERIODS_OF_SERVICE     PPOS
                   WHERE PPTU.PERSON_ID = P_PERSON_ID
                     AND PPOS.PERSON_ID = P_PERSON_ID
                     AND PPTU.EFFECTIVE_START_DATE = PPOS.DATE_START
                     AND PPTU.EFFECTIVE_START_DATE BETWEEN P_START_DATE AND P_END_DATE;
                   
               WHEN P_TYPE = 'B' THEN
                  SELECT 
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
        dbms_output.put_line('**Error en la función GET_DATA_MOVEMENT. (' || P_PERSON_ID || ',' || P_TYPE || ',' || P_START_DATE || ',' || P_END_DATE || ')' || SQLERRM);
        FND_FILE.put_line(FND_FILE.LOG, '**Error en la función GET_DATA_MOVEMENT. (' || P_PERSON_ID || ',' || P_TYPE || ',' || P_START_DATE || ',' || P_END_DATE || ')' || SQLERRM);
      END;
      
      
      FUNCTION GET_EFFECTIVE_START_DATE(
             P_PERSON_ID      NUMBER)
      RETURN DATE
      IS
            var_effective_start_date    DATE;
      BEGIN
      
      
            SELECT PAPF.EFFECTIVE_START_DATE
              INTO var_effective_start_date
              FROM PER_ALL_PEOPLE_F         PAPF 
             WHERE PAPF.PERSON_ID = P_PERSON_ID
               AND PAPF.OBJECT_VERSION_NUMBER = (SELECT MAX(PF.OBJECT_VERSION_NUMBER)
                                                   FROM PER_ALL_PEOPLE_F    PF
                                                  WHERE PF.PERSON_ID = P_PERSON_ID);
      
      
            RETURN var_effective_start_date;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;        
              WHEN OTHERS THEN
        dbms_output.put_line('**Error en la función GET_DATA_MOVEMENT. (' || P_PERSON_ID || ',' || SQLERRM);
        FND_FILE.put_line(FND_FILE.LOG, '**Error en la función GET_DATA_MOVEMENT. (' || P_PERSON_ID || ',' || SQLERRM);
      END;
      
      
      FUNCTION GET_BALANCE(P_ASSIGNMENT_ACTION_ID    NUMBER,
                           P_DATE_EARNED             DATE,
                           P_ELEMENT_NAME            VARCHAR2,
                           P_ENTRY_NAME              VARCHAR2)
        RETURN NUMBER
        IS 
            var_result_value    NUMBER;
        BEGIN
                
            SELECT PEEV.ENTRY_VALUE
              INTO var_result_value  
              FROM apps.PAY_ELEMENT_ENTRIES_V PEEV 
             WHERE 1 = 1
               AND PEEV.ELEMENT_NAME = P_ELEMENT_NAME
               AND PEEV.NAME = P_ENTRY_NAME
               AND PEEV.ASSIGNMENT_ACTION_ID = P_ASSIGNMENT_ACTION_ID
               AND PEEV.PEE_EFFECTIVE_END_DATE = P_DATE_EARNED;

            
            RETURN var_result_value;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 0;
        END;

    
        
END PAC_RESULT_VALUES_PKG;