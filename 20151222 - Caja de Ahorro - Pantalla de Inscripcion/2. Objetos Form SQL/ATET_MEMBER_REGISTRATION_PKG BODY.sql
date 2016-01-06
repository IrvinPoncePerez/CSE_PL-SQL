PACKAGE BODY ATET_MEMBER_REGISTRATION_PKG IS

  
  PROCEDURE ENABLE_CONTROLS 
  IS
  BEGIN 
    
    app_item_property.set_property('CONTROL.MAX_SAV_AMT_SM', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('CONTROL.MAX_SAV_AMT_WK', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('CONTROL.MIN_SAV_AMT_SM', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('CONTROL.MIN_SAV_AMT_WK', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('CONTROL.MAX_PER_SAV', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('ATET_MEMBER_REGISTRATION.EMPLOYEE_FULL_NAME', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('ATET_MEMBER_REGISTRATION.PERSON_TYPE', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('ATET_MEMBER_REGISTRATION.SENIORITY_YEARS', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('ATET_MEMBER_REGISTRATION.RFC', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('ATET_MEMBER_REGISTRATION.CURP', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('ATET_MEMBER_REGISTRATION.SEX', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('ATET_MEMBER_REGISTRATION.EMAIL_ADDRESS', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('ATET_MEMBER_REGISTRATION.EFFECTIVE_HIRE_DATE', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('ATET_MEMBER_REGISTRATION.EFFECTIVE_TERMINATION_DATE', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('ATET_MEMBER_REGISTRATION.POSIBILITY_SAVING', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('ATET_MEMBER_REGISTRATION.MEMBER_START_DATE', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('ATET_MEMBER_REGISTRATION.MEMBER_END_DATE', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('ATET_MEMBER_REGISTRATION.IS_SAVER', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('ATET_MEMBER_REGISTRATION.IS_BORROWER', ENABLED, PROPERTY_OFF);
    app_item_property.set_property('ATET_MEMBER_REGISTRATION.IS_ENDORSEMENT', ENABLED, PROPERTY_OFF);
    
    app_item_property.set_property('CONTROL.MAX_SAV_AMT_SM', VISUAL_ATTRIBUTE, 'NO_BOLD');
    app_item_property.set_property('CONTROL.MAX_SAV_AMT_WK', VISUAL_ATTRIBUTE, 'NO_BOLD');
    app_item_property.set_property('CONTROL.MIN_SAV_AMT_SM', VISUAL_ATTRIBUTE, 'NO_BOLD');
    app_item_property.set_property('CONTROL.MIN_SAV_AMT_WK', VISUAL_ATTRIBUTE, 'NO_BOLD');
    
    go_item('ATET_MEMBER_REGISTRATION.EMPLOYEE_NUMBER');
    
  END ENABLE_CONTROLS;
  
  
  PROCEDURE LOAD_FORM
  IS
    var_saving_bank_id    NUMBER := ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID;
  BEGIN
    
    IF SYSDATE > ATET_SAVINGS_BANK_PKG.GET_REGISTRATION_DATE THEN
      app_item_property.set_property('ATET_MEMBER_REGISTRATION.AMOUNT_TO_SAVE', ENABLED, PROPERTY_OFF);
    END IF;
    
    :CONTROL.MAX_SAV_AMT_SM := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_SAV_AMT_SM');
    :CONTROL.MAX_SAV_AMT_WK := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_SAV_AMT_WK');
    :CONTROL.MIN_SAV_AMT_SM := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MIN_SAV_AMT_SM');
    :CONTROL.MIN_SAV_AMT_WK := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MIN_SAV_AMT_WK');
    :CONTROL.MAX_PER_SAV := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MAX_PER_SAV');
    
  END LOAD_FORM;
  
  
  PROCEDURE INSERT_MEMBER
  IS
    var_period_type                 VARCHAR2(100);
    
    var_assignment_id               NUMBER;
    var_payroll_id                  NUMBER;
    
    var_max_assignment_action_id    NUMBER;
    var_subtbr                      NUMBER;
    var_isrret                      NUMBER;
    var_mondet                      NUMBER;
    
    var_posibility_saving           NUMBER;
    var_max_sav_amt_sm              NUMBER;
    var_max_sav_amt_wk              NUMBER;
    var_max_per_sav                 NUMBER;
    
    var_member_termination_date     VARCHAR2(50);
  BEGIN
    
    :ATET_MEMBER_REGISTRATION.SAVING_BANK_ID := ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID;
    
    
    IF ATET_SAVINGS_BANK_PKG.IF_MEMBER_EXIST(:ATET_MEMBER_REGISTRATION.EMPLOYEE_NUMBER) = 0 THEN
      
      SELECT PPF.PERSON_ID                                                    AS  "PERSON_ID",
             PPF.EMPLOYEE_NUMBER                                              AS  "EMPLOYEE_NUMBER",
             PPF.FULL_NAME                                                    AS  "EMPLOYEE_NAME",
             UPPER(PPTT.USER_PERSON_TYPE)                                     AS  "PERSON_TYPE",
             TRUNC(HR_MX_UTILITY.GET_SENIORITY_SOCIAL_SECURITY(PPF.PERSON_ID, 
                                                               SYSDATE))      AS  "SENIORITY_YEARS",
             PPF.PER_INFORMATION2                                             AS  "RFC",
             PPF.NATIONAL_IDENTIFIER                                          AS  "CURP",
             UPPER(PAC_HR_PAY_PKG.GET_LOOKUP_MEANING('SEX', 
                                                     PPF.SEX))                AS  "SEX",
             PPF.EMAIL_ADDRESS                                                AS  "EMAIL_ADDRESS",
             PAC_RESULT_VALUES_PKG.GET_EFFECTIVE_START_DATE(PPF.PERSON_ID)    AS  "FFECTIVE_START_DATE",
             SYSDATE,
             'N'                                                              AS  "IS_SAVER",
             'N'                                                              AS  "IS_BORROWER",
             'N'                                                              AS  "IS_ENDORSEMENT"
        INTO :ATET_MEMBER_REGISTRATION.PERSON_ID,
             :ATET_MEMBER_REGISTRATION.EMPLOYEE_NUMBER,
             :ATET_MEMBER_REGISTRATION.EMPLOYEE_FULL_NAME,
             :ATET_MEMBER_REGISTRATION.PERSON_TYPE,
             :ATET_MEMBER_REGISTRATION.SENIORITY_YEARS,
             :ATET_MEMBER_REGISTRATION.RFC,
             :ATET_MEMBER_REGISTRATION.CURP,
             :ATET_MEMBER_REGISTRATION.SEX,
             :ATET_MEMBER_REGISTRATION.EMAIL_ADDRESS,
             :ATET_MEMBER_REGISTRATION.EFFECTIVE_HIRE_DATE,
             :ATET_MEMBER_REGISTRATION.MEMBER_START_DATE,
             :ATET_MEMBER_REGISTRATION.IS_SAVER,
             :ATET_MEMBER_REGISTRATION.IS_BORROWER,
             :ATET_MEMBER_REGISTRATION.IS_ENDORSEMENT
        FROM PER_PEOPLE_F             PPF,
             PER_PERSON_TYPES_TL      PPTT,
             PER_ASSIGNMENTS_F        PAF,
             PER_PERIODS_OF_SERVICE   PPOS
       WHERE 1 = 1
         AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
         AND PPF.PERSON_TYPE_ID = PPTT.PERSON_TYPE_ID
         AND LANGUAGE = USERENV('LANG')
         AND PPTT.USER_PERSON_TYPE IN ('Employee', 'Empleado')
         AND PPF.PERSON_ID = PAF.PERSON_ID
         AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
         AND PPOS.PERSON_ID = PPF.PERSON_ID
         AND PPOS.PERIOD_OF_SERVICE_ID = PAF.PERIOD_OF_SERVICE_ID
         AND PPF.EMPLOYEE_NUMBER = :ATET_MEMBER_REGISTRATION.EMPLOYEE_NUMBER
       ORDER BY TO_NUMBER(PPF.EMPLOYEE_NUMBER);
       
    ELSE
      MESSAGE('Este registro ya fue guardado. Realizar consulta.');
      RAISE FORM_TRIGGER_FAILURE;
    END IF;
    
    
    SELECT PAF.ASSIGNMENT_ID,
           PAF.PAYROLL_ID
      INTO var_assignment_id,
           var_payroll_id
      FROM PER_ASSIGNMENTS_F  PAF
     WHERE 1 = 1
       AND PAF.PERSON_ID = :ATET_MEMBER_REGISTRATION.PERSON_ID
       AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE;
  
    
    var_period_type := ATET_SAVINGS_BANK_PKG.GET_PERIOD_TYPE(:ATET_MEMBER_REGISTRATION.PERSON_ID);   
    var_max_assignment_action_id := ATET_SAVINGS_BANK_PKG.GET_MAX_ASSIGNMENT_ACTION_ID(var_assignment_id, var_payroll_id);
    var_subtbr := ATET_SAVINGS_BANK_PKG.GET_SUBTBR(var_max_assignment_action_id);
    var_isrret := ATET_SAVINGS_BANK_PKG.GET_ISRRET(var_max_assignment_action_id);
    var_mondet := ATET_SAVINGS_BANK_PKG.GET_MONDET(var_max_assignment_action_id);
     
    
    IF    var_period_type IN ('Semana', 'Week') THEN
      app_item_property.set_property('CONTROL.MAX_SAV_AMT_SM', VISUAL_ATTRIBUTE, 'NO_BOLD');
      app_item_property.set_property('CONTROL.MAX_SAV_AMT_WK', VISUAL_ATTRIBUTE, 'BOLD');
      app_item_property.set_property('CONTROL.MIN_SAV_AMT_SM', VISUAL_ATTRIBUTE, 'NO_BOLD');
      app_item_property.set_property('CONTROL.MIN_SAV_AMT_WK', VISUAL_ATTRIBUTE, 'BOLD');
    ELSIF var_period_type IN ('Quincena', 'Semi-Month') THEN                                 
      app_item_property.set_property('CONTROL.MAX_SAV_AMT_SM', VISUAL_ATTRIBUTE, 'BOLD');
      app_item_property.set_property('CONTROL.MAX_SAV_AMT_WK', VISUAL_ATTRIBUTE, 'NO_BOLD');
      app_item_property.set_property('CONTROL.MIN_SAV_AMT_SM', VISUAL_ATTRIBUTE, 'BOLD');
      app_item_property.set_property('CONTROL.MIN_SAV_AMT_WK', VISUAL_ATTRIBUTE, 'NO_BOLD');
    END IF;  
    
    
    var_max_per_sav := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(:ATET_MEMBER_REGISTRATION.SAVING_BANK_ID, 'MAX_PER_SAV');
    var_max_sav_amt_sm := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(:ATET_MEMBER_REGISTRATION.SAVING_BANK_ID, 'MAX_SAV_AMT_SM');
    var_max_sav_amt_wk := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(:ATET_MEMBER_REGISTRATION.SAVING_BANK_ID, 'MAX_SAV_AMT_WK');
    var_posibility_saving := (var_subtbr - (var_isrret + var_mondet)) * (var_max_per_sav / 100);
    
    IF    var_period_type IN ('Week', 'Semana') THEN
      IF var_posibility_saving > var_max_sav_amt_wk THEN
        :ATET_MEMBER_REGISTRATION.POSIBILITY_SAVING := TRUNC(var_max_sav_amt_wk);
      ELSE
        :ATET_MEMBER_REGISTRATION.POSIBILITY_SAVING := TRUNC(var_posibility_saving);
      END IF;
    ELSIF var_period_type IN ('Semi-Month', 'Quincena') THEN
      IF var_posibility_saving > var_max_sav_amt_sm THEN
        :ATET_MEMBER_REGISTRATION.POSIBILITY_SAVING := TRUNC(var_max_sav_amt_sm);
      ELSE
        :ATET_MEMBER_REGISTRATION.POSIBILITY_SAVING := TRUNC(var_posibility_saving);
      END IF;
    END IF;
    
    var_member_termination_date := ATET_SAVINGS_BANK_PKG.GET_MEMBER_TERMINATION_DATE(:ATET_MEMBER_REGISTRATION.PERSON_ID);
    IF var_member_termination_date <> 'NOTHING' THEN
      :ATET_MEMBER_REGISTRATION.MEMBER_END_DATE := var_member_termination_date;
    END IF;
    
    IF SYSDATE > ATET_SAVINGS_BANK_PKG.GET_REGISTRATION_DATE THEN
      app_item_property.set_property('ATET_MEMBER_REGISTRATION.AMOUNT_TO_SAVE', ENABLED, PROPERTY_OFF);
      :ATET_MEMBER_REGISTRATION.IS_SAVER := 'N';
    ELSE
      :ATET_MEMBER_REGISTRATION.IS_SAVER := 'Y';
    END IF;
    
  END INSERT_MEMBER;
  
  
  PROCEDURE INSERT_SAVING_AMOUNT
  IS
    var_saving_bank_id              NUMBER;
    var_period_type                 VARCHAR2(100);
  
    var_min_sav_amt_sm              NUMBER;
    var_min_sav_amt_wk              NUMBER;
  BEGIN
    
    var_saving_bank_id := ATET_SAVINGS_BANK_PKG.GET_SAVING_BANK_ID;
    var_min_sav_amt_sm := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MIN_SAV_AMT_SM');
    var_min_sav_amt_wk := ATET_SAVINGS_BANK_PKG.GET_PARAMETER_VALUE(var_saving_bank_id, 'MIN_SAV_AMT_WK');
    var_period_type := ATET_SAVINGS_BANK_PKG.GET_PERIOD_TYPE(:ATET_MEMBER_REGISTRATION.PERSON_ID); 
    
    
    IF    var_period_type IN ('Semana', 'Week') THEN
      IF    :ATET_MEMBER_REGISTRATION.AMOUNT_TO_SAVE < var_min_sav_amt_wk THEN
        :ATET_MEMBER_REGISTRATION.AMOUNT_TO_SAVE := var_min_sav_amt_wk;
      ELSIF :ATET_MEMBER_REGISTRATION.AMOUNT_TO_SAVE > :ATET_MEMBER_REGISTRATION.POSIBILITY_SAVING THEN
        :ATET_MEMBER_REGISTRATION.AMOUNT_TO_SAVE := :ATET_MEMBER_REGISTRATION.POSIBILITY_SAVING;
      ELSE
        :ATET_MEMBER_REGISTRATION.AMOUNT_TO_SAVE := TRUNC(:ATET_MEMBER_REGISTRATION.AMOUNT_TO_SAVE);
      END IF;
    ELSIF var_period_type IN ('Quincena', 'Semi-Month') THEN
      IF    :ATET_MEMBER_REGISTRATION.AMOUNT_TO_SAVE < var_min_sav_amt_sm THEN
        :ATET_MEMBER_REGISTRATION.AMOUNT_TO_SAVE := var_min_sav_amt_sm;
      ELSIF :ATET_MEMBER_REGISTRATION.AMOUNT_TO_SAVE > :ATET_MEMBER_REGISTRATION.POSIBILITY_SAVING THEN
        :ATET_MEMBER_REGISTRATION.AMOUNT_TO_SAVE := :ATET_MEMBER_REGISTRATION.POSIBILITY_SAVING;
      ELSE
        :ATET_MEMBER_REGISTRATION.AMOUNT_TO_SAVE := TRUNC(:ATET_MEMBER_REGISTRATION.AMOUNT_TO_SAVE);
      END IF; 
    END IF;
    
    
  END INSERT_SAVING_AMOUNT;
  
  
  Function COMPARAISON (val1 varchar2, val2 varchar2)
  Return number
  Is
     answer number := 0;
  Begin
     if val1 = val2 then
        answer := 1;
     end if;
     return(answer);
  End;
  
  
END;