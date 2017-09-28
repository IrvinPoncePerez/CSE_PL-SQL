CREATE OR REPLACE PACKAGE APPS.XXCALV_PAY_POLIZA_PKG IS
  /******************************************************************
   Program : Realiza la transferencia de poliza contable de empleados PAC.
   Author  : Javier Juarez Palma
             
   Date    : 12-08-2014
  *******************************************************************/
  --
  g_debug                        VARCHAR2(2000);
  --
  PROCEDURE Genera_Poliza
                  ( errbuf                     OUT NOCOPY VARCHAR2
                   ,retcode                    OUT NOCOPY NUMBER
                   ,p_payroll_id               IN         NUMBER
                   ,p_consolidation_id         IN         NUMBER
                   ,p_period_type              IN         VARCHAR2
                   ,p_start_date               IN         VARCHAR2
                   ,p_end_date                 IN         VARCHAR2
                   ,p_assignment_set_id        IN         NUMBER
                   ,p_final_mode               IN         VARCHAR2
                   ,p_je_source_name           IN         VARCHAR2
                   ,p_je_category_name         IN         VARCHAR2
                   ,p_gl_access_set_id         IN         NUMBER
                   );
    
   /****************************************************
    *   Función nueva:
    *   User : IPONCE
    *   Date : 2017.09.27
    ***************************************************/               
   FUNCTION GET_CONCATENED_SEGMENTS(
        P_COST_ALLOCATION_KEYFLEX_ID    NUMBER,
        P_COLUMN_NAME                   VARCHAR2)
    RETURN VARCHAR2;    
    
  --
END XXCALV_PAY_POLIZA_PKG;
/
