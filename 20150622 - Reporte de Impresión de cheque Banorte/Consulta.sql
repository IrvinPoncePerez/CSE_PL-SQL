/* Formatted on 22/06/2015 06:03:49 p.m. (QP5 v5.163.1008.3004) */
/*Codigo JRCA 13-dic-2010*/

  SELECT ac.check_id,
         ac.check_number,
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
                      ,XXCALV_NOMBRE_PROV (AIA.ATTRIBUTE2))) Proveedor, --Irvin Ponce Perez 03-JUL-2015
         --'/var/tmp/CARGAS/calvario.jpg' IMAGEN,
         DECODE (cba.currency_code,
                 'MXN', NVL (ac.base_amount, ac.amount),
                 ac.amount)
            amount,
         cba.currency_code moneda,
         APPS.XXCALV_UTILS_PKG.XXCALV_GET_DESCRIPCION_FACTURA (ac.check_id)
            description,
         cba.BANK_ACCOUNT_NUM BANK_ACCOUNT_NUM,
         USR.USER_NAME,
         DECODE (
            :P_LEYENDA,
            'NO', DECODE (
                     NVL (XXCALV_OBTIENE_LEYENDA_FNC (ac.vendor_name), 'NO'),
                     'NO', '',
                     'PARA ABONO EN LA CUENTA DEL BENEFICIARIO'),
            'SI', 'PARA ABONO EN LA CUENTA DEL BENEFICIARIO')
            Nota,
         'Referencia Cta. Bancaria --> '
         || REGEXP_SUBSTR (cba.BANK_ACCOUNT_NUM, '[[:digit:]]+')
            Referencia
    FROM ap.ap_checks_all ac,
         ap.ap_suppliers ap,
         ce_bank_accounts cba,
         ap.ap_invoice_payments_all aip,
         ap.ap_invoices_all aia,
         applsys.fnd_user usr
   WHERE     1 = 1
         AND ac.vendor_id = ap.vendor_id
         AND ac.BANK_ACCOUNT_NAME = cba.BANK_ACCOUNT_NAME
         AND ac.STATUS_LOOKUP_CODE != 'VOIDED'
         AND aia.invoice_id = aip.invoice_id
         AND ac.check_id = aip.check_id
         AND AC.CREATED_BY = usr.user_id
         AND UPPER (ac.BANK_ACCOUNT_NAME) LIKE '%BANORTE%'  --JRCA 13/DIC/2010
         AND ac.check_number >= :P_CHECK_NUMBER
         AND ac.check_number <= :P_CHECK_NUMBER2
         AND ac.org_id = :P_ORG_ID     --Irvin Ponce Pérez 23-JUN-2015
GROUP BY ac.check_id,
         ac.check_number,
         ac.check_date,
         ac.vendor_id,
         ac.vendor_name,
         AIA.ATTRIBUTE1,
         AIA.ATTRIBUTE2,
         ac.amount,
         ac.base_amount,
         APPS.XXCALV_UTILS_PKG.XXCALV_GET_DESCRIPCION_FACTURA (ac.check_id),
         cba.BANK_ACCOUNT_NUM,
         cba.currency_code,
         USR.USER_NAME                                      --JRCA 13/DIC/2010
ORDER BY check_number