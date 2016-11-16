#!/usr/bin/env bats

@test "execute: zfs-snapshot-recursive.sh" {
	run ./zfs-snapshot-recursive.sh
	[ "$status" -eq 1 ]
	[ "${lines[0]}" = "Command 'zpool' is not installed!" ]
}

@test "execute: zfs-snapshot-recursive.sh -h" {
	run ./zfs-snapshot-recursive.sh -h
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "Usage: zfs-snapshot-recursive.sh <snapshot-name>" ]
}

@test "execute: zfs-snapshot-recursive.sh --help" {
	run ./zfs-snapshot-recursive.sh --help
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "Usage: zfs-snapshot-recursive.sh <snapshot-name>" ]
}
