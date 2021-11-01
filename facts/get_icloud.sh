#!/bin/zsh
## Get logged in user
CURRENT_USER=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
icloudaccount=$( defaults read /Users/$CURRENT_USER/Library/Preferences/MobileMeAccounts.plist Accounts | grep AccountID | cut -d '"' -f 2) 2>/dev/null
if [ -z "$icloudaccount" ] 
then
    echo "No Accounts Signed In"
else
    echo "$icloudaccount"
fi