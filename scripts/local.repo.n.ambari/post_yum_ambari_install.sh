#!/bin/bash

# THIS SCRIPT SHOULD BE RUN ON THE AMBARI SERVER
#
#  ---- AFTER the Ambari-Server has been installed (yum install ambari-server)
#  -----   AND BEFORE ambari-server start
#

# Copy over the repoinfo.xml to the stacks area of the newly
#   install ambari server

if [ $# -lt 1 ]; then
echo " Please specify the Local Repo's host FQDN

	$0 repo.mycompany.com
	
"
exit -1
fi

STACK_REPOS_TEMPLATE_DIR=/var/lib/ambari-server/resources/stacks/HDPLocal

# This repo template should already have been "adjusted" for use 
# by this cluster during the Local repo configuration.

wget http://$1/templates/ambari-server/resources/stacks/HDPLocal/1.3.0/repos/repoinfo.xml -O $STACK_REPOS_TEMPLATE_DIR/1.3.0/repos/repoinfo.xml

wget http://$1/repos/jdk/jdk-6u31-linux-x64.bin -O /var/lib/ambari-server/resources/jdk-6u31-linux-x64.bin

