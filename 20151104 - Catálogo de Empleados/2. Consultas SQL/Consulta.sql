SELECT PAPF.PERSON_ID,
       PAAF.ASSIGNMENT_ID,
       PEA_SDO.EXTERNAL_ACCOUNT_ID,
       PPF.PAYROLL_ID,
       PPF.PERIOD_TYPE                                                              AS  "PERIOD_TYPE",
       PPF.PAYROLL_NAME                                                             AS  "PAYROLL_NAME",
       PAPF.EMPLOYEE_NUMBER                                                         AS  "EMPLOYEE_NUMBER",
       PAPF.FULL_NAME                                                               AS  "EMPLOYEE_FULL_NAME",
       PAPF.LAST_NAME                                                               AS  "LAST_NAME",
       PAPF.PER_INFORMATION1                                                        AS  "SECOND_LAST_NAME" , 
       (PAPF.FIRST_NAME 
        || ' ' || 
        PAPF.MIDDLE_NAMES)                                                          AS  "NAMES",
       PA.ADDRESS_LINE1                                                             AS  "STREET",
       PA.ADDR_ATTRIBUTE2                                                           AS  "EXTERNAL_NUMBER",
       PA.ADDR_ATTRIBUTE1                                                           AS  "INTERNAL_NUMBER",  
       PA.ADDRESS_LINE2                                                             AS  "NEIGHBORHOOD", 
       PA.REGION_2                                                                  AS  "MUNICIPALITY",
       PA.TOWN_OR_CITY                                                              AS  "CITY",
       UPPER(PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('MX_STATE', PA.REGION_1))            AS  "STATE",
       (SELECT UPPER(NVL(FT2.NLS_TERRITORY, ' '))
          FROM PER_ADDRESSES    PA,
               FND_TERRITORIES  FT2
         WHERE PA.PERSON_ID = PAPF.PERSON_ID
           AND FT2.TERRITORY_CODE = PA.COUNTRY)                                     AS  "COUNTRY",
       PA.POSTAL_CODE                                                               AS  "POSTAL_CODE",
       NVL(PA.TELEPHONE_NUMBER_1,
           NVL(PA.TELEPHONE_NUMBER_2,
               PA.TELEPHONE_NUMBER_3))                                              AS  "TELEPHONE",
       UPPER(PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('SEX', PAPF.SEX))                    AS  "SEX",
       DECODE(NVL(PAPF.NATIONALITY, 'NOTHING'), 
              'NOTHING', ' ',
              UPPER(PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('NATIONALITY', 
                                                      PAPF.NATIONALITY)))           AS  "NATIONALITY",
       PAPF.TOWN_OF_BIRTH                                                           AS  "TOWN_OF_BIRTH",
       TO_DATE(PAPF.DATE_OF_BIRTH, 'DD-MON-YYYY')                                   AS  "DATE_OF_BIRTH",
       PAPF.ATTRIBUTE10                                                             AS  "LEVEL_OF_EDUCATION",
       DECODE(NVL(PAAF.EMPLOYMENT_CATEGORY, 'NOTHING'),
              'NOTHING', ' ',
              UPPER(PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('EMP_CAT', 
                                                      PAAF.EMPLOYMENT_CATEGORY)))   AS  "ASSIGNMENT_CATEGORY",
       REPLACE(PAAF.ASS_ATTRIBUTE1, '00:00:00', '')                                 AS  "CONTRACT_TERMINATION_DATE",
       PPG.SEGMENT2                                                                 AS  "MANAGEMENT_NUM",
       PAC_HR_PAY_PKG.GET_MANAGEMENT_BY_GROUPID(PAAF.PEOPLE_GROUP_ID)               AS  "MANAGEMENT_DESC",
       PAC_HR_PAY_PKG.GET_DEPARTMENT_NUMBER(PAAF.ORGANIZATION_ID)                   AS  "DEPARTMENT_NUMBER",
       PAC_HR_PAY_PKG.GET_DEPARTMENT_NAME(PAAF.ORGANIZATION_ID)                     AS  "DEPARTMENT_NAME",
       PAC_HR_PAY_PKG.GET_POSITION_NAME(PAAF.POSITION_ID)                           AS  "POSITION_NAME",
       PAC_HR_PAY_PKG.GET_NAME_JOB(PAPF.PERSON_ID)                                  AS  "JOB_NAME",
       PAAF.ASS_ATTRIBUTE30                                                         AS  "TIME_TURN",
       DECODE(NVL(PAAF.EMPLOYEE_CATEGORY, 'NOTHING'),
              'NOTHING', ' ', 
              UPPER(PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('EMPLOYEE_CATG', 
                                                      PAAF.EMPLOYEE_CATEGORY)))     AS  "EMPLOY_CATEGORY",     
       PAPF.PER_INFORMATION2                                                        AS  "RFC",
       PAPF.NATIONAL_IDENTIFIER                                                     AS  "CURP",
       PAPF.PER_INFORMATION3                                                        AS  "NSS",
       PAPF.ATTRIBUTE15                                                             AS  "DELEGATION_IMSS",
       PAPF.ATTRIBUTE20                                                             AS  "SUBDELEGATION_IMSS",
       PAPF.PER_INFORMATION4                                                        AS  "SOCIAL_SECURITY_MEDICAL_CENTER",
       PAC_HR_PAY_PKG.GET_EMPLOYER_REGISTRATION(PAAF.ASSIGNMENT_ID)                 AS  "EMPLOYER_REGISTRATION",
       PAC_RESULT_VALUES_PKG.GET_EFFECTIVE_START_DATE(PAAF.PERSON_ID)               AS  "EFFECTIVE_START_DATE",
       PAC_HR_PAY_PKG.GET_SALARIO_BASE_JC(PAAF.ASSIGNMENT_ID)                       AS  "BASIC_SALARY",
       PAC_HR_PAY_PKG.GET_DIARY_SALARY(PAPF.PERSON_ID)                              AS  "IDW",
       PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('UNICO INGRESO EMPLEADO', 1)               AS  "SINGLE_EMPLOYEE",  
       PAAF.ASS_ATTRIBUTE20                                                         AS  "BONO_DESP",
       UPPER(PPT_DESP.PAYMENT_TYPE_NAME)                                            AS  "PAYMENT_TYPE_DESP",
       REPLACE(REPLACE(PEA_DESP.SEGMENT3, CHR(10), ''), CHR(13), '')                AS  "ACCOUNT_DESP",
       REPLACE(REPLACE(PPPM_DESP.ATTRIBUTE1, CHR(10), ''), CHR(13), '')             AS  "CARD_DESP",
       UPPER(PPT_SDO.PAYMENT_TYPE_NAME)                                             AS  "PAYMENT_TYPE_SDO",
       POPM_SDO.ORG_PAYMENT_METHOD_NAME                                             AS  "PAYMENT_METHOD_NAME",
       PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('MX_BANK', PEA_SDO.SEGMENT1)               AS  "BANK",
       REPLACE(REPLACE(PEA_SDO.SEGMENT3, CHR(10), ''), CHR(13), '')                 AS  "ACCOUNT_SDO",
       REPLACE(REPLACE(PPPM_SDO.ATTRIBUTE1, CHR(10), ''), CHR(13), '')              AS  "CARD_SDO",
       PAAF.ASS_ATTRIBUTE10                                                         AS  "AFORE",
       PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAC_RESULT_VALUES_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(PAAF.ASSIGNMENT_ID,
                                                                                                PPF.PAYROLL_ID,
                                                                                                :P_YEAR),
                                             'D058_INFONAVIT',
                                             'Credit Number')                       AS  "INFONAVIT_CREDIT_NUMBER",
       (CASE 
        WHEN PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAC_RESULT_VALUES_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(PAAF.ASSIGNMENT_ID,
                                                                                                      PPF.PAYROLL_ID,
                                                                                                      :P_YEAR),
                                                   'D058_INFONAVIT',
                                                   'Discount Start Date') IS NOT NULL THEN
            SUBSTR(PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAC_RESULT_VALUES_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(PAAF.ASSIGNMENT_ID,
                                                                                                            PPF.PAYROLL_ID,
                                                                                                            :P_YEAR),
                                                         'D058_INFONAVIT',
                                                         'Discount Start Date'), 1, 11)
        END)                                                                        AS  "INFONAVIT_START_DATE",
       (CASE PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAC_RESULT_VALUES_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(PAAF.ASSIGNMENT_ID,
                                                                                                      PPF.PAYROLL_ID,
                                                                                                      :P_YEAR),
                                                   'D058_INFONAVIT',
                                                   'Discount Type')
             WHEN 'P' THEN '1'
             WHEN 'C' THEN '2'
             WHEN 'V' THEN '3'
             ELSE PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAC_RESULT_VALUES_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(PAAF.ASSIGNMENT_ID,
                                                                                                           PPF.PAYROLL_ID,
                                                                                                           :P_YEAR),  
                                                        'D058_INFONAVIT',
                                                        'Discount Type')
        END)                                                                        AS  "INFONAVIT_DISCOUNT_TYPE",
       PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAC_RESULT_VALUES_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(PAAF.ASSIGNMENT_ID,
                                                                                                PPF.PAYROLL_ID,
                                                                                                :P_YEAR),
                                             'D058_INFONAVIT',
                                             'Discount Value')                      AS  "INFONAVIT_DISCOUNT_VALUE",
       
       
       

       UPPER(PPTT.USER_PERSON_TYPE)                                                 AS  "PERSON_TYPE"
  FROM PAY_PAYROLLS_F                       PPF,
       FND_LOOKUP_VALUES                    FLV1,
       PER_ALL_PEOPLE_F                     PAPF,             
       PER_ALL_ASSIGNMENTS_F                PAAF,
       PER_PERSON_TYPES_TL                  PPTT,
       PER_ADDRESSES                        PA,
       PAY_PEOPLE_GROUPS                    PPG,
       PAY_PERSONAL_PAYMENT_METHODS_F       PPPM_DESP,
       PAY_ORG_PAYMENT_METHODS_F            POPM_DESP,
       PAY_PAYMENT_TYPES_TL                 PPT_DESP,
       PAY_EXTERNAL_ACCOUNTS                PEA_DESP,
       FND_LOOKUP_VALUES                    FLV_DESP,
       PAY_PERSONAL_PAYMENT_METHODS_F       PPPM_SDO,
       PAY_ORG_PAYMENT_METHODS_F            POPM_SDO,
       PAY_PAYMENT_TYPES_TL                 PPT_SDO,
       PAY_EXTERNAL_ACCOUNTS                PEA_SDO,
       FND_LOOKUP_VALUES                    FLV_SDO     
 WHERE 1 = 1
   AND FLV1.LOOKUP_TYPE = 'NOMINAS POR EMPLEADOR LEGAL'
   AND FLV1.LOOKUP_CODE = :P_COMPANY_ID
   AND FLV1.LANGUAGE = USERENV('LANG')
   AND SUBSTR(PPF.PAYROLL_NAME,1,2) = FLV1.LOOKUP_CODE
   AND APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(:P_PERIOD_TYPE, APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
   AND PPF.PAYROLL_ID = NVL(:P_PAYROLL_ID, PPF.PAYROLL_ID)
   AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
   AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
   AND PAAF.PERSON_ID = PAPF.PERSON_ID 
   AND NVL(:P_YEAR, EXTRACT(YEAR FROM SYSDATE)) BETWEEN EXTRACT(YEAR FROM PAPF.EFFECTIVE_START_DATE) AND EXTRACT(YEAR FROM PAPF.EFFECTIVE_END_DATE)
   AND PPTT.PERSON_TYPE_ID = PAPF.PERSON_TYPE_ID
   AND PPTT.LANGUAGE = USERENV('LANG')
   AND PPTT.USER_PERSON_TYPE = NVL(:P_PERSON_TYPE, PPTT.USER_PERSON_TYPE)
   AND PAPF.PERSON_ID = PA.PERSON_ID
   AND PAAF.PEOPLE_GROUP_ID = PPG.PEOPLE_GROUP_ID
   AND PAAF.ASSIGNMENT_ID = PPPM_DESP.ASSIGNMENT_ID
   AND PAAF.ASSIGNMENT_ID = PPPM_SDO.ASSIGNMENT_ID
   /******************************************DESPENSA*/
   AND PPPM_DESP.ORG_PAYMENT_METHOD_ID = POPM_DESP.ORG_PAYMENT_METHOD_ID
   AND POPM_DESP.PAYMENT_TYPE_ID = PPT_DESP.PAYMENT_TYPE_ID
   AND PPPM_DESP.EXTERNAL_ACCOUNT_ID = PEA_DESP.EXTERNAL_ACCOUNT_ID
   AND PPT_DESP.LANGUAGE = USERENV('LANG')
   AND FLV_DESP.LOOKUP_TYPE = 'XXCALV_METODOS_DESPEN'
   AND FLV_DESP.LANGUAGE = USERENV('LANG')
   AND FLV_DESP.MEANING = POPM_DESP.ORG_PAYMENT_METHOD_NAME
   /******************************************SUELDO***/
   AND PPPM_SDO.ORG_PAYMENT_METHOD_ID = POPM_SDO.ORG_PAYMENT_METHOD_ID
   AND POPM_SDO.PAYMENT_TYPE_ID = PPT_SDO.PAYMENT_TYPE_ID
   AND PPPM_SDO.EXTERNAL_ACCOUNT_ID = PEA_SDO.EXTERNAL_ACCOUNT_ID
   AND PPT_SDO.LANGUAGE = USERENV('LANG')
   AND FLV_SDO.LOOKUP_TYPE = 'XXCALV_METODOS_PAGO'
   AND FLV_SDO.LANGUAGE = USERENV('LANG')
   AND FLV_SDO.MEANING = POPM_SDO.ORG_PAYMENT_METHOD_NAME
   /**************************************************/
   AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
   AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
   AND SYSDATE BETWEEN PPPM_DESP.EFFECTIVE_START_DATE AND PPPM_DESP.EFFECTIVE_END_DATE
   AND SYSDATE BETWEEN POPM_DESP.EFFECTIVE_START_DATE AND POPM_DESP.EFFECTIVE_END_DATE
   AND SYSDATE BETWEEN PPPM_SDO.EFFECTIVE_START_DATE AND PPPM_SDO.EFFECTIVE_END_DATE
   AND SYSDATE BETWEEN POPM_SDO.EFFECTIVE_START_DATE AND POPM_SDO.EFFECTIVE_END_DATE   
--   AND PAPF.PERSON_ID IN (78)
 ORDER BY PERIOD_TYPE,
          PAYROLL_NAME,
          TO_NUMBER(EMPLOYEE_NUMBER);
   
