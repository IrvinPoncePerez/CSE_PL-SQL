        SELECT /*+ LEADING(PPF, PPA, PTP, PAA, PRR, PRRV) */ 
               (CASE
                    WHEN PETF.ELEMENT_NAME LIKE 'P0%'
                        THEN TO_NUMBER(TO_CHAR(SUBSTR(PETF.ELEMENT_NAME, 2, 3)))
                    WHEN PETF.ELEMENT_NAME LIKE 'D0%'
                        THEN TO_NUMBER(TO_CHAR(SUBSTR(PETF.ELEMENT_NAME, 2, 3))) + 1000
                    ELSE 
                        PETF.ELEMENT_TYPE_ID + 2000
                END)                        AS  "ROWINDEX", 
               PETF.ELEMENT_NAME            AS  ELEMENT_NAME,
               PETF.ELEMENT_NAME            AS  DESCRIPTION,
               PPF.ATTRIBUTE1               AS  CVNOM,
               SUM(CASE
                    WHEN SUBSTR (PETF.ELEMENT_NAME, 1, 1) = 'D' THEN
                        TO_NUMBER (NVL (PRRV.RESULT_VALUE, 0)) * -1
                    ELSE
                        TO_NUMBER (NVL (PRRV.RESULT_VALUE, 0))
                   END)                     AS  RESULT_VALUE
          FROM PAY_ALL_PAYROLLS_F           PPF,
               PAY_PAYROLL_ACTIONS          PPA,
               PER_TIME_PERIODS             PTP,
               PAY_ASSIGNMENT_ACTIONS       PAA,
               PAY_RUN_RESULTS              PRR,
               PAY_RUN_RESULT_VALUES        PRRV,
               PAY_INPUT_VALUES_F           PIVF,
               PAY_ELEMENT_TYPES_F          PETF,
               PAY_ELEMENT_CLASSIFICATIONS  PEC
         WHERE 1 = 1
           AND PPA.PAYROLL_ID = PPF.PAYROLL_ID
           AND PTP.PAYROLL_ID = PPF.PAYROLL_ID
           AND PPA.TIME_PERIOD_ID = PTP.TIME_PERIOD_ID
           AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
           AND PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
           AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
           AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
           AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
           AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
           AND PPA.EFFECTIVE_DATE BETWEEN PPF.EFFECTIVE_START_DATE
                                      AND PPF.EFFECTIVE_END_DATE                                                             
           AND PAC_HR_PAY_PKG.GET_EMPLOYER_NAME (PPF.PAYROLL_NAME) = NVL(:P_EMPLOYER_NAME, PAC_HR_PAY_PKG.GET_EMPLOYER_NAME (PPF.PAYROLL_NAME))
           AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE (PPF.PAYROLL_NAME) = NVL(:P_PAY_PERIOD_TYPE, PAC_HR_PAY_PKG.GET_PERIOD_TYPE (PPF.PAYROLL_NAME))
           AND PPF.PAYROLL_NAME = NVL (:P_PAYROLL_NAME, PPF.PAYROLL_NAME)
           AND PPA.CONSOLIDATION_SET_ID = NVL (:P_CONSOLIDATION_SET_ID, PPA.CONSOLIDATION_SET_ID)
           AND EXTRACT(YEAR FROM PTP.END_DATE) = NVL(:P_PAYROLL_PERIOD_YEAR, EXTRACT(YEAR FROM PTP.END_DATE))
           AND EXTRACT(MONTH FROM PTP.END_DATE) BETWEEN NVL (:P_PAYROLL_START_MONTH_NUMBER, EXTRACT(MONTH FROM PTP.END_DATE))
                                                    AND NVL (:P_PAYROLL_END_MONTH_NUMBER, EXTRACT(MONTH FROM PTP.END_DATE))
           AND PTP.PERIOD_NUM BETWEEN NVL (:P_PAYROLL_START_PERIOD_NUMBER, PTP.PERIOD_NUM)
                                  AND NVL (:P_PAYROLL_END_PERIOD_NUMBER, PTP.PERIOD_NUM)
           AND PPA.EFFECTIVE_DATE BETWEEN PIVF.EFFECTIVE_START_DATE
                                      AND PIVF.EFFECTIVE_END_DATE  
           AND PIVF.NAME = 'Pay Value'
           AND PPA.EFFECTIVE_DATE BETWEEN PETF.EFFECTIVE_START_DATE
                                      AND PETF.EFFECTIVE_END_DATE   
           AND (   PETF.ELEMENT_NAME IN (SELECT MEANING
                                           FROM FND_LOOKUP_VALUES
                                          WHERE 1 = 1
                                            AND LOOKUP_TYPE IN ('XX_PERCEPCIONES_INFORMATIVAS',
                                                                'XX_DEDUCCIONES_INFORMATIVAS')
                                            AND LANGUAGE = USERENV('LANG'))                     
                OR PEC.CLASSIFICATION_NAME IN ('Earnings', 
                                               'Supplemental Earnings', 
                                               'Amends', 
                                               'Imputed Earnings',
                                               'Voluntary Deductions',
                                               'Involuntary Deductions'))
         GROUP 
            BY PETF.ELEMENT_NAME,
               PETF.ELEMENT_TYPE_ID,
               PPF.ATTRIBUTE1
        UNION
        SELECT /*+ LEADING(PPF, PPA, PTP, PAA, PRR, PRRV) */
               5555                         AS  "ROWINDEX", 
               'NETO'                       AS  ELEMENT_NAME,
               'NETO'                       AS  DESCRIPTION,
               PPF.ATTRIBUTE1               AS  CVNOM,
               SUM(CASE
                    WHEN SUBSTR (PETF.ELEMENT_NAME, 1, 1) = 'D' THEN
                        TO_NUMBER (NVL (PRRV.RESULT_VALUE, 0)) * -1
                    ELSE
                        TO_NUMBER (NVL (PRRV.RESULT_VALUE, 0))
                   END)                     AS  RESULT_VALUE
          FROM PAY_ALL_PAYROLLS_F           PPF,
               PAY_PAYROLL_ACTIONS          PPA,
               PER_TIME_PERIODS             PTP,
               PAY_ASSIGNMENT_ACTIONS       PAA,
               PAY_RUN_RESULTS              PRR,
               PAY_RUN_RESULT_VALUES        PRRV,
               PAY_INPUT_VALUES_F           PIVF,
               PAY_ELEMENT_TYPES_F          PETF,
               PAY_ELEMENT_CLASSIFICATIONS  PEC
         WHERE 1 = 1
           AND PPA.PAYROLL_ID = PPF.PAYROLL_ID
           AND PTP.PAYROLL_ID = PPF.PAYROLL_ID
           AND PPA.TIME_PERIOD_ID = PTP.TIME_PERIOD_ID
           AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
           AND PRR.ASSIGNMENT_ACTION_ID = PAA.ASSIGNMENT_ACTION_ID
           AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
           AND PIVF.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
           AND PETF.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
           AND PEC.CLASSIFICATION_ID = PETF.CLASSIFICATION_ID
           AND PPA.EFFECTIVE_DATE BETWEEN PPF.EFFECTIVE_START_DATE
                                      AND PPF.EFFECTIVE_END_DATE
           AND PAC_HR_PAY_PKG.GET_EMPLOYER_NAME (PPF.PAYROLL_NAME) = NVL(:P_EMPLOYER_NAME, PAC_HR_PAY_PKG.GET_EMPLOYER_NAME (PPF.PAYROLL_NAME))
           AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE (PPF.PAYROLL_NAME) = NVL(:P_PAY_PERIOD_TYPE, PAC_HR_PAY_PKG.GET_PERIOD_TYPE (PPF.PAYROLL_NAME))
           AND PPF.PAYROLL_NAME = NVL (:P_PAYROLL_NAME, PPF.PAYROLL_NAME)
           AND PPA.CONSOLIDATION_SET_ID = NVL (:P_CONSOLIDATION_SET_ID, PPA.CONSOLIDATION_SET_ID)
           AND EXTRACT(YEAR FROM PTP.END_DATE) = NVL(:P_PAYROLL_PERIOD_YEAR, EXTRACT(YEAR FROM PTP.END_DATE))
           AND EXTRACT(MONTH FROM PTP.END_DATE) BETWEEN NVL (:P_PAYROLL_START_MONTH_NUMBER, EXTRACT(MONTH FROM PTP.END_DATE))
                                                    AND NVL (:P_PAYROLL_END_MONTH_NUMBER, EXTRACT(MONTH FROM PTP.END_DATE))
           AND PTP.PERIOD_NUM BETWEEN NVL (:P_PAYROLL_START_PERIOD_NUMBER, PTP.PERIOD_NUM)
                                  AND NVL (:P_PAYROLL_END_PERIOD_NUMBER, PTP.PERIOD_NUM)
           AND PPA.EFFECTIVE_DATE BETWEEN PIVF.EFFECTIVE_START_DATE
                                      AND PIVF.EFFECTIVE_END_DATE 
           AND PIVF.NAME = 'Pay Value'
           AND PPA.EFFECTIVE_DATE BETWEEN PETF.EFFECTIVE_START_DATE
                                      AND PETF.EFFECTIVE_END_DATE   
           AND (   PETF.ELEMENT_NAME IN (SELECT MEANING
                                           FROM FND_LOOKUP_VALUES
                                          WHERE 1 = 1
                                            AND LOOKUP_TYPE IN ('XX_PERCEPCIONES_INFORMATIVAS',
                                                                'XX_DEDUCCIONES_INFORMATIVAS')
                                            AND LANGUAGE = USERENV('LANG'))                     
                OR PEC.CLASSIFICATION_NAME IN ('Earnings', 
                                               'Supplemental Earnings', 
                                               'Amends', 
                                               'Imputed Earnings',
                                               'Voluntary Deductions',
                                               'Involuntary Deductions'))
         GROUP 
            BY PPF.ATTRIBUTE1
        UNION
        SELECT /*+ LEADING(PAAF, PPF, PPA, PTP, PAA) */
               6666 + POPM.ORG_PAYMENT_METHOD_ID    AS  "ROWINDEX",
               POPM.ORG_PAYMENT_METHOD_NAME         AS  ELEMENT_NAME,
               POPM.ORG_PAYMENT_METHOD_NAME         AS  DESCRIPTION,
               PPF.ATTRIBUTE1                       AS  CVNOM,
               SUM(PPP.VALUE)                       AS  RESULT_VALUE
          FROM PER_ALL_ASSIGNMENTS_F        PAAF,
               PAY_ALL_PAYROLLS_F           PPF,
               PAY_PAYROLL_ACTIONS          PPA,
               PER_TIME_PERIODS             PTP,
               PAY_ASSIGNMENT_ACTIONS       PAA,
               PAY_PAYROLL_ACTIONS          PPA_PP,
               PAY_ASSIGNMENT_ACTIONS       PAA_PP,
               PAY_PRE_PAYMENTS             PPP,
               PAY_ORG_PAYMENT_METHODS_F    POPM,
               PAY_RUN_TYPES_F              PRT
         WHERE 1 = 1
           AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
           AND PPA.PAYROLL_ID = PPF.PAYROLL_ID
           AND PTP.PAYROLL_ID = PPF.PAYROLL_ID
           AND PPA.TIME_PERIOD_ID = PTP.TIME_PERIOD_ID
           AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
           AND PRT.RUN_TYPE_ID = PAA.RUN_TYPE_ID
           AND PPA.EFFECTIVE_DATE BETWEEN PPF.EFFECTIVE_START_DATE
                                      AND PPF.EFFECTIVE_END_DATE                                                              
           AND PAC_HR_PAY_PKG.GET_EMPLOYER_NAME (PPF.PAYROLL_NAME) = NVL(:P_EMPLOYER_NAME, PAC_HR_PAY_PKG.GET_EMPLOYER_NAME (PPF.PAYROLL_NAME))
           AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE (PPF.PAYROLL_NAME) = NVL(:P_PAY_PERIOD_TYPE, PAC_HR_PAY_PKG.GET_PERIOD_TYPE (PPF.PAYROLL_NAME))
           AND PPF.PAYROLL_NAME = NVL (:P_PAYROLL_NAME, PPF.PAYROLL_NAME)
           AND PPA.CONSOLIDATION_SET_ID = NVL (:P_CONSOLIDATION_SET_ID, PPA.CONSOLIDATION_SET_ID)
           AND EXTRACT(YEAR FROM PTP.END_DATE) = NVL(:P_PAYROLL_PERIOD_YEAR, EXTRACT(YEAR FROM PTP.END_DATE))
           AND EXTRACT(MONTH FROM PTP.END_DATE) BETWEEN NVL (:P_PAYROLL_START_MONTH_NUMBER, EXTRACT(MONTH FROM PTP.END_DATE))
                                                    AND NVL (:P_PAYROLL_END_MONTH_NUMBER, EXTRACT(MONTH FROM PTP.END_DATE))
           AND PTP.PERIOD_NUM BETWEEN NVL (:P_PAYROLL_START_PERIOD_NUMBER, PTP.PERIOD_NUM)
                                  AND NVL (:P_PAYROLL_END_PERIOD_NUMBER, PTP.PERIOD_NUM)
           AND PPF.PAYROLL_ID = PPA_PP.PAYROLL_ID
           AND PPA.CONSOLIDATION_SET_ID = PPA_PP.CONSOLIDATION_SET_ID
           AND PPA.EFFECTIVE_DATE = PPA_PP.EFFECTIVE_DATE
           AND PPA_PP.PAYROLL_ACTION_ID = PAA_PP.PAYROLL_ACTION_ID
           AND PAA_PP.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
           AND PAA_PP.ASSIGNMENT_ACTION_ID = PPP.ASSIGNMENT_ACTION_ID
           AND PPA_PP.ACTION_TYPE IN ('P')
           AND PPA.EFFECTIVE_DATE BETWEEN PAAF.EFFECTIVE_START_DATE
                                      AND PAAF.EFFECTIVE_END_DATE 
           AND PAA.ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID
           AND POPM.ORG_PAYMENT_METHOD_ID = PPP.ORG_PAYMENT_METHOD_ID
           AND PPA_PP.EFFECTIVE_DATE BETWEEN POPM.EFFECTIVE_START_DATE
                                      AND POPM.EFFECTIVE_END_DATE   
         GROUP 
            BY POPM.ORG_PAYMENT_METHOD_ID,
               POPM.ORG_PAYMENT_METHOD_NAME,
               PPF.ATTRIBUTE1
         ORDER 
            BY 1;
         