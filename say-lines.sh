#!/bin/sh

while read line; do {
if [ "$line" != '\n' ]; then
spd-say -w $* "$line"
fi
} done
