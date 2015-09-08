/*  Codigo JRCA (STO)
    Modify by : Irvin Ponce Pérez
    Modify date : 07 Jul 2014 03:30pm
    Modify by : CToral
    Modify date : 09 Enero 2014 03:30pm
    Modify by : IPONCE
    Modify date: 07 Septiembre 04:10pm 
    */
SELECT 
      ac.org_id,
      ac.check_id,
      ac.check_number,
     '/var/tmp/CARGAS/calvario.jpg' IMAGEN,
      ac.check_date,
      ac.vendor_id,
      DECODE(XXCALV_UTILS_PKG.xxcalv_pasta_txt(PAC_GET_FULL_VENDOR_NAME(ac.VENDOR_ID))
             ,'FINIQUITO'
             ,DECODE(AIA.ATTRIBUTE1
                     ,NULL
                     ,'NO PUSO NOMBRE EMPLEADO'
                     ,AIA.ATTRIBUTE1)
             ,DECODE(AIA.ATTRIBUTE2
                     ,NULL
                     ,PAC_GET_FULL_VENDOR_NAME(ac.VENDOR_ID)
                     ,XXCALV_NOMBRE_PROV (AIA.ATTRIBUTE2))) Proveedor,
      DECODE(cba.currency_code
             ,'MXN'
             ,NVL(ac.base_amount,ac.amount)
             ,ac.amount)            amount,
      APPS.XXCALV_UTILS_PKG.XXCALV_GET_DESCRIPCION_FACTURA(ac.check_id) description,
      cba.currency_code moneda,
      cba.BANK_ACCOUNT_NUM BANK_ACCOUNT_NUM,
      USR.USER_NAME,
      DECODE(:P_LEYENDA
             ,'NO'
             ,DECODE(NVL(XXCALV_OBTIENE_LEYENDA_FNC(PAC_GET_FULL_VENDOR_NAME(ac.VENDOR_ID)),'NO')
                     ,'NO'
                     ,''
                     ,'PARA ABONO EN CUENTA') 
             ,'SI'
             ,'PARA ABONO EN CUENTA')Nota  
      ,'Referencia Cta. Bancaria --> ' || REGEXP_SUBSTR(cba.BANK_ACCOUNT_NUM,'[[:digit:]]+') Referencia
 FROM ap.ap_checks_all              ac
      , ap.ap_suppliers             ap
      , ap.ap_invoice_payments_all  aip
      , ce_bank_accounts            cba
      , ap.ap_invoices_all          aia
      , applsys.fnd_user            usr
 WHERE 1=1
    AND ac.vendor_id = ap.vendor_id
    AND ac.STATUS_LOOKUP_CODE != 'VOIDED'
    AND ac.BANK_ACCOUNT_NAME = cba.BANK_ACCOUNT_NAME
    AND cba.BANK_ACCOUNT_NAME = NVL(:P_ACCOUNT_NAME, cba.BANK_ACCOUNT_NAME)
    AND aia.invoice_id = aip.invoice_id
    AND ac.check_id = aip.check_id
    AND AC.CREATED_BY = usr.user_id
    AND UPPER(ac.BANK_ACCOUNT_NAME) LIKE '%BANCOMER%'                     
    AND ac.check_number >= :P_CHECK_NUMBER
    AND ac.check_number <= :P_CHECK_NUMBER2
     AND ac.org_id   = :p_org_id              
    AND ac.payment_method_code    = 'CHECK'
GROUP BY ac.check_id,
         ac.check_number,
         ac.check_date,
         ac.vendor_id,
          ac.org_id,
         AIA.ATTRIBUTE1,
         AIA.ATTRIBUTE2,
         ac.amount,      
         ac.base_amount,
         APPS.XXCALV_UTILS_PKG.XXCALV_GET_DESCRIPCION_FACTURA(ac.check_id),
         cba.BANK_ACCOUNT_NUM,
         cba.currency_code,
         USR.USER_NAME   
ORDER BY check_number