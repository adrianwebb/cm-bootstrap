#!/bin/bash
#-------------------------------------------------------------------------------

# Install Git.
echo "*** Ensuring Git"
apt-get -y install git="$GIT_VERSION" || exit 10

# Make sure it is easy to communicate with repo hosts
echo "*** Adding GitHub to root known hosts"

mkdir -p "/root/.ssh" || exit 11
touch "/root/.ssh/known_hosts" || exit 12

ssh-keygen -R github.com || exit 13 # No duplicates
ssh-keyscan -H github.com >> "/root/.ssh/known_hosts" 2>/dev/null || exit 14

echo "*** Adding default Git configurations"
if [[ -z "`git config --global user.name`" ]] && [[ -n "$GIT_USER" ]]
then
  git config --global user.name "$GIT_USER"
fi
if [[ -z "`git config --global user.email`" ]] && [[ -n "$GIT_EMAIL" ]]
then
  git config --global user.email "$GIT_EMAIL"
fi
