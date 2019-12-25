#!/bin/sh

which mawk >/dev/null && alias awk=mawk

cache_date="$(stat -c '%Y' /var/cache/apt/pkgcache.bin)"
lists_date="$(find /var/lib/apt/lists -type f -exec stat -c '%Y' '{}' \; 2>/dev/null | sort -n | tail -n1)"

if [ "$lists_date" -gt "$cache_date" ]; then
	apt_date="$lists_date"
else
	apt_date="$cache_date"
fi

if ! { [ -f .apt-get-updates.sh-cache ] && [ "$(stat -c '%Y' .apt-get-updates.sh-cache)" -gt "$apt_date" ]; } then
	# Check if there are updates and tell me if there are
	APT_GET_THINGS="$(apt-get upgrade -s | awk 'okaynow == 1 {print} /[0-9]+ upgraded/ {okaynow=1}')"
	if [ "${APT_GET_THINGS}" ]; then
		echo "${APT_GET_THINGS}" | awk 'seen[$2]++ {} END {for (item in seen) print "apt-get: " item}' > .apt-get-updates.sh-cache
	else
		touch .apt-get-updates.sh-cache
	fi
fi
cat .apt-get-updates.sh-cache
