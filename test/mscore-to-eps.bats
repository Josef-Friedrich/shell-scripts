#!/usr/bin/env bats

@test "execute: mscore-to-eps.sh" {
  run ./mscore-to-eps.sh test/mscore-to-eps/no-mscore
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "No files to convert found!" ]
}

@test "execute: mscore-to-eps.sh -h" {
  run ./mscore-to-eps.sh -h
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Usage: mscore-to-eps.sh [-h] [<musescore-file>]" ]
}

@test "execute: mscore-to-eps.sh test/mscore-to-eps/single-page.mscx" {
  [ "$TRAVIS" != 'true' ] || skip
  run ./mscore-to-eps.sh test/mscore-to-eps/single-page.mscx
  [ "$status" -eq 0 ]
  [ -f test/mscore-to-eps/single-page.eps ]
}


@test "unittest: _pdf_pages" {
  [ "$TRAVIS" != 'true' ] || skip
  source ./mscore-to-eps.sh

  [ "$(_pdf_pages ./test/mscore-to-eps/PDF_one-page.pdf)" -eq 1 ]
  [ "$(_pdf_pages ./test/mscore-to-eps/PDF_two-pages.pdf)" -eq 2 ]
}
