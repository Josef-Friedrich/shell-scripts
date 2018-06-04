#! /bin/bash

if [ -z "$NSCA_SERVER" ]; then
	NSCA_SERVER="123.123.123.123"
fi

if [ -z "$NSCA_CONFIG" ]; then
	NSCA_CONFIG="/etc/send_nsca.cfg"
fi

if [ -z "$NSCA_CONFIG" ] && [ -d "/usr/lib/nagios/plugins" ]; then
	PATH_CHECK="/usr/lib/nagios/plugins"
fi

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

FIRST_RELEASE=2016-06-28
VERSION=1.0
PROJECT_PAGES="https://github.com/JosefFriedrich-shell/easy-nsca.sh"
SHORT_DESCRIPTION='A convenient script wrapper around send_nsca.'
USAGE="Usage: $(basename "$0") [<options>] <service> <check-command>

$SHORT_DESCRIPTION

Environment variables: (to place in your *rc files of your shell)

	- NSCA_SERVER
	- NSCA_CONFIG
	- PATH_CHECK

export NSCA_SERVER=\"123.123.123.123\"
export NSCA_CONFIG=\"/etc/send_nsca.cfg\"
export PATH_CHECK=\"/usr/lib/nagios/plugins\"

Options:
	-c NSCA_CONFIG:    NSCA config file (default: /etc/send_nsca.cfg)
	-h:                Show this help.
	-H NSCA_SERVER:    IP address of the Nagios server.
	-n HOST_SERVICE:   Host of the service.
	-p PATH_CHECK:     Folder containing the check commands.
	                   (default: /usr/lib/nagios/plugins)
	-o OUTPUT:         Output of the check commands.
	-r RETURN:         Plugin return codes: 0 Ok, 1 Warning,
	                   2 Critical, 3 Unkown.

Examples:

$(basename "$0") \"APT\" \"check_apt -t 100\"
$(basename "$0") \"Disk space\" \"check_disk -w 10% -c 5% /dev/sda1\""

_nsca() {
	if [ -f /usr/sbin/send_nsca ]; then
		# shellcheck disable=SC2068
		/usr/sbin/send_nsca $@
	else
		# shellcheck disable=SC2068
		/usr/local/sbin/send_nsca $@
	fi
}

_nsca_return() {
	local HOSTNAME="$1"
	local SVC_DESCRIPTION="$2"
	local RETURN="$3"
	local PLUGIN_OUTPUT="$4"
	echo -e "${HOSTNAME}\t${SVC_DESCRIPTION}\t${RETURN}\t${PLUGIN_OUTPUT}\n"
}

_send_nsca_raw() {
	_nsca_return "$1" "$2" "$3" "$4" | _nsca -H $NSCA_SERVER -c $NSCA_CONFIG
}

_status_color() {
	case "$1" in
		0)
			echo -e "\e[32mOK\e[0m"
			;;

		1)
			echo -e "\e[33mWARNING\e[0m"
			;;

		2)
			echo -e " \e[31mCRITICAL\e[0m"
			;;

		3)
			echo -e "\e[38;5;208mUNKOWN\e[0m"
			;;
	esac
}

_send_nsca() {
	local SERVICE="$1"
	local CHECK_COMMAND="$2"

	if [ -z "$HOSTNAME" ]; then
		HOSTNAME=$(hostname)
	fi

	if [ -z "$OVERRIDE_HOSTNAME" ]; then
		HOST_SERVICE="$HOSTNAME"
	else
		HOST_SERVICE="$OVERRIDE_HOSTNAME"
	fi

	if [ -z "$CHECK_COMMAND" ] && [ -z "$OUTPUT" ]; then
		_send_nsca_raw "$HOSTNAME" "$SERVICE" 0 "$SERVICE"
		echo "$SERVICE"
	elif [ -n "$OUTPUT" ]; then
		_send_nsca_raw "$HOSTNAME" "$SERVICE" "${RETURN:-0}" "$OUTPUT"
		echo "$OUTPUT"
	else
		if [ -d ${PATH_CHECK} ]; then
			OUTPUT=$(eval "${PATH_CHECK}/${CHECK_COMMAND}")
		else
			OUTPUT=$(eval "${CHECK_COMMAND}")
		fi
		local RETURN="$?"
		_send_nsca_raw "$HOST_SERVICE" "$SERVICE" "$RETURN" "$OUTPUT"
		_status_color "$RETURN"
		echo "$OUTPUT"
	fi
}

## This SEPARATOR is required for test purposes. Please don’t remove! ##

while getopts ":c:hH:n:p:o:r:" OPT; do
	case $OPT in
		c)
			NSCA_CONFIG="$OPTARG"
			;;

		h)
			echo "$USAGE"
			exit 0
			;;

		H)
			NSCA_SERVER="$OPTARG"
			;;

		n)
			OVERRIDE_HOSTNAME="$OPTARG"
			;;

		o)
			OUTPUT="$OPTARG"
			;;

		p)
			PATH_CHECK="$OPTARG"
			;;

		r)
			RETURN="$RETURN"
			;;

		\?)
			echo "Invalid option: -$OPTARG" >&2
			;;

	esac
done

shift $((OPTIND - 1))

SERVICE="$1"
CHECK_COMMAND="$2"

if [ -z "$SERVICE" ]; then
	echo "$USAGE"
	exit 1
fi

echo
echo "$SERVICE"
_send_nsca "$SERVICE" "$CHECK_COMMAND"
