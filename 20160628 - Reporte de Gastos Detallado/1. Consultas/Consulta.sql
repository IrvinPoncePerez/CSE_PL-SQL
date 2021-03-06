    SELECT (GCC.SEGMENT1 || '-' ||
            GCC.SEGMENT2 || '-' ||
            GCC.SEGMENT3 || '-' ||
            GCC.SEGMENT4 || '-' ||
            GCC.SEGMENT5 || '-' ||
            GCC.SEGMENT6)               AS  CODE_COMBINATION,
            GB.PERIOD_NAME              AS  PERIOD_NAME,
            GJB.NAME                    AS  BATCH_NAME,
            GJL.JE_LINE_NUM             AS  LINE_NUMBER,
            GJL.ENTERED_DR              AS  ENTERED_DR,
            GJL.ENTERED_CR              AS  ENTERED_CR,
            XAL.ACCOUNTING_DATE         AS  ACCOUNTING_DATE,
            XAL.ACCOUNTED_DR            AS  ACCOUNTED_DR,
            XAL.ACCOUNTED_CR            AS  ACCOUNTED_CR,
            TE.ENTITY_CODE              AS  ENTITY_CODE,
            TE.TRANSACTION_NUMBER       AS  TRANSACTION_NUMBER
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
     ORDER BY GJH.JE_HEADER_ID,
              GJL.JE_LINE_NUM
           
           