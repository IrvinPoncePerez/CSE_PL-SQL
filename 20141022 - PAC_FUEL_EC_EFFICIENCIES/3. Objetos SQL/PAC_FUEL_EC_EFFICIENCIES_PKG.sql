PACKAGE PAC_FUEL_EC_EFFICIENCIES_PKG IS
 
  FUNCTION GET_ASSET_GROUP_DESCRIPTION(VEHICLE_ID     VARCHAR2)
  RETURN VARCHAR2;
  
  PROCEDURE CLEAR_CONTROLS(P_CONTROL VARCHAR2);

  PROCEDURE CALCULATE_EFFICIENCY;

  PROCEDURE ENABLED_CONTROLS(P_AREA VARCHAR2);

  PROCEDURE VALIDATE_AREA;

  PROCEDURE VALIDATE_TRAFFIC_NUMBER;
 
  PROCEDURE VALIDATE_CONSUMED_FUEL;

  PROCEDURE VALIDATE_ACTUAL_READING;

  PROCEDURE SET_COLOR(P_PERCENT NUMBER);

	PROCEDURE BUTTON_PRESSED;

	PROCEDURE ON_SAVE_PROCEDURE;

	PROCEDURE CHECK_STATUS;

	PROCEDURE CHECK_STATUS_BY_CONTROL;

	FUNCTION VALIDATE_FORM 
	RETURN BOOLEAN;

  PROCEDURE VALIDATE_VEHICLE_ID;
  
  PROCEDURE GET_EFFICIENCY_EXPECTED;
  
END;