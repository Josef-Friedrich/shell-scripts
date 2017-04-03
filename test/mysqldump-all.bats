#!/usr/bin/env bats

@test "execute: mysqldump-all.sh" {
	run ./mysqldump-all.sh
	[ "$status" -eq 1 ]
	[ "${lines[0]}" = "Usage: mysqldump-all.sh -u <username> -p <password>" ]
}
