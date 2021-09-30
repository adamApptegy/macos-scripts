#/bin/bash

APP_NAME="Google Chrome.app"
APP_PATH="/Applications/$APP_NAME"
APP_DIRECTORY="/Applications/Google Chrome.app"
APP_PROCESS_NAME="Google Chrome"

CURRENT_USER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

NEW_VERSION=$(curl -s https://raw.githubusercontent.com/adamApptegy/macos-scripts/main/application_versions.csv | grep chrome | awk -F',' '{print $2}')
echo "New version is: $NEW_VERSION"

CURRENT_VERSION=$(/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version | cut -d' ' -f3)

echo "Current version is: $CURRENT_VERSION"

arch_name="$(uname -m)"

if [ "${arch_name}" = "x86_64" ]; then
    if [ "$(sysctl -in sysctl.proc_translated)" = "1" ]; then
        echo "Running on Rosetta 2"
    else
        echo "Running on native Intel"
    fi
    ARCH_TYPE="Intel"
elif [ "${arch_name}" = "arm64" ]; then
    echo "Running on ARM"
    ARCH_TYPE="M1"
else
    echo "Unknown architecture: ${arch_name}"
    ARCH_TYPE="UNKNOWN"
fi

vercomp() { #NEW_VERSION, #TARGET_VERSION - 0 means the same, 1 means TARGET is newer, 2 means INSTALLED is newer
    if [[ $1 == $2 ]]; then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i = ${#ver1[@]}; i < ${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i = 0; i < ${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 2
        fi
    done
    return 0
}

vercomp ${NEW_VERSION} ${CURRENT_VERSION}
COMP=$? # 0 means the same, 1 means TARGET is newer, 2 means INSTALLED is newer
echo "COMPARISON: ${COMP}"

if [ "${COMP}" -eq 1 ]; then # 1
    echo "Installed version is older than ${NEW_VERSION}."
    echo "Prompting ${CURRENT_USER} to close Google Chrome."

    CLOSE_CHROME="$(sudo launchctl asuser $CURRENT_USER /usr/bin/osascript -e 'Tell current application to display dialog "Your Google Chrome is outdated and must be Updated to version '$NEW_VERSION'. Click Update Now to close Google Chrome and get its latest release." with title "Google Chrome Update" with text buttons {"Update Now", "Later"} default button "Update Now"')"

    if [ "$CLOSE_CHROME" = "button returned:Update Now" ]; then
        if [ "$ARCH_TYPE" = "Intel" ]; then
            echo "Installing Intel version"
            DL_URL="https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
        elif ["$ARCH_TYPE" = "M1" ]; then
            echo "Installing M1 version"
            DL_URL="https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg"
        else
            echo "Unknown architecture"
            exit 1
        fi
        if pgrep "$APP_PROCESS_NAME" &>/dev/null; then
            #killall "Google Chrome"
            echo "killed chrome"
        fi
        TEMP_LOCATION="/tmp/chrome.dmg"
        echo "Installing from URL $DL_URL"
        curl -sLo $TEMP_LOCATION "$DL_URL"
        hdiutil attach -nobrowse -quiet "$TEMP_LOCATION";
        ditto -rsrc "/Volumes/Google Chrome/Google Chrome.app" "/Applications/Google Chrome.app"
        hdiutil detach "/Volumes/Google Chrome"
        rm "$TEMP_LOCATION"

        echo "Google Chrome installed successfully at version ${NEW_VERSION}"
        sudo launchctl asuser $CURRENT_USER /usr/bin/osascript -e 'Tell current application to display dialog "Your Google Chrome has been successfully updated to version '$NEW_VERSION'." with title "Success!" with text buttons {"OK"} default button "OK"'
        exit 0
    else
        echo "Scheduled for the next day."
        exit 1
    fi
else
    echo "Installed version is the same or newer than the ${NEW_VERSION}."
    exit 1
fi
