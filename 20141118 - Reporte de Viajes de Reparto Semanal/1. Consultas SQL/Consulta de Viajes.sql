    SELECT DISTINCT
           CII.INSTANCE_NUMBER      AS VEHICLE_ID,
           CII.INSTANCE_DESCRIPTION AS VEHICLE,
           DAYS.NUM_DAY,
           DAYS.MON_DAY,
           TO_CHAR(MON_DAY, 'DAY')  AS DES_DAY,
           PAC_FUEL_EC_REPORTS_PKG.GET_DESTINATION_NAME(CII.INSTANCE_NUMBER, DAYS.MON_DAY)  AS  DESTINATION_NAME,
           PAC_FUEL_EC_REPORTS_PKG.GET_DRIVER_NAME(CII.INSTANCE_NUMBER, DAYS.MON_DAY)       AS  DRIVER_NAME,
           PAC_FUEL_EC_REPORTS_PKG.GET_TRAILER_TYPE(CII.INSTANCE_NUMBER, DAYS.MON_DAY)      AS  TRAILER_TYPE,
           ROUND(PAC_FUEL_EC_REPORTS_PKG.GET_LTS_DIFFERENCE(CII.INSTANCE_NUMBER, DAYS.MON_DAY),0)  AS  LTS_DIFFERENCE
      FROM CSI_ITEM_INSTANCES       CII,
           EAM_ORG_MAINT_DEFAULTS   EOMD,
           MTL_EAM_LOCATIONS        MEL,
           MTL_CATEGORIES_B         MC,
           (SELECT LEVEL NUM_DAY,
                   TO_DATE(TO_CHAR(LEVEL
                                   , '09')||
                           TO_CHAR(EXTRACT(MONTH FROM :CP_START_DATE)
                                   , '09')||
                           TO_CHAR(EXTRACT(YEAR FROM :CP_START_DATE)
                                   , '9999')
                           ,'dd.mm.yyyy') MON_DAY
              FROM DUAL 
             WHERE ROWNUM <= EXTRACT(DAY FROM LAST_DAY(:CP_START_DATE))
           CONNECT BY LEVEL = ROWNUM
            UNION
            SELECT LEVEL NUM_DAY,
                   TO_DATE(TO_CHAR(LEVEL
                                   , '09')||
                           TO_CHAR(EXTRACT(MONTH FROM :CP_END_DATE)
                                   , '09')||
                           TO_CHAR(EXTRACT(YEAR FROM :CP_END_DATE)
                                   , '9999')
                           ,'dd.mm.yyyy') MON_DAY
              FROM DUAL 
             WHERE ROWNUM <= EXTRACT(DAY FROM LAST_DAY(:CP_END_DATE))
           CONNECT BY LEVEL = ROWNUM) DAYS
     WHERE 1 = 1
       AND CII.INSTANCE_ID  = EOMD.OBJECT_ID
       AND EOMD.AREA_ID = MEL.LOCATION_ID
       AND CII.CATEGORY_ID = MC.CATEGORY_ID
       AND MC.SEGMENT1 = 'VEHICULO'
       AND MEL.LOCATION_CODES = 'REPARTO'
       AND CII.INSTANCE_NUMBER NOT LIKE 'PAC%'
       AND (MC.SEGMENT2 = 'TRACTOCAMION'
        OR MC.SEGMENT2 = 'TORTON')
       AND DAYS.MON_DAY >= :CP_START_DATE
       AND DAYS.MON_DAY <= :CP_END_DATE
     ORDER BY VEHICLE,
              VEHICLE_ID,
              MON_DAY;