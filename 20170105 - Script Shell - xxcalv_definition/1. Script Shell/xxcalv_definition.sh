#!/bin/bash
var1=$1
var2=$2
var3=$3
var4=$4
if [ $var1 = DOWNLOAD ]; then
	echo "Descarga."
	if [ $var2 = FND_RESPONSIBILITY ]; then
		echo "Descargando definicion de "$var2
		FNDLOAD apps/apps 0 Y $var1 $FND_TOP/patch/115/import/afscursp.lct $var2"_"$var3.ldt $var2 RESP_KEY=$var3
		echo "Archivo "$var2"_"$var3".ldt Creado."
	fi
	if [ $var2 = VALUE_SET ]; then
		echo "Descargando definicion de "$var2
		FNDLOAD apps/apps 0 Y $var1 $FND_TOP/patch/115/import/afffload.lct $var2"_"$var3.ldt $var2 FLEX_VALUE_SET_NAME=$var3
		echo "Archivo "$var2"_"$var3".ldt Creado."
	fi
	if [ $var2 = MENU ]; then
		echo "Descargando definicion de "$var2
		FNDLOAD apps/apps 0 Y $var1 $FND_TOP/patch/115/import/afsload.lct $var2"_"$var3.ldt $var2 MENU_NAME=$var3
		echo "Archivo "$var2"_"$var3".ldt Creado."	
	fi
	if [ $var2 = FORM ]; then
		echo "Descargando definicion de "$var2
		FNDLOAD apps/apps 0 Y $var1 $FND_TOP/patch/115/import/afsload.lct $var2"_"$var3.ldt $var2 FORM_NAME=$var3
		echo "Archivo "$var2"_"$var3".ldt Creado."	
	fi
	if [ $var2 = FUNCTION ]; then
		echo "Descargando definicion de "$var2
		FNDLOAD apps/apps 0 Y $var1 $FND_TOP/patch/115/import/afsload.lct $var2"_"$var3.ldt $var2 FUNCTION_NAME=$var3
		echo "Archivo "$var2"_"$var3".ldt Creado."			
	fi
	if [ $var2 = PROGRAM ]; then
		echo "Descargando definicion de "$var2
		FNDLOAD apps/apps 0 Y $var1 $FND_TOP/patch/115/import/afcpprog.lct $var2"_"$var3.ldt $var2 APPLICATION_SHORT_NAME=$var4 CONCURRENT_PROGRAM_NAME=$var3
		echo "Archivo "$var2"_"$var3".ldt Creado."			
	fi
	if [ $var2 = FND_LOOKUP_TYPE ]; then
		echo "Descargando definicion de "$var2
		FNDLOAD apps/apps 0 Y $var1 $FND_TOP/patch/115/import/aflvmlu.lct $var2"_"$var3.ldt $var2 APPLICATION_SHORT_NAME=$var4 LOOKUP_TYPE=$var3
		echo "Archivo "$var2"_"$var3".ldt Creado."			
	fi
	if [ $var2 = REQUEST_GROUP ]; then
		echo "Descargando definicion de "$var2
		FNDLOAD apps/apps 0 Y $var1 $FND_TOP/patch/115/import/afcpreqg.lct $var2"_"$var3.ldt $var2 REQUEST_GROUP_NAME=$var3
		echo "Archivo "$var2"_"$var3".ldt Creado."			
	fi
	if [ $var2 = REQ_SET ]; then
		echo "Descargando definicion de "$var2
		FNDLOAD apps/apps 0 Y $var1 $FND_TOP/patch/115/import/afcprset.lct $var2"_"$var3.ldt $var2 APPLICATION_SHORT_NAME=$var4 REQUEST_SET_NAME=$var3
		echo "Archivo "$var2"_"$var3".ldt Creado."			
	fi
	if [ $var2 = XDO_DS_DEFINITIONS ]; then
		echo "Descargando definicion de "$var2
		FNDLOAD apps/apps 0 Y $var1 $XDO_TOP/patch/115/import/xdotmpl.lct $var2"_"$var3.ldt $var2 APPLICATION_SHORT_NAME=$var4 DATA_SOURCE_CODE=$var3
		echo "Archivo "$var2"_"$var3".ldt Creado."			
	fi
else
	if [ $var1 = UPLOAD ]; then
		echo "Carga."
		if [ $var2 = FND_RESPONSIBILITY ]; then
			echo "Cargando definicion de "$var2" en "$var3
			FNDLOAD apps/apps 0 Y $var1 $
		fi
		if [ $var2 = VALUE_SET ]; then
			echo "Cargando definicion de "$var2" en "$var3
			FNDLOAD apps/apps 0 Y $var1 $
		fi
		if [ $var2 = MENU ]; then
			echo "Cargando definicion de "$var2" en "$var3
			FNDLOAD apps/apps 0 Y $var1 $FND_TOP/patch/115/import/afffload.lct $var3.ldt
		fi
		if [ $var2 = FORM ]; then
			echo "Cargando definicion de "$var2" en "$var3
			FNDLOAD apps/apps 0 Y $var1 $FND_TOP/patch/115/import/afsload.lct $var3.ldt
		fi
		if [ $var2 = FUNCTION ]; then
			echo "Cargando definicion de "$var2" en "$var3
			FNDLOAD apps/apps 0 Y $var1 $
		fi
		if [ $var2 = PROGRAM ]; then
			echo "Cargando definicion de "$var2" en "$var3
			FNDLOAD apps/apps 0 Y $var1 $FND_TOP/patch/115/import/afcpprog.lct $
		fi
		if [ $var2 = FND_LOOKUP_TYPE ]; then
			echo "Cargando definicion de "$var2" en "$var3
			FNDLOAD apps/apps 0 Y $var1 $FND_TOP/patch/115/import/aflvmlu.lct $var3.ldt
		fi
		if [ $var2 = REQUEST_GROUP ]; then
			echo "Cargando definicion de "$var2" en "$var3
			FNDLOAD apps/apps 0 Y $var1 $
		fi
		if [ $var2 = REQ_SET ]; then
			echo "Cargando definicion de "$var2" en "$var3
			FNDLOAD apps/apps 0 Y $var1 $
		fi
		if [ $var2 = XDO_DS_DEFINITIONS ]; then
			echo "Cargando definicion de "$var2" en "$var3
			FNDLOAD apps/apps 0 Y $var1 $XDO_TOP/patch/115/import/xdotmpl.lct $var3.ldt
		fi
	fi
fi
echo "Terminado."