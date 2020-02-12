#!/bin/ksh93

#####################################################################
#      Author          : Francisco Hernandez
#      Company Name    : BCBST
#      Date written    : 02/11/2020
#      Description     : Multi-Use tool for any mapping/rule inserts in TDSN
#                        Executes all command files created by this prg
#####################################################################
echo ${USR} | tr '[:lower:]' '[:upper:]' | read USRUPPER
grep UDBUSERID /home/${USR}/app_sec/${USRUPPER}.DWH.DB2|sed 's/export UDBUSERID=//' |read UDBUSERID
grep UDBPASS /home/${USR}/app_sec/${USRUPPER}.DWH.DB2|sed 's/export UDBPASS=//' |read UDBPASS
echo "Connecting to $TDSN_DB Database"
db2 connect to $TDSN_DB user $UDBUSERID using $UDBPASS

CMD_FILE1=${TGT_TABLE}_createtbl_cmd
CMD_FILE2=${TGT_TABLE}_insert_cmd
CMD_FILE3=${TGT_TABLE}_mrgcommon_cmd

cat "$CMD_FILE1"
echo ">>> Creating Table"
     db2 -txf "$CMD_FILE1"
     EXIT_CODE=$?
     if [ "$EXIT_CODE" -ne 0 ]; then
      echo ">>> Table Creation Failed!  Return Code = $EXIT_CODE"
    else
     # cat "$CMD_FILE2"
      echo ">>>Table Created! Running Insert."
      db2 -txf "$CMD_FILE2"
      EXIT_CODE=$?
      if [ "$EXIT_CODE" -ne 0 ]; then
       echo ">>> Inserts failed, check cmd file for errors."
      else
      cat "$CMD_FILE3"
     echo ">>> Running merge"
     db2 -txf "$CMD_FILE3"
     EXIT_CODE=$?
     if [ "$EXIT_CODE" -ne 0 ]; then
      echo ">>> Merge failed!  Return Code = $EXIT_CODE"
      echo "Check key Columns in PREP file and drop temp table before restarting"
    else
      echo ">>>Merge Succeded."
      db2 DROP TABLE ${SRC_TABLE}
      echo "Done."
    fi
      fi
    fi
date
exit $EXIT_CODE
