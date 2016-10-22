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

# http://lartc.org/howto/lartc.ratelimit.single.html

_usage() {
	echo "Usage: $(basename $0) <dest> <bandwidth>

	<dest>: Destination ip address or url
	<bandwith>: Bandwith rates like '1000kbps'. See tc documentation.


OPTIONS:
	-d <dev>: Network interface, e. g.: eth1, eno1

or

$(basename $0) [-d <network-interface> ] clear
"
}

while getopts ":d:" OPT; do
	case $OPT in
		-d)
			DEV=$OPTARG
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			;;
	esac
done

shift $((OPTIND-1))


if [ -z "$1" ]; then
	_usage
	exit 1
fi

IP=$1
IP=$(dig +short $IP)
BANDWIDTH=$2

if [ -z "$DEV" ]; then
	DEV=$(ip route show | grep default | awk '{print $5}')
fi

if [ "$1" = clear ]; then
	sudo tc qdisc del dev $DEV root
	exit
fi

sudo tc qdisc add dev $DEV root handle 1: cbq avpkt 1000 bandwidth 10mbit

sudo tc class add dev $DEV parent 1: classid 1:1 cbq rate $BANDWIDTH \
	allot 1500 prio 5 bounded isolated

sudo tc filter add dev $DEV parent 1: protocol ip prio 16 u32 \
	match ip dst $IP flowid 1:1

sudo tc qdisc add dev $DEV parent 1:1 sfq perturb 10
