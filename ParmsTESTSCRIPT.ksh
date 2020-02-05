#!/bin/ksh93
#
#################################################################
#
# This script will prompt for a dsjob and project to compare
#  parameters against the job listed in datastage.
#
#
##################################################################
#
# Author: Francisco Hernandez
#   Date: 2019-12-17
#
##################################################################
#sed '/As pre-defined/d' fileTosplit.txt_test > newFileToSplit.txt
echo 'Enter job Name'; read JOB_NME
echo 'Enter etl name'; read ETL_NME
echo 'Enter project name'; read PROJ_NME
echo 'Enter Batch Configuration ID'; read batch_cfg
echo 'Enter Event Number'; read EVNT_NO




JOB_NAME="'$JOB_NME',"
ETL_JOB_NME="'$ETL_NME',"
CURRENT_TIMESTAMP="CURRENT TIMESTAMP,"
BATCH_CFG_ID="'$batch_cfg',"
USER_ID="'`whoami`'"
USR_ID=`whoami`
VALID_RULE=",'Y'"
OUT_PATH=/datawhse/work/
FINOUTFILE=${USR_ID}.${JOB_NME}.${batch_cfg}.sql
touch ${FINOUTFILE}
OUT_FILE=${USR_ID}.${JOB_NME}.${batch_cfg}.pre.sql
touch ${OUT_FILE}
OUT_FILE2=${USR_ID}.${JOB_NME}.${batch_cfg}.JOBCTRL.sql
touch ${OUT_FILE2}



###################################################
#ParmValueInsert
###################################################
ParmValueInsert="INSERT INTO TPGMCTL.SYSTEM_JOB_PARAMETER_VALUE (JOB_NME,
        ETL_JOB_NME,
        PARM_NME,
        BATCH_CFG_ID,
        PARM_VAL,
        SYS_LOAD_DTM,
        SYS_UPDT_DTM,
        SYS_UPDT_BY,
    PARM_ACTV_FLG)
VALUES"

JobControlInsert="INSERT INTO TPGMCTL.SYSTEM_JOB_CONTROL (JOB_NME, BATCH_CFG_ID, JOB_DESC, SYS_LOAD_DTM, SYS_UPDT_DTM, SYS_UPDT_BY) VALUES"
############################################
### Gets parameter file and log file
############################################
BIN_PATH=/opt/IBM/InformationServer/Server/DSEngine/bin
#${BIN_PATH}/dsjob -lparams ecw_dev_dwh1 YW302X01PRG1 | sort | sed '/APT_CONFIG/d' > /datawhse/work/f16802h/dsparams.DATASTAGE #gets params from DSJOB
${BIN_PATH}/dsjob -lparams ${PROJ_NME} ${ETL_NME} | sort | sed '/APT_CONFIG/d' > /datawhse/work/$USR_ID/dsparams.DATASTAGE #gets params from DSJOB

#${BIN_PATH}/dsjob -logdetail ecw_dev_dwh1 YW302X01PRG1 3672 | sort | sed '/APT_CONFIG/d' > /datawhse/work/f16802h/dsparamlogs.DATASTAGE #gets paramvalues from DSLog
${BIN_PATH}/dsjob -logdetail ${PROJ_NME} ${ETL_NME} ${EVNT_NO} | sort | sed '/APT_CONFIG/d' > /datawhse/work/$USR_ID/dsparamlogs.DATASTAGE #gets paramvalues from DSLog


###################################
##File clean up
###################################

awk 'FNR==NR{a[$1];next}($1 in a){print}' dsparams.DATASTAGE dsparamlogs.DATASTAGE > fileTosplit.txt #Will match Log to Params i.e. removes uneccessary entries
sed '/As pre-defined/d' fileTosplit.txt > newFileToSplit.txt #leaves file with only params that matter i.e. now parent name params like BalTarget

################################################
#Splits files into ParmName and ParmValues
################################################
awk '{print $1}' newFileToSplit.txt > dsparamnames.DATASTAGE #PARM_NME
awk '{print $3}' newFileToSplit.txt > dsparamvalues.DATASTAGE #PARM_VAL
sed -e "s/\(.*\)/'\1'/" dsparamvalues.DATASTAGE > dsparamvalues.dat #Wraps all entries in a single quote to avoid special character execution when cat into array

##############################################
# Imports PARM_NME and PARM_VAL as arrays
##############################################
typeset -a parmnamesArray=($(cat dsparamnames.DATASTAGE))
#typeset -a parmvaluesArray=($(cat dsparamvalues.DATASTAGE))
typeset -a parmvaluesArray=($(cat dsparamvalues.dat))

###################################################
#This will recombine the arrays in desired insert statement
###################################################
#unset result
for (( i=0; i<${#parmnamesArray[*]}; ++i))
do

    case ${parmnamesArray[$i]} in

        Bal*.*CaptureTable)
              PARM_VAL="'\${BAL_CPTRE_TBL}'"
              ;;
        Bal*.*MessageRefTable)
              PARM_VAL="'\${BAL_MSG_REF_TBL}'"
              ;;
        Bal*.*RefTable)
              PARM_VAL="'\${BAL_XREF_TBL}'"
              ;;
        Bal*.*Password)
              PARM_VAL="'\${BALPASS}'"
              ;;
        Bal*.*UserID)
              PARM_VAL="'\${BALUSERID}'"
              ;;
        Bal*.*Schema)
              PARM_VAL="'\${BALSCHEMA}'"
              ;;
        Bal*.*Database)
              PARM_VAL="'\${BALSERVER}'"
              ;;
        Bal*.BatchConfigID)
              PARM_VAL="'\${BATCH_CONFIG}'"
              ;;
        ECW*.*Database)
              PARM_VAL="'\${WAREHOUSE_DB}'"
              ;;
        ECW*.*UserID)
              PARM_VAL="'\${ECWUSERID}'"
              ;;
        ECW*.*Password)
              PARM_VAL="'\${ECWPASS}'"
              ;;
        DB2*.*UserID)
              PARM_VAL="'\${DB2USERID}'"
              ;;
        DB2*.*Password)
              PARM_VAL="'\${DB2PASS}'"
              ;;
        CBDW*.*UserID)
              PARM_VAL="'\${UDBUSERID}'"
              ;;
        CBDW*.*Password)
              PARM_VAL="'\${UDBPASS}'"
              ;;
        Facets*.*UserID)
              PARM_VAL="'\${SYBUSERID}'"
              ;;
        Facets*.*Password)
              PARM_VAL="'\${SYBPASS}'"
              ;;
        SQL*.*UserID)
              PARM_VAL="'\${WINSQLUSERID}'"
              ;;
        SQL*.*Password)
              PARM_VAL="'\${WINSQLPASS}'"
              ;;
        *.TargetUpdatedBy)
              PARM_VAL="'\${SCHED_JOB_NAME}'"
              ;;
        *)
              PARM_VAL=${parmvaluesArray[$i]}
              ;;
      esac
        echo "$ParmValueInsert ($JOB_NAME $ETL_JOB_NME '${parmnamesArray[$i]}', $BATCH_CFG_ID $PARM_VAL, $CURRENT_TIMESTAMP $CURRENT_TIMESTAMP $USER_ID $VALID_RULE);" >> $OUT_FILE
done

echo 'Do you need a Job control Statement? Y or N'; read JOB_CTRL_QUEST
if [ "$JOB_CTRL_QUEST" == "Y" ] || [ "$JOB_CTRL_QUEST" == "y" ]
        then
        echo "Enter job description:           \c" ; read JOB_DESC
fi
Job_Desc="'"$JOB_DESC"',"
#####################################################################################################################
typeset -A JobControlArray
JobControlArray[0]=("($JOB_NAME $BATCH_CFG_ID   $Job_Desc $CURRENT_TIMESTAMP $CURRENT_TIMESTAMP $USER_ID);")
#####################################################################################################################

if [ "$JOB_CTRL_QUEST" == "Y" ] || [ "$JOB_CTRL_QUEST" == "y" ]
        then
        echo "$JobControlInsert ${JobControlArray[0]}" >> $OUT_FILE2
fi




sleep 1
sed 's/),/ ),|/g' $OUT_FILE | tr '|' '\n' > $FINOUTFILE
sleep 1
rm $OUT_FILE dsparams.DATASTAGE newFileToSplit.txt fileTosplit.txt dsparamvalues.DATASTAGE dsparamnames.DATASTAGE dsparamlogs.DATASTAGE dsparamvalues.dat

echo
echo "-------------------------------------------------------"
echo
echo "Insert statements have been written to $FINOUTFILE"
echo "and $OUT_FILE2"
echo
echo
echo "To execute connect to ECWDEV with the following commands"
echo "db2 CONNECT TO ECWDEV USER `whoami`"
echo "db2 -vtf $FINOUTFILE"
echo "db2 -vtf $OUT_FILE2"
echo
echo "-------------------------------------------------------"
echo
