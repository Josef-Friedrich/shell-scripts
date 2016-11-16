#!/usr/bin/env bats

@test "execute: zfs-diff-walkthrough.sh" {
	run ./zfs-diff-walkthrough.sh
	[ "$status" -eq 1 ]
	[ "${lines[0]}" = "Command 'zfs' is not installed!" ]
}
