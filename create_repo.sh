#!/bin/sh
# This script is intended for use by us, but feel free to use it for your own purposes, too.


# defines the host on which your repository resides
git_host=""

# the path to your repositories
repo_home=""

# allow the config values to be overridden
if [ -e /usr/local/etc/create_repo.conf ]; then
	. /usr/local/etc/create_repo.conf
fi

if [ -z "$git_host" ]; then

fi

if [ -z "$repo_home" ]; then

fi

if [ $# -lt 1 ]; then
	echo "Usage: $0 <repo name>.git"
	exit 1
fi

if ! echo $1 | grep -q -E '.git$' ; then
	echo "Repo name '$1' must end in '.git'."
	exit 1
fi

if [ `whoami` = "git" ]; then
	mkdir $repo_home/$1
	cd $repo_home/$1;
	/usr/local/bin/git init --bare
	cat << __EOT
To clone the repo, run the following on your machine:

    git clone $git_host:$repo_home/$1

If you have already created the repo locally and need to add this one, run:

    git remote add origin $git_host:$repo_home/$1

Be sure to configure your name and email:

    git config user.email <email>
    git config user.name "<Full Name>"

************** TROUBLESHOOTING ******************************"

If you're unable to clone, be sure you have the following lines in your ~/.ssh/config:

Host $git_host
  User git
  Port 2242

If you still can't clone, it's likely that your public key is not in the git user's .ssh/authorized_keys file.

__EOT

else
	if ! groups | grep -q wheel ; then
		echo "Sorry, you must be part of the group 'wheel' to do this."
		exit 1
	fi

	echo "Enter your password to continue..."
	sudo -u git $0 $1

fi
