#!/bin/bash

# Establish a Local Repository with the appropriate mirrors and templates
#  that can be used by the cluster.

# Ensure script being run as root.
if [ `whoami` != "root" ]; then
echo "Must be root to run this script."
exit -1
fi

# Determine if httpd has been installed
HTTPD=`yum list installed | grep httpd`
if [ "$HTTPD" == "" ]; then
# Install httpd
yum -y install httpd
service httpd start
fi

# install the HDP repos
wget -nv http://public-repo-1.hortonworks.com/HDP/centos6/1.x/GA/1.3.0.0/hdp.repo -O /etc/yum.repos.d/hdp.repo
wget -nv http://public-repo-1.hortonworks.com/ambari/centos6/1.x/updates/1.2.4.9/ambari.repo -O /etc/yum.repos.d/ambari.repo

yum repolist

# Install the epel repo
yum -y install epel-release
yum -y install yum-utils
yum -y install createrepo

# Copy the repo templates to the httpd server


# Create directories for repos
# Attempting to mimic the published repo structure as much as possible
BASE_REPO_DIR="/var/www/html/repos"

# Copy the repo templates to the httpd server
if [ -d  $BASE_REPO_DIR/local.yum.repos.d ]; then
mkdir -p $BASE_REPO_DIR/local.yum.repos.d
fi

if [ ! -d $BASE_REPO_DIR/jdk ]; then
mkdir -p $BASE_REPO_DIR/jdk
fi

if [ ! -f $BASE_REPO_DIR/jdk/jdk-6u31-linux-x64.bin ]; then
wget -nv http://public-repo-1.hortonworks.com/ARTIFACTS/jdk-6u31-linux-x64.bin -O $BASE_REPO_DIR/jdk/jdk-6u31-linux-x64.bin
fi

if [ -d $BASE_REPO_DIR/local.yum.repos.d ]; then
rm $BASE_REPO_DIR/local.yum.repos.d
fi

mkdir -p $BASE_REPO_DIR/local.yum.repos.d

wget https://bitbucket.org/dstreev/hwx-ps-utils/raw/f7606b83841acfbcc6030dd37676863e416bf6f2/templates/ambari.repo -O $BASE_REPO_DIR/local.yum.repos.d/ambari.repo

sed -i bak -e "s:!local.repo.host!:`hostname`:g" $BASE_REPO_DIR/local.yum.repos.d/ambari.repo
sed -i bak -e "s:!local.repo.host!:`hostname`:g" $BASE_REPO_DIR/local.yum.repos.d/CentOS-Base.repo

# ambari-1.x
# baseurl=http://public-repo-1.hortonworks.com/ambari/centos6/1.x/GA
if [ -d  $BASE_REPO_DIR/ambari/centos6/1.x/GA ]; then
mkdir -p $BASE_REPO_DIR/ambari/centos6/1.x/GA
fi

# HDP-UTILS-1.1.0.15
# http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.15/repos/centos6
if [ -d  $BASE_REPO_DIR/HDP-UTILS-1.1.0.15/repos/centos6 ]; then
mkdir -p $BASE_REPO_DIR/HDP-UTILS-1.1.0.15/repos/centos6
fi

# Updates-ambari-1.2.4.9
# baseurl=http://public-repo-1.hortonworks.com/ambari/centos6/1.x/updates/1.2.4.9
if [ -d  $BASE_REPO_DIR/ambari/centos6/1.x/updates/1.2.4.9 ]; then
mkdir -p $BASE_REPO_DIR/ambari/centos6/1.x/updates/1.2.4.9
fi

# epel
# baseurl=http://download.fedoraproject.org/pub/epel/6/$basearch (x86_64)
if [ -d  $BASE_REPO_DIR/pub/epel/6/x86_64 ]; then
mkdir -p $BASE_REPO_DIR/pub/epel/6/x86_64
fi

# HDP-1.3.0.0
# http://public-repo-1.hortonworks.com/HDP/centos6/1.x/GA/1.3.0.0
if [ -d  $BASE_REPO_DIR/HDP/centos6/1.x/GA/1.3.0.0 ]; then
mkdir -p $BASE_REPO_DIR/HDP/centos6/1.x/GA/1.3.0.0
fi

# Install the repo for Ambari and HDP
reposync -r ambari-1.x -p $BASE_REPO_DIR/ambari/centos6/1.x/GA --norepopath
reposync -r HDP-UTILS-1.1.0.15 -p $BASE_REPO_DIR/HDP-UTILS-1.1.0.15/repos/centos6 --norepopath
reposync -r HDP-1.3.0.0 -p $BASE_REPO_DIR/HDP/centos6/1.x/GA/1.3.0.0 --norepopath
reposync -r Updates-ambari-1.2.4.9 -p $BASE_REPO_DIR/ambari/centos6/1.x/updates/1.2.4.9
reposync -r epel -p $BASE_REPO_DIR/pub/epel/6/x86_64 --norepopath
reposync -r base -p $BASE_REPO_DIR/centos/6/os/x86_64 --norepopath
reposync -r updates -p $BASE_REPO_DIR/centos/6/updates/x86_64 --norepopath
reposync -r extras -p $BASE_REPO_DIR/centos/6/extras/x86_64 --norepopath
reposync -r centosplus -p $BASE_REPO_DIR/centos/6/centosplus/x86_64 --norepopath
reposync -r contrib -p $BASE_REPO_DIR/centos/6/contrib/x86_64 --norepopath

createrepo --update $BASE_REPO_DIR/ambari/centos6/1.x/GA
createrepo --update $BASE_REPO_DIR/HDP-UTILS-1.1.0.15/repos/centos6
createrepo --update $BASE_REPO_DIR/HDP/centos6/1.x/GA/1.3.0.0
createrepo --update $BASE_REPO_DIR/ambari/centos6/1.x/updates/1.2.4.9
createrepo --update $BASE_REPO_DIR/pub/epel/6/x86_64
createrepo --update $BASE_REPO_DIR/centos/6/x86_64
createrepo --update $BASE_REPO_DIR/centos/6/updates/x86_64
createrepo --update $BASE_REPO_DIR/centos/6/extras/x86_64
createrepo --update $BASE_REPO_DIR/centos/6/centosplus/x86_64
createrepo --update $BASE_REPO_DIR/centos/6/contrib/x86_64

