#! /bin/bash

rm -f /etc/apt/sources.list.d/*.distUpgrade

# https://stackoverflow.com/a/3350246
_clean() {
	sed -i 's/#.*$//' -e '/^$/d' "$1"
}

FILES=/etc/apt/sources.list.d/*.list
for FILE in $FILES; do
  _clean "$FILE"
done
