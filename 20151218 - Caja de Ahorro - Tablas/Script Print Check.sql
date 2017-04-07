ALTER SESSION SET CURRENT_SCHEMA=APPS;

BEGIN

    fnd_global.apps_initialize (user_id        => 3938,
                                resp_id        => 53698,
                                resp_appl_id   => 101);
                       
    mo_global.set_policy_context ('S', 1329);


    ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL();
    
    ATET_SAVINGS_BANK_PKG.PRINT_SAVING_RETIREMENT_CHECK(4079);

END;

