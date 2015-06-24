 select     sum(pay_value) m_aport_mensual , 
            sum(total_owed) m_saldo_i,
            sum(saldo_pagado) 
            m_saldo_p, 
            sum(saldo_restante) m_saldo_r
            from (SELECT   assignment_id, 
                           folio, 
                           no_credito, 
                           pay_value, 
                           total_owed,
                           saldo_pagado, 
                           saldo_restante, 
                           MAX (payroll_run_date)
            FROM pac_fonacot
           WHERE mes = decode (LENGTH(:p_mes),'2',:p_mes,('0'||''||:p_mes)) 
                 AND ano = :p_ano
        GROUP BY assignment_id,
                 folio,
                 no_credito,
                 pay_value,
                 total_owed,
                 saldo_pagado,
                 saldo_restante
        ORDER BY assignment_id)