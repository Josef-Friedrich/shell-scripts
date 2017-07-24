#!/usr/bin/env bats

@test "execute: bandwidth-limiting-single-host.sh" {
	run ./bandwidth-limiting-single-host.sh
	[ "$status" -eq 1 ]
	[ "${lines[0]}" = "Usage: bandwidth-limiting-single-host.sh <dest> <bandwidth>" ]
}

@test "execute: bandwidth-limiting-single-host.sh -h" {
	run ./bandwidth-limiting-single-host.sh -h
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "Usage: bandwidth-limiting-single-host.sh <dest> <bandwidth>" ]
}
