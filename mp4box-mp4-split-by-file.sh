#! /bin/bash

# MIT License
#
# Copyright (c) 2023 Josef Friedrich <josef@friedrich.rocks>
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
      $(basename $0)
         Split mp4 files without re-encoding using a
         text file for the clips specification.
         MP4Box (gpac)

    <clips-txt>:

    100  130
    204  251
    390  410
    505  538

SYNOPSIS
       $(basename $0) <mp4-input-file> <clips-txt>


EXAMPLE
       $(basename $0) video.mp4 clips.txt
"

}

INPUT="$1"
CLIPS="$2"

if [ -z "$1" ] || [ -z "$2" ] ; then
	_usage
	exit 1
fi

_cut() {
	MP4Box -splitx $1:$2 "$INPUT"
}

cat $CLIPS | while read line
do
	_cut $line
done
