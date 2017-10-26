CREATE OR REPLACE PACKAGE BODY APPS.PAC_CFDI_FUNCTIONS_PKG AS

    PP_CONSOLIDATION_ID     NUMBER  := 0;
    
    PROCEDURE CFDI_LOGGING(
        P_FILE_NAME   VARCHAR2,
        P_STATUS      VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        
        var_date      VARCHAR2(100);
    BEGIN
    
        SELECT TO_CHAR(CURRENT_TIMESTAMP,'DD-MM-RRRR HH24:MI:SS PM')
          INTO var_date
          FROM DUAL;
    
        INSERT 
          INTO PAC_CFDI_LOG_TB
            (FILE_NAME,
             STATUS,
             LOG_DATE)
        VALUES
            (P_FILE_NAME,
             P_STATUS,
             var_date);
             
        COMMIT;
    
    END;
    
    
    
    /*
    Suma de todas las percepciones suma de gravado mas excento
    */
    FUNCTION GET_SUBTBR(P_ASSIGNMENT_ACTION_ID      NUMBER)
    RETURN NUMBER
    IS 
        var_result_value    NUMBER;
    BEGIN
        
         SELECT SUM(RESULT)
           INTO var_result_value
           FROM(SELECT SUM(PRRV.RESULT_VALUE) AS RESULT
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
                   AND (PEC.CLASSIFICATION_NAME IN ('Earnings', 
                                                    'Supplemental Earnings', 
                                                    'Amends', 
                                                    'Imputed Earnings') 
                          OR PETF.ELEMENT_NAME  IN (SELECT MEANING
                                                      FROM FND_LOOKUP_VALUES 
                                                     WHERE LOOKUP_TYPE = 'XX_PERCEPCIONES_INFORMATIVAS'
                                                       AND LANGUAGE = USERENV('LANG')))
                   AND PETF.ELEMENT_NAME NOT IN (CASE 
                                                    WHEN PP_CONSOLIDATION_ID = 65 THEN 'P091_FONDO AHORRO E ACUM'
                                                    ELSE 'TODOS'
                                                 END)
                   AND PIVF.UOM = 'M'
                   AND (PIVF.NAME = 'ISR Subject' OR PIVF.NAME = 'ISR Exempt')
                   AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                   AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
                UNION
                SELECT SUM(PRRV.RESULT_VALUE) AS RESULT                    
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
                   AND PETF.ELEMENT_NAME  IN ('FINAN_TRABAJO_RET',
                                              'P080_FONDO AHORRO TR ACUM',
                                              'P047_ISPT ANUAL A FAVOR')
                   AND PETF.ELEMENT_NAME NOT IN (CASE 
                                                    WHEN PP_CONSOLIDATION_ID = 65 THEN 'P080_FONDO AHORRO TR ACUM'
                                                    ELSE 'TODOS'
                                                 END)
                   AND PIVF.UOM = 'M'
                   AND PIVF.NAME = 'Pay Value'
                   AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                   AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE);
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END GET_SUBTBR;

    FUNCTION GET_SUBEMP(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER
    IS
        var_result_value    NUMBER;
    BEGIN
        
         SELECT SUM(RESULT)
           INTO var_result_value
           FROM(SELECT SUM(PRRV.RESULT_VALUE) AS RESULT                    
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
                   AND PETF.ELEMENT_NAME  IN ('P032_SUBSIDIO_PARA_EMPLEO')
                   AND PIVF.UOM = 'M'
                   AND PIVF.NAME = 'Pay Value'
                   AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                   AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE);
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END GET_SUBEMP;
    
    /*
    SUMA DE PAGO POR SEPARACIÓN, PRIMA DE ANTIGÜEDAD E INDEMNIZACIÓN 
    */
    FUNCTION GET_TOTSEP(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER
    IS
        var_result_value    NUMBER;
    BEGIN
    
        SELECT SUM(RESULT)
           INTO var_result_value
           FROM(SELECT SUM(PRRV.RESULT_VALUE) AS RESULT                    
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
                   AND PETF.ELEMENT_NAME  IN ('P017_PRIMA DE ANTIGUEDAD')
                   AND PIVF.UOM = 'M'
                   AND PIVF.NAME = 'Pay Value'
                   AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                   AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE);
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END GET_TOTSEP;
    
    /*
    ISR Retenido
    */    
    FUNCTION GET_ISRRET(P_ASSIGNMENT_ACTION_ID      NUMBER)
    RETURN NUMBER
    IS 
        var_result_value    NUMBER;
    BEGIN
        
         SELECT ROUND(PRRV.RESULT_VALUE, 2)
           INTO var_result_value
           FROM PAY_RUN_RESULTS          PRR,
                PAY_ELEMENT_TYPES_F      PETF,
                PAY_RUN_RESULT_VALUES    PRRV,
                PAY_INPUT_VALUES_F       PIVF
          WHERE PRR.ASSIGNMENT_ACTION_ID = P_ASSIGNMENT_ACTION_ID
            AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
            AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
            AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
            AND PETF.ELEMENT_NAME = 'D055_ISPT'
            AND PIVF.NAME = 'Pay Value'
            AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
            AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE;
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END GET_ISRRET;
    
    /*
    Suma de los importes de deducciones excepto el ISR. 
    */    
    FUNCTION GET_MONDET(P_ASSIGNMENT_ACTION_ID      NUMBER)
    RETURN NUMBER
    IS 
        var_result_value    NUMBER;
    BEGIN
        
        SELECT SUM(PRRV.RESULT_VALUE)
          INTO var_result_value
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
           AND (PEC.CLASSIFICATION_NAME IN ('Voluntary Deductions', 
                                            'Involuntary Deductions') 
                   OR PETF.ELEMENT_NAME IN (SELECT MEANING
                                              FROM FND_LOOKUP_VALUES 
                                             WHERE LOOKUP_TYPE = 'XX_DEDUCCIONES_INFORMATIVAS'
                                               AND LANGUAGE = USERENV('LANG')))
           AND PETF.ELEMENT_NAME <> 'D055_ISPT'
           AND PIVF.UOM = 'M'
           AND PIVF.NAME = 'Pay Value'
           AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE;
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END GET_MONDET;
    
    /*
    Dias Pagados.
    */    
    FUNCTION GET_DIAPAG(P_ASSIGNMENT_ACTION_ID      NUMBER)
    RETURN NUMBER
    IS 
        var_result_value    NUMBER;
    BEGIN
        
        SELECT TRUNC(SUM(PRRV.RESULT_VALUE), 1)
          INTO var_result_value
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
           AND (PIVF.NAME = 'Dias Recibo'
             OR PIVF.NAME = 'Dias Normales')
           AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE;
    
        IF var_result_value = 0 THEN
         var_result_value := 1;
        END IF;
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END GET_DIAPAG;
    
    /*
    Fondo de ahorro acumulado del periodo consultado.
    */    
    FUNCTION GET_FAHOACUM(P_ASSIGNMENT_ACTION_ID    NUMBER,
                          P_DATE_EARNED             DATE,
                          P_TAX_UNIT_ID             NUMBER)
    RETURN NUMBER
    IS 
        var_result_value    NUMBER;
    BEGIN
        
         SELECT APPS.PAY_BALANCE_PKG.GET_VALUE(
                    P_DEFINED_BALANCE_ID    => PDB.DEFINED_BALANCE_ID,
                    P_ASSIGNMENT_ACTION_ID  => P_ASSIGNMENT_ACTION_ID, 
                    P_TAX_UNIT_ID => P_TAX_UNIT_ID,
                    P_JURISDICTION_CODE => NULL, 
                    P_SOURCE_ID => NULL, 
                    P_TAX_GROUP => NULL,
                    P_DATE_EARNED => P_DATE_EARNED)
           INTO var_result_value      
           FROM PAY_BALANCE_TYPES        PBT,
                PAY_BALANCE_DIMENSIONS   PBD,
                PAY_DEFINED_BALANCES     PDB
          WHERE 1 = 1
            AND PBT.BALANCE_NAME = 'P043_FONDO AHORRO EMP'
            AND PBD.DATABASE_ITEM_SUFFIX = '_ASG_YTD'
            AND PBD.LEGISLATION_CODE = 'MX'
            AND (PDB.BALANCE_TYPE_ID = PBT.BALANCE_TYPE_ID
            AND PDB.BALANCE_DIMENSION_ID = PBD.BALANCE_DIMENSION_ID);

                 
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END GET_FAHOACUM;

    /*
    TOTAL DE PERCEPCIONES GRAVADAS
    */    
    FUNCTION GET_PER_TOTGRA(P_ASSIGNMENT_ACTION_ID  NUMBER)
    RETURN NUMBER
    IS 
        var_result_value    NUMBER;
    BEGIN
        
        SELECT SUM(PRRV.RESULT_VALUE)
          INTO var_result_value
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
           AND (PEC.CLASSIFICATION_NAME IN ('Earnings', 
                                            'Supplemental Earnings', 
                                            'Amends', 
                                            'Imputed Earnings') 
                   OR PETF.ELEMENT_NAME IN ('FINAN_TRABAJO_RET',
                                            'P080_FONDO AHORRO TR ACUM',
                                            'P017_PRIMA DE ANTIGUEDAD',
                                            'P032_SUBSIDIO_PARA_EMPLEO',
                                            'P047_ISPT ANUAL A FAVOR',
                                            'P026_INDEMNIZACION'))
           AND PETF.ELEMENT_NAME NOT IN (CASE 
                                            WHEN PP_CONSOLIDATION_ID = 65 THEN 'P080_FONDO AHORRO TR ACUM'
                                            ELSE 'TODOS'
                                         END)
           AND (PIVF.NAME = 'ISR Subject')
           AND PIVF.UOM = 'M'
           AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE;
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END GET_PER_TOTGRA;
    
    /*
    TOTAL DE PERCEPCIONES EXENTAS
    */    
    FUNCTION GET_PER_TOTEXE(P_ASSIGNMENT_ACTION_ID  NUMBER)
    RETURN NUMBER
    IS 
        var_result_value    NUMBER;
    BEGIN
        
         SELECT SUM(RESULT)
           INTO var_result_value
           FROM(SELECT SUM(PRRV.RESULT_VALUE) AS RESULT
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
                   AND (PEC.CLASSIFICATION_NAME IN ('Earnings', 
                                                    'Supplemental Earnings', 
                                                    'Amends', 
                                                    'Imputed Earnings') 
                          OR PETF.ELEMENT_NAME  IN ((SELECT MEANING
                                                      FROM FND_LOOKUP_VALUES 
                                                     WHERE LOOKUP_TYPE = 'XX_PERCEPCIONES_INFORMATIVAS'
                                                       AND LANGUAGE = USERENV('LANG'))))
                   AND PETF.ELEMENT_NAME NOT IN (CASE 
                                                    WHEN PP_CONSOLIDATION_ID = 65 THEN 'P091_FONDO AHORRO E ACUM'
                                                    ELSE 'TODOS'
                                                 END)
                   AND PIVF.UOM = 'M'
                   AND PIVF.NAME = 'ISR Exempt'
                   AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                   AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
                UNION
                SELECT SUM(PRRV.RESULT_VALUE) AS RESULT                    
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
                   AND PETF.ELEMENT_NAME  IN ('FINAN_TRABAJO_RET',
                                              'P080_FONDO AHORRO TR ACUM',
                                              'P017_PRIMA DE ANTIGUEDAD',
                                              'P047_ISPT ANUAL A FAVOR',
                                              'P026_INDEMNIZACION')
                   AND PETF.ELEMENT_NAME NOT IN (CASE 
                                            WHEN PP_CONSOLIDATION_ID = 65 THEN 'P080_FONDO AHORRO TR ACUM'
                                            ELSE 'TODOS'
                                         END)
                   AND PIVF.UOM = 'M'
                   AND PIVF.NAME = 'Pay Value'
                   AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                   AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE);
    
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END GET_PER_TOTEXE;
    
    
    FUNCTION GET_PER_TOTSUL(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER
    IS
        var_result_value    NUMBER;
    BEGIN
        
        SELECT SUM(PRRV.RESULT_VALUE)
          INTO var_result_value
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
           AND (PEC.CLASSIFICATION_NAME IN ('Earnings', 
                                            'Supplemental Earnings', 
                                            'Amends', 
                                            'Imputed Earnings') 
                   OR PETF.ELEMENT_NAME IN ('FINAN_TRABAJO_RET',
                                            'P080_FONDO AHORRO TR ACUM',
                                            'P032_SUBSIDIO_PARA_EMPLEO',
                                            'P047_ISPT ANUAL A FAVOR'))
           AND PETF.ELEMENT_NAME NOT IN (CASE 
                                            WHEN PP_CONSOLIDATION_ID = 65 THEN 'P080_FONDO AHORRO TR ACUM'
                                            ELSE 'TODOS'
                                         END)
           AND (PIVF.NAME = 'Pay Value')
           AND PIVF.UOM = 'M'
           AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE;
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END GET_PER_TOTSUL;
      
      
    FUNCTION GET_PER_TOTSEP(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER
    IS
        var_result_value    NUMBER;
    BEGIN
        
        SELECT SUM(PRRV.RESULT_VALUE)
          INTO var_result_value
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
           AND PETF.ELEMENT_NAME IN ('P026_INDEMNIZACION')
           AND PIVF.NAME = 'Pay Value'
           AND PIVF.UOM = 'M'
           AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE;
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END GET_PER_TOTSEP;
      

    FUNCTION GET_NOM_DESCRI(P_PAYROLL_ACTION_ID     NUMBER)
    RETURN VARCHAR2
    IS
        var_nom_descri              VARCHAR2(1000);
        var_consolidation_set_id    NUMBER;
        var_element_set_id          NUMBER;
        
    BEGIN
    
        SELECT DISTINCT
               PPA.ELEMENT_SET_ID,
               PPA.CONSOLIDATION_SET_ID
          INTO var_element_set_id,
               var_consolidation_set_id
          FROM PAY_PAYROLL_ACTIONS          PPA
         WHERE PPA.PAYROLL_ACTION_ID = P_PAYROLL_ACTION_ID;
         
         
         
         BEGIN
         
            SELECT DISTINCT 
                   PES.ELEMENT_SET_NAME
              INTO var_nom_descri
              FROM PAY_ELEMENT_SETS PES
             WHERE PES.ELEMENT_SET_ID = var_element_set_id;
         
         EXCEPTION WHEN OTHERS THEN
         
            SELECT DISTINCT
                   PCS.CONSOLIDATION_SET_NAME
              INTO var_nom_descri
              FROM PAY_CONSOLIDATION_SETS       PCS
             WHERE PCS.CONSOLIDATION_SET_ID = var_consolidation_set_id;                
         
         END;
         
         
         CASE
            WHEN var_nom_descri LIKE 'GRATIFICACION_MAYO' OR var_nom_descri LIKE 'GRATIFICACIÓN' THEN
                var_nom_descri := 'GRATIFICACION MARZO';
            WHEN var_nom_descri LIKE 'GRATIFICACION_MAYO_PTU' THEN
                var_nom_descri := 'GRATIFICACION MAYO PTU';
            WHEN var_nom_descri LIKE '%AHORRO%' THEN 
                var_nom_descri := 'FONDO DE AHORRO';
            WHEN var_nom_descri LIKE '%ORDINARIA%' THEN 
                var_nom_descri := 'PAGO DE NOMINA';
            ELSE
                var_nom_descri := UPPER(REPLACE(var_nom_descri, '_', ' '));
         END CASE;

    
    
        RETURN var_nom_descri;
    END GET_NOM_DESCRI;
    
    FUNCTION GET_NOM_PER_ANIO(
        P_PERSON_ID       NUMBER)
      RETURN NUMBER
    IS
        var_result_value    NUMBER;
    BEGIN
        
        SELECT ROUND((ACTUAL_TERMINATION_DATE - DATE_START) / 365)
          INTO var_result_value
          FROM (SELECT NVL(PPOS.ADJUSTED_SVC_DATE,  
                           PAPF.ORIGINAL_DATE_OF_HIRE)  DATE_START,
                           PPT.USER_PERSON_TYPE,
                           PPOS.ACTUAL_TERMINATION_DATE
                  FROM PER_ALL_PEOPLE_F         PAPF
                      ,PER_PERIODS_OF_SERVICE   PPOS
                      ,PER_PERSON_TYPES         PPT
                 WHERE 1 = 1
                   AND PAPF.PERSON_ID = P_PERSON_ID
                   AND PAPF.PERSON_ID = PPOS.PERSON_ID
                   AND PAPF.PERSON_TYPE_ID = PPT.PERSON_TYPE_ID 
                   AND PPT.USER_PERSON_TYPE IN ('Ex-empleado', 'Ex-employee')
                 ORDER
                    BY PPOS.ACTUAL_TERMINATION_DATE DESC
                )
         WHERE 1 = 1
           AND ROWNUM = 1;    
    
        RETURN var_result_value;
    EXCEPTION
        WHEN OTHERS THEN 
            RETURN 1;
    END GET_NOM_PER_ANIO;
    
    FUNCTION GET_NOM_PER_ULTSUE(
        P_PERSON_ID             NUMBER)
      RETURN NUMBER
    IS
        var_result_value        NUMBER;
    BEGIN
        
        SELECT PEEV.SCREEN_ENTRY_VALUE
          INTO var_result_value
          FROM PER_ALL_PEOPLE_F             PAPF
              ,PER_ALL_ASSIGNMENTS_F        PAAF
              ,PAY_ELEMENT_ENTRIES_F        PEEF
              ,PAY_ELEMENT_TYPES_F          PETF
              ,PAY_ELEMENT_ENTRY_VALUES_F   PEEV
              ,PAY_INPUT_VALUES_F           PIVF
         WHERE 1 = 1
           AND PAPF.PERSON_ID = P_PERSON_ID
           AND PAAF.PERSON_ID = PAPF.PERSON_ID
           AND PEEF.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
           AND PEEF.ELEMENT_TYPE_ID = PETF.ELEMENT_TYPE_ID
           AND PETF.ELEMENT_NAME = 'P001_SUELDO NORMAL'
           AND PEEV.ELEMENT_ENTRY_ID = PEEF.ELEMENT_ENTRY_ID
           AND PEEV.INPUT_VALUE_ID = PIVF.INPUT_VALUE_ID
           AND PIVF.NAME = 'Rate'
           AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE
                           AND PAPF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE
                           AND PAAF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PEEF.EFFECTIVE_START_DATE
                           AND PEEF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE
                           AND PETF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE
                           AND PIVF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PEEV.EFFECTIVE_START_DATE
                           AND PEEV.EFFECTIVE_END_DATE;
    
        RETURN var_result_value;
        
    END GET_NOM_PER_ULTSUE;
    
    FUNCTION GET_VIATICAL(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER
    IS
        var_result      NUMBER;
    BEGIN 
        SELECT SUM(PRRV.RESULT_VALUE) 
          INTO var_result                    
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
           AND PETF.ELEMENT_NAME  IN ('I005_VIATICOS')
           AND PIVF.UOM = 'M'
           AND PIVF.NAME = 'Pay Value'
           AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE;
           
         RETURN var_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END GET_VIATICAL;
    
    PROCEDURE CREATE_CFDI_NOMINA(
        P_ERRBUF    OUT NOCOPY  VARCHAR2,
        P_RETCODE   OUT NOCOPY  VARCHAR2,
        P_COMPANY_ID            VARCHAR2,
        P_PERIOD_TYPE           VARCHAR2,
        P_PAYROLL_ID            NUMBER,
        P_CONSOLIDATION_ID      NUMBER,
        P_YEAR                  NUMBER,
        P_MONTH                 NUMBER,
        P_PERIOD_NAME           VARCHAR2,
        P_EARNED_DATE           VARCHAR2)
    IS
        var_path            VARCHAR2(250) := 'CFDI_NOMINA';
        var_file_name       VARCHAR2(250);
        var_payroll_name    VARCHAR2(200);
        var_file            UTL_FILE.FILE_TYPE;
        var_consolidation_name  VARCHAR2(250);
        var_run_type_name       VARCHAR2(250);
        var_sequence_name   VARCHAR2(250);
        
        var_date_exp        VARCHAR2(50);
        var_reg_seq         NUMBER(10);
        var_user_id         NUMBER := FND_GLOBAL.USER_ID;
        var_validate        NUMBER;
        var_request_id      NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        var_earned_date     DATE := TRUNC(TO_DATE(P_EARNED_DATE,'RRRR/MM/DD HH24:MI:SS'));
        
        MIN_WAGE            NUMBER;
                
        CURSOR  DETAIL_LIST IS
             SELECT DISTINCT 
                    PPF.PAYROLL_NAME,
                    (CASE
                        WHEN FLV1.LOOKUP_CODE = '02' THEN 'CSUD'
                        WHEN FLV1.LOOKUP_CODE = '08' THEN 'POGA'
                        WHEN FLV1.LOOKUP_CODE = '11' THEN 'PACUD'
                     END)                                                                           AS  SERFOL,
                    UPPER(OI.ORG_INFORMATION2)                                                      AS  RFCEMI,
                    UPPER(FLV1.MEANING)                                                             AS  NOMEMI,
                    UPPER(LA.ADDRESS_LINE_1)                                                        AS  CALEMI,
                    UPPER(LA.ADDRESS_LINE_2)                                                        AS  COLEMI,
                    UPPER(LA.TOWN_OR_CITY)                                                          AS  MUNEMI,
                    UPPER(FLV2.MEANING)                                                             AS  ESTEMI,
                    LA.POSTAL_CODE                                                                  AS  CODEMI,
                    UPPER(FT1.NLS_TERRITORY)                                                        AS  PAIEMI,
                    (CASE
                        WHEN PAPF.EMPLOYEE_NUMBER = 5646
                        THEN 'GAÑU980724L34'
                        ELSE REPLACE(PAPF.PER_INFORMATION2, '-', '')
                     END)                                                                           AS  RFCREC,
                    UPPER(PAPF.LAST_NAME        || ' ' || 
                          PAPF.PER_INFORMATION1 || ' ' || 
                          PAPF.FIRST_NAME       || ' ' || 
                          PAPF.MIDDLE_NAMES)                                                        AS  NOMREC,
                    UPPER(PAD.ADDRESS_LINE1)                                                        AS  CALREC,
                    (SELECT UPPER(NVL(FT2.NLS_TERRITORY, 'MEXICO'))
                       FROM PER_ADDRESSES    PA,
                            FND_TERRITORIES  FT2
                      WHERE PA.PERSON_ID = PAPF.PERSON_ID
                        AND FT2.TERRITORY_CODE = PA.COUNTRY)                                        AS  PAIREC,
                    NVL(PAPF.EMAIL_ADDRESS, 'NULL')                                                 AS  MAIL,
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_SUBTBR(PAA.ASSIGNMENT_ACTION_ID), '0'))                             AS  SUBTBR,  
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_SUBEMP(PAA.ASSIGNMENT_ACTION_ID), '0'))                             AS  SUBEMP,  
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_TOTSEP(PAA.ASSIGNMENT_ACTION_ID), '0'))                             AS  TOTSEP_ANT, 
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_PER_TOTSEP(PAA.ASSIGNMENT_ACTION_ID), '0'))                         AS  TOTSEP_IND,
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_ISRRET(PAA.ASSIGNMENT_ACTION_ID), '0'))                             AS  ISRRET,
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_MONDET(PAA.ASSIGNMENT_ACTION_ID), '0'))                             AS  MONDET,  
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_VIATICAL(PAA.ASSIGNMENT_ACTION_ID), '0'))                           AS  VIATICAL,
                    PAPF.EMPLOYEE_NUMBER                                                            AS  NOM_NUMEMP,
                    PAPF.NATIONAL_IDENTIFIER                                                        AS  NOM_CURP,
                    PAC_CFDI_FUNCTIONS_PKG.GET_EFFECTIVE_START_DATE(PAPF.PERSON_ID)                                        AS  NOM_FECREL,
                    (CASE
                        WHEN PAAF.EMPLOYEE_CATEGORY = '001CALV' THEN 'Sí'
                        WHEN PAAF.EMPLOYEE_CATEGORY = '002CALV' THEN 'No'
                        ELSE 'No'
                     END)                                                                           AS  NOM_SINDC,
                    (CASE
                        WHEN PAAF.EMPLOYMENT_CATEGORY = 'MX1_P' THEN
                            '01'
                        WHEN PAAF.EMPLOYMENT_CATEGORY = 'MX2_E' THEN
                            '03'
                     END)                                                                           AS  NOM_TIPCON,
                    NVL(var_earned_date, (CASE
                                            WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%NORMAL%' THEN
                                                CASE 
                                                    WHEN P_PERIOD_TYPE = 'Week' OR P_PERIOD_TYPE = 'Semana' THEN
                                                         PTP.END_DATE + 4
                                                    ELSE
                                                         PTP.END_DATE
                                                END
                                            WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%FINIQUITOS%' THEN
                                                PTP.END_DATE + 1
                                            ELSE
                                                PTP.END_DATE
                                          END))                                                     AS  NOM_FECPAG,       
                    (CASE
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%NORMAL%' THEN
                            PTP.START_DATE
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%FINIQUITOS%' THEN
                            PTP.END_DATE + 1 
                        ELSE 
                            PTP.END_DATE
                     END)                                                                           AS  NOM_FECINI,
                    (CASE
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%FINIQUITOS%' THEN
                            PTP.END_DATE + 1
                        ELSE 
                            PTP.END_DATE
                     END)                                                                           AS  NOM_FECFIN,
                    TO_CHAR(REPLACE(REPLACE(PAPF.PER_INFORMATION3, ' ', ''),'-',''), '00000000000') AS  NOM_NUMSEG,   
                    MAX(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_DIAPAG(PAA.ASSIGNMENT_ACTION_ID), '1'))                          AS  NOM_DIAPAG,
                    HOUV.NAME                                                                       AS  NOM_DEPTO,
                    (CASE
                        WHEN HOUV.REGION_1 = 'CAMP' THEN 'CAM'
                        WHEN HOUV.REGION_1 = 'TAMPS' THEN 'TAM'
                        WHEN HOUV.REGION_1 = 'CHIS' THEN 'CHP'
                        WHEN HOUV.REGION_1 = 'DF' THEN 'DIF'
                        WHEN HOUV.REGION_1 = 'QROO' THEN 'ROO'
                        WHEN HOUV.REGION_1 = 'TLAX' THEN 'TLA'
                        ELSE HOUV.REGION_1
                     END)                                                                           AS  NOM_ENTFED,
                    HAPD.NAME                                                                       AS  NOM_PUESTO, 
                    (CASE
                        WHEN PPF.PAYROLL_NAME LIKE '%SEM%' 
                         AND PCS.CONSOLIDATION_SET_NAME LIKE '%NORMAL%'
                        THEN '02'
                        WHEN PPF.PAYROLL_NAME LIKE '%QUIN%'
                         AND PCS.CONSOLIDATION_SET_NAME LIKE '%NORMAL%' 
                        THEN '04'
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%GRATIFICACIÓN%'
                        THEN '99'
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%FINIQUITO%'
                        THEN '99'
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%PTU%'
                        THEN '99'
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%AGUINALDO%'
                        THEN '99'
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%FONDO DE AHORRO%'
                        THEN '99'
                     END)                                                                           AS  NOM_FORPAG,
                    PTP.PERIOD_NUM                                                                  AS  NOM_NUMERONOM,
                    APPS.PAC_HR_PAY_PKG.GET_EMPLOYER_REGISTRATION(PAAF.ASSIGNMENT_ID)               AS  NOM_REGPAT,
                    MAX(NVL(PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAA.ASSIGNMENT_ACTION_ID,
                                            'Integrated Daily Wage',
                                            'Pay Value'), '0'))                                     AS  NOM_SDI,
                    MAX(NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,
                                              'P001_SUELDO NORMAL',
                                              'Sueldo Diario'), '0'))                               AS  NOM_SALBASE, 
                    MAX(NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,
                                              'P039_DESPENSA',
                                              'Pay Value'), '0'))                                   AS  GROCERIES_VALUE,
                    PPF.ATTRIBUTE1                                                                  AS  NOM_CVENOM,  
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_PER_TOTSUL(PAA.ASSIGNMENT_ACTION_ID), '0'))                         AS  NOM_PER_TOTSUL,
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_PER_TOTGRA(PAA.ASSIGNMENT_ACTION_ID), '0'))                         AS  NOM_PER_TOTGRA,
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_PER_TOTEXE(PAA.ASSIGNMENT_ACTION_ID), '0'))                         AS  NOM_PER_TOTEXE,  
                    PAC_CFDI_FUNCTIONS_PKG.GET_NOM_DESCRI(PPA.PAYROLL_ACTION_ID)                                           AS  NOM_DESCRI,
                    (CASE
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%NORMAL%' THEN
                            'O'
                        ELSE
                            'E'
                     END)                                                                           AS  NOM_TIPO,   
                     NVL((SELECT DISTINCT 
                                 (CASE WHEN PAPF.EMPLOYEE_NUMBER = 13 OR PAPF.EMPLOYEE_NUMBER = 24 THEN
                                        '03' --TRANSFERENCIA E' --'TRANSFERENCIA ELECTRONICA'
                                       WHEN PCS.CONSOLIDATION_SET_NAME = 'FINIQUITOS' THEN
                                        '02' --CHEQUE' --'CHEQUE'
                                       WHEN POPM.ORG_PAYMENT_METHOD_NAME LIKE '%EFECTIVO%' THEN
                                        '01' --EFECTIVO' --'EFECTIVO'
                                       WHEN (POPM.ORG_PAYMENT_METHOD_NAME LIKE '%BANCOMER%'
                                          OR POPM.ORG_PAYMENT_METHOD_NAME LIKE '%BANORTE%'
                                          OR POPM.ORG_PAYMENT_METHOD_NAME LIKE '%HSBC%'
                                          OR POPM.ORG_PAYMENT_METHOD_NAME LIKE '%INVERLAT%') THEN
                                        '03' --TRANSFERENCIA E' --'TRANSFERENCIA ELECTRONICA'
                                       
                                  END)
                            FROM PER_ALL_ASSIGNMENTS_F          PAA,
                                 PAY_PERSONAL_PAYMENT_METHODS_F PPPM,
                                 PAY_ORG_PAYMENT_METHODS_F      POPM,
                                 PAY_PAYMENT_TYPES_V            PPTV
                            WHERE PPPM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
                              AND PPPM.ORG_PAYMENT_METHOD_ID = POPM.ORG_PAYMENT_METHOD_ID
                              AND PPTV.PAYMENT_TYPE_ID = POPM.PAYMENT_TYPE_ID
                              AND PPTV.TERRITORY_CODE = 'MX'
                              AND (POPM.ORG_PAYMENT_METHOD_NAME NOT LIKE '%DESPENSA%'
                              AND POPM.ORG_PAYMENT_METHOD_NAME NOT LIKE '%EFECTIVALE%'
                              AND POPM.ORG_PAYMENT_METHOD_NAME NOT LIKE '%PENSIONES%')
                              AND ROWNUM = 1
                                ), '01')                                                            AS  METPAG,
                    PPF.PAYROLL_ID,
                    PAAF.ASSIGNMENT_ID,
                    PAPF.PERSON_ID,
                    PPA.PAYROLL_ACTION_ID,
                    PPA.DATE_EARNED,
                    PPA.CONSOLIDATION_SET_ID,
                    PPA.EFFECTIVE_DATE,
                    PTP.END_DATE
                  FROM 
                       FND_LOOKUP_VALUES            FLV1,
                       HR_ALL_ORGANIZATION_UNITS    AOU,
                       HR_LOCATIONS_ALL             LA,
                       HR_ORGANIZATION_INFORMATION  OI,
                       FND_TERRITORIES              FT1,
                       FND_LOOKUP_VALUES            FLV2,
                       PAY_PAYROLLS_F               PPF,
                       PAY_PAYROLL_ACTIONS          PPA,
                       PER_TIME_PERIODS             PTP,
                       PER_ALL_ASSIGNMENTS_F        PAAF,
                       PAY_ASSIGNMENT_ACTIONS       PAA,
                       PER_ALL_PEOPLE_F             PAPF,
                       PAY_RUN_TYPES_X              PRTX,
                       HR_ORGANIZATION_UNITS_V      HOUV,
                       HR_ALL_POSITIONS_D           HAPD,
                       PAY_CONSOLIDATION_SETS       PCS,
                       PER_ADDRESSES                PAD
                 WHERE 1 = 1
                   AND FLV1.LOOKUP_TYPE = 'NOMINAS POR EMPLEADOR LEGAL'
                   AND FLV1.LOOKUP_CODE = P_COMPANY_ID
                   AND FLV1.LANGUAGE = USERENV('LANG')
                   AND AOU.NAME = FLV1.MEANING
                   AND LA.LOCATION_ID = AOU.LOCATION_ID
                   AND AOU.ORGANIZATION_ID = OI.ORGANIZATION_ID
                   AND OI.ORG_INFORMATION_CONTEXT = 'MX_TAX_REGISTRATION'
                   AND LA.COUNTRY = FT1.TERRITORY_CODE
                   AND FLV2.LOOKUP_CODE = LA.REGION_1
                   AND FLV2.LOOKUP_TYPE = 'MX_STATE'
                   AND FLV2.LANGUAGE = USERENV('LANG')
                   AND SUBSTR(PPF.PAYROLL_NAME,1,2) = FLV1.LOOKUP_CODE
                   AND APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(P_PERIOD_TYPE, APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
                   AND PPF.PAYROLL_ID = NVL(P_PAYROLL_ID, PPF.PAYROLL_ID) 
                   AND PPF.PAYROLL_ID = PPA.PAYROLL_ID
                   AND PPA.CONSOLIDATION_SET_ID  = NVL(P_CONSOLIDATION_ID, PPA.CONSOLIDATION_SET_ID)
                   AND PTP.PAYROLL_ID = PPF.PAYROLL_ID
                   AND (EXTRACT(YEAR FROM PTP.END_DATE) = P_YEAR 
                    AND EXTRACT(MONTH FROM PTP.END_DATE) = P_MONTH)
                   AND PTP.PERIOD_NAME = NVL(P_PERIOD_NAME, PTP.PERIOD_NAME)
                   AND PPA.EFFECTIVE_DATE BETWEEN PTP.START_DATE AND PTP.END_DATE
                   AND PTP.TIME_PERIOD_ID = PPA.TIME_PERIOD_ID   
                   AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
                   AND PAPF.PERSON_ID = PAAF.PERSON_ID
                   AND PAD.PERSON_ID = PAPF.PERSON_ID
                   AND PPA.CONSOLIDATION_SET_ID = PCS.CONSOLIDATION_SET_ID
                   AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID 
                   AND PAA.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
                   AND PRTX.RUN_TYPE_ID = PAA.RUN_TYPE_ID
                   AND PAAF.ORGANIZATION_ID = NVL(HOUV.ORGANIZATION_ID, PAAF.ORGANIZATION_ID) 
                   AND PAAF.POSITION_ID = NVL(HAPD.POSITION_ID, PAAF.POSITION_ID)
                   AND PPF.PAYROLL_NAME NOT IN ('02_SEM - GRBE', '02_QUIN - EVENTUAL')
                   AND PPA.EFFECTIVE_DATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
                   AND PPA.EFFECTIVE_DATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
                   AND PPA.EFFECTIVE_DATE BETWEEN HAPD.EFFECTIVE_START_DATE AND HAPD.EFFECTIVE_END_DATE
                   AND PPA.EFFECTIVE_DATE BETWEEN PRTX.EFFECTIVE_START_DATE AND PRTX.EFFECTIVE_END_DATE
                   AND PPA.EFFECTIVE_DATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
--                   AND PAC_CFDI_FUNCTIONS_PKG.GET_PAYMENT_METHOD(PAA.ASSIGNMENT_ID) LIKE '%%'
                   AND (    (CASE
                                WHEN PCS.CONSOLIDATION_SET_NAME IN ('GRATIFICACIÓN', 'PTU', 'NORMAL') THEN  
                                    PAC_CFDI_FUNCTIONS_PKG.GET_SUBTBR(PAA.ASSIGNMENT_ACTION_ID)
                                ELSE 1
                            END) <> 0
                        OR  (CASE 
                                WHEN PCS.CONSOLIDATION_SET_NAME IN ('GRATIFICACIÓN', 'PTU', 'NORMAL') THEN
                                    PAC_CFDI_FUNCTIONS_PKG.GET_MONDET(PAA.ASSIGNMENT_ACTION_ID)
                                ELSE 1        
                            END) <> 0
                        OR  (CASE 
                                WHEN PCS.CONSOLIDATION_SET_NAME IN ('GRATIFICACIÓN', 'PTU', 'NORMAL') THEN
                                    PAC_CFDI_FUNCTIONS_PKG.GET_ISRRET(PAA.ASSIGNMENT_ACTION_ID)
                                ELSE 1
                            END) <> 0)
                   AND (CASE
                            WHEN PCS.CONSOLIDATION_SET_NAME IN ('NORMAL') THEN
                                PAC_CFDI_FUNCTIONS_PKG.GET_DIAPAG(PAA.ASSIGNMENT_ACTION_ID)
                            ELSE 1
                        END) <> 0
--                   AND PAPF.EMPLOYEE_NUMBER NOT IN (5646) -- PrBueba 17.05.30
                 GROUP BY PPF.PAYROLL_NAME,
                          FLV1.LOOKUP_CODE,
                          OI.ORG_INFORMATION2,
                          FLV1.MEANING,
                          LA.ADDRESS_LINE_1,
                          LA.ADDRESS_LINE_2,
                          LA.TOWN_OR_CITY,
                          FLV2.MEANING,
                          LA.POSTAL_CODE,
                          FT1.NLS_TERRITORY,
                          PAPF.PER_INFORMATION2,
                          PAPF.LAST_NAME, 
                          PAPF.PER_INFORMATION1, 
                          PAPF.FIRST_NAME, 
                          PAPF.MIDDLE_NAMES,
                          PAPF.PERSON_ID,
                          PAD.ADDRESS_LINE1,
                          PAPF.EMAIL_ADDRESS,
                          PAPF.EMPLOYEE_NUMBER,
                          PAAF.EMPLOYEE_CATEGORY,
                          PAPF.NATIONAL_IDENTIFIER,
                          PCS.CONSOLIDATION_SET_NAME,
                          PTP.END_DATE,
                          PTP.START_DATE,
                          PAPF.PER_INFORMATION3,
                          HOUV.NAME,
                          HOUV.REGION_1,
                          HAPD.NAME,
                          PTP.PERIOD_NUM,
                          PAAF.ASSIGNMENT_ID,
                          PAAF.EMPLOYMENT_CATEGORY,
                          PPF.ATTRIBUTE1,
                          PPA.PAYROLL_ACTION_ID,
                          PPF.PAYROLL_ID,
                          PAAF.ASSIGNMENT_ID,
                          PPA.PAYROLL_ACTION_ID,
                          PPA.DATE_EARNED,
                          PPA.CONSOLIDATION_SET_ID,
                          PPA.EFFECTIVE_DATE,
                          PTP.END_DATE
                 ORDER BY PPF.PAYROLL_NAME,
                          PAPF.EMPLOYEE_NUMBER;                          

                                                
         TYPE   DETAILS IS TABLE OF DETAIL_LIST%ROWTYPE INDEX BY PLS_INTEGER;
         
         DETAIL DETAILS;
         
         PROCEDURE REGISTRING IS BEGIN dbms_lock.SLEEP(3); END;
         
    BEGIN
        
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

        BEGIN
        
            SELECT REPLACE(PCS.CONSOLIDATION_SET_NAME, ' ', '_')
              INTO var_consolidation_name
              FROM PAYBV_CONSOLIDATION_SET PCS
             WHERE PCS.CONSOLIDATION_SET_ID = P_CONSOLIDATION_ID;
             
            PP_CONSOLIDATION_ID := P_CONSOLIDATION_ID;
        
            var_file_name := 'CFDI_';
            
            IF P_COMPANY_ID = '02' THEN 
                var_file_name := var_file_name || 'CS_';
            ELSIF P_COMPANY_ID = '08' THEN 
                var_file_name := var_file_name || 'POGA_';
            ELSIF P_COMPANY_ID = '11' THEN 
                var_file_name := var_file_name || 'PAC_';
            END IF;
            
            var_file_name := var_file_name || REPLACE(NVL(P_PERIOD_NAME,P_MONTH || '_' || P_YEAR), ' ', '_') || '_';
            var_file_name := var_file_name || REPLACE(var_consolidation_name, 'Ó', 'O');
            var_sequence_name := SUBSTR(REPLACE(REPLACE(var_file_name, 'NOMINA', ''), '_', ''), 0, 30);
            var_file_name := var_file_name || '.txt';
            
        EXCEPTION WHEN OTHERS THEN 
            P_RETCODE := 1;       
            dbms_output.put_line('**Error al preparar el archivo CFDI de Nómina. ' || SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al preparar el archivo CFDI de Nómina. ' || SQLERRM); 
        END;
        
        SELECT COUNT(CFDI.FILE_NAME)
          INTO var_validate
          FROM PAC_CFDI_NOMINA_TB  CFDI
         WHERE 1 = 1
           AND CFDI.FILE_NAME = var_file_name;
        
        IF var_validate = 0 OR var_consolidation_name <> 'FONDO_DE_AHORRO' THEN
        
            INSERT
              INTO PAC_CFDI_NOMINA_TB (USER_ID,
                                       REQUEST_ID,
                                       FILE_NAME,
                                       SEQUENCE_NAME,
                                       CREATION_DATE)
                               VALUES (var_user_id,
                                       var_request_id,
                                       var_file_name,
                                       var_sequence_name,
                                       SYSDATE);
        
            --Eliminación y creación del Archivo.
            BEGIN
                
                CFDI_LOGGING(var_file_name, 'CREATE CFDI FILE');
            
                var_file := UTL_FILE.FOPEN(var_path, var_file_name, 'A', 30000);
                UTL_FILE.FREMOVE(var_path, var_file_name);
            
            EXCEPTION
                WHEN UTL_FILE.INVALID_OPERATION THEN
                    var_file := UTL_FILE.FOPEN(var_path, var_file_name, 'A', 30000); 
                WHEN OTHERS THEN
                    P_RETCODE := 1;
                    dbms_output.put_line('**Error al Limpiar el Archivo.. ' || SQLERRM);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Limpiar el Archivo.. ' || SQLERRM);
            END;
            
            var_file := UTL_FILE.FOPEN(var_path, var_file_name, 'A', 30000);
            
            --Creación de la secuencia
            BEGIN

                EXECUTE IMMEDIATE 'CREATE SEQUENCE ' || var_sequence_name || ' ' ||
                              'START WITH 1 ' ||
                              'INCREMENT BY 1 ' ||
                              'NOCACHE ' ||
                              'NOCYCLE';
                              
            EXCEPTION WHEN OTHERS THEN
                P_RETCODE := 1;
                dbms_output.put_line('**Error al Crear la Secuencia ' || var_sequence_name || '. ' || SQLERRM);
                FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Crear la Secuencia ' || var_sequence_name || '. ' || SQLERRM);
            END;
            
            
            --Impresión de Parametros.
            BEGIN
            
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parametros de Ejecucion. ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_COMPANY_ID : '       || P_COMPANY_ID);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_PERIOD_TYPE : '      || P_PERIOD_TYPE);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_PAYROLL_ID : '       || P_PAYROLL_ID);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_CONSOLIDATION_ID : ' || P_CONSOLIDATION_ID);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_YEAR : '             || P_YEAR);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_MONTH : '            || P_MONTH);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_PERIOD_NAME : '      || P_PERIOD_NAME);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_SEQUENCE_NAME : '    || var_sequence_name);
                
                dbms_output.put_line('Parametros de Ejecucion. ');
                dbms_output.put_line('P_COMPANY_ID : '       || P_COMPANY_ID);
                dbms_output.put_line('P_PERIOD_TYPE : '      || P_PERIOD_TYPE);
                dbms_output.put_line('P_PAYROLL_ID : '       || P_PAYROLL_ID);
                dbms_output.put_line('P_CONSOLIDATION_ID : ' || P_CONSOLIDATION_ID);
                dbms_output.put_line('P_YEAR : '             || P_YEAR);
                dbms_output.put_line('P_MONTH : '            || P_MONTH);
                dbms_output.put_line('P_PERIOD_NAME : '      || P_PERIOD_NAME);
            
            END;
            
            --Inicio del Procesamiento del Cursor
            dbms_output.put_line('Creando el Archivo. . .');
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Creando el Archivo. . .');
            
            --Recorrido del Cursor de Empleados.
            BEGIN
            
                CFDI_LOGGING(var_file_name, 'START WRITE');
            
                var_date_exp := TO_CHAR(SYSDATE, 'RRRR-MM-DD') || 'T' || TO_CHAR(SYSDATE, 'HH24:MI:SS');
                
                OPEN DETAIL_LIST;
                
                LOOP        
                
                    CFDI_LOGGING(var_file_name, 'FLUSH DATA');  
                    DBMS_LOCK.SLEEP(60);                          
                
                    FETCH DETAIL_LIST BULK COLLECT INTO DETAIL LIMIT 100;
                    
                    EXIT WHEN DETAIL.COUNT = 0;
                    
                    FOR rowIndex IN 1 .. DETAIL.COUNT
                    LOOP
                    
                        MIN_WAGE := 0;
                        MIN_WAGE := PAY_MX_UTILITY.GET_MIN_WAGE(P_CTX_DATE_EARNED => DETAIL(rowIndex).DATE_EARNED,
                                                                P_TAX_BASIS => 'NONE',
                                                                P_ECON_ZONE => 'A');
                
                        --Consulta de la Secuencia
                        BEGIN
                            EXECUTE 
                            IMMEDIATE   'SELECT ' || var_sequence_name || '.NEXTVAL FROM DUAL' INTO var_reg_seq;
                        EXCEPTION WHEN OTHERS THEN
                            P_RETCODE := 1;
                            dbms_output.put_line('**Error al Consultar la Secuencia ' || var_sequence_name || '. ' || SQLERRM);
                            FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Consultar la Secuencia ' || var_sequence_name || '. ' || SQLERRM);
                        END;       
                        
                        /****************************************************************/
                        /**                     DATOS DE ENCABEZADO                    **/
                        /****************************************************************/
--                        UTL_FILE.PUT_LINE(var_file, 'E');
                        UTL_FILE.PUT_LINE(var_file, 'NOMINA');
                        UTL_FILE.PUT_LINE(var_file, 'NOMDOC  Recibo Nomina');
                        UTL_FILE.PUT_LINE(var_file, 'TIPDOC  2');    
                        UTL_FILE.PUT_LINE(var_file, 'SERFOL  ' || DETAIL(rowIndex).SERFOL);
                        UTL_FILE.PUT_LINE(var_file, 'NUMFOL ' || TO_CHAR(var_reg_seq,'0000'));
                        UTL_FILE.PUT_LINE(var_file, 'FECEXP  ' || var_date_exp);
                        UTL_FILE.PUT_LINE(var_file, 'TIP     Egreso'); 
                        
                        /****************************************************************/
                        /**                     DATOS DEL EMISOR                        */
                        /****************************************************************/
                        UTL_FILE.PUT_LINE(var_file, 'RFCEMI  ' || DETAIL(rowIndex).RFCEMI);
                        UTL_FILE.PUT_LINE(var_file, 'NOMEMI  ' || DETAIL(rowIndex).NOMEMI);
                        UTL_FILE.PUT_LINE(var_file, 'CALEMI  ' || DETAIL(rowIndex).CALEMI);
                        UTL_FILE.PUT_LINE(var_file, 'COLEMI  ' || DETAIL(rowIndex).COLEMI);
                        UTL_FILE.PUT_LINE(var_file, 'MUNEMI  ' || DETAIL(rowIndex).MUNEMI);
                        UTL_FILE.PUT_LINE(var_file, 'ESTEMI  ' || DETAIL(rowIndex).ESTEMI);
                        UTL_FILE.PUT_LINE(var_file, 'CODEMI  ' || DETAIL(rowIndex).CODEMI);
                        UTL_FILE.PUT_LINE(var_file, 'PAIEMI  ' || DETAIL(rowIndex).PAIEMI);
                        UTL_FILE.PUT_LINE(var_file, 'REGIMEN 601');
                        
                        /****************************************************************/
                        /**                     DATOS DEL EMPLEADO                      */
                        /****************************************************************/
                        UTL_FILE.PUT_LINE(var_file, 'RFCREC  ' || DETAIL(rowIndex).RFCREC);
                        UTL_FILE.PUT_LINE(var_file, 'NOMREC  ' || DETAIL(rowIndex).NOMREC);
                        UTL_FILE.PUT_LINE(var_file, 'CALREC  ' || DETAIL(rowIndex).CALREC);
                        UTL_FILE.PUT_LINE(var_file, 'PAIREC  ' || NVL(DETAIL(rowIndex).PAIREC, 'MEXICO'));
                        
                        /****************************************************************/
                        /**                 DATOS PARA ENVÍO DE CORREO                  */
                        /****************************************************************/
                        IF DETAIL(rowIndex).MAIL <> 'NULL'  AND DETAIL(rowIndex).MAIL <> 'trabajadores@elcalvario.com.mx'THEN
                            UTL_FILE.PUT_LINE(var_file, 'EMAIL    ' || DETAIL(rowIndex).MAIL); --Prueba 17.05.30
                        END IF;
                        UTL_FILE.PUT_LINE(var_file, 'NUMERO_IMP 1');
                        UTL_FILE.PUT_LINE(var_file, 'COPIAS     1');
                        
                        /****************************************************************/
                        /**                 FORMA DE PAGO Y TOTALES                     */
                        /****************************************************************/
                        UTL_FILE.PUT_LINE(var_file, 'FORPAG  Pago en una sola exhibición');
                        UTL_FILE.PUT_LINE(var_file, 'METPAG  NA');
                        UTL_FILE.PUT_LINE(var_file, 'LUGEXP  75790'); --PUE, TEHUACAN'); 
                        UTL_FILE.PUT_LINE(var_file, 'SUBTBR  ' || TO_CHAR(DETAIL(rowIndex).SUBTBR + 
                                                                          DETAIL(rowIndex).SUBEMP + 
                                                                          DETAIL(rowIndex).TOTSEP_ANT +
                                                                          DETAIL(rowIndex).TOTSEP_IND + 
                                                                          (CASE
                                                                               WHEN DETAIL(rowIndex).ISRRET < 0 
                                                                               THEN ABS(DETAIL(rowIndex).ISRRET)
                                                                               WHEN DETAIL(rowIndex).SUBEMP < 0 
                                                                               THEN ABS(DETAIL(rowIndex).SUBEMP)
                                                                               ELSE 0
                                                                           END) +
                                                                          (CASE
                                                                               WHEN DETAIL(rowIndex).VIATICAL > 0
                                                                               THEN DETAIL(rowIndex).VIATICAL
                                                                               ELSE 0
                                                                           END)
                                                                           , '9999990D99'));
                        UTL_FILE.PUT_LINE(var_file, 'MONDET  ' || TO_CHAR(DETAIL(rowIndex).MONDET + 
                                                                          DETAIL(rowIndex).ISRRET +
                                                                          (CASE
                                                                               WHEN DETAIL(rowIndex).ISRRET < 0 
                                                                               THEN ABS(DETAIL(rowIndex).ISRRET)
                                                                               WHEN DETAIL(rowIndex).SUBEMP < 0 
                                                                               THEN ABS(DETAIL(rowIndex).SUBEMP)
                                                                               ELSE 0
                                                                           END) +
                                                                          DETAIL(rowIndex).VIATICAL
                                                                          , '9999990D99'));
                        UTL_FILE.PUT_LINE(var_file, 'TIPMON  MXN');
                        UTL_FILE.PUT_LINE(var_file, 'TIPCAM  1');
                        UTL_FILE.PUT_LINE(var_file, 'TOTPAG  ' || TO_CHAR(((DETAIL(rowIndex).SUBTBR + 
                                                                            DETAIL(rowIndex).SUBEMP +
                                                                            DETAIL(rowIndex).TOTSEP_ANT +
                                                                            DETAIL(rowIndex).TOTSEP_IND 
                                                                            ) - (DETAIL(rowIndex).ISRRET + 
                                                                                 DETAIL(rowIndex).MONDET)), '9999990D99'));
                        
                        /****************************************************************/
                        /**                         DETALLE                             */
                        /****************************************************************/
                        UTL_FILE.PUT_LINE(var_file, 'CANTID  1');
                        UTL_FILE.PUT_LINE(var_file, 'DESCRI  Pago de nómina');
                        UTL_FILE.PUT_LINE(var_file, 'UNIDAD  ACT');
                        UTL_FILE.PUT_LINE(var_file, 'PBRUDE  ' || TO_CHAR(DETAIL(rowIndex).SUBTBR + 
                                                                          DETAIL(rowIndex).SUBEMP +
                                                                          DETAIL(rowIndex).TOTSEP_ANT +
                                                                          DETAIL(rowIndex).TOTSEP_IND +
                                                                          (CASE
                                                                               WHEN DETAIL(rowIndex).ISRRET < 0 
                                                                               THEN ABS(DETAIL(rowIndex).ISRRET)
                                                                               ELSE 0
                                                                           END) +
                                                                          (CASE
                                                                               WHEN DETAIL(rowIndex).VIATICAL > 0
                                                                               THEN DETAIL(rowIndex).VIATICAL
                                                                               ELSE 0
                                                                           END)
                                                                           , '9999990D99'));
                        UTL_FILE.PUT_LINE(var_file, 'IMPBRU  ' || TO_CHAR(DETAIL(rowIndex).SUBTBR + 
                                                                          DETAIL(rowIndex).SUBEMP +
                                                                          DETAIL(rowIndex).TOTSEP_ANT +
                                                                          DETAIL(rowIndex).TOTSEP_IND +
                                                                          (CASE
                                                                               WHEN DETAIL(rowIndex).ISRRET < 0 
                                                                               THEN ABS(DETAIL(rowIndex).ISRRET)
                                                                               ELSE 0
                                                                           END) +
                                                                          (CASE
                                                                               WHEN DETAIL(rowIndex).VIATICAL > 0
                                                                               THEN DETAIL(rowIndex).VIATICAL
                                                                               ELSE 0
                                                                           END)
                                                                           , '9999990D99'));
                        
                        /****************************************************************/
                        /**             COMPLEMENTO DE RECIBOS DE NÓMINA                */
                        /****************************************************************/
                        UTL_FILE.PUT_LINE(var_file, 'NOM_VERS   1.2');
                        UTL_FILE.PUT_LINE(var_file, 'NOM_TIPO   ' || DETAIL(rowIndex).NOM_TIPO);
                        UTL_FILE.PUT_LINE(var_file, 'NOM_FECPAG  ' || TO_CHAR(DETAIL(rowIndex).NOM_FECPAG, 'YYYY-MM-DD'));
                        UTL_FILE.PUT_LINE(var_file, 'NOM_FECINI  ' || TO_CHAR(DETAIL(rowIndex).NOM_FECINI, 'YYYY-MM-DD'));
                        UTL_FILE.PUT_LINE(var_file, 'NOM_FECFIN  ' || TO_CHAR(DETAIL(rowIndex).NOM_FECFIN, 'YYYY-MM-DD'));                        
                        UTL_FILE.PUT_LINE(var_file, 'NOM_DIAPAG  ' || DETAIL(rowIndex).NOM_DIAPAG);
                        UTL_FILE.PUT_LINE(var_file, 'NOM_TOTPER  ' || TO_CHAR(DETAIL(rowIndex).SUBTBR + 
                                                                              DETAIL(rowIndex).TOTSEP_ANT +
                                                                              DETAIL(rowIndex).TOTSEP_IND +
                                                                              DETAIL(rowIndex).VIATICAL, '9999990D99'));
                        IF      DETAIL(rowIndex).ISRRET <> 0 
                           OR   DETAIL(rowIndex).MONDET <> 0 
                           OR   DETAIL(rowIndex).SUBEMP < 0 THEN
                            UTL_FILE.PUT_LINE(var_file, 'NOM_TOTDED  ' || TO_CHAR(DETAIL(rowIndex).ISRRET + 
                                                                                  DETAIL(rowIndex).MONDET +
                                                                                  (CASE
                                                                                       WHEN DETAIL(rowIndex).ISRRET < 0 
                                                                                       THEN ABS(DETAIL(rowIndex).ISRRET)
                                                                                       WHEN DETAIL(rowIndex).SUBEMP < 0 
                                                                                       THEN ABS(DETAIL(rowIndex).SUBEMP)
                                                                                       ELSE 0 
                                                                                   END) +
                                                                                  DETAIL(rowIndex).VIATICAL
                                                                                  , '9999990D99'));
                        END IF;
                        IF  DETAIL(rowIndex).SUBEMP > 0 
                         OR DETAIL(rowIndex).ISRRET < 0 
                         THEN                                                                                
                            UTL_FILE.PUT_LINE(var_file, 'NOM_TOTPAG  ' || TO_CHAR((CASE
                                                                                        WHEN DETAIL(rowIndex).SUBEMP > 0
                                                                                        THEN DETAIL(rowIndex).SUBEMP
                                                                                        ELSE 0 
                                                                                   END) + 
                                                                                  (CASE 
                                                                                        WHEN DETAIL(rowIndex).ISRRET < 0 
                                                                                        THEN ABS(DETAIL(rowIndex).ISRRET)
                                                                                        ELSE 0
                                                                                   END) 
                                                                                   , '9999990D99'));
                        END IF;
                        
                        /****************************************************************/
                        /**                     DATOS DE RECEPTOR                       */
                        /****************************************************************/
                        UTL_FILE.PUT_LINE(var_file, 'NOM_CURP    ' || DETAIL(rowIndex).NOM_CURP);
                        UTL_FILE.PUT_LINE(var_file, 'NOM_NUMSEG  ' || DETAIL(rowIndex).NOM_NUMSEG);
                        UTL_FILE.PUT_LINE(var_file, 'NOM_FECREL  ' || TO_CHAR(DETAIL(rowIndex).NOM_FECREL, 'RRRR-MM-DD'));
                        UTL_FILE.PUT_LINE(var_file, 'NOM_TIPCON  ' || DETAIL(rowIndex).NOM_TIPCON);
                        UTL_FILE.PUT_LINE(var_file, 'NOM_TIPJOR  01');
                        UTL_FILE.PUT_LINE(var_file, 'NOM_TIPREG  02');
                        UTL_FILE.PUT_LINE(var_file, 'NOM_NUMEMP  ' || DETAIL(rowIndex).NOM_NUMEMP);
                        UTL_FILE.PUT_LINE(var_file, 'NOM_DEPTO   ' || REPLACE(DETAIL(rowIndex).NOM_DEPTO, '.', ' '));
                        UTL_FILE.PUT_LINE(var_file, 'NOM_PUESTO  ' || REPLACE(DETAIL(rowIndex).NOM_PUESTO, '.', ' '));
                        UTL_FILE.PUT_LINE(var_file, 'NOM_FORPAG  ' || DETAIL(rowIndex).NOM_FORPAG);
                        UTL_FILE.PUT_LINE(var_file, 'NOM_SALBASE ' || TO_CHAR(DETAIL(rowIndex).NOM_SALBASE, '9999990D99'));
                        IF DETAIL(rowIndex).NOM_SDI >= (MIN_WAGE * 25) THEN
                            UTL_FILE.PUT_LINE(var_file, 'NOM_SDI     ' || TO_CHAR((MIN_WAGE * 25), '9999990D99'));
                        ELSE
                            UTL_FILE.PUT_LINE(var_file, 'NOM_SDI     ' || TO_CHAR(DETAIL(rowIndex).NOM_SDI, '9999990D99'));
                        END IF;
                        UTL_FILE.PUT_LINE(var_file, 'NOM_ENTFED  ' || DETAIL(rowIndex).NOM_ENTFED);
                        UTL_FILE.PUT_LINE(var_file, 'NOM_NUMERONOM  ' || DETAIL(rowIndex).NOM_NUMERONOM);
                        UTL_FILE.PUT_LINE(var_file, 'NOM_REGPAT  ' || DETAIL(rowIndex).NOM_REGPAT);
                        UTL_FILE.PUT_LINE(var_file, 'NOM_TIPSAL  MIXTO');
                        UTL_FILE.PUT_LINE(var_file, 'NOM_CVENOM  ' || DETAIL(rowIndex).NOM_CVENOM);
                        UTL_FILE.PUT_LINE(var_file, 'NOM_PER_TOTSUL  ' || TO_CHAR(DETAIL(rowIndex).SUBTBR +
                                                                                  DETAIL(rowIndex).VIATICAL, '9999990D99'));
                        UTL_FILE.PUT_LINE(var_file, 'NOM_PER_TOTSEP  ' || TO_CHAR(DETAIL(rowIndex).TOTSEP_ANT +
                                                                                  DETAIL(rowIndex).TOTSEP_IND, '9999990D99'));
                        UTL_FILE.PUT_LINE(var_file, 'NOM_PER_TOTGRA  ' || TO_CHAR(DETAIL(rowIndex).NOM_PER_TOTGRA, '9999990D99'));
                        UTL_FILE.PUT_LINE(var_file, 'NOM_PER_TOTEXE  ' || TO_CHAR(DETAIL(rowIndex).NOM_PER_TOTEXE + 
                                                                                  DETAIL(rowIndex).VIATICAL, '9999990D99'));
                        UTL_FILE.PUT_LINE(var_file, 'NOM_DED_TOTGRA  ' || TO_CHAR(0, '9999990D99'));
                        UTL_FILE.PUT_LINE(var_file, 'NOM_DED_TOTEXE  ' || TO_CHAR(DETAIL(rowIndex).MONDET + 
                                                                                  DETAIL(rowIndex).ISRRET +
                                                                                  (CASE
                                                                                       WHEN DETAIL(rowIndex).SUBEMP < 0 
                                                                                       THEN ABS(DETAIL(rowIndex).SUBEMP)
                                                                                       ELSE 0
                                                                                   END) +
                                                                                  (CASE
                                                                                       WHEN DETAIL(rowIndex).VIATICAL > 0
                                                                                       THEN DETAIL(rowIndex).VIATICAL
                                                                                       ELSE 0
                                                                                   END), '9999990D99'));
                        UTL_FILE.PUT_LINE(var_file, 'NOM_DESCRI  ' || DETAIL(rowIndex).NOM_DESCRI);
                        UTL_FILE.PUT_LINE(var_file, 'NOM_SINDC   ' || DETAIL(rowIndex).NOM_SINDC);
                        
                        IF DETAIL(rowIndex).TOTSEP_ANT + DETAIL(rowIndex).TOTSEP_IND > 0 THEN
                            UTL_FILE.PUT_LINE(var_file, 'NOM_PER_TOTPAG     ' || TO_CHAR(DETAIL(rowIndex).TOTSEP_IND, '9999990D99'));
                            UTL_FILE.PUT_LINE(var_file, 'NOM_PER_ANIO       ' || GET_NOM_PER_ANIO(DETAIL(rowIndex).PERSON_ID));
                            UTL_FILE.PUT_LINE(var_file, 'NOM_PER_ULTSUE     ' || TO_CHAR(GET_NOM_PER_ULTSUE(DETAIL(rowIndex).PERSON_ID), '9999990D99'));
                            UTL_FILE.PUT_LINE(var_file, 'NOM_PER_INGACUM    ' || TO_CHAR(GET_NOM_PER_ULTSUE(DETAIL(rowIndex).PERSON_ID), '9999990D99'));
                            UTL_FILE.PUT_LINE(var_file, 'NOM_PER_INGNO      ' || TO_CHAR('0', '9999990D99'));
                        END IF; 
                    
                        DECLARE 
                        
                            CURSOR  DETAIL_ASSIGNMENT_ACTION (P_ASSIGNMENT_ID       NUMBER,
                                                              P_PAYROLL_ACTION_ID   NUMBER) IS
                                     SELECT DISTINCT PAA.ASSIGNMENT_ACTION_ID
                                       FROM PAY_ASSIGNMENT_ACTIONS PAA
                                      WHERE 1 = 1
                                        AND PAA.ASSIGNMENT_ID = P_ASSIGNMENT_ID
                                        AND PAA.PAYROLL_ACTION_ID = P_PAYROLL_ACTION_ID; 
                        
                            CURSOR  DETAIL_PERCEPCION (P_ASSIGNMENT_ACTION_ID   NUMBER) IS
                                     SELECT NOM_PER_TIP,
                                            NOM_PER_CVE,
                                            NOM_PER_DESCRI,
                                            NOM_PER_IMPGRA,
                                            NOM_PER_IMPEXE    
                                       FROM(SELECT 
                                                NOM_PER_TIP,
                                                NOM_PER_CVE,
                                                NOM_PER_DESCRI,
                                                SUM(NOM_PER_IMPGRA) AS  NOM_PER_IMPGRA,
                                                SUM(NOM_PER_IMPEXE) AS  NOM_PER_IMPEXE 
                                              FROM (SELECT /*+ LEADING(PEC PIVF PETF)   index(PEC  PAY_ELEMENT_CLASSIFICATION_UK2)   index(PETF  PAY_ELEMENT_TYPES_F_FK1)     index(PIVF  PAY_INPUT_VALUES_F_UK2)   */
                                                        NVL((SELECT DISTINCT
                                                                    DESCRIPTION
                                                               FROM FND_LOOKUP_VALUES
                                                              WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                                 OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                                AND MEANING LIKE PETF.ELEMENT_NAME
                                                                AND LANGUAGE = 'ESA'), '038')       AS  NOM_PER_TIP,
                                                        NVL((SELECT DISTINCT
                                                                    TAG
                                                               FROM FND_LOOKUP_VALUES
                                                              WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                                 OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                                AND MEANING LIKE PETF.ELEMENT_NAME
                                                                AND LANGUAGE = 'ESA'), '000')      AS  NOM_PER_CVE,
                                                        (CASE 
                                                            WHEN PETF.ELEMENT_NAME = 'Profit Sharing' THEN
                                                                'REPARTO DE UTILIDADES'
                                                            WHEN PETF.ELEMENT_NAME LIKE 'P0%' THEN
                                                                REPLACE(SUBSTR(PETF.ELEMENT_NAME, 6, LENGTH(PETF.ELEMENT_NAME)), '_', ' ')
                                                            WHEN PETF.ELEMENT_NAME LIKE 'A0%' THEN
                                                                REPLACE(SUBSTR(PETF.ELEMENT_NAME, 6, LENGTH(PETF.ELEMENT_NAME)), '_', ' ')
                                                            ELSE
                                                                REPLACE(UPPER(PETF.ELEMENT_NAME), '_', ' ')
                                                         END)                                       AS  NOM_PER_DESCRI,
                                                        (CASE
                                                            WHEN PIVF.NAME = 'ISR Subject' THEN
                                                                SUM(PRRV.RESULT_VALUE)
                                                            ELSE 0
                                                         END)                                       AS  NOM_PER_IMPGRA,
                                                         (CASE
                                                            WHEN PIVF.NAME = 'ISR Exempt' THEN
                                                                SUM(PRRV.RESULT_VALUE)
                                                            ELSE 0
                                                         END)                                       AS  NOM_PER_IMPEXE
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
                                                       AND (PEC.CLASSIFICATION_NAME IN ('Earnings', 
                                                                                        'Supplemental Earnings', 
                                                                                        'Amends', 
                                                                                        'Imputed Earnings') 
                                                              OR PETF.ELEMENT_NAME  IN (SELECT MEANING
                                                                                          FROM FND_LOOKUP_VALUES 
                                                                                         WHERE LOOKUP_TYPE = 'XX_PERCEPCIONES_INFORMATIVAS'
                                                                                           AND LANGUAGE = USERENV('LANG')))
                                                       AND PETF.ELEMENT_NAME NOT IN (CASE 
                                                                                        WHEN P_CONSOLIDATION_ID = 65 THEN 'P091_FONDO AHORRO E ACUM'
                                                                                        ELSE 'TODOS'
                                                                                     END)
                                                       AND PIVF.UOM = 'M'
                                                       AND (PIVF.NAME = 'ISR Subject' OR PIVF.NAME = 'ISR Exempt')
                                                       AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                                                       AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE 
                                                     GROUP BY PETF.ELEMENT_NAME,
                                                              PETF.REPORTING_NAME,
                                                              PETF.ELEMENT_INFORMATION11,
                                                              PIVF.NAME
                                                    UNION
                                                    SELECT /*+ LEADING(PEC PIVF PETF)   index(PEC  PAY_ELEMENT_CLASSIFICATION_UK2)   index(PETF  PAY_ELEMENT_TYPES_F_FK1)     index(PIVF  PAY_INPUT_VALUES_F_UK2)   */
                                                        NVL((SELECT DISTINCT
                                                                    DESCRIPTION
                                                               FROM FND_LOOKUP_VALUES
                                                              WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                                 OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                                AND MEANING LIKE PETF.ELEMENT_NAME
                                                                AND LANGUAGE = 'ESA'), '038')       AS  NOM_PER_TIP,
                                                        NVL((SELECT DISTINCT
                                                                    TAG
                                                               FROM FND_LOOKUP_VALUES
                                                              WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                                 OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                                AND MEANING LIKE PETF.ELEMENT_NAME
                                                                AND LANGUAGE = 'ESA'), '000')      AS  NOM_PER_CVE,
                                                        (CASE
                                                            WHEN PETF.ELEMENT_NAME = 'Profit Sharing' THEN
                                                                'REPARTO DE UTILIDADES' 
                                                            WHEN PETF.ELEMENT_NAME LIKE 'P0%' THEN
                                                                REPLACE(SUBSTR(PETF.ELEMENT_NAME, 6, LENGTH(PETF.ELEMENT_NAME)), '_', ' ')
                                                            WHEN PETF.ELEMENT_NAME LIKE 'A0%' THEN
                                                                REPLACE(SUBSTR(PETF.ELEMENT_NAME, 6, LENGTH(PETF.ELEMENT_NAME)), '_', ' ')
                                                            ELSE
                                                                REPLACE(UPPER(PETF.ELEMENT_NAME), '_', ' ')
                                                         END)                                       AS  NOM_PER_DESCRI,
                                                         0                                          AS  NOM_PER_IMPGRA,
                                                         SUM(PRRV.RESULT_VALUE)                     AS  NOM_PER_IMPEXE
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
                                                       AND PETF.ELEMENT_NAME  IN ('FINAN_TRABAJO_RET',
                                                                                  'P080_FONDO AHORRO TR ACUM',
                                                                                  'P017_PRIMA DE ANTIGUEDAD',
                                                                                  'P026_INDEMNIZACION',
                                                                                  'P047_ISPT ANUAL A FAVOR')
                                                       AND PETF.ELEMENT_NAME NOT IN (CASE 
                                                                                        WHEN P_CONSOLIDATION_ID = 65 THEN 'P080_FONDO AHORRO TR ACUM'
                                                                                        ELSE 'TODOS'
                                                                                     END)
                                                       AND PIVF.UOM = 'M'
                                                       AND PIVF.NAME = 'Pay Value'
                                                       AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                                                       AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
                                                     GROUP BY PETF.ELEMENT_NAME,
                                                              PETF.REPORTING_NAME,
                                                              PETF.ELEMENT_INFORMATION11,
                                                              PIVF.NAME
                                                   ) GROUP BY NOM_PER_TIP,
                                                              NOM_PER_CVE,
                                                              NOM_PER_DESCRI)
                                      WHERE 1 = 1
                                        AND (   NOM_PER_IMPGRA <> 0
                                             OR NOM_PER_IMPEXE <> 0)
                                      ORDER BY NOM_PER_CVE;
                                                                  
                            CURSOR  DETAIL_DEDUCCION (P_ASSIGNMENT_ACTION_ID NUMBER) IS
                                     SELECT NOM_DED_TIP,
                                            NOM_DED_CVE,
                                            NOM_DED_DESCRI,
                                            NOM_DED_IMPGRA,
                                            NOM_DED_IMPEXE
                                       FROM(SELECT /*+ LEADING(PEC PIVF PETF)   index(PEC  PAY_ELEMENT_CLASSIFICATION_UK2)   index(PETF  PAY_ELEMENT_TYPES_F_FK1)     index(PIVF  PAY_INPUT_VALUES_F_UK2)   */
                                                    NVL((SELECT DISTINCT
                                                                DESCRIPTION
                                                           FROM FND_LOOKUP_VALUES
                                                          WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                             OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                            AND MEANING LIKE PETF.ELEMENT_NAME
                                                            AND LANGUAGE = 'ESA'), '004')       AS  NOM_DED_TIP,
                                                    NVL((SELECT DISTINCT
                                                                TAG
                                                           FROM FND_LOOKUP_VALUES
                                                          WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                             OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                            AND MEANING LIKE PETF.ELEMENT_NAME
                                                            AND LANGUAGE = 'ESA'), '000')      AS  NOM_DED_CVE,
                                                   SUBSTR(PETF.ELEMENT_NAME,
                                                          6,
                                                          LENGTH(PETF.ELEMENT_NAME))AS  NOM_DED_DESCRI,
                                                   0                                AS  NOM_DED_IMPGRA,
                                                   PRRV.RESULT_VALUE                AS  NOM_DED_IMPEXE  
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
                                               AND (PEC.CLASSIFICATION_NAME IN ('Voluntary Deductions', 
                                                                                'Involuntary Deductions') 
                                                       OR PETF.ELEMENT_NAME IN (SELECT MEANING
                                                                                  FROM FND_LOOKUP_VALUES 
                                                                                 WHERE LOOKUP_TYPE = 'XX_DEDUCCIONES_INFORMATIVAS'
                                                                                   AND LANGUAGE = USERENV('LANG')))
                                               AND PIVF.UOM = 'M'
                                               AND PIVF.NAME = 'Pay Value'
                                               AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                                               AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE)
                                       WHERE 1 = 1
                                         AND (   NOM_DED_IMPGRA <> 0
                                              OR NOM_DED_IMPEXE <> 0)
                                       ORDER BY NOM_DED_DESCRI;
                                       
                            CURSOR DETAIL_OTRA_PERCEPCION (P_ASSIGNMENT_ACTION_ID   NUMBER) IS
                                    SELECT 
                                        NVL((SELECT DISTINCT
                                                    DESCRIPTION
                                               FROM FND_LOOKUP_VALUES
                                              WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                 OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                AND MEANING LIKE PETF.ELEMENT_NAME
                                                AND LANGUAGE = 'ESA'), '016')       AS  NOM_OTR_TIP,
                                        NVL((SELECT DISTINCT
                                                    TAG
                                               FROM FND_LOOKUP_VALUES
                                              WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                 OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                AND MEANING LIKE PETF.ELEMENT_NAME
                                                AND LANGUAGE = 'ESA'), '000')      AS  NOM_OTR_CVE,
                                        (CASE
                                            WHEN PETF.ELEMENT_NAME = 'Profit Sharing' THEN
                                                'REPARTO DE UTILIDADES' 
                                            WHEN PETF.ELEMENT_NAME LIKE 'P0%' THEN
                                                REPLACE(SUBSTR(PETF.ELEMENT_NAME, 6, LENGTH(PETF.ELEMENT_NAME)), '_', ' ')
                                            WHEN PETF.ELEMENT_NAME LIKE 'A0%' THEN
                                                REPLACE(SUBSTR(PETF.ELEMENT_NAME, 6, LENGTH(PETF.ELEMENT_NAME)), '_', ' ')
                                            ELSE
                                                REPLACE(UPPER(PETF.ELEMENT_NAME), '_', ' ')
                                         END)                                       AS  NOM_OTR_DESCRI,
                                         0                                          AS  NOM_OTR_IMPEXE,
                                         SUM(PRRV.RESULT_VALUE)                     AS  NOM_OTR_IMPGRA
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
                                       AND PETF.ELEMENT_NAME  IN ('P032_SUBSIDIO_PARA_EMPLEO')
                                       AND PIVF.UOM = 'M'
                                       AND PIVF.NAME = 'Pay Value'
                                       AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                                       AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
                                     GROUP BY PETF.ELEMENT_NAME,
                                              PETF.REPORTING_NAME,
                                              PETF.ELEMENT_INFORMATION11,
                                              PIVF.NAME;
                        
                            isPERCEP    BOOLEAN;
                            isDEDUC     BOOLEAN;
                            isOTRO      BOOLEAN;
                            
                            isOTHER     BOOLEAN;
                            
                            var_extra_days      NUMBER;
                            var_extra_hours     NUMBER;
                            var_extra_pay_value NUMBER;
                            var_seniority_years NUMBER;
                            var_proposed_salary NUMBER;
                            var_inc_dias        NUMBER;
                            var_inc_tip         VARCHAR2(100);
                            
                        BEGIN
                        
                            isPERCEP := FALSE;
                            isDEDUC  := FALSE;
                            isOTRO   := FALSE;
                        
                            FOR ASSIGN IN DETAIL_ASSIGNMENT_ACTION (DETAIL(rowIndex).ASSIGNMENT_ID, DETAIL(rowIndex).PAYROLL_ACTION_ID) LOOP       
                                FOR PERCEP IN DETAIL_PERCEPCION (ASSIGN.ASSIGNMENT_ACTION_ID) LOOP
                                    IF isPERCEP = FALSE THEN
--                                        UTL_FILE.PUT_LINE(var_file, 'INIPER');
                                        isPERCEP := TRUE;
                                    END IF;
                                    
                                    isOTHER := FALSE;
                                
                                    UTL_FILE.PUT_LINE(var_file, 'INIPER');
                                    UTL_FILE.PUT_LINE(var_file, 'NOM_PER_TIP     ' || PERCEP.NOM_PER_TIP);
                                    UTL_FILE.PUT_LINE(var_file, 'NOM_PER_CVE     ' || PERCEP.NOM_PER_CVE);
                                    UTL_FILE.PUT_LINE(var_file, 'NOM_PER_DESCRI  ' || REPLACE(PERCEP.NOM_PER_DESCRI, '_', ' '));
                                    UTL_FILE.PUT_LINE(var_file, 'NOM_PER_IMPGRA  ' || TO_CHAR(PERCEP.NOM_PER_IMPGRA, '9999990D99'));
                                    UTL_FILE.PUT_LINE(var_file, 'NOM_PER_IMPEXE  ' || TO_CHAR(PERCEP.NOM_PER_IMPEXE, '9999990D99'));
                                    
                                    IF PERCEP.NOM_PER_DESCRI = 'HORAS EXTRAS' THEN
                                    
                                        UTL_FILE.PUT_LINE(var_file, 'FINPER');
                                        isOTHER := TRUE;
                                    
                                        var_extra_hours := GET_NOM_HEX_DIAS(ASSIGN.ASSIGNMENT_ACTION_ID,'Hours');
                                        var_extra_pay_value := GET_NOM_HEX_DIAS(ASSIGN.ASSIGNMENT_ACTION_ID, 'Pay Value');
                                        
                                        IF      var_extra_hours <= 3 THEN 
                                            var_extra_days := 1;
                                        ELSIF   var_extra_hours > 3 AND var_extra_hours <= 6 THEN
                                            var_extra_days := 2;
                                        ELSIF   var_extra_hours > 6  THEN
                                            var_extra_days := 3;
                                        END IF;
                                        
                                        UTL_FILE.PUT_LINE(var_file, '');
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_HEX_DIAS   ' || TO_CHAR(var_extra_days));
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_HEX_TIP    01');
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_HEX_HOR    ' || TO_CHAR(ROUND(var_extra_hours)));
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_HEX_IMP    ' || TO_CHAR(var_extra_pay_value, '9999990D99'));
                                        UTL_FILE.PUT_LINE(var_file, '');
                                    
                                    END IF;
                                    
                                    IF PERCEP.NOM_PER_DESCRI = 'INDEMNIZACION' THEN
                                    
                                        UTL_FILE.PUT_LINE(var_file, 'FINPER');
                                        isOTHER := TRUE;
                                    
                                        var_seniority_years := TRUNC(HR_MX_UTILITY.GET_SENIORITY_SOCIAL_SECURITY(DETAIL(rowIndex).PERSON_ID, SYSDATE));
                                        var_proposed_salary := GET_PROPOSED_SALARY(DETAIL(rowIndex).ASSIGNMENT_ID);
                                    
                                        UTL_FILE.PUT_LINE(var_file, '');
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_PER_TOTPAG     ' || TO_CHAR(GET_NOM_PER_TOTPAG(ASSIGN.ASSIGNMENT_ACTION_ID), '9999990D99'));
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_PER_ANIO       ' || TO_CHAR(var_seniority_years));
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_PER_UTLSUE     ' || TO_CHAR(var_proposed_salary, '9999990D99'));
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_PER_INGACUM    ');
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_PER_INGNO      '); 
                                        UTL_FILE.PUT_LINE(var_file, '');   
                                    
                                    END IF;
                                    
                                    IF PERCEP.NOM_PER_DESCRI = 'SUBSIDIO INCAPACIDAD' THEN
                                        
                                        UTL_FILE.PUT_LINE(var_file, 'FINPER');
                                        isOTHER := TRUE;
                                        
                                        var_inc_dias := GET_INFORMATION_VALUE(ASSIGN.ASSIGNMENT_ACTION_ID,
                                                                              'P012_SUBSIDIO INCAPACIDAD',
                                                                              'Days');
                                        var_inc_tip := GET_INFORMATION_DISABILITY(DETAIL(rowIndex).PERSON_ID,
                                                                                  DETAIL(rowIndex).NOM_FECINI,
                                                                                  DETAIL(rowIndex).NOM_FECFIN);
                                                                                  
                                        IF    var_inc_tip = 'RT' THEN
                                            var_inc_tip := '01';
                                        ELSIF var_inc_tip = 'MAT' THEN
                                            var_inc_tip := '03';
                                        ELSIF var_inc_tip = 'GRAL' THEN
                                            var_inc_tip := '02';
                                        END IF;
                                        
                                        UTL_FILE.PUT_LINE(var_file, '');
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_INC_DIAS       ' || TO_CHAR(var_inc_dias));
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_INC_TIP        ' || TO_CHAR(var_inc_tip));
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_INC_IMP        ' || TO_CHAR(PERCEP.NOM_PER_IMPEXE, '9999990D99'));
                                        UTL_FILE.PUT_LINE(var_file, '');
                                    
                                    END IF;
                                    
                                    IF isOTHER = FALSE THEN
                                        UTL_FILE.PUT_LINE(var_file, 'FINPER');
                                    END IF;
                                
                                END LOOP;
                            END LOOP;
                            
                            IF DETAIL(rowIndex).VIATICAL > 0 THEN
                                UTL_FILE.PUT_LINE(var_file, 'INIPER');
                                UTL_FILE.PUT_LINE(var_file, 'NOM_PER_TIP     ' || '050');
                                UTL_FILE.PUT_LINE(var_file, 'NOM_PER_CVE     ' || '005');
                                UTL_FILE.PUT_LINE(var_file, 'NOM_PER_DESCRI  ' || 'VIATICOS');
                                UTL_FILE.PUT_LINE(var_file, 'NOM_PER_IMPGRA  ' || TO_CHAR('0', '9999990D99'));
                                UTL_FILE.PUT_LINE(var_file, 'NOM_PER_IMPEXE  ' || TO_CHAR(ABS(DETAIL(rowIndex).VIATICAL), '9999990D99'));
                                UTL_FILE.PUT_LINE(var_file, 'FINPER');
                            END IF;
                                    
                            IF isPERCEP = TRUE THEN
                                NULL;
--                                UTL_FILE.PUT_LINE(var_file, '');
--                                UTL_FILE.PUT_LINE(var_file, 'FINPER');
                            END IF;                        
                               
                            UTL_FILE.PUT_LINE(var_file, '');
                            IF      DETAIL(rowIndex).MONDET <> 0 
                               OR   DETAIL(rowIndex).SUBEMP < 0 THEN
                                UTL_FILE.PUT_LINE(var_file, 'NOM_DED_OTRDED ' || TO_CHAR(DETAIL(rowIndex).MONDET + 
                                                                                         (CASE
                                                                                              WHEN DETAIL(rowIndex).SUBEMP < 0
                                                                                              THEN ABS(DETAIL(rowIndex).SUBEMP)
                                                                                              ELSE 0
                                                                                          END) +
                                                                                         DETAIL(rowIndex).VIATICAL
                                                                                         , '9999990D99'));
                            END IF;
                            IF DETAIL(rowIndex).ISRRET > 0 THEN
                                UTL_FILE.PUT_LINE(var_file, 'NOM_DED_TOTRET ' ||TO_CHAR(DETAIL(rowIndex).ISRRET , '9999990D99'));
                            END IF;
                            UTL_FILE.PUT_LINE(var_file, '');
                            
                            FOR ASSIGN IN DETAIL_ASSIGNMENT_ACTION (DETAIL(rowIndex).ASSIGNMENT_ID, DETAIL(rowIndex).PAYROLL_ACTION_ID) LOOP                            
                                FOR DEDUC IN DETAIL_DEDUCCION (ASSIGN.ASSIGNMENT_ACTION_ID) LOOP
                                
                                    IF isDEDUC = FALSE THEN
--                                        UTL_FILE.PUT_LINE(var_file, 'INIDED');
                                        isDEDUC := TRUE;   
                                    END IF;
                                
                                    IF      DEDUC.NOM_DED_DESCRI <> 'ISPT' THEN
                                        UTL_FILE.PUT_LINE(var_file, 'INIDED');
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_DED_TIP     ' || DEDUC.NOM_DED_TIP);
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_DED_CVE     ' || DEDUC.NOM_DED_CVE);
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_DED_DESCRI  ' || REPLACE(DEDUC.NOM_DED_DESCRI, '_', ' '));
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_DED_IMPGRA  ' || TO_CHAR(DEDUC.NOM_DED_IMPEXE, '9999990D99'));
                                        UTL_FILE.PUT_LINE(var_file, 'FINDED'); 
                                    ELSIF   DEDUC.NOM_DED_DESCRI = 'ISPT' AND DETAIL(rowIndex).ISRRET >= 0 THEN
                                        UTL_FILE.PUT_LINE(var_file, 'INIDED');
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_DED_TIP     ' || DEDUC.NOM_DED_TIP);
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_DED_CVE     ' || DEDUC.NOM_DED_CVE);
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_DED_DESCRI  ' || REPLACE(DEDUC.NOM_DED_DESCRI, '_', ' '));
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_DED_IMPGRA  ' || TO_CHAR(DEDUC.NOM_DED_IMPEXE, '9999990D99'));
                                        UTL_FILE.PUT_LINE(var_file, 'FINDED');                                                                                   
                                    END IF;
                                    
                                    
                                END LOOP;
                            END LOOP;                       
                                    
                            IF      DETAIL(rowIndex).SUBEMP < 0 THEN
                                UTL_FILE.PUT_LINE(var_file, 'INIDED');
                                UTL_FILE.PUT_LINE(var_file, 'NOM_DED_TIP     ' || '013');
                                UTL_FILE.PUT_LINE(var_file, 'NOM_DED_CVE     ' || '000');
                                UTL_FILE.PUT_LINE(var_file, 'NOM_DED_DESCRI  ' || 'PAGOS HECHOS CON EXCESO AL TRABAJADOR');
                                UTL_FILE.PUT_LINE(var_file, 'NOM_DED_IMPGRA  ' || TO_CHAR(ABS(DETAIL(rowIndex).SUBEMP), '9999990D99'));
                                UTL_FILE.PUT_LINE(var_file, 'FINDED');
                            END IF;
                            
                            IF DETAIL(rowIndex).VIATICAL > 0 THEN
                                UTL_FILE.PUT_LINE(var_file, 'INIDED');
                                UTL_FILE.PUT_LINE(var_file, 'NOM_DED_TIP     ' || '081');
                                UTL_FILE.PUT_LINE(var_file, 'NOM_DED_CVE     ' || '006');
                                UTL_FILE.PUT_LINE(var_file, 'NOM_DED_DESCRI  ' || 'AJUSTE DE VIATICOS');
                                UTL_FILE.PUT_LINE(var_file, 'NOM_DED_IMPGRA  ' || TO_CHAR(ABS(DETAIL(rowIndex).VIATICAL), '9999990D99'));
--                                UTL_FILE.PUT_LINE(var_file, 'NOM_DED_IMPEXE  ' || TO_CHAR(ABS(DETAIL(rowIndex).VIATICAL), '9999990D99'));
                                UTL_FILE.PUT_LINE(var_file, 'FINDED');
                            END IF;
                            
                            IF isDEDUC = TRUE THEN
                                NULL;
--                                UTL_FILE.PUT_LINE(var_file, '');
--                                UTL_FILE.PUT_LINE(var_file, 'FINDED');
                            END IF;
                                
                            FOR ASSIGN IN DETAIL_ASSIGNMENT_ACTION (DETAIL(rowIndex).ASSIGNMENT_ID, DETAIL(rowIndex).PAYROLL_ACTION_ID) LOOP
                                FOR OTR IN DETAIL_OTRA_PERCEPCION (ASSIGN.ASSIGNMENT_ACTION_ID) LOOP
                                
                                    IF isOTRO = FALSE THEN
--                                        UTL_FILE.PUT_LINE(var_file, 'INIOTR');
                                        isOTRO := TRUE;   
                                    END IF;
                                
                                    IF DETAIL(rowIndex).SUBEMP > 0 THEN 
                                        UTL_FILE.PUT_LINE(var_file, 'INIOTR');
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_OTR_TIP     ' || OTR.NOM_OTR_TIP);
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_OTR_CVE     ' || OTR.NOM_OTR_CVE);
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_OTR_DESCRI  ' || REPLACE(OTR.NOM_OTR_DESCRI, '_', ' '));
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_OTR_IMPGRA  ' || TO_CHAR(OTR.NOM_OTR_IMPGRA, '9999990D99'));
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_OTR_IMPEXE  ' || TO_CHAR(OTR.NOM_OTR_IMPEXE, '9999990D99'));
                                        UTL_FILE.PUT_LINE(var_file, '');    
                                        UTL_FILE.PUT_LINE(var_file, 'NOM_OTR_SUBSID ' || NVL(GET_SUBSIDIO_EMPLEO(ASSIGN.ASSIGNMENT_ACTION_ID), TO_CHAR(OTR.NOM_OTR_IMPGRA, '9999990D99')));
                                        UTL_FILE.PUT_LINE(var_file, 'FINOTR');
                                    END IF;
                                    
                                END LOOP;
                            END LOOP;
                            
                            IF DETAIL(rowIndex).ISRRET < 0 THEN
                                UTL_FILE.PUT_LINE(var_file, 'INIOTR');
                                UTL_FILE.PUT_LINE(var_file, 'NOM_OTR_TIP     ' || '001');
                                UTL_FILE.PUT_LINE(var_file, 'NOM_OTR_CVE     ' || '000');
                                UTL_FILE.PUT_LINE(var_file, 'NOM_OTR_DESCRI  ' || 'REINTEGRO DE ISR PAGADO EN EXCESO');
                                UTL_FILE.PUT_LINE(var_file, 'NOM_OTR_IMPGRA  ' || TO_CHAR(ABS(DETAIL(rowIndex).ISRRET), '9999990D99'));
                                UTL_FILE.PUT_LINE(var_file, 'NOM_OTR_IMPEXE  ' || TO_CHAR('0', '9999990D99'));
                                UTL_FILE.PUT_LINE(var_file, 'FINOTR');
                            END IF;
                            
                            
                            IF isOTRO = TRUE THEN
                                UTL_FILE.PUT_LINE(var_file, '');
--                                UTL_FILE.PUT_LINE(var_file, 'FINOTR');
                            END IF;
                            
                            UTL_FILE.PUT_LINE(var_file, '');
                            
                            dbms_output.put_line(TO_CHAR(var_reg_seq,'00000') || ' - ' || DETAIL(rowIndex).NOMREC);
                            FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(var_reg_seq,'00000') || ' - ' || DETAIL(rowIndex).NOMREC);
                            
                        EXCEPTION WHEN OTHERS THEN
                            P_RETCODE := 1;
                            dbms_output.put_line('**Error al Crear los Registros de Percepciones y Deducciones. ' || SQLERRM);
                            FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Crear los Registros de Percepciones y Deducciones. ' || SQLERRM);
                        END;
                
                        CFDI_LOGGING(var_file_name, 'WRITE ' || DETAIL(rowIndex).NOM_NUMEMP || ' ' || DETAIL(rowIndex).NOMREC);
                        REGISTRING;

                    END LOOP;
                    
                END LOOP;
                
                CLOSE DETAIL_LIST;
                        
            
            EXCEPTION WHEN OTHERS THEN
                P_RETCODE := 1;
                dbms_output.put_line('**Error al Recorrer el Cursor DETAIL_LIST. ' || SQLERRM);
                FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Recorrer el Cursor DETAIL_LIST. ' || SQLERRM);
            END;
            
            --Finalizacion del Procedimiento.
            dbms_output.put_line('Archivo creado!');
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Archivo creado!');
            
            --Eliminación de la secuencia
            BEGIN
            
                UPDATE PAC_CFDI_NOMINA_TB 
                   SET RECORDS = var_reg_seq
                 WHERE 1 = 1
                   AND USER_ID = var_user_id
                   AND REQUEST_ID = var_request_id
                   AND FILE_NAME = var_file_name
                   AND SEQUENCE_NAME = var_sequence_name;
            
                EXECUTE IMMEDIATE 'DROP SEQUENCE ' || var_sequence_name;
                
                IF NVL(var_reg_seq, 0) = 0 THEN
                    P_RETCODE := 1;
                    P_ERRBUF := 'EL ARCHIVO SE ENCUENTRA VACIO, NOMINA NO EJECUTADA.';
                END IF;
                              
            EXCEPTION WHEN OTHERS THEN
                P_RETCODE := 1;
                dbms_output.put_line('**Error al Borrar la Secuencia ' || var_sequence_name || '. ' || SQLERRM);
                FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Borrar la Secuencia ' || var_sequence_name || '. ' || SQLERRM);
            END;
            
            CFDI_LOGGING(var_file_name, 'FINISHED WRITE');
            COMMIT;
        
        ELSE
            P_RETCODE := 1;
            P_ERRBUF := 'EL ARCHIVO ' || var_file_name || ' YA HA SIDO GENERADO ANTERIORMENTE.';
        END IF;
        
    EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('**Error al Ejecutar el Procedure PAC_CFDI_NOMINA_PRC. ' || SQLERRM);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Ejecutar el Procedure PAC_CFDI_NOMINA_PRC. ' || SQLERRM);
    END CREATE_CFDI_NOMINA;
        
    PROCEDURE FILE_CFDI_NOMINA(
        P_ERRBUF    OUT NOCOPY  VARCHAR2,
        P_RETCODE   OUT NOCOPY  VARCHAR2,
        P_COMPANY_ID            VARCHAR2,
        P_PERIOD_TYPE           VARCHAR2,
        P_PAYROLL_ID            NUMBER,
        P_CONSOLIDATION_ID      NUMBER,
        P_YEAR                  NUMBER,
        P_MONTH                 NUMBER,
        P_PERIOD_NAME           VARCHAR2,
        P_EARNED_DATE           VARCHAR2)
    IS
        
        V_REQUEST_ID            NUMBER;
        WAITING                 BOOLEAN;
        PHASE                   VARCHAR2 (80 BYTE);
        STATUS                  VARCHAR2 (80 BYTE);
        DEV_PHASE               VARCHAR2 (80 BYTE);
        DEV_STATUS              VARCHAR2 (80 BYTE);
        V_MESSAGE               VARCHAR2 (4000 BYTE);
        
        var_file_name           VARCHAR2 (1000);
        var_file_records        NUMBER;
        var_directory_name      VARCHAR2 (1000);
        var_local_directory     VARCHAR2(150) := '/var/tmp/CARGAS/CFE/INTERFACE_NOM_O';
        ERROR_FILES             PAC_CFDI_ERROR_FILES;
        var_errors              NUMBER;
        var_user_id             NUMBER := FND_GLOBAL.USER_ID;
        
        var_request_id_export   NUMBER;
        
        NO_DIRECTORY            EXCEPTION;
        
        var_ejecuciones         NUMBER;
    
    BEGIN
    
        DELETE 
          FROM PAC_CFDI_LOG_TB;
        COMMIT;
    
        FND_GLOBAL.APPS_INITIALIZE (USER_ID        => 3397,     --IPONCE
                                    RESP_ID        => 50668,    --CALVARIO_HR_ADMINISTRADOR
                                    RESP_APPL_ID   => 800);     --Human Resources
                       
        MO_GLOBAL.SET_POLICY_CONTEXT (P_ACCESS_MODE => 'S', 
                                      P_ORG_ID      => 85);   
        
        BEGIN
        
            FND_FILE.PUT_LINE(FND_FILE.LOG,  '');
            FND_FILE.PUT_LINE(FND_FILE.LOG,  'XXCALV - Crea CFDI de Nómina');
            FND_FILE.PUT_LINE(FND_FILE.LOG,  'Inicio : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS'));   
                
            V_REQUEST_ID :=
                FND_REQUEST.SUBMIT_REQUEST (
                   APPLICATION => 'PER',
                   PROGRAM => 'PAC_CFDI_NOMINA',
                   DESCRIPTION => '',
                   START_TIME => '',
                   SUB_REQUEST => FALSE,
                   ARGUMENT1 => TO_CHAR(P_COMPANY_ID),
                   ARGUMENT2 => TO_CHAR(P_PERIOD_TYPE),
                   ARGUMENT3 => TO_CHAR(P_PAYROLL_ID),
                   ARGUMENT4 => TO_CHAR(P_CONSOLIDATION_ID),
                   ARGUMENT5 => TO_CHAR(P_YEAR),
                   ARGUMENT6 => TO_CHAR(P_MONTH),
                   ARGUMENT7 => TO_CHAR(P_PERIOD_NAME),
                   ARGUMENT8 => TO_CHAR(P_EARNED_DATE)
                                           );
            STANDARD.COMMIT;                                          
                         
            WAITING :=
                FND_CONCURRENT.WAIT_FOR_REQUEST (
                    REQUEST_ID => V_REQUEST_ID,
                    INTERVAL => 1,
                    MAX_WAIT => 0,
                    PHASE => PHASE,
                    STATUS => STATUS,
                    DEV_PHASE => DEV_PHASE,
                    DEV_STATUS => DEV_STATUS,
                    MESSAGE => V_MESSAGE
                                            );
        
            FND_FILE.PUT_LINE(FND_FILE.LOG,  'Finalización : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS')); 
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Fase : ' || PHASE || '     Estatus : ' || STATUS);   
            
        EXCEPTION WHEN OTHERS THEN
            dbms_output.put_line('**Error al mover el archivo CFDI de Nómina. ' || SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al mover el archivo CFDI de Nómina. ' || SQLERRM);
        END;
        
        SELECT FILE_NAME,
               RECORDS
          INTO var_file_name,
               var_file_records
          FROM PAC_CFDI_NOMINA_TB CFDI
         WHERE 1 = 1
           AND CFDI.REQUEST_ID = V_REQUEST_ID; 
           

        IF P_COMPANY_ID = '02' THEN 
            var_directory_name := 'Calvario_Servicios';
        ELSIF P_COMPANY_ID = '08' THEN 
            RAISE NO_DIRECTORY;
        ELSIF P_COMPANY_ID = '11' THEN 
            var_directory_name := 'Productos_Avicolas';
        END IF;
    
        
        IF PHASE IN ('Finalizado', 'Completed') AND STATUS IN ('Normal') THEN 
        
            FND_FILE.PUT_LINE(FND_FILE.LOG,  '');
            FND_FILE.PUT_LINE(FND_FILE.LOG,  'XXCALV - Mueve CFDI de Nómina');
            FND_FILE.PUT_LINE(FND_FILE.LOG,  'Inicio : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS'));
        
            BEGIN
                
                    
                V_REQUEST_ID :=
                    FND_REQUEST.SUBMIT_REQUEST (
                       APPLICATION => 'PER',
                       PROGRAM => 'MUEVE_CFDI_NOMINA',
                       DESCRIPTION => '',
                       START_TIME => '',
                       SUB_REQUEST => FALSE,
                       ARGUMENT1 => TO_CHAR(var_file_name),
                       ARGUMENT2 => TO_CHAR(var_directory_name)
                                               );
                STANDARD.COMMIT;                  
                             
                WAITING :=
                    FND_CONCURRENT.WAIT_FOR_REQUEST (
                        REQUEST_ID => V_REQUEST_ID,
                        INTERVAL => 1,
                        MAX_WAIT => 0,
                        PHASE => PHASE,
                        STATUS => STATUS,
                        DEV_PHASE => DEV_PHASE,
                        DEV_STATUS => DEV_STATUS,
                        MESSAGE => V_MESSAGE
                                                );
                
                FND_FILE.PUT_LINE(FND_FILE.LOG,  'Finalización : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS')); 
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Fase : ' || PHASE || '     Estatus : ' || STATUS); 
                
            EXCEPTION WHEN OTHERS THEN
                dbms_output.put_line('**Error al mover el archivo CFDI de Nómina. ' || SQLERRM);
                FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al mover el archivo CFDI de Nómina. ' || SQLERRM);
            END;
            
        ELSE
                    P_RETCODE := 1;
        END IF;
        
        IF PHASE IN ('Finalizado', 'Completed') AND STATUS IN ('Normal') THEN 
        
            FND_FILE.PUT_LINE(FND_FILE.LOG,  '');
            FND_FILE.PUT_LINE(FND_FILE.LOG,  'XXCALV - Timbrado CFDI de Nómina');
            FND_FILE.PUT_LINE(FND_FILE.LOG,  'Inicio : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS'));
            
            BEGIN
                
                V_REQUEST_ID :=
                    FND_REQUEST.SUBMIT_REQUEST (
                       APPLICATION => 'PER',
                       PROGRAM => 'PAC_TIMBRADO_CFDI_NOMINA',
                       DESCRIPTION => '',
                       START_TIME => '',
                       SUB_REQUEST => FALSE,
                       ARGUMENT1 => TO_CHAR(var_file_name),
                       ARGUMENT2 => TO_CHAR(var_directory_name)
                                               );
                STANDARD.COMMIT;                  
                                 
                WAITING :=
                    FND_CONCURRENT.WAIT_FOR_REQUEST (
                        REQUEST_ID => V_REQUEST_ID,
                        INTERVAL => 1,
                        MAX_WAIT => 0,
                        PHASE => PHASE,
                        STATUS => STATUS,
                        DEV_PHASE => DEV_PHASE,
                        DEV_STATUS => DEV_STATUS,
                        MESSAGE => V_MESSAGE
                                                );
                    
                FND_FILE.PUT_LINE(FND_FILE.LOG,  'Finalización : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS')); 
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Fase : ' || PHASE || '     Estatus : ' || STATUS);  
                
            EXCEPTION WHEN OTHERS THEN
                dbms_output.put_line('**Error durante el timbrado del archivo CFDI de Nómina. ' || SQLERRM);
                FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error durante el timbrado del archivo CFDI de Nómina. ' || SQLERRM);
            END;
            
        ELSE
                P_RETCODE := 1;    
        END IF;
        
        
        IF PHASE IN ('Finalizado', 'Completed') AND STATUS IN ('Advertencia', 'Warning') THEN
        
            FND_GLOBAL.APPS_INITIALIZE (USER_ID        => var_user_id,
                                        RESP_ID        => 50668,    --CALVARIO_HR_ADMINISTRADOR
                                        RESP_APPL_ID   => 800);     --Human Resources
                           
            MO_GLOBAL.SET_POLICY_CONTEXT (P_ACCESS_MODE => 'S', 
                                          P_ORG_ID      => 85);
        
            FND_FILE.PUT_LINE(FND_FILE.LOG,  '');
            FND_FILE.PUT_LINE(FND_FILE.LOG,  'XXCALV - Errores CFDI de Nómina');
            FND_FILE.PUT_LINE(FND_FILE.LOG,  'Inicio : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS'));
                    
            DECLARE 
                var_remote_directory    VARCHAR2(150) := '/' || var_directory_name || '/Descarga/' || EXTRACT(YEAR FROM SYSDATE) || '/' || TRIM(TO_CHAR(EXTRACT(MONTH FROM SYSDATE), '00'));
                var_company_directory   VARCHAR2(150) := var_directory_name;
                var_day_directory       VARCHAR2(150) := TO_CHAR(TO_DATE(SYSDATE, 'DD/MM/RRRR'), 'RRRRMMDD');
                var_new_directory       VARCHAR2(150) := var_day_directory || '_' || REPLACE(var_file_name, '.txt', '');
            BEGIN
                                                                                                         
                        
                V_REQUEST_ID :=
                    FND_REQUEST.SUBMIT_REQUEST (
                       APPLICATION => 'PER',
                       PROGRAM => 'ERRORES_CFDI_NOMINA',
                       DESCRIPTION => '',
                       START_TIME => '',
                       SUB_REQUEST => FALSE,
                       ARGUMENT1 => TO_CHAR(var_remote_directory),
                       ARGUMENT2 => TO_CHAR(var_local_directory),
                       ARGUMENT3 => TO_CHAR(var_company_directory),
                       ARGUMENT4 => TO_CHAR(var_day_directory),
                       ARGUMENT5 => TO_CHAR(var_new_directory)
                                               );
                STANDARD.COMMIT;                  
                                         
                WAITING :=
                    FND_CONCURRENT.WAIT_FOR_REQUEST (
                        REQUEST_ID => V_REQUEST_ID,
                        INTERVAL => 1,
                        MAX_WAIT => 0,
                        PHASE => PHASE,
                        STATUS => STATUS,
                        DEV_PHASE => DEV_PHASE,
                        DEV_STATUS => DEV_STATUS,
                        MESSAGE => V_MESSAGE
                                                );
                            
                FND_FILE.PUT_LINE(FND_FILE.LOG,  'Finalización : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS')); 
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Fase : ' || PHASE || '     Estatus : ' || STATUS);  
                        
            EXCEPTION WHEN OTHERS THEN
                dbms_output.put_line('**Error durante la descarga del archivo de Errores de Timbrado Nómina. ' || SQLERRM);
                FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error durante la descarga del archivo de Errores de Timbrado Nómina. ' || SQLERRM);
            END;    
        
        
            P_RETCODE := 1; 
        END IF;   
        
        
        FND_GLOBAL.APPS_INITIALIZE (USER_ID        => 3397,     --IPONCE
                                    RESP_ID        => 50668,    --CALVARIO_HR_ADMINISTRADOR
                                    RESP_APPL_ID   => 800);     --Human Resources
                       
        MO_GLOBAL.SET_POLICY_CONTEXT (P_ACCESS_MODE => 'S', 
                                      P_ORG_ID      => 85);
           
         
        BEGIN
            
            FND_FILE.PUT_LINE(FND_FILE.LOG,  '');
            FND_FILE.PUT_LINE(FND_FILE.LOG,  'XXCALV - Descarga CFDI de Nómina');
            FND_FILE.PUT_LINE(FND_FILE.LOG,  'Inicio : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS'));
                        
            DECLARE 
                var_remote_directory    VARCHAR2(150) := '/' || var_directory_name || '/Descarga/' || EXTRACT(YEAR FROM SYSDATE) || '/' || TRIM(TO_CHAR(EXTRACT(MONTH FROM SYSDATE), '00'));
                var_company_directory   VARCHAR2(150) := var_directory_name;
                var_day_directory       VARCHAR2(150) := TO_CHAR(TO_DATE(SYSDATE, 'DD/MM/RRRR'), 'RRRRMMDD');
                var_new_directory       VARCHAR2(150) := var_day_directory || '_' || REPLACE(var_file_name, '.txt', '');
            BEGIN
                            
                                  
                LOOP
                    ERROR_FILES := GET_ERROR_FILES(var_directory_name, TO_CHAR(TO_DATE(SYSDATE, 'DD/MM/RRRR'), 'RRRRMMDD'));
                        
                    var_errors := ERROR_FILES.COUNT;
                
                    FOR var_index IN 1..ERROR_FILES.COUNT LOOP
                        DECLARE
                            var_file_name           VARCHAR2(100) := '';
                        BEGIN
                            var_file_name := ERROR_FILES(var_index);
                                
                            IF var_file_name IN ('Productos_Avicolas', 'Calvario_Servicios', 'aspnet_client', 'Adriana_Pocovi') THEN
                                var_errors := var_errors - 1;                
                            END IF;
                        END;
                    END LOOP;
                    
                    DBMS_LOCK.SLEEP(60);
                    CFDI_LOGGING(var_file_name, 'WAIT DOWNLOAD FILES');
                        
                    EXIT WHEN IS_DOWNLOADING(var_remote_directory,((var_file_records - var_errors) * 2)) = FALSE;
                END LOOP;
                                                                                             
                            
                V_REQUEST_ID :=
                    FND_REQUEST.SUBMIT_REQUEST (
                       APPLICATION => 'PER',
                       PROGRAM => 'DESCARGA_CFDI_NOMINA',
                       DESCRIPTION => '',
                       START_TIME => '',
                       SUB_REQUEST => FALSE,
                       ARGUMENT1 => TO_CHAR(var_remote_directory),
                       ARGUMENT2 => TO_CHAR(var_local_directory),
                       ARGUMENT3 => TO_CHAR(var_company_directory),
                       ARGUMENT4 => TO_CHAR(var_day_directory),
                       ARGUMENT5 => TO_CHAR(var_new_directory)
                                               );
                STANDARD.COMMIT;                  
                                             
                WAITING :=
                    FND_CONCURRENT.WAIT_FOR_REQUEST (
                        REQUEST_ID => V_REQUEST_ID,
                        INTERVAL => 1,
                        MAX_WAIT => 0,
                        PHASE => PHASE,
                        STATUS => STATUS,
                        DEV_PHASE => DEV_PHASE,
                        DEV_STATUS => DEV_STATUS,
                        MESSAGE => V_MESSAGE
                                                );
                                
                FND_FILE.PUT_LINE(FND_FILE.LOG,  'Finalización : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS')); 
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Fase : ' || PHASE || '     Estatus : ' || STATUS);  
                            
            EXCEPTION WHEN OTHERS THEN
                dbms_output.put_line('**Error durante la descarga de los archivos XML de Nómina. ' || SQLERRM);
                FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error durante la descarga de los archivos XML de Nómina. ' || SQLERRM);
            END;
            
            CFDI_LOGGING(var_file_name, 'FILES DOWNLOADED');
            
        END;
              
        
                
        IF P_COMPANY_ID = '02' AND P_CONSOLIDATION_ID = 68 THEN
        
            IF PHASE IN ('Finalizado', 'Completed') AND STATUS IN ('Normal') THEN
            
                FND_FILE.PUT_LINE(FND_FILE.LOG,  '');
                FND_FILE.PUT_LINE(FND_FILE.LOG,  'ATET - Exportar movimientos de caja de ahorro');
                FND_FILE.PUT_LINE(FND_FILE.LOG,  'Inicio : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS'));
            
                BEGIN                                                                    
                        
                    V_REQUEST_ID :=
                        FND_REQUEST.SUBMIT_REQUEST (
                           APPLICATION => 'PER',
                           PROGRAM => 'ATET_EXPORT_PAYROLL_RESULTS',
                           DESCRIPTION => '',
                           START_TIME => '',
                           SUB_REQUEST => FALSE,
                           ARGUMENT1 => TO_CHAR(P_PERIOD_TYPE),
                           ARGUMENT2 => TO_CHAR(P_YEAR),
                           ARGUMENT3 => TO_CHAR(P_MONTH),
                           ARGUMENT4 => TO_CHAR(P_PERIOD_NAME)
                                                   );
                    STANDARD.COMMIT;                  
                                         
                    WAITING :=
                        FND_CONCURRENT.WAIT_FOR_REQUEST (
                            REQUEST_ID => V_REQUEST_ID,
                            INTERVAL => 1,
                            MAX_WAIT => 0,
                            PHASE => PHASE,
                            STATUS => STATUS,
                            DEV_PHASE => DEV_PHASE,
                            DEV_STATUS => DEV_STATUS,
                            MESSAGE => V_MESSAGE
                                                    );
                                                    
                    var_request_id_export := V_REQUEST_ID;
                            
                    FND_FILE.PUT_LINE(FND_FILE.LOG,  'Finalización : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS')); 
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Fase : ' || PHASE || '     Estatus : ' || STATUS);  
                        
                EXCEPTION WHEN OTHERS THEN
                    dbms_output.put_line('**Error durante la importación de los archivos XML de Nómina. ' || SQLERRM);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error durante la importación de los archivos XML de Nómina. ' || SQLERRM);
                END;
            ELSE
                P_RETCODE := 1;
            END IF;
            
            IF PHASE IN ('Finalizado', 'Completed') AND STATUS IN ('Normal') THEN
            
                FND_FILE.PUT_LINE(FND_FILE.LOG,  '');
                FND_FILE.PUT_LINE(FND_FILE.LOG,  'ATET - Importar movimientos de caja de ahorro');
                FND_FILE.PUT_LINE(FND_FILE.LOG,  'Inicio : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS'));
            
                BEGIN                                                                    
                        
                    V_REQUEST_ID :=
                        FND_REQUEST.SUBMIT_REQUEST (
                           APPLICATION => 'PER',
                           PROGRAM => 'ATET_IMPORT_PAYROLL_RESULTS',
                           DESCRIPTION => '',
                           START_TIME => '',
                           SUB_REQUEST => FALSE,
                           ARGUMENT1 => TO_CHAR(var_request_id_export)
                                                   );
                    STANDARD.COMMIT;                  
                                         
                    WAITING :=
                        FND_CONCURRENT.WAIT_FOR_REQUEST (
                            REQUEST_ID => V_REQUEST_ID,
                            INTERVAL => 1,
                            MAX_WAIT => 0,
                            PHASE => PHASE,
                            STATUS => STATUS,
                            DEV_PHASE => DEV_PHASE,
                            DEV_STATUS => DEV_STATUS,
                            MESSAGE => V_MESSAGE
                                                    );
                            
                    FND_FILE.PUT_LINE(FND_FILE.LOG,  'Finalización : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS')); 
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Fase : ' || PHASE || '     Estatus : ' || STATUS);  
                        
                EXCEPTION WHEN OTHERS THEN
                    dbms_output.put_line('**Error durante la importación de los archivos XML de Nómina. ' || SQLERRM);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error durante la importación de los archivos XML de Nómina. ' || SQLERRM);
                END;
            ELSE
                P_RETCODE := 1;
            END IF;
            
            IF PHASE IN ('Finalizado', 'Completed') AND STATUS IN ('Normal') THEN
            
                FND_FILE.PUT_LINE(FND_FILE.LOG,  '');
                FND_FILE.PUT_LINE(FND_FILE.LOG,  'ATET - Transferir movimientos de caja de ahorro a GL - D071_CAJA DE AHORRO');
                FND_FILE.PUT_LINE(FND_FILE.LOG,  'Inicio : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS'));
            
                BEGIN                                                                    
                        
                    V_REQUEST_ID :=
                        FND_REQUEST.SUBMIT_REQUEST (
                           APPLICATION => 'PER',
                           PROGRAM => 'ATET_TRANSFER_EXPORT_TO_GL',
                           DESCRIPTION => '',
                           START_TIME => '',
                           SUB_REQUEST => FALSE,
                           ARGUMENT1 => TO_CHAR(P_PERIOD_TYPE),
                           ARGUMENT2 => TO_CHAR(P_YEAR),
                           ARGUMENT3 => TO_CHAR(P_MONTH),
                           ARGUMENT4 => TO_CHAR(P_PERIOD_NAME),
                           ARGUMENT5 => TO_CHAR('D071_CAJA DE AHORRO')
                                                   );
                    STANDARD.COMMIT;                  
                                         
                    WAITING :=
                        FND_CONCURRENT.WAIT_FOR_REQUEST (
                            REQUEST_ID => V_REQUEST_ID,
                            INTERVAL => 1,
                            MAX_WAIT => 0,
                            PHASE => PHASE,
                            STATUS => STATUS,
                            DEV_PHASE => DEV_PHASE,
                            DEV_STATUS => DEV_STATUS,
                            MESSAGE => V_MESSAGE
                                                    );
                            
                    FND_FILE.PUT_LINE(FND_FILE.LOG,  'Finalización : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS')); 
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Fase : ' || PHASE || '     Estatus : ' || STATUS);  
                        
                EXCEPTION WHEN OTHERS THEN
                    dbms_output.put_line('**Error durante la importación de los archivos XML de Nómina. ' || SQLERRM);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error durante la importación de los archivos XML de Nómina. ' || SQLERRM);
                END;
            ELSE
                P_RETCODE := 1;
            END IF;
            
            IF PHASE IN ('Finalizado', 'Completed') AND STATUS IN ('Normal') THEN
            
                FND_FILE.PUT_LINE(FND_FILE.LOG,  '');
                FND_FILE.PUT_LINE(FND_FILE.LOG,  'ATET - Transferir movimientos de caja de ahorro a GL - D072_PRESTAMO CAJA DE AHORRO');
                FND_FILE.PUT_LINE(FND_FILE.LOG,  'Inicio : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS'));
            
                BEGIN                                                                    
                        
                    V_REQUEST_ID :=
                        FND_REQUEST.SUBMIT_REQUEST (
                           APPLICATION => 'PER',
                           PROGRAM => 'ATET_TRANSFER_EXPORT_TO_GL',
                           DESCRIPTION => '',
                           START_TIME => '',
                           SUB_REQUEST => FALSE,
                           ARGUMENT1 => TO_CHAR(P_PERIOD_TYPE),
                           ARGUMENT2 => TO_CHAR(P_YEAR),
                           ARGUMENT3 => TO_CHAR(P_MONTH),
                           ARGUMENT4 => TO_CHAR(P_PERIOD_NAME),
                           ARGUMENT5 => TO_CHAR('D072_PRESTAMO CAJA DE AHORRO')
                                                   );
                    STANDARD.COMMIT;                  
                                         
                    WAITING :=
                        FND_CONCURRENT.WAIT_FOR_REQUEST (
                            REQUEST_ID => V_REQUEST_ID,
                            INTERVAL => 1,
                            MAX_WAIT => 0,
                            PHASE => PHASE,
                            STATUS => STATUS,
                            DEV_PHASE => DEV_PHASE,
                            DEV_STATUS => DEV_STATUS,
                            MESSAGE => V_MESSAGE
                                                    );
                            
                    FND_FILE.PUT_LINE(FND_FILE.LOG,  'Finalización : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS')); 
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Fase : ' || PHASE || '     Estatus : ' || STATUS);  
                        
                EXCEPTION WHEN OTHERS THEN
                    dbms_output.put_line('**Error durante la importación de los archivos XML de Nómina. ' || SQLERRM);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error durante la importación de los archivos XML de Nómina. ' || SQLERRM);
                END;
            ELSE
                P_RETCODE := 1;
            END IF;
            
        END IF;
        
        FND_GLOBAL.APPS_INITIALIZE (USER_ID        => var_user_id,
                                    RESP_ID        => 50668,    --CALVARIO_HR_ADMINISTRADOR
                                    RESP_APPL_ID   => 800);     --Human Resources
                           
        MO_GLOBAL.SET_POLICY_CONTEXT (P_ACCESS_MODE => 'S', 
                                      P_ORG_ID      => 85);
        
         
        IF PHASE IN ('Finalizado', 'Completed') AND STATUS IN ('Normal') OR var_ejecuciones > 1 THEN
        
            FND_FILE.PUT_LINE(FND_FILE.LOG,  '');
            FND_FILE.PUT_LINE(FND_FILE.LOG,  'XXCALV-Programa_Importacion_CFDI_Nom');
            FND_FILE.PUT_LINE(FND_FILE.LOG,  'Inicio : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS'));
                
            CFDI_LOGGING(var_file_name, 'START IMPORT CFDI');
            
            BEGIN
                    
                V_REQUEST_ID :=
                    FND_REQUEST.SUBMIT_REQUEST (
                       APPLICATION => 'PAY',
                       PROGRAM => 'XXCALV_UUID_NOM',
                       DESCRIPTION => '',
                       START_TIME => '',
                       SUB_REQUEST => FALSE,
                       ARGUMENT1 => TO_CHAR(var_local_directory)
                                               );
                STANDARD.COMMIT;                  
                                     
                WAITING :=
                    FND_CONCURRENT.WAIT_FOR_REQUEST (
                        REQUEST_ID => V_REQUEST_ID,
                        INTERVAL => 1,
                        MAX_WAIT => 0,
                        PHASE => PHASE,
                        STATUS => STATUS,
                        DEV_PHASE => DEV_PHASE,
                        DEV_STATUS => DEV_STATUS,
                        MESSAGE => V_MESSAGE
                                                );
                        
                FND_FILE.PUT_LINE(FND_FILE.LOG,  'Finalización : ' || TO_CHAR(SYSDATE, 'DD-MON-RRRR HH24:MI:SS')); 
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Fase : ' || PHASE || '     Estatus : ' || STATUS);  
                    
            EXCEPTION WHEN OTHERS THEN
                dbms_output.put_line('**Error durante el timbrado del archivo CFDI de Nómina. ' || SQLERRM);
                FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error durante el timbrado del archivo CFDI de Nómina. ' || SQLERRM);
            END;
           
        
            CFDI_LOGGING(var_file_name, 'FINISHED IMPORT CFDI');
        ELSE
                P_RETCODE := 1;
        END IF; 

    EXCEPTION WHEN NO_DIRECTORY THEN
        P_ERRBUF := 'DIRECTORIO NO DEFINIDO';
        P_RETCODE := 1;
    END FILE_CFDI_NOMINA;
    
    
    PROCEDURE REPORT_CFDI_NOMINA(
        P_COMPANY_ID            VARCHAR2,
        P_PERIOD_TYPE           VARCHAR2,
        P_PAYROLL_ID            NUMBER,
        P_CONSOLIDATION_ID      NUMBER,
        P_YEAR                  NUMBER,
        P_MONTH                 NUMBER,
        P_PERIOD_NAME           VARCHAR2)
    IS
--        
        MIN_WAGE            NUMBER;
                
        CURSOR  DETAIL_LIST IS
             SELECT DISTINCT 
                    PPF.PAYROLL_NAME,
                    (CASE
                        WHEN FLV1.LOOKUP_CODE = '02' THEN 'CSUD'
                        WHEN FLV1.LOOKUP_CODE = '08' THEN 'POGA'
                        WHEN FLV1.LOOKUP_CODE = '11' THEN 'PACUD'
                     END)                                                                           AS  SERFOL,
                    UPPER(OI.ORG_INFORMATION2)                                                      AS  RFCEMI,
                    UPPER(FLV1.MEANING)                                                             AS  NOMEMI,
                    UPPER(LA.ADDRESS_LINE_1)                                                        AS  CALEMI,
                    UPPER(LA.ADDRESS_LINE_2)                                                        AS  COLEMI,
                    UPPER(LA.TOWN_OR_CITY)                                                          AS  MUNEMI,
                    UPPER(FLV2.MEANING)                                                             AS  ESTEMI,
                    LA.POSTAL_CODE                                                                  AS  CODEMI,
                    UPPER(FT1.NLS_TERRITORY)                                                        AS  PAIEMI,
                    (CASE
                        WHEN PAPF.EMPLOYEE_NUMBER = 5646
                        THEN 'GAÑU980724L34'
                        ELSE REPLACE(PAPF.PER_INFORMATION2, '-', '')
                     END)                                                                           AS  RFCREC,
                    UPPER(PAPF.LAST_NAME        || ' ' || 
                          PAPF.PER_INFORMATION1 || ' ' || 
                          PAPF.FIRST_NAME       || ' ' || 
                          PAPF.MIDDLE_NAMES)                                                        AS  NOMREC,
                    UPPER(PAD.ADDRESS_LINE1)                                                        AS  CALREC,
                    (SELECT UPPER(NVL(FT2.NLS_TERRITORY, 'MEXICO'))
                       FROM PER_ADDRESSES    PA,
                            FND_TERRITORIES  FT2
                      WHERE PA.PERSON_ID = PAPF.PERSON_ID
                        AND FT2.TERRITORY_CODE = PA.COUNTRY)                                        AS  PAIREC,
                    NVL(PAPF.EMAIL_ADDRESS, 'NULL')                                                 AS  MAIL,
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_SUBTBR(PAA.ASSIGNMENT_ACTION_ID), '0'))                             AS  SUBTBR,  
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_SUBEMP(PAA.ASSIGNMENT_ACTION_ID), '0'))                             AS  SUBEMP,  
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_TOTSEP(PAA.ASSIGNMENT_ACTION_ID), '0'))                             AS  TOTSEP_ANT, 
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_PER_TOTSEP(PAA.ASSIGNMENT_ACTION_ID), '0'))                         AS  TOTSEP_IND,
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_ISRRET(PAA.ASSIGNMENT_ACTION_ID), '0'))                             AS  ISRRET,
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_MONDET(PAA.ASSIGNMENT_ACTION_ID), '0'))                             AS  MONDET,  
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_VIATICAL(PAA.ASSIGNMENT_ACTION_ID), '0'))                           AS  VIATICAL,
                    PAPF.EMPLOYEE_NUMBER                                                            AS  NOM_NUMEMP,
                    PAPF.NATIONAL_IDENTIFIER                                                        AS  NOM_CURP,
                    PAC_CFDI_FUNCTIONS_PKG.GET_EFFECTIVE_START_DATE(PAPF.PERSON_ID)                                        AS  NOM_FECREL,
                    (CASE
                        WHEN PAAF.EMPLOYEE_CATEGORY = '001CALV' THEN 'Sí'
                        WHEN PAAF.EMPLOYEE_CATEGORY = '002CALV' THEN 'No'
                        ELSE 'No'
                     END)                                                                           AS  NOM_SINDC,
                    (CASE
                        WHEN PAAF.EMPLOYMENT_CATEGORY = 'MX1_P' THEN
                            '01'
                        WHEN PAAF.EMPLOYMENT_CATEGORY = 'MX2_E' THEN
                            '03'
                     END)                                                                           AS  NOM_TIPCON,    
                    (CASE
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%NORMAL%' THEN
                            PTP.START_DATE
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%FINIQUITOS%' THEN
                            PTP.END_DATE + 1 
                        ELSE 
                            PTP.END_DATE
                     END)                                                                           AS  NOM_FECINI,
                    (CASE
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%FINIQUITOS%' THEN
                            PTP.END_DATE + 1
                        ELSE 
                            PTP.END_DATE
                     END)                                                                           AS  NOM_FECFIN,
                    TO_CHAR(REPLACE(REPLACE(PAPF.PER_INFORMATION3, ' ', ''),'-',''), '00000000000') AS  NOM_NUMSEG,   
                    MAX(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_DIAPAG(PAA.ASSIGNMENT_ACTION_ID), '1'))                          AS  NOM_DIAPAG,
                    HOUV.NAME                                                                       AS  NOM_DEPTO,
                    (CASE
                        WHEN HOUV.REGION_1 = 'CAMP' THEN 'CAM'
                        WHEN HOUV.REGION_1 = 'TAMPS' THEN 'TAM'
                        WHEN HOUV.REGION_1 = 'CHIS' THEN 'CHP'
                        WHEN HOUV.REGION_1 = 'DF' THEN 'DIF'
                        WHEN HOUV.REGION_1 = 'QROO' THEN 'ROO'
                        WHEN HOUV.REGION_1 = 'TLAX' THEN 'TLA'
                        ELSE HOUV.REGION_1
                     END)                                                                           AS  NOM_ENTFED,
                    HAPD.NAME                                                                       AS  NOM_PUESTO, 
                    (CASE
                        WHEN PPF.PAYROLL_NAME LIKE '%SEM%' 
                         AND PCS.CONSOLIDATION_SET_NAME LIKE '%NORMAL%'
                        THEN '02'
                        WHEN PPF.PAYROLL_NAME LIKE '%QUIN%'
                         AND PCS.CONSOLIDATION_SET_NAME LIKE '%NORMAL%' 
                        THEN '04'
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%GRATIFICACIÓN%'
                        THEN '99'
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%FINIQUITO%'
                        THEN '99'
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%PTU%'
                        THEN '99'
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%AGUINALDO%'
                        THEN '99'
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%FONDO DE AHORRO%'
                        THEN '99'
                     END)                                                                           AS  NOM_FORPAG,
                    PTP.PERIOD_NUM                                                                  AS  NOM_NUMERONOM,
                    APPS.PAC_HR_PAY_PKG.GET_EMPLOYER_REGISTRATION(PAAF.ASSIGNMENT_ID)               AS  NOM_REGPAT,
                    MAX(NVL(PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAA.ASSIGNMENT_ACTION_ID,
                                            'Integrated Daily Wage',
                                            'Pay Value'), '0'))                                     AS  NOM_SDI,
                    MAX(NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,
                                              'P001_SUELDO NORMAL',
                                              'Sueldo Diario'), '0'))                               AS  NOM_SALBASE, 
                    MAX(NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(PAA.ASSIGNMENT_ACTION_ID,
                                              'P039_DESPENSA',
                                              'Pay Value'), '0'))                                   AS  GROCERIES_VALUE,
                    PPF.ATTRIBUTE1                                                                  AS  NOM_CVENOM,  
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_PER_TOTSUL(PAA.ASSIGNMENT_ACTION_ID), '0'))                         AS  NOM_PER_TOTSUL,
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_PER_TOTGRA(PAA.ASSIGNMENT_ACTION_ID), '0'))                         AS  NOM_PER_TOTGRA,
                    SUM(NVL(PAC_CFDI_FUNCTIONS_PKG.GET_PER_TOTEXE(PAA.ASSIGNMENT_ACTION_ID), '0'))                         AS  NOM_PER_TOTEXE,  
                    PAC_CFDI_FUNCTIONS_PKG.GET_NOM_DESCRI(PPA.PAYROLL_ACTION_ID)                                           AS  NOM_DESCRI,
                    (CASE
                        WHEN PCS.CONSOLIDATION_SET_NAME LIKE '%NORMAL%' THEN
                            'O'
                        ELSE
                            'E'
                     END)                                                                           AS  NOM_TIPO,   
                     NVL((SELECT DISTINCT 
                                 (CASE WHEN PAPF.EMPLOYEE_NUMBER = 13 OR PAPF.EMPLOYEE_NUMBER = 24 THEN
                                        '03' --TRANSFERENCIA E' --'TRANSFERENCIA ELECTRONICA'
                                       WHEN PCS.CONSOLIDATION_SET_NAME = 'FINIQUITOS' THEN
                                        '02' --CHEQUE' --'CHEQUE'
                                       WHEN POPM.ORG_PAYMENT_METHOD_NAME LIKE '%EFECTIVO%' THEN
                                        '01' --EFECTIVO' --'EFECTIVO'
                                       WHEN (POPM.ORG_PAYMENT_METHOD_NAME LIKE '%BANCOMER%'
                                          OR POPM.ORG_PAYMENT_METHOD_NAME LIKE '%BANORTE%'
                                          OR POPM.ORG_PAYMENT_METHOD_NAME LIKE '%HSBC%'
                                          OR POPM.ORG_PAYMENT_METHOD_NAME LIKE '%INVERLAT%') THEN
                                        '03' --TRANSFERENCIA E' --'TRANSFERENCIA ELECTRONICA'
                                       
                                  END)
                            FROM PER_ALL_ASSIGNMENTS_F          PAA,
                                 PAY_PERSONAL_PAYMENT_METHODS_F PPPM,
                                 PAY_ORG_PAYMENT_METHODS_F      POPM,
                                 PAY_PAYMENT_TYPES_V            PPTV
                            WHERE PPPM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
                              AND PPPM.ORG_PAYMENT_METHOD_ID = POPM.ORG_PAYMENT_METHOD_ID
                              AND PPTV.PAYMENT_TYPE_ID = POPM.PAYMENT_TYPE_ID
                              AND PPTV.TERRITORY_CODE = 'MX'
                              AND (POPM.ORG_PAYMENT_METHOD_NAME NOT LIKE '%DESPENSA%'
                              AND POPM.ORG_PAYMENT_METHOD_NAME NOT LIKE '%EFECTIVALE%'
                              AND POPM.ORG_PAYMENT_METHOD_NAME NOT LIKE '%PENSIONES%')
                              AND ROWNUM = 1
                                ), '01')                                                            AS  METPAG,
                    PPF.PAYROLL_ID,
                    PAAF.ASSIGNMENT_ID,
                    PAPF.PERSON_ID,
                    PPA.PAYROLL_ACTION_ID,
                    PPA.DATE_EARNED,
                    PPA.CONSOLIDATION_SET_ID,
                    PPA.EFFECTIVE_DATE,
                    PTP.END_DATE
                  FROM 
                       FND_LOOKUP_VALUES            FLV1,
                       HR_ALL_ORGANIZATION_UNITS    AOU,
                       HR_LOCATIONS_ALL             LA,
                       HR_ORGANIZATION_INFORMATION  OI,
                       FND_TERRITORIES              FT1,
                       FND_LOOKUP_VALUES            FLV2,
                       PAY_PAYROLLS_F               PPF,
                       PAY_PAYROLL_ACTIONS          PPA,
                       PER_TIME_PERIODS             PTP,
                       PER_ALL_ASSIGNMENTS_F        PAAF,
                       PAY_ASSIGNMENT_ACTIONS       PAA,
                       PER_ALL_PEOPLE_F             PAPF,
                       PAY_RUN_TYPES_X              PRTX,
                       HR_ORGANIZATION_UNITS_V      HOUV,
                       HR_ALL_POSITIONS_D           HAPD,
                       PAY_CONSOLIDATION_SETS       PCS,
                       PER_ADDRESSES                PAD
                 WHERE 1 = 1
                   AND FLV1.LOOKUP_TYPE = 'NOMINAS POR EMPLEADOR LEGAL'
                   AND FLV1.LOOKUP_CODE = P_COMPANY_ID
                   AND FLV1.LANGUAGE = USERENV('LANG')
                   AND AOU.NAME = FLV1.MEANING
                   AND LA.LOCATION_ID = AOU.LOCATION_ID
                   AND AOU.ORGANIZATION_ID = OI.ORGANIZATION_ID
                   AND OI.ORG_INFORMATION_CONTEXT = 'MX_TAX_REGISTRATION'
                   AND LA.COUNTRY = FT1.TERRITORY_CODE
                   AND FLV2.LOOKUP_CODE = LA.REGION_1
                   AND FLV2.LOOKUP_TYPE = 'MX_STATE'
                   AND FLV2.LANGUAGE = USERENV('LANG')
                   AND SUBSTR(PPF.PAYROLL_NAME,1,2) = FLV1.LOOKUP_CODE
                   AND APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(P_PERIOD_TYPE, APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
                   AND PPF.PAYROLL_ID = NVL(P_PAYROLL_ID, PPF.PAYROLL_ID) 
                   AND PPF.PAYROLL_ID = PPA.PAYROLL_ID
                   AND PPA.CONSOLIDATION_SET_ID  = NVL(P_CONSOLIDATION_ID, PPA.CONSOLIDATION_SET_ID)
                   AND PTP.PAYROLL_ID = PPF.PAYROLL_ID
                   AND (EXTRACT(YEAR FROM PTP.END_DATE) = P_YEAR 
                    AND EXTRACT(MONTH FROM PTP.END_DATE) = P_MONTH)
                   AND PTP.PERIOD_NAME = NVL(P_PERIOD_NAME, PTP.PERIOD_NAME)
                   AND PPA.EFFECTIVE_DATE BETWEEN PTP.START_DATE AND PTP.END_DATE
                   AND PTP.TIME_PERIOD_ID = PPA.TIME_PERIOD_ID   
                   AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
                   AND PAPF.PERSON_ID = PAAF.PERSON_ID
                   AND PAD.PERSON_ID = PAPF.PERSON_ID
                   AND PPA.CONSOLIDATION_SET_ID = PCS.CONSOLIDATION_SET_ID
                   AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID 
                   AND PAA.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
                   AND PRTX.RUN_TYPE_ID = PAA.RUN_TYPE_ID
                   AND PAAF.ORGANIZATION_ID = NVL(HOUV.ORGANIZATION_ID, PAAF.ORGANIZATION_ID) 
                   AND PAAF.POSITION_ID = NVL(HAPD.POSITION_ID, PAAF.POSITION_ID)
                   AND PPF.PAYROLL_NAME NOT IN ('02_SEM - GRBE', '02_QUIN - EVENTUAL')
                   AND PPA.EFFECTIVE_DATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
                   AND PPA.EFFECTIVE_DATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
                   AND PPA.EFFECTIVE_DATE BETWEEN HAPD.EFFECTIVE_START_DATE AND HAPD.EFFECTIVE_END_DATE
                   AND PPA.EFFECTIVE_DATE BETWEEN PRTX.EFFECTIVE_START_DATE AND PRTX.EFFECTIVE_END_DATE
                   AND PPA.EFFECTIVE_DATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
--                   AND PAC_CFDI_FUNCTIONS_PKG.GET_PAYMENT_METHOD(PAA.ASSIGNMENT_ID) LIKE '%%'
                   AND (    (CASE
                                WHEN PCS.CONSOLIDATION_SET_NAME IN ('GRATIFICACIÓN', 'PTU', 'NORMAL') THEN  
                                    PAC_CFDI_FUNCTIONS_PKG.GET_SUBTBR(PAA.ASSIGNMENT_ACTION_ID)
                                ELSE 1
                            END) <> 0
                        OR  (CASE 
                                WHEN PCS.CONSOLIDATION_SET_NAME IN ('GRATIFICACIÓN', 'PTU', 'NORMAL') THEN
                                    PAC_CFDI_FUNCTIONS_PKG.GET_MONDET(PAA.ASSIGNMENT_ACTION_ID)
                                ELSE 1        
                            END) <> 0
                        OR  (CASE 
                                WHEN PCS.CONSOLIDATION_SET_NAME IN ('GRATIFICACIÓN', 'PTU', 'NORMAL') THEN
                                    PAC_CFDI_FUNCTIONS_PKG.GET_ISRRET(PAA.ASSIGNMENT_ACTION_ID)
                                ELSE 1
                            END) <> 0)
                   AND (CASE
                            WHEN PCS.CONSOLIDATION_SET_NAME IN ('NORMAL') THEN
                                PAC_CFDI_FUNCTIONS_PKG.GET_DIAPAG(PAA.ASSIGNMENT_ACTION_ID)
                            ELSE 1
                        END) <> 0
--                   AND PAPF.EMPLOYEE_NUMBER NOT IN (5646) -- PrBueba 17.05.30
                 GROUP BY PPF.PAYROLL_NAME,
                          FLV1.LOOKUP_CODE,
                          OI.ORG_INFORMATION2,
                          FLV1.MEANING,
                          LA.ADDRESS_LINE_1,
                          LA.ADDRESS_LINE_2,
                          LA.TOWN_OR_CITY,
                          FLV2.MEANING,
                          LA.POSTAL_CODE,
                          FT1.NLS_TERRITORY,
                          PAPF.PER_INFORMATION2,
                          PAPF.LAST_NAME, 
                          PAPF.PER_INFORMATION1, 
                          PAPF.FIRST_NAME, 
                          PAPF.MIDDLE_NAMES,
                          PAPF.PERSON_ID,
                          PAD.ADDRESS_LINE1,
                          PAPF.EMAIL_ADDRESS,
                          PAPF.EMPLOYEE_NUMBER,
                          PAAF.EMPLOYEE_CATEGORY,
                          PAPF.NATIONAL_IDENTIFIER,
                          PCS.CONSOLIDATION_SET_NAME,
                          PTP.END_DATE,
                          PTP.START_DATE,
                          PAPF.PER_INFORMATION3,
                          HOUV.NAME,
                          HOUV.REGION_1,
                          HAPD.NAME,
                          PTP.PERIOD_NUM,
                          PAAF.ASSIGNMENT_ID,
                          PAAF.EMPLOYMENT_CATEGORY,
                          PPF.ATTRIBUTE1,
                          PPA.PAYROLL_ACTION_ID,
                          PPF.PAYROLL_ID,
                          PAAF.ASSIGNMENT_ID,
                          PPA.PAYROLL_ACTION_ID,
                          PPA.DATE_EARNED,
                          PPA.CONSOLIDATION_SET_ID,
                          PPA.EFFECTIVE_DATE,
                          PTP.END_DATE
                 ORDER BY PPF.PAYROLL_NAME,
                          PAPF.EMPLOYEE_NUMBER;                          



                                       
         TYPE   DETAILS IS TABLE OF DETAIL_LIST%ROWTYPE INDEX BY PLS_INTEGER;
         
         DETAIL DETAILS;
         
    BEGIN
        
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;        
        DELETE FROM PAC_CFDI_HEADERS_TB;
        DELETE FROM PAC_CFDI_EARNINGS_TB;
        DELETE FROM PAC_CFDI_DEDUCTIONS_TB;
        
        COMMIT;
            
        --Impresión de Parametros.
        BEGIN
            
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parametros de Ejecucion. ');
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_COMPANY_ID : '       || P_COMPANY_ID);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_PERIOD_TYPE : '      || P_PERIOD_TYPE);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_PAYROLL_ID : '       || P_PAYROLL_ID);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_CONSOLIDATION_ID : ' || P_CONSOLIDATION_ID);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_YEAR : '             || P_YEAR);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_MONTH : '            || P_MONTH);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_PERIOD_NAME : '      || P_PERIOD_NAME);
            
        END;
            
        --Inicio del Procesamiento del Cursor
        dbms_output.put_line('Creando el Archivo. . .');
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Creando el Archivo. . .');
            
        --Recorrido del Cursor de Empleados.
        BEGIN
                
            OPEN DETAIL_LIST;
                
            LOOP
                
                FETCH DETAIL_LIST BULK COLLECT INTO DETAIL LIMIT 500;
                    
                EXIT WHEN DETAIL.COUNT = 0;
                    
                FOR rowIndex IN 1 .. DETAIL.COUNT
                LOOP
                    
                    MIN_WAGE := 0;
                    MIN_WAGE := PAY_MX_UTILITY.GET_MIN_WAGE(P_CTX_DATE_EARNED => DETAIL(rowIndex).DATE_EARNED,
                                                            P_TAX_BASIS => 'NONE',
                                                            P_ECON_ZONE => 'A');      
                        
                    INSERT
                      INTO PAC_CFDI_HEADERS_TB( FECEXP,
                                                RFCEMI,
                                                NOMEMI,
                                                CALEMI,
                                                COLEMI,
                                                MUNEMI,
                                                ESTEMI,
                                                CODEMI,
                                                PAIEMI,
                                                RFCREC,
                                                NOMREC,
                                                PAIREC,
                                                SUBTBR,
                                                ISRRET,
                                                MONDET,
                                                TOTPAG,
                                                NOM_NUMEMP,
                                                NOM_CURP,
                                                NOM_FECPAG,
                                                NOM_FECINI,
                                                NOM_FECFIN,
                                                NOM_NUMSEG,
                                                NOM_DIAPAG,
                                                NOM_DEPTO,
                                                NOM_PUESTO,
                                                NOM_FORPAG,
                                                NOM_NUMERONOM,
                                                NOM_REGPAT,
                                                NOM_SALBASE,
                                                NOM_CVENOM,
                                                NOM_PER_TOTGRA,
                                                NOM_PER_TOTEXE,
                                                NOM_DED_TOTGRA,
                                                NOM_DED_TOTEXE,
                                                NOM_DESCRI,
                                                PBRUDE,
                                                IMPBRU,
                                                ASSIGNMENT_ID, 
                                                PAYROLL_ACTION_ID)
                                        VALUES (SYSDATE,
                                                DETAIL(rowIndex).RFCEMI,
                                                DETAIL(rowIndex).NOMEMI,
                                                DETAIL(rowIndex).CALEMI,
                                                DETAIL(rowIndex).COLEMI,
                                                DETAIL(rowIndex).MUNEMI,
                                                DETAIL(rowIndex).ESTEMI,
                                                DETAIL(rowIndex).CODEMI,
                                                DETAIL(rowIndex).PAIEMI,
                                                DETAIL(rowIndex).RFCREC,
                                                DETAIL(rowIndex).NOMREC,
                                                NVL(DETAIL(rowIndex).PAIREC, 'MEXICO'),
                                                TO_CHAR(DETAIL(rowIndex).SUBTBR, '9999990D99'),
                                                TO_CHAR(DETAIL(rowIndex).ISRRET, '9999990D99'),
                                                TO_CHAR(DETAIL(rowIndex).MONDET, '9999990D99'),
                                                TO_CHAR((DETAIL(rowIndex).SUBTBR - (DETAIL(rowIndex).ISRRET + DETAIL(rowIndex).MONDET)), '9999990D99'),
                                                DETAIL(rowIndex).NOM_NUMEMP,
                                                DETAIL(rowIndex).NOM_CURP,
                                                TO_CHAR(SYSDATE, 'YYYY-MM-DD'),
                                                TO_CHAR(DETAIL(rowIndex).NOM_FECINI, 'YYYY-MM-DD'),
                                                TO_CHAR(DETAIL(rowIndex).NOM_FECFIN, 'YYYY-MM-DD'),
                                                DETAIL(rowIndex).NOM_NUMSEG,
                                                DETAIL(rowIndex).NOM_DIAPAG,
                                                DETAIL(rowIndex).NOM_DEPTO,
                                                DETAIL(rowIndex).NOM_PUESTO,
                                                DETAIL(rowIndex).NOM_FORPAG,
                                                DETAIL(rowIndex).NOM_NUMERONOM,
                                                DETAIL(rowIndex).NOM_REGPAT,
                                                TO_CHAR(DETAIL(rowIndex).NOM_SALBASE, '9999990D99'),
                                                DETAIL(rowIndex).NOM_CVENOM,
                                                TO_CHAR(DETAIL(rowIndex).NOM_PER_TOTGRA, '9999990D99'),
                                                TO_CHAR(DETAIL(rowIndex).NOM_PER_TOTEXE, '9999990D99'),
                                                TO_CHAR(0, '9999990D99'),
                                                TO_CHAR((DETAIL(rowIndex).MONDET + DETAIL(rowIndex).ISRRET), '9999990D99'),
                                                DETAIL(rowIndex).NOM_DESCRI,
                                                TO_CHAR(DETAIL(rowIndex).SUBTBR, '9999990D99'),
                                                TO_CHAR(DETAIL(rowIndex).SUBTBR, '9999990D99'),
                                                DETAIL(rowIndex).ASSIGNMENT_ID, 
                                                DETAIL(rowIndex).PAYROLL_ACTION_ID);
                    
                    DECLARE 
                        
                        CURSOR  DETAIL_ASSIGNMENT_ACTION (P_ASSIGNMENT_ID       NUMBER,
                                                          P_PAYROLL_ACTION_ID   NUMBER) IS
                                 SELECT DISTINCT PAA.ASSIGNMENT_ACTION_ID
                                   FROM PAY_ASSIGNMENT_ACTIONS PAA
                                  WHERE 1 = 1
                                    AND PAA.ASSIGNMENT_ID = P_ASSIGNMENT_ID
                                    AND PAA.PAYROLL_ACTION_ID = P_PAYROLL_ACTION_ID; 
                        
                        CURSOR  DETAIL_PERCEPCION (P_ASSIGNMENT_ACTION_ID   NUMBER) IS
                                 SELECT NOM_PER_TIP,
                                        NOM_PER_CVE,
                                        NOM_PER_DESCRI,
                                        NOM_PER_IMPGRA,
                                        NOM_PER_IMPEXE    
                                   FROM(SELECT 
                                            NOM_PER_TIP,
                                            NOM_PER_CVE,
                                            NOM_PER_DESCRI,
                                            SUM(NOM_PER_IMPGRA) AS  NOM_PER_IMPGRA,
                                            SUM(NOM_PER_IMPEXE) AS  NOM_PER_IMPEXE 
                                          FROM (SELECT /*+ LEADING(PEC PIVF PETF)   index(PEC  PAY_ELEMENT_CLASSIFICATION_UK2)   index(PETF  PAY_ELEMENT_TYPES_F_FK1)     index(PIVF  PAY_INPUT_VALUES_F_UK2)   */
                                                    NVL((SELECT DISTINCT
                                                                DESCRIPTION
                                                           FROM FND_LOOKUP_VALUES
                                                          WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                             OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                            AND MEANING LIKE PETF.ELEMENT_NAME
                                                            AND LANGUAGE = 'ESA'), '016')       AS  NOM_PER_TIP,
                                                    NVL((SELECT DISTINCT
                                                                TAG
                                                           FROM FND_LOOKUP_VALUES
                                                          WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                             OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                            AND MEANING LIKE PETF.ELEMENT_NAME
                                                            AND LANGUAGE = 'ESA'), '000')      AS  NOM_PER_CVE,
                                                    (CASE 
                                                        WHEN PETF.ELEMENT_NAME = 'Profit Sharing' THEN
                                                            'REPARTO DE UTILIDADES'
                                                        WHEN PETF.ELEMENT_NAME LIKE 'P0%' THEN
                                                            REPLACE(SUBSTR(PETF.ELEMENT_NAME, 6, LENGTH(PETF.ELEMENT_NAME)), '_', ' ')
                                                        WHEN PETF.ELEMENT_NAME LIKE 'A0%' THEN
                                                            REPLACE(SUBSTR(PETF.ELEMENT_NAME, 6, LENGTH(PETF.ELEMENT_NAME)), '_', ' ')
                                                        ELSE
                                                            REPLACE(UPPER(PETF.ELEMENT_NAME), '_', ' ')
                                                     END)                                       AS  NOM_PER_DESCRI,
                                                    (CASE
                                                        WHEN PIVF.NAME = 'ISR Subject' THEN
                                                            SUM(PRRV.RESULT_VALUE)
                                                        ELSE 0
                                                     END)                                       AS  NOM_PER_IMPGRA,
                                                     (CASE
                                                        WHEN PIVF.NAME = 'ISR Exempt' THEN
                                                            SUM(PRRV.RESULT_VALUE)
                                                        ELSE 0
                                                     END)                                       AS  NOM_PER_IMPEXE
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
                                                   AND (PEC.CLASSIFICATION_NAME IN ('Earnings', 
                                                                                    'Supplemental Earnings', 
                                                                                    'Amends', 
                                                                                    'Imputed Earnings') 
                                                          OR PETF.ELEMENT_NAME  IN (SELECT MEANING
                                                                                      FROM FND_LOOKUP_VALUES 
                                                                                     WHERE LOOKUP_TYPE = 'XX_PERCEPCIONES_INFORMATIVAS'
                                                                                       AND LANGUAGE = USERENV('LANG')))
                                                   AND PETF.ELEMENT_NAME NOT IN (CASE 
                                                                                    WHEN P_CONSOLIDATION_ID = 65 THEN 'P091_FONDO AHORRO E ACUM'
                                                                                    ELSE 'TODOS'
                                                                                 END)
                                                   AND PIVF.UOM = 'M'
                                                   AND (PIVF.NAME = 'ISR Subject' OR PIVF.NAME = 'ISR Exempt')
                                                   AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                                                   AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE 
                                                 GROUP BY PETF.ELEMENT_NAME,
                                                          PETF.REPORTING_NAME,
                                                          PETF.ELEMENT_INFORMATION11,
                                                          PIVF.NAME
                                                UNION
                                                SELECT /*+ LEADING(PEC PIVF PETF)   index(PEC  PAY_ELEMENT_CLASSIFICATION_UK2)   index(PETF  PAY_ELEMENT_TYPES_F_FK1)     index(PIVF  PAY_INPUT_VALUES_F_UK2)   */
                                                    NVL((SELECT DISTINCT
                                                                DESCRIPTION
                                                           FROM FND_LOOKUP_VALUES
                                                          WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                             OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                            AND MEANING LIKE PETF.ELEMENT_NAME
                                                            AND LANGUAGE = 'ESA'), '016')       AS  NOM_PER_TIP,
                                                    NVL((SELECT DISTINCT
                                                                TAG
                                                           FROM FND_LOOKUP_VALUES
                                                          WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                             OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                            AND MEANING LIKE PETF.ELEMENT_NAME
                                                            AND LANGUAGE = 'ESA'), '000')      AS  NOM_PER_CVE,
                                                    (CASE
                                                        WHEN PETF.ELEMENT_NAME = 'Profit Sharing' THEN
                                                            'REPARTO DE UTILIDADES' 
                                                        WHEN PETF.ELEMENT_NAME LIKE 'P0%' THEN
                                                            REPLACE(SUBSTR(PETF.ELEMENT_NAME, 6, LENGTH(PETF.ELEMENT_NAME)), '_', ' ')
                                                        WHEN PETF.ELEMENT_NAME LIKE 'A0%' THEN
                                                            REPLACE(SUBSTR(PETF.ELEMENT_NAME, 6, LENGTH(PETF.ELEMENT_NAME)), '_', ' ')
                                                        ELSE
                                                            REPLACE(UPPER(PETF.ELEMENT_NAME), '_', ' ')
                                                     END)                                       AS  NOM_PER_DESCRI,
                                                     0                                          AS  NOM_PER_IMPGRA,
                                                     SUM(PRRV.RESULT_VALUE)                     AS  NOM_PER_IMPEXE
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
                                                   AND PETF.ELEMENT_NAME  IN ('FINAN_TRABAJO_RET',
                                                                              'P080_FONDO AHORRO TR ACUM',
                                                                              'P017_PRIMA DE ANTIGUEDAD',
                                                                              'P032_SUBSIDIO_PARA_EMPLEO',
                                                                              'P047_ISPT ANUAL A FAVOR',
                                                                              'P026_INDEMNIZACION')
                                                   AND PETF.ELEMENT_NAME NOT IN (CASE 
                                                                                    WHEN P_CONSOLIDATION_ID = 65 THEN 'P080_FONDO AHORRO TR ACUM'
                                                                                    ELSE 'TODOS'
                                                                                 END)
                                                   AND PIVF.UOM = 'M'
                                                   AND PIVF.NAME = 'Pay Value'
                                                   AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                                                   AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
                                                 GROUP BY PETF.ELEMENT_NAME,
                                                          PETF.REPORTING_NAME,
                                                          PETF.ELEMENT_INFORMATION11,
                                                          PIVF.NAME
                                               ) GROUP BY NOM_PER_TIP,
                                                          NOM_PER_CVE,
                                                          NOM_PER_DESCRI)
                                  WHERE 1 = 1
                                    AND (   NOM_PER_IMPGRA <> 0
                                         OR NOM_PER_IMPEXE <> 0)
                                  ORDER BY NOM_PER_CVE;
                                                                  
                        CURSOR  DETAIL_DEDUCCION (P_ASSIGNMENT_ACTION_ID NUMBER) IS
                                 SELECT NOM_DED_TIP,
                                        NOM_DED_CVE,
                                        NOM_DED_DESCRI,
                                        NOM_DED_IMPGRA,
                                        NOM_DED_IMPEXE
                                   FROM(SELECT /*+ LEADING(PEC PIVF PETF)   index(PEC  PAY_ELEMENT_CLASSIFICATION_UK2)   index(PETF  PAY_ELEMENT_TYPES_F_FK1)     index(PIVF  PAY_INPUT_VALUES_F_UK2)   */
                                                NVL((SELECT DISTINCT
                                                            DESCRIPTION
                                                       FROM FND_LOOKUP_VALUES
                                                      WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                         OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                        AND MEANING LIKE PETF.ELEMENT_NAME
                                                        AND LANGUAGE = 'ESA'), '004')       AS  NOM_DED_TIP,
                                                NVL((SELECT DISTINCT
                                                            TAG
                                                       FROM FND_LOOKUP_VALUES
                                                      WHERE (LOOKUP_TYPE = 'XXCALV_CFDI_SAT_EARNING_CODES'
                                                         OR  LOOKUP_TYPE = 'XXCALV_CFDI_SAT_DEDUCTION_CODE')
                                                        AND MEANING LIKE PETF.ELEMENT_NAME
                                                        AND LANGUAGE = 'ESA'), '000')      AS  NOM_DED_CVE,
                                               SUBSTR(PETF.ELEMENT_NAME,
                                                      6,
                                                      LENGTH(PETF.ELEMENT_NAME))AS  NOM_DED_DESCRI,
                                               0                                AS  NOM_DED_IMPGRA,
                                               PRRV.RESULT_VALUE                AS  NOM_DED_IMPEXE  
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
                                           AND (PEC.CLASSIFICATION_NAME IN ('Voluntary Deductions', 
                                                                            'Involuntary Deductions') 
                                                   OR PETF.ELEMENT_NAME IN (SELECT MEANING
                                                                              FROM FND_LOOKUP_VALUES 
                                                                             WHERE LOOKUP_TYPE = 'XX_DEDUCCIONES_INFORMATIVAS'
                                                                               AND LANGUAGE = USERENV('LANG')))
                                           AND PIVF.UOM = 'M'
                                           AND PIVF.NAME = 'Pay Value'
                                           AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
                                           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE)
                                   WHERE 1 = 1
                                     AND (   NOM_DED_IMPGRA <> 0
                                          OR NOM_DED_IMPEXE <> 0)
                                   ORDER BY NOM_DED_DESCRI;
                        
                        isPERCEP    BOOLEAN;
                        isDEDUC     BOOLEAN;
                            
                            
                    BEGIN
                        
                        isPERCEP := FALSE;
                        isDEDUC  := FALSE;
                        
                        FOR ASSIGN IN DETAIL_ASSIGNMENT_ACTION (DETAIL(rowIndex).ASSIGNMENT_ID, DETAIL(rowIndex).PAYROLL_ACTION_ID) LOOP       
                            FOR PERCEP IN DETAIL_PERCEPCION (ASSIGN.ASSIGNMENT_ACTION_ID) LOOP
                               
                                INSERT 
                                  INTO PAC_CFDI_EARNINGS_TB (ASSIGNMENT_ID, 
                                                             PAYROLL_ACTION_ID,
                                                             NOM_PER_TIP,
                                                             NOM_PER_CVE,
                                                             NOM_PER_DESCRI,
                                                             NOM_PER_IMPGRA,
                                                             NOM_PER_IMPEXE)
                                                     VALUES (DETAIL(rowIndex).ASSIGNMENT_ID, 
                                                             DETAIL(rowIndex).PAYROLL_ACTION_ID,
                                                             PERCEP.NOM_PER_TIP,
                                                             PERCEP.NOM_PER_CVE,
                                                             REPLACE(PERCEP.NOM_PER_DESCRI, '_', ' '),
                                                             TO_CHAR(PERCEP.NOM_PER_IMPGRA, '9999990D99'),
                                                             TO_CHAR(PERCEP.NOM_PER_IMPEXE, '9999990D99'));
                                
                            END LOOP;
                        END LOOP;
                                                         
                            
                        FOR ASSIGN IN DETAIL_ASSIGNMENT_ACTION (DETAIL(rowIndex).ASSIGNMENT_ID, DETAIL(rowIndex).PAYROLL_ACTION_ID) LOOP                            
                            FOR DEDUC IN DETAIL_DEDUCCION (ASSIGN.ASSIGNMENT_ACTION_ID) LOOP
                                
                                INSERT
                                  INTO PAC_CFDI_DEDUCTIONS_TB (ASSIGNMENT_ID, 
                                                               PAYROLL_ACTION_ID,
                                                               NOM_DED_TIP,
                                                               NOM_DED_CVE,
                                                               NOM_DED_DESCRI,
                                                               NOM_DED_IMPGRA,
                                                               NOM_DED_IMPEXE)
                                                       VALUES (DETAIL(rowIndex).ASSIGNMENT_ID,
                                                               DETAIL(rowIndex).PAYROLL_ACTION_ID,
                                                               DEDUC.NOM_DED_TIP,
                                                               DEDUC.NOM_DED_CVE,
                                                               REPLACE(DEDUC.NOM_DED_DESCRI, '_', ' '),
                                                               TO_CHAR(DEDUC.NOM_DED_IMPGRA, '9999990D99'),
                                                               TO_CHAR(DEDUC.NOM_DED_IMPEXE, '9999990D99'));
                                    
                            END LOOP;
                        END LOOP;                       
                                    
                                                       
                    END;
                
                END LOOP;
                    
            END LOOP;
                
            CLOSE DETAIL_LIST;
                        
        END;
           
        COMMIT;
        
    END REPORT_CFDI_NOMINA;
    
    FUNCTION  TEST_CONNECTION(
        P_DIRECTORY             VARCHAR2)
      RETURN VARCHAR2
    AS LANGUAGE JAVA NAME 'PAC_CFDI_TIMBRADO.test_connection(java.lang.String) return java.lang.String'; 
    
    FUNCTION  FIND_FILE(
        P_DIRECTORY             VARCHAR2, 
        P_SUB_DIRECTORY         VARCHAR2, 
        P_FILE_NAME             VARCHAR2)
      RETURN BOOLEAN
    AS LANGUAGE JAVA NAME 'PAC_CFDI_TIMBRADO.find_file(java.lang.String, java.lang.String, java.lang.String) return java.lang.Boolean'; 
    
    FUNCTION  IS_WORKING(
        P_DIRECTORY             VARCHAR2)
      RETURN BOOLEAN
    AS LANGUAGE JAVA NAME 'PAC_CFDI_TIMBRADO.is_working(java.lang.String) return java.lang.Boolean';
    
    FUNCTION GET_OUTPUT_FILES(
        P_DIRECTORY             VARCHAR2,
        P_SUB_DIRECTORY         VARCHAR2)
      RETURN PAC_CFDI_OUTPUT_FILES
    AS LANGUAGE JAVA NAME 'PAC_CFDI_TIMBRADO.get_output_files(java.lang.String, java.lang.String) return oracle.sql.ARRAY';
      
    FUNCTION GET_ERROR_FILES(
        P_DIRECTORY             VARCHAR2,
        P_SUB_DIRECTORY         VARCHAR2)
      RETURN PAC_CFDI_ERROR_FILES
    AS LANGUAGE JAVA NAME 'PAC_CFDI_TIMBRADO.get_error_files(java.lang.String, java.lang.String) return oracle.sql.ARRAY';
    
    FUNCTION IS_DOWNLOADING(
        P_DIRECTORY             VARCHAR2,
        P_RECORDS               NUMBER)
      RETURN BOOLEAN
    AS LANGUAGE JAVA NAME 'PAC_CFDI_TIMBRADO.is_downloading(java.lang.String, java.lang.Integer) return java.lang.Boolean';
    
    PROCEDURE TIMBRADO_CFDI_NOMINA(   
        P_ERRBUF    OUT NOCOPY  VARCHAR2,
        P_RETCODE   OUT NOCOPY  VARCHAR2,
        P_FILE_NAME             VARCHAR2,
        P_DIRECTORY_NAME        VARCHAR2)
    AS
        var_test_connection     VARCHAR2(100);
        var_file_name           VARCHAR2(200) := REPLACE(P_FILE_NAME, '.txt', '');
        var_sub_directory_name  VARCHAR2(100) := TO_CHAR(TO_DATE(SYSDATE, 'DD/MM/RRRR'), 'RRRRMMDD');
        var_errors              NUMBER;
        
        OUTPUT_FILES            PAC_CFDI_OUTPUT_FILES;
        ERROR_FILES             PAC_CFDI_ERROR_FILES;
    BEGIN
        
        SELECT TEST_CONNECTION(P_DIRECTORY_NAME)
          INTO var_test_connection
          FROM DUAL;
          
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, var_test_connection);
        CFDI_LOGGING(P_FILE_NAME, 'START SEARCH TXT FILE');
        
        LOOP
            
            CFDI_LOGGING(P_FILE_NAME, 'WAITING 60 SECONDS');
            DBMS_LOCK.SLEEP(60);
        
            EXIT WHEN FIND_FILE(P_DIRECTORY_NAME, var_sub_directory_name, var_file_name || '.txt') = TRUE;
            
        END LOOP;
        
        CFDI_LOGGING(P_FILE_NAME, 'FINISHED SEARCH TXT FILE');
        
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, var_file_name || '.txt Found!.');
        
        CFDI_LOGGING(P_FILE_NAME, 'START SEARCH XML FILE');
        
        LOOP 
        
            CFDI_LOGGING(P_FILE_NAME, 'WAITING 60 SECONDS');
            DBMS_LOCK.SLEEP(60);
        
            EXIT WHEN FIND_FILE(P_DIRECTORY_NAME, var_sub_directory_name, var_file_name || '.xml') = TRUE;
            
        END LOOP;
        
        CFDI_LOGGING(P_FILE_NAME, 'FINISHED SEARCH XML FILE');
        
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, var_file_name || '.xml Found!.');
        
        CFDI_LOGGING(P_FILE_NAME, 'START WAIT WORKING');
        
        LOOP
        
            CFDI_LOGGING(P_FILE_NAME, 'WAITING 60 SECONDS');
            DBMS_LOCK.SLEEP(60);
        
            EXIT WHEN IS_WORKING(P_DIRECTORY_NAME) = FALSE;
            
        END LOOP;
        
        CFDI_LOGGING(P_FILE_NAME, 'FINISHED WAIT WORKING');
        
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Recuperando archivos del servidor...');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
        
        OUTPUT_FILES := GET_OUTPUT_FILES(P_DIRECTORY_NAME, var_sub_directory_name);
        CFDI_LOGGING(P_FILE_NAME, 'GET OUTPUT FILES : ' || TO_CHAR(OUTPUT_FILES.COUNT-2) || ' OUTPUT FILES');
        
        ERROR_FILES := GET_ERROR_FILES(P_DIRECTORY_NAME, var_sub_directory_name);
        CFDI_LOGGING(P_FILE_NAME, 'GET ERROR FILES : ' || TO_CHAR(ERROR_FILES.COUNT) || ' ERROR FILES');
        
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OUTPUT_FILES.COUNT-2 || ' Archivos finalizados satisfactoriamente.');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
        
        CFDI_LOGGING(P_FILE_NAME, 'START GET OUTPUT FILES');
        
        FOR var_index IN 1..OUTPUT_FILES.COUNT LOOP
            DECLARE
                var_employee_number     VARCHAR2(10) := '';
                var_file_name           VARCHAR2(100) := '';
                var_employee_name       VARCHAR2(500) := '';
            BEGIN
                var_file_name := OUTPUT_FILES(var_index);
                var_employee_number := SUBSTR(var_file_name,0,INSTR(var_file_name, '_')-1);
                
                BEGIN
                    SELECT DISTINCT
                           PPF.FULL_NAME
                      INTO var_employee_name
                      FROM PER_PEOPLE_F     PPF
                     WHERE 1 = 1
                       AND PPF.EMPLOYEE_NUMBER = var_employee_number
                       AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE;
                EXCEPTION 
                    WHEN OTHERS THEN NULL;
                END;
                
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, var_file_name || ' ' || var_employee_name);
                
                DBMS_LOCK.SLEEP(1);
                CFDI_LOGGING(P_FILE_NAME, var_file_name || ' ' || var_employee_name);                    
                
            END;
        END LOOP;
        
        CFDI_LOGGING(P_FILE_NAME, 'FINISHED GET OUTPUT FILES');
        
        var_errors := ERROR_FILES.COUNT;
        
        CFDI_LOGGING(P_FILE_NAME, 'START GET ERROR FILES');
        
        FOR var_index IN 1..ERROR_FILES.COUNT LOOP
            DECLARE
                var_file_name           VARCHAR2(100) := '';
            BEGIN
                var_file_name := ERROR_FILES(var_index);
                
                IF var_file_name IN ('Productos_Avicolas', 'Calvario_Servicios', 'aspnet_client', 'Adriana_Pocovi') THEN
                    var_errors := var_errors - 1;                
                END IF;
            END;
        END LOOP;
        
        IF    var_errors > 0 THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, var_errors || ' Archivos finalizados con error.');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
            
            FOR var_index IN 1..ERROR_FILES.COUNT LOOP
                DECLARE
                    var_employee_number     VARCHAR2(10) := '';
                    var_file_name           VARCHAR2(100) := '';
                    var_employee_name       VARCHAR2(500) := '';
                BEGIN
                    var_file_name := ERROR_FILES(var_index);
                    
                    IF var_file_name NOT IN ('Productos_Avicolas', 'Calvario_Servicios', 'aspnet_client', 'Adriana_Pocovi') THEN
                        var_employee_number := SUBSTR(var_file_name,0,INSTR(var_file_name, '_')-1);
                    
                        BEGIN
                            SELECT DISTINCT
                                   PPF.FULL_NAME
                              INTO var_employee_name
                              FROM PER_PEOPLE_F     PPF
                             WHERE 1 = 1
                               AND PPF.EMPLOYEE_NUMBER = var_employee_number
                               AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE;
                        EXCEPTION 
                            WHEN OTHERS THEN NULL;
                        END;
                        
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, var_file_name || ' ' || var_employee_name);
                        
                        DBMS_LOCK.SLEEP(1);
                        CFDI_LOGGING(P_FILE_NAME, var_file_name || ' ' || var_employee_name);
                        
                    END IF;
                END;
            END LOOP;
            
            
            
            P_RETCODE := 1;
        ELSIF var_errors = 0 THEN
            P_RETCODE := 0;
        END IF;
        
        CFDI_LOGGING(P_FILE_NAME, 'FINISHED GET ERROR FILES');
    
    END TIMBRADO_CFDI_NOMINA;  
    
    FUNCTION GET_PAYMENT_METHOD(
        P_ASSIGNMENT_ID         NUMBER)
      RETURN VARCHAR2
    IS
        var_payment_method      VARCHAR2(500);
    BEGIN
    
        SELECT POPM.ORG_PAYMENT_METHOD_NAME
          INTO var_payment_method
          FROM PAY_PERSONAL_PAYMENT_METHODS_F   PPPM,
               PAY_ORG_PAYMENT_METHODS_F        POPM
         WHERE 1 = 1
           AND SYSDATE BETWEEN PPPM.EFFECTIVE_START_DATE 
                           AND PPPM.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN POPM.EFFECTIVE_START_DATE
                           AND POPM.EFFECTIVE_END_DATE
           AND POPM.ORG_PAYMENT_METHOD_ID = PPPM.ORG_PAYMENT_METHOD_ID
           AND PPPM.ASSIGNMENT_ID = P_ASSIGNMENT_ID  
           AND ORG_PAYMENT_METHOD_NAME NOT LIKE '%PENSIONES%'
           AND ORG_PAYMENT_METHOD_NAME NOT LIKE '%DESPENSA%'
           AND ORG_PAYMENT_METHOD_NAME NOT LIKE '%EFECTIVALE%'
           AND ORG_PAYMENT_METHOD_NAME NOT LIKE '%CHEQUE%';
        
        RETURN var_payment_method;
    END GET_PAYMENT_METHOD;
    
    FUNCTION GET_UUID(
        P_EMPLOYEE_NUMBER           NUMBER,
        P_START_DATE                DATE,
        P_END_DATE                  DATE,
        P_CONSOLIDATION_SET_NAME    VARCHAR2)
      RETURN VARCHAR2
    IS
        var_uuid        VARCHAR2(500);
    BEGIN
    
        DBMS_OUTPUT.PUT_LINE( P_EMPLOYEE_NUMBER || ':' || to_char(P_START_DATE)      || ':' || to_char(P_END_DATE)        || ':' || P_CONSOLIDATION_SET_NAME);
    
        SELECT UNIQUE
               UUID.UUID
          INTO var_uuid
          FROM XXCALV_UUID_NOM     UUID 
         WHERE 1 = 1 
           AND UUID.NUMEMPLOYEE = P_EMPLOYEE_NUMBER 
           AND REPLACE(UUID.PERIOD, ' ', '') = (CASE 
                                                    WHEN P_CONSOLIDATION_SET_NAME LIKE 'NORMAL' THEN
                                                         TO_CHAR(TO_DATE(P_START_DATE, 'DD/MM/RRRR'), 'DD-MON-RR') || TO_CHAR(TO_DATE(P_END_DATE,'DD/MM/RRRR'), 'DD-MON-RR')
                                                    ELSE 
                                                         TO_CHAR(TO_DATE(P_END_DATE, 'DD/MM/RRRR'), 'DD-MON-RR') || TO_CHAR(TO_DATE(P_END_DATE,'DD/MM/RRRR'), 'DD-MON-RR')
                                                END)
           AND UUID.JUEGO_CONSOLIDACION = (CASE
                                               WHEN P_CONSOLIDATION_SET_NAME LIKE 'GRATIFICACIÓN' THEN
                                                    'GRATIFICACIÓN'
                                               WHEN P_CONSOLIDATION_SET_NAME LIKE 'PTU' THEN
                                                    'PTU'
                                               WHEN P_CONSOLIDATION_SET_NAME LIKE 'FONDO DE AHORRO' THEN 
                                                    'FONDO DE AHORRO'
                                               WHEN P_CONSOLIDATION_SET_NAME LIKE '%ORDINARIA%' THEN 
                                                    'PAGO DE NOMINA'
                                               ELSE
                                                    UPPER(REPLACE(P_CONSOLIDATION_SET_NAME, '_', ' '))
                                            END);
    
        RETURN var_uuid;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN ' ';
        WHEN TOO_MANY_ROWS THEN
            RETURN ' ';
    END GET_UUID;
    
    FUNCTION GET_SUBSIDIO_EMPLEO(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER
    IS
        var_result      NUMBER;
    BEGIN
    
        SELECT SUM(PRRV.RESULT_VALUE) 
          INTO var_result                    
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
           AND PETF.ELEMENT_NAME  IN ('I055 ART 8VO TABLA')
           AND PIVF.UOM = 'M'
           AND PIVF.NAME = 'Pay Value'
           AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE;           
        
        RETURN var_result;
    END GET_SUBSIDIO_EMPLEO;

    FUNCTION GET_EFFECTIVE_START_DATE(
             P_PERSON_ID      NUMBER)
      RETURN DATE
      IS
            var_effective_start_date    DATE;
    BEGIN
          
        SELECT NVL(PPOS.ADJUSTED_SVC_DATE, PPF.ORIGINAL_DATE_OF_HIRE)
          INTO var_effective_start_date
          FROM PER_PEOPLE_F             PPF,
               PER_PERIODS_OF_SERVICE   PPOS    
         WHERE 1 = 1 
           AND PPF.PERSON_ID = P_PERSON_ID
           AND PPF.PERSON_ID = PPOS.PERSON_ID
           AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
           AND PPOS.ACTUAL_TERMINATION_DATE IS NULL;
          
          
        RETURN var_effective_start_date;
    EXCEPTION    
        WHEN NO_DATA_FOUND THEN
            BEGIN
                    
                SELECT EFFECTIVE_DATE
                  INTO var_effective_start_date
                  FROM (SELECT NVL(PPOS.ADJUSTED_SVC_DATE, PPF.ORIGINAL_DATE_OF_HIRE) AS EFFECTIVE_DATE
                          FROM PER_PEOPLE_F             PPF,
                               PER_PERIODS_OF_SERVICE   PPOS    
                         WHERE 1 = 1 
                           AND PPF.PERSON_ID = P_PERSON_ID
                           AND PPF.PERSON_ID = PPOS.PERSON_ID
                           AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
                           AND PPOS.ACTUAL_TERMINATION_DATE IS NOT NULL
                         ORDER BY PPOS.ACTUAL_TERMINATION_DATE DESC ) 
                 WHERE 1 = 1
                   AND ROWNUM = 1;
                           
                RETURN var_effective_start_date;
            EXCEPTION
                WHEN OTHERS THEN
                dbms_output.put_line('**Error en la funcion GET_EFFECTIVE_START_DATET. (' || P_PERSON_ID || ')' || SQLERRM);
                FND_FILE.put_line(FND_FILE.LOG, '**Error en la funcion GET_EFFECTIVE_START_DATE. (' || P_PERSON_ID || ')' || SQLERRM);
                        
                RETURN NULL;
            END;
        WHEN OTHERS THEN
            dbms_output.put_line('**Error en la funcion GET_EFFECTIVE_START_DATET. (' || P_PERSON_ID || ')' || SQLERRM);
            FND_FILE.put_line(FND_FILE.LOG, '**Error en la funcion GET_EFFECTIVE_START_DATE. (' || P_PERSON_ID || ')' || SQLERRM);
                    
            RETURN NULL;
    END GET_EFFECTIVE_START_DATE;
      
    FUNCTION GET_NOM_HEX_DIAS(
        P_ASSIGNMENT_ACTION_ID    NUMBER,
        P_INPUT_VALUE_NAME        VARCHAR2)
      RETURN NUMBER
    IS
        var_result      NUMBER;
    BEGIN
        
        SELECT SUM(PRRV.RESULT_VALUE)
          INTO var_result
          FROM PAY_RUN_RESULTS              PRR,
               PAY_ELEMENT_TYPES_F          PETF,
               PAY_RUN_RESULT_VALUES        PRRV,
               PAY_INPUT_VALUES_F           PIVF,
               PAY_ELEMENT_CLASSIFICATIONS  PEC
         WHERE 1 = 1
           AND PRR.ASSIGNMENT_ACTION_ID = P_ASSIGNMENT_ACTION_ID
           AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
           AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
           AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
           AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
           AND PETF.ELEMENT_NAME = 'P002_HORAS EXTRAS'
           AND PIVF.NAME = P_INPUT_VALUE_NAME
           AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE;   
    
        RETURN var_result;
    END GET_NOM_HEX_DIAS;
    
    FUNCTION GET_NOM_PER_TOTPAG(
        P_ASSIGNMENT_ACTION_ID    NUMBER)
      RETURN NUMBER
    IS
        var_result  NUMBER;
    BEGIN
    
        SELECT SUM(PRRV.RESULT_VALUE)
          INTO var_result
          FROM PAY_RUN_RESULTS              PRR,
               PAY_ELEMENT_TYPES_F          PETF,
               PAY_RUN_RESULT_VALUES        PRRV,
               PAY_INPUT_VALUES_F           PIVF,
               PAY_ELEMENT_CLASSIFICATIONS  PEC
         WHERE 1 = 1
           AND PRR.ASSIGNMENT_ACTION_ID = P_ASSIGNMENT_ACTION_ID
           AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
           AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
           AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
           AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
           AND PETF.ELEMENT_NAME = 'P026_INDEMNIZACION'
           AND PIVF.NAME = 'Pay Value'
           AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE;   
    
        RETURN var_result;
    END GET_NOM_PER_TOTPAG;
    
    FUNCTION GET_PROPOSED_SALARY(
        P_ASSIGNMENT_ID           NUMBER)
      RETURN NUMBER
    IS
        var_result  NUMBER;
    BEGIN
    
        SELECT PPP.PROPOSED_SALARY_N
          INTO var_result
          FROM PER_PAY_PROPOSALS    PPP
         WHERE 1 = 1
           AND PPP.ASSIGNMENT_ID = P_ASSIGNMENT_ID
           AND SYSDATE BETWEEN PPP.CHANGE_DATE AND PPP.DATE_TO
           AND PPP.APPROVED = 'Y';
        
        RETURN var_result;
    END GET_PROPOSED_SALARY;
    
    PROCEDURE DELETE_UUID_CANCELED(
        P_ERRBUF    OUT NOCOPY  VARCHAR2,
        P_RETCODE   OUT NOCOPY  VARCHAR2,
        P_UUID      VARCHAR2)
    IS
    
        CURSOR  C_UUID
        IS
        SELECT UUID.XML_ID,
               UUID.COMPANY,
               UUID.DATE_UUID,
               UUID.UUID,
               UUID.NUMEMPLOYEE,
               UUID.BENEFICIARY,
               UUID.PERIOD,
               UUID.JUEGO_CONSOLIDACION,
               UUID.METODO_PAGO,
               UUID.FILE_NAME,
               UUID.CREATION_DATE
          FROM XXCALV_UUID_NOM UUID
         WHERE 1 = 1 
           AND UUID.UUID = UPPER(P_UUID);
    
    BEGIN
    
        P_RETCODE := 0;
        
        FOR UUID IN C_UUID 
        LOOP
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'XML ID : ' || UUID.XML_ID);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'COMPAÑIA : '|| UUID.COMPANY);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'FECHA UUID : ' || TO_CHAR(UUID.DATE_UUID));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'UUID : ' || UUID.UUID);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'NUMERO EMPLEADO : ' || UUID.NUMEMPLOYEE);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'NOMBRE EMPLEADO : ' || UUID.BENEFICIARY);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'PERIODO : ' || UUID.PERIOD); 
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'JUEGO DE CONSOLIDACION : ' || UUID.JUEGO_CONSOLIDACION);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'METODO DE PAGO : ' || UUID.METODO_PAGO);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'NOMBRE DE ARCHIVO : ' || UUID.FILE_NAME);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'FECHA DE IMPORTACION : ' || TO_CHAR(UUID.CREATION_DATE));
            
            DELETE FROM XXCALV_UUID_NOM
             WHERE 1 = 1
               AND UUID = UPPER(P_UUID);
            
            COMMIT;
            P_RETCODE := 1;
            
        END LOOP;
          
    END DELETE_UUID_CANCELED;
    
    
    FUNCTION  GET_INFORMATION_VALUE(
        P_ASSIGNMENT_ACTION_ID  NUMBER,
        P_ELEMENT_NAME          VARCHAR2,
        P_INPUT_VALUE_NAME      VARCHAR2)
        RETURN VARCHAR2
    IS
        result_value      VARCHAR2(100);
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
           AND PETF.ELEMENT_NAME = P_ELEMENT_NAME
           AND PIVF.NAME = P_INPUT_VALUE_NAME;
        
        RETURN result_value;
    END GET_INFORMATION_VALUE;
    
    FUNCTION GET_INFORMATION_DISABILITY(
        P_PERSON_ID             NUMBER,
        P_START_DATE            DATE,
        P_END_DATE              DATE)
        RETURN VARCHAR2
    IS
        var_result_value    VARCHAR2(100);
    BEGIN
    
        
        SELECT DISTINCT CATEGORY
          INTO var_result_value
          FROM PER_DISABILITIES_F   PDF
         WHERE 1 = 1
           AND PDF.PERSON_ID = P_PERSON_ID
           AND (   P_START_DATE 
                    BETWEEN PDF.REGISTRATION_DATE
                        AND PDF.REGISTRATION_EXP_DATE
                OR P_END_DATE 
                    BETWEEN PDF.REGISTRATION_DATE
                        AND PDF.REGISTRATION_EXP_DATE
                OR PDF.REGISTRATION_DATE 
                    BETWEEN P_START_DATE
                        AND P_END_DATE
                OR PDF.REGISTRATION_EXP_DATE
                    BETWEEN P_START_DATE
                        AND P_END_DATE);
        
    
        RETURN var_result_value;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'GRAL';
    END GET_INFORMATION_DISABILITY;
    
END PAC_CFDI_FUNCTIONS_PKG;