PACKAGE PAC_VISITS_VIEW_PKG IS
  
  PROCEDURE ON_PRE_QUERY;
  
  PROCEDURE ON_POST_QUERY;
  
  PROCEDURE SET_BACKGROUND(ITEM VARCHAR2, BACKGROUND VARCHAR2);
  
  PROCEDURE	PRINT_LABEL;  
  
  PROCEDURE CHECKED;
  
  PROCEDURE REENTRY;
  
END;