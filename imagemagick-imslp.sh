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

THRESHOLD_SERIES="50 55 60 65 70 75"

NAME="$(basename "$0")"
PROJECT_NAME="$(basename "$(pwd)")"
FIRST_RELEASE=2017-08-11
VERSION=1.0
PROJECT_PAGES="https://github.com/Josef-Friedrich/imagemagick-imslp.sh"
SHORT_DESCRIPTION="A wrapper script for imagemagick to process image \
files suitable for imslp.org (International Music Score Library Project)"
USAGE="Usage: imagemagick-imslp.sh [-bcfhjrSstv] <filename-or-glob-pattern>

$SHORT_DESCRIPTION

http://imslp.org/wiki/IMSLP:Musiknoten_beisteuern

OPTIONS:
	-b, --backup
	  Backup original images (add .bak to filename).
	-c, --compression
	  Use CCITT Group 4 compression. This options generates a PDF
	  file.
	-f, --force
	  force
	-h, --help
	  Show this help message
	-j, --join
	  Join single paged PDF files to one PDF file
	-r, --resize
	  Resize 200%
	-S, --threshold-series
	  Convert the samge image with differnt threshold values to find
	  the best threshold value. Those values are probed:
	  $THRESHOLD_SERIES.
	-s, --short-description
	  Show a short description / summary.
	-t, --threshold
	  threshold, default 50%.
	-v, --version
	  Show the version number of this script.
"

OUT_EXT=png
JOB_IDENTIFIER="imagemagick-imslp_$(date +%s)"

_getopts() {
	OPT_BACKUP=
	OPT_COMPRESSION=
	OPT_FORCE=
	OPT_JOIN=
	OPT_RESIZE=
	OPT_THRESHOLD=50%

	while getopts :cbfhjrSst:v-: arg; do
		case $arg in
			b) OPT_BACKUP=1 ;;
			c) OPT_COMPRESSION=1 ;;
			f) OPT_FORCE=1 ;;
			h) echo "$USAGE" ; exit 0 ;;
			j) OPT_JOIN=1 ;;
			r) OPT_RESIZE=1 ;;
			S) OPT_SERIES=1 ;;
			s) echo "$SHORT_DESCRIPTION" ; exit 0 ;;
			t) OPT_THRESHOLD="$OPTARG" ;;
			v) echo "$VERSION" ; exit 0 ;;

			\?) echo "Invalid option “-$OPTARG”!" >&2 ; exit 2 ;;
			:) echo "Option “-$OPTARG” requires an argument!" >&2 ; exit 3 ;;

			-)
				LONG_OPTARG="${OPTARG#*=}"
				case $OPTARG in
					backup) OPT_BACKUP=1 ;;
					compression) OPT_COMPRESSION=1 ;;
					force) OPT_FORCE=1 ;;
					help) echo "$USAGE" ; exit 0 ;;
					join) OPT_JOIN=1 ;;
					resize) OPT_RESIZE=1 ;;
					threshold-series) OPT_SERIES=1 ;;
					threshold=?*) OPT_THRESHOLD="$LONG_OPTARG" ;;
					short-description) echo "$SHORT_DESCRIPTION" ; exit 0 ;;
					version) echo "$VERSION" ; exit 0 ;;

					backup*|compression*|force*|help*|join*|resize*|short-description*|threshold-series*|version*)
						echo "No argument allowed for the option “--$OPTARG”!" >&2
						exit 4
						;;

					threshold*)
						echo "Option “--$OPTARG” requires an argument!" >&2
						exit 3
						;;

					'') break ;;
					*) echo "Illegal option --$OPTARG" >&2; exit 2 ;;
				esac ;;
			\?) exit 2 ;;
		esac
	done
	shift $((OPTIND - 1))
	IMAGES=$@
}

_remove_extension() {
	echo "$1" | sed 's/\.[[:alnum:]]*$//'
}

_get_extension() {
	echo "${1##*.}"
}

_pdf_to_images() {
	pdfimages -tiff "$1" "$JOB_IDENTIFIER"
}

_threshold_series() {
	for THRESHOLD in $THRESHOLD_SERIES ; do
		OPT_THRESHOLD="$THRESHOLD%"
		_convert "$1"
	done
}

_process_pdf() {
	if [ "$(_get_extension "$1")" = pdf ]; then
		_pdf_to_images "$1"
		IMAGES="$(find . -maxdepth 1 -name "$JOB_IDENTIFIER*")"
	fi
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
	if [ -z "$OPT_SERIES" ]; then
		NEW=$(_remove_extension "$1").$OUT_EXT
	else
		local TMP_THRESHOLD=$(echo $OPT_THRESHOLD | sed 's/%//g')
		NEW="$(_remove_extension "$1")_threshold-${TMP_THRESHOLD}.$OUT_EXT"
	fi

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

_join() {
	pdftk *.pdf cat output out.pdf
}

## This SEPARATOR is required for test purposes. Please don’t remove! ##

_getopts $@

if [ -z "$IMAGES" ]; then
	echo "$USAGE" >&2
	exit 1
fi

_process_pdf $IMAGES

if [ -n "$OPT_SERIES" ]; then
	_threshold_series $IMAGES
else
	for IMAGE in $IMAGES; do
		_convert "$IMAGE"
	done
fi

[ "$OPT_JOIN" ] && _join
