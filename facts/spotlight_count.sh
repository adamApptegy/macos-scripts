#/bin/bash
# This is from an Addigy Community fact
direct1=$(sudo find /private/var/folders/*/*/C/com.apple.metadata.mdworker -type d 2>/dev/null | wc -l | tr -d ' ')
direct2=$(sudo find /private/var/folders/*/*/C/com.apple.mdworker.bundle -type d 2>/dev/null | wc -l | tr -d ' ')

sum=$(( $direct1 + $direct2 ))

echo $sum