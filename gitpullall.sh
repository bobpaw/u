#!/bin/sh

##
## Update all git repositories in current directory
##

for i in $(find -maxdepth 1 -type d | sed 's/\.\/\(.*\)/\1/'| grep -v "^.*\..*" | tr '\n' ' '); do {
  if [ -d ./${i}/.git ]; then
    echo "Pulling repository in folder ${i}"
    cd ${i}
    git pull
    cd ..
  fi
} done
