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

_usage() {
	echo "Usage: $(basename "$0")

Options:
	-h, --help: Show this help message.
"
}

if [ "$1" = '-h' ] || [ "$1" = '--help' ] ; then
	_usage
	exit 0
fi

RSA="$HOME/.ssh/id_rsa.pub"
DSA="$HOME/.ssh/id_dsa.pub"

show_id_pub() {
	ID_PUB="$1"

	if [ -f "$ID_PUB" ]; then
		echo	"$ID_PUB:
"

ssh-keygen -E sha256 -lf "$ID_PUB"
ssh-keygen -E sha1 -lf "$ID_PUB"
ssh-keygen -E md5 -lf "$ID_PUB"

echo

		cat "$ID_PUB"
	else
		echo "
$ID_PUB not found.
"
	fi
}

show_id_pub "$RSA"
show_id_pub "$DSA"
