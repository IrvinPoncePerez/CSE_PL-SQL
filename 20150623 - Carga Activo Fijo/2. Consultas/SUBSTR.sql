SELECT :P_STR,
       INSTR(:P_STR, '.'),
       SUBSTR(:P_STR, 0, INSTR(:P_STR, '.') - 1)    SEGMENT1,
       SUBSTR(:P_STR, INSTR(:P_STR, '.') + 1)   SEGMENT2
FROM DUAL;