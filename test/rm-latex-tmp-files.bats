#!/usr/bin/env bats

@test "execute: rm-latex-tmp-files.sh" {
	skip
	run ./rm-latex-tmp-files.sh
	[ "$status" -eq 1 ]
	[ "${lines[0]}" = "" ]
}
