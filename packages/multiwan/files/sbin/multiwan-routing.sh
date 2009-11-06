#!/bin/sh -u

ifaceName="$1"
ifaceAction="$2"
ifaceIp="$3"
ifaceGw="$4"

ruleShiftLocal="10"
ruleShiftSelf="100"
ruleShiftFrom="200"

rt_tables="/etc/iproute2/rt_tables"

#######################################################################

uciGet()
  {
  uci get "$1" 2> /dev/null
  }

registerTable()
  {
  grep "^[[:digit:]]*[[:space:]]*${1}\$" "$rt_tables" > /dev/null && return
  local ri=1
  while grep "^$ri[[:space:]]" "$rt_tables" > /dev/null
    do
    ri="`expr "$ri" + 1`"
    done
  printf "$ri\t$1\n" >> "$rt_tables"
  }

setRoute()
  {
  ip route replace to "$1" via "$2" src "$3" table "$4"
  }

ipRuleDel()
  {
  ip rule show|grep "^$1\:"|
    {
    read p1 p2 from table
    while test -n "$from"
      do
      body=""
      test "$from" == "all" || body="from $from $table"
      ip rule delete priority "$1" $body 
      read p1 p2 from table
      done
    }
  }

setRule()
  {
  ipRuleDel "$1"
  ip rule add priority "$1" from "$2" table "$3"
  }

setSelfRoute()
  {
  registerTable "${1}_itself"
  setRoute "0.0.0.0/0" "$4" "$3" "${1}_itself"
  setRule "$2" "$3" "${1}_itself"
  }

doForEach()
  {
  local ri=0
  local param="`uciGet "multiwan.@${1}[$ri].$2"`"
  while test -n "$param"
    do
    $3 "$ri" "$param"
    ri="`expr "$ri" + 1`"
    param="`uciGet "multiwan.@${1}[$ri].$2"`"
    done
  }

setOneRoute()
  {
  setRoute "$5" "$3" "$2" "$1"
  }

setOneRule()
  {
  setRule "$2" "$4" "$1"
  }

setPolicyRouting()
  {
  test "$5" == "$1" &&
    {
    local thisFrom="`uciGet multiwan.@routing[$4].from`"
    local thisTo="`uciGet multiwan.@routing[$4].to`"
    local thisSticky="`uciGet multiwan.@routing[$4].sticky`"

    tableName="${thisFrom}_${thisTo}_${1}"
    test "$thisSticky" == "yes" && tableName="${tableName}_sticky"

    registerTable "${tableName}"

    doForEach "${thisTo}"   "cidr" "setOneRoute ${tableName} $2 $3"
    doForEach "${thisFrom}" "cidr" "setOneRule  ${tableName} `expr "$ruleShiftFrom" + "$4"`"
    }
  }

#######################################################################

test -n "$ifaceGw" &&
  {
  echo "Interface '$ifaceName' has a gateway '$ifaceGw', adding self-routes"

  ri="$ruleShiftSelf"
  #
  for riIface in `uci show multiwan|grep "^multiwan.@routing\[[[:digit:]]*\]\.via="|cut -d '=' -f 2|sort -u`
    do
    test "$riIface" == "$ifaceName" && setSelfRoute "$ifaceName" "$ri" "$ifaceIp" "$ifaceGw"
    ri="`expr "$ri" + 1`"
    done
  }

test "$ifaceAction" == "up" ||
  {
  echo "Interface '$ifaceName' down, removing corresponding routes"
  for t in `grep "_$ifaceName\$" "$rt_tables"|cut -f 2`
    do
    echo "Flushing table '$t'"
    ip route flush table "$t"
    done
  exit 0
  }

echo "Interface '$ifaceName' up, adding corresponding routes"

registerTable copyofmain
ip route flush table copyofmain
ip route show table main | grep -v '^default[[:space:]]' |
  {
  read line
  while test -n "$line"
    do
    ip route add $line table copyofmain
    read line
    done
  }
setRule "$ruleShiftLocal" 0.0.0.0/0 copyofmain

doForEach routing via "setPolicyRouting $ifaceName $ifaceIp $ifaceGw"

ip route flush cache
