#!/usr/bin/env bats

@test "execute: rsync-backup.sh" {
	run ./rsync-backup.sh
	[ "$status" -eq 1 ]
	[ "${lines[0]}" = 'The folders are not accessible or no affirmation file exists!' ]
}

@test "execute: rsync-backup.sh -h" {
	run ./rsync-backup.sh -h
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = 'Usage: rsync-backup [-abBdehlLmN] <source> <destination>' ]
}

@test "rsync-backup.sh: Basic sync" {
  TMP1=$(mktemp -d)
  TMP2=$(mktemp -d)
	./rsync-backup.sh -a "$TMP1"
	[ -f "$TMP1/.rsync-backup/please-sync" ]
	./rsync-backup.sh -a "$TMP2"
	[ -f "$TMP2/.rsync-backup/please-sync" ]
	echo lol > $TMP1/lol1
	echo lol > $TMP1/lol2
	./rsync-backup.sh $TMP1 $TMP2
	[ -f "$TMP2/lol1" ]
	[ -f "$TMP2/lol2" ]
}

@test "rsync-backup.sh: Basic sync via _execute" {
  TMP1=$(mktemp -d)
  TMP2=$(mktemp -d)
	source ./rsync-backup.sh
	run _execute -h
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = 'Usage: rsync-backup [-abBdehlLmN] <source> <destination>' ]
	run _execute -a "$TMP1"
	[ -f "$TMP1/.rsync-backup/please-sync" ]
	run _execute -a "$TMP2"
	[ -f "$TMP2/.rsync-backup/please-sync" ]
}

@test "unittest: variables" {
	source ./rsync-backup.sh
	[ "$LOG_FOLDER_HOST" = "$HOME/rsync-backup-logs" ]
	[ "$RSYNC_FOLDER" = ".rsync-backup" ]
	[ "$BACKUP_FOLDER" = ".rsync-backup/backups" ]
	[ -n "$DATE" ]
	[ "$TMP_FOLDER" = "/tmp/.rsync-backup" ]
	[ "$AFFIRMATION_FILE" = "please-sync" ]
	[ "$EXCLUDE_FILE" = "excludes" ]
	[ "$SEPARATOR" = '################################################' ]
	[ "$DEFAULT_EXCLUDES" = '--exclude .rsync_shadow --exclude .snapshots' ]
}

@test "unittest: function _trim_value" {
	source ./rsync-backup.sh
	VALUE=" 1 2 3 4 "
  run _trim_value $VALUE
	[ "$output" = "1" ]
  run _trim_value lol troll
	[ "$output" = "lol" ]
}

@test "unittest: function _extract_value" {
	source ./rsync-backup.sh
	VALUE="line 1: 1
line 2: 2
line 3: 3
line 4: 4
"

	[ "$(_extract_value "$VALUE" 1)" = "1" ]
	[ "$(_extract_value "$VALUE" 2)" = "2" ]
	[ "$(_extract_value "$VALUE" 3)" = "3" ]
}

@test "unittest: function _parse_statistics" {
	source ./rsync-backup.sh
  INPUT="sending incremental file list

Number of files: 1 (dir: 1)
Number of created files: 2
Number of deleted files: 3
Number of regular files transferred: 4
Total file size: 5 bytes
Total transferred file size: 6 bytes
Literal data: 7 bytes
Matched data: 8 bytes
File list size: 9
File list generation time: 10.001 seconds
File list transfer time: 11.000 seconds
Total bytes sent: 12
Total bytes received: 13

sent 65 bytes  received 17 bytes  164.00 bytes/sec
total size is 0  speedup is 0.00"

	_parse_statistics "$INPUT"
	[ "$STAT_NUM_FILES" = "1" ]
	[ "$STAT_NUM_CREATED_FILES" = "2" ]
	[ "$STAT_NUM_DELETED_FILES" = "3" ]
	[ "$STAT_NUM_FILES_TRANSFERRED" = "4" ]
	[ "$STAT_TOTAL_SIZE" = "5" ]
	[ "$STAT_TRANSFERRED_SIZE" = "6" ]
	[ "$STAT_LITERAL_DATA" = "7" ]
	[ "$STAT_MATCHED_DATA" = "8" ]
	[ "$STAT_LIST_SIZE" = "9" ]
	[ "$STAT_LIST_GENERATION_TIME" = "10.001" ]
	[ "$STAT_LIST_TRANSFER_TIME" = "11.000" ]
	[ "$STAT_BYTES_SENT" = "12" ]
	[ "$STAT_BYTES_RECEIVED" = "13" ]
}
