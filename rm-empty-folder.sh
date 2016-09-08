#! /bin/sh

# https://gist.github.com/Josef-Friedrich/3f0aa77b3c6b09c3f5712b2fd630e92f

#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
# Copyright (C) 2016 Josef Friedrich <josef@friedrich.rocks>
#
# Everyone is permitted to copy and distribute verbatim or modified
# copies of this license document, and changing it is allowed as long
# as the name is changed.
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO“

if [ -z "$1" ]; then
	BASE="."
else
	BASE="$1"
fi

find "$BASE" -type d -empty -exec rmdir {} \;
