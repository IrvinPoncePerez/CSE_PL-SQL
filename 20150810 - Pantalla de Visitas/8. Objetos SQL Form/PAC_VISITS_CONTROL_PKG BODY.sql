PACKAGE BODY PAC_VISITS_CONTROL_PKG IS
  
  PROCEDURE ON_WHEN_NEW_FORM_INSTANCE IS
    
    TIME_TIMER    TIMER;
    QUERY_TIMER   TIMER;
    
    BY_1_SEC    CONSTANT  NUMBER := 1000;
    BY_60_SEC   CONSTANT  NUMBER := 60000;
    
  BEGIN
    
    READ_IMAGE_FILE('$PER_TOP/forms/US/PAC_TIME_CLOCK.BMP','bmp','PAC_LOGO');
    
    TIME_TIMER := CREATE_TIMER('TIME_TIMER',   BY_1_SEC,  REPEAT);
    QUERY_TIMER := CREATE_TIMER('QUERY_TIMER', BY_60_SEC, REPEAT);
    
    :SYSTEM.MESSAGE_LEVEL := 25;
    
  END ON_WHEN_NEW_FORM_INSTANCE;
  
  
  PROCEDURE ON_WHEN_TIMER_EXPIRED IS
  
    TIME_TIMER    TIMER;
    QUERY_TIMER   TIMER;    
    
    var_date VARCHAR2(30) := TO_CHAR(SYSDATE + PAC_GET_TVALUE/1440,'dd/mm/yyyy'); 
    var_time VARCHAR2(30) := TO_CHAR(SYSDATE + PAC_GET_TVALUE/1440,'HH24:MI:SS'); 
  
  BEGIN
    
    TIME_TIMER := find_timer('TIME_TIMER');
    QUERY_TIMER := find_timer('QUERY_TIMER');
    
    IF NOT ID_NULL(TIME_TIMER) AND get_application_property(TIMER_NAME) = 'TIME_TIMER' THEN
      
      :CONTROL.TXT_DATE := var_date;
      :CONTROL.TXT_HOUR := SUBSTR(var_time, INSTR(var_time,' ') + 1);
    
    END IF;
    
    IF NOT ID_NULL(QUERY_TIMER) AND get_application_property(TIMER_NAME) = 'QUERY_TIMER' THEN
      
      GO_ITEM('PAC_VISITS_VIEW_TB.VISITOR_DAY_ID');
      EXECUTE_QUERY;
      
    END IF;
    
  END ON_WHEN_TIMER_EXPIRED;
  
  
  PROCEDURE CREATE_FOLIO IS
  BEGIN
    
    SELECT TO_CHAR(SYSDATE, 'YYMMDD') ||
           TRIM(TO_CHAR((COUNT(PVC.VISITOR_DAY_ID) + 1), '000'))
      INTO :PAC_VISITS_CONTROL_TB.VISITOR_DAY_ID
      FROM PAC_VISITS_CONTROL_TB PVC
     WHERE 1 = 1
       AND PVC.VISITOR_DAY_ID LIKE (TO_CHAR(SYSDATE, 'YYMMDD') ||'%');
    
  END CREATE_FOLIO;
  
  
  PROCEDURE ON_WHEN_RADIO_CHANGED IS
  BEGIN
    
    IF :PAC_VISITS_CONTROL_TB.IDENTIFICATION_TYPE = 'Otro' THEN
      
      app_item_property.set_property('PAC_VISITS_CONTROL_TB.OTHER_IDENTIFICATION_NAME', ENABLED, PROPERTY_ON);
      :PAC_VISITS_CONTROL_TB.OTHER_IDENTIFICATION_NAME := NULL;
      
    ELSE
      
      app_item_property.set_property('PAC_VISITS_CONTROL_TB.OTHER_IDENTIFICATION_NAME', ENABLED, PROPERTY_OFF);
      :PAC_VISITS_CONTROL_TB.OTHER_IDENTIFICATION_NAME := NULL;
      
    END IF;
    
  END ON_WHEN_RADIO_CHANGED;
  
  
  PROCEDURE ON_WHEN_NEW_RECORD_INSTANCE IS
  BEGIN
    
    app_item_property.set_property('PAC_VISITS_CONTROL_TB.OTHER_IDENTIFICATION_NAME', ENABLED, PROPERTY_OFF);
    
  END ON_WHEN_NEW_RECORD_INSTANCE;
  
  
  PROCEDURE ON_INSERT IS
  
    var_alert_number    NUMBER;
    var_time_stamp      VARCHAR2(50) := TO_CHAR(SYSDATE + PAC_GET_TVALUE/1440, 'dd/mm/yyyy hh12:mm:ss pm');
    var_date            VARCHAR2(30) := TO_CHAR(SYSDATE + PAC_GET_TVALUE/1440, 'dd/mm/yyyy'); 
    var_time            VARCHAR2(30) := TO_CHAR(SYSDATE + PAC_GET_TVALUE/1440, 'HH24:MI:SS');
    
  BEGIN
    
    IF VALIDATE_DATA() = TRUE THEN 
    
      CREATE_FOLIO;
    
      INSERT INTO PAC_VISITS_CONTROL_TB (
                                    VISITOR_DAY_ID,
                                    VISITOR_NAME,
                                    VISITOR_COMPANY,
                                    IDENTIFICATION_TYPE,
                                    OTHER_IDENTIFICATION_NAME,
                                    REASON_VISIT,
                                    ASSOCIATE_PERSON_ID,
                                    ASSOCIATE_DEPARTMENT_ID,
                                    REGISTRATION_TIME_STAMP,
                                    REGISTRATION_DATE,
                                    REGISTRATION_TIME,
                                    CHECK_IN,
                                    CHECK_OUT,
                                    VISITOR_LENGTH_STAY,
                                    ATTRIBUTE1,
                                    ATTRIBUTE2,
                                    ATTRIBUTE3,
                                    ATTRIBUTE4,
                                    ATTRIBUTE5,
                                    ATTRIBUTE6,
                                    ATTRIBUTE7,
                                    ATTRIBUTE8,
                                    ATTRIBUTE9,
                                    CREATED_BY,
                                    CREATION_DATE,
                                    LAST_UPDATED_BY,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATE_LOGIN
                                         )
                                 VALUES (
                                    :PAC_VISITS_CONTROL_TB.VISITOR_DAY_ID,
                                    :PAC_VISITS_CONTROL_TB.VISITOR_NAME,
                                    :PAC_VISITS_CONTROL_TB.VISITOR_COMPANY,
                                    :PAC_VISITS_CONTROL_TB.IDENTIFICATION_TYPE,
                                    :PAC_VISITS_CONTROL_TB.OTHER_IDENTIFICATION_NAME,
                                    :PAC_VISITS_CONTROL_TB.REASON_VISIT,
                                    :PAC_VISITS_CONTROL_TB.ASSOCIATE_PERSON_ID,
                                    :PAC_VISITS_CONTROL_TB.ASSOCIATE_DEPARTMENT_ID,
                                    var_time_stamp,
                                    var_date,
                                    var_time,
                                    :PAC_VISITS_CONTROL_TB.CHECK_IN,
                                    :PAC_VISITS_CONTROL_TB.CHECK_OUT,
                                    :PAC_VISITS_CONTROL_TB.VISITOR_LENGTH_STAY,
                                    :PAC_VISITS_CONTROL_TB.ATTRIBUTE1,
                                    :PAC_VISITS_CONTROL_TB.ATTRIBUTE2,
                                    'Y',
                                    :PAC_VISITS_CONTROL_TB.ATTRIBUTE4,
                                    :PAC_VISITS_CONTROL_TB.ATTRIBUTE5,
                                    :PAC_VISITS_CONTROL_TB.ATTRIBUTE6,
                                    :PAC_VISITS_CONTROL_TB.ATTRIBUTE7,
                                    :PAC_VISITS_CONTROL_TB.ATTRIBUTE8,
                                    :PAC_VISITS_CONTROL_TB.ATTRIBUTE9,
                                    FND_GLOBAL.USER_ID,
                                    SYSDATE,
                                    FND_GLOBAL.USER_ID,
                                    SYSDATE,
                                    FND_GLOBAL.USER_ID
                                         );  
      
    END IF;     
    
  END ON_INSERT;
             
           
  FUNCTION VALIDATE_DATA RETURN BOOLEAN IS
  BEGIN
    
    IF :PAC_VISITS_CONTROL_TB.VISITOR_NAME    IS NULL THEN RETURN FALSE; END IF;
    IF :PAC_VISITS_CONTROL_TB.VISITOR_COMPANY IS NULL THEN RETURN FALSE; END IF;
    
    RETURN TRUE;
    
  END VALIDATE_DATA;
  
  
  PROCEDURE ON_WHEN_TAB_PAGE_CHANGED IS
    TAB_PAGE  VARCHAR(100);
  BEGIN
    TAB_PAGE := GET_CANVAS_PROPERTY('PAC_VISITS_CONTROL', TOPMOST_TAB_PAGE);
    
    IF    TAB_PAGE = 'PAGE_VISITS_CONTROL' THEN
      
      GO_ITEM('PAC_VISITS_CONTROL_TB.VISITOR_NAME');
      
    ELSIF TAB_PAGE = 'PAGE_VISITS_VIEW' THEN  
      
      GO_ITEM('PAC_VISITS_VIEW_TB.VISITOR_DAY_ID');
      
    END IF;
  END ON_WHEN_TAB_PAGE_CHANGED;  
  
  
  PROCEDURE ON_WHEN_BUTTON_PRESSED IS
  BEGIN
    
    IF :PAC_VISITS_CONTROL_TB.ATTRIBUTE3 IS NULL THEN
      IF VALIDATE_DATA() = TRUE THEN
        COMMIT_FORM;
      END IF;
    END IF;
    
  END ON_WHEN_BUTTON_PRESSED;
  
  
END;