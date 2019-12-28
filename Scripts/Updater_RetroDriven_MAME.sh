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

#Directory for MAME Zips
MAME_PATH=$BASE_PATH/"Arcade/Mame"

#Directory for MRA Files
MRA_PATH=$BASE_PATH/"_ArcadeNew"

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

#A space separated list of filters for MRA Files.
#i.e. “DigDug DonkeyKong MsPacman”
MRA_FILTER="" 

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
echo "|                   RetroDriven: MAME Zip Updater v1.3                   |"
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
        if [ -e "$FILE_MAME" ];then
            REMOTE_SIZE=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -s -L -I $MAME_URL/$SUBDIR/$FILE_MAME | awk -v IGNORECASE=1 '/^Content-Length/ { print int($2) }')
            LOCAL_SIZE=$(stat -c %s $MAME_PATH/$FILE_MAME)
        fi
        #Check to see if the File Sizes match(Local vs Remote)
        if [[ -e "$FILE_MAME" && $LOCAL_SIZE -eq $REMOTE_SIZE ]];then
            echo "Skipping: $FILE_MAME" >&2
            else
            #Download Zip if the File Sizes don't match or if the Zip is missing
            echo "Downloading: $FILE_MAME"
            curl $CURL_RETRY $SSL_SECURITY_OPTION -# -O $MAME_URL/$SUBDIR/$FILE_MAME
            echo
        fi   	    
done
}

#Download MRA Function
Download_Mra(){
MRA_FILTER="$( echo "$MRA_FILTER" | sed -e 's/\([a-zA-Z0-9]*\) /\1\n/g')" 
for FILE_MRA in $(curl $CURL_RETRY $SSL_SECURITY_OPTION -s $MRA_URL/$SUBDIR/ |
                  grep href |
                  sed 's/.*href="//' |
                  sed 's/".*//' |
                  grep -iF "$MRA_FILTER.mra"); do 

        #Check to see if the MRA exists already
        if [ -e "$FILE_MRA" ];then
            REMOTE_SIZE=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -s -L -I $MRA_URL/$SUBDIR/$FILE_MRA | awk -v IGNORECASE=1 '/^Content-Length/ { print int($2) }')
            LOCAL_SIZE=$(stat -c %s $MRA_PATH/$FILE_MRA)
        fi
        #Check to see if the File Sizes match(Local vs Remote)
        if [[ -e "$FILE_MRA" && $LOCAL_SIZE -eq $REMOTE_SIZE ]];then
            echo "Skipping: $FILE_MRA" >&2
            else
            #Download MRA if the File Sizes don't match or if the MRA is missing
            echo "Downloading: $FILE_MRA"
            curl $CURL_RETRY $SSL_SECURITY_OPTION -# -O $MRA_URL/$SUBDIR/$FILE_MRA
            echo
        fi   	    
done
}

#Footer Function
Footer(){
echo "=========================================================================="
echo "                         MAME ZIPs are up to date!                        "
echo "=========================================================================="
#echo "** Please visit RetroDriven.com for all of your MiSTer and Retro News and Updates! ***"
#sleep 3
}

#Footer Mra Function
Footer_Mra(){
echo "=========================================================================="
echo "                    MAME ZIPs and MRAs are up to date!                    "
echo "=========================================================================="
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

#Change to MAME Path
cd $MAME_PATH

#Download Official Zips
SUBDIR="Official"
Download_Zip "$SUBDIR"

#Download Jotego Zips
SUBDIR="Jotego"
Download_Zip "$SUBDIR"

#Download MrX Zips
SUBDIR="MrX"
Download_Zip "$SUBDIR"

#Download MrX Sega System 1 Zips
SUBDIR="MrX/SegaSystem1"
Download_Zip "$SUBDIR"

#Download Gaz68 Zips
SUBDIR="Gaz68"
Download_Zip "$SUBDIR"

#Download Nullobject Zips
SUBDIR="Nullobject"
Download_Zip "$SUBDIR"

#MRA Downloading
if [ $MRA_DOWNLOAD == "True" ];then
    
    echo
    echo "=========================================================================="
    echo "                           Downloading MRA Files                          "
    echo "=========================================================================="

    #Make Directories if needed
    mkdir -p $MRA_PATH

    #Change to MAME Path
    cd $MRA_PATH

    #Download Official MRAs
    SUBDIR="Official"
    Download_Mra "$SUBDIR"

    #Download Jotego MRAs
    SUBDIR="Jotego"
    Download_Mra "$SUBDIR"

    #Download MrX MRAs
    SUBDIR="MrX"
    Download_Mra "$SUBDIR"

    #Download MrX Sega System 1 MRAs
    SUBDIR="MrX/SegaSystem1"
    Download_Mra "$SUBDIR"

    #Download Gaz68 MRAs
    SUBDIR="Gaz68"
    Download_Mra "$SUBDIR"

    #Download Nullobject MRAs
    SUBDIR="Nullobject"
    Download_Mra "$SUBDIR"
fi

echo

#Display Footer
if [ $MRA_DOWNLOAD == "True" ];then
    Footer_Mra
else
    Footer
fi
