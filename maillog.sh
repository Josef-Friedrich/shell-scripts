#! /bin/sh
if [ -z "$MAILLOG_EMAIL" ]; then
	MAILLOG_EMAIL=logs@example.com
fi

# https://gist.github.com/Josef-Friedrich/a098e0f34169859d72f893b8c3fb6125

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
	echo "Usage: $(basename $0) [-b BODY ] <subject> <text-file-to-send>

Wrapper script to easily send log informations by email.

This script is designed to be used in Shell scripts. By design there is
no '-e' to specify an email address. The email address should be stored
in the 'rc' (run control) files of your shell (for more informations
read the next lines). The $(basename $0) script can be used in many
places of your scripts. Because the email address is only stored on
one place, the address can easily be changed and you not have to edit
all your scripts.

# Use cases

## Send a temporay and manually created log file:

	echo 'Some log messages' > /tmp/logs
	echo '... and more log message' >> /tmp/logs
	$(basename $0) 'Log subject' /tmp/logs

## Specify the body text by a command line option:

	$(basename $0) -b 'Some log messages' 'Log subject'

## Pipe to $(basename $0):

	echo 'Some log messages' | $(basename $0) 'Log subject'

# How to specify the email address?

1. Edit this script ($0) and
place your log email address on line 3

	MAILLOG_EMAIL=yourmail@example.com

or / and:

2. Add this line to your ~.bashrc, ~.bash_profile or ~.zshrc or
whatever your run control file of your shell is:

export MAILLOG_EMAIL=yourmail@example.com

Don't forget to execute your scripts in a login shell (e. g. bash -l)
in order to get the 'MAILLOG_EMAIL' variable.

Options:
	-b BODY:  Text for the body of the mail.
	-h:       Show this help text.
	-t:       Send a test mail (no further arguments needed).
"
	exit 0
}


while getopts ":b:ht" OPT; do
	case $OPT in
		b)
			BODY="$OPTARG"
			;;
		h)
			_usage
			;;
		t)
			SUBJECT="Test mail "
			BODY="Sent on $(date) to $MAILLOG_EMAIL."
			echo "Sending test mail to $MAILLOG_EMAIL."
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			;;
	esac
done

shift $((OPTIND-1))

if [ -z "$SUBJECT" ]; then
	SUBJECT="$1"
fi

FILE="$2"

if [ -z "$SUBJECT" ]; then
	_usage
fi

TMP_FILE=/tmp/maillog.sh_$(date +%s)
if [ ! -f "$FILE" ] && [ -n "$BODY" ]; then
	echo "$BODY" > $TMP_FILE
	FILE=$TMP_FILE
fi

if [ ! -f "$FILE" ]; then
	FILE=$TMP_FILE
	while read DATA; do
		echo "$DATA" >> "$FILE"
		echo "$DATA"
	done
fi

mail -s "$SUBJECT" $MAILLOG_EMAIL < "$FILE"
