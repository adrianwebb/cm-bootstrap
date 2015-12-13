#!/bin/bash
#-------------------------------------------------------------------------------

# Uninstall the CM gem

echo "*** Removing old versions of CM gem"
su - -c "gem uninstall cm -x --force" root || exit 101

# Install the CM gem

if [ "$GEM_CM_DEV" ]
then
  rm -Rf /tmp/cm
  mkdir /tmp/cm || exit 102

  cd /tmp/cm || exit 103

  echo "*** Fetching CM source repository"
  git clone --branch "$GEM_CM_REVISION" git://github.com/adrianwebb/cm.git /tmp/cm || exit 104
  git submodule update --init --recursive || exit 105

  echo "*** Building CM gem from branch "$GEM_CM_REVISION""
  su - -c "cd /tmp/cm; gem build /tmp/cm/cm.gemspec" root || exit 106

  echo "*** Installing latest dev build of CM"
  su - -c "cd /tmp/cm; gem install /tmp/cm/cm-*.gem" root || exit 107
else
  echo "*** Installing latest release of CM"
  su - -c "gem install cm -v '$GEM_CM_VERSION'" root || exit 102
fi