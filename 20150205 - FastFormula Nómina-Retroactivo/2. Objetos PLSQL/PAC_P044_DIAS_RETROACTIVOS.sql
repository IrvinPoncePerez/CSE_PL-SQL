CREATE OR REPLACE FUNCTION PAC_P044_DIAS_RETROACTIVOS(
        P_ASSIGNMENT_ID     NUMBER,
        P_DATE              DATE,
        P_ELEMENT_NAME      VARCHAR2,
        P_PAYROLL           VARCHAR2)
RETURN NUMBER
IS 
    days        NUMBER := 0;
    days_imss   NUMBER := 0;
    
    CURSOR DETAIL_DAYS IS
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
               AND PAA.ASSIGNMENT_ID = P_ASSIGNMENT_ID
               AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID 
               AND EXTRACT(YEAR FROM PPA.EFFECTIVE_DATE) = EXTRACT(YEAR FROM P_DATE)
               AND PPA.EFFECTIVE_DATE < P_DATE 
               AND PPA.ACTION_TYPE IN ('Q', 'R')
               AND PAA.RUN_TYPE_ID IS NOT NULL
               AND PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
               AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
               AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
               AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
               AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
               AND SYSDATE <= PETF.EFFECTIVE_END_DATE
               AND PETF.ELEMENT_NAME = P_ELEMENT_NAME
               AND PIVF.NAME IN ('Dias Recibo', 'Dias Normales')
             ORDER BY PPA.EFFECTIVE_DATE;
               
  
    
BEGIN
    

        
    FOR detail IN DETAIL_DAYS LOOP
    
        IF P_PAYROLL LIKE '%SEM%' THEN    
        
        
            IF detail.EFFECTIVE_DATE <= TO_DATE('04/01/2016', 'DD/MM/YYYY') THEN
            
            
                IF P_ELEMENT_NAME LIKE '%P001%' THEN
                    days := days + TRUNC((detail.days * 7/6), 2);
                ELSIF P_ELEMENT_NAME LIKE '%P005%' THEN
                    days_imss := days_imss + detail.DAYS;
                    days := TRUNC((days_imss * 7/6), 2);
                END IF;
                
                
            ELSIF detail.EFFECTIVE_DATE <= TO_DATE('11/01/2016', 'DD/MM/YYYY') THEN
                       
                IF P_ELEMENT_NAME LIKE '%P001%' THEN
                    days := days + TRUNC((detail.days * 7/6), 2);
                ELSIF P_ELEMENT_NAME LIKE '%P005%' THEN
                    days := days + TRUNC((detail.DAYS * 7/6), 2);                            
                END IF;
                    
            END IF;
            
            
        ELSIF P_PAYROLL LIKE '%QUIN%' THEN
            days_imss := days_imss + detail.DAYS;    
            days := TRUNC((days_imss * 15/13), 2);
        END IF;

    
    END LOOP;
    
       
    IF days IS NULL THEN
        days := 0;
    END IF;
       
    RETURN days;

EXCEPTION WHEN OTHERS THEN
    RETURN 0;
END PAC_P044_DIAS_RETROACTIVOS;