SELECT D.COMPANY_NAME,
       D.EMPLOYEE_NUMBER,
       D.EMPLOYEE_FULL_NAME,
       D.PERSON_ID,
       D.PP_MEMBER_ID,
       D.CURP,
       D.RFC,
       D.PAYROLL_NAME,
       D.DEPARTMENT_NAME,
       D.JOB_NAME,
       D.PRINT_DATE,
       ROWNUM   AS  RECEIPT_NUMBER
  FROM (SELECT 'ASOCIACION DE TRABAJADORES Y EMPLEADOS DE TEHUACAN, S.C.'   AS  "COMPANY_NAME",
               ASM.EMPLOYEE_NUMBER                                          AS  "EMPLOYEE_NUMBER",
               ASM.EMPLOYEE_FULL_NAME                                       AS  "EMPLOYEE_FULL_NAME",
               ASM.MEMBER_ID                                                AS  "PP_MEMBER_ID",
               ASM.PERSON_ID                                                AS  "PERSON_ID",
               PAPF.NATIONAL_IDENTIFIER                                     AS  "CURP",
               PAPF.PER_INFORMATION2                                        AS  "RFC",
               PPF.PAYROLL_NAME                                             AS  "PAYROLL_NAME",
               HOU.NAME                                                     AS  "DEPARTMENT_NAME",
               HAP.NAME                                                     AS  "JOB_NAME",
               TO_DATE(SYSDATE, 'DD/MM/RRRR')                               AS  "PRINT_DATE"
          FROM ATET_SB_MEMBERS          ASM,
               ATET_SB_MEMBERS_ACCOUNTS ASMA_SAV,
               ATET_SB_MEMBERS_ACCOUNTS ASMA_INT,
               PER_ALL_PEOPLE_F         PAPF,
               PER_ALL_ASSIGNMENTS_F    PAAF,
               PAY_PAYROLLS_F           PPF,
               HR_ORGANIZATION_UNITS    HOU,
               HR_ALL_POSITIONS_F       HAP,
               ATET_SAVINGS_BANK        ASB
         WHERE 1 = 1
           AND ASM.MEMBER_ID = ASMA_SAV.MEMBER_ID
           AND ASM.MEMBER_ID = ASMA_INT.MEMBER_ID
           AND ASMA_SAV.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO'
           AND ASMA_INT.ACCOUNT_DESCRIPTION = 'INTERES GANADO'
           AND ASMA_SAV.FINAL_BALANCE = 0
           AND ASMA_INT.FINAL_BALANCE = 0
           AND PAPF.PERSON_ID = ASM.PERSON_ID
           AND PAAF.PERSON_ID = ASM.PERSON_ID
           AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
           AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
           AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
           AND HOU.ORGANIZATION_ID = PAAF.ORGANIZATION_ID
           AND HAP.POSITION_ID = PAAF.POSITION_ID
           AND SYSDATE BETWEEN HAP.EFFECTIVE_START_DATE AND HAP.EFFECTIVE_END_DATE
           AND ASM.SAVING_BANK_ID = ASB.SAVING_BANK_ID
           AND HOU.ORGANIZATION_ID = NVL(:P_ORGANIZATION_ID, HOU.ORGANIZATION_ID)
           AND PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
           AND ASM.MEMBER_ID = NVL(:P_MEMBER_ID, ASM.MEMBER_ID)
           AND ASB.YEAR = :P_YEAR 
         ORDER BY DEPARTMENT_NAME,
                  EMPLOYEE_NUMBER) D
 WHERE 1 = 1;

   
   
  