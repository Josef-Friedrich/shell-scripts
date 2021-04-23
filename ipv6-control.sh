#! /bin/sh

INTERFACE=$(route | grep '^default' | grep -o '[^ ]*$')

_control() {
	sudo sh -c "echo $1 > /proc/sys/net/ipv6/conf/${INTERFACE}/disable_ipv6"
}

_usage() {
	echo "Usage: $(basename $0) disable|enable"
}


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
