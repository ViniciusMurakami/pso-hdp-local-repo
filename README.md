# Local Repository Configuration

[License](./LICENSE)

NOTE: To support future version of HDP, this repo has branches for the different hdp distributions.  Make sure you are using the desired branch.

Configuring a local repository is necessary when the cluster doesn't have access to the internet OR the shear volume of cluster hosts would put a load on the internet connection that isn't desirable.  To begin this process, you need to establish a separate RHEL/CentOS server that "does" have access to the internet, at least temporarily, to sync with the remote repositories that we'll need to install the cluster.

This "local" repository server must be accessible to the servers in the cluster.

## Installation Steps - NOTE: You DO NOT need everything in this project, only the 3 scripts listed below.

1. Retrieve these 3 scripts:
	1. [local_repo_config.sh](scripts/local_repo_config.sh) - Copy to your local repository server.
	2. [install_local_repos.sh](scripts/install_local_repos.sh) - Copy to your target Ambari server.
	3. [post_yum_ambari_install.sh](scripts/post_yum_ambari_install.sh) - Copy to your target Ambari server.
2. Configure the local repository. (local_repo_config.sh)
3. Install \*.repo files on Ambari Server (pre ambari-server installation). (install_local_repos.sh)
4. Install Ambari-Server (yum install ambari-server). DON'T start it yet.
5. Replace the Ambari Templates with a template that will point to your local repo. (post-yum-ambari-install.sh)
6. Start Ambari and proceed with provisioning cluster.  *Make sure you provision with the HDPLocal and for stack 1.3.0.* With the above steps completed, Ambari will use and publish *.repos to the cluster hosts that will use the configured local repo.

## NOTE: This currently only pulls and configures for RHEL/CentOS 6 !!!

[Script - Local Repo Config](scripts/local_repo_config.sh)

Run this on a RHEL/CentOS server that will be the local repository.  The script will check/install httpd, install the needed repo's in /etc/yum.repos.d and then create local sync'd copies that can be referenced for the local installation. This script needs to run as root (or sudo).

[Script - Install Local Repos](scripts/install_local_repos.sh)

This script will fetch repos location files from the 'local_repo_config.sh' server created earlier and copy them to the hosts /etc/yum.repos.d directory.  All other repos in the /etc/yum.repos.d directory will be moved so no conflicts will occur.  This script needs to run as root (or sudo).

[Script - Ambari Templates for Local Repo](scripts/post-yum-ambari-install.sh)

## FAQs:

Q: What is local repository server?

Ans: Hadoop cluster setup requires installation and configuration of binaries from various projects. Before setting up the Hadoop cluster it is a good practice to download all the binaries from multiple sources in to a local machine and create a local repository. This local machine having local code repository is called local repository server. This local repository server is very useful if the hadoop cluster is behind a firewall and cannot access internet during installation process. Using a local repository will allow the installation process to look for the binaries in the local machine instead of try to download them from internet repositories.

If you are trying to set up a test virtual machine based cluster on one mac/pc, one of the virtual machines can be used as a local repository. 


Q: What is target Ambari server?

And: Target Ambari server is the server which is used as the central server to install and configure hadoop cluster environment. Ambari has user interface that allows installation and set up of hadoop cluster. During the installation process, binaries will be pulled from local repository server instead of going to internet when you use the scripts in this git.
