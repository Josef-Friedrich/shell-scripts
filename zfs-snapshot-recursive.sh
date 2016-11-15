#! /bin/bash -l

# Usage: ./zfs-snapshot-recursive.sh <snapshot-name>
# Description: Create snapshots recursively for all datasets in all
# zpools.

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
	echo "Usage: $(basename "$0") <snapshot-name>

Create snapshots on all datasets of all zfs pools.

Options:
	-h, --help: Show this help message.
"
}

if [ "$1" = '-h' ] ||  [ "$1" == '--help' ] ; then
	_usage
	exit 0
fi

if [ -z "$1" ]; then
	NAME=$(date +%Y%m%dT%H%M%S)
else
	NAME="$1"
fi

command -v zpool > /dev/null 2>&1 || { echo >&2 "Command 'zpool' is not installed!"; exit 1; }
command -v zfs > /dev/null 2>&1 || { echo >&2 "Command 'zfs' is not installed!"; exit 1; }

LOG="/tmp/maillog_$(basename "$0")"
echo > "$LOG"
POOLS=$(zpool list -H | awk '{print $1}')

for POOL in ${POOLS}; do
	echo "Create snapshots named '$NAME' for all datasets in zpool '$POOL'." | tee -a "$LOG"
	zfs snapshot -r "${POOL}@${NAME}" 2>&1 | tee -a "$LOG"
done

maillog.sh "ZFS snapshots" "$LOG"
easy-nsca.sh "ZFS snapshots"
