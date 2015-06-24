SELECT 
       GJH.JE_HEADER_ID,
       GJL.JE_LINE_NUM,
       GJH.NAME                                                AS  NOM_POLIZA,
       TO_CHAR(GJH.DEFAULT_EFFECTIVE_DATE,'DD/MM/YYYY')        AS  fecha_elabo,
       ('POLIZA DE ' || UPPER(GJCT.USER_JE_CATEGORY_NAME) 
                     || ' '
                     || UPPER(GJST.USER_JE_SOURCE_NAME)
                     || ' '
                     ||GJH.DOC_SEQUENCE_VALUE)                  AS  CATEGORIA,
        GJH.DOC_SEQUENCE_VALUE                                  AS  num_poliza,
        (TO_CHAR(SYSDATE,'DD/MM/YYYY') 
                 || ' ' 
                 || 'Hora:'
                 || ' '
                 || TO_CHAR(SYSDATE,'hh:mi:ss'))                AS  fecha_impre,
        GCC.SEGMENT1 ||' '|| HAOU.NAME                          AS  compania,
        HAOU.NAME                                               AS  nom_entidad,
        GCC.SEGMENT2                                            AS  centro_costos,
        GCC.SEGMENT3                                            AS  CUENTA,
         (SELECT DISTINCT 
                 FFVT.DESCRIPTION
            FROM FND_FLEX_VALUES_TL     FFVT,
                 FND_FLEX_VALUES        FFVB,
                 FND_ID_FLEX_SEGMENTS   FIFS,
                 GL_ACCESS_SETS         GAS
           WHERE FFVB.FLEX_VALUE_ID     = FFVT.FLEX_VALUE_ID
             AND FFVB.FLEX_VALUE_SET_ID = FIFS.FLEX_VALUE_SET_ID
             AND FFVT.LANGUAGE          = 'ESA'
             AND FIFS.SEGMENT_NAME      = 'CUENTA'
             AND FIFS.ID_FLEX_CODE      = 'GL#'
             AND GAS.CHART_OF_ACCOUNTS_ID = FIFS.ID_FLEX_NUM
             AND GAS.ACCESS_SET_ID      = NVL(NULL, GAS.ACCESS_SET_ID)
             AND FFVB.FLEX_VALUE        = GCC.SEGMENT3
         )                                                      AS  DESCRP_CUENTA,
        GCC.SEGMENT4                                            AS  intercompania,
        GJL.DESCRIPTION                                         AS  descripcion_lineas,
        DECODE(GJH.CURRENCY_CODE,
               'MXN',
               GJL.ENTERED_DR,
               GJL.ACCOUNTED_DR)                                AS  cargo,
        DECODE(GJH.CURRENCY_CODE,
               'MXN',
               GJL.ENTERED_CR,
               GJL.ACCOUNTED_CR)                                AS  abono,
        DECODE(GJH.CURRENCY_CODE,
               'MXN',
               GJH.RUNNING_TOTAL_DR,
               GJH.RUNNING_TOTAL_ACCOUNTED_DR)                  AS  total_cargo,
        DECODE(GJH.CURRENCY_CODE,
               'MXN',
               GJH.RUNNING_TOTAL_CR,
               GJH.RUNNING_TOTAL_ACCOUNTED_CR)                  AS  total_abono,
        GJH.CREATED_BY,
        UPPER(FNU.DESCRIPTION)                                  AS  ELABORO       
  FROM HR_ALL_ORGANIZATION_UNITS        HAOU,
       FINANCIALS_SYSTEM_PARAMS_ALL     FSPA,
       GL_LEDGERS                       GL,
       GL_JE_HEADERS                    GJH,
       GL_JE_LINES                      GJL,
       GL_CODE_COMBINATIONS             GCC,
       GL_JE_CATEGORIES_TL              GJCT,
       GL_JE_SOURCES_TL                 GJST,
       FND_USER                         FNU,
       (SELECT 
               FFVS.FLEX_VALUE_SET_NAME,
               FFVL.DESCRIPTION,
               FFV.FLEX_VALUE
          FROM FND_FLEX_VALUE_SETS  FFVS,
               FND_FLEX_VALUES_TL   FFVL,
               FND_FLEX_VALUES      FFV
         WHERE FFV.FLEX_VALUE_SET_ID    = FFVS.FLEX_VALUE_SET_ID
           AND FFV.FLEX_VALUE_ID        = FFVL.FLEX_VALUE_ID
           AND FFVS.FLEX_VALUE_SET_NAME = 'Elaboro Polizas'
           AND FFVL.LANGUAGE            = 'ESA'
         )   DES
 WHERE HAOU.ORGANIZATION_ID     = :P_ORG_ID
   AND HAOU.ORGANIZATION_ID     = FSPA.ORG_ID
   AND GL.LEDGER_ID             = FSPA.SET_OF_BOOKS_ID
   AND GJH.LEDGER_ID            = GL.LEDGER_ID
   AND GJH.DEFAULT_EFFECTIVE_DATE BETWEEN NVL(APPS.FND_DATE.CANONICAL_TO_DATE(:P_FECHA_INI), GJH.DEFAULT_EFFECTIVE_DATE) 
                                      AND NVL(APPS.FND_DATE.CANONICAL_TO_DATE(:P_FECHA_FIN), GJH.DEFAULT_EFFECTIVE_DATE)    
   AND GJH.DOC_SEQUENCE_VALUE LIKE NVL(:P_NUM_POL, '%')                             
   AND GJH.JE_HEADER_ID         = GJL.JE_HEADER_ID
   AND GJL.LEDGER_ID            = GL.LEDGER_ID
   AND GJL.CODE_COMBINATION_ID  = GCC.CODE_COMBINATION_ID
   AND GJCT.JE_CATEGORY_NAME    = GJH.JE_CATEGORY
   AND GJCT.LANGUAGE            = 'ESA'
   AND GJCT.USER_JE_CATEGORY_NAME = NVL(:P_CATEGORIA, GJCT.USER_JE_CATEGORY_NAME)
   AND GJH.JE_SOURCE            = GJST.JE_SOURCE_NAME    
   AND GJST.LANGUAGE            = 'ESA'   
   AND GJST.USER_JE_SOURCE_NAME = NVL(:P_ORIGEN, GJST.USER_JE_SOURCE_NAME)  
   AND GJH.CREATED_BY           = FNU.USER_ID
   AND GJST.JE_SOURCE_NAME      = DES.FLEX_VALUE
 ORDER BY GJH.DOC_SEQUENCE_VALUE,                   
          GCC.SEGMENT2,
          GCC.SEGMENT3,
          GCC.SEGMENT4