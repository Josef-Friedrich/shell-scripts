#! /bin/sh

mscore --export-to $2.$1 $2.mscx


inkscape \
	--export-area-drawing \
	--without-gui \
	--export-eps=$1.eps $1.svg
