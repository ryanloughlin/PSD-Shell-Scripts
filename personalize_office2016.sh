# !/bin/bash
# PATH=/bin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/libexec
# Source - http://maclovin.org/blog-native/2015/office-2016-where-is-the-name-of-the-user-stored-
export PATH


########################################################################################################
#
#		SET VARIABLES
#
########################################################################################################

CITY="Portsmouth"
STATE="NH"
ZIP="03801"
EMAIL=$USER"@portsmouth.k12.nh.us"

########################################################################################################
#
#		GATHER INFO ABOUT THE COMPUTER
#
########################################################################################################

COMPUTERID=$( scutil --get ComputerName );

# Grab the building code from the front of the computer name
BUILDING=${COMPUTERID:0:3};

# Expand the building name to match the AD OU

case $BUILDING in
	PHS|phs|Phs)
		BUILDING='Portsmouth High School'
		ADDRESS='50 Andrew Jarvis Drive'
		PHONE="'(603) 436-7100'"
		;;
	PMS|pms|Pms)
		BUILDING='Portsmouth Middle School'
		ADDRESS='155 Parrott Ave'
		PHONE="'(603) 436-5781'"
echo $PHONE
		;;
	LHS|lhs|Lhs)
		BUILDING='Little Harbour School'
		ADDRESS='50 Clough Drive'
		PHONE="'(603) 436-1708'"
		;;
	DON|don|Don)
		BUILDING='Dondero School'
		ADDRESS='32 Van Buren Avenue'
		PHONE="'(603) 436-2231'"
		;;
	NFS|nfs|Nfs)
		BUILDING='New Franklin School'
		ADDRESS='1 Franklin Drive'
		PHONE="'(603) 436-0910'"
		;;
	RJL|rjl|Rjl)
		BUILDING='Robert J. Lister Academy'
		ADDRESS='35 Sherburne Road'
		PHONE="'(603) 427-2901'"
		;;
	*)
		BUILDING=''
		ADDRESS=''
		PHONE=''

esac





FullScriptName=$(basename "$0") # Variable used to store the file name of this script

DsclSearchPath="/Local/Default" # Variable used to store the search path used by the dscl command.

# Get the username of the person currently running the script.
username=$(id -un)

echo "$FullScriptName -- Personalizing Office 2016 for $username"

# Lookup the user's name from the local directory
firstname=$(dscl "$DsclSearchPath" -read /Users/$username RealName | tr -d '\n' | awk '{print $2}')
lastname=$(dscl "$DsclSearchPath" -read /Users/$username RealName | tr -d '\n' | awk '{print $3}')

# Get the first letter for the initial
firstInitial=${firstname:0:1}

# Get the first letter for the initial
lastInitial=${lastname:0:1}

# Concatenate the initials together into one variable.
UserInitials="$(echo $firstInitial$lastInitial)"

# Concatenate the full name together into one variable.
UserFullName="$(echo $firstname $lastname)"

# Remove any leading or trailing whitepace
UserFullName="$(echo -e "${UserFullName}" | sed -e 's/^[[:space:]]//' -e 's/[[:space:]]$//')"
UserInitials="$(echo -e "${UserInitials}" | sed -e 's/^[[:space:]]//' -e 's/[[:space:]]$//')"

defaults write "/Users/$username/Library/Group Containers/UBF8T346G9.Office/MeContact.plist" Name "$UserFullName"
defaults write "/Users/$username/Library/Group Containers/UBF8T346G9.Office/MeContact.plist" Initials "$UserInitials"
defaults write "/Users/$username/Library/Group Containers/UBF8T346G9.Office/MeContact.plist" Business\ Company "$BUILDING"
defaults write "/Users/$username/Library/Group Containers/UBF8T346G9.Office/MeContact.plist" Address "$ADDRESS"
defaults write "/Users/$username/Library/Group Containers/UBF8T346G9.Office/MeContact.plist" City "$CITY"
defaults write "/Users/$username/Library/Group Containers/UBF8T346G9.Office/MeContact.plist" State "$STATE"
defaults write "/Users/$username/Library/Group Containers/UBF8T346G9.Office/MeContact.plist" Zip "$ZIP"
defaults write "/Users/$username/Library/Group Containers/UBF8T346G9.Office/MeContact.plist" Phone "$PHONE"
defaults write "/Users/$username/Library/Group Containers/UBF8T346G9.Office/MeContact.plist" Email "$EMAIL"



echo "$FullScriptName -- Completed personalizing Office 2016 for $username"

defaults write $HOME/Library/Group\ Containers/UBF8T346G9.Office/com.microsoft.officeprefs.plist DefaultsToLocalOpenSave -bool TRUE

# Quit the script without errors.
exit 0