--USERID=userID as schema for temp table
--HEADER=first line in CSV
--SCHEMATAB= user inputs schema and target table
CREATE TABLE ${USERID}.FW_TEMP AS (
SELECT
	${HEADER}
FROM
	${SCHEMATAB}) WITH NO DATA;

--EXIT code
INSERT
	INTO
	`whoami`.FW_TEMP ('HEADER')
VALUES ('','','','','');
--exit code (Handle duplicates in file)

MERGE INTO ${SCHEMATAB} tgt
	USING ${USERID}.FW_TEMP src ON
src.key1 = tgt.key1
AND src.key2 = tgt.key2
AND src.key3 = tgt.key3
WHEN NOT MATCHED THEN
INSERT
	(HEADER1,
	...)
VALUES (src.HEADER1,
...)
WHEN MATCHED THEN
UPDATE
SET
	tgt.HEADER1 = src.HEADER1,
	tgt.HEADER2 = src.HEADER2,
	--and so on
;
--exit code into if statement
DROP TABLE ${USERID}.FW_TEMP
