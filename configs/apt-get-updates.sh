#!/bin/sh

# Check if there are updates and tell me if there are
APT_GET_THINGS="$(apt-get upgrade -s | mawk 'okaynow == 1 {print} /[0-9]+ upgraded/ {okaynow=1}')"
if [ "${APT_GET_THINGS}" ]; then
	echo "${APT_GET_THINGS}" | mawk 'seen[$2]++ {} END {for (item in seen) print "apt-get: " item}'
fi
