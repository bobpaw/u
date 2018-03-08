#!/bin/bash

PATH=/bin:/usr/bin:/usr/local/bin

QUIET=
PORT=
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
            PORT=$(echo ${i} | sed 's/^-p\([0-9]\+\)$/\1/')
            ;;
        *)
            HOST=${i}
    esac
done

if [ "${HOST}" ]; then
    text="`nmap -oG - -p${PORT} ${HOST} | cat`"
    if echo ${text} | grep -q 'Status: Up'; then
        STATUS="Up"
    else
        STATUS="Down"
    fi
    if [ -z "${QUIET}" ]; then
        echo "Host Status: ${STATUS}"
    fi
    if [ "${PORT}" -a "${STATUS}" = "Up" ]; then
        if grep "${PORT}/open" <(echo $text) > /dev/null; then
            if [ -z "${QUIET}" ]; then
                echo "Port ${PORT} is open."
            fi
            PORT_OPEN=true
        else
            if [ -z "${QUIET}" ]; then
                echo "Port ${PORT} is closed."
            fi
            PORT_OPEN=
        fi
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
