#! /bin/sh

UNIT="$1"

if [ -z "$UNIT" ]; then
	for UNIT in $(ls); do
		systemctl enable "$(pwd)/$UNIT"
	done
else
	systemctl enable "$(pwd)/$UNIT" 
fi
