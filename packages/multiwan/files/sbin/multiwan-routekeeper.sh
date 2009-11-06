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

write_resolv()
	{
	test -n "$2" &&
	echo "search $2" >> "$1"

	local ns
	test -n "$3" &&
	for ns in $3
	  do
      echo "nameserver $ns" >> "$1"
	  done
	}

write_null()
	{
	echo "nothing to do with $@"
	}

keepTheRoutes()
  {
  config_load multiwan

  local conntest_method="method_$CONFIG_conntest_method"

  local resolvfile="`uci get dhcp.@dnsmasq[0].resolvfile`"
  local write_resolv_func='write_null';
  test -n "$resolvfile" &&
    {
    write_resolv_func='write_resolv'
    echo > "$resolvfile.multiwan.tmp"
    }

  local iface
  #
  cd "$keepDir" &&
  for iface in *
    do
    local device address gateway nameservers domain
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
          /sbin/multiwan-routing.sh "$iface" up   "$address" "$gateway" "$nameservers" &&
          touch "$keepDir/../up/$iface" &&
          echo "up-flag '$iface' created"
          }
      else
        test -f "$keepDir/../up/$iface" &&
          {
          /sbin/multiwan-routing.sh "$iface" down "$address" "$gateway" "$nameservers" &&
          rm -f "$keepDir/../up/$iface" &&
          echo "up-flag '$iface' removed"
          }
        fi
      }
    $write_resolv_func "$resolvfile.multiwan.tmp" "$domain" "$nameservers"
    done
  test -n "$resolvfile" &&
  mv -f "$resolvfile.multiwan.tmp" "$resolvfile"
  }

####################################################################

echo $$ > /var/run/multiwan-routekeeper.pid

while true
  do
  keepTheRoutes 2>&1 | logger -p daemon.info -t routekeeper
  sleep "$CONFIG_conntest_interval"
  done < /dev/null 2>&1 > /dev/null