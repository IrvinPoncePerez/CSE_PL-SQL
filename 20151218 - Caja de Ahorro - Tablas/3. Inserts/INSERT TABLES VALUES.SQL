INSERT 
  INTO ATET_SB_TABLE_VALUES (TABLE_ID, 
                             LOWER_BOUND, 
                             UPPER_BOUND,
                             LOWER_VALUE,
                             UPPER_VALUE,
                             UNITS,
                             EFFECTIVE_START_DATE)
                     VALUES (1,
                             0.5,
                             0.9,
                             500,
                             500,
                             'MONEY',
                             SYSDATE);
 
INSERT 
  INTO ATET_SB_TABLE_VALUES (TABLE_ID, 
                             LOWER_BOUND, 
                             UPPER_BOUND,
                             LOWER_VALUE,
                             UPPER_VALUE,
                             UNITS,
                             EFFECTIVE_START_DATE)
                     VALUES (1,
                             1,
                             2.9,
                             20,
                             30,
                             'DAYS',
                             SYSDATE);
                             
INSERT 
  INTO ATET_SB_TABLE_VALUES (TABLE_ID, 
                             LOWER_BOUND, 
                             UPPER_BOUND,
                             LOWER_VALUE,
                             UPPER_VALUE,
                             UNITS,
                             EFFECTIVE_START_DATE)
                     VALUES (1,
                             3,
                             5.9,
                             31,
                             40,
                             'DAYS',
                             SYSDATE);
                             
INSERT 
  INTO ATET_SB_TABLE_VALUES (TABLE_ID, 
                             LOWER_BOUND, 
                             UPPER_BOUND,
                             LOWER_VALUE,
                             UPPER_VALUE,
                             UNITS,
                             EFFECTIVE_START_DATE)
                     VALUES (1,
                             6,
                             100,
                             41,
                             60,
                             'DAYS',
                             SYSDATE);

COMMIT;