#!/bin/sh

while read line; do {
echo $line
if [ "$line" != '\n' ]; then
spd-say -w "$line"
fi
} done < $1
