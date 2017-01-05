#!/bin/bash
echo "$1"
FNDLOAD apps/apps 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct $1.ldt -WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE