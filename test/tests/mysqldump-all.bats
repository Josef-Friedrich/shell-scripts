#!/usr/bin/env bats

@test "execute: mysqldump-all.sh" {
	run ./mysqldump-all.sh
	[ "$status" -eq 1 ]
	[ "${lines[0]}" = "Usage: mysqldump-all.sh -u <username> -p <password>" ]
}

@test "execute: mysqldump-all.sh -h" {
	run ./mysqldump-all.sh -h
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "Usage: mysqldump-all.sh -u <username> -p <password>" ]
}
