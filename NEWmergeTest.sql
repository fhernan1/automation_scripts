--whoami=userID as schema for temp table
--HEADER=first line in CSV
--PASTED= user inputs schema and target table

CREATE TABLE `whoami`.FW_TEMP
	AS
		(SELECT 'HEADER'
			FROM 'PASTED') WITH NO DATA;
exit code
INSERT INTO `whoami`.FW_TEMP
	('HEADER')
	VALUES
	(''''''''''');
exit code (Handle duplicates in file)

MERGE INTO 'PASTED' c
   USING `whoami`.FW_TEMP e
   ON c.key1=e.key1 AND c.key2=e.key2 AND c.key3=e.key3
WHEN NOT MATCHED THEN 
     INSERT
        (c.HEADER1,...)
     VALUES
        (e.HEADER1,...)
WHEN MATCHED THEN UPDATE
       SET c.HEADER1 = e.HEADER1,
           c.HEADER2 = e.HEADER2,
		--and so on
 ;
