#!/bin/sh

##
## Read lines of STDIN using Speech Dispatcher
##

trap 'spd-say -S' SIGINT

while read line; do {
  if [ "$line" != '\n' ]; then
    spd-say -w $* "$line"
  fi
} done
