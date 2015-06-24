SELECT
    COMPANY.MEANING,
    ORGANIZATIONS.ORGANIZATION_ID,
    INFORMATION.ORG_INFORMATION2
FROM FND_LOOKUP_VALUES                     COMPANY     
INNER JOIN HR_ORGANIZATION_UNITS_V         ORGANIZATIONS    ON COMPANY.MEANING = ORGANIZATIONS.NAME
INNER JOIN HR_ORGANIZATION_INFORMATION     INFORMATION      ON INFORMATION.ORGANIZATION_ID = ORGANIZATIONS.ORGANIZATION_ID
WHERE COMPANY.lookup_type= 'NOMINAS POR EMPLEADOR LEGAL'
  AND COMPANY.lookup_code = :P_COMPANY_ID
  AND INFORMATION.ORG_INFORMATION_CONTEXT = 'MX_TAX_REGISTRATION'