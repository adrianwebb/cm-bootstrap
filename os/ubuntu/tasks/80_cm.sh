#!/bin/bash
#-------------------------------------------------------------------------------

# Ensure CM configuration directory

echo "*** Ensuring default CM configuration directory"
mkdir -p /etc/cm

# Uninstall the CM gem

echo "*** Removing old versions of CM gem"
bash -l -c "gem uninstall cm -x --force" || exit 101

# Install the CM gem

if [ "$GEM_CM_DEV" ]
then
  rm -Rf /tmp/cm
  
  if [ "$GEM_CM_DIRECTORY" ]
  then
    echo "*** Copying local CM gem directory"
    cp -Rf "$GEM_CM_DIRECTORY" /tmp/cm || exit 102
    
    echo "*** Building CM gem from local copy"
  else
    mkdir /tmp/cm || exit 102
    cd /tmp/cm || exit 103

    echo "*** Fetching CM source repository"
    git clone --branch "$GEM_CM_REVISION" git://github.com/adrianwebb/cm.git /tmp/cm || exit 104
    git submodule update --init --recursive || exit 105
    
    echo "*** Building CM gem from branch "$GEM_CM_REVISION""
  fi  
  bash -l -c "cd /tmp/cm; gem build /tmp/cm/cm.gemspec" || exit 106

  echo "*** Installing development build of CM"
  bash -l -c "cd /tmp/cm; gem install /tmp/cm/cm-*.gem" || exit 107
else
  echo "*** Installing latest release of CM"
  bash -l -c "gem install cm -v '$GEM_CM_VERSION'" || exit 102
fi

# Test installed commands
echo "*** Testing installed cm commands"
test_command cm