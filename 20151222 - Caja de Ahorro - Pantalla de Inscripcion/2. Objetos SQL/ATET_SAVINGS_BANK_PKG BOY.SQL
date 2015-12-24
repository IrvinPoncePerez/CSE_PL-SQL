CREATE OR REPLACE PACKAGE BODY ATET_SAVINGS_BANK_PKG IS

    /*****************      ARINCON     ****************/
    
    /*****************      SARIAS      ****************/
    
    /*****************      IPONCE      ****************/
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
           
           
        RETURN var_saving_bank_id;
    
    END GET_SAVING_BANK_ID;
    
    
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
           AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE;
        
        RETURN var_period_type;    
    
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
           
        RETURN var_registration_date;
    
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
                
        RETURN var_parameter_value;
    
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
    
        RETURN var_result;
        
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
--           AND EXTRACT(YEAR FROM PPA.DATE_EARNED) = P_YEAR
           AND PPA.CONSOLIDATION_SET_ID = PCS.CONSOLIDATION_SET_ID
           AND PCS.CONSOLIDATION_SET_NAME IN ('NORMAL')
         ORDER BY PPA.DATE_EARNED DESC,
                  PAA.ASSIGNMENT_ACTION_ID DESC;
                       
        RETURN var_assignment_action_id;   
              
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
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END;


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
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END;
    
    
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
    
        RETURN var_result_value;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END;
      
    
    /*****************      LHERNANDEZ  ****************/

END ATET_SAVINGS_BANK_PKG;