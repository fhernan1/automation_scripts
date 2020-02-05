#!/usr/bin/env python3
import fileinput


def keyWordCheck():
    with fileinput.FileInput('mappingRules.sql', inplace=True, backup='.bak') as file:
        for line in file:
            print(line.replace("'CURRENT DATE'","CURRENT DATE"), end='')

    with fileinput.FileInput('mappingRules.sql', inplace=True, backup='.bak') as file:
        for line in file:
            print(line.replace("'CURRENT_DATE'","CURRENT DATE"), end='')
    with fileinput.FileInput('mappingRules.sql', inplace=True, backup='.bak') as file:
        for line in file:
            print(line.replace("'CURRENT_TIMESTAMP'", "CURRENT TIMESTAMP"), end='')
    with fileinput.FileInput('mappingRules.sql', inplace=True, backup='.bak') as file:
        for line in file:
            print(line.replace("'CURRENT TIMESTAMP'", "CURRENT TIMESTAMP"), end='')
    with fileinput.FileInput('mappingRules.sql', inplace=True, backup='.bak') as file:
        for line in file:
            print(line.replace("'CURRENT TIME'", "CURRENT TIME"), end='')
if __name__ == '__main__':
    keyWordCheck()
