
SELECT gl.CODE_COMBINATION_ID,
       gl.segment1 || '-' ||
       gl.segment2 || '-' || 
       gl.segment3 ||  '-' ||
       gl.segment4 ||  '-' ||
       gl.segment5 ||  '-' ||
       gl.segment6 AS CODE_COMBINATION,
    gl_flexfields_pkg.get_concat_description
                                          (chart_of_accounts_id,
                                           code_combination_id
                                          ) AS DESCRIPTION
 FROM GL_CODE_COMBINATIONS_V  gl
WHERE 1 = 1
  AND TEMPLATE_ID IS NULL
  AND SEGMENT1 = '07';



SELECT GL.CODE_COMBINATION_ID
  FROM GL_CODE_COMBINATIONS_V  GL
 WHERE 1 = 1
   AND GL.TEMPLATE_ID IS NULL
   AND GL.SEGMENT1 = '07'
   AND (GL.SEGMENT1 ||
        GL.SEGMENT2 ||
        GL.SEGMENT3 ||
        GL.SEGMENT4 ||
        GL.SEGMENT5 ||
        GL.SEGMENT6) = :P_CODE_COMBINATION; 
        
        
DELETE FROM ATET_SB_ENDORSEMENTS;
DELETE FROM ATET_SB_PAYMENTS_SCHEDULE;
DELETE FROM ATET_SB_PAYROLL_RESULTS;
DELETE FROM ATET_SB_MEMBERS_ACCOUNTS;
DELETE FROM ATET_SB_LOANS;
DELETE FROM ATET_SB_LOANS_TRANSACTIONS;
DELETE FROM ATET_SB_SAVINGS_TRANSACTIONS;

COMMIT;