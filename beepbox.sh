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


HOUR=$(date +%k)

_usage() {
	echo "Usage: $(basename "$0") [error|success|sync-start|sync-end|warning]"
	exit "${1:-0}"
}

_beep() {
	if [ "$HOUR" -lt 7 ] || [ "$HOUR" -gt 19 ]; then
		echo "It's to late or to early to beep."
		exit 0
	fi
	command -v beep > /dev/null 2>&1 || { echo >&2 "Please install 'beep'!"; exit 1; }
	beep $@
}

_default() {
	_beep -f1234 -l10 -d20 -r20
}

_warning() {
	for i in {5000..4000..100}; do
		_beep -f $i -l 50
	done
}

_error() {
	# shellcheck disable=SC2034
	for n in 1 2 3 4 5 6 7 8 9 0; do
		for f in 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600; do
			_beep -f$f -l20
		done
	done
}

_success() {
	for i in {4000..5000..100}; do
		_beep -f $i -l 50
	done
}

_sync_start() {
	_beep -f1396.91 -l500 -D500 -n -f1864.66 -l1000
}

_sync_end() {
	_beep -f1864.66 -l500 -D500 -n -f1396.91 -l500 -D500 -r3 -n -f1396.91 -l1000
}

OPTION="$1"

case "$OPTION" in
	-h|--help) _usage ;;
	error) _error ;;
	success) _success ;;
	sync-start) _sync_start ;;
	sync-end) _sync_end ;;
	warning) _warning ;;
	*) _default ;;
esac
