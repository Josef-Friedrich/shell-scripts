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

COLORS=('\033[0;30m' '\033[0;31m' '\033[0;32m' '\033[0;33m' '\033[0;34m' '\033[0;35m' '\033[0;36m' '\033[0;37m' '\033[1;30m' '\033[1;31m' '\033[1;32m' '\033[1;33m' '\033[1;34m' '\033[1;35m' '\033[1;36m' '\033[1;37m' '\033[4;30m' '\033[4;31m' '\033[4;32m' '\033[4;33m' '\033[4;34m' '\033[4;35m' '\033[4;36m' '\033[4;37m')

TEST_STRING="user@host:~$"

echo "

######
#     # #####   ####  #    # #####  #####
#     # #    # #    # ##  ## #    #   #
######  #    # #    # # ## # #    #   #
#       #####  #    # #    # #####    #
#       #   #  #    # #    # #        #
#       #    #  ####  #    # #        #

 #####
#     #  ####  #       ####  #####
#       #    # #      #    # #    #
#       #    # #      #    # #    #
#       #    # #      #    # #####
#     # #    # #      #    # #   #
 #####   ####  ######  ####  #    #


Please choose a prompt color!

"

COUNT=0
for COLOR in "${COLORS[@]}"; do
  echo -e "$COUNT:	${COLOR}${TEST_STRING}${RESET}"
  COUNT=$((COUNT + 1))
done

echo -n "
Your favourite prompt color: "

read COLOR_NUMBER

CHOSEN_COLOR=${COLORS[$COLOR_NUMBER]}

echo "$CHOSEN_COLOR" > "$HOME/.prompt-color"

echo -e "Your color: ${CHOSEN_COLOR}${TEST_STRING}${RESET}"

bash
