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
apt-get -y install build-essential="$BUILD_ESSENTIAL_VERSION" \
                   cmake="$CMAKE_VERSION" \
                   rake="$RAKE_VERSION" \
                   unzip="$UNZIP_VERSION" \
                   curl="$CURL_VERSION" \
                   zlibc="$ZLIBC_VERSION" \
                   bison="$BISON_VERSION" \
                   llvm="$LLVM_VERSION" \
                   llvm-dev="$LLVM_DEV_VERSION" \
                   zlib1g-dev="$ZLIB1G_DEV_VERSION" \
                   libpopt-dev="$LIBPOPT_DEV_VERSION" \
                   libpq-dev="$LIBPQ_DEV_VERSION" \
                   libssl-dev="$LIBSSL_DEV_VERSION" \
                   libcurl4-openssl-dev="$LIBCURL4_OPENSSL_DEV_VERSION" \
                   libxslt1-dev="$LIBXSLT1_DEV_VERSION" \
                   libyaml-dev="$LIBYAML_DEV_VERSION" \
                   libreadline6-dev="$LIBREADLINE6_DEV_VERSION" \
                   libncurses5-dev="$LIBNCURSES5_DEV_VERSION" \
                   libeditline-dev="$LIBEDITLINE_DEV_VERSION" \
                   libedit-dev="$LIBEDIT_DEV_VERSION" || exit 7
