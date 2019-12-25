#!/bin/sh

##
## install-configs.sh
## Installs files in the configs folder to HOME
##
## Options:
##
## -b Copy backups (default is no)
## -i PREFIX Set prefix to install files into (default: ~)
## --prefix=PREFIX
## -h Display help
## -n Never replace destination files
## -q Quiet mode (Implies -n unless -y is specified)
## -u Display usage
## -v Verbose mode
## -y Always replace destination files
##

BACKUPS=0
NEXT_PREFIX=0
PREFIX=$HOME
FOLDER="configs"
REPLACE_ALL=0
QUIET=0
VERBOSE=0

for opt in $*; do
	case $opt in
		-b)
			BACKUPS=1
			;;
		-h)
			echo "Full help not yet implemented"
			exit 0
			;;
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
		-n)
			REPLACE_ALL=-1
			;;
		-q)
			QUIET=1
			[ "$REPLACE_ALL" -eq 0 ] && REPLACE_ALL=-1
			;;
		-u)
			echo "Usage: $0 [-bhnquvy] [-i PREFIX] [FOLDER]"
			exit 0
			;;
		-v)
			VERBOSE=1
			;;
		-y)
			REPLACE_ALL=1
			;;
		*)
			if [ "$NEXT_PREFIX" -eq 1 ]; then
				PREFIX=$opt
			fi
			;;
	esac
done

if [ "$BACKUPS" -eq 0 ]; then
	file_list="$(find $FOLDER -type f ! -name 'README*' ! -name '*~')"
else
	file_list="$(find $FOLDER -type f ! -name README*)"
fi

dup_list=""

for i in $file_list; do
	if [ -f "$PREFIX/$(basename $i)" ] && [ "$(diff $i $PREFIX/$(basename $i))" ]; then
		dup_list="$dup_list $i"
	elif [ -z "$(diff $i $PREFIX/$(basename $i))" ]; then
		[ "$VERBOSE" -eq 1 ] && echo "Not replacing identical $(basename $i)"
	else
		install -t $PREFIX $i && { [ "$VERBOSE" -eq 1 ] && echo "Successfully installed $(basename $i)" || true; } || echo "Error installing $(basename $i)" > /dev/null >&2
	fi
done

case_success=0

for i in $dup_list; do
	case_success=0
	if [ "$REPLACE_ALL" -eq 0 ]; then
		echo -n "File $(basename $i) already exists. $PREFIX/$(basename $i) is "
		if [ "$(stat -c '%Y' $i)" -lt "$(stat -c '%Y' $PREFIX/$(basename $i))" ]; then
			echo "newer."
		else
			echo "older."
		fi
		until [ "$case_success" -eq 1 ]; do
			read -p "Replace it? [(y)es/(n)o/(d)iff/(a)ll/ne(v)er]: " response
			case $response in
				y)
					install -t $PREFIX $i && { [ "$VERBOSE" -eq 1 ] && echo "Successfully installed $(basename $i)" || true; } || echo "Error installing $(basename $i)" > /dev/null >&2
					case_success=1
					;;
				n)
					[ "$VERBOSE" -eq 1 ] && echo "Not installing $(basename $i)"
					case_success=1
					;;
				a)
					REPLACE_ALL=1
					install -t $PREFIX $i && { [ "$VERBOSE" -eq 1 ] && echo "Successfully installed $(basename $i)" || true; } || echo "Error installing $(basename $i)" > /dev/null >&2
					case_success=1
					;;
				v)
					REPLACE_ALL=-1
					[ "$VERBOSE" -eq 1 ] && echo "Not installing $(basename $i)"
					case_success=1
					;;
				d)
					echo "Not yet implemented"
					;;
				*)
					;;
			esac
		done
	elif [ "$REPLACE_ALL" -eq -1 ]; then
		[ "$VERBOSE" -eq 1 ] && echo "Not installing $(basename $i)"
	else
		install -t $PREFIX $i && { [ "$VERBOSE" -eq 1 ] && echo "Successfully installed $(basename $i)" || true; } || echo "Error installing $(basename $i)" > /dev/null >&2
	fi
done
