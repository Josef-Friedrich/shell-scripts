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

########################################################################
# Variables
########################################################################

LOG_FOLDER_HOST="$HOME/rsync-backup-logs"

# Prepare variables for backup dir. Backup dir should look like
# ".backup/2013-04-04T20-11-23"

RSYNC_FOLDER=".rsync-backup"

BACKUP_FOLDER="$RSYNC_FOLDER/backups"
DATE=$(date "+%Y-%m-%dT%H-%M-%S")

HOSTNAME=$(hostname -s)
USER=$(whoami)

TMP_FOLDER="/tmp/.rsync-backup"

AFFIRMATION_FILE="please-sync"
EXCLUDE_FILE="excludes"

SEPARATOR='################################################'

# Sorry: --exclude PATTERN --exclude PATTERN
DEFAULT_EXCLUDES="--exclude .rsync_shadow --exclude .snapshots"

if [ -f /etc/rsync-backup.conf ]; then
	# shellcheck disable=SC1091
	. /etc/rsync-backup.conf
fi

INFO_PATH="$TMP_FOLDER/info-"

if [ ! -d "$TMP_FOLDER" ]; then
	mkdir "$TMP_FOLDER"
fi

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

###                                             ###
### #    #   ##   #####  #    # # #    #  ####  ###
### #    #  #  #  #    # ##   # # ##   # #    # ###
 #  #    # #    # #    # # #  # # # #  # #       #
    # ## # ###### #####  #  # # # #  # # #  ###
### ##  ## #    # #   #  #   ## # #   ## #    # ###
### #    # #    # #    # #    # # #    #  ####  ###

"
	fi

	if [ "$SOURCE_INACCESSIBILITY" = 1 ]; then
		echo "rsync-backup -a $SOURCE"
	fi

	if [ "$DESTINATION_INACCESSIBILITY" = 1 ]; then
		echo "rsync-backup -a $DESTINATION"
	fi

	if [ "$SOURCE_INACCESSIBILITY" = 1 ] || [ "$DESTINATION_INACCESSIBILITY" = 1 ]; then
		beepbox.sh warning
		exit 1
	fi
}

##
# Create a dotfile in a given directory, which is used as a sync affirmation
# file.
##
_create_affirmation_file() {
	FOLDER="$1"

	date +%s > "$TMP_FOLDER/$AFFIRMATION_FILE"

	rsync "$TMP_FOLDER/$AFFIRMATION_FILE" "$FOLDER/$RSYNC_FOLDER/" > /dev/null 2>&1

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

	if [ -z "$NO_BACKUP" ]; then
		BACKUP="--backup --backup-dir=$BACKUP_FOLDER/$DATE"
	fi

	echo "$DEFAULT $EXCLUDES $EXCLUDES_BY_FILE $BACKUP"
}


########################################################################
# log showing
########################################################################

##
# Show the tail of the summary log.
##
_log_summary_show() {
	SUMMARY="$LOG_FOLDER_HOST/summary.log"

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

_show_folder_logs() {
	FOLDER="${1%/}/$RSYNC_FOLDER"

	FILES=$(find "$FOLDER" -name "log_*" | tail -n 5)

	for FILE in $FILES; do
		echo "
$SEPARATOR"
		basename "$FILE" | sed -e 's/\.log$//' | awk 'BEGIN {FS="_"} {print $2 " " $3 ": " $4 " -> " $5}'
		echo "$SEPARATOR"

		# Delete first 7 lines
		# Delete last 15 lines
		tail -n "+7" | sed -n -e :a -e '1,15!{P;N;D;};N;ba' < "$FILE"

	done
}

########################################################################
# log processing
########################################################################

##
# Replace '@', '/' and ':' to '-'.
##
_logfile_cleaner() {
	STRING="$*"

	STRING="$(echo "$STRING" | sed -e 's/@/#/g')"
	STRING="$(echo "$STRING" | sed -e 's/\//-/g')"
	STRING="$(echo "$STRING" | sed -e 's/:/#/g')"
	STRING="$(echo "$STRING" | sed -e 's/---/-/g')"
	STRING="$(echo "$STRING" | sed -e 's/--/-/g')"
	STRING="$(echo "$STRING" | sed -e 's/-\./\./g')"
	STRING="$(echo "$STRING" | sed -e 's/-_-/_/g')"

	echo "$STRING"
}

##
# Create the log file and add meta informations to the head of the log file.
##
_log_init() {
	if [ ! -d "$LOG_FOLDER_HOST" ]; then
		mkdir "$LOG_FOLDER_HOST"
	fi

	LOG_FILE_HOST="$LOG_FOLDER_HOST/log_$(_logfile_cleaner "${DATE}_${HOSTNAME}_${SOURCE}_${DESTINATION}.log")"
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

	DECORATION="$1"

	if [ "$DECORATION" = 'YES' ]; then

		echo "$SEPARATOR

												#					 #
###	## # # ##	###		 ###	## ### # # # # ###
#		#	### # # #	 ### # # # # #	 ##	# # # #
#	 ##		# # # ###		 ### ### ### # # ### ###
				###																 #
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
	MAIL_COMMAND=$(command -v mail)
	if [ -n "$MAIL_COMMAND" ]; then

		LINES=$(wc -l < "$LOG_FILE_HOST")
		STATUS=""
		VALUE="25"

		# shellcheck disable=SC2034
		for i in 1 2 3 4 5 6 7 ; do
			if [ "$LINES" -gt "$VALUE" ]; then
				STATUS="$STATUS#"
			fi

			VALUE=$((VALUE + 10))
		done

		# $HOSTNAME
		# DATE_SHORT=$(date "+%d-%b %H:%M")
		# $DATE_SHORT
		maillog.sh "#rb [$SOURCE] -> [$DESTINATION] $STATUS ($FILE_TRANSFERRED transferred files)" "$LOG_FILE_HOST"
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
	WRITE_TO_SUMMARY=0
	START_SUMMARY=''
	STOP_SUMMARY=''
	NOT_EMPTY_LINE=''
	FILE_TRANSFERRED=''

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

		FILE_TRANSFERRED=$(echo "$DATA" | grep 'files transferred:' | awk '{print $NF;}')

		# A piped while loop runs in its own subshell, so we need to make this
		# over tmp info files.
		if [ ! -z "$FILE_TRANSFERRED" ]; then
			echo "$FILE_TRANSFERRED" > "$INFO_PATH$IDENTIFIER"
		fi

	done
}

##
# Process send_nsca to nagios.
##
_nsca_process() {
	easy-nsca.sh -o "RSYNC OK: Files transfered: $FILE_TRANSFERRED; Activity: $STATUS" "RSYNC ${SOURCE} ${DESTINATION}"
	echo "Send NSCA: RSYNC ${SOURCE} ${DESTINATION}"
	echo "Message: RSYNC OK: Files transfered: $FILE_TRANSFERRED; Activity: $STATUS"
}

########################################################################
# Misc
########################################################################

_date() {
	date +%Y-%m-%dT%H-%M-%S
}

_split_colon() {
	echo "$1" | cut -d ':' -f "$2"
}

_make_zfs_path() {
	echo "${1%/}" | sed -e 's/\/mnt\///g'
}

_zfs_snapshot() {
	# e. g.: wnas:/mnt/zpool/shares/ or /mnt/zpool/shares/
	if [ "$DESTINATION" != "${DESTINATION%:*}" ]; then
		REMOTE_HOST=$(_split_colon "$DESTINATION" 1)
		ZFS_PATH=$(_split_colon "$DESTINATION" 2)
		SSH="ssh $REMOTE_HOST"
	else
		ZFS_PATH="$DESTINATION"
	fi

	ZFS_PATH=$(_make_zfs_path "$ZFS_PATH")
	if [ "$FILE_TRANSFERRED" -ge 1 ]; then
		$SSH zfs snapshot "$ZFS_PATH@rb_$(_date)"
		echo "Making snapshot."
	fi
}

_get_info() {
	cat "$INFO_PATH$IDENTIFIER"
}

_generate_identifier() {
	# Unix timestamp, $$ is pid.
	echo "$(date +%s)-$$"
}

##
# Show a short help text.
##
_help_show() {
	echo "Usage: rsync-backup [-adefhlLmnNz] <source> <destination>

DESCRIPTION
	A wrapper command for rsync with the main features:
		- Backups in in the folder '$BACKUP_FOLDER'
		- Logging per e mail.
		- Source und destination folder checks over scp.

OPTIONS
	-a <path>: Creates a $RSYNC_FOLDER/$AFFIRMATION_FILE affirmation file for the given folder.
	-b: Beep.
	-d: Delete all log file in the log folder.
	-e: Show execution log.
	-f: Show folder log files.
	-h: Show help.
	-i <identifier>: Provide a identifier, to get informations across multiple
	subshells
	-l: Show log summary.
	-L: Show log folder.
	-n: No backup.
	-N: Send NSCA message to nagios.
	-z: Create ZFS snapshot.

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
}

########################################################################
# Process
########################################################################

while getopts ":a:bdef:hi:lLnNz" OPT; do
	case $OPT in

		a)
			_create_affirmation_file "$OPTARG"
			exit 0
			;;

		b)
			BEEP=1
			;;

		d)
			_log_delete
			exit 0
			;;

		e)
			_log_execution_show
			exit 0
			;;

		f)
			_show_folder_logs "$OPTARG"
			exit 0
			;;

		h)
			_help_show
			exit 0
			;;

		i)
			IDENTIFIER="$OPTARG"
			;;

		l)
			_log_summary_show
			exit 0
			;;

		L)
			_log_show_folder
			exit 0
			;;

		n)
			NO_BACKUP=1
			;;

		N)
			NSCA=1
			;;

		z)
			ZFS_SNAPSHOT=1
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

if [ -z "$IDENTIFIER" ]; then
	IDENTIFIER=$(_generate_identifier)
fi

_check_accessiblity

_log_init

_log_header "YES"

# shellcheck disable=SC2046
rsync $(_process_options) $(_process_source_destination) | _log_process

FILE_TRANSFERRED=$(_get_info)

if [ -n "$ZFS_SNAPSHOT" ]; then
	_zfs_snapshot
fi

_log_mail

_log_execution

_log_file_copy "$SOURCE"
_log_file_copy "$DESTINATION"

if [ -n "$NSCA" ]; then
	_nsca_process
fi

if [ -n "$BEEP" ]; then
	beepbox.sh success
fi
