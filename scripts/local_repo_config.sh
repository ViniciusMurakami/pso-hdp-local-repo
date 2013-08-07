#!/bin/bash

# Establish a Local Repository with the appropriate mirrors and templates
#  that can be used by the cluster.  This script will use `hostname` to replace
#  all references in templates to the server this script is being run on. make
#  sure the hostname is correct and resolvable from ALL cluster hosts that will
#  need this repository.

# Ensure script being run as root.
if [ `whoami` != "root" ]; then
echo "Must be root to run this script."
exit -1
fi

HOSTNAME=${1:-`hostname`}

echo "Using $HOSTNAME as the hostname for the repo server."

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
if [ ! -d  $BASE_REPO_DIR/local.yum.repos.d ]; then
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

wget https://raw.github.com/dstreev/HWX-PS-Utils/hdp_1.3.0/templates/ambari.repo -O $BASE_REPO_DIR/local.yum.repos.d/ambari.repo

wget https://raw.github.com/dstreev/HWX-PS-Utils/hdp_1.3.0/templates/CentOS-Base.repo -O $BASE_REPO_DIR/local.yum.repos.d/CentOS-Base.repo

sed -i bak -e "s:!local.repo.host!:$HOSTNAME:g" $BASE_REPO_DIR/local.yum.repos.d/ambari.repo
sed -i bak -e "s:!local.repo.host!:$HOSTNAME:g" $BASE_REPO_DIR/local.yum.repos.d/CentOS-Base.repo

# ambari-1.x
# baseurl=http://public-repo-1.hortonworks.com/ambari/centos6/1.x/GA
if [ ! -d  $BASE_REPO_DIR/ambari/centos6/1.x/GA ]; then
mkdir -p $BASE_REPO_DIR/ambari/centos6/1.x/GA
fi

# HDP-UTILS-1.1.0.15
# http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.15/repos/centos6
if [ ! -d  $BASE_REPO_DIR/HDP-UTILS-1.1.0.15/repos/centos6 ]; then
mkdir -p $BASE_REPO_DIR/HDP-UTILS-1.1.0.15/repos/centos6
fi

# Updates-ambari-1.2.4.9
# baseurl=http://public-repo-1.hortonworks.com/ambari/centos6/1.x/updates/1.2.4.9
if [ ! -d  $BASE_REPO_DIR/ambari/centos6/1.x/updates/1.2.4.9 ]; then
mkdir -p $BASE_REPO_DIR/ambari/centos6/1.x/updates/1.2.4.9
fi

# epel
# baseurl=http://download.fedoraproject.org/pub/epel/6/$basearch (x86_64)
if [ ! -d  $BASE_REPO_DIR/pub/epel/6/x86_64 ]; then
mkdir -p $BASE_REPO_DIR/pub/epel/6/x86_64
fi

# HDP-1.3.0.0
# http://public-repo-1.hortonworks.com/HDP/centos6/1.x/GA/1.3.0.0
if [ ! -d  $BASE_REPO_DIR/HDP/centos6/1.x/GA/1.3.0.0 ]; then
mkdir -p $BASE_REPO_DIR/HDP/centos6/1.x/GA/1.3.0.0
fi

# Need to get the Ambari templates
if [ -d $BASE_REPO_DIR/../templates/ambari-server/resources/stacks/HDPLocal/1.3.0/repos ]; then
rm -rf $BASE_REPO_DIR/../templates/ambari-server/resources/stacks/HDPLocal/1.3.0/repos
fi

# Get fresh copies
mkdir -p $BASE_REPO_DIR/../templates/ambari-server/resources/stacks/HDPLocal/1.3.0/repos
if [ -f $BASE_REPO_DIR/../templates/ambari-server/resources/stacks/HDPLocal/1.3.0/repos/repoinfo.xml ];
then
# Cleanup old copy.
rm $BASE_REPO_DIR/../templates/ambari-server/resources/stacks/HDPLocal/1.3.0/repos/repoinfo.xml
fi

wget https://raw.github.com/dstreev/HWX-PS-Utils/hdp_1.3.0/templates/ambari-server/resources/stacks/HDPLocal/1.3.0/repos/repoinfo.xml -O $BASE_REPO_DIR/../templates/ambari-server/resources/stacks/HDPLocal/1.3.0/repos/repoinfo.xml
sed -i bak -e "s:!local.repo.host!:$HOSTNAME:g" $BASE_REPO_DIR/../templates/ambari-server/resources/stacks/HDPLocal/1.3.0/repos/repoinfo.xml



# Install the repo for Ambari and HDP
echo ""
echo "================================="
echo "Syncing ambari-1.x repo..."
echo "---------------------------------"
reposync -r ambari-1.x -p $BASE_REPO_DIR/ambari/centos6/1.x/GA --norepopath
echo ""
echo "================================="
echo "Syncing HDP-UTILS-1.1.0.15 repo..."
echo "---------------------------------"
reposync -r HDP-UTILS-1.1.0.15 -p $BASE_REPO_DIR/HDP-UTILS-1.1.0.15/repos/centos6 --norepopath
echo ""
echo "================================="
echo "Syncing HDP-1.3.0.0 repo..."
echo "---------------------------------"
reposync -r HDP-1.3.0.0 -p $BASE_REPO_DIR/HDP/centos6/1.x/GA/1.3.0.0 --norepopath
echo ""
echo "================================="
echo "Syncing Updates-ambari-1.2.4.9 repo..."
echo "---------------------------------"
reposync -r Updates-ambari-1.2.4.9 -p $BASE_REPO_DIR/ambari/centos6/1.x/updates/1.2.4.9
echo ""
echo "================================="
echo "Syncing epel repo..."
echo "---------------------------------"
reposync -r epel -p $BASE_REPO_DIR/pub/epel/6/x86_64 --norepopath
echo ""
echo "================================="
echo "Syncing base repo..."
echo "---------------------------------"
reposync -r base -p $BASE_REPO_DIR/centos/6/os/x86_64 --norepopath
echo ""
echo "================================="
echo "Syncing updates repo..."
echo "---------------------------------"
reposync -r updates -p $BASE_REPO_DIR/centos/6/updates/x86_64 --norepopath
echo ""
echo "================================="
echo "Syncing extras repo..."
echo "---------------------------------"
reposync -r extras -p $BASE_REPO_DIR/centos/6/extras/x86_64 --norepopath
echo ""
echo "================================="
echo "Syncing centosplus repo..."
echo "---------------------------------"
reposync -r centosplus -p $BASE_REPO_DIR/centos/6/centosplus/x86_64 --norepopath
echo ""
echo "================================="
echo "Syncing contrib repo..."
echo "---------------------------------"
reposync -r contrib -p $BASE_REPO_DIR/centos/6/contrib/x86_64 --norepopath

if [ ! -d $BASE_REPO_DIR/ambari/centos6/RPM-GPG-KEY ]; then
mkdir -p $BASE_REPO_DIR/ambari/centos6/RPM-GPG-KEY
fi

wget http://public-repo-1.hortonworks.com/ambari/centos6/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins -O $BASE_REPO_DIR/ambari/centos6/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins

echo ""
echo "================================="
echo "Updating Local Repo DB for ambari..."
echo "---------------------------------"
createrepo --update $BASE_REPO_DIR/ambari/centos6/1.x/GA
echo ""
echo "================================="
echo "Updating Local Repo DB for HDP-UTILS-1.1.0.15..."
echo "---------------------------------"
createrepo --update $BASE_REPO_DIR/HDP-UTILS-1.1.0.15/repos/centos6
echo ""
echo "================================="
echo "Updating Local Repo DB for HDP-1.3.0.0..."
echo "---------------------------------"
createrepo --update $BASE_REPO_DIR/HDP/centos6/1.x/GA/1.3.0.0
echo ""
echo "================================="
echo "Updating Local Repo DB for ambari-1.2.4.9..."
echo "---------------------------------"
createrepo --update $BASE_REPO_DIR/ambari/centos6/1.x/updates/1.2.4.9
echo ""
echo "================================="
echo "Updating Local Repo DB for epel..."
echo "---------------------------------"
createrepo --update $BASE_REPO_DIR/pub/epel/6/x86_64
echo ""
echo "================================="
echo "Updating Local Repo DB for base..."
echo "---------------------------------"
createrepo --update $BASE_REPO_DIR/centos/6/os/x86_64
echo ""
echo "================================="
echo "Updating Local Repo DB for updates..."
echo "---------------------------------"
createrepo --update $BASE_REPO_DIR/centos/6/updates/x86_64
echo ""
echo "================================="
echo "Updating Local Repo DB for extras..."
echo "---------------------------------"
createrepo --update $BASE_REPO_DIR/centos/6/extras/x86_64
echo ""
echo "================================="
echo "Updating Local Repo DB for centosplus..."
echo "---------------------------------"
createrepo --update $BASE_REPO_DIR/centos/6/centosplus/x86_64
echo ""
echo "================================="
echo "Updating Local Repo DB for contrib..."
echo "---------------------------------"
createrepo --update $BASE_REPO_DIR/centos/6/contrib/x86_64
echo ""
echo ""
echo "******* Local repo configured..."