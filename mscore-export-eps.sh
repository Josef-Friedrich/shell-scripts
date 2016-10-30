#! /bin/sh

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

INTER_FORMAT=pdf

_usage() {
	echo "Usage: $(basename $0) [-h] [<musescore-file>]

Convert MuseScore files to eps using Inkscape. If <musescore-file>
is omitted all MuseScore files in the current working directory are
converted.

OPTIONS
	-h, --help	Show this help message.
	-n, --no-clean 	Do not remove / clean intermediate
	                *.$INTER_FORMAT files
"
}

_mscore() {
	if [ "$(uname)" = "Darwin" ]; then
		/Applications/MuseScore\ 2.app/Contents/MacOS/mscore \
			--export-to "$1".$INTER_FORMAT "$2"
	else
		mscore --export-to "$1".$INTER_FORMAT "$2"
	fi
}

_inkscape() {
	local INKSCAPE
	if [ "$(uname)" = "Darwin" ]; then
		INKSCAPE=/Applications/Inkscape.app/Contents/Resources/bin/inkscape
	else
		INKSCAPE=inkscape
	fi
	$INKSCAPE \
		--export-area-drawing \
		--without-gui \
		--export-eps="$1".eps "$1".$INTER_FORMAT
}

_clean() {
	if [ ! "$NO_CLEAN" = "1" ]; then
		rm -f "$1".$INTER_FORMAT
	fi
}

_do_file() {
	local INPUT
	INPUT="$1"
	local SCORE
	SCORE="$(pwd)$1"
	SCORE=$(echo "$SCORE" | sed 's+\./+/+g')
	local BASENAME
	BASENAME=$(echo "$FILE" | sed 's/\.mscx//g' | sed 's/\.mscy//g')

	echo "Convert $INPUT"
	_mscore "$BASENAME" "$SCORE" > /dev/null 2>&1
	_inkscape "$BASENAME" > /dev/null 2>&1
	_clean "$BASENAME"
}

if [ "$1" = '-n' ] || [ "$1" = '--no-clean' ]; then
	NO_CLEAN="1"
	shift
fi

if [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
	_usage
	exit 1
fi

FILE="$1"

if [ -z "$FILE" ]; then
	FILES=$(find . -iname '*.mscz' -or -iname '*.mscx')
	for FILE in $FILES; do
		_do_file "$FILE"
	done
elif [ -f "$FILE" ]; then
	_do_file "$FILE"
else
	_usage
	exit 1
fi
