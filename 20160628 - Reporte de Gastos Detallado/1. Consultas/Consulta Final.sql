SELECT D.SEGMENT1 || '-' ||
       D.SEGMENT2 || '-' ||
       D.SEGMENT3 || '-' ||
       D.SEGMENT4 || '-' ||
       D.SEGMENT5 || '-' ||
       D.SEGMENT6                           AS  CODE_COMBINATION,
       D.ACCOUNTING_DATE,
       D.SEGMENT2                           AS  C_CTO,
       D.SEGMENT3                           AS  C_ACCOUNT,
       D.DOCUMENT_NUMBER,
       D.INVOICE_AMOUNT,
       D.VENDOR_NAME,
       D.DESCRIPTION,
       D.ACCOUNTED_DR,
       D.ACCOUNTED_CR
  FROM (SELECT  GCC.SEGMENT1,
                GCC.SEGMENT2,
                GCC.SEGMENT3,
                GCC.SEGMENT4,
                GCC.SEGMENT5,
                GCC.SEGMENT6,
                GB.PERIOD_NAME              AS  PERIOD_NAME,
                GJB.NAME                    AS  BATCH_NAME,
                GJL.JE_LINE_NUM             AS  LINE_NUMBER,
                GJL.ENTERED_DR              AS  ENTERED_DR,
                GJL.ENTERED_CR              AS  ENTERED_CR,
                XAL.ACCOUNTING_DATE         AS  ACCOUNTING_DATE,
                XAL.ACCOUNTED_DR            AS  ACCOUNTED_DR,
                XAL.ACCOUNTED_CR            AS  ACCOUNTED_CR,
                TE.ENTITY_CODE              AS  ENTITY_CODE,
                TE.TRANSACTION_NUMBER       AS  TRANSACTION_NUMBER,
                NULL                        AS  DOCUMENT_NUMBER,
                NULL                        AS  VENDOR_NAME,
                NULL                        AS  DESCRIPTION,
                NULL                        AS  INVOICE_AMOUNT,
                GJL.JE_HEADER_ID,
                GJL.JE_LINE_NUM
          FROM GL_LEDGERS                   GL,
               GL_BALANCES                  GB,
               GL_CODE_COMBINATIONS         GCC,
               GL_JE_BATCHES                GJB,
               GL_JE_HEADERS                GJH,
               GL_JE_LINES                  GJL,
               GL_IMPORT_REFERENCES         GIR,
               XLA_AE_LINES                 XAL,
               XLA_AE_HEADERS               XAH,
               XLA.XLA_TRANSACTION_ENTITIES TE
         WHERE 1 = 1
           AND GL.NAME = 'CALVARIO_LIBRO_CONTABLE'
           AND GL.LEDGER_ID = GB.LEDGER_ID
           AND GB.PERIOD_NAME = :P_PERIOD_NAME
           AND GB.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND GCC.SEGMENT1 = NVL(:P_SEGMENT1, GCC.SEGMENT1)
           AND GCC.SEGMENT2 = NVL(:P_SEGMENT2, GCC.SEGMENT2)
           AND GCC.SEGMENT3 = NVL(:P_SEGMENT3, GCC.SEGMENT3)
           AND GCC.SEGMENT4 = NVL(:P_SEGMENT4, GCC.SEGMENT4)
           AND GCC.SEGMENT5 = NVL(:P_SEGMENT5, GCC.SEGMENT5)
           AND GCC.SEGMENT6 = NVL(:P_SEGMENT6, GCC.SEGMENT6)
           AND GJH.LEDGER_ID = GL.LEDGER_ID
           AND GJH.PERIOD_NAME = GB.PERIOD_NAME
           AND GJB.JE_BATCH_ID = GJH.JE_BATCH_ID
           AND GJL.JE_HEADER_ID = GJH.JE_HEADER_ID
           AND GJL.LEDGER_ID = GL.LEDGER_ID
           AND GJL.PERIOD_NAME = GB.PERIOD_NAME
           AND GJL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND GIR.JE_BATCH_ID = GJB.JE_BATCH_ID
           AND GIR.JE_HEADER_ID = GJH.JE_HEADER_ID
           AND GIR.JE_LINE_NUM = GJL.JE_LINE_NUM
           AND GIR.GL_SL_LINK_ID = XAL.GL_SL_LINK_ID
           AND GIR.GL_SL_LINK_TABLE = XAL.GL_SL_LINK_TABLE
           AND XAL.AE_HEADER_ID = XAH.AE_HEADER_ID
           AND XAL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND TE.ENTITY_ID = XAH.ENTITY_ID
           AND TE.ENTITY_CODE NOT IN ('MTL_ACCOUNTING_EVENTS',
--                                      'WIP_ACCOUNTING_EVENTS',
                                      'AP_INVOICES')
    UNION
        SELECT  GCC.SEGMENT1,
                GCC.SEGMENT2,
                GCC.SEGMENT3,
                GCC.SEGMENT4,
                GCC.SEGMENT5,
                GCC.SEGMENT6,
                GB.PERIOD_NAME              AS  PERIOD_NAME,
                GJB.NAME                    AS  BATCH_NAME,
                GJL.JE_LINE_NUM             AS  LINE_NUMBER,
                GJL.ENTERED_DR              AS  ENTERED_DR,
                GJL.ENTERED_CR              AS  ENTERED_CR,
                XAL.ACCOUNTING_DATE         AS  ACCOUNTING_DATE,
                XAL.ACCOUNTED_DR            AS  ACCOUNTED_DR,
                XAL.ACCOUNTED_CR            AS  ACCOUNTED_CR,
                TE.ENTITY_CODE              AS  ENTITY_CODE,
                TE.TRANSACTION_NUMBER       AS  TRANSACTION_NUMBER,
                NULL                        AS  DOCUMENT_NUMBER,
                NULL                        AS  VENDOR_NAME,
                MSI.DESCRIPTION             AS  DESCRIPTION,
                NULL                        AS  INVOICE_AMOUNT,
                GJL.JE_HEADER_ID,
                GJL.JE_LINE_NUM
          FROM GL_LEDGERS                   GL,
               GL_BALANCES                  GB,
               GL_CODE_COMBINATIONS         GCC,
               GL_JE_BATCHES                GJB,
               GL_JE_HEADERS                GJH,
               GL_JE_LINES                  GJL,
               GL_IMPORT_REFERENCES         GIR,
               XLA_AE_LINES                 XAL,
               XLA_AE_HEADERS               XAH,
               XLA.XLA_TRANSACTION_ENTITIES TE,
               MTL_MATERIAL_TRANSACTIONS    MMT,
               MTL_SYSTEM_ITEMS_TL          MSI
         WHERE 1 = 1
           AND GL.NAME = 'CALVARIO_LIBRO_CONTABLE'
           AND GL.LEDGER_ID = GB.LEDGER_ID
           AND GB.PERIOD_NAME = :P_PERIOD_NAME
           AND GB.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND GCC.SEGMENT1 = NVL(:P_SEGMENT1, GCC.SEGMENT1)
           AND GCC.SEGMENT2 = NVL(:P_SEGMENT2, GCC.SEGMENT2)
           AND GCC.SEGMENT3 = NVL(:P_SEGMENT3, GCC.SEGMENT3)
           AND GCC.SEGMENT4 = NVL(:P_SEGMENT4, GCC.SEGMENT4)
           AND GCC.SEGMENT5 = NVL(:P_SEGMENT5, GCC.SEGMENT5)
           AND GCC.SEGMENT6 = NVL(:P_SEGMENT6, GCC.SEGMENT6)
           AND GJH.LEDGER_ID = GL.LEDGER_ID
           AND GJH.PERIOD_NAME = GB.PERIOD_NAME
           AND GJB.JE_BATCH_ID = GJH.JE_BATCH_ID
           AND GJL.JE_HEADER_ID = GJH.JE_HEADER_ID
           AND GJL.LEDGER_ID = GL.LEDGER_ID
           AND GJL.PERIOD_NAME = GB.PERIOD_NAME
           AND GJL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND GIR.JE_BATCH_ID = GJB.JE_BATCH_ID
           AND GIR.JE_HEADER_ID = GJH.JE_HEADER_ID
           AND GIR.JE_LINE_NUM = GJL.JE_LINE_NUM
           AND GIR.GL_SL_LINK_ID = XAL.GL_SL_LINK_ID
           AND GIR.GL_SL_LINK_TABLE = XAL.GL_SL_LINK_TABLE
           AND XAL.AE_HEADER_ID = XAH.AE_HEADER_ID
           AND XAL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND TE.ENTITY_ID = XAH.ENTITY_ID
           AND TE.ENTITY_CODE IN ('MTL_ACCOUNTING_EVENTS')
           AND TE.TRANSACTION_NUMBER = MMT.TRANSACTION_ID
           AND MSI.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
           AND MSI.ORGANIZATION_ID = MMT.ORGANIZATION_ID
           AND MSI.LANGUAGE = USERENV('LANG')
    UNION
--        SELECT  GCC.SEGMENT1,
--                GCC.SEGMENT2,
--                GCC.SEGMENT3,
--                GCC.SEGMENT4,
--                GCC.SEGMENT5,
--                GCC.SEGMENT6,
--                GB.PERIOD_NAME              AS  PERIOD_NAME,
--                GJB.NAME                    AS  BATCH_NAME,
--                GJL.JE_LINE_NUM             AS  LINE_NUMBER,
--                GJL.ENTERED_DR              AS  ENTERED_DR,
--                GJL.ENTERED_CR              AS  ENTERED_CR,
--                XAL.ACCOUNTING_DATE         AS  ACCOUNTING_DATE,
--                XAL.ACCOUNTED_DR            AS  ACCOUNTED_DR,
--                XAL.ACCOUNTED_CR            AS  ACCOUNTED_CR,
--                TE.ENTITY_CODE              AS  ENTITY_CODE,
--                TE.TRANSACTION_NUMBER       AS  TRANSACTION_NUMBER,
--                NULL                        AS  DOCUMENT_NUMBER,
--                NULL                        AS  VENDOR_NAME,
--                WE.WIP_ENTITY_NAME          AS  DESCRIPTION,
--                GJL.JE_HEADER_ID,
--                GJL.JE_LINE_NUM
--          FROM GL_LEDGERS                   GL,
--               GL_BALANCES                  GB,
--               GL_CODE_COMBINATIONS         GCC,
--               GL_JE_BATCHES                GJB,
--               GL_JE_HEADERS                GJH,
--               GL_JE_LINES                  GJL,
--               GL_IMPORT_REFERENCES         GIR,
--               XLA_AE_LINES                 XAL,
--               XLA_AE_HEADERS               XAH,
--               XLA.XLA_TRANSACTION_ENTITIES TE,
--               XLA_DISTRIBUTION_LINKS       XDL,
--               WIP_TRANSACTION_ACCOUNTS     WTA,
--               WIP_ENTITIES                 WE
--         WHERE 1 = 1
--           AND GL.NAME = 'CALVARIO_LIBRO_CONTABLE'
--           AND GL.LEDGER_ID = GB.LEDGER_ID
--           AND GB.PERIOD_NAME = :P_PERIOD_NAME
--           AND GB.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
--           AND GCC.SEGMENT1 = NVL(:P_SEGMENT1, GCC.SEGMENT1)
--           AND GCC.SEGMENT2 = NVL(:P_SEGMENT2, GCC.SEGMENT2)
--           AND GCC.SEGMENT3 = NVL(:P_SEGMENT3, GCC.SEGMENT3)
--           AND GCC.SEGMENT4 = NVL(:P_SEGMENT4, GCC.SEGMENT4)
--           AND GCC.SEGMENT5 = NVL(:P_SEGMENT5, GCC.SEGMENT5)
--           AND GCC.SEGMENT6 = NVL(:P_SEGMENT6, GCC.SEGMENT6)
--           AND GJH.LEDGER_ID = GL.LEDGER_ID
--           AND GJH.PERIOD_NAME = GB.PERIOD_NAME
--           AND GJB.JE_BATCH_ID = GJH.JE_BATCH_ID
--           AND GJL.JE_HEADER_ID = GJH.JE_HEADER_ID
--           AND GJL.LEDGER_ID = GL.LEDGER_ID
--           AND GJL.PERIOD_NAME = GB.PERIOD_NAME
--           AND GJL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
--           AND GIR.JE_BATCH_ID = GJB.JE_BATCH_ID
--           AND GIR.JE_HEADER_ID = GJH.JE_HEADER_ID
--           AND GIR.JE_LINE_NUM = GJL.JE_LINE_NUM
--           AND GIR.GL_SL_LINK_ID = XAL.GL_SL_LINK_ID
--           AND GIR.GL_SL_LINK_TABLE = XAL.GL_SL_LINK_TABLE
--           AND XAL.AE_HEADER_ID = XAH.AE_HEADER_ID
--           AND XAL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
--           AND TE.ENTITY_ID = XAH.ENTITY_ID
--           AND TE.ENTITY_CODE IN ('WIP_ACCOUNTING_EVENTS')
--           AND XDL.AE_HEADER_ID = XAH.AE_HEADER_ID
--           AND XDL.EVENT_ID = XAH.EVENT_ID
--           AND XDL.APPLICATION_ID = TE.APPLICATION_ID
--           AND XDL.AE_LINE_NUM = XAL.AE_LINE_NUM
--           AND XDL.SOURCE_DISTRIBUTION_ID_NUM_1 = WTA.WIP_SUB_LEDGER_ID
--           AND WTA.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
--    UNION
        SELECT  GCC.SEGMENT1,
                GCC.SEGMENT2,
                GCC.SEGMENT3,
                GCC.SEGMENT4,
                GCC.SEGMENT5,
                GCC.SEGMENT6,
                GB.PERIOD_NAME              AS  PERIOD_NAME,
                GJB.NAME                    AS  BATCH_NAME,
                GJL.JE_LINE_NUM             AS  LINE_NUMBER,
                GJL.ENTERED_DR              AS  ENTERED_DR,
                GJL.ENTERED_CR              AS  ENTERED_CR,
                XAL.ACCOUNTING_DATE         AS  ACCOUNTING_DATE,
                XAL.ACCOUNTED_DR            AS  ACCOUNTED_DR,
                XAL.ACCOUNTED_CR            AS  ACCOUNTED_CR,
                TE.ENTITY_CODE              AS  ENTITY_CODE,
                TE.TRANSACTION_NUMBER       AS  TRANSACTION_NUMBER,
                ACA.CHECK_NUMBER            AS  DOCUMENT_NUMBER,
                PV.VENDOR_NAME              AS  VENDOR_NAME,
                AIA.DESCRIPTION             AS  DESCRIPTION,
                AIA.INVOICE_AMOUNT          AS  INVOICE_AMOUNT,
                GJL.JE_HEADER_ID,
                GJL.JE_LINE_NUM
          FROM GL_LEDGERS                   GL,
               GL_BALANCES                  GB,
               GL_CODE_COMBINATIONS         GCC,
               GL_JE_BATCHES                GJB,
               GL_JE_HEADERS                GJH,
               GL_JE_LINES                  GJL,
               GL_IMPORT_REFERENCES         GIR,
               XLA_AE_LINES                 XAL,
               XLA_AE_HEADERS               XAH,
               XLA.XLA_TRANSACTION_ENTITIES TE,
               AP_INVOICES_ALL              AIA,
               PO_VENDORS                   PV,
               AP_INVOICE_PAYMENTS_ALL      AIPA,
               AP_CHECKS_ALL                ACA
         WHERE 1 = 1
           AND GL.NAME = 'CALVARIO_LIBRO_CONTABLE'
           AND GL.LEDGER_ID = GB.LEDGER_ID
           AND GB.PERIOD_NAME = :P_PERIOD_NAME
           AND GB.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND GCC.SEGMENT1 = NVL(:P_SEGMENT1, GCC.SEGMENT1)
           AND GCC.SEGMENT2 = NVL(:P_SEGMENT2, GCC.SEGMENT2)
           AND GCC.SEGMENT3 = NVL(:P_SEGMENT3, GCC.SEGMENT3)
           AND GCC.SEGMENT4 = NVL(:P_SEGMENT4, GCC.SEGMENT4)
           AND GCC.SEGMENT5 = NVL(:P_SEGMENT5, GCC.SEGMENT5)
           AND GCC.SEGMENT6 = NVL(:P_SEGMENT6, GCC.SEGMENT6)
           AND GJH.LEDGER_ID = GL.LEDGER_ID
           AND GJH.PERIOD_NAME = GB.PERIOD_NAME
           AND GJB.JE_BATCH_ID = GJH.JE_BATCH_ID
           AND GJL.JE_HEADER_ID = GJH.JE_HEADER_ID
           AND GJL.LEDGER_ID = GL.LEDGER_ID
           AND GJL.PERIOD_NAME = GB.PERIOD_NAME
           AND GJL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND GIR.JE_BATCH_ID = GJB.JE_BATCH_ID
           AND GIR.JE_HEADER_ID = GJH.JE_HEADER_ID
           AND GIR.JE_LINE_NUM = GJL.JE_LINE_NUM
           AND GIR.GL_SL_LINK_ID = XAL.GL_SL_LINK_ID
           AND GIR.GL_SL_LINK_TABLE = XAL.GL_SL_LINK_TABLE
           AND XAL.AE_HEADER_ID = XAH.AE_HEADER_ID
           AND XAL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND TE.ENTITY_ID = XAH.ENTITY_ID
           AND TE.ENTITY_CODE IN ('AP_INVOICES')
           AND AIA.INVOICE_ID = TE.SOURCE_ID_INT_1
           AND PV.VENDOR_ID = AIA.VENDOR_ID
           AND AIPA.INVOICE_ID = AIA.INVOICE_ID
           AND ACA.CHECK_ID = AIPA.CHECK_ID
        ) D
 WHERE 1 = 1      
 ORDER BY 1,
          D.JE_HEADER_ID,
          D.JE_LINE_NUM
               
               
               
