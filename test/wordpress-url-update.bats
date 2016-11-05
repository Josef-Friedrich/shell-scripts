#! /bin/bash

@test "execute: wordpress-url-update.sh" {
  run ./wordpress-url-update.sh
	echo $lines > log
  [ "$status" -eq 1 ]
  #[ "$lines[0]" = "Usage: wordpress-update-url.sh" ]
  #[ "$lines[0]" = "No or incomplete informations about the MySQL connection!" ]
}

@test "execute: wordpress-url-update.sh -h" {
  run ./wordpress-url-update.sh -h
  [ "$status" -eq 0 ]
  #[ "$lines[0]" = "Usage: wordpress-url-update.sh" ]
}
