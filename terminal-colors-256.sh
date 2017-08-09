#!/bin/bash

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.

_usage() {
	echo "Usage: $(basename "$0")

Options:
	-h, --help: Show this help message."
}

### This SEPARATOR is needed for the tests. Do not remove it! ##########

if [ "$1" = '-h' ] || [ "$1" = '--help' ] ; then
	_usage
	exit 0
fi

for fgbg in 38 48 ; do #Foreground/Background
	for color in {0..256} ; do #Colors
		#Display the color
		echo -en "\e[${fgbg};5;${color}m ${color}\t\e[0m"
		#Display 10 colors per lines
		if [ $((($color + 1) % 10)) == 0 ] ; then
			echo #New line
		fi
	done
	echo #New line
done
