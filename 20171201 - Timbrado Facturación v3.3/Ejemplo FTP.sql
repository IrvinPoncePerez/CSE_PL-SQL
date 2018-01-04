CREATE OR REPLACE DIRECTORY CARGAS AS '/var/tmp/CARGAS';


-- Retrieve an ASCII file from a remote FTP server.
DECLARE
  l_conn  UTL_TCP.connection;
BEGIN
  l_conn := ftp.login('192.1.1.64', '21', 'ftpuser', 'Oracle123');
  ftp.ascii(p_conn => l_conn);
  ftp.get(p_conn      => l_conn,
          p_from_file => '/Calvario_Servicios/Descarga/2017/12/20171215_CFDI_CS_23_2017_Quincena_NORMAL/CSE941214C11_ZAGA820402DHA_CSUD_105468.xml',
          p_to_dir    => 'CARGAS',
          p_to_file   => '/var/tmp/CARGAS/CSE941214C11_ZAGA820402DHA_CSUD_105468.xml');
  ftp.logout(l_conn);
END;
/

-- Send an ASCII file to a remote FTP server.
DECLARE
  l_conn  UTL_TCP.connection;
BEGIN
  l_conn := ftp.login('192.1.1.64', '21', 'ftpuser', 'Oracle123');
  ftp.ascii(p_conn => l_conn);
  ftp.put(p_conn      => l_conn,
          p_from_dir  => 'CARGAS',
          p_from_file   => 'CSE941214C11_ZAGA820402DHA_CSUD_105468.xml',
          p_to_file => '/Calvario_Servicios/Descarga/2017/12/20171215_CFDI_CS_23_2017_Quincena_NORMAL/CSE941214C11_ZAGA820402DHA_CSUD_105468.xml'
          );
  ftp.logout(l_conn);
END;
/

-- Retrieve a binary file from a remote FTP server.
DECLARE
  l_conn  UTL_TCP.connection;
BEGIN
  l_conn := ftp.login('192.1.1.64', '21', 'ftpuser', 'Oracle123');
  ftp.binary(p_conn => l_conn);
  ftp.get(p_conn      => l_conn,
          p_from_file => '/Calvario_Servicios/Descarga/2017/12/20171215_CFDI_CS_23_2017_Quincena_NORMAL/CSE941214C11_ZAGA820402DHA_CSUD_105468.pdf',
          p_to_dir    => 'CARGAS',
          p_to_file   => '/var/tmp/CARGAS/CSE941214C11_ZAGA820402DHA_CSUD_105468.PDF');
  ftp.logout(l_conn);
END;
/

-- Send a binary file to a remote FTP server.
DECLARE
  l_conn  UTL_TCP.connection;
BEGIN
  l_conn := ftp.login('192.1.1.64', '21', 'ftpuser', 'Oracle123');
  ftp.binary(p_conn => l_conn);
  ftp.put(p_conn      => l_conn,
          p_from_dir  => 'CARGAS',
          p_from_file => 'CSE941214C11_ZAGA820402DHA_CSUD_105468.PDF',
          p_to_file   => '/Calvario_Servicios/Descarga/2017/12/20171215_CFDI_CS_23_2017_Quincena_NORMAL/CSE941214C11_ZAGA820402DHA_CSUD_105468.PDF');
  ftp.logout(l_conn);
END;
/

-- Get a directory listing from a remote FTP server.
DECLARE
  l_conn  UTL_TCP.connection;
  l_list  ftp.t_string_table;
BEGIN
  l_conn := ftp.login('192.1.1.119', '21', 'cfd', 'Facturacion01');
  ftp.list(p_conn   => l_conn,
           p_dir   => '/ERROR/',
           p_list  => l_list);
  ftp.logout(l_conn);
  
  IF l_list.COUNT > 0 THEN
    FOR i IN l_list.first .. l_list.last LOOP
      DBMS_OUTPUT.put_line(i || ': ' || l_list(i));
    END LOOP;
  END IF;
END;
/

-- Get a directory listing (file names only) from a remote FTP server.
DECLARE
  l_conn  UTL_TCP.connection;
  l_list  ftp.t_string_table;
BEGIN
  l_conn := ftp.login('192.1.1.119', '21', 'cfd', 'Facturacion01');
  ftp.nlst(p_conn   => l_conn,
           p_dir   => '/ERROR/',
           p_list  => l_list);
  ftp.logout(l_conn);
  
  IF l_list.COUNT > 0 THEN
    FOR i IN l_list.first .. l_list.last LOOP
      DBMS_OUTPUT.put_line(i || ': ' || l_list(i));
    END LOOP;
  END IF;
END;
/

-- Rename a file on a remote FTP server.
DECLARE
  l_conn  UTL_TCP.connection;
BEGIN
  l_conn := ftp.login('ftp.company.com', '21', 'ftpuser', 'ftppassword');
  ftp.rename(p_conn => l_conn,
             p_from => '/u01/app/oracle/dba/shutdown',
             p_to   => '/u01/app/oracle/dba/shutdown.old');
  ftp.logout(l_conn);
END;
/

-- Delete a file on a remote FTP server.
DECLARE
  l_conn  UTL_TCP.connection;
BEGIN
  l_conn := ftp.login('192.1.1.193', '21', 'developer', 'oracle');
  ftp.delete(p_conn => l_conn,
             p_file => '/var/tmp/CARGAS/ARCHIVO_PRUEBA2.TXT');
  ftp.logout(l_conn);
END;
/

-- Create a directory on a remote FTP server.
DECLARE
  l_conn  UTL_TCP.connection;
BEGIN
  l_conn := ftp.login('ftp.company.com', '21', 'ftpuser', 'ftppassword');
  ftp.mkdir(p_conn => l_conn,
            p_dir => '/u01/app/oracle/test');
  ftp.logout(l_conn);
END;
/

-- Remove a directory from a remote FTP server.
DECLARE
  l_conn  UTL_TCP.connection;
BEGIN
  l_conn := ftp.login('ftp.company.com', '21', 'ftpuser', 'ftppassword');
  ftp.rmdir(p_conn => l_conn,
            p_dir  => '/u01/app/oracle/test');
  ftp.logout(l_conn);
END;