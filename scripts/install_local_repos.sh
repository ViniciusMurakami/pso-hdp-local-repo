#!/bin/bash

# When building a cluster from a local repo, you need to
#  adjust your yum repos to retrieve packages from it and
#  not from the repos on the net.

# First make copies of your current repos

if [ $# -lt 1 ]; then
echo "Need to specify the local repo hosts FQDN"
exit -1
fi

if [ `whoami` != "root" ]; then
echo "Must be root to run this script"
fi

DATE=`date +%y%m%d%H%M`

mkdir /etc/yum.repos.d/$DATE

# Remove any unnecessary repos from yum.
mv /etc/yum.repos.d/*.* /etc/yum.repos.d/$DATE

# Get the repos tuned for the local repo and place them in the /etc/yum.repos.d directory for yum.
wget http://$1/repos/local.yum.repos.d/ambari.repo -O /etc/yum.repos.d/ambari.repo
wget http://$1/repos/local.yum.repos.d/CentOS-Base.repo -O /etc/yum.repos.d/CentOS_Base.repo

