#!/bin/sh

##
## Update all git repositories in current directory, or specified directories
##

for i in $*; do
    case $i in
        -d*)
            max=$(echo ${i} | cut -d'd' -f'2')
            ;;
        -n)
            dont=true
            ;;
        *)
            dirs=${dirs} ${i}
            ;;
    esac
done

max=${max:-1}
dirs=${dirs:-.}
dont=${dont:-false}

if [ "${dont}" = "false" ]; then
    tempfile=$(mktemp "${TMPDIR:-/tmp/}tmp.$(basename $0).XXXXXXX")

    curl -L -s -o ${tempfile} https://github.com/bobpaw/u/raw/master/gitpullall.sh

    diff gitpullall.sh ${tempfile} --unchanged-line-format='' --old-line-format=''
    if [ "$(diff gitpullall.sh ${tempfile} --unchanged-line-format='' --old-line-format='')" ]; then
        echo -n "There is a newer version available. Use it? [y/n]: "
        read answer
        if [ "${answer}" = "y" ]; then
            exec $(readlink -f /proc/$$/exe) gitpullall-new.sh -n
            exit 1
        fi
    fi
fi

for topdir in $dirs; do
    if cd $topdir; then
        for i in $(find -maxdepth ${max} -type d | sed 's/\.\/\(.*\)/\1/'| grep -v "^.*\..*" | tr '\n' ' '); do
            if [ -d ./${i}/.git ]; then
                echo "Pulling repository in folder ${i}"
                cd ${i}
                git pull
                cd ..
            fi
        done
    fi
done
