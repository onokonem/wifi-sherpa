#!/bin/sh

case "$1" in
        if-create)
                ;;
        if-up)
                ifName="`ifconfig|grep wimax|head -n 1|awk '{print $1}'`"
                uci set network.wan.ifname="$ifName"
                /sbin/ifup wan
                /etc/init.d/firewall restart
                ;;
        if-down)
                /sbin/ifdown wan
                ;;
        if-release)
                ;;
esac

exit 0