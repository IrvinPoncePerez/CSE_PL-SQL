select *
  from (
select member_id,
       count(loan_id) prestamos
 from (

SELECT ASL.MEMBER_ID,
       ASL.LOAN_ID,
       ASMA.ACCOUNT_DESCRIPTION || ' # ' || ASL.LOAN_NUMBER AS  ACCOUNT_DESCRIPTION,
       ASL.LOAN_BALANCE + ASLT.CREDIT_AMOUNT                AS  INITIAL_BALANCE,
       ASLT.CREDIT_AMOUNT                                   AS  CREDIT_AMOUNT,
       ASL.LOAN_BALANCE                                     AS  FINAL_BALANCE
  FROM ATET_SB_LOANS                ASL,
       ATET_SB_MEMBERS_ACCOUNTS     ASMA,
       ATET_SB_LOANS_TRANSACTIONS   ASLT
 WHERE 1 = 1 
   AND ASMA.LOAN_ID = ASL.LOAN_ID
   AND ASMA.MEMBER_ID = ASL.MEMBER_ID
   AND ASLT.LOAN_ID = ASL.LOAN_ID
   AND ASLT.MEMBER_ACCOUNT_ID = ASMA.MEMBER_ACCOUNT_ID
   AND ASLT.MEMBER_ID = ASL.MEMBER_ID
   AND ASLT.ATTRIBUTE7 = 'REPARTO DE AHORRO'
--   AND ASL.MEMBER_ID = :PP_MEMBER_ID
 UNION
SELECT DISTINCT
       ASL.MEMBER_ID,
       ASL.LOAN_ID,
       ASMA.ACCOUNT_DESCRIPTION || ' # ' || ASL.LOAN_NUMBER AS  ACCOUNT_DESCRIPTION,
       ASL.LOAN_BALANCE                                     AS  INITIAL_BALANCE,
       0                                                    AS  CREDIT_AMOUNT,
       ASL.LOAN_BALANCE                                     AS  FINAL_BALANCE
  FROM ATET_SB_LOANS                ASL,
       ATET_SB_MEMBERS_ACCOUNTS     ASMA,
       ATET_SB_LOANS_TRANSACTIONS   ASLT
 WHERE 1 = 1
   AND ASMA.LOAN_ID = ASL.LOAN_ID
   AND ASMA.MEMBER_ID = ASL.MEMBER_ID
   AND ASLT.LOAN_ID = ASL.LOAN_ID
   AND ASL.LOAN_STATUS_FLAG = 'ACTIVE'
   AND ASLT.MEMBER_ACCOUNT_ID = ASMA.MEMBER_ACCOUNT_ID
   AND ASLT.MEMBER_ID = ASL.MEMBER_ID
   AND ASLT.ATTRIBUTE7 = NULL)d
where 1 = 1
  
group by member_id) f,
    atet_sb_members asm
where prestamos > 1
     and f.member_id = asm.member_id
--   AND ASL.MEMBER_ID = :PP_MEMBER_ID


   
