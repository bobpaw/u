#!/bin/sh

which mawk >/dev/null && alias awk=mawk


apt_date="$( { find /var/lib/apt/lists -type f -exec stat -c '%Y' '{}' \; 2>/dev/null; stat -c '%Y' /var/cache/apt/pkgcache.bin /var/log/apt/history.log; } | sort -n | tail -n1)"

if ! [ -f ~/.apt-get-updates.sh-cache ] || [ "$(stat -c '%Y' ~/.apt-get-updates.sh-cache)" -lt "$apt_date" ]; then
	# Check if there are updates and tell me if there are
	APT_GET_THINGS="$(apt-get upgrade -s | awk 'okaynow == 1 {print} /[0-9]+ upgraded/ {okaynow=1}')"
	if [ "${APT_GET_THINGS}" ]; then
		echo "${APT_GET_THINGS}" | awk 'seen[$2]++ {} END {for (item in seen) print "apt-get: " item}' > ~/.apt-get-updates.sh-cache
	else
		: > ~/.apt-get-updates.sh-cache
	fi
fi
cat ~/.apt-get-updates.sh-cache
