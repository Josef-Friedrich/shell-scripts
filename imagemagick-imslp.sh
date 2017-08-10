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

OUT_EXT=png
OPT_THRESHOLD=50%
OPT_COMPRESSION=
OPT_RESIZE=

_usage() {
	echo "Usage: $(basename "$0") [-bcfhrt] <filename-or-glob-pattern>

This is a wrapper script around imagemagick to process image files
suitable for imslp.org (International Music Score Library Project)

http://imslp.org/wiki/IMSLP:Musiknoten_beisteuern

OPTIONS:
	-c: Use CCITT Group 4 compress. This options generates a PDF file
	-b: backup original images (add .bak to filename)
	-f: force
	-h: Show this help message
	-r: Resize 200%
	-t: threshold, default 50%
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

_remove_extension() {
	echo "$1" | sed 's/\.[[:alnum:]]*$//'
}

_get_channels() {
	identify "$1" | cut -d " " -f 7
}

_options() {
	echo "$OPT_RESIZE\
-deskew 40% \
-threshold $OPT_THRESHOLD \
-trim +repage$OPT_COMPRESSION"
}

_convert() {
	if [ -n "$OPT_COMPRESSION" ]; then
		OUT_EXT=pdf
	fi
	CHANNELS=$(_get_channels "$1")
	NEW=$(_remove_extension "$1").$OUT_EXT
	if [ "$CHANNELS" != 2c ] || [ "$FORCE" = 1 ]; then
		echo "Convert $1 to $NEW"
		if [ "$BACKUP" = 1 ]; then
			cp "$1" "$1.bak"
		fi
		convert "$1" $(_options) "$NEW"
	else
		echo "The image has already 2 channels ($CHANNELS). Use -f option to force conversion."
	fi
}

_arguments() {
	OPT_BACKUP=
	OPT_COMPRESSION=
	OPT_FORCE=
	OPT_RESIZE=
	OPT_THRESHOLD=

	while getopts :cbfhrt:-: arg; do
		case $arg in
			b) OPT_BACKUP=1 ;;
			c) OPT_COMPRESSION=1 ;;
			f) OPT_FORCE=1 ;;
			h) _usage ; exit 0 ;;
			r) OPT_RESIZE=1 ;;
			t) OPT_THRESHOLD="$OPTARG" ;;
			-)
			  LONG_OPTARG="${OPTARG#*=}"
				case $OPTARG in
					backup) OPT_BACKUP=1 ;;
					compression) OPT_COMPRESSION=1 ;;
					force) OPT_FORCE=1 ;;
					help) _usage ; exit 0 ;;
					resize) OPT_RESIZE=1 ;;
					threshold=?*) OPT_THRESHOLD="$LONG_OPTARG" ;;
					threshold*) echo "No arg for --$OPTARG option" >&2; exit 2 ;;
					'')
						break ;;
					*)
						echo "Illegal option --$OPTARG" >&2; exit 2 ;;
					esac ;;
			\?)
				exit 2
				;;
		esac
	done
	shift $((OPTIND - 1))
	IMAGES=$@
}

### This SEPARATOR is needed for the tests. Do not remove it! ##########

while getopts ":cbfhrt:" OPT; do
	case $OPT in
		b)
			BACKUP=1
			;;
		c) OPT_COMPRESSION=1 ;;
		f)
			FORCE=1
			;;
		h)
			_usage
			exit 0
			;;
		r)
			OPT_RESIZE=1 ;;
		t)
			OPT_THRESHOLD="$OPTARG"
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			;;
	esac
done

[ "$OPT_COMPRESSION" ] && OPT_COMPRESSION=' -compress Group4 -monochrome'
[ "$OPT_RESIZE" ] && OPT_RESIZE='-resize 200% '

shift $((OPTIND-1))

if [ -z "$*" ]; then
	_usage
	exit 1
fi

for IMAGE in $*; do
	_convert "$IMAGE"
done
