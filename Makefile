.PHONY: all test bash_unit bats

get = wget -O $(1) \
	https://raw.githubusercontent.com/Josef-Friedrich/$(1)/master/$(1) ; \
	chmod a+x $(1)

all: test

test: bats

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

get_upstream:
	$(call get,imagemagick-imslp.sh)
	$(call get,mscore-to-eps.sh)
	$(call get,rsync-backup.sh)
	$(call get,easy-nsca.sh)
	$(call get,maillog.sh)
	$(call get,wordpress-url-update.sh)
	$(call get,zfs-delete-empty-snapshots.sh)
