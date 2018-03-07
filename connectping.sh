#!/bin/sh

host = "`tcpdump -c1 'icmp[icmptype] == icmp-echo' 2> /dev/null | cut -f3 -d' '`"

echo $host
if [ $1 ]; then
echo 'user given'
ssh $1@$host
else
ssh $host
fi
