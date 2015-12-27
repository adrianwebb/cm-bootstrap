#!/bin/bash
#-------------------------------------------------------------------------------

# Ensure CM configuration directory

echo "*** Ensuring default CM configuration directory"
mkdir -p /etc/cm

# Uninstall the CM gem

echo "*** Removing old versions of CM gem"
su - -c "gem uninstall cm -x --force" root || exit 101

# Install the CM gem

if [ "$GEM_CM_DEV" ]
then
  rm -Rf /tmp/cm

  echo "*** Installing Ruby Bundler library"  
  su - -c "gem install bundler -v '$GEM_BUNDLER_VERSION'" root || exit 102
  
  if [ "$GEM_CM_DIRECTORY" ]
  then
    echo "*** Copying local CM gem directory"
    cp -Rf "$GEM_CM_DIRECTORY" /tmp/cm || exit 103
    
    echo "*** Building CM gem from local copy"
  else
    mkdir /tmp/cm || exit 103
    cd /tmp/cm || exit 104

    echo "*** Fetching CM source repository"
    git clone --branch "$GEM_CM_REVISION" git://github.com/adrianwebb/cm.git /tmp/cm || exit 105
    git submodule update --init --recursive || exit 106
    
    echo "*** Building CM gem from branch "$GEM_CM_REVISION""
  fi  
  su - -c "cd /tmp/cm; bundle install" root || exit 107
  su - -c "cd /tmp/cm; bundle exec rake install" root || exit 108
else
  echo "*** Installing latest release of CM"
  su - -c "gem install cm -v '$GEM_CM_VERSION'" root || exit 102
fi