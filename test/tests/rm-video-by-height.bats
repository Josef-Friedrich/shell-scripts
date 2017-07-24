#!/usr/bin/env bats

@test "execute: rm-video-by-height.sh" {
	skip
	run ./rm-video-by-height.sh
	[ "$status" -eq 1 ]
	[ "${lines[0]}" = "" ]
}
