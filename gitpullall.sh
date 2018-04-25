#!/bin/sh

##
## Update all git repositories in current directory, or specified directories
##

tempfile=$(mktemp "${TMPDIR:-/tmp/}tmp.$(basename $0).XXXXXXX")

curl -L -s -o ${tempfile} https://github.com/bobpaw/u/raw/master/gitpullall.sh

if [ "$(diff gitpullall.sh ${tempfile} --unchanged-line-format='' --old-line-format='')" ]; then
  echo -n "There is a newer version available. Use it? [y/n]: "
  read answer
  if [ "${answer}" = "y" ]; then
    cp ${tempfile} "$(dirname $0)/gitpullall-new.sh"
    echo "mv gitpullall-new.sh gitpullall.sh" >> gitpullall-fix.sh
    echo "$(readlink -f /proc/$$/exe) gitpullall.sh" >> gitpullall-fix.sh
    echo "rm -- $0" >> gipullall-fix.sh
    exec $(readlink -f /proc/$$/exe) gitpullall-new.sh
  fi
fi

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
