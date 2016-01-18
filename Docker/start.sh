#!/usr/bin/env bash

# Start SSH on container launch
service ssh start

# You can pass any number of command line arguments to this shell script using
# the "Args" feature when creating the ZCS container.  This demo only has one
# argument - the directory to watch for new files.
if [ $# -lt 2 ] ; then
  echo "Usage:"
  echo "  $0 <topic> <Watch Directories>"
  exit 1
fi

if [ -z "$AWS_REGION" ] || [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] ; then
  echo "Missing needed environmental variables. Aborting"
  exit 1
fi

export AWS_REGION
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY


topic=$1
shift
dirs=$@

/publish_fs_events.rb $topic $dirs | tee -a /event.log

