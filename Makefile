.PHONY: all test

all: test

test:
	-./test/bats/bin/bats test/tests
	-./test/bash_unit test/tests/*.bash_unit
