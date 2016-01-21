DECLARE 
    var_result  VARCHAR2(50);
BEGIN

    var_result := ATET_SAVINGS_BANK_PKG.INSERT_LOAN_TRANSACTION(P_EXPORT_REQUEST_ID => 44536763,
                                          P_PAYROLL_RESULT_ID => 235,
                                          P_PERSON_ID => 1724,
                                          P_RUN_RESULT_ID => 11760419,
                                          P_EARNED_DATE => TO_DATE('2016/02/15', 'RRRR/MM/DD'),
                                          P_TIME_PERIOD_ID => 1647,
                                          P_PERIOD_NAME => '3 2016 Quincena',
                                          P_ELEMENT_NAME => 'D072_PRESTAMO CAJA DE AHORRO',
                                          P_ENTRY_NAME => 'Pay Value',
                                          P_ENTRY_UNITS => 'Dinero',
                                          P_ENTRY_VALUE => 883.33,
                                          P_DEBIT_AMOUNT => 0,
                                          P_CREDIT_AMOUNT => 883.33);
                                          
    dbms_output.put_line(var_result);
    

END;

SELECT *
FROM ATET_Sb_LOANS
WHERE MEMBER_ID = 1339;

SELECT *
FROM ATET_SB_MEMBERS_ACCOUNTS
WHERE MEMBER_ID = 1339;

SELECT *
FROM ATET_SB_PAYMENTS_SCHEDULE ASPS
WHERE ASPS.LOAN_ID = 96;

ROLLBACK;