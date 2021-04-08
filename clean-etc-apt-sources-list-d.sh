#! /bin/bash

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

_usage() {
	echo "Usage: $(basename "$0")

Clean up the folder /etc/apt/sources.list.d. Delete the backup
files like '*.save' oder '*.distUpgrade'. Remove all comments from
the configuration files. Then delete all empty files.


OPTIONS:
	-h, --help:       Show this message.
"
}

if [ "$1" = '-h' ] || [ "$1" = '--help' ] ; then
	_usage
	exit 0
fi


sudo rm -f /etc/apt/sources.list.d/*.distUpgrade

# https://stackoverflow.com/a/3350246
_clean() {
	echo "Remove comments and whitespaces in the file $1"
	sudo sed -i.bak 's/#.*$//' "$1"
	sudo sed -i.bak '/^$/d' "$1"
}

FILES=/etc/apt/sources.list.d/*.list
for FILE in $FILES; do
	_clean "$FILE"
done

sudo find /etc/apt/sources.list.d -size 0 -print -delete

sudo rm -f /etc/apt/sources.list.d/*.bak

sudo rm -f /etc/apt/sources.list.distUpgrade
sudo rm -f /etc/apt/sources.list.save
