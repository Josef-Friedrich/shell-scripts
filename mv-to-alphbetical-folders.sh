#! /bin/bash

_usage() {
	echo "Usage: $(basename "$0")

Options:
	-h, --help: Show this help message."
}

if [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
	_usage
	exit 0
fi

for ALPHABET in {a..z}; do

	LOWER="$ALPHABET"
	UPPER="$(echo $ALPHABET | tr '[:lower:]' '[:upper:]')"

	mkdir "$LOWER"
	mv "$LOWER"* "$LOWER"
	mv "$UPPER"* "$LOWER"
done
