CREATE OR REPLACE PACKAGE APPS.PAC_EFT_PKG
AS
   FUNCTION extract_account_number (p_supplier_clabe_account IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION create_batch (p_bank_account_id NUMBER)
      RETURN NUMBER;

   PROCEDURE create_line (p_batch_id          NUMBER,
                          p_line_number       NUMBER,
                          p_invoice_id        NUMBER,
                          output_msg      OUT VARCHAR2);

   PROCEDURE remove_emp (employee_id NUMBER);

   PROCEDURE read_data_form;

   PROCEDURE create_export_layout (p_batch_id   IN     NUMBER,
                                   v_file          OUT VARCHAR2,
                                   output_msg      OUT VARCHAR2);

   --
   --   PROCEDURE increase_sal (employee_id NUMBER, salary_incr NUMBER);
   --
   --   PROCEDURE increase_comm (employee_id NUMBER, comm_incr NUMBER);

   no_comm   EXCEPTION;
   no_sal    EXCEPTION;
END PAC_EFT_PKG;
/
