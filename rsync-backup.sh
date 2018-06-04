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

FIRST_RELEASE=2013-12-16
VERSION=1.0
PROJECT_PAGES="https://github.com/Josef-Friedrich/rsync-backup.sh"
SHORT_DESCRIPTION='A wrapper script for rsync with source und destination accessibility checks, advanced logging and backup support.'

########################################################################
# Variables
########################################################################

LOG_FOLDER_HOST="$HOME/rsync-backup-logs"

# Prepare variables for backup dir. Backup dir should look like
# ".backup/2013-04-04T20-11-23"

RSYNC_FOLDER='.rsync-backup'

BACKUP_FOLDER="$RSYNC_FOLDER/backups"
DATE="$(date "+%Y-%m-%dT%H-%M-%S")"

HOSTNAME=$(hostname -s)
USER=$(whoami)

TMP_FOLDER='/tmp/.rsync-backup'

AFFIRMATION_FILE='please-sync'
EXCLUDE_FILE='excludes'

SEPARATOR='################################################'

# Sorry: --exclude PATTERN --exclude PATTERN
DEFAULT_EXCLUDES="--exclude .rsync_shadow --exclude .snapshots"

if [ -f /etc/rsync-backup.conf ]; then
	# shellcheck disable=SC1091
	. /etc/rsync-backup.conf
fi

if [ ! -d "$TMP_FOLDER" ]; then
	mkdir "$TMP_FOLDER"
fi


USAGE="Usage: rsync-backup [-abBdehlLmn] <source> <destination>

$SHORT_DESCRIPTION

OPTIONS
	-a <path>: Creates a $RSYNC_FOLDER/$AFFIRMATION_FILE affirmation file for the given folder.
	-b: Beep.
	-B: Backup.
	-d: Delete all log file in the log folder.
	-e: Show execution log.
	-h: Show help.
	-l: Show log summary.
	-L: Show log folder.
	-m: Send logs per mail.
	-n: Send NSCA message to nagios.

LOG FILES
	GENERAL LOG FILE
		$LOG_FOLDER_HOST/summary.log
		$LOG_FOLDER_HOST/execution.log

	LOG FILE PER DATE, SOURCE AND DESTINATION
		Directory: $LOG_FOLDER_HOST
		Naming convention: log_\$DATE_\$HOSTNAME_\$SOURCE_\$DESTINATION.log

EXCLUDES
	To exclude some files or folders place a 'excludes' file in the destination
	folder ($RSYNC_FOLDER/$EXCLUDE_FILE). For further informations read the
	'--exclude-from' section in the 'rsync' manual.

AFFIRMATION_FILE
	Synchronization only works, if in both folders (source and destination) a
	affirmation file exists ($RSYNC_FOLDER/$AFFIRMATION_FILE).

CONFIGURATION
	Custom configurations can be done in /etc/rsync-backup.conf.

DEPENDENCIES
	- rsync
	- scp
	- tee"

########################################################################
# Accessibility check.
########################################################################

##
# Check if source or destinations folder exists.
##
_check_scp() {
	FOLDER="$1"

	scp "$FOLDER/$RSYNC_FOLDER/$AFFIRMATION_FILE" "$TMP_FOLDER/" > /dev/null 2>&1

	if [ $? -eq 0 ]; then
		FOLDER_INACCESSIBILITY=0
	else
		FOLDER_INACCESSIBILITY=1
	fi
}

_check_accessiblity() {
	_check_scp "$SOURCE" "Source"

	if [ "$FOLDER_INACCESSIBILITY" = 1 ]; then
		SOURCE_INACCESSIBILITY=1
	fi

	_check_scp "$DESTINATION" "Destination"

	if [ "$FOLDER_INACCESSIBILITY" = 1 ]; then
		DESTINATION_INACCESSIBILITY=1
	fi

	if [ "$SOURCE_INACCESSIBILITY" = 1 ] || [ "$DESTINATION_INACCESSIBILITY" = 1 ]; then
		echo "The folders are not accessible or no affirmation file exists!
Create a '$RSYNC_FOLDER/$AFFIRMATION_FILE' file or use the command 'rsync -a <folder>'.

###    #     #    #    ######  #     # ### #     #  #####     ###
###    #  #  #   # #   #     # ##    #  #  ##    # #     #    ###
###    #  #  #  #   #  #     # # #   #  #  # #   # #          ###
 #     #  #  # #     # ######  #  #  #  #  #  #  # #  ####     #
       #  #  # ####### #   #   #   # #  #  #   # # #     #
###    #  #  # #     # #    #  #    ##  #  #    ## #     #    ###
###     ## ##  #     # #     # #     # ### #     #  #####     ###


"
	fi

	if [ "$SOURCE_INACCESSIBILITY" = 1 ]; then
		echo "rsync-backup.sh -a $SOURCE"
	fi

	if [ "$DESTINATION_INACCESSIBILITY" = 1 ]; then
		echo "rsync-backup.sh -a $DESTINATION"
	fi

	if [ "$SOURCE_INACCESSIBILITY" = 1 ] || [ "$DESTINATION_INACCESSIBILITY" = 1 ]; then
		if [ "$BEEP" = 1 ]; then
			beep -f 65.4064 -l 100 > /dev/null 2>&1
		fi
		exit 1
	fi
}

##
# Create a dotfile in a given directory, which is used as a sync affirmation
# file.
##
_create_affirmation_file() {
	FOLDER="$1"

	local TMP_FILE=$(mktemp)
	local TMP_FOLDER=$(mktemp -d)

	date +%s > "$TMP_FILE"

	rsync -av "$TMP_FOLDER" "$FOLDER/$RSYNC_FOLDER" > /dev/null 2>&1
	rsync -av "$TMP_FILE" "$FOLDER/$RSYNC_FOLDER/$AFFIRMATION_FILE" > /dev/null 2>&1

	if [ $? -eq 0 ]; then
		echo "The '$AFFIRMATION_FILE' file was successfully created."
	else
		echo "The '$AFFIRMATION_FILE' file could not be created."
		exit 1
	fi
}

########################################################################
# rsync-backup options processing.
########################################################################

##
# Process source and destination parameters for rsync.
##
_process_source_destination() {
	# Slash on the end of source and destination variables is important,
	# that the ".backup" folder is placed in the right position.
	echo "$SOURCE/ $DESTINATION/"
}

##
# Process the options for the rsync command.
##
_process_options() {
	# Exclude the _gsdata_ folder, which creates the sync software
	# "Goodsync". Exclude the .backup folder, where the deleted and
	# modified files are stored. Otherwise these files got more and more
	# nested.
	EXCLUDES="--exclude $RSYNC_FOLDER/ $DEFAULT_EXCLUDES"
	DESTINATION_EXCLUDE_FILE="${DESTINATION}/${RSYNC_FOLDER}/${EXCLUDE_FILE}"

	DESTINATION_EXCLUDE_FILE=$(echo "$DESTINATION_EXCLUDE_FILE" | sed -e 's/\/\//\//g')
	scp "${DESTINATION_EXCLUDE_FILE}" "$TMP_FOLDER/excludes_$SYNC_ID"	> /dev/null 2>&1

	if [ $? -eq 0 ]; then
		EXCLUDES_BY_FILE=" --exclude-from $TMP_FOLDER/excludes_$SYNC_ID"
	fi

	# Default options, which works hopefully on many NASs. To avoid
	# annoying recopies if the size-only option is set.

	# -a -> -rlptgoD
	# --recursive --links --perms , --times	--group	 --owner --devices
	DEFAULT="--recursive \
--links \
--perms \
--times \
--group \
--owner \
--verbose \
--delete \
--size-only \
--keep-dirlinks \
--partial \
--stats"

	if [ "$OPTION_BACKUP" = 1 ]; then
		BACKUP="--backup --backup-dir=$BACKUP_FOLDER/$DATE"
	fi

	echo "$DEFAULT $EXCLUDES $EXCLUDES_BY_FILE $BACKUP"
}

_trim_value() {
	echo $1 | tr -d ,
}

_extract_value() {
	local VALUE
	VALUE=$(echo "$1" | head -n "$2" | tail -1 | cut -d ':' -f 2)
	_trim_value $VALUE
}

_parse_statistics() {
	local STAT_BLOCK="$(echo "$1" | grep -A 13 "Number of files")"

	STAT_NUM_FILES="$(_extract_value "$STAT_BLOCK" 1)"
	STAT_NUM_CREATED_FILES="$(_extract_value "$STAT_BLOCK" 2)"
	STAT_NUM_DELETED_FILES="$(_extract_value "$STAT_BLOCK" 3)"
	STAT_NUM_FILES_TRANSFERRED="$(_extract_value "$STAT_BLOCK" 4)"
	STAT_TOTAL_SIZE="$(_extract_value "$STAT_BLOCK" 5)"
	STAT_TRANSFERRED_SIZE="$(_extract_value "$STAT_BLOCK" 6)"
	STAT_LITERAL_DATA="$(_extract_value "$STAT_BLOCK" 7)"
	STAT_MATCHED_DATA="$(_extract_value "$STAT_BLOCK" 8)"
	STAT_LIST_SIZE="$(_extract_value "$STAT_BLOCK" 9)"
	STAT_LIST_GENERATION_TIME="$(_extract_value "$STAT_BLOCK" 10)"
	STAT_LIST_TRANSFER_TIME="$(_extract_value "$STAT_BLOCK" 11)"
	STAT_BYTES_SENT="$(_extract_value "$STAT_BLOCK" 12)"
	STAT_BYTES_RECEIVED="$(_extract_value "$STAT_BLOCK" 13)"
}

########################################################################
# log showing
########################################################################

##
# Show the tail of the summary log.
##
_log_summary_show() {
	local SUMMARY="$LOG_FOLDER_HOST/summary.log"

	if [ -f "$SUMMARY" ]; then
		tail -f -n 1000 "$SUMMARY"
	fi
}

##
# Show the tail of the execution log.
##
_log_execution_show() {
	EXECUTION="$LOG_FOLDER_HOST/execution.log"

	if [ -f "$EXECUTION" ]; then
		tail -f -n 50 "$EXECUTION"
	fi
}

_log_show_folder() {
	ls -l "$LOG_FOLDER_HOST"
}

########################################################################
# log processing
########################################################################

_sync_job_name() {
	echo "$*" | sed \
		-e 's#[/@:\.]#-#g' \
		-e 's#-*\([_]\)-*#\1#g' \
		-e 's/-\{2,\}/-/g' \
		-e 's/-$//g' \
		-e 's/^-//g'
}

##
# Create the log file and add meta informations to the head of the log file.
##
_log_init() {
	if [ ! -d "$LOG_FOLDER_HOST" ]; then
		mkdir "$LOG_FOLDER_HOST"
	fi
	LOG_FILE_HOST_NAME="log_${DATE}_${SYNC_JOB_NAME}.log"
	LOG_FILE_HOST="$LOG_FOLDER_HOST/$LOG_FILE_HOST_NAME"
	touch "$LOG_FILE_HOST"
	> "$LOG_FILE_HOST"

	_log_header >> "$LOG_FILE_HOST"
}

_log_delete() {
	find "$LOG_FOLDER_HOST" -type f -exec rm -rf {} \;
}

##
# Write informations to a log file how often the rsync-backup command on a
# certain is executed.
##
_log_execution() {
	echo "$(_date) [$SOURCE] -> [$DESTINATION]" >> "$LOG_FOLDER_HOST"/execution.log
}

##
# Print out background informations about the sync.
##
_log_header() {
	local DECORATION="$1"

	if [ "$DECORATION" = 'YES' ]; then
		echo "$SEPARATOR

                        #           #
###  ## # # ##  ###     ###  ## ### # # # # ###
#    #  ### # # #   ### # # # # #   ##  # # # #
#   ##    # # # ###     ### ### ### # # ### ###
        ###                                 #
"
	fi

	echo "SOURCE: $SOURCE
DESTINATION: $DESTINATION
DATE: $DATE
HOST: $HOSTNAME
USER: $USER"

	if [ "$DECORATION" = 'YES' ]; then
		echo "
$SEPARATOR
"
	fi
}

##
# Send the generated log file to a email address.
##
_log_mail() {
	local MAIL_COMMAND=$(command -v mail)
	if [ -n "$MAIL_COMMAND" ]; then
		local SUBJECT="#rb [$SOURCE] -> [$DESTINATION] \
created: $STAT_NUM_CREATED_FILES \
deleted: $STAT_NUM_DELETED_FILES"

		maillog.sh "$SUBJECT" "$LOG_FILE_HOST"
	fi
}

##
# Copy the log file to the source and destination folder.
##
_log_file_copy() {
	FOLDER="$1/$RSYNC_FOLDER/"
	scp "$LOG_FILE_HOST" "$FOLDER" > /dev/null 2>&1
}

##
# Write out from rsync to log files.
##
_log_process() {
	local WRITE_TO_SUMMARY=0
	local START_SUMMARY=''
	local STOP_SUMMARY=''
	local NOT_EMPTY_LINE=''

	while read -r DATA; do
		echo "$DATA" >> "$LOG_FILE_HOST"

		STOP_SUMMARY=$(echo "$DATA" | grep 'Number of files:')

		if [ -n "$STOP_SUMMARY" ]; then
			WRITE_TO_SUMMARY=0
		fi

		NOT_EMPTY_LINE=$(echo "$DATA" | awk 'NF')

		if [ ! "$WRITE_TO_SUMMARY" = 0 ] && [ -n "$NOT_EMPTY_LINE" ]; then
			echo "$(date "+%Y-%m-%dT%H-%M-%S") [$SOURCE] -> [$DESTINATION]: $DATA" >> "$LOG_FOLDER_HOST"/summary.log
		fi

		START_SUMMARY=$(echo "$DATA" | grep -E 'building file list|sending incremental file list|receiving incremental file list')

		if [ -n "$START_SUMMARY" ]; then
			WRITE_TO_SUMMARY=1
		fi

		echo "$DATA" | awk 'NF'
	done
}

_nsca_output() {
	echo "RSYNC OK \
| \
num_files=${STAT_NUM_FILES} \
num_created_files=${STAT_NUM_CREATED_FILES} \
num_deleted_files=${STAT_NUM_DELETED_FILES} \
num_files_transferred=${STAT_NUM_FILES_TRANSFERRED} \
total_size=${STAT_TOTAL_SIZE} \
transferred_size=${STAT_TRANSFERRED_SIZE} \
literal_data=${STAT_LITERAL_DATA} \
matched_data=${STAT_MATCHED_DATA} \
list_size=${STAT_LIST_SIZE} \
list_generation_time=${STAT_LIST_GENERATION_TIME} \
list_transfer_time=${STAT_LIST_TRANSFER_TIME} \
bytes_sent=${STAT_BYTES_SENT} \
bytes_received=${STAT_BYTES_RECEIVED}"
}

##
# Process send_nsca to nagios.
##
_nsca_process() {
	easy-nsca.sh -o "$(_nsca_output)" "rsync_${SYNC_JOB_NAME}"

	echo "NSCA output: $(_nsca_output)" >> "$LOG_FILE_HOST"
	echo "NSCA service: rsync_${SYNC_JOB_NAME}" >> "$LOG_FILE_HOST"
}

########################################################################
# Misc
########################################################################

_date() {
	date +%Y-%m-%dT%H-%M-%S
}

########################################################################
# Process
########################################################################

_execute() {
	while getopts ":a:bBdehlLmn" OPT; do
		case $OPT in

			a)
				_create_affirmation_file "$OPTARG"
				exit 0
				;;

			b)
				OPTION_BEEP=1
				;;

			B)
				OPTION_BACKUP=1
				;;

			d)
				_log_delete
				exit 0
				;;

			e)
				_log_execution_show
				exit 0
				;;

			h)
				echo "$USAGE"
				exit 0
				;;

			l)
				_log_summary_show
				exit 0
				;;

			L)
				_log_show_folder
				exit 0
				;;

			m)
				OPTION_MAIL=1
				;;

			n)
				OPTION_NSCA=1
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
	SOURCE="${1%/}"
	DESTINATION="${2%/}"
	SYNC_JOB_NAME="$(_sync_job_name "${HOSTNAME}_${SOURCE}_${DESTINATION}")"

	_check_accessiblity

	_log_init

	_log_header "YES"

	# shellcheck disable=SC2046
	rsync $(_process_options) $(_process_source_destination) | _log_process

	_parse_statistics "$(cat "$LOG_FILE_HOST")"

	if [ -n "$OPTION_NSCA" ]; then
		_nsca_process
	fi

	if [ "$OPTION_MAIL" = 1 ]; then
		_log_mail
	fi

	_log_execution

	_log_file_copy "$SOURCE"
	_log_file_copy "$DESTINATION"

	if [ "$OPTION_BEEP" = 1 ]; then
		beep -f 4186.01 -l 40 > /dev/null 2>&1
	fi
}

### This SEPARATOR is needed for the tests. Do not remove it! ##########

if [ "$(basename "$0")" = 'rsync-backup.sh' ]; then
	_execute $@
fi
