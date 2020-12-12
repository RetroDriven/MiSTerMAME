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

# Copyright 2018-2020 Alessandro "Locutus73" Miele
# Copyright 2020 RetroDriven
# Adapted to jotego cores by José Manuel Barroso Galindo "theypsilon" © 2020

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
# Version 1.4 - 11/21/2020 - Removed Sega System  1 from the Script as that is an Official Core
# Version 1.3 - 06/27/2020 - Changed/Adapted parts of this Script from the latest Jotego Updater. This will pull almost all MRA/RBF files from the Proper GitHub Pages; Added DOWNLOAD_MRA_ALTERNATIVES to control if you'd like Download/Skip MRA Alternatives
# Version 1.2 - 06/12/2020 - Changed Default Mame path to use /Games/mame and /Games/hbmame
# Version 1.1 - 05/30/2020 - Added Options to control what is downloaded via INI; Added Option to Download Beta MRA Files
# Version 1.0 - 05/25/2020 - SE(Second Edition) Script Created based off the Original Script; This is a slight revamp with less options to make things cleaner for less mess/issues globally; This version is using Mirror/Sync to provide a faster and more reliable experience 

#=========   URL OPTIONS   =========

#Main URL
MAIN_URL="https://www.retrodriven.appboxes.co"

#MAME ROM Zips
MAME_URL="https://www.retrodriven.appboxes.co/MiSTerMAME/Arcade/mame/"

#HBMAME ROM Zips
HBMAME_URL="https://www.retrodriven.appboxes.co/MiSTerMAME/Arcade/hbmame/"

#MRA - Jotego Alternatives
MRA_JOTEGO_URL="https://www.retrodriven.appboxes.co/MiSTerMAME/Arcade/MRA/Alternatives/Jotego/"

#MRA - CPS1 Alternatives
MRA_CPS1_URL="https://www.retrodriven.appboxes.co/MiSTerMAME/Arcade/MRA/Alternatives/CPS1/"

#MRA - Beta
MRA_BETA_URL="https://www.retrodriven.appboxes.co/MiSTerMAME/Arcade/MRA/Beta/"

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
BETA_PATH="$UNOFFICIAL_PATH/_Beta"

#Directory for MAME/HBMAME ROM Zips
#Arcade Path = "$BASE_PATH/$ARCADE_FOLDER"
#Games Path = "$BASE_PATH/Games"
MAME_PATH="$BASE_PATH/Games"

#=========   DOWNLOAD OPTIONS   =========

DOWNLOAD_MRA_UNOFFICIAL="True"
DOWNLOAD_MRA_JOTEGO="True"
DOWNLOAD_MRA_CPS1="True"
DOWNLOAD_MRA_BETA="False"

DOWNLOAD_MRA_ALTERNATIVES="True"

DOWNLOAD_MAME="True"
DOWNLOAD_HBMAME="True"

DOWNLOAD_CORES_UNOFFICIAL="True"
DOWNLOAD_CORES_JOTEGO="True"
DOWNLOAD_CORES_CPS1="True"

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
CURL_RETRY="--connect-timeout 15 --max-time 180 --retry 3 --retry-delay 5"

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
echo " ------------------------------------------------------------"
echo "|          RetroDriven: MiSTer MAME Updater SE v1.4          |"
echo " ------------------------------------------------------------"
sleep 1

echo
echo " ------------------------------------------------------------"
echo "                   *** IMPORTANT NOTE ***                     "
echo
echo "   All RetroDriven Scripts will be End Of Life January 2021   "
echo
echo "   Please see my GitHub, Twitter, or Patreon for full details "                         
echo " ------------------------------------------------------------"
sleep 10

}

#Shareware Info Function
Shareware(){
echo "================================================================"
echo "                 Shareware - Please Distribute!                 "
echo "             Please report issues on the GitHub Page            "
echo "================================================================"
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
echo ""
sleep 1
Shareware
echo
}

#Download MAME Function
Download_MAME(){

    echo
    echo "================================================================"
    echo "                     Downloading MAME Files                     "
    echo "================================================================"
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
    echo "================================================================"
    echo "                    Downloading HBMAME Files                    "
    echo "================================================================"
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
    echo "================================================================"
    echo "                      Downloading MRA Files                     "
    echo "================================================================"
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
    echo "================================================================"
    echo "             Backing Up Files from Previous Script              "
    echo "================================================================"
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

#Cleanup MRA Function
Cleanup_MRA(){

if [ -f "$CLEAN_PATH/$CLEAN_FILE" ];then
	rm -f "$CLEAN_PATH/$CLEAN_FILE" 2>/dev/null	
fi

}

#Footer Function
Footer(){
clear
echo
echo "================================================================"
echo "             MAME ZIP/MRA/RBF Files are up to date!             "
echo "================================================================"
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
    sleep 1
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
	if ! grep -q "set xfer:log no" "/.lftp/rc"; then
	mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
    	[ "$RO_ROOT" == "true" ] && mount / -o remount,rw
	echo "set xfer:log no" >> /root/.lftp/rc
	[ "$RO_ROOT" == "true" ] && mount / -o remount,ro
	fi

	if ! grep -q "set ssl:verify-certificate no" "/.lftp/rc"; then 
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

#Cleanup from v1.2 to v1.3
if [ ! -f "/media/fat/Scripts/.RetroDriven/.Migrate/v1.2-v1.3.log" ];then
	mkdir -p "/media/fat/Scripts/.RetroDriven/.Migrate"
	touch "/media/fat/Scripts/.RetroDriven/.Migrate/v1.2-v1.3.log"

	#Cleanup Jotego MRAs
	if [ $DOWNLOAD_MRA_JOTEGO == "True" ];then
		
		CLEAN_PATH="$BASE_PATH/$ARCADE_FOLDER/$JOTEGO_PATH"
		
		CLEAN_FILE="Ares no tsubasa.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE 
		
		CLEAN_FILE="Section Z.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE
	fi

	#Cleanup Unofficial MRAs
	if [ $DOWNLOAD_MRA_UNOFFICIAL == "True" ];then

		CLEAN_PATH="$BASE_PATH/$ARCADE_FOLDER/$UNOFFICIAL_PATH"
		
		CLEAN_FILE="Penguin-Kun Wars (Japan).mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Penguin-Kun Wars (US).mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE
	fi

	#Cleanup CPS1 MRAs
	if [ $DOWNLOAD_MRA_CPS1 == "True" ];then
		
		CLEAN_PATH="$BASE_PATH/$ARCADE_FOLDER/$CPS1_PATH"
		
		CLEAN_FILE="1941 - Counter Attack.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Adventure Quiz Capcom World 2.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Captain Commando.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Carrier Air Wing.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE
		
		CLEAN_FILE="Daimakaimura.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Dynasty Wars.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE
	
		CLEAN_FILE="Final Fight.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Forgotten Worlds.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Ganbare! Marine Kun.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Ghouls'n Ghosts.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Gulunpa.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Knights of the Round.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Magic Sword  - Heroic Fantasy.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Mega Man - The Power Battle.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE
		
		CLEAN_FILE="Mega Twins.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Mercs.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE
		
		CLEAN_FILE="Nemo.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Pang! 3.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Pokonyan! Balloon.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Quiz & Dragons - Capcom Quiz Game.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Quiz Tonosama no Yabou 2 - Zenkoku-ban.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Street Fighter II - Champion Edition.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Street Fighter II - Hyper Fighting.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Street Fighter II - The World Warrior.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Street Fighter Zero.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Strider.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE
		
		CLEAN_FILE="The King of Dragons.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Three Wonders.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="U.N. Squadron.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Varth - Operation Thunderstorm.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Willow.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		#Cleanup CPS1 Alternatives
		rm -r "$CLEAN_PATH/_Alternatives/_Ghouls n Ghosts" 2>/dev/null
		rm -r "$CLEAN_PATH/_Alternatives/Quiz & Dragons - Capcom Quiz Game" 2>/dev/null
		rm -r "$CLEAN_PATH/_Alternatives/_Street Fighter II - Hyper Fighting" 2>/dev/null
		rm -r "$CLEAN_PATH/_Alternatives/_Street Fighter II - The World Warrior" 2>/dev/null
		rm -r "$CLEAN_PATH/_Alternatives/_1941" 2>/dev/null
		rm -r "$CLEAN_PATH/_Alternatives/_Daimakaimura" 2>/dev/null
		rm -r "$CLEAN_PATH/_Alternatives/_Magic Sword" 2>/dev/null
		rm -r "$CLEAN_PATH/_Alternatives/_Mega Man" 2>/dev/null
		rm -r "$CLEAN_PATH/_Alternatives/_Mega Twins" 2>/dev/null
		rm -r "$CLEAN_PATH/_Alternatives/_Street Fighter Zero" 2>/dev/null
		rm -r "$CLEAN_PATH/_Alternatives/_Tenchi wo Kurau" 2>/dev/null
		rm -r "$CLEAN_PATH/_Alternatives/_Varth" 2>/dev/null
		rm -r "$CLEAN_PATH/_Alternatives/_Street Fighter II - Champion Edition" 2>/dev/null

		CLEAN_PATH="$BASE_PATH/$ARCADE_FOLDER/$CPS1_PATH/_Alternatives"
		CLEAN_FILE="U.N. Squadron -USA-.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Quiz Tonosama no Yabou 2  Zenkoku-ban -Japan 950123-.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Pokonyan! Balloon -Japan 940322-.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Pnickies -Japan 940608-.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Huo Feng Huang -Chinese bootleg of Sangokushi II-.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Ganbare! Marine Kun -Japan 2K0411-.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Dinosaur Hunter -Chinese bootleg of Cadillacs and Dinosaurs-.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE

		CLEAN_FILE="Biaofeng Zhanjing -Chinese bootleg of The Punisher-.mra"
		Cleanup_MRA $CLEAN_PATH $CLEAN_FILE
	fi

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
SCRIPTS_PATH="Scripts"
MAME_ALT_ROMS="false"

Unofficial_Updater(){

#================================================================================#
#                       UNOFFICIAL CORE UPDATER STARTS HERE                      #
#================================================================================#

#=========   USER OPTIONS   =========

#Directory where RetroDriven Cores are downloaded
declare -A CORE_CATEGORY_PATHS
CORE_CATEGORY_PATHS["arcade-cores"]="$BASE_PATH/$ARCADE_FOLDER"

UPDATE_CHEATS="false"
UPDATE_LINUX="false"
ADDITIONAL_REPOSITORIES=()
FILTERS_URL=""
CORE_CATEGORY="-"
SD_INSTALLER_PATH=""
REBOOT_NEEDED="false"
CORE_CATEGORIES_FILTER=""
ARCADE_ALT_PATHS="${CORE_CATEGORY_PATHS["arcade-cores"]}/_Arcade Hacks|${CORE_CATEGORY_PATHS["arcade-cores"]}/_Arcade Revisions"
DELETE_OLD_FILES="true"
DOWNLOAD_NEW_CORES="true"
REMOVE_ARCADE_PREFIX="true"
CREATE_CORES_DIRECTORIES="true"
MAME_ARCADE_ROMS="true"
ALLOW_INSECURE_SSL="true"
CURL_RETRY="--connect-timeout 15 --max-time 180 --retry 3 --retry-delay 5"
MISTER_URL="https://github.com/MiSTer-devel/Main_MiSTer"
OLD_SCRIPTS_PATH="#Scripts"
REBOOT_PAUSE=0  # in seconds
TEMP_PATH="/tmp"
TO_BE_DELETED_EXTENSION="to_be_deleted"

UPDATER_VERSION="4.0.9"

#========= CODE STARTS HERE ========= 
    if [ $DEV_NAME == "Unofficial" ];then
    clear    
    echo
    echo "================================================================"
    echo "            Downloading Unofficial Arcade Cores/MRAs            "
    echo "================================================================"
    echo ""
    sleep 1
fi	

if [ $DEV_NAME == "Jotego" ];then
    clear    
    echo
    echo "================================================================"
    echo "              Downloading Jotego Arcade Cores/MRAs              "
    echo "================================================================"
    echo ""
    sleep 1 
fi

if [ $DEV_NAME == "CPS1" ];then
    clear    
    echo
    echo "================================================================"
    echo "               Downloading CPS1 Arcade Core/MRAs                "
    echo "================================================================"
    echo ""
    sleep 1 
fi

ORIGINAL_SCRIPT_PATH="$0"
if [ "$ORIGINAL_SCRIPT_PATH" == "bash" ]
then
	ORIGINAL_SCRIPT_PATH=$(ps | grep "^ *$PPID " | grep -o "[^ ]*$")
	if [ "$ORIGINAL_SCRIPT_PATH" == "-" ] ; then
		PARENT_PPID=$(ps -o pid,ppid | grep "^ *$PPID" | grep -o "[^ ]* *$")
		ORIGINAL_SCRIPT_PATH=$(ps | grep "^ *$PARENT_PPID " | grep -o "[^ ]*$")
	fi
fi
INI_PATH=${ORIGINAL_SCRIPT_PATH%.*}.ini
if [ -f $INI_PATH ]
then
	eval "$(cat $INI_PATH | tr -d '\r')"
	INI_DATETIME_UTC=$(date -d "$(stat -c %y "${INI_PATH}" 2>/dev/null)" -u +"%Y-%m-%dT%H:%M:%SZ")
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
curl $CURL_RETRY -q https://github.com &>/dev/null
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
#if [ "$SSL_SECURITY_OPTION" == "" ]
#then
#	if [ "$(grep -v "^#" "${ORIGINAL_SCRIPT_PATH}")" == "curl $CURL_RETRY -ksLf https://#github.com/jotego/Updater_script_MiSTer/blob/master/mister_updater.sh?raw=true | bash -" ]
#	then
#		echo "Downloading $(sed 's/.*\///' <<< "${ORIGINAL_SCRIPT_PATH}")"
#		echo ""
#		curl $CURL_RETRY $SSL_SECURITY_OPTION -L "https://github.com/jotego/#Updater_script_MiSTer/blob/master/update_jtcores.sh?raw=true" -o "$ORIGINAL_SCRIPT_PATH"
#	fi
#fi

## sync with a public time server
if [[ -n "${NTP_SERVER}" ]] ; then
	echo "Syncing date and time with"
	echo "${NTP_SERVER}"
	# (-b) force time reset, (-s) write output to syslog, (-u) use
	# unprivileged port for outgoing packets to workaround firewalls
	ntpdate -b -s -u "${NTP_SERVER}"
    echo
fi

UPDATE_START_DATETIME_LOCAL=$(date)
UPDATE_START_DATETIME_UTC=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

for idx in "${!CORE_CATEGORY_PATHS[@]}"; do
	CORE_CATEGORY_PATHS[$idx]="${CORE_CATEGORY_PATHS[$idx]/\/media\/fat/${BASE_PATH}}"
	#echo "CORE_CATEGORY_PATHS[$idx]=${CORE_CATEGORY_PATHS[$idx]}"
done

for idx in "${!ADDITIONAL_REPOSITORIES[@]}"; do
	ADDITIONAL_REPOSITORIES[$idx]="${ADDITIONAL_REPOSITORIES[$idx]/\/media\/fat/${BASE_PATH}}"
	ADDITIONAL_REPOSITORIES[$idx]="${ADDITIONAL_REPOSITORIES[$idx]/@GAMES_SUBDIR@/${GAMES_SUBDIR}}"
	#echo "ADDITIONAL_REPOSITORIES[$idx]=${ADDITIONAL_REPOSITORIES[$idx]}"
done

mkdir -p "${CORE_CATEGORY_PATHS[@]}"
if [ "${MAME_ARCADE_ROMS}" == "true" ]
then
	if ls ${CORE_CATEGORY_PATHS["arcade-cores"]}/*.rbf > /dev/null 2>&1 && ! ls ${CORE_CATEGORY_PATHS["arcade-cores"]}/*.mra > /dev/null 2>&1
	then
		echo "Backupping ${CORE_CATEGORY_PATHS["arcade-cores"]}"
		echo "into ${CORE_CATEGORY_PATHS["arcade-cores"]}_backup_$(date -u +%Y%m%d)"
		echo "please wait..."
		cp -r "${CORE_CATEGORY_PATHS["arcade-cores"]}" "${CORE_CATEGORY_PATHS["arcade-cores"]}_backup_$(date -u +%Y%m%d)"
		echo "...done."
		echo ""
	fi
	mkdir -p "${CORE_CATEGORY_PATHS["arcade-cores"]}/cores"
	
#if [ ! -d "${CORE_CATEGORY_PATHS["arcade-cores"]}/mame" ] && [ ! -d "${GAMES_SUBDIR}/mame" ]
	#then
	#	if [ "${GAMES_SUBDIR}" == "${BASE_PATH}" ]
	#	then
	#		mkdir -p "${CORE_CATEGORY_PATHS["arcade-cores"]}/mame"
	#	else
	#		mkdir -p "${GAMES_SUBDIR}/mame"
	#	fi
	#fi
	#if [ -d "${BASE_PATH}/games/mame" ] && [ "$(find ${BASE_PATH}/games/mame -type f -print -quit 2> /dev/null)" == "" ] && [ "$(find $	#{CORE_CATEGORY_PATHS["arcade-cores"]}/mame -type f -print -quit 2> /dev/null)" != "" ]
#	then
#		echo "Deleting empty ${BASE_PATH}/games/mame since ${CORE_CATEGORY_PATHS["arcade-cores"]}/mame is not empty"
#		echo ""
#		rm -R "${BASE_PATH}/games/mame" > /dev/null 2>&1
#	fi
#	if [ ! -d "${CORE_CATEGORY_PATHS["arcade-cores"]}/hbmame" ] && [ ! -d "${GAMES_SUBDIR}/hbmame" ]
#	then
#		if [ "${GAMES_SUBDIR}" == "${BASE_PATH}" ]
#		then
#			mkdir -p "${CORE_CATEGORY_PATHS["arcade-cores"]}/hbmame"
#		else
#			mkdir -p "${GAMES_SUBDIR}/hbmame"
#		fi
#	fi

#	if [ -d "${BASE_PATH}/games/hbmame" ] && [ "$(find ${BASE_PATH}/games/hbmame -type f -print -quit 2> /dev/null)" == "" ] && [ "$(find $#{CORE_CATEGORY_PATHS["arcade-cores"]}/hbmame -type f -print -quit 2> /dev/null)" != "" ]
#	then
#		echo "Deleting empty ${BASE_PATH}/games/hbmame since ${CORE_CATEGORY_PATHS["arcade-cores"]}/hbmame is not empty"
#		echo ""
#		rm -R "${BASE_PATH}/games/hbmame" > /dev/null 2>&1
#	fi

#	mv "${CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup/"*.mra "${CORE_CATEGORY_PATHS["arcade-cores"]}/" > /dev/null 2>&1
#	find "${CORE_CATEGORY_PATHS["arcade-cores"]}" -maxdepth 1 -type f -name '*.mra' -size +165000c -size -166000c -delete
#	rm "${CORE_CATEGORY_PATHS["arcade-cores"]}/Arkanoid (unl.lives%2C slower).mra" > /dev/null 2>&1
#elif [ "${MAME_ARCADE_ROMS}" == "false" ]
#then
#	mv "${CORE_CATEGORY_PATHS["arcade-cores"]}/cores/"*.rbf "${CORE_CATEGORY_PATHS["arcade-cores"]}/" > /dev/null 2>&1
#	mkdir -p "${CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup"
#	mv "${CORE_CATEGORY_PATHS["arcade-cores"]}/"*.mra "${CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup/" > /dev/null 2>&1
fi

#if [ "${MAME_ALT_ROMS}" == "true" ]
#then
#	mv "${CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup/_alternatives/" "${CORE_CATEGORY_PATHS["arcade-cores"]}/_alternatives/" > /dev/null 2>&1
#elif [ "${MAME_ALT_ROMS}" == "false" ]
#then
#	mkdir -p "${CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup"
#	mv "${CORE_CATEGORY_PATHS["arcade-cores"]}/_alternatives/" "${CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup/_alternatives/" > /dev/null 2>&1
#fi

rm "${BASE_PATH}/"Arduboy_*.rbf > /dev/null 2>&1

declare -A NEW_CORE_CATEGORY_PATHS
if [ "$DOWNLOAD_NEW_CORES" != "true" ] && [ "$DOWNLOAD_NEW_CORES" != "false" ] && [ "$DOWNLOAD_NEW_CORES" != "" ]
then
	for idx in "${!CORE_CATEGORY_PATHS[@]}"; do
		NEW_CORE_CATEGORY_PATHS[$idx]=$(echo ${CORE_CATEGORY_PATHS[$idx]} | sed "s/$(echo $BASE_PATH | sed 's/\//\\\//g')/$(echo $BASE_PATH | sed 's/\//\\\//g')\/$DOWNLOAD_NEW_CORES/g")
	done
	mkdir -p "${NEW_CORE_CATEGORY_PATHS[@]}"
	if [ "${MAME_ARCADE_ROMS}" == "true" ]
	then
		mkdir -p "${NEW_CORE_CATEGORY_PATHS["arcade-cores"]}/cores"
		mv "${NEW_CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup/"*.mra "${NEW_CORE_CATEGORY_PATHS["arcade-cores"]}/" > /dev/null 2>&1
	elif [ "${MAME_ARCADE_ROMS}" == "false" ]
	then
		mv "${NEW_CORE_CATEGORY_PATHS["arcade-cores"]}/cores/"*.rbf "${NEW_CORE_CATEGORY_PATHS["arcade-cores"]}/" > /dev/null 2>&1
		mkdir -p "${NEW_CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup"
		mv "${NEW_CORE_CATEGORY_PATHS["arcade-cores"]}/"*.mra "${NEW_CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup/" > /dev/null 2>&1
	fi
fi

UPDATED_CORES_FILE=$(mktemp)
ERROR_CORES_FILE=$(mktemp)
UPDATED_ADDITIONAL_REPOSITORIES_FILE=$(mktemp)
ERROR_ADDITIONAL_REPOSITORIES_FILE=$(mktemp)

[ "${UPDATE_LINUX}" == "true" ] && SD_INSTALLER_URL="https://github.com/MiSTer-devel/SD-Installer-Win64_MiSTer"

#echo "Downloading MiSTer Wiki structure"
#echo ""
#CORE_URLS=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "$MISTER_URL/wiki"| awk '/user-content-fpga-cores/,/user-content-development/' | grep -io '\(https://github.com/[a-zA-Z0-9./_-]*_MiSTer\)\|\(user-content-[a-zA-Z0-9-]*\)')
#CORE_URLS=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "$MISTER_URL/wiki"| awk '/user-content-fpga-cores/,/user-content-development/' | grep -ioE '(https://github.com/[a-zA-Z0-9./_-]*[_-]MiSTer)|(user-content-[a-zA-Z0-9-]*)')
#MENU_URL=$(echo "${CORE_URLS}" | grep -io 'https://github.com/[a-zA-Z0-9./_-]*Menu_MiSTer')
#CORE_URLS=$(echo "${CORE_URLS}" |  sed 's/https:\/\/github.com\/[a-zA-Z0-9.\/_-]*Menu_MiSTer//')
#CORE_URLS=${SD_INSTALLER_URL}$'\n'${MISTER_URL}$'\n'${MENU_URL}$'\n'${CORE_URLS}$'\n'"user-content-arcade-cores"$'\n'$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "$MISTER_URL/wiki/Arcade-Cores-List"| awk '/wiki-content/,/wiki-rightbar/' | grep -io '\(https://github.com/[a-zA-Z0-9./_-]*_MiSTer\)' | awk '!a[$0]++')

if [ "$REPOSITORIES_FILTER" != "" ]
then
	#CORE_CATEGORIES_FILTER="^\($( echo "$REPOSITORIES_FILTER" | sed 's/[ 	]\{1,\}/\\)\\|\\(/g' )\)$"
	#REPOSITORIES_FILTER="\(Main_MiSTer\)\|\(Menu_MiSTer\)\|\(SD-Installer-Win64_MiSTer\)\|\($( echo "$REPOSITORIES_FILTER" | sed 's/[ 	]\{1,\}/\\)\\|\\([\/_-]/g' )\)"
	CORE_CATEGORIES_FILTER_REGEX="^($( echo "$REPOSITORIES_FILTER" | sed 's/[ 	]\{1,\}/)|(/g' ))$"
	REPOSITORIES_FILTER_REGEX="(Main_MiSTer)|(Menu_MiSTer)|(SD-Installer-Win64_MiSTer)|([\/_-]$( echo "$REPOSITORIES_FILTER" | sed 's/[ 	]\{1,\}/)|([\/_-]/g' ))"
fi
if [ "$REPOSITORIES_NEGATIVE_FILTER" != "" ]
then
	CORE_CATEGORIES_NEGATIVE_FILTER_REGEX="^($( echo "$REPOSITORIES_NEGATIVE_FILTER" | sed 's/[ 	]\{1,\}/)|(/g' ))$"
	REPOSITORIES_NEGATIVE_FILTER_REGEX="([\/_-]$( echo "$REPOSITORIES_NEGATIVE_FILTER" | sed 's/[ 	]\{1,\}/)|([\/_-]/g' ))"
fi
CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER=""
LAST_SUCCESSFUL_RUN_PATH="${WORK_PATH}/$(basename ${RUN_NAME%.*}.last_successful_run)"
if [ -f ${LAST_SUCCESSFUL_RUN_PATH} ]
then
	LAST_SUCCESSFUL_RUN_DATETIME_UTC=$(cat "${LAST_SUCCESSFUL_RUN_PATH}" | sed '1q;d')
	LAST_SUCCESSFUL_RUN_INI_DATETIME_UTC=$(cat "${LAST_SUCCESSFUL_RUN_PATH}" | sed '2q;d')
	LAST_SUCCESSFUL_RUN_UPDATER_VERSION=$(cat "${LAST_SUCCESSFUL_RUN_PATH}" | sed '3q;d')
	
	if [ "${MISTER_DEVEL_REPOS_URL}" != "" ] && [ "${INI_DATETIME_UTC}" == "${LAST_SUCCESSFUL_RUN_INI_DATETIME_UTC}" ] && [ "${UPDATER_VERSION}" == "${LAST_SUCCESSFUL_RUN_UPDATER_VERSION}" ]
	then
		echo "Downloading ${MISTER_DEVEL_REPOS_URL} updates"
		echo ""
		API_PAGE=1
		API_RESPONSE=$(curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} -sSLf "${MISTER_DEVEL_REPOS_URL}?per_page=100&page=${API_PAGE}" | grep -oE '("svn_url": "[^"]*)|("updated_at": "[^"]*)' | sed 's/"svn_url": "//; s/"updated_at": "//')
		until [ "${API_RESPONSE}" == "" ]; do
			for API_RESPONSE_LINE in $API_RESPONSE; do
				if [[ "${API_RESPONSE_LINE}" =~ https: ]]
				then
					if [[ "${LAST_SUCCESSFUL_RUN_DATETIME_UTC}" < "${REPO_UPDATE_DATETIME_UTC}" ]]
					then
						CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER="${CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER} ${API_RESPONSE_LINE##*/}"
					fi
				else
					REPO_UPDATE_DATETIME_UTC="${API_RESPONSE_LINE}"
				fi
			done
			API_PAGE=$((API_PAGE+1))
			API_RESPONSE=$(curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} -sSLf "${MISTER_DEVEL_REPOS_URL}?per_page=100&page=${API_PAGE}" | grep -oE '("svn_url": "[^"]*)|("updated_at": "[^"]*)' | sed 's/"svn_url": "//; s/"updated_at": "//')
		done
		if [ "${CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER}" != "" ]
		then
			CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER=$(echo "${CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER}" | cut -c2- )
		else
			CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER="ZZZZZZZZZ"
		fi
		
		echo "Performing an optimized update checking only repositories"
		echo "updated after $(date -d ${LAST_SUCCESSFUL_RUN_DATETIME_UTC})"
		echo ""		
		echo "If you want a full updater resync please delete:${LAST_SUCCESSFUL_RUN_PATH}"
		#echo "${LAST_SUCCESSFUL_RUN_PATH}"
		echo ""
	else
		echo "Performing a full updater resync because"
		if [ "${UPDATER_VERSION}" != "${LAST_SUCCESSFUL_RUN_UPDATER_VERSION}" ]
		then
			echo "a new updater has been released"
		fi
		if [ "${INI_DATETIME_UTC}" != "${LAST_SUCCESSFUL_RUN_INI_DATETIME_UTC}" ]
		then
			echo "${INI_PATH} was modified"
		fi
		echo ""
	fi
else
	echo "Performing a full updater resync"
	echo ""
fi
if [ "$CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER" != "" ]
then
	CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER_REGEX="([\/_-]$( echo "$CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER" | sed 's/[ 	]\{1,\}/)|([\/_-]/g' ))"
fi

GOOD_CORES=""
if [ "$GOOD_CORES_URL" != "" ]
then
	GOOD_CORES=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "$GOOD_CORES_URL")
fi

function checkCoreURL {
	[[ ${CORE_URL} =~ ^([a-zA-Z]+://)?github.com(:[0-9]+)?/([a-zA-Z0-9_-]*)/.*$ ]] || true
	local DOMAIN_URL=${BASH_REMATCH[3]}

	echo "Checking $(sed 's/.*\/// ; s/_MiSTer//' <<< "${CORE_URL}")"
	[ "${SSH_CLIENT}" != "" ] && echo "URL: $CORE_URL"
	# if echo "$CORE_URL" | grep -qE "SD-Installer"
	# then
	# 	RELEASES_URL="$CORE_URL"
	# else
	# 	RELEASES_URL=https://github.com$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "$CORE_URL" | grep -oi '/'${DOMAIN_URL}'/[a-zA-Z0-9./_-]*/tree/[a-zA-Z0-9./_-]*/releases' | head -n1)
	# fi
	case "$CORE_URL" in
		*SD-Installer*)
			RELEASES_URL="$CORE_URL"
			;;
		*Minimig*)
			RELEASES_URL="${CORE_URL}/file-list/MiSTer/releases"
			;;
		*jotego/jtbin*)
			RELEASES_URL="https://github.com/jotego/jtbin/file-list/master/mister/$(basename ${CORE_URL})/releases"
			;;
		*)
			RELEASES_URL="${CORE_URL}/file-list/master/releases"
			;;
	esac
	RELEASES_HTML=""
	RELEASES_HTML=$(curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} -sSLf "${RELEASES_URL}")
	RELEASE_URLS=$(echo ${RELEASES_HTML} | grep -oE '/'${DOMAIN_URL}'/[a-zA-Z0-9./_-]*_[0-9]{8}[a-zA-Z]?(\.rbf|\.rar|\.zip)?')
	
	CORE_HAS_MRA="false"
	#if  [ "${CORE_CATEGORY}" == "arcade-cores" ] && [ "${MAME_ARCADE_ROMS}" == "true" ] && { echo "${RELEASES_HTML}" | grep -qE '/'${DOMAIN_URL}'/[a-zA-Z0-9./_%&#;!()-]*\.mra'; }
	if  [ "${CORE_CATEGORY}" == "arcade-cores" ] && [ "${MAME_ARCADE_ROMS}" == "true" ] && [[ "${RELEASES_HTML}" =~ /${DOMAIN_URL}/[a-zA-Z0-9./_%\&#\;!()-]*\.mra ]]
	then
		CORE_HAS_MRA="true"
	fi
	
	MAX_VERSION=""
	MAX_RELEASE_URL=""
	GOOD_CORE_VERSION=""
	for RELEASE_URL in $RELEASE_URLS; do
		#if echo "$RELEASE_URL" | grep -q "SharpMZ"
		if [[ "${RELEASE_URL}" =~ SharpMZ ]]
		then
			RELEASE_URL=$(echo "$RELEASE_URL"  | grep '\.rbf$')
		fi			
		#if echo "$RELEASE_URL" | grep -q "Atari800"
		if [[ "${RELEASE_URL}" =~ Atari800 ]]
		then
			if [ "$CORE_CATEGORY" == "cores" ] || [ "$CORE_CATEGORY" == "computer-cores" ]
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
	if [ "$CORE_CATEGORY" == "arcade-cores" ] && [ $REMOVE_ARCADE_PREFIX == "true" ]
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
	#if [ "$BASE_FILE_NAME" == "MiSTer" ] || [ "$BASE_FILE_NAME" == "menu" ] || { echo "$CORE_URL" | grep -qE "SD-Installer|Filters_MiSTer"; }
	if [ "$BASE_FILE_NAME" == "MiSTer" ] || [ "$BASE_FILE_NAME" == "menu" ] || [[ "${CORE_URL}" =~ SD-Installer|Filters_MiSTer|MRA-Alternatives_MiSTer ]]
	then
		mkdir -p "$WORK_PATH"
		CURRENT_DIRS=("$WORK_PATH")
	fi
	
	CURRENT_LOCAL_VERSION=""
	MAX_LOCAL_VERSION=""
	for CURRENT_DIR in "${CURRENT_DIRS[@]}"
	do
		if [ "${CORE_CATEGORY}" == "arcade-cores" ] && [ "${MAME_ARCADE_ROMS}" == "true" ] && [ "${CORE_HAS_MRA}" == "false" ]
		then
			case "${BASE_FILE_NAME}" in
				"CrushRoller")
					[ -f "${CURRENT_DIR}/Crush Roller.mra" ] && { CORE_HAS_MRA="true"; }
					;;
				"MrTNT")
					[ -f "${CURRENT_DIR}/mr. tnt.mra" ] && { CORE_HAS_MRA="true"; }
					;;
				"MsPacman")
					[ -f "${CURRENT_DIR}/Ms. Pacman.mra" ] && { CORE_HAS_MRA="true"; }
					;;
				"PacmanClub")
					[ -f "${CURRENT_DIR}/Pacman Club.mra" ] && { CORE_HAS_MRA="true"; }
					;;
				"PacmanPlus")
					[ -f "${CURRENT_DIR}/Pacman Plus.mra" ] && { CORE_HAS_MRA="true"; }
					;;
				*)
					[ -f "${CURRENT_DIR}/${BASE_FILE_NAME}.mra" ] && { CORE_HAS_MRA="true"; }
					;;
			esac
		fi
		if [ "${CORE_HAS_MRA}" == "true" ]
		then
			mv "${CURRENT_DIR}/${BASE_FILE_NAME}"_*.rbf "${CURRENT_DIR}/cores/" > /dev/null 2>&1
			CURRENT_DIR="${CURRENT_DIR}/cores"
		fi
		for CURRENT_FILE in "$CURRENT_DIR/$BASE_FILE_NAME"*
		do
			if [ -f "$CURRENT_FILE" ]
			then
				#if echo "$CURRENT_FILE" | grep -q "$BASE_FILE_NAME\_[0-9]\{8\}[a-zA-Z]\?\(\.rbf\|\.rar\|\.zip\)\?$"
				if [[ "${CURRENT_FILE}" =~ ${BASE_FILE_NAME}_[0-9]{8}[a-zA-Z]?(\.rbf|\.rar|\.zip)?$ ]]
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
	
	[[ "${CORE_URL}" =~ SD-Installer ]] && [ -f /MiSTer.version ] && MAX_LOCAL_VERSION="20$(cat /MiSTer.version)"
	
	if [ "${BASE_FILE_NAME}" == "MiSTer" ] || [ "${BASE_FILE_NAME}" == "menu" ]
	then
		if [[ "${MAX_VERSION}" == "${MAX_LOCAL_VERSION}" ]]
		then
			#DESTINATION_FILE=$(echo "${MAX_RELEASE_URL}" | sed 's/.*\///g' | sed 's/_[0-9]\{8\}[a-zA-Z]\{0,1\}//g')
			DESTINATION_FILE=$(echo "${MAX_RELEASE_URL}" | sed 's/.*\///g; s/_[0-9]\{8\}[a-zA-Z]\{0,1\}//g')
			ACTUAL_CRC=$(md5sum "/media/fat/${DESTINATION_FILE}" | grep -o "^[^ ]*")
			SAVED_CRC=$(cat "${WORK_PATH}/${FILE_NAME}")
			if [ "$ACTUAL_CRC" != "$SAVED_CRC" ]
			then
				mv "${CURRENT_FILE}" "${CURRENT_FILE}.${TO_BE_DELETED_EXTENSION}" > /dev/null 2>&1
				MAX_LOCAL_VERSION=""
			fi
		fi
	fi
	
	if [[ "$MAX_VERSION" > "$MAX_LOCAL_VERSION" ]]
	then
		#if [ "$DOWNLOAD_NEW_CORES" != "false" ] || [ "$MAX_LOCAL_VERSION" != "" ] || [ "$BASE_FILE_NAME" == "MiSTer" ] || [ "$BASE_FILE_NAME" == "menu" ] || { echo "$CORE_URL" | grep -qE "SD-Installer|Filters_MiSTer"; }
		if [ "$DOWNLOAD_NEW_CORES" != "false" ] || [ "$MAX_LOCAL_VERSION" != "" ] || [ "$BASE_FILE_NAME" == "MiSTer" ] || [ "$BASE_FILE_NAME" == "menu" ] || [[ "${CORE_URL}" =~ SD-Installer|Filters_MiSTer|MRA-Alternatives_MiSTer ]]
		then
			echo "Downloading $FILE_NAME to $CURRENT_DIR/$FILE_NAME"
			[ "${SSH_CLIENT}" != "" ] && echo "URL: https://github.com$MAX_RELEASE_URL?raw=true"
			if curl $CURL_RETRY $SSL_SECURITY_OPTION $([ "${PARALLEL_UPDATE}" == "true" ] && echo "-sS") -# -L "https://github.com$MAX_RELEASE_URL?raw=true" -o "$CURRENT_DIR/$FILE_NAME"
			then
				if [ ${DELETE_OLD_FILES} == "true" ]
				then
					echo "Deleting old ${BASE_FILE_NAME} files"
					rm "${CURRENT_DIR}/${BASE_FILE_NAME}"*.${TO_BE_DELETED_EXTENSION} > /dev/null 2>&1
				fi
				if [ $BASE_FILE_NAME == "MiSTer" ] || [ $BASE_FILE_NAME == "menu" ]
				then
					#DESTINATION_FILE=$(echo "$MAX_RELEASE_URL" | sed 's/.*\///g' | sed 's/_[0-9]\{8\}[a-zA-Z]\{0,1\}//g')
					DESTINATION_FILE=$(echo "$MAX_RELEASE_URL" | sed 's/.*\///g; s/_[0-9]\{8\}[a-zA-Z]\{0,1\}//g')
					echo "Moving $DESTINATION_FILE"
					rm "/media/fat/$DESTINATION_FILE" > /dev/null 2>&1
					mv "$CURRENT_DIR/$FILE_NAME" "/media/fat/$DESTINATION_FILE"
					echo "$(md5sum "/media/fat/${DESTINATION_FILE}" | grep -o "^[^ ]*")" > "${CURRENT_DIR}/${FILE_NAME}"
					REBOOT_NEEDED="true"
				fi
				#if echo "$CORE_URL" | grep -q "SD-Installer"
				if [[ "${CORE_URL}" =~ SD-Installer ]]
				then
					SD_INSTALLER_PATH="$CURRENT_DIR/$FILE_NAME"
				fi
				#if echo "$CORE_URL" | grep -q "Filters_MiSTer"
				if [[ "${CORE_URL}" =~ Filters_MiSTer|MRA-Alternatives_MiSTer ]]
				then
					echo "Extracting ${FILE_NAME}"
					if [[ "${CORE_URL}" =~ MRA-Alternatives_MiSTer ]]
					then
						unzip -o "${WORK_PATH}/${FILE_NAME}" -d "${CORE_CATEGORY_PATHS["arcade-cores"]}/$ARCADE_SUBFOLDER" 1>&2
					else
						unzip -o "${WORK_PATH}/${FILE_NAME}" -d "${BASE_PATH}" 1>&2
					fi
					rm "${WORK_PATH}/${FILE_NAME}" > /dev/null 2>&1
					touch "${WORK_PATH}/${FILE_NAME}" > /dev/null 2>&1
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
										#if [ -f "$ARCADE_HACK_CORE" ] && { echo "$ARCADE_HACK_CORE" | grep -q "$BASE_FILE_NAME\_[0-9]\{8\}[a-zA-Z]\?\.rbf$"; }
										if [ -f "${ARCADE_HACK_CORE}" ] && [[ "${ARCADE_HACK_CORE}" =~ ${BASE_FILE_NAME}_[0-9]{8}[a-zA-Z]?\.rbf$ ]]
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
				if [ "$CREATE_CORES_DIRECTORIES" != "false" ] && [ "$MAX_LOCAL_VERSION" == "" ]
				then
					if [ "$BASE_FILE_NAME" != "menu" ] && [ "$CORE_CATEGORY" == "cores" ] || [ "$CORE_CATEGORY" == "computer-cores" ] || [ "$CORE_CATEGORY" == "console-cores" ]
					then
						CORE_SOURCE_URL=""
						CORE_INTERNAL_NAME=""
						case "${BASE_FILE_NAME}" in
							"Minimig")
								CORE_INTERNAL_NAME="Amiga"
								;;
							"Apple-I"|"C64"|"PDP1"|"NeoGeo"|"AY-3-8500")
								CORE_INTERNAL_NAME="${BASE_FILE_NAME}"
								;;
							"SharpMZ")
								CORE_INTERNAL_NAME="SHARP MZ SERIES"
								;;
							*)
								CORE_SOURCE_URL="$(echo "https://github.com$MAX_RELEASE_URL" | sed 's/releases.*//g')${BASE_FILE_NAME}.sv"
								CORE_INTERNAL_NAME="$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "${CORE_SOURCE_URL}?raw=true" | awk '/CONF_STR[^=]*=/,/;/' | grep -oE -m1 '".*?;' | sed 's/[";]//g')"
								;;
						esac
						if [ "$CORE_INTERNAL_NAME" != "" ]
						then
							echo "Creating ${GAMES_SUBDIR}/${CORE_INTERNAL_NAME} directory"
							mkdir -p "${GAMES_SUBDIR}/${CORE_INTERNAL_NAME}"
						fi
					fi
				fi
				if [[ "${CORE_URL}" =~ Filters_MiSTer|MRA-Alternatives_MiSTer ]]
				then
					echo -n ", ${FILE_NAME}" >> "${UPDATED_ADDITIONAL_REPOSITORIES_FILE}"
				else
					echo -n ", ${FILE_NAME}" >> "${UPDATED_CORES_FILE}"
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
				if [[ "${CORE_URL}" =~ Filters_MiSTer|MRA-Alternatives_MiSTer ]]
				then
					echo -n ", ${FILE_NAME}" >> "${ERROR_ADDITIONAL_REPOSITORIES_FILE}"
				else
					echo -n ", ${FILE_NAME}" >> "${ERROR_CORES_FILE}"
				fi
				echo "If you experience frequent download errors"
				echo "maybe the parallel update is hitting your network too hard"
				echo "please try PARALLEL_UPDATE=\"false\" in"
				echo "${INI_PATH}"
			fi
			sync
		else
			echo "New core: $FILE_NAME"
		fi
	else
		echo "Nothing to update"
	fi
	
	if [ "${CORE_HAS_MRA}" == "true" ] && [ "${RELEASES_HTML}" != "" ]
	then
		ADDITIONAL_REPOSITORY="MRA files|mra|${CURRENT_DIR%%\/cores}"
		checkAdditionalRepository
		ADDITIONAL_REPOSITORY=""
	else
		echo ""
	fi
	RELEASES_HTML=""
}

function checkAdditionalRepository {
	[[ ${ADDITIONAL_FILES_URL} =~ ^([a-zA-Z]+://)?github.com(:[0-9]+)?/([a-zA-Z0-9_-]*)/.*$ ]] || true
	local DOMAIN_URL=${BASH_REMATCH[3]}

	OLD_IFS="$IFS"
	IFS="|"
	PARAMS=($ADDITIONAL_REPOSITORY)
	ADDITIONAL_FILES_URL="${PARAMS[0]}"
	ADDITIONAL_FILES_EXTENSIONS="\($(echo ${PARAMS[1]} | sed 's/ \{1,\}/\\|/g')\)"
	CURRENT_DIR="${PARAMS[2]}"
	IFS="$OLD_IFS"
	
	echo "Checking $(echo $ADDITIONAL_FILES_URL | sed 's/.*\///g' | awk '{ print toupper( substr( $0, 1, 1 ) ) substr( $0, 2 ); }')"
	if ! [[ "${ADDITIONAL_FILES_URL}" == https://github.com/${DOMAIN_URL}/* ]] || [ "$CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER" == "" ] || [[ "${ADDITIONAL_FILES_URL^^}" =~ ${CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER_REGEX^^} ]]
	then
		if [ ! -d "$CURRENT_DIR" ]
		then
			mkdir -p "$CURRENT_DIR"
		fi
		[ "${SSH_CLIENT}" != "" ] && [[ $ADDITIONAL_FILES_URL == http* ]] && echo "URL: $ADDITIONAL_FILES_URL"
		#if echo "$ADDITIONAL_FILES_URL" | grep -q "\/tree\/master\/"
		if [[ "${ADDITIONAL_FILES_URL}" =~ /tree/master/ ]]
		then
			ADDITIONAL_FILES_URL=$(echo "$ADDITIONAL_FILES_URL" | sed 's/\/tree\/master\//\/file-list\/master\//g')
		else
			ADDITIONAL_FILES_URL="$ADDITIONAL_FILES_URL/file-list/master"
		fi
		if [ "${RELEASES_HTML}" == "" ]
		then
			CONTENT_HTML=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "$ADDITIONAL_FILES_URL")
		else
			CONTENT_HTML="${RELEASES_HTML}"
		fi
		#ADDITIONAL_FILE_DATETIMES=$(echo "$CONTENT_TDS" | awk '/class="age">/,/<\/td>/' | tr -d '\n' | sed 's/ \{1,\}/+/g' | sed 's/<\/td>/\n/g')
		#ADDITIONAL_FILE_DATETIMES=$(echo "$CONTENT_TDS" | awk '/class="age">/,/<\/td>/' | tr -d '\n' | sed 's/ \{1,\}/+/g; s/<\/td>/\n/g')
		#ADDITIONAL_FILE_DATETIMES=$(echo "$CONTENT_TDS" | grep -oE 'datetime="[^"]*"' | sed 's/datetime="//; s/"/ /' | tr -d '\n')
		ADDITIONAL_FILE_DATETIMES=$(echo "$CONTENT_HTML" | grep -oE 'datetime="[^"]*' | sed 's/datetime="//')
		ADDITIONAL_FILE_DATETIMES=( $ADDITIONAL_FILE_DATETIMES )
		#for DATETIME_INDEX in "${!ADDITIONAL_FILE_DATETIMES[@]}"; do 
		#	ADDITIONAL_FILE_DATETIMES[$DATETIME_INDEX]=$(echo "${ADDITIONAL_FILE_DATETIMES[$DATETIME_INDEX]}" | grep -o "[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}Z" )
		#	if [ "${ADDITIONAL_FILE_DATETIMES[$DATETIME_INDEX]}" == "" ]
		#	then
		#		ADDITIONAL_FILE_DATETIMES[$DATETIME_INDEX]="${ADDITIONAL_FILE_DATETIMES[$((DATETIME_INDEX-1))]}"
		#	fi
		#done
		#CONTENT_TDS=$(echo "$CONTENT_TDS" | awk '/class="content">/,/<\/td>/' | tr -d '\n' | sed 's/ \{1,\}/+/g' | sed 's/<\/td>/\n/g')
		#CONTENT_TDS=$(echo "$CONTENT_TDS" | awk '/class="content">/,/<\/td>/' | tr -d '\n' | sed 's/ \{1,\}/+/g; s/<\/td>/\n/g')
		ADDITIONAL_FILE_URLS=$(echo "$CONTENT_HTML" | grep -oE 'js-navigation-open link-gray-dark[^>]*' | sed 's/.*href="//; s/"//')
		#ADDITIONAL_FILE_URLS=$(echo "$CONTENT_TDS" | grep -oE 'js-navigation-open link-gray-dark[^>]*')
		CONTENT_INDEX=0
		#for CONTENT_TD in $CONTENT_TDS; do
		for ADDITIONAL_FILE_URL in $ADDITIONAL_FILE_URLS; do
			#ADDITIONAL_FILE_URL=$(echo "$CONTENT_TD" | grep -o "href=\(\"\|\'\)[a-zA-Z0-9%&#;!()./_-]*\.$ADDITIONAL_FILES_EXTENSIONS\(\"\|\'\)" | sed "s/href=//g" | sed "s/\(\"\|\'\)//g")
			#ADDITIONAL_FILE_URL=$(echo "$CONTENT_TD" | grep -o "href=\(\"\|\'\)[a-zA-Z0-9%&#;!()./_-]*\.$ADDITIONAL_FILES_EXTENSIONS\(\"\|\'\)" | sed "s/href=//g; s/\(\"\|\'\)//g; s/&#39;/'/g")
			#ADDITIONAL_FILE_URL=$(echo "${ADDITIONAL_FILE_URL}" | grep -o "href=\(\"\|\'\)[a-zA-Z0-9%&#;!()./_-]*\.$ADDITIONAL_FILES_EXTENSIONS\(\"\|\'\)" | sed "s/href=//g; s/\(\"\|\'\)//g; s/&#39;/'/g")
			ADDITIONAL_FILE_URL=$(echo "${ADDITIONAL_FILE_URL}" | grep "\.$ADDITIONAL_FILES_EXTENSIONS$" | sed "s/&#39;/'/g")
			if [ "$ADDITIONAL_FILE_URL" != "" ]
			then
				#ADDITIONAL_FILE_NAME=$(echo "$ADDITIONAL_FILE_URL" | sed 's/.*\///g' | sed 's/%20/ /g; s/&#39;/'\''/g')
				#ADDITIONAL_FILE_NAME=$(echo "$ADDITIONAL_FILE_URL" | sed 's/.*\///g' | sed 's/%20/ /g')
				ADDITIONAL_FILE_NAME=$(echo "$ADDITIONAL_FILE_URL" | sed 's/.*\///g; s/%20/ /g; s/%2C/,/g')
				ADDITIONAL_ONLINE_FILE_DATETIME=${ADDITIONAL_FILE_DATETIMES[$CONTENT_INDEX]}
				if [ -f "$CURRENT_DIR/$ADDITIONAL_FILE_NAME" ]
				then
					ADDITIONAL_LOCAL_FILE_DATETIME=$(date -d "$(stat -c %y "$CURRENT_DIR/$ADDITIONAL_FILE_NAME" 2>/dev/null)" -u +"%Y-%m-%dT%H:%M:%SZ")
				else
					ADDITIONAL_LOCAL_FILE_DATETIME=""
				fi
				
				#echo "---------"
				#echo "CONTENT_INDEX=${CONTENT_INDEX}"
				#echo "ADDITIONAL_FILE_URL=${ADDITIONAL_FILE_URL}"
				#echo "ADDITIONAL_ONLINE_FILE_DATETIME=${ADDITIONAL_ONLINE_FILE_DATETIME}"
				#echo "ADDITIONAL_FILE_NAME=${ADDITIONAL_FILE_NAME}"
				#echo "ADDITIONAL_LOCAL_FILE_DATETIME=${ADDITIONAL_LOCAL_FILE_DATETIME}"
				
				if [ "$ADDITIONAL_LOCAL_FILE_DATETIME" == "" ] || [[ "$ADDITIONAL_ONLINE_FILE_DATETIME" > "$ADDITIONAL_LOCAL_FILE_DATETIME" ]]
				then
					echo "Downloading $ADDITIONAL_FILE_NAME"
					[ "${SSH_CLIENT}" != "" ] && echo "URL: https://github.com$ADDITIONAL_FILE_URL?raw=true"
					mv "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}" "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}.${TO_BE_DELETED_EXTENSION}" > /dev/null 2>&1
					if curl $CURL_RETRY $SSL_SECURITY_OPTION $([ "${PARALLEL_UPDATE}" == "true" ] && echo "-sS") -# -L "https://github.com$ADDITIONAL_FILE_URL?raw=true" -o "$CURRENT_DIR/$ARCADE_SUBFOLDER/$ADDITIONAL_FILE_NAME"
					then
						rm "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}.${TO_BE_DELETED_EXTENSION}" > /dev/null 2>&1
						if [[ "${ADDITIONAL_FILE_NAME}" =~ \.mra ]]
						then
							echo -n ", ${ADDITIONAL_FILE_NAME}" >> "${UPDATED_CORES_FILE}"
						else
							echo -n ", ${ADDITIONAL_FILE_NAME}" >> "${UPDATED_ADDITIONAL_REPOSITORIES_FILE}"
						fi
					else
						echo "${ADDITIONAL_FILE_NAME} download failed"
						echo "Restoring old ${ADDITIONAL_FILE_NAME} file"
						rm "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}" > /dev/null 2>&1
						mv "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}.${TO_BE_DELETED_EXTENSION}" "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}" > /dev/null 2>&1
						if [[ "${ADDITIONAL_FILE_NAME}" =~ \.mra ]]
						then
							echo -n ", ${ADDITIONAL_FILE_NAME}" >> "${ERROR_CORES_FILE}"
						else
							echo -n ", ${ADDITIONAL_FILE_NAME}" >> "${ERROR_ADDITIONAL_REPOSITORIES_FILE}"
						fi
						echo "If you experience frequent download errors"
						echo "maybe the parallel update is hitting your network too hard"
						echo "please try PARALLEL_UPDATE=\"false\" in"
						echo "${INI_PATH}"
					fi
					sync
					echo ""
				fi
			fi
			CONTENT_INDEX=$((CONTENT_INDEX+1))
		done
		echo ""
	fi
	
}

if [ "${CORE_CATEGORY_PATHS["cores"]}" != "" ]
then
	CORE_CATEGORY_PATHS["computer-cores"]="${CORE_CATEGORY_PATHS["cores"]}"
fi
REPOSITORIES_FILTER_REGEX="${REPOSITORIES_FILTER_REGEX/]cores)/]computer-cores)}"
CORE_CATEGORIES_FILTER_REGEX="${CORE_CATEGORIES_FILTER_REGEX/(cores)/(computer-cores)}"
REPOSITORIES_NEGATIVE_FILTER_REGEX="${REPOSITORIES_NEGATIVE_FILTER_REGEX/]cores)/]computer-cores)}"
CORE_CATEGORIES_NEGATIVE_FILTER_REGEX="${CORE_CATEGORIES_NEGATIVE_FILTER_REGEX/(cores)/(computer-cores)}"

for CORE_URL in $CORE_URLS; do
	if [[ $CORE_URL == https://* ]]
	then
		#if [ "$REPOSITORIES_FILTER" == "" ] || { echo "$CORE_URL" | grep -qi "$REPOSITORIES_FILTER";  } || { echo "$CORE_CATEGORY" | grep -qi "$CORE_CATEGORIES_FILTER";  }
		if [ "$REPOSITORIES_FILTER" == "" ] || [[ "${CORE_URL^^}" =~ ${REPOSITORIES_FILTER_REGEX^^} ]] || [[ "${CORE_CATEGORY^^}" =~ ${CORE_CATEGORIES_FILTER_REGEX^^} ]]
		then
			if [ "$REPOSITORIES_NEGATIVE_FILTER" == "" ] || { ! [[ "${CORE_URL^^}" =~ ${REPOSITORIES_NEGATIVE_FILTER_REGEX^^} ]] && ! [[ "${CORE_CATEGORY^^}" =~ ${CORE_CATEGORIES_NEGATIVE_FILTER_REGEX^^} ]]; }
			then
				if [ "$CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER" == "" ] || [[ "${CORE_URL^^}" =~ ${CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER_REGEX^^} ]]
				then
					#if echo "$CORE_URL" | grep -qE "(SD-Installer)|(/Main_MiSTer$)|(/Menu_MiSTer$)"
					if [[ "${CORE_URL}"  =~ (SD-Installer)|(/Main_MiSTer$)|(/Menu_MiSTer$) ]]
					then
						checkCoreURL
					else
						[ "$PARALLEL_UPDATE" == "true" ] && { echo "$(checkCoreURL)"$'\n' & } || checkCoreURL
					fi
				fi
			fi
		fi
	else
		CORE_CATEGORY=$(echo "$CORE_URL" | sed 's/user-content-//g')
		#if [ "$CORE_CATEGORY" == "" ]
		#then
		#	CORE_CATEGORY="-"
		#fi
		#if [ "$CORE_CATEGORY" == "computer-cores" ] || [[ "$CORE_CATEGORY" =~ [a-z]+-comput[a-z]+ ]]
		#then
		#	CORE_CATEGORY="cores"
		#fi
		#if [[ "$CORE_CATEGORY" =~ console.* ]]
		#then
		#	CORE_CATEGORY="console-cores"
		#fi
		case "${CORE_URL}" in
			*comput*) CORE_CATEGORY="computer-cores" ;;
			*console*) CORE_CATEGORY="console-cores" ;;
			*other-systems*) CORE_CATEGORY="other-cores" ;;
			"") CORE_CATEGORY="-" ;;
			*) ;;
		esac
	fi
done
wait

if [ "${MAME_ALT_ROMS}" == "true" ]
then
	CORE_CATEGORY="-"
	CORE_URL="${MRA_ALT_URL}"
	if [ "$CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER" == "" ] || [[ "${CORE_URL^^}" =~ ${CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER_REGEX^^} ]]
	then
		checkCoreURL
	fi
fi

if [ "$FILTERS_URL" != "" ]
then
	if [ -d "$BASE_PATH/Filters" ] && dir $BASE_PATH/Filters/* > /dev/null 2>&1 && ! dir $BASE_PATH/Filters/*/ > /dev/null 2>&1 && [ ! -d "$BASE_PATH/Filters_backup" ]
	then
		echo "Backing up Filters"
		mkdir -p "$BASE_PATH/Filters_backup"
		mv $BASE_PATH/Filters/* $BASE_PATH/Filters_backup/
		echo ""
	fi
	CORE_CATEGORY="-"
	CORE_URL="$FILTERS_URL"
	if [ "$CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER" == "" ] || [[ "${CORE_URL^^}" =~ ${CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER_REGEX^^} ]]
	then
		checkCoreURL
	fi
fi

for ADDITIONAL_REPOSITORY in "${ADDITIONAL_REPOSITORIES[@]}"; do
	[ "$PARALLEL_UPDATE" == "true" ] && { echo "$(checkAdditionalRepository)"$'\n' & } || checkAdditionalRepository
done
wait

function checkCheat {
	MAPPING_KEY=$(echo "${CHEAT_MAPPING}" | grep -o "^[^:]*")
	MAPPING_VALUE=$(echo "${CHEAT_MAPPING}" | grep -o "[^:]*$")
	MAX_VERSION=""
	FILE_NAME=$(echo "${CHEAT_URLS}" | grep "mister_${MAPPING_KEY}_")
	echo "Checking ${MAPPING_KEY^^}"
	if [ "${FILE_NAME}" != "" ]
	then
		CHEAT_URL="${CHEATS_URL}${FILE_NAME}"
		MAX_VERSION=$(echo "${FILE_NAME}" | grep -oE "[0-9]{8}")
		CURRENT_LOCAL_VERSION=""
		MAX_LOCAL_VERSION=""
		for CURRENT_FILE in "${WORK_PATH}/mister_${MAPPING_KEY}_"*
		do
			if [ -f "${CURRENT_FILE}" ]
			then
				#if echo "${CURRENT_FILE}" | grep -qE "mister_[^_]+_[0-9]{8}.zip"
				if [[ "${CURRENT_FILE}" =~ mister_[^_]+_[0-9]{8}\.zip ]]
				then
					CURRENT_LOCAL_VERSION=$(echo "${CURRENT_FILE}" | grep -oE '[0-9]{8}')
					[ "${UPDATE_CHEATS}" == "once" ] && CURRENT_LOCAL_VERSION="99999999"
					if [[ "${CURRENT_LOCAL_VERSION}" > "${MAX_LOCAL_VERSION}" ]]
					then
						MAX_LOCAL_VERSION=${CURRENT_LOCAL_VERSION}
					fi
					if [[ "${MAX_VERSION}" > "${CURRENT_LOCAL_VERSION}" ]] && [ "${DELETE_OLD_FILES}" == "true" ]
					then
						mv "${CURRENT_FILE}" "${CURRENT_FILE}.${TO_BE_DELETED_EXTENSION}" > /dev/null 2>&1
					fi
				fi
			fi
		done
		if [[ "${MAX_VERSION}" > "${MAX_LOCAL_VERSION}" ]]
		then
			echo "Downloading ${FILE_NAME}"
			[ "${SSH_CLIENT}" != "" ] && echo "URL: ${CHEAT_URL}"
			if curl $CURL_RETRY $SSL_SECURITY_OPTION -L --cookie "challenge=BitMitigate.com" "${CHEAT_URL}" -o "${WORK_PATH}/${FILE_NAME}"
			then
				if [ ${DELETE_OLD_FILES} == "true" ]
				then
					echo "Deleting old mister_${MAPPING_KEY} files"
					rm "${WORK_PATH}/mister_${MAPPING_KEY}_"*.${TO_BE_DELETED_EXTENSION} > /dev/null 2>&1
				fi
				mkdir -p "${BASE_PATH}/cheats/${MAPPING_VALUE}"
				sync
				echo "Extracting ${FILE_NAME}"
				unzip -o "${WORK_PATH}/${FILE_NAME}" -d "${BASE_PATH}/cheats/${MAPPING_VALUE}" 1>&2
				rm "${WORK_PATH}/${FILE_NAME}" > /dev/null 2>&1
				touch "${WORK_PATH}/${FILE_NAME}" > /dev/null 2>&1
				echo -n ", ${FILE_NAME}" >> "${UPDATED_ADDITIONAL_REPOSITORIES_FILE}"
			else
				echo "${FILE_NAME} download failed"
				rm "${WORK_PATH}/${FILE_NAME}" > /dev/null 2>&1
				if [ ${DELETE_OLD_FILES} == "true" ]
				then
					echo "Restoring old mister_${MAPPING_KEY} files"
					for FILE_TO_BE_RESTORED in "${WORK_PATH}/mister_${MAPPING_KEY}_"*.${TO_BE_DELETED_EXTENSION}
					do
					  mv "${FILE_TO_BE_RESTORED}" "${FILE_TO_BE_RESTORED%.${TO_BE_DELETED_EXTENSION}}" > /dev/null 2>&1
					done
				fi
				echo -n ", ${FILE_NAME}" >> "${ERROR_ADDITIONAL_REPOSITORIES_FILE}"
				echo "If you experience frequent download errors"
				echo "maybe the parallel update is hitting your network too hard"
				echo "please try PARALLEL_UPDATE=\"false\" in"
				echo "${INI_PATH}"
			fi
			sync
		fi
	fi
	echo ""
}

if [ "${UPDATE_CHEATS}" != "false" ]
then
	echo "Checking Cheats"
	echo ""
	CHEAT_URLS=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf --cookie "challenge=BitMitigate.com" "${CHEATS_URL}" | grep -oE '"mister_[^_]+_[0-9]{8}.zip"' | sed 's/"//g')
	for CHEAT_MAPPING in ${CHEAT_MAPPINGS}; do
		[ "$PARALLEL_UPDATE" == "true" ] && { echo "$(checkCheat)"$'\n' & } || checkCheat
	done
	wait
fi

EXIT_CODE=0
LOG_PATH="${WORK_PATH}/$(basename ${RUN_NAME%.*}.log)"
echo "MiSTer Updater version ${UPDATER_VERSION}" > "${LOG_PATH}"
echo "started at ${UPDATE_START_DATETIME_LOCAL}" >> "${LOG_PATH}"
echo "" >> "${LOG_PATH}"
echo "Successfully updated cores:" >> "${LOG_PATH}"
if [ "$(cat "${UPDATED_CORES_FILE}")" != "" ]
then
	cat "${UPDATED_CORES_FILE}" | cut -c3- >> "${LOG_PATH}"
else
	echo "none" >> "${LOG_PATH}"
fi
rm "${UPDATED_CORES_FILE}" > /dev/null 2>&1
echo "" >> "${LOG_PATH}"
echo "Error updating these cores:" >> "${LOG_PATH}"
if [ "$(cat "${ERROR_CORES_FILE}")" != "" ]
then
	cat "${ERROR_CORES_FILE}" | cut -c3- >> "${LOG_PATH}"
	EXIT_CODE=100
else
	 echo "none" >> "${LOG_PATH}"
fi
rm "${ERROR_CORES_FILE}" > /dev/null 2>&1
echo "" >> "${LOG_PATH}"
echo "Successfully updated additional files:" >> "${LOG_PATH}"
if [ "$(cat "${UPDATED_ADDITIONAL_REPOSITORIES_FILE}")" != "" ]
then
	cat "${UPDATED_ADDITIONAL_REPOSITORIES_FILE}" | cut -c3- >> "${LOG_PATH}"
else
	 echo "none" >> "${LOG_PATH}"
fi
rm "${UPDATED_ADDITIONAL_REPOSITORIES_FILE}" > /dev/null 2>&1
echo "" >> "${LOG_PATH}"
echo "Error updating these additional files:" >> "${LOG_PATH}"
if [ "$(cat "${ERROR_ADDITIONAL_REPOSITORIES_FILE}")" != "" ]
then
	cat "${ERROR_ADDITIONAL_REPOSITORIES_FILE}" | cut -c3- >> "${LOG_PATH}"
	EXIT_CODE=100
else
	 echo "none" >> "${LOG_PATH}"
fi
rm "${ERROR_ADDITIONAL_REPOSITORIES_FILE}" > /dev/null 2>&1
if [ "${EXIT_CODE}" != "0" ] && [ "$PARALLEL_UPDATE" == "true" ]
then
	echo "" >> "${LOG_PATH}"
	echo "If you experience frequent download errors" >> "${LOG_PATH}"
	echo "maybe the parallel update is hitting your network too hard" >> "${LOG_PATH}"
	echo "please try PARALLEL_UPDATE=\"false\" in" >> "${LOG_PATH}"
	echo "${INI_PATH}" >> "${LOG_PATH}"
fi
echo "Updater Log: ${LOG_PATH}"
echo ""
echo "==========================="
cat "${LOG_PATH}"
echo "==========================="
echo ""
if [ "${EXIT_CODE}" == "0" ]
then
	echo "${UPDATE_START_DATETIME_UTC}" > "${LAST_SUCCESSFUL_RUN_PATH}"
	#[ "${INI_DATETIME_UTC}" != "" ] && echo "${INI_DATETIME_UTC}" >> "${LAST_SUCCESSFUL_RUN_PATH}"
	echo "${INI_DATETIME_UTC}" >> "${LAST_SUCCESSFUL_RUN_PATH}"
	echo "${UPDATER_VERSION}" >> "${LAST_SUCCESSFUL_RUN_PATH}"
fi
sync

echo "Done!"
sleep 1

}

#Unofficial Updates
if [ $DOWNLOAD_CORES_UNOFFICIAL == "True" ];then
	
	DEV_NAME="Unofficial"
	MISTER_DEVEL_REPOS_URL="https://api.github.com/users/RetroDriven/repos"
	DEV_WIKI="https://github.com/RetroDriven/MiSTerMAME/wiki/Unofficial"
	ARCADE_SUBFOLDER="$UNOFFICIAL_PATH"
	mkdir -p "$BASE_PATH/$ARCADE_FOLDER/$ARCADE_SUBFOLDER"
	WORK_PATH="$LOGS_PATH/.unofficial"
	mkdir -p "$WORK_PATH"
	RUN_NAME="unofficial"	
	CORE_URLS="user-content-arcade-cores"$'\n'$'\n'$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "$DEV_WIKI"| awk '/wiki-content/,/wiki-rightbar/' | grep -io '\(https://github.com/[a-zA-Z0-9./_-]*\)' | awk '!a[$0]++')

	#MRA Handling
	if [ $DOWNLOAD_MRA_UNOFFICIAL == "True" ];then
		MAME_ARCADE_ROMS="true"
	fi
	if [ $DOWNLOAD_MRA_UNOFFICIAL != "True" ];then
		MAME_ARCADE_ROMS="false"
	fi

	Unofficial_Updater $MISTER_DEVEL_REPOS_URL $CORE_URLS $ARCADE_SUBFOLDER $RUN_NAME $DEV_NAME $MAME_ARCADE_ROMS
	#Log File Handling
	#echo "Date: $TIMESTAMP" >> "$LOGS_PATH/RBF_Downloaded.txt"

fi	

#Jotego Updates
if [ $DOWNLOAD_CORES_JOTEGO == "True" ];then   
	
	DEV_NAME="Jotego"
	MISTER_DEVEL_REPOS_URL="https://api.github.com/users/jotego/repos"
	DEV_WIKI="https://github.com/RetroDriven/MiSTerMAME/wiki/Jotego"
	DEV_GITHUB="https://github.com/jotego/jtbin"
	ARCADE_SUBFOLDER="$JOTEGO_PATH"
	mkdir -p "$BASE_PATH/$ARCADE_FOLDER/$ARCADE_SUBFOLDER"
	WORK_PATH="$LOGS_PATH/.jotego"
	mkdir -p "$WORK_PATH"
	RUN_NAME="jotego"
	CORE_URLS="user-content-arcade-cores"$'\n'$'\n'$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "$DEV_WIKI"| awk '/wiki-content/,/wiki-rightbar/' | grep -ioE '(https://github.com/[a-zA-Z0-9./_-]*_MiSTer)|('$DEV_GITHUB'/[a-zA-Z0-9./_-]*)' | awk '!a[$0]++')

	#MRA Handling
	if [ $DOWNLOAD_MRA_JOTEGO == "True" ];then
		MAME_ARCADE_ROMS="true"
	fi
	if [ $DOWNLOAD_MRA_JOTEGO != "True" ];then
		MAME_ARCADE_ROMS="false"
	fi

	Unofficial_Updater $MISTER_DEVEL_REPOS_URL $CORE_URLS $ARCADE_SUBFOLDER $RUN_NAME $DEV_NAME $MAME_ARCADE_ROMS
	#Log File Handling
	#echo "Date: $TIMESTAMP" >> "$LOGS_PATH/RBF_Downloaded.txt"
	
	#Download Jotego MRA Alternatives
	if [ $DOWNLOAD_MRA_ALTERNATIVES == "True" ];then
		clear	
		MRA_PATH="$BASE_PATH/$ARCADE_FOLDER/$JOTEGO_PATH/_Alternatives"
		MRA_TYPE="Jotego Alternatives"
		MRA_DOWNLOAD_URL="$MRA_JOTEGO_URL"
		MRA_LOG="MRA_Jotego_Alternatives.txt"
		Download_MRA "$MRA_PATH" "$MRA_TYPE" "$MRA_DOWNLOAD_URL" "$MRA_LOG"
	fi

fi

#CPS1 Updates
if [ $DOWNLOAD_CORES_CPS1 == "True" ];then  

	DEV_NAME="CPS1"
	MISTER_DEVEL_REPOS_URL="https://api.github.com/users/jotego/repos"
	DEV_WIKI="https://github.com/RetroDriven/MiSTerMAME/wiki/CPS1"
	DEV_GITHUB="https://github.com/jotego/jtbin"
	ARCADE_SUBFOLDER="$CPS1_PATH"
	mkdir -p "$BASE_PATH/$ARCADE_FOLDER/$ARCADE_SUBFOLDER"
	WORK_PATH="$LOGS_PATH/.cps1"
	mkdir -p "$WORK_PATH"
	RUN_NAME="cps1"
	CORE_URLS="user-content-arcade-cores"$'\n'$'\n'$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "$DEV_WIKI"| awk '/wiki-content/,/wiki-rightbar/' | grep -ioE '(https://github.com/[a-zA-Z0-9./_-]*_MiSTer)|('$DEV_GITHUB'/[a-zA-Z0-9./_-]*)' | awk '!a[$0]++')

	#MRA Handling
	if [ $DOWNLOAD_MRA_CPS1 == "True" ];then
		MAME_ARCADE_ROMS="true"
	fi
	if [ $DOWNLOAD_MRA_CPS1 != "True" ];then
		MAME_ARCADE_ROMS="false"
	fi

	Unofficial_Updater $MISTER_DEVEL_REPOS_URL $CORE_URLS $ARCADE_SUBFOLDER $RUN_NAME $DEV_NAME $MAME_ARCADE_ROMS
	#Log File Handling
	#echo "Date: $TIMESTAMP" >> "$LOGS_PATH/RBF_Downloaded.txt"
	
	#Download CPS1 MRA Alternatives
	if [ $DOWNLOAD_MRA_ALTERNATIVES == "True" ];then
		clear	
		MRA_PATH="$BASE_PATH/$ARCADE_FOLDER/$CPS1_PATH/_Alternatives"
		MRA_TYPE="CPS1 Alternatives"
		MRA_DOWNLOAD_URL="$MRA_CPS1_URL"
		MRA_LOG="MRA_CPS1_Alternatives.txt"
		Download_MRA "$MRA_PATH" "$MRA_TYPE" "$MRA_DOWNLOAD_URL" "$MRA_LOG"
	fi

fi

#Display Footer
Footer
echo "Downloaded Log Files are located here: $LOGS_PATH"
if [ $SHOW_BACKUP_LOCATION == "True" ];then
	echo "Backup Files from Previous Script located here: $BASE_PATH/$ARCADE_FOLDER/rd_backup"
fi
echo
