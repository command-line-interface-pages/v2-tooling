# PREFIX: sets the installation prefix
PREFIX?=/home/$(USER)/.local/bin

script=md-to-clip

.PHONY: install
install:
	cp -nv ./$(script).sh $(PREFIX)/$(script)
	chmod +x $(PREFIX)/$(script)

.PHONY: uninstall
uninstall:
	rm -v $(PREFIX)/$(script)

.PHONY: tests
tests:
	bats tests.bats
