#! /bin/sh

# MIT License
#
# Copyright (c) 2018 Josef Friedrich <josef@friedrich.rocks>
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

NAME="nsupdate-wrapper.sh"
PROJECT_NAME="nsupdate-wrapper"
FIRST_RELEASE=2018-02-13
VERSION=1.0
PROJECT_PAGES="https://github.com/Josef-Friedrich/nsupdate-wrapper.sh"
SHORT_DESCRIPTION='Wrapper around nsupdate. Update your DNS server using nsupdate. Supports both ipv4 and ipv6.'
USAGE="$NAME v$VERSION

Usage: $NAME [-46dhklnrstvz]

$SHORT_DESCRIPTION

Options:
	-4, --ipv4-only
	  Update the ipv4 / A record only.
	-6, --ipv6-only
	  Update the ipv6 / AAAA record only.
	-d, --device
	  The interface (device to look for an IP address), e. g. “eth0”
	-h, --help
	  Show this help message.
	-k, --key-file
	  Path to private key.
	-l, --literal-key [hmac:]keyname:secret
	  Literal TSIG authentication key. keyname is the name of the
	  key, and secret is the base64 encoded shared secret. hmac is
	  the name of the key algorithm; valid choices are hmac-md5,
	  hmac-sha1, hmac-sha224, hmac-sha256, hmac-sha384, or
	  hmac-sha512. If hmac is not specified, the default is
	  hmac-md5. For example: hmac-sha256:example.com:n+WgaHX...0ni+HOQew8=
	-n, --nameserver
	  DNS server to send updates to, e. g. “ns.example.com”
	-r, --record
	  Record to update, e. g. “subdomain.example.com.”
	-s, --short-description
	  Show a short description / summary.
	-t, --ttl
	  Time to live for updated record; default 3600s., e. g. “300”
	-v, --version
	  Show the version number of this script.
	-z, --zone
	  Zone to update, e. g. “example.com.”
"

# See https://stackoverflow.com/a/28466267

# Exit codes
# Invalid option: 2
# Missing argument: 3
# No argument allowed: 4
_getopts() {
	while getopts ':46d:hk:l:n:r:st:vz:-:' OPT ; do
		case $OPT in
			4) OPT_IPV4=1 ;;
			6) OPT_IPV6=1 ;;
			d) OPT_DEVICE="$OPTARG" ;;
			h) echo "$USAGE" ; exit 0 ;;
			k) OPT_KEY_FILE="$OPTARG" ;;
			l) OPT_LITERAL_KEY="$OPTARG" ;;
			n) OPT_NAME_SERVER="$OPTARG" ;;
			r) OPT_RECORD="$OPTARG" ;;
			s) echo "$SHORT_DESCRIPTION" ; exit 0 ;;
			t) OPT_TTL="$OPTARG" ;;
			v) echo "$VERSION" ; exit 0 ;;
			z) OPT_ZONE="$OPTARG" ;;
			\?) echo "Invalid option “-$OPTARG”!" >&2 ; exit 2 ;;
			:) echo "Option “-$OPTARG” requires an argument!" >&2 ; exit 3 ;;

			-)
				LONG_OPTARG="${OPTARG#*=}"

				case $OPTARG in
					ipv4-only) OPT_IPV4=1 ;;
					ipv6-only) OPT_IPV6=1 ;;
					device=?*) OPT_DEVICE="$LONG_OPTARG" ;;
					help) echo "$USAGE" ; exit 0 ;;
					key-file=?*) OPT_KEY_FILE="$LONG_OPTARG" ;;
					literal-key=?*) OPT_LITERAL_KEY="$LONG_OPTARG" ;;
					name-server=?*) OPT_NAME_SERVER="$LONG_OPTARG" ;;
					record=?*) OPT_RECORD="$LONG_OPTARG" ;;
					short-description) echo "$SHORT_DESCRIPTION" ; exit 0 ;;
					ttl=?*) OPT_TTL="$LONG_OPTARG" ;;
					version) echo "$VERSION" ; exit 0 ;;
					zone=?*) OPT_ZONE="$LONG_OPTARG" ;;

					device*|key-file*|literal-key*|name-server*|record*|ttl*|zone*)
						echo "Option “--$OPTARG” requires an argument!" >&2
						exit 3
						;;

					ipv4-only*|ipv6-only*|help*|short-description*|version*)
						echo "No argument allowed for the option “--$OPTARG”!" >&2
						exit 4
						;;

					'') break ;; # "--" terminates argument processing
					*) echo "Invalid option “--$OPTARG”!" >&2 ; exit 2 ;;

				esac
				;;

		esac
	done
	GETOPTS_SHIFT=$((OPTIND - 1))
}

########################################################################

# _get_ipv4() {
# 	if [ -z "$OPT_DEVICE" ] ; then
# 		echo "No device given!" >&2
# 		exit 9
# 	fi
# 	ip -4 addr show dev $OPT_DEVICE | \
# 		grep inet | \
# 		sed -e 's/.*inet \([.0-9]*\).*/\1/'
# }

# https://github.com/phoemur/ipgetter/blob/master/ipgetter.py
_get_external_ipv4() {
	# http://myexternalip.com/raw
	$BINARY http://v4.ident.me
}

########################################################################

_get_ipv6() {
	if [ -z "$OPT_DEVICE" ] ; then
		echo "No device given!" >&2
		exit 9
	fi
	ip -6 addr list scope global $OPT_DEVICE | \
		grep -v " fd" | \
		sed -n 's/.*inet6 \([0-9a-f:]\+\).*/\1/p' | head -n 1
}

# _get_external_ipv6() {
# 	$BINARY http://v6.ident.me
# }

########################################################################

_get_nsupdate_commands() {
	if [ -n "$IPV6" ]; then
		RESOURCE_RECORD_TYPE='AAAA'
		IP="$IPV6"
	else
		RESOURCE_RECORD_TYPE='A'
		IP="$IPV4"
	fi
	echo "server $OPT_NAME_SERVER
zone $OPT_ZONE
update delete $OPT_RECORD $RESOURCE_RECORD_TYPE
update add $OPT_RECORD $OPT_TTL $RESOURCE_RECORD_TYPE $IP
show
send"
}

_get_binary() {
	if command -v curl > /dev/null 2>&1 ; then
		#-f, --fail -> exit code 22 on error
		#-s, --silent
		echo 'curl -fs'
	elif command -v wget > /dev/null 2>&1 ; then
		echo 'wget -q -O -'
	else
		echo "Neither “curl” nor “wget” found!"
		exit 1
	fi
}

## This SEPARATOR is required for test purposes. Please don’t remove! ##

if ! command -v nsupdate > /dev/null 2>&1 ; then
	echo 'Command “nsupdate” could not be found!'
	exit 1
fi

BINARY="$(_get_binary)"

_getopts $@

if [ -z "$OPT_NAME_SERVER" ] || [ -z "$OPT_ZONE" ] || [ -z "$OPT_RECORD" ]; then
	echo 'You have to specify this options: --name-server --zone --record' >&2
	exit 11
fi

if [ -z "$OPT_TTL" ]; then
	OPT_TTL=300
fi

if [ -z "$OPT_IPV4" ] && [ -z "$OPT_IPV6" ]; then
	OPT_IPV4=1
	OPT_IPV6=1
fi

if [ -n "$OPT_KEY_FILE" ] && [ -n "$OPT_LITERAL_KEY" ] ; then
	echo 'Select only one option. Both options are not allowed: “--key-file” or “--literal-key”' >&2
	exit 12
fi

if [ -n "$OPT_KEY_FILE" ]; then
	AUTH="-k $OPT_KEY_FILE"
elif [ -n "$OPT_LITERAL_KEY" ]; then
	AUTH="-y $OPT_LITERAL_KEY"
fi

########################################################################

if [ -n "$OPT_IPV4" ]; then
	IPV4="$(_get_external_ipv4)"
	if [ -n "$IPV4" ]; then
		_get_nsupdate_commands | nsupdate -D $AUTH
	fi
fi

IPV4=

########################################################################

if [ -n "$OPT_IPV6" ]; then
	IPV6="$(_get_ipv6)"
	if [ -n "$IPV6" ]; then
		_get_nsupdate_commands | nsupdate -D $AUTH
	fi
fi
