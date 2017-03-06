#! /bin/sh

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

_usage() {
	echo "Usage: $(basename "$0") <svg-file>"
}

_icns() {
	inkscape \
		--export-png=icon.iconset/icon_"$2".png \
		--export-area=0:0:"$3":"$3" \
		"$1"
}

if [ -z "$1" ]; then
	_usage
	exit 1
fi

mkdir icon.iconset

_icns "$1" 16x16 12
_icns "$1" 16x16@2x 32
_icns "$1" 32x32 32
_icns "$1" 32x32@2x 64
_icns "$1" 128x128 128
_icns "$1" 128x128@2x 256
_icns "$1" 256x256 256
_icns "$1" 256x256@2x 512
_icns "$1" 512x512 512
_icns "$1" 512x512@2x 2015
