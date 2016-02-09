begin

    ATET_SAVINGS_BANK_PKG.EXTEND_PAYMENTS_SCHEDULE(P_LOAN_ID => 180,
                             P_PERSON_ID => 2801,
                             P_MEMBER_ID => 1435,
                             P_TIME_PERIOD_ID => 135352,
                             P_ACTUAL_DATE_EARNED => TO_DATE('31/10/2016', 'DD/MM/YYYY'),
                             P_PAYMENT_CAPITAL => 357.15,
                             P_PAYMENT_INTEREST => 74.9,
                             P_PAYMENT_INTEREST_LATE => 21.60);

end;


select asm.person_id,
       asm.member_id,
       ASM.ATTRIBUTE6,
       asl.LOAN_ID,
       asps.TIME_PERIOD_ID,
       asps.payment_number,
       ASPS.PERIOD_NUMBER,
       ASPS.PERIOD_NAME,
       asps.PAYMENT_DATE,
       asps.PAYMENT_CAPITAL,
       asps.PAYMENT_INTEREST,
       asps.PAYMENT_INTEREST_LATE
  from atet_sb_members  asm,
       atet_sb_loans    asl,
       atet_sb_payments_schedule asps
 where 1 = 1
   and asm.MEMBER_ID = asl.MEMBER_ID
   and asl.loan_id = asps.loan_id
 order by person_id,    
          loan_id,
          payment_number;
   