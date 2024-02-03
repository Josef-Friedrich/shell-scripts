#! /bin/bash

# MIT License
#
# Copyright (c) 2024 Josef Friedrich <josef@friedrich.rocks>
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

OPTION="$1"
INFO_I="$2"
INFO_II="$3"
INFO_III="$4"

_from_to() {
  if [ -n "$INFO_III" ]; then
    QUALITY="-quality $INFO_III"
  fi
  convert $QUALITY "${FILE}" "${FILE}.${INFO_II}"
}

_resize() {
  convert "${FILE}" -resize 1920x1080\! "1920x1080_${FILE}"
}

_levels_and_color_reduction() {
  convert "${FILE}" -level ${INFO_II} -colors ${INFO_III} -flatten "levels_${FILE}.png"
}

_big_band() {
  convert "${FILE}" -level 60,80% -colors 8 -flatten -density 300 "big-band_${FILE}.png"
}


_usage() {
  echo "Usage: $(basename $0) <options> <more-options>

Options:

  -f <from-extension> <to-extension> <quality>
    From extension 1 to extension 2.
      e. g. $(basename $0) -f jpg png 80

  -l <from-extension> <levels> <colors>
    Reduce levels <levels> to and colors to <colors> to a png file.
      e. g. $(basename $0) -l png 40,85% 8

  -b <from-extension>
    For big band scores: -b tiff => -l tiff 60,80% 8
"
}

_separator() {
  echo "
############################################################
# ${FILE}
############################################################
"
}

case $OPTION in

  -b)
    COMMAND='_big_band'
    ;;

  -f)
    COMMAND='_from_to'
    ;;

  -h)
    _usage
    exit 1
    ;;

  -l)
    COMMAND='_levels_and_color_reduction'
    ;;

  *)
    _usage
    exit 1
    ;;

esac

find . -iname "*.${INFO_I}" -print0 | while read -d $'\0' FILE ; do
  FILE=$(basename ${FILE})
  _separator

  $COMMAND

done
