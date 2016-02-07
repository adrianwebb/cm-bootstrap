#!/bin/bash
#-------------------------------------------------------------------------------

# Install SVN.
echo "*** Ensuring SVN"
apt-get -y install subversion || exit 11

# Test installed packages
echo "*** Testing installed svn packages"
test_package subversion

# Test installed commands
echo "*** Testing installed svn commands"
test_command svn