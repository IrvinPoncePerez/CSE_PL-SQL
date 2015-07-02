SELECT MSI.INVENTORY_ITEM_ID,
       MSI.DESCRIPTION,
       MSI.SEGMENT1
  FROM MTL_SYSTEM_ITEMS_B       MSI
  LEFT JOIN MTL_SYSTEM_ITEMS_B  MSI1    ON
 WHERE 1 = 1 
   AND MSI.ORGANIZATION_ID = 101
   AND MSI.SEGMENT1 IN ('HVOBCO0070',
                        'HVOBCO0200',
                        'HVOBCO0201',
                        'HVOBCO0202',
                        'HVOBCO0203',
                        'HVOBCO0204',
                        'HVOBCO0205',
                        'HVOBCO0206',
                        'HVOCON0001',
                        'HVOCON0002',
                        'HVOCON0003',
                        'HVOCON0007',
                        'HVORES0001')