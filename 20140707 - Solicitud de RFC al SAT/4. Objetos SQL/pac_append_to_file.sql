CREATE OR REPLACE PROCEDURE APPS.pac_append_to_file (p_path varchar2, p_file_name varchar2, p_string varchar2) IS
    v_file utl_file.file_type;
    v_directory varchar2(250);
BEGIN
    
    v_file := utl_file.fopen(p_path, p_file_name, 'A',1201);
    utl_file.put_line(v_file, p_string);
    utl_file.fclose(v_file);

EXCEPTION WHEN others THEN
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Error inesperado. '||SQLERRM);
    dbms_output.put_line('Error inesperado. '||SQLERRM);
END;
/