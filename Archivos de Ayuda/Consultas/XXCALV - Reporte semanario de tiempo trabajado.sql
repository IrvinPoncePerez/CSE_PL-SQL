SELECT cmp.meaning company, 
       tpttl.display_period_type period, 
       hpev.payroll_name payroll, 
       hpev.organization_id,
       hpev.d_organization_id department,
       hpev.d_organization_id department_mast_det,
       tpe.period_num||' del '||to_char(tpe.start_date,'DD/MON/YYYY')||' al '||to_char(tpe.end_date,'DD/MON/YYYY') period_num,
       tpe.time_period_id, tpe.period_name,
       to_char(tpe.start_date,'DD') MAR, 
       to_char(NEXT_DAY(tpe.start_date, 'MIÉ'),'DD') MIÉ, 
       to_char(NEXT_DAY(tpe.start_date, 'JUE'),'DD') JUE, 
       to_char(NEXT_DAY(tpe.start_date, 'VIE'),'DD') VIE, 
       to_char(NEXT_DAY(tpe.start_date, 'SÁB'),'DD') SÁB,
       to_char(NEXT_DAY(tpe.start_date, 'DOM'),'DD') DOM, 
       to_char(NEXT_DAY(tpe.start_date, 'LUN'),'DD') LUN,
       '1' TOTAL,
       '2' ED,
       hpev.employee_number,
       hpev.full_name,
       hpev.d_position_id,
       (SELECT meaning 
          FROM fnd_lookup_values flv
         WHERE lookup_type = 'XXCALV SEM TIEMPO TRAB'
           AND lookup_code = '011'
           AND LANGUAGE = userenv('LANG')
       ) bono,
       decode(hpev.employment_category,'MX2_TEMP_WRK',hpev.ass_attribute1,decode (hpev.assignment_type, 'E', hr_general.decode_lookup ('EMP_CAT', hpev.employment_category), 'C', hr_general.decode_lookup ('CWK_ASG_CATEGORY', hpev.employment_category))) contrato,
       (SELECT description
          FROM fnd_lookup_values flv
         WHERE lookup_type = 'XXCALV TIEMPO TRAB ELABORO'
           AND meaning = hpev.d_organization_id
           AND LANGUAGE = userenv('LANG')
       ) elaboro,
       (SELECT description
          FROM fnd_lookup_values flv
         WHERE lookup_type = 'XXCALV TIEMPO TRAB AUTORIZO'
           AND meaning = hpev.d_organization_id
           AND LANGUAGE = userenv('LANG')
       ) autorizo,
       (SELECT description
          FROM fnd_lookup_values flv
         WHERE lookup_type = 'XXCALV TIEMPO TRAB VO. BO.'
           AND meaning = hpev.d_organization_id
           AND LANGUAGE = userenv('LANG')
       ) vobo,
       (SELECT meaning
          FROM fnd_lookup_values flv
         WHERE lookup_type = 'XXCALV SEM TIEMPO TRAB'
           AND lookup_code = '001'
           AND LANGUAGE = userenv('LANG')
       ) X,
       (SELECT meaning
          FROM fnd_lookup_values flv
         WHERE lookup_type = 'XXCALV SEM TIEMPO TRAB'
           AND lookup_code = '002'
           AND LANGUAGE = userenv('LANG')
       ) F,
       (SELECT meaning
          FROM fnd_lookup_values flv
         WHERE lookup_type = 'XXCALV SEM TIEMPO TRAB'
           AND lookup_code = '003'
           AND LANGUAGE = userenv('LANG')
       ) V,
       (SELECT meaning
          FROM fnd_lookup_values flv
         WHERE lookup_type = 'XXCALV SEM TIEMPO TRAB'
           AND lookup_code = '004'
           AND LANGUAGE = userenv('LANG')
       ) B,
       (SELECT meaning
          FROM fnd_lookup_values flv
         WHERE lookup_type = 'XXCALV SEM TIEMPO TRAB'
           AND lookup_code = '005'
           AND LANGUAGE = userenv('LANG')
       ) I,
       (SELECT meaning
          FROM fnd_lookup_values flv
         WHERE lookup_type = 'XXCALV SEM TIEMPO TRAB'
           AND lookup_code = '006'
           AND LANGUAGE = userenv('LANG')
       ) DF,
       (SELECT meaning
          FROM fnd_lookup_values flv
         WHERE lookup_type = 'XXCALV SEM TIEMPO TRAB'
           AND lookup_code = '007'
           AND LANGUAGE = userenv('LANG')
       ) D,
       (SELECT meaning
          FROM fnd_lookup_values flv
         WHERE lookup_type = 'XXCALV SEM TIEMPO TRAB'
           AND lookup_code = '008'
           AND LANGUAGE = userenv('LANG')
       ) S,
       (SELECT meaning
          FROM fnd_lookup_values flv
         WHERE lookup_type = 'XXCALV SEM TIEMPO TRAB'
           AND lookup_code = '009'
           AND LANGUAGE = userenv('LANG')
       ) P,
       (SELECT meaning
          FROM fnd_lookup_values flv
         WHERE lookup_type = 'XXCALV SEM TIEMPO TRAB'
           AND lookup_code = '010'
           AND LANGUAGE = userenv('LANG')
       ) IR
  FROM 
       per_time_period_types tpt,
       per_time_period_types_tl tpttl,
       per_time_periods tpe,
       hr_lookups hl,
       fnd_lookup_values cmp,
       xxcalv_hr_pay_employees_v hpev
 WHERE 1=1
   AND tpttl.LANGUAGE = userenv ('LANG')
   AND tpt.period_type = hpev.period_type
   AND tpt.period_type = tpttl.period_type
   AND hpev.payroll_id = tpe.payroll_id
   AND hl.lookup_code = tpe.status
   AND hl.lookup_type = 'PROCESSING_PERIOD_STATUS'
   AND hpev.PAYROLL_ID = :p_payroll_id
   AND tpe.period_name = :p_period_name
   AND cmp.lookup_type = 'NOMINAS POR EMPLEADOR LEGAL'
   AND cmp.lookup_code = substr(hpev.payroll_name,1,2)
   AND cmp.LANGUAGE = userenv('LANG')
   AND hpev.organization_id = nvl(:p_organization_id, hpev.organization_id)
 ORDER BY to_number(hpev.employee_number) ASC;