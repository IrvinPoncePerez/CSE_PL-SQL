select :p_decimal,
       TRIM(LPAD(TRUNC(:P_DECIMAL), 12, 0)),
       RPAD(SUBSTR(TO_CHAR(TRUNC(:P_DECIMAL,2), '999999999999.99'), INSTR(TO_CHAR(TRUNC(:P_DECIMAL, 2), '999999999999.99'), '.')+1), 2,0)     
from dual;   
     
     
     
     
      SELECT UNIQUE *
        FROM AP_PAYMENT_SCHEDULES_ALL apsa,
             ap_invoices_all aia,
             apps.ap_suppliers aps,
             ap.ap_supplier_sites_all apss,
             apps.iby_ext_bank_accounts ieba,
             apps.iby_account_owners iao,
             apps.iby_ext_banks_v ieb,
             apps.iby_ext_bank_branches_v iebb
       WHERE     1 = 1
             AND aia.VENDOR_ID = aps.VENDOR_ID
             AND apsa.invoice_id = aia.invoice_id
             AND aps.vendor_id = apss.vendor_id
             AND iao.account_owner_party_id = aps.party_id
             AND ieba.ext_bank_account_id = iao.ext_bank_account_id
             AND ieb.bank_party_id = iebb.bank_party_id
             AND ieba.branch_id = iebb.branch_party_id
             AND ieba.bank_id = ieb.bank_party_id
             and IEb.bank_name_alt = 'BANAMEX';
     



 SELECT tsc_supplier_name,
                  supplier_account_number,
                  paying_account_number,
                  supplier_clabe_account,
                  operation_currency,
                  SUM (operation_amount) operation_amount,
                  invoice_id
             FROM PAC_EFT_BATCH_LINES
            WHERE batch_id = :p_batch_id
         GROUP BY tsc_supplier_name,
                  supplier_account_number,
                  paying_account_number,
                  supplier_clabe_account,
                  operation_currency,
                  invoice_id;
                  
                  
                  
SELECT :P_DESC,
       REGEXP_SUBSTR(:P_DESC, '\(?([0-9A-Za-z]+)\)?')
 FROM DUAL;                  
 
 
 