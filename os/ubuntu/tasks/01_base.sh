#!/bin/bash
#-------------------------------------------------------------------------------

if [ ! -f /.dockerinit ]
then
  # Set hostname
  echo "*** Setting hostname"
  echo "$HOSTNAME" > "/etc/hostname" || exit 1

  echo "*** Initializing hosts file"
  sed -ri 's/127\.0\.1\.1.*//' /etc/hosts
  echo "127.0.1.1 $HOSTNAME" >> /etc/hosts || exit 2
fi

# Set OpenDNS as our DNS lookup source
echo "*** Setting command DNS gateways"
echo "nameserver $DNS_IP" | tee /etc/resolvconf/resolv.conf.d/base 1>/dev/null || exit 3
resolvconf -u || exit 4

# Force time update
echo "*** Forcing system time update"
ntpdate -s time.nist.gov

echo "*** Updating system timezone"
ln -sf "/usr/share/zoneinfo/$SYSTEM_TIMEZONE" /etc/localtime

# Test time information
echo "*** Testing system configuration"
test_timezone "$SYSTEM_TIMEZONE"

# Set locale information
echo "*** Generating US UTF-8 system locale"
locale-gen "$SYSTEM_LOCALE"

echo "*** Setting "$SYSTEM_LOCALE" system locale"
LOCALE_PATH="/etc/profile.d/locale.sh"

if [ ! -e "$LOCALE_PATH" ]
then
( cat <<'EOP'
export LANG="$SYSTEM_LOCALE"
EOP
) > "$LOCALE_PATH" || exit 5
fi
source "$LOCALE_PATH"

# Update system packages
echo "*** Updating system packages"
apt-get update || exit 6

# Install basic build packages.
echo "*** Ensuring basic libraries and development utilities"
apt-get -y install build-essential \
                   cmake \
                   rake \
                   unzip \
                   curl \
                   zlibc \
                   bison \
                   llvm \
                   llvm-dev \
                   zlib1g-dev \
                   libpopt-dev \
                   libpq-dev \
                   libssl-dev \
                   libcurl4-openssl-dev \
                   libxslt1-dev \
                   libyaml-dev \
                   libreadline6-dev \
                   libncurses5-dev \
                   libeditline-dev \
                   libedit-dev || exit 7

# Test installed packages
echo "*** Testing installed base packages"
test_package build-essential
test_package cmake
test_package rake
test_package unzip
test_package curl
test_package zlibc
test_package bison
test_package llvm
test_package llvm-dev
test_package zlib1g-dev
test_package libpq-dev
test_package libpopt-dev
test_package libssl-dev
test_package libcurl4-openssl-dev
test_package libxslt1-dev
test_package libyaml-dev
test_package libreadline6-dev
test_package libeditline-dev
test_package libedit-dev

# Test installed commands
echo "*** Testing installed base commands"
test_command make
test_command cmake
test_command rake
test_command openssl version
test_command unzip
test_command curl
