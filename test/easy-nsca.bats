#!/usr/bin/env bats

@test "execute: easy-nsca.sh" {
  run ./easy-nsca.sh
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Usage: easy-nsca.sh [<options>] <service> <check-command>" ]
}

@test "execute: easy-nsca.sh -h" {
  run ./easy-nsca.sh -h
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Usage: easy-nsca.sh [<options>] <service> <check-command>" ]
}
