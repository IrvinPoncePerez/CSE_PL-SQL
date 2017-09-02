alter session set current_schema=apps;



DECLARE

    add_layout_boolean  BOOLEAN;
    v_request_id        number;
    waiting             BOOLEAN;
    phase               varchar2(80 BYTE);
    status              varchar2(80 BYTE);
    dev_phase           varchar2(80 BYTE);
    dev_status          varchar2(80 BYTE);
    v_message           varchar2(4000 BYTE);
    
    CURSOR  LOANS
    IS
    SELECT LOAN_ID
      FROM ATET_SB_LOANS
     WHERE 1 = 1
       AND LOAN_ID BETWEEN :P_LOAN_ID_MIN 
                       AND :P_LOAN_ID_MAX;
    
BEGIN


    fnd_global.apps_initialize (user_id        => 3938,
                                resp_id        => 53698,
                                resp_appl_id   => 101);
                       
    mo_global.set_policy_context ('S', 1329);
    
    
    
    FOR LOAN IN LOANS LOOP

     add_layout_boolean := fnd_request.add_layout (template_appl_name   => 'PER',
                                                  template_code        => 'ATET_SB_PROMISSORY_NOTE',
                                                  template_language    => 'Spanish', --use language from template definition
                                                  template_territory   => 'Mexico', --use territory from template definition
                                                  output_format        => 'PDF' --use output format from template definition
                                                 );

    v_request_id := fnd_request.submit_request ('PER',                        -- application
                                                'ATET_SB_PROMISSORY_NOTE', -- program short name
                                                '',                           -- description
                                                '',                            -- start time
                                                FALSE,                        -- sub request
                                                TO_CHAR (LOAN.LOAN_ID),       -- argument1
                                                CHR (0)       -- represents end of arguments
                                               );
    COMMIT;
    waiting := fnd_concurrent.wait_for_request (v_request_id,1,0,
                                                phase,
                                                status,
                                                dev_phase,
                                                dev_status,
                                                v_message
                                               ); 

    END LOOP;

END;




BEGIN


     fnd_global.apps_initialize (user_id        => 3938,
                                resp_id        => 53698,
                                resp_appl_id   => 101);
                       
    mo_global.set_policy_context ('S', 1329);
    
    
    ATET_SB_BACK_OFFICE_PKG.TRANSFER_JOURNALS_TO_GL;


END;