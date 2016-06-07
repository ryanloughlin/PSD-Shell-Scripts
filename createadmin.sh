#!/bin/bash

dscl . -create /Users/localadmin
dscl . -create /Users/localadmin UserShell /bin/bash
dscl . -create /Users/localadmin RealName "Local Administrator" 
dscl . -create /Users/localadmin UniqueID "499"
dscl . -create /Users/localadmin PrimaryGroupID 80
dscl . -create /Users/localadmin NFSHomeDirectory /Users/localadmin
dscl . -passwd /Users/localadmin password 

dscl . -append /Groups/admin GroupMembership localadmin

sudo createhomedir -u localadmin

# ==============================================
# Skip iCloud & Diagnostic nonsense - copied from larger script by rtrouton
# ==============================================
#mkdir /Users/localadmin/Library/Preferences
#chown 499 /Users/localadmin/Library
#chown 499 /Users/localadmin/Library/Preferences
#defaults write Users/localadmin/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
#defaults write Users/localadmin/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
#defaults write Users/localadmin/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
#chown 499 Users/localadmin/Library/Preferences/com.apple.SetupAssistant.plist
sudo touch /var/db/.AppleSetupDone
sudo touch /var/db/.AppleDiagnosticsSetupDone


# ==============================================
# Shell
# ==============================================
echo "export CLICOLOR=1" >> ~/.bash.profile
echo "export LSCOLORS=GxFxCxDxBxegedabagaced" >> ~/.bash_profile
echo "export PS1='\[\033[1;35m\]\u\[\033[m\]@\[\033[37m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ '" >> ~/.bash_profile
echo "export PATH=/usr/local/sbin:$PATH" >> /Users/localadmin/.bash_profile
