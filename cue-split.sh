#! /bin/sh

# https://bbs.archlinux.org/viewtopic.php?id=75774

# MIT License
#
# Copyright (c) 2016 Josef Friedrich <josef@friedrich.rocks>
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

CUETAG=cuetag
FLAC='flac flac -V --best -o %f -'
FORMAT='%n %p - %t'
SDIR=`pwd`

_usage() {
	echo "Usage: $(basename "$0") [Path]

frontend for:	cuetools, shntool, mp3splt
optional dependencies:	flac, mac, wavpack, ttaenc

The default path is the current directory.

The folder must contain only one *.cue file and one audio file.
"
}

if [ "$1" = "" ]
	then
		DIR=$SDIR
else
		case $1 in
				-h | --help )
						_usage
						exit
						;;
				* )
				DIR=$1
		esac
fi

echo "Directory: $DIR
"

cd "$DIR"
TYPE=`ls -t1`

case $TYPE in
	*.ape*)
		mkdir split
		shnsplit -d split -f *.cue -o "$FLAC" *.ape -t "$FORMAT"
		rm -f split/00*pregap*
		"$CUETAG" *.cue split/*.flac
		exit
		;;

	*.flac*)
		mkdir split
		shnsplit -d split -f *.cue -o "$FLAC" *.flac -t "$FORMAT"
		rm -f split/00*pregap*
		"$CUETAG" *.cue split/*.flac
		exit
		;;

	*.mp3*)
		mp3splt -no "@n @p - @t (split)" -c *.cue *.mp3
		"$CUETAG" *.cue *split\).mp3
		exit
		;;

	*.ogg*)
		mp3splt -no "@n @p - @t (split)" -c *.cue *.ogg
		"$CUETAG" *.cue *split\).ogg
		exit
		;;

	*.tta*)
		mkdir split
		shnsplit -d split -f *.cue -o "$FLAC" *.tta -t "$FORMAT"
		rm -f split/00*pregap*
		"$CUETAG" *.cue split/*.flac
		exit
		;;

	*.wv*)
		mkdir split
		shnsplit -d split -f *.cue -o "$FLAC" *.wv -t "$FORMAT"
		rm -f split/00*pregap*
		"$CUETAG" *.cue split/*.flac
		exit
		;;

	*.wav*)
		mkdir split
		shnsplit -d split -f *.cue -o "$FLAC" *.wav -t "$FORMAT"
		rm -f split/00*pregap*
		"$CUETAG" *.cue split/*.flac
		exit
		;;

	* )
		echo "Error: Found no files to split!"
		echo "			 --> APE, FLAC, MP3, OGG, TTA, WV, WAV"

esac
