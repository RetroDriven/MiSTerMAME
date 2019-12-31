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

# v1.5 - Added most recent MRA files
#        Added Hbmame Zips
#        Removed MRA Filtering for now
#        Adjusted Script to handle spaces in MRA file names
# v1.4 - MRA directory structure has changed within MiSTer
#        Adjusted Script and INI to account for the changes
#	 Added INI Option for Showing Downloaded Files List/Log
# v1.3 - Added MRA File downloading
#        MRA Filtering Added
# v1.2 - Organized Zips via Subfolders
#        Adjusted script to loop through the subfolders
# v1.1 - Cleaned up script and added some additional Variables
#        Added IDDQD DOOM Loading Screen option
#        Added File Size Comparing to make sure the Zips match(Local vs Remote files)
# v1.0 - Changed original Script from Locutus73 as needed

#=========   USER OPTIONS   =========

#Base directory for all script’s tasks, "/media/fat" for SD root, "/media/usb0" for USB drive root.
BASE_PATH="/media/fat"

#Directory for MRA Files
#This is your Arcade Directory
MRA_PATH=$BASE_PATH/"_Arcade"

#Directory for MAME Zips
#LEAVE THIS AS IS
MAME_PATH=$MRA_PATH/"Mame"

#Main URL
MAIN_URL="https://mister.retrodriven.com"

#MAME ROM Zips URL
MAME_URL="https://mister.retrodriven.com/MAME/Zips"

#MRA URL
MRA_URL="https://mister.retrodriven.com/MAME/MRA"

#Set to "True" for DOOM Loading screen and Pure Retro Nostalgia. Set to "False" to skip the DOOM Loading screen.
IDDQD="True"

#Set to "True" to download the Arcade MRA Files. Set to "False" if you do not want to download these files.
MRA_DOWNLOAD="False"

#Set to "True" to see a list of the files that were Downloaded. Set to "False" if you do not want to see this list.
SHOW_DOWNLOADED="True"

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
echo "|                 RetroDriven: MiSTer MAME Updater v1.5                  |"
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

#Download Zip Function
Download_Zip(){
for FILE_MAME in $(curl $CURL_RETRY $SSL_SECURITY_OPTION -s $MAME_URL/$SUBDIR/ |
                  grep href |
                  sed 's/.*href="//' |
                  sed 's/".*//' |
                  grep '^[a-zA-Z0-9].*.zip'); do

        #Check to see if the Zip exists already
        if [ -e "$LMAME_PATH/$FILE_MAME" ];then
            REMOTE_SIZE=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -s -L -I $MAME_URL/$SUBDIR/$FILE_MAME | awk -v IGNORECASE=1 '/^Content-Length/ { print int($2) }')
            LOCAL_SIZE=$(stat -c %s "$LMAME_PATH/$FILE_MAME")
        fi
        #Check to see if the File Sizes match(Local vs Remote)
        if [[ -e "$LMAME_PATH/$FILE_MAME" && $LOCAL_SIZE -eq $REMOTE_SIZE ]];then
            echo "Skipping: $FILE_MAME" >&2
            else
            #Download Zip if the File Sizes don't match or if the Zip is missing
            echo "Downloading: $FILE_MAME"
            curl $CURL_RETRY $SSL_SECURITY_OPTION -# -O $MAME_URL/$SUBDIR/$FILE_MAME        
            ZIP_SUMMARY+=$(echo "$FILE_MAME ")           
            echo
        fi   	    
done
}

#Download MRA Function
Download_Mra(){
for FILE_MRA in $(curl $CURL_RETRY $SSL_SECURITY_OPTION -s $MRA_URL/$SUBDIR/ |
                  grep href |
                  sed 's/.*href="//' |
                  sed 's/".*//' |
                  grep '^[a-zA-Z0-9].*.mra'); do 

        #Check to see if the MRA exists already
        MRA_CLEAN="$(echo $FILE_MRA | sed 's/%20/ /g')"
        if [ -e "$LMRA_PATH/$MRA_CLEAN" ];then
            REMOTE_SIZE=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -s -L -I "$MRA_URL/$SUBDIR/$FILE_MRA" | awk -v IGNORECASE=1 '/^Content-Length/ { print int($2) }')
            LOCAL_SIZE=$(stat -c %s "$LMRA_PATH/$MRA_CLEAN")
        fi
        #Check to see if the File Sizes match(Local vs Remote)
        if [[ -e "$LMRA_PATH/$MRA_CLEAN" && $LOCAL_SIZE -eq $REMOTE_SIZE ]];then
            echo "Skipping: $MRA_CLEAN" >&2
            else
            #Download MRA if the File Sizes don't match or if the MRA is missing            
            echo "Downloading: $MRA_CLEAN"            
            curl $CURL_RETRY $SSL_SECURITY_OPTION -# -O "$MRA_URL/$SUBDIR/$FILE_MRA"
            rename 's/%20/ /g' $FILE_MRA                  
            MRA_SUMMARY+=$(echo "$MRA_CLEAN ")  
            echo
        fi   	    
done
}

#Zip Log Function
Zip_Log(){
echo "***** Zip Files Downloaded *****"
echo
    if [ ${#ZIP_SUMMARY[@]} -eq 0 ]; then    
        echo "All Zip files are up to date!"
        echo 
    else
        echo "${ZIP_SUMMARY[@]}"
        echo
        sleep 3     
fi
}

#Mra Log Function
Mra_Log(){
echo "***** MRA Files Downloaded *****"
echo
    if [ ${#MRA_SUMMARY[@]} -eq 0 ]; then    
        echo "All MRA files are up to date!"
        echo 
    else
        echo "${MRA_SUMMARY[@]}"
        echo
        sleep 3     
fi
}

#Footer Function
Footer(){
if [ $SHOW_DOWNLOADED == "True" ];then
    clear
fi
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
if [ $IDDQD == "True" ]; then
    Doom_Boot
else
    IDDQD_Off
    sleep 3
fi

#Make Directories if needed
mkdir -p $MAME_PATH
mkdir -p $MRA_PATH/"hbmame"

#Download Official Zips
SUBDIR="Official"
cd $MAME_PATH
LMAME_PATH="$MAME_PATH"
Download_Zip "$SUBDIR" "$LMAME_PATH"

#Download hbmame Zips
SUBDIR="hbmame"
cd $MRA_PATH/"hbmame"
LMAME_PATH="$MRA_PATH/hbmame"
Download_Zip "$SUBDIR" "$LMAME_PATH"

#MRA Downloading
if [ $MRA_DOWNLOAD == "True" ];then
    
    clear
    echo
    echo "=========================================================================="
    echo "                           Downloading MRA Files                          "
    echo "=========================================================================="
    sleep 2    

    #Make Directories if needed   
    mkdir -p $MRA_PATH
    mkdir -p $MRA_PATH/"_Sega System 1"
 
    #Download Official MRAs
    SUBDIR="Official"
    cd $MRA_PATH
    LMRA_PATH="$MRA_PATH"
    Download_Mra "$SUBDIR" "$LMRA_PATH"

    #Download Sega System 1 MRAs
    SUBDIR="_Sega%20System%201"
    cd $MRA_PATH/"_Sega System 1"
    LMRA_PATH="$MRA_PATH/_Sega System 1"     
    Download_Mra "$SUBDIR" "$LMRA_PATH"
fi

echo

#Display Footer
Footer

#Display Zip Downloaded Files
if [ $SHOW_DOWNLOADED == "True" ];then
Zip_Log
fi

#Display MRA Downloaded Files
if [ $SHOW_DOWNLOADED == "True" ] && [ $MRA_DOWNLOAD == "True" ];then
Mra_Log
fi

echo
