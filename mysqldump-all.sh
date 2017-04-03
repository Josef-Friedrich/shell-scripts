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
	echo "Usage: $(basename $0) -u <username> -p <password> [-d <backup-directory>]"
}

while getopts ":d:u:p:" opt; do
	case $opt in
		d)
			DIR="$OPTARG"
			;;

		p)
			PASSWORD="$OPTARG"
			;;

		u)
			USER="$OPTARG"
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

if [ -z "$USER" ] || [ -z "$PASSWORD" ]; then
	_usage
	exit 1
fi

if [ -z "$DIR" ]; then
	DIR="$(pwd)"
fi

DATABASES=$(mysql -u $USER -p$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)

for DB in $DATABASES; do
	if [ "$DB" != "information_schema" ] && [ "$DB" != "performance_schema" ] && [ "$DB" != "mysql" ] && [ "$DB" != _* ] ; then
		echo "Dumping database: $DB"
		DUMP="$DIR/$(date +%Y%m%d).$DB.sql"
		mysqldump -u "$USER" -p$PASSWORD "$DB" > "$DUMP"
	  gzip "$DUMP"
	fi
done
