#! /bin/sh

# MIT License
#
# Copyright (c) 2019 Josef Friedrich <josef@friedrich.rocks>
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

_reopen() {
	local SCORE
	SCORE="$1"
	mscore3 -o "$1" "$1"
}

FILE="$1"

if [ -f "$FILE" ]; then
	_reopen "$FILE"
	exit 0
fi

if [ -d "$FILE" ]; then
	FILES=$(find "$FILE" -iname '*.mscz' -or -iname '*.mscx')
elif [ -z "$FILE" ]; then
	FILES=$(find . -iname '*.mscz' -or -iname '*.mscx')
fi

if [ "$FILES" = '' ]; then
	echo 'No files to convert found!'
	exit 1
fi

for FILE in $FILES; do
	_reopen "$FILE"
done
