#!/bin/bash

EVENTS="close_write,moved_to,create,moved_from,delete"
DIRS="/data/cut /data/raw"

TIMEFMT="%s"
FMT="%T:%w%f:%e"

sudo inotifywait -m -e $EVENTS --timefmt "$TIMEFMT" --format "$FMT" $DIRS
