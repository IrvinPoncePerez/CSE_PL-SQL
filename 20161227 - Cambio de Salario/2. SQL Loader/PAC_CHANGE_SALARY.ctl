LOAD DATA
BADFILE '/PAC_CHANGE_SALARY.BAD'
DISCARDFILE '/PAC_CHANGE_SALARY.DSC'
REPLACE
INTO TABLE APPS.PAC_CHANGE_SALARY_TB
Fields terminated by "," Optionally enclosed by '"'
(
  EMPLOYEE_NUMBER,
  PROPOSED_SALARY,
  CHANGE_DATE
)