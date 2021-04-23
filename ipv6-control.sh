#! /bin/sh

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

INTERFACE=$(route | grep '^default' | grep -o '[^ ]*$')

_control() {
	sudo sh -c "echo $1 > /proc/sys/net/ipv6/conf/${INTERFACE}/disable_ipv6"
}

_usage() {
	echo "Usage: $(basename $0) disable|dis|enable|en

Enable the ipv6 support in the Linux kernel.

Options:
	-h, --help: Show this help message."
}

if [ "$1" = '-h' ] || [ "$1" = '--help' ] ; then
	_usage
	exit 0
fi

if [ -z "$1" ]; then
	_usage
	exit 1
fi

case "$1" in
	disable|dis|0)
		_control 1
		;;
	enable|en|1)
		_control 0
		;;
	*)
		_usage
		;;
esac
