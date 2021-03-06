SELECT DISTINCT
       PAPF.PERSON_ID                                      AS  PERSON_ID
      ,PAPF.EMPLOYEE_NUMBER                                AS  EMPLOYEE_NUMBER
      ,TRIM(PAPF.LAST_NAME)                                AS  LAST_NAME
      ,TRIM(PAPF.PER_INFORMATION1)                         AS  SECOND_LAST_NAME
      ,TRIM(PAPF.FIRST_NAME || ' ' || PAPF.MIDDLE_NAMES)   AS  NAMES
      ,TRIM(PEA.SEGMENT3)                                  AS  ACCOUNT_NUMBER      
      ,TRIM(SUBSTR(POPM.ORG_PAYMENT_METHOD_NAME,4))        AS  BANK_NAME      
      ,TRIM(PEA.SEGMENT5)                                  AS  CLABE      
      ,TRIM(PAPF.PER_INFORMATION2)                         AS  RFC                           
      ,TRIM(PAPF.NATIONAL_IDENTIFIER)                      AS  CURP    
      ,TO_CHAR(SYSDATE, 'RRRRMMDD')                        AS  DATE_EXP 
  FROM PER_ALL_PEOPLE_F                PAPF      
 INNER 
  JOIN PER_PERSON_TYPES                PPT 
    ON PAPF.PERSON_TYPE_ID =  PPT.PERSON_TYPE_ID
 INNER 
  JOIN PER_PERIODS_OF_SERVICE          PPOS  
    ON (   PPOS.PERSON_ID = PAPF.PERSON_ID
       AND PPOS.ACTUAL_TERMINATION_DATE IS NULL)
 INNER 
  JOIN PER_ALL_ASSIGNMENTS_F           PAAF
    ON PAAF.PERSON_ID = PAPF.PERSON_ID
 INNER
  JOIN PAY_PERSONAL_PAYMENT_METHODS_F  PPPM
    ON PPPM.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
 INNER   
  JOIN PAY_ORG_PAYMENT_METHODS_F       POPM
    ON POPM.ORG_PAYMENT_METHOD_ID = PPPM.ORG_PAYMENT_METHOD_ID
  LEFT
  JOIN PAY_EXTERNAL_ACCOUNTS           PEA
    ON PEA.EXTERNAL_ACCOUNT_ID = PPPM.EXTERNAL_ACCOUNT_ID
 WHERE 1 = 1
   AND PPT.USER_PERSON_TYPE IN ('Employee', 'Empleado')
   AND PPT.ACTIVE_FLAG = 'Y'
   AND ORG_PAYMENT_METHOD_NAME NOT LIKE '%PENSIONES%'
   AND ORG_PAYMENT_METHOD_NAME NOT LIKE '%DESPENSA%'
   AND ORG_PAYMENT_METHOD_NAME NOT LIKE '%EFECTIVA%'
   AND ORG_PAYMENT_METHOD_NAME NOT LIKE '%CHEQUE%'
   AND NVL(PPOS.ADJUSTED_SVC_DATE,  
           PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PAPF.EFFECTIVE_START_DATE
                                           AND PAPF.EFFECTIVE_END_DATE
   AND NVL(PPOS.ADJUSTED_SVC_DATE,  
           PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PAAF.EFFECTIVE_START_DATE
                                           AND PAAF.EFFECTIVE_END_DATE  
   AND NVL(PPOS.ADJUSTED_SVC_DATE,  
           PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN PPPM.EFFECTIVE_START_DATE
                                           AND PPPM.EFFECTIVE_END_DATE
   AND NVL(PPOS.ADJUSTED_SVC_DATE,  
           PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN POPM.EFFECTIVE_START_DATE
                                           AND POPM.EFFECTIVE_END_DATE 
   AND NVL(PPOS.ADJUSTED_SVC_DATE,  
           PAPF.ORIGINAL_DATE_OF_HIRE) BETWEEN :var_start_date
                                           AND :var_end_date                            
 ORDER
    BY PAPF.EMPLOYEE_NUMBER;
