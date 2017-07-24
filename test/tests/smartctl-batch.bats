#!/usr/bin/env bats

@test "execute: smartctl-batch.sh" {
	if [ "$(whoami)" = root ]; then
		if command -v smartctl > /dev/null 2>&1; then
			[ "$status" -eq 64 ]
		else
			[ "$status" -eq 1 ]
			[ "${lines[0]}" = "Please install 'smartctl'!" ]
		fi
	else
		skip
	fi
}

@test "execute: smartctl-batch.sh -h" {
	run ./smartctl-batch.sh -h
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "Usage: ./smartctl-batch.sh <options>" ]
}

@test "execute: smartctl-batch.sh --help" {
	run ./smartctl-batch.sh --help
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "Usage: ./smartctl-batch.sh <options>" ]
}
