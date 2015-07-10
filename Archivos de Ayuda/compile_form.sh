#!/bin/bash
cd /u01/$1/AP_$1/apps/apps_st/appl/au/12.0.0/forms/US
export FORMS_PATH=$FORMS_PATH=$AU_TOP/forms/US
frmcmp_batch userid=apps/apps Module=$AU_TOP/forms/US/$2.fmb module_type=FORM BATCH=YES compile_all=special output_file=$AU_TOP/forms/US/$2.fmx
cp /u01/$1/AP_$1/apps/apps_st/appl/au/12.0.0/forms/US/$2.fmx /u01/$1/AP_$1/apps/apps_st/appl/$3/12.0.0/forms/US/
cp /u01/$1/AP_$1/apps/apps_st/appl/au/12.0.0/forms/US/$2.fmx /u01/$1/AP_$1/apps/apps_st/appl/$3/12.0.0/forms/ESA/