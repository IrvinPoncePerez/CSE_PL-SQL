CREATE OR REPLACE PROCEDURE APPS.PAC_PAY_CURRENCY_DISTRIBUTION(
   var_employee_id      IN  NUMBER,      
   var_employee_number  IN  NUMBER,
   var_employee_salary  IN  NUMBER)
AS
BEGIN

    DECLARE 
       var_500      NUMBER;
       var_200      NUMBER;
       var_100      NUMBER;
       var_50       NUMBER;
       var_20       NUMBER;
       var_10       NUMBER;
       var_5        NUMBER;
       var_2        NUMBER;
       var_1        NUMBER;
       var_50c      NUMBER;
       var_rest     NUMBER(12, 2) := PAC_ROUND_SALARY_PRC(var_employee_salary); 
    BEGIN
        
        --Quinientos pesos.
        IF (TRUNC(var_rest / 500) > 0) THEN
           var_500 := TRUNC(var_rest / 500);
           var_rest := var_rest - (var_500 * 500);
        ELSE
           var_500 := 0;
        END IF;

        --Doscientos pesos.
        IF (TRUNC(var_rest / 200) > 0) THEN
            var_200 := TRUNC(var_rest / 200);
            var_rest := var_rest - (var_200 * 200);
        ELSE
            var_200 := 0;
        END IF;
        
        --Cien pesos.
        IF (TRUNC(var_rest / 100) > 0) THEN
            var_100 := TRUNC(var_rest / 100);
            var_rest := var_rest - (var_100 * 100);
        ELSE
            var_100 := 0;
        END IF;
        
        --Cincuenta pesos.
        IF (TRUNC(var_rest / 50) > 0) THEN
            var_50 := TRUNC(var_rest / 50);
            var_rest := var_rest - (var_50 * 50);
        ELSE
            var_50 := 0;
        END IF;
        
        --Veinte pesos.
        IF (TRUNC(var_rest / 20) > 0) THEN
            var_20 := TRUNC(var_rest / 20);
            var_rest := var_rest - (var_20 * 20);
        ELSE
            var_20 := 0;
        END IF;
        
        --Diez pesos.
        IF (TRUNC(var_rest / 10) > 0) THEN
            var_10 := TRUNC(var_rest / 10);
            var_rest := var_rest -(var_10 * 10);
        ELSE
            var_10 := 0;
        END IF;
        
        --Cinco pesos.
        IF (TRUNC(var_rest / 5) > 0) THEN
            var_5 := TRUNC(var_rest / 5);
            var_rest := var_rest - (var_5 * 5);
        ELSE
            var_5 := 0;
        END IF;
        
        --Dos pesos.
        IF (TRUNC(var_rest / 2) > 0) THEN
            var_2 := TRUNC(var_rest / 2);
            var_rest := var_rest - (var_2 * 2);
        ELSE
            var_2 := 0;
        END IF;
        
        --Un peso.
        IF (TRUNC(var_rest) > 0) THEN
            var_1 := TRUNC(var_rest);
            var_rest := var_rest - (var_1);
        ELSE
            var_1 := 0;
        END IF;
        
        --Cincuenta centavos.
        IF (TRUNC(var_rest / .50) > 0) THEN
            var_50c := TRUNC(var_rest / .50);
            var_rest := var_rest - (var_50c * .50);
        ELSE
            var_50c := 0;
        END IF;
        
        INSERT INTO PAC_CURRENCY_DISTRIBUTION_TB(EMPLOYEE_ID,
                                                 EMPLOYEE_NUMBER,
                                                 EMPLOYEE_SALARY,
                                                 EMPLOYEE_ROUNDSALARY,
                                                 CURRENCY_500,
                                                 CURRENCY_200,
                                                 CURRENCY_100,
                                                 CURRENCY_50,
                                                 CURRENCY_20,
                                                 CURRENCY_10,
                                                 CURRENCY_5,
                                                 CURRENCY_2,
                                                 CURRENCY_1,
                                                 CURRENCY_50c)
                                         VALUES (var_employee_id,
                                                 var_employee_number,
                                                 var_employee_salary,
                                                 PAC_ROUND_SALARY_PRC(var_employee_salary),
                                                 var_500,
                                                 var_200,
                                                 var_100,
                                                 var_50,
                                                 var_20,
                                                 var_10,
                                                 var_5,
                                                 var_2,
                                                 var_1,
                                                 var_50c);
        
        COMMIT;
    END;


END;