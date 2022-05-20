#! /bin/bash

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
	echo "Usage: $(basename "$0")

Run latexmk recursively on all TeX files in the parent working directory.
Clean all tmp files. Show OK or ERROR for the build status.

Options:
	-h, --help: Show this help message."
}

if [ "$1" = '-h' ] || [ "$1" = '--help' ] ; then
	_usage
	exit 0
fi

_latexmk () {
	# -cd  Change to directory of source file when processing it
	# -gg  Super go mode: clean out generated files (-CA), and then process files regardless of file timestamps
	latexmk -cd -gg -lualatex -silent "$1" > /dev/null 2>&1
	if [ "$?" -eq 0 ]; then
		echo -e "\033[32mOK:\e[0m $TEX_FILE"
	else
		echo -e "\033[31mERROR:\e[0m $TEX_FILE"
	fi
	#  -c clean up (remove) all nonessential files, except dvi, ps and pdf files. This and the other clean-ups are instead of a regular make.
	latexmk -cd -c -silent "$1" > /dev/null 2>&1
}

OLD_IFS="$IFS"
IFS=$'\n'
for TEX_FILE in $(find . -iname "*.tex" | sort); do
	_latexmk "$TEX_FILE"
done
IFS="$OLD_IFS"
