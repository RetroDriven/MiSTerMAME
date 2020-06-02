#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Copyright 2018-2019 Alessandro "Locutus73" Miele

# You can download the latest version of this script from:
# https://github.com/RetroDriven/MiSTerMAME

: '
###### Disclaimer / Legal Information ######
By downloading and using this Script you are agreeing to the following:

* You are responsible for checking your local laws regarding the use of the ROMs that this Script downloads.
* You are authorized/licensed to own/use the ROMs associated with this Script.
* You will not distribute any of these files without the appropriate permissions.
* You own the original Arcade PCB for each ROM file that you download.
* I take no responsibility for any data loss or anything, use the script at your own risk.
'
# v1.1 - Added Options to control what is downloaded via INI
#        Added Option to Download Beta MRA Files
# v1.0 - SE(Second Edition) Script Created based off the Original Script
#        This is a slight revamp with less options to make things cleaner for less mess/issues globally
#        This version is using Mirror/Sync to provide a faster and more reliable experience 


#=========   URL OPTIONS   =========

#Main URL
MAIN_URL="https://www.retrodriven.appboxes.co"

#MAME ROM Zips
MAME_URL="https://www.retrodriven.appboxes.co/MiSTerMAME/Arcade/mame/"

#HBMAME ROM Zips
HBMAME_URL="https://www.retrodriven.appboxes.co/MiSTerMAME/Arcade/hbmame/"

#MRA - Unofficial
MRA_URL="https://www.retrodriven.appboxes.co/MiSTerMAME/Arcade/mra/Unofficial/"

#MRA - Jotego
MRA_JOTEGO_URL="https://www.retrodriven.appboxes.co/MiSTerMAME/Arcade/mra/Jotego/"

#MRA - CPS1
MRA_CPS1_URL="https://www.retrodriven.appboxes.co/MiSTerMAME/Arcade/mra/CPS1/"

#MRA - Sega System 1
MRA_SEGASYS1_URL="https://www.retrodriven.appboxes.co/MiSTerMAME/Arcade/mra/SegaSystem1/"

#MRA - Beta
MRA_BETA_URL="https://www.retrodriven.appboxes.co/MiSTerMAME/Arcade/mra/Beta/"

#=========   DIRECTORY OPTIONS   =========

#Base directory for all script’s tasks, "/media/fat" for SD root, "/media/usb0" for USB drive root.
BASE_PATH="/media/fat"

#This is your Arcade Directory
#Change Name if needed
#NOTE: The directory needs an underscore "_" for MiSTer to see the Directory
ARCADE_FOLDER="_Arcade"

#Control where you'd like to save your MRA Files
#NOTE: Make sure to keep the underscore "_" for MiSTer to see each Path/Folder as a Directory
#EX: Root of Arcade Folder = UNOFFICIAL_PATH="", JOTEGO_PATH="", etc.
#EX: Subfolders in Arcade Folder = UNOFFICIAL_PATH="_Unofficial", JOTEGO_PATH="_Jotego", etc.

UNOFFICIAL_PATH="_Unofficial"
JOTEGO_PATH="$UNOFFICIAL_PATH/_Jotego"
CPS1_PATH="$UNOFFICIAL_PATH/_CPS1"
SEGASYS1_PATH="$UNOFFICIAL_PATH/_Sega System 1"
BETA_PATH="$UNOFFICIAL_PATH/_Beta"

#Directory for MAME/HBMAME ROM Zips
#Arcade Path = "$BASE_PATH/$ARCADE_FOLDER"
#Games Path = "$BASE_PATH/Games"
MAME_PATH="$BASE_PATH/$ARCADE_FOLDER"

#=========   DOWNLOAD OPTIONS   =========

DOWNLOAD_MRA_UNOFFICIAL="True"
DOWNLOAD_MRA_JOTEGO="True"
DOWNLOAD_MRA_CPS1="True"
DOWNLOAD_MRA_SEGASYS1="True"
DOWNLOAD_MRA_BETA="False"

DOWNLOAD_MAME="True"
DOWNLOAD_HBMAME="True"

DOWNLOAD_CORES_UNOFFICIAL="True"
DOWNLOAD_CORES_JOTEGO="True"

#=========   USER OPTIONS   =========

#Set to "True" for DOOM Loading screen and Pure Retro Nostalgia
#Set to "False" to skip the DOOM Loading screen...but why would you do that?
IDDQD="True"

#Set to "True" to remove the "Arcade-" prefix with the Unofficial Arcade RBF Files
#Set to "False" if you'd like to keep the "Arcade-" prefix in place 
REMOVE_ARCADE_PREFIX="True"

#========= DO NOT CHANGE BELOW =========

TIMESTAMP=`date "+%m-%d-%Y @ %I:%M%P"`
ALLOW_INSECURE_SSL="true"
CURL_RETRY="--connect-timeout 15 --max-time 120 --retry 3 --retry-delay 5"

ORIGINAL_SCRIPT_PATH="$0"
if [ "$ORIGINAL_SCRIPT_PATH" == "bash" ]
then
	ORIGINAL_SCRIPT_PATH=$(ps | grep "^ *$PPID " | grep -o "[^ ]*$")
fi
INI_PATH=${ORIGINAL_SCRIPT_PATH%.*}.ini
if [ -f $INI_PATH ]
then
	eval "$(cat $INI_PATH | tr -d '\r')"
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

#========= FUNCTIONS =========

#RetroDriven Updater Banner Function
RetroDriven_Banner(){
echo
echo " ------------------------------------------------------------------------"
echo "|                RetroDriven: MiSTer MAME Updater SE v1.1                |"
echo " ------------------------------------------------------------------------"
sleep 1
}

#Shareware Info Function
Shareware(){
echo "=========================================================================="
echo "                    Shareware - Please Distribute!                        "
echo "                Please report issues on the GitHub Page                   "
echo "=========================================================================="
}

#Doom_Boot Function
Doom_Boot(){
echo "W_Init: Init MAMEfiles."
sleep 1
echo "        adding MAME.zip"
sleep 1
echo "        RetroDriven SE version"
sleep 1
Shareware
sleep 1
echo "M_Init: Init miscellanous info."
sleep 1
echo -n "R_Init: Init MAME Zip refresh daemon - ["; sleep 0.05; echo -n "."; sleep 0.05; echo -n "."; sleep 0.05; echo -n "."; sleep 0.05; echo -n "."; sleep 0.05; sleep 0.05; echo -n "."; sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n ".";sleep 0.05; echo -n "."; echo -n "]";
echo
sleep 1
echo
}

#IDDQD_Off Function
IDDQD_Off(){
echo
echo "IDDQD Off - No DOOM for you!"
sleep 1
Shareware
echo
}

#Download MAME Function
Download_MAME(){

    echo
    echo "=========================================================================="
    echo "                          Downloading MAME Files                          "
    echo "=========================================================================="
	sleep 1

	#Make Directories if needed
	mkdir -p "$MAME_PATH/mame"
    	cd "$MAME_PATH/mame"

    	#MAME Zip Downloading
	echo
	echo "Checking Existing MAME Zips for Updates/New Files......"
	echo
	
    	#Sync Files
    	lftp "$MAME_URL" -e "mirror -p -P 25 --ignore-time --verbose=1 --log="$LOGS_PATH/MAME_Downloads.txt"; quit"
    
	sleep 1
    	clear 	
}

#Download HBMAME Function
Download_HBMAME(){

    echo
    echo "=========================================================================="
    echo "                         Downloading HBMAME Files                         "
    echo "=========================================================================="
    sleep 1

	#Make Directories if needed
	mkdir -p "$MAME_PATH/hbmame"
   	cd "$MAME_PATH/hbmame"

	#HBMAME Zip Downloading
	echo
	echo "Checking Existing HBMAME Zips for Updates/New Files......"
	echo
	
    	#Sync Files
    	lftp "$HBMAME_URL" -e "mirror -p -P 25 --ignore-time --verbose=1 --log="$LOGS_PATH/HBMAME_Downloads.txt"; quit"
     
	sleep 1
    	clear 	
}

#MRA Banner
MRA_BANNER(){
    echo
    echo "=========================================================================="
    echo "                           Downloading MRA Files                          "
    echo "=========================================================================="
    sleep 1 
}

#Download MRA Function
Download_MRA(){

	#Create Directories
	mkdir -p "$MRA_PATH"
    	cd "$MRA_PATH"
    
	MRA_BANNER	
	echo
	echo "Checking Existing $MRA_TYPE MRA Files for Updates/New Files......"
	echo

    	#Sync Files
    	lftp "$MRA_DOWNLOAD_URL" -e "mirror -p -P 25 --ignore-time --verbose=1 --log="$LOGS_PATH/$MRA_LOG"; quit"
	
	sleep 1
    	clear 
}

#Backup Function
Backup(){

    echo
    echo "=========================================================================="
    echo "                  Backing Up Files from Previous Script                   "
    echo "=========================================================================="
    sleep 1 	

	#Delete Original Logs
	rm -r "$BASE_PATH/RetroDriven_Logs" 2>/dev/null

	#Backup Files from Original Script
	cd  "$BASE_PATH/_Arcade" 2>/dev/null
	mkdir "$BASE_PATH/_Arcade/rd_backup" 2>/dev/null

	mv -f "$BASE_PATH/_CPS1" "$BASE_PATH/_Arcade/rd_backup" 2>/dev/null
	mv -f "_Jotego" "$BASE_PATH/_Arcade/rd_backup" 2>/dev/null
	mv -f "_Unofficial" "$BASE_PATH/_Arcade/rd_backup" 2>/dev/null
	mv -f "_Sega System 1" "$BASE_PATH/_Arcade/rd_backup" 2>/dev/null
	mv -f "_CPS1" "$BASE_PATH/_Arcade/rd_backup" 2>/dev/null
	mv -f "_Jotego/_CPS1" "$BASE_PATH/_Arcade/rd_backup" 2>/dev/null
	
	cd "$BASE_PATH/$ARCADE_FOLDER" 2>/dev/null
	mv -f "$BASE_PATH/_CPS1" "$BASE_PATH/$ARCADE_FOLDER/rd_backup" 2>/dev/null
	mv -f "_Jotego" "$BASE_PATH/$ARCADE_FOLDER/rd_backup" 2>/dev/null
	mv -f "_Unofficial" "$BASE_PATH/$ARCADE_FOLDER/rd_backup" 2>/dev/null
	mv -f "_Sega System 1" "$BASE_PATH/$ARCADE_FOLDER/rd_backup" 2>/dev/null
	mv -f "_CPS1" "$BASE_PATH/$ARCADE_FOLDER/rd_backup" 2>/dev/null
	mv -f "_Jotego/_CPS1" "$BASE_PATH/$ARCADE_FOLDER/rd_backup" 2>/dev/null

	#Delete Cached Files/Folder from Original Scipt
	rm -r "/media/fat/scripts/.RetroDriven/HBMAME"
	rm -r "/media/fat/scripts/.RetroDriven/MAME"
	rm -r "/media/fat/scripts/.RetroDriven/MAME_CPS1"
	rm -r "/media/fat/scripts/.RetroDriven/MRA"
	rm -r "/media/fat/scripts/.RetroDriven/MRA_CPS1"

	sleep 1
	clear
}

#Footer Function
Footer(){
clear
echo
echo "=========================================================================="
echo "                  MAME ZIP/MRA/RBF Files are up to date!                  "
echo "=========================================================================="
echo
}

#========= MAIN CODE =========

#RetroDriven Updater Banner
RetroDriven_Banner

#Doom Boot loader
if [ $IDDQD == "True" ]; then
    Doom_Boot
else
    IDDQD_Off
    sleep 3
fi

#Create Logs Folder
LOGS_PATH="/media/fat/Scripts/.RetroDriven/Logs"
mkdir -p "$LOGS_PATH"

#SSL Handling for LFTP
if [ ! -f ~/.lftp/rc ]; then
    mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
    [ "$RO_ROOT" == "true" ] && mount / -o remount,rw
    
    mkdir -p ~/.lftp
    echo "set ssl:verify-certificate no" >> ~/.lftp/rc
    echo "set xfer:log no" >> ~/.lftp/rc

    [ "$RO_ROOT" == "true" ] && mount / -o remount,ro
fi

#Cleaner Download Details
	if ! grep -q "set xfer:log no" "/root/.lftp/rc"; then
	mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
    	[ "$RO_ROOT" == "true" ] && mount / -o remount,rw
	echo "set xfer:log no" >> /root/.lftp/rc
	[ "$RO_ROOT" == "true" ] && mount / -o remount,ro
	fi

	if ! grep -q "set ssl:verify-certificate no" "/root/.lftp/rc"; then
	[ "$RO_ROOT" == "true" ] && mount / -o remount,rw
	echo "set ssl:verify-certificate no" >> /root/.lftp/rc
	[ "$RO_ROOT" == "true" ] && mount / -o remount,ro
	fi


#Backup from previous Script
SHOW_BACKUP_LOCATION="False"
if [ -d "/media/fat/scripts/.RetroDriven/MAME" ];then
	Backup
	SHOW_BACKUP_LOCATION="True"
fi

#Download MAME Zips
if [ $DOWNLOAD_MAME == "True" ];then
	Download_MAME
fi

#Download HBMAME Zips
if [ $DOWNLOAD_HBMAME == "True" ];then
	Download_HBMAME
fi

#Download Unofficial MRAs
if [ $DOWNLOAD_MRA_UNOFFICIAL == "True" ];then
	MRA_PATH="$BASE_PATH/$ARCADE_FOLDER/$UNOFFICIAL_PATH"
	MRA_TYPE="Unofficial"
	MRA_DOWNLOAD_URL="$MRA_URL"
	MRA_LOG="MRA_Unofficial_Downloads.txt"
	Download_MRA "$MRA_PATH" "$MRA_TYPE" "$MRA_DOWNLOAD_URL" "$MRA_LOG"
fi

#Download Jotego MRAs
if [ $DOWNLOAD_MRA_JOTEGO == "True" ];then
	MRA_PATH="$BASE_PATH/$ARCADE_FOLDER/$JOTEGO_PATH"
	MRA_TYPE="Jotego"
	MRA_DOWNLOAD_URL="$MRA_JOTEGO_URL"
	MRA_LOG="MRA_Jotego_Downloads.txt"
	Download_MRA "$MRA_PATH" "$MRA_TYPE" "$MRA_DOWNLOAD_URL" "$MRA_LOG"
fi

#Download CPS1 MRAs
if [ $DOWNLOAD_MRA_CPS1 == "True" ];then
	MRA_PATH="$BASE_PATH/$ARCADE_FOLDER/$CPS1_PATH"
	MRA_TYPE="CPS1"
	MRA_DOWNLOAD_URL="$MRA_CPS1_URL"
	MRA_LOG="MRA_CPS1_Downloads.txt"
	Download_MRA "$MRA_PATH" "$MRA_TYPE" "$MRA_DOWNLOAD_URL" "$MRA_LOG"
fi

#Download Sega System 1 MRAs
if [ $DOWNLOAD_MRA_SEGASYS1 == "True" ];then
	MRA_PATH="$BASE_PATH/$ARCADE_FOLDER/$SEGASYS1_PATH"
	MRA_TYPE="Sega System 1"
	MRA_DOWNLOAD_URL="$MRA_SEGASYS1_URL"
	MRA_LOG="MRA_SEGASYS1_Downloads.txt"
	Download_MRA "$MRA_PATH" "$MRA_TYPE" "$MRA_DOWNLOAD_URL" "$MRA_LOG"
fi

#Download Beta MRAs
if [ $DOWNLOAD_MRA_BETA == "True" ];then
	MRA_PATH="$BASE_PATH/$ARCADE_FOLDER/$BETA_PATH"
	MRA_TYPE="Beta"
	MRA_DOWNLOAD_URL="$MRA_BETA_URL"
	MRA_LOG="MRA_Beta_Downloads.txt"
	Download_MRA "$MRA_PATH" "$MRA_TYPE" "$MRA_DOWNLOAD_URL" "$MRA_LOG"
fi

echo

#Unofficial Updater Function
Unofficial_Updater(){

#================================================================================#
#                       UNOFFICIAL CORE UPDATER STARTS HERE                      #
#================================================================================#

#=========   USER OPTIONS   =========

#Directory where RetroDriven Cores are downloaded
CORE_PATH="$BASE_PATH/$ARCADE_FOLDER/cores"
mkdir -p "$CORE_PATH"
declare -A CORE_CATEGORY_PATHS
CORE_CATEGORY_PATHS["arcade-cores"]="$CORE_PATH"

DELETE_OLD_FILES="true"
DOWNLOAD_NEW_CORES="true"

#EXPERIMENTAL: specifies if the update process must be done with parallel processing; use it at your own risk!
PARALLEL_UPDATE="false"

#========= ADVANCED OPTIONS =========
SCRIPTS_PATH="Scripts"
OLD_SCRIPTS_PATH="#Scripts"
WORK_PATH="/media/fat/$SCRIPTS_PATH/.mister_updater"
#Uncomment this if you want the script to sync the system date and time with a NTP server
#NTP_SERVER="0.pool.ntp.org"
AUTOREBOOT="false"
REBOOT_PAUSE=0
TEMP_PATH="/tmp"
TO_BE_DELETED_EXTENSION="to_be_deleted"

#========= CODE STARTS HERE ========= 
    clear    
    echo
    echo "=========================================================================="
    echo "                    Downloading Unofficial Arcade Cores                   "
    echo "=========================================================================="
    sleep 1	

if [ $DEV_NAME == "jotego" ];then
    clear    
    echo
    echo "=========================================================================="
    echo "                      Downloading Jotego Arcade Cores                     "
    echo "=========================================================================="
    sleep 1 
fi

if [ "$DOWNLOAD_NEW_CORES" != "true" ] && [ "$DOWNLOAD_NEW_CORES" != "false" ] && [ "$DOWNLOAD_NEW_CORES" != "" ]
then
	for idx in "${!CORE_CATEGORY_PATHS[@]}"; do
		NEW_CORE_CATEGORY_PATHS[$idx]=$(echo ${CORE_CATEGORY_PATHS[$idx]} | sed "s/$(echo $BASE_PATH | sed 's/\//\\\//g')/$(echo $BASE_PATH | sed 's/\//\\\//g')\/$DOWNLOAD_NEW_CORES/g")
	done
	mkdir -p "${NEW_CORE_CATEGORY_PATHS[@]}"
fi

CORE_URLS=$(curl $SSL_SECURITY_OPTION -sLf "$WIKI_URL" | grep -io '\('$GITHUB_CORE_URL'/[a-zA-Z0-9./_-]*\)\|\(user-content-[a-z-]*\)')


CORE_CATEGORY="-"
SD_INSTALLER_PATH=""
REBOOT_NEEDED="false"
CORE_CATEGORIES_FILTER=""

GOOD_CORES=""
if [ "$GOOD_CORES_URL" != "" ]
then
	GOOD_CORES=$(curl $SSL_SECURITY_OPTION -sLf "$GOOD_CORES_URL")
fi

function checkCoreURL {
	
	echo "Checking $(echo $CORE_URL | sed 's/.*\///g' | sed 's/_MiSTer//gI')"
	[ "${SSH_CLIENT}" != "" ] && echo "URL: $CORE_URL"
	if echo "$CORE_URL" | grep -q "SD-Installer"
	then
		RELEASES_URL="$CORE_URL"
	else
		RELEASES_URL=https://github.com$(curl $SSL_SECURITY_OPTION -sLf "$CORE_URL" | grep -o '/'$DEV_NAME'/[a-zA-Z0-9./_-]*/tree/master/[a-zA-Z0-9./_-]*/releases' | head -n1)
	fi

	RELEASE_URLS=$(curl $SSL_SECURITY_OPTION -sLf "$RELEASES_URL" | grep -o '/'$DEV_NAME'/[a-zA-Z0-9./_-]*_[0-9]\{8\}[a-zA-Z]\?\(\.rbf\|\.rar\)\?')

	MAX_VERSION=""
	MAX_RELEASE_URL=""
	GOOD_CORE_VERSION=""
	for RELEASE_URL in $RELEASE_URLS; do
		if echo "$RELEASE_URL" | grep -q "SharpMZ"
		then
			RELEASE_URL=$(echo "$RELEASE_URL"  | grep '\.rbf$')
		fi			
		if echo "$RELEASE_URL" | grep -q "Atari800"
		then
			if [ "$CORE_CATEGORY" == "cores" ]
			then
				RELEASE_URL=$(echo "$RELEASE_URL"  | grep '800_[0-9]\{8\}[a-zA-Z]\?\.rbf$')
			else
				RELEASE_URL=$(echo "$RELEASE_URL"  | grep '5200_[0-9]\{8\}[a-zA-Z]\?\.rbf$')
			fi
		fi			
		CURRENT_VERSION=$(echo "$RELEASE_URL" | grep -o '[0-9]\{8\}[a-zA-Z]\?')
		
		if [ "$GOOD_CORES" != "" ]
		then
			GOOD_CORE_VERSION=$(echo "$GOOD_CORES" | grep -wo "$(echo "$RELEASE_URL" | sed 's/.*\///g')" | grep -o '[0-9]\{8\}[a-zA-Z]\?')
			if [ "$GOOD_CORE_VERSION" != "" ]
			then
				MAX_VERSION=$CURRENT_VERSION
				MAX_RELEASE_URL=$RELEASE_URL
				break
			fi
		fi
		
		if [[ "$CURRENT_VERSION" > "$MAX_VERSION" ]]
		then
			MAX_VERSION=$CURRENT_VERSION
			MAX_RELEASE_URL=$RELEASE_URL
		fi
	done
	
	FILE_NAME=$(echo "$MAX_RELEASE_URL" | sed 's/.*\///g')
	if [ "$CORE_CATEGORY" == "arcade-cores" ] && [ $REMOVE_ARCADE_PREFIX == "True" ]
	then
		FILE_NAME=$(echo "$FILE_NAME" | sed 's/Arcade-//gI')
	fi
	BASE_FILE_NAME=$(echo "$FILE_NAME" | sed 's/_[0-9]\{8\}.*//g')
	
	CURRENT_DIRS="${CORE_CATEGORY_PATHS[$CORE_CATEGORY]}"
	if [ "${NEW_CORE_CATEGORY_PATHS[$CORE_CATEGORY]}" != "" ]
	then
		CURRENT_DIRS=("$CURRENT_DIRS" "${NEW_CORE_CATEGORY_PATHS[$CORE_CATEGORY]}")
	fi 
	if [ "$CURRENT_DIRS" == "" ]
	then
		CURRENT_DIRS=("$BASE_PATH")
	fi
	if [ "$BASE_FILE_NAME" == "MiSTer" ] || [ "$BASE_FILE_NAME" == "menu" ] || { echo "$CORE_URL" | grep -q "SD-Installer"; }
	then
		mkdir -p "$WORK_PATH"
		CURRENT_DIRS=("$WORK_PATH")
	fi
	
	CURRENT_LOCAL_VERSION=""
	MAX_LOCAL_VERSION=""
	for CURRENT_DIR in "${CURRENT_DIRS[@]}"
	do
		for CURRENT_FILE in "$CURRENT_DIR/$BASE_FILE_NAME"*
		do
			if [ -f "$CURRENT_FILE" ]
			then
				if echo "$CURRENT_FILE" | grep -q "$BASE_FILE_NAME\_[0-9]\{8\}[a-zA-Z]\?\(\.rbf\|\.rar\)\?$"
				then
					CURRENT_LOCAL_VERSION=$(echo "$CURRENT_FILE" | grep -o '[0-9]\{8\}[a-zA-Z]\?')
					if [ "$GOOD_CORE_VERSION" != "" ]
					then
						if [ "$CURRENT_LOCAL_VERSION" == "$GOOD_CORE_VERSION" ]
						then
							MAX_LOCAL_VERSION=$CURRENT_LOCAL_VERSION
						else
							if [ "$MAX_LOCAL_VERSION" == "" ]
							then
								MAX_LOCAL_VERSION="00000000"
							fi
							if [ $DELETE_OLD_FILES == "true" ]
							then
								mv "${CURRENT_FILE}" "${CURRENT_FILE}.${TO_BE_DELETED_EXTENSION}" > /dev/null 2>&1
							fi
						fi
					else
						if [[ "$CURRENT_LOCAL_VERSION" > "$MAX_LOCAL_VERSION" ]]
						then
							MAX_LOCAL_VERSION=$CURRENT_LOCAL_VERSION
						fi
						if [[ "$MAX_VERSION" > "$CURRENT_LOCAL_VERSION" ]] && [ $DELETE_OLD_FILES == "true" ]
						then
							# echo "Moving $(echo ${CURRENT_FILE} | sed 's/.*\///g')"
							mv "${CURRENT_FILE}" "${CURRENT_FILE}.${TO_BE_DELETED_EXTENSION}" > /dev/null 2>&1
						fi
					fi
				
				fi
			fi
		done
		if [ "$MAX_LOCAL_VERSION" != "" ]
		then
			break
		fi
	done
	
	if [[ "$MAX_VERSION" > "$MAX_LOCAL_VERSION" ]]
	then
		if [ "$DOWNLOAD_NEW_CORES" != "false" ] || [ "$MAX_LOCAL_VERSION" != "" ] || [ "$BASE_FILE_NAME" == "MiSTer" ] || [ "$BASE_FILE_NAME" == "menu" ] || { echo "$CORE_URL" | grep -q "SD-Installer"; }
		then
			echo "Downloading $FILE_NAME"
			[ "${SSH_CLIENT}" != "" ] && echo "URL: https://github.com$MAX_RELEASE_URL?raw=true"
			if curl $SSL_SECURITY_OPTION -# -L "https://github.com$MAX_RELEASE_URL?raw=true" -o "$CURRENT_DIR/$FILE_NAME"
                #Log File handling                
                echo "$FILE_NAME" >> "$LOGS_PATH/RBF_Downloaded.txt"                		
            then
				if [ ${DELETE_OLD_FILES} == "true" ]
				then
					echo "Deleting old ${BASE_FILE_NAME} files"
					rm "${CURRENT_DIR}/${BASE_FILE_NAME}"*.${TO_BE_DELETED_EXTENSION} > /dev/null 2>&1
				fi
				if [ $BASE_FILE_NAME == "MiSTer" ] || [ $BASE_FILE_NAME == "menu" ]
				then
					DESTINATION_FILE=$(echo "$MAX_RELEASE_URL" | sed 's/.*\///g' | sed 's/_[0-9]\{8\}[a-zA-Z]\{0,1\}//g')
					echo "Moving $DESTINATION_FILE"
					rm "/media/fat/$DESTINATION_FILE" > /dev/null 2>&1
					mv "$CURRENT_DIR/$FILE_NAME" "/media/fat/$DESTINATION_FILE"
					touch "$CURRENT_DIR/$FILE_NAME"
					REBOOT_NEEDED="true"
				fi
				if echo "$CORE_URL" | grep -q "SD-Installer"
				then
					SD_INSTALLER_PATH="$CURRENT_DIR/$FILE_NAME"
				fi
				if [ "$CORE_CATEGORY" == "arcade-cores" ]
				then
					OLD_IFS="$IFS"
					IFS="|"
					for ARCADE_ALT_PATH in $ARCADE_ALT_PATHS
					do
						for ARCADE_ALT_DIR in "$ARCADE_ALT_PATH/_$BASE_FILE_NAME"*
						do
							if [ -d "$ARCADE_ALT_DIR" ]
							then
								echo "Updating $(echo $ARCADE_ALT_DIR | sed 's/.*\///g')"
								if [ $DELETE_OLD_FILES == "true" ]
								then
									for ARCADE_HACK_CORE in "$ARCADE_ALT_DIR/"*.rbf
									do
										if [ -f "$ARCADE_HACK_CORE" ] && { echo "$ARCADE_HACK_CORE" | grep -q "$BASE_FILE_NAME\_[0-9]\{8\}[a-zA-Z]\?\.rbf$"; }
										then
											rm "$ARCADE_HACK_CORE"  > /dev/null 2>&1
										fi
									done
								fi
								cp "$CURRENT_DIR/$FILE_NAME" "$ARCADE_ALT_DIR/"
							fi
						done
					done
					IFS="$OLD_IFS"
				fi
			else
				echo "${FILE_NAME} download failed"
				rm "${CURRENT_DIR}/${FILE_NAME}" > /dev/null 2>&1
				if [ ${DELETE_OLD_FILES} == "true" ]
				then
					echo "Restoring old ${BASE_FILE_NAME} files"
					for FILE_TO_BE_RESTORED in "${CURRENT_DIR}/${BASE_FILE_NAME}"*.${TO_BE_DELETED_EXTENSION}
					do
					  mv "${FILE_TO_BE_RESTORED}" "${FILE_TO_BE_RESTORED%.${TO_BE_DELETED_EXTENSION}}" > /dev/null 2>&1
					done
				fi
			fi
			sync
		else
			echo "New core: $FILE_NAME"
		fi
	else
		echo "Nothing to update"
	fi
	
	echo ""
}

for CORE_URL in $CORE_URLS; do

	if [[ $CORE_URL == https://* ]]
	then
		if [ "$REPOSITORIES_FILTER" == "" ] || { echo "$CORE_URL" | grep -qi "$REPOSITORIES_FILTER";  } || { echo "$CORE_CATEGORY" | grep -qi "$CORE_CATEGORIES_FILTER";  }
		then
			if echo "$CORE_URL" | grep -qE "(SD-Installer)|(/Main_MiSTer$)|(/Menu_MiSTer$)"
			then
				checkCoreURL
			else
				[ "$PARALLEL_UPDATE" == "true" ] && { echo "$(checkCoreURL)"$'\n' & } || checkCoreURL
			fi
		fi
	else
		CORE_CATEGORY=$(echo "$CORE_URL" | sed 's/user-content-//g')
		if [ "$CORE_CATEGORY" == "" ]
		then
			CORE_CATEGORY="-"
		fi
		if [ "$CORE_CATEGORY" == "computer-cores" ]
		then
			CORE_CATEGORY="cores"
		fi
	fi
done
wait

#exit 0
}

#Download Unofficial Arcade Cores
	
    #Get Unofficial Arcade RBF Cores - My GitHub
if [ $DOWNLOAD_CORES_UNOFFICIAL == "True" ];then
    WIKI_URL="https://github.com/RetroDriven/MiSTerMAME/wiki"
    GITHUB_CORE_URL="https://github.com/RetroDriven/MiSTerMAME/tree/master/Unofficial_Cores"
    DEV_NAME="RetroDriven"
    Unofficial_Updater $WIKI_URL $GITHUB_CORE_URL $DEV_NAME

	#Log File Handling
	echo "Date: $TIMESTAMP" >> "$LOGS_PATH/RBF_Downloaded.txt"
fi	

    #Get Unofficial Arcade RBF Cores - Jotego
if [ $DOWNLOAD_CORES_JOTEGO == "True" ];then   
    WIKI_URL="https://github.com/jotego/jtbin/wiki"
    GITHUB_CORE_URL="https://github.com/jotego/jtbin/tree/master/mister"
    DEV_NAME="jotego"
    Unofficial_Updater $WIKI_URL $GITHUB_CORE_URL $DEV_NAME

	#Log File Handling
	echo "Date: $TIMESTAMP" >> "$LOGS_PATH/RBF_Downloaded.txt"
fi

#Display Footer
Footer
echo "Downloaded Log Files are located here: $LOGS_PATH"
if [ $SHOW_BACKUP_LOCATION == "True" ];then
	echo "Backup Files from Previous Script located here: $BASE_PATH/$ARCADE_FOLDER/rd_backup"
fi
echo
