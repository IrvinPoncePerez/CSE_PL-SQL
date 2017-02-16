                SELECT DISTINCT 
                       PAA.ASSIGNMENT_ID,
                       PPF.ATTRIBUTE1,
                       PTP.END_DATE,
                       PTP.PERIOD_NUM,
                       PPA.PAYROLL_ACTION_ID,
                       PAA.ASSIGNMENT_ACTION_ID,
                       PPF.PAYROLL_ID,
                       PPA.CONSOLIDATION_SET_ID,
                       PPA.EFFECTIVE_DATE,
                       PTP.START_DATE,
                       PTP.END_DATE,
                       PPA.ACTION_TYPE,
                       PPA.DATE_EARNED,
                       PAA.TAX_UNIT_ID,
                       PAA.RUN_TYPE_ID,
                       PPF.PERIOD_TYPE 
                  FROM PAY_PAYROLL_ACTIONS          PPA,
                       PER_TIME_PERIODS             PTP,
                       PAY_ASSIGNMENT_ACTIONS       PAA,
                       PAY_ALL_PAYROLLS_F           PPF
                 WHERE 1 = 1
                   AND PPF.PAYROLL_NAME NOT IN ('02_SEM - GRBE', '02_QUIN - EVENTUAL')
                   AND SUBSTR(PPF.PAYROLL_NAME, 1, 2) = :P_COMPANY_ID
                   AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
                   AND PPF.PAYROLL_ID = PPA.PAYROLL_ID      
                   AND PPA.CONSOLIDATION_SET_ID = NVL(:P_CONSOLIDATION_SET_ID, PPA.CONSOLIDATION_SET_ID)
                   AND PPA.ACTION_TYPE IN ('Q', 'R', 'B')
                   AND PPA.PAYROLL_ID = NVL(:P_PAYROLL_ID,  PPA.PAYROLL_ID)
                   AND PTP.TIME_PERIOD_ID = PPA.TIME_PERIOD_ID
                   AND PTP.PERIOD_NAME LIKE '%' || :P_YEAR || '%'
                   AND (    EXTRACT(MONTH FROM PTP.END_DATE) >= :P_START_MONTH
                        AND EXTRACT(MONTH FROM PTP.END_DATE) <= :P_END_MONTH)
                   AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
                 GROUP  
                    BY PAA.ASSIGNMENT_ID,
                       PPF.ATTRIBUTE1,
                       PTP.END_DATE,
                       PTP.PERIOD_NUM,
                       PPA.PAYROLL_ACTION_ID,
                       PAA.ASSIGNMENT_ACTION_ID,
                       PPF.PAYROLL_ID,
                       PPA.CONSOLIDATION_SET_ID,
                       PPA.EFFECTIVE_DATE,
                       PTP.START_DATE,
                       PTP.END_DATE,
                       PPA.ACTION_TYPE,
                       PPA.DATE_EARNED,
                       PAA.TAX_UNIT_ID,
                       PAA.RUN_TYPE_ID,
                       PPF.PERIOD_TYPE;
                      
