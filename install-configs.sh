#!/bin/sh

##
## install-configs.sh
## Installs files in the configs folder to HOME
##
## Options:
##
## -i PREFIX Set prefix to install files into (default: ~)
## --prefix=PREFIX
## -h Display help
## -u Display usage
##

NEXT_PREFIX=0
PREFIX=$HOME
FOLDER="configs"

for opt in $*; do
	case $opt in
		-i)
			NEXT_PREFIX=1
			;;
		-i* | --prefix=*)
			if echo "$i" | grep -q '^-i'; then
				PREFIX="$(echo $opt | sed 's/^-i//')"
			else
				PREFIX="$(echo $opt | sed 's/^--prefix=//')"
			fi
			;;
		-u)
			echo "Usage: $0 [-hu] [-i PREFIX] [FOLDER]"
			exit 0
			;;
		-h)
			echo "Full help not yet implemented"
			exit 0
			;;
		*)
			if [ "$NEXT_PREFIX" -eq 1 ]; then
				PREFIX=$opt
			fi
			;;
	esac
done

file_list="$(find $FOLDER -type f ! -name README*)"
for i in $file_list; do
	install -t $PREFIX $i && echo "Successfully installed $i" || { echo "Error installing $i"; exit 1; }
done


