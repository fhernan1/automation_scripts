#!/bin/ksh93
#####################################################################
#      Author          : Francisco Hernandez
#      Company Name    : BCBST
#      Date written    : 02/11/2020
#      Description     : Multi-Use tool for any mapping/rule inserts in TDSN
#                        Creates the "CREATE TABLE" command file
#####################################################################

echo "CREATE TABLE ${SRC_TABLE} AS (SELECT * FROM ${TGT_TABLE}) WITH NO DATA;" > ${TGT_TABLE}_createtbl_cmd
