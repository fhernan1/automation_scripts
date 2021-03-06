#!/usr/bin/env python3
#####################################################################
#      Author          : Francisco Hernandez
#      Company Name    : BCBST
#      Date written    : 02/11/2020
#      Description     : Multi-Use tool for any mapping/rule inserts in TDSN
#                        Creates the Insert Statements from CSV
#####################################################################
import csv
import string
import keyWordCheck
import os

fileName = os.environ['TGT_TABLE']

def insert_fromCSV():
    insertState = "INSERT INTO "
    valState = "VALUES ("
    schemaName = os.environ['SRC_TABLE']
#    schemaName = input("Enter Schema ")
    a = []
    newFile =  open(f"{fileName}_insert_cmd", 'w')
    colHeader =  open('colHeaders.txt', 'w')

    with open('some_1.csv') as colFile:
        reader = csv.reader(colFile)
        a = next(reader)#Captures the HEADER for insert statement
        b = str(",".join(a))
        print(b, file = colHeader)
#    print(b) for testing

    with open('some_1.csv', newline='') as f:
        reader = csv.reader(f)
        next(reader)#This skips the HEADER for values
        for row in reader:
            c = str(row).strip('[]')
      #  statement = (insertState, schemaName,' (', b,' )', valState, c,SYS_LST_TRX_DT, SYS_LST_TRX_OP_NO, SYS_LST_TRX_TM, ');')
            statement = (insertState, schemaName,' (', b,' )', valState, c, ');')
            print(*statement,  file =  newFile)
    newFile.close

if __name__ == '__main__':
    insert_fromCSV()
    keyWordCheck.keyWordCheck()
