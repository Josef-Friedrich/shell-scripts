#!/usr/bin/env bats

T='./test/tests/mscore-to-eps/'

@test "execute: mscore-to-eps.sh ${T}no-mscore" {
	run ./mscore-to-eps.sh "$T"no-mscore
	[ "$status" -eq 1 ]
	[ "${lines[0]}" = "No files to convert found!" ]
}

@test "execute: mscore-to-eps.sh -h" {
	run ./mscore-to-eps.sh -h
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "Usage: mscore-to-eps.sh [-h] [-n] [<path>]" ]
}

@test "execute: mscore-to-eps.sh ${T}single-page.mscx" {
	[ "$TRAVIS" != 'true' ] || skip
	run ./mscore-to-eps.sh "$T"single-page.mscx
	[ "$status" -eq 0 ]
	[ -f "$T"single-page.eps ]
	rm -f "$T"single-page.eps
}

@test "execute: mscore-to-eps.sh ${T}multiple-pages.mscx" {
	[ "$TRAVIS" != 'true' ] || skip
	run ./mscore-to-eps.sh "$T"multiple-pages.mscx
	[ "$status" -eq 0 ]
	[ -f "$T"multiple-pages_1.eps ]
	rm -f "$T"multiple-pages_1.eps
	[ -f "$T"multiple-pages_2.eps ]
	rm -f "$T"multiple-pages_2.eps
}

@test "execute: mscore-to-eps.sh ${T}" {
	[ "$TRAVIS" != 'true' ] || skip
	run ./mscore-to-eps.sh "$T"
	[ "$status" -eq 0 ]
	[ -f "$T"single-page.eps ]
	rm -f "$T"single-page.eps
	[ -f "$T"multiple-pages_1.eps ]
	rm -f "$T"multiple-pages_1.eps
	[ -f "$T"multiple-pages_2.eps ]
	rm -f "$T"multiple-pages_2.eps
}

@test "unittest: _pdf_pages" {
	[ "$TRAVIS" != 'true' ] || skip
	source ./mscore-to-eps.sh

	[ "$(_pdf_pages "$T"PDF_one-page.pdf)" -eq 1 ]
	[ "$(_pdf_pages "$T"PDF_two-pages.pdf)" -eq 2 ]
}

@test "unittest: _pdftops" {
	[ "$TRAVIS" != 'true' ] || skip
	if command -v pdfcrop > /dev/null 2>&1; then
		source ./mscore-to-eps.sh
		_pdftops "$T"PDF_two-pages.pdf 2
		[ -f "$T"PDF_two-pages_2.eps ]
		rm -f "$T"PDF_two-pages_2.eps
	else
		skip
	fi
}
