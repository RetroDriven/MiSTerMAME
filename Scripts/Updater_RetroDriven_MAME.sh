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

# v2.3 - Added File Size Comparing and checking(Local vs Remote). This will avoid incomplete download issues
# v2.2 - Added option to allow Unofficial MRA files to be copied over to the same path as the Official MRA files
#        I highly suggest against changing this default option but this was a requested option for those that want it
#        Keeping the Unofficial MRA files is a safer route and less of a chance for issues with the Official MRA files
# v2.1 - Optimized Speed/Bandwidth
#        Zip files will be dated. Dummy files are saved to Temp directory
#        Script will look to the Dummy files and only download if there's a newer Zip
#        This will increase the Script's speed and save Download Bandwith for all
# v2.0 - Added option to download/update Unofficial Arcade Cores/RBFs
#        No more manually adding/updating these on your own   
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
MAIN_URL="https://retrodriven-nextcloud.cloud.seedboxes.cc"

#MAME ROM Zips URL
MAME_URL="https://retrodriven-nextcloud.cloud.seedboxes.cc/s/MAME/download"

#HBMAME ROM Zips URL
HBMAME_URL="https://retrodriven-nextcloud.cloud.seedboxes.cc/s/HBMAME/download"

#MRA URL
MRA_URL="https://retrodriven-nextcloud.cloud.seedboxes.cc/s/MRA/download"

#=========   DIRECTORY OPTIONS   =========

#Base directory for all script’s tasks
#SD Root: BASE_PATH="/media/fat"
#USB Root: BASE_PATH="/media/usb0"
BASE_PATH="/media/fat"

#Directory to save the Download Logs to if you enable this option below
LOG_PATH=$BASE_PATH/"RetroDriven_Logs/MAME"

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
MRA_DOWNLOAD="True"

#Set to "True" to keep the Unofficial MRA files in it's own Subfolder
#Set to "False" to keep the Unofficial MRA files with the Official Folder
#I HIGHLY SUGGEST keeping this set to "True" to avoid duplicates/mess/issues
MRA_UNOFFICIAL_SUBFOLDER="True"

#Set to "True" to download the HBMame Files
#Set to "False" if you do not want to download these files
HBMAME_DOWNLOAD="True"

#Set to "True" to save a Log File showing which Files were Downloaded/Updated 
#Set to "False" if you do not want to save the Log Files
LOG_DOWNLOADED="True"

#Set to "True" to download the Unofficial Arcade RBF Files(Jotego, gaz68, MrX, etc.)
#Set to "False" if you do not want to download these files
RBF_DOWNLOAD="True"

#Set to "True" to remove the "Arcade-" prefix with the Unofficial Arcade RBF Files
#Set to "False" if you'd like to keep the "Arcade-" prefix in place 
REMOVE_ARCADE_PREFIX="True"

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
echo "|                 RetroDriven: MiSTer MAME Updater v2.3                  |"
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
    
    #Create Directories
    mkdir -p $MAME_PATH
    mkdir -p "$BASE_PATH/Scripts/.RetroDriven/MAME"
    MAME_FAILED="False"

    #Get Current Zip File Name
    cd "$BASE_PATH/Scripts/.RetroDriven/MAME"
    MAME_FILENAME=$(curl -sIkL "$MAME_URL" | sed -r '/filename=/!d;s/.*filename=(.*)$/\1/' | sed -e 's|["'\'']||g' | sed '/^$/d;s/[[:space:]]//g')
    rm -f "download"
    
    #Get File Size
    REMOTE_SIZE=$(curl -I "$MAME_URL" 2>/dev/null | grep "content-length" | head -1 | cut -d":" -f2 | sed '/^$/d;s/[[:space:]]//g')
  
    if [ -f $MAME_FILENAME ];then
        echo "MAME Files are up to date!"
        sleep 1
        if [ $LOG_DOWNLOADED == "True" ];then
            echo "MAME Files are up to date!" >> "$LOG_PATH/Mame_Downloaded.txt"
            echo "Date: $TIMESTAMP" >> "$LOG_PATH/Mame_Downloaded.txt"
            echo "" >> "$LOG_PATH/Mame_Downloaded.txt"                     
        fi        
    fi
 
    #Download Zip and extract files/folders if they don't exist    
    if [ ! -f $MAME_FILENAME ];then    
        echo "Downloading: $MAME_FILENAME"
        cd "$MAME_PATH"
        curl $CURL_RETRY $SSL_SECURITY_OPTION -OJs "$MAME_URL"
        
        #Check File Size
        LOCAL_SIZE=$(ls -l "$MAME_FILENAME" | awk '{ print $5}')
        
        #Handling for when Local and Remote Sizes don't match
            if [ $LOCAL_SIZE != $REMOTE_SIZE ];then
                echo
                echo "WARNING: MAME Files did not download successfully! Please check your Internet Connection and/or try again."
                sleep 5
                clear
                
                #Log handling
                if [ $LOG_DOWNLOADED == "True" ];then
                echo "WARNING: MAME Files did not download successfully! Please check your Internet Connection and/or try again." >> "$LOG_PATH/Mame_Downloaded.txt"
                echo "Date: $TIMESTAMP" >> "$LOG_PATH/Mame_Downloaded.txt"
                echo "" >> "$LOG_PATH/Mame_Downloaded.txt"                     
                fi
                MAME_FAILED="True"
            return
            fi
            
        #Save to Log if Option is Enabled    
        if [ $LOG_DOWNLOADED == "True" ];then
            unzip -uo "$MAME_FILENAME" | tee -a "$LOG_PATH/Mame_Downloaded.txt"
            echo "Date: $TIMESTAMP" >> "$LOG_PATH/Mame_Downloaded.txt"
            echo "" >> "$LOG_PATH/Mame_Downloaded.txt"   
        else   
            unzip -uo "$MAME_FILENAME"
        fi    
        #Delete Zip as it is no longer needed after Unzip
        rm "$MAME_FILENAME"
        #Create Dummy Zip to avoid downloading the same file
        cd "$BASE_PATH/Scripts/.RetroDriven/MAME"
        rm MAME*.zip 2>/dev/null; true    
        touch "$MAME_FILENAME"
    fi
    sleep 1
    clear     
}

#Download HBMAME Function
Download_HBMAME(){

    #echo
    echo "=========================================================================="
    echo "                         Downloading HBMAME Files                         "
    echo "=========================================================================="
    sleep 1
    
    #Create Directories
    mkdir -p "$HBMAME_PATH"    
    mkdir -p "$BASE_PATH/Scripts/.RetroDriven/HBMAME"
    HBMAME_FAILED="False"

    #Get Current Zip File Name
    cd "$BASE_PATH/Scripts/.RetroDriven/HBMAME"    
    HBMAME_FILENAME=$(curl -sIkL "$HBMAME_URL" | sed -r '/filename=/!d;s/.*filename=(.*)$/\1/' | sed -e 's|["'\'']||g' | sed '/^$/d;s/[[:space:]]//g')
    rm -f "download"
    
    #Get File Size
    REMOTE_SIZE=$(curl -I "$HBMAME_URL" 2>/dev/null | grep "content-length" | head -1 | cut -d":" -f2 | sed '/^$/d;s/[[:space:]]//g')

    if [ -f $HBMAME_FILENAME ];then
        echo "HBMAME Files are up to date!"
        sleep 1
        if [ $LOG_DOWNLOADED == "True" ];then
            echo "HBMAME Files are up to date!" >> "$LOG_PATH/HBMame_Downloaded.txt"
            echo "Date: $TIMESTAMP" >> "$LOG_PATH/HBMame_Downloaded.txt"
            echo "" >> "$LOG_PATH/HBMame_Downloaded.txt"                     
        fi        
    fi
 
    #Download Zip and extract files/folders if they don't exist    
    if [ ! -f $HBMAME_FILENAME ];then
        echo "Downloading: $HBMAME_FILENAME"
        cd "$HBMAME_PATH"
        curl $CURL_RETRY $SSL_SECURITY_OPTION -OJs "$HBMAME_URL"
        
        #Check File Size
        LOCAL_SIZE=$(ls -l "$HBMAME_FILENAME" | awk '{ print $5}')
        
        #Handling for when Local and Remote Sizes don't match
            if [ $LOCAL_SIZE != $REMOTE_SIZE ];then
                echo
                echo "WARNING: HBMAME Files did not download successfully! Please check your Internet Connection and/or try again."
                sleep 5
                clear
                
                #Log handling
                if [ $LOG_DOWNLOADED == "True" ];then
                echo "WARNING: HBMAME Files did not download successfully! Please check your Internet Connection and/or try again." >> "$LOG_PATH/HBMame_Downloaded.txt"
                echo "Date: $TIMESTAMP" >> "$LOG_PATH/HBMame_Downloaded.txt"
                echo "" >> "$LOG_PATH/HBMame_Downloaded.txt"                     
                fi
                HBMAME_FAILED="True"
            return
            fi
     
        #Save to Log if Option is Enabled    
        if [ $LOG_DOWNLOADED == "True" ];then
            unzip -uo "$HBMAME_FILENAME" | tee -a "$LOG_PATH/HBMame_Downloaded.txt"
            echo "Date: $TIMESTAMP" >> "$LOG_PATH/HBMame_Downloaded.txt"
            echo "" >> "$LOG_PATH/HBMame_Downloaded.txt"   
        else   
            unzip -uo "$HBMAME_FILENAME"
        fi    
        #Delete Zip as it is no longer needed after Unzip
        rm "$HBMAME_FILENAME"
        #Create Dummy Zip to avoid downloading the same file
        cd "$BASE_PATH/Scripts/.RetroDriven/HBMAME"
        rm HBMAME*.zip 2>/dev/null; true    
        touch "$HBMAME_FILENAME"
    fi
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

    #Create Directories
    mkdir -p $MRA_PATH    
    mkdir -p "$BASE_PATH/Scripts/.RetroDriven/MRA"
    MRA_FAILED="False"

    #Get Current Zip File Name
    cd "$BASE_PATH/Scripts/.RetroDriven/MRA"
    MRA_FILENAME=$(curl -sIkL "$MRA_URL" | sed -r '/filename=/!d;s/.*filename=(.*)$/\1/' | sed -e 's|["'\'']||g' | sed '/^$/d;s/[[:space:]]//g')
    rm -f "download"
    
    #Get File Size
    REMOTE_SIZE=$(curl -I "$MRA_URL" 2>/dev/null | grep "content-length" | head -1 | cut -d":" -f2 | sed '/^$/d;s/[[:space:]]//g')

    if [ -f $MRA_FILENAME ];then
        echo "MRA Files are up to date!"
        sleep 1
        if [ $LOG_DOWNLOADED == "True" ];then
            echo "MRA Files are up to date!" >> "$LOG_PATH/MRA_Downloaded.txt"
            echo "Date: $TIMESTAMP" >> "$LOG_PATH/MRA_Downloaded.txt"
            echo "" >> "$LOG_PATH/MRA_Downloaded.txt"                     
        fi        
    fi
 
    #Download Zip and extract files/folders if they don't exist    
    if [ ! -f $MRA_FILENAME ];then    
        echo "Downloading: $MRA_FILENAME"
        cd "$MRA_PATH"
        curl $CURL_RETRY $SSL_SECURITY_OPTION -OJs "$MRA_URL"
        
        #Check File Size
        LOCAL_SIZE=$(ls -l "$MRA_FILENAME" | awk '{ print $5}')
        
        #Handling for when Local and Remote Sizes don't match
            if [ $LOCAL_SIZE -ne $REMOTE_SIZE ];then
                echo
                echo "WARNING: MRA Files did not download successfully! Please check your Internet Connection and/or try again."
                sleep 5
                clear
                
                #Log handling
                if [ $LOG_DOWNLOADED == "True" ];then
                echo "WARNING: MRA Files did not download successfully! Please check your Internet Connection and/or try again." >> "$LOG_PATH/MRA_Downloaded.txt"
                echo "Date: $TIMESTAMP" >> "$LOG_PATH/MRA_Downloaded.txt"
                echo "" >> "$LOG_PATH/MRA_Downloaded.txt"                     
                fi
                MRA_FAILED="True"
            return
            fi
        
        #Save to Log if Option is Enabled    
        if [ $LOG_DOWNLOADED == "True" ];then
            unzip -uo "$MRA_FILENAME" | tee -a "$LOG_PATH/MRA_Downloaded.txt"
            echo "Date: $TIMESTAMP" >> "$LOG_PATH/MRA_Downloaded.txt"
            echo "" >> "$LOG_PATH/MRA_Downloaded.txt"   
        else   
            unzip -uo "$MRA_FILENAME"
        fi    
        
        #Delete Zip as it is no longer needed after Unzip
        cd "$MRA_PATH"       
        rm "$MRA_FILENAME"
        
        #Create Dummy Zip to avoid downloading the same file
        cd "$BASE_PATH/Scripts/.RetroDriven/MRA"
        rm MRA*.zip 2>/dev/null; true    
        touch "$MRA_FILENAME"

        #Copy MRA Files to Root MRA Path if Option is set to do so
        if [ $MRA_UNOFFICIAL_SUBFOLDER == "False" ];then
            cd "$MRA_PATH/_Unofficial"
            cp -n *.mra "$MRA_PATH" 2>/dev/null; true
            cd "$MRA_PATH/_Unofficial/_Alternatives"
            cp -n -R * "$MRA_PATH/_alternatives" 2>/dev/null; true

            cd "$MRA_PATH/_Jotego"
            cp -n *.mra "$MRA_PATH" 2>/dev/null; true
            cp -n 1942.mra "$MRA_PATH/1942_Jotego.mra" 2>/dev/null; true
            cp -n "1943 Kai Midway Kaisen.mra" "$MRA_PATH/1943 Kai Midway Kaisen_Jotego.mra" 2>/dev/null; true
            cp -n "1943 The Battle of Midway.mra" "$MRA_PATH/1943 The Battle of Midway_Jotego.mra" 2>/dev/null; true
            cp -n "1943 The Battle of Midway Mark II.mra" "$MRA_PATH/1943 The Battle of Midway Mark II_Jotego.mra" 2>/dev/null; true
            cp -n "Ghosts'n Goblins.mra" "$MRA_PATH/Ghosts'n Goblins_Jotego.mra" 2>/dev/null; true

            cd "$MRA_PATH/_Sega System 1"
            cp -n *.mra "$MRA_PATH" 2>/dev/null; true
            cd "$MRA_PATH/_Sega System 1/_Alternatives"
            cp -n -R * "$MRA_PATH/_alternatives" 2>/dev/null; true
        fi   
    fi

        #Delete Unofficial MRA Files as needed
        cd "$MRA_PATH"
        for file in *.mra; do
            if [ -f "$file" ];then
                rm "$MRA_PATH/_Unofficial/$file" 2>/dev/null; true
            fi
        done
         
        #Delete Unofficial Alternative MRA Files as needed
        cd "$MRA_PATH/_alternatives/"
        for dir in *; do
            if [ -d "$dir" ];then
                rm -R -f "$MRA_PATH/_Unofficial/_Alternatives/$dir" 2>/dev/null; true
            fi
        done
        
        #Delete Unofficial Subfolder if Option is set to do so
        if [ $MRA_UNOFFICIAL_SUBFOLDER == "False" ];then
        rm -R -f "$MRA_PATH/_Unofficial" 2>/dev/null; true
        rm -R -f "$MRA_PATH/_Jotego" 2>/dev/null; true
        rm -R -f "$MRA_PATH/_Sega System 1" 2>/dev/null; true
        fi
 
    sleep 1
    clear 
}

#Footer Function
Footer(){
clear
echo
echo "=========================================================================="
echo "                  MAME ZIP/MRA/RBF files are up to date!                  "
echo "=========================================================================="
echo
if [ $MAME_FAILED == "True" ];then
echo "WARNING: MAME Files did not download successfully! Please check your Internet Connection and/or try again."
fi
if [ $HBMAME_DOWNLOAD == "True" ] && [ $HBMAME_FAILED == "True" ];then
echo "WARNING: HBMAME Files did not download successfully! Please check your Internet Connection and/or try again."
fi
if [ $MRA_DOWNLOAD == "True" ] && [ $MRA_FAILED == "True" ];then
echo "WARNING: MRA Files did not download successfully! Please check your Internet Connection and/or try again."
fi
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

#Create Log Folder if needed
if [ $LOG_DOWNLOADED == "True" ];then
    mkdir -p $LOG_PATH
    TIMESTAMP=`date "+%m-%d-%Y @ %I:%M%P"`
fi

#Download MAME Zips
Download_MAME

#Download HBMAME Zips
if [ $HBMAME_DOWNLOAD == "True" ];then
    echo    
    Download_HBMAME
fi

#MRA Downloading
if [ $MRA_DOWNLOAD == "True" ];then
  
    #Download MRA Files
    Download_MRA    
fi

echo

#================================================================================#
#                       UNOFFICIAL CORE UPDATER STARTS HERE                      #
#================================================================================#

#=========   USER OPTIONS   =========

#Directory where RetroDriven Cores are downloaded
declare -A CORE_CATEGORY_PATHS
CORE_CATEGORY_PATHS["arcade-cores"]="$MRA_PATH/cores"

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
if [ $RBF_DOWNLOAD == "True" ];then
    
    clear    
    echo
    echo "=========================================================================="
    echo "                    Downloading Unofficial Arcade Cores                   "
    echo "=========================================================================="
    sleep 1
fi

#Unofficial Updater Function
Unofficial_Updater(){

if [ $DEV_NAME == "jotego" ];then
    clear    
    echo
    echo "=========================================================================="
    echo "                      Downloading Jotego Arcade Cores                     "
    echo "=========================================================================="
    sleep 1 
fi

mkdir -p "$MRA_PATH/cores"

if [ "$DOWNLOAD_NEW_CORES" != "true" ] && [ "$DOWNLOAD_NEW_CORES" != "false" ] && [ "$DOWNLOAD_NEW_CORES" != "" ]
then
	for idx in "${!CORE_CATEGORY_PATHS[@]}"; do
		NEW_CORE_CATEGORY_PATHS[$idx]=$(echo ${CORE_CATEGORY_PATHS[$idx]} | sed "s/$(echo $BASE_PATH | sed 's/\//\\\//g')/$(echo $BASE_PATH | sed 's/\//\\\//g')\/$DOWNLOAD_NEW_CORES/g")
	done
	mkdir -p "${NEW_CORE_CATEGORY_PATHS[@]}"
fi

CORE_URLS=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sLf "$WIKI_URL" | grep -io '\('$GITHUB_CORE_URL'/[a-zA-Z0-9./_-]*\)\|\(user-content-[a-z-]*\)')


CORE_CATEGORY="-"
SD_INSTALLER_PATH=""
REBOOT_NEEDED="false"
CORE_CATEGORIES_FILTER=""

GOOD_CORES=""
if [ "$GOOD_CORES_URL" != "" ]
then
	GOOD_CORES=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sLf "$GOOD_CORES_URL")
fi

function checkCoreURL {
	
	echo "Checking $(echo $CORE_URL | sed 's/.*\///g' | sed 's/_MiSTer//gI')"
	[ "${SSH_CLIENT}" != "" ] && echo "URL: $CORE_URL"
	if echo "$CORE_URL" | grep -q "SD-Installer"
	then
		RELEASES_URL="$CORE_URL"
	else
		RELEASES_URL=https://github.com$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sLf "$CORE_URL" | grep -o '/'$DEV_NAME'/[a-zA-Z0-9./_-]*/tree/master/[a-zA-Z0-9./_-]*/releases' | head -n1)
	fi

	RELEASE_URLS=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sLf "$RELEASES_URL" | grep -o '/'$DEV_NAME'/[a-zA-Z0-9./_-]*_[0-9]\{8\}[a-zA-Z]\?\(\.rbf\|\.rar\)\?')

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
			if curl $CURL_RETRY $SSL_SECURITY_OPTION -# -L "https://github.com$MAX_RELEASE_URL?raw=true" -o "$CURRENT_DIR/$FILE_NAME"
                #Log File handling                
                if [ $LOG_DOWNLOADED == "True" ];then
                echo "$FILE_NAME" >> "$LOG_PATH/RBF_Downloaded.txt"                
                fi 			
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

#Download Unofficial Arcade Cores if Enabled
if [ $RBF_DOWNLOAD == "True" ];then

    #Get Unofficial Arcade RBF Cores - My GitHub
    WIKI_URL="https://github.com/RetroDriven/MiSTerMAME/wiki"
    GITHUB_CORE_URL="https://github.com/RetroDriven/MiSTerMAME/tree/master/Unofficial_Cores"
    DEV_NAME="RetroDriven"
    Unofficial_Updater $WIKI_URL $GITHUB_CORE_URL $DEV_NAME

    #Get Unofficial Arcade RBF Cores - Jotego
    WIKI_URL="https://github.com/jotego/jtbin/wiki"
    GITHUB_CORE_URL="https://github.com/jotego/jtbin/tree/master/mister"
    DEV_NAME="jotego"
    Unofficial_Updater $WIKI_URL $GITHUB_CORE_URL $DEV_NAME

    #Log File Timestamp for RBF Files
    if [ $LOG_DOWNLOADED == "True" ];then
        echo "" >> "$LOG_PATH/RBF_Downloaded.txt"
        echo "Date: $TIMESTAMP" >> "$LOG_PATH/RBF_Downloaded.txt"
    fi
fi

#Display Footer
Footer

#Display Log Info
if [ $LOG_DOWNLOADED == "True" ];then
echo "Downloaded Log Files are located here: $LOG_PATH"
fi

echo
