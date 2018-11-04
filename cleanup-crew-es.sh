#!/usr/bin/env bash

# Clean up script for old elasticsearch snapshots.
#
# You need the jq binary:
# - yum install jq
# - apt-get install jq
# - or download from http://stedolan.github.io/jq/

set -eou pipefail

# The amount of snapshots we want to keep.
LIMIT=15

# Name of our snapshot repository
REPO="repo-name"

# Grab cluster tag using user-data
CLUSTER=$(curl -s http://169.254.169.254/latest/user-data | grep "cluster\": " | awk '{print $2}' | tr -d '",' )

# Get a list of snapshots that we want to delete
if [[ ${CLUSTER} =~ "prod" ]];  then
    LIMIT=61
fi

SNAPSHOTS=$(curl -s -XGET "localhost:9200/_snapshot/${REPO}/_all" | jq -r ".snapshots[:-${LIMIT}][].snapshot")

# Loop over the results and delete each snapshot
for SNAPSHOT in $(echo "${SNAPSHOTS}"); do
 echo "Deleting snapshot: ${SNAPSHOT}"
 curl -s -XDELETE "localhost:9200/_snapshot/${REPO}/${SNAPSHOT}?pretty"
done

echo "Done!"
