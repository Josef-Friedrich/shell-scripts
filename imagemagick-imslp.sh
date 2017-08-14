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

_usage() {
	echo "Usage: imagemagick-imslp.sh [-bcfhjrt] <filename-or-glob-pattern>

`imagemagick-imslp.sh` a wrapper script around imagemagick to process image files
suitable for imslp.org (International Music Score Library Project)

http://imslp.org/wiki/IMSLP:Musiknoten_beisteuern

OPTIONS:
	-c, --compression:  Use CCITT Group 4 compression. This options
	                    generates a PDF file
	-b, --backup:       backup original images (add .bak to filename)
	-f, --force:        force
	-h, --help:         Show this help message
	-j, --join:         Join single paged PDF files to one PDF file
	-r, --resize:       Resize 200%
	-t, --threshold:    threshold, default 50%
"
}

_remove_extension() {
	echo "$1" | sed 's/\.[[:alnum:]]*$//'
}

_get_channels() {
	identify "$1" | cut -d " " -f 7
}

_options_defaults() {
	OPT_BORDER='-border 100x100 -bordercolor "#FFFFFF"'
	[ "$OPT_COMPRESSION" ] && OPT_COMPRESSION=' -compress Group4 -monochrome'
	OPT_DESKEW='-deskew 40%'
	OPT_FUZZ='-fuzz 98%'
	OPT_REPAGE='-trim +repage'
	[ "$OPT_RESIZE" ] && OPT_RESIZE='-resize 200% '
	[ "$OPT_THRESHOLD" ] && OPT_THRESHOLD="-threshold $OPT_THRESHOLD"
}

_options_order() {
	echo "
		$OPT_RESIZE
		$OPT_DESKEW
		$OPT_THRESHOLD
		$OPT_REPAGE
		$OPT_COMPRESSION
	"
}

_options_normalize() {
	echo $@
}

_options() {
	_options_defaults
	_options_normalize $(_options_order)
}

_convert() {
	if [ -n "$OPT_COMPRESSION" ]; then
		OUT_EXT=pdf
	fi
	CHANNELS=$(_get_channels "$1")
	NEW=$(_remove_extension "$1").$OUT_EXT
	if [ "$CHANNELS" != 2c ] || [ "$OPT_FORCE" = 1 ]; then
		echo "Convert $1 to $NEW"
		if [ "$OPT_BACKUP" = 1 ]; then
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
	OPT_JOIN=
	OPT_RESIZE=
	OPT_THRESHOLD=50%

	while getopts :cbfhjrt:-: arg; do
		case $arg in
			b) OPT_BACKUP=1 ;;
			c) OPT_COMPRESSION=1 ;;
			f) OPT_FORCE=1 ;;
			h) _usage ; exit 0 ;;
			j) OPT_JOIN=1 ;;
			r) OPT_RESIZE=1 ;;
			t) OPT_THRESHOLD="$OPTARG" ;;
			-)
				LONG_OPTARG="${OPTARG#*=}"
				case $OPTARG in
					backup) OPT_BACKUP=1 ;;
					compression) OPT_COMPRESSION=1 ;;
					force) OPT_FORCE=1 ;;
					help) _usage ; exit 0 ;;
					join) OPT_JOIN=1 ;;
					resize) OPT_RESIZE=1 ;;
					threshold=?*) OPT_THRESHOLD="$LONG_OPTARG" ;;
					threshold*) echo "No arg for --$OPTARG option" >&2; exit 2 ;;
					'') break ;;
					*) echo "Illegal option --$OPTARG" >&2; exit 2 ;;
				esac ;;
			\?) exit 2 ;;
		esac
	done
	shift $((OPTIND - 1))
	IMAGES=$@
}

_join() {
	pdftk *.pdf cat output out.pdf
}

## This SEPARATOR is required for test purposes. Please don’t remove! ##

_arguments $@

if [ -z "$IMAGES" ]; then
	_usage
	exit 1
fi

for IMAGE in $IMAGES; do
	_convert "$IMAGE"
done

[ "$OPT_JOIN" ] && _join
