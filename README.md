# IMPORTANT NOTE

## Scripts End Of Life(January 2021) 

The Good News: My Family will be growing by one more with a new Baby on the way soon! 

The Bad News: Come January my Scripts will go EOL.

TLDR:New Baby,Not enough time,I will be back at some point

Full Details Below:

<a href="https://www.patreon.com/posts/scripts-end-of-44945379">https://www.patreon.com/posts/scripts-end-of-44945379</a>

# MiSTerMAME
The purpose of this Script to to aid in downloading the correct MAME ROM Zips to use for the new MiSTer Arcade Core MRA configuration. This Script is for testing/educational purposes only.

# Updater Script and INI Download

<a href="https://github.com/RetroDriven/MiSTerMAME/releases/download/SE_v1.3/RetroDriven_MAME_SE_Updater_v1.3.zip"> Script Updater and INI File Download </a>

## Usage ##
* Download the ZIP file above and Extract/Copy <b>Update_RetroDriven_MAME_SE.sh</b> and <b>Update_RetroDriven_MAME_SE.ini</b> to your Scripts Folder on your MiSTer SD Card(typically /media/fat/Scripts).
* Simply run <b>Update_RetroDriven_MAME_SE.sh</b> via MiSTer Scripts Menu to Download/Update your MAME ROM Zips/MRAs and Unofficial Arcade Cores(RBF Files).
* Optional: Changing the <b>Update_RetroDriven_MAME_SE.ini</b> file is optional based on your setup/needs.

## New MRA Arcade Core Folder Structure ##
The following below is the directory structure for the new MRA/Mame Arcade Core setup: 

* /_Arcade/*.mra
* /_Arcade/cores/*.rbf
* /Games/mame/*.zip 
* /Games/hbmame/*.zip

You can place your Mame/HbMame Zip files within your _Arcade folder instead like below:

* /_Arcade/mame/*.zip
* /_Arcade/hbmame/*.zip

NOTE: This change can be made via the INI File. It is recommended to use the Default of using the Games Folder though

## Default Arcade Core Folder Structure for this Script ##
The Folder Names and Structure can be changed via the INI File.

* /_Arcade/_Unofficial/*.mra
* /_Arcade/_Unofficial/_CPS1
* /_Arcade/_Unofficial/_Jotego
* /_Arcade/_Unofficial/_Sega System 1

## Unofficial Arcade Core/RBF Downloads ##
I have included the ability to Download/Update Unofficial Arcade Core RBF files.

* Jotego's Public Cores will be Download/Updated just like his Updater Script is doing currently. NOTE: His Beta Cores are not included as those are for his Patreon Subscribers only.
* All other Unofficial Arcade Cores are ones that I've come across that are not currently a part of the Official MiSTer GitHub.
* If/When these Unofficial Arcade Cores are added to the Official MiSTer GitHub, they will be removed on my end to avoid duplicates/issues.
* Be sure to set the INI Option "REMOVE_ARCADE_PREFIX" based on your current Arcade Core set up to avoid duplicates/issues. 
* If you do not wish to Download the Unofficial Arcade Core RBF files set "RBF_DOWNLOAD" to False in the INI File.

## Credits ##
* <a href="https://github.com/MiSTer-devel/Main_MiSTer/wiki">Sorgelig</a>
* <a href="https://github.com/nullobject">Nullobject</a>
* <a href="https://github.com/jotego">Jotego</a>
* <a href="https://github.com/gaz68">gaz68</a>
* <a href="https://github.com/alanswx">alanswx</a>
* <a href="https://github.com/MrX-8B">MiSTer-X</a>
* <a href="https://github.com/MiSTer-devel/MRA-Alternatives_MiSTer">eubrunosilva</a>
* <a href="https://github.com/d18c7db">Alex d18c7db</a>

## Disclaimer / Legal Information
By downloading and using this Script you are agreeing to the following:

* You are responsible for checking your local laws regarding the use of the ROMs that this Script downloads.
* You are authorized/licensed to own/use the ROMs associated with this Script.
* You will not distribute any of these files without the appropriate permissions.
* You own the original Arcade PCB for each ROM file that you download.
* I take no responsibility for any data loss or anything, use the script at your own risk.
