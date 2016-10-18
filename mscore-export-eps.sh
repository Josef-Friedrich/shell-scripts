#! /bin/sh

# MIT License
#
# Copyright (c) 2016 Josef Friedrich <josef@friedrich.rocks>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

_usage() {
	echo "Usage: $(basename $0) <musescore-file-without-extension>"
}

_mscore() {
	mscore --export-to $1.svg "$2"
}

_inkscape() {
	inkscape \
		--export-area-drawing \
		--without-gui \
		--export-eps="$1".eps "$1".svg
}

_clean() {
	rm -f "$1".svg
}

NAME="$1"

if [ -f "$NAME.mscx" ]; then
	FILE="$NAME.mscx"
elif [ -f "$FILE.mscz" ]; then
	FILE="$NAME.mscz"
fi

if [ -z "$FILE" ]; then
	_usage
	exit 1
fi

_mscore "$NAME" "$FILE"
_inkscape "$NAME"
_clean "$NAME"
