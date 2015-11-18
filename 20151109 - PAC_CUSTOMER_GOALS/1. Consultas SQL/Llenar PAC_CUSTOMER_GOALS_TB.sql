DECLARE

    CURSOR DETAILS IS
        SELECT *
        FROM PAC_CUSTOMER_GOALS_TB;
        
        
    var_id  NUMBER;
    

BEGIN

    FOR detail IN DETAILS LOOP
    
        SELECT PAC_CUSTOMER_GOALS_SEQ.NEXTVAL
          INTO var_id
          FROM dual;
          
          
        UPDATE PAC_CUSTOMER_GOALS_TB
           SET CUSTOMER_GOAL_ID = var_id,
               ATTRIBUTE0 = 'Y'
         WHERE YEAR = detail.YEAR
           AND MONTH = detail.MONTH
           AND COUNTRY = detail.COUNTRY
           AND STATE = detail.STATE
           AND CITY = detail.CITY
           AND CLIENT_NUMBER = detail.CLIENT_NUMBER
           AND CLIENT_NAME = detail.CLIENT_NAME
           AND TARGET_BOXES = detail.TARGET_BOXES;
           
    
    END LOOP;
    
    COMMIT;

END;