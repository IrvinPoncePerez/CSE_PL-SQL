
        SELECT SUM(PRRV.RESULT_VALUE)
          INTO var_result
          FROM PAY_PAYROLL_ACTIONS          PPA,
               PAY_PAYROLLS_F               PPF,
               PER_TIME_PERIODS             PTP,
               PER_ALL_ASSIGNMENTS_F        PAAF,
               PAY_ASSIGNMENT_ACTIONS       PAA,
               PAY_RUN_RESULTS              PRR,
               PAY_ELEMENT_TYPES_F          PETF,
               PAY_RUN_RESULT_VALUES        PRRV,
               PAY_INPUT_VALUES_F           PIVF,
               PAY_ELEMENT_CLASSIFICATIONS  PEC
         WHERE 1 = 1 
           AND PPF.PAYROLL_ID = PPA.PAYROLL_ID
           AND PTP.PAYROLL_ID = PPF.PAYROLL_ID
           AND PTP.START_DATE = P_START_DATE
           AND PTP.END_DATE = P_END_DATE
           AND PPA.EFFECTIVE_DATE BETWEEN PTP.START_DATE AND PTP.END_DATE
           AND PTP.TIME_PERIOD_ID = PPA.TIME_PERIOD_ID   
           AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
           AND PAAF.PERSON_ID = P_PERSON_ID
           AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID 
           AND PAA.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID 
           AND PPF.PAYROLL_NAME NOT IN ('02_SEM - GRBE', '02_QUIN - EVENTUAL')
           AND PPA.EFFECTIVE_DATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
           AND PPA.EFFECTIVE_DATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
           AND PAC_CFDI_FUNCTIONS_PKG.GET_PAYMENT_METHOD(PAA.ASSIGNMENT_ID) LIKE '%%'
           AND PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
           AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
           AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
           AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
           AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
           AND PETF.ELEMENT_NAME  IN ('P039_DESPENSA')
           AND PIVF.UOM = 'M'
           AND PIVF.NAME = 'Pay Value'
           AND SYSDATE BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PIVF.EFFECTIVE_START_DATE AND PIVF.EFFECTIVE_END_DATE;
    
--        RETURN 'BONO : ' || TO_CHAR(var_result) || ' ';