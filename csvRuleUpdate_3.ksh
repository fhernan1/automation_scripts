#!/bin/ksh93

myPath=/datawhse/work/f16802h/MapRuleUpdate
tr , '\n' < colHeaders.txt > colHeaders1.txt
COLS_TGT_COLS_FILE=${myPath}/colHeaders1.txt

grep UDBUSERID /home/f16802h/app_sec/F16802H.DWH.DB2|sed 's/export UDBUSERID=//' |read UDBUSERID
grep UDBPASS /home/f16802h/app_sec/F16802H.DWH.DB2|sed 's/export UDBPASS=//' |read UDBPASS
echo "Connecting to $TDSN_DB Database"
db2 connect to $TDSN_DB user $UDBUSERID using $UDBPASS

  set -eu
  SRC_SCHEMA="$(echo $SRC_TABLE|cut -d'.' -f1)"
  SRC_UQLTABLE="$(echo $SRC_TABLE|cut -d'.' -f2-)"
  TGT_SCHEMA="$(echo $TGT_TABLE|cut -d'.' -f1)"
  TGT_UQLTABLE="$(echo $TGT_TABLE|cut -d'.' -f2-)"

  echo "Source: ${SRC_SCHEMA}.${SRC_UQLTABLE}"
  echo "Target: ${TGT_SCHEMA}.${TGT_UQLTABLE}"
  echo "Keys: ${KEY_COLUMNS}"
  CMD_FILE="${myPath}/${TGT_TABLE}_mrgcommon_cmd"

  echo "cmd file: ${CMD_FILE}"
  sleep 1

     set -eu
     echo ">>> Generating command file"
     echo "merge into ${TGT_TABLE} tgt" > "$CMD_FILE"
     echo "using ${SRC_TABLE} src" >>"$CMD_FILE"
     echo "on (" >>"$CMD_FILE"
     JOIN_S=""
     for colname in $KEY_COLUMNS; do
        echo "${JOIN_S}src.${colname}=tgt.${colname}" >>"$CMD_FILE"
        JOIN_S=" and "
     done
     echo ")" >>"$CMD_FILE"
     echo "when matched then" >>"$CMD_FILE"
     echo "update set" >>"$CMD_FILE"
     JOIN_S=""
     for colname in $(cat "$COLS_TGT_COLS_FILE"); do
       printf "${JOIN_S}%s" "${colname}=src.${colname}" >>"$CMD_FILE"
       JOIN_S=",\n"
     done
     echo "" >>"$CMD_FILE"
     echo "when not matched then" >>"$CMD_FILE"
     echo "insert" >>"$CMD_FILE"
     echo "(" >>"$CMD_FILE"
     JOIN_S=""
     for colname in $(cat "$COLS_TGT_COLS_FILE"); do
       printf "${JOIN_S}%s" "${colname}" >>"$CMD_FILE"
       JOIN_S=",\n"
     done
     echo "" >>"$CMD_FILE"
     echo ")" >>"$CMD_FILE"
     echo "values" >>"$CMD_FILE"
     echo "(" >>"$CMD_FILE"
    JOIN_S=""
     for colname in $(cat "$COLS_TGT_COLS_FILE"); do
       printf "${JOIN_S}%s" "src.${colname}" >>"$CMD_FILE"
       JOIN_S=",\n"
     done
     echo "" >>"$CMD_FILE"
     echo ")" >>"$CMD_FILE"
     echo ";" >>"$CMD_FILE"
     echo ">>> Command Generation Complete:"
     cat "$CMD_FILE"
   #  rm "${COLS_SRC_COLS_FILE}"
   #  rm "${COLS_TGT_COLS_FILE}"
     set +eu
     echo ">>> Running merge"
     db2 -txf "$CMD_FILE"
     EXIT_CODE=$?
     if [ "$EXIT_CODE" -ne 0 ]; then
      echo ">>> Merge failed!  Return Code = $EXIT_CODE"
      echo "Check key Columns in PREP file and drop temp table before restarting"
    else
      echo ">>>Merge Succeded."
      echo "Done."
    fi
date
exit $EXIT_CODE
