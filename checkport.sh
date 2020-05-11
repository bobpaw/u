#!/bin/sh

##
## Check a single port of a host and set return value appropriately.
## Requires nmap
##

PATH=/bin:/usr/bin:/usr/local/bin

QUIET=0
PORTS=
HOST=
STATUS=
PORT_OPEN=0
PORT_CT = 0
ERROR=0

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

log () {
	if [ -z "${QUIET}" ]; then
		echo "$*"
	fi
}

if [ "${HOST}" ]; then
	text="$(nmap -oG - -p${PORTS} ${HOST} | cat)"
	if [ $? -ne 0 ]; then
		log "nmap failed"
		exit 4
	fi
	if echo "${text}" | grep -qF 'Status: Up'; then
		STATUS="Up"
	else
		STATUS="Down"
	fi
	log "Host Status: ${STATUS}"
	if [ "${PORTS}" ] && [ "${STATUS}" = "Up" ]; then
		for PORT in $(echo "${PORTS}" | tr ',' ' '); do
			PORT_CT=$((PORT_CT + 1)) # Used below to determine the number of requested ports
			if echo "$text" | grep -qF "${PORT}/open"; then
				log "Port ${PORT} is open."
				PORT_OPEN=$((PORT_OPEN + 1))
			else
				log "Port ${PORT} is closed."
			fi
		done
	else
		log "No port provided."
		ERROR=1
	fi
else
	log "No host provided."
	ERROR=1
fi

if [ "${ERROR}" -ne 0 ] && [ "${STATUS}" = "Up" ] && [ "${PORT_OPEN}" -eq "${PORT_CT}" ]; then
	exit 0
elif [ "${ERROR}" -ne 0 ] && [ "${STATUS}" = "Down" ]; then
	exit 1
elif [ "${ERROR}" -ne 0 ] && [ "${STATUS}" = "Up" ] && [ "${PORT_OPEN}" -eq 0 ]; then
	exit 2
else
	exit 3
fi
