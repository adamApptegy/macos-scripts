#!/bin/bash

CURRENT_USER=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

sudo -u $CURRENT_USER defaults read com.panic.Transmit | grep SerialNumber5 | cut -d'"' -f 2

