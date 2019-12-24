#!/bin/sh

# Bi pride flag (12 long), only print for login shell (ie ssh/tty).

if echo "$-" | grep -q 'i'; then
	/bin/echo -e "O"
	/bin/echo -e "|\e[48;5;199m            \e[0m"
	/bin/echo -e "|\e[48;5;199m            \e[0m"
	/bin/echo -e "|\e[48;35;45m            \e[0m"
	/bin/echo -e "|\e[48;5;20m            \e[0m"
	/bin/echo -e "|\e[48;5;20m            \e[0m"
	/bin/echo -e "|"
	/bin/echo -e "|"
fi
