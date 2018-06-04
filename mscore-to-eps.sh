#! /bin/sh

INTER_FORMAT=pdf
#EPS_TOOL=inkscape
EPS_TOOL=pdftops

# MIT License
#
# Copyright (c) 2016 Josef Friedrich <josef@friedrich.rocks>
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

FIRST_RELEASE=2017-08-13
VERSION=1.0
PROJECT_PAGES="https://github.com/Josef-Friedrich/mscore-to-eps.sh"
SHORT_DESCRIPTION='Convert MuseScore files (*.mscz, *.mscx) to the EPS file format.'
USAGE="Usage: mscore-to-eps.sh [-hnsv] [<path>]

$SHORT_DESCRIPTION

Convert MuseScore files to eps using 'pdfcrop' and 'pdftops' or
'Inkscape'. If <path> is omitted, all MuseScore files in the
current working directory are converted. <path> can be either a
directory or a MuseScore file.

DEPENDENCIES
	'pdfcrop' (included in TeXlive) and 'pdftops' (Poppler tools) or
	'Inkscape'

OPTIONS
	-h, --help
	  Show this help message.
	-n, --no-clean
	  Do not remove / clean intermediate *.$INTER_FORMAT files
	-s, --short-description
	  Show a short description / summary.
	-v, --version
	  Show the version number of this script.
"

# Exit codes
# Invalid option: 2
# Missing argument: 3
# No argument allowed: 4
_getopts() {
	while getopts ':hnsv-:' OPT ; do
		case $OPT in
			h) echo "$USAGE" ; exit 0 ;;
			n) OPT_NO_CLEAN=1 ;;
			s) echo "$SHORT_DESCRIPTION" ; exit 0 ;;
			v) echo "$VERSION" ; exit 0 ;;

			\?) echo "Invalid option “-$OPTARG”!" >&2 ; exit 2 ;;
			:) echo "Option “-$OPTARG” requires an argument!" >&2 ; exit 3 ;;

			-)
				LONG_OPTARG="${OPTARG#*=}"

				case $OPTARG in
					help) echo "$USAGE" ; exit 0 ;;
					no-clean) OPT_NO_CLEAN=1 ;;
					short-description) echo "$SHORT_DESCRIPTION" ; exit 0 ;;
					version) echo "$VERSION" ; exit 0 ;;

					help*|no-clean*|short-description*|version*)
						echo "No argument allowed for the option “--$OPTARG”!" >&2
						exit 4
						;;

					'') break ;; # "--" terminates argument processing
					*) echo "Invalid option “--$OPTARG”!" >&2 ; exit 2 ;;

				esac
				;;

		esac
	done
	GETOPTS_SHIFT=$((OPTIND - 1))
}

_mscore() {
	if [ "$(uname)" = "Darwin" ]; then
		/Applications/MuseScore\ 2.app/Contents/MacOS/mscore \
			--export-to "$1".$INTER_FORMAT "$2"
	else
		echo "Export to $1"
		mscore --export-to "$1".$INTER_FORMAT "$2"
	fi
}

_inkscape() {
	if [ "$(uname)" = "Darwin" ]; then
		INKSCAPE=/Applications/Inkscape.app/Contents/Resources/bin/inkscape
	else
		INKSCAPE=inkscape
	fi
	$INKSCAPE \
		--export-area-drawing \
		--without-gui \
		--export-eps="$1".eps "$1".$INTER_FORMAT
}

_pdf_pages() {
	pdfinfo "$1" | grep 'Pages:' | awk '{print $2}'
}

_pdftops() {
	pdfcrop "$1" "$1"
	if [ "$2" -gt 0 ]; then
		pdftops -eps -f "$2" -l "$2" "$1" "$(echo "$1" | sed "s/\.pdf/_$2\.eps/g")"
	else
		pdftops -eps "$1"
	fi
}

_to_eps() {
	if [ "$EPS_TOOL" = 'inkscape' ]; then
		_inkscape "$1" "$2" > /dev/null 2>&1
	else
		_pdftops "$1".pdf "$2" > /dev/null 2>&1
	fi
}

_clean() {
	if [ ! "$OPT_NO_CLEAN" = "1" ]; then
		rm -f "$1".$INTER_FORMAT
	fi
}

_do_file() {
	SCORE="$(readlink -f "$1")"
	BASENAME=$(echo "$FILE" | sed 's/\.mscx//g' | sed 's/\.mscy//g')

	_mscore "$BASENAME" "$SCORE" > /dev/null 2>&1

	PAGES=$(_pdf_pages "$BASENAME.$INTER_FORMAT")
	if [ "$PAGES" -gt 1 ]; then
		I=1
		while [ "$I" -le "$PAGES" ]; do
			_to_eps "$BASENAME" "$I"
		I=$((I + 1))
		done
	else
		_to_eps "$BASENAME"
	fi
	_clean "$BASENAME"
}

_check_exec() {
	if ! command -v "$1" > /dev/null 2>&1 ; then
		echo "Missing binary “$1”!" >&2
		exit 2
	fi
}

## This SEPARATOR is required for test purposes. Please don’t remove! ##

if [ $(uname) = 'Darwin' ]; then
	if command -v greadlink > /dev/null ; then
		unalias readlink > /dev/null 2>&1
		alias readlink=greadlink
	else
		echo "ERROR: GNU utils required for Mac. You may use
homebrew to install them: brew install coreutils gnu-sed"
		exit 1
	fi
fi

_getopts $@
shift $GETOPTS_SHIFT

_check_exec mscore
_check_exec pdfcrop
_check_exec pdfinfo
_check_exec pdftops

FILE="$1"

if [ -f "$FILE" ]; then
	_do_file "$FILE"
	exit 0
fi

if [ -d "$FILE" ]; then
	FILES=$(find "$FILE" -iname '*.mscz' -or -iname '*.mscx')
elif [ -z "$FILE" ]; then
	FILES=$(find . -iname '*.mscz' -or -iname '*.mscx')
fi

if [ "$FILES" = '' ]; then
	echo 'No files to convert found!'
	_usage
	exit 1
fi

for FILE in $FILES; do
	_do_file "$FILE"
done
