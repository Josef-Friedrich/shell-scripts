#!/usr/bin/env bats

@test "execute: beepbox.sh" {
	skip
	run ./beepbox.sh
	if ! command -v beep > /dev/null 2>&1; then
		[ "$status" -eq 1 ]
		[ "${lines[0]}" = "Please install 'beep'!" ]
	else
		[ "$status" -eq 0 ]
	fi
}

@test "execute: beepbox.sh -h" {
	run ./beepbox.sh -h
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "Usage: beepbox.sh [error|success|sync-start|sync-end|warning]" ]

}
