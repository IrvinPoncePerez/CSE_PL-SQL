BEGIN


    INSERT 
      INTO ATET_SB_ACCOUNT_MAPPING
            (
                SEGMENT1,
                SEGMENT2,
                SEGMENT3,
                SEGMENT4,
                SEGMENT5,
                SEGMENT6,
                CONCATENED_SEGMENT_1,
                CONCATENED_SEGMENT_2,
                DESCRIPTION
            )
     SELECT GL.SEGMENT1,
            GL.SEGMENT2,
            GL.SEGMENT3,
            GL.SEGMENT4,
            GL.SEGMENT5,
            GL.SEGMENT6,
            GL.SEGMENT1 || '-' ||
            GL.SEGMENT2 || '-' || 
            GL.SEGMENT3 ||  '-' ||
            GL.SEGMENT4 ||  '-' ||
            GL.SEGMENT5 ||  '-' ||
            GL.SEGMENT6,
            GL.SEGMENT1 ||
            GL.SEGMENT2 || 
            GL.SEGMENT3 ||
            GL.SEGMENT4 ||
            GL.SEGMENT5 ||
            GL.SEGMENT6,
            GL_FLEXFIELDS_PKG.GET_CONCAT_DESCRIPTION
                                                  (CHART_OF_ACCOUNTS_ID,
                                                   CODE_COMBINATION_ID
                                                  ) AS DESCRIPTION
         FROM GL_CODE_COMBINATIONS_V  GL
        WHERE 1 = 1
          AND TEMPLATE_ID IS NULL
          AND SEGMENT1 = '07';
          
    COMMIT;


END;