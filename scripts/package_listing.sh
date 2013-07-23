#!/bin/bash

# Get a listing of the package versions installed on the cluster.

OUTPUT="${2:-lib_listing.txt}"

if [ $# -gt 0 ]; then
echo "Gathering Installed Library information across the cluster"
pdsh -g $1 "yum list installed | grep -E 'ambari|hadoop|hbase|oozie|hive|pig|flume|sqoop|hcat'" | sort -k 1,2 > $OUTPUT
echo "Cluster libraries recorded in: $OUTPUT"
else

echo "Need to supply group name for pdsh"

fi

