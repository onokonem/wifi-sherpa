#!/bin/sh

case "$1" in
        if-create)
                ;;
        if-up)
                /sbin/ifup wan
                ;;
        if-down)
                /sbin/ifdown wan
                ;;
        if-release)
                ;;
esac

exit 0