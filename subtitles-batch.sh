#! /bin/bash

PATTERN="$1"

_usage() {
	echo "Usage: $(basename $0) <pattern>

e. g. $(basename $0) \"*.mkv\"
"
}

if [ -z "$PATTERN" ]; then
	_usage
	exit 1
fi

find . -iname "$PATTERN" -print0 | while read -d $'\0' FILE ; do
	FILE_NAME=${FILE%.*}
	mkvmerge -o "${FILE_NAME}_out.mp4" "${FILE}" --language "0:eng" "${FILE_NAME}.srt"
done
