#!/bin/bash
echo "$1"
echo "$2"
FNDLOAD apps/apps 0 Y DOWNLOAD $FND_TOP/patch/115/import/afcpprog.lct $2.ldt PROGRAM APPLICATION_SHORT_NAME="$1" CONCURRENT_PROGRAM_NAME="$2"