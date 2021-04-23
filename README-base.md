[![Build Status](https://travis-ci.org/Josef-Friedrich/shell-scripts.svg?branch=master)](https://travis-ci.org/Josef-Friedrich/shell-scripts)

# shell-scripts

A collection of hopefully useful shell scripts

## Coding style

* Use tabs for indentation
* Prefix functions with _
* Variable names are UPPERCASE

Example:

```sh
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
```

## Standard option `-h` or `--help`

```sh
_usage() {
	echo "Usage: $(basename "$0")

Options:
	-h, --help: Show this help message."
}
```

```sh
if [ "$1" = '-h' ] || [ "$1" = '--help' ] ; then
	_usage
	exit 0
fi
```

# Test

Run test with this command: `make test`

---

# Help messages of all scripts
