CREATE OR REPLACE PROCEDURE PAC_CAT_EMPLEADOS_PRC(
                P_ERRBUF    OUT NOCOPY  VARCHAR2,
                P_RETCODE   OUT NOCOPY  VARCHAR2,
                P_COMPANY_ID            VARCHAR2,
                P_PERIOD_TYPE           VARCHAR2,
                P_PAYROLL_ID            VARCHAR2,
                P_PERSON_TYPE           VARCHAR2,
                P_YEAR                  VARCHAR2)
IS
    
        
    var_data                        VARCHAR2(30000);
    var_company_name	            VARCHAR2(250);
	var_payroll_name	            VARCHAR2(250);
    
    CURSOR DETAIL_LIST IS
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
                                                                                                        P_YEAR),
                                                     'D058_INFONAVIT',
                                                     'Credit Number')                       AS  "INFONAVIT_CREDIT_NUMBER",
               (CASE 
                WHEN PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAC_RESULT_VALUES_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(PAAF.ASSIGNMENT_ID,
                                                                                                              PPF.PAYROLL_ID,
                                                                                                              P_YEAR),
                                                           'D058_INFONAVIT',
                                                           'Discount Start Date') IS NOT NULL THEN
                    SUBSTR(PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAC_RESULT_VALUES_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(PAAF.ASSIGNMENT_ID,
                                                                                                                    PPF.PAYROLL_ID,
                                                                                                                    P_YEAR),
                                                                 'D058_INFONAVIT',
                                                                 'Discount Start Date'), 1, 11)
                END)                                                                        AS  "INFONAVIT_START_DATE",
               (CASE PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAC_RESULT_VALUES_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(PAAF.ASSIGNMENT_ID,
                                                                                                              PPF.PAYROLL_ID,
                                                                                                              P_YEAR),
                                                           'D058_INFONAVIT',
                                                           'Discount Type')
                     WHEN 'P' THEN '1'
                     WHEN 'C' THEN '2'
                     WHEN 'V' THEN '3'
                     ELSE PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAC_RESULT_VALUES_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(PAAF.ASSIGNMENT_ID,
                                                                                                                   PPF.PAYROLL_ID,
                                                                                                                   P_YEAR),  
                                                                'D058_INFONAVIT',
                                                                'Discount Type')
                END)                                                                        AS  "INFONAVIT_DISCOUNT_TYPE",
               PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAC_RESULT_VALUES_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(PAAF.ASSIGNMENT_ID,
                                                                                                        PPF.PAYROLL_ID,
                                                                                                        P_YEAR),
                                                     'D058_INFONAVIT',
                                                     'Discount Value')                      AS  "INFONAVIT_DISCOUNT_VALUE",
               PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAC_RESULT_VALUES_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(PAAF.ASSIGNMENT_ID,
                                                                                                        PPF.PAYROLL_ID,
                                                                                                        P_YEAR),
                                                     'D076_DESC_PENSION_ALIM',
                                                     'Porcentaje')                          AS  "PENSION_PORCENTAJE", 
               PAC_RESULT_VALUES_PKG.GET_OTHER_VALUE(PAC_RESULT_VALUES_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(PAAF.ASSIGNMENT_ID,
                                                                                                        PPF.PAYROLL_ID,
                                                                                                        P_YEAR),
                                                     'D076_DESC_PENSION_ALIM',
                                                     'Amount')                              AS  "PENSION_AMOUNT",
               PAPF.EMAIL_ADDRESS                                                           AS  "EMAIL_ADDRESS",
               DECODE(NVL(PAPF.MARITAL_STATUS, 'NOTHING'),
                      'NOTHING', ' ',
                      UPPER(PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('MAR_STATUS', PAPF.MARITAL_STATUS))) AS  "MARITAL_STATUS",
               PAPF.ATTRIBUTE5                                                              AS  "REGIMEN_MATRIMONIAL",
               UPPER(PPTT.USER_PERSON_TYPE)                                                 AS  "PERSON_TYPE",
               PPOS.ACTUAL_TERMINATION_DATE                                                 AS  "EFFECTIVE_END_DATE",
               PAC_HR_PAY_PKG.GET_AREA_BY_PEOPLE_GROUP_ID(PAAF.PEOPLE_GROUP_ID)             AS  "AREA"
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
               FND_LOOKUP_VALUES                    FLV_SDO,
               PER_PERIODS_OF_SERVICE               PPOS     
         WHERE 1 = 1
           AND FLV1.LOOKUP_TYPE = 'NOMINAS POR EMPLEADOR LEGAL'
           AND FLV1.LOOKUP_CODE = P_COMPANY_ID
           AND FLV1.LANGUAGE = USERENV('LANG')
           AND SUBSTR(PPF.PAYROLL_NAME,1,2) = FLV1.LOOKUP_CODE
           AND APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME) = NVL(P_PERIOD_TYPE, APPS.PAC_HR_PAY_PKG.GET_PERIOD_TYPE(PPF.PAYROLL_NAME))
           AND PPF.PAYROLL_ID = NVL(P_PAYROLL_ID, PPF.PAYROLL_ID)
           AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID
           AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
           AND PAAF.PERSON_ID = PAPF.PERSON_ID 
           AND NVL(P_YEAR, EXTRACT(YEAR FROM SYSDATE)) BETWEEN EXTRACT(YEAR FROM PAPF.EFFECTIVE_START_DATE) AND EXTRACT(YEAR FROM PAPF.EFFECTIVE_END_DATE)
           AND PPTT.PERSON_TYPE_ID = PAPF.PERSON_TYPE_ID
           AND PPTT.LANGUAGE = USERENV('LANG')
           AND PPTT.USER_PERSON_TYPE = NVL(P_PERSON_TYPE, PPTT.USER_PERSON_TYPE)
           AND PAPF.PERSON_ID = PA.PERSON_ID
           AND PAAF.PEOPLE_GROUP_ID = PPG.PEOPLE_GROUP_ID
           AND PAAF.ASSIGNMENT_ID = PPPM_DESP.ASSIGNMENT_ID
           AND PAAF.ASSIGNMENT_ID = PPPM_SDO.ASSIGNMENT_ID
           AND PPOS.PERSON_ID = PAPF.PERSON_ID
           AND PPOS.PERIOD_OF_SERVICE_ID = PAAF.PERIOD_OF_SERVICE_ID
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
           AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PPPM_DESP.EFFECTIVE_START_DATE AND PPPM_DESP.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN POPM_DESP.EFFECTIVE_START_DATE AND POPM_DESP.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PPPM_SDO.EFFECTIVE_START_DATE AND PPPM_SDO.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN POPM_SDO.EFFECTIVE_START_DATE AND POPM_SDO.EFFECTIVE_END_DATE   
         ORDER BY PERIOD_TYPE,
                  PAYROLL_NAME,
                  TO_NUMBER(EMPLOYEE_NUMBER);
    
    
    TYPE    DETAILS IS TABLE OF DETAIL_LIST%ROWTYPE INDEX BY PLS_INTEGER;
    
    detail  DETAILS;
BEGIN
            
    dbms_output.put_line('P_COMPANY_ID : '      || P_COMPANY_ID);
    dbms_output.put_line('P_PERIOD_TYPE : '     || P_PERIOD_TYPE);
    dbms_output.put_line('P_PAYROLL_ID : '      || P_PAYROLL_ID);
    dbms_output.put_line('P_PERSON_TYPE : '     || P_PERSON_TYPE);
    dbms_output.put_line('P_YEAR : '            || P_YEAR);
            
    fnd_file.put_line(fnd_file.log, 'P_COMPANY_ID : '   || P_COMPANY_ID);
    fnd_file.put_line(fnd_file.log, 'P_PERIOD_TYPE : '  || P_PERIOD_TYPE);
    fnd_file.put_line(fnd_file.log, 'P_PAYROLL_ID : '   || P_PAYROLL_ID);
    fnd_file.put_line(fnd_file.log, 'P_PERSON_TYPE : '  || P_PERSON_TYPE);
    fnd_file.put_line(fnd_file.log, 'P_YEAR : '         || P_YEAR);
    
    
    BEGIN
		
		SELECT UPPER(meaning)
			INTO var_company_name
			FROM fnd_lookup_values
		 WHERE lookup_type = 'NOMINAS POR EMPLEADOR LEGAL'
			 AND LANGUAGE = userenv('LANG')
			 AND lookup_code = P_COMPANY_ID;
			
	EXCEPTION WHEN OTHERS THEN
		fnd_file.put_line(fnd_file.log, 'No se consulto el Nombre de la Empresa. ' || SQLERRM);
	END;
    
    
    BEGIN
		
		SELECT DISTINCT PAYROLL_NAME
		  INTO var_payroll_name
			FROM PAY_PAYROLLS_F
		 WHERE PAYROLL_ID = P_PAYROLL_ID;
		
	EXCEPTION WHEN OTHERS THEN
		fnd_file.put_line(fnd_file.log, 'No se consulto el Nombre de la Nómina. ' || SQLERRM);	
	END;
        
        
   
    fnd_file.PUT_LINE(fnd_file.OUTPUT, 'CATALOGO DE EMPLEADOS,');
    fnd_file.PUT_LINE(fnd_file.OUTPUT, 'COMPAÑÍA : ,'   || var_company_name);
    fnd_file.PUT_LINE(fnd_file.OUTPUT, 'PERIODO : ,'    || NVL(P_PERIOD_TYPE, 'TODOS'));
    fnd_file.PUT_LINE(fnd_file.OUTPUT, 'NÓMINA : ,'     || NVL(var_payroll_name, 'TODAS'));
    fnd_file.PUT_LINE(fnd_file.OUTPUT, 'ESTATUS : ,'    || NVL(P_PERSON_TYPE, 'TODOS'));
    fnd_file.PUT_LINE(fnd_file.OUTPUT, 'AÑO : ,'        || P_YEAR);
    
               
    var_data := 'PERIODO,'                              ||
                'NOMINA,'                               ||
                'ID EMPLEADO,'                          ||
                'NOMBRE COMPLETO,'                      ||
                'APELLIDO PATERNO,'                     ||
                'APELLIDO MATERNO,'                     ||
                'NOMBRES,'                              ||
                'CALLE,'                                ||
                'NUM EXT,'                              ||
                'NUM INT,'                              ||
                'COLONIA,'                              ||
                'DELEGACION O MUNICIPIO,'               ||
                'LOCALIDAD O POBLACION,'                ||
                'ESTADO,'                               ||
                'PAIS,'                                 ||
                'CODIGO POSTAL,'                        ||
                'TELEFONO,'                             ||
                'SEXO,'                                 ||
                'NACIONALIDAD,'                         ||
                'LUGAR DE NACIMIENTO,'                  ||
                'FECHA DE NACIMIENTO,'                  ||
                'NIVEL DE ESTUDIOS,'                    ||
                'TIPO DE CONTRATO,'                     ||
                'FECHA DE TERMINACION DE CONTRATO,'     ||
                'NUM DE GERENCIA,'                      ||
                'GERENCIA,'                             ||
                'NUM DEPARTAMENTO,'                     ||
                'DEPARTAMENTO,'                         ||
                'PUESTO,'                               ||
                'TRABAJO,'                              ||
                'TURNO,'                                ||
                'SIND.,'                                ||
                'RFC,'                                  ||
                'CURP,'                                 ||
                'NSS,'                                  ||
                'DELEGACION IMSS,'                      ||
                'SUBDELEGACION IMSS,'                   ||
                'UNIDAD MED FAM,'                       ||
                'REG PATRONAL,'                         ||
                'FECHA ALTA CIA,'                       ||
                'SUELDO BASE,'                          ||
                'S D INTEGRADO,'                        ||
                'UNIC. INGR.,'                          ||
                'BONO DESPENSA,'                        ||
                'FORMA PAGO DESPENSA,'                  ||
                'CTA BONO DESPENSA,'                    ||                      
                'NUM TARJETA DESPENSA,'                 ||
                'TIPO PAGO SDO,'                        ||
                'BANCO DEPOSITO,'                       ||
                'CUENTA BANCARIA,'                      ||
                'TARJETA BANCARIA,'                     ||
                'AFORE,'                                ||
                'CREDITO INFONAVIT,'                    ||
                'FECHA CREDITO,'                        ||
                'TIPO DESCUENTO,'                       ||
                'VALOR DESCUENTO,'                      ||
                '% PENSION ALIMENTICIA,'                ||
                'IMPORTE PENSION ALIMENTICIA,'          ||
                'CORREO ELECTRONICO,'                   ||
                'ESTADO CIVIL,'                         ||
                'REGIMEN MATRIMONIAL,'                  ||
                'ESTATUS,'                              ||
                'FECHA BAJA,'                           ||
                'AREA';
    
    fnd_file.PUT_LINE(fnd_file.OUTPUT, var_data);
                      
                                            
    BEGIN
    
        OPEN DETAIL_LIST;
        
        LOOP
        
            FETCH DETAIL_LIST 
                  BULK COLLECT INTO detail LIMIT 500;
            
            EXIT WHEN detail.COUNT = 0;
                  
            FOR rowIndex IN 1 .. detail.COUNT LOOP
                        
            
                var_data := '';
                var_data := detail(rowIndex).PERIOD_TYPE                    || ',' ||
                            detail(rowIndex).PAYROLL_NAME                   || ',' ||
                            detail(rowIndex).EMPLOYEE_NUMBER                || ',' ||
                            detail(rowIndex).EMPLOYEE_FULL_NAME             || ',' ||
                            detail(rowIndex).LAST_NAME                      || ',' ||
                            detail(rowIndex).SECOND_LAST_NAME               || ',' ||
                            detail(rowIndex).NAMES                          || ',' ||
                            detail(rowIndex).STREET                         || ',' ||
                            detail(rowIndex).EXTERNAL_NUMBER                || ',' ||
                            detail(rowIndex).INTERNAL_NUMBER                || ',' ||
                            detail(rowIndex).NEIGHBORHOOD                   || ',' ||
                            detail(rowIndex).MUNICIPALITY                   || ',' ||
                            detail(rowIndex).CITY                           || ',' ||
                            detail(rowIndex).STATE                          || ',' ||
                            detail(rowIndex).COUNTRY                        || ',' ||
                            detail(rowIndex).POSTAL_CODE                    || ',' ||
                            detail(rowIndex).TELEPHONE                      || ',' ||
                            detail(rowIndex).SEX                            || ',' ||
                            detail(rowIndex).NATIONALITY                    || ',' ||
                            detail(rowIndex).TOWN_OF_BIRTH                  || ',' ||
                            detail(rowIndex).DATE_OF_BIRTH                  || ',' ||
                            detail(rowIndex).LEVEL_OF_EDUCATION             || ',' ||
                            detail(rowIndex).ASSIGNMENT_CATEGORY            || ',' ||
                            detail(rowIndex).CONTRACT_TERMINATION_DATE      || ',' ||
                            detail(rowIndex).MANAGEMENT_NUM                 || ',' ||
                            detail(rowIndex).MANAGEMENT_DESC                || ',' ||
                            detail(rowIndex).DEPARTMENT_NUMBER              || ',' ||
                            detail(rowIndex).DEPARTMENT_NAME                || ',' ||
                            detail(rowIndex).POSITION_NAME                  || ',' ||
                            detail(rowIndex).JOB_NAME                       || ',' ||
                            detail(rowIndex).TIME_TURN                      || ',' ||
                            detail(rowIndex).EMPLOY_CATEGORY                || ',' ||
                            detail(rowIndex).RFC                            || ',' ||
                            detail(rowIndex).CURP                           || ',' ||
                            detail(rowIndex).NSS                            || ',' ||
                            detail(rowIndex).DELEGATION_IMSS                || ',' ||
                            detail(rowIndex).SUBDELEGATION_IMSS             || ',' ||
                            detail(rowIndex).SOCIAL_SECURITY_MEDICAL_CENTER || ',' ||
                            detail(rowIndex).EMPLOYER_REGISTRATION          || ',' ||
                            detail(rowIndex).EFFECTIVE_START_DATE           || ',' ||
                            detail(rowIndex).BASIC_SALARY                   || ',' ||
                            detail(rowIndex).IDW                            || ',' ||
                            detail(rowIndex).SINGLE_EMPLOYEE                || ',' ||
                            detail(rowIndex).BONO_DESP                      || ',' ||
                            detail(rowIndex).PAYMENT_TYPE_DESP              || ',' ||
                            detail(rowIndex).ACCOUNT_DESP                   || ',' ||
                            detail(rowIndex).CARD_DESP                      || ',' ||
                            detail(rowIndex).PAYMENT_TYPE_SDO               || ',' ||
                            detail(rowIndex).BANK                           || ',' ||
                            detail(rowIndex).ACCOUNT_SDO                    || ',' ||
                            detail(rowIndex).CARD_SDO                       || ',' ||
                            detail(rowIndex).AFORE                          || ',' ||
                            detail(rowIndex).INFONAVIT_CREDIT_NUMBER        || ',' ||
                            detail(rowIndex).INFONAVIT_START_DATE           || ',' ||
                            detail(rowIndex).INFONAVIT_DISCOUNT_TYPE        || ',' ||
                            detail(rowIndex).INFONAVIT_DISCOUNT_VALUE       || ',' ||
                            detail(rowIndex).PENSION_PORCENTAJE             || ',' ||
                            detail(rowIndex).PENSION_AMOUNT                 || ',' ||
                            detail(rowIndex).EMAIL_ADDRESS                  || ',' ||
                            detail(rowIndex).MARITAL_STATUS                 || ',' ||
                            detail(rowIndex).REGIMEN_MATRIMONIAL            || ',' ||
                            detail(rowIndex).PERSON_TYPE                    || ',' ||
                            detail(rowIndex).EFFECTIVE_END_DATE             || ',' ||
                            detail(rowIndex).AREA;
                            
                                        
                fnd_file.PUT_LINE(fnd_file.OUTPUT, var_data);                                            
                                 
            END LOOP;        
        
        END LOOP;
        
        CLOSE DETAIL_LIST;

    EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('**Error al Generar los registros de detalle del documento. ' || SQLERRM);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Generar los registros de detalle del documento. ' || SQLERRM);
    END;
    
EXCEPTION WHEN OTHERS THEN
    dbms_output.put_line('**Error al Ejecutar el Procedure Cuadro Basico. ' || SQLERRM);
    FND_FILE.PUT_LINE(FND_FILE.LOG, '**Error al Ejecutar el Procedure Cuadro Basico. ' || SQLERRM);
END PAC_CAT_EMPLEADOS_PRC;
/