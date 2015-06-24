DROP TABLE APPS.PAC_CURRENCY_DISTRIBUTION_TB CASCADE CONSTRAINTS;

CREATE TABLE APPS.PAC_CURRENCY_DISTRIBUTION_TB
(
  EMPLOYEE_ID            NUMBER                 NOT NULL,
  EMPLOYEE_NUMBER        NUMBER                 NOT NULL,
  EMPLOYEE_SALARY        NUMBER(6,2)            NOT NULL,
  EMPLOYEE_ROUNDSALARY   NUMBER(6,2)            NOT NULL,
  CURRENCY_500           NUMBER                 NOT NULL,
  CURRENCY_200           NUMBER                 NOT NULL,
  CURRENCY_100           NUMBER                 NOT NULL,
  CURRENCY_50            NUMBER                 NOT NULL,
  CURRENCY_20            NUMBER                 NOT NULL,
  CURRENCY_10            NUMBER                 NOT NULL,
  CURRENCY_5             NUMBER                 NOT NULL,
  CURRENCY_2             NUMBER                 NOT NULL,
  CURRENCY_1             NUMBER                 NOT NULL,
  CURRENCY_50C           NUMBER                 NOT NULL
);