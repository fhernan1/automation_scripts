#!/bin/ksh93

#colHeaders=$(cat "colHeaders.txt")

echo "CREATE TABLE ${SRC_TABLE} AS (SELECT * FROM ${TGT_TABLE}) WITH NO DATA;" > createTableCommand.sql

grep UDBUSERID /home/f16802h/app_sec/F16802H.DWH.DB2|sed 's/export UDBUSERID=//' |read UDBUSERID
grep UDBPASS /home/f16802h/app_sec/F16802H.DWH.DB2|sed 's/export UDBPASS=//' |read UDBPASS
echo "Connecting to $TDSN_DB Database"
db2 connect to $TDSN_DB user $UDBUSERID using $UDBPASS

CMD_FILE1=createTableCommand.sql
CMD_FILE2=mappingRules.sql
echo ">>> Creating Table"
     db2 -txf "$CMD_FILE1"
     EXIT_CODE=$?
     if [ "$EXIT_CODE" -ne 0 ]; then
      echo ">>> Table Creation Failed!  Return Code = $EXIT_CODE"
    else
      echo ">>>Table Created! Running Insert."
      db2 -txf "$CMD_FILE2"
      EXIT_CODE=$?
      if [ "$EXIT_CODE" -ne 0 ]; then
       echo ">>> Inserts failed, check cmd file for errors."
      else
      echo "Done."
      fi
    fi
date
exit $EXIT_CODE
