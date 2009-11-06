#!/bin/sh 

keepDir="/tmp/multiwan/ifaces"

. /etc/functions.sh

method_ping()
  {
  ping -c "$CONFIG_conntest_tries"      \
       -s "$CONFIG_conntest_packetsize" \
       -w "$CONFIG_conntest_timeout"    \
       -I "$1"                          \
       -q                               \
       "$CONFIG_conntest_destination"   |
  grep '% packet loss$'|tr -d '%'|cut -d ' ' -f 7|read result
  test "$result" -lt "$$CONFIG_conntest_treshold"
  }

keepTheRoutes()
  {
  config_load multiwan

  conntest_method="method_$CONFIG_conntest_method"

  local iface
  
  cd "$keepDir/ifaces/" &&
  for iface in *
    do
    local device ipaddr gateway
    . "$iface"
    local result='';
    "$conntest_method" "$ipaddr" && result='up'
    if test -n "$result"
      test -f "$keepDir/up/$iface" ||
        {
        mkdir -p "$keepDir/../up" &&
        /sbin/multiwan-routing.sh "$face" up   "$ipaddr" "$gateway" &&
        touch "$keepDir/../up/$iface" &&
        echo "Flag '$iface' created"
        }
    else
      test -f "$keepDir/up/$iface" &&
        {
        /sbin/multiwan-routing.sh "$face" down "$ipaddr" "$gateway" &&
        rm -vf "$keepDir/../up/$iface"
        }
      fi
    done
  }

####################################################################

echo $$ > /var/run/multiwan-routekeeper.pid

while true
  {
  keepTheRoutes 2>&1 | logger -p daemon.info -t routekeeper
  sleep 1
  } < /dev/null 2>&1 > /dev/null