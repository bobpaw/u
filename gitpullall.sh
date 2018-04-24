#!/bin/sh

##
## Update all git repositories in current directory
##

for i in $*; do
    case $i in
        -d*)
            max=$(echo ${i} | cut -d'd' -f'2')
            ;;
        *)
            dirs=${dirs} ${i}
            ;;
    esac
done

max=${max:-1}
dirs=${dirs:-.}

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
