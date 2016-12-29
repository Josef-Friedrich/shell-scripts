#! /bin/bash

for ALPHABET in {a..z}; do

	LOWER="$ALPHABET"
	UPPER="$(echo $ALPHABET | tr '[:lower:]' '[:upper:]')"

	mkdir "$LOWER"
	mv "$LOWER"* "$LOWER"
	mv "$UPPER"* "$LOWER"
done
