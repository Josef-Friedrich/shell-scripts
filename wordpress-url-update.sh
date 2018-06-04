#! /bin/sh

# MIT License
#
# Copyright (c) 2016 Josef Friedrich <josef@friedrich.rocks>
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

FIRST_RELEASE=2014-12-31
VERSION=1.0
PROJECT_PAGES="https://github.com/Josef-Friedrich/wordpress-update-url.sh"
SHORT_DESCRIPTION='A small shell script to update the url of wordpress sites.'
USAGE="Usage: wordpress-url-update.sh

$SHORT_DESCRIPTION

Options:
	-u MySQL user
	-p MySQL password
	-d MySQL database
	-o Old URL
	-n New URL
	-h Show usage



This script uses the mysql shell command. To use this script you must have
access to the mysql server providing the data for your wordpress site
over the shell command.

# Where is the url stored in the mysql database?

	* In the table 'wp_options' in the column 'option_value'.
	* In the table 'wp_posts' in the columns 'guid' and 'post_content'.

# Command line usage:

	wordpress-url-update.sh -u <user> -p <password> -d <database> -n <new-url>

## Example:

	wordpress-url-update.sh -u root -p 5dtaJ -d wp_db -n http://new-url.com

If you use the shell script frequently on the same site, it is recommended
to edit the script file and put there your mysql connection and url
informations:

	MYSQL_USER=\"\"
	MYSQL_PASSWORD=\"\"
	MYSQL_DATABASE=\"\"
	NEW_URL=\"\"

## Example:

	MYSQL_USER=\"root\"
	MYSQL_PASSWORD=\"5dtaJ\"
	MYSQL_DATABASE=\"wp_db\"
	NEW_URL=\"http://new-url.com\"

Then you can update your wordpress site executing this short command:

	wordpress-url-update.sh"

MYSQL_USER=""
MYSQL_PASSWORD=""
MYSQL_DATABASE=""
NEW_URL=""

_execute_mysql() {
	mysql \
		--silent \
		--raw \
		--user=$MYSQL_USER \
		--password=$MYSQL_PASSWORD $MYSQL_DATABASE \
		-e "$1" 2> /dev/null
}

_get_old_url() {
	_execute_mysql "
		SELECT option_value FROM options WHERE option_name = 'siteurl';
	"
}

_update_wp_options() {
	_execute_mysql "
		UPDATE options
			SET option_value = replace(option_value, '$OLD_URL', '$NEW_URL')
			WHERE option_name = 'home'
				OR option_name = 'siteurl';
	"
}

_update_wp_posts() {
	_execute_mysql "
		UPDATE posts
		SET guid = replace(guid, '$OLD_URL','$NEW_URL');
"
}

_update_post_content() {
	_execute_mysql "
		UPDATE posts
		SET post_content = replace(post_content, '$OLD_URL', '$NEW_URL');
	"
}

## This SEPARATOR is required for test purposes. Please don’t remove! ##

while getopts ":u:p:d:o:n:h" OPT; do
	case $OPT in

		u) MYSQL_USER="$OPTARG";;
		p) MYSQL_PASSWORD="$OPTARG";;
		d) MYSQL_DATABASE="$OPTARG";;
		o) OLD_URL="$OPTARG";;
		n) NEW_URL="$OPTARG";;
		h) echo "$USAGE"; exit 0 ;;

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

if [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ]; then
	echo "No or incomplete informations about the MySQL connection!
Use -u (user) -p (password) and -d (database) options."
	exit 1
fi

if [ -z "$OLD_URL" ]; then
	OLD_URL=$(_get_old_url)
fi

if [ -z "$NEW_URL" ]; then
	echo "No new URL! Use -n option."
	exit 1
fi

# For debug purposes only:
#echo "MySQL user: $MYSQL_USER"
#echo "MySQL password: $MYSQL_PASSWORD"
#echo "MySQL database: $MYSQL_DATABASE"
#echo "Old URL: $OLD_URL"
#echo "New URL: $NEW_URL"

_update_wp_options

_update_wp_posts

_update_post_content
