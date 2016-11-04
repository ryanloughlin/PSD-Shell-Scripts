#!/bin/sh


########################################################################################################
#
#		CONVERT MOBILE USER TO LOCAL
#
########################################################################################################

dateandtime=`date`
logFile="/var/log/convertuser"
touch $logFile
computerName=`scutil --get ComputerName`
ldapServer="shadowfax.portsmouth.k12.nh.us"


# 		GET LOGGED IN USER


uName=$(who)
uName=$(echo $uName | awk '{print $1}')
#echo $uName


#		GET CURRENT PASSWORD

echo "********************************************************************************************" >> $logFile
echo "[$dateandtime]	[BEGIN]	getting current password for $uName" >> $logFile

userpwd=`osascript <<-AppleScript
tell application "AppleScript Runner" to set userpwd to text returned of (display dialog "Please enter your email password:" default answer "" buttons {"Cancel","OK"} default button 2 with hidden answer)
return userpwd
AppleScript`

if [ $? -ne 0 ]; then

	echo "[$dateandtime]	[ERROR]	failed to get current password for $uName" >> $logFile
	echo "[$dateandtime]	[END]	Fatal error. Exiting" >> $logFile
	echo "********************************************************************************************" >> $logFile && exit 1 

fi

echo "[$dateandtime]	[END]	retrieved current password for $uName" >> $logFile
echo "********************************************************************************************" >> $logFile


#		TEST KEYCHAIN

echo -e "\n********************************************************************************************" >> $logFile
echo "[$dateandtime]	[BEGIN]	testing $uName login keychain" >> $logFile

# Use su to run commands as the user
# Try to unlock the user's login keychain with the supplied password
sudo userpwd=$userpwd su $uName -c 'security lock-keychain && security unlock-keychain -p $userpwd login.keychain 1>&2'


# If the supplied password doesn't unlock the keychain then exit
if [ $? -eq 0 ]; then
	echo "[$dateandtime]	[INFO]	The supplied password unlocked $uName login keychain" >> $logFile
	echo "[$dateandtime]	[END]	Sucessfully tested $uName login keychain" >> $logFile
	echo "********************************************************************************************" >> $logFile

else
	echo "[$dateandtime]	[ERROR]	The supplied password failed to unlock $uName login keychain" >> $logFile
	echo "[$dateandtime]	[END]	Fatal error. Exiting" >> $logFile
	echo "********************************************************************************************" >> $logFile && exit 1 

fi


#		CONVERT ACCOUNT

# Pull the primary user's last name from the ARD field
userLastName=`defaults read /Library/Preferences/com.apple.RemoteDesktop Text1`
# Convert the last name to lowercase for later comparison
userLastName=`echo "$userLastName" | awk '{print tolower($0)}'`
uName=`echo "$uName" | awk '{print tolower($0)}'`

# compare the logged on user's name against the assigned user's name and exit if they dont match 
[[ "$uName" == *"$userLastName"* ]] &&  echo "[$dateandtime]	[INFO]	Current user and assigned user match." >> $logFile || ( echo "[$dateandtime]	[ERROR]	Current user and assigned user don't match. Exiting" >> $logFile && exit 1 )

# List out all the local users
#for i in `dscl  /Local/Default -list /Users`; do 
# Get the uniqueID of each local user
uniqueID=`dscl . -read /Users/$i UniqueID | awk '{print $2}'`

# If the unique ID is greater than 800 pull the username from the record
#if [ "$uniqueID" -ge 800 ]; then
	recordName=`dscl  /Local/Default -read /Users/$i RecordName | awk '{print $2}'`

	#if [[ "$recordName" == *"$userLastName"* ]]; then # See if the local user username contains the assigned user's last name

		uniqueID=`dscl . -read /Users/$recordName UniqueID | awk '{print $2}'`
		realName=`dscl /Local/Default -read /Users/$recordName RealName`
		realName=`echo $realName | awk -F: '{gsub(/^[ \t]+/,"",$2); print $2}'` # Change the awk field separator to ':' in order to handle spaces in the full name, remove leading whitespace
		fName=`dscl /Local/Default -read /Users/$recordName FirstName`
		fName=`echo $fName | awk -F: '{gsub(/^[ \t]+/,"",$2); print$2}'` # Change the awk field separator to ':' in order to handle spaces in the first name, remove leading whitespace
		lName=`dscl /Local/Default -read /Users/$recordName LastName | awk '{print $2}'`
		email=`dscl /Local/Default -read /Users/$recordName EMailAddress | awk '{print $2}'`
		uName=`dscl /Local/Default -read /Users/$recordName RecordName | awk '{print $2}'`
		home=`dscl /Local/Default -read /Users/$recordName NFSHomeDirectory | awk '{print $2}'`
		pass="$userpwd"
		#echo -e "First Name: $fName\nLast Name: $lName\nUsername: $uName\nReal Name: $realName\nUID: $uniqueID\nHome: $home"

		echo -e "\n********************************************************************************************" >> $logFile
		echo "[$dateandtime]	[BEGIN]	converting mobile account to local account for $recordName" >> $logFile

		( dscl . -delete /Users/$recordName && echo "[$dateandtime]	[INFO]	Deleted mobile account $recordName" >> $logFile ) || (echo "[$dateandtime] [ERROR]	Failed to delete mobile user $recordName" >> $logFile && exit 1 )	# delete the main user's mobile account
		
		( dscl . -create /Users/$recordName && echo "[$dateandtime]	[INFO]	Created local account $recordName" >> $logFile ) || (echo "[$dateandtime] [ERROR]	Failed to create local user $recordName" >> $logFile && exit 1 )
		( dscl . -create /Users/$recordName UserShell /bin/bash && echo "[$dateandtime]	[INFO]	Set UserShell for $recordName to /bin/bash" >> $logFile ) || (echo "[$dateandtime] [ERROR]	Failed to set UserShell for $recordName to /bin/bash" >> $logFile && exit 1 )
		( dscl . -create /Users/$recordName RealName "$realName" && echo "[$dateandtime]	[INFO]	Set RealName for $recordName to $realName" >> $logFile ) || (echo "[$dateandtime] [ERROR]	Failed to set RealName for $recordName to $realName" >> $logFile && exit 1 )
		( dscl . -create /Users/$recordName UniqueID "$uniqueID" && echo "[$dateandtime]	[INFO]	Set UniqueID for $recordName to $uniqueID" >> $logFile ) || (echo "[$dateandtime] [ERROR]	Failed to set UniqueID for $recordName to $uniqueID" >> $logFile && exit 1 )
		( dscl . -create /Users/$recordName FirstName "$fName" && echo "[$dateandtime]	[INFO]	Set FirstName for $recordName to $fName" >> $logFile ) || (echo "[$dateandtime] [ERROR]	Failed to set FirstName for $recordName to $fName" >> $logFile && exit 1 )
		( dscl . -create /Users/$recordName LastName "$lName" && echo "[$dateandtime]	[INFO]	Set LastName for $recordName to $lName" >> $logFile ) || (echo "[$dateandtime] [ERROR]	Failed to set LastName for $recordName to $lName" >> $logFile && exit 1 )
		( dscl . -create /Users/$recordName NFSHomeDirectory "$home" && echo "[$dateandtime]	[INFO]	Set NFSHomeDirectory for $recordName to $home" >> $logFile ) || (echo "[$dateandtime] [ERROR]	Failed to set NFSHomeDirectory for $recordName to $home" >> $logFile && exit 1 )
		( dscl . -create /Users/$recordName PrimaryGroupID 20 && echo "[$dateandtime]	[INFO]	Set PrimaryGroup for $recordName to 20" >> $logFile ) || (echo "[$dateandtime] [ERROR]	Failed to set PrimaryGroup for $recordName to 20" >> $logFile && exit 1 )
		( dscl . -create /Users/$recordName EmailAddress $email && echo "[$dateandtime]	[INFO]	Set EmailAddress for $recordName to $email" >> $logFile ) || (echo "[$dateandtime] [ERROR]	Failed to set EmailAddress for $recordName to $email" >> $logFile && exit 1 )
		( dscl . -passwd /Users/$recordName $pass && echo "[$dateandtime]	[INFO]	Set Password for $recordName to $pass" >> $logFile ) || (echo "[$dateandtime] [ERROR]	Failed to set Password for $recordName to $pass" >> $logFile && exit 1 )

		( dseditgroup -o edit -t user -a $recordName admin && echo "[$dateandtime]	[INFO]	Made $recordName an admin." >> $logFile ) || ( echo "[$dateandtime] [ERROR]	Failed to make $recordName an admin." >> $logFile && exit 1 )

	#fi
#fi
#done


echo "[$dateandtime]	[END]	Finished converting mobile account to local account for $recordName" >> $logFile
echo "********************************************************************************************" >> $logFile




#		REMOVE MANAGED PREFERENCES


echo -e "\n********************************************************************************************" >> $logFile
echo "[$dateandtime]	[BEGIN]	removing managed settings for $computerName" >> $logFile


( dsconfigldap -r $ldapServer -l localadmin -q '$PASSWORD'  && echo "[$dateandtime]	[INFO]	Removed LDAP server $ldapServer" >> $logFile ) || ( echo "[$dateandtime]	[ERROR]	Failed to remove LDAP server $ldapServer" >> $logFile  && exit 1 )# remove the OD mangement server binding
( dscl . -list Computers | grep "^localhost&" | while read computer_name ; do sudo dscl. -delete Computers/"$computer_name" ; done && echo "[$dateandtime]	[INFO]	Removed computer entry for $computerName" >> $logFile ) || ( echo "[$dateandtime] [ERROR]	Failed to remove computer entry for $computerName" >> $logFile  && exit 1 )# remove machine managed preferences
( rm -Rf /Library/Managed Preferences  && echo "[$dateandtime]	[INFO]	Removed /Library/Managed Preferences" >> $logFile ) || ( echo "[$dateandtime] [ERROR]	Failed to remove /Library/Managed Preferences" >> $logFile  && exit 1 )# remove cached user managed preferences
( dsconfigad -mobile disable -localhome disable   && echo "[$dateandtime]	[INFO]	Updated AD Plugin mobile account and local home preferences" >> $logFile ) || ( echo "[$dateandtime]	[INFO]	Failed to update AD Plugin mobile account and local home preferences" >> $logFile && exit 1 )


echo "[$dateandtime]	[END]	Finished removing managed settings for $computerName" >> $logFile
echo "********************************************************************************************" >> $logFile

#		SETUP USER PREFERENCES

echo -e "\n********************************************************************************************" >> $logFile
echo "[$dateandtime]	[BEGIN]	Setting user preferences" >> $logFile

apps=("ADPassMon" "Google Drive" "Google Photos Backup")

testapp () {

	a=$(echo -e "${1}" | tr -d '[:space:]')
	if [[ ! -d "/Applications/$1.app" ]]; then
#	echo $a
		curl -o "/tmp/$1.zip" "http://brego/files/$a.zip" && ditto -V -x -k --sequesterRsrc --rsrc "/tmp/$1.zip" /Applications
		rm "/tmp/$1.zip"
	else
		:
	fi;
}

for i in "${apps[@]}"
do
	testapp "$i"
done

( curl -o /Library/LaunchAgents/us.nh.k12.portsmouth.adpassmon.plist http://brego/files/us.nh.k12.portsmouth.adpassmon.plist && echo "[$dateandtime]	[INFO]	Installed ADPassMon LaunchAgent" >> $logFile ) || echo "[$dateandtime]	[ERROR]	Failed to install ADPAssMon LaunchAgent" >> $logFile
( chmod 644 /Library/LaunchAgents/us.nh.k12.portsmouth.adpassmon.plist && echo "[$dateandtime]	[INFO]	Changed permissions on ADPassMon LaunchAgent" >> $logFile ) || echo "[$dateandtime]	[ERROR]	Failed to change permissions on ADPAssMon LaunchAgent" >> $logFile
( chown root:wheel /Library/LaunchAgents/us.nh.k12.portsmouth.adpassmon.plist && echo "[$dateandtime]	[INFO]	Changed ownership of ADPassMon LaunchAgent" >> $logFile ) || echo "[$dateandtime]	[ERROR]	Failed to change ownership of ADPAssMon LaunchAgent" >> $logFile

( su $uName -c 'defaults write org.pmbuko.ADPassMon runIfLocal -bool true' &&
su $uName -c 'defaults write org.pmbuko.ADPassMon allowPasswordChange -bool false' &&
su $uName -c 'defaults write org.pmbuko.ADPassMon pwPolicy "Click OK to visit OWA and change\nyour NETWORK/EMAIL password.\n\n**This WILL NOT change your laptop or Google passwords**."' &&
su $uName -c 'defaults write org.pmbuko.ADPassMon pwPolicyURLButtonTitle "OK"' &&
su $uName -c 'defaults write org.pmbuko.ADPassMon pwPolicyURLButtonURL "https://mail.portsmouth.k12.nh.us/ecp/?rfr=owa&owaparam=modurl%3D0&p=PersonalSettings/Password.aspx"' &&
su $uName -c 'defaults write org.pmbuko.ADPassMon accTest 0' && echo "[$dateandtime]	[INFO]	Set ADPassMon preferences." >> $logFile ) || echo "[$dateandtime]	[ERROR]	Failed to set ADPassMon preferences." >> $logFile )

( lpstat -p | grep printer | cut -d" " -f2 | xargs -I {} lpadmin -p {} -o printer-is-shared=False && echo "[$dateandtime]	[INFO]	Turned off printer sharing" >> $logFile ) || echo "[$dateandtime]	[ERROR]	Failed to tur noff printer sharing." >> $logFile

removeMenuItem () {
plbuddy="/usr/libexec/PlistBuddy"
plist="$HOME/Library/Preferences/com.apple.systemuiserver.plist"

OIFS="$IFS"

menutemp=$(defaults read com.apple.systemuiserver menuExtras)
menutemp2=$(echo $menutemp | sed 's/( //')
menutemp3=$(echo $menutemp2 | sed 's/ )//')

IFS=','
read -a menuitems <<< "$menutemp3"
IFS="$OIFS"

for (( i = 0 ; i < ${#menuitems[@]} ; i++ ))
do
    if [[ "${menuitems[$i]}" == *"/System/Library/CoreServices/Menu Extras/HomeSync.menu"* ]]
    then
		$plbuddy -c "Delete :menuExtras:$i" $plist
	else
		echo "No match found"
    fi
done
}

( removeMenuItem && echo "[$dateandtime]	[INFO]	Removed HomeSync menuitem" >> $logFile ) || echo "[$dateandtime]	[ERROR]	Failed to remove HomeSync menuitem" >> $logFile

killall SystemUIServer && echo "[$dateandtime]	[INFO]	Restarted SystemUIServer" >> $logFile


echo "[$dateandtime]	[END]	Finished setting user preferences" >> $logFile
echo "********************************************************************************************" >> $logFile

open $logFile
