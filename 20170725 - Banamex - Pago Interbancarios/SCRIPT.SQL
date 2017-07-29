     
SELECT UNIQUE aps.vendor_name vendor_name,
             aps.segment1 vendor_num,
             aia.invoice_num,
             SUBSTRB (aia.description, 1, 50),
             apsa.amount_remaining - NVL (apsa.discount_amount_available, 0)
                amount_remaining,
             ieba.BANK_ACCOUNT_NUM,
             ieb.BANK_NAME,
             ieb.BANK_NAME_ALT,
             pac_eft_pkg.extract_account_number (ieba.BANK_ACCOUNT_NUM),
             aia.invoice_currency_code currency
--        INTO l_vendor_name,
--             l_vendor_num,
--             l_invoice_num,
--             l_invoice_description,
--             l_operation_amount,
--             l_supplier_clabe_number,
--             l_supplier_account_number,
--             l_operation_currency
        FROM AP_PAYMENT_SCHEDULES_ALL apsa,
             ap_invoices_all aia,
             apps.ap_suppliers aps,
             ap.ap_supplier_sites_all apss,
             apps.iby_ext_bank_accounts ieba,
             apps.iby_account_owners iao,
             apps.iby_ext_banks_v ieb,
             iby_pmt_instr_uses_all uses,
             apps.iby_ext_bank_branches_v iebb
       WHERE     1 = 1
             AND aia.VENDOR_ID = aps.VENDOR_ID
             AND apsa.invoice_id = aia.invoice_id
             AND aia.invoice_id = :p_invoice_id
             AND aps.vendor_id = apss.vendor_id
             AND iao.account_owner_party_id = aps.party_id
             AND ieba.ext_bank_account_id = iao.ext_bank_account_id
             AND ieb.bank_party_id = iebb.bank_party_id
             AND ieba.branch_id = iebb.branch_party_id
             AND ieba.bank_id = ieb.bank_party_id
             AND uses.instrument_id = ieba.ext_bank_account_id
             AND uses.end_date IS NULL
             ;      
     



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