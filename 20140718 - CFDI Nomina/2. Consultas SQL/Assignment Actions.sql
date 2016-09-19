SELECT DISTINCT PAA.ASSIGNMENT_ACTION_ID
                                       FROM PAY_ASSIGNMENT_ACTIONS PAA
                                      WHERE 1 = 1
                                        AND PAA.ASSIGNMENT_ID = :P_ASSIGNMENT_ID
                                        AND PAA.PAYROLL_ACTION_ID = :P_PAYROLL_ACTION_ID;