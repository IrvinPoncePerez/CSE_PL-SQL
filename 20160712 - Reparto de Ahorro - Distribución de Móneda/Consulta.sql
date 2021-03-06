 SELECT ASM.MEMBER_ID,
                       ASM.PERSON_ID,
                       ASM.EMPLOYEE_NUMBER,
                       ASM.EMPLOYEE_FULL_NAME,
                       (ASMA1.FINAL_BALANCE + ASMA2.FINAL_BALANCE) AS   FINAL_BALANCE,
                       ASMA1.FINAL_BALANCE                         AS   SAVING_FINAL_BALANCE,
                       ASMA1.MEMBER_ACCOUNT_ID                     AS   SAVING_ACCOUNT_ID,
                       ASMA1.ACCOUNT_DESCRIPTION                   AS   SAVING_ACCOUNT_DESCRIPTION,
                       ASMA2.FINAL_BALANCE                         AS   INTEREST_FINAL_BALANCE,
                       ASMA2.MEMBER_ACCOUNT_ID                     AS   INTEREST_ACCOUNT_ID,
                       ASMA2.ACCOUNT_DESCRIPTION                   AS   INTEREST_ACCOUNT_DESCRIPTION
                  FROM ATET_SB_MEMBERS                  ASM,
                       ATET_SB_MEMBERS_ACCOUNTS         ASMA1,
                       ATET_SB_MEMBERS_ACCOUNTS         ASMA2,
                       PER_ASSIGNMENTS_F                PAF,
                       PAY_PERSONAL_PAYMENT_METHODS_F   PPM,
                       PAY_ORG_PAYMENT_METHODS_F        OPM
                 WHERE 1 = 1
                   AND ASM.MEMBER_ID = ASMA1.MEMBER_ID
                   AND ASM.MEMBER_ID = ASMA2.MEMBER_ID
                   AND ASMA1.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO'
                   AND ASMA2.ACCOUNT_DESCRIPTION = 'INTERES GANADO'
                   AND (ASMA1.FINAL_BALANCE + ASMA2.FINAL_BALANCE) > 0
                   AND ASM.PERSON_ID = PAF.PERSON_ID
                   AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
                   AND PAF.ASSIGNMENT_ID = PPM.ASSIGNMENT_ID
                   AND SYSDATE BETWEEN PPM.EFFECTIVE_START_DATE AND PPM.EFFECTIVE_END_DATE
                   AND OPM.ORG_PAYMENT_METHOD_ID = PPM.ORG_PAYMENT_METHOD_ID
                   AND SYSDATE BETWEEN OPM.EFFECTIVE_START_DATE AND OPM.EFFECTIVE_END_DATE
                   AND OPM.ORG_PAYMENT_METHOD_NAME LIKE '%EFECTIVO%'
                   AND ASM.MEMBER_ID IN (416, 337, 359, 355, 387);
        
     
     
    SELECT ASM.MEMBER_ID,
           ASM.EMPLOYEE_NUMBER,
           ASM.EMPLOYEE_FULL_NAME
      FROM ATET_SB_MEMBERS                  ASM,
           ATET_SB_MEMBERS_ACCOUNTS         ASMA1,
           ATET_SB_MEMBERS_ACCOUNTS         ASMA2
     WHERE 1 = 1
       AND ASM.MEMBER_ID = ASMA1.MEMBER_ID
       AND ASM.MEMBER_ID = ASMA2.MEMBER_ID
       AND ASMA1.ACCOUNT_DESCRIPTION = 'D071_CAJA DE AHORRO'
       AND ASMA2.ACCOUNT_DESCRIPTION = 'INTERES GANADO'
       AND (ASMA1.FINAL_BALANCE + ASMA2.FINAL_BALANCE) > 0
     ORDER BY 2 ;
     
     SELECT ACD.SAVING_RETIREMENT_ROUND,
                       ASM.MEMBER_ID,
                       ASM.EMPLOYEE_NUMBER,
                       ASM.EMPLOYEE_FULL_NAME
                  FROM ATET_CURRENCY_DISTRIBUTION_TB    ACD,
                       ATET_SB_MEMBERS                  ASM,
                       ATET_SB_MEMBERS_ACCOUNTS         ASMA,
                       ATET_SB_SAVINGS_TRANSACTIONS     ASST
                 WHERE 1 = 1
                   AND ACD.ACCOUNT_DESCRIPTION = 'INTERES GANADO'
                   AND ACD.SAVING_BANK_ID = atet_savings_bank_pkg.GET_SAVING_BANK_ID
                   AND ASM.MEMBER_ID = ACD.MEMBER_ID
                   AND ASM.MEMBER_ID = ASMA.MEMBER_ID
                   AND ASMA.ACCOUNT_DESCRIPTION = ACD.ACCOUNT_DESCRIPTION
                   AND ASM.MEMBER_ID = ASST.MEMBER_ID
                   AND ASST.MEMBER_ACCOUNT_ID = ASMA.MEMBER_ACCOUNT_ID
                   AND ASST.ATTRIBUTE2 = ACD.SAVING_RETIREMENT_ROUND;
                   
                   
    SELECT *
  FROM (SELECT SUM(CURRENCY_500) AS "CURRENCY_500",
               SUM(CURRENCY_200) AS "CURRENCY_200",
               SUM(CURRENCY_100) AS "CURRENCY_100",
               SUM(CURRENCY_50) AS "CURRENCY_50",
               SUM(CURRENCY_20) AS "CURRENCY_20",
               SUM(CURRENCY_10) AS "CURRENCY_10",
               SUM(CURRENCY_5) AS "CURRENCY_5",
               SUM(CURRENCY_2) AS "CURRENCY_2",
               SUM(CURRENCY_1) AS "CURRENCY_1",
               SUM(CURRENCY_50C) AS "CURRENCY_C",
               (SUM(CURRENCY_500) * 500) AS "TOTAL_500",
               (SUM(CURRENCY_200) * 200) AS "TOTAL_200",
               (SUM(CURRENCY_100) * 100) AS "TOTAL_100",
               (SUM(CURRENCY_50) * 50) AS "TOTAL_50",
               (SUM(CURRENCY_20) * 20) AS "TOTAL_20",
               (SUM(CURRENCY_10) * 10) AS "TOTAL_10",
               (SUM(CURRENCY_5) * 5) AS "TOTAL_5",
               (SUM(CURRENCY_2) * 2) AS "TOTAL_2",
               (SUM(CURRENCY_1) * 1) AS "TOTAL_1",
               (SUM(CURRENCY_50C) * .5) AS "TOTAL_C"
          FROM ATET_CURRENCY_DISTRIBUTION_TB) 
               UNPIVOT ( (QUANTITY, TOTAL) FOR CURRENCY IN ((CURRENCY_500, TOTAL_500) AS 'QUINIENTOS PESOS',
                                                            (CURRENCY_200, TOTAL_200) AS 'DOSCIENTOS PESOS',
                                                            (CURRENCY_100, TOTAL_100) AS 'CIEN PESOS',
                                                            (CURRENCY_50, TOTAL_50) AS 'CINCUENTA PESOS',
                                                            (CURRENCY_20, TOTAL_20) AS 'VEINTE PESOS',
                                                            (CURRENCY_10, TOTAL_10) AS 'DIEZ PESOS',
                                                            (CURRENCY_5, TOTAL_5) AS 'CINCO PESOS',
                                                            (CURRENCY_2, TOTAL_2) AS 'DOS PESOS',
                                                            (CURRENCY_1, TOTAL_1) AS 'UN PESO',
                                                            (CURRENCY_C, TOTAL_C) AS 'CINCUENTA CENTAVOS'
                                                           )
                       );