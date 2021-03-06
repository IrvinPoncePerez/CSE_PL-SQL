SELECT VH.LOCATION_CODE,
       VH.VEHICLE_TYPE,
       VH.VEHICLE_ID,
       VH.VEHICLE,
       VH.FUEL_TYPE,
       EAM.METER_NAME,
       PAC_FUEL_EFFICIENCY.GET_METER_READING(EAM.METER_ID) METER_READING
  FROM (SELECT DISTINCT
               MEL.LOCATION_CODES       AS "LOCATION_CODE",
               MC.SEGMENT2              AS "VEHICLE_TYPE",
               CII.INSTANCE_NUMBER      AS VEHICLE_ID,
               CII.INSTANCE_DESCRIPTION AS "VEHICLE",       
               CII.ATTRIBUTE10          AS FUEL_TYPE
          FROM CSI_ITEM_INSTANCES       CII,
               EAM_ORG_MAINT_DEFAULTS   EOMD,
               MTL_EAM_LOCATIONS        MEL,
               MTL_CATEGORIES_B         MC
         WHERE 1 = 1
           AND CII.INSTANCE_ID  = EOMD.OBJECT_ID
           AND EOMD.AREA_ID = MEL.LOCATION_ID
           AND MEL.LOCATION_CODES <> 'GRB'
           AND CII.CATEGORY_ID = MC.CATEGORY_ID
           AND MC.SEGMENT1 = 'VEHICULO'
           AND MEL.LOCATION_CODES <> 'GRB'
           AND CII.INSTANCE_NUMBER NOT LIKE 'PAC%'
           AND (MC.SEGMENT2 <> 'REMOLQUE'
            AND MC.SEGMENT2 <> 'SEMIREMOLQUE'
            AND MC.SEGMENT2 <> 'TOLVA'
            AND MC.SEGMENT2 <> 'DOLLY')
         )  VH
  LEFT JOIN EAM_ASSET_METERS_V EAM ON  (EAM.ASSET_NUMBER = VH.VEHICLE_ID AND EAM.METER_UOM = 'KM')
 WHERE 1 = 1
   AND VH.LOCATION_CODE = NVL(:P_AREA, VH.LOCATION_CODE)
   AND VH.VEHICLE_TYPE = NVL(:P_VEHICLE_TYPE, VH.VEHICLE_TYPE)
 ORDER BY LOCATION_CODE,
          VEHICLE_TYPE,
          VEHICLE