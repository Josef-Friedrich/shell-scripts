#!/usr/bin/env bats

@test "execute: rm-by-extension.sh" {
	run ./rm-by-extension.sh
	[ "$status" -eq 1 ]
	[ "${lines[0]}" = 'Usage: rm-by-extension.sh <extension>' ]
}
