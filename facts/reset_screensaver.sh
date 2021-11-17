#!/bin/zsh
## Get logged in user
CURRENT_USER=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

## Set the screensaver timeout to 30 minutes (30*60)
sudo -u $CURRENT_USER defaults -currentHost write com.apple.screensaver idleTime -int 1800