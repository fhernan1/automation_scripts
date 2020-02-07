#!/bin/ksh93

grep UDBUSERID /home/f16802h/app_sec/F16802H.DWH.DB2|sed 's/export UDBUSERID=//' |read UDBUSERID
grep UDBPASS /home/f16802h/app_sec/F16802H.DWH.DB2|sed 's/export UDBPASS=//' |read UDBPASS
echo "Connecting to $TDSN_DB Database"
db2 connect to $TDSN_DB user $UDBUSERID using $UDBPASS

db2 DROP TABLE ${SRC_TABLE}
