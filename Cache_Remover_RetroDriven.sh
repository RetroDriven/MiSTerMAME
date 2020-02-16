#!/bin/bash

BASE_PATH="/media/fat"

ORIGINAL_SCRIPT_PATH="$0"
if [ "$ORIGINAL_SCRIPT_PATH" == "bash" ]
then
	ORIGINAL_SCRIPT_PATH=$(ps | grep "^ *$PPID " | grep -o "[^ ]*$")
fi

#Delete the Dummy/Cache Zip files
cd "$BASE_PATH/Scripts/.RetroDriven/MAME" 2>/dev/null; true
rm MAME*.zip 2>/dev/null; true
cd "$BASE_PATH/Scripts/.RetroDriven/MRA" 2>/dev/null; true
rm MRA*.zip 2>/dev/null; true
cd "$BASE_PATH/Scripts/.RetroDriven/HBMAME" 2>/dev/null; true
rm HBMAME*.zip 2>/dev/null; true
cd "$BASE_PATH/Scripts/.RetroDriven/Arduboy" 2>/dev/null; true
rm Arduboy*.zip 2>/dev/null; true

echo
echo "RetroDriven Cache has been cleared!"
echo
exit 0
