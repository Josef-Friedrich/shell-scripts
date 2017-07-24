.PHONY: all test

all: test

test:
	./test/bash_unit test/tests/*.bash_unit
