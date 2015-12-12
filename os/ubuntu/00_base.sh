#!/bin/bash
#-------------------------------------------------------------------------------

if [ ! -f /.dockerinit ]
then
  # Set hostname
  echo "1. Setting hostname"
  echo "$HOSTNAME" > "/etc/hostname" || exit 1

  echo "2. Initializing hosts file"
  sed -ri 's/127\.0\.1\.1.*//' /etc/hosts
  echo "127.0.1.1 $HOSTNAME" >> /etc/hosts || exit 2
fi

# Set OpenDNS as our DNS lookup source
echo "3. Setting command DNS gateways"
echo "nameserver 208.67.222.222" | tee /etc/resolvconf/resolv.conf.d/base > /dev/null || exit 3
resolvconf -u || exit 4

# Force time update
echo "4. Forcing system time update"
ntpdate -s time.nist.gov

# Update system packages
echo "5. Updating system packages"
apt-get update >/tmp/update.log 2>&1 || exit 5

# Install basic build packages.
echo "6. Ensuring basic libraries and development utilities"
apt-get -y install build-essential="$BUILD_ESSENTIAL_VERSION" \
                   cmake="$CMAKE_VERSION" \
                   rake="$RAKE_VERSION" \
                   unzip="$UNZIP_VERSION" \
                   curl="$CURL_VERSION" \
                   git="$GIT_VERSION" \
                   ruby2.0="$RUBY_VERSION" \
                   ruby2.0-dev="$RUBY_DEV_VERSION" \
                   zlibc="$ZLIBC_VERSION" \
                   sqlite3="$SQLITE3_VERSION" \
                   libsqlite3-dev="$LIBSQLITE3_DEV_VERSION" \
                   zlib1g-dev="$ZLIB1G_DEV_VERSION" \
                   libmysqlclient-dev="$LIBMYSQLCLIENT_DEV_VERSION" \
                   libpopt-dev="$LIBPOPT_DEV_VERSION" \
                   libpq-dev="$LIBPQ_DEV_VERSION" \
                   libssl-dev="$LIBSSL_DEV_VERSION" \
                   libcurl4-openssl-dev="$LIBCURL4_OPENSSL_DEV_VERSION" \
                   libxslt1-dev="$LIBXSLT1_DEV_VERSION" \
                   libyaml-dev="$LIBYAML_DEV_VERSION" \
                   libreadline6-dev="$LIBREADLINE6_DEV_VERSION" >/tmp/base.install.log 2>&1 || exit 6
