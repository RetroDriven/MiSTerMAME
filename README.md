# MiSTerMAME
The purpose of this Script to to aid in downloading the correct MAME ROM Zips to use for the new MiSTer Arcade Core MRA configuration. This Script is for testing/educational purposes only.

# Script Download
Right-Click and Save As the following below:

<a href="https://raw.githubusercontent.com/RetroDriven/MiSTerMAME/master/Update_RetroDriven_MAME.sh"> Update_RetroDriven_MAME.sh </a>

# INI File Download
Right-Click and Save As the following below:

<a href="https://raw.githubusercontent.com/RetroDriven/MiSTerMAME/master/Update_RetroDriven_MAME.ini"> Update_RetroDriven_MAME.ini </a>

## Usage ##
* Download <b>Update_RetroDriven_MAME.sh</b> above and Save it to your Scripts Folder on your MiSTer SD Card(typically /media/fat/Scripts).
* Optional: Download <b>Update_RetroDriven_MAME.ini</b> above and Save it to your Scripts Folder. You can change the INI file as needed but it is not required.
* Simply run <b>Update_RetroDriven_MAME.sh</b> via MiSTer Scripts Menu to Download/Update your MAME ROM Zips/MRAs.

## New MRA Arcade Core Folder Structure ##
The following below is the directory structure for the new MRA/Mame Arcade Core setup: 

* /_Arcade/*.mra
* /_Arcade/cores/*.rbf
* /_Arcade/mame/*.zip 
* /_Arcade/hbmame/*.zip

You can place your Mame/HbMame Zip files into your Games folder instead like below: 
* /Games/mame/*.zip
* /Games/hbmame/*.zip

## Notes ##
* By default MRA Files and HBMame files are not downloaded. You can enable these via the INI File.
* You can save Mame and HBMame files within the "Games" Folder on your MiSTer SD Card. By default this Script saves these files within /_Arcade/Mame and /_Arcade/hbmame but the Path's can be change to your liking via the INI File.
* In the near future the Official MiSTer Updater will download the RBS and MRA files automatically for you. When this happens I will likely remove all Official MRA files from this Script. I will likely keep the Non-Official MRA files here for downloading though. Such as Jotego's MRA Files.

## Wiki ##
You can visit the Wiki page here for lists of the Files that the Script downloads as well as other information.

<a href="https://github.com/RetroDriven/MiSTerMAME/wiki"> Wiki Page</a>

## Disclaimer / Legal Information
By downloading and using this Script you are agreeing to the following:

* You are responsible for checking your local laws regarding the use of the ROMs that this Script downloads.
* You are authorized/licensed to own/use the ROMs associated with this Script.
* You will not distribute any of these files without the appropriate permissions.
* You own the original Arcade PCB for each ROM file that you download.
* I take no responsibility for any data loss or anything, use the script at your own risk.
