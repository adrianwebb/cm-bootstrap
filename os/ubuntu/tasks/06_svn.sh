#!/bin/bash
#-------------------------------------------------------------------------------

# Install SVN.
echo "*** Ensuring SVN"
apt-get -y install subversion="$SVN_VERSION" || exit 11
