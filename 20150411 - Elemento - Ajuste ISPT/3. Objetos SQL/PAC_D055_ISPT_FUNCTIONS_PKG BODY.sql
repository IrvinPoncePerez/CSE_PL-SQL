CREATE OR REPLACE PACKAGE BODY PAC_D055_ISPT_FUNCTIONS_PKG AS



    FUNCTION GET_NUM_WEEK(P_DATE_EARNED DATE) 
    RETURN NUMBER
    IS
        num_week        NUMBER;
        num_month       NUMBER;
        loop_month      NUMBER;
        new_date        DATE;
    BEGIN
    
        num_week := 1;
        num_month := TO_NUMBER(EXTRACT(MONTH FROM P_DATE_EARNED));
        new_date := P_DATE_EARNED;
    
        LOOP
        
            new_date := (new_date - 7);
            loop_month := TO_NUMBER(EXTRACT(MONTH FROM new_date));
            
            IF (loop_month = num_month) THEN
                num_week := num_week + 1;
            END IF;           
            
            EXIT WHEN loop_month != num_month;            
        
        END LOOP;
    
        RETURN num_week;
    END GET_NUM_WEEK;
    

    
    FUNCTION HAS_EMPLOYMENT_SUBSIDY( P_ASSIGNMENT_ID NUMBER, P_DATE_EARNED DATE)
    RETURN NUMBER
    IS
        CURSOR DETAIL_LIST IS
                SELECT PAA.ASSIGNMENT_ACTION_ID,
                       ROWNUM AS ROW_NUM
                  FROM PAY_ASSIGNMENT_ACTIONS       PAA,
                       PAY_PAYROLL_ACTIONS          PPA,
                       PAY_RUN_TYPES_X              PRTX
                 WHERE 1 = 1 
                   AND PAA.ASSIGNMENT_ID = P_ASSIGNMENT_ID
                   AND PPA.PAYROLL_ACTION_ID = PAA.PAYROLL_ACTION_ID
                   AND EXTRACT(YEAR FROM PPA.DATE_EARNED) = EXTRACT(YEAR FROM P_DATE_EARNED)
                   AND EXTRACT(MONTH FROM PPA.DATE_EARNED) = EXTRACT(MONTH FROM P_DATE_EARNED)
                   AND PRTX.RUN_TYPE_ID = PAA.RUN_TYPE_ID
                   AND PRTX.RUN_TYPE_NAME = 'Standard';           
    
        var_result             NUMBER := 0;
        var_employment_subsidy NUMBER := 0;
    BEGIN
    
        FOR detail IN DETAIL_LIST
        LOOP
            
            var_employment_subsidy := var_employment_subsidy + NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(detail.ASSIGNMENT_ACTION_ID,
                                                                                                           'P032_SUBSIDIO_PARA_EMPLEO',
                                                                                                           'Pay Value'), 
                                                                   0);
                                          
        END LOOP;
        
        IF var_employment_subsidy > 0 THEN      var_result := 1;
        ELSIF var_employment_subsidy = 0 THEN   var_result := 0;
        END IF;
    
        RETURN var_result;
    END HAS_EMPLOYMENT_SUBSIDY;
    
    

    FUNCTION AVERAGE_EMPLOYMENT_SUBSIDY(P_ASSIGNMENT_ID NUMBER, P_DATE_EARNED DATE)
    RETURN NUMBER
    IS
        CURSOR DETAIL_LIST IS
                SELECT PAA.ASSIGNMENT_ACTION_ID,
                       ROWNUM AS ROW_NUM
                  FROM PAY_ASSIGNMENT_ACTIONS       PAA,
                       PAY_PAYROLL_ACTIONS          PPA,
                       PAY_RUN_TYPES_X              PRTX
                 WHERE 1 = 1 
                   AND PAA.ASSIGNMENT_ID = P_ASSIGNMENT_ID
                   AND PPA.PAYROLL_ACTION_ID = PAA.PAYROLL_ACTION_ID
                   AND EXTRACT(YEAR FROM PPA.DATE_EARNED) = EXTRACT(YEAR FROM P_DATE_EARNED)
                   AND EXTRACT(MONTH FROM PPA.DATE_EARNED) = EXTRACT(MONTH FROM P_DATE_EARNED)
                   AND PRTX.RUN_TYPE_ID = PAA.RUN_TYPE_ID
                   AND PRTX.RUN_TYPE_NAME = 'Standard';           
    
        
        var_employment_subsidy          NUMBER := 0;
        var_row_num                     NUMBER := 0;
        var_average_employment_subsidy  NUMBER := 0;
    BEGIN
    
        FOR detail IN DETAIL_LIST
        LOOP
            var_row_num := detail.ROW_NUM;
            var_employment_subsidy := var_employment_subsidy + NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(detail.ASSIGNMENT_ACTION_ID,
                                                                                                           'P032_SUBSIDIO_PARA_EMPLEO',
                                                                                                           'Pay Value'), 
                                                                   0);                            
        END LOOP;
        
        IF var_employment_subsidy > 0 THEN      var_average_employment_subsidy := TRUNC((var_employment_subsidy / 4), 2);
        ELSIF var_employment_subsidy = 0 THEN   var_average_employment_subsidy := 0;
        END IF;       
    
        RETURN var_average_employment_subsidy;
    END AVERAGE_EMPLOYMENT_SUBSIDY;
    


END PAC_D055_ISPT_FUNCTIONS_PKG;
