#! /bin/sh

EXTENSION=$1

if [ -z "$EXTENSION" ]; then
	echo "Usage: $(basename $0) <extension>

e. g.: $(basename $0) mkv
"
	exit 1
fi

mkvmerge -o out.$EXTENSION *.$EXTENSION --language "0:eng" *.srt
