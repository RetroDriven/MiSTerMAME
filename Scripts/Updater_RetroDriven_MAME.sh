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
# v1.9 - Remove Unofficial MRAs when they are MiSTer Official
# v1.8 - Removed Support for Official MRA files and Alternatives
#        These MRA files can be downloaded via Official Updater Script
#	     All Unofficial MRA files will remain here until those become Official
# v1.7 - Script overhaul completed. Crazy fast Updating speeds!
#        Zipped Mame/HBMame/MRA/Alt MRA files on my end
#        Zips will be downloaded and exracted only if the files are missing or out of date
#        Added an Option in the INI for Download Logs
# v1.6 - Added HBMAME_PATH option. You can now use the "Games" folder for Mame and Hbmame Zips
# v1.5 - Added most recent MRA files
#        Added Hbmame Zips
#        Removed MRA Filtering for now
#        Adjusted Script to handle spaces in MRA file names
# v1.4 - MRA directory structure has changed within MiSTer
#        Adjusted Script and INI to account for the changes
#        Added INI Option for Showing Downloaded Files List/Log
# v1.3 - Added MRA File downloading
#        MRA Filtering Added
# v1.2 - Organized Zips via Subfolders
#        Adjusted script to loop through the subfolders
# v1.1 - Cleaned up script and added some additional Variables
#        Added IDDQD DOOM Loading Screen option
#        Added File Size Comparing to make sure the Zips match(Local vs Remote files)
# v1.0 - Changed original Script from Locutus73 as needed

#=========   URL OPTIONS   =========
#Main URL
MAIN_URL="https://cloud.retrodriven.com"

#MAME ROM Zips URL
MAME_URL="https://cloud.retrodriven.com/index.php/s/Mame/download"

#HBMAME ROM Zips URL
HBMAME_URL="https://cloud.retrodriven.com/index.php/s/hbmame/download"

#MRA URL
MRA_URL="https://cloud.retrodriven.com/index.php/s/MRA/download"

#=========   DIRECTORY OPTIONS   =========

#Base directory for all script’s tasks
#SD Root: BASE_PATH="/media/fat"
#USB Root: BASE_PATH="/media/usb0"
BASE_PATH="/media/fat"

#Directory to save the Download Logs to if you enable this option below
LOG_PATH=$BASE_PATH/"RetroDriven_Logs"

#Directory for MRA Files
#This is your Arcade Directory. This can be change to your liking
#NOTE: The directory needs an underscore "_" for MiSTer to see the Directory
MRA_PATH=$BASE_PATH/"_Arcade"

#Directory for MAME Zips
#Games Path: MAME_PATH=$BASE_PATH/Games/"mame"
#Arcade Path: MAME_PATH=$MRA_PATH/"mame
MAME_PATH=$MRA_PATH/"mame"

#Directory for HBMAME Zips
#Games Path: HBMAME_PATH=$BASE_PATH/Games/"hbmame"
#Arcade Path: HBMAME_PATH=$MRA_PATH/"hbmame"
HBMAME_PATH=$MRA_PATH/"hbmame"

#=========   USER OPTIONS   =========

#Set to "True" for DOOM Loading screen and Pure Retro Nostalgia
#Set to "False" to skip the DOOM Loading screen...but why would you do that?
IDDQD="True"

#Set to "True" to download the Unofficial Arcade MRA Files(Jotego, gaz68, MrX, etc.)
#Set to "False" if you do not want to download these files
MRA_DOWNLOAD="False"

#Set to "True" to download the HBMame Files
#Set to "False" if you do not want to download these files
HBMAME_DOWNLOAD="False"

#Set to "True" to save a Log File showing which Files were Downloaded/Updated 
#Set to "False" if you do not want to save the Log Files
LOG_DOWNLOADED="True"

#========= DO NOT CHANGE BELOW =========

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
echo "|                 RetroDriven: MiSTer MAME Updater v1.9                  |"
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
echo "        adding mame.zip"
sleep 1
echo "        RetroDriven version"
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

    #Download Zip and extract files/folders if they don't exist    
    cd "$MAME_PATH"
    curl $CURL_RETRY $SSL_SECURITY_OPTION -OJs "$MAME_URL"
    #Save to Log if Option is Enabled    
    if [ $LOG_DOWNLOADED == "True" ];then
        unzip -uo "Mame.zip" | tee -a "$LOG_PATH/Mame_Downloaded.txt"
        echo "Date: $TIMESTAMP" >> "$LOG_PATH/Mame_Downloaded.txt"
        echo "" >> "$LOG_PATH/Mame_Downloaded.txt"   
    else   
        unzip -uo "Mame.zip"
    fi    
    #Delete Zip as it is no longer needed after Unzip
    rm "Mame.zip"
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
    
    #Create Directory if neded
    mkdir -p "$HBMAME_PATH"    
    cd "$HBMAME_PATH"

    #Download Zip and extract files/folders if they don't exist    
    curl $CURL_RETRY $SSL_SECURITY_OPTION -OJs "$HBMAME_URL"
    #Save to Log if Option is Enabled    
    if [ $LOG_DOWNLOADED == "True" ];then
        unzip -uo "hbmame.zip" | tee -a "$LOG_PATH/HBMame_Downloaded.txt"
        echo "Date: $TIMESTAMP" >> "$LOG_PATH/HBMame_Downloaded.txt"
        echo "" >> "$LOG_PATH/HBMame_Downloaded.txt" 
    else   
        unzip -uo "hbmame.zip"
    fi    
    #Delete Zip as it is no longer needed after Unzip
    rm "hbmame.zip" 
    sleep 1
    clear 
}

#Download MRA Function
Download_MRA(){

    echo
    echo "=========================================================================="
    echo "                           Downloading MRA Files                          "
    echo "=========================================================================="
    sleep 1 

    #Download Zip and extract files/folders if they don't exist    
    cd "$MRA_PATH"
    curl $CURL_RETRY $SSL_SECURITY_OPTION -OJs "$MRA_URL"
    #Save to Log if Option is Enabled    
    if [ $LOG_DOWNLOADED == "True" ];then
        unzip -uo "MRA.zip" | tee -a "$LOG_PATH/MRA_Downloaded.txt"
        echo "Date: $TIMESTAMP" >> "$LOG_PATH/MRA_Downloaded.txt"
        echo "" >> "$LOG_PATH/MRA_Downloaded.txt" 
    else   
        unzip -uo "MRA.zip"
    fi    
    #Delete MRA.zip as it is no longer needed after Unzip
    rm "MRA.zip"
    
    #Delete Unofficial MRA Files as needed
    cd "$MRA_PATH"
    for file in *.mra; do
        if [ -f "$file" ];then
            rm "$MRA_PATH/_Unofficial/$file" 2>/dev/null; true
        fi
    done
    sleep 1
    clear 
    
    #Delete Unofficial Alternative MRA Files as needed
    cd "$MRA_PATH/_alternatives/"
    for dir in *; do
        if [ -d "$dir" ];then
            rm -R -f "$MRA_PATH/_Unofficial/_Alternatives/$dir" 2>/dev/null; true
        fi
    done
    sleep 1
    clear 
}

#Footer Function
Footer(){
clear
echo
echo "=========================================================================="
echo "                    MAME ZIP/MRA files are up to date!                    "
echo "=========================================================================="
echo
#echo "** Please visit RetroDriven.com for all of your MiSTer and Retro News and Updates! ***"
#sleep 3
}

#========= MAIN CODE =========

#RetroDriven Updater Banner
RetroDriven_Banner

#Doom Boot loader
if [ $IDDQD == "True" ];then
    Doom_Boot
else
    IDDQD_Off
    sleep 3
fi

#Create MAME directory if needed
mkdir -p $MAME_PATH

#Create Log Folder if needed
if [ $LOG_DOWNLOADED == "True" ];then
    mkdir -p $LOG_PATH
    TIMESTAMP=`date "+%m-%d-%Y @ %I:%M%P"`
fi

#Download MAME Zips
Download_MAME

#Download HBMAME Zips
if [ $HBMAME_DOWNLOAD == "True" ];then
    Download_HBMAME
fi

#MRA Downloading
if [ $MRA_DOWNLOAD == "True" ];then
    
    #Make Directories if needed   
    mkdir -p $MRA_PATH
    
    #Download MRA Files
    Download_MRA    
fi

echo

#Display Footer
Footer

#Display Log Info
if [ $LOG_DOWNLOADED == "True" ];then
echo "Downloaded Log Files are located here: $LOG_PATH"
fi

echo
