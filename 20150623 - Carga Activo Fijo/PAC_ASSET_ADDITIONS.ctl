LOAD DATA
BADFILE '/PAC_ASSET_ADDITIONS.BAD'
DISCARDFILE '/PAC_ASSET_ADDITIONS.DSC'
REPLACE
INTO TABLE APPS.PAC_ASSET_ADDITIONS_TB
Fields terminated by "," Optionally enclosed by '"'
(
  	DESCRIPTION     	  ,
    TAG_NUMBER            ,
    SERIAL_NUMBER         ,
    UNITS                 ,   
    CATEGORY              ,
    SUBCATEGORY           ,
    COST                  ,
    VENDOR_NAME           ,
    INVOICE_NUMBER        ,
    BOOK_CODE             ,
    DATE_IN_SERVICE       ,
    DEPRECIATE_METHOD     ,
    PRORATE_CODE          ,
    CODE_COMPANY          ,
    CODE_CCOST            ,
    CODE_ACCOUNT          ,
    CODE_INTERORG         ,
    CODE_FUTURO1          ,
    CODE_FUTURO2          ,
    LOCATION_STATE        ,
    LOCATION_CITY         ,
    LOCATION_COST         
)

