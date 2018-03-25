#!/bin/sh

##
## Get current battery power
##

upower -i "$(upower -e | grep 'BAT')" | egrep "updated|percentage|time to|state" | sed 's/updated.*\(([0-9]* seconds ago)\)/updated: \1/' | sed 's/^[[:blank:]]*\(.*\)$/\1/g' | tr -s ' '
