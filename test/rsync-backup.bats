#!/usr/bin/env bats

@test "execute: rsync-backup.sh" {
	run ./rsync-backup.sh
	[ "$status" -eq 1 ]
	[ "${lines[0]}" = 'The folders are not accessible or no affirmation file exists!' ]
}

@test "execute: rsync-backup.sh -h" {
	run ./rsync-backup.sh -h
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = 'Usage: rsync-backup [-adefhlLmnNz] <source> <destination>' ]
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

@test "unittest: function _parse_statistics" {
	source ./rsync-backup.sh
  INPUT="sending incremental file list

Number of files: 1 (dir: 1)
Number of created files: 0
Number of deleted files: 0
Number of regular files transferred: 0
Total file size: 0 bytes
Total transferred file size: 0 bytes
Literal data: 0 bytes
Matched data: 0 bytes
File list size: 0
File list generation time: 0.001 seconds
File list transfer time: 0.000 seconds
Total bytes sent: 65
Total bytes received: 17

sent 65 bytes  received 17 bytes  164.00 bytes/sec
total size is 0  speedup is 0.00"

	_parse_statistics "$INPUT"
	[ "$STAT_LOL" = "Literal data: 0 bytes" ]
}
