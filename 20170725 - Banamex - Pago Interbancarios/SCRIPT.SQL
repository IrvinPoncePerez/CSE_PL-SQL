
 
 SELECT REGEXP_REPLACE(:P_DESC, '[^0-9]+', '')
FROM DUAL;
 
 
 select translate(:p_desc,'0*~!#$%^()_-+=&#124}]{{/?.,><','0') from dual