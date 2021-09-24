#!/bin/bash
LoggedInUser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
echo $LoggedInUser

LoggedInUserHome="/Users/$LoggedInUser"

su $LoggedInUser
killall Dock

configureDefaultDock() {

    echo "Logged in user is $LoggedInUser"
    echo "Logged in user's home $LoggedInUserHome"

    if [ -e /usr/local/bin/dockutil ]; then
        dockutilVersion=$(/usr/local/bin/dockutil --version --version)
        echo "dockutil version: $dockutilVersion"
    else
        echo "dockutil not installed, installing first..."
        curl "https://raw.githubusercontent.com/adamApptegy/macos-scripts/main/files/dockutil-2.0.5.pkg" -o /tmp/dockutil.pkg
        sudo installer -pkg /tmp/dockutil.pkg -target /
        rm /tmp/dockutil.pkg
    fi

    echo "Clearing Dock..."
    /usr/local/bin/dockutil --remove all --no-restart "$LoggedInUserHome"
    #Add the standard operating applications
    echo "Adding Launchpad..."
    /usr/local/bin/dockutil --add '/System/Applications/Launchpad.app' --no-restart --position 1 "$LoggedInUserHome"
    echo "Adding Notes..."
    /usr/local/bin/dockutil --add '/System/Applications/Notes.app' --no-restart --position 2 "$LoggedInUserHome"
    echo "Adding App Store..."
    /usr/local/bin/dockutil --add '/System/Applications/App Store.app' --no-restart --position 3 "$LoggedInUserHome"
    echo "Adding Google Chrome..."
    /usr/local/bin/dockutil --add '/Applications/Google Chrome.app' --no-restart --position 4 "$LoggedInUserHome"
    echo "Adding Slack..."
    /usr/local/bin/dockutil --add '/Applications/Slack.app' --no-restart --position 5 "$LoggedInUserHome"
    echo "Adding Zoom..."
    /usr/local/bin/dockutil --add '/Applications/zoom.us.app' --no-restart --position 6 "$LoggedInUserHome"
    echo "Adding System Preferences..."
    /usr/local/bin/dockutil --add '/System/Applications/System Preferences.app' --no-restart --position 7 "$LoggedInUserHome"

    # Department tools
    #check if transmit exists
    if [ -e /Applications/Transmit.app ]; then
        echo "Adding Transmit..."
        /usr/local/bin/dockutil --add '/Applications/Transmit.app' --no-restart --position 8 "$LoggedInUserHome"
    fi

    #check if pixelmator exists
    if [ -e /Applications/Pixelmator.app ]; then
        echo "Adding pixelmator..."
        /usr/local/bin/dockutil --add '/Applications/Pixelmator.app' --no-restart --position 8 "$LoggedInUserHome"
    fi

}

configureDefaultDock
killall -KILL Dock

exit 0
