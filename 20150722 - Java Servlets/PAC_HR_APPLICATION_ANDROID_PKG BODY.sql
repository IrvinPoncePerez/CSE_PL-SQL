CREATE OR REPLACE PACKAGE BODY PAC_HR_APPLICATION_ANDROID_PKG
IS

    FUNCTION GET_EMPLOYEE_NAME(P_EMPLOYEE_NUMBER  NUMBER)
             RETURN VARCHAR2
    IS
        var_employee_name   VARCHAR2(100) := '';
    BEGIN
    
        SELECT DISTINCT
               PAPF.FULL_NAME
          INTO var_employee_name
          FROM PER_ALL_PEOPLE_F PAPF
         WHERE 1 = 1
           AND PAPF.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
           AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE;
    
        RETURN var_employee_name;
    END;
             
    FUNCTION GET_DEPARTMENT(P_EMPLOYEE_NUMBER  NUMBER)
             RETURN VARCHAR2
    IS
        var_department  VARCHAR2(1000) := '';    
    BEGIN
    
        SELECT HOU.NAME
          INTO var_department
          FROM APPS.PER_PEOPLE_F             PPF,    
               APPS.PER_ALL_ASSIGNMENTS_F    PAAF,
               HR.HR_ALL_ORGANIZATION_UNITS    HOU
         WHERE 1 = 1
           AND PPF.PERSON_ID = PAAF.PERSON_ID
           AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
           AND PAAF.ORGANIZATION_ID = HOU.ORGANIZATION_ID
           AND PPF.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
           AND ROWNUM = 1;
--        var_department := P_EMPLOYEE_NUMBER;
           
        RETURN var_department;
    EXCEPTION WHEN OTHERS THEN
        RETURN SQLERRM;
    END;
             
    FUNCTION GET_JOB(P_EMPLOYEE_NUMBER  NUMBER)
             RETURN VARCHAR2
    IS
        var_job  VARCHAR2(1000) := '';
    BEGIN
   
        SELECT HAPD.NAME
          INTO var_job
          FROM APPS.PER_ALL_PEOPLE_F             PAPF,
               APPS.PER_ALL_ASSIGNMENTS_F        PAAF, 
               APPS.HR_ALL_POSITIONS_F          HAPD       
         WHERE 1 = 1
           AND PAPF.PERSON_ID = PAAF.PERSON_ID
           AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
           AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
           AND PAPF.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
           AND HAPD.POSITION_ID = PAAF.POSITION_ID
           AND ROWNUM = 1;
--        var_job := P_EMPLOYEE_NUMBER;

        RETURN var_job;
    EXCEPTION WHEN OTHERS THEN
        RETURN SQLERRM;
    END;
             
    FUNCTION GET_PICTURE(P_EMPLOYEE_NUMBER  NUMBER)
             RETURN BLOB
    IS
        l_exists    NUMBER(1);
        var_image   BLOB;
    BEGIN
    
    
        SELECT CASE WHEN EXISTS(
                                SELECT PPIT.EMPLOYEE_PICTURE
                                  FROM PAC_PER_IMAGES_TB    PPIT
                                 WHERE 1 = 1
                                   AND PPIT.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
                               )
                    THEN 1
                    ELSE 0
               END
          INTO l_exists
          FROM DUAL;
    
    
    
        IF (l_exists = 1) THEN
            
            SELECT PPIT.EMPLOYEE_PICTURE
              INTO var_image
              FROM PAC_PER_IMAGES_TB PPIT
             WHERE 1 = 1
               AND PPIT.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER;
        
        ELSE
        
            SELECT PI.IMAGE
              INTO var_image
              FROM PER_PEOPLE_F     PPF,
                   PER_IMAGES       PI
             WHERE 1 = 1
               AND PPF.PERSON_ID = PI.PARENT_ID
               AND PI.TABLE_NAME = 'PER_PEOPLE_F'
               AND PPF.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER
               AND ROWNUM = 1;
        
        END IF;
              
        RETURN var_image;  
    END;
    
    FUNCTION SET_PICTURE(P_EMPLOYEE_NUMBER  VARCHAR2)
             RETURN VARCHAR2
    IS 
    
        var_result      VARCHAR2(1000) := 'false';
        var_person_id   NUMBER;     
        
        l_dir       VARCHAR2(10) := 'IMAGES';
        l_file      VARCHAR2(20) := P_EMPLOYEE_NUMBER || '.jpg';
        l_len       NUMBER;
        l_blob      BLOB;
        l_bfile     BFILE;
        
    BEGIN
    
        BEGIN
        
            SELECT DISTINCT
                   PPF.PERSON_ID
              INTO var_person_id
              FROM PER_PEOPLE_F     PPF
             WHERE 1 = 1
               AND PPF.EMPLOYEE_NUMBER = P_EMPLOYEE_NUMBER;
        
        EXCEPTION WHEN OTHERS THEN
            var_result := 'false';
        END;
            
        
        BEGIN
        
            EXECUTE IMMEDIATE ('DELETE FROM PAC_PER_IMAGES_TB WHERE EMPLOYEE_NUMBER = ' || P_EMPLOYEE_NUMBER);
        
            
--            INSERT INTO APPS.PER_IMAGES (IMAGE_ID,
--                                         PARENT_ID,
--                                         TABLE_NAME,
--                                         IMAGE)
--                 VALUES (PER_IMAGES_S.NEXTVAL,
--                         var_person_id,
--                         'PER_PEOPLE_F',
--                         EMPTY_BLOB())
--                 RETURN IMAGE INTO l_blob;
--                 
--                 
--            l_bfile := BFILENAME(l_dir, l_file);
--            DBMS_LOB.fileopen(l_bfile, DBMS_LOB.file_readonly);
--            DBMS_LOB.loadfromfile(l_blob, l_bfile, DBMS_LOB.getlength(l_bfile));
--            DBMS_LOB.fileclose(l_bfile);

            INSERT INTO PAC_PER_IMAGES_TB
                        (
                            PERSON_ID,
                            EMPLOYEE_NUMBER, 
                            EMPLOYEE_PICTURE
                        ) 
                 VALUES
                        (
                            var_person_id,
                            P_EMPLOYEE_NUMBER,
                            EMPTY_BLOB()
                        )
                 RETURN EMPLOYEE_PICTURE INTO l_blob;
            
            l_bfile := BFILENAME(l_dir, l_file);
            DBMS_LOB.fileopen(l_bfile, DBMS_LOB.file_readonly);
            DBMS_LOB.loadfromfile(l_blob, l_bfile, DBMS_LOB.getlength(l_bfile));
            DBMS_LOB.fileclose(l_bfile);
            
            COMMIT;
            
            var_result := 'true';
                               
        EXCEPTION WHEN OTHERS THEN
            var_result := 'false';
        END;
        
    
        RETURN var_result;
    END;

END PAC_HR_APPLICATION_ANDROID_PKG;