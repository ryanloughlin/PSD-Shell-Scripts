#! /bin/bash

########################################################################################################
#	pmsartusers.sh
#
#
#
#
#	Creates 7 local accounts, 1 for each period, for student use in the PMS Art iMac lab.
#	The accounts are for organizational purposes only not security. Passwords are all blank.
#	
########################################################################################################




# Download the user picuters for local art accounts to a temp directory
sudo curl -o "/tmp/artusers.tar.gz" http://brego/files/images/artusers.tar.gz

# Unzip the pictures and extract them to the user pictures directory
sudo gunzip /tmp/artusers.tar.gz
sudo tar -xvf /tmp/artusers.tar -C "/Library/User Pictures"

# cleanup any temp files
sudo rm /tmp/artusers*

sudo dscl . create /Users/period1 UserShell /bin/bash
sudo dscl . create /Users/period1 RealName "Period 1"
sudo dscl . create /Users/period1 UniqueID "701"
sudo dscl . create /Users/period1 PrimaryGroupID 20
sudo dscl . create /Users/period1 NFSHomeDirectory /Local/Users/period1
sudo dscl . -passwd /Users/period1
sudo dscl . create /Users/period1 Picture "/Library/User Pictures/kermit.tif"

sudo dscl . create /Users/period2 UserShell /bin/bash
sudo dscl . create /Users/period2 RealName "Period 2"
sudo dscl . create /Users/period2 UniqueID "702"
sudo dscl . create /Users/period2 PrimaryGroupID 20
sudo dscl . create /Users/period2 NFSHomeDirectory /Local/Users/period2
sudo dscl . -passwd /Users/period2
sudo dscl . create /Users/period2 Picture "/Library/User Pictures/piggy.tif"

sudo dscl . create /Users/period3 UserShell /bin/bash
sudo dscl . create /Users/period3 RealName "Period 3"
sudo dscl . create /Users/period3 UniqueID "703"
sudo dscl . create /Users/period3 PrimaryGroupID 20
sudo dscl . create /Users/period3 NFSHomeDirectory /Local/Users/period3
sudo dscl . -passwd /Users/period3
sudo dscl . create /Users/period3 Picture "/Library/User Pictures/fozzie.tif"

sudo dscl . create /Users/period4 UserShell /bin/bash
sudo dscl . create /Users/period4 RealName "Period 4"
sudo dscl . create /Users/period4 UniqueID "704"
sudo dscl . create /Users/period4 PrimaryGroupID 20
sudo dscl . create /Users/period4 NFSHomeDirectory /Local/Users/period4
sudo dscl . -passwd /Users/period4
sudo dscl . create /Users/period4 Picture "/Library/User Pictures/gonzo.tif"

sudo dscl . create /Users/period5 UserShell /bin/bash
sudo dscl . create /Users/period5 RealName "Period 5"
sudo dscl . create /Users/period5 UniqueID "705"
sudo dscl . create /Users/period5 PrimaryGroupID 20
sudo dscl . create /Users/period5 NFSHomeDirectory /Local/Users/period5
sudo dscl . -passwd /Users/period5
sudo dscl . create /Users/period5 Picture "/Library/User Pictures/beaker.tif"

sudo dscl . create /Users/period6 UserShell /bin/bash
sudo dscl . create /Users/period6 RealName "Period 6"
sudo dscl . create /Users/period6 UniqueID "706"
sudo dscl . create /Users/period6 PrimaryGroupID 20
sudo dscl . create /Users/period6 NFSHomeDirectory /Local/Users/period6
sudo dscl . -passwd /Users/period6
sudo dscl . create /Users/period6 Picture "/Library/User Pictures/animal.tif"

sudo dscl . create /Users/period7 UserShell /bin/bash
sudo dscl . create /Users/period7 RealName "Period 7"
sudo dscl . create /Users/period7 UniqueID "707"
sudo dscl . create /Users/period7 PrimaryGroupID 20
sudo dscl . create /Users/period7 NFSHomeDirectory /Local/Users/period7
sudo dscl . -passwd /Users/period7
sudo dscl . create /Users/period7 Picture "/Library/User Pictures/rowlf.tif"
