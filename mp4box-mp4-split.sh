#! /bin/bash

_usage() {
  echo "NAME
      $(basename $0) - Split mp4 files without re-encoding.

SYNOPSIS
       $(basename $0) mp4-file start-time end-time

DESCRIPTION
       The  mp4-split-command  split  mp4  files  without  re-encoding.  It  uses  the mp4box-command of the GPAC framework. Both start and end time must be specified in this format:
       hh-mm-ss, e. g. 01-34-23.

EXAMPLES
       $(basename $0) video.mp4 00-23-43 01-01-32
"

}

time_convert() {
  local TIME SECONDS
  IFS="-"
  TIME=($1)
  SECONDS=$((${TIME[0]}*3600 + ${TIME[1]}*60 + ${TIME[2]}))
  echo $SECONDS
}

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$2" ] ; then
	_usage
	exit 1
fi

MP4Box -splitx $(time_convert $2):$(time_convert $3) "$1"
