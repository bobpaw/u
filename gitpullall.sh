#!/bin/bash

##
## Update all git repositories in current directory, or specified directories
##

for i in $*; do
    case $i in
        -d*)
            max="$(echo ${i} | cut -d'd' -f'2')"
            ;;
        -n)
            dont="true"
            ;;
        *)
            dirs="${dirs} ${i}"
            ;;
    esac
done

max=${max:-1}
dirs=${dirs:-.}
dont=${dont:-false}

if [ "${dont}" = "false" ]; then
    curl -Ls -o "$0-new" https://github.com/bobpaw/u/raw/master/gitpullall.sh
    diff <(sed 's/\\r\\n/\\n/' "$0") <(sed 's/\\r\\n/\\n/' "$0-new") --unchanged-line-format='' --old-line-format=''
    if [ "$(diff <(sed 's/\\r\\n/\\n/' $0) <(sed 's/\\r\\n/\\n/' $0-new) --unchanged-line-format='' --old-line-format='')" ]; then
        echo -n "There is a newer version available. Use it? [y/n]: "
        read answer
        if [ "${answer}" = "y" ]; then
            mv "$0-new" "$0"
            chmod +x "$0"
            exec "$0" -n "$@"
            exit 1
        fi
    fi
    rm -f "$0-new"
fi

for topdir in $dirs; do
    if cd $topdir; then
        for i in $(find -maxdepth ${max} -type d | sed 's/\.\/\(.*\)/\1/'| grep -v "^.*\..*" | tr '\n' ' '); do
            if [ -d ./${i}/.git ]; then
                echo "Pulling repository in folder ${i}"
                cd ${i}
                git pull --all
                cd ..
            fi
        done
    fi
done
