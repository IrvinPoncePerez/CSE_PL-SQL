#!/bin/bash
var1=$1
var2=$2
var3=$3
if [ $var1 = DOWNLOAD ]; then
	echo "Descargando definicion."
	if [ $var2 = FND_RESPONSIBILITY ]; then
		echo "Descargando Responsabilidad."
		FNDLOAD apps/apps 0 Y $var1 $FND_TOP/patch/115/import/afscursp.lct $var2"_"$var3.ldt $var2 RESP_KEY=$var3
		echo "Archivo "$var2"_"$var3".ldt Creado."
	fi
	if [ $var2 = VALUE_SET ]; then
		echo "Descargando Juego de Valores."
		FNDLOAD apps/apps 0 Y DOWNLOAD $FND_TOP/patch/115/import/afffload.lct $var2"_"$var3.ldt $var2 FLEX_VALUE_SET_NAME=$var3
		echo "Archivo "$var2"_"$var3".ldt Creado."
	fi
	if [ $var2 = MENU ]; then
		echo "Descargando Menu."
		FNDLOAD apps/apps 0 Y DOWNLOAD $FND_TOP/patch/115/import/afsload.lct $var2"_"$var3.ldt $var2 MENU_NAME=$var3
		echo "Archivo "$var2"_"$var3".ldt Creado."	
	fi
else
	if [ $var1 = UPLOAD ]; then
		echo "Uploading definition..."
		if [ $var2 = FND_RESPONSIBILITY ]; then
			echo "Cargando Responsabilidad."
			FNDLOAD apps/apps 0 Y UPLOAD $FND_TOP/patch/115/import/afscursp.lct $var3.ldt
		fi
		if [ $var2 = VALUE_SET ]; then
			echo "Cargando Juego de Valores."
			FNDLOAD apps/apps 0 Y UPLOAD $FND_TOP/patch/115/import/afffload.lct $var3.ldt
		fi
		if [ $var2 = MENU ]; then
			echo "Cargando Menu."
			FNDLOAD apps/apps 0 Y UPLOAD $FND_TOP/patch/115/import/afsload.lct $var3.ldt
		fi
	fi
fi
