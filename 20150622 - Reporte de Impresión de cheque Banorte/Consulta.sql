/*Codigo JRCA 13-dic-2010*/
select ac.check_id,
      ac.check_number,
      ac.check_date,
      ac.vendor_id,
            decode(XXCALV_UTILS_PKG.xxcalv_pasta_txt(UPPER(TRIM(ac.vendor_name)))
                                                                           ,'FINIQUITO',
                                                                                    DECODE(AIA.ATTRIBUTE1,
                                                                                           NULL,
                                                                                           'NO PUSO NOMBRE EMPLEADO',
                                                                                           AIA.ATTRIBUTE1)
                                                                           ,DECODE(AIA.ATTRIBUTE2,
                                                                                           NULL,
                                                                                           UPPER(TRIM(ac.vendor_name)),
                                                                                           XXCALV_NOMBRE_PROV (AIA.ATTRIBUTE2)
                                                                                           )                
                                              )
      Proveedor,
     --'/var/tmp/CARGAS/calvario.jpg' IMAGEN,
     decode(cba.currency_code,'MXN',NVL(ac.base_amount,ac.amount),ac.amount)            amount,
     cba.currency_code moneda,
      APPS.XXCALV_UTILS_PKG.XXCALV_GET_DESCRIPCION_FACTURA(ac.check_id) description,
      cba.BANK_ACCOUNT_NUM BANK_ACCOUNT_NUM,
      USR.USER_NAME,
      decode(:P_LEYENDA,'NO',decode(nvl(XXCALV_OBTIENE_LEYENDA_FNC(ac.vendor_name),'NO'),'NO','','PARA ABONO EN LA CUENTA DEL BENEFICIARIO') ,
                                           'SI','PARA ABONO EN LA CUENTA DEL BENEFICIARIO'
      )
       Nota  
      ,'Referencia Cta. Bancaria --> ' || REGEXP_SUBSTR(cba.BANK_ACCOUNT_NUM,'[[:digit:]]+') Referencia 
 from ap.ap_checks_all ac,
        ap.ap_suppliers ap,
        ce_bank_accounts cba,
        ap.ap_invoice_payments_all aip,
        ap.ap_invoices_all aia,
        applsys.fnd_user usr
 where 1=1
    and ac.vendor_id = ap.vendor_id
    and ac.BANK_ACCOUNT_NAME = cba.BANK_ACCOUNT_NAME
    and ac.STATUS_LOOKUP_CODE != 'VOIDED'
    and aia.invoice_id = aip.invoice_id
    and ac.check_id = aip.check_id
    and AC.CREATED_BY = usr.user_id
    and UPPER(ac.BANK_ACCOUNT_NAME) like '%BANORTE%'         --JRCA 13/DIC/2010
    and ac.check_number >= :P_CHECK_NUMBER
    and ac.check_number <= :P_CHECK_NUMBER2
--    and ac.org_id                 = FND_PROFILE.VALUE('ORG_ID')  --JRCA 01/DIC/2010
group by ac.check_id,
      ac.check_number,
      ac.check_date,
      ac.vendor_id,
      ac.vendor_name,
      AIA.ATTRIBUTE1,
      AIA.ATTRIBUTE2,
      ac.amount, 
      ac.base_amount,
     APPS.XXCALV_UTILS_PKG.XXCALV_GET_DESCRIPCION_FACTURA(ac.check_id),
      cba.BANK_ACCOUNT_NUM,
      cba.currency_code,
      USR.USER_NAME                                --JRCA 13/DIC/2010
order by check_number