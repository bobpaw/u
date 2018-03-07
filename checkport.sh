#!/bin/sh

text="`nmap -oG - $1`"
status="`echo $text | sed 's/.*Status: \([[:alpha:]]\) .*$/\1/'`"
