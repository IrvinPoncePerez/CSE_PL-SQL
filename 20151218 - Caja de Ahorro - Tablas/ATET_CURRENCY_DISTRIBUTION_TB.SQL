DROP TABLE APPS.ATET_CURRENCY_DISTRIBUTION_TB CASCADE CONSTRAINTS;

CREATE TABLE APPS.ATET_CURRENCY_DISTRIBUTION_TB
(
  MEMBER_ID              NUMBER                 NOT NULL,
  SAVING_TRANSACTION_ID  NUMBER                 NOT NULL,
  ACCOUNT_DESCRIPTION    VARCHAR2(500)          NOT NULL,
  SAVING_RETIREMENT      NUMBER                 NOT NULL,
  SAVING_RETIREMENT_ROUND NUMBER                NOT NULL,
  CURRENCY_500           NUMBER                 NOT NULL,
  CURRENCY_200           NUMBER                 NOT NULL,
  CURRENCY_100           NUMBER                 NOT NULL,
  CURRENCY_50            NUMBER                 NOT NULL,
  CURRENCY_20            NUMBER                 NOT NULL,
  CURRENCY_10            NUMBER                 NOT NULL,
  CURRENCY_5             NUMBER                 NOT NULL,
  CURRENCY_2             NUMBER                 NOT NULL,
  CURRENCY_1             NUMBER                 NOT NULL,
  CURRENCY_50C           NUMBER                 NOT NULL,
  SAVING_BANK_ID         NUMBER                 NOT NULL
);