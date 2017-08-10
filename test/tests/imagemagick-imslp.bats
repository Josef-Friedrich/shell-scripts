#!/usr/bin/env bats

@test "execute: imagemagick-imslp.sh" {
	run ./imagemagick-imslp.sh
	[ "$status" -eq 1 ]
	[ "${lines[0]}" = "Usage: imagemagick-imslp.sh [-bcfhrt] <filename-or-glob-pattern>" ]
}

@test "execute: imagemagick-imslp.sh -h" {
	run ./imagemagick-imslp.sh -h
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "Usage: imagemagick-imslp.sh [-bcfhrt] <filename-or-glob-pattern>" ]
}
