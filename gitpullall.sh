#!/bin/bash

##
## Update all git repositories in current directory, or specified directories
##

for i in $*; do
    case $i in
        -d*)
            max="$(echo ${i} | cut -d'd' -f'2')"
            ;;
        -u)
            check="true"
            ;;
        *)
            dirs="${dirs} ${i}"
            ;;
    esac
done

max=${max:-1}
dirs=${dirs:-.}
check=${check:-false}

if [ "${check}" = "true" ]; then
    self_history="$(curl -s https://api.github.com/repos/bobpaw/u/commits?path=gitpullall.sh)"
    self_reallast="$(stat -c %Y $0)"
    git_last=$(python3 -c "
import json
import dateutil.parser as dp
hist_string = '''$(echo ${self_history} | sed 's/\\/\\\\/g')'''
date = json.loads(hist_string)[0]['commit']['author']['date']
parsed = dp.parse(date)
print(parsed.strftime('%s'))
"
)
    if [ "${git_last}" -gt "${self_reallast}" ]; then
        echo -n "There is a newer version available from GitHub. Try to get it? [y/n]: "
        read answer
        if [ "${answer}" = "y" ]; then
            curl -Ls -o "$0-new" https://github.com/bobpaw/u/raw/master/gitpullall.sh
            unix_self=$(mktemp)
            unix_new=$(mktemp)
            sed 's/\\r\\n/\\n/' "$0" > ${unix_self}
            sed 's/\\r\\n/\\n/' "$0-new" > ${unix_new}
            echo "Diff:"
            diff ${unix_self} ${unix_new}
            if [ "$(diff ${unix_self} ${unix_new})" ]; then
                echo -n "Use the newer version? [y/n]: "
                read answer
                if [ "${answer}" = "y" ]; then
                    cat > "$0-mid" <<EOF
mv "$0-new" "$0"
chmod +x "$0"
exec "$0" $(awk '{ for (i = 0; i < NF; ++i) if (i != "-u" ) printf "%s ", $i }')
exit 1
EOF
                    exec "$0-mid"
                fi
            else
                touch "$0"
            fi
            rm -f "$0-new" "${unix_self}" "${unix_new}"
        fi # use it?
    fi # Older?
fi # Check flag?

for topdir in ${dirs}; do
    if pushd ${topdir} > /dev/null; then
        for i in $(find -maxdepth ${max} -type d | sed 's/\.\/\(.*\)/\1/'| grep -v "^.*\..*" | tr '\n' ' '); do
            if [ -d ./${i}/.git ]; then
                echo -n "Pulling repository in folder ${i}"
                pushd ${i} > /dev/null
                git_output="$(git pull --all |& tail -n+2)"
                if [ "$(echo $git_output | awk 'END {print FNR}')" -eq 1 ]; then
                    echo " - ""$git_output"
                else
                    echo
                    echo "$git_output"
                fi
                popd > /dev/null
            fi
        done
    fi
    popd > /dev/null
done

