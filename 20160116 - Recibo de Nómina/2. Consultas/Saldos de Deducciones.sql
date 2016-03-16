SELECT F.BALANCE_PAYROLL_ACTION_ID,
       F.BALANCE_ASSIGNMENT_ID,
       F.BALANCE_ELEMENT_NAME,
       F.BALANCE_LAST_BALANCE,
       F.BALANCE_VALUE,
       F.BALANCE_FINAL_BALANCE
  FROM (SELECT PAA.PAYROLL_ACTION_ID                                AS  BALANCE_PAYROLL_ACTION_ID, 
               PAA.ASSIGNMENT_ID                                    AS  BALANCE_ASSIGNMENT_ID,
               PETF.ELEMENT_NAME                                    AS  BALANCE_ELEMENT_NAME,
               SUM(CASE WHEN PIVF.NAME = 'Saldo Anterior' THEN 
                             TO_NUMBER(PRRV.RESULT_VALUE) 
                   END)                                             AS  BALANCE_LAST_BALANCE,
               SUM(CASE WHEN PIVF.NAME = 'Pay Value' THEN 
                             TO_NUMBER(PRRV.RESULT_VALUE)
                   END)                                             AS  BALANCE_VALUE,     
               SUM(CASE WHEN PIVF.NAME = 'Saldo Restante' THEN 
                             PRRV.RESULT_VALUE 
                   END)                                             AS  BALANCE_FINAL_BALANCE
          FROM PAY_ASSIGNMENT_ACTIONS       PAA,
               PAY_RUN_RESULTS              PRR,
               PAY_ELEMENT_TYPES_F          PETF,
               PAY_RUN_RESULT_VALUES        PRRV,
               PAY_INPUT_VALUES_F           PIVF,
               PAY_ELEMENT_CLASSIFICATIONS  PEC
         WHERE 1 = 1 
           AND PAA.PAYROLL_ACTION_ID = :PAYROLL_ACTION_ID 
           AND PAA.ASSIGNMENT_ID = :ASSIGNMENT_ID
           AND PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
           AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
           AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
           AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
           AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
           AND (PEC.CLASSIFICATION_NAME IN ('Involuntary Deductions', 
                                            'Deducciones Involuntarias', 
                                            'Voluntary Deductions',
                                            'Deducciones Voluntarias')
                  AND PETF.ELEMENT_NAME  IN (SELECT MEANING
                                               FROM FND_LOOKUP_VALUES_VL 
                                              WHERE LOOKUP_TYPE = 'XX_DEDUCCIONES_ESTADOS_CUENTA')) 
           AND PETF.ELEMENT_NAME NOT LIKE '%Special Features%'
           AND PIVF.NAME IN ('Pay Value', 'Saldo Anterior', 'Saldo Restante')
         GROUP BY PRR.ASSIGNMENT_ACTION_ID,
                  PAA.PAYROLL_ACTION_ID,
                  PAA.ASSIGNMENT_ID,
                  PETF.ELEMENT_NAME  
        UNION   
        SELECT BALANCE_PAYROLL_ACTION_ID,
               BALANCE_ASSIGNMENT_ID,
               BALANCE_ELEMENT_NAME,
               BALANCE_LAST_BALANCE,
               BALANCE_VALUE,
               BALANCE_FINAL_BALANCE
          FROM (SELECT D.PAYROLL_ACTION_ID          AS  BALANCE_PAYROLL_ACTION_ID, 
                       D.ASSIGNMENT_ID              AS  BALANCE_ASSIGNMENT_ID,
                       D.ELEMENT_NAME                   BALANCE_ELEMENT_NAME,
                       (CASE WHEN D.ASSIGNMENT_ACTION_ID IN (SELECT DISTINCT PAA2.ASSIGNMENT_ACTION_ID
                                                               FROM PAY_ASSIGNMENT_ACTIONS PAA2
                                                              WHERE PAA2.SOURCE_ACTION_ID = D.ASSIGNMENT_ACTION_ID) THEN
                               TO_NUMBER(NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(D.ASSIGNMENT_ACTION_ID,    
                                                                                       'P047_ISPT ANUAL A FAVOR',  
                                                                                       'Saldo_Pendiente'),   '0')) 
                               +  TO_NUMBER(NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(D.ASSIGNMENT_ACTION_ID,    
                                                                             'P047_ISPT ANUAL A FAVOR',  
                                                                             'Pay Value'),   '0')) 
                             ELSE
                                TO_NUMBER(NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(D.ASSIGNMENT_ACTION_ID,
                                                                                'P047_ISPT ANUAL A FAVOR',
                                                                                'Saldo_Pendiente'),    '0'))
                                END)                    BALANCE_LAST_BALANCE,
                      (CASE WHEN D.ASSIGNMENT_ACTION_ID IN (SELECT DISTINCT PAA2.ASSIGNMENT_ACTION_ID
                                                              FROM PAY_ASSIGNMENT_ACTIONS PAA2
                                                             WHERE PAA2.SOURCE_ACTION_ID = D.ASSIGNMENT_ACTION_ID)  THEN
                              TO_NUMBER(NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(D.ASSIGNMENT_ACTION_ID,
                                                                                    'P047_ISPT ANUAL A FAVOR',
                                                                                    'Pay Value'),         '0'))
                            ELSE 0 END)                 BALANCE_VALUE,
                      TO_NUMBER(NVL(PAC_RESULT_VALUES_PKG.GET_EARNING_VALUE(D.ASSIGNMENT_ACTION_ID,
                                                                                'P047_ISPT ANUAL A FAVOR',
                                                                                'Saldo_Pendiente'),    '0')) BALANCE_FINAL_BALANCE 
                FROM (  SELECT PPA.DATE_EARNED,
                               PRRV.RESULT_VALUE,
                               PIVF.NAME,
                               PETF.ELEMENT_NAME,
                               PAA.PAYROLL_ACTION_ID, 
                               PAA.ASSIGNMENT_ID,
                               PAA.ASSIGNMENT_ACTION_ID
                          FROM PAY_ASSIGNMENT_ACTIONS       PAA,
                               PAY_PAYROLL_ACTIONS          PPA,
                               PAY_RUN_TYPES_X              PRTX,
                               PAY_RUN_RESULTS              PRR,
                               PAY_ELEMENT_TYPES_F          PETF,
                               PAY_RUN_RESULT_VALUES        PRRV,
                               PAY_INPUT_VALUES_F           PIVF,
                               PAY_ELEMENT_CLASSIFICATIONS  PEC
                         WHERE 1 = 1
                           AND PAA.PAYROLL_ACTION_ID = :PAYROLL_ACTION_ID 
                           AND PAA.ASSIGNMENT_ID = :ASSIGNMENT_ID
                           AND PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
                           AND PRTX.RUN_TYPE_ID = PAA.RUN_TYPE_ID        
                           AND PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
                           AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
                           AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
                           AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
                           AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
                           AND SYSDATE <= PETF.EFFECTIVE_END_DATE
                           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE
                           AND PEC.CLASSIFICATION_NAME = 'Earnings' 
                           AND PETF.ELEMENT_NAME = 'P047_ISPT ANUAL A FAVOR'
                           AND PPA.DATE_EARNED <= (SELECT DISTINCT PPA1.DATE_EARNED
                                                     FROM PAY_ASSIGNMENT_ACTIONS PAA1,
                                                          PAY_PAYROLL_ACTIONS    PPA1
                                                    WHERE PAA1.PAYROLL_ACTION_ID = PPA1.PAYROLL_ACTION_ID
                                                      AND PAA1.SOURCE_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID )
                           AND PIVF.NAME = 'Saldo_Pendiente'
                         ORDER BY TO_DATE(PPA.DATE_EARNED) DESC) D
                 WHERE ROWNUM = 1 ) D
        WHERE 1 = 1
          AND (D.BALANCE_LAST_BALANCE <> 0
              OR D.BALANCE_VALUE <> 0
              OR D.BALANCE_FINAL_BALANCE <> 0)) F
 WHERE 1 = 1
 ORDER BY F.BALANCE_ELEMENT_NAME