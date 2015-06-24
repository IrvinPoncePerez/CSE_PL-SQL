
SELECT  decode(comp.empresa,:p_empresa,comp.empresa,'TODAS' ) empresa,
        decode(comp.nomina,:p_nomina, comp.nomina,'TODAS' ) nomina,
        DECODE(comp.periodo,:p_periodo,comp.periodo,'TODOS' )  periodo, 
        decode(comp.anos,:p_anos,comp.anos,'TODAS' ) año,
        decode(comp.mes,:p_mes,comp.mes,'TODAS' ) mes,
       comp.n_area, 
       comp.area desc_area, 
       comp.n_gerencia, 
       comp.gerencia desc_gerencia,
       comp.num_departamento, 
       comp.departamento desc_departamento, 
       comp.planta CB_Autorizado, 
       comp.fte CB_Permanente, 
       round(prom_planta,2) CB_Real_P,
       comp.eventual CB_Eventual, 
       round(prom_eventual,2) Eventuales_Promedio, 
       comp.percepciones Costo_Nomina,
       comp.despensa Costo_Bonos,
       comp.d_organization_idd, 
       comp.n_periodo, 
       upper(comp.juego_consolidacion)
  FROM (SELECT   an.planta, 
                 an.eventual, 
                 an.empresa, 
                 an.nomina, 
                 an.periodo,
                 an.n_area, 
                 an.area, 
                 an.n_gerencia, 
                 an.gerencia,
                 an.num_departamento, 
                 an.departamento, 
                 an.d_organization_idd,
                 an.fte, 
                 an.anos, 
                 an.n_periodo, 
                 an.mes,
                 an.juego_consolidacion, 
                 an.percepciones, 
                 an.despensa
            FROM (SELECT   SUM (CASE
                                   WHEN t_contrato = 'PLANTA'
                                      THEN 1
                                   ELSE 0
                                END
                               ) planta,
                           SUM (CASE
                                   WHEN t_contrato = 'EVENTUAL'
                                      THEN 1
                                   ELSE 0
                                END
                               ) eventual,
                           empresa, 
                           nomina, 
                           periodo, 
                           n_area, 
                           area, 
                           n_gerencia,
                           gerencia, 
                           num_departamento, 
                           departamento,
                           d_organization_idd, 
                           estatus, 
                           SUM (fte) fte,
                           COUNT (availability_status_desc), 
                           anos, 
                           n_periodo,
                           mes, 
                           juego_consolidacion,
                           SUM (t_percepciones) percepciones,
                           SUM (t_despensa) despensa
                      FROM (SELECT empresa, 
                                   nomina, 
                                   periodo, 
                                   t_contrato,
                                   n_area, 
                                   area, 
                                   n_gerencia, 
                                   gerencia,
                                   num_departamento, 
                                   departamento, 
                                   estatus,
                                   d_organization_idd, 
                                   puesto, 
                                   fte,
                                   availability_status_desc, 
                                   anos, 
                                   n_periodo,
                                   mes, 
                                   juego_consolidacion, 
                                   t_percepciones,
                                   t_despensa
                              FROM pac_departamento_pbono_v
                             WHERE availability_status_desc = 'Active'
                               AND estatus = 'EMPLOYEE')
                     WHERE availability_status_desc = 'Active'
                       AND estatus = 'EMPLOYEE'
                       AND mes = :p_mes
                       AND anos = :p_anos
                  GROUP BY empresa,
                           nomina,
                           periodo,
                           n_area,
                           estatus,
                           area,
                           n_gerencia,
                           gerencia,
                           num_departamento,
                           departamento,
                           d_organization_idd,
                           anos,
                           n_periodo,
                           mes,
                           juego_consolidacion
                  ORDER BY d_organization_idd) an,
                 (SELECT   MAX (n_periodo) perio, 
                           empresa, 
                           nomina, 
                           n_area,
                           area, 
                           n_gerencia, 
                           gerencia, 
                           d_organization_idd,
                           periodo, 
                           mes, 
                           anos
                      FROM pac_emp_cb_v
                     WHERE 1 = 1 AND mes = :p_mes AND anos = :p_anos
                  GROUP BY empresa,
                           nomina,
                           n_area,
                           periodo,
                           area,
                           n_gerencia,
                           gerencia,
                           num_departamento,
                           departamento,
                           d_organization_idd,
                           mes,
                           anos
                  ORDER BY d_organization_idd) ba
           WHERE 1 = 1
             AND an.n_periodo = ba.perio
             AND an.mes = ba.mes
             AND an.anos = ba.anos
             AND an.d_organization_idd = ba.d_organization_idd
             AND an.empresa = ba.empresa
             AND an.nomina = ba.nomina
             AND an.n_area = ba.n_area
             AND an.area = ba.area
             AND an.n_gerencia = ba.n_gerencia
             AND an.gerencia = ba.gerencia
        ORDER BY an.d_organization_idd ASC) comp,
       (SELECT   (  (  SUM (sem_planta)
                     / (pac_hr_pay_pkg.get_number_consecutive_periods (mes,
                                                                       anos
                                                                      )
                       )
                    )
                  + ((SUM (quin_planta)) / 2)
                 ) prom_planta,
                 (  (  SUM (sem_eventual)
                     / (pac_hr_pay_pkg.get_number_consecutive_periods (mes,
                                                                       anos
                                                                      )
                       )
                    )
                  + ((SUM (quin_eventual)) / 2)
                 ) prom_eventual,
                 empresa, 
                 nomina, 
                 n_area, 
                 area, 
                 n_gerencia, 
                 gerencia,
                 d_organization_idd, 
                 anos, 
                 mes
            FROM (SELECT   SUM (CASE
                                   WHEN periodo = 'SEMANAL'
                                   AND t_contrato = 'PLANTA'
                                      THEN 1
                                   ELSE 0
                                END
                               ) sem_planta,
                           SUM (CASE
                                   WHEN periodo = 'QUINCENAL'
                                   AND t_contrato = 'PLANTA'
                                      THEN 1
                                   ELSE 0
                                END
                               ) quin_planta,
                           SUM (CASE
                                   WHEN periodo = 'SEMANAL'
                                   AND t_contrato = 'EVENTUAL'
                                      THEN 1
                                   ELSE 0
                                END
                               ) sem_eventual,
                           SUM (CASE
                                   WHEN periodo = 'QUINCENAL'
                                   AND t_contrato = 'EVENTUAL'
                                      THEN 1
                                   ELSE 0
                                END
                               ) quin_eventual,
                           empresa, 
                           nomina, 
                           periodo, 
                           n_area, 
                           area, 
                           n_gerencia,
                           gerencia, 
                           num_departamento, 
                           departamento,
                           d_organization_idd, 
                           anos, 
                           n_periodo, 
                           mes
                      FROM (SELECT empresa, 
                                   nomina, 
                                   periodo, 
                                   t_contrato,
                                   n_area, 
                                   area, 
                                   n_gerencia, 
                                   gerencia,
                                   num_departamento, 
                                   departamento, 
                                   estatus,
                                   d_organization_idd, 
                                   puesto, 
                                   fte,
                                   availability_status_desc, 
                                   anos, 
                                   n_periodo,
                                   mes
                              FROM pac_emp_cb_v
                             WHERE availability_status_desc = 'Active'
                               AND estatus = 'EMPLOYEE')
                     WHERE availability_status_desc = 'Active'
                       AND estatus = 'EMPLOYEE'
                       AND mes = :p_mes
                       AND anos = :p_anos
                  GROUP BY empresa,
                           nomina,
                           periodo,
                           n_area,
                           estatus,
                           area,
                           n_gerencia,
                           gerencia,
                           num_departamento,
                           departamento,
                           d_organization_idd,
                           anos,
                           n_periodo,
                           mes
                  ORDER BY d_organization_idd)
        GROUP BY empresa,
                 nomina,
                 n_area,
                 area,
                 n_gerencia,
                 gerencia,
                 d_organization_idd,
                 anos,
                 mes
        ORDER BY d_organization_idd) rel
 WHERE 1 = 1
   AND comp.empresa = rel.empresa
   AND comp.nomina = rel.nomina
   AND comp.n_area = rel.n_area
   AND comp.area = rel.area
   AND comp.n_gerencia = rel.n_gerencia
   AND comp.gerencia = rel.gerencia
   AND comp.d_organization_idd = rel.d_organization_idd
   AND comp.anos = rel.anos
   AND comp.mes = rel.mes
   AND comp.empresa = NVL (:p_empresa,comp.empresa)
   and comp.juego_consolidacion = NVL (:p_juego_consolidacion,comp.juego_consolidacion)
   AND comp.periodo = NVL (:p_periodo,comp.periodo)
   order by  comp.empresa asc,comp.nomina asc,comp.d_organization_idd asc
   
   
  