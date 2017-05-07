#! /bin/bash

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

_get_snapshots() {
	if [ -n "$DIRECTORY" ]; then
		DIRECTORY=$(pwd)
	fi
	readarray -t SNAPSHOTS <<< "$(zfs list -t snapshot -o name -r -H "$DIRECTORY")"
}

_get_date() {
	zfs get -H -o value creation "$1"
}

_list_snapshots() {
	((COUNT=${#SNAPSHOTS[@]}, MAX=COUNT - 1))

	for ((i = 0; i <= MAX; i++)); do
		echo -e "$i:\t${SNAPSHOTS[i]}"
	done
}

_usage() {
echo "Usage: zfs-diff-walkthrough [-p] <nr> [<nr>]

Options:
  -d   Dataset or directory.
  -h   Show this help message.
  -p   Compare with previous snapshot instead of later snapshot."
}

while getopts ":d:hp" OPT; do
	case $OPT in

	d)
		DIRECTORY="$OPTARG"
		;;
	h)
		_usage
		exit 0
		;;

	p)
		DIFF_PREVIOUS=1
		;;

	\?)
		echo "Invalid option: -$OPTARG" >&2
		exit 1
		;;

	:)
		echo "Option -$OPTARG requires an argument." >&2
		exit 1
		;;

	esac
done

shift $((OPTIND-1))

command -v zfs > /dev/null 2>&1 || echo "Command 'zfs' is not installed!"; exit 1

FIRST=$1
SECOND=$2

_get_snapshots

if [ -z "$FIRST" ]; then
	_usage
	_list_snapshots
	exit 1
fi

if [ -z "$SECOND" ]; then
	if [ -n "$DIFF_PREVIOUS" ]; then
		SECOND=$FIRST
		FIRST=$((FIRST - 1))
	else
		SECOND=$((FIRST + 1))
	fi
fi

SNAP_FIRST="${SNAPSHOTS[$FIRST]}"
SNAP_SECOND="${SNAPSHOTS[$SECOND]}"

echo "Differences between:

  $SNAP_FIRST   [$(_get_date "$SNAP_FIRST")]

    <- and ->

  $SNAP_SECOND   [$(_get_date "$SNAP_SECOND")]

###########################################################
"

zfs diff "$SNAP_FIRST" "$SNAP_SECOND"
