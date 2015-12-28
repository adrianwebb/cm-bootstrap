#!/bin/bash
#-------------------------------------------------------------------------------

# Install (root level) RVM.
#
# Some of these commands borrowed from this tutorial:
# http://renaud-cuny.com/en/blog/2013-04-11-step-by-step-ruby-rvm-installation-ubuntu-server
#

function initialize_rvm_user()
{
  local USER_NAME="$1"
  local HOME_BASE="$2"
  
  local LOCAL_HOME="${HOME_BASE}/${USER_NAME}"
  local BASHRC_FILE="${LOCAL_HOME}/.bashrc"
  local PROFILE_FILE="${LOCAL_HOME}/.profile"
  
  local PATH_ENTRY='PATH=${PATH}:/usr/local/rvm/bin'
  local SCRIPT_INCLUDE="[[ -s '/usr/local/rvm/scripts/rvm' ]] && source '/usr/local/rvm/scripts/rvm'"

  echo "*** Initializing RVM user ${USER_NAME} group and environment settings"
  adduser "$USER_NAME" rvm || exit 54
  
  if ! grep -Fxq "$PATH_ENTRY" "$PROFILE_FILE"
  then
    echo "$PATH_ENTRY" >> "$PROFILE_FILE"
  fi
  if ! grep -Fxq "$SCRIPT_INCLUDE" "$BASHRC_FILE"
  then
    echo "$SCRIPT_INCLUDE" >> "$BASHRC_FILE"
  fi
}

echo "*** Ensuring Ruby development package"
apt-get -y install ruby-dev="$RUBY_DEV_VERSION" || exit 50

echo "*** Fetching RVM keys"
gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 || exit 51

echo "*** Installing RVM"
curl -sL https://get.rvm.io | bash -s stable || exit 52

if [ ! -e "/etc/profile.d/rvmsudo.sh" ]
then
echo "*** Adding a sudoers initialization file (compatible with RVM)"

( cat <<'EOP'
export rvmsudo_secure_path=1
alias sudo=rvmsudo
EOP
) > "/etc/profile.d/rvmsudo.sh" || exit 53
fi

initialize_rvm_user 'root'

for USER_HOME in /home/*/
do
  [[ "$USER_HOME" =~ ([^/]+)/?$ ]]
  if [ ! -L "${BASH_REMATCH[1]}" -a "${BASH_REMATCH[1]}" != "lost+found" -a "${BASH_REMATCH[1]}" != "*" ]
  then
    initialize_rvm_user "${BASH_REMATCH[1]}" '/home'
  fi
done

echo "*** Installing Ruby version $RVM_RUBY_VERSION -- this might take some time"

bash -l -c "rvm install $RVM_RUBY_VERSION" || exit 55
bash -l -c "rvm use $RVM_RUBY_VERSION --default" || exit 56

if [ ! -e "/root/.gemrc" ]
then
echo "*** Adding an initial .gemrc configuration"

# Set Gem options
( cat <<'EOP'
gem: --no-rdoc --no-ri 
EOP
) > "/root/.gemrc" || exit 57
fi
