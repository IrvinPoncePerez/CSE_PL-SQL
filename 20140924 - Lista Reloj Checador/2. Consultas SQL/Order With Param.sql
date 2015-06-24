select 
    PPF.EMPLOYEE_NUMBER,
    PPF.FULL_NAME
from PER_PEOPLE_F   PPF

order by case :field1

         when '1' then Row_Number() over(order by EMPLOYEE_NUMBER)

         when '2' then Row_Number() over(order by FULL_NAME)

         end;