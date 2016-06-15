#! /bin/bash

########################################################################################################
#	pmsartusers.sh
#
#
#
#
#	Creates 7 local accounts, 1 for each period, for student use in the PMS Art iMac lab.
#	The accounts are for organizational purposes only, not security. Passwords are all blank.
#	
########################################################################################################




# Download the user picuters for local art accounts to a temp directory
sudo curl -o "/tmp/artusers.tar.gz" http://brego/files/images/artusers.tar.gz

# Unzip the pictures and extract them to the user pictures directory
sudo gunzip /tmp/artusers.tar.gz
sudo tar -xvf /tmp/artusers.tar -C "/Library/User Pictures"

# cleanup any temp files
sudo rm /tmp/artusers*

declare -a users=("Period 1" "Period 2" "Period 3" "Period 4" "Period 5" "Period 6" "Period 7")

for i in "${!users[@]}"
do
shortName=$(echo -e ${users[$i]} | tr -d '[:space:]' | awk '{print tolower($0)}')

sudo dscl . create /Users/$shortName UserShell /bin/bash
sudo dscl . create /Users/$shortName RealName "${users[$i]}"
sudo dscl . create /Users/$shortName UniqueID "70$(($i + 1))"
sudo dscl . create /Users/$shortName PrimaryGroupID 20
sudo dscl . create /Users/$shortName NFSHomeDirectory /Users/$shortName
sudo dscl . -passwd /Users/$shortName
sudo dscl . create /Users/$shortName Picture "/Library/User Pictures/$shortName.tif"

done
