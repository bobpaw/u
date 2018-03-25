#!/bin/sh

##
## Read a file using Speech Dispatcher
##

while read line; do {
  echo $line
  if [ "$line" != '\n' ]; then
    spd-say -w "$line"
  fi
} done < $1
