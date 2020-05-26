#!/bin/bash

#=========   URL OPTIONS   =========
#Main URL
MAIN_URL="https://github.com"

#========= DO NOT CHANGE BELOW =========

ALLOW_INSECURE_SSL="true"
CURL_RETRY="--connect-timeout 15 --max-time 120 --retry 3 --retry-delay 5"

ORIGINAL_SCRIPT_PATH="$0"
if [ "$ORIGINAL_SCRIPT_PATH" == "bash" ]
then
	ORIGINAL_SCRIPT_PATH=$(ps | grep "^ *$PPID " | grep -o "[^ ]*$")
fi

if [ -d "${BASE_PATH}/${OLD_SCRIPTS_PATH}" ] && [ ! -d "${BASE_PATH}/${SCRIPTS_PATH}" ]
then
	mv "${BASE_PATH}/${OLD_SCRIPTS_PATH}" "${BASE_PATH}/${SCRIPTS_PATH}"
	echo "Moved"
	echo "${BASE_PATH}/${OLD_SCRIPTS_PATH}"
	echo "to"
	echo "${BASE_PATH}/${SCRIPTS_PATH}"
	echo "please relaunch the script."
	exit 3
fi

SSL_SECURITY_OPTION=""
curl $CURL_RETRY -q $MAIN_URL &>/dev/null
case $? in
	0)
		;;
	60)
		if [ "$ALLOW_INSECURE_SSL" == "true" ]
		then
			SSL_SECURITY_OPTION="--insecure"
		else
			echo "CA certificates need"
			echo "to be fixed for"
			echo "using SSL certificate"
			echo "verification."
			echo "Please fix them i.e."
			echo "using security_fixes.sh"
			exit 2
		fi
		;;
	*)
		echo "No Internet connection"
		exit 1
		;;
esac

#========= MAIN SCRIPT =========

echo
echo " ------------------------------------------------------------------------"
echo "|            RetroDriven: Script Migration to New SE Version             |"
echo " ------------------------------------------------------------------------"
sleep 1

#Download New Script and INI
curl $SSL_SECURITY_OPTION -OJs "https://raw.githubusercontent.com/RetroDriven/MiSTerMAME/master/Update_RetroDriven_MAME_SE.sh"
curl $SSL_SECURITY_OPTION -OJs "https://raw.githubusercontent.com/RetroDriven/MiSTerMAME/master/Update_RetroDriven_MAME_SE.ini"

#Delete Previous Script
rm -f "Update_RetroDriven_MAME.ini" 2>/dev/null; true
rm -f "Update_RetroDriven_MAME.sh" 2>/dev/null; true
rm -f "Cache_Remover_RetroDriven.sh" 2>/dev/null; true

echo