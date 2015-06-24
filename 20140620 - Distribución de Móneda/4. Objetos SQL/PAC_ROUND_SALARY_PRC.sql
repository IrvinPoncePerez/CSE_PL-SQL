CREATE OR REPLACE FUNCTION PAC_ROUND_SALARY_PRC(P_SALARY    NUMBER) RETURN NUMBER
IS
    var_salary          NUMBER(12, 2);
    var_centavos        VARCHAR2(10);
BEGIN
    
        dbms_output.put_line(P_SALARY);

    --Para el caso en dónde los netos a pagar existan decimales, se considerará lo siguiente:
    IF ( INSTR(P_SALARY, '.') > 0 ) THEN

        var_centavos    := SUBSTR(P_SALARY, INSTR(P_SALARY, '.'), LENGTH(P_SALARY));
        var_salary      := TO_NUMBER(REPLACE(P_SALARY, var_centavos));
    
        --Con decimales de 0.01 al 0.25 'Se quedará en CERO pesos
        IF (TO_NUMBER(var_centavos, '9.99') >= .01 AND TO_NUMBER(var_centavos, '9.99') <= .24) THEN
        
            var_salary := var_salary;
        
        --Con decimales de 0.26 al 0.75 'Se quedará en 0.50 Centavos
        ELSIF (TO_NUMBER(var_centavos, '9.99') >= .25 AND TO_NUMBER(var_centavos, '9.99') <= .74) THEN
        
            var_salary := var_salary + 0.50;
        
        --Con decimales de 0.76 al 0.99 'Se quedará en 1 peso
        ELSIF (TO_NUMBER(var_centavos, '9.99') >= .75 AND TO_NUMBER(var_centavos, '9.99') <= .99) THEN
        
            var_salary := var_salary + 1;
        
        END IF;

    ELSE
     
       var_salary := P_SALARY;
    
    END IF;
    
    IF var_salary IS NULL THEN
        var_salary := 0;
    END IF;
    
    RETURN var_salary;
END;