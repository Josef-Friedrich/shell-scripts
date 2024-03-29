#! /bin/sh

# MSCORE=/usr/bin/mscore3
MSCORE="flatpak run org.musescore.MuseScore"

# MIT License
#
# Copyright (c) 2016-22 Josef Friedrich <josef@friedrich.rocks>
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
SHORT_DESCRIPTION='Convert MuseScore files (*.mscz, *.mscx) to the EPS or SVG file format.'
USAGE="Usage: mscore-to-vector.sh [-ehnsSv] [<path>]

$SHORT_DESCRIPTION

Convert MuseScore files to eps or svg using 'pdfcrop' and 'pdftops' and
'pdf2svg'. If <path> is omitted, all MuseScore files in the
current working directory are converted. <path> can be either a
directory or a MuseScore file.

DEPENDENCIES
	'pdfcrop' (included in TeXlive) and 'pdftops' (Poppler tools) and
    'pdf2svg'

OPTIONS
	-e, --eps
	  Create only EPS files.
	-h, --help
	  Show this help message.
	-n, --no-clean
	  Do not remove / clean intermediate *.pdf files.
	-N, --no-crop
	  Do not crop.
	-p, --pdf-for-latex
	  Create additionally to the eps a corresponding PDF file with the
	  suffix -eps-converted-to.pdf.
	-s, --svg
	  Create only SVG files.
	-S, --short-description
	  Show a short description / summary.
	-v, --version
	  Show the version number of this script.
"

# Exit codes
# Invalid option: 2
# Missing argument: 3
# No argument allowed: 4
_getopts() {
	while getopts ':ehnNpsSv-:' OPT ; do
		case $OPT in
			e) OPT_EPS=1 ;;
			h) echo "$USAGE" ; exit 0 ;;
			n) OPT_NO_CLEAN=1 ;;
			N) OPT_NO_CROP=1 ;;
			p) OPT_PDF_FOR_LATEX=1 ;;
			s) OPT_SVG=1 ;;
			S) echo "$SHORT_DESCRIPTION" ; exit 0 ;;
			v) echo "$VERSION" ; exit 0 ;;

			\?) echo "Invalid option “-$OPTARG”!" >&2 ; exit 2 ;;
			:) echo "Option “-$OPTARG” requires an argument!" >&2 ; exit 3 ;;

			-)
				LONG_OPTARG="${OPTARG#*=}"

				case $OPTARG in
					eps) OPT_EPS=1 ;;
					help) echo "$USAGE" ; exit 0 ;;
					no-clean) OPT_NO_CLEAN=1 ;;
					no-crop) OPT_NO_CROP=1 ;;
					pdf-for-latex) OPT_PDF_FOR_LATEX=1 ;;
					svg) OPT_SVG=1 ;;
					short-description) echo "$SHORT_DESCRIPTION" ; exit 0 ;;
					version) echo "$VERSION" ; exit 0 ;;

					eps*|help*|no-clean*|no-crop*|pdf-for-latex*|svg*|short-description*|version*)
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

_mscore_to_pdf() {
	local MSCORE_FILE PDF_FILE
	MSCORE_FILE="$1"
	PDF_FILE="$2"
	$MSCORE --force --export-to "$PDF_FILE" "$MSCORE_FILE"
}

_pdf_pages() {
	local PDF_FILE
	PDF_FILE="$1"
	pdfinfo "$PDF_FILE" | grep 'Pages:' | awk '{print $2}'
}

_eps_to_pdf() {
	local EPS_FILE PDF_BASE_NAME
	EPS_FILE="$1"
	# logo.eps -> logo
	PDF_BASE_NAME="${EPS_FILE%.eps}"
	epstopdf "$EPS_FILE" --outfile "${PDF_BASE_NAME}-eps-converted-to.pdf"
}

# $1: pdf file
# $2: page number
_to_eps() {
	local PDF_FILE PAGE_NUMBER EPS_FILE
	PDF_FILE="$1"
	PAGE_NUMBER="$2"

	if [ -n "$2" ]; then
		EPS_FILE="$(echo "$PDF_FILE" | sed "s/\.pdf/_$PAGE_NUMBER\.eps/g")"
		pdftops -eps \
			-f "$PAGE_NUMBER" \
			-l "$PAGE_NUMBER" \
			"$PDF_FILE" \
			"$EPS_FILE"
	else
		EPS_FILE="$(echo "$PDF_FILE" | sed "s/\.pdf/\.eps/g")"
		pdftops -eps "$PDF_FILE"
	fi
	if [ -n "$OPT_PDF_FOR_LATEX" ]; then
		_eps_to_pdf "$EPS_FILE"
	fi
}

# Usage: pdf2svg <in file.pdf> <out file.svg> [<page no>]
_to_svg() {
	local PDF_FILE PAGE_NUMBER
	PDF_FILE="$1"
	PAGE_NUMBER="$2"
	if [ -n "$PAGE_NUMBER" ] && [ "$PAGE_NUMBER" -gt 0 ]; then
		pdf2svg \
			"$PDF_FILE" \
			"$(echo "$PDF_FILE" | sed "s/\.pdf/_$PAGE_NUMBER\.svg/g")" \
			"$PAGE_NUMBER"
	else
		pdf2svg "$PDF_FILE" "$(echo "$PDF_FILE" | sed "s/\.pdf/\.svg/g")"
	fi
}

_pdf_to_vector() {
	local PDF_FILE PAGE_NUMBER
	PDF_FILE="$1"
	PAGE_NUMBER="$2"
	if [ -n "$OPT_EPS" ]; then
		_to_eps "$PDF_FILE" "$PAGE_NUMBER"
	fi
	if [ -n "$OPT_SVG" ]; then
		_to_svg "$PDF_FILE" "$PAGE_NUMBER"
	fi
}

_clean() {
	local PDF_FILE
	PDF_FILE="$1"
	if [ ! "$OPT_NO_CLEAN" = "1" ]; then
		rm -f "$PDF_FILE"
	fi
}

_convert_mscore_file() {
	local MSCORE_FILE BASENAME PDF_FILE PAGES
	MSCORE_FILE="$1"

	MSCORE_FILE="$(readlink -f "$MSCORE_FILE")"
	BASENAME=$(echo "$MSCORE_FILE" | sed 's/\.mscx//g' | sed 's/\.mscy//g')
	PDF_FILE="${BASENAME}.pdf"

	_mscore_to_pdf "$MSCORE_FILE" "$PDF_FILE" > /dev/null 2>&1

	if [ -z "$OPT_NO_CROP" ]; then
		pdfcrop "$PDF_FILE" "$PDF_FILE" > /dev/null 2>&1
	fi
	PAGES=$(_pdf_pages "$PDF_FILE")

	if [ "$PAGES" -gt 1 ]; then
		I=1
		while [ "$I" -le "$PAGES" ]; do
			_pdf_to_vector "$PDF_FILE" "$I"
		I=$((I + 1))
		done
	else
		_pdf_to_vector "$PDF_FILE"
	fi
	_clean "$PDF_FILE"
}

_check_for_executable() {
	if ! command -v "$1" > /dev/null 2>&1 ; then
		echo "Missing binary “$1”!" >&2
		exit 2
	fi
}

## This SEPARATOR is required for test purposes. Please don’t remove! ##

_getopts $@
shift $GETOPTS_SHIFT

# By default we build eps and svg files.
if [ -z "$OPT_EPS" ] && [ -z "$OPT_SVG" ]; then
	OPT_EPS=1
  OPT_PDF_FOR_LATEX=1
	OPT_SVG=1
fi

_check_for_executable $MSCORE
_check_for_executable pdfcrop
_check_for_executable pdfinfo
_check_for_executable pdftops
_check_for_executable pdf2svg
_check_for_executable epstopdf

FILE="$1"

if [ -f "$FILE" ]; then
	_convert_mscore_file "$FILE"
	exit 0
fi

if [ -d "$FILE" ]; then
	FILES=$(find "$FILE" -iname '*.mscz' -or -iname '*.mscx')
elif [ -z "$FILE" ]; then
	FILES=$(find . -iname '*.mscz' -or -iname '*.mscx')
fi

if [ "$FILES" = '' ]; then
	echo 'No files to convert found!'
	echo "$USAGE"
	exit 1
fi

for FILE in $FILES; do
	_convert_mscore_file "$FILE"
done
