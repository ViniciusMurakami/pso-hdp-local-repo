#!/bin/bash

# Using Ambari REST API, gather the cluster configuration information.

CLUSTER_URL=$1
USER="${2:-admin}"
PWD="${3:-admin}"
OUTPUT="${4:-cluster-cfg.txt}"

curl -
