#!/bin/bash
#
# Test exposed commands
#
function test_command {
  local name=$1
  local version=$2
  local version_options="${3:---version}"

  echo -n "it should expose the $name command... "
  su - -c "
  $name $version_options 2>&1 | grep -E '( |^)$version' > /dev/null
  " root
  [ "$?" -ne 0 ] && echo fail && exit 1
  echo pass
}
