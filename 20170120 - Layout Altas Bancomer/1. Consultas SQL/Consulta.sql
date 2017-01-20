SELECT PPF.FIRST_NAME || '' || PPF.MIDDLE_NAMES     AS  EMPLOYEE_NAME,
       PPF.LAST_NAME                                AS  EMPLOYEE_LAST_NAME,
       PPF.PER_INFORMATION1                         AS  EMPLOYEE_SECOND_LAST_NAME    
  FROM PER_PEOPLE_F             PPF
 WHERE 1 = 1;