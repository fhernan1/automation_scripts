#!/bin/ksh93
#####################################################################
#      Author          : Francisco Hernandez
#      Company Name    : BCBST
#      Date written    : 02/11/2020
#      Description     : Multi-Use tool for any mapping/rule inserts in TDSN
#                        Creates the "MERGE STATEMENT" command file
#####################################################################

myPath=/datawhse/work/${USR}/MapRuleUpdate
tr , '\n' < colHeaders.txt > colHeaders1.txt
COLS_TGT_COLS_FILE=${myPath}/colHeaders1.txt


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
