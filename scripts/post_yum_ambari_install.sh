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

# Loop through the stacks and replace the hortonworks.com repo with your local repo location.
echo ""
echo "   Adjusting the $STACK_REPOS_TEMPLATE_DIR stacks to use your Local Repo."
echo "     Works currently with HDP 1.3.x"
echo ""
echo "  NOTE: sed errors expected...."
echo ""
for i in `ls $STACK_REPOS_TEMPLATE_DIR`; do
sed -i bak -e "s:<baseurl>http\://public-repo-1.hortonworks.com:<baseurl>http\://$1/repos:g" $STACK_REPOS_TEMPLATE_DIR/$i/repos/repoinfo.xml
done

echo ""
echo " Fetching the JDK for Ambari to distribute. "
echo ""
wget http://$1/repos/jdk/jdk-6u31-linux-x64.bin -O /var/lib/ambari-server/resources/jdk-6u31-linux-x64.bin

