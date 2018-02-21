DECLARE
   a   BOOLEAN;
BEGIN
   a := fnd_profile.SAVE ('FND_EXPORT_MIME_TYPE'
                        , 'application/excel'
                        , 'SITE'
                        , NULL
                        , NULL
                        , NULL
                         );

   IF a
   THEN
      DBMS_OUTPUT.put_line ('Success');
      COMMIT;
   ELSE
      DBMS_OUTPUT.put_line ('Error');
   END IF;
END;