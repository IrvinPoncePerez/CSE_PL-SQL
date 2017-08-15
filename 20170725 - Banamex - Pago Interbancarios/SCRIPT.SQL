SELECT PV.VENDOR_NAME,
       PV.ATTRIBUTE1,
       PV.ATTRIBUTE2,
       PV.ATTRIBUTE3,
       PV.NUM_1099,
       AIA.TOTAL_TAX_AMOUNT
  FROM AP_INVOICES_ALL      AIA,
       PO_VENDORS           PV,
       PAC_EFT_BATCH_LINES  PEBL
 WHERE 1 = 1
   AND AIA.INVOICE_ID = PEBL.INVOICE_ID
   AND AIA.VENDOR_ID = PV.VENDOR_ID;
   
   
SELECT *
  FROM PO_VENDORS
 WHERE 1 = 1
   AND VENDOR_ID = 1261;



SELECT tsc_supplier_name,
                  supplier_account_number,
                  paying_account_number,
                  length(supplier_clabe_account),
                  operation_currency,
                  SUM (operation_amount) operation_amount,
                  INVOICE_ID,                           --  IPONCE 2017.07.31
                  PAYMENT_DESCRIPTION                   --  IPONCE 2017.08.02           
             FROM PAC_EFT_BATCH_LINES
            WHERE batch_id = :p_batch_id
         GROUP BY tsc_supplier_name,
                  supplier_account_number,
                  paying_account_number,
                  supplier_clabe_account,
                  operation_currency,
                  INVOICE_ID,                           --  IPONCE 2017.07.31
                  PAYMENT_DESCRIPTION;
   
   