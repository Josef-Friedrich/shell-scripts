#! /bin/bash

# MIT License
#
# Copyright (c) 2017 Josef Friedrich <josef@friedrich.rocks>
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

# Based on:

# https://gist.github.com/jvhaarst/2343281

# Reads EXIF creation date from image files in the
# current directory and moves them carefully under
#
#   $BASEDIR/YYYY-MM-DD/
#
# ...where 'carefully' means that it does not overwrite
# differing files if they already exist and will not delete
# the original file if copying fails for some reason.
#
# It DOES overwrite identical files in the destination directory
# with the ones in current, however.
#
# This script was originally written and put into
# Public Domain by Jarno Elonen <elonen@iki.fi> in June 2003.
# Feel free to do whatever you like with it.

_usage() {
	echo "Usage: $(basename "$0")

Options:
	-h, --help: Show this help message."
}

if [ "$1" = '-h' ] || [ "$1" = '--help' ] ; then
	_usage
	exit 0
fi

_mv_image() {
	INPUT="$1"
	DATE=$(exiftool -quiet -tab -dateformat "%Y:%m:%d" -json -DateTimeOriginal "${INPUT}" | jq --raw-output '.[].DateTimeOriginal')
	# If exif extraction with DateTimeOriginal failed
	if [ "$DATE" == "null" ]; then
		DATE=$(exiftool -quiet -tab -dateformat "%Y:%m:%d" -json -MediaCreateDate "${INPUT}" | jq --raw-output '.[].MediaCreateDate')
	fi
	# If exif extraction failed
	if [ -z "$DATE" ] || [ "$DATE" == "null" ]; then
		DATE=$(stat -f "%Sm" -t %F "${INPUT}" | awk '{print $1}'| sed 's/-/:/g')
	fi
	# Doublecheck
	if [ ! -z "$DATE" ]; then
		YEAR=$(echo $DATE | sed -E "s/([0-9]*):([0-9]*):([0-9]*)/\\1/")
		MONTH=$(echo $DATE | sed -E "s/([0-9]*):([0-9]*):([0-9]*)/\\2/")
		DAY=$(echo $DATE | sed -E "s/([0-9]*):([0-9]*):([0-9]*)/\\3/")
		if [ "$YEAR" -gt 0 ] & [ "$MONTH" -gt 0 ] & [ "$DAY" -gt 0 ]; then
			OUTPUT_DIRECTORY=${BASEDIR}/${YEAR}-${MONTH}-${DAY}
			mkdir -pv ${OUTPUT_DIRECTORY}
			OUTPUT=${OUTPUT_DIRECTORY}/$(basename ${INPUT})
			if [ -e "$OUTPUT" ] && ! cmp -s "$INPUT" "$OUTPUT"; then
				echo "WARNING: '$OUTPUT' exists already and is different from '$INPUT'."
			else
				echo "Moving '$INPUT' to $OUTPUT"
				rsync -ah --progress "$INPUT"  "$OUTPUT"
				if ! cmp -s "$INPUT" "$OUTPUT"; then
					echo "WARNING: copying failed somehow?"
				fi
			fi
		else
			echo "WARNING: '$INPUT' doesn't contain date."
		fi
	else
		echo "WARNING: '$INPUT' doesn't contain date."
	fi
}

### This SEPARATOR is needed for the tests. Do not remove it! ##########

# Defaults
TOOLS=(exiftool jq) # Also change settings below if changing this, the output should be in the format YYYY:MM:DD
DEFAULTDIR='/home/jf/Bilder'

# activate debugging from here
#set -o xtrace
#set -o verbose

# Improve error handling
set -o errexit
set -o pipefail

# Check whether needed programs are installed
for TOOL in ${TOOLS[*]}; do
	hash $TOOL 2>/dev/null || { echo >&2 "I require $TOOL but it's not installed. Aborting."; exit 1; }
done

# Enable handling of filenames with spaces:
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# Use BASEDIR from commandline, or default if none given
BASEDIR=${1:-$DEFAULTDIR}

for FILE in $(find $(pwd -P) -not -wholename "*._*" -iname "*.jpg" -or -iname "*.jpeg"  -or -iname "*.mov" -or -iname "*.nef" ); do
	_mv_image "$FILE"
done

# restore $IFS
IFS=$SAVEIFS
