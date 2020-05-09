#!/bin/bash

##
## Check a single port of a host and set return value appropriately.
## Requires nmap
##

PATH=/bin:/usr/bin:/usr/local/bin

QUIET=
PORTS=
HOST=
STATUS=
PORT_OPEN=
ERROR=

for i in $*; do
	case ${i} in
		-q)
			QUIET=true
			;;
		-p*)
			PORTS=$(echo ${i} | sed 's/^-p\([0-9,-]\+\)$/\1/')
			;;
		*)
			HOST=${i}
	esac
done

if [ "${HOST}" ]; then
	text="`nmap -oG - -p${PORTS} ${HOST} | cat`"
	if echo ${text} | grep -q 'Status: Up'; then
		STATUS="Up"
	else
		STATUS="Down"
	fi
	if [ -z "${QUIET}" ]; then
		echo "Host Status: ${STATUS}"
	fi
	if [ "${PORTS}" -a "${STATUS}" = "Up" ]; then
		for PORT in $(echo ${PORTS}|tr ',' ' '); do
			if grep "${PORT}/open" <(echo $text) > /dev/null; then
				if [ -z "${QUIET}" ]; then
					echo "Port ${PORT} is open."
				fi
				if [ -z "${PORT_OPEN}" ]; then
					PORT_OPEN=true
				fi
			else
				if [ -z "${QUIET}" ]; then
					echo "Port ${PORT} is closed."
				fi
				PORT_OPEN=false
			fi
		done
	else
		if [ -z "${QUIET}" ]; then
			echo "No port provided."
		fi
		ERROR=true
	fi
else
	if [ -z "${QUIET}" ]; then
		echo "No host provided."
	fi
	ERROR=true
fi
if [ ! "${ERROR}" -a "${STATUS}" = "Up" -a "${PORT_OPEN}" ]; then
	exit 0
elif [ ! "${ERROR}" -a "${STATUS}" = "Down" ]; then
	exit 1
elif [ ! "${ERROR}" -a "${STATUS}" = "Up" -a ! "${PORT_OPEN}" ]; then
	exit 2
else
	exit 3
fi
