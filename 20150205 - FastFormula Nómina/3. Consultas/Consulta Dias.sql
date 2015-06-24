SELECT SUM(TRUNC(PRRV.RESULT_VALUE, 2))
  FROM PAY_ASSIGNMENT_ACTIONS       PAA,
       PAY_PAYROLL_ACTIONS          PPA,
       PAY_RUN_RESULTS              PRR,
       PAY_ELEMENT_TYPES_F          PETF,
       PAY_RUN_RESULT_VALUES        PRRV,
       PAY_INPUT_VALUES_F           PIVF,
       PAY_ELEMENT_CLASSIFICATIONS  PEC
 WHERE 1 = 1
   AND PAA.ASSIGNMENT_ID = :P_ASSIGNMENT_ID
   AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID 
   AND EXTRACT(YEAR FROM PPA.EFFECTIVE_DATE) = :P_YEAR 
   AND PPA.ACTION_TYPE IN ('Q', 'R')
   AND PAA.RUN_TYPE_ID IS NOT NULL
   AND PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
   AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
   AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
   AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
   AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
   AND SYSDATE <= PETF.EFFECTIVE_END_DATE
   AND PETF.ELEMENT_NAME = 'P001_SUELDO NORMAL'
   AND PIVF.NAME = 'Days';