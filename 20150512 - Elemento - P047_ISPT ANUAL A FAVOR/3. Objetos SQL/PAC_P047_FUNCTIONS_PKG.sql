CREATE OR REPLACE PACKAGE PAC_P047_FUNCTIONS_PKG AS

    FUNCTION GET_BALANCE(P_ASSIGNMENT_ID        NUMBER)
             RETURN NUMBER;
             
END PAC_P047_FUNCTIONS_PKG;