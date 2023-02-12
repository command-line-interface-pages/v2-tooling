# PREFIX: sets the installation prefix
PREFIX?=/home/$(USER)/.local/bin

script=clip-view

.PHONY: install
install:
	cp -nv ./$(script).sh $(PREFIX)/$(script)
	chmod +x $(PREFIX)/$(script)

.PHONY: uninstall
uninstall:
	rm -v $(PREFIX)/$(script)

.PHONY: tests
tests:
	echo No tests available yet.
