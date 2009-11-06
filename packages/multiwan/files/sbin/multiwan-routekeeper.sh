#!/bin/sh -u

keepDir="/tmp/multiwan/ifaces"

IPKG_INSTROOT='';
NO_CALLBACK='';
. /etc/functions.sh

config_load multiwan

method_ping()
  {
  
  local result="`ping -c "$CONFIG_conntest_tries"      \
                      -s "$CONFIG_conntest_packetsize" \
                      -w "$CONFIG_conntest_timeout"    \
                      -I "$1"                          \
                      -q                               \
                      "$CONFIG_conntest_destination"   |
                 grep '% packet loss$'|cut -d ' ' -f 7|tr -d '%'`"
  test "$result" -lt "$CONFIG_conntest_treshold"
  local retVal=$?
  echo "testing interface '$1' with method ping, result: $retVal (${result}:${CONFIG_conntest_treshold})"
  return $retVal
  }

keepTheRoutes()
  {
  config_load multiwan

  conntest_method="method_$CONFIG_conntest_method"

  local iface
  
  cd "$keepDir" &&
  for iface in *
    do
    local device address gateway
    . "./$iface"
    test -n "$gateway" &&
      {
      local result='';
      "$conntest_method" "$address" && result='up'
      if test -n "$result"
        then
        test -f "$keepDir/../up/$iface" ||
          {
          mkdir -p "$keepDir/../up" &&
          /sbin/multiwan-routing.sh "$iface" up   "$address" "$gateway" &&
          touch "$keepDir/../up/$iface" &&
          echo "Flag '$iface' created"
          }
      else
        test -f "$keepDir/../up/$iface" &&
          {
          /sbin/multiwan-routing.sh "$iface" down "$address" "$gateway" &&
          rm -vf "$keepDir/../up/$iface"
          }
        fi
      }
    done
  }

####################################################################

echo $$ > /var/run/multiwan-routekeeper.pid

while true
  do
  keepTheRoutes 2>&1 | logger -p daemon.info -t routekeeper
  sleep "$CONFIG_conntest_interval"
  done < /dev/null 2>&1 > /dev/null