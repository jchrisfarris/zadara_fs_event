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

# echo "Waiting for new files in ${watchdir}..."
# inotifywait ${watchdir} -m -q -e close_write --format %f . | while IFS= read -r file; do
#         # Do some work here using ${file} variable...  For example, to create
#         # a Redis key "newfile" with the contents being the filename:
#         #
#         # redis-cli -h 10.10.10.10 set newfile $(basename ${file})
#         #
#         # The "hostname" can be changed into an argument from the "Args"
#         # setting.  e.g. "redis_server=${2}", then "-h ${redis_server}"

#         # Output what inotify saw to the console log.  Log can be downloaded
#         # from the "Logs" tab for the running container.
#         echo "-------------------------------------------------------------"
#         echo "Saw new file ${file} in ${watchdir}"
# done