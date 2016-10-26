#! /bin/sh

# https://gist.github.com/Josef-Friedrich/890be58425dd8f8c41a0de3b42f29fad

# Execute smartctl on all disks

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
	echo "Usage: $0 <options>

Use this options:
"
}

if [ "$@" != "" ]; then
	OPTIONS="$@"
else
	OPTIONS="-a"
fi

if [ "$OPTIONS" = "-h" ] || [ "$OPTIONS" = "--help" ]; then
	_usage
	smartctl -h
	exit 0
fi

for DISK in $(smartctl --scan | awk '{print $1}'); do
	echo "
########################################################################
# $DISK
########################################################################
"
	sudo smartctl $OPTIONS $DISK
done
