#!/bin/sh

##
## Check a single port of a host and set return value appropriately.
## Requires nmap
## Return Values:
## 0 Host is up and all ports open
## 1 Host is down
## 2 Host is up but some ports closed
## 3 Nmap failed
## 4 Unknown option/getopt error
## 5 No host provided
## 6 No port provided
## 7 Unknown error
##

unset error
error () {
	echo "$*" >&2
}

if ! which nmap > /dev/null; then
	error "FATAL: nmap not found."
	exit 2
fi

QUIET=0
PORTS=
HOST=
STATUS=
PORT_OPEN=0
PORT_CT=0
ERROR=0
USAGE_STRING="Usage: $0 [-hquv] -p PORT,... HOST"
HELP_STRING="${USAGE_STRING}

-h          Display this help message.
-p PORT,... List of ports to scan.
-q          Quiet mode. Still logs errors.
-u          Display usage string.
-v          Print version information and exit."

while getopts 'hp:quv' opt; do
	case $opt in
	h) echo "${HELP_STRING}"; exit 0 ;;
	p) PORTS=$OPTARG ;;
	q) QUIET=1 ;;
	u) echo "${USAGE_STRING}"; exit 0 ;;
	v) echo "checkport.sh 0.x Aiden Woodruff"; exit 0 ;;
	\?) echo "${USAGE_STRING}"; exit 4 ;;
	*) error "getopts issue"; exit 4
	esac
done
shift $((OPTIND - 1))

# Mostly just mirrors my other stuff. Not very useful here since I can't handle multiple hosts.
while [ $# -gt 0 ]; do
	case $1 in
	*) HOST=$1
	esac
	shift
done

unset log
log () {
	if [ "${QUIET}" -eq 0 ]; then
		echo "$*"
	fi
}

if [ "${HOST}" ]; then
	text="$(nmap -oG - -p${PORTS} ${HOST} | cat)"
	if [ $? -ne 0 ]; then
		error "Nmap failed"
		exit 3
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
		ERROR=6
	fi
else
	log "No host provided."
	ERROR=5
fi

if [ "${STATUS}" = "Up" ] && [ "${PORT_OPEN}" -eq "${PORT_CT}" ]; then
	exit 0
elif [ "${STATUS}" = "Down" ]; then
	exit 1
elif [ "${STATUS}" = "Up" ] && [ "${PORT_OPEN}" -ne "${PORT_CT}" ]; then
	exit 2
else
	exit ${ERROR}
fi
