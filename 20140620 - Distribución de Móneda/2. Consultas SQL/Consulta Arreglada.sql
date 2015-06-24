SELECT   CMP.MEANING COMPANY,
         HPV.D_ORGANIZATION_ID, 
         HPV.PAYROLL_NAME,
         HPV.PERSON_ID, 
         HPV.EMPLOYEE_NUMBER, 
         HPV.FULL_NAME, 
         PPP.VALUE, 
         PAC_HR_PAY_PKG.GET_PERIOD_TYPE (HPV.PAYROLL_NAME) PERIOD_TYPE,
         PAA.PERIOD_NAME,
         PPP.PAYMENT_TYPE_NAME
    FROM PAY_PAYROLL_ACTIONS PAC1,
         PAY_ASSIGNMENT_ACTIONS_V PAA,
         PAY_PRE_PAYMENTS_V PPP,
         FND_LOOKUP_VALUES CMP,
         XXCALV_HR_PAY_EMPLOYEES_V HPV
   WHERE 1=1 
     AND HPV.PAYROLL_ID = PAC1.PAYROLL_ID
     AND PAC1.PAYROLL_ACTION_ID = PAA.PAYROLL_ACTION_ID
     AND PAA.ASSIGNMENT_ACTION_ID = PPP.ASSIGNMENT_ACTION_ID
     AND PAA.ASSIGNMENT_NUMBER = HPV.EMPLOYEE_NUMBER
     AND PAA.ACTION_TYPE IN ('U','P')
     AND CMP.LOOKUP_TYPE = 'NOMINAS POR EMPLEADOR LEGAL'
     AND CMP.LOOKUP_CODE = :P_COMPANY_ID
     AND CMP.LOOKUP_CODE = SUBSTR(HPV.PAYROLL_NAME,1,2)
     AND CMP.LANGUAGE = USERENV('LANG')
     AND UPPER(PPP.PAYMENT_TYPE_NAME) IN ('CASH','EFECTIVO')
     AND (PAC1.START_DATE >= :P_START_DATE
     AND PAC1.EFFECTIVE_DATE <= :P_END_DATE)
     AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE (HPV.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, PAC_HR_PAY_PKG.GET_PERIOD_TYPE (HPV.PAYROLL_NAME))
     AND HPV.PAYROLL_ID = NVL(:P_PAYROLL_ID, HPV.PAYROLL_ID)
     AND HPV.ORGANIZATION_ID = NVL(:P_ORGANIZATION_ID, HPV.ORGANIZATION_ID)      
     AND PAC1.CONSOLIDATION_SET_ID = NVL(:P_CONSOLIDATION_SET_ID, PAC1.CONSOLIDATION_SET_ID)
ORDER BY PPP.PRE_PAYMENT_ID; 