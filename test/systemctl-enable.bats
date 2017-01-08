#!/usr/bin/env bats

@test "execute: systemctl-enable.sh -h" {
	run ./systemctl-enable.sh -h
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "Usage: systemctl-enable.sh <unit-file>" ]
}

@test "execute: systemctl-enable.sh --help" {
	run ./systemctl-enable.sh --help
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "Usage: systemctl-enable.sh <unit-file>" ]
}
