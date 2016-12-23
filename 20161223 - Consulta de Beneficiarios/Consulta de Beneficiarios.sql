
SELECT *
  FROM per_contact_relationships
 WHERE (person_id = 1720);
 
select *
  from per_people_f
 where 1 = 1
   and person_id = 33972;
   
   
   




SELECT DISTINCT
       EMP.EMPLOYEE_NUMBER      "Numero de Empleado",
       EMP.FULL_NAME            "Nombre de Empleado",
       EMP.USER_PERSON_TYPE     "Tipo Persona",
       CON.FULL_NAME            "Nombre de Contacto",
       PPT.USER_PERSON_TYPE     "Tipo Contacto"
  FROM (SELECT EMP.PERSON_ID,
               EMP.EMPLOYEE_NUMBER,
               EMP.FULL_NAME,
               PPT.USER_PERSON_TYPE
          FROM PER_PEOPLE_F     EMP,
               PER_PERSON_TYPES PPT
         WHERE 1 = 1 
           AND SYSDATE BETWEEN EMP.EFFECTIVE_START_DATE AND EMP.EFFECTIVE_END_DATE
           AND EMP.PERSON_TYPE_ID = PPT.PERSON_TYPE_ID
           AND PPT.SYSTEM_PERSON_TYPE = 'EMP'
        ) EMP
  LEFT JOIN PER_CONTACT_RELATIONSHIPS   PCR
         ON PCR.PERSON_ID = EMP.PERSON_ID
  LEFT JOIN PER_PEOPLE_F                CON
         ON PCR.CONTACT_PERSON_ID = CON.PERSON_ID
  LEFT JOIN PER_PERSON_TYPES    PPT
         ON CON.PERSON_TYPE_ID = PPT.PERSON_TYPE_ID
        AND PPT.USER_PERSON_TYPE IN ('Contacto', 'Contact')
 WHERE 1 = 1 
 ORDER BY TO_NUMBER(EMP.EMPLOYEE_NUMBER)