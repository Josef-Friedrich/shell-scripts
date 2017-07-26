.PHONY: all test bash_unit bats 

all: test

test: bash_unit bats

bash_unit:
	-./test/bash_unit test/tests/*.bash_unit

bats:
	-./test/bats/bin/bats test/tests
