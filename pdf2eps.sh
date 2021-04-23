#! /bin/sh

# MIT License
#
# Copyright (c) 2021 Josef Friedrich <josef@friedrich.rocks>
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
	echo "Usage: $(basename "$0") <pdf-file-without-ext> [page-number]

Options:
	-h, --help: Show this help message."
}

if [ "$1" = '-h' ] || [ "$1" = '--help' ] ; then
	_usage
	exit 0
fi

FILE="$1"
PAGE_NUMBER="$2"

if [ -z "$FILE" ]; then
	_usage
	exit 1
fi

if [ -z "$PAGE_NUMBER" ]; then
	PAGE_NUMBER=1
fi

#pdfcrop ${FILE}.pdf
pdftops -f $PAGE_NUMBER -l $PAGE_NUMBER -eps "${FILE}.pdf"
#rm  -f "${FILE}-crop.pdf"
#mv  "${FILE}-crop.eps" $FILE.eps
