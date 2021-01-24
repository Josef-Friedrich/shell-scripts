#! /bin/bash

# MIT License
#
# Copyright (c) 2021 Josef Friedrich <josef@friedrich.rocks>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
