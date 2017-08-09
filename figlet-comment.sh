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
	echo 'FIGLET-COMMENT(1)

NAME
			 figlet-comment - Converts text to ASCII Art text using figlet and adds comments.

SYNOPSIS
			 figlet-comment [-f f ont style -s comment style] text

DESCRIPTION
			 Converts text to ASCII Art text using figlet and adds comments.

OPTIONS
			 ·   -f schrift: Specify a font style like moscow. Default font style is big. You get a list of possible font styles using figlist(1).

			 ·   -s comment style: Specifiy a comment style like bash. Default comment style is cstyle.

			 ·   none

			 ·   bash

			 ·   cstyle

			 ·   cplus

			 ·   vbasic

			 ·   tex

EXAMPLES
			 figlet-comment -s bash -f moscow foo bar

SEE ALSO
			 figlet(1), figlist(1)'
}

### This SEPARATOR is needed for the tests. Do not remove it! ##########

#font="banner"
font="big"
style="cstyle"

while getopts ":f:hs:" opt; do
	case $opt in
		f)
			font=$OPTARG
		;;

		h)
			_usage
			exit 0
		;;

		s)
			style=$OPTARG
		;;

		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
		;;

		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
		;;

	esac
done

shift $((OPTIND-1))

case $style in
	none)
		comment=""
	;;
	bash)
		comment="# "
	;;
	cstyle)
		prefix='/**'
		comment=' * '
		suffix=' */'
	;;
	cplus)
		comment="// "
	;;
	vbasic)
		comment="' "
	;;
	tex)
		comment="% "
	;;
esac

inline=$@
while true; do

 if [ -n "$inline" ]; then
	 input="$inline"
	 inline=""
 else
	 read input
 fi

	if [ -n "$prefix" ]; then
		echo "$prefix"
	fi

	figlet -w 120 -f $font $input | sed '/^ *$/d' | sed -e "s/^/$comment/g"

	if [ -n "$suffix" ]; then
		echo "$suffix"
	fi

done
