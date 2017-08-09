#! /bin/sh

# MIT License
#
# Copyright (c) 2017 Josef Friedrich <josef@friedrich.rocks>
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

_usage() {
	echo "Usage: $(basename $0)

OPTIONS:
	-b: backup original images (add .bak to filename)
	-f: force
	-t: threshold, default 50%
	-h: Show this help message
"
}

# convert "$INPUT" \
# 	-border 100x100 -bordercolor "#FFFFFF" \
# 	-deskew 40% \
# 	-level 45,50% \
# 	-colors 2 \
# 	-fuzz 98% \
# 	-trim +repage \
# 	-compress Group4 -monochrome \
# 	output.pdf

_convert() {
	CHANNELS=$(identify "$1" | cut -d " " -f 7)
	NEW=$(echo $1 | sed 's/\.[[:alnum:]]*$//').png
	if [ "$CHANNELS" != 2c ] || [ "$FORCE" = 1 ]; then
		echo "Convert $1 to $NEW"
		if [ "$BACKUP" = 1 ]; then
			cp "$1" "$1.bak"
		fi
		convert "$1" \
			-resize 200% \
			-deskew 40% \
			-threshold "$THRESHOLD" \
			-trim +repage \
			"$NEW"
	else
		echo "The image has already 2 channels ($CHANNELS). Use -f option to force conversion."
	fi
}

while getopts ":bfht:" OPT; do
	case $OPT in
		b)
			BACKUP=1
			;;
		f)
			FORCE=1
			;;
		h)
			_usage
			;;
		t)
			THRESHOLD="$OPTARG"
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			;;
	esac
done

shift $((OPTIND-1))

if [ -z "$*" ]; then
	_usage
fi

if [ -z "$THRESHOLD" ]; then
	THRESHOLD='50%'
fi

for IMAGE in $*; do
	_convert "$IMAGE"
done
