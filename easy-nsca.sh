#! /bin/bash

if [ -z "$NSCA_SERVER" ]; then
	NSCA_SERVER="123.123.123.123"
fi

if [ -z "$NSCA_CONFIG" ]; then
	NSCA_CONFIG="/etc/send_nsca.cfg"
fi

if [ -d "/usr/lib/nagios/plugins" ]; then
	NAGIOS_PLUGINS="/usr/lib/nagios/plugins"
fi

# https://gist.github.com/Josef-Friedrich/556be59f80d3bc1f49510695f67f8a64

#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
# Copyright (C) 2016 Josef Friedrich <josef@friedrich.rocks>
#
# Everyone is permitted to copy and distribute verbatim or modified
# copies of this license document, and changing it is allowed as long
# as the name is changed.
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.

_usage() {
	echo "Usage: $(basename $0) [<options>] <service> <check-command>

Environment variables: (to place in your *rc files of your shell)

	- NSCA_SERVER
	- NSCA_CONFIG
	- NAGIOS_PLUGINS

export NSCA_SERVER=\"123.123.123.123\"
export NSCA_CONFIG=\"/etc/send_nsca.cfg\"
export NAGIOS_PLUGINS=\"/usr/lib/nagios/plugins\"

Options:
	-c NSCA_CONFIG:    NSCA config file (default: /etc/send_nsca.cfg)
	-h:                Show this help.
	-H NSCA_SERVER:    IP address of the Nagios server.
	-p NAGIOS_PLUGINS: Folder containing the check commands.
	                   (default: /usr/lib/nagios/plugins)
	-o OUTPUT:         Output of the check commands.
	-r RETURN:         Plugin return codes: 0 Ok, 1 Warning,
	                   2 Critical, 3 Unkown.

Examples:

$(basename $0) \"APT\" \"check_apt -t 100\"
$(basename $0) \"Disk space\" \"check_disk -w 10% -c 5% /dev/sda1\"
"
}

_nsca() {
	if [ -f /usr/sbin/send_nsca ]; then
		/usr/sbin/send_nsca $@
	else
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

_send_nsca() {
	local SERVICE="$1"
	local CHECK_COMMAND="$2"

	if [ -z "$HOSTNAME" ]; then
		HOSTNAME=$(hostname)
	fi

	if [ -z "$CHECK_COMMAND" ] && [ -z "$OUTPUT" ]; then
		_send_nsca_raw "$HOSTNAME" "$SERVICE" 0 "$SERVICE"
		echo "$SERVICE"
	elif [ -n "$OUTPUT" ]; then
		_send_nsca_raw "$HOSTNAME" "$SERVICE" ${RETURN:-0} "$OUTPUT"
		echo $OUTPUT
	else
		if [ -d ${NAGIOS_PLUGINS} ]; then
			OUTPUT=$(eval "${NAGIOS_PLUGINS}/${CHECK_COMMAND}")
		else
			OUTPUT=$(eval "${CHECK_COMMAND}")
		fi
		_send_nsca_raw "$HOSTNAME" "$SERVICE" $? "$OUTPUT"
		echo $OUTPUT
	fi
}

while getopts ":c:hH:p:o:r:" OPT; do
	case $OPT in
		c)
			NSCA_CONFIG="$OPTARG"
			;;
		h)
			_usage
			;;
		H)
			NSCA_SERVER="$OPTARG"
			;;

		p)	NAGIOS_PLUGINS="$OPTARG"
			;;

		o)	OUTPUT="$OPTARG"
			;;

		r)
			RETURN="$RETURN"
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			;;
	esac
done

shift $((OPTIND-1))

SERVICE="$1"
CHECK_COMMAND="$2"

if [ -z "$SERVICE" ]; then
	_usage
	exit 1
fi

_send_nsca "$SERVICE" "$CHECK_COMMAND"
