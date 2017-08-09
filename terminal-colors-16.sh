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

#Background
for clbg in {40..47} {100..107} 49 ; do
	#Foreground
	for clfg in {30..37} {90..97} 39 ; do
		#Formatting
		for attr in 0 1 2 4 5 7 ; do
			#Print the result
			echo -en "\e[${attr};${clbg};${clfg}m ^[${attr};${clbg};${clfg}m \e[0m"
		done
		echo #Newline
	done
done
