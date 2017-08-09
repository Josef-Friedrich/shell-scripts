#! /bin/bash

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

_usage() {
	echo "$(basename "$0") [-hd] [ -H <height> ] <folder>

	-d: Dry run
	-h: Show this help message
	-H: Height of the min resolution (e. g. 720)
"

}

### This SEPARATOR is needed for the tests. Do not remove it! ##########

while getopts ":dhH:" OPT; do
	case $OPT in

		d)
			DRY=1
			;;

		h)
			_usage
			exit 1
			;;

		H)
			MIN_HEIGHT=$OPTARG
			exit 1
			;;

		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;

		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;

	esac
done

shift $((OPTIND-1))

command -v mediainfo > /dev/null 2>&1 || { echo >&2 "Please install 'mediainfo'!"; exit 1; }

FOLDER="$1"

if [ -z "$FOLDER" ]; then
	_usage
	exit 1
fi

if [ -z "$MIN_HEIGHT" ]; then
	MIN_HEIGHT=720
fi

find "$FOLDER" -iname "*" -type f -print0 | while read -r -d $'\0' FILE ; do

	HEIGHT=$(mediainfo --Inform="Video;%Height%" "$FILE")
	if [ "$?" -gt 0 ]; then
		echo "$FILE"
	fi

	if [ "$HEIGHT" -lt "$MIN_HEIGHT" ]; then
		MESSAGE="Delete $FILE (height: ${HEIGHT}px)"
		if [ -z "$DRY" ]; then
			echo "$MESSAGE"
			rm "$FILE"
		else
			echo "Dry run: $MESSAGE"
		fi
	fi
done
