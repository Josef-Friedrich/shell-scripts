.PHONY: all test bash_unit bats

all: test

test: split bash_unit bats clean

bash_unit:
	./test/bash_unit test/tests/*.bash_unit

bats:
	./test/bats/bin/bats test/tests

readme:
	cat ./README-base.md > README.md ; \
	for COMMAND in $$(find . -maxdepth 1 -iname "*.sh" | sort); do \
		echo $$COMMAND ; \
		echo >> README.md ; \
		echo "## $$COMMAND" >> README.md ; \
		echo >> README.md ; \
		echo "\`\`\`" >> README.md ; \
		$$COMMAND -h >> README.md ; \
		echo "\`\`\`" >> README.md ; \
	done

split:
	for COMMAND in $$(find . -maxdepth 1 -iname "*.sh"); do \
		echo $$COMMAND ; \
		csplit \
			--prefix=$$COMMAND. \
			$$COMMAND \
			'/### This SEPARATOR is needed for the tests. Do not remove it! ##########/' ; \
	done

clean:
	find .  -iname "*.0[01]" -exec rm -f {} \;
