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
