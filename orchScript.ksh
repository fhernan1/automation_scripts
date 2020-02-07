#!/bin/ksh93
USR=`whoami`
myPath=/datawhse/work/${USR}/MapRuleUpdate
TDSN_DB=TDSN

export SRC_TABLE
export TGT_TABLE
export KEY_COLUMNS
export TDSN_DB


${myPath}/csvRuleUpdate_1.py
${myPath}/csvRuleUpdate_2.ksh
${myPath}/csvRuleUpdate_3.ksh
${myPath}/csvRuleUpdate_4.ksh
