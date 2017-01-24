CREATE OR REPLACE FUNCTION APPS.PAC_P044_DIAS_RETROACTIVOS(
        P_ASSIGNMENT_ID     NUMBER,
        P_DATE              DATE,
        P_ELEMENT_NAME      VARCHAR2,
        P_PAYROLL           VARCHAR2)
RETURN NUMBER
IS 
    days        NUMBER := 0;
    days_imss   NUMBER := 0;
    var_person_id   NUMBER;
    
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
               
    FUNCTION GET_ABSENCES(
        P_PERSON_ID     NUMBER
        )   RETURN NUMBER 
    IS
        var_result NUMBER;
    BEGIN
        SELECT NVL((CASE
                    WHEN PAA.DATE_END = PAA.DATE_START THEN
                        (1 + PAA.DATE_END) - PAA.DATE_START
                    WHEN PAA.DATE_START < TO_DATE('01/01/2017', 'DD/MM/RRRR') AND PAA.DATE_END IN (TO_DATE('01/01/2017', 'DD/MM/RRRR'), TO_DATE('02/01/2017', 'DD/MM/RRRR')) THEN
                        (1 + PAA.DATE_END) - TO_DATE('01/01/2017', 'DD/MM/RRRR')
                    WHEN PAA.DATE_END > TO_DATE('02/01/2017', 'DD/MM/RRRR') AND PAA.DATE_START IN (TO_DATE('01/01/2017', 'DD/MM/RRRR'), TO_DATE('02/01/2017', 'DD/MM/RRRR')) THEN
                        (1 + TO_DATE('02/01/2017', 'DD/MM/RRRR')) - PAA.DATE_START
                    WHEN PAA.DATE_END = PAA.DATE_START + 1 THEN
                        PAA.ABSENCE_DAYS 
                END),0)            DIAS_AUSENTISMOS
          INTO var_result
          FROM PER_ABSENCE_ATTENDANCES          PAA,
               PER_ABS_ATTENDANCE_TYPES_VL      PAAT
         WHERE 1 = 1
           AND PAA.ABSENCE_ATTENDANCE_TYPE_ID = PAAT.ABSENCE_ATTENDANCE_TYPE_ID
           AND PAAT.NAME IN ('INCAPACIDAD GENERAL',
                             'INCAPACIDAD POR MATERNIDAD',
                             'INCAPACIDAD RIESGO DE TRABAJO',
                             'AUSENCIA',
                             'PERMISO SIN GOCE DE SUELDO',
                             'SUSPENSIÓN',
                             'PERMISO POR PATERNIDAD')
           AND (   PAA.DATE_START IN (TO_DATE('01/01/2017','DD/MM/RRRR'),
                                      TO_DATE('02/01/2017','DD/MM/RRRR')) 
                OR PAA.DATE_END IN (TO_DATE('01/01/2017','DD/MM/RRRR'),
                                    TO_DATE('02/01/2017','DD/MM/RRRR')))
           AND PAA.PERSON_ID = P_PERSON_ID;

        RETURN var_result;           
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;           
    END GET_ABSENCES;
    
BEGIN
    
    SELECT PERSON_ID
      INTO var_person_id
      FROM PER_ASSIGNMENTS_F
     WHERE 1 = 1
       AND ASSIGNMENT_ID = P_ASSIGNMENT_ID
       AND SYSDATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE; 
        
    FOR detail IN DETAIL_DAYS LOOP
    
        IF P_PAYROLL LIKE '%SEM%' THEN    
        
        
            /****************************************/
            /*      Semana 1                        */
            /****************************************/
            IF detail.EFFECTIVE_DATE <= TO_DATE('02/01/2017', 'DD/MM/YYYY') THEN 
            
            
                IF P_ELEMENT_NAME LIKE '%P001%' THEN
                    days := (days + 2) - GET_ABSENCES(var_person_id);
                ELSIF P_ELEMENT_NAME LIKE '%P005%' THEN
                    days := days;
                END IF;
                
                
--                IF P_ELEMENT_NAME LIKE '%P001%' THEN
--                    days := days + TRUNC((detail.days * 7/6), 2);
--                ELSIF P_ELEMENT_NAME LIKE '%P005%' THEN
--                    days_imss := days_imss + detail.DAYS;
--                    days := TRUNC((days_imss * 7/6), 2);
--                END IF;
                
                
            /****************************************/
            /*      Semana 2                        */
            /****************************************/    
            ELSIF detail.EFFECTIVE_DATE <= TO_DATE('09/01/2017', 'DD/MM/YYYY') THEN
                       
                IF P_ELEMENT_NAME LIKE '%P001%' THEN
                    days := days + TRUNC((detail.days * 7/6), 2);
                ELSIF P_ELEMENT_NAME LIKE '%P005%' THEN
                    days := days + TRUNC((detail.DAYS * 7/6), 2);                            
                END IF;
            
            /****************************************/
            /*      Semana 3                        */
            /****************************************/
            ELSIF detail.EFFECTIVE_DATE <= TO_DATE('16/01/2017', 'DD/MM/YYYY') THEN
                       
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