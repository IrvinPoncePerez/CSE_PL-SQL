CREATE OR REPLACE PACKAGE BODY ATET_SAVINGS_BANK_PKG IS


    FUNCTION    GET_SAVING_BANK_ID
      RETURN    NUMBER
    IS
        var_saving_bank_id      NUMBER;
    BEGIN
        
        SELECT SB.SAVING_BANK_ID
          INTO var_saving_bank_id
          FROM ATET_SAVINGS_BANK SB
         WHERE 1 = 1 
           AND SB.SAVING_BANK_STATUS = 'OPEN';
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_SAVING_BANK_ID() RETURN ' || var_saving_bank_id); 

        RETURN var_saving_bank_id;
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_SAVING_BANK_ID ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_SAVING_BANK_ID;
    
    
    FUNCTION    GET_SAVING_BANK_YEAR
      RETURN    NUMBER
    IS
        var_saving_bank_year    NUMBER;
    BEGIN
    
        SELECT ASB.YEAR
          INTO var_saving_bank_year
          FROM ATET_SAVINGS_BANK    ASB
         WHERE 1 = 1
           AND ASB.SAVING_BANK_ID = GET_SAVING_BANK_ID;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_SAVING_BANK_YEAR() RETURN ' || var_saving_bank_year); 
           
        RETURN var_saving_bank_year;
        
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_SAVING_BANK_YEAR ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_SAVING_BANK_YEAR;
    
    
    FUNCTION    GET_AVAILABLE_PERIODS(P_MEMBER_ID   NUMBER)
      RETURN    NUMBER
    IS
        var_count_periods   NUMBER;
        var_extemp_loans    VARCHAR2(50);
    BEGIN
    
        var_extemp_loans := NVL(GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'EXTEMP_LOANS'), 'N');
    
        IF var_extemp_loans = 'N' THEN 
            SELECT COUNT(D.PERIOD_NAME)
            --       D.PERIOD_NAME,
            --       D.TIME_PERIOD_ID,
            --       D.ASSIGNMENT_ID,
            --       D.PAYROLL_ID,
            --       D.END_DATE,
            --       PPA.TIME_PERIOD_ID,
            --       PAA.RUN_TYPE_ID
              INTO var_count_periods
              FROM (SELECT PTP.PERIOD_NAME,
                           PTP.TIME_PERIOD_ID,
                           PAF.ASSIGNMENT_ID,
                           PAF.PAYROLL_ID,
                           PTP.START_DATE,
                           PTP.END_DATE,
                           PAF.EFFECTIVE_START_DATE,
                           PAF.EFFECTIVE_END_DATE
                      FROM ATET_SB_MEMBERS          ASM,
                           ATET_SAVINGS_BANK        ASB,
                           PER_ASSIGNMENTS_F        PAF,
                           PER_TIME_PERIODS         PTP
                     WHERE 1 = 1
                       AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
                       AND ASM.PERSON_ID = PAF.PERSON_ID
                       AND ASM.SAVING_BANK_ID = ASB.SAVING_BANK_ID
                       AND ASM.MEMBER_ID = P_MEMBER_ID
                       AND PTP.PAYROLL_ID = PAF.PAYROLL_ID    
                       AND EXTRACT(YEAR FROM PTP.END_DATE) = ASB.YEAR
                       AND PTP.END_DATE BETWEEN SYSDATE AND ASB.TERMINATION_DATE) D
               LEFT JOIN PAY_PAYROLL_ACTIONS          PPA
                 ON PPA.PAYROLL_ID = D.PAYROLL_ID
                AND PPA.TIME_PERIOD_ID = D.TIME_PERIOD_ID
                AND PPA.EFFECTIVE_DATE BETWEEN D.START_DATE AND D.END_DATE
                AND PPA.EFFECTIVE_DATE BETWEEN D.EFFECTIVE_START_DATE AND D.EFFECTIVE_END_DATE
               LEFT JOIN PAY_ASSIGNMENT_ACTIONS       PAA
                 ON PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
                AND PAA.ASSIGNMENT_ID = D.ASSIGNMENT_ID
                AND PAA.RUN_TYPE_ID IS NOT NULL 
              WHERE 1 = 1 
                AND PPA.TIME_PERIOD_ID IS NULL
              ORDER BY D.TIME_PERIOD_ID;
        ELSE 
            SELECT COUNT(D.PERIOD_NAME)
            --       D.PERIOD_NAME,
            --       D.TIME_PERIOD_ID,
            --       D.ASSIGNMENT_ID,
            --       D.PAYROLL_ID,
            --       D.END_DATE,
            --       PPA.TIME_PERIOD_ID,
            --       PAA.RUN_TYPE_ID
              INTO var_count_periods
              FROM (SELECT PTP.PERIOD_NAME,
                           PTP.TIME_PERIOD_ID,
                           PAF.ASSIGNMENT_ID,
                           PAF.PAYROLL_ID,
                           PTP.START_DATE,
                           PTP.END_DATE,
                           PAF.EFFECTIVE_START_DATE,
                           PAF.EFFECTIVE_END_DATE
                      FROM ATET_SB_MEMBERS          ASM,
                           ATET_SAVINGS_BANK        ASB,
                           PER_ASSIGNMENTS_F        PAF,
                           PER_TIME_PERIODS         PTP
                     WHERE 1 = 1
                       AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
                       AND ASM.PERSON_ID = PAF.PERSON_ID
                       AND ASM.SAVING_BANK_ID = ASB.SAVING_BANK_ID
                       AND ASM.MEMBER_ID = P_MEMBER_ID
                       AND PTP.PAYROLL_ID = PAF.PAYROLL_ID    
                       AND EXTRACT(YEAR FROM PTP.END_DATE) = ASB.YEAR
--                       AND PTP.END_DATE BETWEEN SYSDATE AND ASB.TERMINATION_DATE
                       ) D
               LEFT JOIN PAY_PAYROLL_ACTIONS          PPA
                 ON PPA.PAYROLL_ID = D.PAYROLL_ID
                AND PPA.TIME_PERIOD_ID = D.TIME_PERIOD_ID
                AND PPA.EFFECTIVE_DATE BETWEEN D.START_DATE AND D.END_DATE
                AND PPA.EFFECTIVE_DATE BETWEEN D.EFFECTIVE_START_DATE AND D.EFFECTIVE_END_DATE
               LEFT JOIN PAY_ASSIGNMENT_ACTIONS       PAA
                 ON PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
                AND PAA.ASSIGNMENT_ID = D.ASSIGNMENT_ID
                AND PAA.RUN_TYPE_ID IS NOT NULL 
              WHERE 1 = 1 
                AND PPA.TIME_PERIOD_ID IS NULL
              ORDER BY D.TIME_PERIOD_ID;
        END IF;

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_AVAILABLE_PERIODS(P_MEMBER_ID => ' || P_MEMBER_ID || 
                                                              ') RETURN ' || var_count_periods); 
           
        RETURN var_count_periods; 
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_AVAILABLE_PERIODS ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_AVAILABLE_PERIODS;
    
    
    FUNCTION    GET_PERIOD_TYPE(P_PERSON_ID             NUMBER)
      RETURN    VARCHAR2
    IS
        var_period_type     VARCHAR2(100);
    BEGIN
        
        SELECT PPF.PERIOD_TYPE
          INTO var_period_type
          FROM PER_ASSIGNMENTS_F    PAF,
               PAY_PAYROLLS_F       PPF
         WHERE 1 = 1
           AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
           AND PAF.PERSON_ID = P_PERSON_ID
           AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_PERIOD_TYPE(P_PERSON_ID => ' || P_PERSON_ID || 
                                                        ') RETURN ' || var_period_type); 
        
        RETURN var_period_type;    
    
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_PERIOD_TYPE ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_PERIOD_TYPE;
    
      
    FUNCTION    GET_REGISTRATION_DATE
      RETURN    DATE
    IS
        var_registration_date   DATE;
    BEGIN
        
        SELECT SB.REGISTRATION_DATE
          INTO var_registration_date
          FROM ATET_SAVINGS_BANK    SB
         WHERE 1 = 1
           AND SB.SAVING_BANK_ID = GET_SAVING_BANK_ID;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_REGISTRATION_DATE() RETURN ' || var_registration_date); 
           
        RETURN var_registration_date;
    
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_REGISTRATION_DATE ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_REGISTRATION_DATE;
    
    
    FUNCTION    GET_PARAMETER_VALUE(P_SAVING_BANK_ID          NUMBER,
                                    P_PARAMETER_CODE          VARCHAR2)
      RETURN    VARCHAR2
    IS
        var_parameter_value     VARCHAR2(100);
    BEGIN
    
        SELECT ASP.PARAMETER_VALUE
          INTO var_parameter_value
          FROM ATET_SB_PARAMETERS   ASP
         WHERE 1 = 1    
           AND ASP.SAVING_BANK_ID = P_SAVING_BANK_ID
           AND ASP.PARAMETER_CODE = P_PARAMETER_CODE 
           AND (   ASP.EFFECTIVE_END_DATE IS NULL
                OR SYSDATE BETWEEN ASP.EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE);
                
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_PARAMETER_VALUE(P_SAVING_BANK_ID => ' || P_SAVING_BANK_ID ||
                                                           ',P_PARAMETER_CODE => ' || P_PARAMETER_CODE ||
                                                           ') RETURN ' || var_parameter_value); 
                
        RETURN var_parameter_value;
    
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_PARAMETER_VALUE ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_PARAMETER_VALUE;
    
    
    FUNCTION    IF_MEMBER_EXIST(P_EMPLOYEE_NUMBER      NUMBER)
      RETURN    NUMBER
    IS
        var_result  NUMBER;
    BEGIN
        
        SELECT COUNT(ASM.PERSON_ID)
          INTO var_result
          FROM ATET_SB_MEMBERS ASM
         WHERE 1 = 1
           AND ASM.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
           AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'IF_MEMBER_EXIST(P_EMPLOYEE_NUMBER => ' || P_EMPLOYEE_NUMBER ||
                                                       ') RETURN ' || var_result); 
    
        RETURN var_result;
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en IF_MEMBER_EXIST ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END IF_MEMBER_EXIST;
    
    
    FUNCTION GET_MAX_ASSIGNMENT_ACTION_ID(P_ASSIGNMENT_ID        NUMBER,
                                          P_PAYROLL_ID           NUMBER)
        RETURN NUMBER                                                        
    IS
              
        var_assignment_action_id    NUMBER;
              
    BEGIN
              
        SELECT MAX(PAA.ASSIGNMENT_ACTION_ID)
          INTO var_assignment_action_id
          FROM PAY_ASSIGNMENT_ACTIONS       PAA,
               PAY_PAYROLL_ACTIONS          PPA,
               PER_TIME_PERIODS             PTP,
               PAY_RUN_TYPES_F              PRT,
               PAY_CONSOLIDATION_SETS       PCS
         WHERE 1 = 1
           AND PAA.ASSIGNMENT_ID = P_ASSIGNMENT_ID
           AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
           AND PPA.PAYROLL_ID = P_PAYROLL_ID
           AND PPA.ACTION_TYPE IN ('Q', 'R')
           AND PPA.TIME_PERIOD_ID = PTP.TIME_PERIOD_ID
           AND PAA.RUN_TYPE_ID = PRT.RUN_TYPE_ID
           AND PRT.RUN_TYPE_NAME IN ('Standard') 
           AND PPA.CONSOLIDATION_SET_ID = PCS.CONSOLIDATION_SET_ID
           AND PCS.CONSOLIDATION_SET_NAME IN ('NORMAL')
         ORDER BY PPA.DATE_EARNED DESC,
                  PAA.ASSIGNMENT_ACTION_ID DESC;
                  
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_MAX_ASSIGNMENT_ACTION_ID(P_ASSIGNMENT_ID => ' || P_ASSIGNMENT_ID ||
                                                                    ',P_PAYROLL_ID => ' || P_PAYROLL_ID || 
                                                                    ') RETURN ' || var_assignment_action_id); 
                       
        RETURN var_assignment_action_id;   
    
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_MAX_ASSIGNMENT_ACTION_ID ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_MAX_ASSIGNMENT_ACTION_ID;
    
    
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
                   AND PIVF.UOM = 'M'
                   AND (PIVF.NAME = 'ISR Subject' OR PIVF.NAME = 'ISR Exempt')
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
                                              'P032_SUBSIDIO_PARA_EMPLEO')
                   AND PIVF.UOM = 'M'
                   AND PIVF.NAME = 'Pay Value');
                   
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_SUBTBR(P_ASSIGNMENT_ACTION_ID => ' || P_ASSIGNMENT_ACTION_ID ||
                                                  ') RETURN ' || var_result_value); 
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_SUBTBR(P_ASSIGNMENT_ACTION_ID => ' || P_ASSIGNMENT_ACTION_ID ||
                                                  ') RETURN 0');
    
        RETURN 0;
    END GET_SUBTBR;


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
            AND PIVF.NAME = 'Pay Value';
            
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_ISRRET(P_ASSIGNMENT_ACTION_ID => ' || P_ASSIGNMENT_ACTION_ID || 
                                                  ') RETURN ' || var_result_value);  
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_ISRRET(P_ASSIGNMENT_ACTION_ID => ' || P_ASSIGNMENT_ACTION_ID || 
                                                  ') RETURN 0');
    
        RETURN 0;
    END GET_ISRRET;
    
    
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
           AND PIVF.NAME = 'Pay Value';
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_MONDET(P_ASSIGNMENT_ACTION_ID => ' || P_ASSIGNMENT_ACTION_ID ||
                                                   ') RETURN ' || var_result_value); 
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_MONDET(P_ASSIGNMENT_ACTION_ID => ' || P_ASSIGNMENT_ACTION_ID ||
                                                   ') RETURN ' || var_result_value);
    
        RETURN 0;
    END GET_MONDET;
    
    
    FUNCTION    GET_PERSON_TERMINATION_DATE(P_PERSON_ID     NUMBER)
      RETURN    VARCHAR2
    IS
        var_actual_termination_date VARCHAR2(50) := 'NOTHING';
    BEGIN
    
        SELECT PPOS.ACTUAL_TERMINATION_DATE
          INTO var_actual_termination_date
          FROM PER_PEOPLE_F             PPF,
               PER_ASSIGNMENTS_F        PAF,
               PER_PERIODS_OF_SERVICE   PPOS
         WHERE 1 = 1
           AND PPF.PERSON_ID = PAF.PERSON_ID
           AND PPF.PERSON_ID = PPOS.PERSON_ID
           AND PAF.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID
           AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
           AND PPF.PERSON_ID = P_PERSON_ID;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_PERSON_TERMINATION_DATE(P_PERSON_ID => ' || P_PERSON_ID ||
                                                                   ') RETURN ' || var_actual_termination_date);
           
        RETURN var_actual_termination_date;   
        
    EXCEPTION WHEN NO_DATA_FOUND THEN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_PERSON_TERMINATION_DATE(P_PERSON_ID => ' || P_PERSON_ID ||
                                                                   ') RETURN ' || var_actual_termination_date);
     
        RETURN var_actual_termination_date; 
    END GET_PERSON_TERMINATION_DATE;
    
      
    FUNCTION    GET_MEMBER_TERMINATION_DATE(P_PERSON_ID     NUMBER)
      RETURN    VARCHAR2
    IS
        var_member_termination_date VARCHAR2(50) := 'NOTHING';
    BEGIN
    
        SELECT SBM.MEMBER_END_DATE
          INTO var_member_termination_date
          FROM ATET_SB_MEMBERS SBM
         WHERE 1 = 1
           AND SBM.PERSON_ID = P_PERSON_ID
           AND SBM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_MEMBER_TERMINATION_DATE(P_PERSON_ID => ' || P_PERSON_ID || 
                                                                    ') RETURN ' || var_member_termination_date); 
           
        RETURN var_member_termination_date;
    EXCEPTION WHEN NO_DATA_FOUND THEN
    
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_MEMBER_TERMINATION_DATE(P_PERSON_ID => ' || P_PERSON_ID || 
                                                                    ') RETURN ' || var_member_termination_date);
    
        RETURN var_member_termination_date;
    END GET_MEMBER_TERMINATION_DATE;
    
    
    PROCEDURE   EXPORT_PAYROLL_RESULTS(P_ERRBUF         OUT NOCOPY  VARCHAR2,
                                       P_RETCODE        OUT NOCOPY  VARCHAR2,
                                       P_PERIOD_TYPE    VARCHAR2,
                                       P_YEAR           NUMBER,
                                       P_MONTH          NUMBER,
                                       P_PERIOD_NAME    VARCHAR2)
    IS
    
        CURSOR  DETAIL_LIST IS
            SELECT DISTINCT 
                   PAF.PERSON_ID            AS  "PERSON_ID",
                   PAF.ASSIGNMENT_ID        AS  "ASSIGNMENT_ID",
                   PAA.ASSIGNMENT_ACTION_ID AS  "ASSIGNMENT_ACTION_ID",
                   PPA.PAYROLL_ACTION_ID    AS  "PAYROLL_ACTION_ID",
                   PPA.DATE_EARNED          AS  "EARNED_DATE",
                   PTP.TIME_PERIOD_ID       AS  "TIME_PERIOD_ID",
                   PTP.PERIOD_NAME          AS  "PERIOD_NAME",
                   ATET_SAVINGS_BANK_PKG.GET_LOOKUP_MEANING('ACTION_STATUS', 
                                                            PPA.ACTION_STATUS)        AS  "PAYROLL_STATUS",
                   PETF.ELEMENT_NAME        AS  "ELEMENT_NAME",
                   PIVF.NAME                AS  "ENTRY_NAME",
                   ATET_SAVINGS_BANK_PKG.GET_LOOKUP_MEANING('UNITS', 
                                                            PIVF.UOM)                 AS  "ENTRY_UNITS",
                   PRRV.RESULT_VALUE        AS  "ENTRY_VALUE",
                   PRR.RUN_RESULT_ID        AS  "RUN_RESULT_ID",
                   PRR.ELEMENT_ENTRY_ID     AS  "ELEMENT_ENTRY_ID"
              FROM PAY_PAYROLL_ACTIONS          PPA,
                   PER_TIME_PERIODS             PTP,
                   PAY_ASSIGNMENT_ACTIONS       PAA,
                   PAY_PAYROLLS_F               PPF,
                   PER_ASSIGNMENTS_F            PAF,
                   PAY_RUN_RESULTS              PRR,
                   PAY_ELEMENT_TYPES_F          PETF,
                   PAY_RUN_RESULT_VALUES        PRRV,
                   PAY_INPUT_VALUES_F           PIVF,
                   PAY_ELEMENT_CLASSIFICATIONS  PEC
             WHERE 1 = 1
               AND PTP.TIME_PERIOD_ID = PPA.TIME_PERIOD_ID
               AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
               AND PPA.PAYROLL_ID = PPF.PAYROLL_ID     
               AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(P_PERIOD_TYPE, PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
               AND PPA.ACTION_TYPE IN ('Q', 'R', 'B')
               AND PTP.PERIOD_NAME LIKE '%' || P_YEAR || '%'
               AND PTP.PERIOD_NAME = NVL(P_PERIOD_NAME, PTP.PERIOD_NAME)
               AND EXTRACT(MONTH FROM PPA.DATE_EARNED) >= P_MONTH
               AND PAF.ASSIGNMENT_ID = PAA.ASSIGNMENT_ID
               AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
               AND PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
               AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
               AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
               AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
               AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
               AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
               AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
               AND PETF.ELEMENT_NAME IN (ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME'),
                                         ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME'))
               /************************************************/
               /************************************************/
--               AND PAF.PERSON_ID IN (SELECT ASM.PERSON_ID FROM ATET_SB_MEMBERS ASM)
               /************************************************/
               /************************************************/ 
             ORDER BY PAF.PERSON_ID,
                      PETF.ELEMENT_NAME,
                      PIVF.NAME,
                      PRR.RUN_RESULT_ID;
   
        TYPE   DETAILS IS TABLE OF DETAIL_LIST%ROWTYPE INDEX BY PLS_INTEGER;
     
        detail DETAILS;
        
        var_request_id      NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        var_log             VARCHAR2(1000);
        var_user_id         NUMBER := FND_GLOBAL.USER_ID;
        var_validate        NUMBER;
    
    BEGIN
        
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '***********     PARAMETERS     ***********');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_PERIOD_TYPE : ' || P_PERIOD_TYPE);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_YEAR : ' || P_YEAR);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_MONTH : ' || P_MONTH);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_PERIOD_NAME : ' || P_PERIOD_NAME);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '******************************************'); 
        
        SELECT COUNT(ASPR.PERIOD_NAME) 
          INTO var_validate
          FROM ATET_SB_PAYROLL_RESULTS ASPR 
         WHERE 1 = 1
           AND ASPR.PERIOD_NAME = P_PERIOD_NAME;
        
        IF var_validate = 0 THEN
        
            OPEN DETAIL_LIST;
            
            LOOP
            
                FETCH DETAIL_LIST BULK COLLECT INTO detail LIMIT 500;
                
                EXIT WHEN detail.COUNT = 0;
                
                FOR rowIndex IN 1 .. detail.COUNT
                LOOP
                
                    INSERT INTO ATET_SB_PAYROLL_RESULTS(PERSON_ID,
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
                                                        ATTRIBUTE6,
                                                        CREATION_DATE,
                                                        CREATED_BY,
                                                        LAST_UPDATE_DATE,
                                                        LAST_UPDATED_BY)
                                                 VALUES (detail(rowIndex).PERSON_ID,
                                                         detail(rowIndex).ASSIGNMENT_ID,
                                                         detail(rowIndex).ASSIGNMENT_ACTION_ID,
                                                         detail(rowIndex).PAYROLL_ACTION_ID,
                                                         detail(rowIndex).EARNED_DATE,
                                                         detail(rowIndex).TIME_PERIOD_ID,
                                                         detail(rowIndex).PERIOD_NAME,
                                                         detail(rowIndex).PAYROLL_STATUS,
                                                         detail(rowIndex).ELEMENT_NAME,
                                                         detail(rowIndex).ENTRY_NAME,
                                                         detail(rowIndex).ENTRY_UNITS,
                                                         detail(rowIndex).ENTRY_VALUE,
                                                         detail(rowIndex).RUN_RESULT_ID,
                                                         detail(rowIndex).ELEMENT_ENTRY_ID,
                                                         var_request_id,
                                                         'IMPORTED',
                                                         SYSDATE,
                                                         var_user_id,
                                                         SYSDATE,
                                                         var_user_id);
                                 
                    COMMIT;
                    
                
                    var_log := RPAD(detail(rowIndex).PERSON_ID, 10, ' ')              ||
                               RPAD(detail(rowIndex).ASSIGNMENT_ID, 10, ' ')          ||
                               RPAD(detail(rowIndex).ASSIGNMENT_ACTION_ID, 10, ' ')   ||
                               RPAD(detail(rowIndex).PAYROLL_ACTION_ID, 10, ' ')      ||
                               RPAD(detail(rowIndex).EARNED_DATE, 15, ' ')            ||
                               RPAD(detail(rowIndex).TIME_PERIOD_ID, 15, ' ')         ||
                               RPAD(detail(rowIndex).PERIOD_NAME, 20, ' ')            ||
                               RPAD(detail(rowIndex).PAYROLL_STATUS, 10, ' ')         ||
                               RPAD(detail(rowIndex).ELEMENT_NAME, 30, ' ')           ||
                               RPAD(detail(rowIndex).ENTRY_NAME, 15, ' ')             ||
                               RPAD(detail(rowIndex).ENTRY_UNITS, 10, ' ')            ||
                               RPAD(detail(rowIndex).ENTRY_VALUE, 10, ' ');
                    
                    FND_FILE.PUT_LINE(FND_FILE.LOG ,var_log);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT ,var_log);       
                        
                END LOOP;
                
            END LOOP;
            
            CLOSE DETAIL_LIST;
        ELSE
        
            P_ERRBUF := 'EL PROCESO DE EXPORTACIÓN PARA EL PERIODO ' || P_PERIOD_NAME || ' YA FUE EJECUTADO ANTERIORMENTE.';
            P_RETCODE := 1;
        
        END IF;
    
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en EXPORT_PAYROLL_RESULTS ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END EXPORT_PAYROLL_RESULTS;
    
    
    PROCEDURE   IMPORT_PAYROLL_RESULTS(P_ERRBUF            OUT NOCOPY  VARCHAR2,
                                       P_RETCODE           OUT NOCOPY  VARCHAR2,
                                       P_EXPORT_REQUEST_ID NUMBER)
    IS
        var_import_request_id       NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        var_log                     VARCHAR2(1000);
        var_user_id                 NUMBER := FND_GLOBAL.USER_ID;
        var_validate                NUMBER;
        var_have_account            NUMBER;
        var_result                  VARCHAR2(50) := 'N';
        
        var_period_name             VARCHAR2(200);
        
        var_sum_saving_amount       NUMBER;
        var_sum_saving_pay_value    NUMBER;
        var_sum_saving_import       NUMBER;
        
        var_sum_loan_amount         NUMBER;
        var_sum_loan_pay_value      NUMBER;
        var_sum_loan_import         NUMBER;
    BEGIN
    
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '***********     PARAMETERS     ***********');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_EXPORT_REQUEST_ID : ' || P_EXPORT_REQUEST_ID);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '******************************************');
        
    
        SELECT COUNT(ASPR.EXPORT_REQUEST_ID)
          INTO var_validate
          FROM ATET_SB_PAYROLL_RESULTS ASPR
         WHERE 1 = 1
           AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
           AND ASPR.IMPORT_REQUEST_ID IS NOT NULL;
           
           
        IF var_validate = 0 THEN
        
            UPDATE ATET_SB_PAYROLL_RESULTS
               SET IMPORT_REQUEST_ID = var_import_request_id,
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = var_user_id
             WHERE EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID;
             
            COMMIT;
            
            DECLARE
                CURSOR DETAIL_LIST_SAVINGS IS
                    SELECT ASPR.PAYROLL_RESULT_ID,
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
                           ASPR.ENTRY_VALUE
                      FROM ATET_SB_PAYROLL_RESULTS  ASPR
                     WHERE 1 = 1
                       AND ASPR.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME')
                       AND ASPR.ENTRY_NAME = 'Pay Value'
                       AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                       AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;           
                
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
                       AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                       AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;     
            
                    
            BEGIN
            
                IF var_result = 'N' THEN    
                
                    OPEN DETAIL_LIST_SAVINGS;
                    IF DETAIL_LIST_SAVINGS%ROWCOUNT = 0 THEN
                        var_result := 'Y';
                    END IF;
                    CLOSE DETAIL_LIST_SAVINGS;
                                 
                    FOR detail_saving IN DETAIL_LIST_SAVINGS LOOP
                        
                        CREATE_ACCOUNT(detail_saving.PERSON_ID,
                                       'SAVINGS_ELEMENT_NAME',
                                       'SAV_CODE_COMB');                             
                            
                        var_result := 'N';
                        
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'PROCESANDO: ' || detail_saving.PAYROLL_RESULT_ID  || ','
                                                                       || detail_saving.PERSON_ID          || ','
                                                                       || detail_saving.EARNED_DATE        || ','
                                                                       || detail_saving.PERIOD_NAME        || ','
                                                                       || detail_saving.ELEMENT_NAME       || ','
                                                                       || detail_saving.ENTRY_NAME         || ','
                                                                       || detail_saving.ENTRY_UNITS        || ','
                                                                       || detail_saving.ENTRY_VALUE);
                        
                        var_result := INSERT_SAVING_TRANSACTION(P_PAYROLL_RESULT_ID => detail_saving.PAYROLL_RESULT_ID,
                                                                P_PERSON_ID => detail_saving.PERSON_ID,
                                                                P_EARNED_DATE => detail_saving.EARNED_DATE,
                                                                P_TIME_PERIOD_ID => detail_saving.TIME_PERIOD_ID,
                                                                P_PERIOD_NAME => detail_saving.PERIOD_NAME,
                                                                P_ELEMENT_NAME => detail_saving.ELEMENT_NAME,
                                                                P_ENTRY_NAME => detail_saving.ENTRY_NAME,
                                                                P_ENTRY_UNITS => detail_saving.ENTRY_UNITS,
                                                                P_ENTRY_VALUE => detail_saving.ENTRY_VALUE,
                                                                P_DEBIT_AMOUNT => 0,
                                                                P_CREDIT_AMOUNT => detail_saving.ENTRY_VALUE);
                        
                        UPDATE ATET_SB_PAYROLL_RESULTS ASPR
                           SET ASPR.ATTRIBUTE7 = 'PROCESSED'
                         WHERE ASPR.PAYROLL_RESULT_ID = detail_saving.PAYROLL_RESULT_ID;
                                                                    
                        IF var_result = 'N' THEN
                            EXIT;
                        END IF;                          
                                
                    END LOOP;
                    
                    IF    var_result = 'Y' THEN
                    
                        BEGIN
                            SELECT DISTINCT ASPR.PERIOD_NAME
                              INTO var_period_name
                              FROM ATET_SB_PAYROLL_RESULTS  ASPR
                             WHERE 1 = 1
                               AND ASPR.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME')
                               AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                               AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                               
                            SELECT SUM(ASPEE.ENTRY_VALUE1)
                              INTO var_sum_saving_import
                              FROM ATET_SB_PAY_ELEMENT_ENTRIES  ASPEE
                             WHERE 1 = 1
                               AND ASPEE.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME')
                               AND ASPEE.PERIOD_NAME = var_period_name;
                            
                            SELECT SUM(ASPR.ENTRY_VALUE)
                              INTO var_sum_saving_amount
                              FROM ATET_SB_PAYROLL_RESULTS  ASPR
                             WHERE 1 = 1
                               AND ASPR.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME')
                               AND ASPR.ENTRY_NAME = 'Amount'
                               AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                               AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                               
                            SELECT SUM(ASPR.ENTRY_VALUE)
                              INTO var_sum_saving_pay_value
                              FROM ATET_SB_PAYROLL_RESULTS  ASPR
                             WHERE 1 = 1
                               AND ASPR.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME')
                               AND ASPR.ENTRY_NAME = 'Pay Value'
                               AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                               AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'SIN DECUENTOS ' ||GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME'));    
                        END;
                        
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '********************************************************');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   '||GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME'));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   DESCUENTOS EXPORTADOS    : ' || TO_CHAR(var_sum_saving_import));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   DESCUENTOS PROGRAMADOS   : ' || TO_CHAR(var_sum_saving_amount));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   DESCUENTOS REALES        : ' || TO_CHAR(var_sum_saving_pay_value));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '********************************************************');
                        
                    ELSIF var_result = 'N' THEN
                        
                        ROLLBACK;
                    
                        UPDATE ATET_SB_PAYROLL_RESULTS  ASPR
                           SET IMPORT_REQUEST_ID = NULL,
                               ATTRIBUTE6 = NULL
                         WHERE ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                           AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                           
                        COMMIT; 
                        
                        P_ERRBUF := 'EL PROCESO DE IMPORTACIÓN ENCONTRO UN INCONVENIENTE AL MOMENTO DE PROCESAR LOS MOVIMIENTOS DE CAJA DE AHORRO.';
                        P_RETCODE := 1;                      
                           
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'EL PROCESO DE IMPORTACIÓN ENCONTRO UN INCONVENIENTE AL MOMENTO DE PROCESAR LOS MOVIMIENTOS DE CAJA DE AHORRO.');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'**************************************SE REVIRTIERON TODOS LOS PROCESOS**************************************');
                        
                    END IF;
                    
                END IF;
                
                IF var_result = 'Y' THEN
                
                    FOR detail_loan IN DETAIL_LIST_LOANS LOOP
                                                         
                        var_result := 'N';
                        
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'PROCESANDO: ' || detail_loan.PAYROLL_RESULT_ID  || ','
                                                                       || detail_loan.PERSON_ID          || ','
                                                                       || detail_loan.EARNED_DATE        || ','
                                                                       || detail_loan.PERIOD_NAME        || ','
                                                                       || detail_loan.ELEMENT_NAME       || ','
                                                                       || detail_loan.ENTRY_NAME         || ','
                                                                       || detail_loan.ENTRY_UNITS        || ','
                                                                       || detail_loan.ENTRY_VALUE);
                        
                        var_result := INSERT_LOAN_TRANSACTION(P_EXPORT_REQUEST_ID => detail_loan.EXPORT_REQUEST_ID,
                                                              P_PAYROLL_RESULT_ID => detail_loan.PAYROLL_RESULT_ID,
                                                              P_PERSON_ID => detail_loan.PERSON_ID,
                                                              P_RUN_RESULT_ID => detail_loan.RUN_RESULT_ID,
                                                              P_EARNED_DATE => detail_loan.EARNED_DATE,
                                                              P_TIME_PERIOD_ID => detail_loan.TIME_PERIOD_ID,
                                                              P_PERIOD_NAME => detail_loan.PERIOD_NAME,
                                                              P_ELEMENT_NAME => detail_loan.ELEMENT_NAME,
                                                              P_ENTRY_NAME => detail_loan.ENTRY_NAME,
                                                              P_ENTRY_UNITS => detail_loan.ENTRY_UNITS,
                                                              P_ENTRY_VALUE => detail_loan.ENTRY_VALUE,
                                                              P_DEBIT_AMOUNT => 0,
                                                              P_CREDIT_AMOUNT => detail_loan.ENTRY_VALUE);
                                                              
                                                              
                        UPDATE ATET_SB_PAYROLL_RESULTS ASPR
                           SET ASPR.ATTRIBUTE7 = 'PROCESSED'
                         WHERE ASPR.PAYROLL_RESULT_ID = detail_loan.PAYROLL_RESULT_ID;
                                                                                                                                  
                        IF var_result = 'N' THEN
                            EXIT;
                        END IF;                          
                                
                    END LOOP;
                    
                    IF    var_result = 'Y' THEN
                    
                        BEGIN
                            SELECT DISTINCT ASPR.PERIOD_NAME
                              INTO var_period_name
                              FROM ATET_SB_PAYROLL_RESULTS  ASPR
                             WHERE 1 = 1
                               AND ASPR.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME')
                               AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                               AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                               
                            SELECT SUM(ASPEE.ENTRY_VALUE1)
                              INTO var_sum_loan_import
                              FROM ATET_SB_PAY_ELEMENT_ENTRIES  ASPEE
                             WHERE 1 = 1
                               AND ASPEE.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME')
                               AND ASPEE.PERIOD_NAME = var_period_name;
                            
                            SELECT SUM(ASPR.ENTRY_VALUE)
                              INTO var_sum_loan_amount
                              FROM ATET_SB_PAYROLL_RESULTS  ASPR
                             WHERE 1 = 1
                               AND ASPR.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME')
                               AND ASPR.ENTRY_NAME = 'Amount'
                               AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                               AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                               
                            SELECT SUM(ASPR.ENTRY_VALUE)
                              INTO var_sum_loan_pay_value
                              FROM ATET_SB_PAYROLL_RESULTS  ASPR
                             WHERE 1 = 1
                               AND ASPR.ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME')
                               AND ASPR.ENTRY_NAME = 'Pay Value'
                               AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                               AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'SIN DECUENTOS ' ||GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME'));
                        END;
                        
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '********************************************************');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   '||GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME'));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   DESCUENTOS EXPORTADOS    : ' || TO_CHAR(var_sum_loan_import));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   DESCUENTOS PROGRAMADOS   : ' || TO_CHAR(var_sum_loan_amount));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*   DESCUENTOS REALES        : ' || TO_CHAR(var_sum_loan_pay_value));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '********************************************************');
                        
                    ELSIF var_result = 'N' THEN
                        
                        ROLLBACK;
                    
                        UPDATE ATET_SB_PAYROLL_RESULTS  ASPR
                           SET IMPORT_REQUEST_ID = NULL,
                               ATTRIBUTE6 = NULL
                         WHERE ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
                           AND ASPR.IMPORT_REQUEST_ID = var_import_request_id;
                           
                        COMMIT; 
                        
                        P_ERRBUF := 'EL PROCESO DE IMPORTACIÓN ENCONTRO UN INCONVENIENTE AL MOMENTO DE PROCESAR LOS MOVIMIENTOS DE PRESTAMO DE CAJA DE AHORRO.';
                        P_RETCODE := 1;                      
                        
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'EL PROCESO DE IMPORTACIÓN ENCONTRO UN INCONVENIENTE AL MOMENTO DE PROCESAR LOS MOVIMIENTOS DE PRESTAMO DE CAJA DE AHORRO.');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'********************************************SE REVIRTIERON TODOS LOS PROCESOS********************************************');
                           
                    END IF;
                
                END IF;
            
            END;
            
            IF var_result = 'Y' THEN
                COMMIT;
            ELSIF var_result = 'N' THEN
                ROLLBACK;
            END IF;
            
        ELSE
        
            P_ERRBUF := 'EL PROCESO DE IMPORTACIÓN YA FUE EJECUTADO ANTERIORMENTE.';
            P_RETCODE := 1;
        
        END IF;  

    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'XXXXXXXXXXXXX   ROLLBACK EJECUTADO   XXXXXXXXXXXXX');
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en IMPORT_PAYROLL_RESULTS ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END IMPORT_PAYROLL_RESULTS;
    
    
    
    
    PROCEDURE   CREATE_ACCOUNT(P_PERSON_ID              NUMBER,
                               P_PARAM_ELEMENT_NAME     VARCHAR2,
                               P_PARAM_CODE_COMBINATION VARCHAR2)
    IS
        var_have_account    NUMBER;
        var_user_id         NUMBER := FND_GLOBAL.USER_ID;
    BEGIN
                   

        IF P_PARAM_ELEMENT_NAME = 'SAVINGS_ELEMENT_NAME' THEN
            
            SELECT COUNT(ASMA.MEMBER_ACCOUNT_ID)
              INTO var_have_account
              FROM ATET_SB_MEMBERS          ASM,
                   ATET_SB_MEMBERS_ACCOUNTS ASMA                               
             WHERE 1 = 1
               AND ASM.PERSON_ID = P_PERSON_ID
               AND ASM.MEMBER_ID = ASMA.MEMBER_ID   
               AND ASMA.ACCOUNT_DESCRIPTION = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME)
               AND ASMA.ACCOUNT_NUMBER = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_CODE_COMBINATION)
               AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;

            IF var_have_account = 0 THEN                                
                INSERT INTO ATET_SB_MEMBERS_ACCOUNTS(MEMBER_ID,
                                                     CODE_COMBINATION_ID,
                                                     ACCOUNT_NUMBER,
                                                     ACCOUNT_DESCRIPTION,
                                                     DEBIT_BALANCE,
                                                     CREDIT_BALANCE,
                                                     FINAL_BALANCE,
                                                     CREATION_DATE,
                                                     CREATED_BY,
                                                     LAST_UPDATE_DATE,
                                                     LAST_UPDATED_BY)
                                             VALUES (GET_MEMBER_ID(P_PERSON_ID),
                                                     GET_CODE_COMBINATION_ID(GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAV_CODE_COMB')),
                                                     GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAV_CODE_COMB'),
                                                     GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME),
                                                     0,
                                                     0,
                                                     0,
                                                     SYSDATE,
                                                     var_user_id,
                                                     SYSDATE,
                                                     var_user_id);
                COMMIT;
                
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'CREATE ACCOUNT ' || GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME) || '.');
                
            END IF;                                                                                                                                              
                                                                                             
        ELSIF P_PARAM_ELEMENT_NAME = 'LOAN_ELEMENT_NAME' THEN
            IF GET_MEMBER_IS_SAVER(GET_MEMBER_ID(P_PERSON_ID)) = 'Y' THEN
            
                SELECT COUNT(ASMA.MEMBER_ACCOUNT_ID)
                  INTO var_have_account
                  FROM ATET_SB_MEMBERS          ASM,
                       ATET_SB_MEMBERS_ACCOUNTS ASMA                               
                 WHERE 1 = 1
                   AND ASM.PERSON_ID = P_PERSON_ID
                   AND ASM.MEMBER_ID = ASMA.MEMBER_ID   
                   AND ASMA.ACCOUNT_DESCRIPTION = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME)
                   AND ASMA.ACCOUNT_NUMBER = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_SAV_CODE_COMB')
                   AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID
                   AND ASMA.LOAN_ID IS NULL;
                   
                IF var_have_account = 0 THEN             
                    INSERT INTO ATET_SB_MEMBERS_ACCOUNTS(MEMBER_ID,
                                                         CODE_COMBINATION_ID,
                                                         ACCOUNT_NUMBER,
                                                         ACCOUNT_DESCRIPTION,
                                                         DEBIT_BALANCE,
                                                         CREDIT_BALANCE,
                                                         FINAL_BALANCE,
                                                         CREATION_DATE,
                                                         CREATED_BY,
                                                         LAST_UPDATE_DATE,
                                                         LAST_UPDATED_BY)
                                                 VALUES (GET_MEMBER_ID(P_PERSON_ID),
                                                         GET_CODE_COMBINATION_ID(GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_SAV_CODE_COMB')),
                                                         GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_SAV_CODE_COMB'),
                                                         GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME),
                                                         0,
                                                         0,
                                                         0,
                                                         SYSDATE,
                                                         var_user_id,
                                                         SYSDATE,
                                                         var_user_id);
                    COMMIT;
                    
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'CREATE ACCOUNT ' || GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME) || '.');
                END IF;
            ELSE
                SELECT COUNT(ASMA.MEMBER_ACCOUNT_ID)
                  INTO var_have_account
                  FROM ATET_SB_MEMBERS          ASM,
                       ATET_SB_MEMBERS_ACCOUNTS ASMA                               
                 WHERE 1 = 1
                   AND ASM.PERSON_ID = P_PERSON_ID
                   AND ASM.MEMBER_ID = ASMA.MEMBER_ID   
                   AND ASMA.ACCOUNT_DESCRIPTION = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME)
                   AND ASMA.ACCOUNT_NUMBER = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_NO_SAV_CODE_COMB')
                   AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID
                   AND ASMA.LOAN_ID IS NULL;
                   
                IF var_have_account = 0 THEN 
                    INSERT INTO ATET_SB_MEMBERS_ACCOUNTS(MEMBER_ID,
                                                         CODE_COMBINATION_ID,
                                                         ACCOUNT_NUMBER,
                                                         ACCOUNT_DESCRIPTION,
                                                         DEBIT_BALANCE,
                                                         CREDIT_BALANCE,
                                                         FINAL_BALANCE,
                                                         CREATION_DATE,
                                                         CREATED_BY,
                                                         LAST_UPDATE_DATE,
                                                         LAST_UPDATED_BY)
                                                 VALUES (GET_MEMBER_ID(P_PERSON_ID),
                                                         GET_CODE_COMBINATION_ID(GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_NO_SAV_CODE_COMB')),
                                                         GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_NO_SAV_CODE_COMB'),
                                                         GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME),
                                                         0,
                                                         0,
                                                         0,
                                                         SYSDATE,
                                                         var_user_id,
                                                         SYSDATE,
                                                         var_user_id);
                    COMMIT;
                    
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'CREATE ACCOUNT ' || GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, P_PARAM_ELEMENT_NAME) || '.');
                END IF;
            END IF;                          
        END IF;
 
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en CREATE_ACCOUNT ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END CREATE_ACCOUNT;
    
    
    FUNCTION GET_LOOKUP_MEANING(P_LOOKUP_TYPE    VARCHAR2,
                                P_LOOKUP_CODE    VARCHAR2)
      RETURN VARCHAR2
   --
   AS
      V_MEANING   HR_LOOKUPS.MEANING%TYPE;
   --
   BEGIN
      --


      --
      BEGIN
         SELECT HRL.MEANING
           INTO V_MEANING
           FROM HR_LOOKUPS HRL
          WHERE HRL.LOOKUP_TYPE = P_LOOKUP_TYPE
                AND HRL.LOOKUP_CODE = P_LOOKUP_CODE;
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE_APPLICATION_ERROR (
               -20001,
                  'An error was encountered - in get_lookup_meaning '
               || SQLCODE
               || ' -ERROR- '
               || SQLERRM);
      END;

      --

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_LOOKUP_MEANING(P_LOOKUP_TYPE => ' || P_LOOKUP_TYPE ||
                                                        ',P_LOOKUP_CODE => ' || P_LOOKUP_CODE || ') RETURN ' || V_MEANING);

      --
      RETURN V_MEANING;
   --
   END GET_LOOKUP_MEANING;
   
   
    PROCEDURE   ROLLBACK_EXPORT_PAYRESULT(P_ERRBUF            OUT NOCOPY  VARCHAR2,
                                          P_RETCODE           OUT NOCOPY  VARCHAR2,
                                          P_EXPORT_REQUEST_ID NUMBER)
    IS
    
        CURSOR DETAIL_LIST  IS
            SELECT ASPR.PAYROLL_RESULT_ID,
                   ASPR.PERSON_ID,
                   ASPR.ASSIGNMENT_ID,
                   ASPR.ASSIGNMENT_ACTION_ID,
                   ASPR.PAYROLL_ACTION_ID,
                   ASPR.EARNED_DATE,
                   ASPR.PERIOD_NAME,
                   ASPR.PAYROLL_STATUS,
                   ASPR.ELEMENT_NAME,
                   ASPR.ENTRY_NAME,
                   ASPR.ENTRY_UNITS,
                   ASPR.ENTRY_VALUE,
                   ASPR.EXPORT_REQUEST_ID
              FROM ATET_SB_PAYROLL_RESULTS ASPR
             WHERE ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID;
             
        TYPE   DETAILS IS TABLE OF DETAIL_LIST%ROWTYPE INDEX BY PLS_INTEGER;
     
        detail DETAILS;
        
        var_log             VARCHAR2(1000);
        var_validate        NUMBER;
        
    BEGIN
        
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '***********     PARAMETERS     ***********');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_EXPORT_REQUEST_ID : ' || P_EXPORT_REQUEST_ID);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '******************************************');
        
        OPEN DETAIL_LIST;
            
        LOOP
            
            FETCH DETAIL_LIST BULK COLLECT INTO detail LIMIT 500;
                
            EXIT WHEN detail.COUNT = 0;
                
            FOR rowIndex IN 1 .. detail.COUNT
            LOOP
                
                var_log := '';
                
                SELECT COUNT(ASPR.PAYROLL_RESULT_ID)
                  INTO var_validate
                  FROM ATET_SB_PAYROLL_RESULTS ASPR
                 WHERE 1 = 1
                   AND ASPR.PAYROLL_RESULT_ID = detail(rowIndex).PAYROLL_RESULT_ID
                   AND ASPR.IMPORT_REQUEST_ID IS NULL; 
                
                IF var_validate = 1 THEN
                    DELETE FROM ATET_SB_PAYROLL_RESULTS
                     WHERE PAYROLL_RESULT_ID = detail(rowIndex).PAYROLL_RESULT_ID;
                     
                    COMMIT;
                    
                    var_log := RPAD('COMPLETE : ', 10, ' ');
                ELSE
                    P_ERRBUF := 'No se puede revertir el movimiento.';
                    P_RETCODE := 1;
                    var_log := RPAD('WARNING : ', 10, ' ');
                END IF;    
                
                var_log := var_log || RPAD(detail(rowIndex).PERSON_ID, 10, ' ')              ||
                                      RPAD(detail(rowIndex).ASSIGNMENT_ID, 10, ' ')          ||
                                      RPAD(detail(rowIndex).ASSIGNMENT_ACTION_ID, 10, ' ')   ||
                                      RPAD(detail(rowIndex).PAYROLL_ACTION_ID, 10, ' ')      ||
                                      RPAD(detail(rowIndex).EARNED_DATE, 15, ' ')            ||
                                      RPAD(detail(rowIndex).PERIOD_NAME, 20, ' ')            ||
                                      RPAD(detail(rowIndex).PAYROLL_STATUS, 10, ' ')         ||
                                      RPAD(detail(rowIndex).ELEMENT_NAME, 30, ' ')           ||
                                      RPAD(detail(rowIndex).ENTRY_NAME, 15, ' ')             ||
                                      RPAD(detail(rowIndex).ENTRY_UNITS, 10, ' ')            ||
                                      RPAD(detail(rowIndex).ENTRY_VALUE, 10, ' ')            ||
                                      RPAD(detail(rowIndex).EXPORT_REQUEST_ID, 10, ' ');
                    
                FND_FILE.PUT_LINE(FND_FILE.LOG ,var_log);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT ,var_log);       
                        
            END LOOP;
                
        END LOOP;
            
        CLOSE DETAIL_LIST;
        
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en ROLLBACK_EXPORT_PAYRESULT ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END ROLLBACK_EXPORT_PAYRESULT;
    
    
    PROCEDURE   CHANGE_AMOUNT_TO_SAVE(P_ERRBUF            OUT NOCOPY  VARCHAR2,
                                      P_RETCODE           OUT NOCOPY  VARCHAR2,
                                      P_EMPLOYEE_NUMBER   NUMBER,
                                      P_AMOUNT_TO_SAVE    NUMBER)
    IS
        var_amount_to_save      NUMBER;
        var_next_discount       NUMBER;
        var_employee_number     NUMBER;
        var_employee_name       VARCHAR2(500);
        
        var_attribute2          VARCHAR2(15);
        var_attribute3          VARCHAR2(15);
        var_is_saver            VARCHAR2(5);
    BEGIN
    
        IF SYSDATE > TO_DATE(GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'REG_CHANGED_DATE'), 'RRRR/MM/DD') THEN
            P_ERRBUF := 'No se puede cambiar el monto de ahorro cuando la fecha de inscripción ha finalizado.';
            P_RETCODE := 1;
        ELSE
        
            -- ATTRIBUTE2       Periodos pendientes
            -- ATTRIBUTE3       Monto real de ahorro.
            
            SELECT NVL(TO_CHAR(ASM.ATTRIBUTE2), 'NOTHING'),
                   NVL(TO_CHAR(ASM.ATTRIBUTE3), 'NOTHING'),
                   ASM.IS_SAVER
              INTO var_attribute2,
                   var_attribute3,
                   var_is_saver
              FROM ATET_SB_MEMBERS ASM 
             WHERE ASM.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER 
               AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
               
            IF var_is_saver = 'Y' THEN
                
                IF var_attribute2 = 'NOTHING' AND var_attribute3 = 'NOTHING' THEN
                
                    UPDATE ATET_SB_MEMBERS
                       SET AMOUNT_TO_SAVE = P_AMOUNT_TO_SAVE,
                           ATTRIBUTE7 = 'CHANGED',
                           LAST_UPDATE_DATE = SYSDATE,
                           LAST_UPDATED_BY = FND_GLOBAL.USER_ID
                     WHERE EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
                       AND SAVING_BANK_ID = GET_SAVING_BANK_ID;


                    COMMIT;
                        
                    SELECT ASM.EMPLOYEE_NUMBER,
                           ASM.EMPLOYEE_FULL_NAME,
                           ASM.AMOUNT_TO_SAVE
                      INTO var_employee_number,
                           var_employee_name,
                           var_amount_to_save
                      FROM ATET_SB_MEMBERS ASM
                     WHERE ASM.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
                       AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
                           
                           
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '***********     CAMBIO DE AHORRO     ***********');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Número de empleado :          ' || var_employee_number);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Nombre de empleado :          ' || var_employee_name);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Monto de ahorro actualizado : ' || var_amount_to_save);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '************************************************');
                        
                ELSE
                    
                    UPDATE ATET_SB_MEMBERS
                       SET ATTRIBUTE3 = P_AMOUNT_TO_SAVE,
                           AMOUNT_TO_SAVE = P_AMOUNT_TO_SAVE * (1 + ATTRIBUTE2),
                           ATTRIBUTE7 = 'CHANGED',
                           LAST_UPDATE_DATE = SYSDATE,
                           LAST_UPDATED_BY = FND_GLOBAL.USER_ID
                     WHERE EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
                       AND SAVING_BANK_ID = GET_SAVING_BANK_ID;


                    COMMIT;
                        
                    SELECT ASM.EMPLOYEE_NUMBER,
                           ASM.EMPLOYEE_FULL_NAME,
                           ASM.ATTRIBUTE3,
                           ASM.AMOUNT_TO_SAVE
                      INTO var_employee_number,
                           var_employee_name,
                           var_amount_to_save,
                           var_next_discount
                      FROM ATET_SB_MEMBERS ASM
                     WHERE ASM.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
                       AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
                           
                           
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '***********     CAMBIO DE AHORRO     ***********');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Número de empleado :          ' || var_employee_number);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Nombre de empleado :          ' || var_employee_name);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Monto de ahorro actualizado : ' || var_amount_to_save);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Próximo descuento : '           || var_next_discount);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '************************************************');
                    
                END IF;
                
            END IF;
               
        END IF;
    
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en CHANGE_AMOUNT_TO_SAVE ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END CHANGE_AMOUNT_TO_SAVE;
    
    
    PROCEDURE   RESTART_SEQUENCE
    IS
    BEGIN
        
        EXECUTE IMMEDIATE 'DROP SEQUENCE ATET_SB_LOAN_NUMBER_SEQ';

        EXECUTE IMMEDIATE
             'CREATE SEQUENCE ATET_SB_LOAN_NUMBER_SEQ '
          || 'START WITH 1 '
          || 'INCREMENT BY 1 '
          || 'NOCACHE '
          || 'NOCYCLE';
                  
                  
        EXECUTE IMMEDIATE 'DROP SEQUENCE ATET_SB_CHECK_NUMBER_SEQ';

        EXECUTE IMMEDIATE
             'CREATE SEQUENCE ATET_SB_CHECK_NUMBER_SEQ '
          || 'START WITH 1 '
          || 'INCREMENT BY 1 '
          || 'NOCACHE '
          || 'NOCYCLE';
          
          
        EXECUTE IMMEDIATE 'DROP SEQUENCE ATET_SB_ENDORSEMENT_NUMBER_SEQ';

        EXECUTE IMMEDIATE
             'CREATE SEQUENCE ATET_SB_ENDORSEMENT_NUMBER_SEQ '
          || 'START WITH 1 '
          || 'INCREMENT BY 1 '
          || 'NOCACHE '
          || 'NOCYCLE';      
                  
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en RESTART_SEQUENCE ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END RESTART_SEQUENCE;  
    
    
    FUNCTION    GET_MEMBER_ID(P_PERSON_ID   NUMBER)
      RETURN    NUMBER
    IS
        var_member_id   NUMBER;
    BEGIN
        SELECT ASM.MEMBER_ID
          INTO var_member_id
          FROM ATET_SB_MEMBERS ASM
         WHERE ASM.PERSON_ID = P_PERSON_ID
           AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_MEMBER_ID(P_PERSON_ID => ' || P_PERSON_ID || ') RETURN ' || var_member_id);
           
        RETURN var_member_id;   
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_MEMBER_ID ' || SQLCODE || ' -ERROR- ' || SQLERRM);        
    END GET_MEMBER_ID;
    
    
    FUNCTION    GET_MEMBER_IS_SAVER(P_MEMBER_ID     NUMBER)
      RETURN    VARCHAR2
    IS
        var_result  VARCHAR2(50);
    BEGIN
    
        SELECT ASM.IS_SAVER
          INTO var_result
          FROM ATET_SB_MEMBERS  ASM
         WHERE 1 = 1
           AND ASM.MEMBER_ID = P_MEMBER_ID;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_MEMBER_IS_SAVER(P_MEMBER_ID => ' || P_MEMBER_ID || ') RETURN ' || var_result);
    
        RETURN var_result;

    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_MEMBER_IS_SAVER ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_MEMBER_IS_SAVER;
      
   
    FUNCTION    GET_CODE_COMBINATION_ID(P_CODE_COMBINATION   VARCHAR2)
      RETURN    NUMBER
    IS
        var_result  NUMBER;
    BEGIN
        SELECT GL.CODE_COMBINATION_ID
          INTO var_result
          FROM GL_CODE_COMBINATIONS_V  GL
         WHERE 1 = 1
           AND GL.TEMPLATE_ID IS NULL
           AND GL.SEGMENT1 = '07'
           AND (GL.SEGMENT1 ||
                GL.SEGMENT2 ||
                GL.SEGMENT3 ||
                GL.SEGMENT4 ||
                GL.SEGMENT5 ||
                GL.SEGMENT6) = REPLACE(P_CODE_COMBINATION, '-', '');
                
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_CODE_COMBINATION_ID(P_CODE_COMBINATION => ' || P_CODE_COMBINATION || ') RETURN ' || var_result); 
                
        RETURN var_result;
        
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_CODE_COMBINATION_ID ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_CODE_COMBINATION_ID;
    
    
    FUNCTION    INSERT_SAVING_TRANSACTION(P_PAYROLL_RESULT_ID   NUMBER,
                                          P_PERSON_ID           NUMBER,
                                          P_EARNED_DATE         DATE,
                                          P_TIME_PERIOD_ID      NUMBER,
                                          P_PERIOD_NAME         VARCHAR2,
                                          P_ELEMENT_NAME        VARCHAR2,
                                          P_ENTRY_NAME          VARCHAR2,
                                          P_ENTRY_UNITS         VARCHAR2,
                                          P_ENTRY_VALUE         NUMBER,
                                          P_DEBIT_AMOUNT        NUMBER,
                                          P_CREDIT_AMOUNT       NUMBER)
    RETURN VARCHAR2
    IS
        var_import_request_id       NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        var_log                     VARCHAR2(1000);
        var_user_id                 NUMBER := FND_GLOBAL.USER_ID;
        
        var_member_id               NUMBER;
        var_member_account_id       NUMBER;
        var_attribute2              VARCHAR2(50);
        var_attribute3              VARCHAR2(50);
    BEGIN
    
        var_member_id := GET_MEMBER_ID(P_PERSON_ID);
        var_member_account_id := GET_SAVING_MEMBER_ACCOUNT_ID(GET_MEMBER_ID(P_PERSON_ID),
                                                              GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAV_CODE_COMB'),
                                                              GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME'));
    
        INSERT INTO ATET_SB_SAVINGS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                  MEMBER_ID,
                                                  PAYROLL_RESULT_ID,
                                                  PERSON_ID,
                                                  EARNED_DATE,
                                                  TIME_PERIOD_ID,
                                                  PERIOD_NAME,
                                                  ELEMENT_NAME,
                                                  ENTRY_NAME,
                                                  ENTRY_UNITS,
                                                  ENTRY_VALUE,
                                                  TRANSACTION_CODE,
                                                  DEBIT_AMOUNT,
                                                  CREDIT_AMOUNT,
                                                  REQUEST_ID,
                                                  ACCOUNTED_FLAG,
                                                  CREATION_DATE,
                                                  CREATED_BY,
                                                  LAST_UPDATE_DATE,
                                                  LAST_UPDATED_BY)
                                          VALUES (var_member_account_id,
                                                  var_member_id,
                                                  P_PAYROLL_RESULT_ID,
                                                  P_PERSON_ID,
                                                  P_EARNED_DATE,
                                                  P_TIME_PERIOD_ID,
                                                  P_PERIOD_NAME,
                                                  P_ELEMENT_NAME,
                                                  P_ENTRY_NAME,
                                                  P_ENTRY_UNITS,
                                                  P_ENTRY_VALUE,
                                                  'PROCESSED',
                                                  P_DEBIT_AMOUNT,
                                                  P_CREDIT_AMOUNT,
                                                  var_import_request_id,
                                                  'UNACCOUNTED',
                                                  SYSDATE,
                                                  var_user_id,
                                                  SYSDATE,
                                                  var_user_id);
                                                  
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET DEBIT_BALANCE = DEBIT_BALANCE + P_DEBIT_AMOUNT,
               CREDIT_BALANCE = CREDIT_BALANCE + P_CREDIT_AMOUNT,
               LAST_TRANSACTION_DATE = SYSDATE               
         WHERE MEMBER_ID = var_member_id
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET FINAL_BALANCE = CREDIT_BALANCE - DEBIT_BALANCE,
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = var_user_id             
         WHERE MEMBER_ID = var_member_id
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
        
        
        SELECT NVL(TO_CHAR(ASM.ATTRIBUTE2), 'NOTHING'),
               NVL(TO_CHAR(ASM.ATTRIBUTE3), 'NOTHING')
          INTO var_attribute2,
               var_attribute3
          FROM ATET_SB_MEMBERS ASM 
         WHERE ASM.MEMBER_ID = var_member_id 
           AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
        
        
        IF var_attribute2 <> 'NOTHING' AND var_attribute3 <> 'NOTHING' THEN
            
           UPDATE ATET_SB_MEMBERS
              SET AMOUNT_TO_SAVE = TO_NUMBER(var_attribute3),
                  ATTRIBUTE2 = NULL,
                  ATTRIBUTE3 = NULL,
                  LAST_UPDATE_DATE = SYSDATE,
                  LAST_UPDATED_BY = var_user_id
            WHERE MEMBER_ID = var_member_id;
        
        END IF;
             
                                                  
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'MOVIMIENTO PROCESADO: *AHORRO*'    || P_PAYROLL_RESULT_ID  || ','
                                                                               || P_PERSON_ID          || ','
                                                                               || P_EARNED_DATE        || ','
                                                                               || P_PERIOD_NAME        || ','
                                                                               || P_ELEMENT_NAME       || ','
                                                                               || P_ENTRY_NAME         || ','
                                                                               || P_ENTRY_UNITS        || ','
                                                                               || P_ENTRY_VALUE        || ','
                                                                               || P_DEBIT_AMOUNT       || ','
                                                                               || P_CREDIT_AMOUNT      || '.');    
                                                                               
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT_SAVING_TRANSACTION(P_PAYROLL_RESULT_ID => ' || P_PAYROLL_RESULT_ID ||
                                                                 ',P_PERSON_ID => ' || P_PERSON_ID ||
                                                                 ',P_EARNED_DATE => ' || P_EARNED_DATE || 
                                                                 ',P_TIME_PERIOD_ID => ' || P_TIME_PERIOD_ID ||
                                                                 ',P_PERIOD_NAME => ' || P_PERIOD_NAME ||
                                                                 ',P_ELEMENT_NAME => ' || P_ELEMENT_NAME ||
                                                                 ',P_ENTRY_NAME => ' || P_ENTRY_NAME ||
                                                                 ',P_ENTRY_UNITS => ' || P_ENTRY_UNITS ||
                                                                 ',P_ENTRY_VALUE => ' || P_ENTRY_VALUE ||
                                                                 ',P_DEBIT_AMOUNT => ' || P_DEBIT_AMOUNT ||
                                                                 ',P_CREDIT_AMOUNT => ' || P_CREDIT_AMOUNT || ') RETURN Y');                       
    
        RETURN 'Y';
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'NO SE PROCESO EL MOVIMIENTO: *AHORRO*' || P_PAYROLL_RESULT_ID  || ','
                                                                                || P_PERSON_ID          || ','
                                                                                || P_EARNED_DATE        || ','
                                                                                || P_PERIOD_NAME        || ','
                                                                                || P_ELEMENT_NAME       || ','
                                                                                || P_ENTRY_NAME         || ','
                                                                                || P_ENTRY_UNITS        || ','
                                                                                || P_ENTRY_VALUE        || ','
                                                                                || P_DEBIT_AMOUNT       || ','
                                                                                || P_CREDIT_AMOUNT      || '.' || SQLERRM);
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT_SAVING_TRANSACTION(P_PAYROLL_RESULT_ID => ' || P_PAYROLL_RESULT_ID ||
                                                                 ',P_PERSON_ID => ' || P_PERSON_ID ||
                                                                 ',P_EARNED_DATE => ' || P_EARNED_DATE || 
                                                                 ',P_TIME_PERIOD_ID => ' || P_TIME_PERIOD_ID ||
                                                                 ',P_PERIOD_NAME => ' || P_PERIOD_NAME ||
                                                                 ',P_ELEMENT_NAME => ' || P_ELEMENT_NAME ||
                                                                 ',P_ENTRY_NAME => ' || P_ENTRY_NAME ||
                                                                 ',P_ENTRY_UNITS => ' || P_ENTRY_UNITS ||
                                                                 ',P_ENTRY_VALUE => ' || P_ENTRY_VALUE ||
                                                                 ',P_DEBIT_AMOUNT => ' || P_DEBIT_AMOUNT ||
                                                                 ',P_CREDIT_AMOUNT => ' || P_CREDIT_AMOUNT || ') RETURN N');
        
        ROLLBACK;
        RETURN 'N';
    END INSERT_SAVING_TRANSACTION;
    
    
  
    FUNCTION   INSERT_LOAN_TRANSACTION(P_EXPORT_REQUEST_ID   NUMBER,
                                       P_PAYROLL_RESULT_ID   NUMBER,
                                       P_PERSON_ID           NUMBER,
                                       P_RUN_RESULT_ID       NUMBER,
                                       P_EARNED_DATE         DATE,
                                       P_TIME_PERIOD_ID      NUMBER,
                                       P_PERIOD_NAME         VARCHAR2,
                                       P_ELEMENT_NAME        VARCHAR2,
                                       P_ENTRY_NAME          VARCHAR2,
                                       P_ENTRY_UNITS         VARCHAR2,
                                       P_ENTRY_VALUE         NUMBER,
                                       P_DEBIT_AMOUNT        NUMBER,
                                       P_CREDIT_AMOUNT       NUMBER)
      RETURN    VARCHAR2
    IS
        var_import_request_id       NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        var_log                     VARCHAR2(1000);
        var_user_id                 NUMBER := FND_GLOBAL.USER_ID;
        
        var_member_id               NUMBER;
        var_member_account_id       NUMBER;
        var_attribute2              VARCHAR2(50);
        var_attribute3              VARCHAR2(50);
        
        var_loan_id                 NUMBER;
        var_loan_number             NUMBER;
        var_entry_value_export      NUMBER;
        
        var_entry_value             NUMBER;
        var_payment_schedule_id     NUMBER;
        var_payment_number          NUMBER;
        var_payment_amount          NUMBER;
        var_payment_capital         NUMBER;
        var_payment_interest        NUMBER;
        var_payment_interest_late   NUMBER;
        var_expected_payment_amount NUMBER;
        
        var_validate                NUMBER;
    BEGIN
    
        var_entry_value := P_ENTRY_VALUE;
        var_member_id := GET_MEMBER_ID(P_PERSON_ID);
        var_loan_id := GET_RESULT_FROM_PAYROLL_RESULT(P_PERSON_ID, P_EXPORT_REQUEST_ID, P_RUN_RESULT_ID, 'Futuro 4');
        var_loan_number := GET_RESULT_FROM_PAYROLL_RESULT(P_PERSON_ID, P_EXPORT_REQUEST_ID, P_RUN_RESULT_ID, 'Folio');
        
        IF var_loan_id = 0 AND var_loan_number <> 0 THEN
            var_loan_id := GET_LOAN_ID(
                                P_MEMBER_ID => var_member_id, 
                                P_LOAN_NUMBER => var_loan_number);
        ELSIF var_loan_id = 0 AND var_loan_number = 0 THEN
            var_loan_id := GET_LOAN_ID(
                                P_PERSON_ID => P_PERSON_ID,
                                P_PAYMENT_AMOUNT => GET_RESULT_FROM_PAYROLL_RESULT(P_PERSON_ID, P_EXPORT_REQUEST_ID, P_RUN_RESULT_ID, 'Amount'));
        END IF;
        
        var_member_account_id := GET_LOAN_MEMBER_ACCOUNT_ID(GET_MEMBER_ID(P_PERSON_ID), var_loan_id);
                                                            
                                                            
        SELECT ASPS.PAYMENT_SCHEDULE_ID,
               ASPS.PAYMENT_NUMBER,
               ASPS.PAYMENT_AMOUNT,
               ASPS.PAYMENT_AMOUNT,
               ASPS.PAYMENT_CAPITAL,
               ASPS.PAYMENT_INTEREST,
               ASPS.PAYMENT_INTEREST_LATE
          INTO var_payment_schedule_id,
               var_payment_number,
               var_payment_amount,
               var_expected_payment_amount,
               var_payment_capital,
               var_payment_interest,
               var_payment_interest_late
          FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
         WHERE 1 = 1
           AND ASPS.LOAN_ID = var_loan_id
           AND ASPS.TIME_PERIOD_ID = P_TIME_PERIOD_ID
           AND ASPS.PERIOD_NAME = P_PERIOD_NAME;
           
        IF TRUNC(var_payment_amount, 0) <> TRUNC(var_entry_value, 0) THEN
            var_payment_amount := var_entry_value; 
            
            IF (var_entry_value - var_payment_interest_late) >= 0 THEN
                var_payment_interest_late := var_payment_interest_late;
            ELSE
                var_payment_interest_late := var_entry_value;
            END IF;
            
            var_entry_value := var_entry_value - var_payment_interest_late;
            
            IF (var_entry_value - var_payment_interest) >= 0 THEN
                var_payment_interest := var_payment_interest;
            ELSE
                var_payment_interest := var_entry_value;
            END IF; 
            
            var_entry_value := var_entry_value - var_payment_interest;
            
            IF (var_entry_value - var_payment_capital) >= 0 THEN
                var_payment_capital := var_payment_capital;
            ELSE
                var_payment_capital := var_entry_value;
            END IF;
        ELSE
            var_payment_amount := var_payment_amount;
            var_payment_capital := var_payment_capital;
            var_payment_interest := var_payment_interest;
            var_payment_interest_late := var_payment_interest_late;
        END IF;
    
        INSERT INTO ATET_SB_LOANS_TRANSACTIONS (MEMBER_ACCOUNT_ID,
                                                MEMBER_ID,
                                                PAYROLL_RESULT_ID,
                                                LOAN_ID,
                                                PERSON_ID,
                                                RUN_RESULT_ID,
                                                EARNED_DATE,
                                                TIME_PERIOD_ID,
                                                PERIOD_NAME,
                                                ELEMENT_NAME,
                                                ENTRY_NAME,
                                                ENTRY_UNITS,
                                                ENTRY_VALUE,
                                                TRANSACTION_CODE,
                                                DEBIT_AMOUNT,
                                                CREDIT_AMOUNT,
                                                PAYMENT_AMOUNT,
                                                PAYMENT_CAPITAL,
                                                PAYMENT_INTEREST,
                                                PAYMENT_INTEREST_LATE,
                                                REQUEST_ID,
                                                ACCOUNTED_FLAG,
                                                CREATION_DATE,
                                                CREATED_BY,
                                                LAST_UPDATE_DATE,
                                                LAST_UPDATED_BY)
                                         VALUES (var_member_account_id,
                                                 var_member_id,
                                                 P_PAYROLL_RESULT_ID,
                                                 var_loan_id,
                                                 P_PERSON_ID,
                                                 P_RUN_RESULT_ID,
                                                 P_EARNED_DATE,
                                                 P_TIME_PERIOD_ID,
                                                 P_PERIOD_NAME,
                                                 P_ELEMENT_NAME,
                                                 P_ENTRY_NAME,
                                                 P_ENTRY_UNITS,
                                                 P_ENTRY_VALUE,
                                                 'PROCESSED',
                                                 P_DEBIT_AMOUNT,
                                                 P_CREDIT_AMOUNT,
                                                 var_payment_amount,
                                                 var_payment_capital,
                                                 var_payment_interest,
                                                 var_payment_interest_late,
                                                 var_import_request_id,
                                                 'UNACCOUNTED',
                                                  SYSDATE,
                                                  var_user_id,
                                                  SYSDATE,
                                                  var_user_id);
                                                  
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET DEBIT_BALANCE = DEBIT_BALANCE + P_DEBIT_AMOUNT,
               CREDIT_BALANCE = CREDIT_BALANCE + P_CREDIT_AMOUNT,
               LAST_TRANSACTION_DATE = SYSDATE               
         WHERE MEMBER_ID = var_member_id
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET FINAL_BALANCE = DEBIT_BALANCE - CREDIT_BALANCE,
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = var_user_id             
         WHERE MEMBER_ID = var_member_id
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
        UPDATE ATET_SB_LOANS ASL
           SET ASL.LOAN_BALANCE = ASL.LOAN_BALANCE - P_CREDIT_AMOUNT,
               ASL.LAST_PAYMENT_DATE = SYSDATE
         WHERE 1 = 1
           AND ASL.LOAN_ID = var_loan_id;
           
           
        --Actualización de payment_schedule.           
        IF TRUNC(var_expected_payment_amount, 0) = TRUNC(P_ENTRY_VALUE, 0) THEN
            UPDATE ATET_SB_PAYMENTS_SCHEDULE ASPS
               SET ASPS.STATUS_FLAG = 'PAYED',
                   ASPS.LAST_UPDATE_DATE = SYSDATE,
                   ASPS.LAST_UPDATED_BY = var_user_id
             WHERE ASPS.PAYMENT_SCHEDULE_ID = var_payment_schedule_id
               AND ASPS.LOAN_ID = var_loan_id;
        ELSIF P_ENTRY_VALUE > 0 THEN
            UPDATE ATET_SB_PAYMENTS_SCHEDULE ASPS
               SET ASPS.STATUS_FLAG = 'PARTIAL',
                   ASPS.ATTRIBUTE1 = ASPS.PAYMENT_CAPITAL - var_payment_capital,
                   ASPS.ATTRIBUTE2 = ASPS.PAYMENT_INTEREST - var_payment_interest,
                   ASPS.ATTRIBUTE3 = ASPS.PAYMENT_INTEREST_LATE - var_payment_interest_late,
                   ASPS.ATTRIBUTE6 = HAS_DISABILITIES(P_PERSON_ID, ASPS.TIME_PERIOD_ID),
                   ASPS.LAST_UPDATE_DATE = SYSDATE,
                   ASPS.LAST_UPDATED_BY = var_user_id
             WHERE ASPS.PAYMENT_SCHEDULE_ID = var_payment_schedule_id
               AND ASPS.LOAN_ID = var_loan_id;
        ELSIF P_ENTRY_VALUE = 0 THEN
            UPDATE ATET_SB_PAYMENTS_SCHEDULE ASPS
               SET ASPS.STATUS_FLAG = 'PARTIAL',
                   ASPS.ATTRIBUTE1 = ASPS.PAYMENT_CAPITAL - var_payment_capital,
                   ASPS.ATTRIBUTE2 = ASPS.PAYMENT_INTEREST - var_payment_interest,
                   ASPS.ATTRIBUTE3 = ASPS.PAYMENT_INTEREST_LATE - var_payment_interest_late,
                   ASPS.ATTRIBUTE6 = HAS_DISABILITIES(P_PERSON_ID, ASPS.TIME_PERIOD_ID),
                   ASPS.LAST_UPDATE_DATE = SYSDATE,
                   ASPS.LAST_UPDATED_BY = var_user_id
             WHERE ASPS.PAYMENT_SCHEDULE_ID = var_payment_schedule_id
               AND ASPS.LOAN_ID = var_loan_id;                   
        END IF;
        
        
        UPDATE ATET_SB_PAYMENTS_SCHEDULE ASPS
               SET ASPS.STATUS_FLAG = 'SKIP',
                   ASPS.ATTRIBUTE1 = ASPS.PAYMENT_CAPITAL,
                   ASPS.ATTRIBUTE2 = ASPS.PAYMENT_INTEREST,
                   ASPS.ATTRIBUTE3 = ASPS.PAYMENT_INTEREST_LATE,
                   ASPS.ATTRIBUTE6 = HAS_DISABILITIES(P_PERSON_ID, ASPS.TIME_PERIOD_ID),
                   ASPS.LAST_UPDATE_DATE = SYSDATE,
                   ASPS.LAST_UPDATED_BY = var_user_id
             WHERE 1 = 1
               AND ASPS.LOAN_ID = var_loan_id
               AND ASPS.PAYMENT_NUMBER BETWEEN 1 AND var_payment_number
               AND ASPS.STATUS_FLAG IN ('PENDING', 'EXPORTED');    
               
               
        /***********************  INTERESES  MORATORIOS  **********************/
        
        SELECT COUNT(ASPS.PAYMENT_SCHEDULE_ID)
          INTO var_validate
          FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
         WHERE 1 = 1
           AND ASPS.LOAN_ID = var_loan_id
           AND ASPS.STATUS_FLAG IN ('PENDING', 'EXPORTED')
           AND ASPS.PAYMENT_NUMBER > var_payment_number;
           
        IF var_validate = 0 THEN
            NULL;
        END IF;
        
        /**********************************************************************/
        
        
        SELECT COUNT(ASPS.PAYMENT_NUMBER)
          INTO var_validate
          FROM ATET_SB_PAYMENTS_SCHEDULE    ASPS
         WHERE 1 = 1
           AND ASPS.LOAN_ID = var_loan_id
           AND ASPS.STATUS_FLAG NOT IN ('PAYED');
           
        IF var_validate = 0 THEN
        
            UPDATE ATET_SB_LOANS ASL
               SET ASL.LOAN_STATUS_FLAG = 'PAYED'
             WHERE ASL.LOAN_ID = var_loan_id;

             
            MERGE INTO ATET_SB_MEMBERS      ASM
                 USING ATET_SB_ENDORSEMENTS ASE
                    ON (    ASE.LOAN_ID = var_loan_id
                        AND ASE.MEMBER_ENDORSEMENT_ID = ASM.MEMBER_ID)
            WHEN MATCHED THEN 
            UPDATE SET ASM.IS_ENDORSEMENT = 'N';      


            SELECT COUNT(ASL.LOAN_ID)
              INTO var_validate
              FROM ATET_SB_LOANS ASL
             WHERE 1 = 1
               AND ASL.MEMBER_ID = var_member_id
               AND ASL.LOAN_STATUS_FLAG = 'ACTIVE';

            IF var_validate = 0 THEN 
                MERGE INTO ATET_SB_MEMBERS      ASM
                     USING ATET_SB_ENDORSEMENTS ASE
                        ON (    ASE.LOAN_ID = var_loan_id
                            AND ASE.MEMBER_BORROWER_ID = ASM.MEMBER_ID)
                WHEN MATCHED THEN 
                UPDATE SET ASM.IS_BORROWER = 'N';
            END IF;
        
        END IF;
           
                                                  
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'MOVIMIENTO PROCESADO: *PRESTAMO*' || P_PAYROLL_RESULT_ID  || ','
                                                                              || P_PERSON_ID          || ','
                                                                              || P_RUN_RESULT_ID      || ','
                                                                              || P_EARNED_DATE        || ','
                                                                              || P_PERIOD_NAME        || ','
                                                                              || P_ELEMENT_NAME       || ','
                                                                              || P_ENTRY_NAME         || ','
                                                                              || P_ENTRY_UNITS        || ','
                                                                              || P_ENTRY_VALUE        || ','
                                                                              || P_DEBIT_AMOUNT       || ','
                                                                              || P_CREDIT_AMOUNT      || '.'); 
                                                                              
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT_LOAN_TRANSACTION(P_EXPORT_REQUEST_ID => ' || P_EXPORT_REQUEST_ID ||
                                                               ',P_PAYROLL_RESULT_ID => ' || P_PAYROLL_RESULT_ID ||
                                                               ',P_PERSON_ID => ' || P_PERSON_ID ||
                                                               ',P_RUN_RESULT_ID => ' || P_RUN_RESULT_ID ||
                                                               ',P_EARNED_DATE => ' || P_EARNED_DATE ||
                                                               ',P_TIME_PERIOD_ID => ' || P_TIME_PERIOD_ID ||
                                                               ',P_PERIOD_NAME => ' || P_PERIOD_NAME ||
                                                               ',P_ELEMENT_NAME => ' || P_ELEMENT_NAME ||
                                                               ',P_ENTRY_NAME => ' || P_ENTRY_NAME ||
                                                               ',P_ENTRY_UNITS => ' || P_ENTRY_UNITS ||
                                                               ',P_ENTRY_VALUE => ' || P_ENTRY_VALUE ||
                                                               ',P_DEBIT_AMOUNT => ' || P_DEBIT_AMOUNT ||
                                                               ',P_CREDIT_AMOUNT => ' || P_CREDIT_AMOUNT || ') RETURN Y');                          
    
        RETURN 'Y';
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'NO SE PROCESO EL MOVIMIENTO: *PRESTAMO*' || P_PAYROLL_RESULT_ID  || ','
                                                                                  || P_PERSON_ID          || ','
                                                                                  || P_RUN_RESULT_ID      || ','
                                                                                  || P_EARNED_DATE        || ','
                                                                                  || P_PERIOD_NAME        || ','
                                                                                  || P_ELEMENT_NAME       || ','
                                                                                  || P_ENTRY_NAME         || ','
                                                                                  || P_ENTRY_UNITS        || ','
                                                                                  || P_ENTRY_VALUE        || ','
                                                                                  || P_DEBIT_AMOUNT       || ','
                                                                                  || P_CREDIT_AMOUNT      || '.' || SQLERRM);
                                                                                  
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSERT_LOAN_TRANSACTION(P_EXPORT_REQUEST_ID => ' || P_EXPORT_REQUEST_ID ||
                                                               ',P_PAYROLL_RESULT_ID => ' || P_PAYROLL_RESULT_ID ||
                                                               ',P_PERSON_ID => ' || P_PERSON_ID ||
                                                               ',P_RUN_RESULT_ID => ' || P_RUN_RESULT_ID ||
                                                               ',P_EARNED_DATE => ' || P_EARNED_DATE ||
                                                               ',P_TIME_PERIOD_ID => ' || P_TIME_PERIOD_ID ||
                                                               ',P_PERIOD_NAME => ' || P_PERIOD_NAME ||
                                                               ',P_ELEMENT_NAME => ' || P_ELEMENT_NAME ||
                                                               ',P_ENTRY_NAME => ' || P_ENTRY_NAME ||
                                                               ',P_ENTRY_UNITS => ' || P_ENTRY_UNITS ||
                                                               ',P_ENTRY_VALUE => ' || P_ENTRY_VALUE ||
                                                               ',P_DEBIT_AMOUNT => ' || P_DEBIT_AMOUNT ||
                                                               ',P_CREDIT_AMOUNT => ' || P_CREDIT_AMOUNT || ') RETURN N');
                                                               
        ROLLBACK;
        RETURN 'N';
    END INSERT_LOAN_TRANSACTION;

    FUNCTION    GET_SAVING_MEMBER_ACCOUNT_ID(P_MEMBER_ID            NUMBER,
                                             P_ACCOUNT_NUMBER       VARCHAR2,
                                             P_ACCOUNT_DESCRIPTION  VARCHAR2)
      RETURN    NUMBER
    IS
        var_member_account_id   NUMBER;
    BEGIN
    
        SELECT ASMA.MEMBER_ACCOUNT_ID
          INTO var_member_account_id
          FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
         WHERE 1 = 1
           AND ASMA.MEMBER_ID = P_MEMBER_ID
           AND ASMA.ACCOUNT_NUMBER = P_ACCOUNT_NUMBER
           AND ASMA.ACCOUNT_DESCRIPTION = P_ACCOUNT_DESCRIPTION;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_SAVING_MEMBER_ACCOUNT_ID(P_MEMBER_ID => ' || P_MEMBER_ID || 
                                                                    ',P_ACCOUNT_NUMBER => ' || P_ACCOUNT_NUMBER || 
                                                                    ',P_ACCOUNT_DESCRIPTION => ' || P_ACCOUNT_DESCRIPTION || 
                                                                    ') RETURN ' || var_member_account_id);
         
        RETURN var_member_account_id;

    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_SAVING_MEMBER_ACCOUNT_ID ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_SAVING_MEMBER_ACCOUNT_ID;
    
    
    FUNCTION    GET_LOAN_MEMBER_ACCOUNT_ID(P_MEMBER_ID          NUMBER,
                                           P_LOAN_ID            NUMBER)
      RETURN    NUMBER
    IS
        var_member_account_id   NUMBER;

    BEGIN
           
        BEGIN
        
            SELECT ASMA.MEMBER_ACCOUNT_ID
              INTO var_member_account_id
              FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
             WHERE 1 = 1
               AND ASMA.MEMBER_ID = P_MEMBER_ID
               AND ASMA.LOAN_ID = P_LOAN_ID
               AND ASMA.ACCOUNT_DESCRIPTION = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME');        
               
               DBMS_OUTPUT.PUT_LINE( 'SELECT ACCOUNT');
        
        EXCEPTION WHEN NO_DATA_FOUND THEN
           
            UPDATE ATET_SB_MEMBERS_ACCOUNTS ASMA
               SET ASMA.LOAN_ID = P_LOAN_ID
             WHERE 1 = 1
               AND ASMA.MEMBER_ID = P_MEMBER_ID
               AND ASMA.ACCOUNT_DESCRIPTION = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME')
               AND ASMA.LOAN_ID IS NULL; 
               
               DBMS_OUTPUT.PUT_LINE( 'UPDATE ACCOUNT');
               
            COMMIT;
            
            SELECT ASMA.MEMBER_ACCOUNT_ID
              INTO var_member_account_id
              FROM ATET_SB_MEMBERS_ACCOUNTS ASMA
             WHERE 1 = 1
               AND ASMA.MEMBER_ID = P_MEMBER_ID
               AND ASMA.LOAN_ID = P_LOAN_ID
               AND ASMA.ACCOUNT_DESCRIPTION = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME');  
        
            DBMS_OUTPUT.PUT_LINE( 'SELECT ACCOUNT');
        
        END;
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_LOAN_MEMBER_ACCOUNT_ID(P_MEMBER_ID => ' || P_MEMBER_ID || 
                                                                  ',P_LOAN_ID => ' || P_LOAN_ID || 
                                                                  ') RETURN ' || var_member_account_id);
    
        RETURN var_member_account_id;
    END GET_LOAN_MEMBER_ACCOUNT_ID;


    PROCEDURE   SET_LOAN_BALANCE(P_LOAN_ID            NUMBER,
                                 P_LOAN_AMOUNT        NUMBER,
                                 P_PERSON_ID          NUMBER)
    IS
        var_member_id           NUMBER := GET_MEMBER_ID(P_PERSON_ID);
        var_member_account_id   NUMBER;
        var_user_id             NUMBER := FND_GLOBAL.USER_ID;
        var_loan_number         NUMBER;
        var_loan_id             NUMBER;
    BEGIN
    
        SELECT ASL.LOAN_ID,
               ASL.LOAN_NUMBER
          INTO var_loan_id,
               var_loan_number
          FROM ATET_SB_LOANS    ASL
         WHERE 1 = 1
           AND ASL.MEMBER_ID = GET_MEMBER_ID(P_PERSON_ID)
           AND ASL.LOAN_ID = P_LOAN_ID;
           
           
            DBMS_OUTPUT.PUT_LINE( 'SELECT LOAN_ID, LOAN_NUMBER');     
           
        var_member_account_id := GET_LOAN_MEMBER_ACCOUNT_ID(GET_MEMBER_ID(P_PERSON_ID), P_LOAN_ID);
                                                          
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET DEBIT_BALANCE = DEBIT_BALANCE + P_LOAN_AMOUNT,
               CREDIT_BALANCE = CREDIT_BALANCE + 0,
               LAST_TRANSACTION_DATE = SYSDATE               
         WHERE MEMBER_ID = var_member_id
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
        UPDATE ATET_SB_MEMBERS_ACCOUNTS
           SET FINAL_BALANCE = DEBIT_BALANCE - CREDIT_BALANCE,
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = var_user_id             
         WHERE MEMBER_ID = var_member_id
           AND MEMBER_ACCOUNT_ID = var_member_account_id;
           
           
        INSERT INTO ATET_SB_LOANS_TRANSACTIONS(MEMBER_ACCOUNT_ID,
                                               MEMBER_ID,
                                               PAYROLL_RESULT_ID,
                                               LOAN_ID,
                                               PERSON_ID,
                                               EARNED_DATE,
                                               PERIOD_NAME,
                                               ELEMENT_NAME,
                                               TRANSACTION_CODE,
                                               DEBIT_AMOUNT,
                                               CREDIT_AMOUNT,
                                               CREATION_DATE,
                                               CREATED_BY,
                                               LAST_UPDATE_DATE,
                                               LAST_UPDATED_BY)
                                       VALUES (var_member_account_id,
                                               var_member_id,
                                               -1,
                                               P_LOAN_ID,
                                               P_PERSON_ID,
                                               SYSDATE,
                                               'APERTURA',
                                               'APERTURA DE PRESTAMO',
                                               'OPENING',
                                               P_LOAN_AMOUNT,
                                               0,
                                               SYSDATE,
                                               var_user_id,
                                               SYSDATE,
                                               var_user_id);
        
        COMMIT;

    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en SET_LOAN_BALANCE ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END SET_LOAN_BALANCE;
    
    
    PROCEDURE   INSERT_EXTEMPORANEOUS_SAVING(P_ERRBUF               OUT NOCOPY  VARCHAR2,
                                             P_RETCODE              OUT NOCOPY  VARCHAR2,
                                             P_PERSON_ID            NUMBER,
                                             P_SAVING_AMOUNT        NUMBER,
                                             P_PENDING_PAYMENT      NUMBER)
    IS
    
         var_person_id                  NUMBER;
         var_employee_number            NUMBER;
         var_employee_full_name         VARCHAR2(300);
         var_person_type                VARCHAR2(300);
         var_seniority_years            NUMBER;
         var_rfc                        VARCHAR2(300);
         var_curp                       VARCHAR2(300);
         var_sex                        VARCHAR2(300);
         var_email_address              VARCHAR2(300);
         var_effective_hire_date        DATE;
         var_member_start_date          DATE;
         var_is_saver                   VARCHAR2(10);
         var_is_borrower                VARCHAR2(10);
         var_is_endorsement             VARCHAR2(10);
         var_assignment_id              NUMBER;
         var_payroll_id                 NUMBER;
         var_period_type                VARCHAR2(300);
         var_max_assignment_action_id   NUMBER;
         var_max_per_sav                NUMBER;
         var_max_sav_amt_sm             NUMBER;
         var_max_sav_amt_wk             NUMBER;
         var_posibility_saving          NUMBER;
         var_real_posibility_saving     NUMBER;
         var_isrret                     NUMBER;
         var_subtbr                     NUMBER;
         var_mondet                     NUMBER;
         var_validate                   VARCHAR2(1) := 'N';
         var_min_sav_amt_sm             NUMBER;
         var_min_sav_amt_wk             NUMBER;
         var_saving_bank_id             NUMBER := ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID;
    BEGIN
        
        IF TO_DATE(GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'REG_EXTEMPORANEOUS_DATE'), 'RRRR/MM/DD') > SYSDATE THEN
            
            SELECT PPF.PERSON_ID                                                  AS  "PERSON_ID",
                 PPF.EMPLOYEE_NUMBER                                              AS  "EMPLOYEE_NUMBER",
                 PPF.FULL_NAME                                                    AS  "EMPLOYEE_NAME",
                 UPPER(PPTT.USER_PERSON_TYPE)                                     AS  "PERSON_TYPE",
                 TRUNC(HR_MX_UTILITY.GET_SENIORITY_SOCIAL_SECURITY(PPF.PERSON_ID, 
                                                                   SYSDATE))      AS  "SENIORITY_YEARS",
                 PPF.PER_INFORMATION2                                             AS  "RFC",
                 PPF.NATIONAL_IDENTIFIER                                          AS  "CURP",
                 UPPER(PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('SEX', 
                                                         PPF.SEX))                AS  "SEX",
                 PPF.EMAIL_ADDRESS                                                AS  "EMAIL_ADDRESS",
                 PAC_RESULT_VALUES_PKG.GET_EFFECTIVE_START_DATE(PPF.PERSON_ID)    AS  "FFECTIVE_START_DATE",
                 SYSDATE,
                 'Y'                                                              AS  "IS_SAVER",
                 'N'                                                              AS  "IS_BORROWER",
                 'N'                                                              AS  "IS_ENDORSEMENT",
                 PAF.ASSIGNMENT_ID,
                 PAF.PAYROLL_ID
            INTO var_person_id,
                 var_employee_number,
                 var_employee_full_name,
                 var_person_type,
                 var_seniority_years,
                 var_rfc,
                 var_curp,
                 var_sex,
                 var_email_address,
                 var_effective_hire_date,
                 var_member_start_date,
                 var_is_saver,
                 var_is_borrower,
                 var_is_endorsement,
                 var_assignment_id,
                 var_payroll_id
            FROM PER_PEOPLE_F             PPF,
                 PER_PERSON_TYPES_TL      PPTT,
                 PER_ASSIGNMENTS_F        PAF,
                 PER_PERIODS_OF_SERVICE   PPOS
            WHERE 1 = 1
             AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
             AND PPF.PERSON_TYPE_ID = PPTT.PERSON_TYPE_ID
             AND LANGUAGE = USERENV('LANG')
             AND PPTT.USER_PERSON_TYPE IN ('Employee', 'Empleado')
             AND PPF.PERSON_ID = PAF.PERSON_ID
             AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
             AND PPOS.PERSON_ID = PPF.PERSON_ID
             AND PPOS.PERIOD_OF_SERVICE_ID = PAF.PERIOD_OF_SERVICE_ID
             AND PPF.PERSON_ID = P_PERSON_ID
            ORDER BY TO_NUMBER(PPF.EMPLOYEE_NUMBER);
            
            IF ATET_SAVINGS_BANK_PKG.IF_MEMBER_EXIST(var_employee_number) = 0 THEN
            
                var_period_type := ATET_SAVINGS_BANK_PKG.GET_PERIOD_TYPE(var_person_id);
                var_max_assignment_action_id := ATET_SAVINGS_BANK_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(var_assignment_id, var_payroll_id);
                var_subtbr := ATET_SAVINGS_BANK_PKG.GET_SUBTBR(var_max_assignment_action_id);
                var_isrret := ATET_SAVINGS_BANK_PKG.GET_ISRRET(var_max_assignment_action_id);
                var_mondet := ATET_SAVINGS_BANK_PKG.GET_MONDET(var_max_assignment_action_id);
                            
            
                var_max_per_sav := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_PER_SAV');
                var_max_sav_amt_sm := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_SAV_AMT_SM');
                var_max_sav_amt_wk := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_SAV_AMT_WK');
                var_min_sav_amt_sm := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MIN_SAV_AMT_SM');
                var_min_sav_amt_wk := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MIN_SAV_AMT_WK');
                var_posibility_saving := (var_subtbr - (var_isrret + var_mondet)) * (var_max_per_sav / 100);
            
                IF    var_period_type IN ('Week', 'Semana') THEN
                
                  IF var_posibility_saving > var_max_sav_amt_wk THEN
                    var_real_posibility_saving := TRUNC(var_max_sav_amt_wk);
                  ELSE
                    var_real_posibility_saving := TRUNC(var_posibility_saving);
                  END IF;
                
                ELSIF var_period_type IN ('Semi-Month', 'Quincena') THEN
                
                  IF var_posibility_saving > var_max_sav_amt_sm THEN
                    var_real_posibility_saving := TRUNC(var_max_sav_amt_sm);
                  ELSE
                    var_real_posibility_saving := TRUNC(var_posibility_saving);
                  END IF;
                
                END IF;
                
                
                IF    var_period_type IN ('Semana', 'Week') THEN
                
                  IF    P_SAVING_AMOUNT < var_min_sav_amt_wk THEN
                    var_validate := 'N';
                  ELSIF P_SAVING_AMOUNT > var_real_posibility_saving THEN
                    var_validate := 'N';
                  ELSE
                    var_validate := 'Y';
                  END IF;
                
                ELSIF var_period_type IN ('Quincena', 'Semi-Month') THEN
                
                  IF    P_SAVING_AMOUNT < var_min_sav_amt_sm THEN
                    var_validate := 'N';
                  ELSIF P_SAVING_AMOUNT > var_real_posibility_saving THEN
                    var_validate := 'N';
                  ELSE
                    var_validate := 'Y';
                  END IF; 
                
                END IF;
                
                
                IF var_validate = 'Y' THEN
                    
                    INSERT INTO ATET_SB_MEMBERS (SAVING_BANK_ID,
                                                 PERSON_ID,
                                                 EMPLOYEE_NUMBER,
                                                 EMPLOYEE_FULL_NAME,
                                                 PERSON_TYPE,
                                                 SENIORITY_YEARS,
                                                 RFC,
                                                 CURP,
                                                 SEX,
                                                 EMAIL_ADDRESS,
                                                 AMOUNT_TO_SAVE,
                                                 ATTRIBUTE2,
                                                 ATTRIBUTE3,
                                                 EFFECTIVE_HIRE_DATE,
                                                 MEMBER_START_DATE,
                                                 IS_SAVER,
                                                 IS_BORROWER,
                                                 IS_ENDORSEMENT,
                                                 ATTRIBUTE6,                                                 
                                                 CREATION_DATE,
                                                 CREATED_BY,
                                                 LAST_UPDATE_DATE,
                                                 LAST_UPDATED_BY)
                                         VALUES (var_saving_bank_id,
                                                 var_person_id,
                                                 var_employee_number,
                                                 var_employee_full_name,
                                                 var_person_type,
                                                 var_seniority_years,
                                                 var_rfc,
                                                 var_curp,
                                                 var_sex,
                                                 var_email_address,
                                                 P_SAVING_AMOUNT * (1 + P_PENDING_PAYMENT),
                                                 P_PENDING_PAYMENT,
                                                 P_SAVING_AMOUNT,
                                                 var_effective_hire_date,
                                                 TO_DATE(var_member_start_date, 'DD/MM/RRRR'),
                                                 var_is_saver,
                                                 var_is_borrower,
                                                 var_is_endorsement,
                                                 var_period_type,
                                                 SYSDATE,
                                                 FND_GLOBAL.USER_ID,
                                                 SYSDATE,
                                                 FND_GLOBAL.USER_ID); 
                                                 
                    COMMIT;
                    
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '****************AHORRO INGRESADO****************');
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Número de empleado : ' || var_employee_number);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Nombre de empleado : ' || var_employee_full_name);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Tipo de persona : ' || var_person_type);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Antigüedad : ' || var_seniority_years);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'RFC : ' || var_rfc);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'CURP :' || var_curp);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Sexo : ' || var_sex);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'e-mail : ' || var_email_address);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Monto de ahorro :' || P_SAVING_AMOUNT);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Periodos pendientes :' || P_PENDING_PAYMENT);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Siguiente descuento :' || TO_CHAR(P_SAVING_AMOUNT * (1 + P_PENDING_PAYMENT)));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Fecha de Inscripción :' || TO_CHAR(var_member_start_date));
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '***********************************************');
                
                ELSE
                    P_ERRBUF := 'La cantidad de ahorro ingresada excede la posibilidad de ahorro del empleado.';
                    P_RETCODE := 1;
                END IF;
            
            ELSE
                P_ERRBUF := 'El empleado ingresado ya es miembro de la caja de ahorro.';
                P_RETCODE := 1;
            END IF;
        
        ELSE
            P_ERRBUF := 'La fecha de registro ha vencido para este proceso.';
            P_RETCODE := 1;
        END IF;
    
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en INSERT_EXTEMPORANEOUS_SAVING ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END INSERT_EXTEMPORANEOUS_SAVING;
    
    
    FUNCTION    GET_POSIBILITY_SAVING(P_PERSON_ID           NUMBER)
      RETURN    NUMBER
    IS
         var_period_type                VARCHAR2(100);
         var_assignment_id               NUMBER;
         var_payroll_id                 NUMBER;
         var_max_assignment_action_id   NUMBER;
         var_max_per_sav                NUMBER;
         var_posibility_saving          NUMBER;
         var_isrret                     NUMBER;
         var_subtbr                     NUMBER;
         var_mondet                     NUMBER;
         var_saving_bank_id             NUMBER := ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID;
         var_max_sav_amt_sm             NUMBER;
         var_max_sav_amt_wk             NUMBER;
    BEGIN
    
        SELECT PAF.ASSIGNMENT_ID,
               PAF.PAYROLL_ID
          INTO var_assignment_id,
               var_payroll_id
          FROM PER_ASSIGNMENTS_F    PAF
         WHERE 1 = 1
           AND PAF.PERSON_ID = P_PERSON_ID
           AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE;
          
    
        var_period_type := ATET_SAVINGS_BANK_PKG.GET_PERIOD_TYPE(P_PERSON_ID);   
        var_max_assignment_action_id := ATET_SAVINGS_BANK_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(var_assignment_id, var_payroll_id);
        var_subtbr := ATET_SAVINGS_BANK_PKG.GET_SUBTBR(var_max_assignment_action_id);
        var_isrret := ATET_SAVINGS_BANK_PKG.GET_ISRRET(var_max_assignment_action_id);
        var_mondet := ATET_SAVINGS_BANK_PKG.GET_MONDET(var_max_assignment_action_id);
        var_max_per_sav := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_PER_SAV');
--        var_posibility_saving := (var_subtbr - (var_isrret + var_mondet)) * (var_max_per_sav / 100);
        var_posibility_saving := (var_subtbr) * (var_max_per_sav / 100);
        var_max_sav_amt_sm := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_SAV_AMT_SM');
        var_max_sav_amt_wk := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_SAV_AMT_WK');
        
        IF    var_period_type IN ('Week', 'Semana') THEN
          IF var_posibility_saving > var_max_sav_amt_wk THEN
            var_posibility_saving := TRUNC(var_max_sav_amt_wk);
          ELSE
            var_posibility_saving := TRUNC(var_posibility_saving);
          END IF;
        ELSIF var_period_type IN ('Semi-Month', 'Quincena') THEN
          IF var_posibility_saving > var_max_sav_amt_sm THEN
            var_posibility_saving := TRUNC(var_max_sav_amt_sm);
          ELSE
            var_posibility_saving := TRUNC(var_posibility_saving);
          END IF;
        END IF;
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_POSIBILITY_SAVING(P_PERSON_ID => ' || P_PERSON_ID || 
                                                              ') RETURN ' || var_posibility_saving); 
    
        RETURN var_posibility_saving;
        
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_POSIBILITY_SAVING ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_POSIBILITY_SAVING;
        
    
    FUNCTION    GET_RESULT_FROM_PAYROLL_RESULT(P_PERSON_ID                 NUMBER,
                                               P_EXPORT_REQUEST_ID         NUMBER,
                                               P_RUN_RESULT_ID             NUMBER,
                                               P_ENTRY_NAME                VARCHAR2)
      RETURN    NUMBER
    IS
        var_result      NUMBER;
    BEGIN 
    
        SELECT ASPR.ENTRY_VALUE
          INTO var_result
          FROM ATET_SB_PAYROLL_RESULTS  ASPR
         WHERE 1 = 1
           AND ASPR.PERSON_ID = P_PERSON_ID
           AND ASPR.EXPORT_REQUEST_ID = P_EXPORT_REQUEST_ID
           AND ASPR.RUN_RESULT_ID = P_RUN_RESULT_ID
           AND ASPR.ENTRY_NAME = P_ENTRY_NAME;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_RESULT_FROM_PAYROLL_RESULT(P_PERSON_ID => ' || P_PERSON_ID || 
                                                                      ',P_EXPORT_REQUEST_ID => ' || P_EXPORT_REQUEST_ID || 
                                                                      ',P_RUN_RESULT_ID => ' || P_RUN_RESULT_ID || 
                                                                      ',P_ENTRY_NAME => ' || P_ENTRY_NAME || 
                                                                      ') RETURN ' || var_result);
    
        RETURN var_result;
       
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END GET_RESULT_FROM_PAYROLL_RESULT;
    
    
    FUNCTION    GET_LOAN_ID(P_MEMBER_ID     NUMBER,
                            P_LOAN_NUMBER   NUMBER)
      RETURN    NUMBER
    IS
        var_result  NUMBER;
    BEGIN
    
        SELECT ASL.LOAN_ID
          INTO var_result
          FROM ATET_SB_LOANS    ASL,
               ATET_SB_MEMBERS  ASM
         WHERE 1 = 1
           AND ASL.LOAN_NUMBER = P_LOAN_NUMBER
           AND ASL.MEMBER_ID = ASM.MEMBER_ID
           AND ASM.MEMBER_ID = P_MEMBER_ID
           AND ASM.SAVING_BANK_ID = GET_SAVING_BANK_ID;
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_LOAN_ID(P_MEMBER_ID => ' || P_MEMBER_ID || 
                                                   ',P_LOAN_NUMBER => ' || P_LOAN_NUMBER || 
                                                   ') RETURN ' || var_result);
    
        RETURN var_result;
        
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_LOAN_ID(P_MEMBER_ID, P_LOAN_NUMBER) ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_LOAN_ID;
    
    
    FUNCTION    GET_LOAN_ID(P_PERSON_ID         NUMBER,
                            P_PAYMENT_AMOUNT    NUMBER)
      RETURN    NUMBER
    IS
        var_result  NUMBER;
    BEGIN
    
        SELECT ASL.LOAN_ID
          INTO var_result
          FROM ATET_SB_MEMBERS              ASM,
               ATET_SB_LOANS                ASL,
               ATET_SB_PAYMENTS_SCHEDULE    ASPS
         WHERE ASM.PERSON_ID = P_PERSON_ID
           AND ASM.SAVING_BANK_ID = ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID
           AND ASM.MEMBER_ID = ASL.MEMBER_ID
           AND ASL.LOAN_STATUS_FLAG = 'ACTIVE'
           AND ASL.LOAN_ID = ASPS.LOAN_ID
           AND ASPS.PAYMENT_NUMBER = 1
           AND TRUNC(ASPS.PAYMENT_AMOUNT, 0) = TRUNC(P_PAYMENT_AMOUNT,0);
           
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_LOAN_ID(P_PERSON_ID => ' || P_PERSON_ID || 
                                                   ',P_PAYMENT_AMOUNT => ' || P_PAYMENT_AMOUNT || 
                                                   ') RETURN ' || var_result); 
    
        RETURN var_result;
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en GET_LOAN_ID(P_PERSON_ID, P_PAYMENT_AMOUNT) ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END GET_LOAN_ID;
      
    
    
    PROCEDURE   SEND_TO_XLA(P_ERRBUF         OUT NOCOPY  VARCHAR2,
                            P_RETCODE        OUT NOCOPY  VARCHAR2,
                            P_PERIOD_TYPE    VARCHAR2,
                            P_YEAR           NUMBER,
                            P_MONTH          NUMBER,
                            P_PERIOD_NAME    VARCHAR2,
                            P_ELEMENT_NAME   VARCHAR2)
    IS
    
        CURSOR DETAILS_COMPANIES IS
            SELECT DISTINCT SUBSTR(PPF.PAYROLL_NAME, 0, 2) AS COMPANY_CODE
              FROM PAY_PAYROLLS_F   PPF
             WHERE 1 = 1
               AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE;
    
        CURSOR DETAILS_SAVINGS(PP_PERIOD_NAME   VARCHAR2, 
                               PP_ELEMENT_NAME  VARCHAR2, 
                               PP_COMPANY_CODE  VARCHAR2) IS
            SELECT ASST.SAVING_TRANSACTION_ID,
                   ASMA.CODE_COMBINATION_ID,
                   ASMA.ACCOUNT_NUMBER,
                   ASST.MEMBER_ID,
                   ASM.EMPLOYEE_FULL_NAME,
                   ASST.PERSON_ID,
                   ASST.ENTRY_VALUE,
                   ASST.DEBIT_AMOUNT,
                   ASST.CREDIT_AMOUNT
              FROM ATET_SB_SAVINGS_TRANSACTIONS ASST,
                   ATET_SB_MEMBERS              ASM,
                   ATET_SB_MEMBERS_ACCOUNTS     ASMA,
                   PER_ASSIGNMENTS_F            PAF,
                   PAY_PAYROLLS_F               PPF 
             WHERE ASST.PERIOD_NAME = PP_PERIOD_NAME
               AND ASST.ELEMENT_NAME = PP_ELEMENT_NAME 
               AND ASST.ACCOUNTED_FLAG = 'UNACCOUNTED'
               AND ASST.MEMBER_ID = ASM.MEMBER_ID
               AND ASM.MEMBER_ID = ASMA.MEMBER_ID
               AND ASST.MEMBER_ACCOUNT_ID = ASMA.MEMBER_ACCOUNT_ID
               AND ASST.PERSON_ID = PAF.PERSON_ID
               AND ASST.EARNED_DATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
               AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
               AND ASST.EARNED_DATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
               AND SUBSTR(PPF.PAYROLL_NAME, 0, 2) = PP_COMPANY_CODE;
               
        CURSOR DETAILS_LOANS (PP_PERIOD_NAME   VARCHAR2, 
                              PP_ELEMENT_NAME  VARCHAR2, 
                              PP_COMPANY_CODE  VARCHAR2) IS
            SELECT ASLT.LOAN_TRANSACTION_ID,
                   ASMA.CODE_COMBINATION_ID,
                   ASMA.ACCOUNT_NUMBER,
                   ASLT.MEMBER_ID,
                   ASM.EMPLOYEE_FULL_NAME,
                   ASLT.PERSON_ID,
                   ASLT.PAYMENT_AMOUNT,
                   ASL.LOAN_NUMBER
              FROM ATET_SB_LOANS_TRANSACTIONS   ASLT,
                   ATET_SB_MEMBERS              ASM,
                   ATET_SB_MEMBERS_ACCOUNTS     ASMA,
                   ATET_SB_LOANS                ASL,
                   PER_ASSIGNMENTS_F            PAF,
                   PAY_PAYROLLS_F               PPF 
             WHERE ASLT.PERIOD_NAME = PP_PERIOD_NAME
               AND ASLT.ELEMENT_NAME = PP_ELEMENT_NAME 
               AND ASLT.ACCOUNTED_FLAG = 'UNACCOUNTED'
               AND ASLT.MEMBER_ID = ASM.MEMBER_ID
               AND ASM.MEMBER_ID = ASMA.MEMBER_ID
               AND ASLT.MEMBER_ACCOUNT_ID = ASMA.MEMBER_ACCOUNT_ID
               AND ASLT.MEMBER_ID = ASL.MEMBER_ID
               AND ASLT.LOAN_ID = ASL.LOAN_ID
               AND ASLT.PERSON_ID = PAF.PERSON_ID
               AND ASLT.EARNED_DATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
               AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
               AND ASLT.EARNED_DATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
               AND SUBSTR(PPF.PAYROLL_NAME, 0, 2) = PP_COMPANY_CODE;
               
        CURSOR DETAILS_INTERESTS (PP_PERIOD_NAME   VARCHAR2, 
                                  PP_ELEMENT_NAME  VARCHAR2, 
                                  PP_COMPANY_CODE  VARCHAR2) IS
            SELECT ASLT.LOAN_TRANSACTION_ID,
                   ASMA.CODE_COMBINATION_ID,
                   ASMA.ACCOUNT_NUMBER,
                   ASLT.MEMBER_ID,
                   ASM.EMPLOYEE_FULL_NAME,
                   ASLT.PERSON_ID,
                   ASLT.PAYMENT_INTEREST,
                   ASL.LOAN_NUMBER
              FROM ATET_SB_LOANS_TRANSACTIONS   ASLT,
                   ATET_SB_MEMBERS              ASM,
                   ATET_SB_MEMBERS_ACCOUNTS     ASMA,
                   ATET_SB_LOANS                ASL,
                   PER_ASSIGNMENTS_F            PAF,
                   PAY_PAYROLLS_F               PPF 
             WHERE ASLT.PERIOD_NAME = PP_PERIOD_NAME
               AND ASLT.ELEMENT_NAME = PP_ELEMENT_NAME
               AND ASLT.MEMBER_ID = ASM.MEMBER_ID
               AND ASM.MEMBER_ID = ASMA.MEMBER_ID
               AND ASLT.MEMBER_ACCOUNT_ID = ASMA.MEMBER_ACCOUNT_ID
               AND ASLT.MEMBER_ID = ASL.MEMBER_ID
               AND ASLT.LOAN_ID = ASL.LOAN_ID
               AND ASLT.PERSON_ID = PAF.PERSON_ID
               AND ASLT.EARNED_DATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
               AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
               AND ASLT.EARNED_DATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
               AND SUBSTR(PPF.PAYROLL_NAME, 0, 2) = PP_COMPANY_CODE;
               
        CURSOR DETAILS_INTERESTS_LATE (PP_PERIOD_NAME   VARCHAR2, 
                                       PP_ELEMENT_NAME  VARCHAR2, 
                                       PP_COMPANY_CODE  VARCHAR2) IS
            SELECT ASLT.LOAN_TRANSACTION_ID,
                   ASMA.CODE_COMBINATION_ID,
                   ASMA.ACCOUNT_NUMBER,
                   ASLT.MEMBER_ID,
                   ASM.EMPLOYEE_FULL_NAME,
                   ASLT.PERSON_ID,
                   ASLT.PAYMENT_INTEREST_LATE,
                   ASL.LOAN_NUMBER
              FROM ATET_SB_LOANS_TRANSACTIONS   ASLT,
                   ATET_SB_MEMBERS              ASM,
                   ATET_SB_MEMBERS_ACCOUNTS     ASMA,
                   ATET_SB_LOANS                ASL,
                   PER_ASSIGNMENTS_F            PAF,
                   PAY_PAYROLLS_F               PPF 
             WHERE ASLT.PERIOD_NAME = PP_PERIOD_NAME
               AND ASLT.ELEMENT_NAME = PP_ELEMENT_NAME
               AND ASLT.MEMBER_ID = ASM.MEMBER_ID
               AND ASM.MEMBER_ID = ASMA.MEMBER_ID
               AND ASLT.MEMBER_ACCOUNT_ID = ASMA.MEMBER_ACCOUNT_ID
               AND ASLT.MEMBER_ID = ASL.MEMBER_ID
               AND ASLT.LOAN_ID = ASL.LOAN_ID
               AND ASLT.PERSON_ID = PAF.PERSON_ID
               AND ASLT.EARNED_DATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
               AND PAF.PAYROLL_ID = PPF.PAYROLL_ID
               AND ASLT.EARNED_DATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
               AND ASLT.PAYMENT_INTEREST_LATE <> 0
               AND SUBSTR(PPF.PAYROLL_NAME, 0, 2) = PP_COMPANY_CODE;
               
        var_saving_debit_amount         NUMBER;
        var_saving_credit_amount        NUMBER;
        
        var_loan_debit_amount           NUMBER;
        var_loan_credit_amount          NUMBER;
        
        var_deb_cs_code_comb            VARCHAR2(500);
        var_deb_pac_code_comb           VARCHAR2(500);
        var_not_rec_sav_code_comb       VARCHAR2(500);
        var_not_rec_no_sav_code_comb    VARCHAR2(500);
        var_une_int_code_comb           VARCHAR2(500);
        var_int_rec_code_comb           VARCHAR2(500);
        
        var_deb_cs_account_id           NUMBER;
        var_deb_pac_account_id          NUMBER;
        var_not_rec_sav_account_id      NUMBER;
        var_not_rec_no_sav_account_id   NUMBER;
        var_une_int_account_id          NUMBER;
        var_int_rec_account_id          NUMBER;
        
        var_header_id                   NUMBER;
        var_index                       NUMBER := 0;
        var_description                 VARCHAR2(500);
        
        var_user_id                     NUMBER := FND_GLOBAL.USER_ID;
        
    BEGIN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '***********     PARAMETERS     ***********');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_PERIOD_TYPE : ' || P_PERIOD_TYPE);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_YEAR : ' || P_YEAR);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_MONTH : ' || P_MONTH);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_PERIOD_NAME : ' || P_PERIOD_NAME);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'P_ELEMENT_NAME : ' || P_ELEMENT_NAME);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '******************************************');
        
        IF    P_ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'SAVINGS_ELEMENT_NAME') THEN
            
            var_deb_cs_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'DEB_CS_CODE_COMB');
            var_deb_pac_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'DEB_PAC_CODE_COMB');
            var_deb_cs_account_id := GET_CODE_COMBINATION_ID(var_deb_cs_code_comb);
            var_deb_pac_account_id := GET_CODE_COMBINATION_ID(var_deb_pac_code_comb);
            
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_deb_cs_code_comb);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_deb_pac_code_comb);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_deb_cs_account_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_deb_pac_account_id);
            
            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (P_ENTITY_CODE        => 'PAYROLL',
                                                       P_EVENT_TYPE_CODE    => 'PAYROLL_SAVINGS',
                                                       P_BATCH_NAME         => 'APORTACIONES DE AHORRO',
                                                       P_JOURNAL_NAME       => UPPER(P_PERIOD_NAME || '-' || P_ELEMENT_NAME),
                                                       P_HEADER_ID          => var_header_id);

            FND_FILE.PUT_LINE(FND_FILE.LOG, 'HEADER_ID : ' || var_header_id);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('CUENTA', 35, ' ') || 
                                               RPAD('DESCRIPCION', 50, ' ') || 
                                               LPAD('CARGO', 30, ' ') || 
                                               LPAD('ABONO', 30, ' '));             
            
            FOR detail_company IN DETAILS_COMPANIES LOOP
            
                var_saving_debit_amount := 0;
                var_saving_credit_amount := 0;
                var_description := '';
                
                FOR detail_saving IN DETAILS_SAVINGS(P_PERIOD_NAME, 
                                                     P_ELEMENT_NAME, 
                                                     detail_company.COMPANY_CODE) LOOP
                    var_saving_debit_amount := var_saving_debit_amount + detail_saving.ENTRY_VALUE;
                END LOOP;
                
                /*****************************************************/
                /*          CARGO   :   DEUDORES DIVERSOS            */
                /*****************************************************/
                IF detail_company.COMPANY_CODE = '02' AND var_saving_debit_amount > 0 THEN
                
                    var_index := var_index + 1;
                
                    var_description := UPPER('Aportaciones de ahorro (El Calvario Servicios)');
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_deb_cs_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_SAVINGS',
                                                             P_ACCOUNTED_DR            => var_saving_debit_amount,
                                                             P_ACCOUNTED_CR            => var_saving_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => -1,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_deb_cs_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_saving_debit_amount, 30, ' ') || 
                                                       LPAD(var_saving_credit_amount, 30, ' '));
                    
                ELSIF detail_company.COMPANY_CODE = '11' AND var_saving_debit_amount > 0 THEN
                
                    var_index := var_index + 1;
                
                    var_description := UPPER('Aportaciones de ahorro (Productos Avicolas El Calvario)');
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_deb_pac_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_SAVINGS',
                                                             P_ACCOUNTED_DR            => var_saving_debit_amount,
                                                             P_ACCOUNTED_CR            => var_saving_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => -1,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_deb_pac_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_saving_debit_amount, 30, ' ') || 
                                                       LPAD(var_saving_credit_amount, 30, ' '));                                         
                                                                                 
                END IF;
                
                /*****************************************************/
                /*          ABONO   :   APORTACIONES POR PAGAR       */
                /*****************************************************/
                FOR detail_saving IN DETAILS_SAVINGS(P_PERIOD_NAME, 
                                                     P_ELEMENT_NAME, 
                                                     detail_company.COMPANY_CODE) LOOP
                    var_saving_debit_amount := 0;                                                     
                    var_saving_credit_amount := 0;
                    var_index := var_index + 1;
                    var_description := '';
                                                     
                    var_saving_credit_amount := detail_saving.CREDIT_AMOUNT;
                    var_description := detail_saving.EMPLOYEE_FULL_NAME || '|' || var_saving_credit_amount;
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => detail_saving.CODE_COMBINATION_ID,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_SAVINGS',
                                                             P_ACCOUNTED_DR            => var_saving_debit_amount,
                                                             P_ACCOUNTED_CR            => var_saving_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => detail_saving.SAVING_TRANSACTION_ID,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_SAVINGS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(detail_saving.ACCOUNT_NUMBER, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_saving_debit_amount, 30, ' ') || 
                                                       LPAD(var_saving_credit_amount, 30, ' '));
                    
                    UPDATE ATET_SB_SAVINGS_TRANSACTIONS ASST
                       SET ASST.ACCOUNTED_FLAG = 'ACCOUNTED',
                           ASST.LAST_UPDATE_DATE = SYSDATE,
                           ASST.LAST_UPDATED_BY = var_user_id
                     WHERE 1 = 1 
                       AND ASST.SAVING_TRANSACTION_ID = detail_saving.SAVING_TRANSACTION_ID;
                       
                    COMMIT;
                    
                END LOOP;
                
                
            
            END LOOP;
            
        ELSIF P_ELEMENT_NAME = GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'LOAN_ELEMENT_NAME') THEN
            
            var_deb_cs_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'DEB_CS_CODE_COMB');
            var_deb_pac_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'DEB_PAC_CODE_COMB');
            var_not_rec_sav_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'NOT_REC_SAV_CODE_COMB');
            var_not_rec_no_sav_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'NOT_REC_NO_SAV_CODE_COMB');
            var_une_int_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'UNE_INT_CODE_COMB');
            var_int_rec_code_comb := GET_PARAMETER_VALUE(GET_SAVING_BANK_ID, 'INT_REC_CODE_COMB');
            
            var_deb_cs_account_id := GET_CODE_COMBINATION_ID(var_deb_cs_code_comb);
            var_deb_pac_account_id := GET_CODE_COMBINATION_ID(var_deb_pac_code_comb);
            var_not_rec_sav_account_id := GET_CODE_COMBINATION_ID(var_not_rec_sav_code_comb);
            var_not_rec_no_sav_account_id := GET_CODE_COMBINATION_ID(var_not_rec_no_sav_code_comb);
            var_une_int_account_id := GET_CODE_COMBINATION_ID(var_une_int_code_comb);
            var_int_rec_account_id := GET_CODE_COMBINATION_ID(var_int_rec_code_comb);  
            
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_deb_cs_code_comb);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_deb_pac_code_comb);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_not_rec_sav_code_comb);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_not_rec_no_sav_code_comb);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_une_int_code_comb);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_int_rec_code_comb);
            
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_deb_cs_account_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_deb_pac_account_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_not_rec_sav_account_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_not_rec_no_sav_account_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_une_int_account_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG, var_int_rec_account_id);
            
            ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_HEADER (P_ENTITY_CODE        => 'PAYROLL',
                                                       P_EVENT_TYPE_CODE    => 'PAYROLL_LOANS',
                                                       P_BATCH_NAME         => 'PAGO DE PRESTAMOS',
                                                       P_JOURNAL_NAME       => UPPER(P_PERIOD_NAME || '-' || P_ELEMENT_NAME),
                                                       P_HEADER_ID          => var_header_id);

            FND_FILE.PUT_LINE(FND_FILE.LOG, 'HEADER_ID : ' || var_header_id);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('CUENTA', 35, ' ') || 
                                               RPAD('DESCRIPCION', 50, ' ') || 
                                               LPAD('CARGO', 30, ' ') || 
                                               LPAD('ABONO', 30, ' '));
            
            FOR detail_company IN DETAILS_COMPANIES LOOP
            
                var_loan_debit_amount := 0;
                var_loan_credit_amount := 0;
                var_description := '';
                
                FOR detail_loan IN DETAILS_LOANS(P_PERIOD_NAME, 
                                                 P_ELEMENT_NAME, 
                                                 detail_company.COMPANY_CODE) LOOP
                    var_loan_debit_amount := var_loan_debit_amount + detail_loan.PAYMENT_AMOUNT;
                END LOOP;
                
                /*****************************************************/
                /*          CARGO   :   DEUDORES DIVERSOS            */
                /*****************************************************/
                IF detail_company.COMPANY_CODE = '02' AND var_loan_debit_amount > 0 THEN
                
                    var_index := var_index + 1;
                
                    var_description := UPPER('Pago de prestamo de caja ahorro (El Calvario Servicios)');
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_deb_cs_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_LOANS',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => -1,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_deb_cs_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));
                    
                ELSIF detail_company.COMPANY_CODE = '11' AND var_loan_debit_amount > 0 THEN
                
                    var_index := var_index + 1;
                
                    var_description := UPPER('Pago de prestamo de caja ahorro (Productos Avicolas El Calvario)');
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_deb_pac_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_LOANS',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => -1,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_deb_pac_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));                                         
                                                                                 
                END IF;
                
                /*****************************************************/
                /*          ABONO   :   DOCUMENTOS POR COBRAR        */
                /*****************************************************/
                FOR detail_loan IN DETAILS_LOANS(P_PERIOD_NAME, 
                                                 P_ELEMENT_NAME, 
                                                 detail_company.COMPANY_CODE) LOOP
                    var_loan_debit_amount := 0;
                    var_loan_credit_amount := 0;
                    var_index := var_index + 1;
                    var_description := '';
                                                     
                    var_loan_credit_amount := detail_loan.PAYMENT_AMOUNT;
                    var_description := detail_loan.EMPLOYEE_FULL_NAME || '|' || detail_loan.LOAN_NUMBER || '|' || var_loan_credit_amount;
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => detail_loan.CODE_COMBINATION_ID,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_LOANS',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => detail_loan.LOAN_TRANSACTION_ID,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(detail_loan.ACCOUNT_NUMBER, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));
                    
                    UPDATE ATET_SB_LOANS_TRANSACTIONS ASLT
                       SET ASLT.ACCOUNTED_FLAG = 'ACCOUNTED',
                           ASLT.LAST_UPDATE_DATE = SYSDATE,
                           ASLT.LAST_UPDATED_BY = var_user_id
                     WHERE 1 = 1 
                       AND ASLT.LOAN_TRANSACTION_ID = detail_loan.LOAN_TRANSACTION_ID;
                       
                    COMMIT;
                                                                     
                END LOOP;       
                
                /*****************************************************/
                /*          CARGO   :   INTERESES POR DEVENGAR       */
                /*****************************************************/
                FOR detail_interest IN DETAILS_INTERESTS(P_PERIOD_NAME, 
                                                         P_ELEMENT_NAME, 
                                                         detail_company.COMPANY_CODE) LOOP
                    
                    var_loan_debit_amount := 0;
                    var_loan_credit_amount := 0;
                    var_index := var_index + 1;
                    var_description := '';
                                                     
                    var_loan_debit_amount := detail_interest.PAYMENT_INTEREST;
                    var_description := detail_interest.EMPLOYEE_FULL_NAME || '|' || detail_interest.LOAN_NUMBER || '|' || var_loan_debit_amount;
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_une_int_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => detail_interest.LOAN_TRANSACTION_ID,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_une_int_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));
                    
                    
                    UPDATE ATET_SB_LOANS_TRANSACTIONS ASLT
                       SET ASLT.ACCOUNTED_FLAG = 'ACCOUNTED',
                           ASLT.LAST_UPDATE_DATE = SYSDATE,
                           ASLT.LAST_UPDATED_BY = var_user_id
                     WHERE 1 = 1 
                       AND ASLT.LOAN_TRANSACTION_ID = detail_interest.LOAN_TRANSACTION_ID;
                       
                    COMMIT;
                                                                     
                END LOOP;  
                
                var_loan_debit_amount := 0;
                var_loan_credit_amount := 0;
                var_description := '';
                
                FOR detail_interest IN DETAILS_INTERESTS(P_PERIOD_NAME, 
                                                         P_ELEMENT_NAME, 
                                                         detail_company.COMPANY_CODE) LOOP
                    var_loan_credit_amount := var_loan_credit_amount + detail_interest.PAYMENT_INTEREST;
                END LOOP;      
                
                /*****************************************************/
                /*          ABONO   :   INTERESES COBRADOS           */
                /*****************************************************/
                IF detail_company.COMPANY_CODE = '02' AND var_loan_credit_amount > 0 THEN
                
                    var_index := var_index + 1;
                
                    var_description := UPPER('Intereses Cobrados (El Calvario Servicios)');
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_int_rec_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => -1,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_int_rec_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));
                    
                ELSIF detail_company.COMPANY_CODE = '11' AND var_loan_credit_amount > 0 THEN
                
                    var_index := var_index + 1;
                
                    var_description := UPPER('Intereses Cobrados (Productos Avicolas El Calvario)');
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_int_rec_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => -1,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_int_rec_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));                                         
                                                                                 
                END IF;
                
                var_loan_debit_amount := 0;
                var_loan_credit_amount := 0;
                var_description := '';
                
                FOR detail_interest_late IN DETAILS_INTERESTS_LATE(P_PERIOD_NAME, 
                                                                   P_ELEMENT_NAME, 
                                                                   detail_company.COMPANY_CODE) LOOP
                    var_loan_debit_amount := var_loan_debit_amount + detail_interest_late.PAYMENT_INTEREST_LATE;
                END LOOP;
                
                /*****************************************************/
                /*          CARGO   :   DEUDORES DIVERSOS            */
                /*****************************************************/
                IF detail_company.COMPANY_CODE = '02' AND var_loan_debit_amount > 0 THEN
                
                    var_index := var_index + 1;
                
                    var_description := UPPER('Intereses Moratorios Cobrados (El Calvario Servicios)');
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_deb_cs_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST_LATE',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => -1,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_deb_cs_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));
                    
                ELSIF detail_company.COMPANY_CODE = '11' AND var_loan_debit_amount > 0 THEN
                
                    var_index := var_index + 1;
                
                    var_description := UPPER('Intereses Moratorios Cobrados (Productos Avicolas El Calvario)');
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_deb_pac_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_LOANS',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => -1,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_deb_pac_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));                                         
                                                                                 
                END IF;
                
                /*****************************************************/
                /*          CARGO   :   INTERESES POR DEVENGAR       */
                /*****************************************************/
                FOR detail_interest_late IN DETAILS_INTERESTS_LATE(P_PERIOD_NAME, 
                                                                   P_ELEMENT_NAME, 
                                                                   detail_company.COMPANY_CODE) LOOP
                    var_loan_debit_amount := 0;
                    var_loan_credit_amount := 0;
                    var_index := var_index + 1;
                    var_description := '';
                                                     
                    var_loan_credit_amount := detail_interest_late.PAYMENT_INTEREST_LATE;
                    var_description := detail_interest_late.EMPLOYEE_FULL_NAME || '|' || detail_interest_late.LOAN_NUMBER || '|' || var_loan_credit_amount;
                
                    ATET_SB_BACK_OFFICE_PKG.CREATE_XLA_LINES(P_HEADER_ID               => var_header_id,
                                                             P_ROW_NUMBER              => var_index,
                                                             P_CODE_COMBINATION_ID     => var_int_rec_account_id,
                                                             P_ACCOUNTING_CLASS_CODE   => 'PAYROLL_INTEREST_LATE',
                                                             P_ACCOUNTED_DR            => var_loan_debit_amount,
                                                             P_ACCOUNTED_CR            => var_loan_credit_amount,
                                                             P_DESCRIPTION             => var_description,
                                                             P_SOURCE_ID               => detail_interest_late.LOAN_TRANSACTION_ID,
                                                             P_SOURCE_LINK_TABLE       => 'ATET_SB_LOANS_TRANSACTIONS');
                                                             
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(var_int_rec_code_comb, 35, ' ') || 
                                                       RPAD(var_description, 50, ' ') || 
                                                       LPAD(var_loan_debit_amount, 30, ' ') || 
                                                       LPAD(var_loan_credit_amount, 30, ' '));
                    
                    
                    UPDATE ATET_SB_LOANS_TRANSACTIONS ASLT
                       SET ASLT.ACCOUNTED_FLAG = 'ACCOUNTED',
                           ASLT.LAST_UPDATE_DATE = SYSDATE,
                           ASLT.LAST_UPDATED_BY = var_user_id
                     WHERE 1 = 1 
                       AND ASLT.LOAN_TRANSACTION_ID = detail_interest_late.LOAN_TRANSACTION_ID;
                       
                    COMMIT;
                                                                     
                END LOOP;  
            
            END LOOP;                        
        
        END IF;
        
        ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL;
        
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR (-20001, 'Error encontrado en SEND_TO_XLA ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    END SEND_TO_XLA;
    
    
    FUNCTION    HAS_DISABILITIES(P_PERSON_ID        NUMBER,
                                 P_TIME_PERIOD_ID   NUMBER)
      RETURN    VARCHAR2
    IS
        var_result  VARCHAR2(100);
        var_count   NUMBER;
    BEGIN
    
                SELECT DISTINCT
                       COUNT(PDF.DISABILITY_ID)
                  INTO var_count
                  FROM  PAY_ALL_PAYROLLS_F          PAP,
                        PER_PERSON_TYPE_USAGES_F    PPTU,
                        PER_PERIODS_OF_SERVICE      PPOS,
                        PER_ALL_ASSIGNMENTS_F       PAA,   
                        PER_PEOPLE_F                PPF,      
                        PER_ALL_PEOPLE_F            PAPF,
                        PER_DISABILITIES_F          PDF,
                        PER_TIME_PERIODS            PTP  
                 WHERE 1 = 1
                   AND PPF.PERSON_ID = PPTU.PERSON_ID
                   AND PPF.PERSON_ID = PPOS.PERSON_ID
                   AND PAA.PAYROLL_ID = PAP.PAYROLL_ID
                   AND PAA.PERSON_ID = PPF.PERSON_ID
                   AND PAPF.PERSON_ID = PPF.PERSON_ID
                   AND (PPF.EFFECTIVE_START_DATE = PAPF.EFFECTIVE_START_DATE
                    AND PPF.EFFECTIVE_START_DATE = PPTU.EFFECTIVE_START_DATE
                    AND PPF.EFFECTIVE_START_DATE = PPOS.DATE_START) 
                   AND PAA.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID
                   AND PPF.REGISTERED_DISABLED_FLAG IS NULL
                   AND PDF.PERSON_ID = PPF.PERSON_ID
                   AND PDF.PERSON_ID = P_PERSON_ID
                   AND PAP.PAYROLL_ID = PTP.PAYROLL_ID
                   AND PTP.TIME_PERIOD_ID = P_TIME_PERIOD_ID
                   AND (   PDF.REGISTRATION_DATE BETWEEN PTP.START_DATE AND PTP.END_DATE
                        OR PDF.REGISTRATION_EXP_DATE BETWEEN PTP.START_DATE AND PTP.END_DATE)   
                   AND (PDF.CATEGORY = 'RT'
                     OR PDF.CATEGORY = 'GRAL'
                     OR PDF.CATEGORY = 'MAT')
                 GROUP BY PPF.PERSON_ID,
                           PAPF.EMPLOYEE_NUMBER,       
                           PAPF.FULL_NAME,
                           PDF.DISABILITY_ID,
                           PDF.REGISTRATION_DATE, 
                           PDF.REGISTRATION_EXP_DATE;
                           
        IF var_count > 0 THEN
            var_result := 'DISABILITIES';
        ELSE
            var_result := '';
        END IF;
        
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'HAS_DISABILITIES(P_PERSON_ID => ' || P_PERSON_ID || 
                                                        ',P_TIME_PERIOD_ID => ' || P_TIME_PERIOD_ID || 
                                                        ') RETURN ' || var_result);
    
        RETURN var_result;
    END HAS_DISABILITIES;
                                 

END ATET_SAVINGS_BANK_PKG;